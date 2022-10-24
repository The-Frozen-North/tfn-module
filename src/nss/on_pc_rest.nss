#include "inc_persist"
#include "inc_general"
#include "inc_horse"
#include "inc_nwnx"
#include "inc_henchman"
#include "inc_follower"
#include "util_i_csvlists"
#include "x0_i0_position"
#include "nwnx_area"
#include "nwnx_visibility"
#include "inc_restxp"

// this function gets all creatures near a location and interrupts their rest + prevents resting for a bit
// typically this should be applied to a campfire (uses around the same radius for creatures attaching to a campfire)
void InterruptRest(location lLocation)
{
    object oCreature = GetFirstObjectInShape(SHAPE_SPHERE, 31.0, lLocation);

    while (GetIsObjectValid(oCreature))
    {
        if (GetIsResting(oCreature))
        {
            AssignCommand(oCreature, ClearAllActions());
            SetLocalInt(oCreature, "ambushed", 1);
            DelayCommand(12.0, DeleteLocalInt(oCreature, "ambushed"));
        }

        oCreature = GetNextObjectInShape(SHAPE_SPHERE, 31.0, lLocation);
    }
}

void ApplySleepVFX(object oCreature)
{
    if (GetRacialType(oCreature) == RACIAL_TYPE_ELF) return;

    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_SLEEP), oCreature);
}

void AnnounceRemainingRevivesOnCreature(object oCreature)
{
    int nTimesRevived = GetTimesRevived(oCreature);
    
    string sReviveMessage = "*" + GetName(oCreature);

    if (nTimesRevived >= 3)
    {
        sReviveMessage += " cannot be revived without Raise Dead*";
    }
    else if (nTimesRevived == 2)
    {
        sReviveMessage += " can be revived one more time*";
    }
    else if (nTimesRevived == 1)
    {
        sReviveMessage += " can be revived two more times*";
    }
    
    if (nTimesRevived > 0)
    {
        FloatingTextStringOnCreature(sReviveMessage, oCreature, TRUE);
    }
}

void AnnounceRemainingRevives(object oPC)
{
    AnnounceRemainingRevivesOnCreature(oPC);
    int nIndex = 0;
    while (1)
    {
        object oHench = GetHenchmanByIndex(oPC, nIndex);
        if (!GetIsObjectValid(oHench))
        {
            break;
        }
        AnnounceRemainingRevivesOnCreature(oHench);
        nIndex++;
    }
    nIndex = 0;
    while (1)
    {
        object oHench = GetFollowerByIndex(oPC, nIndex);
        if (!GetIsObjectValid(oHench))
        {
            break;
        }
        AnnounceRemainingRevivesOnCreature(oHench);
        nIndex++;
    }
}

void main()
{
    object oPC = GetLastPCRested();

    if (GetLocalInt(oPC, "ambushed") == 1)
    {
        SendMessageToPC(oPC, "You cannot rest while you are being ambushed.");
        AssignCommand(oPC, ClearAllActions());
        return;
    }

    object oArea = GetArea(oPC);
    object oObjectLoop, oCurrentPC, oCampfire, oValidator, oAmbushSpawn;
    location lLocation = GetLocation(oPC);
    float fFacing = GetFacing(oPC);
    location lTarget = GenerateNewLocation(oPC, 1.5, fFacing, fFacing);
    int bRanger = FALSE;
    int bHarperScout = FALSE;
    int nAmbushRoll, nAmbushChance, nEnemyGroup;
    int nEnemyGroups = 0;
    int nHideClassChance = 0;
    int nHideChance = 10;
    float fAmbushTime;
    string sHideClass;
    string sHidePrepend = "You manage to hide away from enemies (";
    string sHideAppend = " bonus).";
    string sHide = "You manage to hide away from enemies.";
    string sSpotted = "You have been spotted by enemies!";
    int i, nSlot;
    object oItem = GetFirstItemInInventory(oPC);

    float fSize = 30.0;

    switch (GetLastRestEventType())
    {
        case REST_EVENTTYPE_REST_STARTED:

            SendDebugMessage("Event: REST_STARTED");

// prevent PC from resting when there are enemies in line of sight
            oObjectLoop = GetFirstObjectInShape(SHAPE_SPHERE, fSize, lLocation, TRUE, OBJECT_TYPE_CREATURE);
            while (GetIsObjectValid(oObjectLoop))
            {
                if (GetIsReactionTypeHostile(oPC, oObjectLoop) && !GetIsDead(oObjectLoop))
                {
                    FloatingTextStringOnCreature("You cannot rest when there are enemies nearby.", oPC, FALSE);
                    AssignCommand(oPC, ClearAllActions());
                    return;
                    break;
                }

                oObjectLoop = GetNextObjectInShape(SHAPE_SPHERE, fSize, lLocation, TRUE, OBJECT_TYPE_CREATURE);
            }

            RemoveMount(oPC);


// =======================================
// START REST AMBUSH CODE
// =======================================

// only the first 7
            for (i = 1; i < 8; i++)
            {
                if (GetLocalString(oArea, "random"+IntToString(i)) != "") nEnemyGroups++;
            }
            SendDebugMessage("pvp area: "+IntToString(NWNX_Area_GetPVPSetting(oArea)));
            if (NWNX_Area_GetPVPSetting(oArea) > 0)
            {
// only do ambushes if there are random enemy groups
                if ((GetLocalInt(oArea, "ambush") == 1) && (nEnemyGroups > 0))
                {
                    nAmbushChance = 40; // any rolls 10 is not an ambush either. essentially this is 30% chance of an ambush occuring
                }
                else
                {
                    nAmbushChance = 0;
                }

// loop through waypoints to see if there is a rest in progress, in which case we will use if exists
                oObjectLoop = GetFirstObjectInShape(SHAPE_SPHERE, fSize, lLocation, FALSE, OBJECT_TYPE_PLACEABLE);
                while (GetIsObjectValid(oObjectLoop))
                {
                    if (GetTag(oObjectLoop) == "_campfire")
                    {
                        SendDebugMessage("oCampfire found, rest in progress.");
                        oCampfire = oObjectLoop;
                        break;
                    }

                    oObjectLoop = GetNextObjectInShape(SHAPE_SPHERE, fSize, lLocation, FALSE, OBJECT_TYPE_PLACEABLE);
                }

// if it doesnt exist, create a rest in progress
                if (!GetIsObjectValid(oCampfire))
                {
                   SendDebugMessage("oCampfire was not found, creating a rest in progress.");
// spawn a creature to determine if this is valid spawn point
                   oValidator = CreateObject(OBJECT_TYPE_CREATURE, "_cf_validator", lTarget);

                   oCampfire = CreateObject(OBJECT_TYPE_PLACEABLE, "_campfire", GetLocation(oValidator), FALSE, "_campfire");

                   DelayCommand(30.0, AssignCommand(oCampfire, PlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE)));
                   DestroyObject(oCampfire, 60.0);

                   DestroyObject(oValidator);

// loop through PCs in the same vicinity to check if there is a ranger or harper scout
                   oCurrentPC = GetFirstPC();
                   while(oCurrentPC != OBJECT_INVALID)
                   {

// the party member must be in the same area and distance to count
                      if((GetArea(oCurrentPC) == oArea) && (GetDistanceBetween(oCurrentPC, oPC) <= fSize))
                      {
// rangers and harper scouts reduce the chance of an ambush. having both however doesn't stack
                          if (GetLevelByClass(CLASS_TYPE_RANGER, oCurrentPC) >= 1)
                          {
                                SendDebugMessage("Ranger was found in rest vicinity.");
                                bRanger = TRUE;
                          }
                          if (GetLevelByClass(CLASS_TYPE_HARPER, oCurrentPC) >= 1)
                          {
                                SendDebugMessage("Harper Scout was found in rest vicinity.");
                                bHarperScout = TRUE;
                          }
                      }
                      oCurrentPC = GetNextPC();
                    }

                    if (bRanger || bHarperScout) nHideClassChance = nAmbushChance/2;

                    nAmbushRoll = d100();

                    int bSafeRest = FALSE;
                    object oSafeRest = GetNearestObjectByTag("_safe_rest");
                    float fDistanceToSafeRest = GetDistanceBetween(oPC, oSafeRest);
                    if (GetIsObjectValid(oSafeRest) && fDistanceToSafeRest > 0.0 && fDistanceToSafeRest < 50.0)
                    {
                        bSafeRest = TRUE;
                    }
                    else if (!GetIsObjectValid(GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oPC, 1, CREATURE_TYPE_IS_ALIVE, TRUE)))
                    {
                        bSafeRest = TRUE;
                    }

                    if (bSafeRest)
                    {
                        SendDebugMessage("Setting ambush chance and roll to 20 due safe rest");
                        nAmbushChance = 0;
                        nAmbushRoll = 20; // this is set so "hiding from enemies" text isnt shown
                    }

                    SendDebugMessage("Ambush roll: "+IntToString(nAmbushRoll));
                    SendDebugMessage("Ambush chance: "+IntToString(nAmbushChance));
                    SendDebugMessage("Hide chance: "+IntToString(nHideChance));
                    SendDebugMessage("Hide class chance: "+IntToString(nHideClassChance));
// 10% of the time the ambush will never trigger with a message
                    if (nAmbushRoll <= 10)
                    {
                        SetLocalInt(oCampfire, "hide", 1);
                    }
// if there is a ranger or harper scout, decrease the chance of an ambush
                    if (nAmbushRoll <= nHideChance)
                    {
                       if (bRanger && bHarperScout)
                        {
                            switch (d2())
                            {
                                case 1: sHideClass = "Ranger"; break;
                                case 2: sHideClass = "Harper Scout"; break;
                            }
                        }
                        else if (bRanger) {sHideClass = "Ranger";}
                        else if (bHarperScout) {sHideClass = "Harper Scout";}

                        SetLocalString(oCampfire, "hide_class", sHideClass);
                        DelayCommand(50.0, AssignCommand(oCampfire, PlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE)));
                        DestroyObject(oCampfire, 60.0);
                    }
// otherwise, trigger an ambush
                    else if (nAmbushRoll <= nAmbushChance)
                    {
                        fAmbushTime = IntToFloat(4+d6());
                        SendDebugMessage("Ambush will be created in: "+FloatToString(fAmbushTime)+" seconds");

// we will spawn a creature that will run to a specified spawn point. this will simulate a creature spawning from somewhere
// instead of it spawning on top of the player
                        object oAmbushSpawn = CreateObject(OBJECT_TYPE_CREATURE, "_ambush_spawn", lLocation);

// make this ambush spawn a ghost and have set it to be invisible to everyone
                        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectCutsceneGhost(), oAmbushSpawn);
                        NWNX_Visibility_SetVisibilityOverride(OBJECT_INVALID, oAmbushSpawn, NWNX_VISIBILITY_HIDDEN);

// store some values on the ambush spawn itself
                        SetLocalObject(oAmbushSpawn, "pc", oPC);
                        SetLocalLocation(oAmbushSpawn, "pc_location", lLocation);
                        SetLocalInt(oAmbushSpawn, "target", Random(nEnemyGroups)+1); // the random spawn target that will be stored and used

// make it run away from the PC's location
                        AssignCommand(oAmbushSpawn, ActionMoveAwayFromLocation(lLocation, TRUE, 45.0));

                        DelayCommand(fAmbushTime+1.0, AssignCommand(oCampfire, PlayAnimation(ANIMATION_PLACEABLE_DEACTIVATE)));
                        DestroyObject(oCampfire, fAmbushTime+10.0);
                        DelayCommand(fAmbushTime, ExecuteScript("create_ambush", oAmbushSpawn));
                        DelayCommand(fAmbushTime, FloatingTextStringOnCreature(sSpotted, oPC, FALSE));

                        DelayCommand(fAmbushTime, InterruptRest(GetLocation(oCampfire)));
                    }
                 }
                 sHideClass = GetLocalString(oCampfire, "hide_class");

                 if (GetLocalInt(oCampfire, "hide") == 1) {FloatingTextStringOnCreature(sHide, oPC, TRUE);}
                 else if ((sHideClass == "Ranger") || (sHideClass == "Harper Scout")) {FloatingTextStringOnCreature(sHidePrepend+sHideClass+sHideAppend, oPC, FALSE);}
            }
// =======================================
// END REST AMBUSH CODE
// =======================================

            ApplySleepVFX(GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, 1));
            ApplySleepVFX(GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, 2));
            ApplySleepVFX(GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, 3));
            ApplySleepVFX(GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, 4));
            ApplySleepVFX(GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, 5));
            ApplySleepVFX(GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, 6));
            ApplySleepVFX(GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, 7));
            ApplySleepVFX(GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, 8));
            ApplySleepVFX(GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, 9));

            ApplySleepVFX(GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oPC, 1));
            ApplySleepVFX(GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oPC, 2));
            ApplySleepVFX(GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPC, 1));
            ApplySleepVFX(GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPC, 2));

            ApplySleepVFX(oPC);

            DelayCommand(0.1,FadeToBlack(oPC,FADE_SPEED_FAST));
            DelayCommand(2.6, FadeFromBlack(oPC, FADE_SPEED_MEDIUM));
        break;
        case REST_EVENTTYPE_REST_FINISHED:
            //DeleteLocalInt(oPC, "invis");
            DeleteLocalInt(oPC, "gsanc");
            DeleteLocalInt(oPC, "healers_kit_cd");
            GiveHiPSFeatSafely(oPC);

            while ( oItem != OBJECT_INVALID ) {
                IPRemoveAllItemProperties(oItem,DURATION_TYPE_TEMPORARY);
                oItem = GetNextItemInInventory(oPC);
            }

            for ( nSlot = 0; nSlot < NUM_INVENTORY_SLOTS; ++nSlot )
                IPRemoveAllItemProperties(GetItemInSlot(nSlot, oPC));


            if (GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPC))) DecrementRemainingFeatUses(oPC, FEAT_SUMMON_FAMILIAR);
            if (GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oPC)))  DecrementRemainingFeatUses(oPC, FEAT_ANIMAL_COMPANION);
            
            AnnounceRemainingRevives(oPC);
            GiveHouseRestingXP(oPC);
            SendRestedXPNotifierToPC(oPC);
            if (PlayerGetsRestedXPInArea(oPC))
            {
                if (!GetIsPlayerHomeless(oPC) && GetTag(oArea) == GetHomeTag(oPC))
                {
                    // GiveHouseRestingXP deals with messages in home
                }
                else
                {
                    SendMessageToPC(oPC, "You are gaining resting experience in this area. You do no need to repeatedly rest to accumulate this.");
                }
            }
            if (IsEligibleForHouseRestingXP(oPC))
            {
                SendMessageToPC(oPC, "You feel like you would benefit from a rest in your own home...");
            }

        case REST_EVENTTYPE_REST_CANCELLED:
            StopFade(oPC);
            SavePCInfo(oPC);
            if (GetPCPublicCDKey(oPC) != "") ExportSingleCharacter(oPC);
        break;
    }

}

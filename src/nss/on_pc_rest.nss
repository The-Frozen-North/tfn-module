#include "inc_persist"
#include "inc_general"
#include "inc_horse"
#include "util_i_csvlists"

string ChooseSpawnRef(object oArea, int nTarget)
{
    string sTarget = "random"+IntToString(nTarget);

    string sList = GetLocalString(oArea, sTarget+"_list");
    string sListUnique = GetLocalString(oArea, sTarget+"_list_unique");

    int nUniqueChance = GetLocalInt(oArea, sTarget+"_unique_chance");

    if (d100() <= nUniqueChance)
    {
        return GetListItem(sListUnique, Random(CountList(sListUnique)));
    }
    else
    {
        return GetListItem(sList, Random(CountList(sList)));
    }
}

void CreateAmbush(int nTarget, object oArea, location lLocation)
{
    string sSpawnScript = GetLocalString(oArea, "random"+IntToString(nTarget)+"_spawn_script");

    object oEnemy1 = CreateObject(OBJECT_TYPE_CREATURE, ChooseSpawnRef(oArea, nTarget), lLocation, TRUE);
    SetLocalInt(oEnemy1, "ambush", 1);
    if (sSpawnScript != "") ExecuteScript(sSpawnScript, oEnemy1);
    object oEnemy2 = CreateObject(OBJECT_TYPE_CREATURE, ChooseSpawnRef(oArea, nTarget), lLocation, TRUE);
    SetLocalInt(oEnemy2, "ambush", 1);
    if (sSpawnScript != "") ExecuteScript(sSpawnScript, oEnemy2);

    DestroyObject(oEnemy1, 300.0);
    DestroyObject(oEnemy2, 300.0);
}

void main()
{
    object oPC = GetLastPCRested();
    object oArea = GetArea(oPC);
    object oObjectLoop, oCurrentPC, oRestWP;
    location lLocation = GetLocation(oPC);
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
    int i;

    float fSize = 30.0;

    effect eSleep = EffectVisualEffect(VFX_IMP_SLEEP);

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

// only do ambushes if there are random enemy groups
            if ((GetLocalInt(oArea, "ambush") == 1) && (nEnemyGroups > 0))
            {

                nAmbushChance = 40;

// loop through waypoints to see if there is a rest in progress, in which case we will use if exists
                oObjectLoop = GetFirstObjectInShape(SHAPE_SPHERE, fSize, lLocation, FALSE, OBJECT_TYPE_WAYPOINT);
                while (GetIsObjectValid(oObjectLoop))
                {
                    if (GetTag(oObjectLoop) == "_rest_wp")
                    {
                        SendDebugMessage("oRestWP found, rest in progress.");
                        oRestWP = oObjectLoop;
                        break;
                    }

                    oObjectLoop = GetNextObjectInShape(SHAPE_SPHERE, fSize, lLocation, FALSE, OBJECT_TYPE_WAYPOINT);
                }

// if it doesnt exist, create a rest in progress
                if (!GetIsObjectValid(oRestWP))
                {
                   SendDebugMessage("oRestWP was not found, creating a rest in progress.");
                   oRestWP = CreateObject(OBJECT_TYPE_WAYPOINT, "nw_waypoint001", lLocation, FALSE, "_rest_wp");

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

                    SendDebugMessage("Ambush roll: "+IntToString(nAmbushRoll));
                    SendDebugMessage("Ambush chance: "+IntToString(nAmbushChance));
                    SendDebugMessage("Hide chance: "+IntToString(nHideChance));
                    SendDebugMessage("Hide class chance: "+IntToString(nHideClassChance));
// 10% of the time the ambush will never trigger with a message
                    if (nAmbushRoll <= 10)
                    {
                        SetLocalInt(oRestWP, "hide", 1);
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

                        SetLocalString(oRestWP, "hide_class", sHideClass);
                    }
// otherwise, trigger an ambush
                    else if (nAmbushRoll <= nAmbushChance)
                    {
                        fAmbushTime = IntToFloat(4+d6());
                        SendDebugMessage("Ambush will be created in: "+FloatToString(fAmbushTime)+" seconds");

                        DelayCommand(fAmbushTime, CreateAmbush(Random(nEnemyGroups)+1, oArea, lLocation));
                        DelayCommand(fAmbushTime, FloatingTextStringOnCreature(sSpotted, oPC, FALSE));
                    }

                    DestroyObject(oRestWP, 15.0);
                 }
                 sHideClass = GetLocalString(oRestWP, "hide_class");

                 if (GetLocalInt(oRestWP, "hide") == 1) {FloatingTextStringOnCreature(sHide, oPC, TRUE);}
                 else if ((sHideClass == "Ranger") || (sHideClass == "Harper Scout")) {FloatingTextStringOnCreature(sHidePrepend+sHideClass+sHideAppend, oPC, FALSE);}

             }
             else
             {
                SendDebugMessage("No random enemy spawns were found, so skipping ambush.");
             }
// =======================================
// END REST AMBUSH CODE
// =======================================

            ApplyEffectToObject(DURATION_TYPE_INSTANT, eSleep, GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, 1));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eSleep, GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, 2));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eSleep, GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, 3));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eSleep, GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, 4));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eSleep, GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, 5));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eSleep, GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, 6));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eSleep, GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, 7));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eSleep, GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, 8));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eSleep, GetAssociate(ASSOCIATE_TYPE_HENCHMAN, oPC, 9));

            ApplyEffectToObject(DURATION_TYPE_INSTANT, eSleep, GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oPC, 1));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eSleep, GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oPC, 2));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eSleep, GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPC, 1));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eSleep, GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPC, 2));

            ApplyEffectToObject(DURATION_TYPE_INSTANT, eSleep, oPC);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eSleep, oPC);


            DelayCommand(0.1,FadeToBlack(oPC,FADE_SPEED_FAST));
            DelayCommand(2.6, FadeFromBlack(oPC, FADE_SPEED_MEDIUM));
        break;
        case REST_EVENTTYPE_REST_FINISHED:
            DeleteLocalInt(oPC, "invis");

            if (GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oPC))) DecrementRemainingFeatUses(oPC, FEAT_SUMMON_FAMILIAR);
            if (GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oPC)))  DecrementRemainingFeatUses(oPC, FEAT_ANIMAL_COMPANION);

        case REST_EVENTTYPE_REST_CANCELLED:
            StopFade(oPC);
            SavePCInfo(oPC);
            if (GetPCPublicCDKey(oPC) != "") ExportSingleCharacter(oPC);
        break;
    }

}


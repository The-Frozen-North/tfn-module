#include "inc_persist"
#include "inc_debug"
#include "inc_henchman"
#include "inc_penalty"
#include "inc_quest"
#include "inc_sql"
#include "inc_general"
#include "inc_sqlite_time"
#include "inc_weather"
#include "nwnx_player"
#include "inc_horse"
#include "inc_restxp"

int GetIsDeadOrPetrified(object oCreature)
{
    if (GetHasPermanentPetrification(oCreature)) return TRUE;
    if (GetIsDead(oCreature)) return TRUE;

    return FALSE;
}

void ResetFactionsAttempt(object oPC)
{
// reset it if in combat
       if (GetIsInCombat(oPC))
       {
           DeleteLocalInt(oPC, "faction_reset");
           return;
       }

// on 5th hb continue, otherwise increment
       int nFactionReset = GetLocalInt(oPC, "faction_reset");
       if (nFactionReset < 4)
       {
           SetLocalInt(oPC, "faction_reset", nFactionReset + 1);
           return;
       }

       FactionReset(oPC);

       DeleteLocalInt(oPC, "faction_reset");
}

void DoRevive(object oDead)
{
        if (GetIsInCombat(oDead)) return;
        if (GetIsDeadOrPetrified(oDead))
        {
            SendDebugMessage(GetName(oDead)+" is dead, start revive loop");
            int bEnemy = FALSE;
            int bFriend = FALSE;
            int bMasterFound = FALSE;
            int nFaction, nRace;

            string sReviveMessage = "";

            int nTimesRevived = GetTimesRevived(oDead);

            if (nTimesRevived >= 3)
            {
                sReviveMessage = " can no longer be revived without raise dead*";
            }
            else if (nTimesRevived == 2)
            {
                sReviveMessage = " can be revived one more time*";
            }
            else if (nTimesRevived == 1)
            {
                sReviveMessage = " can be revived two more times*";
            }

            object oMaster = GetMasterByUUID(oDead);
            int bMasterDead = GetIsDeadOrPetrified(oMaster);

            object oLastFriend;

            location lLocation = GetLocation(oDead);

            float fSize = 30.0;

            float fMasterDistance = GetDistanceBetween(oDead, oMaster);
            if (fMasterDistance <= 90.0) bMasterFound = TRUE;

            if (GetArea(oMaster) != GetArea(oDead)) bMasterFound = FALSE;

            object oCreature = GetFirstObjectInShape(SHAPE_SPHERE, fSize, lLocation, TRUE, OBJECT_TYPE_CREATURE);

            while (GetIsObjectValid(oCreature))
            {
// do not count self and count only if alive
                if (!GetIsDeadOrPetrified(oCreature) && (oCreature != oDead))
                {
                    nRace = GetRacialType(oCreature);
                    // added check to see if they have a master, if so check if it is an enemy to their master as well
                    if (GetIsEnemy(oCreature, oDead) || (GetIsObjectValid(oMaster) && GetIsEnemy(oCreature, oMaster)))
                    {
                        bEnemy = TRUE;
                        SendDebugMessage("Enemy detected, breaking from revive loop: "+GetName(oCreature));
                        break;
                    }
                    else if (!bFriend && GetIsFriend(oCreature, oDead) && nRace != RACIAL_TYPE_ANIMAL && nRace != RACIAL_TYPE_VERMIN && !GetIsInCombat(oCreature))
                    {
                        bFriend = TRUE;
                        oLastFriend = oCreature;
                        SendDebugMessage("Friend detected: "+GetName(oCreature));
                    }
                    else if (nRace != RACIAL_TYPE_ANIMAL && nRace != RACIAL_TYPE_VERMIN && !bFriend && !GetIsInCombat(oCreature) && (GetIsFriend(oCreature, oDead) || GetIsNeutral(oCreature, oDead)))
                    {
                        nFaction = NWNX_Creature_GetFaction(oCreature);

                        if (nFaction == STANDARD_FACTION_COMMONER || nFaction == STANDARD_FACTION_DEFENDER || nFaction == STANDARD_FACTION_MERCHANT)
                        {
                            bFriend = TRUE;
                            oLastFriend = oCreature;
                            SendDebugMessage("Commoner/Defender/Merchant detected: "+GetName(oCreature));
                        }
                    }

                }

                oCreature = GetNextObjectInShape(SHAPE_SPHERE, fSize, lLocation, TRUE, OBJECT_TYPE_CREATURE);
            }

            if (GetStringLeft(GetResRef(oDead), 3) == "hen" && bMasterFound && !bMasterDead && !GetIsInCombat(oMaster))
            {
                oLastFriend = oMaster;
                bFriend = TRUE;
            }

            // don't revive if there's an enemy to the last friend
            object oLastEnemy = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oLastFriend, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
            if (GetIsObjectValid(oLastEnemy) && GetDistanceBetween(oLastFriend, oLastEnemy) < fSize)
            {
                SendDebugMessage("Friend has enemy detected, breaking from revive loop: "+GetName(oLastEnemy));
                bEnemy = TRUE;
            }

            if (!bEnemy && bFriend && IsCreatureRevivable(oDead))
            {
                if (GetHasPermanentPetrification(oDead))
                {
                    if (GetStoneToFleshSalveCharges(oDead) > 0)
                    {
                        UseStoneToFleshSalveCharge(oDead);
                        FloatingTextStringOnCreature("Your Salve of Stone to Flesh has " + IntToString(GetStoneToFleshSalveCharges(oDead)) + " uses remaining today.", oDead);
                        effect eEffect = GetFirstEffect(oDead);
                        while (GetIsEffectValid(eEffect))
                        {
                            if (GetEffectType(eEffect) == EFFECT_TYPE_PETRIFY)
                            {
                                if (GetEffectDurationType(eEffect) == DURATION_TYPE_PERMANENT)
                                {
                                    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DISPEL), oDead);
                                    RemoveEffect(oDead, eEffect);
                                }
                            }
                            eEffect = GetNextEffect(oDead);
                        }
                        if (GetIsPC(oDead))
                        {
                            SQLocalsPlayer_DeleteInt(oDead, "PETRIFIED");
                        }
                        DeleteLocalInt(oDead, "PETRIFIED");
                        object oFactionPC = GetFirstFactionMember(oDead);
                        while (GetIsObjectValid(oFactionPC))
                        {
                            if (GetIsObjectValid(oLastFriend))
                                NWNX_Player_FloatingTextStringOnCreature(oFactionPC, oDead, "*The power of "+GetName(oDead)+"'s Salve of Stone to Flesh was activated by "+GetName(oLastFriend)+".*");

                            if (sReviveMessage != "")
                                DelayCommand(3.0, NWNX_Player_FloatingTextStringOnCreature(oFactionPC, oDead, "*"+GetName(oDead)+sReviveMessage));

                            oFactionPC = GetNextFactionMember(oDead);
                        }
                    }
                }
                else
                {
                    SQLocalsPlayer_DeleteInt(oDead, "DEAD");
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oDead);
                    SetObjectVisualTransform(oDead, OBJECT_VISUAL_TRANSFORM_SCALE, 1.0);
                    SetObjectVisualTransform(oDead, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, 0.0);

                    DetermineDeathEffectPenalty(oDead, 1);

                    if (GetStringLeft(GetResRef(oDead), 3) == "hen" && bMasterFound) SetMaster(oDead, oMaster);

                    object oFactionPC = GetFirstFactionMember(oDead);
                    while (GetIsObjectValid(oFactionPC))
                    {
                        if (GetIsObjectValid(oLastFriend))
                            NWNX_Player_FloatingTextStringOnCreature(oFactionPC, oDead, "*"+GetName(oDead)+" was revived by "+GetName(oLastFriend)+".*");

                        if (sReviveMessage != "")
                            DelayCommand(3.0, NWNX_Player_FloatingTextStringOnCreature(oFactionPC, oDead, "*"+GetName(oDead)+sReviveMessage));

                        oFactionPC = GetNextFactionMember(oDead);
                    }
                }
                WriteTimestampedLogEntry(GetName(oDead)+" was revived by friendly "+GetName(oLastFriend)+".");
            }

// destroy henchman if still not alive and master isn't found
            if (!GetIsPC(oDead) && GetIsDeadOrPetrified(oDead) && GetStringLeft(GetResRef(oDead), 3) == "hen" && !bMasterFound)
            {
                 // how long has it been since I can't find my master after I'm dead?
                 int nNoMasterCount = GetLocalInt(oDead, "no_master_count");

                 // if dead for quite a while with no master, reset
                 if (nNoMasterCount >= MAX_NO_MASTER_COUNT)
                 {
                     ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_RESTORATION), lLocation);
                     ClearMaster(oDead);
                     DestroyObject(oDead);
                     // Delete their store if it exists or it will be floating around in memory until restart
                     object oStore = GetLocalObject(oDead, "merchant");
                     DestroyObject(oStore);
                 }
                 else // otherwise increment
                 {
                    SetLocalInt(oDead, "no_master_count", nNoMasterCount + 1);
                 }
            }
        }
}


void main()
{
    object oPC = GetFirstPC();
    object oModule = GetModule();

    ExportAllCharacters();



    string sBounties = GetLocalString(oModule, "bounties");

    if (GetIsObjectValid(oPC))
    {
        int nTickCount = GetTickRate();
        if (nTickCount <= 50) SendDebugMessage("Low tick count detected: "+IntToString(nTickCount), TRUE);
    }

    int nTime = SQLite_GetTimeStamp();

    while(GetIsObjectValid(oPC))
    {
        DoRevive(oPC);
        DetermineHorseEffects(oPC);
        RefreshCompletedBounties(oPC, nTime, sBounties);

        AddRestedXPHeartbeat(oPC);

        if (GetHasPermanentPetrification(oPC))
        {
            string sPenalty = IntToString(GetXP(oPC) - GetXPOnRespawn(oPC)) + " XP and " + IntToString(GetGoldLossOnRespawn(oPC)) + " gold";
            if (GetXP(oPC) < 3000)
            {
                sPenalty = "no penalty";
            }
            string sDeathMessage;
            if (GetStoneToFleshSalveCharges(oPC) > 0)
            {
                sDeathMessage = "The power of the Salve of Stone to Flesh will restore you if there is an ally nearby, there are no enemies, and you are out of combat, or you can respawn at your chosen temple for " + sPenalty + ". You will automatically respawn if you die while petrified.";
            }
            else
            {
                sDeathMessage = "You can wait for a greater restoration or stone to flesh spell, or you can respawn at your chosen temple for " + sPenalty + ". You will automatically respawn if you die while petrified.";
            }

            PopUpDeathGUIPanel(oPC, TRUE, TRUE, 0, sDeathMessage);
        }
        else if (!GetIsDead(oPC))
        {
            SQLocalsPlayer_DeleteInt(oPC, "DEAD");

            if (GetCurrentHitPoints(oPC) >= GetMaxHitPoints(oPC)/2)
                DeleteLocalInt(oPC, "dying_voice");
        }

        SavePCInfo(oPC);

        oPC = GetNextPC();
    }

    DoRevive(GetObjectByTag("hen_tomi"));
    DoRevive(GetObjectByTag("hen_daelan"));
    DoRevive(GetObjectByTag("hen_sharwyn"));
    DoRevive(GetObjectByTag("hen_linu"));
    DoRevive(GetObjectByTag("hen_boddyknock"));
    DoRevive(GetObjectByTag("hen_grimgnaw"));
    DoRevive(GetObjectByTag("hen_valen"));
    DoRevive(GetObjectByTag("hen_nathyrra"));
    DoRevive(GetObjectByTag("hen_bim"));
    DoRevive(GetObjectByTag("hen_xanos"));
    DoRevive(GetObjectByTag("hen_dorna"));
    DoRevive(GetObjectByTag("hen_mischa"));

    int nWeatherCount = GetLocalInt(oModule, "weather_count");
    int nWeatherDuration = GetLocalInt(oModule, "weather_duration");

    if (nWeatherDuration < 10)
        nWeatherDuration = nWeatherCount;

    //SendDebugMessage("weather count: "+IntToString(nWeatherCount)+" weather duration: "+IntToString(nWeatherDuration));

    if (nWeatherCount > nWeatherDuration)
    {
        SetGlobalWeather();
        DeleteLocalInt(oModule, "weather_count");
    }
    else
    {
        SetLocalInt(oModule, "weather_count", nWeatherCount+1);
    }

// only do this if there isn't a yesgar in the module yet
    if (!GetIsObjectValid(GetObjectByTag("yesgar")))
    {
        object oModule = GetModule();
        int nYesgarCount = GetLocalInt(oModule, "yesgar_count");

// only spawn yesgar if 200 module heartbeats have passed
        if (nYesgarCount > 200)
        {
// yesgar will spawn on a random location
            CreateObject(OBJECT_TYPE_CREATURE, "yesgar", GetLocation(GetObjectByTag("YESGAR_SPAWN"+IntToString(d4()))));
            DeleteLocalInt(oModule, "yesgar_count");
        }
        else
        {
            SetLocalInt(oModule, "yesgar_count", nYesgarCount + 1);
        }
    }
}

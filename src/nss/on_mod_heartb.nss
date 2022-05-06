#include "inc_persist"
#include "inc_debug"
#include "inc_henchman"
#include "inc_penalty"
#include "inc_quest"
#include "nwnx_util"
#include "inc_sql"
#include "inc_general"
#include "inc_sqlite_time"
#include "inc_weather"
#include "nwnx_player"
#include "inc_horse"

int GetIsDeadOrPetrified(object oCreature)
{
    if (GetHasEffect(EFFECT_TYPE_PETRIFY, oCreature)) return TRUE;
    if (GetIsDead(oCreature)) return TRUE;

    return FALSE;
}

void DoRevive(object oDead)
{
        if (GetIsInCombat(oDead)) return;
        if (GetIsDead(oDead))
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
                SQLocalsPlayer_DeleteInt(oDead, "DEAD");
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectResurrection(), oDead);

                DetermineDeathEffectPenalty(oDead, 1);

                if (GetStringLeft(GetResRef(oDead), 3) == "hen" && bMasterFound) SetMaster(oDead, oMaster);

                object oFactionPC = GetFirstFactionMember(oDead);
                while (GetIsObjectValid(oFactionPC))
                {
                    if (GetIsObjectValid(oLastFriend))
                        NWNX_Player_FloatingTextStringOnCreature(oFactionPC, oDead, "*"+GetName(oDead)+" was revived by "+GetName(oLastFriend)+".");

                    if (sReviveMessage != "")
                        DelayCommand(3.0, NWNX_Player_FloatingTextStringOnCreature(oFactionPC, oDead, "*"+GetName(oDead)+sReviveMessage));

                    oFactionPC = GetNextFactionMember(oDead);
                }
                WriteTimestampedLogEntry(GetName(oDead)+" was revived by friendly "+GetName(oLastFriend)+".");
            }

// destroy henchman if still not alive and master isn't found
            if (!GetIsPC(oDead) && GetIsDeadOrPetrified(oDead) && GetStringLeft(GetResRef(oDead), 3) == "hen" && !bMasterFound)
            {
                 ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_RESTORATION), lLocation);
                 ClearMaster(oDead);
                 DestroyObject(oDead);
            }
        }
}


void main()
{
    object oPC = GetFirstPC();

    ExportAllCharacters();

    object oModule = GetModule();

    string sBounties = GetLocalString(oModule, "bounties");

    if (GetIsObjectValid(oPC))
    {
        int nTickCount = NWNX_Util_GetServerTicksPerSecond();
        if (nTickCount <= 50) SendDebugMessage("Low tick count detected: "+IntToString(nTickCount), TRUE);
    }

    int nTime = SQLite_GetTimeStamp();

    while(GetIsObjectValid(oPC))
    {
        DoRevive(oPC);
        DetermineHorseEffects(oPC);
        RefreshCompletedBounties(oPC, nTime, sBounties);

        if (GetHasEffect(EFFECT_TYPE_PETRIFY, oPC))
        {
            string sPenalty = IntToString(GetXP(oPC) - GetXPOnRespawn(oPC)) + " XP and " + IntToString(GetGoldLossOnRespawn(oPC)) + " gold";
            string sDeathMessage = "You can wait for a greater restoration or stone to flesh spell, or you can respawn at your chosen temple for " + sPenalty + ". You will automatically respawn if you die while petrified.";

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

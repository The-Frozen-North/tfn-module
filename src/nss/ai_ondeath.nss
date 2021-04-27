//#include "gs_inc_common"
//#include "gs_inc_effect"
//#include "gs_inc_encounter"
#include "inc_ai_event"
//#include "gs_inc_flag"
#include "inc_ai_time"
//#include "gs_inc_xp"
#include "inc_respawn"
#include "inc_general"
#include "inc_henchman"
#include "inc_follower"
#include "nwnx_area"


//const string GS_TEMPLATE_CORPSE  = "gs_placeable016";
//const string GS_BOSS_HEAD_MEGA   = "gs_item393";
//const string GS_BOSS_HEAD_HIGH   = "gs_item386";
//const string GS_BOSS_HEAD_MEDIUM = "gs_item390";
//const string GS_BOSS_HEAD_LOW    = "gs_item391";
//const string GS_BOSS_HEAD_MINI   = "gs_item392";
//const int GS_TIMEOUT             = 21600; //6 hours
//const int GS_LIMIT_VALUE         = 10000;

void main()
{
    SignalEvent(OBJECT_SELF, EventUserDefined(GS_EV_ON_DEATH));

//    gsFXBleed();
//    SetLocalInt(OBJECT_SELF, "GS_TIMEOUT", gsTIGetActualTimestamp() + GS_TIMEOUT);

    object oKiller = GetLastKiller();

    if (GetIsObjectValid(oKiller) && GetObjectType(oKiller) == OBJECT_TYPE_CREATURE && oKiller != OBJECT_SELF)
    {
            SpeakString("GS_AI_ATTACK_TARGET", TALKVOLUME_SILENT_TALK);
    }

    StartRespawn();

// only give credit if a PC or their associate killed it or if it was already tagged
    if (GetIsPC(GetMaster(oKiller)) || GetIsPC(oKiller) || (GetLocalInt(OBJECT_SELF, "player_tagged") == 1))
    {
        ExecuteScript("party_credit", OBJECT_SELF);
    }

// Set for no credit after first death so no multiple credit is rewarded (cases of rez or resurrection)
    SetLocalInt(OBJECT_SELF, "no_credit", 1);

// dismiss henchman when killing innocent in non-pvp area
    if ((GetStandardFactionReputation(STANDARD_FACTION_COMMONER, OBJECT_SELF) >= 50 || GetStandardFactionReputation(STANDARD_FACTION_DEFENDER, OBJECT_SELF) >= 50) && NWNX_Area_GetPVPSetting(GetArea(OBJECT_SELF)) == NWNX_AREA_PVP_SETTING_NO_PVP)
    {
        object oMurderer;

        if (GetIsPC(GetMaster(oKiller)))
        {
            oMurderer = GetMaster(oKiller);
        }
        else if (GetIsPC(oKiller))
        {
            oMurderer = oKiller;
        }

        if (GetIsObjectValid(oMurderer))
        {
            object oHench = GetFirstFactionMember(oMurderer, FALSE);

            while (GetIsObjectValid(oHench))
            {

                if (GetMaster(oHench) == oMurderer)
                {

                    if (GetLocalInt(oHench, "follower") == 1) { DismissFollower(oHench); }
                    else if (GetStringLeft(GetResRef(oHench), 3) == "hen") { DismissHenchman(oHench); }
                }

                oHench = GetNextFactionMember(oMurderer, FALSE);
            }
        }
    }

    TakeGoldFromCreature(1000, OBJECT_SELF, TRUE);

//    if (gsFLGetFlag(GS_FL_MORTAL)) gsCMDestroyInventory();

        string sScript = GetLocalString(OBJECT_SELF, "death_script");
    if (sScript != "") ExecuteScript(sScript);

    if (GibsNPC(OBJECT_SELF))
    {
        DoMoraleCheckSphere(OBJECT_SELF, 16);
    }
    else
    {
        DoMoraleCheckSphere(OBJECT_SELF, 12);
    }
}

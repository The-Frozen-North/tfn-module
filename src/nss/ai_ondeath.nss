#include "inc_ai_event"
#include "inc_ai_time"
//#include "inc_respawn"
#include "inc_general"
#include "inc_henchman"
#include "inc_follower"
#include "inc_webhook"
#include "nwnx_area"

void main()
{
    SignalEvent(OBJECT_SELF, EventUserDefined(GS_EV_ON_DEATH));

//    gsFXBleed();
//    SetLocalInt(OBJECT_SELF, "GS_TIMEOUT", gsTIGetActualTimestamp() + GS_TIMEOUT);

    object oKiller = GetLastKiller();

// get teammate's attention if i was killed
    if (GetIsObjectValid(oKiller))
        SpeakString("GS_AI_ATTACK_TARGET", TALKVOLUME_SILENT_TALK);

    //StartRespawn();

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

        if (GetIsPC(oMurderer))
            AdjustAlignment(oMurderer, ALIGNMENT_EVIL, 5, FALSE);

        if (GetIsObjectValid(oMurderer))
        {
            object oHench = GetFirstFactionMember(oMurderer, FALSE);

            while (GetIsObjectValid(oHench))
            {

                if (GetMaster(oHench) == oMurderer)
                {
                    // skip grimgnaw
                    if (GetLocalInt(oHench, "follower") == 1 && GetResRef(oHench) != "hen_grimgnaw") { DismissFollower(oHench); }
                    else if (GetStringLeft(GetResRef(oHench), 3) == "hen") { DismissHenchman(oHench); }
                }

                oHench = GetNextFactionMember(oMurderer, FALSE);
            }
        }
    }

    TakeGoldFromCreature(1000, OBJECT_SELF, TRUE);

    DestroyPet(OBJECT_SELF);
    object eAOE = GetLocalObject(OBJECT_SELF, "aoe_to_cleanup");
    if (GetIsObjectValid(eAOE))
    {
        AssignCommand(eAOE, SetIsDestroyable(TRUE));
        AssignCommand(eAOE, DestroyObject(eAOE, 0.5));
    }

    if (GetLocalInt(OBJECT_SELF, "defeated_webhook") == 1)
    {
        BossDefeatedWebhook(oKiller, OBJECT_SELF);
    }

//    if (gsFLGetFlag(GS_FL_MORTAL)) gsCMDestroyInventory();

    string sScript = GetLocalString(OBJECT_SELF, "death_script");
    if (sScript != "") ExecuteScript(sScript);

    if (GibsNPC(OBJECT_SELF))
    {
        DoMoraleCheckSphere(OBJECT_SELF, MORALE_PANIC_GIB_DC);
    }
    else
    {
        DoMoraleCheckSphere(OBJECT_SELF, MORALE_PANIC_DEATH_DC);
    }
}

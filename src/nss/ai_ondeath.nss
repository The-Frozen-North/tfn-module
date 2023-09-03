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
// TODO: Handle traps

// dismiss henchman when killing innocents
    if (GetStandardFactionReputation(STANDARD_FACTION_COMMONER, OBJECT_SELF) >= 50 || GetStandardFactionReputation(STANDARD_FACTION_DEFENDER, OBJECT_SELF) >= 50)
    {
        object oMurderer;

        string sResRef = GetResRef(oKiller);

        // simple case, use the PC if they killed the innocent
        if (GetIsPC(oKiller))
        {
            oMurderer = oKiller;
        }
        // otherwise, if the killer is evil or NOT a henchman, use their master if present (associate case)
        else if ((GetAlignmentGoodEvil(oKiller) == ALIGNMENT_EVIL || GetAssociateType(oKiller) != ASSOCIATE_TYPE_HENCHMAN) && GetIsPC(GetMaster(oKiller)))
        {
            oMurderer = GetMaster(oKiller);
        }
        // final try, if the killer is a henchman or follower, AND not evil in a friendly (non-pvp) area, associate the master as the murderer
        else if (GetAlignmentGoodEvil(oKiller) != ALIGNMENT_EVIL && GetAssociateType(oKiller) == ASSOCIATE_TYPE_HENCHMAN && NWNX_Area_GetPVPSetting(GetArea(oKiller)) == NWNX_AREA_PVP_SETTING_NO_PVP && GetIsPC(GetMaster(oKiller)))
        {
            oMurderer = GetMaster(oKiller);    
        }
        // anyone else who kills an innocent won't count, for example if Boddyknock or a mage follower casted a fireball or something at a group of enemies
        // this may introduce a loophole where a PC could kill an innocent with a non-evil henchman and not count as murder in pvp areas

        if (GetIsPC(oMurderer))
            AdjustAlignment(oMurderer, ALIGNMENT_EVIL, 5, FALSE);

        if (GetIsObjectValid(oMurderer))
        {
            IncrementPlayerStatistic(oMurderer, "innocents_killed");

            ExecuteScript("party_credit", OBJECT_SELF);
            
            object oHench = GetFirstFactionMember(oMurderer, FALSE);

            while (GetIsObjectValid(oHench))
            {

                if (GetMaster(oHench) == oMurderer)
                {
                    // only dismiss henchman and followers that are not evil
                    if (GetAlignmentGoodEvil(oHench) != ALIGNMENT_EVIL)
                    {
                        // dismiss followers and henchman
                        if (GetLocalInt(oHench, "follower") == 1) { DismissFollower(oHench); }                  
                        else if (GetStringLeft(GetResRef(oHench), 3) == "hen") { DismissHenchman(oHench); }
                    }
                }

                oHench = GetNextFactionMember(oMurderer, FALSE);
            }
        }
    }
    else if (GetIsPC(GetMaster(oKiller)) || GetIsPC(oKiller) || (GetLocalInt(OBJECT_SELF, "player_tagged") == 1))
    {
        ExecuteScript("party_credit", OBJECT_SELF);
    }

    if (GetLocalString(OBJECT_SELF, "heartbeat_script") == "fol_heartb")
    {
        IncrementPlayerStatistic(GetMaster(OBJECT_SELF), "followers_died");
    }

    // not counting associates. we should count summons though
    object oPCToIncrementOn = oKiller;
    
    if (GetIsPC(GetMaster(oKiller)))
    {
        int nAssociateType = GetAssociateType(oKiller);

        if (nAssociateType == ASSOCIATE_TYPE_FAMILIAR || nAssociateType == ASSOCIATE_TYPE_ANIMALCOMPANION || nAssociateType == ASSOCIATE_TYPE_DOMINATED || nAssociateType == ASSOCIATE_TYPE_SUMMONED)
        {
            oPCToIncrementOn = GetMaster(oKiller);
        }
    }
    
    if (GetIsPC(oPCToIncrementOn))
    {
        int nCR = GetLocalInt(OBJECT_SELF, "cr");
        IncrementPlayerStatistic(oPCToIncrementOn, "enemies_killed");

        if (GetLocalInt(OBJECT_SELF, "boss") == 1)
        {
            nCR++;
            IncrementPlayerStatistic(oPCToIncrementOn, "bosses_killed");
        }
        else if (GetLocalInt(OBJECT_SELF, "rare") == 1)
        {
            nCR++;
            IncrementPlayerStatistic(oPCToIncrementOn, "rares_killed");
        }
        
        int nOldMaxCR = GetPlayerStatistic(oPCToIncrementOn, "most_powerful_cr");
        if (nCR > nOldMaxCR)
        {
            SetPlayerStatistic(oPCToIncrementOn, "most_powerful_cr", nCR);
            SetPlayerStatisticString(oPCToIncrementOn, "most_powerful_killed", GetName(OBJECT_SELF));
        }
    }

// Set for no credit after first death so no multiple credit is rewarded (cases of rez or resurrection)
    SetLocalInt(OBJECT_SELF, "no_credit", 1);

    TakeGoldFromCreature(1000, OBJECT_SELF, TRUE);

    DestroyPet(OBJECT_SELF);
    
    json jAOEs = GetLocalJson(OBJECT_SELF, "aoe_to_cleanup");
    int nCount = JsonGetLength(jAOEs);
    int i;
    for (i=0; i<nCount; i++)
    {
        object oAOE = StringToObject(JsonGetString(JsonArrayGet(jAOEs, i)));
        if (GetIsObjectValid(oAOE))
        {
            SendDebugMessage("Destroy old aoe: " + ObjectToString(oAOE));
            AssignCommand(oAOE, SetIsDestroyable(TRUE));
            AssignCommand(oAOE, DestroyObject(oAOE, 0.5));
        }
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

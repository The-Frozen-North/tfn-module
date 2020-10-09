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
/*
    int nKiller    = GetIsObjectValid(oKiller) &&
                     GetObjectType(oKiller) == OBJECT_TYPE_CREATURE &&
                    oKiller != OBJECT_SELF;
    int nOverride  = gsFLGetAreaFlag("PVP") ||
                     gsFLGetAreaFlag("OVERRIDE_DEATH");

    if (! nOverride)
    {
        if (nKiller)
        {

            //reward
            if (! GetLocalInt(OBJECT_SELF, "GS_STATIC") ||
                gsENGetIsEncounterCreature() ||
                gsBOGetIsBossCreature())
            {
                gsXPRewardKill();
            }

            if (! gsFLGetFlag(GS_FL_DISABLE_CALL))
                SpeakString("GS_AI_ATTACK_TARGET", TALKVOLUME_SILENT_TALK);
        }

        if (! gsFLGetFlag(GS_FL_DISABLE_LOOT))
        {
            //create corpse
            object oCorpse = CreateObject(OBJECT_TYPE_PLACEABLE,
                                          GS_TEMPLATE_CORPSE,
                                          GetLocation(OBJECT_SELF));

            if (GetIsObjectValid(oCorpse))
            {
                //set name
                SetName(oCorpse, GetName(OBJECT_SELF));

                //create boss head
                if (gsBOGetIsBossCreature())
                {
                    string sTemplate       = "";
                    float fChallengeRating = GetChallengeRating(OBJECT_SELF);

                    if (fChallengeRating >= 20.0)      sTemplate = GS_BOSS_HEAD_MEGA;
                    else if (fChallengeRating >= 15.0) sTemplate = GS_BOSS_HEAD_HIGH;
                    else if (fChallengeRating >= 10.0) sTemplate = GS_BOSS_HEAD_MEDIUM;
                    else if (fChallengeRating >= 5.0)  sTemplate = GS_BOSS_HEAD_LOW;
                    else                               sTemplate = GS_BOSS_HEAD_MINI;

                    CreateItemOnObject(sTemplate);
                }

                //transfer inventory
                object oSelf = OBJECT_SELF;

                AssignCommand(oCorpse, gsDropLoot(oSelf));
                return;
            }
        }
    }
*/
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












/*
void _gsDropLoot()
{
    SetPlotFlag(OBJECT_SELF, FALSE);

    if (! GetIsObjectValid(GetFirstItemInInventory()))
    {
        DestroyObject(OBJECT_SELF);
        return;
    }

    DelayCommand(60.0, ExecuteScript("gs_run_destroy", OBJECT_SELF));
}
//----------------------------------------------------------------
void gsDropLoot(object oSource)
{
    object oItem = OBJECT_INVALID;
    int nMortal  = gsFLGetFlag(GS_FL_MORTAL, oSource);
    int nValue   = 0;

    //gold
    TakeGoldFromCreature(GetGold(oSource), oSource);

    //creature slots
    if (nMortal)
    {
        oItem = GetItemInSlot(INVENTORY_SLOT_CARMOUR,   oSource);
        if (GetIsObjectValid(oItem)) DestroyObject(oItem);
        oItem = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B, oSource);
        if (GetIsObjectValid(oItem)) DestroyObject(oItem);
        oItem = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L, oSource);
        if (GetIsObjectValid(oItem)) DestroyObject(oItem);
        oItem = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R, oSource);
        if (GetIsObjectValid(oItem)) DestroyObject(oItem);

        oItem = GetItemInSlot(INVENTORY_SLOT_ARMS, oSource);

        if (GetIsObjectValid(oItem))
        {
            nValue = gsCMGetItemValue(oItem);

            if (nValue < GS_LIMIT_VALUE)
            {
                SetIdentified(oItem, nValue <= 100);
                ActionTakeItem(oItem, oSource);
            }
            else
            {
                DestroyObject(oItem);
            }
        }

        oItem = GetItemInSlot(INVENTORY_SLOT_ARROWS, oSource);

        if (GetIsObjectValid(oItem))
        {
            nValue = gsCMGetItemValue(oItem);

            if (nValue < GS_LIMIT_VALUE)
            {
                SetIdentified(oItem, nValue <= 100);
                ActionTakeItem(oItem, oSource);
            }
            else
            {
                DestroyObject(oItem);
            }
        }

        oItem = GetItemInSlot(INVENTORY_SLOT_BELT, oSource);

        if (GetIsObjectValid(oItem))
        {
            nValue = gsCMGetItemValue(oItem);

            if (nValue < GS_LIMIT_VALUE)
            {
                SetIdentified(oItem, nValue <= 100);
                ActionTakeItem(oItem, oSource);
            }
            else
            {
                DestroyObject(oItem);
            }
        }

        oItem = GetItemInSlot(INVENTORY_SLOT_BOLTS, oSource);

        if (GetIsObjectValid(oItem))
        {
            nValue = gsCMGetItemValue(oItem);

            if (nValue < GS_LIMIT_VALUE)
            {
                SetIdentified(oItem, nValue <= 100);
                ActionTakeItem(oItem, oSource);
            }
            else
            {
                DestroyObject(oItem);
            }
        }

        oItem = GetItemInSlot(INVENTORY_SLOT_BOOTS, oSource);

        if (GetIsObjectValid(oItem))
        {
            nValue = gsCMGetItemValue(oItem);

            if (nValue < GS_LIMIT_VALUE)
            {
                SetIdentified(oItem, nValue <= 100);
                ActionTakeItem(oItem, oSource);
            }
            else
            {
                DestroyObject(oItem);
            }
        }

        oItem = GetItemInSlot(INVENTORY_SLOT_BULLETS, oSource);

        if (GetIsObjectValid(oItem))
        {
            nValue = gsCMGetItemValue(oItem);

            if (nValue < GS_LIMIT_VALUE)
            {
                SetIdentified(oItem, nValue <= 100);
                ActionTakeItem(oItem, oSource);
            }
            else
            {
                DestroyObject(oItem);
            }
        }

        oItem = GetItemInSlot(INVENTORY_SLOT_CHEST, oSource);

        if (GetIsObjectValid(oItem))
        {
            nValue = gsCMGetItemValue(oItem);

            if (nValue < GS_LIMIT_VALUE)
            {
                SetIdentified(oItem, nValue <= 100);
                ActionTakeItem(oItem, oSource);
            }
            else
            {
                DestroyObject(oItem);
            }
        }

        oItem = GetItemInSlot(INVENTORY_SLOT_CLOAK, oSource);

        if (GetIsObjectValid(oItem))
        {
            nValue = gsCMGetItemValue(oItem);

            if (nValue < GS_LIMIT_VALUE)
            {
                SetIdentified(oItem, nValue <= 100);
                ActionTakeItem(oItem, oSource);
            }
            else
            {
                DestroyObject(oItem);
            }
        }

        oItem = GetItemInSlot(INVENTORY_SLOT_HEAD, oSource);

        if (GetIsObjectValid(oItem))
        {
            nValue = gsCMGetItemValue(oItem);

            if (nValue < GS_LIMIT_VALUE)
            {
                SetIdentified(oItem, nValue <= 100);
                ActionTakeItem(oItem, oSource);
            }
            else
            {
                DestroyObject(oItem);
            }
        }

        oItem = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oSource);

        if (GetIsObjectValid(oItem))
        {
            nValue = gsCMGetItemValue(oItem);

            if (nValue < GS_LIMIT_VALUE)
            {
                SetIdentified(oItem, nValue <= 100);
                ActionTakeItem(oItem, oSource);
            }
            else
            {
                DestroyObject(oItem);
            }
        }

        oItem = GetItemInSlot(INVENTORY_SLOT_LEFTRING, oSource);

        if (GetIsObjectValid(oItem))
        {
            nValue = gsCMGetItemValue(oItem);

            if (nValue < GS_LIMIT_VALUE)
            {
                SetIdentified(oItem, nValue <= 100);
                ActionTakeItem(oItem, oSource);
            }
            else
            {
                DestroyObject(oItem);
            }
        }

        oItem = GetItemInSlot(INVENTORY_SLOT_NECK, oSource);

        if (GetIsObjectValid(oItem))
        {
            nValue = gsCMGetItemValue(oItem);

            if (nValue < GS_LIMIT_VALUE)
            {
                SetIdentified(oItem, nValue <= 100);
                ActionTakeItem(oItem, oSource);
            }
            else
            {
                DestroyObject(oItem);
            }
        }

        oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oSource);

        if (GetIsObjectValid(oItem))
        {
            nValue = gsCMGetItemValue(oItem);

            if (nValue < GS_LIMIT_VALUE)
            {
                SetIdentified(oItem, nValue <= 100);
                ActionTakeItem(oItem, oSource);
            }
            else
            {
                DestroyObject(oItem);
            }
        }

        oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTRING, oSource);

        if (GetIsObjectValid(oItem))
        {
            nValue = gsCMGetItemValue(oItem);

            if (nValue < GS_LIMIT_VALUE)
            {
                SetIdentified(oItem, nValue <= 100);
                ActionTakeItem(oItem, oSource);
            }
            else
            {
                DestroyObject(oItem);
            }
        }
    }

    //inventory
    oItem = GetFirstItemInInventory(oSource);

    while (GetIsObjectValid(oItem))
    {
        nValue = gsCMGetItemValue(oItem);

        if ((nMortal || GetDroppableFlag(oItem)) &&
            nValue < GS_LIMIT_VALUE)
        {
            SetIdentified(oItem, nValue <= 100);
            ActionTakeItem(oItem, oSource);
        }
        else if (nMortal)
        {
            DestroyObject(oItem);
        }

        oItem = GetNextItemInInventory(oSource);
    }

    ActionDoCommand(_gsDropLoot());
}
*/
//----------------------------------------------------------------

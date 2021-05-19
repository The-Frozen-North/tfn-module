#include "inc_ai"
//#include "gs_inc_boss"
//#include "gs_inc_common"
//#include "gs_inc_encounter"
#include "inc_ai_event"
//#include "gs_inc_flag"
#include "inc_ai_time"
#include "inc_respawn"
#include "nwnx_creature"
#include "inc_loot"

void CopyKey()
{
// duplicate the key but make it unpickpocketable/undroppable
    object oItem = GetFirstItemInInventory();
    object oNewItem;

    while (GetIsObjectValid(oItem))
    {
        if (GetBaseItemType(oItem) == BASE_ITEM_KEY)
        {
            oNewItem = CopyItem(oItem, OBJECT_SELF, TRUE);
            SetDroppableFlag(oNewItem, FALSE);
            SetPickpocketableFlag(oNewItem, FALSE);
            break;
        }

        oItem = GetNextItemInInventory();
    }
}

//const int GS_TIMEOUT = 7200; //2 hours

void main()
{
    SignalEvent(OBJECT_SELF, EventUserDefined(GS_EV_ON_SPAWN));



    //listen
    SetListenPattern(OBJECT_SELF, "GS_AI_ATTACK_TARGET",         10000);
    SetListenPattern(OBJECT_SELF, "GS_AI_REQUEST_REINFORCEMENT", 10003);
    SetListenPattern(OBJECT_SELF, "GS_AI_INNOCENT_ATTACKED", 10100);
    SetListening(OBJECT_SELF, TRUE);

    //set action matrix
    gsAISetActionMatrix(gsAIGetDefaultActionMatrix());

    if (GetWeaponRanged(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND))) SetLocalInt(OBJECT_SELF, "range", 1);
    if (IPGetIsMeleeWeapon(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND))) SetLocalInt(OBJECT_SELF, "offhand", 1);
    //set random facing
    //SetFacing(IntToFloat(Random(360)));

//    SetLocalLocation(OBJECT_SELF, "GS_LOCATION", GetLocation(OBJECT_SELF));
//    SetLocalInt(OBJECT_SELF, "GS_TIMEOUT", gsTIGetActualTimestamp() + GS_TIMEOUT);

    int iAreaCR = GetLocalInt(GetArea(OBJECT_SELF), "cr");

    switch (GetRacialType(OBJECT_SELF))
    {
        case RACIAL_TYPE_DWARF:
        case RACIAL_TYPE_ELF:
        case RACIAL_TYPE_GNOME:
        case RACIAL_TYPE_HALFLING:
        case RACIAL_TYPE_HALFORC:
        case RACIAL_TYPE_HUMAN:
        case RACIAL_TYPE_HALFELF:
            if (GetLocalInt(OBJECT_SELF, "no_potion") != 1 && d4() == 1)
            {
                object oPotion = CreateItemOnObject("cure_potion1", OBJECT_SELF);
                SetDroppableFlag(oPotion, FALSE);
                SetPickpocketableFlag(oPotion, TRUE);
            }

            if (d10() == 1)
            {
                object oItem = GenerateTierItem(GetHitDice(OBJECT_SELF), iAreaCR, OBJECT_SELF, "Misc");
                SetDroppableFlag(oItem, FALSE);
                SetPickpocketableFlag(oItem, TRUE);
            }

            object oGold = CreateItemOnObject("nw_it_gold001", OBJECT_SELF, d2(GetHitDice(OBJECT_SELF)));
            SetDroppableFlag(oGold, FALSE);
            SetPickpocketableFlag(oGold, TRUE);
        break;
    }


    NWNX_Creature_SetCorpseDecayTime(OBJECT_SELF, 1200000);
    NWNX_Creature_SetDisarmable(OBJECT_SELF, TRUE);

// Set cr integer on self. This is used for determining treasure.
    float fCR = GetChallengeRating(OBJECT_SELF);

    if (GetLocalInt(OBJECT_SELF, "boss"))
    {
        fCR = fCR * 2.0; // double CR for bosses
    }
    else if (GetLocalInt(OBJECT_SELF, "semiboss"))
    {
        fCR = fCR * 1.5; // 50% increase for semibosses
    }

    SetLocalInt(OBJECT_SELF, "cr", FloatToInt(fCR));
    SetLocalInt(OBJECT_SELF, "area_cr", iAreaCR);

    DelayCommand(3.0, CopyKey());

    //int nRace = GetRacialType(oCreature);

    SetSpawn();

    if (d8() == 1)
    {
        SetLocalInt(OBJECT_SELF, "no_stealth", 1);
    }
    else if (GetSkillRank(SKILL_HIDE, OBJECT_SELF, TRUE) > 0)
    {
        SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, TRUE);
    }

    string sScript = GetLocalString(OBJECT_SELF, "spawn_script");
    if (sScript != "") ExecuteScript(sScript);
}

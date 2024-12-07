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

void GeneratePickpocketItem(int nAllowedLootTypes=LOOT_TYPE_MISC)
{
    // Avoids increasing high tier item odds on bosses/semibosses
    object oItem = SelectLootItemFromACR(OBJECT_SELF, GetLocalInt(OBJECT_SELF, "area_cr"), nAllowedLootTypes);
    SetDroppableFlag(oItem, FALSE);
    SetPickpocketableFlag(oItem, TRUE);
    SetLocalInt(OBJECT_SELF, "pickpocket_xp", 1);
    SetLocalInt(oItem, "pickpocket_xp", 1);
}

//const int GS_TIMEOUT = 7200; //2 hours

void main()
{
    object oArea = GetArea(OBJECT_SELF);
    float fCR = GetChallengeRating(OBJECT_SELF);
    int iAreaCR = GetLocalInt(oArea, "cr");
    SetLocalInt(OBJECT_SELF, "cr", FloatToInt(fCR));
    SetLocalInt(OBJECT_SELF, "area_cr", iAreaCR);

    SignalEvent(OBJECT_SELF, EventUserDefined(GS_EV_ON_SPAWN));

    NWNX_Creature_SetNoPermanentDeath(OBJECT_SELF, TRUE);

    int nFamiliar = GetLocalInt(OBJECT_SELF, "familiar");
    if (nFamiliar > 0)
        NWNX_Creature_SetFamiliarCreatureType(OBJECT_SELF, nFamiliar);

    int nCompanion = GetLocalInt(OBJECT_SELF, "companion");
    if (nCompanion > 0)
        NWNX_Creature_SetAnimalCompanionCreatureType(OBJECT_SELF, nCompanion);

    DetermineMaxHitPoints(OBJECT_SELF);

    if (GetImmortal(OBJECT_SELF))
    {
        SetLocalInt(OBJECT_SELF, "immortal", 1);
        SetLocalInt(OBJECT_SELF, "no_credit", 1);
        SetImmortal(OBJECT_SELF, FALSE);
        SetIsDestroyable(FALSE, TRUE, FALSE);
    }

    //listen
    SetListenPattern(OBJECT_SELF, "GS_AI_ATTACK_TARGET",         10000);
    SetListenPattern(OBJECT_SELF, "GS_AI_REQUEST_REINFORCEMENT", 10003);
    SetListenPattern(OBJECT_SELF, "GS_AI_INNOCENT_ATTACKED", 10100);
    SetListenPattern(OBJECT_SELF, "GS_AI_BASH_LOCK", 10200);
    SetListening(OBJECT_SELF, TRUE);

    //set action matrix
    gsAISetActionMatrix(gsAIGetDefaultActionMatrix());

    if (!GetHasFeat(FEAT_KEEN_SENSE) && !GetHasFeat(FEAT_BLINDSIGHT_60_FEET))
    {
        SetActionMode(OBJECT_SELF, ACTION_MODE_DETECT, TRUE);
    }

    //set random facing
    //SetFacing(IntToFloat(Random(360)));

//    SetLocalLocation(OBJECT_SELF, "GS_LOCATION", GetLocation(OBJECT_SELF));
//    SetLocalInt(OBJECT_SELF, "GS_TIMEOUT", gsTIGetActualTimestamp() + GS_TIMEOUT);

    

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

            if (d8() == 1) GeneratePickpocketItem();

            // 1 in 20 chance of generating something that may not be a misc item
            if (d20() == 1) GeneratePickpocketItem(LOOT_TYPE_ANY);

            int nGold = d3(GetHitDice(OBJECT_SELF));

            // 3x the gold on bosses
            if (GetLocalInt(OBJECT_SELF, "boss") == 1)
            {
                nGold = nGold * 3;
                GeneratePickpocketItem();
                GeneratePickpocketItem();
                if (d3() == 1) GeneratePickpocketItem(LOOT_TYPE_ANY);
            }
            // 2x the gold on semibosses or immortals (quest/unique npcs usually)
            else if (GetLocalInt(OBJECT_SELF, "semiboss") == 1 || GetLocalInt(OBJECT_SELF, "rare") || GetLocalInt(OBJECT_SELF, "immortal") == 1)
            {
                nGold = nGold * 2;
                GeneratePickpocketItem();
                if (d6() == 1) GeneratePickpocketItem(LOOT_TYPE_ANY);
            }

            object oGold = CreateItemOnObject("nw_it_gold001", OBJECT_SELF, nGold);
            SetDroppableFlag(oGold, FALSE);
            SetPickpocketableFlag(oGold, TRUE);
        break;
    }


    NWNX_Creature_SetCorpseDecayTime(OBJECT_SELF, 1200000);
    NWNX_Creature_SetDisarmable(OBJECT_SELF, TRUE);

    // Create random weapons before scanning, it's sensible
    string sScript = GetLocalString(OBJECT_SELF, "spawn_script");
    //WriteTimestampedLogEntry("ai_onspawn for " + GetName(OBJECT_SELF) + "-> spawn script = " + sScript);
    if (sScript != "") ExecuteScript(sScript);

    string sAreaScript = GetLocalString(oArea, "creature_spawn_script");
    if (sAreaScript != "") ExecuteScript(sAreaScript);

// Scan and store weapons.
    object oItemInSlot = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);
    object oRange, oMelee, oItem;

    if (GetWeaponRanged(oItemInSlot))
    {
        SetLocalInt(OBJECT_SELF, "range", 1);
        oRange = oItemInSlot;
    }
    else if (GetIsObjectValid(oItemInSlot) && IPGetIsMeleeWeapon(oItemInSlot))
    {
        oMelee = oItemInSlot;
    }

    oItem = GetFirstItemInInventory(OBJECT_SELF);

    while (GetIsObjectValid(oItem) && (!GetIsObjectValid(oMelee) || !GetIsObjectValid(oRange)))
    {
        if (!GetIsObjectValid(oRange) && GetWeaponRanged(oItem))
        {
            oRange = oItem;
        }
        else if (!GetIsObjectValid(oMelee) && IPGetIsMeleeWeapon(oItem))
        {
            oMelee = oItem;
        }

        oItem = GetNextItemInInventory(OBJECT_SELF);
    }

    if (GetIsObjectValid(oMelee))
        SetLocalObject(OBJECT_SELF, "melee_weapon", oMelee);

    if (GetIsObjectValid(oRange))
        SetLocalObject(OBJECT_SELF, "range_weapon", oRange);

    object oOffhand = GetItemInSlot(INVENTORY_SLOT_LEFTHAND);
    if (GetIsObjectValid(oOffhand))
        SetLocalObject(OBJECT_SELF, "offhand", oOffhand);



    

    DelayCommand(3.0, CopyKey());

    //int nRace = GetRacialType(oCreature);

    SetSpawn();

// 1 in 6 chance of never stealthing. Bosses and semibosses will always stealth, if possible.
    if (GetLocalInt(OBJECT_SELF, "boss") == 0 && GetLocalInt(OBJECT_SELF, "semiboss") == 0 && d6() == 1)
    {
        SetLocalInt(OBJECT_SELF, "no_stealth", 1);
    }
    else if (GetSkillRank(SKILL_HIDE, OBJECT_SELF, TRUE) > 0 && !GetLocalInt(OBJECT_SELF, "no_stealth"))
    {
        SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, TRUE);
    }


}

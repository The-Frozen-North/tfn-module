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

//    SetAILevel(OBJECT_SELF, AI_LEVEL_LOW);

    //set mortality
/*
    if ((GetLocalInt(OBJECT_SELF, "GS_STATIC") ||
         ! GetLocalInt(GetArea(OBJECT_SELF), "GS_ENABLED")) &&
        ! (gsENGetIsEncounterCreature() || gsBOGetIsBossCreature()))
    {
        SetIsDestroyable(FALSE, TRUE, TRUE);
    }
    else
    {
        gsFLSetFlag(GS_FL_MORTAL);
        SetIsDestroyable(TRUE, TRUE, FALSE);
    }

    //create special items
    int nRacialType = GetRacialType(OBJECT_SELF);

    switch (nRacialType)
    {
    case RACIAL_TYPE_ABERRATION:
        break;

    case RACIAL_TYPE_ANIMAL:
        switch (GetCreatureSize(OBJECT_SELF))
        {
        case CREATURE_SIZE_TINY:
        case CREATURE_SIZE_SMALL:
            SetDroppableFlag(CreateItemOnObject("gs_item895"), TRUE); //skin
            SetDroppableFlag(CreateItemOnObject("gs_item899"), TRUE); //meat
            break;

        case CREATURE_SIZE_MEDIUM:
            SetDroppableFlag(CreateItemOnObject("gs_item896"), TRUE); //skin
            SetDroppableFlag(CreateItemOnObject("gs_item898"), TRUE); //meat
            break;

        case CREATURE_SIZE_LARGE:
        case CREATURE_SIZE_HUGE:
            SetDroppableFlag(CreateItemOnObject("gs_item854"), TRUE); //skin
            SetDroppableFlag(CreateItemOnObject("gs_item897"), TRUE); //meat
            SetDroppableFlag(CreateItemOnObject("gs_item335"), TRUE); //sinew
            break;
        }
        break;

    case RACIAL_TYPE_BEAST:
        break;

    case RACIAL_TYPE_CONSTRUCT:
        break;

    case RACIAL_TYPE_DRAGON:
        SetDroppableFlag(CreateItemOnObject("gs_item824"), TRUE); //blood
        break;

    case RACIAL_TYPE_DWARF:
        break;

    case RACIAL_TYPE_ELEMENTAL:
        break;

    case RACIAL_TYPE_ELF:
        break;

    case RACIAL_TYPE_FEY:
        SetDroppableFlag(CreateItemOnObject("gs_item824"), TRUE); //blood
        break;

    case RACIAL_TYPE_GIANT:
        break;

    case RACIAL_TYPE_GNOME:
        break;

    case RACIAL_TYPE_HALFELF:
        break;

    case RACIAL_TYPE_HALFLING:
        break;

    case RACIAL_TYPE_HALFORC:
        break;

    case RACIAL_TYPE_HUMAN:
        break;

    case RACIAL_TYPE_HUMANOID_GOBLINOID:
        break;

    case RACIAL_TYPE_HUMANOID_MONSTROUS:
        break;

    case RACIAL_TYPE_HUMANOID_ORC:
        break;

    case RACIAL_TYPE_HUMANOID_REPTILIAN:
        break;

    case RACIAL_TYPE_INVALID:
        break;

    case RACIAL_TYPE_MAGICAL_BEAST:
        SetDroppableFlag(CreateItemOnObject("gs_item824"), TRUE); //blood
        break;

    case RACIAL_TYPE_OOZE:
        break;

    case RACIAL_TYPE_OUTSIDER:
        break;

    case RACIAL_TYPE_SHAPECHANGER:
        break;

    case RACIAL_TYPE_UNDEAD:
        break;

    case RACIAL_TYPE_VERMIN:
        break;
    }

    //create inventory
    if (GetAbilityScore(OBJECT_SELF, ABILITY_INTELLIGENCE) >= 6)
    {
        object oInventory = GetObjectByTag("GS_INVENTORY_" + IntToString(nRacialType));

        if (GetIsObjectValid(oInventory))
        {
            object oItem = GetFirstItemInInventory(oInventory);
            object oCopy = OBJECT_INVALID;

            if (GetIsObjectValid(oItem))
            {
                int nRating  = FloatToInt(pow(GetChallengeRating(OBJECT_SELF), 2.0));
                int nRandom  = 0;
                int nValue   = 0;

                GiveGoldToCreature(OBJECT_SELF, Random(nRating));
                nRating     *= 10;

                do
                {
                    nRandom = Random(100);

                    if (nRandom == 99 ||
                        (nRandom >= 90 &&
                         gsCMGetItemValue(oItem) <= nRating))
                    {
                        oCopy  = CopyItem(oItem, OBJECT_SELF);
                        nValue = gsCMGetItemValue(oItem);

                        if (GetIsObjectValid(oCopy))
                        {
                            SetIdentified(oCopy, nValue <= 100);
                            SetDroppableFlag(oCopy, TRUE);
                        }
                    }

                    oItem = GetNextItemInInventory(oInventory);
                }
                while (GetIsObjectValid(oItem));
            }
        }
    }
    else
    {
        gsFLSetFlag(GS_FL_DISABLE_CALL);
    }
*/
    //listen
    SetListenPattern(OBJECT_SELF, "GS_AI_ATTACK_TARGET",         10000);
    SetListenPattern(OBJECT_SELF, "GS_AI_REQUEST_REINFORCEMENT", 10003);
    SetListenPattern(OBJECT_SELF, "GS_AI_INNOCENT_ATTACKED", 10100);
    SetListening(OBJECT_SELF, TRUE);

    //set action matrix
    gsAISetActionMatrix(gsAIGetDefaultActionMatrix());

    if (GetWeaponRanged(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND))) SetLocalInt(OBJECT_SELF, "range", 1);

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

// Set cr integer on self. This is used for determining treasure.
    SetLocalInt(OBJECT_SELF, "cr", FloatToInt(GetChallengeRating(OBJECT_SELF)));
    SetLocalInt(OBJECT_SELF, "area_cr", iAreaCR);

    object oItem = GetFirstItemInInventory();
    object oNewItem;

    DelayCommand(3.0, CopyKey());

    //int nRace = GetRacialType(oCreature);

    SetSpawn();

    string sScript = GetLocalString(OBJECT_SELF, "spawn_script");
    if (sScript != "") ExecuteScript(sScript);
}

#include "nwnx_events"

void main()
{
    object oPC = OBJECT_SELF;

// do nothing if not a PC
    if (!GetIsPC(oPC)) return;

// do nothing if not in combat
    if (!GetIsInCombat(oPC)) return;

    object oItem = StringToObject(NWNX_Events_GetEventData("ITEM"));

    int nItemType = GetBaseItemType(oItem);

    switch (nItemType) {
        case BASE_ITEM_BOOTS:
        case BASE_ITEM_BRACER:
        case BASE_ITEM_CLOAK:
        case BASE_ITEM_GLOVES:
        case BASE_ITEM_HELMET:
        case BASE_ITEM_RING:
        case BASE_ITEM_AMULET:
        case BASE_ITEM_BELT:
            FloatingTextStringOnCreature("*You cannot change this item while in combat!*", oPC, FALSE);
            NWNX_Events_SkipEvent();
        break;
    }
}

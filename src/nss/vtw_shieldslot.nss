int StartingConditional()
{
    object oPC = GetPCSpeaker();
    object oItem = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);
    if (
        GetBaseItemType(oItem) == BASE_ITEM_SMALLSHIELD ||
        GetBaseItemType(oItem) == BASE_ITEM_LARGESHIELD ||
        GetBaseItemType(oItem) == BASE_ITEM_TOWERSHIELD
        ) return TRUE;

    else return FALSE;
}

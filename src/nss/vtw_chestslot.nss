int StartingConditional()
{
    object oPC = GetPCSpeaker();
    object oItem = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);
    if (GetIsObjectValid(oItem)) return TRUE;
    else return FALSE;
}

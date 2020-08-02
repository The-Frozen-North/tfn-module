int StartingConditional()
{
    object oPC = GetPCSpeaker();
    object oItem = GetItemInSlot(INVENTORY_SLOT_HEAD, oPC);
    if (GetIsObjectValid(oItem)) return TRUE;
    else return FALSE;
}

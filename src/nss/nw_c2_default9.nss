void main()
{
    object oItem = GetFirstItemInInventory();

    while (GetIsObjectValid(oItem))
    {
        SetDroppableFlag(oItem, FALSE);
        SetPickpocketableFlag(oItem, FALSE);

        oItem = GetNextItemInInventory();
    }


    int nSlot;
    object oSlotItem;
    for ( nSlot = 0; nSlot < NUM_INVENTORY_SLOTS; ++nSlot )
    {
        oSlotItem = GetItemInSlot(nSlot);

        SetDroppableFlag(oSlotItem, FALSE);
        SetPickpocketableFlag(oItem, FALSE);
    }
}

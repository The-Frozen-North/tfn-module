void main()
{
    // Delete all items on death.
    object oItem = GetFirstItemInInventory();

    while (GetIsObjectValid(oItem))
    {
        DestroyObject(oItem);

        oItem = GetNextItemInInventory();
    }

    // Destroy equipped items.
    int nSlot;
    for ( nSlot = 0; nSlot < NUM_INVENTORY_SLOTS; ++nSlot )
        DestroyObject(GetItemInSlot(nSlot));
}

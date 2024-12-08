#include "inc_itemevent"

void main()
{
    // Call item unequip event for polymorphed items
    int nSlot;
    for (nSlot=0; nSlot<=INVENTORY_SLOT_HIGHEST; nSlot++)
    {
        object oItem = GetItemInSlot(nSlot, OBJECT_SELF);
        if (GetIsObjectValid(oItem))
        {
            ItemEventCallEventOnItem(oItem, ITEM_EVENT_UNEQUIP, OBJECT_SELF, TRUE);
        }
    }
}
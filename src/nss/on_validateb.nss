#include "nwnx_object"
#include "nwnx_item"

void main()
{
    int nSlot;
    object oItem;
    int nHitDice = GetHitDice(OBJECT_SELF);
    for ( nSlot = 0; nSlot < 14; ++nSlot )
    {
        oItem = GetItemInSlot(nSlot, OBJECT_SELF);
        if (NWNX_Item_GetMinEquipLevel(oItem) > nHitDice)
            ActionUnequipItem(oItem);
    }
}

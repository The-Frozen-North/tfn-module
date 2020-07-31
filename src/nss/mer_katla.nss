#include "nwnx_item"

void CreateHorseStone(int nHorse, string sName, int nAppearance)
{
    object oItem = CreateItemOnObject("horse_stone", OBJECT_SELF, 1, "horse"+IntToString(nHorse));

    NWNX_Item_SetItemAppearance(oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, nAppearance);
    SetLocalInt(oItem, "horse", nHorse);
    SetName(oItem, GetName(oItem)+" ("+sName+")");
    SetInfiniteFlag(oItem, TRUE);
}

void main()
{
    CreateHorseStone(16, "Walnut", 75);
    CreateHorseStone(29, "Gunpowder", 76);
    CreateHorseStone(55, "Black", 77);
    CreateHorseStone(42, "Spotted", 78);
}

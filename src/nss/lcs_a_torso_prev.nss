//#include "lcs_shld_include"
#include "lcs_inc_chmodel"

void main()
{
    object oPC = GetPCSpeaker();
    object oItem = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);
    //int nNewLine = lcs_GetNextValidShieldModel(oItem);

    //lcs_ModifyandEquipNewShield(oItem, nNewLine);

    object item_new = set_chest_model_prev(oItem, oPC);
    equip_item(item_new, INVENTORY_SLOT_CHEST, oPC);
}

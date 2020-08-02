//#include "lcs_shld_include"
#include "lcs_inc_amodel"

void main()
{
    object oPC = GetPCSpeaker();
    object oItem = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);
    //int nNewLine = lcs_GetNextValidShieldModel(oItem);

    //lcs_ModifyandEquipNewShield(oItem, nNewLine);

    object item_new = set_armor_model_next(oItem, ITEM_APPR_ARMOR_MODEL_LTHIGH, "parts_legs", oPC);
    item_new = set_armor_model_next(item_new, ITEM_APPR_ARMOR_MODEL_RTHIGH, "parts_legs", oPC);
    equip_item(item_new, INVENTORY_SLOT_CHEST, oPC);
}

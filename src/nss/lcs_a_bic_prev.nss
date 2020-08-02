//#include "lcs_shld_include"
#include "lcs_inc_amodel"

void main()
{
    object oPC = GetPCSpeaker();
    object oItem = GetItemInSlot(INVENTORY_SLOT_CHEST, oPC);
    //int nNewLine = lcs_GetNextValidShieldModel(oItem);

    //lcs_ModifyandEquipNewShield(oItem, nNewLine);

    object item_new = set_armor_model_prev(oItem, ITEM_APPR_ARMOR_MODEL_LBICEP, "parts_bicep", oPC);
    item_new = set_armor_model_prev(item_new, ITEM_APPR_ARMOR_MODEL_RBICEP, "parts_bicep", oPC);
    equip_item(item_new, INVENTORY_SLOT_CHEST, oPC);
}

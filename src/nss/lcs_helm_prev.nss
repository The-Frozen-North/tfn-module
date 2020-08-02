//#include "lcs_helm_include"
#include "lcs_inc_wmodel"

void main()
{
    object oPC = GetPCSpeaker();
    object oItem = GetItemInSlot(INVENTORY_SLOT_HEAD, oPC);
    //int nNewLine = lcs_GetPreviousValidHelmModel(oItem);

    //lcs_ModifyandEquipNewHelm(oItem, nNewLine);

    set_model_prev(oItem, ITEM_APPR_TYPE_ARMOR_MODEL, 0, oPC, HELMET_MODEL_VAL_MIN, HELMET_MODEL_VAL_MAX);
}

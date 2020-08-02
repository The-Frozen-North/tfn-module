//#include "lcs_wpn_include"
#include "lcs_inc_wmodel"

void main()
{
    object oPC = GetPCSpeaker();
    object oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    //int nNewLine = lcs_GetNextValidWeaponModel(oItem, ITEM_APPR_WEAPON_MODEL_MIDDLE);

    //lcs_ModifyandEquipNewWeapon(oItem, ITEM_APPR_WEAPON_MODEL_MIDDLE, nNewLine);

    set_model_next(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_MIDDLE, oPC, WEAPON_MODEL_MID_VAL_MIN, WEAPON_MODEL_MID_VAL_MAX);
}

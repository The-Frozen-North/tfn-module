//#include "lcs_wpn_include"
#include "lcs_inc_wmodel"

void main()
{
    object oPC = GetPCSpeaker();
    object oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    //int nNewLine = lcs_GetNextValidWeaponModel(oItem, ITEM_APPR_WEAPON_MODEL_BOTTOM);

    //lcs_ModifyandEquipNewWeapon(oItem, ITEM_APPR_WEAPON_MODEL_BOTTOM, nNewLine);

    set_model_next(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, ITEM_APPR_WEAPON_MODEL_BOTTOM, oPC, WEAPON_MODEL_BTM_VAL_MIN, WEAPON_MODEL_BTM_VAL_MAX);
}

//#include "lcs_shld_include"
#include "lcs_inc_wmodel"

void main()
{
    object oPC = GetPCSpeaker();
    object oItem = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);
    //int nNewLine = lcs_GetNextValidShieldModel(oItem);

    //lcs_ModifyandEquipNewShield(oItem, nNewLine);

    set_model_next(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, 0, oPC, SHIELD_MODEL_VAL_MIN, SHIELD_MODEL_VAL_MAX);
}

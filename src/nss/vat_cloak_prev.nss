#include "lcs_inc_wmodel"

void main()
{
    object oPC = GetPCSpeaker();
    object oItem = GetItemInSlot(INVENTORY_SLOT_CLOAK, oPC);
    set_model_prev(oItem, ITEM_APPR_TYPE_SIMPLE_MODEL, 0, oPC, CLOAK_MODEL_VAL_MIN, CLOAK_MODEL_VAL_MAX);
}

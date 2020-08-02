#include "lcs_shld_include"

void main()
{
    object oPC = GetPCSpeaker();
    object oItem = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, oPC);
    int nNewLine = lcs_GetPreviousValidShieldColor(oItem);

    lcs_ModifyColorandEquipNewShield(oItem, nNewLine);
}

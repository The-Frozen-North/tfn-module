#include "lcs_wpn_include"

void main()
{
    object oPC = GetPCSpeaker();
    object oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    int nNewLine = lcs_GetPreviousValidWeaponColor(oItem, ITEM_APPR_WEAPON_COLOR_BOTTOM);

    lcs_ModifyColorandEquipNewWeapon(oItem, ITEM_APPR_WEAPON_COLOR_BOTTOM, nNewLine);
}

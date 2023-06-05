#include "x2_inc_itemprop"
#include "tmog_inc_craft"

void main()
{
    object oPC = GetPCSpeaker();
    int iSlot = GetLocalInt(oPC, "iSlot");
    int iColorType = GetLocalInt(oPC, "iItemAppr");
    int iColor = GetLocalInt(oPC, "iColor" + IntToString(iColorType));

    //metal red
    int iNewColor = 24;

    HideFeedbackForCraftText(oPC, TRUE);
    object oItem = IPDyeArmor(GetItemInSlot(iSlot, oPC), iColorType, iNewColor);

    SetLocalInt(oPC, "iColor" + IntToString(iColorType), iNewColor);
    FloatingTextStringOnCreature("Color " + IntToString(iNewColor), oPC, FALSE);

    AssignCommand(oPC, ActionEquipItem(oItem, iSlot));
    HideFeedbackForCraftText(oPC, FALSE);
}

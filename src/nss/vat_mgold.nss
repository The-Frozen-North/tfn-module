#include "x2_inc_itemprop"

void main()
{
    object oPC = GetPCSpeaker();
    int iSlot = GetLocalInt(oPC, "iSlot");
    int iColorType = GetLocalInt(oPC, "iItemAppr");
    int iColor = GetLocalInt(oPC, "iColor" + IntToString(iColorType));

    //metal gold
    int iNewColor = 9;

    object oItem = IPDyeArmor(GetItemInSlot(iSlot, oPC), iColorType, iNewColor);

    SetLocalInt(oPC, "iColor" + IntToString(iColorType), iNewColor);
    FloatingTextStringOnCreature("Color " + IntToString(iNewColor), oPC, FALSE);

    AssignCommand(oPC, ActionEquipItem(oItem, iSlot));
}

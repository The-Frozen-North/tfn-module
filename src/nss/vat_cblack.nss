#include "x2_inc_itemprop"

void main()
{
    object oPC = GetPCSpeaker();
    int iSlot = GetLocalInt(oPC, "iSlot");
    int iColorType = GetLocalInt(oPC, "iItemAppr");
    int iColor = GetLocalInt(oPC, "iColor" + IntToString(iColorType));

    //black
    int iNewColor = 23;

    object oItem = IPDyeArmor(GetItemInSlot(iSlot, oPC), iColorType, iNewColor);

    SetLocalInt(oPC, "iColor" + IntToString(iColorType), iNewColor);
    FloatingTextStringOnCreature("Color " + IntToString(iNewColor), oPC, FALSE);

    AssignCommand(oPC, ActionEquipItem(oItem, iSlot));
}

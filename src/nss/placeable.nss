#include "nwnx_object"
#include "inc_housing"

void main()
{
    object oItem = GetItemActivated();
    object oPC = GetItemActivator();

    if (!IsInOwnHome(oPC))
    {
        FloatingTextStringOnCreature("*Placeables can only placed in your own home.*", oPC, FALSE);
        return;
    }

    int nAppearanceType = GetLocalInt(oItem, "appearance_type");
    string sName = GetLocalString(oItem, "name");
    string sDescription = GetLocalString(oItem, "description");
    string sType = GetLocalString(oItem, "type");


    object oPlaceable = CopyPlaceable(sName, sDescription, sType, GetItemActivatedTargetLocation(), nAppearanceType);

    if (!GetIsObjectValid(oPlaceable))
    {
        SendMessageToPC(oPC, "Something went wrong and the placeable was not created.");
        return;
    }

    DestroyObject(oItem);
}

#include "nwnx_admin"
#include "nwnx_events"
#include "nwnx_object"
#include "inc_craft"

void main()
{
    object oObject = NWNX_Object_StringToObject(NWNX_Events_GetEventData("EXAMINEE_OBJECT_ID"));

    if (GetObjectType(oObject) == OBJECT_TYPE_CREATURE && GetFactionEqual(oObject))
    {
        NWNX_Administration_SetPlayOption(NWNX_ADMINISTRATION_OPTION_EXAMINE_EFFECTS, TRUE);
    }
    else if (GetObjectType(oObject) == OBJECT_TYPE_ITEM && GetIdentified(oObject) && GetResRef(oObject) == "ammo_maker")
    {
        object oAmmo = GetObjectByTag("fabricator_"+GetLocalString(oObject, "ammo_tag"));
        SetDescription(oObject, "This appears to be some sort of contraption that can create ammunition.\n\nThe difficulty class and gold required is dependant on the type of ammunition that this device outputs.\n\nDC: "+IntToString(DetermineAmmoCraftingDC(oAmmo))+"\nGold: "+IntToString(DetermineAmmoCraftingCost(oAmmo)));
    }
}

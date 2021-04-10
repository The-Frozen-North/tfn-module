#include "nwnx_events"
#include "nwnx_object"
#include "inc_debug"

void main()
{
    object oStore = NWNX_Object_StringToObject(NWNX_Events_GetEventData("STORE"));
    SendDebugMessage("store: "+GetTag(oStore));
    string sString = GetLocalString(oStore, "target_pawnshop");
    SendDebugMessage("target pawnshop: "+sString);
    object oTargetPawnStore = GetObjectByTag(sString);
    if (StringToInt(NWNX_Events_GetEventData("RESULT")) == TRUE && GetIsObjectValid(oTargetPawnStore))
    {
        SendDebugMessage("item sold");
        object oItem = NWNX_Object_StringToObject(NWNX_Events_GetEventData("ITEM"));
        CopyItem(oItem, oTargetPawnStore, TRUE);
        DestroyObject(oItem);
    }
}

#include "nwnx_events"

void main()
{
    object oObject = StringToObject(NWNX_Events_GetEventData("ITEM"));
    object oPossesor = GetItemPossessor(oObject);

    if (GetObjectType(oObject) == OBJECT_TYPE_ITEM && GetIdentified(oObject) && GetLocalInt(oObject, "identified_in_storage") == 0 && GetObjectType(oPossesor) == OBJECT_TYPE_PLACEABLE && GetResRef(oPossesor) == "_pc_storage")
    {
        SetLocalInt(oObject, "identified_in_storage", 1);
        StoreCampaignObject(GetPCPublicCDKey(OBJECT_SELF), GetTag(oPossesor), oPossesor);
    }
}

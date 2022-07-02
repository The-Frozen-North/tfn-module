#include "nwnx_events"
#include "inc_webhook"

void main()
{
    object oObject = StringToObject(NWNX_Events_GetEventData("ITEM"));
    object oPossesor = GetItemPossessor(oObject);

    if (GetObjectType(oObject) == OBJECT_TYPE_ITEM && GetIdentified(oObject) && GetLocalInt(oObject, "identified_in_storage") == 0 && GetObjectType(oPossesor) == OBJECT_TYPE_PLACEABLE && GetResRef(oPossesor) == "_pc_storage")
    {
        SetLocalInt(oObject, "identified_in_storage", 1);
        StoreCampaignObject(GetPCPublicCDKey(OBJECT_SELF), GetTag(oPossesor), oPossesor);
    }
    if (GetObjectType(oObject) == OBJECT_TYPE_ITEM && GetIdentified(oObject))
    {
        if (GetLocalInt(oObject, "loreb_wasunidentified"))
        {
            DeleteLocalInt(oObject, "loreb_wasunidentified");
            ValuableItemWebhook(OBJECT_SELF, oObject, FALSE);
        }
    }
}

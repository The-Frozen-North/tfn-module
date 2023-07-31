#include "nwnx_events"
#include "inc_webhook"

void main()
{
    object oObject = StringToObject(NWNX_Events_GetEventData("ITEM"));
    object oPossessor = GetItemPossessor(oObject);
    object oPC = OBJECT_SELF;

    if (GetObjectType(oObject) == OBJECT_TYPE_ITEM && GetIdentified(oObject) && GetLocalInt(oObject, "identified_in_storage") == 0 && GetObjectType(oPossessor) == OBJECT_TYPE_PLACEABLE && GetResRef(oPossessor) == "_pc_storage")
    {
        SetLocalInt(oObject, "identified_in_storage", 1);
        StoreCampaignObject(GetPCPublicCDKey(OBJECT_SELF), GetTag(oPossessor), oPossessor);
    }
    if (GetObjectType(oObject) == OBJECT_TYPE_ITEM && GetIdentified(oObject))
    {
        if (GetLocalInt(oObject, "loreb_wasunidentified"))
        {
            DeleteLocalInt(oObject, "loreb_wasunidentified");
            ValuableItemWebhook(oPC, oObject, FALSE);
            SetLocalObject(oObject, "webhook_valuable_identifier", oPC);
        }
    }
}

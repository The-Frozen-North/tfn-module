#include "nwnx_events"

void main()
{
    object oObject = StringToObject(NWNX_Events_GetEventData("ITEM"));
    if (GetObjectType(oObject) == OBJECT_TYPE_ITEM && !GetIdentified(oObject))
    {
        SetLocalInt(oObject, "loreb_wasunidentified", 1);
    }
}

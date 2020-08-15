#include "nwnx_events"
#include "nwnx_object"
#include "inc_debug"

void main()
{
    object oArea = NWNX_Object_StringToObject(NWNX_Events_GetEventData("AREA"));

    int nObjectType = StringToInt(NWNX_Events_GetEventData("OBJECT_TYPE"));

    if (GetStringLeft(GetResRef(oArea), 1) == "_" && !GetIsDeveloper(OBJECT_SELF))
    {
        WriteTimestampedLogEntry("DM: "+GetName(OBJECT_SELF)+" is not a developer and not allowed to spawn an object in this area: "+GetResRef(oArea));
        SendMessageToPC(OBJECT_SELF, "Only a developer is allowed to spawn objects in this area.");
        NWNX_Events_SkipEvent();
    }
    else if (!(nObjectType == 5 || nObjectType == 9))
    {
        WriteTimestampedLogEntry("DM: "+GetName(OBJECT_SELF)+" could not create object because the object type is not a creature or placeable: "+IntToString(nObjectType));
        SendMessageToPC(OBJECT_SELF, "Could not create object because the object type is not a creature or placeable.");
        NWNX_Events_SkipEvent();
    }
}

#include "nwnx_events"
#include "nwnx_object"
#include "inc_debug"

void main()
{
    object oObject = NWNX_Object_StringToObject(NWNX_Events_GetEventData("OBJECT"));

    string sResRef = GetResRef(oObject);

    if (GetStringLeft(sResRef, 1) == "_")
    {
        WriteTimestampedLogEntry("DM: "+GetName(OBJECT_SELF)+" created an system object that will be automatically destroyed: "+sResRef);
        SendMessageToPC(OBJECT_SELF, "This is a system object which should never be created, destroying.");
        DestroyObject(oObject);
    }
    else if (GetStringLeft(sResRef, 3) == "hen")
    {
        WriteTimestampedLogEntry("DM: "+GetName(OBJECT_SELF)+" created a henchman that will be automatically destroyed: "+sResRef);
        SendMessageToPC(OBJECT_SELF, "This is a henchman which should never be created, destroying.");
        DestroyObject(oObject);
    }
    else if (GetObjectType(oObject) == OBJECT_TYPE_PLACEABLE && GetStringLeft(sResRef, 6) == "treas_")
    {
        WriteTimestampedLogEntry("DM: "+GetName(OBJECT_SELF)+" created a treasure: "+sResRef);
        SendMessageToPC(OBJECT_SELF, "Initializing treasure...");
        ExecuteScript("treas_init", oObject);
    }
    else
    {
        WriteTimestampedLogEntry("DM: "+GetName(OBJECT_SELF)+" created an object: "+sResRef);
    }

}

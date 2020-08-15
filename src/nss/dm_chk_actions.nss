#include "nwnx_events"
#include "nwnx_object"

void main()
{
    object oArea = NWNX_Object_StringToObject(NWNX_Events_GetEventData("TARGET_AREA"));

    int nNumTargets = StringToInt(NWNX_Events_GetEventData("NUM_TARGETS"));

    object oObject;

    int i;
    for (i = 1; i <= nNumTargets; i++)
    {
        oObject = NWNX_Object_StringToObject(NWNX_Events_GetEventData("TARGET_"+IntToString(i)));

        if (GetLocalInt(oObject, "dm_immune") == 1)
        {
            SendMessageToPC(OBJECT_SELF, "Aborting action because object"+IntToString(i)+" is dm_immune: "+GetName(oObject));
            WriteTimestampedLogEntry("DM: "+GetName(OBJECT_SELF)+" could not do action on dm_immune object: "+GetName(oObject));
            NWNX_Events_SkipEvent();
            break;
        }
    }
}

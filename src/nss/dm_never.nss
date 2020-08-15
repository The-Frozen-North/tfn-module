#include "nwnx_events"

void main()
{
    WriteTimestampedLogEntry("DM: "+GetName(OBJECT_SELF)+" is attempting an unallowed action: "+NWNX_Events_GetCurrentEvent());

    SendMessageToPC(OBJECT_SELF, "No one is allowed to do this action.");
    NWNX_Events_SkipEvent();
}

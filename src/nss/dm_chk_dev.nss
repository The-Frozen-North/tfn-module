#include "inc_debug"
#include "nwnx_events"

void main()
{
    if (!GetIsDeveloper(OBJECT_SELF))
    {
        WriteTimestampedLogEntry("DM: "+GetName(OBJECT_SELF)+" was not allowed to do developer only action: "+NWNX_Events_GetCurrentEvent());
        SendMessageToPC(OBJECT_SELF, "You are not allowed to do this action.");
        NWNX_Events_SkipEvent();
    }
}

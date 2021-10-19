#include "inc_debug"
#include "nwnx_events"
#include "inc_nwnx"

void main()
{
    if (!GetIsDeveloper(OBJECT_SELF))
    {
        WriteTimestampedLogEntry("DM: "+GetName(OBJECT_SELF)+" was not allowed to do developer only action: "+NWNX_Events_GetCurrentEvent());
        SendMessageToPC(OBJECT_SELF, "You are not allowed to do this action.");
        NWNX_Events_SkipEvent();
    }
    else if (GetIsDeveloper(OBJECT_SELF))
    {
         SendDiscordLogMessage("DM: "+GetName(OBJECT_SELF)+" has executed "+NWNX_Events_GetCurrentEvent()+", target: "+GetName(StringToObject(NWNX_Events_GetEventData("OBJECT")))+", amount: "+NWNX_Events_GetEventData("AMOUNT"));
    }
}

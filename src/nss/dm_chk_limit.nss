#include "inc_debug"
#include "nwnx_events"
#include "nwnx_object"
#include "inc_nwnx"

void main()
{
    if (!GetIsDeveloper(OBJECT_SELF))
    {
        int nAmount = StringToInt(NWNX_Events_GetEventData("AMOUNT"));
        if (nAmount < 0)
        {
            WriteTimestampedLogEntry("DM: "+GetName(OBJECT_SELF)+" tried to do a limit action with an amount that was negative: "+NWNX_Events_GetCurrentEvent());
            SendMessageToPC(OBJECT_SELF, "You are not allowed to do this action with a negative amount.");
            NWNX_Events_SkipEvent();
        }
        else if (nAmount > 500)
        {
            WriteTimestampedLogEntry("DM: "+GetName(OBJECT_SELF)+" tried to do a limit action greater than 500: "+NWNX_Events_GetCurrentEvent());
            SendMessageToPC(OBJECT_SELF, "You are not allowed to do this action with an amount greater than 500.");
            NWNX_Events_SkipEvent();
        }
    }
    else if (GetIsDeveloper(OBJECT_SELF))
    {
         SendDiscordLogMessage("DM: "+GetName(OBJECT_SELF)+" has executed "+NWNX_Events_GetCurrentEvent()+", target: "+GetName(NWNX_Object_StringToObject(NWNX_Events_GetEventData("OBJECT")))+", amount: "+NWNX_Events_GetEventData("AMOUNT"));
    }
}

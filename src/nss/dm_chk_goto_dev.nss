#include "nwnx_events"
#include "inc_debug"

void main()
{
    object oArea = StringToObject(NWNX_Events_GetEventData("TARGET"));

    if (!GetIsObjectValid(oArea))
    {
        SendMessageToPC(OBJECT_SELF, "Could not retrieve area.");
        WriteTimestampedLogEntry("DM: "+GetName(OBJECT_SELF)+" could not GoTo to an area because it was invalid");
        NWNX_Events_SkipEvent();
    }
    else if (GetStringLeft(GetResRef(oArea), 1) == "_")
    {
        if (!GetIsDeveloper(OBJECT_SELF))
        {
            SendMessageToPC(OBJECT_SELF, "Only a developer is allowed to go to this area.");
            WriteTimestampedLogEntry("DM: "+GetName(OBJECT_SELF)+" was not allowed to GoTo to developer only area: "+GetResRef(oArea));
            NWNX_Events_SkipEvent();
        }
        else
        {
            SendDiscordLogMessage(GetName(OBJECT_SELF) + " used the developer menu to enter a system area.");
        }
    }
}

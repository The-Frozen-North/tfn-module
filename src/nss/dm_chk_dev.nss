#include "inc_debug"
#include "nwnx_events"
#include "nwnx_regex"
#include "x3_inc_string"

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
        object oTarget = StringToObject(NWNX_Events_GetEventData("TARGET"));
        string sEvent = NWNX_Events_GetCurrentEvent();
        if (sEvent == "NWNX_ON_DM_SET_STAT_BEFORE")
        {
            SendDiscordLogMessage(GetName(OBJECT_SELF) + " set stat " + NWNX_Events_GetEventData("STAT") + " on " + GetName(oTarget) + " to " + NWNX_Events_GetEventData("VALUE"));
        }
        else if (sEvent == "NWNX_ON_DM_GIVE_ITEM_BEFORE")
        {
            SendDiscordLogMessage(GetName(OBJECT_SELF) + " created an item for " + GetName(oTarget));
        }
        else if (sEvent == "NWNX_ON_DM_SET_VARIABLE_BEFORE")
        {
            SendDiscordLogMessage(GetName(OBJECT_SELF) + " set variable " + NWNX_Events_GetEventData("KEY") + "(type " + NWNX_Events_GetEventData("TYPE") + ") to " + NWNX_Events_GetEventData("VALUE") + " on " + GetName(oTarget));
        }
        else if (sEvent == "NWNX_ON_DEBUG_RUN_SCRIPT_BEFORE")
        {
            SendDiscordLogMessage(GetName(OBJECT_SELF) + " ran script " + NWNX_Events_GetEventData("SCRIPT_NAME") + " on " + GetName(oTarget));
        }
        else if (sEvent == "NWNX_ON_DEBUG_RUN_SCRIPT_CHUNK_BEFORE")
        {
            string sChunk = NWNX_Events_GetEventData("SCRIPT_CHUNK");
            // 0xd is \r which can appear if you copy code in, the compiler ignores it, but the discord webhook STRONGLY objects to it
            sChunk = StringReplace(sChunk, "\x0d", "");
            sChunk = StringReplace(sChunk, "\n", "\\n");
            sChunk = StringReplace(sChunk, "\"", "\\\"");
            sChunk = "```c\\n" + sChunk + "\\n```";

            WriteTimestampedLogEntry(sChunk);

            SendDiscordLogMessage(GetName(OBJECT_SELF) + " ran script chunk on " + GetName(oTarget) + ":");
            SendDiscordLogMessage(sChunk);
            //SendDiscordLogMessage(sChunk);
        }
        else
        {
            SendDiscordLogMessage("Developer: "+GetName(OBJECT_SELF)+" has executed "+NWNX_Events_GetCurrentEvent()+", target: "+GetName(StringToObject(NWNX_Events_GetEventData("OBJECT")))+", amount: "+NWNX_Events_GetEventData("AMOUNT"));
        }
    }
}

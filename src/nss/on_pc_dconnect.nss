#include "nwnx_events"
#include "inc_general"

void main()
{
    string sName = GetPCPlayerName(OBJECT_SELF);

// Only care about people from login, because we already have a webhook for characters (client leave)
    if (sName != "") return;

    string sMessage = "A player from login has disconnected..";

    SendDiscordLogMessage(sMessage);

    object oPC = GetFirstPC();
    while (GetIsObjectValid(oPC))
    {
        SendColorMessageToPC(oPC, sMessage, MESSAGE_COLOR_SERVER);

        oPC = GetNextPC();
    }
}

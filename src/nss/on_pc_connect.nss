#include "nwnx_events"
#include "inc_general"

void main()
{
    object oPC = GetFirstPC();
    string sMessage = NWNX_Events_GetEventData("PLAYER_NAME")+" has connected..";
    SendDiscordLogMessage(sMessage);

    while (GetIsObjectValid(oPC))
    {
        SendColorMessageToPC(oPC, sMessage, MESSAGE_COLOR_SERVER);

        oPC = GetNextPC();
    }
}

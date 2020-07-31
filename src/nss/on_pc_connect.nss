#include "nwnx_events"
#include "inc_nwnx"

void main()
{
    object oPC = GetFirstPC();
    string sMessage = NWNX_Events_GetEventData("PLAYER_NAME")+" has connected ..";
    SendDiscordLogMessage(sMessage);

    while (GetIsObjectValid(oPC))
    {
        SendMessageToPC(oPC, sMessage);

        oPC = GetNextPC();
    }
}

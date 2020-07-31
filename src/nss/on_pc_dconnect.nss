#include "nwnx_events"
#include "inc_nwnx"

void main()
{
    object oPC = GetFirstPC();

    string sName = GetPCPlayerName(OBJECT_SELF);
    if (sName == "") sName = "A player from login";
    string sMessage = sName+" has disconnected ..";

    SendDiscordLogMessage(sMessage);

    while (GetIsObjectValid(oPC))
    {
        SendMessageToPC(oPC, sMessage);

        oPC = GetNextPC();
    }
}

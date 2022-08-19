#include "inc_persist"
#include "inc_webhook"
#include "inc_debug"

void main()
{
    object oPC = GetExitingObject();
    SavePCInfo(oPC);
    SQLocalsPlayer_SetInt(oPC, "RESTXP_LAST_SAVE", SQLite_GetTimeStamp());

    object oPCCount = GetFirstPC();
    int nPCs = -1;

    while (GetIsObjectValid(oPCCount))
    {
        nPCs = nPCs + 1;
        oPCCount = GetNextPC();
    }

    if (nPCs < 0) nPCs = 0;

    string sMessage = PlayerDetailedName(oPC)+" has left the game.";

    WriteTimestampedLogEntry(PlayerDetailedName(oPC)+" has left the game.");

    LogWebhook(oPC, LOG_OUT);
}

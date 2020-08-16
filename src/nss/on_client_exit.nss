#include "inc_persist"
#include "inc_nwnx"
#include "inc_debug"

void main()
{
    object oPC = GetExitingObject();
    SavePCInfo(oPC);

    object oPCCount = GetFirstPC();
    int nPCs = -1;

    while (GetIsObjectValid(oPCCount))
    {
        nPCs = nPCs + 1;
        oPCCount = GetNextPC();
    }

    if (nPCs < 0) nPCs = 0;

    string sMessage = PlayerDetailedName(oPC)+" has left the game.";

    WriteTimestampedLogEntry(sMessage);

    SendDiscordLogMessage(sMessage+" - there " + (nPCs == 1 ? "is" : "are") + " now " + IntToString(nPCs) + " player" + (nPCs == 1 ? "" : "s") + " online.");
}

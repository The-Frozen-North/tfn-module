#include "inc_persist"
#include "inc_nwnx"

void main()
{
    SavePCInfo(GetExitingObject());

    object oPCCount = GetFirstPC();
    int nPCs = -1;

    while (GetIsObjectValid(oPCCount))
    {
        nPCs = nPCs + 1;
        oPCCount = GetNextPC();
    }

    if (nPCs < 0) nPCs = 0;

    SendDiscordLogMessage("There is now "+IntToString(nPCs)+" player(s) online.");
}

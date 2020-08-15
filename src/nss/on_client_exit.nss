#include "inc_persist"
#include "inc_nwnx"

void main()
{
    SavePCInfo(GetExitingObject());

    object oPCCount = GetFirstPC();
    int nPCs = 0;

    while (GetIsObjectValid(oPCCount))
    {
        nPCs = nPCs + 1;
        oPCCount = GetNextPC();
    }

    SendDiscordLogMessage("There is now "+IntToString(nPCs)+" player(s) online.");
}

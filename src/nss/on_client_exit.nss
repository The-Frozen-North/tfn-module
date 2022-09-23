#include "inc_persist"
#include "inc_webhook"
#include "inc_debug"

void main()
{
    object oPC = GetExitingObject();
    SavePCInfo(oPC);
    SQLocalsPlayer_SetInt(oPC, "RESTXP_LAST_SAVE", SQLite_GetTimeStamp());
    
    // Change henchman factions, otherwise they turn hostile to commoner factions and go killing sprees
    int i;
    for (i=0; i<GetHenchmanCount(oPC); i++)
    {
       object oHench = GetHenchmanByIndex(oPC, i);
       RemoveHenchman(oPC, oHench);
       ChangeToStandardFaction(oHench, STANDARD_FACTION_DEFENDER);
    }
    // ... and followers too
    for (i=0; i<GetFollowerCount(oPC); i++)
    {
       object oHench = GetFollowerByIndex(oPC, i);
       RemoveHenchman(oPC, oHench);
       ChangeToStandardFaction(oHench, STANDARD_FACTION_DEFENDER);
    }
    
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

#include "nwnx_events"
#include "inc_nwnx"

void main()
{
    string sIP = NWNX_Events_GetEventData("IP_ADDRESS");
    int nDM = StringToInt(NWNX_Events_GetEventData("IS_DM"));

    WriteTimestampedLogEntry("Connecting IP: "+sIP);
    /*
    if (nDM == 1)
    {
        string sKey = NWNX_Events_GetEventData("CDKEY");
        string sName = NWNX_Events_GetEventData("PLAYER_NAME");
        string sTargetKey;
        int nSkip = TRUE;

        int i;
        for (i = 0; i < 9; i++)
        {
            sTargetKey = Get2DAString("env_dm", "Value", i);
            if (sTargetKey != "" && sTargetKey == sKey)
            {
                nSkip = FALSE;
                break;
            }
        }

        if (nSkip)
        {
            WriteTimestampedLogEntry(sName+" attempted to connect as a DM without a whitelisted CD Key: "+sKey+" IP: "+sIP);
            WriteTimestampedLogEntry("WARNING: This may possibly mean an intruder has gained access to the DM password!");
            SendDiscordLogMessage("WARNING: "+sName+" (****"+GetStringRight(sKey, 4)+") attempted to connect as a DM with the correct password, but the CD Key was not whitelisted.");
            NWNX_Events_SkipEvent();
        }
    }
    */
}

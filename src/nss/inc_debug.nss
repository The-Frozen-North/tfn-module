#include "nwnx_webhook"

// Log it to a description object that can be viewed if set for debug.
// Optionally, put it in the log as well regardless
void SendDebugMessage(string sMessage, int bLog = FALSE);

// Returns the player's name, level, and character
string PlayerDetailedName(object oPC);

// TRUE if the server is running in a development environment
// Only developers can set the necessary variable to do this on the "live" server
int GetIsDevServer();

// True if oPC is a developer, as defined in the env files
int GetIsDeveloper(object oPC);

string PlayerDetailedName(object oPC)
{
    return GetPCPlayerName(oPC)+" (L"+IntToString(GetHitDice(oPC))+" "+GetName(oPC)+")";
}

void AppendServerError(string sError)
{
    object oError = GetObjectByTag("_error");
    string sErrors = GetLocalString(oError, "errors");

    SetEventScript(oError, EVENT_SCRIPT_PLACEABLE_ON_HEARTBEAT, "error_hb");

    SetLocalString(oError, "errors", sErrors+"|"+sError);
}

void SendDebugMessage(string sMessage, int bLog = FALSE)
{
    if (bLog) WriteTimestampedLogEntry(sMessage);

    if (GetLocalInt(GetModule(), "debug_verbose") == 1) SendMessageToPC(GetFirstPC(), "** DEBUG: "+sMessage+" **");
}

int GetIsDevServer()
{
    if (GetLocalInt(GetModule(), "dev") != 0)
    {
        return 1;
    }
    return 0;
}

int GetIsDeveloper(object oPC)
{
    string sPCCDKey = GetPCPublicCDKey(oPC);
    string sPCName = GetPCPlayerName(oPC);

    int nKeyLine;
    int nNameLine;

    // First iteration: lines 0 (key) and 1 (name)
    // After: line 4 (key) and 5 (name)
    int i;
    for (i=1; i<=2; i++)
    {
        if (i == 1)
        {
            nKeyLine = 0;
            nNameLine = 1;
        }
        else if (i == 2)
        {
            nKeyLine = 4;
            nNameLine = 5;
        }

        string sAdminName = Get2DAString("env", "Value", nNameLine);
        string sAdminCDKey = Get2DAString("env", "Value", nKeyLine);

        if (sAdminCDKey == "" || sAdminName == "") return FALSE;

        if (sPCName == sAdminName && sPCCDKey == sAdminCDKey)
        {
            SendMessageToPC(oPC, "Your Public CD Key --> " + sPCCDKey);
            SendMessageToPC(oPC, "Your PC Player Name --> " + sPCName);
            SendMessageToPC(oPC, "Your env.2da CD Key --> '" + sAdminCDKey + "'");
            SendMessageToPC(oPC, "Your env.2da Name --> '" + sAdminName + "'");
            return TRUE;
        }
    }
    return FALSE;
}

void SendDiscordLogMessage(string sMessage)
{
// TODO: Refactor to include "inc_webhook" and use the same constant instead of a "magic number"
    string sDiscordKey = Get2DAString("env", "Value", 2);

    if (sDiscordKey == "") return;

    if (GetLocalInt(GetModule(), "dev") == 0)
    {
        NWNX_WebHook_SendWebHookHTTPS("discordapp.com", sDiscordKey, sMessage);
    }
    else
    {
        // Try anyway
        NWNX_WebHook_SendWebHookHTTPS("discordapp.com", sDiscordKey, sMessage);
        // But the log is good
        WriteTimestampedLogEntry("Webhook message: " + sMessage);
    }
}

//void main(){}


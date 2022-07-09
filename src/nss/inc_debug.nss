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
    string sAdminCDKey = Get2DAString("env", "Value", 0);
    string sAdminName = Get2DAString("env", "Value", 1);

    if (sAdminCDKey == "" || sAdminName == "") return FALSE;

    if (sPCName == sAdminName && sPCCDKey == sAdminCDKey)
    {
        SendMessageToPC(oPC, "Your Public CD Key --> " + sPCCDKey);
        SendMessageToPC(oPC, "Your PC Player Name --> " + sPCName);
        SendMessageToPC(oPC, "Your env.2da CD Key --> '" + sAdminCDKey + "'");
        SendMessageToPC(oPC, "Your env.2da Name --> '" + sAdminName + "'");
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

//void main(){}


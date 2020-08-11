#include "nwnx_time"


// Log it to a description object that can be viewed if set for debug.
// Optionally, put it in the log as well regardless
void SendDebugMessage(string sMessage, int bLog = FALSE);

// Returns the player's name, level, and character
string PlayerDetailedName(object oPC);

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

int GetIsDeveloper(object oPC)
{
    if (GetPCPlayerName(oPC) == Get2DAString("env", "Value", 1) && GetPCPublicCDKey(oPC, TRUE) == Get2DAString("env", "Value", 0))
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

//void main(){}

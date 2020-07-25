#include "nwnx_webhook"

void SendDiscordMessage(string sPath, string sMessage)
{
    NWNX_WebHook_SendWebHookHTTPS("discordapp.com", sPath, sMessage);
}

void SendDiscordLogMessage(string sMessage)
{
    if (GetLocalInt(GetModule(), "dev") == 0) NWNX_WebHook_SendWebHookHTTPS("discordapp.com", Get2DAString("env", "Value", 2), sMessage);
}

//void main() {}
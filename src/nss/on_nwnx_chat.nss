#include "nwnx_chat"

int GetIsDMOn()
{
    object oPC = GetFirstPC();

    int bDMIsOn = FALSE;

    while (GetIsObjectValid(oPC))
    {
        if (GetIsDM(oPC))
        {
            bDMIsOn = TRUE;
            break;
        }

        oPC = GetNextPC();
    }

    return bDMIsOn;
}

void main()
{
    object oSender = NWNX_Chat_GetSender();

    if (GetIsPC(oSender) && NWNX_Chat_GetChannel() == NWNX_CHAT_CHANNEL_PLAYER_DM)
    {
        SendMessageToPC(oSender, "Message sent to DM channel: "+NWNX_Chat_GetMessage());
        if (!GetIsDMOn())
           SendMessageToPC(oSender, "There currently isn't a DM on.");
    }
}

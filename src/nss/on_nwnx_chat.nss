#include "nwnx_chat"
#include "nwnx_player"

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
    int nChannel = NWNX_Chat_GetChannel();
    if (GetIsPC(oSender) && nChannel == NWNX_CHAT_CHANNEL_PLAYER_DM)
    {
        SendMessageToPC(oSender, "Message sent to DM channel: "+NWNX_Chat_GetMessage());
        if (!GetIsDMOn())
           SendMessageToPC(oSender, "There currently isn't a DM on.");
    }
    else if (nChannel == NWNX_CHAT_CHANNEL_DM_TELL || nChannel == NWNX_CHAT_CHANNEL_PLAYER_TELL)
    {
        NWNX_Player_PlaySound(NWNX_Chat_GetTarget(), "gui_dm_alert");
    }
}

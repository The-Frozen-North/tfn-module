#include "inc_sql"
#include "inc_general"
#include "0i_win_layouts"

void main()
{
    object oPC = GetItemActivator();
    string sKey = GetPCPublicCDKey(oPC, TRUE);

    if (GetCampaignInt(sKey, "pc_menu_disabled") == 1)
    {
        SendColorMessageToPC(oPC, "Player menu enabled", MESSAGE_COLOR_INFO);
        DeleteCampaignVariable(sKey, "pc_menu_disabled");
        PopUpPlayerHorGUIPanel(oPC);
    }
    else
    {
        SendColorMessageToPC(oPC, "Player menu disabled", MESSAGE_COLOR_INFO);
        SetCampaignInt(sKey, "pc_menu_disabled", 1);
        NuiDestroy(oPC, NuiFindWindow(oPC, "pcplayerwin"));
    }
}

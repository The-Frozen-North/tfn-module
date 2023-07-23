#include "inc_sql"
#include "inc_general"
#include "0i_win_layouts"

void main()
{
    object oPC = GetItemActivator();

    if (SQLocalsPlayer_GetInt(oPC, "pc_menu_disabled") == 1)
    {
        SendColorMessageToPC(oPC, "Player menu enabled", MESSAGE_COLOR_INFO);
        SQLocalsPlayer_DeleteInt(oPC, "pc_menu_disabled");
        PopUpPlayerHorGUIPanel(oPC);
    }
    else
    {
        SendColorMessageToPC(oPC, "Player menu disabled", MESSAGE_COLOR_INFO);
        SQLocalsPlayer_SetInt(oPC, "pc_menu_disabled", 1);
        NuiDestroy(oPC, NuiFindWindow(oPC, "pcplayerwin"));
    }
}

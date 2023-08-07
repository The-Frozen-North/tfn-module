/*//////////////////////////////////////////////////////////////////////////////
 Script Name: load_nui_menu
 Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
    Loads the NUI menu based on if your a player or a dm.
/*//////////////////////////////////////////////////////////////////////////////
#include "0i_win_layouts"
#include "0i_database"

void main()
{
    string sKey = GetPCPublicCDKey(OBJECT_SELF, TRUE);
    if (GetCampaignInt(sKey, "pc_menu_disabled") != 1)
    {
        // Sets up the player target event.
        // If you have a target event then you will have to adjust it for you NUI.
        // SetEventScript (GetModule (), EVENT_SCRIPT_MODULE_ON_PLAYER_TARGET, "0e_player_target");
        // Create and initialize our database.
        // We use the database to save options and the location of our menus.
        CheckServerDataTableAndCreateTable (PLAYER_TABLE);
        CheckServerDataAndInitialize (OBJECT_SELF, PLAYER_TABLE);
        // See which menu the player would like to see (Horizontal or Vertical).
        // int nData = GetServerDatabaseInt (OBJECT_SELF, PLAYER_TABLE, "pcplayerwinhv");
        // Load up the GUIPanel.
        // if (nData) PopUpPlayerVerGUIPanel (OBJECT_SELF);
        // else PopUpPlayerHorGUIPanel (OBJECT_SELF);

        PopUpPlayerHorGUIPanel (OBJECT_SELF);
    }
}




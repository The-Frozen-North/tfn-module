/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_win_design_pc
////////////////////////////////////////////////////////////////////////////////
 Include script for handling window displays.

 To size a layout you must base the size on a scale of 1.0 and a simple way to
 calculate a scale 1.0 layout is to use the following numbers to calculate it.
 Layout pixel sizes:
 Pixel width for Title bar 33.
 Pixel height for Top edge 12, between widgets 8, bottom edge 12.
 Pixel width for Left edge 12, between widgets 4, right edge 12.

 Use these pixel sizes to size your layouts width and height.
 Example for PopUpPlayerHorGUIPanel.

 Calculate Width: Row 1 has 3 buttons with a width of 100 each.
 Left edge + Button1 + Space + Button2 + Space + Button3 + Right Edge
 12 + 100 + 8 + 100 + 8 + 100 + 12 = 340.0f

 Calculate Height: 2 rows with the buttons height of 35
 Title bar + Top edge + Button1 + Space + Button2 + Bottom edge
 33 + 12 + 35 + 4 + 35 + 12 = 131.0f
*///////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
#include "0i_window"
#include "nw_inc_nui_insp"
#include "inc_sql"

const string WIKI_LINK = "https://github.com/b5635/the-frozen-north/wiki";
const string DISCORD_LINK = "discord.gg/qKqRUDZ";

// Finishes the player GUIPanel after the layout is set.
void SetupPlayerGUIPanel (object oPC, json jCol, float fWinWidth, float fWinHeight)
{
    //MakeWindowInspector (oPC);
    // Create event so we can capture window button pushes and such on all windows.
    // SetEventScript (GetModule (), EVENT_SCRIPT_MODULE_ON_NUI_EVENT, "0e_window");
    // Get the window location to restore it from the database.
    float fX = GetServerDatabaseFloat (oPC, PLAYER_TABLE, "pcplayerwinx");
    float fY = GetServerDatabaseFloat (oPC, PLAYER_TABLE, "pcplayerwiny");
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
/*    int nToken = SetWindow (oPC, jLayout, "FALSE", PM_NAME,
                            fX, fY, fWinWidth, fWinHeight, PM_RESIZE,
                            FALSE, FALSE, FALSE, PM_BORDER);
*/
    int nToken = SetWindow (oPC, jLayout, "pcplayerwin", PM_NAME,
                            fX, fY, fWinWidth, fWinHeight, PM_RESIZE,
                            PM_COLLAPSE, PM_CLOSE, PM_TRANSPARENT, PM_BORDER);

    // Save token incase we need to change layout.
    SetLocalInt (oPC, "0_Menu_Token", nToken);
    // Set the binds and watches for the layout,
    // Set the buttons on or off within the window.
    NuiSetBind (oPC, nToken, "btn_info", JsonBool (PM_INFO));
    NuiSetBind (oPC, nToken, "btn_bug_report", JsonBool (PM_BUG_REPORT));
    NuiSetBind (oPC, nToken, "btn_desc", JsonBool (PM_DESCRIPTION));
    NuiSetBind (oPC, nToken, "btn_dice", JsonBool (PM_DICE));
    NuiSetBind (oPC, nToken, "btn_options", JsonBool (PM_OPTIONS));
    NuiSetBind (oPC, nToken, "btn_pc_summary", JsonBool (PM_PC_SUMMARY));
    // Set the buttons to show events to 0e_window.
    NuiSetBind (oPC, nToken, "btn_info_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_bug_report_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_desc_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_dice_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_options_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_pc_summary_event", JsonBool (TRUE));
    // Set event watches for window inspector and saving the location.
    NuiSetBindWatch (oPC, nToken, "collapsed", TRUE);
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
}

// Setup the Horizontal Layout to the player GUIPanel.

void PopUpPlayerHorGUIPanel (object oPC)
{
    if (SQLocalsPlayer_GetInt(oPC, "pc_menu_disabled") == 1)
        return;

    // Set a variable so we don't save the windows position when it is created.
    // This keeps the players last x,y position of the window from being erased.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // ********** Create new Column *******
    // I am only using one column for these menus.
    json jCol = JsonArray ();
    // *************************************************************************
    // Create row 1 (buttons).
    json jRow = JsonArray ();
    jRow = CreateButton (jRow, "Information", "btn_info", 110.0, 35.0);
    jRow = CreateButton (jRow, "Report a bug", "btn_bug_report", 110.0, 35.0);
    jRow = CreateButton (jRow, "Options", "btn_options", 110.0, 35.0);
    // Add the row to the column and set the row height.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // *************************************************************************
    // Create row 2 (buttons).
    jRow = JsonArray ();
    jRow = CreateButton (jRow, "PC Description", "btn_desc", 110.0, 35.0);
    jRow = CreateButton (jRow, "Dice Roll", "btn_dice", 110.0, 35.0);
    jRow = CreateButton (jRow, "PC Summary", "btn_pc_summary", 110.0, 35.0);
    // Add the row to the column and set column height.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Adjust the layout variables and load window.
    SetupPlayerGUIPanel (oPC, jCol, PM_WIN_HORIZONTAL_WIDTH, PM_WIN_HORIZONTAL_HEIGHT);
}

/*
// Setup the Vertical Layout to the player GUIPanel.
void PopUpPlayerVerGUIPanel (object oPC)
{
    // Set a variable so we don't save the windows position when it is created.
    // This keeps the players last x,y position of the window from being erased.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // ********** Create new Column *******
    // I am only using one column for these menus.
    json jCol = JsonArray ();
    // *************************************************************************
    // Create row 1 (buttons).
    json jRow = JsonArray ();
    jRow = CreateButton (jRow, "Options", "btn_options", 100.0, 35.0);
    jRow = CreateButton (jRow, "Bug Report", "btn_bug_report", 100.0, 35.0);
    // Add the row to the column and set column height.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // *************************************************************************
    // Create row 2 (buttons).
    jRow = JsonArray ();
    jRow = CreateButton (jRow, "Dice", "btn_dice", 100.0, 35.0);
    jRow = CreateButton (jRow, "Description", "btn_desc", 100.0, 35.0);
    // Add the row to the column and set column height.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // *************************************************************************
    // Create row 3 (buttons).
    jRow = JsonArray ();
    jRow = CreateButton (jRow, "Teleport", "btn_teleport", 100.0, 35.0);
    jRow = CreateButton (jRow, "", "btn_summons", 100.0, 35.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Adjust the layout variables and load window.
    SetupPlayerGUIPanel (oPC, jCol, PM_WIN_VERTICAL_WIDTH, PM_WIN_VERTICAL_HEIGHT);
}
*/

// Setup the Player Info layout GUIPanel.
void PopUpPlayerInfoGUIPanel (object oPC)
{
    if (SQLocalsPlayer_GetInt(oPC, "pc_menu_disabled") == 1)
        return;

    // Set a variable so we don't save the windows position when it is created.
    // This keeps the players last x,y position of the window from being erased.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // ********** Create new Column *******
    // I am only using one column for these menus.
    json jCol = JsonArray ();
    // *************************************************************************
    // Row 1
    json jRow = JsonArray ();
    jRow = CreateTextBox(jRow, "info_line1", 600.0, 100.0);
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // *************************************************************************
    // Row 2
    jRow = JsonArray ();
    jRow = CreateTextBox(jRow, "info_line2", 600.0, 100.0);
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // *************************************************************************
    // Row 3
    jRow = JsonArray ();
    jRow = CreateTextBox(jRow, "info_github", 600.0, 20.0);
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // *************************************************************************
    // Row 4
    jRow = JsonArray ();
    jRow = CreateTextEditBox (jRow, "github_link", "github_link", GetStringLength(WIKI_LINK), FALSE, 400.0, 30.0, "github_tooltip");
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // *************************************************************************
    // Row 5
    jRow = JsonArray ();
    jRow = CreateTextBox(jRow, "info_discord", 600.0, 20.0);
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // *************************************************************************
    // Row 6
    jRow = JsonArray ();
    jRow = CreateTextEditBox (jRow, "discord_link", "discord_link", GetStringLength(DISCORD_LINK), FALSE, 200.0, 30.0, "discord_tooltip");
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));

    // Get the window location to restore it from the database.
    float fX = GetServerDatabaseFloat (oPC, PLAYER_TABLE, "pcinfowinx");
    float fY = GetServerDatabaseFloat (oPC, PLAYER_TABLE, "pcinfowiny");
    // Set the Layout of the window.
    json jLayout = NuiCol (jCol);
    int nToken = SetWindow (oPC, jLayout, "pcinfowin", "Information",
                            fX, fY, 630.0, 450.0, FALSE, FALSE, TRUE, FALSE, TRUE);

    NuiSetBind (oPC, nToken, "info_line1", JsonString("Welcome to The Frozen North! This is a persistent world capped at level 12, with an aim to keep class and spell changes to a minimal - done with an effort by meticulously balancing items and encounters accordingly while keeping things challenging!"));
    NuiSetBind (oPC, nToken, "info_line2", JsonString("The adventures in this world are based around official content, mainly Neverwinter and the surrounding areas, with stories and locations from the original campaign, Hordes of the Underdark, Neverwinter Nights 2, Icewind Dale, and much more."));

    NuiSetBind (oPC, nToken, "info_github", JsonString("For more information, features, changes, and server rules, visit our GitHub wiki below."));
    NuiSetBind (oPC, nToken, "github_link", JsonString(WIKI_LINK));
    NuiSetBind (oPC, nToken, "github_tooltip", JsonString("You can copy and paste this into your web browser."));

    NuiSetBind (oPC, nToken, "info_discord", JsonString("For any questions, please feel free to join the discord and ask. We don't bite."));
    NuiSetBind (oPC, nToken, "discord_link", JsonString(DISCORD_LINK));
    NuiSetBind (oPC, nToken, "discord_tooltip", JsonString("You can copy and paste this into your web browser or Discord app."));

    // Get the horizontal / vertical option from the database so we can
    // restore the combo box selection to the last saved.
    int nOption = GetServerDatabaseInt (oPC, PLAYER_TABLE, "pcplayerwinhv");
    // Needed to save the location of the window.
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);

    NuiSetBindWatch (oPC, nToken, "discord_link", TRUE);
    NuiSetBindWatch (oPC, nToken, "github_link", TRUE);
}

// Setup the Character description layout GUIPanel.
void PopUpCharacterDescriptionGUIPanel (object oPC)
{
    // are we possessing something?
    object oMaster = GetMaster(oPC);
    if (GetIsObjectValid(oMaster)) oPC = oMaster;

    // Set a variable so we don't save the windows position when it is created.
    // This keeps the players last x,y position of the window from being erased.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // ********** Create new Column *******
    // I am only using one column for these menus.
    json jCol = JsonArray ();
    /*
    // *************************************************************************
    // Create row 1 (portait name).
    json jRow = JsonArray ();
    // Adding a spacer before and after the text edit box so it will be centered.
    // Spacers are used like Left/Center/Right alignment for widgets.
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Creating a text edit box so they can enter a custom portrait.
    jRow = CreateTextEditBox (jRow, "port_p_holder", "port_name", 15,
                              FALSE, 140.0, 30.0, "port_tooltip");
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // *************************************************************************
    // Create row 2 (portait id number).
    jRow = JsonArray ();
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Adding a spacer before and after the lable so it will be centered.
    jRow = CreateLabel (jRow, "port_id", 140.0, 10.0f);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // *************************************************************************
    // Create row 3 (portait).
    jRow = JsonArray();
    // Adding a spacer before and after the portrait so it will be centered.
    // Spacers are used like Left/Center/Right alignment for widgets.
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Create the portait.
    json jImg = NuiImage (NuiBind ("port_resref"),
                          JsonInt (NUI_ASPECT_EXACT),
                          JsonInt (NUI_HALIGN_CENTER),
                          JsonInt (NUI_VALIGN_TOP));
    // Group the portait and adjust its width and height.
    jImg = NuiGroup (jImg);
    jImg = NuiWidth (jImg, 140.0);
    jImg = NuiHeight (jImg, 160.0);
    // Now add it to the row.
    jRow = JsonArrayInsert (jRow, jImg);
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // *************************************************************************
    // Create row 4 (portait buttons).
    jRow = JsonArray();
    // Adding a spacer before and after the buttons so it will be centered.
    // Spacers are used like Left/Center/Right alignment for widgets.
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateButton (jRow, "<", "btn_portrait_prev", 42.0f, 40.0);
    jRow = CreateButton (jRow, "Set", "btn_portrait_ok", 44.0f, 40.0);
    jRow = CreateButton (jRow, ">", "btn_portrait_next", 42.0f, 40.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // *************************************************************************
    // Create row 5 (Desctiption label).
    json jRow = JsonArray();
    jRow = CreateLabel (jRow, "description_label", 300.0, 10.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    */
    // *************************************************************************
    // Create row 6 (Character Description box).
    json jRow = JsonArray();
    // Create the large description box for the player
    // to edit the characters description.
    jRow = CreateTextEditBox (jRow, "desc_Placeholder", "desc_value",
                              1000, TRUE, 300.0, 200.0, "desc_tooltip");
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // *************************************************************************
    // Create row 7 (Character Description box).

    jRow = JsonArray();
    // Adding a spacer before and after the label so it will be centered.
    // Spacers are used like Left/Center/Right alignment for widgets.
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateButton (jRow, "Save Description", "btn_desc_save", 150.0f, 30.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Get the window location to restore it from the database.
    float fX = GetServerDatabaseFloat (oPC, PLAYER_TABLE, "pcdescwinx");
    float fY = GetServerDatabaseFloat (oPC, PLAYER_TABLE, "pcdescwiny");
    // Add the column to the layout.
    json jLayout = NuiCol (jCol);
    int nToken = SetWindow (oPC, jLayout, "pcdescwin", "Edit " + GetName (oPC) + "'s Description",
                            fX, fY, 325.0, 280.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set the binds and watches for the layout.
    // Grab the players portrait Id and save it on to the layout for later use.
    int nID = GetPortraitId (oPC);
    NuiSetUserData (oPC, nToken, JsonInt (nID));
    string sID;
    // If the Id is 65535 then it is a custom portrait so lets show that.
    if (nID == PORTRAIT_INVALID) sID = "Custom Portrait";
    else sID = IntToString (nID);
    // Get the players portrait resref so we can display the portrait.
    string sResRef = GetPortraitResRef (oPC);
    // Set the portrait name to be watch in e_window_pc so we can update any
    // NuiSetBind (oPC, nToken, "port_name", JsonString (sResRef));
    // NuiSetBind (oPC, nToken, "port_id", JsonString (sID));
    // NuiSetBind (oPC, nToken, "port_resref", JsonString (sResRef + "l"));
    // Add a tool tip so the player knows they can enter a custom portrait.
    // NuiSetBind (oPC, nToken, "port_tooltip", JsonString ("You may also type the portrait file name."));
    // Set the buttons to show events to 0e_window_pc.
    // NuiSetBind (oPC, nToken, "btn_portrait_prev_event", JsonBool (TRUE));
    // NuiSetBind (oPC, nToken, "btn_portrait_next_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_desc_save_event", JsonBool (TRUE));
    // NuiSetBind (oPC, nToken, "btn_portrait_ok_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "desc_tooltip", JsonString ("You can edit your character's description when examined."));
    NuiSetBind (oPC, nToken, "description_label", JsonString ("Edit " + GetName (oPC) + "'s Description"));
    // Get the players description and put it into the description edit box.
    string sDescription = GetDescription (oPC);
    NuiSetBind (oPC, nToken, "desc_value", JsonString (sDescription));
    // custom portrait entered.
    // NuiSetBindWatch (oPC, nToken, "port_name", TRUE);
    // This watch is needed to save the location of the window.
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
}

// Setup the Bug report layout GUIPanel.
void PopUpBugReportGUIPanel (object oPC, string sWinID)
{
    // Set a variable so we don't save the windows position when it is created.
    // This keeps the players last x,y position of the window from being erased.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // ********** Create new Column *******
    // I am only using one column for these menus.
    json jCol = JsonArray ();
    // *************************************************************************
    // Create row 1 (label).
    json jRow = JsonArray ();
    jRow = CreateTextBox(jRow, "bug_report_label", 300.0, 40.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // *************************************************************************
    // Create row 2 (bug report text edit box).
    jRow = JsonArray();
    jRow = CreateTextEditBox (jRow, "bug_Placeholder", "bug_value", 1000,
                              TRUE, 300.0, 200.0, "bug_tooltip");
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // *************************************************************************
    // Create row 3 (save button).
    jRow = JsonArray();
    // Adding a spacer before and after the label so it will be centered.
    // Spacers are used like Left/Center/Right alignment for widgets.
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateButton (jRow, "Send Report", "btn_bug_save", 150.0f, 30.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Get the window location to restore it from the database.
    float fX = GetServerDatabaseFloat (oPC, PLAYER_TABLE, sWinID + "x");
    float fY = GetServerDatabaseFloat (oPC, PLAYER_TABLE, sWinID + "y");
    // Set the Layout of the window.
    json jLayout = NuiCol (jCol);
    int nToken = SetWindow (oPC, jLayout, sWinID, "Report a Bug",
                            fX, fY, 325.0, 350.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set the binds and watches for the layout.
    // Add a tool tip so the player knows to enter informaton in this box.
    NuiSetBind (oPC, nToken, "bug_tooltip", JsonString ("Please enter as much information as you can."));
    // Set the buttons to show events to 0e_window_pc.
    NuiSetBind (oPC, nToken, "bug_report_label", JsonString ("Your coordinates and area will be automatically sent. Thank you!"));
    NuiSetBind (oPC, nToken, "bug_value", JsonString (""));
    // Setup text edit box so we can activate the save button once text is written.
    NuiSetBindWatch (oPC, nToken, "bug_value", TRUE);
    // This watch is needed to save the location of the window.
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
}

// Setup the Dice layout GUIPanel.
void PopUpDiceGUIPanel (object oPC, string sWinID)
{
    // Set a variable so we don't save the windows position when it is created.
    // This keeps the players last x,y position of the window from being erased.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // ********** Create new Column *******
    // I am only using one column for these menus.
    json jCol = JsonArray ();
    // *************************************************************************
    // Create row 1 (labels).
    json jRow = JsonArray ();
    jRow = CreateLabel (jRow, "broadcast_label", 100.0, 30.0f);
    jRow = CreateLabel (jRow, "num_label", 75.0, 30.0f);
    jRow = CreateLabel (jRow, "type_label", 200.0, 30.0f);
    jRow = CreateLabel (jRow, "bonus_label", 75.0, 30.0f);
    jRow = CreateLabel (jRow, "roll_title", 200.0, 30.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // *************************************************************************
    // Create row 2 (combo boxes).
    jRow = JsonArray ();
    jRow = CreateBroadcastCombo (oPC, jRow, "broadcast_combo");
    jRow = CreateNumOfDiceCombo (oPC, jRow, "num_dice_combo");
    jRow = CreateRollTypeCombo (oPC, jRow, "type_roll_combo");
    jRow = CreateDieBonusCombo (oPC, jRow, "die_bonus_combo");
    jRow = CreateTextEditBox (jRow, "roll_place", "roll_text", 30, FALSE, 200.0f, 35.0f);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // *************************************************************************
    // Create row 3 (Roll Button).
    jRow = JsonArray ();
    // Adding a spacer before and after the label so it will be centered.
    // Spacers are used like Left/Center/Right alignment for widgets.
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateButton (jRow, "Roll", "btn_roll", 200.0f, 30.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Get the window location to restore it from the database.
    float fX = GetServerDatabaseFloat (oPC, PLAYER_TABLE, sWinID + "x");
    float fY = GetServerDatabaseFloat (oPC, PLAYER_TABLE, sWinID + "y");
    // Set the Layout of the window.
    json jLayout = NuiCol (jCol);
    int nToken = SetWindow (oPC, jLayout, sWinID, "Dice Rolls",
                        fX, fY, 690.0, 168.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set the binds and watches for the layout,
    // Set the binds for the labels.
    NuiSetBind (oPC, nToken, "num_label", JsonString ("# of Rolls"));
    NuiSetBind (oPC, nToken, "type_label", JsonString ("Type of Roll"));
    NuiSetBind (oPC, nToken, "bonus_label", JsonString ("Modifier"));
    NuiSetBind (oPC, nToken, "broadcast_label", JsonString ("Channels"));
    NuiSetBind (oPC, nToken, "roll_title", JsonString ("Roll to Be Made"));
    NuiSetBind (oPC, nToken, "roll_label", JsonString (GetRollText (oPC)));
    // Set the combo box selections.
    NuiSetBind (oPC, nToken, "num_dice_combo_selected", JsonInt (GetLocalInt (oPC, "0_NumDice")));
    NuiSetBind (oPC, nToken, "type_roll_combo_selected", JsonInt (GetLocalInt (oPC, "0_TypeRoll")));
    NuiSetBind (oPC, nToken, "die_bonus_combo_selected", JsonInt (GetLocalInt (oPC, "0_DieBonus")));
    if (GetIsDM (oPC) && GetLocalInt (oPC, "0_Broadcast") == 0) SetLocalInt (oPC, "0_Broadcast", 1);
    NuiSetBind (oPC, nToken, "broadcast_combo_selected", JsonInt (GetLocalInt (oPC, "0_Broadcast")));
    // Set the buttons/combo boxes to show events to 0e_window_pc.
    NuiSetBind (oPC, nToken, "btn_roll", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "num_dice_combo_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "type_roll_combo_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "die_bonus_combo_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "broadcast_combo_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_roll_event", JsonBool (TRUE));
    // Setup the roll text window.
    NuiSetBind (oPC, nToken, "roll_text", JsonString (GetRollText (oPC)));
    // Watch the selections so we can update the roll_label with the correct dice roll.
    NuiSetBindWatch (oPC, nToken, "num_dice_combo_selected", TRUE);
    NuiSetBindWatch (oPC, nToken, "type_roll_combo_selected", TRUE);
    NuiSetBindWatch (oPC, nToken, "die_bonus_combo_selected", TRUE);
    NuiSetBindWatch (oPC, nToken, "broadcast_combo_selected", TRUE);
    // This watch is needed to save the location of the window.
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
}

// Setup the Bug report layout GUIPanel.
void PopUpOptionsGUIPanel (object oPC, string sWinID)
{
    // Set a variable so we don't save the windows position when it is created.
    // This keeps the players last x,y position of the window from being erased.
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // ********** Create new Column *******
    // I am only using one column for these menus.
    json jCol = JsonArray ();
    // *************************************************************************
    // Create row 1 (label).
    json jRow = JsonArray ();
    jRow = CreateCheckBox(jRow, "hide_discord_label", "hide_discord_value", 300.0, 40.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));

    // Get the window location to restore it from the database.
    float fX = GetServerDatabaseFloat (oPC, PLAYER_TABLE, sWinID + "x");
    float fY = GetServerDatabaseFloat (oPC, PLAYER_TABLE, sWinID + "y");
    // Set the Layout of the window.
    json jLayout = NuiCol (jCol);
    int nToken = SetWindow (oPC, jLayout, sWinID, "Player Options",
                            fX, fY, 350.0, 150.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set the binds and watches for the layout.
    int bHideDiscord = GetCampaignInt(GetPCPublicCDKey(oPC), "hide_discord");
    NuiSetBind (oPC, nToken, "hide_discord_label", JsonString ("Hide non-login Discord Activities"));
    NuiSetBind (oPC, nToken, "hide_discord_value", JsonBool (bHideDiscord));
    NuiSetBindWatch (oPC, nToken, "hide_discord_value", TRUE);

    // This watch is needed to save the location of the window.
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
}



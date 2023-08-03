#include "0i_window"
#include "nw_inc_nui_insp"
#include "inc_nui_config"

void main ()
{
   object oPC = GetPCSpeaker();

   string sWinID = "namepet";
   //SendMessageToPC(GetFirstPC(), "tag: "+GetTag(OBJECT_SELF));

   SetLocalInt(oPC, "pet_target", GetLocalInt(OBJECT_SELF, "target"));

   // ********** Create new Column *******
    // I am only using one column for these menus.
    json jCol = JsonArray ();
    // *************************************************************************
    // Create row 1 (label).
    json jRow = JsonArray ();
    jRow = CreateTextBox(jRow, "name_pet_label", 300.0, 30.0f);
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // *************************************************************************
    // Create row 2 (bug report text edit box).
    jRow = JsonArray();
    jRow = CreateTextEditBox (jRow, "name_Placeholder", "name_value", 1000,
                              FALSE, 300.0, 50.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // *************************************************************************
    // Create row 3 (save button).
    jRow = JsonArray();
    // Adding a spacer before and after the label so it will be centered.
    // Spacers are used like Left/Center/Right alignment for widgets.
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateButton (jRow, "Confirm name", "btn_name_save", 150.0f, 30.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Set the Layout of the window.
    json jLayout = NuiCol (jCol);
    int nToken = SetWindow (oPC, jLayout, sWinID, "Name Pet",
                            1000.0, 300.0, 325.0, 200.0, FALSE, FALSE, TRUE, FALSE, TRUE);

    //json jGeometry = GetPersistentWindowGeometryBind(oPC, sWinID, NuiRect(-1.0, -1.0, 325.0, 150.0));
    //json jNui = EditableNuiWindow(sWinID, "Name Pet", jLayout, "Name Pet", jGeometry, 0, 0, 1, JsonBool(0), JsonBool(1));
    //int nToken = NuiCreate(oPC, jNui, sWinID);
    //SetIsInterfaceConfigurable(oPC, nToken, FALSE, FALSE);
    //LoadNuiConfigBinds(oPC, nToken);
    //json jUserData = NuiGetUserData(oPC, nToken);
    //jUserData = JsonObjectSet(jUserData, "event_script", JsonString("name_pet_nui"));
    //NuiSetUserData(oPC, nToken, jUserData);

    // Set the binds and watches for the layout.
    // Add a tool tip so the player knows to enter informaton in this box.
    // Set the buttons to show events to 0e_window_pc.
    NuiSetBind (oPC, nToken, "name_pet_label", JsonString ("Enter a name for your pet."));
    NuiSetBind (oPC, nToken, "name_value", JsonString (GetName(OBJECT_SELF)));
    // Setup text edit box so we can activate the save button once text is written.
    NuiSetBind (oPC, nToken, "btn_name_save_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "name_value", TRUE);
    // This watch is needed to save the location of the window.
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
}

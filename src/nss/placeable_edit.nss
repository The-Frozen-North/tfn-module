#include "inc_housing"
#include "0i_win_layouts"

// NUI code from Philos. Thanks!
int PopUpPlaceableGUIPanel(object oPC, object oTarget)
{
    SetLocalObject (oPC, "0_Placeable_Target", oTarget);
    // Get the DM target.
    // object oTarget = GetLocalObject(oPC, "0_Placeable_Target");
    // Row 1 (RotateRight/North/RotateLeft)************************************* 45
    json jRow = JsonArrayInsert (JsonArray (), NuiSpacer());
    jRow = CreateButton (jRow, "Rotate Left", "btn_rotate_left", 110.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    jRow = CreateButton (jRow, "North", "btn_north", 110.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    jRow = CreateButton (jRow, "Rotate Right", "btn_rotate_right", 110.0, 25.0);
    jRow = JsonArrayInsert(jRow, NuiSpacer());
    // Add the row to the column.
    json jCol = JsonArrayInsert (JsonArray (), NuiRow (jRow));
    // Row 2 (West/Reset/East)************************************************** 78
    jRow = CreateButton (JsonArray (), "West", "btn_west", 110.0, 25.0);
    jRow = CreateButton (jRow, "Reset", "btn_reset", 110.0, 25.0);
    jRow = CreateButton (jRow, "East", "btn_east", 110.0, 25.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 3 (Up/South/Down)**************************************************** 111
    jRow = CreateButton (JsonArray (), "Up", "btn_up", 110.0, 25.0);
    jRow = CreateButton (jRow, "South", "btn_south", 110.0, 25.0);
    jRow = CreateButton (jRow, "Down", "btn_down", 110.0, 25.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (Fine rotation slider, -90..+90 degrees)
    jRow = CreateLabelText (JsonArray (), "Fine rotation (-90 to +90)", "rot_label", 338.0, 20.0, -1.0, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE);
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    jRow = CreateSlider (JsonArray (), "rot_slider", 338.0, 25.0);
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));

    jRow = JsonArrayInsert (JsonArray (), NuiSpacer());
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    //jRow = CreateLabel (jRow, "name_label", 200.0, 25.0f);
    //jRow = CreateLabel (jRow, "", "name", 300.0, 25.0, NUI_HALIGN_CENTER, NUI_VALIGN_MIDDLE);
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    // Add the row to the column.
    //jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 5 (Destroy)********************************************************** 177
    // jRow = CreateButton (JsonArray (), "Get Placeable", "btn_get_placeable", 167.0, 25.0);
    jRow = JsonArrayInsert (JsonArray (), NuiSpacer());
    jRow = CreateButton (jRow, "Retrieve", "btn_destroy", 100.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    jRow = CreateButton (jRow, "", "btn_edit", 100.0, 25.0);
    jRow = JsonArrayInsert (jRow, NuiSpacer());
    jRow = CreateButton (jRow, "Save", "btn_save", 100.0, 25.0);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Set the layout of the window.
    json jLayout = NuiCol (jCol);
    float fY = GetGUIHeightMiddle (oPC, 270.0);
    string sName = GetName(oTarget);// StripColorCodes (GetName (oTarget));
    // Events for this window go straight to placeable_nui instead of on_nuievent.
    int nToken = SetWindow (oPC, jLayout, "moveplaceablewin", "Edit "+sName,
                            0.0, fY, 362.0, 270.0, FALSE, FALSE, TRUE, FALSE, TRUE, "placeable_nui");
    // Enable the buttons.
    SetLocalLocation (oTarget, "0_Reset_Location", GetLocation (oTarget));
    json jButtons = JsonParse("[\"btn_rotate_right\",\"btn_north\",\"btn_rotate_left\",\"btn_west\",\"btn_reset\",\"btn_east\",\"btn_up\",\"btn_south\",\"btn_down\",\"btn_destroy\",\"btn_save\",\"btn_edit\"]");
    int i;
    for (i = 0; i < JsonGetLength(jButtons); i++)
    {
        NuiSetBind(oPC, nToken, JsonGetString(JsonArrayGet(jButtons, i)) + "_event", JsonBool(TRUE));
    }

    // Fine rotation slider: offset in degrees from the current facing, 0 at start.
    DeleteLocalInt (oPC, "placeable_edit_off");
    NuiSetBind (oPC, nToken, "btn_edit_label", JsonString ("Edit On"));
    SetLocalFloat (oPC, "placeable_base_facing", GetFacing (oTarget));
    NuiSetBind (oPC, nToken, "rot_slider_min", JsonInt (-90));
    NuiSetBind (oPC, nToken, "rot_slider_max", JsonInt (90));
    NuiSetBind (oPC, nToken, "rot_slider_stepsize", JsonInt (1));
    NuiSetBind (oPC, nToken, "rot_slider_value", JsonInt (0));
    NuiSetBind (oPC, nToken, "rot_slider_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "rot_slider_value", TRUE);

    return nToken;
}

void main()
{
    object oPC = GetPlaceableLastClickedBy();
    
    if (GetIsPC(oPC))
    {
        if (IsInOwnHome(oPC))
        {
            AssignCommand(oPC, ClearAllActions()); // clear all actions as players will just run up to it and possibly use the placeable
            // SetLocalObject (oPC, "0_Placeable_Target", OBJECT_SELF);
            PopUpPlaceableGUIPanel(oPC, OBJECT_SELF);
        }
        else
        {
            FloatingTextStringOnCreature("This house does not belong to you.", oPC, FALSE);
        }
    }
}

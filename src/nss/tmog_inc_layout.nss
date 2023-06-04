/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_win_layout_pc
////////////////////////////////////////////////////////////////////////////////
 Include script for creating player and DM layouts for NUI.

 Layout pixel sizes:
 Pixel width Title bar 33.
 Pixel height Top edge 12, between widgets 8, bottom edge 12.
 Pixel width Left edge 12, between widgets 4, right edge 12.
*///////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
#include "nw_inc_nui_insp"
#include "tmog_inc_window"
#include "tmog_inc_craft"

const float BUTTON_WIDTH = 130.0f;
const float PALETTE_WIDTH = 256.0f;

json CreateItemCombo (object oPC, json jRow, string sComboBind);
json CreateModelCombo (object oPC, json jRow, string sComboBind);
json CreateMaterialCombo (object oPC, json jRow, string sComboBind);

// Sets a string of characters between the predefined markers of ":".
// sArray is the text holding the array.
// sArray should look as follows ":0:0:0:0:0:"
// iIndex is the number of the data we are searching for.
// A 0 iIndex is the first item in the text array.
// sField is the field of characters to replace that index.
// sSeperator is the character that seperates the array (Usefull for Multiple arrays in one string).
string SetStringArray (string sArray, int iIndex, string sField, string sSeperator = ":")
{
   int iCount = 1, iMark = 1, iStringLength = GetStringLength (sArray);
   int iIndexCounter = 0;
   string sChar, sNewArray = sSeperator, sText;
   // Check to make sure this is not a new array.
   // If it is new then set it with 1 slot.
   if (iStringLength < 2)
   {
        sArray = sSeperator + " " + sSeperator;
        iStringLength = 3;
   }
   // Search the string.
   while (iCount <= iStringLength)
   {
      sChar = GetSubString (sArray, iCount, 1);
      // Look for the mark.
      if (sChar == sSeperator)
      {
            // First check to see if this is the index we are replacing.
            if (iIndex == iIndexCounter) sText = sField;
            else
            {
                // Get the original text for this field.
                sText = GetSubString (sArray, iMark, iCount - iMark);
            }
            // Add the field to the new index.
            sNewArray = sNewArray + sText + sSeperator;
            // Now set the marker to the new starting point.
            iMark = iCount + 1;
            // Increase the index counter as well.
            iIndexCounter ++;
      }
      iCount ++;
   }
   // if we are at the end of the array and still have not set the data
   // then add blank data until we get to the correct index.
   while (iIndexCounter <= iIndex)
   {
        // If they match add the field.
        if (iIndexCounter == iIndex) sNewArray = sNewArray + sField + sSeperator;
        // Otherwise just add a blank field.
        else sNewArray = sNewArray + " " + sSeperator;
        iIndexCounter ++;
   }
   // When done return the new array.
   return sNewArray;
}

// Gets the colorId from a image of the color pallet.
// Thanks Zunath for the base code.
int GetColorPalletId (object oPlayer)
{
    float fScale = IntToFloat (GetPlayerDeviceProperty (oPlayer, PLAYER_DEVICE_PROPERTY_GUI_SCALE)) / 100.0f;
    json jPayload = NuiGetEventPayload ();
    json jMousePosition = JsonObjectGet (jPayload, "mouse_pos");
    json jX = JsonObjectGet (jMousePosition, "x");
    json jY = JsonObjectGet (jMousePosition, "y");
    float fX = StringToFloat (JsonDump (jX));
    float fY = StringToFloat (JsonDump (jY));
    float fCellSize = 16.0f * fScale;
    int nCellX = FloatToInt (fX / fCellSize);
    int nCellY = FloatToInt (fY / fCellSize);
    if (nCellX < 0) nCellX = 0;
    else if (nCellX > 16) nCellX = 16;
    if (nCellY < 0) nCellY = 0;
    else if (nCellY > 11) nCellY = 11;
    return nCellX + nCellY * 16;
}

void PopUpCraftingGUIPanel (object oPC)
{
    SetLocalInt (oPC, "0_No_Win_Save", TRUE);
    DelayCommand (0.5f, DeleteLocalInt (oPC, "0_No_Win_Save"));
    // Create the column.
    json jCol = JsonArray ();
    // Row 1 (label)************************************************************
    json jRow = JsonArray ();
    // jRow = JsonArrayInsert (jRow, CreateLabel ("", "craft_ranks", 140.0f, 10.0f));
    jRow = JsonArrayInsert (jRow, CreateLabel ("", "", BUTTON_WIDTH, 10.0f)); // empty label to take space
    json jLabel = CreateLabel ("", "craft_warning", BUTTON_WIDTH, 10.0f);
    jLabel = NuiStyleForegroundColor (jLabel, NuiColor (255, 0, 0, 255));
    jRow = JsonArrayInsert (jRow, jLabel);
    // jRow = JsonArrayInsert (jRow, CreateLabel ("", "craft_required", 140.0f, 10.0f));
    jRow = JsonArrayInsert (jRow, CreateLabel ("", "", BUTTON_WIDTH, 10.0f)); // empty label to take space
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 2 (button)***********************************************************
    // not supported right now... but would be cool
    /*
    jRow = JsonArray ();
    jRow = CreateButtonSelect (jRow, "Copy", "btn_copy", 140.0f, 35.0f);
    jRow = CreateButton (jRow, "Paste", "btn_paste", 140.0f, 35.0f);
    jRow = CreateButton (jRow, "Randomize", "btn_rand", 140.0f, 35.0f);
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    */
    // Row 3 (image)************************************************************
    jRow = JsonArray ();

    float fPaletteSpacer = ((BUTTON_WIDTH * 3.0) - PALETTE_WIDTH) / 2.0;
    // jRow = JsonArrayInsert (jRow, CreateButtonImage ("left_arrow", "btn_prev", 82.0f, 176.0f));
    jRow = JsonArrayInsert (jRow, CreateLabel ("", "", fPaletteSpacer, 10.0f));

    // jRow = CreateImage (jRow, "", "color_pallet", NUI_ASPECT_EXACTSCALED, NUI_HALIGN_CENTER, NUI_VALIGN_TOP, 256.0f, 176.0f);
    jRow = CreateImage (jRow, "gui_pal_tattoo", "color_pallet", NUI_ASPECT_EXACTSCALED, NUI_HALIGN_CENTER, NUI_VALIGN_TOP, PALETTE_WIDTH, 176.0f);

    // jRow = JsonArrayInsert (jRow, CreateButtonImage ("right_arrow", "btn_next", 82.0f, 176.0f));
    jRow = JsonArrayInsert (jRow, CreateLabel ("", "", fPaletteSpacer, 10.0f));

    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 4 (button)***********************************************************
    jRow = JsonArray ();
    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    jRow = CreateButton (jRow, "Previous", "btn_prev", BUTTON_WIDTH, 35.0f);

    // jRow = CreateButton (jRow, "Save", "btn_save", 140.0f, 35.0f);
    jRow = CreateButton (jRow, "", "btn_special", BUTTON_WIDTH, 35.0f);

    // jRow = CreateButton (jRow, "", "btn_cancel", 140.0f, 35.0f);
    jRow = CreateButton (jRow, "Next", "btn_next", BUTTON_WIDTH, 35.0f);

    jRow = JsonArrayInsert (jRow, NuiSpacer ());
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 5 (text)*************************************************************
    jRow = JsonArray ();
    jRow = JsonArrayInsert (jRow, CreateLabel ("Item", "item_title", BUTTON_WIDTH, 10.0f));
    jRow = JsonArrayInsert (jRow, CreateLabel ("Model slot", "model_title", BUTTON_WIDTH, 10.0f));
    jRow = JsonArrayInsert (jRow, CreateLabel ("Material color", "material_title", BUTTON_WIDTH, 10.0f));
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));
    // Row 6 (combo box)********************************************************
    jRow = JsonArray ();
    jRow = CreateItemCombo (oPC, jRow, "item_combo");
    jRow = CreateModelCombo (oPC, jRow, "model_combo");
    jRow = CreateMaterialCombo (oPC, jRow, "material_combo");
    // Add the row to the column.
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));


    // Row 7 (combo box)********************************************************
    jRow = JsonArray ();
    jRow = JsonArrayInsert (jRow, CreateLabel ("Metal colors cannot be customized in this menu.", "", BUTTON_WIDTH * 3.0, 10.0f));
    jCol = JsonArrayInsert (jCol, NuiRow (jRow));

    // Set the Layout for column.
    json jLayout = NuiCol (jCol);
    // Get the window location to restore it from the database.
    string sPCWindow;
    // Check if we are a DM then use our target and DB table.
    object oTarget;

    /*
    if (GetIsDM (oPC) || GetIsDMPossessed (oPC))
    {
        sPCWindow = GetServerDatabaseString (oPC, DM_TABLE, "plcraftwin");
        oTarget = GetLocalObject (oPC, "0_DM_Target");
    }
    else
    {
        sPCWindow = GetServerDatabaseString (oPC, PLAYER_TABLE, "plcraftwin");
        oTarget = oPC;
    }

    float fX = StringToFloat (GetStringArray (sPCWindow, 1));
    float fY = StringToFloat (GetStringArray (sPCWindow, 2));
    */

    float fX = 200.0;
    float fY = 300.0;
    int nToken = SetWindow (oPC, jLayout, "plcraftwin", "Crafting",
                            fX, fY, 410.0, 360.0, FALSE, FALSE, TRUE, FALSE, TRUE);
    // Set all binds, events, and watches.
    // Setup the crafting rank labels.
    //int nRanks = GetSkillRank (SKILL_CRAFTING, oPC, TRUE);
    // NuiSetBind (oPC, nToken, "craft_ranks", JsonString ("Craft ranks: " + IntToString (nRanks)));
    // nRanks = GetLocalInt (oPC, "0_RANKS_REQUIRED");
    // NuiSetBind (oPC, nToken, "craft_required", JsonString ("Ranks required: " + IntToString (nRanks)));
    // Setup the copy, paste, and random buttons.
    int nSelected = GetLocalInt (oPC, "0_COPY_ITEM");
    // NuiSetBind (oPC, nToken, "btn_copy", JsonBool (nSelected));
    // NuiSetBind (oPC, nToken, "btn_copy_event", JsonBool (TRUE));
    // NuiSetBind (oPC, nToken, "btn_paste", JsonBool (TRUE));
    // NuiSetBind (oPC, nToken, "btn_paste_event", JsonBool (nSelected));
    // NuiSetBind (oPC, nToken, "btn_rand", JsonBool (TRUE));
    // NuiSetBind (oPC, nToken, "btn_rand_event", JsonBool (TRUE));
    // Setup the Previous, Collor pallet, and Next buttons.
    NuiSetBind (oPC, nToken, "btn_prev", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_prev_event", JsonBool (TRUE));
    string sColorPallet = GetLocalString (oPC, "0_COLOR_PALLET");
    if (sColorPallet == "") sColorPallet = "cloth_pallet";
    NuiSetBind (oPC, nToken, "color_pallet_image", JsonString (sColorPallet));
    NuiSetBind (oPC, nToken, "color_pallet_event", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_next", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_next_event", JsonBool (TRUE));
    // Setup the Item selection combo.
    int nItem = GetLocalInt (oPC, "0_CRAFT_ITEM_SELECTION");
    object oItem = GetSelectedItem (oTarget, nItem);
    NuiSetBind (oPC, nToken, "item_combo_selected", JsonInt (nItem));
    NuiSetBind (oPC, nToken, "item_combo_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "item_combo_selected", TRUE);
    // Setup the model selection combo.
    nSelected = GetLocalInt (oPC, "0_CRAFT_MODEL_SELECTION");
    NuiSetBind (oPC, nToken, "model_combo_selected", JsonInt (nSelected));
    NuiSetBind (oPC, nToken, "model_combo_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "model_combo_selected", TRUE);
    // Setup the material selection combo.
    nSelected = GetLocalInt (oPC, "0_CRAFT_MATERIAL_SELECTION");
    NuiSetBind (oPC, nToken, "material_combo_selected", JsonInt (nSelected));
    NuiSetBind (oPC, nToken, "material_combo_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "material_combo_selected", TRUE);
    // Setup the save button.
    NuiSetBind (oPC, nToken, "btn_save", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_save_event", JsonBool (FALSE));
    // Setup the special button.
    nSelected = GetLocalInt (oPC, "0_MODEL_SPECIAL");
    NuiSetBind (oPC, nToken, "btn_special", JsonBool (TRUE));
    NuiSetBind (oPC, nToken, "btn_special_event", JsonBool (TRUE));
    if (nItem == 3 || nItem == 4)
    {
        NuiSetBind (oPC, nToken, "btn_special_label", JsonString ("****"));
        NuiSetBind (oPC, nToken, "btn_special", JsonBool (FALSE));
        NuiSetBind (oPC, nToken, "btn_special_event", JsonBool (FALSE));
    }
    else if (nSelected == 0) NuiSetBind (oPC, nToken, "btn_special_label", JsonString ("Left/Right Linked"));
    else if (nSelected == 1) NuiSetBind (oPC, nToken, "btn_special_label", JsonString ("Left Model"));
    else if (nSelected == 2) NuiSetBind (oPC, nToken, "btn_special_label", JsonString ("Right Model"));
    else
    {
        nSelected = GetHiddenWhenEquipped (oItem);
        if (nSelected)
        {
            NuiSetBind (oPC, nToken, "btn_special_label", JsonString ("Model Hidden"));
            SetLocalInt (oPC, "0_MODEL_SPECIAL", 4);
        }
        else
        {
            NuiSetBind (oPC, nToken, "btn_special_label", JsonString ("Model Visible"));
            SetLocalInt (oPC, "0_MODEL_SPECIAL", 3);
        }
    }
    // Setup the Cancel/Exit button.
    // NuiSetBind (oPC, nToken, "btn_cancel_label", JsonString ("Exit"));
    // NuiSetBind (oPC, nToken, "btn_cancel", JsonBool (TRUE));
    // NuiSetBind (oPC, nToken, "btn_cancel_event", JsonBool (TRUE));
    NuiSetBindWatch (oPC, nToken, "window_geometry", TRUE);
}

/*******************************************************************************
*  Helper functions for the layouts.                                           *
*******************************************************************************/

json CreateItemCombo (object oPC, json jRow, string sComboBind)
{
    int nCnt;
    json jCombo = JsonArray ();
    // Create the list.
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Armor", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Cloak", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Helmet", 2));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Right hand", 3));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Left hand", 4));
    jCombo = NuiId (NuiCombo (jCombo, NuiBind (sComboBind + "_selected")), sComboBind);
    jCombo = NuiEnabled  (jCombo, NuiBind (sComboBind + "_event"));
    return JsonArrayInsert (jRow, NuiWidth (jCombo, BUTTON_WIDTH));
}

json CreateModelCombo (object oPC, json jRow, string sComboBind)
{
    float fFacing = GetFacing (oPC);
    json jCombo = JsonArray ();
    int nSelected = GetLocalInt (oPC, "0_CRAFT_ITEM_SELECTION");
    // Create the list.
    // Armor.
    if (nSelected == 0)
    {
        fFacing += 180.0f;
        if (fFacing > 359.0) fFacing -=359.0;
        AssignCommand (oPC, SetCameraFacing (fFacing, 4.5f, 75.0, CAMERA_TRANSITION_TYPE_VERY_FAST));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Neck", 0));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Shoulder", 1));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Bicep", 2));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Forearm", 3));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Hand", 4));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Torso", 5));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Belt", 6));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Pelvis", 7));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Thigh", 8));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Shin", 9));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Foot", 10));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Robe", 11));
    }
    // Cloak.
    else if (nSelected == 1)
    {
        if (fFacing > 359.0) fFacing -=359.0;
        AssignCommand (oPC, SetCameraFacing (fFacing, 4.5f, 75.0, CAMERA_TRANSITION_TYPE_VERY_FAST));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Cloak", 0));
    }
    // Headgear.
    else if (nSelected == 2)
    {
        fFacing += 180.0f;
        if (fFacing > 359.0) fFacing -=359.0;
        AssignCommand (oPC, SetCameraFacing (fFacing, 2.5f, 75.0, CAMERA_TRANSITION_TYPE_VERY_FAST));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Helmet", 0));
    }
    // Weapon.
    else if (nSelected == 3)
    {
        // If they are changing a bow then face the opposite side.
        object oItem = GetItemInSlot (INVENTORY_SLOT_RIGHTHAND, oPC);
        int nBaseItemType = GetBaseItemType (oItem);
        if (nBaseItemType == BASE_ITEM_LONGBOW || nBaseItemType == BASE_ITEM_SHORTBOW) fFacing -= 90.00;
        // This will make the camera face a melee weapon.
        else fFacing += 90.0;
        if (fFacing > 359.0) fFacing -=359.0;
        AssignCommand (oPC, SetCameraFacing (fFacing, 3.5f, 75.0, CAMERA_TRANSITION_TYPE_VERY_FAST));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Bottom", 0));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Middle", 1));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Top", 2));
    }
    // Weapon/Shield.
    else if (nSelected == 4)
    {
        fFacing += 270.0f;
        if (fFacing > 359.0) fFacing -=359.0;
        AssignCommand (oPC, SetCameraFacing (fFacing, 3.5f, 75.0, CAMERA_TRANSITION_TYPE_VERY_FAST));
        object oItem = GetItemInSlot (INVENTORY_SLOT_LEFTHAND, oPC);
        if (GetIsWeapon (oItem))
        {
            jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Top", 0));
            jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Middle", 1));
            jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Bottom", 2));
        }
        else
        {
            jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Shield", 0));
        }
    }
    jCombo = NuiId (NuiCombo (jCombo, NuiBind (sComboBind + "_selected")), sComboBind);
    jCombo = NuiEnabled  (jCombo, NuiBind (sComboBind + "_event"));
    return JsonArrayInsert (jRow, NuiWidth (jCombo, BUTTON_WIDTH));
}

json CreateMaterialCombo (object oPC, json jRow, string sComboBind)
{
    int nCnt;
    json jCombo = JsonArray ();
    int nSelected = GetLocalInt (oPC, "0_CRAFT_ITEM_SELECTION");
    // Create the list.
    // Armor, Cloak, Headgear.
    if (nSelected == 0 || nSelected == 1 || nSelected == 2)
    {
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Cloth 1", 0));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Cloth 2", 1));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Leather 1", 2));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Leather 2", 3));
        // this tga isn't included, so customizing metal colors aren't really accurate. have to omit :(
        // jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Metal 1", 4));
        // jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Metal 2", 5));
    }
    else
    {
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("None", 0));
    }
    jCombo = NuiId (NuiCombo (jCombo, NuiBind (sComboBind + "_selected")), sComboBind);
    jCombo = NuiEnabled  (jCombo, NuiBind (sComboBind + "_event"));
    return JsonArrayInsert (jRow, NuiWidth (jCombo, BUTTON_WIDTH));
}



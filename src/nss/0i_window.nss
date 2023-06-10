/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_window
////////////////////////////////////////////////////////////////////////////////
 Include script for handling window displays.
*///////////////////////////////////////////////////////////////////////////////
// Programmer: Philos
////////////////////////////////////////////////////////////////////////////////
#include "0i_main"
#include "0i_database"
#include "nw_inc_nui"

// ********** Player menu constants *********
const string PM_NAME = "Player Menu";
const int PM_RESIZE = FALSE;
const int PM_COLLAPSE = TRUE;
const int PM_CLOSE = FALSE;
const int PM_TRANSPARENT = FALSE;
const int PM_BORDER = TRUE;
const float PM_WIN_HORIZONTAL_HEIGHT = 130.0f;
const float PM_WIN_HORIZONTAL_WIDTH = 355.0f;
// const float PM_WIN_VERTICAL_HEIGHT = 178.0f;
// const float PM_WIN_VERTICAL_WIDTH = 228.0f;

// TRUE turns the buttons on, FALSE turns the buttons off.
const int PM_INFO = TRUE;
const int PM_BUG_REPORT = TRUE;
const int PM_DESCRIPTION = TRUE;
const int PM_DICE = TRUE;
const int PM_OPTIONS = TRUE;
const int PM_PC_SUMMARY = TRUE;

// Return the middle of the screen for the x position.
// oPC using the menu.
// fMenuWidth - the width of the menu to display.
float GetGUIWidthMiddle (object oPC, float fMenuWidth);

// Return the middle of the screen for the y position.
// oPC using the menu.
// fMenuHeight - the height of the menu to display.
float GetGUIHeightMiddle (object oPC, float fMenuHeight);

// oPC is the PC using the menu.
// jLayout is the Layout of the menu.
// sWinID is the string ID for this window.
// slabel is the label of the menu.
// fX is the X position of the menu. if (-1.0) then it will center the x postion
// fY is the Y position of the menu. if (-1.0) then it will center the y postion
// fWidth is the width of the menu.
// fHeight is the height of the menu.
// bResize - TRUE will all it to be resized.
// bCollapse - TRUE will allow the window to be collapsable.
// bClose - TRUE will allow the window to be closed.
// bTransparent - TRUE makes the menu transparent.
// bBorder - TRUE makes the menu have a border.
int SetWindow (object oPC, json jLayout, string sWinID, string slabel, float fX, float fY, float fWidth, float fHeight, int bResize, int bCollapse, int bClose, int bTransparent, int bBorder);

// Creates a basic label.
// jRow is the row the label goes into.
// sBind is the bind variable so we can change the text.
// fWidth is the width of the label.
// fHeight is the Height of the label.
json CreateLabel (json jRow, string sBind, float fWidth, float fHeight);

// Creates a basic Button.
// jRow is the row the button goes into.
// sLabel is the text that will go into the button.
// If sLabel is "" then it will be binded using sId + "_label".
// sId is the Id to bind the button with as well as setup the event.
// fWidth is the width of the button.
// fHeight is the Height of the button.
json CreateButton (json jRow, string sLabel, string sId, float fWidth, float fHeight);

// Creates a basic button when clicked highlights until clicked again.
// jRow is the row the label goes into.
// sLabel is the text placed in the button. If "" is passed then it will
// create a bind of sId + "_label".
// sId is the binds for the button and the event uses sId + "_event".
// fWidth is the width of the label.
// fHeight is the Height of the button.
json CreateButtonSelect (json jRow, string sLabel, string sId, float fWidth, float fHeight);

// Creates a basic button with an image instead of text.
// jRow is the row the label goes into.
// sResRef is the image to be placed on the button. If "" is passed then it will
// create a bind of sId + "_image".
// sId is the binds for the button and the event uses sId + "_event".
// fWidth is the width of the label.
// fHeight is the Height of the button.
json CreateButtonImage (json jRow, string sResRef, string sId, float fWidth, float fHeight);

// Create a basic text edit box.
// jRow is the row the TextEdit box goes into.
// sPlaceHolderBind is the bind for Placeholder.
// sValueBind is the bind variable so we can change the text.
// nMaxLength is the maximum lenght of the text (1 - 65535)
// bMultiline - True or False that is has multiple lines.
// fWidth the width of the box.
// fHeight the height of the box.
json CreateTextEditBox (json jRow, string sPlaceHolderBind, string sValueBind, int nMaxLength, int bMultiline, float fWidth, float fHeight, string sToolTipBind = "tool_tip");

// Create a combobox with the entries setup before we call this function.
// jRow is the row to add the combo box to.
// jCombo is the json entries setup before we call this function.
// sId is the binds for the combo box,
//      selected is sId + "_selected and event is sId + "_event".
// fWidth the width of the box.
// fHeight the height of the box.
json CreateComboBox (json jRow, json jCombo, string sId, float fWidth, float fHeight);

string GetRollText (object oPlayer);

json CreateNumOfDiceCombo (object oPC, json jRow, string sComboBind);

json CreateRollTypeCombo (object oPC, json jRow, string sComboBind);

json CreateDieBonusCombo (object oPC, json jRow, string sComboBind);

json CreateBroadcastCombo (object oPC, json jRow, string sComboBind);

// Checks the dicerolltext to see if we are doing a special check.
// Returns "" if not.
string CheckDiceRollText (object oRoller, string sInput);

void SendDiceMessage (object oPC, string sRoll);

// return the middle of the screen for the x position.
// oPC using the menu.
// fMenuWidth - the width of the menu to display.
float GetGUIWidthMiddle (object oPC, float fMenuWidth)
{
    // Get players window information.
    float fGUI_Width = IntToFloat (GetPlayerDeviceProperty (oPC, PLAYER_DEVICE_PROPERTY_GUI_WIDTH));
    float fGUI_Scale = IntToFloat (GetPlayerDeviceProperty (oPC, PLAYER_DEVICE_PROPERTY_GUI_SCALE)) / 100.0;
    fMenuWidth = fMenuWidth * fGUI_Scale;
    return (fGUI_Width / 2.0) - (fMenuWidth / 2.0);
}

// return the middle of the screen for the y position.
// oPC using the menu.
// fMenuHeight - the height of the menu to display.
float GetGUIHeightMiddle (object oPC, float fMenuHeight)
{
    // Get players window information.
    float fGUI_Height = IntToFloat (GetPlayerDeviceProperty (oPC, PLAYER_DEVICE_PROPERTY_GUI_HEIGHT));
    float fGUI_Scale = IntToFloat (GetPlayerDeviceProperty (oPC, PLAYER_DEVICE_PROPERTY_GUI_SCALE)) / 100.0;
    fMenuHeight = fMenuHeight * fGUI_Scale;
    return (fGUI_Height / 2.0) - (fMenuHeight / 2.0);
}

// oPC is the PC using the menu.
// jLayout is the Layout of the menu.
// sWinID is the string ID for this window.
// slabel is the label of the menu.
// fX is the X position of the menu. if (-1.0) then it will center the x postion
// fY is the Y position of the menu. if (-1.0) then it will center the y postion
// fWidth is the width of the menu.
// fHeight is the height of the menu.
// bResize - TRUE will all it to be resized.
// bCollapse - TRUE will allow the window to be collapsable.
// bClose - TRUE will allow the window to be closed.
// bTransparent - TRUE makes the menu transparent.
// bBorder - TRUE makes the menu have a border.
// To remove the Title bar set sLabel to "FALSE" and bCollapse, bClose to FALSE.
int SetWindow (object oPC, json jLayout, string sWinID, string sLabel, float fX, float fY, float fWidth, float fHeight, int bResize, int bCollapse, int bClose, int bTransparent, int bBorder)
{
    // Create the window binding everything.
    json jWindow;
    if (sLabel == "FALSE")
    {
        jWindow = NuiWindow (jLayout, JsonBool (FALSE), NuiBind ("window_geometry"),
        NuiBind ("window_resizable"), JsonBool (FALSE), JsonBool (FALSE),
        NuiBind ("window_transparent"), NuiBind ("window_border"));
    }
    else
    {
        jWindow = NuiWindow (jLayout, NuiBind ("window_label"), NuiBind ("window_geometry"),
        NuiBind ("window_resizable"), JsonBool (bCollapse), NuiBind ("window_closable"),
        NuiBind ("window_transparent"), NuiBind ("window_border"));
    }
    // Create the window.
    int nToken = NuiCreate (oPC, jWindow, sWinID);
    if (fX == -1.0) fX = GetGUIWidthMiddle (oPC, fWidth);
    if (fY == -1.0) fY = GetGUIHeightMiddle (oPC, fHeight);
    NuiSetBind (oPC, nToken, "window_geometry", NuiRect (fX,
                fY, fWidth, fHeight));
    // Set the binds for the new window.
    // Set the window options.
    if (sLabel != "FALSE")
    {
        NuiSetBind (oPC, nToken, "window_label", JsonString (sLabel));
        NuiSetBind (oPC, nToken, "window_closable", JsonBool (bClose));
    }
    NuiSetBind (oPC, nToken, "window_resizable", JsonBool (bResize));
    NuiSetBind (oPC, nToken, "window_transparent", JsonBool (bTransparent));
    NuiSetBind (oPC, nToken, "window_border", JsonBool (bBorder));
    return nToken;
}

// Creates a basic label.
// jRow is the row the label goes into.
// sBind is the bind variable so we can change the text.
// fWidth is the width of the label.
// fHeight is the Height of the label.
json CreateLabel (json jRow, string sBind, float fWidth, float fHeight)
{
    json jLabel = NuiLabel (NuiBind (sBind), JsonNull (), JsonNull ());
    jLabel = NuiWidth (jLabel, fWidth);
    jLabel = NuiHeight (jLabel, fHeight);
    return JsonArrayInsert (jRow, JsonObjectSet (jLabel, "text_color", NuiColor (255, 0, 0)));
}

// Creates a basic Button.
// jRow is the row the button goes into.
// sLabel is the text that will go into the button.
// If sLabel is "" then it will be binded using sId + "_label".
// sId is the Id to bind the button with as well as setup the event.
// fWidth is the width of the button.
// fHeight is the Height of the button.
json CreateButton (json jRow, string sLabel, string sId, float fWidth, float fHeight)
{
    json jButton;
    if (sLabel == "") jButton = NuiEnabled (NuiId (NuiButton (NuiBind (sId + "_label")), sId), NuiBind (sId + "_event"));
    else jButton = NuiEnabled (NuiId (NuiButton (JsonString (sLabel)), sId), NuiBind (sId + "_event"));
    jButton = NuiWidth (jButton, fWidth);
    jButton = NuiHeight (jButton, fHeight);
    return JsonArrayInsert (jRow, jButton);
}


// Creates a basic button when clicked highlights until clicked again.
// jRow is the row the label goes into.
// sLabel is the text placed in the button. If "" is passed then it will
// create a bind of sId + "_label".
// sId is the binds for the button and the event uses sId + "_event".
// fWidth is the width of the label.
// fHeight is the Height of the button.
json CreateButtonSelect (json jRow, string sLabel, string sId, float fWidth, float fHeight)
{
    json jButton;
    if (sLabel == "") jButton = NuiEnabled (NuiId (NuiButtonSelect (NuiBind (sId + "_label"), NuiBind (sId)), sId), NuiBind (sId + "_event"));
    else jButton = NuiEnabled (NuiId (NuiButtonSelect (JsonString (sLabel), NuiBind (sId)), sId), NuiBind (sId + "_event"));
    jButton = NuiWidth (jButton, fWidth);
    jButton = NuiHeight (jButton, fHeight);
    return JsonArrayInsert (jRow, jButton);
}

// Creates a basic button with an image instead of text.
// jRow is the row the label goes into.
// sResRef is the image to be placed on the button. If "" is passed then it will
// create a bind of sId + "_image".
// sId is the binds for the button and the event uses sId + "_event".
// fWidth is the width of the label.
// fHeight is the Height of the button.
json CreateButtonImage (json jRow, string sResRef, string sId, float fWidth, float fHeight)
{
    json jButton;
    if (sResRef == "") jButton = NuiEnabled (NuiId (NuiButtonImage (NuiBind (sId + "_image")), sId), NuiBind (sId + "_event"));
    else jButton = NuiEnabled (NuiId (NuiButtonImage (JsonString (sResRef)), sId), NuiBind (sId + "_event"));
    jButton = NuiWidth (jButton, fWidth);
    jButton = NuiHeight (jButton, fHeight);
    return JsonArrayInsert (jRow, jButton);
}

// Create a basic text box that cannot be edited.
// jRow is the row the Text box goes into.
// sId is the binds for the text box so we can change the text.
// fWidth the width of the box.
// fHeight the height of the box.
json CreateTextBox (json jRow, string sId, float fWidth, float fHeight)
{
    json jTextBox = NuiText (NuiBind (sId), FALSE, NUI_SCROLLBARS_NONE);
    jTextBox = NuiWidth (jTextBox, fWidth);
    jTextBox = NuiHeight (jTextBox, fHeight);
    return JsonArrayInsert (jRow, JsonObjectSet (jTextBox, "text_color", NuiColor (255, 0, 0)));
}

// Create a basic text edit box.
// jRow is the row the TextEdit box goes into.
// sPlaceHolderBind is the bind for Placeholder.
// sValueBind is the bind variable so we can change the text.
// nMaxLength is the maximum lenght of the text (1 - 65535)
// bMultiline - True or False that is has multiple lines.
// fWidth the width of the box.
// fHeight the height of the box.
json CreateTextEditBox (json jRow, string sPlaceHolderBind, string sValueBind, int nMaxLength, int bMultiline, float fWidth, float fHeight, string sToolTipBind = "tool_tip")
{
    json jTextEditBox = NuiTextEdit (NuiBind (sPlaceHolderBind), NuiBind (sValueBind), nMaxLength, bMultiline);
    jTextEditBox = NuiWidth (jTextEditBox, fWidth);
    jTextEditBox = NuiHeight (jTextEditBox, fHeight);
    jTextEditBox = NuiTooltip (jTextEditBox, NuiBind (sToolTipBind));
    return JsonArrayInsert (jRow, jTextEditBox);
}

json CreateCheckBox (json jRow, string sLabelBind, string sBoolBind, float fWidth, float fHeight);
json CreateCheckBox (json jRow, string sLabelBind, string sBoolBind, float fWidth, float fHeight)
{
    json jCheckBox = NuiCheck (NuiBind (sLabelBind), NuiBind (sBoolBind));
    jCheckBox = NuiWidth (jCheckBox, fWidth);
    jCheckBox = NuiHeight (jCheckBox, fHeight);
    return JsonArrayInsert (jRow, jCheckBox);
}

// Create a combobox with the entries setup before we call this function.
// jRow is the row to add the combo box to.
// jCombo is the json entries setup before we call this function.
// sId is the binds for the combo box,
//      selected is sId + "_selected and event is sId + "_event".
// fWidth the width of the box.
// fHeight the height of the box.
json CreateComboBox (json jRow, json jCombo, string sId, float fWidth, float fHeight)
{
    // We bind sID + "_selected" so we can get the selected entry in the combo box.
    jCombo = NuiId (NuiCombo (jCombo, NuiBind (sId + "_selected")), sId);
    // Enable the combo box so the player can use it.
    jCombo = NuiEnabled  (jCombo, NuiBind (sId + "_event"));
    jCombo = NuiWidth (jCombo, 200.0);
    jCombo = NuiHeight (jCombo, 30.0);
    // Insert the combo box into the row.
    return JsonArrayInsert (jRow, jCombo);
}

string GetRollText (object oPlayer)
{
    int nNum = GetLocalInt (oPlayer, "0_NumDice") + 1;
    int nType = GetLocalInt (oPlayer, "0_TypeRoll");
    int nBonus = GetLocalInt (oPlayer, "0_DieBonus");
    string sNum, sDie, sBonus;
    if (nType < 7)
    {
        sNum = IntToString (nNum);
        if (nType == 0) sDie = "d4";
        if (nType == 1) sDie = "d6";
        if (nType == 2) sDie = "d8";
        if (nType == 3) sDie = "d10";
        if (nType == 4) sDie = "d12";
        if (nType == 5) sDie = "d20";
        if (nType == 6) sDie = "d100";
        if (nBonus == 0) sBonus = "";
        else if (nBonus > 0) sBonus = "+" + IntToString (nBonus);
        else sBonus = "-" + IntToString (abs (nBonus));
        return sNum + sDie + sBonus;
    }
    else if (nType == 7) return "Fortitude Save";
    else if (nType == 8) return "Reflex Save";
    else if (nType == 9) return "Will Save";
    else if (nType == 10) return "Base Attack Roll";
    else if (nType == 11)return "Strength Check";
    else if (nType == 12) return "Dexterity Check";
    else if (nType == 13) return "Constitution Check";
    else if (nType == 14) return "Intelligence Check";
    else if (nType == 15) return "Wisdom Check";
    else if (nType == 16) return "Charisma Check";
    else return GetStringByStrRef (StringToInt (Get2DAString ("skills", "Name", nType - 17))) + " Check";
    return "";
}

json CreateNumOfDiceCombo (object oPC, json jRow, string sComboBind)
{
    json jCombo = JsonArray ();
    int i;
    for (i = 0;i < 20; i ++)
    {
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry (IntToString (i + 1), i));
    }
    jCombo = NuiId (NuiCombo (jCombo, NuiBind (sComboBind + "_selected")), sComboBind);
    jCombo = NuiEnabled  (jCombo, NuiBind (sComboBind + "_event"));
    return JsonArrayInsert (jRow, NuiWidth (jCombo, 75.0));
}

json CreateRollTypeCombo (object oPC, json jRow, string sComboBind)
{
    string sName, sRank;
    int i;
    int bCharacter = GetIsCharacter (oPC);
    json jCombo = JsonArray ();
    // Create the list.
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("d4", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("d6", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("d8", 2));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("d10", 3));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("d12", 4));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("d20", 5));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("d100", 6));
    if (bCharacter) sRank = "(" + IntToString (GetFortitudeSavingThrow (oPC)) + ") ";
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sRank + "Fortitude", 7));
    if (bCharacter) sRank = "(" + IntToString (GetReflexSavingThrow (oPC)) + ") ";
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sRank + "Reflex", 8));
    if (bCharacter) sRank = "(" + IntToString (GetWillSavingThrow (oPC)) + ") ";
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sRank + "Will", 9));
    if (bCharacter) sRank = "(" + IntToString (GetBaseAttackBonus (oPC)) + ") ";
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sRank + "Base Attack", 10));
    if (bCharacter) sRank = "(" + IntToString (GetAbilityModifier (ABILITY_STRENGTH, oPC)) + ") ";
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sRank + "Strength", 11));
    if (bCharacter) sRank = "(" + IntToString (GetAbilityModifier (ABILITY_DEXTERITY, oPC)) + ") ";
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sRank + "Dexterity", 12));
    if (bCharacter) sRank = "(" + IntToString (GetAbilityModifier (ABILITY_CONSTITUTION, oPC)) + ") ";
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sRank + "Constitution", 13));
    if (bCharacter) sRank = "(" + IntToString (GetAbilityModifier (ABILITY_INTELLIGENCE, oPC)) + ") ";
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sRank + "Intelligence", 14));
    if (bCharacter) sRank = "(" + IntToString (GetAbilityModifier (ABILITY_WISDOM, oPC)) + ") ";
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sRank + "Wisdom", 15));
    if (bCharacter) sRank = "(" + IntToString (GetAbilityModifier (ABILITY_CHARISMA, oPC)) + ") ";
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sRank + "Charisma", 16));
    for (i = 0; i < 28; i ++)
    {
        if (bCharacter) sRank = "(" + IntToString (GetSkillRank (i, oPC)) + ") ";
        sName = GetStringByStrRef (StringToInt (Get2DAString ("skills", "Name", i)));
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry (sRank + sName, i + 17));
    }
    jCombo = NuiId (NuiCombo (jCombo, NuiBind (sComboBind + "_selected")), sComboBind);
    jCombo = NuiEnabled  (jCombo, NuiBind (sComboBind + "_event"));
    return JsonArrayInsert (jRow, NuiWidth (jCombo, 200.0));
}

json CreateDieBonusCombo (object oPC, json jRow, string sComboBind)
{
    json jCombo = JsonArray ();
    int i;
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("0", 0));
    for (i = 1;i < 21; i ++)
    {
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("+" + IntToString (i), i));
    }
    for (i = 1;i < 21; i ++)
    {
        jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("-" + IntToString (i), i + 20));
    }
    jCombo = NuiId (NuiCombo (jCombo, NuiBind (sComboBind + "_selected")), sComboBind);
    jCombo = NuiEnabled  (jCombo, NuiBind (sComboBind + "_event"));
    return JsonArrayInsert (jRow, NuiWidth (jCombo, 75.0));
}

json CreateBroadcastCombo (object oPC, json jRow, string sComboBind)
{
    string sName, sRank;
    int i;
    json jCombo = JsonArray ();
    // Create the list.
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Local", 0));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Party", 1));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Global", 2));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("Target", 3));
    jCombo = JsonArrayInsert (jCombo, NuiComboEntry ("DM", 4));
    jCombo = NuiId (NuiCombo (jCombo, NuiBind (sComboBind + "_selected")), sComboBind);
    jCombo = NuiEnabled  (jCombo, NuiBind (sComboBind + "_event"));
    return JsonArrayInsert (jRow, NuiWidth (jCombo, 100.0));
}

// Checks the dicerolltext to see if we are doing a special check.
// Returns "" if not.
string CheckDiceRollText (object oRoller, string sInput)
{
    int nRoll, nRank, nResult, nDMDC, bArmorPenalty, nArmorPenalty;
    int nAbility = -1;
    int nSave = -1;
    int nSkill = -1;
    int nAttack = -1;
    string sString, sCheckName;
    int iDieAdjustment = GetLocalInt (oRoller, "0_DieBonus");
    sInput = GetStringLowerCase (sInput);
    if (sInput == "strength check")
    {
        nAbility = ABILITY_STRENGTH;
        sCheckName = "a Strength check";
    }
    else if (sInput == "dexterity check")
    {
        nAbility = ABILITY_DEXTERITY;
        sCheckName = "a Dexterity check";
    }
    else if (sInput == "constitution check")
    {
        nAbility = ABILITY_CONSTITUTION;
        sCheckName = "a Constitution check";
    }
    else if (sInput == "intelligence check")
    {
        nAbility = ABILITY_INTELLIGENCE;
        sCheckName = "an Intelligence check";
    }
    else if (sInput == "wisdom check")
    {
        nAbility = ABILITY_WISDOM;
        sCheckName = "a Wisdom check";
    }
    else if (sInput == "charisma check")
    {
        nAbility = ABILITY_CHARISMA;
        sCheckName = "a Charisma check";
    }
    // Base Attack Roll.
    else if (sInput == "base attack roll")
    {
        nAttack = 1;
        sCheckName = "a base attack roll";
    }
    // Saves.
    else if (sInput == "fortitude save")
    {
        nSave = SAVING_THROW_FORT;
        sCheckName = "a Fortitude save";
    }
    else if (sInput == "reflex save")
    {
        nSave = SAVING_THROW_REFLEX;
        sCheckName = "a Reflex save";
    }
    else if (sInput == "will save")
    {
        nSave = SAVING_THROW_WILL;
        sCheckName = "a Will save";
    }
    // Check skills from the skills.2da
    int i = 0;
    string sSkillName = GetStringByStrRef (StringToInt (Get2DAString ("skills", "Name", i)));
    sSkillName = GetStringLowerCase (sSkillName);
    while (i < 28)
    {
        PrintString ("sSkillName: " + sSkillName);
        if (sInput == sSkillName + " check")
        {
            nSkill = i;
            bArmorPenalty = StringToInt (Get2DAString ("skills", "ArmorCheckPenalty", i));
            if (GetStringLeft (sSkillName, 1) == "a") sCheckName = "an " + sSkillName + " check";
            else sCheckName = "a " + sSkillName + " check";
            break;
        }
        sSkillName = GetStringByStrRef (StringToInt (Get2DAString ("skills", "Name", ++i)));
        sSkillName = GetStringLowerCase (sSkillName);
    }
    // Check for target.
    object oTarget = GetLocalObject (oRoller, "0_Dice_Target");
    if (oTarget != OBJECT_INVALID) oRoller = oTarget;
    // Return results for an Ability check.
    if (nAbility > -1)
    {
        nRoll = d20();
        nRank = GetAbilityModifier (nAbility, oRoller);
        nResult = nRoll + nRank + iDieAdjustment;
    }
    // Return results for a Save.
    else if (nSave > -1)
    {
        nRoll = d20();
        if (nSave == SAVING_THROW_FORT) nRank = GetFortitudeSavingThrow (oRoller);
        else if (nSave == SAVING_THROW_REFLEX) nRank = GetReflexSavingThrow (oRoller);
        else if (nSave == SAVING_THROW_WILL) nRank = GetWillSavingThrow (oRoller);
        nResult = nRoll + nRank + iDieAdjustment;
    }
    // Return results for a Skill check.
    else if (nSkill > -1)
    {
        nRoll = d20();
        nRank = GetSkillRank (nSkill, oRoller);
        if (bArmorPenalty)
        {
            object oArmor = GetItemInSlot (INVENTORY_SLOT_CHEST, oRoller);
            int nAC = GetItemACValue (oArmor);
            nArmorPenalty = StringToInt (Get2DAString ("armor", "ACCHECK", nAC));
        }
        else nArmorPenalty = 0;
        nResult = nRoll + nRank + nArmorPenalty + iDieAdjustment;
    }
    // Attack rolls.
    if (nAttack > -1)
    {
        nRoll = d20();
        nRank = GetBaseAttackBonus (oRoller);
        nResult = nRoll + nRank + iDieAdjustment;
    }
    // Setup string for Abilities, Saves, and Skills.
    if (nDMDC == 0 && nRoll > 0)
    {
        sString = GetName (oRoller) + " rolls " + sCheckName + " of " + IntToString (nRoll);
        if (nRank > -1) sString +=  " + " + IntToString (nRank);
        else sString += " - " + IntToString (abs (nRank));
        if (nArmorPenalty != 0) sString += " - " + IntToString (abs (nArmorPenalty));
        if (iDieAdjustment != 0)
        {
            if (iDieAdjustment > 0) sString += " + " + IntToString (iDieAdjustment);
            else sString += " - " + IntToString (abs (iDieAdjustment));
        }
        sString +=  " = " + IntToString (nResult);
    }
    return sString;
}

void SendDiceMessage (object oPC, string sRoll)
{
    // Send text to players
    int iBroadcast = GetLocalInt (oPC, "0_Broadcast");
    // Send the string based on the broadcast selection.
    // DM Private
    if (iBroadcast == 0)
    {
        SendMessageToPC (oPC, sRoll);
        SendMessageToAllDMs (sRoll);
    }
    // Local
    else if (iBroadcast == 1)
    {
        // Send the message to all within talking distance (30 meters).
        float fDistance;
        int i = 1;
        object oPlayer = GetFirstPC ();
        while (oPlayer != OBJECT_INVALID)
        {
            if (oPlayer != oPC) fDistance = GetDistanceBetween (oPlayer, oPC);
            else fDistance = 1.0f;
            if (fDistance != 0.0f && fDistance < 31.0f) SendMessageToPC (oPlayer, sRoll);
            oPlayer = GetNextPC ();
        }
    }
    // Party
    else if (iBroadcast == 2)
    {
        // Send the message to all PC's.
        object oPlayer = GetFirstFactionMember (oPC);
        while (oPlayer != OBJECT_INVALID)
        {
            SendMessageToPC (oPlayer, sRoll);
            oPlayer = GetNextFactionMember (oPC);
        }
    }
    // Global
    else if (iBroadcast == 3)
    {
        // Send the message to all PC's.
        object oPlayer = GetFirstPC ();
        while (GetIsObjectValid (oPlayer))
        {
            SendMessageToPC (oPlayer, sRoll);
            oPlayer = GetNextPC ();
        }
    }
}

/*//////////////////////////////////////////////////////////////////////////////
// Script Name: 0i_window
////////////////////////////////////////////////////////////////////////////////
 Include script for handling window displays.

 Layout pixel sizes:
 Pixel width Title bar 33.
 Pixel height Top border 12, between widgets 8, bottom border 12.
 Pixel width Left border 12, between widgets 4, right border 12.
*///////////////////////////////////////////////////////////////////////////////
#include "nw_inc_nui"

struct stComboBox
{
    json jIndex;
    json jCombo;
    json jRow;
    json jResRefArray;
    json jWinArray;
};

// return the middle of the screen for the x position.
// oPC using the menu.
// fMenuWidth - the width of the menu to display.
float GetGUIWidthMiddle (object oPC, float fMenuWidth);

// return the middle of the screen for the y position.
// oPC using the menu.
// fMenuHeight - the height of the menu to display.
float GetGUIHeightMiddle (object oPC, float fMenuHeight);

// oPC is the PC using the menu.
// jLayout is the Layout of the menu.
// sWinID is the string ID for this window.
// sTitle is the Title of the menu.
// fX is the X position of the menu. if (-1.0) then it will center the x postion
// fY is the Y position of the menu. if (-1.0) then it will center the y postion
// fWidth is the width of the menu.
// fHeight is the height of the menu.
// bResize - TRUE will all it to be resized.
// bCollapse - TRUE will allow the window to be collapsable.
// bClose - TRUE will allow the window to be closed.
// bTransparent - TRUE makes the menu transparent.
// bBorder - TRUE makes the menu have a border.
int SetWindow (object oPC, json jLayout, string sWinID, string sTitle, float fX, float fY, float fWidth, float fHeight, int bResize, int bCollapse, int bClose, int bTransparent, int bBorder);

// Creates a label element.
// sLabel is the text placed in the label.
//     If "" is passed then it will create a bind of sId + "_label".
// sId is the bind for the variable and the event uses sId + "_event".
// fWidth is the width of the label.
// fHeight is the Height of the label.
// nHAlign is horizonal align [NUI_HALING_*].
// nVAlign is vertial align [NUI_VALING_*].
json CreateLabel (string sLabel, string sId, float fWidth, float fHeight, int nHAlign = 0, int nVAlign = 0);

// Creates a basic button.
// jRow is the row the label goes into.
// sLabel is the text placed in the button. If "" is passed then it will
// create a bind of sId + "_label".
// sId is the binds for the button and the event uses sId + "_event".
// fWidth is the width of the label.
json CreateButton (json jRow, string sLabel, string sId, float fWidth, float fHeight);

// Creates a basic button select.
// jRow is the row the label goes into.
// sLabel is the text placed in the button. If "" is passed then it will
// create a bind of sId + "_label".
// sId is the binds for the button and the event uses sId + "_event".
// fWidth is the width of the label.
json CreateButtonSelect (json jRow, string sLabel, string sId, float fWidth, float fHeight);

// Creates a button element with an image instead of text.
// sImage is the resref of the image to use.
//     If "" is passed then it will create a bind of sId + "_image".
// sId is the binds for the button and the event uses sId + "_event".
// fWidth is the width of the label.
// fHeight is the Height of the label.
json CreateButtonImage (string sResRef, string sId, float fWidth, float fHeight);

// Create a basic text box that is not editable.
// jRow is the row the TextEdit box goes into.
// sId is the bind variable so we can change the text.
// fWidth the width of the box.
// fHeight the height of the box.
json CreateTextBox (json jRow, string sId, float fWidth, float fHeight);

// Create a basic text edit box.
// jRow is the row the TextEdit box goes into.
// sPlaceHolderBind is the bind for Placeholder.
// sValueBind is the bind variable so we can change the text.
// nMaxLength is the maximum lenght of the text (1 - 65535)
// bMultiline - True or False that is has multiple lines.
// fWidth the width of the box.
// fHeight the height of the box.
json CreateTextEditBox (json jRow, string sPlaceHolderBind, string sValueBind, int nMaxLength, int bMultiline, float fWidth, float fHeight, string sToolTipBind = "tool_tip");

// Create an image.
// jRow is the row the TextEdit box goes into.
// sImage is the resref of the image to use. If "" is passed then it will
// create a bind of sId + "_image".
// nAspect is the aspect of the image NUI_ASPECT_*.
// nHAlign is the horizontal alignment of the image NUI_HALIGN_*.
// nVAlign is the vertical alignment of the image NUI_VALIGN_*.
// fWidth the width of the box.
// fHeight the height of the box.
json CreateImage (json jRow, string sResRef, string sId, int nAspect, int nHAlign, int nVAlign, float fWidth, float fHeight);

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
// sTitle is the Title of the menu.
// fX is the X position of the menu. if (-1.0) then it will center the x postion
// fY is the Y position of the menu. if (-1.0) then it will center the y postion
// fWidth is the width of the menu.
// fHeight is the height of the menu.
// bResize - TRUE will all it to be resized.
// bCollapse - TRUE will allow the window to be collapsable.
// bClose - TRUE will allow the window to be closed.
// bTransparent - TRUE makes the menu transparent.
// bBorder - TRUE makes the menu have a border.
int SetWindow (object oPC, json jLayout, string sWinID, string sTitle, float fX, float fY, float fWidth, float fHeight, int bResize, int bCollapse, int bClose, int bTransparent, int bBorder)
{
    json jWindow = NuiWindow (jLayout, NuiBind ("window_title"), NuiBind ("window_geometry"),
    NuiBind ("window_resizable"), NuiBind ("window_collapsed"), NuiBind ("window_closable"),
    NuiBind ("window_transparent"), NuiBind ("window_border"));
    int nToken = NuiCreate (oPC, jWindow, sWinID);
    NuiSetBind (oPC, nToken, "window_title", JsonString (sTitle));
    if (fX == -1.0) fX = GetGUIWidthMiddle (oPC, fWidth);
    if (fY == -1.0) fY = GetGUIHeightMiddle (oPC, fHeight);
    NuiSetBind (oPC, nToken, "window_geometry", NuiRect (fX,
                fY, fWidth, fHeight));
    // Temporary set till we figure out the windows.
    NuiSetBind (oPC, nToken, "window_resizable", JsonBool (bResize));
    NuiSetBind (oPC, nToken, "window_collapsed", JsonBool (bCollapse));
    NuiSetBind (oPC, nToken, "window_closable", JsonBool (bClose));
    NuiSetBind (oPC, nToken, "window_transparent", JsonBool (bTransparent));
    NuiSetBind (oPC, nToken, "window_border", JsonBool (bBorder));
    return nToken;
}

// Creates a label element.
// sLabel is the text placed in the label.
//     If "" is passed then it will create a bind of sId + "_label".
// sId is the bind variable so we can change the text.
// fWidth is the width of the label.
// fHeight is the Height of the label.
// nHAlign is horizonal align [NUI_HALING_*].
// nVAlign is vertial align [NUI_VALING_*].
json CreateLabel (string sLabel, string sId, float fWidth, float fHeight, int nHAlign = 0, int nVAlign = 0)
{
    json jLabel;
    if (sLabel == "") jLabel = NuiId (NuiLabel (NuiBind (sId + "_label"), JsonInt (nHAlign), JsonInt (nVAlign)), sId);
    else jLabel = NuiId (NuiLabel (JsonString (sLabel), JsonInt (nHAlign), JsonInt (nVAlign)), sId);
    jLabel = NuiWidth (jLabel, fWidth);
    return NuiHeight (jLabel, fHeight);
}

// Creates a basic button.
// jRow is the row the label goes into.
// sLabel is the text placed in the button. If "" is passed then it will
//     create a bind of sId + "_label".
// sId is the binds for the button and the event uses sId + "_event".
// fWidth is the width of the label.
// fHeight is the Height of the label.
json CreateButton (json jRow, string sLabel, string sId, float fWidth, float fHeight)
{
    json jButton;
    if (sLabel == "") jButton = NuiEnabled (NuiId (NuiButton (NuiBind (sId + "_label")), sId), NuiBind (sId + "_event"));
    else jButton = NuiEnabled (NuiId (NuiButton (JsonString (sLabel)), sId), NuiBind (sId + "_event"));
    jButton = NuiWidth (jButton, fWidth);
    jButton = NuiHeight (jButton, fHeight);
    return JsonArrayInsert (jRow, jButton);
}

// Creates a basic button select.
// jRow is the row the label goes into.
// sLabel is the text placed in the button. If "" is passed then it will
// create a bind of sId + "_label".
// sId is the binds for the button and the event uses sId + "_event".
// fWidth is the width of the label.
// fHeight is the Height of the label.
json CreateButtonSelect (json jRow, string sLabel, string sId, float fWidth, float fHeight)
{
    json jButton;
    if (sLabel == "") jButton = NuiEnabled (NuiId (NuiButtonSelect (NuiBind (sId + "_label"), NuiBind (sId)), sId), NuiBind (sId + "_event"));
    else jButton = NuiEnabled (NuiId (NuiButtonSelect (JsonString (sLabel), NuiBind (sId)), sId), NuiBind (sId + "_event"));
    jButton = NuiWidth (jButton, fWidth);
    jButton = NuiHeight (jButton, fHeight);
    return JsonArrayInsert (jRow, jButton);
}

// Creates a button element with an image instead of text.
// sImage is the resref of the image to use.
//     If "" is passed then it will create a bind of sId + "_image".
// sId is the binds for the button and the event uses sId + "_event".
// fWidth is the width of the label.
// fHeight is the Height of the label.
json CreateButtonImage (string sResRef, string sId, float fWidth, float fHeight)
{
    json jButton;
    if (sResRef == "") jButton = NuiEnabled (NuiId (NuiButtonImage (NuiBind (sId + "_image")), sId), NuiBind (sId + "_event"));
    else jButton = NuiEnabled (NuiId (NuiButtonImage (JsonString (sResRef)), sId), NuiBind (sId + "_event"));
    jButton = NuiWidth (jButton, fWidth);
    return NuiHeight (jButton, fHeight);
}

// Create a basic text box that is not editable.
// jRow is the row the TextEdit box goes into.
// sId is the bind variable so we can change the text.
// fWidth the width of the box.
// fHeight the height of the box.
json CreateTextBox (json jRow, string sId, float fWidth, float fHeight)
{
    json jTextBox = NuiText (NuiBind (sId));
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
    json jObject = NuiTextEdit (NuiBind (sPlaceHolderBind), NuiBind (sValueBind), nMaxLength, bMultiline);
    jObject = NuiWidth (jObject, fWidth);
    jObject = NuiHeight (jObject, fHeight);
    jObject = NuiTooltip (jObject, NuiBind (sToolTipBind));
    return JsonArrayInsert (jRow, jObject);
}

// Create an image.
// jRow is the row the TextEdit box goes into.
// sImage is the resref of the image to use. If "" is passed then it will
// create a bind of sId + "_image".
// nAspect is the aspect of the image NUI_ASPECT_*.
// nHAlign is the horizontal alignment of the image NUI_HALIGN_*.
// nVAlign is the vertical alignment of the image NUI_VALIGN_*.
// fWidth the width of the box.
// fHeight the height of the box.
json CreateImage (json jRow, string sResRef, string sId, int nAspect, int nHAlign, int nVAlign, float fWidth, float fHeight)
{
    json jImage;
    if (sResRef == "") jImage = NuiEnabled (NuiId (NuiImage (NuiBind (sId + "_image"), JsonInt (nAspect), JsonInt (nHAlign), JsonInt (nVAlign)), sId), NuiBind (sId + "_event"));
    else jImage = NuiEnabled (NuiId (NuiImage (JsonString (sResRef), JsonInt (nAspect), JsonInt (nHAlign), JsonInt (nVAlign)), sId), NuiBind (sId + "_event"));
    jImage = NuiWidth (jImage, fWidth);
    jImage = NuiHeight (jImage, fHeight);
    return JsonArrayInsert (jRow, jImage);
}



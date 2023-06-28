#include "inc_xp"
#include "inc_nui_config"

void main()
{
	object oPC = NuiGetEventPlayer();
    string sEvent = NuiGetEventType();
    int nToken = NuiGetEventWindow();
    string sElement = NuiGetEventElement();
    
    string sWindow = NuiGetWindowId(oPC, nToken);
    
    //WriteTimestampedLogEntry("event = " + sEvent + ", element = " + sElement);
    
    // This will handle the events that are made when a PC moves their UI
    // and save the coordinates in their DB
    HandleEditModeEvents();
    
    // This script needs to handle:
    // 1) Changes to rest xp (update text only, and possibly change the hide-on-empty bind)
    // 2) Geometry changes and startup, we have to redo everything
    // 3) Changes to config options:
    //      bgcolor, bgopacity -> assemble a new NuiColor for the background drawlist
    //      hideifempty -> it should be possible to make case 1) handle this
    
    // As 1) and 2) are not true NUI events some things will be passed in via script param
    int bGeometryChange = 0;
    int bTextUpdate = 0;
    string sAction = GetScriptParam("action");
    if (sAction != "")
    {
        oPC = StringToObject(GetScriptParam("pc"));
        nToken = StringToInt(GetScriptParam("token"));
        if (sAction == "init")
        {
            bGeometryChange = 1;
        }
        bTextUpdate = 1;
    }
    
    if (sEvent == "watch" && sElement == "_geometry")
    {
        bGeometryChange = 1;
    }
    
    if (sEvent == "watch" && sElement == "_config_hideifempty")
    {
        bTextUpdate = 1;
    }
    //WriteTimestampedLogEntry("textupdate: " + IntToString(bTextUpdate) + ", geomupdate: " + IntToString(bGeometryChange));
    
    if (sAction == "init" || (sEvent == "watch" && (sElement == "_config_bgcolor" || sElement == "_config_bgopacity")))
    {
        json jColor = NuiGetBind(oPC, nToken, "_config_bgcolor");
        float fOpacity = IntToFloat(JsonGetInt(NuiGetBind(oPC, nToken, "_config_bgopacity")));
        // The slider is 0-100, convert to 0-255
        fOpacity = 255.0 * (fOpacity/100.0);
        int nOpacity = FloatToInt(fOpacity);
        jColor = JsonObjectSet(jColor, "a", JsonInt(nOpacity));
        NuiSetBind(oPC, nToken, "real_bg_color", jColor);
    }
    
    
    if (bGeometryChange)
    {
        json jGeom = NuiGetBind(oPC, nToken, "_geometry");
        json jWidth = JsonObjectGet(jGeom, "w");
        json jHeight = JsonObjectGet(jGeom, "h");
        float fWidth = JsonGetFloat(jWidth);
        float fHeight = JsonGetFloat(jHeight);
        
        // Background drawlist: is simply a big box that covers the whole window.
        json jBackgroundDrawListCoords = JsonArray();
        jBackgroundDrawListCoords = JsonArrayInsert(jBackgroundDrawListCoords, JsonFloat(0.0));
        jBackgroundDrawListCoords = JsonArrayInsert(jBackgroundDrawListCoords, JsonFloat(0.0));
        
        jBackgroundDrawListCoords = JsonArrayInsert(jBackgroundDrawListCoords, jWidth);
        jBackgroundDrawListCoords = JsonArrayInsert(jBackgroundDrawListCoords, JsonFloat(0.0));
        
        jBackgroundDrawListCoords = JsonArrayInsert(jBackgroundDrawListCoords, jWidth);
        jBackgroundDrawListCoords = JsonArrayInsert(jBackgroundDrawListCoords, jHeight);
        
        jBackgroundDrawListCoords = JsonArrayInsert(jBackgroundDrawListCoords, JsonFloat(0.0));
        jBackgroundDrawListCoords = JsonArrayInsert(jBackgroundDrawListCoords, jHeight);
        
        NuiSetBind(oPC, nToken, "background_coords", jBackgroundDrawListCoords);
        
        // Text drawlist rectangle: the hard part is finding the start coordinates to write at
        float fStartX = (fWidth/2.0) - 50.0;
        float fStartY = (fHeight/2.0) - 30.0;
        if (fStartX < 0.0) { fStartX = 0.0; }
        if (fStartY < 0.0) { fStartY = 0.0; }
        NuiSetBind(oPC, nToken, "text_pos1", NuiRect(fStartX, fStartY, 200.0, 200.0));
        NuiSetBind(oPC, nToken, "text_pos2", NuiRect(fStartX, fStartY+20.0, 200.0, 200.0));
        NuiSetBind(oPC, nToken, "text_pos3", NuiRect(fStartX, fStartY+40.0, 200.0, 200.0));
    
    }
    if (bTextUpdate)
    {
        float fAmount = GetRestedXP(oPC);
        if (fAmount <= 0.01 && GetNuiConfigValue(oPC, sWindow, "hideifempty") == JsonBool(1))
        {
            NuiSetBind(oPC, nToken, "visibility", JsonBool(0));
        }
        else
        {    
            NuiSetBind(oPC, nToken, "visibility", JsonBool(1));
            string sAmount = IntToString(FloatToInt(fAmount));
            string sPercent = IntToString(FloatToInt(GetRestedXPPercentage(oPC)*100.0));
            string sAreaRestText = PlayerGetsRestedXPInArea(oPC, GetArea(oPC)) ? "Resting..." : "";
            NuiSetBind(oPC, nToken, "text_content1", JsonString("Rested XP:"));
            NuiSetBind(oPC, nToken, "text_content2", JsonString(sAmount + " (" + sPercent + "%)"));
            NuiSetBind(oPC, nToken, "text_content3", JsonString(sAreaRestText));
        }        
    }
}
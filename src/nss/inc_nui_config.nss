// NUI persistent position and configuration handler.


// Thanks Philos for these values!
// In the words of Philos...
/*
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
*/
const float NUI_TITLEBAR_HEIGHT = 33.0;
const float NUI_WINDOW_EDGE_HEIGHT = 12.0;
const float NUI_SPACE_HEIGHT = 4.0;

const float NUI_EDGE_WIDTH = 12.0;
const float NUI_SPACE_WIDTH = 8.0;

#include "nw_inc_nui"
#include "inc_sqlite_time"
#include "inc_debug"

/*
Usage notes:

1) Define your configs first. Don't try to read from configs that aren't defined yet.
2) This enforces the following binds. This file's contents will also mess with them, so it is maybe best to consider these READ ONLY.
    _resizeable: window resizeability
    _geometry: window geometry [watched]
    _closeable: window closeable state
    _title: window title
3) Make your layout like normal.
4) Use EditableNuiWindow in place of NuiWindow. Geometry parameter should be whatever is returend by GetPersistentWindowGeometryBind
5) Use NuiCreate like normal to get a token.
6) SetIsInterfaceConfigurable if required
7) LoadNuiConfigBinds, even if you don't have any configs set


Configs are automatically bindwatched, these are named "_config_" + sConfigName.
    So a config named "color" will trigger watch events for "_config_color" when changed from the config window.
UserData is set to a JsonObject with a few things passed around on it.
    
*/


// Edit Mode: An option that lets players freely move (and optionally, resize) many interfaces.
// Then we remember where they are for next time (and for all their other characters too).

// Set this interface as being configurable, as well as optionally allowing you to move/resize it in edit mode if you can't normally.
// This is needed if the window has config options, even if you don't want edit mode to let you move it.
// bEditModeAllowsResize does what it says it does. Maybe you don't want some windows to be resized this way.
void SetIsInterfaceConfigurable(object oPC, int nToken, int bEditModeAllowsResize, int bEditModeAllowsMovement);

// Set fixed sizes for opening this window. Passing -1.0 will skip either parameter.
void SetInterfaceFixedSize(string sWindow, float fWidth=-1.0, float fHeight=-1.0);

// Set the state of Edit Mode.
void SetInterfaceEditModeState(object oPC, int bState);

// Get the state of Edit Mode.
int GetInterfaceEditModeState(object oPC);

// Return last recorded geometry for sWindow opened by oPC
// or jDefault if none was set
// (this always returns a bind regardless of whether jDefault was used or not)
json GetPersistentWindowGeometryBind(object oPC, string sWindow, json jDefault);

// Return the actual NuiRect for oPC's sWindow, or jDefault if there is no saved value.
json GetPersistentWindowGeometry(object oPC, string sWindow, json jDefault);
    
// It looks and works just like NuiWindow, but with a few weird options.
// sName is the "internal" name, and should be the same as what is used for NuiCreate
// sDisplayName is the window title shown to the player in the configuration window.
// (without it, interfaces like the XP bar without a title have no "nice" name to show in the configurable interface list)
// jGeometry should always be obtained from GetPersistentWindowGeometryBind first
// You may pass binds as any of the other json args, BUT the bind name must ALWAYS be the same for this window name.
// Resizeable, Collapseable, Closable are ints and cannot be bound, because edit mode needs to mess with them.
// Title is a NWScript string. Passing "" results in JsonBool(FALSE).
json EditableNuiWindow(string sName, string sDisplayName, json jRoot, string sTitle, json jGeometry, int bResizeable, int bCollapse, int bCloseable, json jTransparent, json jBorder); 

// Call this in your event script. It will deal with all edit and config option events.
void HandleEditModeEvents();

// Configure Options: Lets you add config options to NUIs.

// Adds four text entry boxes for X, Y, Width, Height.
// Useful for those windows that normal resizing can't make small enough.
void AddInterfaceConfigOptionFineMovement(string sWindow, int nDefaultX, int nDefaultY, int nDefaultWidth, int nDefaultHeight);

// Add a dropdown config option named sConfigName to sWindow.
// sLabel is shown as the option name.
// sTooltip is shown on hoverover.
// jOptionLabels is a JsonArray of JsonStrings containing the possible option labels.
// jOptionValues is a JsonArray of JsonInts containing enumerated IDs for the options.
// nDefaultOptionIndex defines the index into the arrays that contains the default option.
void AddInterfaceConfigOptionDropdown(string sWindow, string sConfigName, string sLabel, string sTooltip, json jOptionLabels, json jOptionValues, int nDefaultOptionIndex=0);

// Add a text entry config option named sConfigName to sWindow.
// sLabel is shown as the option name.
// sTooltip is shown on hoverover.
// sDefault contains the default text, if any.
void AddInterfaceConfigOptionTextEntry(string sWindow, string sConfigName, string sLabel, string sTooltip, string sDefault="");

// Add a checkbox config option named sConfigName to sWindow.
// sLabel is shown as the option name.
// sTooltip is shown on hoverover.
// bDefault contains the ticked/unticked default state.
void AddInterfaceConfigOptionCheckBox(string sWindow, string sConfigName, string sLabel, string sTooltip, int bDefault=0);

// Add a colorpick config option named sConfigName to sWindow.
// sLabel is shown as the option name.
// sTooltip is shown on hoverover.
// jDefault should be a NuiColor json object containing the default color.
void AddInterfaceConfigOptionColorPick(string sWindow, string sConfigName, string sLabel, string sTooltip, json jDefault);

// Returns the number of config options for sWindow.
// If a PC hasn't opened sWindow since the server started, this will incorrectly return zero.
int GetNumberInterfaceConfigOptions(string sWindow);
    
// Returns a NuiBind containing the the value of the config named sConfigName for sWindow.
json GetNuiConfigBind(string sWindow, string sConfigName);

// Returns a Json wrapped form of oPC's config option.
// (It is necessary to add the config options before calling this, else no defaults will be found on the first pass)
json GetNuiConfigValue(object oPC, string sWindow, string sConfigName);
    
// Once the NUI is created, call this. It updates binds behind the scenes to values the player set.
// This also assigns a new JsonObject to UserData if it is empty.
void LoadNuiConfigBinds(object oPC, int nToken);

   
   
/////////////////////////////////////////////

// PC Locals

// JsonArray of window tokens
const string LOCAL_EDITABLE_INTERFACES = "editable_interfaces";
// Int of t/f
const string LOCAL_EDITMODE_STATE = "editmode_state";

// Module locals
const string LOCAL_NUI_DATA_DB_EXISTS = "nui_data_db";

const int NUI_CONFIG_TYPE_TEXTBOX = 1;
const int NUI_CONFIG_TYPE_CHECKBOX = 2;
const int NUI_CONFIG_TYPE_DROPDOWN = 3;
const int NUI_CONFIG_TYPE_COLORPICK = 4;
const int NUI_CONFIG_TYPE_SLIDER = 5;

// Having a massive array of tokens for interfaces that aren't open any more
// is not going to be a very good idea, so trim them regularly
json _CullDeadEditModeInterfaceTokens(object oPC, json jArray)
{
    int nPos = 0;
    int nLength = JsonGetLength(jArray);
    while (nPos < nLength)
    {
        int nToken = JsonGetInt(JsonArrayGet(jArray, nPos));
        string sID = NuiGetWindowId(oPC, nToken);
        if (sID == "")
        {
            jArray = JsonArrayDel(jArray, nPos);
            nLength--;
            continue;
        }
        nPos++;
    }
    return jArray;
}

// We make a module DB table to store a lot of this stuff.
// This will involve making a LOT of variables, and apparently
// doing them as plain locals can get a bit on the slower side

// The various sqlite variable functions kicking about have been pretty useful for this...

void _CreateModuleNuiDataDBTable()
{
    object oMod = GetModule();
    if (!GetLocalInt(oMod, LOCAL_NUI_DATA_DB_EXISTS))
    {
        sqlquery sql = SqlPrepareQueryObject(GetModule(),
        "CREATE TABLE IF NOT EXISTS inc_nui_data (" +
        "varname TEXT PRIMARY KEY, " +
        "value TEXT);");
        SqlStep(sql);
        SetLocalInt(oMod, LOCAL_NUI_DATA_DB_EXISTS, 1);
    }
}

sqlquery _NuiDataDB_PrepareSelect(string sVarName)
{
    _CreateModuleNuiDataDBTable();
    sqlquery sql = SqlPrepareQueryObject(GetModule(),
        "SELECT value FROM inc_nui_data " +
        "WHERE varname = @varname;");
    SqlBindString(sql, "@varname", sVarName);
    return sql;
}

int _NuiDataDB_GetInt(string sVarName)
{
    sqlquery sql = _NuiDataDB_PrepareSelect(sVarName);
    if (SqlStep(sql))
        return SqlGetInt(sql, 0);
    else
        return 0;
}

float _NuiDataDB_GetFloat(string sVarName)
{
    sqlquery sql = _NuiDataDB_PrepareSelect(sVarName);
    if (SqlStep(sql))
        return SqlGetFloat(sql, 0);
    else
        return 0.0;
}

string _NuiDataDB_GetString(string sVarName)
{
    sqlquery sql = _NuiDataDB_PrepareSelect(sVarName);
    if (SqlStep(sql))
        return SqlGetString(sql, 0);
    else
        return "";
}

json _NuiDataDB_GetJson(string sVarName)
{
    sqlquery sql = _NuiDataDB_PrepareSelect(sVarName);
    if (SqlStep(sql))
        return SqlGetJson(sql, 0);
    else
        return JsonNull();
}

sqlquery _NuiDataDB_PrepareInsert(string sVarName)
{
    _CreateModuleNuiDataDBTable();
    sqlquery sql = SqlPrepareQueryObject(GetModule(),
        "INSERT INTO inc_nui_data " +
        "(varname, value) VALUES (@varname, @value) " + 
        " ON CONFLICT (varname) DO UPDATE SET value = @value;");
    SqlBindString(sql, "@varname", sVarName);
    return sql;
}

void _NuiDataDB_SetInt(string sVarName, int nValue)
{
    sqlquery sql = _NuiDataDB_PrepareInsert(sVarName);
    SqlBindInt(sql, "@value", nValue);
    SqlStep(sql);
}

void _NuiDataDB_SetFloat(string sVarName, float fValue)
{
    sqlquery sql = _NuiDataDB_PrepareInsert(sVarName);
    SqlBindFloat(sql, "@value", fValue);
    SqlStep(sql);
}

void _NuiDataDB_SetString(string sVarName, string sValue)
{
    sqlquery sql = _NuiDataDB_PrepareInsert(sVarName);
    SqlBindString(sql, "@value", sValue);
    SqlStep(sql);
}

void _NuiDataDB_SetJson(string sVarName, json jValue)
{
    sqlquery sql = _NuiDataDB_PrepareInsert(sVarName);
    SqlBindJson(sql, "@value", jValue);
    SqlStep(sql);
}


void SetIsInterfaceConfigurable(object oPC, int nToken, int bEditModeAllowsResize, int bEditModeAllowsMovement)
{
    json jArray = GetLocalJson(oPC, LOCAL_EDITABLE_INTERFACES);
    if (jArray == JsonNull())
    {
        jArray = JsonArray();
    }
    else
    {
        jArray = _CullDeadEditModeInterfaceTokens(oPC, jArray);
    }
    json jToken = JsonInt(nToken);
    json jFind = JsonFind(jArray, jToken);
    if (jFind == JsonNull())
    {
        jArray = JsonArrayInsert(jArray, jToken);
    }
    SetLocalJson(oPC, LOCAL_EDITABLE_INTERFACES, jArray);
    string sWindow = NuiGetWindowId(oPC, nToken);
    _NuiDataDB_SetInt(sWindow + "_editmoderesize", bEditModeAllowsResize);
    _NuiDataDB_SetInt(sWindow + "_editmodemove", bEditModeAllowsMovement);
    // Maintain a list of all configurable interfaces that have been opened since the server started
    json jAllConfigurables = _NuiDataDB_GetJson("all_configurables");
    if (jAllConfigurables == JsonNull())
    {
        jAllConfigurables = JsonArray();
    }
    if (JsonFind(jAllConfigurables, JsonString(sWindow)) == JsonNull())
    {
        jAllConfigurables = JsonArrayInsert(jAllConfigurables, JsonString(sWindow));
        _NuiDataDB_SetJson("all_configurables", jAllConfigurables);
    }
}

void _UpdateEditModeBinds(object oPC, int nToken, string sWindow, int bToggle=0)
{
    string sTitle = _NuiDataDB_GetString(sWindow + "_title");
    json jUserData = NuiGetUserData(oPC, nToken);
    float fYAdjust = 0.0;
    if (GetInterfaceEditModeState(oPC))
    {        
        if (_NuiDataDB_GetInt(sWindow + "_editmoderesize"))
        {
            NuiSetBind(oPC, nToken, "_resizeable", JsonBool(1));
        }
        NuiSetBind(oPC, nToken, "_closeable", JsonBool(0));
        if (sTitle == "" && _NuiDataDB_GetInt(sWindow + "_editmodemove"))
        {
            NuiSetBind(oPC, nToken, "_title", JsonString(_NuiDataDB_GetString(sWindow + "_displayname")));
            if (bToggle)
            {
                json jGeom = NuiGetBind(oPC, nToken, "_geometry");
                float fY = JsonGetFloat(JsonObjectGet(jGeom, "y"));
                float fH = JsonGetFloat(JsonObjectGet(jGeom, "h"));
                fY = fY - fYAdjust;
                fH = fH + fYAdjust;
                jGeom = JsonObjectSet(jGeom, "y", JsonFloat(fY));
                jGeom = JsonObjectSet(jGeom, "h", JsonFloat(fH));
                //NuiSetBind(oPC, nToken, "_geometry", jGeom);
            }
        }
    }
    else
    {
        jUserData = JsonObjectDel(jUserData, "_height_bloat");
        NuiSetBind(oPC, nToken, "_resizeable", JsonBool(_NuiDataDB_GetInt(sWindow + "_resizeable")));
        
        NuiSetBind(oPC, nToken, "_closeable", JsonBool(_NuiDataDB_GetInt(sWindow + "_closeable")));
        if (sTitle == "")
        {
            NuiSetBind(oPC, nToken, "_title", JsonBool(FALSE));
            // If we are turning the title off, the window needs to get smaller again
            if (bToggle && _NuiDataDB_GetInt(sWindow + "_editmodemove"))
            {
                json jGeom = NuiGetBind(oPC, nToken, "_geometry");
                float fY = JsonGetFloat(JsonObjectGet(jGeom, "y"));
                float fH = JsonGetFloat(JsonObjectGet(jGeom, "h"));
                fY = fY + fYAdjust;
                fH = fH - fYAdjust;
                jGeom = JsonObjectSet(jGeom, "y", JsonFloat(fY));
                jGeom = JsonObjectSet(jGeom, "h", JsonFloat(fH));
                //NuiSetBind(oPC, nToken, "_geometry", jGeom);
            }
        }
    }
}

void SetInterfaceEditModeState(object oPC, int bState)
{
    int bOldState = GetLocalInt(oPC, LOCAL_EDITMODE_STATE);
    if (bOldState != bState)
    {
        SetLocalInt(oPC, LOCAL_EDITMODE_STATE, bState);
        json jArray = GetLocalJson(oPC, LOCAL_EDITABLE_INTERFACES);
        jArray = _CullDeadEditModeInterfaceTokens(oPC, jArray);
        int nLength = JsonGetLength(jArray);
        int i;
        for (i=0; i<nLength; i++)
        {
            
            int nToken = JsonGetInt(JsonArrayGet(jArray, i));
            string sWindow = NuiGetWindowId(oPC, nToken);
            //WriteTimestampedLogEntry("Entry " + IntToString(i) + " of " + IntToString(nLength) + " = " + sWindow);
            _UpdateEditModeBinds(oPC, nToken, sWindow, 1);
        }
        
    }
}

int GetInterfaceEditModeState(object oPC)
{
    return GetLocalInt(oPC, LOCAL_EDITMODE_STATE);
}

json EditableNuiWindow(string sName, string sDisplayName, json jRoot, string sTitle, json jGeometry, int bResizeable, int bCollapse, int bCloseable, json jTransparent, json jBorder)
{
    json jResizeable = NuiBind("_resizeable");
    // binding collapse prevents you from hiding title bars
    //json jCollapse = NuiBind("_collapse");
    json jCloseable = NuiBind("_closeable");
    json jTitle = NuiBind("_title");
    _NuiDataDB_SetInt(sName + "_resizeable", bResizeable);
    //_NuiDataDB_SetInt(sName + "_collapse", bCollapse);
    _NuiDataDB_SetInt(sName + "_closeable", bCloseable);
    _NuiDataDB_SetString(sName + "_title", sTitle);
    _NuiDataDB_SetString(sName + "_displayname", sDisplayName);
    _NuiDataDB_SetInt(sName + "_iseditable", 1);
    return NuiWindow(jRoot, jTitle, jGeometry, jResizeable, JsonBool(bCollapse), jCloseable, jTransparent, jBorder);
}

void LoadNuiConfigBinds(object oPC, int nToken)
{
    json jUserData = NuiGetUserData(oPC, nToken);
    if (jUserData == JsonNull())
    {
        jUserData = JsonObject();
        NuiSetUserData(oPC, nToken, jUserData);
    }
    string sWindow = NuiGetWindowId(oPC, nToken);
    string sKey = GetPCPublicCDKey(oPC, TRUE);
    json jGeom = GetCampaignJson(sKey, "nui_geom_" + sWindow);
    int bEditMode = GetInterfaceEditModeState(oPC);
    
    if (jGeom != JsonNull())
    {
        float fFixedWidth = _NuiDataDB_GetFloat(sWindow + "_fixed_width");
        if (fFixedWidth > 0.0)
        {
            jGeom = JsonObjectSet(jGeom, "w", JsonFloat(fFixedWidth));
        }
        float fFixedHeight = _NuiDataDB_GetFloat(sWindow + "_fixed_height");
        if (fFixedHeight > 0.0)
        {
            jGeom = JsonObjectSet(jGeom, "h", JsonFloat(fFixedHeight));
        }
        NuiSetBind(oPC, nToken, "_geometry", jGeom);
        //WriteTimestampedLogEntry("Set geom to " + JsonDump(jGeom));
    }
    NuiSetBindWatch(oPC, nToken, "_geometry", 1);
    _UpdateEditModeBinds(oPC, nToken, sWindow, 0);
    int nNumConfigs = _NuiDataDB_GetInt(sWindow + "_num_configs");
    int i;
    for (i=0; i<nNumConfigs; i++)
    {
        string sConfigName = _NuiDataDB_GetString(sWindow + "_config_" + IntToString(i));
        //WriteTimestampedLogEntry("LoadNuiConfigBinds: " + sConfigName + " -> " + JsonDump(GetNuiConfigValue(oPC, sWindow, sConfigName)));
        NuiSetBind(oPC, nToken, "_config_" + sConfigName, GetNuiConfigValue(oPC, sWindow, sConfigName));
        NuiSetBindWatch(oPC, nToken, "_config_" + sConfigName, 1);
    }
    NuiSetBind(oPC, nToken, "_title", JsonString(_NuiDataDB_GetString(sWindow + "_title")));
}

json GetPersistentWindowGeometryBind(object oPC, string sWindow, json jDefault)
{
    string sKey = GetPCPublicCDKey(oPC, TRUE);
    _NuiDataDB_SetJson(sWindow + "_default_geom", jDefault);
    json jSaved = GetCampaignJson(sKey, "nui_geom_" + sWindow);
    if (jSaved == JsonNull())
    {
        SetCampaignJson(sKey, "nui_geom_" + sWindow, jDefault);
    }
    return NuiBind("_geometry");
}

json GetPersistentWindowGeometry(object oPC, string sWindow, json jDefault)
{
    string sKey = GetPCPublicCDKey(oPC, TRUE);
    _NuiDataDB_SetJson(sWindow + "_default_geom", jDefault);
    json jSaved = GetCampaignJson(sKey, "nui_geom_" + sWindow);
    if (jSaved == JsonNull())
    {
        SetCampaignJson(sKey, "nui_geom_" + sWindow, jDefault);
        jSaved = jDefault;
    }
    return jSaved;
}

void AddInterfaceConfigOptionSlider(string sWindow, string sConfigName, string sLabel, string sTooltip, int nMin, int nMax, int nStep, int nDefault)
{
    if (!_NuiDataDB_GetInt(sWindow + "_config_" + sConfigName))
    {
        int nThisConfig = _NuiDataDB_GetInt(sWindow + "_num_configs");
        _NuiDataDB_SetInt(sWindow + "_config_" + sConfigName, nThisConfig+1);
        _NuiDataDB_SetInt(sWindow + "_num_configs", nThisConfig+1);
        _NuiDataDB_SetString(sWindow + "_config_" + IntToString(nThisConfig), sConfigName);
        _NuiDataDB_SetInt(sWindow + "_config_" + IntToString(nThisConfig) + "_type", NUI_CONFIG_TYPE_SLIDER);
        _NuiDataDB_SetString(sWindow + "_config_" + IntToString(nThisConfig) + "_label", sLabel);
        _NuiDataDB_SetString(sWindow + "_config_" + IntToString(nThisConfig) + "_tooltip", sTooltip);
        _NuiDataDB_SetJson(sWindow + "_config_" + IntToString(nThisConfig) + "_min", JsonInt(nMin));
        _NuiDataDB_SetJson(sWindow + "_config_" + IntToString(nThisConfig) + "_max", JsonInt(nMax));
        _NuiDataDB_SetJson(sWindow + "_config_" + IntToString(nThisConfig) + "_step", JsonInt(nStep));
        _NuiDataDB_SetJson(sWindow + "_config_" + IntToString(nThisConfig) + "_default", JsonInt(nDefault));
    }
}

void AddInterfaceConfigOptionDropdown(string sWindow, string sConfigName, string sLabel, string sTooltip, json jOptionLabels, json jOptionValues, int nDefaultOptionIndex=0)
{
    if (!_NuiDataDB_GetInt(sWindow + "_config_" + sConfigName))
    {
        int nThisConfig = _NuiDataDB_GetInt(sWindow + "_num_configs");
        _NuiDataDB_SetInt(sWindow + "_config_" + sConfigName, nThisConfig+1);
        _NuiDataDB_SetInt(sWindow + "_num_configs", nThisConfig+1);
        _NuiDataDB_SetString(sWindow + "_config_" + IntToString(nThisConfig), sConfigName);
        _NuiDataDB_SetInt(sWindow + "_config_" + IntToString(nThisConfig) + "_type", NUI_CONFIG_TYPE_DROPDOWN);
        _NuiDataDB_SetString(sWindow + "_config_" + IntToString(nThisConfig) + "_label", sLabel);
        _NuiDataDB_SetString(sWindow + "_config_" + IntToString(nThisConfig) + "_tooltip", sTooltip);
        _NuiDataDB_SetJson(sWindow + "_config_" + IntToString(nThisConfig) + "_labels", jOptionLabels);
        _NuiDataDB_SetJson(sWindow + "_config_" + IntToString(nThisConfig) + "_values", jOptionValues);
        _NuiDataDB_SetJson(sWindow + "_config_" + IntToString(nThisConfig) + "_default", JsonArrayGet(jOptionValues, nDefaultOptionIndex));
    }
}

void AddInterfaceConfigOptionTextEntry(string sWindow, string sConfigName, string sLabel, string sTooltip, string sDefault="")
{
    if (!_NuiDataDB_GetInt(sWindow + "_config_" + sConfigName))
    {
        int nThisConfig = _NuiDataDB_GetInt(sWindow + "_num_configs");
        _NuiDataDB_SetInt(sWindow + "_config_" + sConfigName, nThisConfig+1);
        _NuiDataDB_SetInt(sWindow + "_num_configs", nThisConfig+1);
        _NuiDataDB_SetString(sWindow + "_config_" + IntToString(nThisConfig), sConfigName);
        _NuiDataDB_SetInt(sWindow + "_config_" + IntToString(nThisConfig) + "_type", NUI_CONFIG_TYPE_TEXTBOX);
        _NuiDataDB_SetString(sWindow + "_config_" + IntToString(nThisConfig) + "_label", sLabel);
        _NuiDataDB_SetString(sWindow + "_config_" + IntToString(nThisConfig) + "_tooltip", sTooltip);
        _NuiDataDB_SetJson(sWindow + "_config_" + IntToString(nThisConfig) + "_default", JsonString(sDefault));
    }
}

void AddInterfaceConfigOptionCheckBox(string sWindow, string sConfigName, string sLabel, string sTooltip, int bDefault=0)
{
    if (!_NuiDataDB_GetInt(sWindow + "_config_" + sConfigName))
    {
        int nThisConfig = _NuiDataDB_GetInt(sWindow + "_num_configs");
        _NuiDataDB_SetInt(sWindow + "_config_" + sConfigName, nThisConfig+1);
        _NuiDataDB_SetInt(sWindow + "_num_configs", nThisConfig+1);
        _NuiDataDB_SetString(sWindow + "_config_" + IntToString(nThisConfig), sConfigName);
        _NuiDataDB_SetInt(sWindow + "_config_" + IntToString(nThisConfig) + "_type", NUI_CONFIG_TYPE_CHECKBOX);
        _NuiDataDB_SetString(sWindow + "_config_" + IntToString(nThisConfig) + "_label", sLabel);
        _NuiDataDB_SetString(sWindow + "_config_" + IntToString(nThisConfig) + "_tooltip", sTooltip);
        _NuiDataDB_SetJson(sWindow + "_config_" + IntToString(nThisConfig) + "_default", JsonBool(bDefault));
    }
}

void AddInterfaceConfigOptionColorPick(string sWindow, string sConfigName, string sLabel, string sTooltip, json jDefault)
{
    if (!_NuiDataDB_GetInt(sWindow + "_config_" + sConfigName))
    {
        int nThisConfig = _NuiDataDB_GetInt(sWindow + "_num_configs");
        _NuiDataDB_SetInt(sWindow + "_config_" + sConfigName, nThisConfig+1);
        _NuiDataDB_SetInt(sWindow + "_num_configs", nThisConfig+1);
        _NuiDataDB_SetString(sWindow + "_config_" + IntToString(nThisConfig), sConfigName);
        _NuiDataDB_SetInt(sWindow + "_config_" + IntToString(nThisConfig) + "_type", NUI_CONFIG_TYPE_COLORPICK);
        _NuiDataDB_SetString(sWindow + "_config_" + IntToString(nThisConfig) + "_label", sLabel);
        _NuiDataDB_SetString(sWindow + "_config_" + IntToString(nThisConfig) + "_tooltip", sTooltip);
        _NuiDataDB_SetJson(sWindow + "_config_" + IntToString(nThisConfig) + "_default", jDefault);
    }
}

void AddInterfaceConfigOptionFineMovement(string sWindow, int nDefaultX, int nDefaultY, int nDefaultWidth, int nDefaultHeight)
{
    AddInterfaceConfigOptionTextEntry(sWindow, "finemovex", "X Position", "This sets the left/right position of the interface. Larger numbers make the interface move right across the screen.", IntToString(nDefaultX));
    AddInterfaceConfigOptionTextEntry(sWindow, "finemovey", "Y Position", "This sets the top/bottom position of the interface. Larger numbers make the interface move down to the bottom of the screen.", IntToString(nDefaultY));
    AddInterfaceConfigOptionTextEntry(sWindow, "finemovew", "Width", "This sets the width of the interface.", IntToString(nDefaultWidth));
    AddInterfaceConfigOptionTextEntry(sWindow, "finemoveh", "Height", "This sets the height of the interface.", IntToString(nDefaultHeight));
}

// Returns a NuiBind containing the the value of the config named sConfigName for sWindow.
json GetNuiConfigBind(string sWindow, string sConfigName)
{
    return NuiBind("_config_" + sConfigName);
}

string GetNuiConfigBindString(string sWindow, string sConfigName)
{
    return "_config_" + sConfigName;
}

// Returns a Json wrapped form of oPC's config option.
// (It is necessary to add the config options before calling this, else no defaults will be found on the first pass)
json GetNuiConfigValue(object oPC, string sWindow, string sConfigName)
{
    string sKey = GetPCPublicCDKey(oPC, TRUE);
    json jFetch = GetCampaignJson(sKey, "nuicfg" + sWindow + "_" + sConfigName);
    if (jFetch == JsonNull())
    {
        int nConfigID = _NuiDataDB_GetInt(sWindow + "_config_" + sConfigName)-1;
        jFetch = _NuiDataDB_GetJson(sWindow + "_config_" + IntToString(nConfigID) + "_default");
    }
    return jFetch;
}

json _BuildConfigGroupForWindow(string sWindow)
{
    // There is no good reason not to save the json for this.
    json jSaved = _NuiDataDB_GetJson("configuration_window_json_" + sWindow);
    
    // In development it turns out that it's really helpful to have this reload on its own
    if (jSaved != JsonNull() && !GetIsDevServer())
    {
        return jSaved;
    }
    
    json jDefaults = JsonArray();
    
    json jTopRow = JsonArray();
    json jButton = NuiId(NuiHeight(NuiWidth(NuiButton(JsonString("Reset Position")), 120.0), 40.0), "resetpos_" + sWindow);
    jTopRow = JsonArrayInsert(jTopRow, jButton);
    jButton = NuiId(NuiHeight(NuiWidth(NuiButton(JsonString("Reset Size")), 120.0), 40.0), "resetsize_" + sWindow);
    jTopRow = JsonArrayInsert(jTopRow, jButton);
    jTopRow = NuiRow(jTopRow);
    
    
    json jRows = JsonArray();    
    jRows = JsonArrayInsert(jRows, jTopRow);
    int nNumConfigs = _NuiDataDB_GetInt(sWindow + "_num_configs");
    int i;
    json jBindValues = JsonArray();
    for (i=0; i<nNumConfigs; i++)
    {
        int nType = _NuiDataDB_GetInt(sWindow + "_config_" + IntToString(i) + "_type");
        string sLabel = _NuiDataDB_GetString(sWindow + "_config_" + IntToString(i) + "_label");
        string sTooltip = _NuiDataDB_GetString(sWindow + "_config_" + IntToString(i) + "_tooltip");
        string sConfigName = _NuiDataDB_GetString(sWindow + "_config_" + IntToString(i));
        //json jValue = GetNuiConfigValue(oPC, sWindow, sConfigName);
        json jDefault = _NuiDataDB_GetJson(sWindow + "_config_" + IntToString(i) + "_default");
        json jLabel = NuiTooltip(NuiLabel(JsonString(sLabel), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_MIDDLE)), JsonString(sTooltip));
        json jRow = JsonArray();
        jRow = JsonArrayInsert(jRow, jLabel);
        json jBind = NuiBind("config_" + sWindow + "_" + IntToString(i));
        float fThisHeight = 50.0;
        if (nType == NUI_CONFIG_TYPE_CHECKBOX)
        {
            json jCheck = NuiCheck(JsonString(""), jBind);
            jRow = JsonArrayInsert(jRow, NuiWidth(jCheck, 100.0));
            //jBindValues = JsonArrayInsert(jBindValues, jValue);
        }
        else if (nType == NUI_CONFIG_TYPE_COLORPICK)
        {
            json jCheck = NuiColorPicker(jBind);
            jRow = JsonArrayInsert(jRow, jCheck);
            //jBindValues = JsonArrayInsert(jBindValues, jValue);
            fThisHeight = 200.0;
        }
        else if (nType == NUI_CONFIG_TYPE_DROPDOWN)
        {
            json jLabels = _NuiDataDB_GetJson(sWindow + "_config_" + IntToString(i) + "_labels");
            json jValues = _NuiDataDB_GetJson(sWindow + "_config_" + IntToString(i) + "_values");
            //int nSelectedIndex = JsonGetInt(JsonFind(jValues, jValue));
            //if (nSelectedIndex < 0) { nSelectedIndex = 0; }
            json jEntries = JsonArray();
            int nLength = JsonGetLength(jLabels);
            int j;
            for (j=0; j<nLength; j++)
            {
                jEntries = JsonArrayInsert(jEntries, NuiComboEntry(JsonGetString(JsonArrayGet(jLabels, j)), JsonGetInt(JsonArrayGet(jValues, j))));
            }
            json jCheck = NuiCombo(jEntries, jBind);
            jRow = JsonArrayInsert(jRow, jCheck);
            //jBindValues = JsonArrayInsert(jBindValues, JsonInt(nSelectedIndex));
            int nDefaultIndex = JsonGetInt(JsonFind(jValues, jDefault));
            if (nDefaultIndex < 0) { nDefaultIndex = 0; }
            jDefault = JsonInt(nDefaultIndex);
        }
        else if (nType == NUI_CONFIG_TYPE_TEXTBOX)
        {
            json jTemp = JsonArray();
            jTemp = JsonArrayInsert(jTemp, NuiSpacer());
            json jCheck = NuiHeight(NuiWidth(NuiTextEdit(JsonString(""), jBind, 30, 0), 100.0), 40.0);
            jTemp = JsonArrayInsert(jTemp, jCheck);
            jTemp = JsonArrayInsert(jTemp, NuiSpacer());
            jRow = JsonArrayInsert(jRow, NuiCol(jTemp));
            //jBindValues = JsonArrayInsert(jBindValues, jValue);
        }
        else if (nType == NUI_CONFIG_TYPE_SLIDER)
        {
            json jMin = JsonInt(_NuiDataDB_GetInt(sWindow + "_config_" + IntToString(i) + "_min"));
            json jMax = JsonInt(_NuiDataDB_GetInt(sWindow + "_config_" + IntToString(i) + "_max"));
            json jStep = JsonInt(_NuiDataDB_GetInt(sWindow + "_config_" + IntToString(i) + "_step"));
            json jCheck = NuiWidth(NuiHeight(NuiSlider(jBind, jMin, jMax, jStep), 40.0), 200.0);
            jRow = JsonArrayInsert(jRow, jCheck);
        }
        json jButtonArr = JsonArray();
        jButtonArr = JsonArrayInsert(jButtonArr, NuiSpacer());
        json jReset = NuiTooltip(NuiId(NuiWidth(NuiHeight(NuiButton(JsonString("R")), 40.0), 40.0), "button_default_" + IntToString(i)), JsonString("Reset this option to its default value."));
        jButtonArr = JsonArrayInsert(jButtonArr, jReset);
        jButtonArr = JsonArrayInsert(jButtonArr, NuiSpacer());
        jDefaults = JsonArrayInsert(jDefaults, jDefault);
        //jRow = JsonArrayInsert(jRow, jReset);
        jRow = JsonArrayInsert(jRow, NuiCol(jButtonArr));
        jRows = JsonArrayInsert(jRows, NuiWidth(NuiHeight(NuiRow(jRow), fThisHeight), 400.0));
    }
    json jGroup = NuiGroup(NuiCol(jRows));
    jGroup = NuiId(jGroup, "configgroup_" + sWindow);
        
    /*
    // Set values
    for (i=0; i<nNumConfigs; i++)
    {
        NuiSetBind(oPC, nParentToken, "config_" + sWindow + "_" + IntToString(i), JsonArrayGet(jBindValues, i));
        // And watch these binds
        NuiSetBindWatch(oPC, nParentToken, "config_" + sWindow + "_" + IntToString(i), 1);
    }
    */
    
    _NuiDataDB_SetJson("configuration_window_json_" + sWindow, jGroup);
    _NuiDataDB_SetJson("configuration_window_defaults" + sWindow, jDefaults);
    
    return jGroup;
}

void _LoadConfigPanelValuesForWindow(object oPC, string sWindow, int nToken)
{
    int nNumConfigs = _NuiDataDB_GetInt(sWindow + "_num_configs");
    int i;
    json jBindValue;
    float fHeight = 0.0;
    for (i=0; i<nNumConfigs; i++)
    {
        int nType = _NuiDataDB_GetInt(sWindow + "_config_" + IntToString(i) + "_type");
        string sConfigName = _NuiDataDB_GetString(sWindow + "_config_" + IntToString(i));
        json jValue = GetNuiConfigValue(oPC, sWindow, sConfigName);
        if (nType == NUI_CONFIG_TYPE_DROPDOWN)
        {
            json jValues = _NuiDataDB_GetJson(sWindow + "_config_" + IntToString(i) + "_values");
            int nSelectedIndex = JsonGetInt(JsonFind(jValues, jValue));
            if (nSelectedIndex < 0) { nSelectedIndex = 0; }
            jBindValue = JsonInt(nSelectedIndex);
        }
        else
        {
            jBindValue = jValue;
        }
        NuiSetBind(oPC, nToken, "config_" + sWindow + "_" + IntToString(i), jBindValue);
        // And watch these binds
        NuiSetBindWatch(oPC, nToken, "config_" + sWindow + "_" + IntToString(i), 1);
    }
}

void HandleEditModeEvents()
{
    object oPC = NuiGetEventPlayer();
    string sEvent = NuiGetEventType();
    int nToken = NuiGetEventWindow();
    string sElement = NuiGetEventElement();
    string sWindow = NuiGetWindowId(oPC, nToken);
    
    string sKey = GetPCPublicCDKey(oPC, TRUE);
    
    json jUserData = NuiGetUserData(oPC, nToken);
    
    // Save updated geometry
    if (sEvent == "watch" && sElement == "_geometry")
    {
        json jGeom = NuiGetBind(oPC, nToken, "_geometry");
        float fW = JsonGetFloat(JsonObjectGet(jGeom, "w"));
        float fH = JsonGetFloat(JsonObjectGet(jGeom, "h"));
        if (fW != 0.0 && fH != 0.0)
        {
            int bChange = 0;
            if (fW < 50.0)
            {
                jGeom = JsonObjectSet(jGeom, "w", JsonFloat(50.0));
                bChange = 1;
            }
            if (fH < 5.0)
            {
                jGeom = JsonObjectSet(jGeom, "h", JsonFloat(5.0));
                bChange = 1;
            }
            
            //jGeom = NuiRect(300.0, 300.0, 300.0, 40.0);
            //WriteTimestampedLogEntry("Save geom for " + sWindow + ": " + JsonDump(jGeom));
            SetCampaignJson(sKey, "nui_geom_" + sWindow, jGeom);
            if (bChange)
            {
                //WriteTimestampedLogEntry("force changed geom, do new update");
                NuiSetBind(oPC, nToken, "_geometry", jGeom);
            }
        }
    }
}

int GetNumberInterfaceConfigOptions(string sWindow)
{
    return _NuiDataDB_GetInt(sWindow + "_num_configs");
}


//////////////////////////////
// Master configuration window

const float CONFIGWINDOW_BUTTONCOLUMN_WIDTH = 180.0;

void DisplayUIMasterConfigurationInterface(object oPC)
{
    json jTop = JsonArray();
    json jTopLabel = NuiLabel(JsonString("Select an interface to view available configuration options."), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_MIDDLE));
    json jEditButtonText = NuiBind("edit_button_text");
    json jRefreshButton = NuiId(NuiHeight(NuiWidth(NuiButton(jEditButtonText), 160.0), 40.0), "configuration_editmode");
    jRefreshButton = NuiTooltip(jRefreshButton, JsonString("Edit mode allows some otherwise fixed interfaces to be moved around."));
    jTop = JsonArrayInsert(jTop, jTopLabel);
    jTop = JsonArrayInsert(jTop, jRefreshButton);
    json jTopRow = NuiRow(jTop);
    json jConfigurable = _NuiDataDB_GetJson("all_configurables");
    
    json jLeftButtonList = JsonArray();
    
    
    int nNumConfigurable = JsonGetLength(jConfigurable);
    int i;
    for (i=0; i<nNumConfigurable; i++)
    {
        string sConfigurable = JsonGetString(JsonArrayGet(jConfigurable, i));
        int nNumConfigs = GetNumberInterfaceConfigOptions(sConfigurable);
        if (nNumConfigs > 0)
        {
            json jWindowConfigOptionButton = NuiButton(JsonString(_NuiDataDB_GetString(sConfigurable + "_displayname")));
            jWindowConfigOptionButton = NuiHeight(jWindowConfigOptionButton, 40.0);
            jWindowConfigOptionButton = NuiWidth(jWindowConfigOptionButton, CONFIGWINDOW_BUTTONCOLUMN_WIDTH - (NUI_SPACE_WIDTH*2));
            jWindowConfigOptionButton = NuiId(jWindowConfigOptionButton, "configure_" + sConfigurable);
            jLeftButtonList = JsonArrayInsert(jLeftButtonList, jWindowConfigOptionButton);
        }
    }
    
    
    
    json jButtonGroup = NuiGroup(NuiCol(jLeftButtonList));
    jButtonGroup = NuiHeight(jButtonGroup, 600.0);
    jButtonGroup = NuiWidth(jButtonGroup, CONFIGWINDOW_BUTTONCOLUMN_WIDTH);
    jButtonGroup = NuiId(jButtonGroup, "buttonlist");
    
    json jConfigArea = NuiGroup(NuiCol(JsonArray()));
    jConfigArea = NuiHeight(jConfigArea, 600.0);
    jConfigArea = NuiWidth(jConfigArea, 450.0);
    jConfigArea = NuiId(jConfigArea, "configarea");
    
    json jContentRow = JsonArray();
    jContentRow = JsonArrayInsert(jContentRow, jButtonGroup);
    jContentRow = JsonArrayInsert(jContentRow, jConfigArea);
    jContentRow = NuiRow(jContentRow);
    
    json jLayout = JsonArray();
    jLayout = JsonArrayInsert(jLayout, jTopRow);
    jLayout = JsonArrayInsert(jLayout, jContentRow);
    //jLayout = JsonArrayInsert(jLayout, jButtonGroup);
    
    jLayout = NuiCol(jLayout);
    //json jTemp = JsonArray();
    //jTemp = JsonArrayInsert(jTemp, jButtonGroup);
    //jLayout = jButtonGroup;
    //jLayout = NuiRow(jButtonGroup);
    
    // I guess there's something slightly funny about using the configurable interface functions
    // to configure the configuration interface
    
    SetInterfaceFixedSize("nui_config", 670.0, 720.0);
    json jGeometry = GetPersistentWindowGeometryBind(oPC, "nui_config", NuiRect(-1.0, -1.0, 670.0, 720.0));
    json jNui = EditableNuiWindow("nui_config", "Interface Configuration", jLayout, "Interface Configuration", jGeometry, 0, 0, 1, JsonBool(0), JsonBool(1));
    int nToken = NuiCreate(oPC, jNui, "nui_config");
    SetIsInterfaceConfigurable(oPC, nToken, 0, 1);
    LoadNuiConfigBinds(oPC, nToken);
    
    int bEditState = GetInterfaceEditModeState(oPC);
    if (bEditState)
    {
        NuiSetBind(oPC, nToken, "edit_button_text", JsonString("Leave Edit Mode"));
    }
    else
    {
        NuiSetBind(oPC, nToken, "edit_button_text", JsonString("Enter Edit Mode"));
    }
}

void SetInterfaceFixedSize(string sWindow, float fWidth, float fHeight)
{
    _NuiDataDB_SetFloat(sWindow + "_fixed_width", fWidth);
    _NuiDataDB_SetFloat(sWindow + "_fixed_height", fHeight);
}


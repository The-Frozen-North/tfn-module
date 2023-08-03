#include "inc_nui_config"
#include "inc_sqlite_time"

void ProcessConfigChange(object oPC, string sElement, int nToken, string sParentWindowName, int nParentToken)
{
    // Okay, you've waited long enough and can queue another one now
    DeleteLocalInt(oPC, "nui_config_time_" + sElement);
    //WriteTimestampedLogEntry("ProcessConfigChange: " + sElement);
    
    // config_pcxbar_1
    
    string sKey = GetPCPublicCDKey(oPC, TRUE);
    string sConfig = GetSubString(sElement, 8 + GetStringLength(sParentWindowName), 99);
    // Make sure you're trying to configure the right window!
    // Somehow it's apparently possible to trigger config events for other windows that aren't
    // the one that's visible...  
    if (GetSubString(sElement, 7, GetStringLength(sParentWindowName)) != sParentWindowName)
    {
        // Well, in the end regex makes pulling the pieces out of this string easier
        // given that the new window name is not known and may contain underscores, trying to do this conventionally
        // would be harder
        json jMatch = RegExpMatch("config_(.*)_(\\d)*$", sElement);
        if (jMatch != JsonNull())
        {
            if (JsonGetLength(jMatch) == 3)
            {
                string sChangedWindowName = JsonGetString(JsonArrayGet(jMatch, 1));
                int nChangedConfigID = JsonGetInt(JsonArrayGet(jMatch, 2));
                sConfig = _NuiDataDB_GetString(sChangedWindowName + "_config_" + IntToString(nChangedConfigID));
                // Change it back to the old one!
                json jValue = GetNuiConfigValue(oPC, sChangedWindowName, sConfig);
                SetCdkeyJson(oPC, "nuiconfig", "nuicfg" + sChangedWindowName + "_" + sConfig, jValue);
                NuiSetBind(oPC, nParentToken, "_config_" + sConfig, jValue);
                WriteTimestampedLogEntry("Tried to change config " + sConfig + " of " + sChangedWindowName + " while visible window was " + sParentWindowName);
                return;
            }
        }
    }
    
    
    int nConfigID = StringToInt(sConfig);
    json jValue = NuiGetBind(oPC, nToken, sElement);
    string sConfigName = _NuiDataDB_GetString(sParentWindowName + "_config_" + IntToString(nConfigID));
    
    // There seems to be a client bug when opening a new config panel that makes all the color pickers
    // set their values to 0, 0, 0, 255 on their own sometimes without really interacting with them
    // Hack solution: don't allow colorpickers to be set to this within a few seconds of opening a new config panel
    int nType = _NuiDataDB_GetInt(sParentWindowName + "_config_" + IntToString(nConfigID) + "_type");
    if (nType == NUI_CONFIG_TYPE_COLORPICK)
    {
        int nNow = SQLite_GetTimeStamp();
        int nLastNewConfig = JsonGetInt(JsonObjectGet(NuiGetUserData(oPC, nToken), "last_config_switch_time"));
        if (nNow - nLastNewConfig < 3)
        {
            if (JsonGetInt(JsonObjectGet(jValue, "r")) == 0)
            {
                if (JsonGetInt(JsonObjectGet(jValue, "g")) == 0)
                {
                    if (JsonGetInt(JsonObjectGet(jValue, "b")) == 0)
                    {
                        // We have the old value saved, so...
                        jValue = GetNuiConfigValue(oPC, sParentWindowName, sConfigName);
                    }
                }
            }
        }
    }
       
    
    SetCdkeyJson(oPC, "nuiconfig", "nuicfg" + sParentWindowName + "_" + sConfigName, jValue);
    NuiSetBind(oPC, nParentToken, "_config_" + sConfigName, jValue);
    //WriteTimestampedLogEntry("ConfigChange " + sConfigName + " (id " + IntToString(nConfigID) + " -> " + JsonDump(jValue));
    if (GetStringLeft(sConfigName, 8) == "finemove")
    {
        //WriteTimestampedLogEntry("ConfigChange " + sConfigName + " is finemove");
        string sDirection = GetStringRight(sConfigName, 1);
        json jGeom = NuiGetBind(oPC, nParentToken, "_geometry");
        int nValue = StringToInt(JsonGetString(jValue));
        if (nValue > 0)
        {
            jGeom = JsonObjectSet(jGeom, sDirection, JsonFloat(IntToFloat(nValue)));
        }
        NuiSetBind(oPC, nParentToken, "_geometry", jGeom);
    }
    //WriteTimestampedLogEntry("Saved config " + sConfigName + " -> " + JsonDump(jValue));
}

void main()
{
    
    object oPC = NuiGetEventPlayer();
    string sEvent = NuiGetEventType();
    int nToken = NuiGetEventWindow();
    string sElement = NuiGetEventElement();
    int nArrIndex = NuiGetEventArrayIndex();
    
    //WriteTimestampedLogEntry("Event: " + sEvent + ", elem = " + sElement + ", arrindex = " + IntToString(nArrIndex));
    
    json jUserData = NuiGetUserData(oPC, nToken);
    
    string sParentWindowName = JsonGetString(JsonObjectGet(jUserData, "parent_window"));
    int nParentToken = NuiFindWindow(oPC, sParentWindowName);
    
    string sKey = GetPCPublicCDKey(oPC, TRUE);
        
    
    if (sEvent == "click" && GetStringLeft(sElement, 10) == "configure_")
    {
        string sWindowToConfigure = GetSubString(sElement, 10, 99);
        // Pull in the layout of this window's config
        json jConfigLayout = _BuildConfigGroupForWindow(sWindowToConfigure);
        NuiSetGroupLayout(oPC, nToken, "configarea", jConfigLayout);
        // Load this PC's values into the config area we just made
        _LoadConfigPanelValuesForWindow(oPC, sWindowToConfigure, nToken);
        // Save which window is currently being configured
        jUserData = JsonObjectSet(jUserData, "parent_window", JsonString(sWindowToConfigure));
        jUserData = JsonObjectSet(jUserData, "last_config_switch_time", JsonInt(SQLite_GetTimeStamp()));
    }
    else if (sEvent == "click" && GetStringLeft(sElement, 15) == "button_default_")
    {
        int nConfigID = StringToInt(GetSubString(sElement, 15, 99));
        json jDefaults = _NuiDataDB_GetJson("configuration_window_defaults" + sParentWindowName);
        json jDefault = JsonArrayGet(jDefaults, nConfigID);
        NuiSetBind(oPC, nToken, "config_" + sParentWindowName + "_" + IntToString(nConfigID), jDefault);
    }
    else if (GetStringLeft(sElement, 7) == "config_" && sEvent == "watch")
    {
        // Gotta rate limit the PC, turns out that sliding your finger happily over a colorpicker
        // triggers hundreds of events and lags the server to heck
        // so maybe don't allow that
        if (GetLocalInt(oPC, "nui_config_time_" + sElement))
        {
            return;
        }
        SetLocalInt(oPC, "nui_config_time_" + sElement, 1);
        DelayCommand(1.0, ProcessConfigChange(oPC, sElement, nToken, sParentWindowName, nParentToken));
    }
    else if (sEvent == "click" && sElement == "configuration_editmode")
    {
        int bNewState = !GetInterfaceEditModeState(oPC);
        if (bNewState)
        {
            NuiSetBind(oPC, nToken, "edit_button_text", JsonString("Leave Edit Mode"));
        }
        else
        {
            NuiSetBind(oPC, nToken, "edit_button_text", JsonString("Enter Edit Mode"));
        }
        SetInterfaceEditModeState(oPC, bNewState);
    }
    else if (sEvent == "click" && GetStringLeft(sElement, 10) == "resetsize_")
    {
        string sWindowToReset = GetSubString(sElement, 10, 99);
        if (sWindowToReset == sParentWindowName)
        {
            json jGeom = GetCdkeyJson(oPC, "nuiconfig", "nui_geom_" + sWindowToReset);
            json jDefault = _NuiDataDB_GetJson(sWindowToReset + "_default_geom");
            jGeom = JsonObjectSet(jGeom, "w", JsonObjectGet(jDefault, "w"));
            jGeom = JsonObjectSet(jGeom, "h", JsonObjectGet(jDefault, "h"));
            NuiSetBind(oPC, nParentToken, "_geometry", jGeom);
        }
    }
    if (sEvent == "click" && GetStringLeft(sElement, 9) == "resetpos_")
    {
        string sWindowToReset = GetSubString(sElement, 9, 99);
        if (sWindowToReset == sParentWindowName)
        {
            json jGeom = GetCdkeyJson(oPC, "nuiconfig", "nui_geom_" + sWindowToReset);
            json jDefault = _NuiDataDB_GetJson(sWindowToReset + "_default_geom");
            jGeom = JsonObjectSet(jGeom, "x", JsonObjectGet(jDefault, "x"));
            jGeom = JsonObjectSet(jGeom, "y", JsonObjectGet(jDefault, "y"));
            NuiSetBind(oPC, nParentToken, "_geometry", jGeom);
        }
    }
    
    
    NuiSetUserData(oPC, nToken, jUserData);
    
}
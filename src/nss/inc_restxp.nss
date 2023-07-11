#include "inc_persist"
#include "util_i_math"
#include "inc_sqlite_time"
#include "inc_housing"
#include "inc_debug"
#include "inc_general"
#include "inc_nui_config"

// The cap of rested XP for a PC is (this variable * amount of xp to reach next level, not counting PC's current progress)
const float RESTEDXP_CAP_BASE = 700.0;
const float RESTEDXP_CAP_PER_LEVEL = 130.0;

// The amount of seconds of logged in time to gain 100% rested xp
const int RESTEDXP_TIME_TO_FILL = 86400; // 24h

// When not online, rested xp gain is multiplied by this
const float RESTEDXP_OFFLINE_MULTIPLIER = 0.075;

// Proportional increase that rested xp adds
// 0.0 = no bonus
// 1.0 = double xp
const float RESTEDXP_KILL_INCREASE = 1.0;
const float RESTEDXP_QUEST_INCREASE = 0.0;

// How much rested XP to give from resting at home, per house tier.
// 0.01 = 1% of cap for poor, 2% for average, 3% for rich
const float RESTEDXP_HOUSE_PER_HOUSE_QUALITY = 0.04;

// The time in seconds between successive at-home rests giving house xp
const int RESTEDXP_HOUSE_REST_COOLDOWN = 21600; // 6h

// Adds six seconds worth of rested xp to oPC, if they are in an eligible area
// Sends notifications to oPC every 2% rested XP they gain
void AddRestedXPHeartbeat(object oPC);

// Every time a logged in player passes a milestone of this much of the total of their rested XP pool
// Send them a message.
const float RESTEDXP_NOTIFICATION_PERCENTAGE = 0.02;

// Adds offline rested XP to oPC if they are in an eligible area
void AddRestedXPOnLogin(object oPC);

// Return fBaseXP modified by the rested increase factor fIncrease, capped to the oPC's available rested xp.
// Deducts the correct amount of xp from the PC's rested pool.
// fIncrease should be RESTEDXP_KILL_INCREASE or RESTEDXP_QUEST_INCREASE.
float GetRestModifiedExperience(float fBaseXP, object oPC, float fIncrease);

// Returns the amount of rested XP oPC has available.
float GetRestedXP(object oPC);

// Returns the maximum amount of rested experience oPC can have
float GetRestedXPCap(object oPC);

// Returns the proportion of rested experience oPC has of their maximum (should be 0-1 in virtually all cases)
float GetRestedXPPercentage(object oPC);

// Sends a FloatingTextString to oPC stating how much rested experience they have
// Does nothing if they have no rested xp
void SendRestedXPNotifierToPC(object oPC);

// FloatToString, except leading whitespace is stripped, and trailing zeroes after the decimal separator are removed
string NeatFloatToString(float fFloat, int nMaxDecimals=2);

// Popup to send when entering a resting area
void SendOnEnterRestedPopup(object oPC);

int PlayerGetsRestedXPInArea(object oPC, object oArea=OBJECT_INVALID);

// This function returns the level based on XP
int GetLevelFromXP(int nXP);

// Decide if oPC's rested xp UI should be hidden or visible.
void ShowOrHideRestXPUI(object oPC, object oArea=OBJECT_INVALID);

// Update oPC's Rested XP NUI.
// If they don't have it open, does nothing.
void UpdateRestXPUI(object oPC);

// Update oPC's XP bar NUI.
// If they don't have it open, does nothing.
void UpdateXPBarUI(object oPC);

// Returns the token of oPC's Rested XP UI.
// This is 0 if they don't have it open.
int GetRestXPUIToken(object oPC);

const string RESTEDXP_AREA_VAR = "restxp";


/////////////////////////////////////////////



const string RESTEDXP_PLAYER_VAR = "PCRestXP";

int GetLevelFromXP(int nXP)
{
   return FloatToInt(0.5 + sqrt(0.25 + (IntToFloat(nXP) / 500 )));
}

int PlayerGetsRestedXPInArea(object oPC, object oArea=OBJECT_INVALID)
{
    if (!GetIsObjectValid(oArea)) { oArea = GetArea(oPC); }
    if (GetLocalInt(oArea, RESTEDXP_AREA_VAR))
    {
        return 1;
    }
    // Also in your own home
    if (!GetIsPlayerHomeless(oPC) && GetTag(oArea) == GetHomeTag(oPC))
    {
        return 1;
    }
    return 0;
}

string NeatFloatToString(float fFloat, int nMaxDecimals=2)
{
    string sOut = FloatToString(fFloat, 18, nMaxDecimals);
    while (1)
    {
        if (GetStringLeft(sOut, 1) == " ")
        {
            sOut = GetSubString(sOut, 1, GetStringLength(sOut));
            continue;
        }
        break;
    }

    while (1)
    {
        string sLastChar = GetStringRight(sOut, 1);
        if (sLastChar == "0" || sLastChar == ".")
        {
            sOut = GetSubString(sOut, 0, GetStringLength(sOut) - 1);
            // Do not go beyond the decimal point
            if (sLastChar == ".")
            {
                break;
            }
            continue;
        }
        break;
    }
    return sOut;
}


float GetRestedXP(object oPC)
{
    return SQLocalsPlayer_GetFloat(oPC, RESTEDXP_PLAYER_VAR);
}

float GetRestedXPCap(object oPC)
{
    //int nXPToLevel = StringToInt(Get2DAString("exptable", "XP", GetHitDice(oPC))) - StringToInt(Get2DAString("exptable", "XP", GetHitDice(oPC)-1));
    return RESTEDXP_CAP_BASE + (RESTEDXP_CAP_PER_LEVEL * IntToFloat(GetLevelFromXP(GetXP(oPC))));
}

float GetRestedXPPercentage(object oPC)
{
    return GetRestedXP(oPC)/GetRestedXPCap(oPC);
}

void _AddRestedXPFlat(object oPC, float fAmountToAdd)
{
    float fCurrent = GetRestedXP(oPC);
    float fRestXPCap = fmax(fCurrent, GetRestedXPCap(oPC));
    float fFinal = fmin(fCurrent + fAmountToAdd, fRestXPCap);
    //SendDebugMessage("Add to rest xp: new = " + FloatToString(fFinal) + " cap = " + FloatToString(fRestXPCap));
    SQLocalsPlayer_SetFloat(oPC, RESTEDXP_PLAYER_VAR, fFinal);
    UpdateRestXPUI(oPC);
    UpdateXPBarUI(oPC);
}

void _AddRestedXP(object oPC, float fTimeDelta)
{
    float fProportionToAdd = fTimeDelta / IntToFloat(RESTEDXP_TIME_TO_FILL);
    float fRestXPCap = GetRestedXPCap(oPC);
    float fAmountToAdd = fRestXPCap * fProportionToAdd;
    _AddRestedXPFlat(oPC, fAmountToAdd);
}

void SendRestedXPNotifierToPC(object oPC)
{
    // If they have the UI open, don't spam system messages as well
    if (GetRestXPUIToken(oPC) != 0) { return; }
    
    float fRestedXP = GetRestedXP(oPC);
    if (fRestedXP >= 0.01)
    {
        float fPercentage = GetRestedXPPercentage(oPC);
        string sMes = "Rested XP: " + NeatFloatToString(fRestedXP, 1) + " (" + NeatFloatToString(100*fPercentage, 1) + "% of maximum)";
        SendColorMessageToPC(oPC, sMes, MESSAGE_COLOR_INFO);
    }
}

void AddRestedXPOnLogin(object oPC)
{
    object oArea = GetArea(oPC);
    if (!GetIsObjectValid(oArea))
    {
        SendDebugMessage(GetName(oPC) + "'s area not valid, try again soon");
        DelayCommand(2.0, AddRestedXPOnLogin(oPC));
        return;
    }
    int nLogout = SQLocalsPlayer_GetInt(oPC, "RESTXP_LAST_SAVE");
    int nNow = SQLite_GetTimeStamp();
    SendDebugMessage(GetName(oPC) + "'s area is valid, run xp on login");
    SQLocalsPlayer_SetInt(oPC, "RESTXP_LAST_SAVE", nNow);
    if (PlayerGetsRestedXPInArea(oPC))
    {
        // Assumed: no variable set, player logged out before this was added
        // We can't really give them anything. :(
        // Definitely DON'T assume them to have last logged in at epoch time 0
        if (nLogout <= 100) { return; }

        float fDelta = IntToFloat(nNow - nLogout);
        fDelta *= RESTEDXP_OFFLINE_MULTIPLIER;
        SendDebugMessage(GetName(oPC) + "'s login rest xp in seconds: " + NeatFloatToString(fDelta, 2), TRUE);
        _AddRestedXP(oPC, fDelta);
        SendRestedXPNotifierToPC(oPC);
    }
}

void AddRestedXPHeartbeat(object oPC)
{
    if (PlayerGetsRestedXPInArea(oPC))
    {
        float fOldPercentage = GetRestedXPPercentage(oPC);
        _AddRestedXP(oPC, 6.0);
        float fNewPercentage = GetRestedXPPercentage(oPC);
        if (fmod(fOldPercentage, RESTEDXP_NOTIFICATION_PERCENTAGE) > fmod(fNewPercentage, RESTEDXP_NOTIFICATION_PERCENTAGE))
        {
            SendRestedXPNotifierToPC(oPC);
        }
    }
}

float GetRestModifiedExperience(float fBaseXP, object oPC, float fIncrease)
{
    float fRestedXP = GetRestedXP(oPC);
    if (fRestedXP > 0.0)
    {
        float fRestedXPAddition = fBaseXP * fIncrease;
        if (fRestedXPAddition >= fRestedXP)
        {
            SQLocalsPlayer_SetFloat(oPC, RESTEDXP_PLAYER_VAR, 0.0);
            FloatingTextStringOnCreature("You have run out of Rested XP.", oPC, FALSE);
            UpdateRestXPUI(oPC);
            return (fBaseXP + fRestedXP);
        }
        else
        {
            SQLocalsPlayer_SetFloat(oPC, RESTEDXP_PLAYER_VAR, fRestedXP - fRestedXPAddition);
            UpdateRestXPUI(oPC);
            return (fBaseXP + fRestedXPAddition);
        }
    }
    return fBaseXP;
}

int IsEligibleForHouseRestingXP(object oPC)
{
    if (!GetIsPlayerHomeless(oPC))
    {
        int nLastRest = SQLocalsPlayer_GetInt(oPC, "RestXP_LastHouseRest");
        int nNow = SQLite_GetTimeStamp();
        int nDelta = nNow - nLastRest;
        if (nDelta >= RESTEDXP_HOUSE_REST_COOLDOWN)
        {
            return 1;
        }
    }
    return 0;
}

void GiveHouseRestingXP(object oPC)
{
    object oArea = GetArea(oPC);
    if (IsEligibleForHouseRestingXP(oPC) && GetTag(oArea) == GetHomeTag(oPC))
    {
        if (GetRestedXPPercentage(oPC) >= 1.0)
        {
            FloatingTextStringOnCreature("You cannot accumulate more Rested XP!", oPC, FALSE);
            return;
        }
        int nNow = SQLite_GetTimeStamp();
        SQLocalsPlayer_SetInt(oPC, "RestXP_LastHouseRest", nNow);
        int nHouseCost = GetCampaignInt(GetPCPublicCDKey(oPC), "house_cost");
        int nMult = 0;
        if (nHouseCost >= 40000)
        {
            nMult = 3;
        }
        else if (nHouseCost >= 15000)
        {
            nMult = 2;
        }
        else if (nHouseCost >= 6000)
        {
            nMult = 1;
        }
        float fRestedXPToAdd = IntToFloat(nMult) * RESTEDXP_HOUSE_PER_HOUSE_QUALITY * GetRestedXPCap(oPC);
        _AddRestedXPFlat(oPC, fRestedXPToAdd);
        FloatingTextStringOnCreature("Resting at home makes you feel refreshed, giving you some Rested XP.", oPC, FALSE);
        return;
    }
    else if (!GetIsPlayerHomeless(oPC) && GetTag(oArea) == GetHomeTag(oPC))
    {
        FloatingTextStringOnCreature("You aren't tired enough yet to get a fully refreshing sleep.", oPC, FALSE);
    }
}

void SendOnEnterRestedPopup(object oPC)
{
    if (GetRestXPUIToken(oPC) != 0) { return; }
    SendColorMessageToPC(oPC, "This area feels safe and comfortable enough that you are gaining Rested XP. This will increase experience gained from kills until depleted. Logging out here will continue to add Rested XP at a lower rate.", MESSAGE_COLOR_INFO);
}

void RestXPDisplay(object oPC, object oArea=OBJECT_INVALID)
{
    if (!GetIsObjectValid(GetArea(oPC)))
    {
        DelayCommand(2.0, RestXPDisplay(oPC, oArea));
        return;
    }
    if (!GetIsObjectValid(oArea))
    {
        oArea = GetArea(oPC);
    }
    string sKey = GetPCPublicCDKey(oPC, TRUE);
    int nSetting = GetCampaignInt(sKey, "option_restxp_ui");
    // 0 = off, 1 = always on, 2 = resting areas only
    if (nSetting == 0 || (nSetting == 2 && !PlayerGetsRestedXPInArea(oPC, oArea)))
    {
        return;
    }
    
    string sWindow = "restxp_nui";
    // Config first.
    AddInterfaceConfigOptionColorPick(sWindow, "textcolor", "Text Color", "The color of the text.", NuiColor(255, 255, 255, 255));
    AddInterfaceConfigOptionColorPick(sWindow, "bgcolor", "Background Color", "The color of the background.", NuiColor(0, 0, 0, 255));
    AddInterfaceConfigOptionSlider(sWindow, "bgopacity", "Background Opacity", "The opacity of the background.", 0, 100, 1, 40);
    AddInterfaceConfigOptionCheckBox(sWindow, "hideifempty", "Hide if Empty", "Hide all UI display if empty.", 1);
    
    // NUI's colorpick does not support opacity, so we have to assemble it later
    json jBackgroundColor = NuiBind("real_bg_color");
    // Bind to hide everything when PC has no rest xp
    json jVisibility = NuiBind("visibility");
    // The configs will write to this bind directly!
    json jTextColor = GetNuiConfigBind(sWindow, "textcolor");
    
    // This is just a label with a background and text drawlisted on top. Not very much to it
    json jBackgroundDrawListCoords = NuiBind("background_coords");
    json jBackgroundDrawList = NuiDrawListPolyLine(jVisibility, jBackgroundColor, JsonBool(1), JsonFloat(1.0), jBackgroundDrawListCoords);
    
    // We need 3 rows of text!
    
    json jTextPos1 = NuiBind("text_pos1");
    json jTextContent1 = NuiBind("text_content1");
    json jTextDrawList1 = NuiDrawListText(jVisibility, jTextColor, jTextPos1, jTextContent1);
    
    json jTextPos2 = NuiBind("text_pos2");
    json jTextContent2 = NuiBind("text_content2");
    json jTextDrawList2 = NuiDrawListText(jVisibility, jTextColor, jTextPos2, jTextContent2);
    
    json jTextPos3 = NuiBind("text_pos3");
    json jTextContent3 = NuiBind("text_content3");
    json jTextDrawList3 = NuiDrawListText(jVisibility, jTextColor, jTextPos3, jTextContent3);
    
    json jDrawListArray = JsonArray();
    jDrawListArray = JsonArrayInsert(jDrawListArray, jBackgroundDrawList);
    jDrawListArray = JsonArrayInsert(jDrawListArray, jTextDrawList1);
    jDrawListArray = JsonArrayInsert(jDrawListArray, jTextDrawList2);
    jDrawListArray = JsonArrayInsert(jDrawListArray, jTextDrawList3);
    
    json jLabel = NuiLabel(JsonString(""), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE));
    jLabel = NuiDrawList(jLabel, JsonBool(0), jDrawListArray);
    
    json jLayout = JsonArray();
    jLayout = JsonArrayInsert(jLayout, jLabel);
    json jRoot = NuiRow(jLayout);
    
    // Pick a default window size.
    float fWinSizeX = 90.0;
    float fWinSizeY = 68.0;
    
    SetInterfaceFixedSize(sWindow, fWinSizeX, fWinSizeY);
    
    float fMidX = IntToFloat(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_WIDTH)/2)*0.8 - (fWinSizeX/2);
    float fMidY = IntToFloat(GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_HEIGHT))*0.2 - (fWinSizeY/2);
    
    json jGeometry = GetPersistentWindowGeometryBind(oPC, sWindow, NuiRect(fMidX, fMidY, fWinSizeX, fWinSizeY));
    WriteTimestampedLogEntry("Geometry: " + JsonDump(NuiRect(fMidX, fMidY, fWinSizeX, fWinSizeY)));
    
    // No title, not collapsable, not moveable: get rid of title bar
    json jNui = EditableNuiWindow(sWindow, "Rested XP Display", jRoot, "", jGeometry, 0, 0, 0, JsonBool(1), JsonBool(0));     
    int nToken = NuiCreate(oPC, jNui, sWindow);
    // Allow edit mode movement, but not resizing
    SetIsInterfaceConfigurable(oPC, nToken, 0, 1);
    // Load PC's saved config binds immediately
    LoadNuiConfigBinds(oPC, nToken);
    
    // Send some script params to the event script
    // This can update the draw lists and everything
    SetScriptParam("action", "init");
    SetScriptParam("pc", ObjectToString(oPC));
    SetScriptParam("token", IntToString(nToken));
    SetScriptParam("updatebar", "1");
    ExecuteScript("restxp_nui_evt", OBJECT_SELF);
}


void ShowOrHideRestXPUI(object oPC, object oArea=OBJECT_INVALID)
{
    // We need to pass the area, because GetArea(oPC) in an OnEnter script returns OBJECT_INVALID
    // so the enter script can pass itself to check whether we get rest xp there or not
    string sKey = GetPCPublicCDKey(oPC, TRUE);
    int nSetting = GetCampaignInt(sKey, "option_restxp_ui");
    int nToken = GetRestXPUIToken(oPC);
    int bClose = 0;
    int bOpen = 0;
    if (nSetting == 0)
    {
        if (nToken != 0)
        {
            bClose = 1;
        }
    }
    else if (nSetting == 1)
    {
        if (nToken == 0)
        {
            bOpen = 1;
        }
    }
    else if (nSetting == 2)
    {
        bOpen = PlayerGetsRestedXPInArea(oPC, oArea);
        bClose = !bOpen;
    }
    if (bClose) { NuiDestroy(oPC, nToken); }
    if (bOpen) { RestXPDisplay(oPC, oArea); }
}


void UpdateRestXPUI(object oPC)
{
    int nToken = GetRestXPUIToken(oPC);
    if (nToken != 0)
    {
        SetScriptParam("action", "update");
        SetScriptParam("pc", ObjectToString(oPC));
        SetScriptParam("token", IntToString(nToken));
        ExecuteScript("restxp_nui_evt", oPC);
    }
}

int GetRestXPUIToken(object oPC)
{
    return NuiFindWindow(oPC, "restxp_nui");
}

#include "inc_persist"
#include "util_i_math"
#include "inc_sqlite_time"
#include "inc_housing"
#include "inc_debug"

// The cap of rested XP for a PC is (this variable * amount of xp to reach next level, not counting PC's current progress)
const float RESTEDXP_CAP_BASE = 1000.0;
const float RESTEDXP_CAP_PER_LEVEL = 200.0;

// The amount of seconds of logged in time to gain 100% rested xp
//const int RESTEDXP_TIME_TO_FILL = 129600; // 36h
const int RESTEDXP_TIME_TO_FILL = 86400; // 24h

// When not online, re  sted xp gain is multiplied by this
const float RESTEDXP_OFFLINE_MULTIPLIER = 0.05;

// Proportional increase that rested xp adds
// 0.0 = no bonus
// 1.0 = double xp
const float RESTEDXP_KILL_INCREASE = 0.7;
const float RESTEDXP_QUEST_INCREASE = 0.0;

// How much rested XP to give from resting at home, per house tier.
// 0.01 = 1% of cap for poor, 2% for average, 3% for rich
const float RESTEDXP_HOUSE_PER_HOUSE_QUALITY = 0.01;

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
    float fRestXPCap = GetRestedXPCap(oPC);
    float fCurrent = GetRestedXP(oPC);
    float fFinal = fmin(fCurrent + fAmountToAdd, fRestXPCap);
    //SendDebugMessage("Add to rest xp: new = " + FloatToString(fFinal) + " cap = " + FloatToString(fRestXPCap));
    SQLocalsPlayer_SetFloat(oPC, RESTEDXP_PLAYER_VAR, fFinal);
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
    float fRestedXP = GetRestedXP(oPC);
    if (fRestedXP >= 0.01)
    {
        float fPercentage = GetRestedXPPercentage(oPC);
        string sMes = "Rested XP: " + NeatFloatToString(fRestedXP, 2) + " (" + NeatFloatToString(100*fPercentage, 2) + "%)";
        FloatingTextStringOnCreature(sMes, oPC, FALSE);
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
        SendDebugMessage(GetName(oPC) + "'s login rest xp in seconds: " + NeatFloatToString(fDelta), TRUE);
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
            return (fBaseXP + fRestedXP);
        }
        else
        {
            SQLocalsPlayer_SetFloat(oPC, RESTEDXP_PLAYER_VAR, fRestedXP - fRestedXPAddition);
            return (fBaseXP + fRestedXPAddition);
        }        
    }
    return fBaseXP;
}

void GiveHouseRestingXP(object oPC)
{
    object oArea = GetArea(oPC);
    if (!GetIsPlayerHomeless(oPC) && GetTag(oArea) == GetHomeTag(oPC))
    {
        int nLastRest = SQLocalsPlayer_GetInt(oPC, "RestXP_LastHouseRest");
        int nNow = SQLite_GetTimeStamp();
        int nDelta = nNow - nLastRest;
        if (nDelta >= RESTEDXP_HOUSE_REST_COOLDOWN)
        {  
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
            FloatingTextStringOnCreature("Resting at home makes you feel refreshed.", oPC, FALSE);
        }
    }
}

void SendOnEnterRestedPopup(object oPC)
{
    SendMessageToPC(oPC, "This area feels safe and comfortable enough that you are gaining Rested XP.");
}

#include "inc_debug"
#include "nwnx_object"

// -------------------------------------------------------------------------
// PROTOTYPES
// -------------------------------------------------------------------------

//save current pc location and hps into database
void SavePCInfo(object oPC);

// Set a temporary global integer that lasts X seconds. Default 60.0.
// Use 0.0 or less fSeconds to never expire for the current session.
void SetTemporaryInt(string sName, int nValue, float fSeconds = 60.0);

// Get a temporary integer from the module.
int GetTemporaryInt(string sName);

// -------------------------------------------------------------------------
// FUNCTIONS
// -------------------------------------------------------------------------

// -------------------------------------------------------------------------
// TEMPORARY
// -------------------------------------------------------------------------

void SetTemporaryInt(string sName, int nValue, float fSeconds = 60.0)
{
    object oModule = GetModule();
    SetLocalInt(oModule, sName, 1);
    SendDebugMessage("Temporary int set: "+sName+" Value: "+IntToString(nValue)+" Expires in: "+FloatToString(fSeconds));
    if (fSeconds > 0.0) DelayCommand(fSeconds, DeleteLocalInt(oModule, sName));
}
int GetTemporaryInt(string sName)
{
    int nValue = GetLocalInt(GetModule(), sName);
    SendDebugMessage("Temporary int retrieved: "+sName+" Value: "+IntToString(nValue));
    return nValue;
}

// -------------------------------------------------------------------------
// PC FUNCTIONS
// -------------------------------------------------------------------------

void SavePCInfo(object oPC)
{
    object oArea = GetArea(oPC);

// Do this if in a valid area
    if(GetIsAreaAboveGround(oArea) != AREA_INVALID)
    {
         vector v = GetPosition(oPC);
         NWNX_Object_SetFloat(oPC, "LOC_X", v.x, TRUE);
         NWNX_Object_SetFloat(oPC, "LOC_Y", v.y, TRUE);
         NWNX_Object_SetFloat(oPC, "LOC_Z", v.z, TRUE);
         NWNX_Object_SetFloat(oPC, "LOC_O", GetFacing(oPC), TRUE);
         NWNX_Object_SetString(oPC, "LOC_A", GetTag(oArea), TRUE);
    }

    NWNX_Object_SetInt(oPC, "CURRENT_HP", GetCurrentHitPoints(oPC), TRUE);
}

//void main () {}

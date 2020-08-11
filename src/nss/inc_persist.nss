#include "inc_debug"
#include "nwnx_object"
#include "nwnx_player"

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

// Saves the current area's minimap data for the PC.
// Stored as map_AREA_RESREF
void ExportMinimap(object oPC);

// Loads the PC's current area minimap data.
void ImportMinimap(object oPC);
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

void ExportMinimap(object oPC)
{
    if (!GetIsPC(oPC)) return;

    object oArea = GetArea(oPC);

    if (GetIsAreaNatural(oArea) == AREA_INVALID) return;

// don't export areas that are set to explored
    if (GetLocalInt(oArea, "explored") == 1) return;

    string sData = NWNX_Player_GetAreaExplorationState(oPC, oArea);
    string sDataTarget = "map_"+GetResRef(oArea);

    SendDebugMessage("exporting minimap "+sDataTarget+": "+sData);
    NWNX_Object_SetString(oPC, sDataTarget, sData, TRUE);
}

void ImportMinimap(object oPC)
{
  if (!GetIsPC(oPC)) return;

  object oArea = GetArea(oPC);

  if (GetIsAreaNatural(oArea) == AREA_INVALID) return;

  if (GetLocalInt(oArea, "explored") == 1)
  {
    ExploreAreaForPlayer(oArea, oPC, FALSE);
    ExploreAreaForPlayer(oArea, oPC, TRUE);
  }
  else
  {
    string sDataTarget = "map_"+GetResRef(oArea);
    string sData = NWNX_Object_GetString(oPC, sDataTarget);
    SendDebugMessage("importing minimap "+sDataTarget+": "+sData);

    if (sData == "") return;

    ExploreAreaForPlayer(oArea, oPC, FALSE);
    NWNX_Player_SetAreaExplorationState(oPC, oArea, sData);
  }
}

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

    ExportMinimap(oPC);

    NWNX_Object_SetInt(oPC, "CURRENT_HP", GetCurrentHitPoints(oPC), TRUE);
}

//void main () {}

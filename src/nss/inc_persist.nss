#include "inc_debug"
#include "inc_sql"
#include "inc_mappin"
#include "nwnx_player"
#include "nwnx_creature"

// -------------------------------------------------------------------------
// PROTOTYPES
// -------------------------------------------------------------------------

//save current pc location and hps into database
void SavePCInfo(object oPC);

// TRUE if running SavePCInfo right now will go through or whether it will be blocked.
// Useful for avoiding duplication exploitation
// for example if a character cannot be saved, they should not
// be allowed to interact with house storage as that will be saved
// even if the player's BIC is not.
// Put simply, without checking this, a PC can polymorph, deposit their life savings into their house
// then log out and back in, and because their BIC isn't saved their gold will be both in their inventory
// and in their house
// If FALSE, writes a string explaining why to the module to the module's UNABLE_TO_SAVE_INFO variable
int CanSavePCInfo(object oPC);

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

const string UNABLE_TO_SAVE_INFO = "inc_persist_cant_save_reason";

// -------------------------------------------------------------------------
// TEMPORARY
// -------------------------------------------------------------------------

void SetTemporaryInt(string sName, int nValue, float fSeconds = 60.0)
{
    object oModule = GetModule();
    SetLocalInt(oModule, sName, 1);
    SendDebugMessage("Temporary int set: "+sName+" Value: "+IntToString(nValue)+" Expires in: "+FloatToString(fSeconds));
    // Assign the clear command to the module
    // If OBJECT_SELF (such as a henchman) is destroyed before this ticks down
    // the var will not be unset until the server is restarted
    if (fSeconds > 0.0) 
    {
        AssignCommand(oModule, DelayCommand(fSeconds, DeleteLocalInt(oModule, sName)));
    }
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

int CanSavePCInfo(object oPC)
{
    object oMod = GetModule();
    DeleteLocalString(oMod, UNABLE_TO_SAVE_INFO);
    //if (NWNX_Creature_GetIsBartering(oPC))
    //{
    //    SendDebugMessage("Can't save BIC for "+GetName(oPC)+" because bartering", TRUE);
    //    SetLocalString(oMod, UNABLE_TO_SAVE_INFO, "Your progress cannot be saved while bartering.");
    //    return 0;
    //}

    int bPolymorph = FALSE;

    effect e = GetFirstEffect(oPC);
    while(GetIsEffectValid(e))
    {
        if(GetEffectType(e) == EFFECT_TYPE_POLYMORPH)
        {
            bPolymorph = TRUE;
            break;
        }
        e = GetNextEffect(oPC);
    }

    if (bPolymorph)
    {
        SendDebugMessage("Can't save BIC for "+GetName(oPC)+" because polymorphed", TRUE);
        SetLocalString(oMod, UNABLE_TO_SAVE_INFO, "Your progress cannot be saved while polymorphed.");
        return 0;
    }
    return 1;
}

void ExportMinimap(object oPC)
{
    if (!GetIsPC(oPC)) return;

    object oArea = GetArea(oPC);

    if (GetIsAreaNatural(oArea) == AREA_INVALID) return;

// don't export areas that are set to explored
    if (GetLocalInt(oArea, "explored") == 1) return;

    string sData = NWNX_Player_GetAreaExplorationState(oPC, oArea);
    string sDataTarget = "map_"+GetResRef(oArea);

    //SendDebugMessage("exporting minimap "+sDataTarget+": "+sData);
    SQLocalsPlayer_SetString(oPC, sDataTarget, sData);
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
    string sData = SQLocalsPlayer_GetString(oPC, sDataTarget);
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
         SQLocalsPlayer_SetFloat(oPC, "LOC_X", v.x);
         SQLocalsPlayer_SetFloat(oPC, "LOC_Y", v.y);
         SQLocalsPlayer_SetFloat(oPC, "LOC_Z", v.z);
         SQLocalsPlayer_SetFloat(oPC, "LOC_O", GetFacing(oPC));
         SQLocalsPlayer_SetString(oPC, "LOC_A", GetTag(oArea));
    }

    ExportMinimap(oPC);
    MapPin_SavePCMapPins(oPC);
        
    SQLocalsPlayer_SetInt(oPC, "CURRENT_HP", GetCurrentHitPoints(oPC));
}

//void main () {}

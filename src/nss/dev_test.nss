#include "nw_inc_nui"
#include "nwnx_util"
#include "inc_treasuremap"
#include "x0_i0_position"


void TestExistingMaps(int nACR)
{
    object oPC = GetFirstPC();
    int nPuzzleID = GetLocalInt(oPC, "puzzleid");
    if (nPuzzleID <= 0)
    {
        InitialiseTreasureMap(oPC, nACR);
        nPuzzleID = GetLocalInt(oPC, "puzzleid");
    }
    SendMessageToPC(oPC, "Puzzle = " + IntToString(nPuzzleID));
    location lSoln = GetPuzzleSolutionLocation(nPuzzleID);
    int nValid = IsTreasureLocationValid(lSoln);
    SendMessageToPC(oPC, "Valid: " + IntToString(nValid));
    if (GetActionMode(oPC, ACTION_MODE_STEALTH))
    {
        SendMessageToPC(oPC, IntToString(nPuzzleID));
        SendMessageToPC(oPC, LocationToString(lSoln));
        AssignCommand(oPC, JumpToLocation(lSoln));
    }
    if (GetArea(oPC) == GetAreaFromLocation(lSoln))
    {
        if (GetDistanceBetweenLocations(GetLocation(oPC), lSoln) <= TREASUREMAP_LOCATION_TOLERANCE)
        {
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_FIREBALL), lSoln);
            DeleteLocalInt(oPC, "puzzleid");
        }
        else
        {
            DisplayTreasureMapUI(oPC, nPuzzleID, nACR);
        }
    }
    else
    {
        DisplayTreasureMapUI(oPC, nPuzzleID, nACR);
    }
    
}

void ReseedAMap(int nPuzzleID)
{
    NWNX_Util_SetInstructionLimit(52428888);
    CalculateTreasureMaps(nPuzzleID);
    DisplayTreasureMapUI(GetFirstPC(), nPuzzleID, 3);
}

void main()
{
    //ReseedAMap(274);
    TestExistingMaps(15);
    //TreasureMapSwatch(GetFirstPC());
    //DisplayTreasureMapUI(GetFirstPC(), 274, 3);
}

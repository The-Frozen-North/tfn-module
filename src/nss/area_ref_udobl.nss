// see also: ud_obeliskpuzzle.nss, ud_obl_lever.nss

// Note to self: make an include for something like this next time, and avoid all the code duplication

#include "nwnx_object"

const float PUZZLE_TILE_SEPARATION = 1.0;
const float PUZZLE_LOOT_SEPARATION = 2.5;

void BeLocked()
{
    ActionCloseDoor(OBJECT_SELF);
    SetLocked(OBJECT_SELF, TRUE);
    SetLockKeyRequired(OBJECT_SELF, TRUE);
}

void main()
{
    WriteTimestampedLogEntry("Running area_ref_udobl on " + GetName(OBJECT_SELF));
    int PUZZLE_GRID_SIZE;
    int PUZZLE_MAX_FORCED;
    if (d2() == 1)
    {
        PUZZLE_GRID_SIZE = 5;
        PUZZLE_MAX_FORCED = 2;
    }
    else
    {
        PUZZLE_GRID_SIZE = 7;
        PUZZLE_MAX_FORCED = 4;
    }
    SetLocalInt(OBJECT_SELF, "PUZZLE_GRID_SIZE", PUZZLE_GRID_SIZE);
    SetLocalInt(OBJECT_SELF, "PUZZLE_MAX_FORCED", PUZZLE_MAX_FORCED);
    // Signal to the tile puzzle that we're doing setup and that it's not trap trigger time
    // nor should it trigger VFX when flipping tiles
    SetLocalInt(OBJECT_SELF, "UDObeliskInInit", 1);
    // Clear old state flags
    DeleteLocalInt(OBJECT_SELF, "UDObeliskPuzzleComplete");
    DeleteLocalInt(OBJECT_SELF, "UDObeliskTrapTriggered");
    
    // Unlock front door, relock exit
    SetLocked(GetObjectByTag("UDObeliskPuzzleEntrance"), FALSE);
    AssignCommand(GetObjectByTag("UDObeliskPuzzleProgression"), BeLocked());
    // Destroy old fog
    int i;
    for (i=1; i<=2; i++)
    {
        object oFog = GetLocalObject(OBJECT_SELF, "UDObeliskFog" + IntToString(i));
        if (GetIsObjectValid(oFog))
        {
            DestroyObject(oFog);
        }
    }
    
    // Recreate loot if it still exists
    object oLootWP = GetWaypointByTag("UDTileLootCentre");
    for (i=1; i<=4; i++)
    {
        object oLoot = GetLocalObject(OBJECT_SELF, "UDObeliskPuzzleLoot" + IntToString(i));
        if (GetIsObjectValid(oLoot))
        {
            DestroyObject(oLoot);
        }
    }
    for (i=1; i<=PUZZLE_MAX_FORCED; i++)
    {
        vector vLoc = GetPosition(oLootWP);
        float fY = (IntToFloat(i) - (IntToFloat(1+PUZZLE_MAX_FORCED)/2.0))*PUZZLE_LOOT_SEPARATION;
        location lLoc = Location(OBJECT_SELF, vLoc + Vector(0.0, fY, 0.0), GetFacing(oLootWP) + 180.0);
        object oLoot = CreateObject(OBJECT_TYPE_PLACEABLE, "treas_treasure_h", lLoc);
        SetLocalObject(OBJECT_SELF, "UDObeliskPuzzleLoot" + IntToString(i), oLoot);
        SetPlotFlag(oLoot, 1);
    }
    
    
    // Recreate lever
    DestroyObject(GetLocalObject(OBJECT_SELF, "UDObeliskLever"));
    object oLever = CreateObject(OBJECT_TYPE_PLACEABLE, "ud_obelisk_lever", GetLocation(GetWaypointByTag("UDTilePuzzleLever")));
    SetLocalObject(OBJECT_SELF, "UDObeliskLever", oLever);
    SetPlotFlag(oLever, TRUE);
    SetEventScript(oLever, EVENT_SCRIPT_PLACEABLE_ON_USED, "ud_obl_lever");
    
    object oOrigin = GetWaypointByTag("UDTilePuzzleCentre");
    vector vOrigin = GetPosition(oOrigin);
    float fFacing = GetFacing(oOrigin);
    
    // Recreate puzzle tiles
    int x;
    int y;
    
    for (x=0; x<7; x++)
    {
        for (y=0; y<7; y++)
        {
            string sVar = "UDTile" + IntToString(x) + "_" + IntToString(y);
            object oTile = GetLocalObject(OBJECT_SELF, sVar);
            if (GetIsObjectValid(oTile))
            {
                DestroyObject(oTile);
            }
        }
    }
    
    
    for (x=0; x<PUZZLE_GRID_SIZE; x++)
    {
        for (y=0; y<PUZZLE_GRID_SIZE; y++)
        {
            string sVar = "UDTile" + IntToString(x) + "_" + IntToString(y);
            float fX = (IntToFloat(x) - (IntToFloat(-1+PUZZLE_GRID_SIZE)/2.0))*PUZZLE_TILE_SEPARATION;
            float fY = (IntToFloat(y) - (IntToFloat(-1+PUZZLE_GRID_SIZE)/2.0))*PUZZLE_TILE_SEPARATION;
            location lTile = Location(OBJECT_SELF, vOrigin + Vector(fX, fY, 0.0), fFacing);
            object oTile = CreateObject(OBJECT_TYPE_PLACEABLE, "ud_puzzle_plate", lTile);
            SetLocalObject(OBJECT_SELF, sVar, oTile);
            SetLocalInt(oTile, "TileX", x);
            SetLocalInt(oTile, "TileY", y);
        }
    }
    
    // Flip some tiles!
    int nFlips = d6(2) + 11;
    for (i=0; i<nFlips; i++)
    {
        x = Random(PUZZLE_GRID_SIZE);
        y = Random(PUZZLE_GRID_SIZE);
        string sVar = "UDTile" + IntToString(x) + "_" + IntToString(y);
        object oTile = GetLocalObject(OBJECT_SELF, sVar);
        ExecuteScript("ud_obeliskpuzzle", oTile);
    }
    // Override textures on all tiles
    for (x=0; x<PUZZLE_GRID_SIZE; x++)
    {
        for (y=0; y<PUZZLE_GRID_SIZE; y++)
        {
            string sVar = "UDTile" + IntToString(x) + "_" + IntToString(y);
            object oTile = GetLocalObject(OBJECT_SELF, sVar);
            ExecuteScript("ud_obpuz_tiletex", oTile);
        }
    }
    // Puzzle is set up and ready for action!
    DeleteLocalInt(OBJECT_SELF, "UDObeliskInInit");
}
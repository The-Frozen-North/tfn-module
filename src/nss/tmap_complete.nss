#include "inc_loot"
#include "inc_persist"

void main()
{
    object oMap = OBJECT_SELF;
    object oOwner = GetItemPossessor(OBJECT_SELF);
    string sTreasureName = "Buried Treasure";
    int nPuzzleID = GetLocalInt(oMap, "puzzleid");
    location lSolution = GetPuzzleSolutionLocation(nPuzzleID);
    int nSurfacemat = GetSurfaceMaterial(lSolution);
    if (!GetIsSurfacematDiggable(nSurfacemat))
    {
        sTreasureName = "Hidden Treasure";
    }
    // Lower the real treasure by 5 units, so it is noncollidable
    // And then visual transform it back up so it looks normal
    // EffectCutsceneGhost doesn't work on placeables!
    location lSpawn = GetLocation(oOwner);
    vector vPos = GetPositionFromLocation(lSpawn);
    vPos.z -= 5.0;
    lSpawn = Location(GetArea(oOwner), vPos, GetFacing(oOwner));
    object oReward = CreateObject(OBJECT_TYPE_PLACEABLE, "treasuremap_loot", lSpawn);
    SetName(oReward, sTreasureName);
    SetObjectVisualTransform(oReward, OBJECT_VISUAL_TRANSFORM_SCALE, 0.5);
    SetObjectVisualTransform(oReward, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, 5.0);
    
    SetLocalString(oReward, "owner", GetPCPublicCDKey(oOwner));
    int nLootLevel = GetLocalInt(oMap, "acr");
    SetLocalInt(oReward, "cr", nLootLevel);
    SetLocalInt(oReward, "area_cr", nLootLevel);
    SetLocalInt(oReward, "parent_map_difficulty", GetTreasureMapDifficulty(OBJECT_SELF));
    SetPlotFlag(oReward, 1);
    AssignCommand(GetModule(), DelayCommand(280.0, SetPlotFlag(oReward, 0)));
    DestroyObject(oReward, 300.0);
    DestroyObject(OBJECT_SELF);

    IncrementPlayerStatistic(oOwner, "treasure_maps_completed");
    
    // Force a PC save. That way there is no way they can keep their map
    // and still be able to loot the chest too
    if (CanSavePCInfo(oOwner))
    {
        AssignCommand(GetModule(), DelayCommand(0.1, SavePCInfo(oOwner)));
    }
}
#include "inc_loot"
#include "inc_persist"

void main()
{
    object oMap = OBJECT_SELF;
    object oOwner = GetItemPossessor(OBJECT_SELF);
    string sTreasureName = "Buried Treasure";
    int nPuzzleID = GetPuzzleIDFromPuzzleUUID(GetLocalString(oMap, "puzzleuuid"));
    location lSolution = GetPuzzleSolutionLocation(nPuzzleID);
    int nSurfacemat = GetSurfaceMaterial(lSolution);
    if (!GetIsSurfacematDiggable(nSurfacemat))
    {
        sTreasureName = "Hidden Treasure";
    }
    
    object oReward = CreateObject(OBJECT_TYPE_PLACEABLE, "treasuremap_loot", GetLocation(oOwner));
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(EffectCutsceneGhost()), oReward);
    SetName(oReward, sTreasureName);
    SetObjectVisualTransform(oReward, OBJECT_VISUAL_TRANSFORM_SCALE, 0.5);
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
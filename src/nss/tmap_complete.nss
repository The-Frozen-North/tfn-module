#include "inc_loot"

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
    
    object oReward = CreateObject(OBJECT_TYPE_PLACEABLE, "treasuremap_loot", GetLocation(oOwner));
    SetName(oReward, sTreasureName);
    SetObjectVisualTransform(oReward, OBJECT_VISUAL_TRANSFORM_SCALE, 0.5);
    SetLocalString(oReward, "owner", GetPCPublicCDKey(oOwner));
    SetLocalInt(oReward, "cr", GetLocalInt(oMap, "acr"));
    SetLocalInt(oReward, "area_cr", GetLocalInt(oMap, "acr"));
    DestroyObject(oReward, 300.0);
    DestroyObject(OBJECT_SELF);
}
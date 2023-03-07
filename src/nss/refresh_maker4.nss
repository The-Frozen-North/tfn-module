#include "nwnx_visibility"
#include "nwnx_object"
#include "nwnx_creature"
#include "inc_debug"

const int NUM_BONEPILES = 8;
const float BONEPILE_AVOID_DISTANCE = 3.0;
const float BONEPILE_AVOID_PLACEABLE_DISTANCE = 2.0;

const int BONEPILE_NUM_BONES = 25;
const float BONEPILE_INITIAL_RADIUS = 0.6;
const float BONEPILE_HEIGHT = 1.2;
const float BONEPILE_RADIUS_CHANGE_PER_HEIGHT = -0.4;

// Return a random point on the circumference of a circle centred around vPos, with a radius of fDist
// the point will always have height fZ
vector GetPositionAroundPoint(vector vPos, float fDist, float fZ)
{
    float fBearing = IntToFloat(Random(360));
    float fX = vPos.x + (fDist * cos(fBearing));
    float fY = vPos.y + (fDist * sin(fBearing));
    return Vector(fX, fY, fZ);
}

void AddBoneToPile(object oBones, vector vPos, int nIndex, int bVisualTransform=1)
{
    location lLoc = Location(GetArea(oBones), vPos, IntToFloat(Random(360)));
    string sResRef = Random(100) < 85 ? "plc_bones" : "plc_pileskulls";
    object oNew = CreateObject(OBJECT_TYPE_PLACEABLE, sResRef, lLoc);
    SetPlotFlag(oNew, 1);
    SetLocalObject(oBones, "bonecomponent" + IntToString(nIndex), oNew);
    if (bVisualTransform)
    {
        SetObjectVisualTransform(oNew, OBJECT_VISUAL_TRANSFORM_ROTATE_X, IntToFloat(Random(50))-25.0);
        SetObjectVisualTransform(oNew, OBJECT_VISUAL_TRANSFORM_ROTATE_Y, IntToFloat(Random(50))-25.0);
    }
}

location GetNewBonepilePosition()
{
    // This is NOT waypoint driven because it's hard, but...
    // The room is a rectangle with straight line "nibbles" taken out of each corner
    // 55, 4
    // 15, 4
    // 55, 25
    // 15, 25
    
    object oArea = GetObjectByTag("ud_maker4");
    int i;
    /*
    float fXStart = 15.0;
    float fYStart = 4.0;
    float fXEnd = 55.0;
    float fYEnd = 25.0;
    float fCornerAvoidance = 4.0;
    float fXRange = fXEnd - fXStart;
    float fYRange = fYEnd - fYStart;
    
    
    object oComputeSafe;
    object oTest = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oTest))
    {
        if (GetObjectType(oTest) == OBJECT_TYPE_CREATURE && GetResRef(oTest) == "mithralgolem")
        {
            oComputeSafe = oTest;
            break;
        }
        oTest = GetNextObjectInArea(oArea);
    }
    */
    location lRet;
    
    int nAttempts = 999;
    while (1)
    {
        nAttempts--;
        if (nAttempts < 0) { break; }
        /*
        float fX = fXStart + (IntToFloat(Random(1000))/1000.0 * fXRange);
        float fY = fYStart + (IntToFloat(Random(1000))/1000.0 * fYRange);
        vector vPos = Vector(fX, fY, 0.0);
        vPos = NWNX_Creature_ComputeSafeLocation(oComputeSafe, vPos);
        fX = vPos.x;
        fY = vPos.y;
        if ((fXEnd - fX < fCornerAvoidance || fX - fXStart < fCornerAvoidance) && (fYEnd - fY < fCornerAvoidance || fY - fYStart < fCornerAvoidance))
        {
            // in a corner, don't generate
            continue;
        }
        lRet = Location(oArea, vPos, IntToFloat(Random(360)));
        */
        // I moved this to a random list of waypoints
        // Otherwise bonepiles could spawn in the entryway in front of the maker, or on his rug
        // both of these cases look a bit ridiculous for a boss fight
        
        int nNumLocs = GetLocalInt(oArea, "num_bonepile_locs");
        int nIndex = Random(nNumLocs);
        SendDebugMessage("Pick random loc " + IntToString(nIndex) + " of " + IntToString(nNumLocs));
        lRet = GetLocalLocation(oArea, "bonepile_loc"+IntToString(nIndex));
        int bBad = 0;
        // Make sure it's not too close to any other bonepiles
        for (i=1; i<=NUM_BONEPILES; i++)
        {
            object oBonepile = GetLocalObject(oArea, "maker_bonepile" + IntToString(i));
            if (GetIsObjectValid(oBonepile))
            {
                float fDist = GetDistanceBetweenLocations(lRet, GetLocation(oBonepile));
                if (fDist < BONEPILE_AVOID_DISTANCE)
                {
                    bBad = 1;
                    break;
                }
            }
        }
        
        if (bBad)
        {
            continue;
        }
        
        object oNearest = GetNearestObjectToLocation(OBJECT_TYPE_PLACEABLE, lRet);
        if (GetDistanceBetweenLocations(GetLocation(oNearest), lRet) < BONEPILE_AVOID_PLACEABLE_DISTANCE)
        {
            continue;
        }
        
        break;
    }
    return lRet;
}

void DestroyBonepile(object oParent)
{
    object oBone;
    int i = 1;
    do
    {
        oBone = GetLocalObject(oParent, "bonecomponent" + IntToString(i));
        SetPlotFlag(oBone, 0);
        DestroyObject(oBone);
        i++;
    } while (GetIsObjectValid(oBone));
    DestroyObject(oParent);
    object oSparks = GetLocalObject(oParent, "sparkvfx");
    SetPlotFlag(oSparks, 0);
    DestroyObject(oSparks);
}

void main()
{
    if (!GetLocalInt(OBJECT_SELF, "num_bonepile_locs"))
    {
        int n = 0;
        object oTest = GetFirstObjectInArea(OBJECT_SELF);
        while (GetIsObjectValid(oTest))
        {
            if (GetTag(oTest) == "maker4_bonepile")
            {
                SetLocalLocation(OBJECT_SELF, "bonepile_loc" + IntToString(n), GetLocation(oTest));
                DestroyObject(oTest);
                n++;
            }
            oTest = GetNextObjectInArea(OBJECT_SELF);
        }
        SetLocalInt(OBJECT_SELF, "num_bonepile_locs", n);
    }
    
    // Make keeper not hidden
    object oKeeper = GetObjectByTag("maker4_keeper");
    NWNX_Visibility_SetVisibilityOverride(OBJECT_INVALID, oKeeper, NWNX_VISIBILITY_DEFAULT);
    
    // Despawn any sling/bullets left on the floor
    object oSling = GetLocalObject(OBJECT_SELF, "puzzle_sling");
    if (GetIsObjectValid(oSling) && GetAreaFromLocation(GetLocation(oSling)) == OBJECT_SELF && !GetIsObjectValid(GetItemPossessor(oSling)))
    {
        DestroyObject(oSling);
    }
    object oBullets = GetLocalObject(OBJECT_SELF, "puzzle_bullets");
    if (GetIsObjectValid(oBullets) && GetAreaFromLocation(GetLocation(oBullets)) == OBJECT_SELF && !GetIsObjectValid(GetItemPossessor(oBullets)))
    {
        DestroyObject(oBullets);
    }
    
    // Reset trap/mirrors
    DeleteLocalInt(OBJECT_SELF, "trap_fired");
    DeleteLocalInt(OBJECT_SELF, "trap_active");
    DeleteLocalInt(OBJECT_SELF, "trap_charge");
    int i;
    for (i=1; i<=4; i++)
    {
        DeleteLocalInt(OBJECT_SELF, "hitmirror" + IntToString(i));
        object oMirror = GetLocalObject(OBJECT_SELF, "mirror" + IntToString(i));
        SetPlotFlag(oMirror, 0);
        DestroyObject(oMirror);
        object oWP = GetWaypointByTag("maker4_spawnmirror" + IntToString(i));
        location lMirror = GetLocation(oWP);
        // mirrors face backwards, for reasons beyond me
        lMirror = Location(OBJECT_SELF, GetPositionFromLocation(lMirror), GetFacingFromLocation(lMirror) + 180.0);
        oMirror = CreateObject(OBJECT_TYPE_PLACEABLE, "x2_plc_mirror_lg", lMirror, FALSE, "maker4_mirror"+IntToString(i));
        NWNX_Object_SetPlaceableIsStatic(oMirror, FALSE);
        NWNX_Object_SetMaxHitPoints(oMirror, 10000);
        NWNX_Object_SetCurrentHitPoints(oMirror, 10000);
        SetUseableFlag(oMirror, 1);
        SetEventScript(oMirror, EVENT_SCRIPT_PLACEABLE_ON_DAMAGED, "maker4_mirrdmg");
        SetLocalObject(OBJECT_SELF, "mirror" + IntToString(i), oMirror);
        SetLocalInt(oMirror, "mirror_index", i);
    }
    
    // Despawn exit portal
    object oPortal = GetLocalObject(OBJECT_SELF, "exit_portal");
    if (GetIsObjectValid(oPortal))
    {
        SetPlotFlag(oPortal, 0);
        DestroyObject(oPortal);
    }
    
    // The maker animation script reads this variable, should mean this constant changes everything nicely
    SetLocalInt(OBJECT_SELF, "num_bonepiles", NUM_BONEPILES);
    // Respawn demilich bones.
    for (i=1; i<=NUM_BONEPILES; i++)
    {
        object oBones = GetLocalObject(OBJECT_SELF, "maker_bonepile" + IntToString(i));
        SetPlotFlag(oBones, 0);
        DestroyBonepile(oBones);
        DeleteLocalObject(OBJECT_SELF, "maker_bonepile" + IntToString(i));
        location lLoc = GetNewBonepilePosition();
        oBones = CreateObject(OBJECT_TYPE_PLACEABLE, "tm_pl_invbarrier", lLoc);
        SetObjectVisualTransform(oBones, OBJECT_VISUAL_TRANSFORM_SCALE, 0.01);
        // Unfortunately this placeable projects a square shadow, but stuffing it under the floor seems to hide that
        SetObjectVisualTransform(oBones, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, -5.0);
        SetLocalObject(OBJECT_SELF, "maker_bonepile" + IntToString(i), oBones);
        SetPlotFlag(oBones, 1);
        vector vPos = GetPositionFromLocation(lLoc);
        int nBoneIndex=1;
        // Some extras at the bottom
        for (nBoneIndex=1; nBoneIndex<=4; nBoneIndex++)
        {
            AddBoneToPile(oBones, GetPositionAroundPoint(vPos, BONEPILE_INITIAL_RADIUS, 0.0), nBoneIndex, 0);
        }
        // Gradually go up, but diminish random offsets as Z goes up
        float fZ = 0.0;
        float fZStep = (BONEPILE_HEIGHT / (BONEPILE_NUM_BONES-nBoneIndex))/2.0;
        // Need more bones at the bottom and fewer at the top
        float fZStepStep = fZStep/8.0;
        while (nBoneIndex <= BONEPILE_NUM_BONES)
        {
            float fRadius = BONEPILE_INITIAL_RADIUS + BONEPILE_RADIUS_CHANGE_PER_HEIGHT*fZ;
            AddBoneToPile(oBones, GetPositionAroundPoint(vPos, fRadius, fZ), nBoneIndex);
            fZ += fZStep;
            fZStep += fZStepStep;
            nBoneIndex++;
        }
        
        //object oSparks = CreateObject(OBJECT_TYPE_PLACEABLE, "plc_solpurple", lLoc);
        object oSparks = CreateObject(OBJECT_TYPE_PLACEABLE, "plc_magicpurple", lLoc);
        SetPlotFlag(oSparks, 1);
        //SetObjectVisualTransform(oSparks, OBJECT_VISUAL_TRANSFORM_SCALE, 0.5);
        SetObjectVisualTransform(oSparks, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, -2.3);
        SetLocalObject(oBones, "sparkvfx", oSparks);
    }
    
    // Remove old maker bone golems
    json jGolems = GetLocalJson(OBJECT_SELF, "maker_golems");
    int nLength = JsonGetLength(jGolems);
    for (i=0; i<nLength; i++)
    {
        object oGolem = StringToObject(JsonGetString(JsonArrayGet(jGolems, i)));
        DestroyObject(oGolem);
    }
    // Set up a new empty array for the maker to fill
    SetLocalJson(OBJECT_SELF, "maker_golems", JsonArray());
    
    // Remove boss loot chests
    json jChests = GetLocalJson(OBJECT_SELF, "maker_loot");
    nLength = JsonGetLength(jChests);
    for (i=0; i<nLength; i++)
    {
        object oGolem = StringToObject(JsonGetString(JsonArrayGet(jChests, i)));
        SetPlotFlag(oGolem, 0);
        DestroyObject(oGolem);
    }
    DeleteLocalJson(OBJECT_SELF, "maker_loot");
    
}
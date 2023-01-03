// Include for prettifying system
// This is intended to place "boring" placeables all over areas, such as rocks, flowers, dirt, moss, puddles, etc.
// It needs configuring carefully on a per-area basis and is NOT a replacement for sensible placement of salient area features.
#include "x0_i0_position"
#include "nwnx_object"
#include "nwnx_util"


struct PrettifyPlaceableSettings
{
    // Placeable resref
    string sResRef;
    // How many spawns for this placeable per 25 toolset tiles (so a 5x5 square) on average...
    // Assuming that this placeable is eligible to be spawned in any location on these 25 imaginary tiles
    int nTargetDensity;
    // Minimum and maximum scale transform to apply to the placeable. Distribution is linear.
    // THIS DOESN'T WORK. Not removing from the structure to avoid breaking scripts that use it
    float fMinScale;
    float fMaxScale;
    // This placeable will not be placed within this distance of any other placeables
    float fAvoidPlaceableRadius;
    // Same thing, for doors
    float fAvoidDoorRadius;
    // The maximum floor surface gradient allowed to place this placeable.
    // Many placeables look stupid when put on too steep hills
    // If set to 0.0, is not checked - to get really flat land, use some very small positive number instead
    float fMaximumGroundSlope;
    // "Surface" refers to either a surfacemat.2da row or combination of SURFACEMAT_ABSTRACT_* flags
    // These are used to match sampled terrain to test whether the placeable can spawn here
    // Using surfacemat.2da indexes will match that terrain type, the abstract flags offer some form of wildcarding.
    // For ValidSurfaces, ANY match is enough to make the proposed surface type valid.
    // For AvoidSurfaces, ANY match is enough to make the surface type invalid
    int nValidSurface1;
    int nValidSurface2;
    int nValidSurface3;
    int nAvoidSurface1;
    int nAvoidSurface2;
    int nAvoidSurface3;
    
    // This allows targeting placeables to borders, or making them avoid borders between certain terrains.
    int nBorder1Surface1;
    int nBorder1Surface2;
    // This should be either PRETTIFY_INFLUENCE_TYPE_REQUIRED or PRETTIFY_INFLUENCE_TYPE_FORBIDDEN
    // for requiring this border nearby or forbidding it
    int nBorder1InfluenceType;
    float fBorder1Radius;
    
    int nBorder2Surface1;
    int nBorder2Surface2;
    int nBorder2InfluenceType;
    float fBorder2Radius;
    
    // Textures to replace on the placeable.
    // I missed that this doesn't work on static placeables. :(
    //string sReplaceTexture1From;
    //string sReplaceTexture1To;
    //string sReplaceTexture2From;
    //string sReplaceTexture2To;
    //string sReplaceTexture3From;
    //string sReplaceTexture3To;
};

// Set these bitflags for terrains to instead set "abstract" terrains, IE to make a placeable valid on any walkable terrain
// Of these flags, all of them must be met to be valid
// This means that making never-valid combinations is possible, as for instance a surface material cannot be both
// walkable and nonwalkable...
const int SURFACEMAT_ABSTRACT_WALKABLE = 1024;
const int SURFACEMAT_ABSTRACT_NOTWALKABLE = 2048;
const int SURFACEMAT_ABSTRACT_LINEOFSIGHT = 4096;
const int SURFACEMAT_ABSTRACT_NOLINEOFSIGHT = 8192;
const int SURFACEMAT_ABSTRACT_WATER = 16384;
const int SURFACEMAT_ABSTRACT_NOTWATER = 32768;
// special flag that will match any surface material type no matter what
const int SURFACEMAT_ABSTRACT_ALL = 65536;
// Never valid, ever.
const int SURFACEMAT_INVALID = -1;

// This is the contents of surfacemat.2da

// This is most "walls"
const int SURFACEMAT_UNDEFINED = 0;
const int SURFACEMAT_DIRT = 1;
const int SURFACEMAT_OBSCURING = 2;
const int SURFACEMAT_GRASS = 3;
const int SURFACEMAT_STONE = 4;
const int SURFACEMAT_WOOD = 5;
// Walkable water
const int SURFACEMAT_WATER = 6;
const int SURFACEMAT_NONWALK = 7;
const int SURFACEMAT_TRANSPARENT = 8;
const int SURFACEMAT_CARPET = 9;
const int SURFACEMAT_METAL = 10;
const int SURFACEMAT_PUDDLES = 11;
const int SURFACEMAT_SWAMP = 12;
const int SURFACEMAT_MUD = 13;
const int SURFACEMAT_LEAVES = 14;
const int SURFACEMAT_LAVA = 15;
const int SURFACEMAT_BOTTOMLESSPIT = 16;
const int SURFACEMAT_DEEPWATER = 17;
const int SURFACEMAT_DOOR = 18;
const int SURFACEMAT_SNOW = 19;
const int SURFACEMAT_SAND = 20;
const int SURFACEMAT_BAREBONES = 21;
const int SURFACEMAT_STONEBRIDGE = 22;


// The scanning step for detecting surface material boundaries
const float PRETTIFY_AREA_BOUNDARY_SCAN_STEP = 0.4;
// When looking for boundaries, the full 360 degrees is split up into this many linear lines
// IE: a value of 4 will check along the cardinal directions only, a value of 8 will check NE, SE, SW, NW as well
const int PRETTIFY_AREA_BOUNDARY_SCAN_NUM_LINES = 10;

// For usage, see comments in the PrettifyPlaceableSettings struct
const int PRETTIFY_INFLUENCE_TYPE_REQUIRED = 1;
const int PRETTIFY_INFLUENCE_TYPE_FORBIDDEN = 2;

// Run the given PrettifyPlaceableSettings on the specified area.
// THIS SHOULD ONLY BE DONE DURING SEEDING.
// The result is saved directly to database.
void PlacePrettifyPlaceable(struct PrettifyPlaceableSettings pps, object oArea);

// Parse the database and create all the placeables that were precalculated in every area.
void LoadAllPrettifyPlaceables();

// Destroy the DB table for oArea. Run before reseeding or this will just add to the old DB
// resulting in placeable overload
void ClearPrettifyPlaceableDBForArea(object oArea);

// Returns a PrettifyPlaceableSettings with sensible defaults.
struct PrettifyPlaceableSettings GetDefaultPrettifySettings();

/////////////////////////////
// INTERNAL STUFF

// Return TRUE if nSurfacemat (row from surfacemat.2da) is matched by nCriteria
// nCriteria can either be a literal surfacemat.2da index, or some combination of SURFACEMAT_ABSTRACT_* flags
int SurfacematMatchesCriteria(int nSurfacemat, int nCriteria);

int CanPrettifiedPlaceableBePlacedAtLocation(struct PrettifyPlaceableSettings pps, location lLoc);

void WritePrettifiedPlaceableLocationToDB(struct PrettifyPlaceableSettings pps, location lLoc);

const int PRETTIFY_DEBUG = 1;

// If PRETTIFY_DEBUG, write sMes to the log
void PrettifyDebug(string sMes);


/////////////////////////////

void PrettifyDebug(string sMes)
{
    if (PRETTIFY_DEBUG)
    {
        WriteTimestampedLogEntry("Prettify: " + sMes);
    }
}

struct PrettifyPlaceableSettings GetDefaultPrettifySettings()
{
    struct PrettifyPlaceableSettings pps;
    pps.fMinScale = 1.0;
    pps.fMaxScale = 1.0;
    pps.nTargetDensity = 25;
    pps.fMaximumGroundSlope = 0.0;
    pps.nValidSurface1 = -1;
    pps.nValidSurface2 = -1;
    pps.nValidSurface3 = -1;
    pps.nAvoidSurface1 = -1;
    pps.nAvoidSurface2 = -1;
    pps.nAvoidSurface3 = -1;
    pps.nBorder1Surface1 = -1;
    pps.nBorder1Surface2 = -1;
    pps.nBorder2Surface1 = -1;
    pps.nBorder2Surface2 = -1;
    return pps;
}

int SurfacematMatchesCriteria(int nSurfacemat, int nCriteria)
{
    if (nCriteria == SURFACEMAT_INVALID) { return 0; }
    if (nSurfacemat == nCriteria) { return 1; }
    if (nCriteria < SURFACEMAT_ABSTRACT_WALKABLE) { return 0; }
    if (nCriteria & SURFACEMAT_ABSTRACT_ALL) { return 1; }
    int bValid = 1;
    int nWalkable = StringToInt(Get2DAString("surfacemat", "Walk", nSurfacemat));
    int nLOS = StringToInt(Get2DAString("surfacemat", "LineOfSight", nSurfacemat));
    int nWater = StringToInt(Get2DAString("surfacemat", "IsWater", nSurfacemat));
    if (nCriteria & SURFACEMAT_ABSTRACT_WALKABLE && !nWalkable) { bValid = 0; }
    else if (nCriteria & SURFACEMAT_ABSTRACT_LINEOFSIGHT && !nLOS) { bValid = 0; }
    else if (nCriteria & SURFACEMAT_ABSTRACT_WATER && !nWater) { bValid = 0; }
    
    else if (nCriteria & SURFACEMAT_ABSTRACT_NOTWALKABLE && nWalkable) { bValid = 0; }
    else if (nCriteria & SURFACEMAT_ABSTRACT_NOLINEOFSIGHT && nLOS) { bValid = 0; }
    else if (nCriteria & SURFACEMAT_ABSTRACT_NOTWATER && nWater) { bValid = 0; }
    
    return bValid;
}

void PlacePrettifyPlaceable(struct PrettifyPlaceableSettings pps, object oArea)
{
    int nWidth = GetAreaSize(AREA_WIDTH, oArea);
    int nHeight = GetAreaSize(AREA_HEIGHT, oArea);
    float fRealWidth = 10.0 * IntToFloat(nWidth);
    float fRealHeight = 10.0 * IntToFloat(nHeight);
    int nAreaTiles = nWidth * nHeight;
    int nSpawnAttempts = (pps.nTargetDensity * nAreaTiles) / 25;
    int i;
    int nCount = 0;
    for (i=0; i<nSpawnAttempts; i++)
    {
        int nWidthRoll = Random(100000);
        int nHeightRoll = Random(100000);
        float fX = IntToFloat(nWidthRoll)/100000.0 * fRealWidth;
        float fY = IntToFloat(nHeightRoll)/100000.0 * fRealHeight;
        location lTest = Location(oArea, Vector(fX, fY, 0.0), 0.0);
        float fZ = GetGroundHeight(lTest);
        lTest = Location(oArea, Vector(fX, fY, fZ), IntToFloat(Random(360)));
        if (CanPrettifiedPlaceableBePlacedAtLocation(pps, lTest))
        {
            WritePrettifiedPlaceableLocationToDB(pps, lTest);
            nCount++;
        }
    }
    PrettifyDebug("Placed " + IntToString(nCount) + " instances of " + pps.sResRef + " in " + IntToString(nSpawnAttempts) + " spawn attempts");
}

int CanPrettifiedPlaceableBePlacedAtLocation(struct PrettifyPlaceableSettings pps, location lLoc)
{
    int nSurfacemat = GetSurfaceMaterial(lLoc);
    // One or more of the valid surfaces needs to be valid
    if (SurfacematMatchesCriteria(nSurfacemat, pps.nValidSurface1) || SurfacematMatchesCriteria(nSurfacemat, pps.nValidSurface2) || SurfacematMatchesCriteria(nSurfacemat, pps.nValidSurface3))
    {
        // None of the avoids can be valid
        if (SurfacematMatchesCriteria(nSurfacemat, pps.nAvoidSurface1) || SurfacematMatchesCriteria(nSurfacemat, pps.nAvoidSurface2) || SurfacematMatchesCriteria(nSurfacemat, pps.nAvoidSurface3))
        {
            //PrettifyDebug("Can't place " + pps.sResRef + " on surface " + IntToString(nSurfacemat) + ": one of the banned surface types");
            return 0;
        }
        // Check fAvoidPlaceableRadius
        if (pps.fAvoidPlaceableRadius > 0.0)
        {
            object oNearest = GetNearestObjectToLocation(OBJECT_TYPE_PLACEABLE, lLoc, 1);
            if (GetIsObjectValid(oNearest) && GetDistanceBetweenLocations(lLoc, GetLocation(oNearest)) <= pps.fAvoidPlaceableRadius)
            {
                //PrettifyDebug("Can't place " + pps.sResRef + " on surface " + IntToString(nSurfacemat) + ": too close to existing placeable " + GetName(oNearest));
                return 0;
            }
        }
        
        // Check fAvoidDoorRadius
        if (pps.fAvoidDoorRadius > 0.0)
        {
            object oNearest = GetNearestObjectToLocation(OBJECT_TYPE_DOOR, lLoc, 1);
            if (GetIsObjectValid(oNearest) && GetDistanceBetweenLocations(lLoc, GetLocation(oNearest)) <= pps.fAvoidPlaceableRadius)
            {
                //PrettifyDebug("Can't place " + pps.sResRef + " on surface " + IntToString(nSurfacemat) + ": too close to door " + GetName(oNearest));
                return 0;
            }
        }
        
        // Check borders.
        vector vLoc = GetPositionFromLocation(lLoc);
        object oArea = GetAreaFromLocation(lLoc);
        int nBorderCheckIndex;
        for (nBorderCheckIndex=1; nBorderCheckIndex<=2; nBorderCheckIndex++)
        {
            int nBorderSurface1;
            int nBorderSurface2;
            int nBorderInfluenceType;
            float fBorderRadius;
            if (nBorderCheckIndex == 1)
            {
                nBorderSurface1 = pps.nBorder1Surface1;
                nBorderSurface2 = pps.nBorder1Surface2;
                nBorderInfluenceType = pps.nBorder1InfluenceType;
                fBorderRadius = pps.fBorder1Radius;
            }
            else if (nBorderCheckIndex == 2)
            {
                nBorderSurface1 = pps.nBorder2Surface1;
                nBorderSurface2 = pps.nBorder2Surface2;
                nBorderInfluenceType = pps.nBorder2InfluenceType;
                fBorderRadius = pps.fBorder2Radius;
            }
            
            // Skip if border surfaces are not set
            if (nBorderSurface1 < 0 || nBorderSurface2 < 0)
            {
                continue;
            }
            
            int bBorderFound = 0;
            
            float fDegIncrement = 360.0/PRETTIFY_AREA_BOUNDARY_SCAN_NUM_LINES;
            int nRayIndex;
            //PrettifyDebug("Origin = " + LocationToString(lLoc) + ", deg increment = " + FloatToString(fDegIncrement));
            for (nRayIndex=0; nRayIndex<PRETTIFY_AREA_BOUNDARY_SCAN_NUM_LINES; nRayIndex++)
            {
                // This is essentially rotating (0, PRETTIFY_AREA_BOUNDARY_SCAN_STEP) about the origin by (fDegIncrement * nRayIndex) degrees
                // The typical rotation formula simplifies down when one of the coordinates is guaranteed to be zero
                float fXScanIncrement = -1.0 * sin(fDegIncrement * nRayIndex) * PRETTIFY_AREA_BOUNDARY_SCAN_STEP;
                float fYScanIncrement = cos(fDegIncrement * nRayIndex) * PRETTIFY_AREA_BOUNDARY_SCAN_STEP;
                int nNumScanIncrements = FloatToInt(fBorderRadius/PRETTIFY_AREA_BOUNDARY_SCAN_STEP);
                if (nNumScanIncrements < 1) { nNumScanIncrements = 1; }
                //PrettifyDebug("Scan increments: " + FloatToString(fXScanIncrement) + FloatToString(fYScanIncrement));
                int nScanIndex;
                for (nScanIndex=1; nScanIndex<=nNumScanIncrements; nScanIndex++)
                {
                    location lScan = Location(oArea, Vector(vLoc.x + (nScanIndex * fXScanIncrement), vLoc.y + (nScanIndex * fYScanIncrement), vLoc.z), 0.0);
                    int nTestSurfacemat = GetSurfaceMaterial(lScan);
                    //PrettifyDebug("Scan location: " + LocationToString(lScan));
                    if (nTestSurfacemat != nSurfacemat)
                    {
                        // Both surface criteria need to find something they like
                        // It is necessary to test them both ways round, though.
                        if ((SurfacematMatchesCriteria(nSurfacemat, nBorderSurface1) && SurfacematMatchesCriteria(nTestSurfacemat, nBorderSurface2)) || (SurfacematMatchesCriteria(nSurfacemat, nBorderSurface2) && SurfacematMatchesCriteria(nTestSurfacemat, nBorderSurface1)))
                        {
                            //PrettifyDebug("Surface is different and border is valid - " + IntToString(nSurfacemat) + " vs " + IntToString(nTestSurfacemat));
                            bBorderFound = 1;
                            break;
                        }
                    }
                }
                if (bBorderFound)
                {
                    break;
                }
            }
            if (bBorderFound)
            {
                if (nBorderInfluenceType == PRETTIFY_INFLUENCE_TYPE_FORBIDDEN)
                {
                    //PrettifyDebug("Can't place " + pps.sResRef + ": forbidden border found");
                    return 0;
                }
            }
            else
            {
                if (nBorderInfluenceType == PRETTIFY_INFLUENCE_TYPE_REQUIRED)
                {
                    //PrettifyDebug("Can't place " + pps.sResRef + ": required border absent");
                    return 0;
                }
            }
        }
        
        // Check ground gradient
        if (pps.fMaximumGroundSlope > 0.0)
        {
            float fLocHeight = GetGroundHeight(lLoc);
            float fDegIncrement = 360.0/PRETTIFY_AREA_BOUNDARY_SCAN_NUM_LINES;
            int nRayIndex;
            for (nRayIndex=0; nRayIndex<PRETTIFY_AREA_BOUNDARY_SCAN_NUM_LINES; nRayIndex++)
            {
                // This is essentially rotating (0, PRETTIFY_AREA_BOUNDARY_SCAN_STEP) about the origin by (fDegIncrement * nRayIndex) degrees
                // The typical rotation formula simplifies down when one of the coordinates is guaranteed to be zero
                float fXScanIncrement = -1.0 * sin(fDegIncrement * nRayIndex) * PRETTIFY_AREA_BOUNDARY_SCAN_STEP;
                float fYScanIncrement = cos(fDegIncrement * nRayIndex) * PRETTIFY_AREA_BOUNDARY_SCAN_STEP;
                location lScan = Location(oArea, Vector(vLoc.x + fXScanIncrement, vLoc.y + fYScanIncrement, vLoc.z), 0.0);
                float fTestHeight = GetGroundHeight(lScan);
                float fGradient = (1.0/PRETTIFY_AREA_BOUNDARY_SCAN_STEP) * (fTestHeight - fLocHeight);
                if (fGradient < 0.0) { fGradient *= -1.0; }
                if (fGradient > pps.fMaximumGroundSlope)
                {
                    //PrettifyDebug("Can't place " + pps.sResRef + ": ground gradient too steep");
                    return 0;
                }
            }
        }
        //PrettifyDebug("Can place " + pps.sResRef + "!");
        return 1;
    }
    //PrettifyDebug("Can't place " + pps.sResRef + " on surface " + IntToString(nSurfacemat) + ": not one of the valid surface types");
    return 0;
}

void ClearPrettifyPlaceableDBForArea(object oArea)
{
    string sArea = GetTag(oArea);
    sqlquery sql = SqlPrepareQueryCampaign("prettify", "DELETE FROM placeables WHERE areatag = @tag");
    SqlBindString(sql, "@tag", sArea);
    SqlStep(sql);
}

void WritePrettifiedPlaceableLocationToDB(struct PrettifyPlaceableSettings pps, location lLoc)
{    
    sqlquery sql = SqlPrepareQueryCampaign("prettify",
        "CREATE TABLE IF NOT EXISTS placeables (" +
        "resref TEXT, " +
        "areatag TEXT, " +
        "position TEXT, " +
        "facing INTEGER, " +
        "scale REAL, " +
        "replacetexture1 TEXT, " +
        "replacetexture1to TEXT, " +
        "replacetexture2 TEXT, " +
        "replacetexture2to TEXT, " +
        "replacetexture3 TEXT, " +
        "replacetexture3to TEXT" +
        ");");
    SqlStep(sql);
    
    object oArea = GetAreaFromLocation(lLoc);
    float fScaleDeviation = pps.fMaxScale - pps.fMinScale;
    float fScale = (IntToFloat(Random(101))/100.0 * fScaleDeviation) + pps.fMinScale;
    int nFacing = Random(360);
    vector vPosition = GetPositionFromLocation(lLoc);
    string sAreaTag = GetTag(oArea);
    sql = SqlPrepareQueryCampaign("prettify",
        "INSERT INTO placeables " +
        "(resref, areatag, position, facing, scale, replacetexture1, replacetexture1to, " +
        "replacetexture2, replacetexture2to, replacetexture3, replacetexture3to) " +
        "VALUES (@resref, @areatag, @position, @facing, @scale, @replacetexture1, @replacetexture1to, " +
        "@replacetexture2, @replacetexture2to, @replacetexture3, @replacetexture3to);");
    SqlBindString(sql, "@resref", pps.sResRef);
    SqlBindString(sql, "@areatag", sAreaTag);
    SqlBindVector(sql, "@position", vPosition);
    SqlBindInt(sql, "@facing", nFacing);
    //SqlBindFloat(sql, "@scale", fScale);
    //SqlBindString(sql, "@replacetexture1", pps.sReplaceTexture1From);
    //SqlBindString(sql, "@replacetexture1to", pps.sReplaceTexture1To);
    //SqlBindString(sql, "@replacetexture2", pps.sReplaceTexture2From);
    //SqlBindString(sql, "@replacetexture2to", pps.sReplaceTexture2To);
    //SqlBindString(sql, "@replacetexture3", pps.sReplaceTexture3From);
    //SqlBindString(sql, "@replacetexture3to", pps.sReplaceTexture3To);
    SqlStep(sql);
    
    // Create the placeable, so that future spawning attempts respect fAvoidPlaceableRadius
    // As we are seeding, there should be no need to get involved in scale, facing or texture replacement
    CreateObject(OBJECT_TYPE_PLACEABLE, pps.sResRef, lLoc);
}

void LoadAllPrettifyPlaceables()
{
    NWNX_Util_SetInstructionsExecuted(0);
    // Grab everything except rowid. I don't need that in here
    sqlquery sql = SqlPrepareQueryCampaign("prettify", "SELECT " +
    "resref, areatag, position, facing, scale, replacetexture1, replacetexture1to, " +
    "replacetexture2, replacetexture2to, replacetexture3, replacetexture3to " +
    "FROM placeables;");
    int nCount = 0;
    WriteTimestampedLogEntry("Started creating prettify placeables.");
    while (SqlStep(sql))
    {
        // TMI here would just be sad
        NWNX_Util_SetInstructionsExecuted(0);
        string sResRef = SqlGetString(sql, 0);
        string sAreaTag = SqlGetString(sql, 1);
        vector vPosition = SqlGetVector(sql, 2);
        int nFacing = SqlGetInt(sql, 3);
        float fScale = SqlGetFloat(sql, 4);
        string sReplaceTexture1From = SqlGetString(sql, 5);
        string sReplaceTexture1To = SqlGetString(sql, 6);
        string sReplaceTexture2From = SqlGetString(sql, 7);
        string sReplaceTexture2To = SqlGetString(sql, 8);
        string sReplaceTexture3From = SqlGetString(sql, 9);
        string sReplaceTexture3To = SqlGetString(sql, 10);
        object oArea = GetObjectByTag(sAreaTag);
        // Testing code: remove to make this really work on all areas
        // Running this via NWScript debug window should have OBJECT_SELF as something other than the module and should therefore create placeables in the other areas
        //if (OBJECT_SELF == GetModule() ^ (sAreaTag == "nw_northroad" || sAreaTag == "ud_east"))
        //{
        //    continue;
        //}
        location lLoc = Location(oArea, vPosition, IntToFloat(nFacing));
        object oPlaceable = CreateObject(OBJECT_TYPE_PLACEABLE, sResRef, lLoc);
        if (!GetIsObjectValid(oPlaceable))
        {
            WriteTimestampedLogEntry("Warning: prettify tried to create a placeable using resref " + sResRef + " but nothing was produced");
            continue;
        }
        SetObjectVisualTransform(oPlaceable, OBJECT_VISUAL_TRANSFORM_SCALE, fScale);
        NWNX_Object_SetPlaceableIsStatic(oPlaceable, 0);
        if (sReplaceTexture1From != "")
        {
            //PrettifyDebug(GetName(oPlaceable) + ": replace texture " + sReplaceTexture1From + " to " + sReplaceTexture1To);
            ReplaceObjectTexture(oPlaceable, sReplaceTexture1From, sReplaceTexture1To);
        }
        if (sReplaceTexture2From != "") { ReplaceObjectTexture(oPlaceable, sReplaceTexture2From, sReplaceTexture2To); }
        if (sReplaceTexture3From != "") { ReplaceObjectTexture(oPlaceable, sReplaceTexture3From, sReplaceTexture3To); }
        SetPlotFlag(oPlaceable, 1);
        NWNX_Object_SetPlaceableIsStatic(oPlaceable, 1);
        nCount++;
    }
    WriteTimestampedLogEntry("Prettify created " + IntToString(nCount) + " placeables.");
}

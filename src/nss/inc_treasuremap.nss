#include "nwnx_area"
#include "nwnx_util"
#include "nwnx_item"
#include "nw_inc_nui"
#include "inc_persist"
#include "inc_prettify"
#include "inc_areadist"

// Include for treasure maps and various functions for interacting with them.

// There are a seeded set of "puzzles" each with their own ID.
// One puzzle ID has one solution location, but has different map data depending on the "difficulty"
// of the map (which is the Area CR of where it was generated).
// Higher ACR versions of the map are more "zoomed in" and display less of the surrounding area.

// A random treasure map cannot send you to an area of higher ACR than where it was obtained.
// Not only do the harder maps have less info on, the number of areas accessible increases dramatically.

// Treasure maps are apparently always squares of this many pixels
const int TREASUREMAP_WINDOW_DIMENSIONS = 400;
// 0-255, opacity of map feature colours to draw on base texture
// If fill is ever fixed, something around the 60-80 mark is likely a better value
const int TREASUREMAP_OVERLAY_OPACITY = 150;

// Minimum/maximum ACR ranges maps to seed for.
const int TREASUREMAP_ACR_MIN = 3;
const int TREASUREMAP_ACR_MAX = 15;

// An eligible area will have ((width in tiles * height in tiles) * this number) of possible map locations made for it.
// At least 1 location will be made for any eligible area.
const float TREASUREMAP_SEED_DENSITY = 0.025;
// 0.025/4
//const float TREASUREMAP_SEED_DENSITY = 0.00625;
// One per map, for testing
//const float TREASUREMAP_SEED_DENSITY = 0.00000001;

// How close you have to get to the true location to count as getting your treasure.
const float TREASUREMAP_LOCATION_TOLERANCE = 5.0;


// Chance for treasure map solution location to be completely random instead of somewhere near
// where you found the map
const int TREASUREMAP_CHANCE_FOR_RANDOM_LOCATION = 15;

// When picking a nearby map, the range that is considered close starts at this value...
const int TREASUREMAP_NEARBY_START_DISTANCE = 1000;
// And then it might be increased by this much...
const int TREASUREMAP_START_DISTANCE_INCREASE_AMOUNT = 333;
// And there's this chance to keep stacking them on top of each other
// (keep increasing until you fail this check)
const int TREASUREMAP_START_DISTANCE_INCREASE_CHANCE = 70;

const int TREASUREMAP_DIFFICULTY_EASY = 1;
const int TREASUREMAP_DIFFICULTY_MEDIUM = 2;
const int TREASUREMAP_DIFFICULTY_HARD = 3;
const int TREASUREMAP_DIFFICULTY_MASTER = 4;
const int TREASUREMAP_HIGHEST_DIFFICULTY = 4;

// What proportion of mapped edge dimensions is omitted at each difficulty
// Because the area removed is effectively this squared, it starts getting increasingly nasty
const float TREASUREMAP_PROPORTION_DISTANCE_REMOVED_EASY = 0.1;
const float TREASUREMAP_PROPORTION_DISTANCE_REMOVED_MEDIUM = 0.27;
const float TREASUREMAP_PROPORTION_DISTANCE_REMOVED_HARD = 0.4;
const float TREASUREMAP_PROPORTION_DISTANCE_REMOVED_MASTER = 0.54;

// The way loot works:
// All maps are guaranteed 1 boss roll
// They have 2d2 rolls total, after their first roll they roll to avoid getting downgraded to semiboss loot
// for the rest of their 2d2 rolls.
const int TREASUREMAP_REWARD_DOWNGRADE_EASY = 93;
const int TREASUREMAP_REWARD_DOWNGRADE_MEDIUM = 81;
const int TREASUREMAP_REWARD_DOWNGRADE_HARD = 64;
const int TREASUREMAP_REWARD_DOWNGRADE_MASTER = 42;

// Items without item properties or with a value < 200 get turned into pure gold.
// This sets the percentage of the item's value that is turned into gold
const int TREASUREMAP_MUNDANE_ITEM_GOLD_CONVERSION_RATE = 80;

// Set a local int on an area with any positive nonzero value to make treasuremap destinations not be generated there
const string DISABLE_TREASUREMAPS_FOR_AREA = "notreasuremaps";
// Set a local int on an area to include it in treasure maps regardless of its natural/artifical status
const string ENABLE_TREASUREMAPS_FOR_AREA = "treasuremaps";

// Area string var: if set, this text will be overlayed on the bottom left corner of maps
// (this is used to make the underdark areas completable, having to search the WHOLE UD is virtually impossible)
const string TREASUREMAP_AREA_TEXT = "treasuremaptext";

const string TREASUREMAP_AVOID_WP = "TreasureMapAvoid15m";
const float TREASUREMAP_AVOID_WP_RADIUS = 15.0;

// Parameters for X marks the spot
const float TREASUREMAP_X_LENGTH = 20.0;
const float TREASUREMAP_X_WIDTH = 4.0;


// Probability of generating a treasure map.
// The actual probability is this value/1000, IE this value is in tenths of percent, 5 = 5/1000 = 0.5% = 1/200.
//const int TREASURE_MAP_CHANCE = 500; // testing, it's really high but not guaranteed
const int TREASURE_MAP_CHANCE = 4; // 0.4%

const int TREASURE_MAP_BOSS_MULTIPLIER = 25; // 10%
const int TREASURE_MAP_SEMIBOSS_MULTIPLIER = 10; // 4%

// Float variable set on area: Probability of a treasure map is multiplied by this value
const string AREA_TREASURE_MAP_MULTIPLIER = "treasuremap_multiplier";

// Surfaces steeper than this amount become walls even if they weren't before
const float TREASUREMAP_GRADIENT_BECOMES_WALL = 2.0;


/////////////////////
// External functions
/////////////////////



// Opens a treasure map display for oPC.
// Displays the given map ID at the given difficulty.
// Nothing happens if these are invalid.
void DisplayTreasureMapUI(object oPC, int nPuzzleID, int nDifficulty, object oMap=OBJECT_INVALID);

// Convert a vector to a string representation for debug purposes
string tmVectorToString(vector vVec);


// Return the solution location for nPuzzleID.
location GetPuzzleSolutionLocation(int nPuzzleID);

// Display a swatch of surface material colours to oPC
void TreasureMapSwatch(object oPC);

// Roll the probabilties for a treasure map drop.
// True if one should drop, False if not
int RollForTreasureMap(object oSource=OBJECT_SELF);

// Do RollForTreasureMap and, if one is generated set up the staging map and return its OID
// return OBJECT_INVALID if nothing was generated
object MaybeGenerateTreasureMap(int nObjectACR);

// Sets up the progenitor map to match the given ACR (in the treasure system area) and returns its OID.
// if oNearbyArea is a valid area and not bNearby, has a TREASUREMAP_CHANCE_FOR_RANDOM_LOCATION to pick a completely random solution location
// Otherwise picks a nearby area as described around TREASUREMAP_NEARBY_START_DISTANCE above.
// Does not copy it to another container. Use inc_loot's CopyTierItemToObjectOrLocation for that.
// If sExtraDesc is given, adds some text to the description about where it was found
object SetupProgenitorTreasureMap(int nObjectACR, object oNearbyArea, int bNearby, string sExtraDesc="");

// If you want to override the default difficulty weightings or force a particular difficulty, use this.
void SetTreasureMapDifficulty(object oMap, int nDifficulty);

// Should return a TREASUREMAP_DIFFICULTY* constant. May return 0 for legacy maps that
// were not opened since difficulties were added
// but such maps aren't completable any more anyway.
int GetTreasureMapDifficulty(object oMap);

// Do what needs doing when oMap's unique power is used.
void UseTreasureMap(object oMap);

void CompleteTreasureMap(object oMap);

int DoesLocationCompleteMap(object oMap, location lTest);

int GetIsSurfacematDiggable(int nSurfacemat);

///////////////////////
// Intended for seeding
///////////////////////

// Scan lLoc.
// Makes a total of nWidth and nHeight measurements along their axes (x and y respectively)
// Each measurement is fDistPerPoint apart.
// Therefore the total distance covered along eg the x axis is (nWidth * fDistPerPoint)
// Measurements record the surface material at each point.
// Values are very crudely written to locals on the module: "map_<x>_<y>"
// Requires an elevated instruction limit.
void TreasureMapScanLocation(location lLoc, int nWidth, int nHeight, float fDistPerPoint=1.0);

// Return a vector to add to the vector component of lLoc which puts it in a more useful position.
// This will try to move the scan centrepoint so that the scan fits entirely within the area boundaries
vector GetVectorToMoveScanLocationWithinAreaBounds(location lLoc, int nWidth, int nHeight, float fDistPerPoint=1.0);

struct MapProcessingSettings
{
    // Remove vertices that will affect the polygon's area by less than this proportion of the original
    // tested: 0.002
    float MAPDATA_AREA_CULL_THRESHOLD_PROPORTION;
    // But no matter how small the polygon is, the above shouldn't be able to go below this value
    // tested: 12
    float MAPDATA_MINIMUM_AREA_CULL_THRESHOLD;
    // Polygons with an area less than this proportion of the total image area are discarded
    // tested: 0.02/(real number of scans per side of the map)
    float MAPDATA_MINIMUM_POLYGON_AREA;

    // Text on the image. Used to make the Underdark maps suck a bit less.
    string sText;

    // The offset (in scan intervals, not real UI pixels) to draw the red X to mark the dig point at.
    float fCrossOffsetX;
    float fCrossOffsetY;
};


// Convert the raw values from TreasureMapScanLocation into a json array of NuiDrawListPolyLines for the map UI.
// nStartX and nStartY are the coordinates to start checking in the scanned map data
// nEndX and nEndY are end. It starts at (inclusively) nStart and goes up (noninclusively) to nEnd.
// Requires an elevated instruction limit.
json ProcessTreasureMapData(int nEndX, int nEndY, int nStartX, int nStartY, struct MapProcessingSettings mpSettings);

// Takes surfacematerial nSurfacemat and returns a NuiColor json object used to represent that surface material
// on treasure maps
json SurfacematToNuiColor(int nSurfacemat);

// This function makes the fallacious assumption that an area is valid if it has a transition to any another
// It does not consider the possibility that "islands" of disconnected areas might exist and appear valid
int CanAreaHaveTreasureMaps(object oArea);

// Do all the necessary steps to seed treasure maps at lLoc.
void CreateNewTreasureMapPuzzleAtLocation(location lLoc);

// In order to be valid there has to be a path from the proposed location to something with an area transition
// and the location itself has to be some kind of walkable surfacemat
int IsTreasureLocationValid(location lLoc);

location GetRandomValidTreasureLocationInArea(object oArea);

// Calculate maps for a given nPuzzleID and saves them to the DB.
// If the location of this map is not valid, rolls another one.
void CalculateTreasureMaps(int nPuzzleID);

///////////////////

json SurfacematToNuiColor(int nSurfacemat)
{
    if (nSurfacemat == 0) { return NuiColor(50, 50, 50, TREASUREMAP_OVERLAY_OPACITY); } // "NotDefined" = walls
    if (nSurfacemat == 1) { return NuiColor(130, 100, 50, TREASUREMAP_OVERLAY_OPACITY); }   // Dirt
    if (nSurfacemat == 2) { return NuiColor(100, 100, 100, TREASUREMAP_OVERLAY_OPACITY); }  // "Obscuring"
    if (nSurfacemat == 3) { return NuiColor(70, 130, 70, TREASUREMAP_OVERLAY_OPACITY); }    // Grass - light green
    if (nSurfacemat == 4) { return NuiColor(180, 180, 180, TREASUREMAP_OVERLAY_OPACITY); }  // Stone - grey
    if (nSurfacemat == 5) { return NuiColor(165, 140, 50, TREASUREMAP_OVERLAY_OPACITY); }   // Wood
    if (nSurfacemat == 6) { return NuiColor(50, 125, 255, TREASUREMAP_OVERLAY_OPACITY); }   // Walkable water - light blue
    if (nSurfacemat == 7) { return NuiColor(215, 255, 255, TREASUREMAP_OVERLAY_OPACITY); }  // "nonwalk" - pale cyan
    if (nSurfacemat == 8) { return NuiColor(225, 225, 225, TREASUREMAP_OVERLAY_OPACITY); }  // "transparent" - pale grey
    if (nSurfacemat == 9) { return NuiColor(190, 110, 105, TREASUREMAP_OVERLAY_OPACITY); }      // Carpet - red
    if (nSurfacemat == 10) { return NuiColor(145, 145, 145, TREASUREMAP_OVERLAY_OPACITY); } // Metal - grey, slightly darker than stone
    if (nSurfacemat == 11) { return NuiColor(100, 160, 255, TREASUREMAP_OVERLAY_OPACITY); } // Puddle - lighter than walkable water
    if (nSurfacemat == 12) { return NuiColor(40, 80, 50, TREASUREMAP_OVERLAY_OPACITY); }    // Swamp - dark turquoise
    if (nSurfacemat == 13) { return NuiColor(90, 90, 70, TREASUREMAP_OVERLAY_OPACITY); }    // Mud - mid brown
    if (nSurfacemat == 14) { return NuiColor(70, 100, 75, TREASUREMAP_OVERLAY_OPACITY); }   // Leaves - darker green than grass
    if (nSurfacemat == 15) { return NuiColor(255, 0, 0, TREASUREMAP_OVERLAY_OPACITY); }     // Lava - dark red
    if (nSurfacemat == 16) { return NuiColor(0, 0, 0, TREASUREMAP_OVERLAY_OPACITY); }       // Bottomless pit - black
    if (nSurfacemat == 17) { return NuiColor(0, 55, 150, TREASUREMAP_OVERLAY_OPACITY); }    // Deep water - dark blue
    if (nSurfacemat == 18) { return NuiColor(220, 200, 135, TREASUREMAP_OVERLAY_OPACITY); } // Door - as wood
    if (nSurfacemat == 19) { return NuiColor(255, 255, 255, TREASUREMAP_OVERLAY_OPACITY); } // Snow - white
    if (nSurfacemat == 20) { return NuiColor(240, 200, 0, TREASUREMAP_OVERLAY_OPACITY); }   // Sand - dark orange
    if (nSurfacemat == 21) { return NuiColor(215, 255, 255, TREASUREMAP_OVERLAY_OPACITY); } // "Barebones" - also pale cyan
    if (nSurfacemat == 22) { return NuiColor(200, 200, 200, TREASUREMAP_OVERLAY_OPACITY); } // "Stonebridge" - as stone
    if (nSurfacemat == -1) { return NuiColor(0, 0, 0, TREASUREMAP_OVERLAY_OPACITY); }   // invalid (edge of map) - black

    return NuiColor(255, 100, 100, TREASUREMAP_OVERLAY_OPACITY); // Unknown - Bright pink?
}


void TreasureMapScanLocation(location lLoc, int nWidth, int nHeight, float fDistPerPoint=1.0)
{
    vector vPos = GetPositionFromLocation(lLoc);
    object oArea = GetAreaFromLocation(lLoc);
    object oModule = GetModule();
    vector vStart = Vector(vPos.x - (fDistPerPoint * IntToFloat(nWidth)/2.0), vPos.y - (fDistPerPoint * IntToFloat(nHeight)/2.0), 0.0);
    int x, y, i;
    for (x=0; x<nWidth; x++)
    {
        for (y=0; y<nHeight; y++)
        {
            float fX = vStart.x + (fDistPerPoint * x);
            float fY = vStart.y + (fDistPerPoint * y);
            vector vScan = Vector(fX, fY, 0.0);
            location lScan = Location(oArea, vScan, 0.0);
            lScan = Location(oArea, Vector(fX, fY, GetGroundHeight(lScan)), 0.0);
            int nSurfacemat = GetSurfaceMaterial(lScan);
            // This method requires mirroring along the y axis to reflect what you see (north facing) ingame
            // This is probably the easiest place to get this done before getting into polygon algorithms
            int y2 = (nHeight-1)-y;
            
            float fGradientStep = fDistPerPoint*0.9;
            
            // Check for excessive gradient around the point, or it needs to become a wall if it was walkable
            if (SurfacematMatchesCriteria(nSurfacemat, SURFACEMAT_ABSTRACT_WALKABLE))
            {
                float fThisHeight = GetGroundHeight(lScan);
                for (i=0; i<4; i++)
                {
                    float fXOffset = i == 0 ? -fGradientStep : (i == 1 ? fGradientStep : 0.0);
                    float fYOffset = i == 2 ? -fGradientStep : (i == 3 ? fGradientStep : 0.0);
                    vector vCheckHeight = vScan + Vector(fXOffset, fYOffset, 0.0);
                    location lCheck = Location(oArea, vCheckHeight, 0.0);
                    vCheckHeight = vScan + Vector(fXOffset, fYOffset, GetGroundHeight(lCheck));
                    lCheck = Location(oArea, vCheckHeight, 0.0);
                    if (fabs(GetGroundHeight(lCheck) - fThisHeight)/fGradientStep >= TREASUREMAP_GRADIENT_BECOMES_WALL)
                    {
                        nSurfacemat = SURFACEMAT_UNDEFINED;
                        break;
                    }
                }
            }
            
            SetLocalInt(oModule, "map_" + IntToString(x) + "_" + IntToString(y2), nSurfacemat);
            //WriteTimestampedLogEntry("Scan " + IntToString(x) + ", " +  IntToString(y2) + " = " + IntToString(nSurfacemat));;
        }
    }
}

vector GetVectorToMoveScanLocationWithinAreaBounds(location lLoc, int nWidth, int nHeight, float fDistPerPoint=1.0)
{

    vector vPos = GetPositionFromLocation(lLoc);
    //WriteTimestampedLogEntry("Scan midpoint = " + tmVectorToString(vPos));
    object oArea = GetAreaFromLocation(lLoc);
    vector vStart = Vector(vPos.x - (fDistPerPoint * IntToFloat(nWidth)/2.0), vPos.y - (fDistPerPoint * IntToFloat(nHeight)/2.0), 0.0);
    //WriteTimestampedLogEntry("Scan start point = " + tmVectorToString(vStart));

    // Small amount of buffer
    float fAreaXMax = IntToFloat(10 * GetAreaSize(AREA_WIDTH, oArea)) + 3.0;
    float fAreaYMax = IntToFloat(10 * GetAreaSize(AREA_HEIGHT, oArea)) + 3.0;

    //WriteTimestampedLogEntry("Area max dimensions: " + FloatToString(fAreaXMax) + ", " + FloatToString(fAreaYMax));

    float fWidth = IntToFloat(nWidth);
    float fHeight = IntToFloat(nHeight);

    float fXStart = vStart.x;
    float fYStart = vStart.y;

    float fXEnd = vStart.x + (nWidth * fDistPerPoint);
    float fYEnd = vStart.y + (nHeight * fDistPerPoint);

    vector vAdjust = Vector(0.0, 0.0, 0.0);

    float fAdjust;


    // Covering both sides of the map
    if (fWidth * fDistPerPoint >= fAreaXMax)
    {
        vAdjust.x = fAreaXMax/2.0 - vPos.x;
    }
    else
    {
        if (fXStart < 0.0)
        {
            fAdjust = -fXStart;
        }
        else if (fXEnd > fAreaXMax)
        {
            fAdjust = fAreaXMax - fXEnd;
        }
        else
        {
            fAdjust = 0.0;
        }
        vAdjust.x += fAdjust;
    }
    if (fHeight * fDistPerPoint >= fAreaYMax)
    {
        vAdjust.y = fAreaYMax/2.0 - vPos.y;
    }
    else
    {
        if (fYStart < 0.0)
        {
            fAdjust = -fYStart;
        }
        else if (fYEnd > fAreaYMax)
        {
            fAdjust = fAreaYMax - fYEnd;
        }
        else
        {
            fAdjust = 0.0;
        }
        vAdjust.y += fAdjust;
    }
    //WriteTimestampedLogEntry("Adjust = " + tmVectorToString(vAdjust));
    return vAdjust;
}


struct MapCell
{
    // These are coords of the top left of the cell
    // The cell itself is a 2x2 square of points
    int x;
    int y;
    // A list of surfacemats for each corner of the cell, in the order
    // (B = bottom, T = top, R = right, L = left, I think I use this abbreviations more further on)
    // [BL, BR, TR, TL]
    json jSurfacemats;
    // Simply a list of all the different surfacemats in this cell
    json jUniqueSurfacemats;

};

struct MapCell _GetMapCell(int x, int y, int nEndX, int nEndY, int nStartX, int nStartY)
{
    struct MapCell mpOut;
    object oModule = GetModule();
    mpOut.jSurfacemats = JsonArray();
    mpOut.jUniqueSurfacemats = JsonArray();

    int x2, y2;

    int xpos = 0;

    // Wrangled loops to make the checks occur in the right order
    for (y2=1; y2>=0; y2--)
    {
        for (x2=0; x2<=1; x2++)
        {
            int x3;
            if (xpos == 0 || xpos == 3)
            {
                x3 = x;
            }
            else
            {
                x3 = x + 1;
            }
            xpos++;
            int y3 = y + y2;
            // Because of the variable scan size, this HAS to only return real values inside the requested scan area
            // everything outside needs to return a -1
            int nSurfacemat = -1;
            if (x3 < nEndX && y3 < nEndY && x3 >= nStartX && y3 >= nStartY)
            {
                nSurfacemat = GetLocalInt(oModule, "map_" + IntToString(x3) + "_" + IntToString(y3));
            }
            //WriteTimestampedLogEntry(IntToString(x3) + ", " + IntToString(y3) + " = " + IntToString(nSurfacemat));
            json jSurfacemat = JsonInt(nSurfacemat);
            mpOut.jSurfacemats = JsonArrayInsert(mpOut.jSurfacemats, jSurfacemat);
            if (JsonFind(mpOut.jUniqueSurfacemats, jSurfacemat) == JsonNull())
            {
                mpOut.jUniqueSurfacemats = JsonArrayInsert(mpOut.jUniqueSurfacemats, jSurfacemat);
            }
        }
    }
    return mpOut;
}

// Return the match index of nSurfacematToCheckFor in mpCell.
// This is a bitmask of:
// 1: Bottom left didn't match
// 2: Bottom right didn't match
// 4: Top right didn't match
// 8: Top left didn't match
int _GetCellMatchIndex(struct MapCell mpCell, int nSurfacematToCheckFor)
{
    int nIndex = 0;
    int i;
    for (i=0; i<4; i++)
    {
        int nOther = JsonGetInt(JsonArrayGet(mpCell.jSurfacemats, i));
        if (nOther != nSurfacematToCheckFor)
        {
            //WriteTimestampedLogEntry("index = " + IntToString(i) + ", checking " + IntToString(nSurfacematToCheckFor) + " vs " + IntToString(nOther));
            nIndex |= (1 << i);
        }
    }
    return nIndex;
}

float _GetAreaFromVertices(json jVerts)
{
    float fTotal = 0.0;
    int nLength = JsonGetLength(jVerts);
    int n = nLength / 2;
    int i;
    // 1/2 * (y1(xn - x2) +y2(x1 - x3) + y3(x2 - x4) + ... + yn(x(n-1) - x1))
    // The first and last terms are awkward to do in a loop and can be done at the end
    // I'm not sure what this will do if passed a polygon with less than four verts
    // but the outcome seems unlikely to affect the map result significantly if this miscalculates those a bit
    for (i=2; i<nLength-2; i+=2)
    {
        float xiMinusOne = JsonGetFloat(JsonArrayGet(jVerts, i-2));
        float xiPlusOne = JsonGetFloat(JsonArrayGet(jVerts, i+2));
        float y = JsonGetFloat(JsonArrayGet(jVerts, i+1));
        fTotal = fTotal + y * (xiMinusOne - xiPlusOne);
    }
    float xn = JsonGetFloat(JsonArrayGet(jVerts, nLength-2));
    float x2 = JsonGetFloat(JsonArrayGet(jVerts, 2));
    float y1 = JsonGetFloat(JsonArrayGet(jVerts, 1));
    fTotal = fTotal + y1 * (xn - x2);

    float xnMinusOne = JsonGetFloat(JsonArrayGet(jVerts, nLength-4));
    float x1 = JsonGetFloat(JsonArrayGet(jVerts, 0));
    float yn = JsonGetFloat(JsonArrayGet(jVerts, nLength-1));
    fTotal = fTotal + yn * (xnMinusOne - x1);

    if (fTotal < 0.0)
    {
        fTotal *= -1.0;
    }
    return fTotal/2.0;
}


json ProcessTreasureMapData(int nEndX, int nEndY, int nStartX, int nStartY, struct MapProcessingSettings mpSettings)
{
    // Todo: Split this monstrosity up a bit.
    // It's really long and comprises three discrete parts
    // It might also make the atrocity of the polygon algorithm a bit more palatable
    object oModule = GetModule();
    int nRun = GetLocalInt(oModule, "ProcessMapDataRun");
    SetLocalInt(oModule, "ProcessMapDataRun", nRun+1);
    string sVar = "ProcessMapData" + IntToString(nRun);
    //WriteTimestampedLogEntry("ProcessMapData width=" + IntToString(nEndX) + ", height=" + IntToString(nEndY) + ", var = " + sVar);

    float fStartX = IntToFloat(nStartX);
    float fStartY = IntToFloat(nStartY);

    //////////////////////////////////////////
    // 1) Most popular colour fills background
    //////////////////////////////////////////
    int x, y;
    int nHighestSurfacemat=-1;
    for (x=nStartX; x<nEndX; x++)
    {
        for (y=nStartY; y<nEndY; y++)
        {
            int nSurfacemat = GetLocalInt(oModule, "map_" + IntToString(x) + "_" + IntToString(y));
            int nCount = GetLocalInt(oModule, sVar + "count" + IntToString(nSurfacemat));
            SetLocalInt(oModule, sVar + "count" + IntToString(nSurfacemat), nCount+1);
            if (nSurfacemat > nHighestSurfacemat)
            {
                nHighestSurfacemat = nSurfacemat;
                //WriteTimestampedLogEntry("New highest surfacemat " + IntToString(nHighestSurfacemat) + " at " + IntToString(x) + ", "+ IntToString(y));
            }
        }
    }
    int i;
    int nBackgroundSurfacemat;
    int nBackgroundSurfacematCount=-1;
    for (i=0; i<=nHighestSurfacemat; i++)
    {
        int nCount = GetLocalInt(oModule, sVar + "count" + IntToString(i));
        if (nCount > nBackgroundSurfacematCount)
        {
            nBackgroundSurfacemat = i;
            nBackgroundSurfacematCount = nCount;
            //WriteTimestampedLogEntry("New most popular surfacemat: " + IntToString(nBackgroundSurfacemat) + " with squarecount=" + IntToString(nBackgroundSurfacematCount));
        }
    }

    //////////////////////
    // BUILD POLYGONS
    //////////////////////

    // The NUI drawing will work best trying to draw lines on a background rather than pixels I think
    // In any case, pixel-based simplification is going to look rather silly trying to deal with
    // features that have curved or slanted edges without getting into a horrible mess

    // Really what this needs is to try to convert regions of the same surfacemat into a polygon and cull exterior vertices
    // that don't distort the outer shape too much
    // and then check for and deal with any "holes" (which should reduce to a recursive problem)

    // -> marching squares https://en.wikipedia.org/wiki/Marching_squares
    // -> discard polygon if too small
    // -> trim excess vertices:     remove verts and see how much the polygon's area changes
    //                              don't let it vary more than some percent in either direction

    // Life might be a bit simpler without dealing with final window coordinates so early
    // but converting all vertex coords later sounds slow
    float fPixelsPerSampleX = IntToFloat(TREASUREMAP_WINDOW_DIMENSIONS)/IntToFloat(nEndX - nStartX);
    float fPixelsPerSampleY = IntToFloat(TREASUREMAP_WINDOW_DIMENSIONS)/IntToFloat(nEndY - nStartY);
    float fImageTotalArea = IntToFloat(TREASUREMAP_WINDOW_DIMENSIONS*TREASUREMAP_WINDOW_DIMENSIONS);
    float fMinimumAcceptedPolygonArea = fImageTotalArea * mpSettings.MAPDATA_MINIMUM_POLYGON_AREA;


    // This algorithm makes sorting the resulting line fragments into discrete polygons pretty hard
    // One option is to simply make a massive pool of fragments on a per-surfacemat basis and join them up...
    // But that would result in "holes" appearing as polygons of their own
    // and the whole thing sounds like a computational nightmare

    // The alternative is to work out from the cell type which cell(s) need to be checked to make a closed final polygon
    // The hardest part of this is dealing with cells 5 and 10, the ones that produce two different line fragments
    // ... but only one of these fragments will connect to the line that we have started
    // Given that each cell outcome makes exactly one line fragment that connects to the one started initially
    // it should be possible to identify the next cell to check unambiguously
    // This approach still has problems with "holes" in final polygons
    // It has to work out which pixels are "done"


    // This approach:
    // Search every 2x2 CELL in the map data
    // Those that have all of their four vertices made up of the same surfacemat can be ignored
    // The moment you find one which isn't, get an initial line fragment
    //  -> If this cell is a 5 or 10 (two line fragments) ignore it until you have only one initial line fragment to trace.
    // It is theoretically possible to have closed shapes made up of only these, but they should always be too small for these maps
    // -> ignore these as starting points
    // From the cell type of the first fragment, follow around and mark all the mixed cells as "done" while keeping the vertex array
    // It will eventually come full circle and be a true enclosed region.
    // Repeat from the same cell that started this process for all the other non-background surfacemats involved in the "collision"
    // Continue until all edge-containing cells have been processed

    // Then try to cull vertices based on the area calculation mentioned above

    // Somewhere to keep polygons as they are found.
    // jPolygonsBySurfacemat[nSurfacemat] contains an array of polygons of that surface material
    // each polygon is made up of an array of floats of vertex coordinates
    json jPolygonsBySurfacemat = JsonArray();
    for (i=0; i<=nHighestSurfacemat; i++)
    {
        jPolygonsBySurfacemat = JsonArrayInsert(jPolygonsBySurfacemat, JsonArray());
    }

    for (x=nStartX; x<nEndX; x++)
    {
        for (y=nStartY; y<nEndY; y++)
        {
            // If we already handled what to do with this cell, keep going
            string sPixelvar = sVar + "_" + IntToString(x) + "_" + IntToString(y);
            if (GetLocalInt(oModule, sPixelvar + "handled"))
            {
                continue;
            }

            struct MapCell mpCurrent = _GetMapCell(x, y, nEndX, nEndY, nStartX, nStartY);
            int nNumSurfacemats = JsonGetLength(mpCurrent.jUniqueSurfacemats);
            // There is no need to trace anything when there is only 1 surface material in the cell
            if (nNumSurfacemats > 1)
            {
                for (i=0; i<nNumSurfacemats; i++)
                {
                    int nThisSurfacemat = JsonGetInt(JsonArrayGet(mpCurrent.jUniqueSurfacemats, i));
                    // -1 (canvas edge) doesn't need polygons tracing
                    // Neither does the background as it's getting one gigantic polygon covering the whole thing first
                    if (nThisSurfacemat == -1 || nThisSurfacemat == nBackgroundSurfacemat)
                    {
                        continue;
                    }
                    // If this surfacemat has already traced at this cell, don't bother
                    if (GetLocalInt(oModule, sPixelvar + "handled" + IntToString(nThisSurfacemat)))
                    {
                        continue;
                    }
                    // Ensure that this is not match index 5 or 10 (the ones that produce two line fragments)
                    // Or 0/15 (no line fragments)
                    // We want to only try tracing when there's exactly one line fragment in this cell
                    int nMatch = _GetCellMatchIndex(mpCurrent, nThisSurfacemat);
                    if (nMatch != 5 && nMatch != 10 && nMatch != 0 && nMatch != 15)
                    {
                        // Copy coords as these are going to get modified as we move round the edge of this polygon
                        // They also need to switch to floats because we're drawing lines between the "pixels" of the
                        // original terrain scan now
                        float x2 = IntToFloat(x);
                        float y2 = IntToFloat(y);
                        json jVertices = JsonArray();
                        int bFirstVertex = 1;
                        float fLastVertx;
                        float fLastVerty;
                        // Keep track of where we started so we know if we are done or not
                        float fFirstVertx;
                        float fFirstVerty;
                        // Trace a polygon.
                        //WriteTimestampedLogEntry("Begin polygon for surfacemat " + IntToString(nThisSurfacemat) + " at " + IntToString(x) + ", " + IntToString(y));
                        while (TRUE)
                        {
                            // Sanity checking
                            if (x2 < -5.0 || y2 < -5.0)
                            {
                                WriteTimestampedLogEntry("ERROR: negative coordinates");
                                return JsonNull();
                            }
                            // These coordinates are in "internal" form
                            // They aren't yet converted to "real" coordinates that will be used in the final NUI
                            float fVert1x, fVert1y, fVert2x, fVert2y;
                            // These are "internal" form offsets relative to (x2, y2) of these coordinates
                            float fVert1xOffset, fVert1yOffset, fVert2xOffset, fVert2yOffset;
                            // Interpret match, writing two floats (vertex coords) to the array
                            // (first vertex needs to write two pairs instead as it has nothing to continue)
                            if (nMatch == 1 || nMatch == 14)
                            {
                                fVert1xOffset = 0.0;
                                fVert1yOffset = 0.5;
                                fVert2xOffset = 0.5;
                                fVert2yOffset = 1.0;
                            }
                            else if (nMatch == 2 || nMatch == 13)
                            {
                                fVert1xOffset = 0.5;
                                fVert1yOffset = 1.0;
                                fVert2xOffset = 1.0;
                                fVert2yOffset = 0.5;
                            }
                            else if (nMatch == 3 || nMatch == 12)
                            {
                                fVert1xOffset = 0.0;
                                fVert1yOffset = 0.5;
                                fVert2xOffset = 1.0;
                                fVert2yOffset = 0.5;
                            }
                            else if (nMatch == 4 || nMatch == 11)
                            {
                                fVert1xOffset = 0.5;
                                fVert1yOffset = 0.0;
                                fVert2xOffset = 1.0;
                                fVert2yOffset = 0.5;
                            }
                            else if (nMatch == 6 || nMatch == 9)
                            {
                                fVert1xOffset = 0.5;
                                fVert1yOffset = 0.0;
                                fVert2xOffset = 0.5;
                                fVert2yOffset = 1.0;
                            }
                            else if (nMatch == 7 || nMatch == 8)
                            {
                                fVert1xOffset = 0.0;
                                fVert1yOffset = 0.5;
                                fVert2xOffset = 0.5;
                                fVert2yOffset = 0.0;
                            }
                            else if (nMatch == 5)
                            {
                                // Bottom left - Top right parallels
                                // Catch the top line
                                //WriteTimestampedLogEntry("Last verts = " + FloatToString(fLastVertx) + ", " + FloatToString(fLastVerty));
                                // These are TL-BR lines
                                // dy of 0 means top line, 0.5 is ambiguous,  1.0 means bottom line
                                // if dy = 0.5 and dx = 0.0, top, if dy = 0.5 and dx = 1.0, bottom
                                if (fLastVerty - (y2 - fStartY) == 0.0 || fLastVertx - (x2 - fStartX) == 0.0)
                                {
                                    //WriteTimestampedLogEntry("Match 5 top line");
                                    fVert1xOffset = 0.0;
                                    fVert1yOffset = 0.5;
                                    fVert2xOffset = 0.5;
                                    fVert2yOffset = 0.0;
                                }
                                else
                                {
                                    // bottom line
                                    //WriteTimestampedLogEntry("Match 5 bottom line");
                                    fVert1xOffset = 0.5;
                                    fVert1yOffset = 1.0;
                                    fVert2xOffset = 1.0;
                                    fVert2yOffset = 0.5;
                                }
                            }
                            else if (nMatch == 10)
                            {
                                // Catch the top line
                                // WriteTimestampedLogEntry("Last verts = " + FloatToString(fLastVertx) + ", " + FloatToString(fLastVerty));
                                // These are TL-BR lines
                                // dy of 0 means top line, 0.5 is ambiguous,  1.0 means bottom line
                                // if dy = 0.5 and dx = 1.0, top, if dy = 0.5 and dx = 0, bottom
                                if (fLastVerty - (y2 - fStartY) == 0.0 || fLastVertx - (x2 - fStartX) == 1.0)
                                {
                                    //WriteTimestampedLogEntry("Match 10 top line");
                                    fVert1xOffset = 0.5;
                                    fVert1yOffset = 0.0;
                                    fVert2xOffset = 1.0;
                                    fVert2yOffset = 0.5;
                                }
                                else
                                {
                                    // bottom line
                                    //WriteTimestampedLogEntry("Match 10 bottom line");
                                    fVert1xOffset = 0.0;
                                    fVert1yOffset = 0.5;
                                    fVert2xOffset = 0.5;
                                    fVert2yOffset = 1.0;
                                }
                            }

                            fVert1x = (x2 - fStartX) + fVert1xOffset;
                            fVert1y = (y2 - fStartY) + fVert1yOffset;
                            fVert2x = (x2 - fStartX) + fVert2xOffset;
                            fVert2y = (y2 - fStartY) + fVert2yOffset;

                            // Work out which offset we are moving along
                            float fThisVertexOffsetx;
                            float fThisVertexOffsety;

                            if (bFirstVertex)
                            {
                                // Write two coordinate pairs instead of one
                                jVertices = JsonArrayInsert(jVertices, JsonFloat(fVert1x * fPixelsPerSampleX));
                                jVertices = JsonArrayInsert(jVertices, JsonFloat(fVert1y * fPixelsPerSampleY));
                                jVertices = JsonArrayInsert(jVertices, JsonFloat(fVert2x * fPixelsPerSampleX));
                                jVertices = JsonArrayInsert(jVertices, JsonFloat(fVert2y * fPixelsPerSampleY));
                                fLastVertx = fVert2x;
                                fLastVerty = fVert2y;
                                fFirstVertx = fVert1x;
                                fFirstVerty = fVert1y;
                                bFirstVertex = 0;
                                fThisVertexOffsetx = fVert2xOffset;
                                fThisVertexOffsety = fVert2yOffset;
                            }
                            else
                            {
                                // The next vertex of the polygon is whichever coordinate pair isn't where we left off
                                // before getting here
                                if (fLastVertx == fVert1x && fLastVerty == fVert1y)
                                {
                                    jVertices = JsonArrayInsert(jVertices, JsonFloat(fVert2x * fPixelsPerSampleX));
                                    jVertices = JsonArrayInsert(jVertices, JsonFloat(fVert2y * fPixelsPerSampleY));
                                    fLastVertx = fVert2x;
                                    fLastVerty = fVert2y;
                                    fThisVertexOffsetx = fVert2xOffset;
                                    fThisVertexOffsety = fVert2yOffset;
                                }
                                else
                                {
                                    jVertices = JsonArrayInsert(jVertices, JsonFloat(fVert1x * fPixelsPerSampleX));
                                    jVertices = JsonArrayInsert(jVertices, JsonFloat(fVert1y * fPixelsPerSampleY));
                                    fLastVertx = fVert1x;
                                    fLastVerty = fVert1y;
                                    fThisVertexOffsetx = fVert1xOffset;
                                    fThisVertexOffsety = fVert1yOffset;
                                }
                                int nVertexArrLength = JsonGetLength(jVertices);
                                if (nVertexArrLength > 6)
                                {
                                    float fTwoBeforex = JsonGetFloat(JsonArrayGet(jVertices, nVertexArrLength - 4));
                                    float fTwoBeforey = JsonGetFloat(JsonArrayGet(jVertices, nVertexArrLength - 3));

                                    float fLastx = JsonGetFloat(JsonArrayGet(jVertices, nVertexArrLength - 2));
                                    float fLasty = JsonGetFloat(JsonArrayGet(jVertices, nVertexArrLength - 1));

                                    float fThreeBeforex = JsonGetFloat(JsonArrayGet(jVertices, nVertexArrLength - 6));
                                    float fThreeBeforey = JsonGetFloat(JsonArrayGet(jVertices, nVertexArrLength - 5));

                                    //WriteTimestampedLogEntry("3 before: " + FloatToString(fThreeBeforex) + ", " + FloatToString(fThreeBeforey));
                                    //WriteTimestampedLogEntry("2 before: " + FloatToString(fTwoBeforex) + ", " +FloatToString(fTwoBeforey));
                                    //WriteTimestampedLogEntry("1 before: " + FloatToString(fLastx) + ", " +FloatToString(fLasty));


                                    // Don't divide by zero when calcing gradients
                                    // Instead of gradient=infinity, this will make it extremely large but still consistent
                                    float fDx = (fTwoBeforex - fThreeBeforex);
                                    if (fDx == 0.0)
                                    {
                                        fDx = 0.0000000001;
                                    }

                                    float fGradientThreeToTwo = (fTwoBeforey - fThreeBeforey)/fDx;

                                    fDx = (fLastx - fTwoBeforex);
                                    if (fDx == 0.0)
                                    {
                                        fDx = 0.0000000001;
                                    }
                                    float fGradientTwoToLast = (fLasty - fTwoBeforey)/fDx;
                                    float fGradientDiff = fGradientThreeToTwo - fGradientTwoToLast;
                                    if (fGradientDiff < 0.0)
                                    {
                                        fGradientDiff *= -1.0;
                                    }
                                    // should be plenty to account for float rounding
                                    //WriteTimestampedLogEntry("Gradients = " + FloatToString(fGradientTwoToLast) + " vs " + FloatToString(fGradientThreeToTwo));
                                    if (fGradientDiff < 0.05)
                                    {
                                        //WriteTimestampedLogEntry("Gradient diff = " + FloatToString(fGradientDiff) + ", remove useless midpoint");
                                        jVertices = JsonArrayDel(jVertices, nVertexArrLength - 4);
                                        jVertices = JsonArrayDel(jVertices, nVertexArrLength - 4);
                                    }
                                }


                            }
                            // Set this place as done, don't start tracing here
                            if (nMatch != 5 && nMatch != 10)
                            {
                                SetLocalInt(oModule, sVar + "_" + IntToString(FloatToInt(x2)) + "_" + IntToString(FloatToInt(y2)) + "handled" + IntToString(nThisSurfacemat), 1);
                            }

                            // Find the next cell coordinates and keep going
                            // (fThisVertexOffsetx, fThisVertexOffsety) will land between two of the cell's edges
                            // we go that way
                            // Turns out, that is whichever coordinate happens to be an integer (rather than half)
                            if (fThisVertexOffsetx == 0.0)
                            {
                                x2 -= 1.0;
                            }
                            else if (fThisVertexOffsetx == 1.0)
                            {
                                x2 += 1.0;
                            }
                            else if (fThisVertexOffsety == 0.0)
                            {
                                y2 -= 1.0;
                            }
                            else if (fThisVertexOffsety == 1.0)
                            {
                                y2 += 1.0;
                            }
                            //WriteTimestampedLogEntry("Finished processing match " + IntToString(nMatch) + ", move to " + FloatToString(x2) + ", " + FloatToString(y2));

                            // But make sure we haven't looped back round to the first vertex in the polygon
                            if (fLastVertx == fFirstVertx && fLastVerty == fFirstVerty)
                            {
                                //WriteTimestampedLogEntry("Polygon is closed loop, finish");
                                break;
                            }
                            nMatch = _GetCellMatchIndex(_GetMapCell(FloatToInt(x2), FloatToInt(y2), nEndX, nEndY, nStartX, nStartY), nThisSurfacemat);
                        }


                        // Cull vertices where the total area change is small enough
                        float fArea = _GetAreaFromVertices(jVertices);
                        //WriteTimestampedLogEntry("Polygon has area " + FloatToString(fArea) + " min accepted " + FloatToString(fMinimumAcceptedPolygonArea));
                        // Don't save the poly at all if its area is too small
                        if (fArea > fMinimumAcceptedPolygonArea)
                        {
                            int nNumVerts = JsonGetLength(jVertices) / 2;;
                            int nIndexToTry = 0;
                            float fVertexCullAreaDeltaThreshold = mpSettings.MAPDATA_AREA_CULL_THRESHOLD_PROPORTION * fArea;
                            if (fVertexCullAreaDeltaThreshold < mpSettings.MAPDATA_MINIMUM_AREA_CULL_THRESHOLD)
                            {
                                fVertexCullAreaDeltaThreshold = mpSettings.MAPDATA_MINIMUM_AREA_CULL_THRESHOLD;
                            }

                            while (TRUE)
                            {
                                // Verts are in pairs. Have to consider and handle them in pairs.
                                // Do not reduce quads further
                                if (nNumVerts < 4)
                                {
                                    break;
                                }
                                if (nIndexToTry * 2 >= nNumVerts)
                                {
                                    break;
                                }
                                json jVertCopy = JsonArrayDel(jVertices, nIndexToTry*2);
                                jVertCopy = JsonArrayDel(jVertCopy, nIndexToTry*2);
                                float fNewArea = _GetAreaFromVertices(jVertCopy);
                                float fAreaDelta = fNewArea - fArea;
                                if (fAreaDelta < 0.0) { fAreaDelta *= -1.0; }
                                if (fAreaDelta < fVertexCullAreaDeltaThreshold)
                                {
                                    //WriteTimestampedLogEntry("Culled vertex " + IntToString(nIndexToTry) + ": area delta = " + FloatToString(fAreaDelta));
                                    jVertices = jVertCopy;
                                    nNumVerts--;
                                    continue;
                                }
                                //WriteTimestampedLogEntry("Do not cull vertex " + IntToString(nIndexToTry) + ": area delta = " + FloatToString(fAreaDelta));
                                nIndexToTry++;
                            }

                            // Ensure the shape is closed (if the first/last verts are culled it isn't)
                            float fx1 = JsonGetFloat(JsonArrayGet(jVertices, 0));
                            float fy1 = JsonGetFloat(JsonArrayGet(jVertices, 1));

                            float fyn = JsonGetFloat(JsonArrayGet(jVertices, JsonGetLength(jVertices)-1));
                            float fxn = JsonGetFloat(JsonArrayGet(jVertices, JsonGetLength(jVertices)-2));

                            if (fx1 != fxn || fy1 != fyn)
                            {
                                jVertices = JsonArrayInsert(jVertices, JsonFloat(fx1));
                                jVertices = JsonArrayInsert(jVertices, JsonFloat(fy1));
                            }


                            // Save the polygon we traced
                            json jThisSurfacematPolygons = JsonArrayGet(jPolygonsBySurfacemat, nThisSurfacemat);
                            jThisSurfacematPolygons = JsonArrayInsert(jThisSurfacematPolygons, jVertices);
                            jPolygonsBySurfacemat = JsonArraySet(jPolygonsBySurfacemat, nThisSurfacemat, jThisSurfacematPolygons);
                        }
                        else
                        {
                            //WriteTimestampedLogEntry("Discard polygon, final area is too low");
                        }
                    }
                }
            }
            // Whether polygons were traced or not, there should be no reason to try again
            SetLocalInt(oModule, sPixelvar + "handled", 1);
        }
    }

    ////////////////////////////
    // PROCESS INTO NUI DRAWLIST
    ////////////////////////////
    json jDrawListElements = JsonArray();
    json jPoints = JsonArray();

    jPoints = JsonArrayInsert(jPoints, JsonFloat(0.0));
    jPoints = JsonArrayInsert(jPoints, JsonFloat(0.0));
    jPoints = JsonArrayInsert(jPoints, JsonFloat(IntToFloat(TREASUREMAP_WINDOW_DIMENSIONS)));
    jPoints = JsonArrayInsert(jPoints, JsonFloat(0.0));
    jPoints = JsonArrayInsert(jPoints, JsonFloat(IntToFloat(TREASUREMAP_WINDOW_DIMENSIONS)));
    jPoints = JsonArrayInsert(jPoints, JsonFloat(IntToFloat(TREASUREMAP_WINDOW_DIMENSIONS)));
    jPoints = JsonArrayInsert(jPoints, JsonFloat(0.0));
    jPoints = JsonArrayInsert(jPoints, JsonFloat(IntToFloat(TREASUREMAP_WINDOW_DIMENSIONS)));
    json jColour = SurfacematToNuiColor(nBackgroundSurfacemat);
    jDrawListElements = JsonArrayInsert(jDrawListElements, NuiDrawListPolyLine(JsonBool(1), jColour, JsonBool(1), JsonFloat(1.0), jPoints));
    int nCoordinates = 8;
    int nPolygons = 1;
    // On "holes": by definition, the area of a simple polygon that entirely contains another must be larger than the one it contains
    // Therefore, drawing polygons in order of decreasing area is probably the way to go here

    json jPolygonsByArea = JsonObject();
    // jPolygonsByArea[area] = [array[surfacemat, vertex array]]
    // it seems pretty unlikely that two polygons will have the exact same area but you never know
    int j;
    for (i=0; i<=nHighestSurfacemat; i++)
    {
        json jThisSurfacematArray = JsonArrayGet(jPolygonsBySurfacemat, i);
        int nLength = JsonGetLength(jThisSurfacematArray);
        //WriteTimestampedLogEntry("Surfacemat " + IntToString(i) + " has " + IntToString(nLength) + " saved polygons");
        for (j=0; j<nLength; j++)
        {
            json jVerts = JsonArrayGet(jThisSurfacematArray, j);
            float fArea = _GetAreaFromVertices(jVerts);
            json jPolygonsAtThisArea = JsonObjectGet(jPolygonsByArea, FloatToString(fArea));
            if (jPolygonsAtThisArea == JsonNull())
            {
                jPolygonsAtThisArea = JsonArray();
            }
            json jData = JsonArray();
            jData = JsonArrayInsert(jData, JsonInt(i));
            jData = JsonArrayInsert(jData, jVerts);
            jPolygonsAtThisArea = JsonArrayInsert(jPolygonsAtThisArea, jData);
            jPolygonsByArea = JsonObjectSet(jPolygonsByArea, FloatToString(fArea), jPolygonsAtThisArea);
            //WriteTimestampedLogEntry("Saved a polygon for surfacemat " + IntToString(i) + " and area " + FloatToString(fArea));
        }
    }
    json jAreas = JsonObjectKeys(jPolygonsByArea);
    json jAreaFloats = JsonArray();
    int nNumAreas = JsonGetLength(jAreas);
    for (i=0; i<nNumAreas; i++)
    {
        jAreaFloats = JsonArrayInsert(jAreaFloats, JsonArrayGet(jAreas, i));
    }
    //WriteTimestampedLogEntry("Unsorted areas: " + JsonDump(jAreaFloats));
    json jAreaFloatsSorted = JsonArrayTransform(jAreaFloats, JSON_ARRAY_SORT_DESCENDING);
    //WriteTimestampedLogEntry("Sorted areas: " + JsonDump(jAreaFloatsSorted));
    for (i=0; i<nNumAreas; i++)
    {
        string sArea = JsonGetString(JsonArrayGet(jAreaFloatsSorted, i));
        json jPolygonsAtThisArea = JsonObjectGet(jPolygonsByArea, sArea);
        int nNumPolygonsAtThisArea = JsonGetLength(jPolygonsAtThisArea);
        //WriteTimestampedLogEntry("Make drawlist for polygons of area " + sArea + ": " + JsonDump(jPolygonsAtThisArea));
        for (j=0; j<nNumPolygonsAtThisArea; j++)
        {

            json jData = JsonArrayGet(jPolygonsAtThisArea, j);
            int nThisSurfacemat = JsonGetInt(JsonArrayGet(jData, 0));
            //WriteTimestampedLogEntry("Making polygon for surfacemat " + IntToString(nThisSurfacemat));
            json jVertices = JsonArrayGet(jData, 1);
            jColour = SurfacematToNuiColor(nThisSurfacemat);
            // fill here
            jDrawListElements = JsonArrayInsert(jDrawListElements, NuiDrawListPolyLine(JsonBool(1), jColour, JsonBool(0), JsonFloat(4.0), jVertices));
            nPolygons++;
            nCoordinates += JsonGetLength(jVertices);
        }
    }

    // It wouldn't be a treasure map without an X to mark the spot
    float fMidX = mpSettings.fCrossOffsetX + IntToFloat(nEndX - nStartX)/2;
    float fMidY = mpSettings.fCrossOffsetY + IntToFloat(nEndY - nStartY)/2;

    // For a little bit of variety, let's rotate these a little randomly
    // It's still an X if the two lines don't meet at exactly right angles

    // Xs themselves are always rectangular (please please fill function don't break on rectangles)
    // So we have four pairs of coordinates
    float fTRx = TREASUREMAP_X_LENGTH/2;
    float fTRy = TREASUREMAP_X_WIDTH/2;

    float fBRx = TREASUREMAP_X_LENGTH/2;
    float fBRy = -TREASUREMAP_X_WIDTH/2;

    float fTLx = -TREASUREMAP_X_LENGTH/2;
    float fTLy = TREASUREMAP_X_WIDTH/2;

    float fBLx = -TREASUREMAP_X_LENGTH/2;
    float fBLy = -TREASUREMAP_X_WIDTH/2;

    // To get the first line of the x, we have to rotate these ~45deg
    // To get the second, we rotate ~135
    // Then add the midpoints calculated above to all coordinates, and it should be good

    float fCrossX = fMidX * fPixelsPerSampleX;
    float fCrossY = fMidY * fPixelsPerSampleY;

    for (i=0; i<2; i++)
    {
        json jVertices = JsonArray();
        float fRotation = IntToFloat((i*90) + 45 + Random(17) - 8);
        jVertices = JsonArrayInsert(jVertices, JsonFloat(fMidX * fPixelsPerSampleX + (fTRx * cos(fRotation)) - (fTRy * sin(fRotation))));
        jVertices = JsonArrayInsert(jVertices, JsonFloat(fMidY * fPixelsPerSampleY + (fTRx * sin(fRotation)) + (fTRy * cos(fRotation))));

        jVertices = JsonArrayInsert(jVertices, JsonFloat(fMidX * fPixelsPerSampleX + (fBRx * cos(fRotation)) - (fBRy * sin(fRotation))));
        jVertices = JsonArrayInsert(jVertices, JsonFloat(fMidY * fPixelsPerSampleY + (fBRx * sin(fRotation)) + (fBRy * cos(fRotation))));

        jVertices = JsonArrayInsert(jVertices, JsonFloat(fMidX * fPixelsPerSampleX + (fBLx * cos(fRotation)) - (fBLy * sin(fRotation))));
        jVertices = JsonArrayInsert(jVertices, JsonFloat(fMidY * fPixelsPerSampleY + (fBLx * sin(fRotation)) + (fBLy * cos(fRotation))));

        jVertices = JsonArrayInsert(jVertices, JsonFloat(fMidX * fPixelsPerSampleX + (fTLx * cos(fRotation)) - (fTLy * sin(fRotation))));
        jVertices = JsonArrayInsert(jVertices, JsonFloat(fMidY * fPixelsPerSampleY + (fTLx * sin(fRotation)) + (fTLy * cos(fRotation))));

        jDrawListElements = JsonArrayInsert(jDrawListElements, NuiDrawListPolyLine(JsonBool(1), NuiColor(180, 0, 0, TREASUREMAP_OVERLAY_OPACITY), JsonBool(1), JsonFloat(0.0), jVertices));
    }

    // Area-defined map label
    if (mpSettings.sText != "")
    {
        // We need to avoid being too close to the red cross
        float fStartX = TREASUREMAP_WINDOW_DIMENSIONS*0.125;
        float fStartY = TREASUREMAP_WINDOW_DIMENSIONS*0.875;
        if (pow(fStartX - fCrossX, 2.0) + pow(fStartY - fCrossY, 2.0) <= pow(TREASUREMAP_X_LENGTH*2.0, 2.0))
        {
            // Slide over to the bottom right corner instead
            fStartX = TREASUREMAP_WINDOW_DIMENSIONS*0.7;
        }
        jDrawListElements = JsonArrayInsert(jDrawListElements, NuiDrawListText(JsonBool(1), NuiColor(0, 0, 0, 200), NuiRect(fStartX, fStartY, 80.0, 28.0), JsonString(mpSettings.sText)));
    }



    //WriteTimestampedLogEntry("Returned " + IntToString(nPolygons) + " polygons with " + IntToString(nCoordinates/2) + " total vertices");

    return jDrawListElements;
}

void TreasureMapSwatch(object oPC)
{
    float fColumn2X = 100.0;
    float fYPerLine = 20.0;
    json jDrawListElements = JsonArray();

    int nSurfacemat;
    for (nSurfacemat=0; nSurfacemat<=22; nSurfacemat++)
    {
        json jColour = SurfacematToNuiColor(nSurfacemat);
        string sName = Get2DAString("surfacemat", "Label", nSurfacemat);

        float fXColumnOffset = nSurfacemat >= 15 ? 200.0 : 0.0;

        float fY = IntToFloat(nSurfacemat % 15) * fYPerLine;
        jDrawListElements = JsonArrayInsert(jDrawListElements, NuiDrawListText(JsonBool(1), NuiColor(0, 0, 0, 255), NuiRect(fXColumnOffset, fY, fXColumnOffset+fColumn2X, fYPerLine), JsonString(sName)));


        json jPoints = JsonArray();
        jPoints = JsonArrayInsert(jPoints, JsonFloat(fXColumnOffset+fColumn2X));
        jPoints = JsonArrayInsert(jPoints, JsonFloat(fY));

        jPoints = JsonArrayInsert(jPoints, JsonFloat(fXColumnOffset+fColumn2X + fYPerLine));
        jPoints = JsonArrayInsert(jPoints, JsonFloat(fY));

        jPoints = JsonArrayInsert(jPoints, JsonFloat(fXColumnOffset+fColumn2X + fYPerLine));
        jPoints = JsonArrayInsert(jPoints, JsonFloat(fY + fYPerLine));

        jPoints = JsonArrayInsert(jPoints, JsonFloat(fXColumnOffset+fColumn2X));
        jPoints = JsonArrayInsert(jPoints, JsonFloat(fY + fYPerLine));

        jDrawListElements = JsonArrayInsert(jDrawListElements, NuiDrawListPolyLine(JsonBool(1), jColour, JsonBool(1), JsonFloat(0.0), jPoints));
    }

    json jImage = NuiImage(JsonString("tm_metal02"), JsonInt(NUI_ASPECT_EXACTSCALED), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE));
    jImage = NuiDrawList(jImage, JsonBool(0), jDrawListElements);

    json jLayout = JsonArray();
    jLayout = JsonArrayInsert(jLayout, jImage);

    json root = NuiCol(jLayout);

    json nui = NuiWindow(
        root,
        JsonString("Treasure Map Swatch"),
        NuiBind("geometry"),
        JsonBool(FALSE), // resize
        NuiBind("collapse"), // collapse
        JsonBool(TRUE), // closable
        JsonBool(FALSE), // transparent
        JsonBool(TRUE)); // border



    int token = NuiCreate(oPC, nui, "treasuremap");
    // Testing this suggests the NUI border takes 20px on the X axis and 53px on the Y
    NuiSetBind(oPC, token, "geometry", NuiRect(-1.0, -1.0, 400.0, 25*fYPerLine));
    NuiSetBind(oPC, token, "collapse", JsonInt(0));
}


void DisplayTreasureMapUI(object oPC, int nPuzzleID, int nDifficulty, object oMap=OBJECT_INVALID)
{
    SetLocalObject(oPC, "opened_treasuremap", oMap);
    int nScale = GetPlayerDeviceProperty(oPC, PLAYER_DEVICE_PROPERTY_GUI_SCALE);
    float fScale = IntToFloat(nScale)/100.0;
    float fGeometryRectPos = -1.0;
    // prior to 8193.35 drawlists were not affected by UI scaling
    // putting things in the top left corner of the screen was the only way to see what was going on.
    if (GetPlayerBuildVersionMajor(oPC) == 8193 && GetPlayerBuildVersionMinor(oPC) < 35)
    {
        if (nScale != 100)
        {
            SendMessageToPC(oPC, "Due to an engine bug the map may not display correctly with your UI scaling. This is fixed in 8193.35 onwards. Otherwise, keeping the map close to the top left of the screen should help with this.");
            fGeometryRectPos = 0.0;
        }
    }
    
    
    // "-" may not be legal for sqlite, I don't want to find out what happens then or if it's possible to do something
    // bad to the db in this case
    if (nDifficulty < TREASUREMAP_DIFFICULTY_EASY || nDifficulty > TREASUREMAP_HIGHEST_DIFFICULTY)
    {
        return;
    }
    
    string sJsonData = "difficulty" + IntToString(nDifficulty);
    sqlquery sql = SqlPrepareQueryCampaign("tmapsolutions",
            "SELECT " + sJsonData +
            " FROM treasuremaps WHERE puzzleid = @puzzleid;");
    SqlBindInt(sql, "@puzzleid", nPuzzleID);
    SqlStep(sql);
    json jDrawListElements = SqlGetJson(sql, 0);

    json jImage = NuiWidth(NuiImage(JsonString("tm_metal02"), JsonInt(NUI_ASPECT_EXACTSCALED), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE)), IntToFloat(TREASUREMAP_WINDOW_DIMENSIONS));

    jImage = NuiDrawList(jImage, JsonBool(0), jDrawListElements);

    json jLayout = JsonArray();
    jLayout = JsonArrayInsert(jLayout, jImage);

    json jButton = NuiId(NuiHeight(NuiButton(JsonString("Dig")), 40.0), "digbutton");
    json jButtonArray = JsonArray();
    json jNoteLabel = NuiLabel(JsonString("Notes:"), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_MIDDLE));
    json jNoteField = NuiHeight(NuiWidth(NuiTextEdit(JsonString(""), NuiBind("tmap_notes"), 30, 0), 180.0), 40.0);
    
    jButtonArray = JsonArrayInsert(jButtonArray, jNoteLabel);
    jButtonArray = JsonArrayInsert(jButtonArray, jNoteField);
    jButtonArray = JsonArrayInsert(jButtonArray, jButton);
    jLayout = JsonArrayInsert(jLayout, NuiRow(jButtonArray));

    json root = NuiCol(jLayout);

    json nui = NuiWindow(
        root,
        JsonString("Treasure Map"),
        NuiBind("geometry"),
        JsonBool(FALSE), // resize
        NuiBind("collapse"), // collapse
        JsonBool(TRUE), // closable
        JsonBool(FALSE), // transparent
        JsonBool(TRUE)); // border



    int token = NuiCreate(oPC, nui, "treasuremap");
    // Testing this suggests the NUI border takes 20px on the X axis and 53px on the Y
    // Plus an extra 50px for the button...
    NuiSetBind(oPC, token, "tmap_notes", JsonString(GetLocalString(oMap, "treasuremap_notes")));
    NuiSetBind(oPC, token, "geometry", NuiRect(fGeometryRectPos, fGeometryRectPos, IntToFloat(TREASUREMAP_WINDOW_DIMENSIONS) + 20.0, IntToFloat(TREASUREMAP_WINDOW_DIMENSIONS) + 50.0 + 53.0));
    NuiSetBind(oPC, token, "collapse", JsonInt(0));
}

int CanAreaHaveTreasureMaps(object oArea)
{
    int nCR = GetLocalInt(oArea, "cr");
    if (nCR <= 0)
    {
        return FALSE;
    }
    int nVar = GetLocalInt(oArea, DISABLE_TREASUREMAPS_FOR_AREA);
    if (nVar > 0)
    {
        return FALSE;
    }
    if (GetLocalInt(oArea, ENABLE_TREASUREMAPS_FOR_AREA) <= 0)
    {
        if (!GetIsAreaNatural(oArea))
        {
            return FALSE;
        }
    }
    // Find objects with transitions attached to them
    // This function makes the fallacious assumption that an area is valid if it has a transition to any another
    // It does not consider the possibility that "islands" of disconnected areas might exist and appear valid
    object oTest = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oTest))
    {
        if (GetIsObjectValid(GetTransitionTarget(oTest)))
        {
            return TRUE;
        }
        oTest = GetNextObjectInArea(oArea);
    }
    return FALSE;
}

int IsTreasureLocationValid(location lLoc)
{
    // If this location is not walkable, discard
    int nSurfacemat = GetSurfaceMaterial(lLoc);
    int nWalkable = StringToInt(Get2DAString("surfacemat", "Walk", nSurfacemat));
    if (!nWalkable)
    {
        return FALSE;
    }
    object oArea = GetAreaFromLocation(lLoc);
    vector vLoc = GetPositionFromLocation(lLoc);

    // Check for forbid waypoints
    object oTest = GetFirstObjectInShape(SHAPE_SPHERE, TREASUREMAP_AVOID_WP_RADIUS, lLoc, FALSE, OBJECT_TYPE_WAYPOINT);
    while (GetIsObjectValid(oTest))
    {
        if (GetTag(oTest) == TREASUREMAP_AVOID_WP)
        {
            return FALSE;
        }
        oTest = GetNextObjectInShape(SHAPE_SPHERE, TREASUREMAP_AVOID_WP_RADIUS, lLoc, FALSE, OBJECT_TYPE_WAYPOINT);
    }


    int nTreeMaxDepth = GetAreaSize(AREA_WIDTH, oArea) * GetAreaSize(AREA_HEIGHT, oArea);
    //int nTreeMaxDepth = 10;

    // Try to find a way to get from the location to a transition object
    // This is usually a door or trigger
    oTest = GetFirstObjectInArea(oArea);
    int nTransitions = 0;
    int nValid = 0;
    while (GetIsObjectValid(oTest))
    {
        if (GetIsObjectValid(GetTransitionTarget(oTest)))
        {
            vector vTest = GetPosition(oTest);
            if (NWNX_Area_GetPathExists(oArea, vLoc, vTest, nTreeMaxDepth))
            {
                //SendMessageToPC(GetFirstPC(), "Path to " + GetName(oTest) + " type " + IntToString(GetObjectType(oTest)) + " at " + tmVectorToString(vTest));
                nValid++;
            }
            nTransitions++;
        }
        oTest = GetNextObjectInArea(oArea);
    }
    //SendMessageToPC(GetFirstPC(), "Valid = " + IntToString(nValid) + " of " + IntToString(nTransitions));
    float fProportion = IntToFloat(nValid)/IntToFloat(nTransitions);
    if (nTransitions > 0 && fProportion > 0.5)
    {
        return TRUE;
    }
    return FALSE;
}

location GetRandomValidTreasureLocationInArea(object oArea)
{
    int nWidth = GetAreaSize(AREA_WIDTH, oArea);
    int nHeight = GetAreaSize(AREA_HEIGHT, oArea);
    float fRealWidth = 10.0 * IntToFloat(nWidth);
    float fRealHeight = 10.0 * IntToFloat(nHeight);
    int nAreaTiles = nWidth * nHeight;
    int nSpawnAttempts = 3000;
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
        lTest = Location(oArea, Vector(fX, fY, fZ), 0.0);
        if (IsTreasureLocationValid(lTest))
        {
            return lTest;
        }
    }
    WriteTimestampedLogEntry("ERROR: Failed to find a valid puzzle location in " + GetResRef(oArea));
    location lInvalid;
    return lInvalid;
}

// Do all the necessary steps to seed treasure maps at lLoc.
void CreateNewTreasureMapPuzzleAtLocation(location lLoc)
{
    // What this actually does is create a row with the location data and then
    // uses CalculateTreasureMaps to populate the json
    int i;
    string sQuery = "CREATE TABLE IF NOT EXISTS treasuremaps (" +
        "puzzleid INTEGER PRIMARY KEY, " +
        "areatag TEXT, " +
        "position TEXT, " +
        "tilehash INTEGER, " +
        "minacr INTEGER";

    for (i=TREASUREMAP_DIFFICULTY_EASY; i<=TREASUREMAP_HIGHEST_DIFFICULTY; i++)
    {
        sQuery = sQuery + ", difficulty" + IntToString(i) + " TEXT";
    }
    sQuery = sQuery + ");";
    
    // Indexing: we do the following:
    // select jsondata<difficulty where puzzleid=? (when opening a map)
    // select areatag, position where puzzleid=? (when digging for maps)
    // select puzzleid, areatag where minacr<=? and areatag in (???) (when making a map near an are)
    // select puzzleid, areatag where minacr<=? (when making a map in a random area)
    
    sqlquery sql = SqlPrepareQueryCampaign("tmapsolutions", sQuery);
    SqlStep(sql);
    
    sql = SqlPrepareQueryCampaign("tmapsolutions",
        "CREATE INDEX IF NOT EXISTS idx_minacr ON treasuremaps(minacr);");
    SqlStep(sql);
    sql = SqlPrepareQueryCampaign("tmapsolutions",
        "CREATE INDEX IF NOT EXISTS idx_minacr_areatag ON treasuremaps(minacr, areatag);");
    SqlStep(sql);
    sql = SqlPrepareQueryCampaign("tmapsolutions",
        "CREATE INDEX IF NOT EXISTS idx_puzzleid ON treasuremaps(puzzleid);");
    SqlStep(sql);


    object oArea = GetAreaFromLocation(lLoc);
    int nMinAcr = GetLocalInt(oArea, "cr");
    if (nMinAcr < TREASUREMAP_ACR_MIN)
    {
        nMinAcr = TREASUREMAP_ACR_MIN;
    }

    sql = SqlPrepareQueryCampaign("tmapsolutions",
        "INSERT INTO treasuremaps " +
        "(areatag, position, minacr) " +
        "VALUES (@areatag, @position, @minacr);");
    SqlBindString(sql, "@areatag", GetResRef(oArea));
    SqlBindVector(sql, "@position", GetPositionFromLocation(lLoc));
    SqlBindInt(sql, "@minacr", nMinAcr);
    SqlStep(sql);

    sql = SqlPrepareQueryCampaign("tmapsolutions", "SELECT LAST_INSERT_ROWID()");
    SqlStep(sql);
    int nPuzzleID = SqlGetInt(sql, 0);
    WriteTimestampedLogEntry("New puzzle id: " + IntToString(nPuzzleID));
    CalculateTreasureMaps(nPuzzleID);
}

void CalculateTreasureMaps(int nPuzzleID)
{
    sqlquery sql = SqlPrepareQueryCampaign("tmapsolutions", "SELECT position, areatag FROM treasuremaps WHERE puzzleid = @puzzleid;");
    SqlBindInt(sql, "@puzzleid", nPuzzleID);
    SqlStep(sql);
    vector vLoc = SqlGetVector(sql, 0);
    string sAreaTag = SqlGetString(sql, 1);
    object oArea;
    int n = 0;
    while (TRUE)
    {
        oArea = GetObjectByTag(sAreaTag, n);
        if (GetArea(oArea) == oArea)
        {
            break;
        }
        if (!GetIsObjectValid(oArea))
        {
            return;
        }
        n++;
    }

    // Small buffer of empty space is allowed
    int nAreaX = 3 + (10*GetAreaSize(AREA_WIDTH, oArea));
    int nAreaY = 3 + (10*GetAreaSize(AREA_HEIGHT, oArea));
    int nAverageAreaDim = (nAreaX + nAreaY)/2;
    int nEdgeRealWorldSize = nAverageAreaDim;
    if (nEdgeRealWorldSize < 30)
    {
        if (nAreaX > nEdgeRealWorldSize)
        {
            nEdgeRealWorldSize = nAreaX;
        }
        if (nAreaY > nEdgeRealWorldSize)
        {
            nEdgeRealWorldSize = nAreaY;
        }
        if (nEdgeRealWorldSize < 30)
        {
            nEdgeRealWorldSize = 30;
        }
    }
    if (nEdgeRealWorldSize > 180)
    {
        nEdgeRealWorldSize = 180;
    }
    // Underdark disables your minimap
    // Text hints may be enough
    //if (GetLocalInt(oArea, "underdark") > 0)
    //{
    //    nEdgeRealWorldSize += (nEdgeRealWorldSize/2);
    //}
    float fInterval = 1.5;
    int nRealScanCount = 100;
    fInterval = IntToFloat(nEdgeRealWorldSize)/IntToFloat(nRealScanCount);
    if (fInterval < 0.7)
    {
        fInterval = 0.7;
        nRealScanCount = FloatToInt(IntToFloat(nEdgeRealWorldSize)/fInterval);
    }

    //WriteTimestampedLogEntry("Scanning has " + IntToString(nRealScanCount) + " intervals");
    location lLoc = Location(oArea, vLoc, 0.0);
    vector vScanAdjustment = GetVectorToMoveScanLocationWithinAreaBounds(lLoc, nRealScanCount, nRealScanCount, fInterval);
    vector vPosScan = vLoc + vScanAdjustment;
    //WriteTimestampedLogEntry("Adjust scan loc " + tmVectorToString(vLoc) + " by " + tmVectorToString(vScanAdjustment) + ", now " + tmVectorToString(vPosScan));
    location lLocScan = Location(oArea, vPosScan, 0.0);
    NWNX_Util_SetInstructionsExecuted(0);
    TreasureMapScanLocation(lLocScan, nRealScanCount, nRealScanCount, fInterval);

    struct MapProcessingSettings mpSettings;
    mpSettings.sText = GetLocalString(oArea, TREASUREMAP_AREA_TEXT);
    mpSettings.MAPDATA_AREA_CULL_THRESHOLD_PROPORTION = 0.002;
    mpSettings.MAPDATA_MINIMUM_AREA_CULL_THRESHOLD = 12.0;


    int nCurrentDifficulty;
    for (nCurrentDifficulty=TREASUREMAP_DIFFICULTY_EASY; nCurrentDifficulty<=TREASUREMAP_HIGHEST_DIFFICULTY; nCurrentDifficulty++)
    {
        float fProportionRemoved = 0.0;
        if (nCurrentDifficulty == TREASUREMAP_DIFFICULTY_EASY) { fProportionRemoved = TREASUREMAP_PROPORTION_DISTANCE_REMOVED_EASY; }
        else if (nCurrentDifficulty == TREASUREMAP_DIFFICULTY_MEDIUM) { fProportionRemoved = TREASUREMAP_PROPORTION_DISTANCE_REMOVED_MEDIUM; }
        else if (nCurrentDifficulty == TREASUREMAP_DIFFICULTY_HARD) { fProportionRemoved = TREASUREMAP_PROPORTION_DISTANCE_REMOVED_HARD; }
        else if (nCurrentDifficulty == TREASUREMAP_DIFFICULTY_MASTER) { fProportionRemoved = TREASUREMAP_PROPORTION_DISTANCE_REMOVED_MASTER; }
        int nNumFewerScansForThisDifficulty = FloatToInt(fProportionRemoved * IntToFloat(nRealScanCount));
        int nScanCountForThisDifficulty = nRealScanCount - nNumFewerScansForThisDifficulty;
        //WriteTimestampedLogEntry("Scancount: " + IntToString(nRealScanCount) + " - " + IntToString(nNumFewerScansForThisDifficulty) + " -> " + IntToString(nScanCountForThisDifficulty));

        // We calculated the offset for the scan based on the MAXIMUM scan distance
        // there is no guarantee that it's the same with the reduced scan count due to difficulty increase...
        vector vOffsetForThisDifficulty = GetVectorToMoveScanLocationWithinAreaBounds(lLoc, nScanCountForThisDifficulty, nScanCountForThisDifficulty, fInterval);
        vector vOffsetFromScanCentreForThisDifficulty = vPosScan - (vLoc + vOffsetForThisDifficulty);

        // ProcessMapData takes two variables per axis
        // 1)   Ending interval index.
        //      Easy to calc when we know the start.
        // 2)   Number of intervals at the start of map data to ignore.
        //      If there was no offset, we'd split the reduced interval count in 2 and take it off both sides.
        //      Now that there is an offset, we have to calc this more carefully.

        //      We know the vector (in game metres) that maps the location we would scan at
        //      if we were using this reduced number of intervals
        //      to the vector we actually did the scanning at.

        //      It should be possible to convert that to a number of checks by dividing it by fInterval
        //      and hopefully adding this to the value that would be used if we didn't have to adjust at all

        // The negation here in the x axis seems to fix some left/right mirroring issues.
        // I'm assuming has to do with the fact that y axis was inverted at some point scanning but x wasn't
        // but my brain is fried and my mathematical reasoning is failing me
        int nOffsetIntervalsX = FloatToInt(-vOffsetFromScanCentreForThisDifficulty.x/fInterval);
        int nOffsetIntervalsY = FloatToInt(vOffsetFromScanCentreForThisDifficulty.y/fInterval);

        int nNonOffsetIntervalCount = nNumFewerScansForThisDifficulty/2;


        //WriteTimestampedLogEntry("vOffsetFromScanCentreForThisDifficulty " + tmVectorToString(vOffsetFromScanCentreForThisDifficulty));

        // Same deal with negating the x axis adjustment
        mpSettings.fCrossOffsetX = -(vScanAdjustment.x - vOffsetFromScanCentreForThisDifficulty.x)/fInterval;
        mpSettings.fCrossOffsetY = (vScanAdjustment.y - vOffsetFromScanCentreForThisDifficulty.y)/fInterval;

        mpSettings.MAPDATA_MINIMUM_POLYGON_AREA = 0.02 / IntToFloat(nScanCountForThisDifficulty);

        int nStartIntervalX = nNonOffsetIntervalCount+nOffsetIntervalsX;
        int nStartIntervalY = nNonOffsetIntervalCount+nOffsetIntervalsY;

        //WriteTimestampedLogEntry("Process map data: X = " + IntToString(nStartIntervalX) + " to " + IntToString(nStartIntervalX+nScanCountForThisDifficulty) + ", Y = " + IntToString(nStartIntervalY) + " to " + IntToString(nStartIntervalY+nScanCountForThisDifficulty));

        // This will be very very prone to TMI
        NWNX_Util_SetInstructionsExecuted(0);

        json jDrawListElements = ProcessTreasureMapData(nStartIntervalX+nScanCountForThisDifficulty, nStartIntervalY+nScanCountForThisDifficulty, nStartIntervalX, nStartIntervalY, mpSettings);

        string sJsonFieldName = "difficulty" + IntToString(nCurrentDifficulty);
        sql = SqlPrepareQueryCampaign("tmapsolutions",
        "UPDATE treasuremaps " +
        "SET " + sJsonFieldName + " = @value " +
        "WHERE puzzleid = @puzzleid;");

        SqlBindJson(sql, "@value", jDrawListElements);
        SqlBindInt(sql, "@puzzleid", nPuzzleID);
        SqlStep(sql);
    }

    // Save area tile hash
    int nTileHash = GetAreaTileHash(oArea);
    sql = SqlPrepareQueryCampaign("tmapsolutions",
        "UPDATE treasuremaps " +
        "SET tilehash = @value " +
        "WHERE puzzleid = @puzzleid;");
    SqlBindInt(sql, "@value", nTileHash);
    SqlBindInt(sql, "@puzzleid", nPuzzleID);
    SqlStep(sql);
}

int GetTreasureMapGoldValue(int nACR)
{
    // This is set very roughly to the value of one item from these
    int nValue = 50 + (20 * nACR);
    if (nACR >= 12) { nValue += (nACR*11) ; }
    else if (nACR >= 9) { nValue += (nACR * 8); }
    else if (nACR >= 6) { nValue += (nACR * 2); }

    // Then multiply up by a bit...
    nValue *= 6;
    return nValue;
}

void SetTreasureMapDifficulty(object oMap, int nDifficulty)
{
    SetLocalInt(oMap, "difficulty", nDifficulty);
}

int GetTreasureMapDifficulty(object oMap)
{
    return GetLocalInt(oMap, "difficulty");
}

void InitialiseTreasureMap(object oMap, int nACR, string sExtraDesc="")
{
    if (nACR > TREASUREMAP_ACR_MAX)
    {
        nACR = TREASUREMAP_ACR_MAX;
    }
    if (nACR < TREASUREMAP_ACR_MIN)
    {
        nACR = TREASUREMAP_ACR_MIN;
    }

    int nValue = GetTreasureMapGoldValue(nACR);

    int nBaseValue = NWNX_Item_GetBaseGoldPieceValue(oMap);
    NWNX_Item_SetAddGoldPieceValue(oMap, nValue - nBaseValue);
    SetLocalInt(oMap, "acr", nACR);
    SetDescription(oMap, "");
    if (sExtraDesc != "")
    {
        string sDesc = GetDescription(oMap);
        sDesc += "\n\n" + sExtraDesc;
        SetDescription(oMap, sDesc);
    }
    int nRoll = d100();
    if (nRoll <= 31) { SetTreasureMapDifficulty(oMap, TREASUREMAP_DIFFICULTY_EASY); }
    else if (nRoll <= 62) { SetTreasureMapDifficulty(oMap, TREASUREMAP_DIFFICULTY_MEDIUM); }
    else if (nRoll <= 93) { SetTreasureMapDifficulty(oMap, TREASUREMAP_DIFFICULTY_HARD); }
    else { SetTreasureMapDifficulty(oMap, TREASUREMAP_DIFFICULTY_MASTER); }
}

void AssignNewPuzzleToMap(object oMap, object oNearbyArea, int bNearby)
{
    int nACR = GetLocalInt(oMap, "acr");
    if (nACR < TREASUREMAP_ACR_MIN)
    {
        SetLocalInt(oMap, "acr", nACR);
        nACR = TREASUREMAP_ACR_MIN;
    }
    
    if (bNearby && GetIsObjectValid(oNearbyArea))
    {
        int nDist = TREASUREMAP_NEARBY_START_DISTANCE;
        while (Random(100) < TREASUREMAP_START_DISTANCE_INCREASE_CHANCE)
        {
            nDist += TREASUREMAP_START_DISTANCE_INCREASE_AMOUNT;
        }
        json jAreaTags = GetAreasWithinDistance(oNearbyArea, nDist);
        int nLength = JsonGetLength(jAreaTags);
        int nValidAreas = 0;
        int i;
        json jValid = JsonArray();
        string sAreas = "";
        for (i=0; i<nLength; i++)
        {
            object oArea = GetObjectByTag(JsonGetString(JsonArrayGet(jAreaTags, i)));
            if (CanAreaHaveTreasureMaps(oArea) && GetLocalInt(oArea, "cr") <= nACR)
            {
                jValid = JsonArrayInsert(jValid, JsonArrayGet(jAreaTags, i));
                nValidAreas++;
                sAreas = sAreas + "'" + JsonGetString(JsonArrayGet(jAreaTags, i)) + "',";
            }
        }
        // If there aren't enough possible areas this will probably be too easy
        // so in that case just go full random
        if (nValidAreas < 5)
        {
            AssignNewPuzzleToMap(oMap, OBJECT_INVALID, FALSE);
            return;
        }
        
        // Remove trailing comma
        sAreas = GetStringLeft(sAreas, GetStringLength(sAreas)-1);
        
        
        
        string sQuery = "SELECT puzzleid, areatag FROM treasuremaps WHERE minacr <= @minacr AND areatag in (" + sAreas + ") " +
        "ORDER BY RANDOM() LIMIT 1;";
        sqlquery sql = SqlPrepareQueryCampaign("tmapsolutions", sQuery);
        SqlBindInt(sql, "@minacr", nACR);
        if (SqlStep(sql))
        {           
            int nPuzzleID = SqlGetInt(sql, 0);
            SendDebugMessage("Picked area tag = " + SqlGetString(sql, 1));
            SetLocalInt(oMap, "puzzleid", nPuzzleID);
        }
        else
        {
            SendDebugMessage("Failed to get a map in this area list, going random");
            // In theory this should not be possible
            AssignNewPuzzleToMap(oMap, OBJECT_INVALID, FALSE);
        }
    }
    else
    {
        string sQuery = "SELECT puzzleid " +
        "FROM treasuremaps WHERE minacr <= @minacr " +
        "ORDER BY RANDOM() LIMIT 1;";
        sqlquery sql = SqlPrepareQueryCampaign("tmapsolutions", sQuery);
        SqlBindInt(sql, "@minacr", nACR);
        SqlStep(sql);
        int nPuzzleID = SqlGetInt(sql, 0);
        SetLocalInt(oMap, "puzzleid", nPuzzleID);
    }
}

void UseTreasureMap(object oMap)
{
    int nACR = GetLocalInt(oMap, "acr");
    int nDifficulty = GetLocalInt(oMap, "difficulty");
    // Update legacy maps that were made before the difficulty bands were a thing
    if (nDifficulty == 0)
    {
        if (nACR == 15) { nDifficulty = TREASUREMAP_DIFFICULTY_MASTER; }
        else if (nACR > 10) { nDifficulty = TREASUREMAP_DIFFICULTY_HARD; }
        else if (nACR > 6) { nDifficulty = TREASUREMAP_DIFFICULTY_MEDIUM; }
        else { nDifficulty = TREASUREMAP_DIFFICULTY_EASY; }
        SetLocalInt(oMap, "difficulty", nDifficulty);
        
    }
    int nPuzzleID = GetLocalInt(oMap, "puzzleid");
    string sAreaTag = "";
    int nAssignPuzzle = 1;
    if (nPuzzleID > 0)
    {
        // Ensure existing data is good and usable
        if (GetIsObjectValid(GetAreaFromLocation(GetPuzzleSolutionLocation(nPuzzleID))))
        {
            // Solution exists and is valid.
            // Just check the puzzle's ACR fits with the map's
            string sQuery = "SELECT minacr " +
                "FROM treasuremaps WHERE puzzleid <= @puzzleid";
            sqlquery sql = SqlPrepareQueryCampaign("tmapsolutions", sQuery);
            SqlBindInt(sql, "@puzzleid", nPuzzleID);
            SqlStep(sql);
            int nMinACR = SqlGetInt(sql, 0);
            if (nMinACR <= nACR)
            {
                nAssignPuzzle = 0;
            }
        }
    }
    if (nAssignPuzzle)
    {
        AssignNewPuzzleToMap(oMap, OBJECT_INVALID, 0);
        nPuzzleID = GetLocalInt(oMap, "puzzleid");
    }
    DisplayTreasureMapUI(GetItemPossessor(oMap), nPuzzleID, nDifficulty, oMap);
}

location GetPuzzleSolutionLocation(int nPuzzleID)
{
    if (nPuzzleID > 0)
    {
        sqlquery sql = SqlPrepareQueryCampaign("tmapsolutions",
                "SELECT areatag, position" +
                " FROM treasuremaps WHERE puzzleid = @puzzleid;");
        SqlBindInt(sql, "@puzzleid", nPuzzleID);
        SqlStep(sql);
        string sAreaTag = SqlGetString(sql, 0);
        vector vPos = SqlGetVector(sql, 1);

        object oArea;
        int n=0;
        while (TRUE)
        {
            oArea = GetObjectByTag(sAreaTag, n);
            n++;
            if (!GetIsObjectValid(oArea))
            {
                location lInvalid;
                return lInvalid;
            }
            if (GetArea(oArea) == oArea)
            {
                break;
            }
        }

        return Location(oArea, vPos, 0.0);
    }
    location lOut;
    return lOut;
}

string tmVectorToString(vector vVec)
{
    string sOut = "Vector(" + FloatToString(vVec.x) + ", " + FloatToString(vVec.y) +  "," + FloatToString(vVec.z) + ")";
    return sOut;
}

// Roll the probabilties for a treasure map drop from a random creature or placeable.
// True if one should drop, F if not
int RollForTreasureMap(object oSource=OBJECT_SELF)
{
    object oArea = GetArea(oSource);
    int nChance = TREASURE_MAP_CHANCE;
    if (GetLocalInt(oSource, "boss"))
    {
        nChance *= TREASURE_MAP_BOSS_MULTIPLIER;
    }
    else if (GetLocalInt(oSource, "semiboss"))
    {
        nChance *= TREASURE_MAP_SEMIBOSS_MULTIPLIER;
    }
    else
    {
        // Not from low treasures
        if (GetLocalString(oSource, "treasure") == "low")
        {
            return 0;
        }
    }



    float fAreaMultiplier = GetLocalFloat(oArea, AREA_TREASURE_MAP_MULTIPLIER);
    if (fAreaMultiplier != 0.0)
    {
        nChance = FloatToInt(IntToFloat(nChance) * fAreaMultiplier);
    }
    if (Random(1000) < nChance)
    {
        return 1;
    }
    return 0;
}

int DoesLocationCompleteMap(object oMap, location lTest)
{
    int nPuzzleID = GetLocalInt(oMap, "puzzleid");
    if (nPuzzleID >= 0)
    {
        if (GetTreasureMapDifficulty(oMap) > 0)
        {
            location lSolution = GetPuzzleSolutionLocation(nPuzzleID);
            if (GetIsObjectValid(GetAreaFromLocation(lSolution)))
            {
                if (GetAreaFromLocation(lSolution) == GetAreaFromLocation(lTest))
                {
                    float fDist = TREASUREMAP_LOCATION_TOLERANCE;
                    object oPC = GetItemPossessor(oMap);
                    float fSearch = IntToFloat(GetSkillRank(SKILL_SEARCH, oPC));
                    fDist = fDist + (fSearch * 0.05 * fDist);
                    if (GetDistanceBetweenLocations(lSolution, lTest) <= fDist)
                    {
                        if (!CanSavePCInfo(oPC))
                        {
                            FloatingTextStringOnCreature("You find some treasure, but cannot dig it up while polymorphed.", oPC, FALSE);
                            DelayCommand(6.0, FloatingTextStringOnCreature("You find some treasure, but cannot dig it up while polymorphed.", oPC, FALSE));
                            return 0;
                        }
                        return 1;
                    }
                }
            }
        }
    }
    return 0;
}

object SetupProgenitorTreasureMap(int nObjectACR, object oNearbyArea, int bNearby, string sExtraDesc="")
{
    // Treasure generation expects a valid OID to copy that's in a system area
    // I guess we give it one
    object oModule = GetModule();
    object oProgenitor = GetLocalObject(oModule, "seed_treasure_map");
    if (!GetIsObjectValid(oProgenitor))
    {
        location lProgenitor = Location(GetObjectByTag("_TREASURE"), Vector(2.0, 0.0, 0.0), 0.0);
        oProgenitor = CreateObject(OBJECT_TYPE_ITEM, "treasuremap", lProgenitor, FALSE, "treasuremap");
        SetIdentified(oProgenitor, TRUE);
        SetLocalObject(oModule, "seed_treasure_map", oProgenitor);
        if (!GetIsObjectValid(oProgenitor))
        {
            WriteTimestampedLogEntry("ERROR: couldn't make seed treasure map");
        }
    }
    if (GetIsObjectValid(oNearbyArea))
    {
        sExtraDesc = "This map was obtained in " + GetName(oNearbyArea) + ". " + sExtraDesc;
    }
    InitialiseTreasureMap(oProgenitor, nObjectACR, sExtraDesc);
    AssignNewPuzzleToMap(oProgenitor, oNearbyArea, bNearby);
    return oProgenitor;
}


// Do RollForTreasureMap and, if one is generated set up the staging map and return its OID
// return OBJECT_INVALID if nothing was generated
object MaybeGenerateTreasureMap(int nObjectACR)
{
    if (!RollForTreasureMap())
    {
        return OBJECT_INVALID;
    }

    string sLocation = GetName(GetArea(OBJECT_SELF));

    return SetupProgenitorTreasureMap(nObjectACR, GetArea(OBJECT_SELF), Random(100) < TREASUREMAP_CHANCE_FOR_RANDOM_LOCATION ? 0 : 1);
}

void CompleteTreasureMap(object oMap)
{
    ExecuteScript("tmap_complete", oMap);
}

int GetIsSurfacematDiggable(int nSurfacemat)
{
    if (nSurfacemat == 4 || // stone
        nSurfacemat == 10 || // metal
        nSurfacemat == 22 || // stonebridge
        nSurfacemat == 9 || // carpet
        nSurfacemat == 5) //wood
    {
        return 0;
    }
    return 1;
}

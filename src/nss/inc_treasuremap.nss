#include "nwnx_area"
#include "nwnx_util"
#include "nw_inc_nui"

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
const int TREASUREMAP_ACR_STEP = 3;

// An eligible area will have ((width in tiles * height in tiles) * this number) of possible map locations made for it.
// At least 1 location will be made for any eligible area.
//const float TREASUREMAP_SEED_DENSITY = 0.025;
const float TREASUREMAP_SEED_DENSITY = 0.00000001;

// How close you have to get to the true location to count as getting your treasure.
const float TREASUREMAP_LOCATION_TOLERANCE = 5.0;

// What proportion of mapped distance is omitted per increasing ACR
// Lowest ACR (TREASUREMAP_ACR_MIN) will display all of the scanned region.
// Each ACR above that loses ((this ACR - TREASUREMAP_ACR_MIN) * this constant)
const float TREASUREMAP_PROPORTION_DISTANCE_REMOVED_PER_ACR = 0.04;

// Set a local int on an area with any positive nonzero value to make treasuremap destinations not be generated there
const string DISABLE_TREASUREMAPS_FOR_AREA = "notreasuremaps";
// Set a local int on an area to include it in treasure maps regardless of its natural/artifical status
const string ENABLE_TREASUREMAPS_FOR_AREA = "treasuremaps";

// Area string var: if set, this text will be overlayed on the bottom left corner of maps
// (this is used to make the underdark areas completable, having to search the WHOLE UD is virtually impossible)
const string TREASUREMAP_AREA_TEXT = "treasuremaptext";

// Parameters for X marks the spot
const float TREASUREMAP_X_LENGTH = 20.0;
const float TREASUREMAP_X_WIDTH = 4.0;


/////////////////////
// External functions
/////////////////////

// Return a hash of an area's tiles.
// This should change only when someone messes with tiles or tilelights in the toolset.
int GetAreaTileHash(object oArea);

// Opens a treasure map display for oPC.
// Displays the given map ID at the given ACR.
// Nothing happens if these are invalid.
void DisplayTreasureMapUI(object oPC, int nPuzzleID, int nACR);

// Initialise a treasure map.
// Assigns it a map ID and records its corresponding puzzle ID.
// Calling this with values already set will ensure they are still good to use.
void InitialiseTreasureMap(object oMap, int nACR);


// A wrapper for DisplayTreasureMapUI that instead operates off a map item.
object DisplayTreasureMapUIFromMapItem(object oPC, object oItem);

// Return the solution location for nPuzzleID.
location GetPuzzleSolutionLocation(int nPuzzleID);

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
	if (nSurfacemat == 0) { return NuiColor(100, 100, 100, TREASUREMAP_OVERLAY_OPACITY); }	// walls
	if (nSurfacemat == 1) { return NuiColor(200, 160, 110, TREASUREMAP_OVERLAY_OPACITY); }	// Dirt
	if (nSurfacemat == 2) { return NuiColor(155, 155, 155, TREASUREMAP_OVERLAY_OPACITY); }	// "Obscuring"
	if (nSurfacemat == 3) { return NuiColor(70, 130, 70, TREASUREMAP_OVERLAY_OPACITY); }	// Grass - light green
	if (nSurfacemat == 4) { return NuiColor(200, 200, 200, TREASUREMAP_OVERLAY_OPACITY); }	// Stone - grey
	if (nSurfacemat == 5) { return NuiColor(220, 200, 135, TREASUREMAP_OVERLAY_OPACITY); }	// Wood
	if (nSurfacemat == 6) { return NuiColor(110, 150, 230, TREASUREMAP_OVERLAY_OPACITY); }	// Walkable water - light blue
	if (nSurfacemat == 7) { return NuiColor(215, 255, 255, TREASUREMAP_OVERLAY_OPACITY); }	// "nonwalk" - pale cyan
	if (nSurfacemat == 8) { return NuiColor(225, 225, 225, TREASUREMAP_OVERLAY_OPACITY); }	// "transparent" - pale grey
	if (nSurfacemat == 9) { return NuiColor(250, 215, 165, TREASUREMAP_OVERLAY_OPACITY); }	// Carpet - pale orange
	if (nSurfacemat == 10) { return NuiColor(185, 185, 185, TREASUREMAP_OVERLAY_OPACITY); }	// Metal - grey, slightly darker than stone
	if (nSurfacemat == 11) { return NuiColor(170, 215, 255, TREASUREMAP_OVERLAY_OPACITY); }	// Puddle - lighter than walkable water
	if (nSurfacemat == 12) { return NuiColor(85, 150, 135, TREASUREMAP_OVERLAY_OPACITY); }	// Swamp - dark turquoise
	if (nSurfacemat == 13) { return NuiColor(135, 130, 100, TREASUREMAP_OVERLAY_OPACITY); }	// Mud - mid brown
	if (nSurfacemat == 14) { return NuiColor(75, 115, 80, TREASUREMAP_OVERLAY_OPACITY); }	// Leaves - darker green than grass
	if (nSurfacemat == 15) { return NuiColor(125, 0, 0, TREASUREMAP_OVERLAY_OPACITY); }	    // Lava - dark red
	if (nSurfacemat == 16) { return NuiColor(0, 0, 0, TREASUREMAP_OVERLAY_OPACITY); }	    // Bottomless pit - black
	if (nSurfacemat == 17) { return NuiColor(20, 75, 160, TREASUREMAP_OVERLAY_OPACITY); }	// Deep water - dark blue
	if (nSurfacemat == 18) { return NuiColor(220, 200, 135, TREASUREMAP_OVERLAY_OPACITY); }	// Door - as wood
	if (nSurfacemat == 19) { return NuiColor(255, 255, 255, TREASUREMAP_OVERLAY_OPACITY); }	// Snow - white
	if (nSurfacemat == 20) { return NuiColor(240, 200, 0, TREASUREMAP_OVERLAY_OPACITY); }	// Sand - dark orange
	if (nSurfacemat == 21) { return NuiColor(215, 255, 255, TREASUREMAP_OVERLAY_OPACITY); }	// "Barebones" - also pale cyan
	if (nSurfacemat == 22) { return NuiColor(200, 200, 200, TREASUREMAP_OVERLAY_OPACITY); }	// "Stonebridge" - as stone
	if (nSurfacemat == -1) { return NuiColor(0, 0, 0, TREASUREMAP_OVERLAY_OPACITY); }	// invalid (edge of map) - black
	
	return NuiColor(255, 100, 100, TREASUREMAP_OVERLAY_OPACITY); // Unknown - Bright pink?
}


void TreasureMapScanLocation(location lLoc, int nWidth, int nHeight, float fDistPerPoint=1.0)
{
	vector vPos = GetPositionFromLocation(lLoc);
	object oArea = GetAreaFromLocation(lLoc);
	object oModule = GetModule();
	vector vStart = Vector(vPos.x - (fDistPerPoint * (nWidth/2)), vPos.y - (fDistPerPoint * (nHeight/2)), 0.0);
	int x, y;
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
			SetLocalInt(oModule, "map_" + IntToString(x) + "_" + IntToString(y2), nSurfacemat);
            //WriteTimestampedLogEntry("Scan " + IntToString(x) + ", " +  IntToString(y2) + " = " + IntToString(nSurfacemat));;
		}
	}
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
    float fMidX = IntToFloat(nEndX - nStartX)/2;
    float fMidY = IntToFloat(nEndY - nStartY)/2;
    
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
    
    for (i=0; i<2; i++)
    {
        json jVertices = JsonArray();
        float fRotation = IntToFloat((i*90) + 45 + Random(17) - 8);
        // I'm pretty sure fMidX * fPixelsPerSampleX is a complicated way to write TREASUREMAP_WINDOW_DIMENSIONS/2
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
        float fStartX = TREASUREMAP_WINDOW_DIMENSIONS*0.125;
        float fStartY = TREASUREMAP_WINDOW_DIMENSIONS*0.875;
        jDrawListElements = JsonArrayInsert(jDrawListElements, NuiDrawListText(JsonBool(1), NuiColor(0, 0, 0, 200), NuiRect(fStartX, fStartY, 50.0, 20.0), JsonString(mpSettings.sText)));
    }
    
    
    
    //WriteTimestampedLogEntry("Returned " + IntToString(nPolygons) + " polygons with " + IntToString(nCoordinates/2) + " total vertices");
    
    return jDrawListElements;
}


void DisplayTreasureMapUI(object oPC, int nPuzzleID, int nACR)
{	
    // - may not be legal for sqlite, I don't want to find out what happens then
    if (nACR < 0)
    {
        return;
    }
    nACR = (nACR/TREASUREMAP_ACR_STEP)*TREASUREMAP_ACR_STEP;
    string sJsonData = "json" + IntToString(nACR);
	sqlquery sql = SqlPrepareQueryCampaign("tmapsolutions",
            "SELECT " + sJsonData +
            " FROM treasuremaps WHERE puzzleid = @puzzleid;");
    SqlBindInt(sql, "@puzzleid", nPuzzleID);
    SqlStep(sql);
    json jDrawListElements = SqlGetJson(sql, 0);
    
	json jImage = NuiImage(JsonString("tm_metal02"), JsonInt(NUI_ASPECT_EXACTSCALED), JsonInt(NUI_HALIGN_CENTER), JsonInt(NUI_VALIGN_MIDDLE));
	
	jImage = NuiDrawList(jImage, JsonBool(0), jDrawListElements);
	
	json jLayout = JsonArray();
	jLayout = JsonArrayInsert(jLayout, jImage);
	
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
	NuiSetBind(oPC, token, "geometry", NuiRect(-1.0, -1.0, IntToFloat(TREASUREMAP_WINDOW_DIMENSIONS) + 20.0, IntToFloat(TREASUREMAP_WINDOW_DIMENSIONS) + 53.0));
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
    int nTreeMaxDepth = 100*GetAreaSize(AREA_WIDTH, oArea) * GetAreaSize(AREA_HEIGHT, oArea);
    
    // Try to find a way to get from the location to a transition object
    // This is usually a door or trigger
    object oTest = GetFirstObjectInArea(oArea);
    while (GetIsObjectValid(oTest))
    {
        if (GetIsObjectValid(GetTransitionTarget(oTest)))
        {
            vector vTest = GetPosition(oTest);
            if (NWNX_Area_GetPathExists(oArea, vLoc, vTest, nTreeMaxDepth))
            {
                return TRUE;
            }
        }
        oTest = GetNextObjectInArea(oArea);
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
        
    for (i=TREASUREMAP_ACR_MIN; i<=TREASUREMAP_ACR_MAX; i++)
    {
        sQuery = sQuery + ", json" + IntToString(i) + " TEXT";
    }
    sQuery = sQuery + ");";
        
    sqlquery sql = SqlPrepareQueryCampaign("tmapsolutions", sQuery);
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
    
    location lLoc = Location(oArea, vLoc, 0.0);
    
    int nAreaX = GetAreaSize(AREA_WIDTH, oArea);
    int nAreaY = GetAreaSize(AREA_HEIGHT, oArea);
    int nAverageAreaDim = (10*(nAreaX + nAreaY))/2;
    int nEdgeRealWorldSize = nAverageAreaDim;
    if (nEdgeRealWorldSize < 30)
    {
        if ((nAreaX*10) > nEdgeRealWorldSize)
        {
            nEdgeRealWorldSize = nAreaX*10;
        }
        if ((nAreaY*10) > nEdgeRealWorldSize)
        {
            nEdgeRealWorldSize = nAreaY*10;
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
    NWNX_Util_SetInstructionsExecuted(0);
    TreasureMapScanLocation(lLoc, nRealScanCount, nRealScanCount, fInterval);
    
    struct MapProcessingSettings mpSettings;
    mpSettings.sText = GetLocalString(oArea, TREASUREMAP_AREA_TEXT);
    mpSettings.MAPDATA_AREA_CULL_THRESHOLD_PROPORTION = 0.002;
    mpSettings.MAPDATA_MINIMUM_AREA_CULL_THRESHOLD = 12.0;
    
    int nAreaCR = GetLocalInt(oArea, "cr");
    if (nAreaCR < TREASUREMAP_ACR_MIN) { nAreaCR = TREASUREMAP_ACR_MIN; }
    if (nAreaCR > TREASUREMAP_ACR_MAX) { nAreaCR = TREASUREMAP_ACR_MAX; }
    
    // Go to the first possible step
    nAreaCR = (nAreaCR/TREASUREMAP_ACR_STEP)*TREASUREMAP_ACR_STEP;
    
    int nCurrentACR;
    for (nCurrentACR=nAreaCR; nCurrentACR<=TREASUREMAP_ACR_MAX; nCurrentACR+=TREASUREMAP_ACR_STEP)
    {
        // This seems very prone to TMI
        NWNX_Util_SetInstructionsExecuted(0);
        float fCRDiff = IntToFloat(nCurrentACR - TREASUREMAP_ACR_MIN);
        int nScansToOmitOffEachSide = FloatToInt((fCRDiff * TREASUREMAP_PROPORTION_DISTANCE_REMOVED_PER_ACR * IntToFloat(nRealScanCount))/2.0);
        
        int nThisScanCount = nRealScanCount - (nScansToOmitOffEachSide*2);
        if (nThisScanCount == 0)
        {
            nThisScanCount = 1;
        }
        
        mpSettings.MAPDATA_MINIMUM_POLYGON_AREA = 0.02 / IntToFloat(nThisScanCount);
        json jDrawListElements = ProcessTreasureMapData(nRealScanCount-nScansToOmitOffEachSide, nRealScanCount-nScansToOmitOffEachSide, nScansToOmitOffEachSide, nScansToOmitOffEachSide, mpSettings);
        string sJsonFieldName = "json" + IntToString(nCurrentACR);
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

void InitialiseTreasureMap(object oMap, int nACR)
{
    if (nACR > TREASUREMAP_ACR_MAX)
    {
        nACR = TREASUREMAP_ACR_MIN;
    }
    if (nACR < TREASUREMAP_ACR_MIN)
    {
        nACR = TREASUREMAP_ACR_MIN;
    }
    int nPuzzleID = GetLocalInt(oMap, "puzzleid");
    string sAreaTag = "";
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
                return;
            }
        }
    }
    string sQuery = "SELECT puzzleid " +
        "FROM treasuremaps WHERE minacr <= @minacr";
    sQuery = sQuery + " ORDER BY RANDOM() LIMIT 1;";
    sqlquery sql = SqlPrepareQueryCampaign("tmapsolutions", sQuery);
    SqlBindInt(sql, "@minacr", nACR);
    SqlStep(sql);
    nPuzzleID = SqlGetInt(sql, 0);
    SetLocalInt(oMap, "puzzleid", nPuzzleID);
    SetLocalInt(oMap, "mapcr", nACR);
}

int GetAreaTileHash(object oArea)
{
    int nRet = GetLocalInt(oArea, "tilehash");
    if (nRet == 0)
    {
        json jArea = ObjectToJson(oArea);
        json jTiles = JsonPointer(jArea, "/ARE/value/Tile_List");
        //WriteTimestampedLogEntry(JsonDump(jTiles));
        nRet = NWNX_Util_Hash(JsonDump(jTiles));
        SetLocalInt(oArea, "tilehash", nRet);
    }
    return nRet;
}

location GetPuzzleSolutionLocation(int nPuzzleID)
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
        SendMessageToPC(GetFirstPC(), GetName(oArea));
    }
    
    return Location(oArea, vPos, 0.0);
}
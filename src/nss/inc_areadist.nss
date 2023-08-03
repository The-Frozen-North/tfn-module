// Deals with estimating the actual ingame distance required to move between two different areas.

#include "nwnx_util"

// This needs to be a big number that can be added to itself and not overflow
// last I checked nwscript int is int32, so...
const int AREA_DISTANCE_INFINITY = 1073741823; // 2^30 - 1

// Returns a crude estimate of the ingame distance needed to travel to oAreaDest from oAreaStart.
// Returns AREA_DISTANCE_INFINITY if no route was found.
int GetDistanceBetweenAreas(object oAreaStart, object oAreaDest);

// Finds areas expected to be reachable within nDistance starting in oAreaStart.
// This includes oAreaStart itself.
// Returns a JsonArray of strings of area tags.
json GetAreasWithinDistance(object oAreaStart, int nDistance);

// Calculate the distance between every area and every other area.
// Call this after the area_init loop. It needs...
// 1) area resrefs == area tags to work properly
// 2) the connection list saved to read
void PrepareAreaTransitionDB();


///////////////////////////////////

// https://en.wikipedia.org/wiki/Floyd%E2%80%93Warshall_algorithm

// The module's area connections form a directed graph
// Not all transitions are bidirectional, the quick exits notably are NOT.
// This is an algorithm that should calculate the distance between each node of the graph and all others
// ... and hopefully leave the rest as infinity.
// Apparently the disconnectedness of some area groups is not an issue for this approach.

int _ShouldAbortAreaDistOnError(string sError)
{
    if (sError != "")
    {
        WriteTimestampedLogEntry("AreaDist seeding failed.");
        return 1;
    }
    return 0;
}



int _IsAreaConsideredForAreaDistance(object oArea)
{
    if (GetStringLeft(GetName(oArea), 1) == "_" || GetStringLeft(GetName(oArea), 2) == "z_")
    {
        return 0;
    }
    if (GetLocalInt(oArea, "playerhouse"))
    {
        return 0;
    }
    // This stupid looking check seemingly removes some instanced/system areas
    if (!GetIsObjectValid(GetObjectByTag(GetTag(oArea))))
    {
        return 0;
    }
    return 1;
}

float _GetAreaDiagonalLength(object oArea)
{
    float fWidth = 5.0 * IntToFloat(GetAreaSize(AREA_WIDTH, oArea));
    float fHeight = 5.0 * IntToFloat(GetAreaSize(AREA_HEIGHT, oArea));
    return sqrt(fWidth * fWidth + fHeight * fHeight);
}

int _CalculateDirectConnectionDistance(object oAreaOne, object oAreaTwo)
{
    if (oAreaOne == oAreaTwo)
    {
        return 0;
    }
    return FloatToInt(_GetAreaDiagonalLength(oAreaOne) + _GetAreaDiagonalLength(oAreaTwo));
}

void PrepareAreaTransitionDB()
{
    int nOldInstructionLimit = NWNX_Util_GetInstructionLimit();
    NWNX_Util_SetInstructionLimit(52428888);


    // Need to know how many areas we have
    json jAreas = JsonArray();
    object oArea = GetFirstArea();
    while (GetIsObjectValid(oArea))
    {
        if (_IsAreaConsideredForAreaDistance(oArea))
        {
            jAreas = JsonArrayInsert(jAreas, JsonString(GetResRef(oArea)));
        }
        oArea = GetNextArea();
    }
    
    // Implementing Wikipedia pseudocode literally as it seems to make sense!
    // "let dist be a |V| × |V| array of minimum distances initialized to infinity"
    int nNumAreas = JsonGetLength(jAreas);
    WriteTimestampedLogEntry("PrepareAreaTransitionDB: Starting connections between " + IntToString(nNumAreas) + " areas...");
    json jDist = JsonArray();
    int i, j;
    for (i=0; i<nNumAreas; i++)
    {
        json jNew = JsonArray();
        for (j=0; j<nNumAreas; j++)
        {
            jNew = JsonArrayInsert(jNew, JsonInt(AREA_DISTANCE_INFINITY));
        }
        jDist = JsonArrayInsert(jDist, jNew);
    }
    WriteTimestampedLogEntry("PrepareAreaTransitionDB: done setting initial distances");
    // "for each edge (u, v) do
    //  dist[u][v] ← w(u, v)"  // The weight of the edge (u, v)
    
    int nCurrentAreaIndex;
    for (nCurrentAreaIndex=0; nCurrentAreaIndex<nNumAreas; nCurrentAreaIndex++)
    {
        NWNX_Util_SetInstructionsExecuted(0);
        string sTag = JsonGetString(JsonArrayGet(jAreas, nCurrentAreaIndex));
        object oCurrentArea = GetObjectByTag(sTag);
        int nConnectionIndex = 1;
        //WriteTimestampedLogEntry("PrepareAreaTransitionDB: start edge weights for area index " + IntToString(nCurrentAreaIndex) + " = " + GetTag(oCurrentArea) + " (retrieved from " + sTag + ")");
        if (!GetIsObjectValid(oCurrentArea))
        {
            WriteTimestampedLogEntry("Warning: Saved area tag " + sTag + " in the area array didn't retrieve to a valid object");
            continue;
        }
        while (1)
        {
            string sConnectArea = GetLocalString(oCurrentArea, "connection" + IntToString(nConnectionIndex));
            if (sConnectArea == "") { break; }
            object oConnectArea = GetObjectByTag(sConnectArea);
            if (!GetIsObjectValid(oConnectArea)) { break; }
            if (GetArea(oConnectArea) != oConnectArea)
            {
                WriteTimestampedLogEntry("ERROR: Retrieved object with tag " + sConnectArea + " is not an area, and apparently shares a tag with an area! This is BAD.");
                nConnectionIndex++;
                continue;
            }
            if (!_IsAreaConsideredForAreaDistance(oConnectArea))
            {
                nConnectionIndex++;
                continue;
            }
            int nDist = _CalculateDirectConnectionDistance(oCurrentArea, oConnectArea);
            json jFind = JsonFind(jAreas, JsonString(sConnectArea));
            if (jFind == JsonNull())
            {
                WriteTimestampedLogEntry("ERROR: Couldn't find tag " + sConnectArea + " in area list.");
            }
            else
            {
                int nIndexOfConnectedAreaInArray = JsonGetInt(jFind);
                json jSubArray = JsonArrayGet(jDist, nCurrentAreaIndex);
                jSubArray = JsonArraySet(jSubArray, nIndexOfConnectedAreaInArray, JsonInt(nDist));
                jDist = JsonArraySet(jDist, nCurrentAreaIndex, jSubArray);
                //WriteTimestampedLogEntry("Dist from " + sTag + " to " + sConnectArea + " = " + IntToString(nDist));
            }
            nConnectionIndex++;
        }
        WriteTimestampedLogEntry("PrepareAreaTransitionDB: finished checking " + IntToString(nConnectionIndex-1) + " connections of " + sTag + "!");
    }
    
    // This is the point at which we have something we can hash to avoid doing this again
    // if nothing changed
    int nHash = NWNX_Util_Hash(JsonDump(jDist));
    
    int nSavedHash = 0;
    sqlquery sql = SqlPrepareQueryCampaign("areadistances", "SELECT hash from areadistshash;");
    if (SqlStep(sql))
    {
        nSavedHash = SqlGetInt(sql, 0);
    }
    
    if (_ShouldAbortAreaDistOnError(SqlGetError(sql))) return;
    
    //if (0)
    if (nSavedHash == nHash)
    {
        WriteTimestampedLogEntry("Hashes match. Skip rebuilding DB this time!");
        return;
    }
    WriteTimestampedLogEntry("Hashes do not match (old = " + IntToString(nSavedHash) + " vs new " + IntToString(nHash) + ". Continuing...");
        
    // "for each vertex v do"
    // "dist[v][v] ← 0"
    
    WriteTimestampedLogEntry("PrepareAreaTransitionDB: set self distances to zero");
    
    // (this maybe could be done in the first step, but it takes no time at all anyway, and they didn't put it there)
    for (i=0; i<nNumAreas; i++)
    {
        json jSubArray = JsonArrayGet(jDist, i);
        jSubArray = JsonArraySet(jSubArray, i, JsonInt(0));
        jDist = JsonArraySet(jDist, i, jSubArray);
    }
    
    /*
    for k from 1 to |V|
        for i from 1 to |V|
            for j from 1 to |V|
                if dist[i][j] > dist[i][k] + dist[k][j] 
                    dist[i][j] ← dist[i][k] + dist[k][j]
                end if    
    */
    
    int k;
    for (k=0; k<nNumAreas; k++)
    {
        if (k % 20 == 0)
        {
            WriteTimestampedLogEntry("PrepareAreaTransitionDB: nest loop: k = " + IntToString(k) + " of " + IntToString(nNumAreas));
        }
        NWNX_Util_SetInstructionsExecuted(0);
        for (i=0; i<nNumAreas; i++)
        {
            for (j=0; j<nNumAreas; j++)
            {
                json jSubArrayi = JsonArrayGet(jDist, i);
                json jSubArrayk = JsonArrayGet(jDist, k);
                int nDistij = JsonGetInt(JsonArrayGet(jSubArrayi, j));
                int nDistik = JsonGetInt(JsonArrayGet(jSubArrayi, k));
                int nDistkj = JsonGetInt(JsonArrayGet(jSubArrayk, j));
                if (nDistij > nDistik + nDistkj)
                {
                    int nNewVal = nDistik + nDistkj;
                    jSubArrayi = JsonArraySet(jSubArrayi, j, JsonInt(nNewVal));
                    jDist = JsonArraySet(jDist, i, jSubArrayi);
                }
            }
        }
    }
    
    WriteTimestampedLogEntry("PrepareAreaTransitionDB: Saving connections to db...");
    
    sql = SqlPrepareQueryCampaign("areadistances",
        "CREATE TABLE IF NOT EXISTS areadists (" +
        "areasource TEXT, " +
        "areadest TEXT, " +
        "distance INTEGER);");
    SqlStep(sql);
    if (_ShouldAbortAreaDistOnError(SqlGetError(sql))) return;
    
    WriteTimestampedLogEntry("Make indexes");
    
    // Attempting to speed up the lookup of this thing
    sql = SqlPrepareQueryCampaign("areadistances",
        "CREATE INDEX IF NOT EXISTS idx_areadists_source_distance ON areadists(areasource, distance);");
    SqlStep(sql);
    if (_ShouldAbortAreaDistOnError(SqlGetError(sql))) return;
    
    sql = SqlPrepareQueryCampaign("areadistances",
        "CREATE INDEX IF NOT EXISTS idx_areadists_source_dest ON areadists(areasource, areadest);");
    SqlStep(sql);
    if (_ShouldAbortAreaDistOnError(SqlGetError(sql))) return;
    
    sql = SqlPrepareQueryCampaign("areadistances", "DELETE FROM areadists;");
    SqlStep(sql);
    if (_ShouldAbortAreaDistOnError(SqlGetError(sql))) return;
    
    sql = SqlPrepareQueryCampaign("areadistances", "BEGIN TRANSACTION");
    SqlStep(sql);
    if (_ShouldAbortAreaDistOnError(SqlGetError(sql))) return;
    
    for (i=0; i<nNumAreas; i++)
    {
        NWNX_Util_SetInstructionsExecuted(0);
        string sSourceArea = JsonGetString(JsonArrayGet(jAreas, i));
        for (j=0; j<nNumAreas; j++)
        {
            string sDestArea = JsonGetString(JsonArrayGet(jAreas, j));
            int nDistance = JsonGetInt(JsonArrayGet(JsonArrayGet(jDist, i), j));
            sql = SqlPrepareQueryCampaign("areadistances", "INSERT INTO areadists " + 
            "(areasource, areadest, distance) VALUES (@areasource, @areadest, @distance);");
            SqlBindString(sql, "@areasource", sSourceArea);
            SqlBindString(sql, "@areadest", sDestArea);
            SqlBindInt(sql, "@distance", nDistance);
            SqlStep(sql);
        }
    }
    sql = SqlPrepareQueryCampaign("areadistances", "COMMIT");
    SqlStep(sql);
    if (_ShouldAbortAreaDistOnError(SqlGetError(sql))) return;
    
    WriteTimestampedLogEntry("PrepareAreaTransitionDB: Finished storing connections");
    
    // Not using campaign DB might seem deranged, but the campaign DB is not happy with the schema change
    // and simply trying to throw the hash in via SetCampaignInt fails
    // so this seems like the... only way to do it?
    
    sql = SqlPrepareQueryCampaign("areadistances",
        "CREATE TABLE IF NOT EXISTS areadistshash (" +
        "hash INTEGER);");
    SqlStep(sql);
    
    if (_ShouldAbortAreaDistOnError(SqlGetError(sql))) return;
    
    sql = SqlPrepareQueryCampaign("areadistances", "DELETE FROM areadistshash;");
    SqlStep(sql);
    if (_ShouldAbortAreaDistOnError(SqlGetError(sql))) return;
    
    sql = SqlPrepareQueryCampaign("areadistances", "INSERT INTO areadistshash (hash) VALUES (@hash);");
    SqlBindInt(sql, "@hash", nHash);
    SqlStep(sql);
    if (_ShouldAbortAreaDistOnError(SqlGetError(sql))) return;

    
    NWNX_Util_SetInstructionLimit(nOldInstructionLimit);
}

// Returns a crude estimate of the ingame distance needed to travel to oAreaDest from oAreaStart.
// Returns AREA_DISTANCE_INFINITY if no route was found.
int GetDistanceBetweenAreas(object oAreaStart, object oAreaDest)
{
    sqlquery sql = SqlPrepareQueryCampaign("areadistances", "SELECT distance from areadists " +
    "WHERE areasource = @areasource AND areadest = @areadest;");
    SqlBindString(sql, "@areasource", GetTag(oAreaStart));
    SqlBindString(sql, "@areadest", GetTag(oAreaDest));
    if (SqlStep(sql))
    {
        return SqlGetInt(sql, 0);
    }
    WriteTimestampedLogEntry("Warning: distance retrieval between " + GetTag(oAreaStart) + " and " + GetTag(oAreaDest) + " returned no rows!");
    return AREA_DISTANCE_INFINITY;
}

// Finds areas expected to be reachable within nDistance starting in oAreaStart.
// This includes oAreaStart itself.
// Returns a JsonArray of strings of area tags.
json GetAreasWithinDistance(object oAreaStart, int nDistance)
{
    if (nDistance < 0)
    {
        return JsonArray();
    }    
    sqlquery sql = SqlPrepareQueryCampaign("areadistances", "SELECT areadest from areadists " +
    "WHERE areasource = @areasource AND distance <= @distance;");
    SqlBindString(sql, "@areasource", GetTag(oAreaStart));
    SqlBindInt(sql, "@distance", nDistance);
    json jOutput = JsonArray();
    int nLength = 0;
    while (SqlStep(sql))
    {
        string sArea = SqlGetString(sql, 0);
        jOutput = JsonArrayInsert(jOutput, JsonString(sArea));
        nLength++;
    }
    if (nLength == 0)
    {
        WriteTimestampedLogEntry("Warning: query for areas within " + IntToString(nDistance) + " of " + GetTag(oAreaStart) + " returned no rows!");
        jOutput = JsonArrayInsert(jOutput, JsonString(GetTag(oAreaStart)));
    }
    return jOutput;
}

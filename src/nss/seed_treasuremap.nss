#include "inc_treasuremap"

// The way this all fits together is...

// All existing PC maps have a puzzle ID and ACR set on them
// the DB maps the puzzle ID to a location and NUI drawlist visuals
// So, when doing stuff to the system or changing areas which impacts the maps
// ideally existing PC maps change only when they have to.

// For this reason, the TMAPSOLUTIONS SQLITE FILE SHOULD NOT BE DELETED
// or every single PC's existing treasure maps will change

// This will check for updated tiles in areas, and then update the json for all maps in the area
// so tile changes get reflected in existing maps without changing the solution location

// If the solution location is made invalid, a PC with this map gets another one in the same area.
// If the area is invalid, it rolls again like a fresh map would.

// If (eg after changing the map json components) it's necessary to redo the whole lot, open the sqlite file
// externally and run:
// update treasuremaps set tilehash=0

// This will then see tile hash mismatches on every map and redo all the json as though someone messed with tiles in every area

void main()
{
    int nAreaCount = 0;
    object oArea = GetFirstArea();
    while (GetIsObjectValid(oArea))
    {
        // Area tags are set to their resref after seeding
        string sTag = GetResRef(oArea);
        if (CanAreaHaveTreasureMaps(oArea))
        {
            WriteTimestampedLogEntry("Checking treasure maps in eligible area: " + GetResRef(oArea));
            int nACR = GetLocalInt(oArea, "cr");
            if (nACR < TREASUREMAP_ACR_MIN)
            {
                nACR = TREASUREMAP_ACR_MIN;
            }
            int nNumPuzzlesInThisArea = 0;
            while (1)
            {
                // Apparently, editing existing rows breaks the SqlStep and it stops immediately
                // So restart every time a row is edited
                nNumPuzzlesInThisArea = 0;
                int nEditedExistingRows = 0;
                sqlquery sql = SqlPrepareQueryCampaign("tmapsolutions",
                      "SELECT puzzleid, minacr, position, tilehash FROM treasuremaps WHERE areatag = @areatag;");
                SqlBindString(sql, "@areatag", sTag);
                int nAreaCurrentTileHash = GetAreaTileHash(oArea);
                while (SqlStep(sql))
                {
                    int nPuzzleID = SqlGetInt(sql, 0);
                    // If someone changed ACR then this needs redoing too
                    int nPuzzleMinACR = SqlGetInt(sql, 1);
                    int nTileHash = SqlGetInt(sql, 3);
                    vector vPos = SqlGetVector(sql, 2);
                    location lPos = Location(oArea, vPos, 0.0);
                    // Reasons to revisit old calculated locations:
                    // 1) min ACR change, means making new maps
                    // 2) area made invalid (likely means tile changes but could be placeables too)
                    // 3) tiles in the area were changed (which might make old maps wrong)
                    if (nPuzzleMinACR != nACR || !IsTreasureLocationValid(lPos) || nAreaCurrentTileHash != nTileHash)
                    {
                        if (!IsTreasureLocationValid(lPos))
                        {
                            WriteTimestampedLogEntry("Puzzle " + IntToString(nPuzzleID) + " has invalid location");
                            lPos = GetRandomValidTreasureLocationInArea(oArea);
                            // If this fails, delete the row
                            if (!IsTreasureLocationValid(lPos))
                            {
                                sql = SqlPrepareQueryCampaign("tmapsolutions",
                                    "DELETE FROM treasuremaps " +
                                    "WHERE puzzleid = @puzzleid;");
                                SqlBindInt(sql, "@puzzleid", nPuzzleID);
                                SqlStep(sql);
                                // Move onto the next puzzle id, don't increment number of existing
                                continue;
                            }
                            else
                            {
                                sql = SqlPrepareQueryCampaign("tmapsolutions",
                                    "UPDATE treasuremaps " +
                                    "SET position = @pos " +
                                    "WHERE puzzleid = @puzzleid;");
                                SqlBindInt(sql, "@puzzleid", nPuzzleID);
                                SqlBindVector(sql, "@pos", GetPositionFromLocation(lPos));
                                SqlStep(sql);
                            }
                        }
                        else if (nPuzzleMinACR != nACR)
                        {
                            WriteTimestampedLogEntry("Puzzle " + IntToString(nPuzzleID) + " has invalid ACR");
                            // Update puzzle ID's min ACR to the new one
                            sql = SqlPrepareQueryCampaign("tmapsolutions",
                                "UPDATE treasuremaps " +
                                "SET minacr = @value " +
                                "WHERE puzzleid = @puzzleid;");
                            SqlBindInt(sql, "@value", nACR);
                            SqlBindInt(sql, "@puzzleid", nPuzzleID);
                            SqlStep(sql);
                        }
                        else
                        {
                            WriteTimestampedLogEntry("Puzzle " + IntToString(nPuzzleID) + " has changed areatile hash: " + IntToString(nAreaCurrentTileHash) + " vs " + IntToString(nTileHash));
                        }
                        WriteTimestampedLogEntry("Updating json for puzzle " + IntToString(nPuzzleID) + " in " + GetTag(oArea));
                        CalculateTreasureMaps(nPuzzleID);
                        nEditedExistingRows++;
                    }
                    nNumPuzzlesInThisArea++;
                }
                if (!nEditedExistingRows)
                {
                    break;
                }
            }
            
            int nHeight = GetAreaSize(AREA_HEIGHT, oArea);
            int nWidth = GetAreaSize(AREA_WIDTH, oArea);
            int nExpectedPuzzlesInThisArea = FloatToInt(TREASUREMAP_SEED_DENSITY * IntToFloat(nHeight*nWidth));
            if (nExpectedPuzzlesInThisArea < 1)
            {
                nExpectedPuzzlesInThisArea = 1;
            }
            WriteTimestampedLogEntry("Found " + IntToString(nNumPuzzlesInThisArea) + " existing puzzles in this area");
            if (nExpectedPuzzlesInThisArea > nNumPuzzlesInThisArea)
            {
                int nNumPuzzlesToMake = nExpectedPuzzlesInThisArea - nNumPuzzlesInThisArea;
                WriteTimestampedLogEntry("This area wants " + IntToString(nNumPuzzlesToMake) + " more puzzles...");
                int i;
                for (i=0; i<nNumPuzzlesToMake; i++)
                {
                    WriteTimestampedLogEntry("Making new puzzle " + IntToString(i+1) + " of " + IntToString(nNumPuzzlesToMake) + "...");
                    NWNX_Util_SetInstructionsExecuted(0);
                    location lPos = GetRandomValidTreasureLocationInArea(oArea);
                    if (IsTreasureLocationValid(lPos))
                    {
                        CreateNewTreasureMapPuzzleAtLocation(lPos);
                    }
                }
            }
        }
        else
        {
            WriteTimestampedLogEntry("Area " + sTag + " is not eligible for puzzles");
            sqlquery sql = SqlPrepareQueryCampaign("tmapsolutions",
                                "DELETE FROM treasuremaps " +
                                "WHERE areatag = @areatag;");
            SqlBindString(sql, "@areatag", sTag);
            int nCount = 0;
            while (SqlStep(sql))
            {
                nCount++;
            }
            if (nCount > 0)
            {
                WriteTimestampedLogEntry("Deleted " + IntToString(nCount) + " puzzles that were in this area");
            }
        }
        nAreaCount++;
        //if (nAreaCount >= 5) { break; }
        oArea = GetNextArea();
    }
}

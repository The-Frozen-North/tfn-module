
#include "util_i_debug"

void MapPin_CreatePCMapPinTable(object oPC, int bReset = FALSE)
{
    if (bReset == TRUE)
    {
        string sqlDelete = "DROP TABLE IF EXISTS pc_mappin;";
        sqlquery sql = SqlPrepareQueryObject(oPC, sqlDelete);
        SqlStep(sql);
    }

    string sqlTable = "CREATE TABLE IF NOT EXISTS pc_mappin ( " +
                        "id INTEGER, " +
                        "area_tag TEXT NOT NULL, " +
                        "pos_x REAL NOT NULL, " +
                        "pos_y REAL NOT NULL, " +
                        "note TEXT);";
    sqlquery sql = SqlPrepareQueryObject(oPC, sqlTable);
    SqlStep(sql);
}

int MapPin_GetMapPinTableExists(object oPC)
{
    string sqlExists = "SELECT name " +
                    "FROM sqlite_master WHERE type = 'table' " +
                    "AND name = @table_name;";
    sqlquery sql = SqlPrepareQueryObject(oPC, sqlExists);
    SqlBindString(sql, "@table_name", "pc_mappin");

    return SqlStep(sql);
}

void MapPin_ResetPCMapPinTable(object oPC)
{
    MapPin_CreatePCMapPinTable(oPC, TRUE);
}

void MapPin_DeleteMapPinVariables(object oPC, string sPinID)
{
    DeleteLocalObject(oPC, "NW_MAP_PIN_AREA_" + sPinID);
    DeleteLocalString(oPC, "NW_MAP_PIN_NTRY_" + sPinID);
    DeleteLocalFloat(oPC, "NW_MAP_PIN_XPOS_" + sPinID);
    DeleteLocalFloat(oPC, "NW_MAP_PIN_YPOS_" + sPinID);
}

void MapPin_ListMapPinVariables(object oPC, string sPinID)
{
    object oArea = GetLocalObject(oPC, "NW_MAP_PIN_AREA_" + sPinID);
    string sArea = GetTag(oArea);

    string sNote = GetLocalString(oPC, "NW_MAP_PIN_NTRY_" + sPinID);
    float fPos_X = GetLocalFloat(oPC, "NW_MAP_PIN_XPOS_" + sPinID);
    float fPos_Y = GetLocalFloat(oPC, "NW_MAP_PIN_YPOS_" + sPinID);

    Notice("  " + sPinID + "  " +
            (sArea == "" ? "[Area Invalid]" : sArea) + " " +
            "X " + FloatToString(fPos_X, 3, 2) + " " +
            "Y " + FloatToString(fPos_Y, 3, 2) + " " +
            (sNote == "" ? "[Description Empty]" : sNote));
}

void MapPin_DumpMapPinVariables(object oPC, int nPinID = 0)
{
    int n, nPins = GetLocalInt(oPC, "NW_TOTAL_MAP_PINS");

    Notice("Dumping Map Pin data " +
        (nPinID == 0 ? "(all pins)" : "(pin #" + IntToString(nPinID) + ")") + " " +
        "for " + GetName(oPC));

    if (nPinID == 0)
    {
        for (n = 1; n <= nPins; n++)
            MapPin_ListMapPinVariables(oPC, IntToString(n));
    }
    else
        MapPin_ListMapPinVariables(oPC, IntToString(nPinID));
}

void MapPin_SavePCMapPins(object oPC)
{
    string sSQL, sValues;

    MapPin_ResetPCMapPinTable(oPC);

    int nPins = GetLocalInt(oPC, "NW_TOTAL_MAP_PINS");
    int n, nPinCount = 1;

    if (nPins == 0)
    {
        Notice("Pin count is 0, skipping");
        return;
    }

    for (n = 1; n <= nPins; n++)
    {
        string sPinID = IntToString(n);
        object oArea = GetLocalObject(oPC, "NW_MAP_PIN_AREA_" + sPinID);
        
        string sPinArea = GetTag(oArea);
        string sPinNote = GetLocalString(oPC, "NW_MAP_PIN_NTRY_" + sPinID);
        float fPin_X = GetLocalFloat(oPC, "NW_MAP_PIN_XPOS_" + sPinID);
        float fPin_Y = GetLocalFloat(oPC, "NW_MAP_PIN_YPOS_" + sPinID);

        if (GetIsObjectValid(oArea) == FALSE)
        {
            MapPin_DeleteMapPinVariables(oPC, sPinID);
            continue;
        }

        string sqlInsert = "INSERT INTO pc_mappin VALUES (@id, @area_tag, @pos_x, @pos_y, @note);";
        sqlquery sql = SqlPrepareQueryObject(oPC, sqlInsert);
        SqlBindInt(sql, "@id", nPinCount++);
        SqlBindString(sql, "@area_tag", sPinArea);
        SqlBindFloat(sql, "@pos_x", fPin_X);
        SqlBindFloat(sql, "@pos_y", fPin_Y);
        SqlBindString(sql, "@note", sPinNote);

        SqlStep(sql);

        MapPin_DeleteMapPinVariables(oPC, sPinID);
    }

    DeleteLocalInt(oPC, "NW_TOTAL_MAP_PINS");
} 

void MapPin_LoadPCMapPins(object oPC)
{
    if (MapPin_GetMapPinTableExists(oPC) == FALSE)
    {
        Notice("Map Pin table does not exist on " + GetName(oPC) + "; skipping");
        return;
    }

    string sQuery = "SELECT * FROM pc_mappin;";
    sqlquery sql = SqlPrepareQueryObject(oPC, sQuery);

    int nPinCount = 1;
    
    while (SqlStep(sql))
    {
        int nID = SqlGetInt(sql, 0);
        string sArea = SqlGetString(sql, 1);
        float fPos_X = SqlGetFloat(sql, 2);
        float fPos_Y = SqlGetFloat(sql, 3);
        string sNote = SqlGetString(sql, 4);

        object oArea = GetObjectByTag(sArea);
        if (GetIsObjectValid(oArea) == FALSE)
            continue;

        string sPinID = IntToString(nPinCount++);
        SetLocalObject(oPC, "NW_MAP_PIN_AREA_" + sPinID, oArea);
        SetLocalString(oPC, "NW_MAP_PIN_NTRY_" + sPinID, sNote);
        SetLocalFloat(oPC, "NW_MAP_PIN_XPOS_" + sPinID, fPos_X);
        SetLocalFloat(oPC, "NW_MAP_PIN_YPOS_" + sPinID, fPos_Y);
    }

    if (nPinCount > 1)
        SetLocalInt(oPC, "NW_TOTAL_MAP_PINS", --nPinCount);
}

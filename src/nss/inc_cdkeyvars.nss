// It turns out that using Set/GetCampaign<Type> is a lot slower
// than rolling your own DB table and writing Set/Get for it
#include "inc_sql"
#include "inc_sqlite_time"

// This also supports having individual tables for different things in case messing with them in the future
// is something that is useful

// It turned out this also reduced to an implementation that just replaces the basic Bioware campaign variable functions
// for arbitrary database names. Maybe that is useful?

// Get an variable from oPC's cdkey db, looking up sVariable in sTable.
// Returns 0 if not set.
// sTable should contain alphabetical characters only.
int GetCdkeyInt(object oPC, string sTable, string sVariable);
// Get an variable from oPC's cdkey db, looking up sVariable in sTable.
// Returns "" if not set.
// sTable should contain alphabetical characters only.
string GetCdkeyString(object oPC, string sTable, string sVariable);
// Get an variable from oPC's cdkey db, looking up sVariable in sTable.
// Returns Vector(-1.0,-1.0,-1.0) if not set.
// sTable should contain alphabetical characters only.
vector GetCdkeyVector(object oPC, string sTable, string sVariable);
// Get an variable from oPC's cdkey db, looking up sVariable in sTable.
// Returns 0.0 if not set.
// sTable should contain alphabetical characters only.
float GetCdkeyFloat(object oPC, string sTable, string sVariable);
// Get an variable from oPC's cdkey db, looking up sVariable in sTable.
// Returns LOCATION_INVALID if not set.
// sTable should contain alphabetical characters only.
location GetCdkeyLocation(object oPC, string sTable, string sVariable);
// Get an variable from oPC's cdkey db, looking up sVariable in sTable.
// Returns JsonNull() if not set.
// sTable should contain alphabetical characters only.
json GetCdkeyJson(object oPC, string sTable, string sVariable);

// Normally passing the PC object is easier, but maybe not always

// Get an variable from the sDatabase campaign database, looking up sVariable in sTable.
// Returns 0 if not set.
// sTable should contain alphabetical characters only.
int GetCampaignDBTableInt(string sDatabase, string sTable, string sVariable);
// Get an variable from the sDatabase campaign database, looking up sVariable in sTable.
// Returns "" if not set.
// sTable should contain alphabetical characters only.
string GetCampaignDBTableString(string sDatabase, string sTable, string sVariable);
// Get an variable from the sDatabase campaign database, looking up sVariable in sTable.
// Returns Vector(-1.0,-1.0,-1.0) if not set.
// sTable should contain alphabetical characters only.
vector GetCampaignDBTableVector(string sDatabase, string sTable, string sVariable);
// Get an variable from the sDatabase campaign database, looking up sVariable in sTable.
// Returns 0.0 if not set.
// sTable should contain alphabetical characters only.
float GetCampaignDBTableFloat(string sDatabase, string sTable, string sVariable);
// Get an variable from the sDatabase campaign database, looking up sVariable in sTable.
// Returns LOCATION_INVALID if not set.
// sTable should contain alphabetical characters only.
location GetCampaignDBTableLocation(string sDatabase, string sTable, string sVariable);
// Get an variable from the sDatabase campaign database, looking up sVariable in sTable.
// Returns JsonNull() if not set.
// sTable should contain alphabetical characters only.
json GetCampaignDBTableJson(string sDatabase, string sTable, string sVariable);

// Set the value of sVariable in oPC's cdkey db.
// sTable should contain alphabetical characters only.
void SetCdkeyInt(object oPC, string sTable, string sVariable, int nValue);
// Set the value of sVariable in oPC's cdkey db.
// sTable should contain alphabetical characters only.
void SetCdkeyString(object oPC, string sTable, string sVariable, string sValue);
// Set the value of sVariable in oPC's cdkey db.
// sTable should contain alphabetical characters only.
void SetCdkeyVector(object oPC, string sTable, string sVariable, vector vValue);
// Set the value of sVariable in oPC's cdkey db.
// sTable should contain alphabetical characters only.
void SetCdkeyFloat(object oPC, string sTable, string sVariable, float fValue);
// Set the value of sVariable in oPC's cdkey db.
// sTable should contain alphabetical characters only.
void SetCdkeyLocation(object oPC, string sTable, string sVariable, location lValue);
// Set the value of sVariable in oPC's cdkey db.
// sTable should contain alphabetical characters only.
void SetCdkeyJson(object oPC, string sTable, string sVariable, json jValue);

// Set the value of sVariable in the sDatabase campaign database.
// sTable should contain alphabetical characters only.
void SetCampaignDBTableInt(string sDatabase, string sTable, string sVariable, int nValue);
// Set the value of sVariable in the sDatabase campaign database.
// sTable should contain alphabetical characters only.
void SetCampaignDBTableString(string sDatabase, string sTable, string sVariable, string sValue);
// Set the value of sVariable in the sDatabase campaign database.
// sTable should contain alphabetical characters only.
void SetCampaignDBTableVector(string sDatabase, string sTable, string sVariable, vector vValue);
// Set the value of sVariable in the sDatabase campaign database.
// sTable should contain alphabetical characters only.
void SetCampaignDBTableFloat(string sDatabase, string sTable, string sVariable, float fValue);
// Set the value of sVariable in the sDatabase campaign database.
// sTable should contain alphabetical characters only.
void SetCampaignDBTableLocation(string sDatabase, string sTable, string sVariable, location lValue);
// Set the value of sVariable in the sDatabase campaign database.
// sTable should contain alphabetical characters only.
void SetCampaignDBTableJson(string sDatabase, string sTable, string sVariable, json jValue);

// Delete sVariable in oPC's cdkey db.
// sTable should contain alphabetical characters only.
void DeleteCdkeyVariable(object oPC, string sTable, string sVariable);
// Delete sVariable in the sDatabase campaign database.
// sTable should contain alphabetical characters only.
void DeleteCampaignDBTableVariable(string sDatabase, string sTable, string sVariable);


// Statistic writing is still too slow.
// The solution seems to be to write changes into memory db
// and periodically save them to the disk database
int GetCachedCdkeyInt(object oPC, string sTable, string sVariable);
float GetCachedCdkeyFloat(object oPC, string sTable, string sVariable);
string GetCachedCdkeyString(object oPC, string sTable, string sVariable);
vector GetCachedCdkeyVector(object oPC, string sTable, string sVariable);
location GetCachedCdkeyLocation(object oPC, string sTable, string sVariable);
json GetCachedCdkeyJson(object oPC, string sTable, string sVariable);

void SetCachedCdkeyInt(object oPC, string sTable, string sVariable, int nValue);
void SetCachedCdkeyFloat(object oPC, string sTable, string sVariable, float fValue);
void SetCachedCdkeyString(object oPC, string sTable, string sVariable, string sValue);
void SetCachedCdkeyVector(object oPC, string sTable, string sVariable, vector vValue);
void SetCachedCdkeyLocation(object oPC, string sTable, string sVariable, location lValue);
void SetCachedCdkeyJson(object oPC, string sTable, string sVariable, json jValue);

// Copies changed records from the cache to the campaign db.
// Does this only for the cached database that has gone the longest since being updated.
void UpdateOldestCachedCdkeyDB();

// Copies all changed records from the cache to their campaign dbs.
// I expect this to be used on module shutdown only.
void UpdateAllCachedCdkeyDBs();

///////////////////////////////////

// Since you apparently cannot bind table names, this is my best attempt
// of preventing injection if anyone ever uses non-static table names for some reason
int _WarnOnBadCdkeyTableString(string sTable)
{
    json jMatch = RegExpMatch("[A-Za-z0-9]*", sTable);
    if (jMatch == JsonNull())
    {
        WriteTimestampedLogEntry("ERROR: inc_cdkeyvars attempted operation with nonalphabetical table name " + sTable + ". DB operation failed.");
        return 1;
    }
    if (JsonGetString(JsonArrayGet(jMatch, 0)) != sTable)
    {
        WriteTimestampedLogEntry("ERROR: inc_cdkeyvars attempted operation with nonalphabetical table name " + sTable + ". DB operation failed.");
        return 1;
    }
    return 0;
}

// These internal functions ASSUME THE CALLER CHECKED sTable with _WarnOnBadCdkeyTableString
void _CreateCdkeyTable(string sDatabase, string sTable)
{
    sqlquery sql = SqlPrepareQueryCampaign(sDatabase, "CREATE TABLE IF NOT EXISTS " + sTable + " (" +
        "var TEXT PRIMARY KEY, " +
        "value TEXT);");
        SqlStep(sql);
    sql = SqlPrepareQueryCampaign(sDatabase, "CREATE INDEX IF NOT EXISTS idx_var ON " + sTable + "(var);");
    SqlStep(sql);
}
// These internal functions ASSUME THE CALLER CHECKED sTable with _WarnOnBadCdkeyTableString
sqlquery _CdkeyPrepareSelect(string sDatabase, string sTable, string sVariable)
{
    _CreateCdkeyTable(sDatabase, sTable);
    sqlquery sql = SqlPrepareQueryCampaign(sDatabase, "SELECT value from " + sTable + " where var=@var;");
    SqlBindString(sql, "@var", sVariable);
    return sql;
}
// These internal functions ASSUME THE CALLER CHECKED sTable with _WarnOnBadCdkeyTableString
sqlquery _CdkeyPrepareInsert(string sDatabase, string sTable, string sVariable)
{
    _CreateCdkeyTable(sDatabase, sTable);
    sqlquery sql = SqlPrepareQueryCampaign(sDatabase,
        "INSERT INTO " + sTable + 
        " (var, value) VALUES (@var, @value) " + 
        " ON CONFLICT (var) DO UPDATE SET value = @value;");
    SqlBindString(sql, "@var", sVariable);
    return sql;
}
// These internal functions ASSUME THE CALLER CHECKED sTable with _WarnOnBadCdkeyTableString
sqlquery _CdkeyPrepareDelete(string sDatabase, string sTable, string sVariable)
{
    _CreateCdkeyTable(sDatabase, sTable);
    sqlquery sql = SqlPrepareQueryCampaign(sDatabase,
        "DELETE FROM " + sTable + 
        " WHERE var=@var;");
    SqlBindString(sql, "@var", sVariable);
    return sql;
}

// All the gets

int GetCdkeyInt(object oPC, string sTable, string sVariable)
{
    oPC = GetMasterFromPossessedFamiliar(oPC);
    if (!GetIsPC(oPC)) return 0;
    return GetCampaignDBTableInt(GetPCPublicCDKey(oPC, TRUE), sTable, sVariable);
}

string GetCdkeyString(object oPC, string sTable, string sVariable)
{
    oPC = GetMasterFromPossessedFamiliar(oPC);
    if (!GetIsPC(oPC)) return "";
    return GetCampaignDBTableString(GetPCPublicCDKey(oPC, TRUE), sTable, sVariable);
}

float GetCdkeyFloat(object oPC, string sTable, string sVariable)
{
    oPC = GetMasterFromPossessedFamiliar(oPC);
    if (!GetIsPC(oPC)) return 0.0;
    return GetCampaignDBTableFloat(GetPCPublicCDKey(oPC, TRUE), sTable, sVariable);
}

vector GetCdkeyVector(object oPC, string sTable, string sVariable)
{
    oPC = GetMasterFromPossessedFamiliar(oPC);
    if (!GetIsPC(oPC)) return Vector(-1.0,-1.0,-1.0);
    return GetCampaignDBTableVector(GetPCPublicCDKey(oPC, TRUE), sTable, sVariable);
}

location GetCdkeyLocation(object oPC, string sTable, string sVariable)
{
    oPC = GetMasterFromPossessedFamiliar(oPC);
    if (!GetIsPC(oPC)) return LOCATION_INVALID;
    return GetCampaignDBTableLocation(GetPCPublicCDKey(oPC, TRUE), sTable, sVariable);
}

json GetCdkeyJson(object oPC, string sTable, string sVariable)
{
    oPC = GetMasterFromPossessedFamiliar(oPC);
    if (!GetIsPC(oPC)) return JsonNull();
    return GetCampaignDBTableJson(GetPCPublicCDKey(oPC, TRUE), sTable, sVariable);
}

int GetCampaignDBTableInt(string sDatabase, string sTable, string sVariable)
{
    if (_WarnOnBadCdkeyTableString(sTable) || sDatabase == "" || sTable == "" || sVariable == "") { return 0; }
    
    sqlquery sql = _CdkeyPrepareSelect(sDatabase, sTable, sVariable);
    if (SqlStep(sql))
    {
        return SqlGetInt(sql, 0);
    }
    return 0;
}

string GetCampaignDBTableString(string sDatabase, string sTable, string sVariable)
{
    if (_WarnOnBadCdkeyTableString(sTable) || sDatabase == "" || sTable == "" || sVariable == "") { return ""; }
    
    sqlquery sql = _CdkeyPrepareSelect(sDatabase, sTable, sVariable);
    if (SqlStep(sql))
    {
        return SqlGetString(sql, 0);
    }
    return "";
}

float GetCampaignDBTableFloat(string sDatabase, string sTable, string sVariable)
{
    if (_WarnOnBadCdkeyTableString(sTable) || sDatabase == "" || sTable == "" || sVariable == "") { return 0.0; }
    
    sqlquery sql = _CdkeyPrepareSelect(sDatabase, sTable, sVariable);
    if (SqlStep(sql))
    {
        return SqlGetFloat(sql, 0);
    }
    return 0.0;
}

vector GetCampaignDBTableVector(string sDatabase, string sTable, string sVariable)
{
    if (_WarnOnBadCdkeyTableString(sTable) || sDatabase == "" || sTable == "" || sVariable == "") { return Vector(-1.0,-1.0,-1.0); }
    
    sqlquery sql = _CdkeyPrepareSelect(sDatabase, sTable, sVariable);
    if (SqlStep(sql))
    {
        return SqlGetVector(sql, 0);
    }
    return Vector(-1.0,-1.0,-1.0);
}

location GetCampaignDBTableLocation(string sDatabase, string sTable, string sVariable)
{
    if (_WarnOnBadCdkeyTableString(sTable) || sDatabase == "" || sTable == "" || sVariable == "") { return LOCATION_INVALID; }
    
    sqlquery sql = _CdkeyPrepareSelect(sDatabase, sTable, sVariable);
    if (SqlStep(sql))
    {
        return SQLocalsPlayer_StringToLocation(SqlGetString(sql, 0));
    }
    return LOCATION_INVALID;
}

json GetCampaignDBTableJson(string sDatabase, string sTable, string sVariable)
{
    if (_WarnOnBadCdkeyTableString(sTable) || sDatabase == "" || sTable == "" || sVariable == "") { return JsonNull(); }
    
    sqlquery sql = _CdkeyPrepareSelect(sDatabase, sTable, sVariable);
    if (SqlStep(sql))
    {
        return SqlGetJson(sql, 0);
    }
    return JsonNull();
}


// All the sets

void SetCdkeyInt(object oPC, string sTable, string sVariable, int nValue)
{
    oPC = GetMasterFromPossessedFamiliar(oPC);
    if (!GetIsPC(oPC)) return;
    SetCampaignDBTableInt(GetPCPublicCDKey(oPC, TRUE), sTable, sVariable, nValue);
}

void SetCdkeyString(object oPC, string sTable, string sVariable, string sValue)
{
    oPC = GetMasterFromPossessedFamiliar(oPC);
    if (!GetIsPC(oPC)) return;
    SetCampaignDBTableString(GetPCPublicCDKey(oPC, TRUE), sTable, sVariable, sValue);
}

void SetCdkeyFloat(object oPC, string sTable, string sVariable, float fValue)
{
    oPC = GetMasterFromPossessedFamiliar(oPC);
    if (!GetIsPC(oPC)) return;
    SetCampaignDBTableFloat(GetPCPublicCDKey(oPC, TRUE), sTable, sVariable, fValue);
}

void SetCdkeyVector(object oPC, string sTable, string sVariable, vector vValue)
{
    oPC = GetMasterFromPossessedFamiliar(oPC);
    if (!GetIsPC(oPC)) return;
    SetCampaignDBTableVector(GetPCPublicCDKey(oPC, TRUE), sTable, sVariable, vValue);
}

void SetCdkeyLocation(object oPC, string sTable, string sVariable, location lValue)
{
    oPC = GetMasterFromPossessedFamiliar(oPC);
    if (!GetIsPC(oPC)) return;
    SetCampaignDBTableLocation(GetPCPublicCDKey(oPC, TRUE), sTable, sVariable, lValue);
}

void SetCdkeyJson(object oPC, string sTable, string sVariable, json jValue)
{
    oPC = GetMasterFromPossessedFamiliar(oPC);
    if (!GetIsPC(oPC)) return;
    SetCampaignDBTableJson(GetPCPublicCDKey(oPC, TRUE), sTable, sVariable, jValue);
}

void SetCampaignDBTableInt(string sDatabase, string sTable, string sVariable, int nValue)
{
    if (_WarnOnBadCdkeyTableString(sTable) || sDatabase == "" || sTable == "" || sVariable == "") { return; }
    
    sqlquery sql = _CdkeyPrepareInsert(sDatabase, sTable, sVariable);
    SqlBindInt(sql, "@value", nValue);
    SqlStep(sql);
    
    sql = SqlPrepareQueryCampaign(sDatabase,
        "INSERT INTO " + sTable + 
        " (var, value) VALUES ('a', 'b');");
    SqlBindString(sql, "@var", sVariable);
    SqlBindInt(sql, "@value", nValue);
    SqlStep(sql);
}

void SetCampaignDBTableString(string sDatabase, string sTable, string sVariable, string sValue)
{
    if (_WarnOnBadCdkeyTableString(sTable) || sDatabase == "" || sTable == "" || sVariable == "") { return; }
    
    sqlquery sql = _CdkeyPrepareInsert(sDatabase, sTable, sVariable);
    SqlBindString(sql, "@value", sValue);
    SqlStep(sql);
}

void SetCampaignDBTableFloat(string sDatabase, string sTable, string sVariable, float fValue)
{
    if (_WarnOnBadCdkeyTableString(sTable) || sDatabase == "" || sTable == "" || sVariable == "") { return; }
    
    sqlquery sql = _CdkeyPrepareInsert(sDatabase, sTable, sVariable);
    SqlBindFloat(sql, "@value", fValue);
    SqlStep(sql);
}

void SetCampaignDBTableVector(string sDatabase, string sTable, string sVariable, vector vValue)
{
    if (_WarnOnBadCdkeyTableString(sTable) || sDatabase == "" || sTable == "" || sVariable == "") { return; }
    
    sqlquery sql = _CdkeyPrepareInsert(sDatabase, sTable, sVariable);
    SqlBindVector(sql, "@value", vValue);
    SqlStep(sql);
}

void SetCampaignDBTableLocation(string sDatabase, string sTable, string sVariable, location lValue)
{
    if (_WarnOnBadCdkeyTableString(sTable) || sDatabase == "" || sTable == "" || sVariable == "") { return; }
    
    sqlquery sql = _CdkeyPrepareInsert(sDatabase, sTable, sVariable);
    SqlBindString(sql, "@value", SQLocalsPlayer_LocationToString(lValue));
    SqlStep(sql);
}

void SetCampaignDBTableJson(string sDatabase, string sTable, string sVariable, json jValue)
{
    if (_WarnOnBadCdkeyTableString(sTable) || sDatabase == "" || sTable == "" || sVariable == "") { return; }
    
    sqlquery sql = _CdkeyPrepareInsert(sDatabase, sTable, sVariable);
    SqlBindJson(sql, "@value", jValue);
    SqlStep(sql);
}

// All the deletes

void DeleteCdkeyVariable(object oPC, string sTable, string sVariable)
{
    oPC = GetMasterFromPossessedFamiliar(oPC);
    if (!GetIsPC(oPC)) return;
    DeleteCampaignDBTableVariable(GetPCPublicCDKey(oPC, TRUE), sTable, sVariable);
}

void DeleteCampaignDBTableVariable(string sDatabase, string sTable, string sVariable)
{
    if (_WarnOnBadCdkeyTableString(sTable) || sDatabase == "" || sTable == "" || sVariable == "") { return; }
    sqlquery sql = _CdkeyPrepareDelete(sDatabase, sTable, sVariable);
    SqlStep(sql);
}

// INTERNAL. Assumes both sDatabase contains only safe characters
void _CreateCdkeyCacheTable(string sDatabase)
{
    if (sDatabase != "")
    {
        sqlquery sql = SqlPrepareQueryObject(GetModule(), "CREATE TABLE IF NOT EXISTS cdkeycache_" + sDatabase + " (" +
            "var TEXT PRIMARY KEY, " +
            "value TEXT, " + 
            "tablename TEXT);");
            SqlStep(sql);
        sql = SqlPrepareQueryObject(GetModule(), "CREATE INDEX IF NOT EXISTS idx_var ON cdkeycache_" + sDatabase + "(tablename, var);");
        SqlStep(sql);
    }
    
    sqlquery sql = SqlPrepareQueryObject(GetModule(), "CREATE TABLE IF NOT EXISTS cdkeycache__update (" +
        "db TEXT PRIMARY KEY, " +
        "lastupdate INTEGER);");
    SqlStep(sql);
}

// INTERNAL. Assumes both sDatabase and sTable contain only safe characters
sqlquery _CdkeyCachePrepareSelect(string sDatabase, string sTable, string sVariable)
{
    _CreateCdkeyCacheTable(sDatabase);
    sqlquery sql = SqlPrepareQueryObject(GetModule(), "SELECT value from cdkeycache_" + sDatabase + " where var=@var and tablename=@tablename;");
    SqlBindString(sql, "@var", sVariable);
    SqlBindString(sql, "@tablename", sTable);
    return sql;
}

// These internal functions ASSUME THE CALLER CHECKED sTable with _WarnOnBadCdkeyTableString
sqlquery _CdkeyCachePrepareInsert(string sDatabase, string sTable, string sVariable)
{
    _CreateCdkeyCacheTable(sDatabase);
    sqlquery sql = SqlPrepareQueryObject(GetModule(), "INSERT INTO cdkeycache__update (db, lastupdate) VALUES (@db, @update) " + 
                                                      "ON CONFLICT (db) DO NOTHING;");
    SqlBindInt(sql, "@update", 0);
    SqlBindString(sql, "@db", sDatabase);
    SqlStep(sql);
    
    
    sql = SqlPrepareQueryObject(GetModule(),
        "INSERT INTO cdkeycache_" + sDatabase + " (var, tablename, value) VALUES (@var, @tablename, @value) " + 
        " ON CONFLICT (var) DO UPDATE SET value = @value;");
    SqlBindString(sql, "@var", sVariable);
    SqlBindString(sql, "@tablename", sTable);
    return sql;
}

int _UpdateCachedCdkeyDB(string sDatabase)
{
    int nStart = GetMicrosecondCounter();
    sqlquery sql = SqlPrepareQueryObject(GetModule(), "SELECT var, tablename, value FROM cdkeycache_"+sDatabase+ ";");
    sqlquery sqlCampaign = SqlPrepareQueryCampaign(sDatabase, "BEGIN TRANSACTION");
    
    SqlStep(sqlCampaign);
    int bAction = 0;
    while (SqlStep(sql))
    {
        bAction = 1;
        string sVar = SqlGetString(sql, 0);
        string sTable = SqlGetString(sql, 1);
        string sValue = SqlGetString(sql, 2);
        
        //WriteTimestampedLogEntry("Write " + sVar + " -> " + sValue);
        SetCampaignDBTableString(sDatabase, sTable, sVar, sValue);
    }
    sqlCampaign = SqlPrepareQueryCampaign(sDatabase, "COMMIT");
    SqlStep(sqlCampaign);
    
    sql = SqlPrepareQueryObject(GetModule(), "DELETE FROM cdkeycache_"+sDatabase+ ";");
    SqlStep(sql);
    
    // If we did something, update the last updated time accordingly
    // If we didn't do anything, remove this database's entry as the PC behind it probably logged out
    if (bAction)
    {
        int nNow = SQLite_GetTimeStamp();
        sqlquery sql = SqlPrepareQueryObject(GetModule(), "INSERT INTO cdkeycache__update (db, lastupdate) VALUES (@db, @update) " + 
                                                          "ON CONFLICT (db) DO UPDATE SET lastupdate=@update;");
        SqlBindInt(sql, "@update", nNow);
        SqlBindString(sql, "@db", sDatabase);
        SqlStep(sql);
    }
    else
    {
        sqlquery sql = SqlPrepareQueryObject(GetModule(), "DELETE FROM cdkeycache__update where db=@db;");
        SqlBindString(sql, "@db", sDatabase);
        SqlStep(sql);
        WriteTimestampedLogEntry("Clear database cache for " + sDatabase + " as there have been no writes since it was copied to disk");
    }
    //WriteTimestampedLogEntry("_UpdateCachedCdkeyDB in " + IntToString(GetMicrosecondCounter() - nStart));
    return bAction;
    
}

void UpdateOldestCachedCdkeyDB()
{
    _CreateCdkeyCacheTable("");
    sqlquery sql = SqlPrepareQueryObject(GetModule(), "SELECT db from cdkeycache__update ORDER BY lastupdate ASC LIMIT 1;");
    if (SqlStep(sql))
    {
        string sDatabase = SqlGetString(sql, 0);
        // Todo: remove this once sure it works with multiple players online
        //WriteTimestampedLogEntry("Oldest cached cdkeydb = " + sDatabase);
        // If this returns 1, it updated the database
        // If it didn't, it removed the database from cdkeycache__update
        // and doing this lookup again will find something different (or nothing)
        if (_UpdateCachedCdkeyDB(sDatabase))
        {
            return;
        }
        else
        {
            UpdateOldestCachedCdkeyDB();
        }
    }
}

void UpdateAllCachedCdkeyDBs()
{
    int nNow = SQLite_GetTimeStamp();
    sqlquery sql = SqlPrepareQueryObject(GetModule(), "SELECT db from cdkeycache__update;");
    json jDatabases = JsonArray();
    while (SqlStep(sql))
    {
        string sDatabase = SqlGetString(sql, 0);
        jDatabases = JsonArrayInsert(jDatabases, JsonString(sDatabase));
    }
    int nLength = JsonGetLength(jDatabases);
    int i;
    for (i=0; i<nLength; i++)
    {
        string sDatabase = JsonGetString(JsonArrayGet(jDatabases, i));
        // Here we don't really care what this returns, only that it does an attempt to update
        WriteTimestampedLogEntry("Save all cached dbs: cdkeydb = " + sDatabase);
        _UpdateCachedCdkeyDB(sDatabase);
    }
}


int GetCachedCdkeyInt(object oPC, string sTable, string sVariable)
{
    oPC = GetMasterFromPossessedFamiliar(oPC);
    if (!GetIsPC(oPC)) return 0;
    string sDatabase = GetPCPublicCDKey(oPC, TRUE);
    
    if (_WarnOnBadCdkeyTableString(sTable) || _WarnOnBadCdkeyTableString(sDatabase) || sDatabase == "" || sTable == "" || sVariable == "") { return 0; }
    
    sqlquery sql = _CdkeyCachePrepareSelect(sDatabase, sTable, sVariable);
    if (SqlStep(sql))
    {
        return SqlGetInt(sql, 0);
    }
    return GetCdkeyInt(oPC, sTable, sVariable);
}

float GetCachedCdkeyFloat(object oPC, string sTable, string sVariable)
{
    oPC = GetMasterFromPossessedFamiliar(oPC);
    if (!GetIsPC(oPC)) return 0.0;
    string sDatabase = GetPCPublicCDKey(oPC, TRUE);
    
    if (_WarnOnBadCdkeyTableString(sTable) || _WarnOnBadCdkeyTableString(sDatabase) || sDatabase == "" || sTable == "" || sVariable == "") { return 0.0; }
    
    sqlquery sql = _CdkeyCachePrepareSelect(sDatabase, sTable, sVariable);
    if (SqlStep(sql))
    {
        return SqlGetFloat(sql, 0);
    }
    return GetCdkeyFloat(oPC, sTable, sVariable);
}

string GetCachedCdkeyString(object oPC, string sTable, string sVariable)
{
    oPC = GetMasterFromPossessedFamiliar(oPC);
    if (!GetIsPC(oPC)) return "";
    string sDatabase = GetPCPublicCDKey(oPC, TRUE);
    
    if (_WarnOnBadCdkeyTableString(sTable) || _WarnOnBadCdkeyTableString(sDatabase) || sDatabase == "" || sTable == "" || sVariable == "") { return ""; }
    
    sqlquery sql = _CdkeyCachePrepareSelect(sDatabase, sTable, sVariable);
    if (SqlStep(sql))
    {
        return SqlGetString(sql, 0);
    }
    return GetCdkeyString(oPC, sTable, sVariable);
}

vector GetCachedCdkeyVector(object oPC, string sTable, string sVariable)
{
    oPC = GetMasterFromPossessedFamiliar(oPC);
    if (!GetIsPC(oPC)) return Vector(-1.0,-1.0,-1.0);
    string sDatabase = GetPCPublicCDKey(oPC, TRUE);
    
    if (_WarnOnBadCdkeyTableString(sTable) || _WarnOnBadCdkeyTableString(sDatabase) || sDatabase == "" || sTable == "" || sVariable == "") { return Vector(-1.0,-1.0,-1.0); }
    
    sqlquery sql = _CdkeyCachePrepareSelect(sDatabase, sTable, sVariable);
    if (SqlStep(sql))
    {
        return SqlGetVector(sql, 0);
    }
    return GetCdkeyVector(oPC, sTable, sVariable);
}

location GetCachedCdkeyLocation(object oPC, string sTable, string sVariable)
{
    oPC = GetMasterFromPossessedFamiliar(oPC);
    if (!GetIsPC(oPC)) return LOCATION_INVALID;
    string sDatabase = GetPCPublicCDKey(oPC, TRUE);
    
    if (_WarnOnBadCdkeyTableString(sTable) || _WarnOnBadCdkeyTableString(sDatabase) || sDatabase == "" || sTable == "" || sVariable == "") { return LOCATION_INVALID; }
    
    sqlquery sql = _CdkeyCachePrepareSelect(sDatabase, sTable, sVariable);
    if (SqlStep(sql))
    {
        return SQLocalsPlayer_StringToLocation(SqlGetString(sql, 0));
    }
    return GetCdkeyLocation(oPC, sTable, sVariable);
}

json GetCachedCdkeyJson(object oPC, string sTable, string sVariable)
{
    oPC = GetMasterFromPossessedFamiliar(oPC);
    if (!GetIsPC(oPC)) return JsonNull();
    string sDatabase = GetPCPublicCDKey(oPC, TRUE);
    
    if (_WarnOnBadCdkeyTableString(sTable) || _WarnOnBadCdkeyTableString(sDatabase) || sDatabase == "" || sTable == "" || sVariable == "") { return JsonNull(); }
    
    sqlquery sql = _CdkeyCachePrepareSelect(sDatabase, sTable, sVariable);
    if (SqlStep(sql))
    {
        return SqlGetJson(sql, 0);
    }
    return GetCdkeyJson(oPC, sTable, sVariable);
}

void SetCachedCdkeyInt(object oPC, string sTable, string sVariable, int nValue)
{
    oPC = GetMasterFromPossessedFamiliar(oPC);
    if (!GetIsPC(oPC)) return;
    string sDatabase = GetPCPublicCDKey(oPC, TRUE);
    
    if (_WarnOnBadCdkeyTableString(sTable) || _WarnOnBadCdkeyTableString(sDatabase) || sDatabase == "" || sTable == "" || sVariable == "") { return; }
    
    sqlquery sql = _CdkeyCachePrepareInsert(sDatabase, sTable, sVariable);
    SqlBindInt(sql, "@value", nValue);
    SqlStep(sql);
}

void SetCachedCdkeyFloat(object oPC, string sTable, string sVariable, float fValue)
{
    oPC = GetMasterFromPossessedFamiliar(oPC);
    if (!GetIsPC(oPC)) return;
    string sDatabase = GetPCPublicCDKey(oPC, TRUE);
    
    if (_WarnOnBadCdkeyTableString(sTable) || _WarnOnBadCdkeyTableString(sDatabase) || sDatabase == "" || sTable == "" || sVariable == "") { return; }
    
    sqlquery sql = _CdkeyCachePrepareInsert(sDatabase, sTable, sVariable);
    SqlBindFloat(sql, "@value", fValue);
    SqlStep(sql);
}

void SetCachedCdkeyString(object oPC, string sTable, string sVariable, string sValue)
{
    oPC = GetMasterFromPossessedFamiliar(oPC);
    if (!GetIsPC(oPC)) return;
    string sDatabase = GetPCPublicCDKey(oPC, TRUE);
    
    if (_WarnOnBadCdkeyTableString(sTable) || _WarnOnBadCdkeyTableString(sDatabase) || sDatabase == "" || sTable == "" || sVariable == "") { return; }
    
    sqlquery sql = _CdkeyCachePrepareInsert(sDatabase, sTable, sVariable);
    SqlBindString(sql, "@value", sValue);
    SqlStep(sql);
}


void SetCachedCdkeyVector(object oPC, string sTable, string sVariable, vector vValue)
{
    oPC = GetMasterFromPossessedFamiliar(oPC);
    if (!GetIsPC(oPC)) return;
    string sDatabase = GetPCPublicCDKey(oPC, TRUE);
    
    if (_WarnOnBadCdkeyTableString(sTable) || _WarnOnBadCdkeyTableString(sDatabase) || sDatabase == "" || sTable == "" || sVariable == "") { return; }
    
    sqlquery sql = _CdkeyCachePrepareInsert(sDatabase, sTable, sVariable);
    SqlBindVector(sql, "@value", vValue);
    SqlStep(sql);
}

void SetCachedCdkeyLocation(object oPC, string sTable, string sVariable, location lValue)
{
    oPC = GetMasterFromPossessedFamiliar(oPC);
    if (!GetIsPC(oPC)) return;
    string sDatabase = GetPCPublicCDKey(oPC, TRUE);
    
    if (_WarnOnBadCdkeyTableString(sTable) || _WarnOnBadCdkeyTableString(sDatabase) || sDatabase == "" || sTable == "" || sVariable == "") { return; }
    
    sqlquery sql = _CdkeyCachePrepareInsert(sDatabase, sTable, sVariable);
    SqlBindString(sql, "@value", SQLocalsPlayer_LocationToString(lValue));
    SqlStep(sql);
}

void SetCachedCdkeyJson(object oPC, string sTable, string sVariable, json jValue)
{
    oPC = GetMasterFromPossessedFamiliar(oPC);
    if (!GetIsPC(oPC)) return;
    string sDatabase = GetPCPublicCDKey(oPC, TRUE);
    
    if (_WarnOnBadCdkeyTableString(sTable) || _WarnOnBadCdkeyTableString(sDatabase) || sDatabase == "" || sTable == "" || sVariable == "") { return; }
    
    sqlquery sql = _CdkeyCachePrepareInsert(sDatabase, sTable, sVariable);
    SqlBindJson(sql, "@value", jValue);
    SqlStep(sql);
}

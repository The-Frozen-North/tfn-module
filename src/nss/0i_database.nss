/*/////////////////////////////////////////////////////////////////////////////////////////////////////
 ScriptName: 0i_database
 Programmer: Philos
//////////////////////////////////////////////////////////////////////////////////////////////////////
 Handles all database functions for the server.
 This script is using the in game database to manage persistance.
*/////////////////////////////////////////////////////////////////////////////////////////////////////

const string SERVER_DATABASE = "NUIDatabase";
const string PLAYER_TABLE = "PlayerTable";
const string CHARACTER_TABLE = "CharacterTable";

// Defined sTableName constants: *_TABLE.
void CheckServerDataTableAndCreateTable (string sTableName);

// Defined sTableName constants: *_TABLE.
// Returns TRUE if data initialized, false if the data alread exists.
int CheckServerDataAndInitialize (object oObject, string sTableName, string sTag = "");

// oObject is the player/module the data is being saved for.
// sTable is the table to use: *_TABLE.
// sDataField should be one of the data fields for that table.
// iData is the integer data to be saved.
void SetServerDatabaseInt (object oObject, string sTableName, string sDataField, int nData);

// oObject is the player/module the data is for.
// sTable is the table to use: *_TABLE.
// sDataField should be one of the data fields for the table.
// Returns a integer of the data stored.
int GetServerDatabaseInt (object oObject, string sTableName, string sDataField);

// oObject is the player/module the data is being saved for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE.
// sDataField should be one of the data fields for that table.
// fData is the float data to be saved.
void SetServerDatabaseFloat (object oObject, string sTableName, string sDataField, float fData);

// oObject is the player/module the data is for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE.
// sDataField should be one of the data fields for the table.
// Returns a integer of the data stored.
float GetServerDatabaseFloat (object oObject, string sTableName, string sDataField);

// oObject is the player/module the data is being saved for.
// sTable is the table to use: *_TABLE.
// sDataField should be one of the data fields for that table.
// sData is the string data to be saved.
void SetServerDatabaseString (object oObject, string sTableName, string sDataField, string sData);

// oObject is the player/module the data is for.
// sTable is the table to use: *_TABLE.
// sDataField should be one of the data fields for the table.
// Returns a string of the data stored.
string GetServerDatabaseString (object oObject, string sTableName, string sDataField);

// oObject is the character/module the data is being saved for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE, OBJECT_TABLE.
// sTag is the tag to define this object in the database for this player npc1, chest1, etc.
// oData is the object data to be saved.
void SetServerDatabaseObject (object oObject, string sTableName, object oData, string sTag);

// oObject is the player/module the data is for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE.
// sTag is the tag to define this object in the database for this player npc1, chest1, etc.
// lLocationToSpawn will spawn the object at that location.
// oInventory will spawn the object in that objects inventory.
object GetServerDatabaseObject (object oObject, string sTableName, location lLocationToSpawn, string sTag, object oInventory = OBJECT_INVALID);

// oObject is the player/module the data is for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE.
// sTag is the tag to define this object in the database for this player npc1, chest1, etc.
void DeleteServerDatabaseObject (object oObject, string sTableName, string sTag);

// Object must be a player character.
// Defined sTableName constants: *_TABLE.
void CheckObjectDataTableAndCreateTable (object oObject, string sTableName);

// Defined sTableName constants: *_TABLE.
// Must add a quest name if initializing a quest table.
void CheckObjectDataAndInitialize (object oObject, string sTableName, string sDataName = "");

// oObject is the player/module the data is being saved for.
// sTable is the table to use: *_TABLE.
// sDataField should be one of the data fields for that table.
// iData is the integer data to be saved.
// sDataName is the name of the quest if we are saveing a quest.
void SetObjectDatabaseInt (object oObject, string sTableName, string sDataField, int iData, string sDataName = "");

// oObject is the player/module the data is for.
// sTable is the table to use: *_TABLE.
// sDataField should be one of the data fields for the table.
// sDataName is the name of the quest if we are saveing a quest.
// Returns a integer of the data stored.
int GetObjectDatabaseInt (object oObject, string sTableName, string sDataField, string sDataName = "");

// oObject is the player/module the data is being saved for.
// sTable is the table to use: *_TABLE.
// sDataField should be one of the data fields for that table.
// sData is the string data to be saved.
// sDataName is the name of the quest if we are saveing a quest.
void SetObjectDatabaseString (object oObject, string sTableName, string sDataField, string sData, string sDataName = "");

// oObject is the player/module the data is for.
// sTable is the table to use: *_TABLE.
// sDataField should be one of the data fields for the table.
// sDataName is the name of the quest if we are saveing a quest.
// Returns a string of the data stored.
string GetObjectDatabaseString (object oObject, string sTableName, string sDataField, string sDataName = "");

// oObject is the player/module the data is being saved for.
// sTable is the table to use: *_TABLE.
// sDataField should be one of the data fields for that table.
// sData is the float data to be saved.
// sDataName is the name of the quest if we are saveing a quest.
void SetObjectDatabaseFloat (object oObject, string sTableName, string sDataField, float fData, string sDataName = "");

// oObject is the player/module the data is for.
// sTable is the table to use: *_TABLE.
// sDataField should be one of the data fields for the table.
// sDataName is the name of the quest if we are saveing a quest.
// Returns a float of the data stored.
float GetObjectDatabaseFloat (object oObject, string sTableName, string sDataField, string sDataName = "");

// oObject is the player the data is for.
// sTable is the table to use: *_TABLE.
// sDataName is the name of the quest if we are saveing a quest.
void DeleteObjectDatabase (object oObject, string sTableName, string sDataName = "");

// Defined sTableName constants: *_TABLE.
void CreateServerDataTable (string sTableName)
{
    if (sTableName == PLAYER_TABLE)
    {
        sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE,
            "CREATE TABLE IF NOT EXISTS " + sTableName + " (" +
            "name           TEXT, " +
            "effects        INT, " +
            "pcplayerwinhv  INT, " +
            "pcplayerwinx   FLOAT, " +
            "pcplayerwiny   FLOAT, " +
            "pcoptionswinx   FLOAT, " +
            "pcoptionswiny   FLOAT, " +
            "pcinfowinx   FLOAT, " +
            "pcinfowiny   FLOAT, " +
            "pcbugwinx      FLOAT, " +
            "pcbugwiny      FLOAT, " +
            "pcdescwinx     FLOAT, " +
            "pcdescwiny     FLOAT, " +
            "pcdicewinx     FLOAT, " +
            "pcdicewiny     FLOAT, " +
            "publiccdkey    TEXT, " +
            "lastipaddress  TEXT, " +
            "creationdate   INTEGER, " +
            "PRIMARY KEY(name, publiccdkey));");
        SqlStep (sql);
    }
}

// Defined sTableName constants: *_TABLE.
void CheckServerDataTableAndCreateTable (string sTableName)
{
    string sQuery = "SELECT name FROM sqlite_master WHERE type ='table' AND name=@tableName;";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindString (sql, "@tableName", sTableName);
    if (!SqlStep (sql)) CreateServerDataTable (sTableName);
}

void InitializePlayerData (object oPlayer, string sTableName)
{
    string sName = GetPCPlayerName (oPlayer);
    string sQuery = "INSERT INTO " + sTableName + "(name, effects, " +
        "pcplayerwinhv, pcplayerwinx, pcplayerwiny, pcoptionswinx, pcoptionswiny, " +
        "pcinfowinx, pcinfowiny, pcbugwinx, pcbugwiny, pcdescwinx, pcdescwiny, " +
        "pcdicewinx, pcdicewiny, publiccdkey, lastipaddress, creationdate) " +
        "VALUES (@name, @effects, @pcplayerwinhv, @pcplayerwinx, @pcplayerwiny, " +
        "@pcoptionswinx, @pcoptionswiny, @pcinfowinx, @pcinfowiny, @pcbugwinx, " +
        "@pcbugwiny, @pcdescwinx, @pcdescwiny, @pcdicewinx, " +
        "@pcdicewiny, @publiccdkey, @lastipaddress, @creationdate);";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindString (sql, "@name", sName);
    SqlBindInt (sql, "@effects", 0);
    SqlBindInt (sql, "@pcplayerwinhv", 0);
    SqlBindFloat (sql, "@pcplayerwinx", -1.0f);
    SqlBindFloat (sql, "@pcplayerwiny", 0.0f);
    SqlBindFloat (sql, "@pcoptionswinx", -1.0f);
    SqlBindFloat (sql, "@pcoptionswiny", 0.0f);
    SqlBindFloat (sql, "@pcinfowinx", -1.0f);
    SqlBindFloat (sql, "@pcinfowiny", 0.0f);
    SqlBindFloat (sql, "@pcbugwinx", -1.0f);
    SqlBindFloat (sql, "@pcbugwiny", 0.0f);
    SqlBindFloat (sql, "@pcdescwinx", -1.0f);
    SqlBindFloat (sql, "@pcdescwiny", 0.0f);
    SqlBindFloat (sql, "@pcdicewinx", -1.0f);
    SqlBindFloat (sql, "@pcdicewiny", 0.0f);
    SqlBindString (sql, "@publiccdkey", GetPCPublicCDKey (oPlayer));
    SqlBindString (sql, "@lastipaddress", "");
    SqlBindString (sql, "@creationdate", "strftime('%m-%d-%Y (%H:%M)','now', '-5 hours')");
    SqlStep (sql);
}

int CheckServerDataAndInitialize (object oObject, string sTableName, string sTag = "")
{
    string sQuery, sName;
    sqlquery sql;
    if (sTableName == PLAYER_TABLE) sName = GetPCPlayerName (oObject);
    else sName = GetName (oObject, TRUE);
    if (sTag != "")
    {
        sQuery = "SELECT name FROM " + sTableName + " Where name = @name AND tag = @tag;";
        sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
        SqlBindString (sql, "@name", sName);
        SqlBindString (sql, "@tag", sTag);
    }
    else
    {
        sQuery = "SELECT name FROM " + sTableName + " Where name = @name;";
        sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
        SqlBindString (sql, "@name", sName);
    }
    if (!SqlStep (sql))
    {
        if (sTableName == PLAYER_TABLE) InitializePlayerData (oObject, sTableName);
        return TRUE;
    }
    return FALSE;
}

// oObject is the player/module the data is being saved for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE.
// sDataField should be one of the data fields for that table.
// nData is the integer data to be saved.
void SetServerDatabaseInt (object oObject, string sTableName, string sDataField, int nData)
{
    string sName;
    if (sTableName == PLAYER_TABLE) sName = GetPCPlayerName (oObject);
    else sName = GetName (oObject, TRUE);
    string sQuery;
    sQuery = "UPDATE " + sTableName + " SET " + sDataField + " = @data WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindInt (sql, "@data", nData);
    SqlBindString (sql, "@name", sName);
    SqlStep (sql);
}

// oObject is the player/module the data is for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE.
// sDataField should be one of the data fields for the table.
// Returns a integer of the data stored.
int GetServerDatabaseInt (object oObject, string sTableName, string sDataField)
{
    string sName;
    if (sTableName == PLAYER_TABLE) sName = GetPCPlayerName (oObject);
    else sName = GetName (oObject, TRUE);
    string sQuery;
    sQuery = "SELECT " + sDataField + " FROM " + sTableName + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindString (sql, "@name", sName);
    if (SqlStep (sql)) return SqlGetInt (sql, 0);
    else return 0;
}

// oObject is the player/module the data is being saved for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE.
// sDataField should be one of the data fields for that table.
// fData is the float data to be saved.
void SetServerDatabaseFloat (object oObject, string sTableName, string sDataField, float fData)
{
    string sName;
    if (sTableName == PLAYER_TABLE) sName = GetPCPlayerName (oObject);
    else sName = GetName (oObject, TRUE);
    string sQuery;
    sQuery = "UPDATE " + sTableName + " SET " + sDataField + " = @data WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindFloat (sql, "@data", fData);
    SqlBindString (sql, "@name", sName);
    SqlStep (sql);
}

// oObject is the player/module the data is for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE.
// sDataField should be one of the data fields for the table.
// Returns a integer of the data stored.
float GetServerDatabaseFloat (object oObject, string sTableName, string sDataField)
{
    string sName;
    if (sTableName == PLAYER_TABLE) sName = GetPCPlayerName (oObject);
    else sName = GetName (oObject, TRUE);
    string sQuery;
    sQuery = "SELECT " + sDataField + " FROM " + sTableName + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindString (sql, "@name", sName);
    if (SqlStep (sql)) return SqlGetFloat (sql, 0);
    else return 0.0f;
}

// oObject is the player/module the data is being saved for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE.
// sDataField should be one of the data fields for that table.
// sData is the string data to be saved.
void SetServerDatabaseString (object oObject, string sTableName, string sDataField, string sData)
{
    string sName;
    if (sTableName == PLAYER_TABLE) sName = GetPCPlayerName (oObject);
    else sName = GetName (oObject, TRUE);
    string sQuery;
    sQuery = "UPDATE " + sTableName + " SET " + sDataField + " = @data WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindString (sql, "@data", sData);
    SqlBindString (sql, "@name", sName);
    SqlStep (sql);
}

// oObject is the character/module the data is for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE.
// sDataField should be one of the data fields for the table.
// Returns a string of the data stored.
string GetServerDatabaseString (object oObject, string sTableName, string sDataField)
{
    string sName;
    if (sTableName == PLAYER_TABLE) sName = GetPCPlayerName (oObject);
    else sName = GetName (oObject, TRUE);
    string sQuery;
    sQuery = "SELECT " + sDataField + " FROM " + sTableName + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindString (sql, "@name", sName);
    if (SqlStep (sql)) return SqlGetString (sql, 0);
    else return "";
}

// oObject is the character/module the data is being saved for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE, OBJECT_TABLE.
// sTag is the tag to define this object in the database for this player npc1, chest1, etc.
// oData is the object data to be saved.
void SetServerDatabaseObject (object oObject, string sTableName, object oData, string sTag)
{
    string sName = GetName (oObject, TRUE);
    string sQuery = "UPDATE " + sTableName + " SET object = @data WHERE name = @name AND tag = @tag;";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindObject (sql, "@data", oData);
    SqlBindString (sql, "@name", sName);
    SqlBindString (sql, "@tag", sTag);
    SqlStep (sql);
}

// oObject is the player/module the data is for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE.
// sTag is the tag to define this object in the database for this player npc1, chest1, etc.
// lLocationToSpawn will spawn the object at that location.
// oInventory will spawn the object in that objects inventory.
object GetServerDatabaseObject (object oObject, string sTableName, location lLocationToSpawn, string sTag, object oInventory = OBJECT_INVALID)
{
    string sName = GetName (oObject, TRUE);
    string sQuery = "SELECT object FROM " + sTableName + " WHERE name = @name AND tag = @tag;";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindString (sql, "@name", sName);
    SqlBindString (sql, "@tag", sTag);
    if (SqlStep (sql)) return SqlGetObject (sql, 0, lLocationToSpawn, oInventory);
    return OBJECT_INVALID;
}

// oObject is the player/module the data is for.
// sTable is the table to use: SERVER_TABLE, PLAYER_TABLE, OBJECT_TABLE, DM_TABLE, NPC_TABLE.
// sTag is the tag to define this object in the database for this player npc1, chest1, etc.
void DeleteServerDatabaseObject (object oObject, string sTableName, string sTag)
{
    string sName = GetName (oObject, TRUE);
    string sQuery = "DELETE FROM " + sTableName + " WHERE name = @name AND tag = @tag;";
    sqlquery sql = SqlPrepareQueryCampaign (SERVER_DATABASE, sQuery);
    SqlBindString (sql, "@name", sName);
    SqlBindString (sql, "@tag", sTag);
    SqlStep (sql);
}

// Object must be a player character.
// Defined sTableName constants: CHARACTER_TABLE, QUEST_TABLE, PIN_TABLE.
void CreateObjectDataTable (object oObject, string sTableName)
{
    if (sTableName == CHARACTER_TABLE)
    {
        sqlquery sql = SqlPrepareQueryObject (oObject,
            "CREATE TABLE IF NOT EXISTS " + sTableName + " (" +
            "name           TEXT, " +
            "playername     TEXT, " +
            "location       TEXT, " +
            "lastlogin      INTEGER, " +
            "creationdate   INTEGER, " +
            "PRIMARY KEY(name, playername));");
        SqlStep (sql);
    }
}

// Object must be a player character.
// Defined sTableName constants: *_TABLE.
void CheckObjectDataTableAndCreateTable (object oObject, string sTableName)
{
    string sQuery = "SELECT name FROM sqlite_master WHERE type='table' AND name=@tableName;";
    sqlquery sql = SqlPrepareQueryObject (oObject, sQuery);
    SqlBindString (sql, "@tableName", sTableName);
    if (!SqlStep (sql)) CreateObjectDataTable (oObject, sTableName);
}

void InitializeCharacterData (object oPC, string sTableName)
{
    string sName = GetName (oPC, TRUE);
    string sPlayerName = GetPCPlayerName (oPC);
    string sQuery = "INSERT INTO " + sTableName + "(name, playername, location, " +
        "lastlogin, creationdate) VALUES (@name, @playername, @location, " +
        "@lastlogin, @creationdate);";
    sqlquery sql = SqlPrepareQueryObject (oPC, sQuery);
    SqlBindString (sql, "@name", sName);
    SqlBindString (sql, "@playername", sPlayerName);
    SqlBindString (sql, "@location", "");
    SqlBindInt (sql, "@lastlogin", 0);
    SqlBindString (sql, "@creationdate", "strftime('%m-%d-%Y (%H:%M)','now', '-5 hours')");
    SqlStep (sql);
}

// Defined sTableName constants: *_TABLE.
void CheckObjectDataAndInitialize (object oObject, string sTableName, string sDataName = "")
{
    CheckObjectDataTableAndCreateTable (oObject, sTableName);
    if (oObject == OBJECT_INVALID) return;
    string sName;
    if (sDataName == "") sName = GetName (oObject, TRUE);
    else sName = sDataName;
    string sQuery = "SELECT name FROM " + sTableName + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject (oObject, sQuery);
    SqlBindString (sql, "@name", sName);
    if (!SqlStep (sql))
    {
        if (sTableName == CHARACTER_TABLE) InitializeCharacterData (oObject, sTableName);
    }
}

// oObject is the player/module the data is being saved for.
// sTable is the table to use: CHARACTER_TABLE.
// sDataField should be one of the data fields for that table.
// iData is the integer data to be saved.
// sDataName is the name of the quest if we are saveing a quest.
void SetObjectDatabaseInt (object oObject, string sTableName, string sDataField, int iData, string sDataName = "")
{
    string sName;
    if (sDataName == "") sName = GetName (oObject, TRUE);
    else sName = sDataName;
    string sQuery = "UPDATE " + sTableName + " SET " + sDataField + " = @data WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject (oObject, sQuery);
    SqlBindInt (sql, "@data", iData);
    SqlBindString (sql, "@name", sName);
    SqlStep (sql);
}

// oObject is the player/module the data is for.
// sTable is the table to use: CHARACTER_TABLE.
// sDataField should be one of the data fields for the table.
// sDataName is the name of the quest if we are saveing a quest.
// Returns a integer of the data stored.
int GetObjectDatabaseInt (object oObject, string sTableName, string sDataField, string sDataName = "")
{
    string sName;
    if (sDataName == "") sName = GetName (oObject, TRUE);
    else sName = sDataName;
    string sQuery = "SELECT " + sDataField + " FROM " + sTableName + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject (oObject, sQuery);
    SqlBindString (sql, "@name", sName);
    if (SqlStep (sql)) return SqlGetInt (sql, 0);
    else return 0;
}

// oObject is the player/module the data is being saved for.
// sTable is the table to use: CHARACTER_TABLE.
// sDataField should be one of the data fields for that table.
// sDataName is the name of the quest if we are saveing a quest.
// fData is the float data to be saved.
void SetObjectDatabaseFloat (object oObject, string sTableName, string sDataField, float fData, string sDataName = "")
{
    string sName;
    if (sDataName == "") sName = GetName (oObject, TRUE);
    else sName = sDataName;
    string sQuery = "UPDATE " + sTableName + " SET " + sDataField + " = @data WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject (oObject, sQuery);
    SqlBindFloat (sql, "@data", fData);
    SqlBindString (sql, "@name", sName);
    SqlStep (sql);
}

// oObject is the player/module the data is for.
// sTable is the table to use: CHARACTER_TABLE.
// sDataField should be one of the data fields for the table.
// sDataName is the name of the quest if we are saveing a quest.
// Returns a float of the data stored.
float GetObjectDatabaseFloat (object oObject, string sTableName, string sDataField, string sDataName = "")
{
    string sName;
    if (sDataName == "") sName = GetName (oObject, TRUE);
    else sName = sDataName;
    string sQuery = "SELECT " + sDataField + " FROM " + sTableName + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject (oObject, sQuery);
    SqlBindString (sql, "@name", sName);
    if (SqlStep (sql)) return SqlGetFloat (sql, 0);
    else return 0.0f;
}

// oObject is the player/module the data is being saved for.
// sTable is the table to use: CHARACTER_TABLE.
// sDataField should be one of the data fields for that table.
// sDataName is the name of the quest if we are saveing a quest.
// sData is the string data to be saved.
void SetObjectDatabaseString (object oObject, string sTableName, string sDataField, string sData, string sDataName = "")
{
    string sName;
    if (sDataName == "") sName = GetName (oObject, TRUE);
    else sName = sDataName;
    string sQuery = "UPDATE " + sTableName + " SET " + sDataField + " = @data WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject (oObject, sQuery);
    SqlBindString (sql, "@data", sData);
    SqlBindString (sql, "@name", sName);
    SqlStep (sql);
}

// oObject is the player/module the data is for.
// sTable is the table to use: CHARACTER_TABLE.
// sDataField should be one of the data fields for the table.
// sDataName is the name of the quest if we are saveing a quest.
// Returns a string of the data stored.
string GetObjectDatabaseString (object oObject, string sTableName, string sDataField, string sDataName = "")
{
    string sName;
    if (sDataName == "") sName = GetName (oObject, TRUE);
    else sName = sDataName;
    string sQuery = "SELECT " + sDataField + " FROM " + sTableName + " WHERE name = @name;";
    sqlquery sql = SqlPrepareQueryObject (oObject, sQuery);
    SqlBindString (sql, "@name", sName);
    if (SqlStep (sql)) return SqlGetString (sql, 0);
    else return "";
}

void DeleteObjectDatabaseTable (object oObject, string sTableName)
{
    string sQuery = "DELETE FROM " + sTableName + ";";
    sqlquery sql = SqlPrepareQueryObject (oObject, sQuery);
    SqlStep (sql);
}

// sDataName is the number of the pin to save.
void SavePinData (object oPC, string sTableName, string sDataName, string sAreaTag, float fXpos, float fYpos, string sEntry)
{
    string sQuery = "INSERT INTO " + sTableName + "(name, areatag, xpos, ypos, entry) " +
        "VALUES (@name, @areatag, @xpos, @ypos, @entry);";
    sqlquery sql = SqlPrepareQueryObject (oPC, sQuery);
    SqlBindString (sql, "@name", sDataName);
    SqlBindString (sql, "@areatag", sAreaTag);
    SqlBindFloat (sql, "@xpos", fXpos);
    SqlBindFloat (sql, "@ypos", fYpos);
    SqlBindString (sql, "@entry", sEntry);
    SqlStep (sql);
}



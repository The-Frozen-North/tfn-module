//::///////////////////////////////////////////////
//:: Utility Include: SQLocalsPlayer
//:: utl_i_sqlplayer.nss
//:://////////////////////////////////////////////
/*
    Daz wrote these library functions to act as replacements for the usual local
    functions:
    * GetLocalInt / SetLocalInt / DeleteLocalInt
    * GetLocalFloat / SetLocalFloat / DeleteLocalFloat
    * GetLocalString / SetLocalString / DeleteLocalString
    * GetLocalObject / SetLocalObject / DeleteLocalObject (NB: remember these are references NOT serialised objects)
    * GetLocalLocation / SetLocalLocation / DeleteLocalLocation
    * Plus a new function for saving just a vector by itself.
    Since sometimes iterating over many locals is slow, this might be an excellent way to
    speed up large amounts of access, or for debugging, or using regex or whatever else.

    These are functions for PC Object persistence only. See utl_i_sqlocals.nss for
    the module saved version.
*/
//:://////////////////////////////////////////////
//:: Based off of the nwscript_utility_scripts project; see for dates/creator info
//:: https://github.com/Finaldeath/nwscript_utility_scripts
//:://////////////////////////////////////////////

const string SQLOCALSPLAYER_TABLE_NAME     = "sqlocalsplayer_table";

const int SQLOCALSPLAYER_TYPE_ALL          = 0;
const int SQLOCALSPLAYER_TYPE_INT          = 1;
const int SQLOCALSPLAYER_TYPE_FLOAT        = 2;
const int SQLOCALSPLAYER_TYPE_STRING       = 4;
const int SQLOCALSPLAYER_TYPE_OBJECT       = 8;
const int SQLOCALSPLAYER_TYPE_VECTOR       = 16;
const int SQLOCALSPLAYER_TYPE_LOCATION     = 32;

// Returns an integer stored on oPlayer, or 0 on error
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
int SQLocalsPlayer_GetInt(object oPlayer, string sVarName);
// Sets an integer stored on oPlayer to the given value
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
// * nValue - Value to store
void SQLocalsPlayer_SetInt(object oPlayer, string sVarName, int nValue);
// Deletes an integer stored on oPlayer
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to delete
void SQLocalsPlayer_DeleteInt(object oPlayer, string sVarName);

// Returns a float stored on oPlayer, or 0.0 on error
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
float SQLocalsPlayer_GetFloat(object oPlayer, string sVarName);
// Sets a float stored on oPlayer to the given value
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
// * fValue - Value to store
void SQLocalsPlayer_SetFloat(object oPlayer, string sVarName, float fValue);
// Deletes a float stored on oPlayer
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to delete
void SQLocalsPlayer_DeleteFloat(object oPlayer, string sVarName);

// Returns an string stored on oPlayer, or "" on error
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
string SQLocalsPlayer_GetString(object oPlayer, string sVarName);
// Sets a string stored on oPlayer to the given value
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
// * sValue - Value to store
void SQLocalsPlayer_SetString(object oPlayer, string sVarName, string sValue);
// Deletes a string stored on oPlayer
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to delete
void SQLocalsPlayer_DeleteString(object oPlayer, string sVarName);

// Returns an object identifier stored on oPlayer
// If this is used on a player it might return a "once valid" OID, so check
// with GetIsObjectValid, do not compare to OBJECT_INVALID.
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
object SQLocalsPlayer_GetObject(object oPlayer, string sVarName);
// Sets an object identifier stored on oPlayer to the given value
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
// * oValue - Value to store
void SQLocalsPlayer_SetObject(object oPlayer, string sVarName, object oValue);
// Deletes an object identifier stored on oPlayer
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to delete
void SQLocalsPlayer_DeleteObject(object oPlayer, string sVarName);

// Returns a vector stored on oPlayer, or [0.0, 0.0, 0.0] on error
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
vector SQLocalsPlayer_GetVector(object oPlayer, string sVarName);
// Sets a vector stored on oPlayer to the given value
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
// * vValue - Value to store
void SQLocalsPlayer_SetVector(object oPlayer, string sVarName, vector vValue);
// Deletes a vector stored on oPlayer
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to delete
void SQLocalsPlayer_DeleteVector(object oPlayer, string sVarName);

// Returns a location stored on oPlayer, or the starting location of the module on error
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
location SQLocalsPlayer_GetLocation(object oPlayer, string sVarName);
// Sets a location stored on oPlayer to the given value
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
// * lValue - Value to store
void SQLocalsPlayer_SetLocation(object oPlayer, string sVarName, location lValue);
// Deletes a location stored on oPlayer
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to delete
void SQLocalsPlayer_DeleteLocation(object oPlayer, string sVarName);

// Deletes a set of locals stored on oPlayer matching the given criteria
// * oPlayer - a player object to save the variable on
// * nType - The SQLOCALSPLAYER_TYPE_* you wish to remove (default: SQLOCALSPLAYER_TYPE_ALL)
// * sLike - The string to compare with the SQL "like" comparison
// * sEscape - The escape character to use with the SQL "escape" keyword
void SQLocalsPlayer_Delete(object oPlayer, int nType = SQLOCALSPLAYER_TYPE_ALL, string sLike = "", string sEscape = "");
// Counts a set of locals stored on oPlayer matching the given criteria
// * oPlayer - a player object to save the variable on
// * nType - The SQLOCALSPLAYER_TYPE_* you wish to count (default: SQLOCALSPLAYER_TYPE_ALL)
// * sLike - The string to compare with the SQL "like" comparison
// * sEscape - The escape character to use with the SQL "escape" keyword
int SQLocalsPlayer_Count(object oPlayer, int nType = SQLOCALSPLAYER_TYPE_ALL, string sLike = "", string sEscape = "");
// Checks a locals stored on oPlayer is set
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
// * nType - The SQLOCALSPLAYER_TYPE_* you wish to check
int SQLocalsPlayer_IsSet(object oPlayer, string sVarName, int nType);
// Returns the last Unix time the given variable was updated
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
// * nType - The SQLOCALSPLAYER_TYPE_* you wish to check
int SQLocalsPlayer_GetLastUpdated_UnixEpoch(object oPlayer, string sVarName, int nType);
// Returns the last UTC time the given variable was updated
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
// * nType - The SQLOCALSPLAYER_TYPE_* you wish to check
string SQLocalsPlayer_GetLastUpdated_UTC(object oPlayer, string sVarName, int nType);


/* INTERNAL */
void SQLocalsPlayer_CreateTable(object oPlayer)
{
    sqlquery sql = SqlPrepareQueryObject(oPlayer,
        "CREATE TABLE IF NOT EXISTS " + SQLOCALSPLAYER_TABLE_NAME + " (" +
        "type INTEGER, " +
        "varname TEXT, " +
        "value TEXT, " +
        "timestamp INTEGER, " +
        "PRIMARY KEY(type, varname));");
    SqlStep(sql);
}

sqlquery SQLocalsPlayer_PrepareSelect(object oPlayer, int nType, string sVarName)
{
    SQLocalsPlayer_CreateTable(oPlayer);

    sqlquery sql = SqlPrepareQueryObject(oPlayer,
        "SELECT value FROM " + SQLOCALSPLAYER_TABLE_NAME + " " +
        "WHERE type = @type AND varname = @varname;");

    SqlBindInt(sql, "@type", nType);
    SqlBindString(sql, "@varname", sVarName);

    return sql;
}

sqlquery SQLocalsPlayer_PrepareInsert(object oPlayer, int nType, string sVarName)
{
    SQLocalsPlayer_CreateTable(oPlayer);

    sqlquery sql = SqlPrepareQueryObject(oPlayer,
        "INSERT INTO " + SQLOCALSPLAYER_TABLE_NAME + " " +
        "(type, varname, value, timestamp) VALUES (@type, @varname, @value, strftime('%s','now')) " +
        "ON CONFLICT (type, varname) DO UPDATE SET value = @value, timestamp = strftime('%s','now');");

    SqlBindInt(sql, "@type", nType);
    SqlBindString(sql, "@varname", sVarName);

    return sql;
}

sqlquery SQLocalsPlayer_PrepareDelete(object oPlayer, int nType, string sVarName)
{
    SQLocalsPlayer_CreateTable(oPlayer);

    sqlquery sql = SqlPrepareQueryObject(oPlayer,
        "DELETE FROM " + SQLOCALSPLAYER_TABLE_NAME + " " +
        "WHERE type = @type AND varname = @varname;");

    SqlBindInt(sql, "@type", nType);
    SqlBindString(sql, "@varname", sVarName);

    return sql;
}

string SQLocalsPlayer_LocationToString(location locLocation)
{
    string sAreaId = ObjectToString(GetAreaFromLocation(locLocation));
    vector vPosition = GetPositionFromLocation(locLocation);
    float fFacing = GetFacingFromLocation(locLocation);

    return "#A#" + sAreaId +
           "#X#" + FloatToString(vPosition.x, 0, 5) +
           "#Y#" + FloatToString(vPosition.y, 0, 5) +
           "#Z#" + FloatToString(vPosition.z, 0, 5) +
           "#F#" + FloatToString(fFacing, 0, 5) + "#";
}

location SQLocalsPlayer_StringToLocation(string sLocation)
{
    location locLocation;

    int nLength = GetStringLength(sLocation);

    if(nLength > 0)
    {
        int nPos, nCount;

        nPos = FindSubString(sLocation, "#A#") + 3;
        nCount = FindSubString(GetSubString(sLocation, nPos, nLength - nPos), "#");
        object oArea = StringToObject(GetSubString(sLocation, nPos, nCount));

        nPos = FindSubString(sLocation, "#X#") + 3;
        nCount = FindSubString(GetSubString(sLocation, nPos, nLength - nPos), "#");
        float fX = StringToFloat(GetSubString(sLocation, nPos, nCount));

        nPos = FindSubString(sLocation, "#Y#") + 3;
        nCount = FindSubString(GetSubString(sLocation, nPos, nLength - nPos), "#");
        float fY = StringToFloat(GetSubString(sLocation, nPos, nCount));

        nPos = FindSubString(sLocation, "#Z#") + 3;
        nCount = FindSubString(GetSubString(sLocation, nPos, nLength - nPos), "#");
        float fZ = StringToFloat(GetSubString(sLocation, nPos, nCount));

        vector vPosition = Vector(fX, fY, fZ);

        nPos = FindSubString(sLocation, "#F#") + 3;
        nCount = FindSubString(GetSubString(sLocation, nPos, nLength - nPos), "#");
        float fOrientation = StringToFloat(GetSubString(sLocation, nPos, nCount));

        if (GetIsObjectValid(oArea))
            locLocation = Location(oArea, vPosition, fOrientation);
        else
            locLocation = GetStartingLocation();
    }

    return locLocation;
}
/* **** */

/* INT */

// Returns an integer stored on oPlayer, or 0 on error
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
int SQLocalsPlayer_GetInt(object oPlayer, string sVarName)
{
    if (!GetIsPC(oPlayer) || sVarName == "") return 0;

    sqlquery sql = SQLocalsPlayer_PrepareSelect(oPlayer, SQLOCALSPLAYER_TYPE_INT, sVarName);

    if (SqlStep(sql))
        return SqlGetInt(sql, 0);
    else
        return 0;
}

// Sets an integer stored on oPlayer to the given value
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
// * nValue - Value to store
void SQLocalsPlayer_SetInt(object oPlayer, string sVarName, int nValue)
{
    if (!GetIsPC(oPlayer) || sVarName == "") return;

    sqlquery sql = SQLocalsPlayer_PrepareInsert(oPlayer, SQLOCALSPLAYER_TYPE_INT, sVarName);
    SqlBindInt(sql, "@value", nValue);
    SqlStep(sql);
}

// Deletes an integer stored on oPlayer
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to delete
void SQLocalsPlayer_DeleteInt(object oPlayer, string sVarName)
{
    if (!GetIsPC(oPlayer) || sVarName == "") return;

    sqlquery sql = SQLocalsPlayer_PrepareDelete(oPlayer, SQLOCALSPLAYER_TYPE_INT, sVarName);
    SqlStep(sql);
}
/* **** */

/* FLOAT */

// Returns a float stored on oPlayer, or 0.0 on error
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
float SQLocalsPlayer_GetFloat(object oPlayer, string sVarName)
{
    if (!GetIsPC(oPlayer) || sVarName == "") return 0.0f;

    sqlquery sql = SQLocalsPlayer_PrepareSelect(oPlayer, SQLOCALSPLAYER_TYPE_FLOAT, sVarName);

    if (SqlStep(sql))
        return SqlGetFloat(sql, 0);
    else
        return 0.0f;
}

// Sets a float stored on oPlayer to the given value
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
// * fValue - Value to store
void SQLocalsPlayer_SetFloat(object oPlayer, string sVarName, float fValue)
{
    if (!GetIsPC(oPlayer) || sVarName == "") return;

    sqlquery sql = SQLocalsPlayer_PrepareInsert(oPlayer, SQLOCALSPLAYER_TYPE_FLOAT, sVarName);
    SqlBindFloat(sql, "@value", fValue);
    SqlStep(sql);
}

// Deletes a float stored on oPlayer
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to delete
void SQLocalsPlayer_DeleteFloat(object oPlayer, string sVarName)
{
    if (!GetIsPC(oPlayer) || sVarName == "") return;

    sqlquery sql = SQLocalsPlayer_PrepareDelete(oPlayer, SQLOCALSPLAYER_TYPE_FLOAT, sVarName);
    SqlStep(sql);
}
/* **** */

/* STRING */

// Returns an string stored on oPlayer, or "" on error
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
string SQLocalsPlayer_GetString(object oPlayer, string sVarName)
{
    if (!GetIsPC(oPlayer) || sVarName == "") return "";

    sqlquery sql = SQLocalsPlayer_PrepareSelect(oPlayer, SQLOCALSPLAYER_TYPE_STRING, sVarName);

    if (SqlStep(sql))
        return SqlGetString(sql, 0);
    else
        return "";
}

// Sets a string stored on oPlayer to the given value
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
// * sValue - Value to store
void SQLocalsPlayer_SetString(object oPlayer, string sVarName, string sValue)
{
    if (!GetIsPC(oPlayer) || sVarName == "") return;

    sqlquery sql = SQLocalsPlayer_PrepareInsert(oPlayer, SQLOCALSPLAYER_TYPE_STRING, sVarName);
    SqlBindString(sql, "@value", sValue);
    SqlStep(sql);
}

// Deletes a string stored on oPlayer
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to delete
void SQLocalsPlayer_DeleteString(object oPlayer, string sVarName)
{
    if (!GetIsPC(oPlayer) || sVarName == "") return;

    sqlquery sql = SQLocalsPlayer_PrepareDelete(oPlayer, SQLOCALSPLAYER_TYPE_STRING, sVarName);
    SqlStep(sql);
}
/* **** */

/* OBJECT */


// Returns an object identifier stored on oPlayer
// If this is used on a player it might return a "once valid" OID, so check
// with GetIsObjectValid, do not compare to OBJECT_INVALID.
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
object SQLocalsPlayer_GetObject(object oPlayer, string sVarName)
{
    if (!GetIsPC(oPlayer) || sVarName == "") return OBJECT_INVALID;

    sqlquery sql = SQLocalsPlayer_PrepareSelect(oPlayer, SQLOCALSPLAYER_TYPE_OBJECT, sVarName);

    if (SqlStep(sql))
        return StringToObject(SqlGetString(sql, 0));
    else
        return OBJECT_INVALID;
}

// Sets an object identifier stored on oPlayer to the given value
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
// * oValue - Value to store
void SQLocalsPlayer_SetObject(object oPlayer, string sVarName, object oValue)
{
    if (!GetIsPC(oPlayer) || sVarName == "") return;

    sqlquery sql = SQLocalsPlayer_PrepareInsert(oPlayer, SQLOCALSPLAYER_TYPE_OBJECT, sVarName);
    SqlBindString(sql, "@value", ObjectToString(oValue));
    SqlStep(sql);
}

// Deletes an object identifier stored on oPlayer
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to delete
void SQLocalsPlayer_DeleteObject(object oPlayer, string sVarName)
{
    if (!GetIsPC(oPlayer) || sVarName == "") return;

    sqlquery sql = SQLocalsPlayer_PrepareDelete(oPlayer, SQLOCALSPLAYER_TYPE_OBJECT, sVarName);
    SqlStep(sql);
}
/* **** */

/* VECTOR */

// Returns a vector stored on oPlayer, or [0.0, 0.0, 0.0] on error
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
vector SQLocalsPlayer_GetVector(object oPlayer, string sVarName)
{
    if (!GetIsPC(oPlayer) || sVarName == "") return [0.0f, 0.0f, 0.0f];

    sqlquery sql = SQLocalsPlayer_PrepareSelect(oPlayer, SQLOCALSPLAYER_TYPE_VECTOR, sVarName);

    if (SqlStep(sql))
        return SqlGetVector(sql, 0);
    else
        return [0.0f, 0.0f, 0.0f];
}

// Sets a vector stored on oPlayer to the given value
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
// * vValue - Value to store
void SQLocalsPlayer_SetVector(object oPlayer, string sVarName, vector vValue)
{
    if (!GetIsPC(oPlayer) || sVarName == "") return;

    sqlquery sql = SQLocalsPlayer_PrepareInsert(oPlayer, SQLOCALSPLAYER_TYPE_VECTOR, sVarName);
    SqlBindVector(sql, "@value", vValue);
    SqlStep(sql);
}

// Deletes a vector stored on oPlayer
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to delete
void SQLocalsPlayer_DeleteVector(object oPlayer, string sVarName)
{
    if (!GetIsPC(oPlayer) || sVarName == "") return;

    sqlquery sql = SQLocalsPlayer_PrepareDelete(oPlayer, SQLOCALSPLAYER_TYPE_VECTOR, sVarName);
    SqlStep(sql);
}
/* **** */

/* LOCATION */

// Returns a location stored on oPlayer, or the starting location of the module on error
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
location SQLocalsPlayer_GetLocation(object oPlayer, string sVarName)
{
    if (!GetIsPC(oPlayer) || sVarName == "") return GetStartingLocation();

    sqlquery sql = SQLocalsPlayer_PrepareSelect(oPlayer, SQLOCALSPLAYER_TYPE_LOCATION, sVarName);

    if (SqlStep(sql))
        return SQLocalsPlayer_StringToLocation(SqlGetString(sql, 0));
    else
        return GetStartingLocation();
}

// Sets a location stored on oPlayer to the given value
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
// * lValue - Value to store
void SQLocalsPlayer_SetLocation(object oPlayer, string sVarName, location lValue)
{
    if (!GetIsPC(oPlayer) || sVarName == "") return;

    sqlquery sql = SQLocalsPlayer_PrepareInsert(oPlayer, SQLOCALSPLAYER_TYPE_LOCATION, sVarName);
    SqlBindString(sql, "@value", SQLocalsPlayer_LocationToString(lValue));
    SqlStep(sql);
}

// Deletes a location stored on oPlayer
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to delete
void SQLocalsPlayer_DeleteLocation(object oPlayer, string sVarName)
{
    if (!GetIsPC(oPlayer) || sVarName == "") return;

    sqlquery sql = SQLocalsPlayer_PrepareDelete(oPlayer, SQLOCALSPLAYER_TYPE_LOCATION, sVarName);
    SqlStep(sql);
}
/* **** */

/* UTILITY */

// Deletes a set of locals stored on oPlayer matching the given criteria
// * oPlayer - a player object to save the variable on
// * nType - The SQLOCALSPLAYER_TYPE_* you wish to remove (default: SQLOCALSPLAYER_TYPE_ALL)
// * sLike - The string to compare with the SQL "like" comparison
// * sEscape - The escape character to use with the SQL "escape" keyword
void SQLocalsPlayer_Delete(object oPlayer, int nType = SQLOCALSPLAYER_TYPE_ALL, string sLike = "", string sEscape = "")
{
    if (!GetIsPC(oPlayer) || nType < 0) return;

    SQLocalsPlayer_CreateTable(oPlayer);

    sqlquery sql = SqlPrepareQueryObject(oPlayer,
        "DELETE FROM " + SQLOCALSPLAYER_TABLE_NAME + " " +
        "WHERE " +
        (nType != SQLOCALSPLAYER_TYPE_ALL ? "AND type & @type " : " ") +
        (sLike != "" ? "AND varname LIKE @like " + (sEscape != "" ? "ESCAPE @escape" : "") : "") +
        ";");

    if (nType != SQLOCALSPLAYER_TYPE_ALL)
        SqlBindInt(sql, "@type", nType);
    if (sLike != "")
    {
        SqlBindString(sql, "@like", sLike);

        if (sEscape != "")
            SqlBindString(sql, "@escape", sEscape);
    }

    SqlStep(sql);
}

// Counts a set of locals stored on oPlayer matching the given criteria
// * oPlayer - a player object to save the variable on
// * nType - The SQLOCALSPLAYER_TYPE_* you wish to count (default: SQLOCALSPLAYER_TYPE_ALL)
// * sLike - The string to compare with the SQL "like" comparison
// * sEscape - The escape character to use with the SQL "escape" keyword
int SQLocalsPlayer_Count(object oPlayer, int nType = SQLOCALSPLAYER_TYPE_ALL, string sLike = "", string sEscape = "")
{
    if (!GetIsPC(oPlayer) || nType < 0) return 0;

    SQLocalsPlayer_CreateTable(oPlayer);

    sqlquery sql = SqlPrepareQueryObject(oPlayer,
        "SELECT COUNT(*) FROM " + SQLOCALSPLAYER_TABLE_NAME + " " +
        "WHERE " +
        (nType != SQLOCALSPLAYER_TYPE_ALL ? "AND type & @type " : " ") +
        (sLike != "" ? "AND varname LIKE @like " + (sEscape != "" ? "ESCAPE @escape" : "") : "") +
        ";");

    if (nType != SQLOCALSPLAYER_TYPE_ALL)
        SqlBindInt(sql, "@type", nType);
    if (sLike != "")
    {
        SqlBindString(sql, "@like", sLike);

        if (sEscape != "")
            SqlBindString(sql, "@escape", sEscape);
    }

    if (SqlStep(sql))
        return SqlGetInt(sql, 0);
    else
        return 0;
}

// Checks a locals stored on oPlayer is set
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
// * nType - The SQLOCALSPLAYER_TYPE_* you wish to check (default: SQLOCALSPLAYER_TYPE_ALL)
int SQLocalsPlayer_IsSet(object oPlayer, string sVarName, int nType)
{
    if (!GetIsPC(oPlayer) || nType < 0) return 0;

    SQLocalsPlayer_CreateTable(oPlayer);

    sqlquery sql = SqlPrepareQueryObject(oPlayer,
        "SELECT * FROM " + SQLOCALSPLAYER_TABLE_NAME + " " +
        "WHERE " +
        (nType != SQLOCALSPLAYER_TYPE_ALL ? "AND type & @type " : " ") +
        "AND varname = @varname;");

    if (nType != SQLOCALSPLAYER_TYPE_ALL)
        SqlBindInt(sql, "@type", nType);
    SqlBindString(sql, "@varname", sVarName);

    return SqlStep(sql);
}

// Returns the last Unix time the given variable was updated
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
// * nType - The SQLOCALSPLAYER_TYPE_* you wish to check (default: SQLOCALSPLAYER_TYPE_ALL)
int SQLocalsPlayer_GetLastUpdated_UnixEpoch(object oPlayer, string sVarName, int nType)
{
    if (!GetIsPC(oPlayer) || nType <= 0) return 0;

    SQLocalsPlayer_CreateTable(oPlayer);

    sqlquery sql = SqlPrepareQueryObject(oPlayer,
        "SELECT timestamp FROM " + SQLOCALSPLAYER_TABLE_NAME + " " +
        "WHERE type = @type " +
        "AND varname = @varname;");

    SqlBindInt(sql, "@type", nType);
    SqlBindString(sql, "@varname", sVarName);

    if (SqlStep(sql))
        return SqlGetInt(sql, 0);
    else
        return 0;
}

// Returns the last UTC time the given variable was updated
// * oPlayer - a player object to save the variable on
// * sVarName - name of the variable to retrieve
// * nType - The SQLOCALSPLAYER_TYPE_* you wish to check (default: SQLOCALSPLAYER_TYPE_ALL)
string SQLocalsPlayer_GetLastUpdated_UTC(object oPlayer, string sVarName, int nType)
{
    if (!GetIsPC(oPlayer) || nType <= 0) return "";

    SQLocalsPlayer_CreateTable(oPlayer);

    sqlquery sql = SqlPrepareQueryObject(oPlayer,
        "SELECT datetime(timestamp, 'unixepoch') FROM " + SQLOCALSPLAYER_TABLE_NAME + " " +
        "WHERE type = @type " +
        "AND varname = @varname;");

    SqlBindInt(sql, "@type", nType);
    SqlBindString(sql, "@varname", sVarName);

    if (SqlStep(sql))
        return SqlGetString(sql, 0);
    else
        return "";
}

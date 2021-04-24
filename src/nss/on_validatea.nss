// Thanks for pointing me at the right direction Daz.

#include "nwnx_player"
#include "nwnx_object"
#include "inc_sql"
#include "util_i_csvlists"

void MigrateInt(object oPC, string sVarName, int bOnlyIfHigher = FALSE)
{
    int nNWNXObjectVar = NWNX_Object_GetInt(oPC, sVarName);
    int nSQLObjectVar = SQLocalsPlayer_GetInt(oPC, sVarName);

    if (nNWNXObjectVar == 0)
        return;

    if (!bOnlyIfHigher || (bOnlyIfHigher && nNWNXObjectVar > nSQLObjectVar))
        SQLocalsPlayer_SetInt(oPC, sVarName, nNWNXObjectVar);
}

void MigrateFloat(object oPC, string sVarName)
{
    float fNWNXObjectVar = NWNX_Object_GetFloat(oPC, sVarName);
    float fSQLObjectVar = SQLocalsPlayer_GetFloat(oPC, sVarName);

    if (fNWNXObjectVar == 0.0)
        return;

    SQLocalsPlayer_SetFloat(oPC, sVarName, fNWNXObjectVar);
}

void MigrateString(object oPC, string sVarName)
{
    string sNWNXObjectVar = NWNX_Object_GetString(oPC, sVarName);
    string sSQLObjectVar = SQLocalsPlayer_GetString(oPC, sVarName);

    if (sNWNXObjectVar == "")
        return;

    SQLocalsPlayer_SetString(oPC, sVarName, sNWNXObjectVar);
}

void main()
{
// assume 0 XP characters are new
    if (GetXP(OBJECT_SELF) == 0) return;

    string sKey = GetPCPublicCDKey(OBJECT_SELF);
    string sBic = NWNX_Player_GetBicFileName(OBJECT_SELF);

    string sList = GetLocalString(GetModule(), "quests");

// We've migrated from NWNX_OBJECT_XXX persistent storage to SQL.
// Do this if it hasn't been set.
    if (SQLocalsPlayer_GetInt(OBJECT_SELF, "migrated") != 1)
    {
        string sList = GetLocalString(GetModule(), "quests");

        int i;
        for (i = 0; i < CountList(sList); i++)
        {
            MigrateInt(OBJECT_SELF, GetListItem(sList, i), TRUE);
        }

        sList = GetLocalString(GetModule(), "bounties");

        for (i = 0; i < CountList(sList); i++)
        {
            MigrateInt(OBJECT_SELF, GetListItem(sList, i), TRUE);
            MigrateInt(OBJECT_SELF, GetListItem(sList, i)+"_reset", TRUE);
        }

        object oArea = GetFirstArea();

        while (GetIsObjectValid(oArea))
        {
            MigrateString(OBJECT_SELF, "map_"+GetResRef(oArea));
            oArea = GetNextArea();
        }

        MigrateInt(OBJECT_SELF, "highcliff");

        MigrateInt(OBJECT_SELF, "DEAD");
        MigrateInt(OBJECT_SELF, "CURRENT_HP");
        //MigrateFloat(OBJECT_SELF, "LOC_X");
        //MigrateFloat(OBJECT_SELF, "LOC_Y");
        //MigrateFloat(OBJECT_SELF, "LOC_Z");
        //MigrateFloat(OBJECT_SELF, "LOC_O");
        //MigrateString(OBJECT_SELF, "LOC_A");

        WriteTimestampedLogEntry(sKey+" "+sBic+" migrated from NWNX_OBJECT to SQL.");
    }

// Set this so it never runs again.
    SQLocalsPlayer_SetInt(OBJECT_SELF, "migrated", 1);

// if the WP exists, then we can skip the rest as it's already done
    object oWP = GetObjectByTag(sKey+sBic);
    if (GetIsObjectValid(oWP)) return;


    float fLocX = SQLocalsPlayer_GetFloat(OBJECT_SELF, "LOC_X");
    float fLocY = SQLocalsPlayer_GetFloat(OBJECT_SELF, "LOC_Y");
    float fLocZ = SQLocalsPlayer_GetFloat(OBJECT_SELF, "LOC_Z");
    float fLocO = SQLocalsPlayer_GetFloat(OBJECT_SELF, "LOC_O");
    string fLocA = SQLocalsPlayer_GetString(OBJECT_SELF, "LOC_A");

    location lLocation = Location(GetObjectByTag(fLocA), Vector(fLocX, fLocY, fLocZ), fLocO);

    oWP = CreateObject(OBJECT_TYPE_WAYPOINT, "nw_waypoint001", lLocation, FALSE, sKey+sBic);

    NWNX_Player_SetPersistentLocation(sKey, sBic, oWP);
}

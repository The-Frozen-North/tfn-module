// Thanks for pointing me at the right direction Daz.

#include "nwnx_player"
#include "nwnx_object"

void main()
{
// assume 0 XP characters are new
    if (GetXP(OBJECT_SELF) == 0) return;

    string sKey = GetPCPublicCDKey(OBJECT_SELF);
    string sBic = NWNX_Player_GetBicFileName(OBJECT_SELF);

// if the WP exists, then we can skip the rest as it's already done
    object oWP = GetObjectByTag(sKey+sBic);
    if (GetIsObjectValid(oWP)) return;


    float fLocX = NWNX_Object_GetFloat(OBJECT_SELF, "LOC_X");
    float fLocY = NWNX_Object_GetFloat(OBJECT_SELF, "LOC_Y");
    float fLocZ = NWNX_Object_GetFloat(OBJECT_SELF, "LOC_Z");
    float fLocO = NWNX_Object_GetFloat(OBJECT_SELF, "LOC_O");
    string fLocA = NWNX_Object_GetString(OBJECT_SELF, "LOC_A");

    location lLocation = Location(GetObjectByTag(fLocA), Vector(fLocX, fLocY, fLocZ), fLocO);

    oWP = CreateObject(OBJECT_TYPE_WAYPOINT, "nw_waypoint001", lLocation, FALSE, sKey+sBic);

    NWNX_Player_SetPersistentLocation(sKey, sBic, oWP);
}

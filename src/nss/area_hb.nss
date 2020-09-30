#include "inc_debug"
#include "nwnx_area"

void main()
{


    int bPlayersInLinkedArea = FALSE;
    int bPlayersInArea = FALSE;
    int bPlayersInInvalidArea = FALSE;
    string sResRef = GetResRef(OBJECT_SELF);
    object oLink1 = GetObjectByTag(GetLocalString(OBJECT_SELF, "link1"));
    object oLink2 = GetObjectByTag(GetLocalString(OBJECT_SELF, "link2"));
    object oLink3 = GetObjectByTag(GetLocalString(OBJECT_SELF, "link3"));

    if (NWNX_Area_GetNumberOfPlayersInArea(OBJECT_SELF) > 0)  bPlayersInArea = TRUE;
    if (GetIsObjectValid(oLink1) && NWNX_Area_GetNumberOfPlayersInArea(oLink1) > 0)  bPlayersInLinkedArea = TRUE;
    if (GetIsObjectValid(oLink2) && NWNX_Area_GetNumberOfPlayersInArea(oLink2) > 0)  bPlayersInLinkedArea = TRUE;
    if (GetIsObjectValid(oLink3) && NWNX_Area_GetNumberOfPlayersInArea(oLink3) > 0)  bPlayersInLinkedArea = TRUE;

    object oPlayer = GetFirstPC();

    while (GetIsObjectValid(oPlayer))
    {
        if (GetArea(oPlayer) == OBJECT_INVALID)
        {
            bPlayersInInvalidArea = TRUE;
            break;
        }

        oPlayer = GetNextPC();
    }

// item clean up
    object oItem = GetFirstObjectInArea(OBJECT_SELF);
    int nDestroyCount;
    while (GetIsObjectValid(oItem))
    {
        if(GetObjectType(oItem) == OBJECT_TYPE_ITEM)
        {
            nDestroyCount = GetLocalInt(oItem, "destroy_count");
            if (nDestroyCount == 100 && !bPlayersInInvalidArea && !bPlayersInArea && !bPlayersInLinkedArea)
            {
                DestroyObject(oItem);
            }
            else
            {
                SetLocalInt(oItem, "destroy_count", nDestroyCount+1);
            }
        }
        oItem = GetNextObjectInArea(OBJECT_SELF);
    }

// execute the heartbeat script if there is one
    string sScript = GetLocalString(OBJECT_SELF, "heartbeat_script");
    if (sScript != "") ExecuteScript(sScript, OBJECT_SELF);

// only proceed below if this area has instanced objects
    if (GetLocalInt(OBJECT_SELF, "instance") != 1) return;

// This is the number to fall back to if a refresh was to be started, but there were players
    int nRefreshRestart = 200;

// only start counting if the refresh counter is there
    int nRefresh = GetLocalInt(OBJECT_SELF, "refresh");
    if (nRefresh >= 300)
    {

        if (!bPlayersInInvalidArea && !bPlayersInArea && !bPlayersInLinkedArea)
        {
            SendDebugMessage("refreshing area "+sResRef, TRUE);
            ExecuteScript("area_refresh");
            DeleteLocalInt(OBJECT_SELF, "refresh");
        }
        else if (bPlayersInInvalidArea)
        {
            SendDebugMessage("cannot reset area "+sResRef+" because a player is in an invalid area (possibly mid-transition)", TRUE);
        }
        else if (bPlayersInArea)
        {
            SendDebugMessage("cannot reset area "+sResRef+" because a player is in the area", TRUE);
            SetLocalInt(OBJECT_SELF, "refresh", nRefreshRestart);
        }
        else if (bPlayersInLinkedArea)
        {
            SendDebugMessage("cannot reset area "+sResRef+" because a player is in a linked area", TRUE);
            SetLocalInt(OBJECT_SELF, "refresh", nRefreshRestart);
        }
    }
    else if (nRefresh > 0)
    {
        SetLocalInt(OBJECT_SELF, "refresh", nRefresh+1);
    }
}

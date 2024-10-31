#include "inc_debug"
#include "nwnx_area"

// Clear the area after this many heartbeats since anyone was in the area
const int REFRESH_HEARTBEAT_COUNT = 600;
// If any player is in the area, count backwards instead, but this backwards count cannot go below this value
const int REFRESH_HEARTBEAT_COUNT_MIN_VALUE_IF_PLAYERS = 500;

void main()
{
    int bPlayersInLinkedArea = FALSE;
    int bPlayersInArea = FALSE;
    int bPlayersInInvalidArea = FALSE;
    string sResRef = GetResRef(OBJECT_SELF);
    
    int nFurthestLinkedAreaOffRefresh = 0;
    // Can't clear if there are players in any linked areas
    if (NWNX_Area_GetNumberOfPlayersInArea(OBJECT_SELF) > 0)  bPlayersInArea = TRUE;
    int nLink = 1;
    while (1)
    {
        object oLinked = GetObjectByTag(GetLocalString(OBJECT_SELF, "link" + IntToString(nLink)));
        if (!GetIsObjectValid(oLinked))
        {
            break;
        }
        if (NWNX_Area_GetNumberOfPlayersInArea(oLinked) > 0)
        {
            bPlayersInLinkedArea = TRUE;
            break;
        }
        int nLinkedRefresh = GetLocalInt(oLinked, "refresh");
        // Find the linked area furthest off refreshing
        // this means finding the smallest nonzero refresh count of any linked area
        if (nLinkedRefresh > 0 && nLinkedRefresh < REFRESH_HEARTBEAT_COUNT && (nFurthestLinkedAreaOffRefresh == 0 || nLinkedRefresh < nFurthestLinkedAreaOffRefresh))
        {
            nFurthestLinkedAreaOffRefresh = nLinkedRefresh;
        }
        nLink++;
    }

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

//   clean up
    object oItem = GetFirstObjectInArea(OBJECT_SELF);
    int nDestroyCount;
    while (GetIsObjectValid(oItem))
    {
        if(GetObjectType(oItem) == OBJECT_TYPE_ITEM)
        {
            nDestroyCount = GetLocalInt(oItem, "destroy_count");
            if (nDestroyCount >= 100 && !bPlayersInInvalidArea && !bPlayersInArea && !bPlayersInLinkedArea)
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
    //if (GetLocalInt(OBJECT_SELF, "instance") != 1) return;

// only start counting if the refresh counter is there
    int nRefresh = GetLocalInt(OBJECT_SELF, "refresh");
    
    int nRefreshSpeedMult = GetLocalInt(OBJECT_SELF, "refresh_speed");
    if (nRefreshSpeedMult < 1)
    {
        if ((FindSubString(GetName(OBJECT_SELF), "Neverwinter") > -1 || FindSubString(GetName(OBJECT_SELF), "Luskan") > -1) && FindSubString(GetName(OBJECT_SELF), "Neverwinter Wood") == -1)
        {
            nRefreshSpeedMult = 2;
        }
        else
        {
            nRefreshSpeedMult = 1;
        }
    }
    
    
    if (nRefresh >= REFRESH_HEARTBEAT_COUNT)
    {
        if (nFurthestLinkedAreaOffRefresh > 0 && nFurthestLinkedAreaOffRefresh < REFRESH_HEARTBEAT_COUNT)
        {
            // Waiting for another area doesn't affect our refresh counter, so don't spam the log too hard with this
            if (nRefresh % 20 == 0)
            //if (1)
            {
                SendDebugMessage("Can't refresh " + sResRef + " due to linked area not being ready, furthest count = " + IntToString(nFurthestLinkedAreaOffRefresh), TRUE);
            }
        }
        else if (!bPlayersInInvalidArea && !bPlayersInArea && !bPlayersInLinkedArea)
        {
            SendDebugMessage("cleaning up area "+sResRef, TRUE);
            ExecuteScript("area_cleanup");
            DeleteLocalInt(OBJECT_SELF, "refresh");
            return;
        }
        else if (bPlayersInInvalidArea)
        {
            SendDebugMessage("cannot reset area "+sResRef+" because a player is in an invalid area (possibly mid-transition)", TRUE);
        }
        else if (bPlayersInArea)
        {
            SendDebugMessage("cannot reset area "+sResRef+" because a player is in the area", TRUE);
        }
        else if (bPlayersInLinkedArea)
        {
            SendDebugMessage("cannot reset area "+sResRef+" because a player is in a linked area", TRUE);
        }
    }
    
    if (nRefresh > 0)
    {
        if (bPlayersInArea)
        {
            int nReducedRefresh = nRefresh - nRefreshSpeedMult;
            nReducedRefresh = nReducedRefresh <= 0 ? 1 : nReducedRefresh;
            if (nReducedRefresh > REFRESH_HEARTBEAT_COUNT_MIN_VALUE_IF_PLAYERS)
            {
                SetLocalInt(OBJECT_SELF, "refresh", nReducedRefresh);
            }
            else if (nRefresh < REFRESH_HEARTBEAT_COUNT)
            {
                SetLocalInt(OBJECT_SELF, "refresh", nRefresh+nRefreshSpeedMult);
            }
        }
        else if (nRefresh < REFRESH_HEARTBEAT_COUNT)
        {
            SetLocalInt(OBJECT_SELF, "refresh", nRefresh+nRefreshSpeedMult);
        }
    }
}

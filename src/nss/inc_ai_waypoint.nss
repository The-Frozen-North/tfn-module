/* WAYPOINT Library by Gigaschatten */

//void main() {}

//walk waypoints
void gsWPWalkWaypoint();
//return TRUE if oCreature has waypoint assigned to it
int gsWPGetHasWaypoint(object oCreature = OBJECT_SELF);
//return number of nearest waypoint matching sWaypointTag
int gsWPGetNearestWaypointNumber(string sWaypointTag);
// return TRUE if oCreature is currently assigned to a DPOST/NPOST waypoint
int gsWPIsPosted(object oCreature = OBJECT_SELF);
//internally used
void _gsWPWalkWaypoints(string sWaypointTag);
//internally used
void __gsWPWalkWaypoints(string sWaypointTag, int nOffset = 1);

void gsWPWalkWaypoint()
{
    string sTag      = GetTag(OBJECT_SELF);
    object oWaypoint = OBJECT_INVALID;
    int nNight       = GetIsDusk() || GetIsNight();

    //day:   GS_WP_DPOST_{creature tag}
    //night: GS_WP_NPOST_{creature tag}
    if (nNight)
    {
        oWaypoint = GetWaypointByTag("GS_WP_NPOST_" + sTag);
    }

    if (! GetIsObjectValid(oWaypoint))
    {
        oWaypoint = GetWaypointByTag("GS_WP_DPOST_" + sTag);
    }

	//----------------------------------------------------------------------
	// NPCs crossing multiple areas behave oddly.  They will initially
	// walk to the *position* of their final waypoint in the *first* area
	// they transition to.  After that, they will then walk on to the next
	// area correctly.  However, if the position they are trying to get to
	// is not walkable, they may never reach their final destination.
	//----------------------------------------------------------------------
    if (GetIsObjectValid(oWaypoint))
    {
	/*
	    // NPCs seem to need some help using doors.
	    // Check whether the waypoint is in an area connected to this
	    // location by a door.  If so, get the NPC through the door.
	    if (GetArea(oWaypoint) != GetArea(OBJECT_SELF))
	    {
	        object oDoor = GetNearestObject(OBJECT_TYPE_DOOR);
	        int nNth = 1;

	        while (GetIsObjectValid(oDoor))
	        {
	            if (GetLocation(GetTransitionTarget(oDoor)) == GetLocation(oWaypoint))
		        {
		            ActionForceMoveToLocation(GetLocation(oWaypoint));
		            ActionJumpToObject(GetTransitionTarget(oDoor));
			        // Then queue the normal move actions.
		            break;
		        }

	            oDoor = GetNearestObject(OBJECT_TYPE_DOOR, OBJECT_SELF, ++nNth);
	        }
	    }
		*/

		ActionForceMoveToLocation(GetLocation(oWaypoint));
        ActionDoCommand(SetFacing(GetFacing(oWaypoint)));
        return;
    }

    //day:   GS_WP_DWALK_{creature tag}_xx
    //night: GS_WP_NWALK_{creature tag}_xx
    string sWaypoint;
    int nWaypoint;

    if (nNight)
    {
        sWaypoint = "GS_WP_NWALK_" + sTag;
        nWaypoint = gsWPGetNearestWaypointNumber(sWaypoint);

        if (! nWaypoint)
        {
            if (GetIsObjectValid(GetWaypointByTag(sWaypoint + "_01"))) nWaypoint = 1;
        }
    }

    if (! nWaypoint)
    {
        sWaypoint = "GS_WP_DWALK_" + sTag;
        nWaypoint = gsWPGetNearestWaypointNumber(sWaypoint);

        if (! nWaypoint)
        {
            if (GetIsObjectValid(GetWaypointByTag(sWaypoint + "_01"))) nWaypoint = 1;
        }
    }

    if (nWaypoint)
    {
        __gsWPWalkWaypoints(sWaypoint, nWaypoint);
        ActionDoCommand(_gsWPWalkWaypoints(sWaypoint));
    }
}
//----------------------------------------------------------------
int gsWPGetHasWaypoint(object oCreature = OBJECT_SELF)
{
    string sTag = GetTag(oCreature);

    return GetIsObjectValid(GetWaypointByTag("GS_WP_DPOST_" + sTag)) ||
           GetIsObjectValid(GetWaypointByTag("GS_WP_NPOST_" + sTag)) ||
           GetIsObjectValid(GetWaypointByTag("GS_WP_DWALK_" + sTag + "_01")) ||
           GetIsObjectValid(GetWaypointByTag("GS_WP_NWALK_" + sTag + "_01"));
}
//----------------------------------------------------------------
int gsWPIsPosted(object oCreature = OBJECT_SELF)
{
    string sTag = GetTag(oCreature);

    // If it's nighttime and we have a night post, or have no night patrol and
    // a daypost, or it's daytime and we have a daypost, return true.
    if ( ( (GetIsNight() || GetIsDusk()) &&
             (  GetIsObjectValid(GetWaypointByTag("GS_WP_NPOST_" + sTag)) ||
                (  !GetIsObjectValid(GetWaypointByTag("GS_WP_NWALK_" + sTag + "_01")) &&
                   GetIsObjectValid(GetWaypointByTag("GS_WP_DPOST_" + sTag))
                )
             )
         )  ||
         ( (GetIsDawn() || GetIsDay()) &&
           GetIsObjectValid(GetWaypointByTag("GS_WP_DPOST_" + sTag))
         )
       )
       return TRUE;

     return FALSE;
}
//----------------------------------------------------------------
int gsWPGetNearestWaypointNumber(string sWaypointTag)
{
    int nNth          = 1;
    int nTagLength    = GetStringLength(sWaypointTag) + 1;
    string sTag       = "";
    sWaypointTag     += "_";

    object oWaypoint  = GetNearestObject(OBJECT_TYPE_WAYPOINT, OBJECT_SELF, nNth);

    while (GetIsObjectValid(oWaypoint))
    {
        sTag      = GetTag(oWaypoint);

        if (GetStringLeft(sTag, nTagLength) == sWaypointTag)
        {
            return StringToInt(GetStringRight(sTag, 2));
        }

        oWaypoint = GetNearestObject(OBJECT_TYPE_WAYPOINT, OBJECT_SELF, ++nNth);
    }

    return FALSE;
}
//----------------------------------------------------------------
void _gsWPWalkWaypoints(string sWaypointTag)
{
    __gsWPWalkWaypoints(sWaypointTag);
    ActionDoCommand(_gsWPWalkWaypoints(sWaypointTag));
}
//----------------------------------------------------------------
void __gsWPWalkWaypoints(string sWaypointTag, int nOffset = 1)
{
    int nTen       = nOffset / 10;
    int nOne       = nOffset - nTen * 10;
    int nFlag      = 0;
    object oTarget = OBJECT_INVALID;
    object oStart  = OBJECT_INVALID;
    object oEnd    = OBJECT_INVALID;

    //increase
    oTarget        = GetObjectByTag(sWaypointTag + "_" + IntToString(nTen) + IntToString(nOne));

    while(GetIsObjectValid(oTarget))
    {
        ActionForceMoveToLocation(GetLocation(oTarget), FALSE, 4.0);
        ActionDoCommand(SetFacing(GetFacing(oTarget)));
        ActionWait(IntToFloat(Random(50)) / 10.0);
        if (++nOne > 9) {nTen++; nOne = 0;}

        oTarget = GetObjectByTag(sWaypointTag + "_" + IntToString(nTen) + IntToString(nOne));
    }

    //decrease
    oStart         = GetObjectByTag(sWaypointTag + "_01");
    if (--nOne < 0) {nTen--; nOne = 9;}
    oEnd           = GetObjectByTag(sWaypointTag + "_" + IntToString(nTen) + IntToString(nOne));
    if (--nOne < 0) {nTen--; nOne = 9;}
    oTarget        = GetObjectByTag(sWaypointTag + "_" + IntToString(nTen) + IntToString(nOne));

    if (GetDistanceBetween(oEnd, oTarget) < GetDistanceBetween(oEnd, oStart))
    {
        while(GetIsObjectValid(oTarget))
        {
            ActionForceMoveToLocation(GetLocation(oTarget));
            ActionDoCommand(SetFacing(GetFacing(oTarget)));
            ActionWait(IntToFloat(Random(50)) / 10.0);
            if (--nOne < 0) {nTen--; nOne = 9;}
            oTarget = GetObjectByTag(sWaypointTag + "_" + IntToString(nTen) + IntToString(nOne));
        }
    }
}


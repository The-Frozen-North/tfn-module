/*/////////////////////// [Resume Waypoint Walking] ////////////////////////////
    Filename: j_ai_walkwaypoin
///////////////////////// [Resume Waypoint Walking] ////////////////////////////
    Executed On Spawn, and from the end of combat, to resume walking

    Notes:
    Needed my own file as to execute and be sure it exsisted. This means
    the Non-override version will not use 2 different waypoint files most of the
    time.
///////////////////////// [History] ////////////////////////////////////////////
    1.0 - Added
    1.3 - Changed to SoU waypoints. fired from End of Spawn and heartbeat.
          It also returns to start location if set.
    1.4 -
///////////////////////// [Workings] ///////////////////////////////////////////
    Might change to SoU waypoints, this, at the moment, will just
    walk normal waypoints.

    GEORG:

    Short rundown on WalkWaypoints

    You can create a set of waypoints with their tag constructed like this:

    WP_[TAG]_XX where [TAG] is the exact, case sensitive tag of the creature
    you want to walk these waypoints and XX the number of the waypoint.

    Numbers must be ascending without a gap and must always contain 2 digits.

    If your creature's tag is MY_Monster, the tags would be
    WP_MY_Monster_01, WP_MY_Monster_02, ...

    You can auto-create a first waypoint in the toolset by rightclicking on a
    creature and selecting the "Create Waypoint" option. You can create
    subsequent waypoints by rightclicking on the ground while the creature is
    still selected and choosing "Create Waypoint".

    If you want to make your creature have a different patrol route at night,
    you can create a different set of WayPoints prefixed with WN_ (i.e.
    WN_MY_Monster_01, WN_MY_Monster_02, ...).

    You can also define so called POST waypoints for creatures that do not have
    a route of waypoints but you want to return to their position after a combat
    (i.e. Guards at a gate). This can be done by creating a single Waypoint with
    the tag POST_[TAG] for day and NIGHT_[TAG] for night posts. Creatures will
    automaticall switch between those posts when day changes to night and vice
    versa.

    Waypoints can be between areas and creatures will move there, if you set a
    global integer variable called X2_SWITCH_CROSSAREA_WALKWAYPOINTS on your
    module to 1.
///////////////////////// [Arguments] //////////////////////////////////////////
    Arguments: WAYPOINT_RUN, WAYPOINT_PAUSE are set On Spawn to remember
               the pause/run actions.
///////////////////////// [Resume Waypoint Walking] //////////////////////////*/

#include "NW_I0_GENERIC"
#include "J_INC_DEBUG"

const string WAYPOINT_RUN       = "WAYPOINT_RUN";
const string WAYPOINT_PAUSE     = "WAYPOINT_PAUSE";
const int AI_FLAG_OTHER_RETURN_TO_SPAWN_LOCATION                = 0x00020000;
const string AI_OTHER_MASTER    = "AI_OTHER_MASTER";
const string AI_LOCATION = "AI_LOCATION";
const string AI_RETURN_TO_POINT = "AI_RETURN_TO_POINT";


// For return  to.
int AI_GetSpawnInCondition(int nCondition, string sName, object oTarget = OBJECT_SELF);

void main()
{
    // FIRST, if we are meant to move back to the start location, do it.
    if(AI_GetSpawnInCondition(AI_FLAG_OTHER_RETURN_TO_SPAWN_LOCATION, AI_OTHER_MASTER))
    {
        location lReturnPoint = GetLocalLocation(OBJECT_SELF, AI_LOCATION + AI_RETURN_TO_POINT);
        object oReturnArea = GetAreaFromLocation(lReturnPoint);
        if(GetIsObjectValid(oReturnArea))
        {
            if((GetArea(OBJECT_SELF) == oReturnArea &&
                GetDistanceBetweenLocations(GetLocation(OBJECT_SELF), lReturnPoint) > 3.0) ||
                GetArea(OBJECT_SELF) != oReturnArea)
            {
                // 77: "[Waypoints] Returning to spawn location. [Area] " + GetName(oInput)
                DebugActionSpeakByInt(77, GetAreaFromLocation(lReturnPoint));
                ActionForceMoveToLocation(lReturnPoint);
                return;
            }
        }
    }
    // Use on-spawn run/pauses.
    WalkWayPoints(GetLocalInt(OBJECT_SELF, WAYPOINT_RUN), GetLocalFloat(OBJECT_SELF, WAYPOINT_PAUSE));
}

int AI_GetSpawnInCondition(int nCondition, string sName, object oTarget)
{
    return (GetLocalInt(oTarget, sName) & nCondition);
}

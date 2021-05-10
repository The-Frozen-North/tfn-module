/*/////////////////////// [On Heartbeat] ///////////////////////////////////////
    Filename: nw_c2_default1 or J_AI_OnHeartbeat
///////////////////////// [On Heartbeat] ///////////////////////////////////////
    Removed stupid stuff, special behaviour, sleep.

    Also, note please, I removed waypoints and day/night posting from this.
    It can be re-added if you like, but it does reduce heartbeats.

    Added in better checks to see if we should fire this script. Stops early if
    some conditions (like we can't move, low AI settings) are set.

    Hint: If nothing is used within this script, either remove it from creatures
          or create one witch is blank, with just a "void main(){}" at the top.

    Hint 2: You could add this very small file to your catche of scripts in the
            module properties, as it runs on every creature every 6 seconds (ow!)

    This also uses a system of Execute Script :-D This means the heartbeat, when
    compiled, should be very tiny.

    Note: NO Debug strings!
    Note 2: Remember, I use default SoU Animations/normal animations. As it is
            executed, we can check the prerequisists here, and then do it VIA
            execute script.

    -Working- Best possible, fast compile.
///////////////////////// [History] ////////////////////////////////////////////
    1.3 - Added more "buffs" to fast buff.
        - Fixed animations (they both WORK and looping ones do loop right!)
        - Loot behaviour!
        - Randomly moving nearer a PC in 25M if set.
        - Removed silly day/night optional setting. Anything we can remove, is a good idea.
    1.4 - Removed AI level setting. Not good to use, I mistakenly added it.
///////////////////////// [Workings] ///////////////////////////////////////////
    This fires off every 6 seconds (with PCs in the area, or AI_LEVEL_HIGH without)
    and therefore is intensive.

    It fires of ExecutesScript things for the different parts - saves CPU stuff
    if the bits are not used.
///////////////////////// [Arguments] //////////////////////////////////////////
    Arguments: Basically, none. Nothing activates this script. Fires every 6 seconds.
///////////////////////// [On Heartbeat] /////////////////////////////////////*/

// - This includes J_Inc_Constants
#include "inc_hai_heartb"


void DoBanter()
{
    if (GetIsDead(OBJECT_SELF) || GetIsInCombat(OBJECT_SELF) || IsInConversation(OBJECT_SELF) || GetIsFighting() || GetIsResting(OBJECT_SELF)) return;

    ExecuteScript("hen_banter", OBJECT_SELF);
}


void main()
{
    // Special - Runner from the leader shouts, each heartbeat, to others to get thier
    // attention that they are being attacked.
    // - Includes fleeing making sure (so it resets the ActionMoveTo each 6 seconds -
    //   this is not too bad)
    // - Includes door bashing stop heartbeat
    if(PerformSpecialAction()) return;

    if (GetIsObjectValid(GetMaster(OBJECT_SELF)) && GetStringLeft(GetResRef(OBJECT_SELF), 3) == "hen")
    {
        int nBanter = GetLocalInt(OBJECT_SELF, "banter");

        if (nBanter >= 100)
        {
            DelayCommand(IntToFloat(d20())+IntToFloat(d10())/10.0, DoBanter());
            DeleteLocalInt(OBJECT_SELF, "banter");
        }
        else
        {
            SetLocalInt(OBJECT_SELF, "banter", nBanter+d4());
        }
    }

    // Pre-heartbeat-event. Returns TRUE if we interrupt this script call.
    if(FirePreUserEvent(AI_FLAG_UDE_HEARTBEAT_PRE_EVENT, EVENT_HEARTBEAT_PRE_EVENT)) return;

    // AI status check. Is the AI on?
    if(GetAIOff()) return;

    // no waypoint stuff - pok

    string sScript = GetLocalString(OBJECT_SELF, "heartbeat_script");
    if (sScript != "") ExecuteScript(sScript);

    // Fire End-heartbeat-UDE
    FireUserEvent(AI_FLAG_UDE_HEARTBEAT_EVENT, EVENT_HEARTBEAT_EVENT);
}





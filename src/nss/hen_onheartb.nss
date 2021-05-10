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
    if (GetIsDead(OBJECT_SELF) || GetIsInCombat(OBJECT_SELF) || IsInConversation(OBJECT_SELF) || GetIsFighting(OBJECT_SELF) || GetIsResting(OBJECT_SELF)) return;

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
    if(GetAIOff() || GetSpawnInCondition(AI_FLAG_OTHER_LAG_IGNORE_HEARTBEAT, AI_OTHER_MASTER)) return;

    // Define the enemy and player to use.
    object oEnemy = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);
    object oPlayer = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC);

    // We can skip to the end if we are in combat, or something...
    if(!JumpOutOfHeartBeat() && // We don't stop due to effects.
       !GetIsInCombat() &&      // We are not in combat.
       !GetIsObjectValid(GetAttackTarget()) && // Second combat check.
       !GetObjectSeen(oEnemy))  // Nearest enemy is not seen.
    {
        // Fast buffing...if we have the spawn in condition...
        if(GetSpawnInCondition(AI_FLAG_COMBAT_FLAG_FAST_BUFF_ENEMY, AI_COMBAT_MASTER) &&
           GetIsObjectValid(oEnemy) && GetDistanceToObject(oEnemy) <= 40.0)
        {
            // ...we may do an advanced buff. If we cannot see/hear oEnemy, but oEnemy
            // is within 40M, we cast many defensive spells instantly...
            ExecuteScript(FILE_HEARTBEAT_TALENT_BUFF, OBJECT_SELF);
            //...if TRUE (IE it does something) we turn of future calls.
            DeleteSpawnInCondition(AI_FLAG_COMBAT_FLAG_FAST_BUFF_ENEMY, AI_COMBAT_MASTER);
            // This MUST STOP the heartbeat event - else, the actions may be interrupted.
            return;
        }
        // Execute waypoints file if we have waypoints set up.
        if(GetWalkCondition(NW_WALK_FLAG_CONSTANT))
        {
            ExecuteScript(FILE_WALK_WAYPOINTS, OBJECT_SELF);
        }
        // We can't have any waypoints for the other things
        else
        {
            // We must have animations set, and not be "paused", so doing a
            // longer looping one
            // - Need a valid player.
            if(GetIsObjectValid(oPlayer) && !IsInConversation(OBJECT_SELF))
            {
                // We may search for PC enemies, 25% chance to move closer to PC's
                if(GetSpawnInCondition(AI_FLAG_OTHER_SEARCH_IF_ENEMIES_NEAR, AI_OTHER_MASTER) &&
                       !GetLocalTimer(AI_TIMER_SEARCHING) && d4() == 1)
                {
                    ExecuteScript(FILE_HEARTBEAT_WALK_TO_PC, OBJECT_SELF);
                }
                // Else, Do we have any animations to speak of?
                // If we have a nearby PC, we do animations.
                else if(GetHasValidAnimations())
                {
                    ExecuteScript(FILE_HEARTBEAT_ANIMATIONS, OBJECT_SELF);
                }
            }
        }
    }

    string sScript = GetLocalString(OBJECT_SELF, "heartbeat_script");
    if (sScript != "") ExecuteScript(sScript);

    // Fire End-heartbeat-UDE
    FireUserEvent(AI_FLAG_UDE_HEARTBEAT_EVENT, EVENT_HEARTBEAT_EVENT);
}





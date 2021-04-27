/************************ [On Heartbeat] ***************************************
    Filename: nw_c2_default1 or ai_onheartb
************************* [On Heartbeat] ***************************************
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
************************* [History] ********************************************
    1.3 - Added more "buffs" to fast buff.
        - Fixed animations (they both WORK and looping ones do loop right!)
        - Loot behaviour!
        - Randomly moving nearer a PC in 25M if set.
        - Removed silly day/night optional setting. Anything we can remove, is a good idea.
************************* [Workings] *******************************************
    This fires off every 6 seconds (with PCs in the area, or AI_LEVEL_HIGH without)
    and therefore is intensive.

    It fires of ExecutesScript things for the different parts - saves CPU stuff
    if the bits are not used.
************************* [Arguments] ******************************************
    Arguments: Basically, none. Nothing activates this script. Fires every 6 seconds.
************************* [On Heartbeat] **************************************/

// - This includes inc_ai_constants
#include "inc_ai_heartb"

void main()
{
    // Special - Runner from the leader shouts, each heartbeat, to others to get thier
    // attention that they are being attacked.
    // - Includes fleeing making sure (so it resets the ActionMoveTo each 6 seconds -
    //   this is not too bad)
    // - Includes door bashing stop heartbeat
    if(PerformSpecialAction()) return;

    // AI status check. Is the AI on?
    if(GetAIOff() || GetSpawnInCondition(AI_FLAG_OTHER_LAG_IGNORE_HEARTBEAT, AI_OTHER_MASTER)) return;

    // Define the enemy and player to use.
    object oEnemy = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);
    object oPlayer = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC);
    int iTempInt;

    // AI level (re)setting
    if(!GetIsInCombat() && !GetIsObjectValid(GetAttackTarget()) &&
       (GetIsObjectValid(oEnemy) && GetDistanceToObject(oEnemy) <= f50 ||
        GetIsObjectValid(oPlayer) && GetDistanceToObject(oPlayer) <= f50))
    {
        // AI setting, normally higher then normal.
        iTempInt = GetAIConstant(LAG_AI_LEVEL_YES_PC_OR_ENEMY_50M);
        if(iTempInt > iM1 && GetAILevel() != iTempInt)
        {
            SetAILevel(OBJECT_SELF, iTempInt);
        }
    }
    else
    {
        // AI setting, normally higher then normal.
        iTempInt = GetAIConstant(LAG_AI_LEVEL_NO_PC_OR_ENEMY_50M);
        if(iTempInt > iM1 && GetAILevel() != iTempInt)
        {
            SetAILevel(OBJECT_SELF, iTempInt);
        }
    }

    // We can skip to the end if we are in combat, or something...
    if(!JumpOutOfHeartBeat() && // We don't stop due to effects.
       !GetIsInCombat() &&      // We are not in combat.
       !GetIsObjectValid(GetAttackTarget()) && // Second combat check.
       !GetObjectSeen(oEnemy))  // Nearest enemy is not seen.
    {
        // Fast buffing...if we have the spawn in condition...
        if(GetSpawnInCondition(AI_FLAG_COMBAT_FLAG_FAST_BUFF_ENEMY, AI_COMBAT_MASTER) &&
           GetIsObjectValid(oEnemy) && GetDistanceToObject(oEnemy) <= f40)
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
            if(GetIsObjectValid(oPlayer))
            {
                // Do we have any animations to speak of?
                // If we have a nearby PC, not in conversation, we do animations.
                if(!IsInConversation(OBJECT_SELF) &&
                    GetAIInteger(AI_VALID_ANIMATIONS))
                {
                    ExecuteScript(FILE_HEARTBEAT_ANIMATIONS, OBJECT_SELF);
                }
                // We may search for PC enemies :-) move closer to PC's
                else if(GetSpawnInCondition(AI_FLAG_OTHER_SEARCH_IF_ENEMIES_NEAR, AI_OTHER_MASTER) &&
                       !GetLocalTimer(AI_TIMER_SEARCHING) && d4() == i1)
                {
                    ExecuteScript(FILE_HEARTBEAT_WALK_TO_PC, OBJECT_SELF);
                }
            }
        }
    }

    string sScript = GetLocalString(OBJECT_SELF, "heartbeat_script");
    if (sScript != "") ExecuteScript(sScript);
}

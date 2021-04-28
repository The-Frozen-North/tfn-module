/*/////////////////////// [On Rested] //////////////////////////////////////////
    Filename: J_AI_OnRest or nw_c2_defaulta
///////////////////////// [On Rested] //////////////////////////////////////////
    This will play the sitting animation for 6 seconds, just something for resting.
    Also, walks waypoints (as resting would stop this) :-) and signals event (if so be)
    Feel free to edit.

    It does have the spell trigger information resetting, however. This can
    only be removed if they have no spell triggers, although it is hardly worth it.
///////////////////////// [History] ////////////////////////////////////////////
    1.3 - Added sitting.
    1.4 - Will be editing this down. No need to reset anything on rest, for a
          better working AI.
          IDEA: Change so that we will work through all spells/feats in order.
          If, at cirtain levels, we do not have any spells to cast from that
          level (set in a global stored integer in the general AI) we ignore all
          spells in that level. Same for each talent category (no need to use
          talents for them in the spawn script).

          If not in combat (EG: In heartbeat) we reset the integers saying "don't
          bother checking those spells" to false.
///////////////////////// [Workings] ///////////////////////////////////////////
    This fires once, at the END of resting.

    If ClearAllActions is added, the resting is actually stopped, or so it seems.

    It doesn't fire more then once.
///////////////////////// [Arguments] //////////////////////////////////////////
    Arguments: None, it seems.
///////////////////////// [On Rested] ////////////////////////////////////////*/

#include "inc_ai_constants"

// Resets all spell triggers used for sString
void LoopResetTriggers(string sString, object oTrigger);

void main()
{
    // Pre-rest-event. Returns TRUE if we interrupt this script call.
    if(FirePreUserEvent(AI_FLAG_UDE_RESTED_PRE_EVENT, EVENT_RESTED_PRE_EVENT)) return;

    // AI status check. Is the AI on?
    if(GetAIOff()) return;

    // Simple debug.
    // 66: "[Rested] Resting. Type: " + IntToString(GetLastRestEventType())
    DebugActionSpeakByInt(66, OBJECT_INVALID, GetLastRestEventType());

    // Reset all spell triggers.
    // Set all triggers
    object oTrigger = GetAIObject(AI_SPELL_TRIGGER_CREATURE);
    if(GetIsObjectValid(oTrigger))
    {
        LoopResetTriggers(SPELLTRIGGER_NOT_GOT_FIRST_SPELL, oTrigger);
        LoopResetTriggers(SPELLTRIGGER_DAMAGED_AT_PERCENT, oTrigger);
        LoopResetTriggers(SPELLTRIGGER_IMMOBILE, oTrigger);
        LoopResetTriggers(SPELLTRIGGER_START_OF_COMBAT, oTrigger);
    }
    // Some sitting for a few seconds.
    ActionPlayAnimation(ANIMATION_LOOPING_SIT_CROSS, 1.0, 6.0);
    DelayCommand(9.0, ExecuteScript(FILE_WALK_WAYPOINTS, OBJECT_SELF));

    // Fire End-heartbeat-UDE
    FireUserEvent(AI_FLAG_UDE_RESTED_EVENT, EVENT_RESTED_EVENT);

    DeleteLocalInt(OBJECT_SELF, "invis");
    DeleteLocalInt(OBJECT_SELF, "combat");
    DeleteLocalInt(OBJECT_SELF, "fast_buffed");
}

// Resets all spell triggers used for sString
void LoopResetTriggers(string sString, object oTrigger)
{
    int nCnt, bBreak, bUsed;
    for(nCnt = 1; bBreak != TRUE; nCnt++)
    {
        // Check max for this setting
        bUsed = GetLocalInt(oTrigger, sString + USED);
        if(bUsed)
        {
            DeleteLocalInt(oTrigger, sString + USED);
        }
        else
        {
            bBreak = TRUE;
        }
    }
}

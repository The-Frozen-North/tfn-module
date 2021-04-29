/*/////////////////////// [On Combat Round End] ////////////////////////////////
    Filename: nw_c2_default3 or J_AI_OnCombatrou
///////////////////////// [On Combat Round End] ////////////////////////////////
    This is run every 3 or 6 seconds, if the creature is in combat. It is
    executed only in combat automatically.

    It runs what the AI should do, bascially.
///////////////////////// [History] ////////////////////////////////////////////
    1.3 - Executes same script as the other parts of the AI to cuase a new action
    1.4 -
///////////////////////// [Workings] ///////////////////////////////////////////
    Calls the combat AI file using the J_INC_OTHER_AI include function,
    DetermineCombatRound.
///////////////////////// [Arguments] //////////////////////////////////////////
    Arguments: GetAttackTarget, GetLastHostileActor, GetAttemptedAttackTarget,
               GetAttemptedSpellTarget (Or these are useful at least!)
///////////////////////// [On Combat Round End] //////////////////////////////*/

#include "inc_ai_other"

void main()
{
    // Pre-combat-round-event. Returns TRUE if we interrupt this script call.
    if(FirePreUserEvent(AI_FLAG_UDE_END_COMBAT_ROUND_PRE_EVENT, EVENT_END_COMBAT_ROUND_PRE_EVENT)) return;

    SetLocalInt(OBJECT_SELF, "combat", 1);

    // AI status check. Is the AI on?
    if(GetAIOff()) return;

    // It is our normal call (every 3 or 6 seconds, when we can change actions)
    // so no need to delete, and we fire the UDE's.

    // Determine combat round against an invalid target (as default)
    DetermineCombatRound();

    // Fire End of end combat round event
    FireUserEvent(AI_FLAG_UDE_END_COMBAT_ROUND_EVENT, EVENT_END_COMBAT_ROUND_EVENT);
}


/************************ [Execute Combat Action] ******************************
    Filename: J_AI_DeterCombat
************************* [Execute Combat Action] ******************************
    Fired from other scripts, this runs an actual actions.

    It also contains the Pre-combat and Post-combat action events. In essense
    they therefore fire if they percieve a target, or a new round, or maybe
    a spell cast at - any combat action.

    Therefore, they only fire if the default AI is being used :-)

    Do NOT mess with this file, please. :-D
************************* [History] ********************************************
    1.3 - AI Include only fired from here. This script is executed from others,
          as the default in place of custom AI scripts.
************************* [Workings] *******************************************
    This is simple:

    - We execute it if there is no other AI files.
    - We use a stored target for things like "On Percieve, attack seen", so
      we react as normal.

    If there is a custom AI file specified, this won't fire.

    It cleans things up, and is the only script in the whole set that has
    j_inc_generic_ai in, reducing file size, and compile times. AI is more
    manageable too!
************************* [Arguments] ******************************************
    Arguments: See J_Inc_Generic_AI
************************* [Execute Combat Action] *****************************/

#include "j_inc_generic_ai"

void main()
{
    // Pre-combat-event
    if(FireUserEvent(AI_FLAG_UDE_COMBAT_ACTION_PRE_EVENT, EVENT_COMBAT_ACTION_PRE_EVENT))
        // We may exit if it fires
        if(ExitFromUDE(EVENT_COMBAT_ACTION_PRE_EVENT)) return;

    // Check: Are we imputting a target? We imputt it even if invalid
    object oTarget = GetLocalObject(OBJECT_SELF, AI_TEMP_SET_TARGET);

    // Speak combat round speakstring
    //SpeakArrayString(AI_TALK_ON_COMBAT_ROUND, TRUE);

    // Call combat round using include
    AI_DetermineCombatRound(oTarget);

    // Delete it whatever happens
    DeleteAIObject(AI_TEMP_SET_TARGET);

    // Fire end of combat action event.
    FireUserEvent(AI_FLAG_UDE_COMBAT_ACTION_EVENT, EVENT_COMBAT_ACTION_EVENT);
}

/************************ [On Percieve] ****************************************
    Filename: j_ai_onpercieve or nw_c2_default2
************************* [On Percieve] ****************************************
    If the target is an enemy, attack
    Will determine combat round on that person, is an enemy, basically.
    Includes shouting for a big radius - if the spawn in condition is set to this.

    NOTE: Debug strings in this file will be uncommented for speed by default.
          - It is one of the most intensive scripts as it runs so often.
          - Attempted to optimise as much as possible.
************************* [History] ********************************************
    1.3 - We include j_inc_other_ai to initiate combat (or go into combat again)
                - j_inc_other_ai holds all other needed functions/integers ETC.
        - Turn off hide things.
        - Added "Only attack if attacked"
        - Removed special conversation things. Almost no one uses them, and the taunt system is easier.
        - Should now search around if they move to a dead body, and only once they get there.
************************* [Workings] *******************************************
    It fires:

    - When a creature enters it perception range (Set in creature properties) and
      is seen or heard.
    - When a creature uses invisiblity/leaves the area in the creatures perception
      range
    - When a creature appears suddenly, already in the perception range (not
      the other way round, normally)
    - When a creature moves out of the creatures perception range, and therefore
      becomes unseen.
************************* [Arguments] ******************************************
    Arguments: GetLastPerceived, GetLastPerceptionSeen, GetLastPerceptionHeard,
               GetLastPerceptionVanished, GetLastPerceptionInaudible.
************************* [On Percieve] ***************************************/

#include "j_inc_other_ai"

void main()
{
    // Percieve pre event.
    if(FireUserEvent(AI_FLAG_UDE_PERCIEVE_PRE_EVENT, EVENT_PERCIEVE_PRE_EVENT))
        // We may exit if it fires
        if(ExitFromUDE(EVENT_PERCIEVE_PRE_EVENT)) return;

    // AI status check. Is the AI on?
    if(GetAIOff()) return;

    // Declare main things.
    // - We declare OUTSIDE if's JUST IN CASE!
    object oPerceived = GetLastPerceived();
    object oAttackTarget = GetAttackTarget();
    int bSeen = GetLastPerceptionSeen();
    int bHeard = GetLastPerceptionHeard();

    // Need to be valid and not ignorable.
    if(GetIsObjectValid(oPerceived) &&
      !GetIsDM(oPerceived) &&
      !GetIgnore(oPerceived))
    {
        // First, easy enemy checks.
        if(GetIsEnemy(oPerceived) && !GetFactionEqual(oPerceived))
        {
            // Turn of hiding, a timer to activate Hiding in the main file. This is
            // done in each of the events, with the opposition checking seen/heard.
            TurnOffHiding(oPerceived);

            // Well, are we both inaudible and vanished?
            // * the GetLastPerception should only say what specific event has fired!
            if(GetLastPerceptionInaudible() || GetLastPerceptionVanished())
            {
                // If they just became invisible because of the spell
                // invisiblity, or improved invisiblity...we set a local object.
                // - Beta: Added in ethereal as well.
                if(GetHasEffect(EFFECT_TYPE_INVISIBILITY, oPerceived) ||
                   GetHasEffect(EFFECT_TYPE_ETHEREAL, oPerceived) ||
                   GetStealthMode(oPerceived) == STEALTH_MODE_ACTIVATED)
                {
                    // Set object, AND the location they went invisible!
                    SetAIObject(AI_LAST_TO_GO_INVISIBLE, oPerceived);
                    // We also set thier location for AOE dispelling - same name
                    SetLocalLocation(OBJECT_SELF, AI_LAST_TO_GO_INVISIBLE, GetLocation(oPerceived));
                }

                // If they were our target, follow! >:-D
                // - Optional, on spawn option, for following through areas.
                if(oAttackTarget == oPerceived)
                {
                    // This means they have exited the area! follow!
                    /* NO FOLLOWING!
                    if(GetArea(oPerceived) != GetArea(OBJECT_SELF))
                    {
                        ClearAllActions();
                        // 51: "[Perception] Our Enemy Target changed areas. Stopping, moving too...and attack... [Percieved] " + GetName(oPerceived)
                        DebugActionSpeakByInt(51, oPerceived);
                        // Call to stop silly moving to enemies if we are fleeing
                        ActionMoveToEnemy(oPerceived);
                    }
                    // - Added check for not casting a spell. If we are, we finnish
                    //  (EG: AOE spell) and automatically carry on.
                    else */ if(GetCurrentAction() != ACTION_CASTSPELL)
                    {
                        ClearAllActions();
                        // 52: "[Perception] Enemy Vanished (Same area) Retargeting/Searching [Percieved] " + GetName(oPerceived)
                        DebugActionSpeakByInt(52, oPerceived);
                        DetermineCombatRound(oPerceived);
                    }
                }
            }// End if just gone out of perception
            // ELSE they have been SEEN or HEARD. We don't check specifics.
            else //if(bSeen || bHeard)
            {
                // If they have been made seen, and they are our attack target,
                // we must re-do combat round - unless we are casting a spell.
                if(bSeen && GetCurrentAction() != ACTION_CASTSPELL &&
                  (oAttackTarget == oPerceived || !GetObjectSeen(oAttackTarget)))
                {
                    AISpeakString(I_WAS_ATTACKED);
                    // 53: "[Perception] Enemy seen, and was old enemy/cannot see current. Re-evaluating (no spell) [Percieved] " + GetName(oPerceived)
                    DebugActionSpeakByInt(53, oPerceived);
                    DetermineCombatRound(oPerceived);
                }
                // Else We check if we are already attacking.
                else if(!CannotPerformCombatRound() &&
                        !GetSpawnInCondition(AI_FLAG_OTHER_ONLY_ATTACK_IF_ATTACKED, AI_OTHER_MASTER))
                {
                    // Special shout, d1000 though!
                    SpeakArrayString(AI_TALK_ON_PERCIEVE_ENEMY, TRUE);

                    // Stop stuff because of facing point - New enemy
                    HideOrClear();

                    // Face the person (this helps stops sneak attacks if we then
                    // cast something on ourselves, ETC).
                    SetFacingPoint(GetPosition(oPerceived));

                    // Get all allies in 60M to come to thier aid. Talkvolume silent
                    // shout does not seem to work well.
                    // - void function. Checks for the spawn int. in it.
                    // - Turns it off in it too
                    // - Variable range On Spawn
                    ShoutBossShout(oPerceived);

                    // Warn others
                    AISpeakString(I_WAS_ATTACKED);
                    // 54: "[Perception] Enemy Seen. Not in combat, attacking. [Percieved] " + GetName(oPerceived)
                    DebugActionSpeakByInt(54, oPerceived);
                    // Note: added ActionDoCommand, so that SetFacingPoint is not
                    // interrupted.
                    ActionDoCommand(DetermineCombatRound(oPerceived));
                }
            }
        }
        // Else, they are an equal faction, or not an enemy (or both)
        /* nope, no investigating!
        else
        {
            // If they are dead, say we saw something on waypoints, we charge in
            // to investigate.
            // * Higher intelligence will buff somewhat as well!
            if(GetIsDead(oPerceived) && (bSeen || bHeard))
            {
                // Warn others
                AISpeakString(I_WAS_ATTACKED);
                // Check if we can attack
                if(!CannotPerformCombatRound())
                {
                    // Hide or clear actions
                    HideOrClear();
                    // 55: "[Perception] Percieved Dead Friend! Moving and Searching [Percieved] " + GetName(oPerceived)
                    DebugActionSpeakByInt(55, oPerceived);
                    ActionMoveToLocation(GetLocation(oPerceived), TRUE);
                    ActionDoCommand(DetermineCombatRound());
                }
            }
            else if(GetIsInCombat(oPerceived) && (bSeen || bHeard))
            {
                // Warn others
                AISpeakString(I_WAS_ATTACKED);
                // Only if we can attack.
                if(!CannotPerformCombatRound())
                {
                    // Hide or clear actions
                    HideOrClear();
                    // 56: "[Perception] Percieved Alive Fighting Friend! Moving to and attacking. [Percieved] " + GetName(oPerceived)
                    DebugActionSpeakByInt(56, oPerceived);
                    ActionMoveToLocation(GetLocation(oPerceived), TRUE);
                    ActionDoCommand(DetermineCombatRound());
                }
            }
        }
        */
    }

    // Fire End of Percieve event
    FireUserEvent(AI_FLAG_UDE_PERCIEVE_EVENT, EVENT_PERCIEVE_EVENT);
}

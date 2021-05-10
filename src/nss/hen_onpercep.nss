/*/////////////////////// [On Percieve] ////////////////////////////////////////
    Filename: J_AI_OnPercieve or nw_c2_default2
///////////////////////// [On Percieve] ////////////////////////////////////////
    If the target is an enemy, attack
    Will determine combat round on that person, is an enemy, basically.
    Includes shouting for a big radius - if the spawn in condition is set to this.

    NOTE: Debug strings in this file will be uncommented for speed by default.
          - It is one of the most intensive scripts as it runs so often.
          - Attempted to optimise as much as possible.
///////////////////////// [History] ////////////////////////////////////////////
    1.3 - We include j_inc_other_ai to initiate combat (or go into combat again)
                - j_inc_other_ai holds all other needed functions/integers ETC.
        - Turn off hide things.
        - Added "Only attack if attacked"
        - Removed special conversation things. Almost no one uses them, and the taunt system is easier.
        - Should now search around if they move to a dead body, and only once they get there.
    1.4 - TO DO:

         1. Perception needs checking - attacking outside perception ranges!
         2. Vanishing targets, etc. test, improve.
         3. Problems with dispelling invisibility. Maybe either do change the line to create placable, or, of course, cast at location (dispells cannot be metamagiked or whatever) Source
         4. No Effect Type Ethereal. Source
///////////////////////// [Workings] ///////////////////////////////////////////
    It fires:

    - When a creature enters it perception range (Set in creature properties) and
      is seen or heard.
        * Tests show (and in general) it fires HEARD first, then immediantly SEEN if,
          of course, they are visible. Odd really, but true.
    - When a creature uses invisiblity/leaves the area in the creatures perception
      range
    - When a creature appears suddenly, already in the perception range (not
      the other way round, normally)
    - When a creature moves out of the creatures perception range, and therefore
      becomes unseen.
///////////////////////// [Arguments] //////////////////////////////////////////
    Arguments: GetLastPerceived, GetLastPerceptionSeen, GetLastPerceptionHeard,
               GetLastPerceptionVanished, GetLastPerceptionInaudible.
///////////////////////// [On Percieve] //////////////////////////////////////*/

#include "inc_hai_other"

void main()
{
    // Pre-percieve-event. Returns TRUE if we interrupt this script call.
    if(FirePreUserEvent(AI_FLAG_UDE_PERCIEVE_PRE_EVENT, EVENT_PERCIEVE_PRE_EVENT)) return;

    // AI status check. Is the AI on?
    if(GetAIOff()) return;

    // Declare main things.
    // - We declare OUTSIDE if's JUST IN CASE!
    object oPerceived = GetLastPerceived();
    object oAttackTarget = GetAttackTarget();
    // 1.4: Very rarely is our attack target valid, so we will set it to
    //      what we would have melee attacked when DCR was called.
    if(GetIgnoreNoFriend(oAttackTarget) || oAttackTarget == OBJECT_SELF)
    {
        oAttackTarget = GetAIObject(AI_LAST_MELEE_TARGET);
    }
    int bSeen = GetLastPerceptionSeen();
    int bHeard = GetLastPerceptionHeard();
    int bVanished = GetLastPerceptionVanished();
    int bInaudiable = GetLastPerceptionInaudible();

    // Debug
    DebugActionSpeak("*** PER ***: " + GetName(oPerceived) + "| SEEN: " + IntToString(bSeen) +
                     "| HEARD: " + IntToString(bHeard) + "| VANISHED: " + IntToString(bVanished) +
                     "| INAUDIABLE: " + IntToString(bInaudiable));

    // Need to be valid and not ignorable.
    if(GetIsObjectValid(oPerceived) &&
      !GetIsDM(oPerceived) &&
      !GetIgnore(oPerceived))
    {
        // First, easy enemy checks.
        if(GetIsEnemy(oPerceived) && !GetFactionEqual(oPerceived))
        {
            DebugActionSpeak("*** PER *** ENEMY");

            // Turn of hiding, a timer to activate Hiding in the main file. This is
            // done in each of the events, with the opposition checking seen/heard.
            TurnOffHiding(oPerceived);

            // Well, are we both inaudible and vanished?
            // * the GetLastPerception should only say what specific event has fired!
            if(bVanished || bInaudiable)
            {
                DebugActionSpeak("*** PER *** VANISHED OR INAUDIBLE");
                // If they just became invisible because of the spell
                // invisiblity, or improved invisiblity...we set a local object.
                // - Beta: Added in ethereal as well.
                if(GetHasEffect(EFFECT_TYPE_INVISIBILITY, oPerceived) ||
                   GetHasEffect(EFFECT_TYPE_SANCTUARY, oPerceived) ||
                   GetStealthMode(oPerceived) == STEALTH_MODE_ACTIVATED)
                {
                    // Set object, AND the location they went invisible!
                    SetAIObject(AI_LAST_TO_GO_INVISIBLE, oPerceived);
                    // We also set thier location for AOE dispelling - same name
                    SetAILocation(AI_LAST_TO_GO_INVISIBLE, GetLocation(oPerceived));
                }

                // If they were our target, follow! >:-D
                // - Optional, on spawn option, for following through areas.
                if(oAttackTarget == oPerceived)
                {
                    DebugActionSpeak("*** PER *** VANISHED OR INAUDIBLE AND IS CURRENT TARGET");
                    // This means they have exited the area! follow!
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
                    // 1.4: If we are using a targetted spell, we do cancle our
                    // spellcasting if it is them.
                    else if(GetCurrentAction() != ACTION_CASTSPELL ||
                            GetAttackTarget() == oPerceived)
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
                    // 53: "[Perception] Enemy seen, and was old enemy/cannot see current. Re-evaluating (no spell) [Percieved] " + GetName(oPerceived)
                    DebugActionSpeakByInt(53, oPerceived);
                    DetermineCombatRound(oPerceived);

                    // Shout to allies to attack oPerceived
                    AISpeakString(AI_SHOUT_I_WAS_ATTACKED);
                }
                // Else We check if we are already attacking.
                else if(!CannotPerformCombatRound() &&
                        !GetSpawnInCondition(AI_FLAG_OTHER_ONLY_ATTACK_IF_ATTACKED, AI_OTHER_MASTER))
                {
                    // * Don't speak when dead. 1.4 change (an obvious one to make)
                    if(CanSpeak())
                    {
                        // Special shout, d1000 though!
                        SpeakArrayString(AI_TALK_ON_PERCIEVE_ENEMY, TRUE);
                    }

                    // Stop stuff because of facing point - New enemy
                    HideOrClear();

                    // boss shout removed - pok

                    // 54: "[Perception] Enemy Seen. Not in combat, attacking. [Percieved] " + GetName(oPerceived)
                    DebugActionSpeakByInt(54, oPerceived);

                    // 1.4 change: SetFacingPoint(GetPosition(oPerceived));
                    // Is now part of DetermineCombatRound().
                    // * This means other events will work similarily.
                    DetermineCombatRound(oPerceived);

                    // Warn others
                    AISpeakString(AI_SHOUT_I_WAS_ATTACKED);
                }
            }
        }
        // Else, they are an equal faction, or not an enemy (or both)
        else
        {
            // If they are dead, or fighting, eg: we saw something on
            // waypoints, we charge in to investigate.
            // * Higher intelligence will buff somewhat as well!
            if((GetIsDead(oPerceived) || GetIsInCombat(oPerceived)) &&
               (bSeen || bHeard))
            {
                if(GetIsDead(oPerceived))
                {
                    // 55: "[Perception] Percieved Dead Friend! Moving into investigate [Percieved] " + GetName(oPerceived)
                    DebugActionSpeakByInt(55, oPerceived);
                }
                else
                {
                    // 56: "[Perception] Percieved Alive Fighting Friend! Moving to and attacking. [Percieved] " + GetName(oPerceived)
                    DebugActionSpeakByInt(56, oPerceived);
                }
                // Check if we can attack
                if(!CannotPerformCombatRound())
                {
                    // Hide or clear actions
                    HideOrClear();

                    // If we were called to arms, react
                    CallToArmsResponse(oPerceived);
                }
                else
                {
                    // Warn others even if we don't, or cannot, attack
                    AISpeakString(AI_SHOUT_CALL_TO_ARMS);
                }
            }
        }
    }

    // Fire End of Percieve event
    FireUserEvent(AI_FLAG_UDE_PERCIEVE_EVENT, EVENT_PERCIEVE_EVENT);
}


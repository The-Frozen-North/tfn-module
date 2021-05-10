/*/////////////////////// [On Phisical Attacked] ///////////////////////////////
    Filename: J_AI_OnPhiAttack or nw_c2_default5
///////////////////////// [On Phisical Attacked] ///////////////////////////////
    On Attacked
    No checking for fleeing or warnings.
    Very boring really!
///////////////////////// [History] ////////////////////////////////////////////
    1.3 - Added hiding things
    1.4 - Missing Silent Shouts have been added.
///////////////////////// [Workings] ///////////////////////////////////////////
    Got some simple Knockdown timer, so that we use heal sooner if we keep getting
    a creature who is attempting to knock us down.
///////////////////////// [Arguments] //////////////////////////////////////////
    Arguments: GetLastAttacker, GetLastWeaponUsed, GetLastAttackMode, GetLastAttackType
///////////////////////// [On Phisical Attacked] /////////////////////////////*/

#include "inc_hai_other"

void main()
{
    // Pre-attacked-event. Returns TRUE if we interrupt this script call.
    if(FirePreUserEvent(AI_FLAG_UDE_ATTACK_PRE_EVENT, EVENT_ATTACK_PRE_EVENT)) return;

    // AI status check. Is the AI on?
    if(GetAIOff()) return;

    // Set up objects.
    object oAttacker = GetLastAttacker();
    object oWeapon = GetLastWeaponUsed(oAttacker);
    //int nMode = GetLastAttackMode(oAttacker);       // Currently unused
    int nAttackType = GetLastAttackType(oAttacker);

    // Check if they are valid, a DM, we are ignoring them, they are dead now, or invalid
    if(!GetIgnoreNoFriend(oAttacker))
    {
        // Adjust automatically if set.
        if(GetSpawnInCondition(AI_FLAG_OTHER_CHANGE_FACTIONS_TO_HOSTILE_ON_ATTACK, AI_OTHER_MASTER))
        {
            if(!GetIsEnemy(oAttacker))
            {
                AdjustReputation(oAttacker, OBJECT_SELF, -100);
            }
        }

        // If we were attacked by knockdown, for a timer of X seconds, we make
        // sure we attempt healing at a higher level.
        if(!GetLocalTimer(AI_TIMER_KNOCKDOWN) &&
          (nAttackType == SPECIAL_ATTACK_IMPROVED_KNOCKDOWN ||
           nAttackType == SPECIAL_ATTACK_KNOCKDOWN) &&
          !GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_KNOCKDOWN) &&
           GetBaseAttackBonus(oAttacker) + 20 >= GetAC(OBJECT_SELF))
        {
            SetLocalTimer(AI_TIMER_KNOCKDOWN, 30.0);
        }

        // Set last hostile, valid attacker (Used in the On Damaged event)
        SetAIObject(AI_STORED_LAST_ATTACKER, oAttacker);

        // * Don't speak when dead. 1.4 change (an obvious one to make)
        if(CanSpeak())
        {
            // Speak the phisically attacked string, if applicable.
            // Speak the damaged string, if applicable.
            SpeakArrayString(AI_TALK_ON_PHISICALLY_ATTACKED);
        }

        // Turn of hiding, a timer to activate Hiding in the main file. This is
        // done in each of the events, with the opposition checking seen/heard.
        TurnOffHiding(oAttacker);

        // We set if we are attacked in HTH onto a low-delay timer.
        // - Not currently used
        /*if(!GetLocalTimer(AI_TIMER_ATTACKED_IN_HTH))
        {
            // If the weapon is not ranged, or is not valid, set the timer.
            if(!GetIsObjectValid(oWeapon) ||
               !GetWeaponRanged(oWeapon))
            {
                SetLocalTimer(AI_TIMER_ATTACKED_IN_HTH, f18);
            }
        }*/

        // If we are not fighting, and they are in the area, attack. Else, determine anyway.
        if(!CannotPerformCombatRound())
        {
            // Must be in our area to go after now.
            if(GetArea(oAttacker) == GetArea(OBJECT_SELF))
            {
                // 59: "[Phisically Attacked] Attacking back. [Attacker(enemy)] " + GetName(oAttacker)
                DebugActionSpeakByInt(59, oAttacker);

                // Attack the attacker
                DetermineCombatRound(oAttacker);

                // Shout to allies to attack the enemy who attacked me
                AISpeakString(AI_SHOUT_I_WAS_ATTACKED);
            }
            else
            {
                // Shout to allies to attack, or be prepared.
                AISpeakString(AI_SHOUT_CALL_TO_ARMS);

                // 60: "[Phisically Attacked] Not same area. [Attacker(enemy)] " + GetName(oAttacker)
                DebugActionSpeakByInt(60, oAttacker);

                // May find another hostile to attack...
                DetermineCombatRound();
            }
        }
        else
        {
            // Shout to allies to attack, or be prepared.
            AISpeakString(AI_SHOUT_CALL_TO_ARMS);
        }
    }
    // Else, invalid, DM, ally, etc...must be prepared at least (could be
    // they are charmed or something!)
    else
    {
        // If we are not fighting, prepare for battle. Something bad must have
        // happened.
        if(!CannotPerformCombatRound())
        {
            // Respond to oAttacker as if they shouted for help.
            IWasAttackedResponse(oAttacker);
        }
        else
        {
            // Shout to allies to attack, or be prepared.
            AISpeakString(AI_SHOUT_CALL_TO_ARMS);
        }
    }

    // Fire End of Attacked event
    FireUserEvent(AI_FLAG_UDE_ATTACK_EVENT, EVENT_ATTACK_EVENT);
}


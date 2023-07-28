/************************ [On Phisical Attacked] *******************************
    Filename: j_ai_onphiattack or nw_c2_default5
************************* [On Phisical Attacked] *******************************
    On Attacked
    No checking for fleeing or warnings.
    Very boring really!
************************* [History] ********************************************
    1.3 - Added hiding things
************************* [Workings] *******************************************
    Got some simple Knockdown timer, so that we use heal sooner if we keep getting
    a creature who is attempting to knock us down.
************************* [Arguments] ******************************************
    Arguments: GetLastAttacker, GetLastWeaponUsed, GetLastAttackMode, GetLastAttackType
************************* [On Phisical Attacked] ******************************/

#include "j_inc_other_ai"

void main()
{
    // Pre-attacked-event
    if(FireUserEvent(AI_FLAG_UDE_ATTACK_PRE_EVENT, EVENT_ATTACK_PRE_EVENT))
        // We may exit if it fires
        if(ExitFromUDE(EVENT_ATTACK_PRE_EVENT)) return;

    // AI status check. Is the AI on?
    if(GetAIOff()) return;

    if (GetIsEnemy(GetLastAttacker()))
        SpeakString("PARTY_I_WAS_ATTACKED", TALKVOLUME_SILENT_TALK);

    // Set up objects.
    object oAttacker = GetLastAttacker();
    object oWeapon = GetLastWeaponUsed(oAttacker);
    int iMode = GetLastAttackMode(oAttacker);       // Currently unused
    int iAttackType = GetLastAttackType(oAttacker);

    if(GetIsObjectValid(oAttacker) && !GetFactionEqual(oAttacker) &&
       !GetIsDM(oAttacker) && !GetIgnore(oAttacker))
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
          (iAttackType == SPECIAL_ATTACK_IMPROVED_KNOCKDOWN ||
           iAttackType == SPECIAL_ATTACK_KNOCKDOWN) &&
          !GetIsImmune(OBJECT_SELF, IMMUNITY_TYPE_KNOCKDOWN) &&
           GetBaseAttackBonus(oAttacker) + i20 >= GetAC(OBJECT_SELF))
        {
            SetLocalTimer(AI_TIMER_KNOCKDOWN, f30);
        }

        // Set last hostile attacker.
        SetAIObject(AI_STORED_LAST_ATTACKER, oAttacker);

        // Speak the phisically attacked string, if applicable.
        // Speak the damaged string, if applicable.
        SpeakArrayString(AI_TALK_ON_PHISICALLY_ATTACKED);

        // Turn of hiding, a timer to activate Hiding in the main file. This is
        // done in each of the events, with the opposition checking seen/heard.
        //TurnOffHiding(oAttacker);

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
            if(GetArea(oAttacker) == GetArea(OBJECT_SELF))
            {
                // 59: "[Phisically Attacked] Attacking back. [Attacker(enemy)] " + GetName(oAttacker)
                DebugActionSpeakByInt(59, oAttacker);
                DetermineCombatRound(oAttacker);
            }
            else
            {
                // 60: "[Phisically Attacked] Not same area. [Attacker(enemy)] " + GetName(oAttacker)
                DebugActionSpeakByInt(60, oAttacker);
                DetermineCombatRound();// May find another hostile to attack...
            }
        }
    }

    // Fire End of Attacked event
    FireUserEvent(AI_FLAG_UDE_ATTACK_EVENT, EVENT_ATTACK_EVENT);
}

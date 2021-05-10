/*/////////////////////// [Include - Heartbeat] ////////////////////////////////
    Filename: J_INC_Heartbeat
///////////////////////// [Include - Heartbeat] ////////////////////////////////
    This contains any heartbeat function calls.

    Note that the heartbeat uses ExecuteScript for larget behaviours that are
    better split up so the heartbeat is as tiny as possible.
///////////////////////// [History] ////////////////////////////////////////////
    1.3 - After Beta - Added
    1.4 - TO DO
        - Add in some function (see rest script) that resets if we are not in
          combat
        - Some more of the things we should do even if interrupted not the
          heartbeat.

        - Have moved "after combat searching" into here. It isn't long - but
          it is more reliable. The special action is cancled if there is combat
          going on, of course.
///////////////////////// [Workings] ///////////////////////////////////////////
    This is included in nw_c2_default1 and J_AI_OnHeartbeat.

    Contains things like in J_INC_OTHER_AI, but only for the heartbeat event.
    Keeps it cleaner to read.
///////////////////////// [Arguments] //////////////////////////////////////////
    Arguments: N/A
///////////////////////// [Include - Heartbeat] //////////////////////////////*/

#include "inc_hai_constant"

// Bioware walk waypoints condition name
const string sWalkwayVarname = "NW_WALK_CONDITION";
// Walk waypoint constant set in the SoU waypoint include
const int NW_WALK_FLAG_CONSTANT                    = 0x00000002;

// Checks:
// * No valid location
// * Petrified, paralised, ETC.
// Note: If sleep is found, it may apply Zzzz randomly, as well as stopping.
int JumpOutOfHeartBeat();

// This checks fleeing, door bashing and so on, to stop the heartbeat
// and perform the override special action, rather then run normal behaviour.
int PerformSpecialAction();

// Get whether the condition is set
// * Bioware SoU Waypoint call.
int GetWalkCondition(int nCondition, object oCreature=OBJECT_SELF);

// Cast fleeing spells.
// - Invisiblity (best)
// - Haste/Expeditious Retreat
void ActionCastFleeingSpells();
// Cast fleeing spells.
// - Invisiblity (best)
// - Haste/Expeditious Retreat
void ActionCastMoveToCombatSpells();

// Attempt to cast nSpell. TRUE if true.
// Searching and fleeing spells use this.
int HeartbeatSpellCast(int nSpell);

// Used in Search(). This apply Trueseeing, See invisibility, or Invisiblity purge
// if we have neither of the 3 on us.
void SearchSpells();

// Returns TRUE if any of the animation settings are on.
int GetHasValidAnimations();

// Checks:
// * No valid location
// * Petrified, paralised, ETC.
// Note: If sleep is found, it may apply Zzzz randomly, as well as stopping.
int JumpOutOfHeartBeat()
{
    // What to return
    int bReturn = FALSE;
    // Checks:
    // * No valid location
    // * Petrified, paralised, ETC.
    // Note: If sleep is found, it may apply Zzzz randomly, as well as stopping.

    // Effect checking
    effect eCheck = GetFirstEffect(OBJECT_SELF);
    int nEffectType;
    while(GetIsEffectValid(eCheck) && bReturn == FALSE)
    {
        nEffectType = GetEffectType(eCheck);
        // Sleep is special
        if(nEffectType == EFFECT_TYPE_SLEEP)
        {
            bReturn = 2;// This immediantly breaks.
        }
        // ALL these stop heartbeat.
        else if(nEffectType == EFFECT_TYPE_PARALYZE || nEffectType == EFFECT_TYPE_STUNNED ||
                nEffectType == EFFECT_TYPE_FRIGHTENED || /* Removed sleep above */
                nEffectType == EFFECT_TYPE_TURNED || nEffectType == EFFECT_TYPE_PETRIFY ||
                nEffectType == EFFECT_TYPE_DAZED || nEffectType == EFFECT_TYPE_TIMESTOP ||
                nEffectType == EFFECT_TYPE_DISAPPEARAPPEAR || nEffectType == EFFECT_TYPE_CHARMED ||
                nEffectType == EFFECT_TYPE_DOMINATED || nEffectType == EFFECT_TYPE_CONFUSED)
        {
            bReturn = 1;// 1 = No Zzz. We continue to check for Zzz as well.
        }
        eCheck = GetNextEffect(OBJECT_SELF);
    }
    // Do we fire the heartbeat event?
    if(bReturn != FALSE)
    {
        // If it is sleep... Zzzzz  sometimes.
        if(bReturn == 2 && d6() == 1)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT,
                                EffectVisualEffect(VFX_IMP_SLEEP),
                                OBJECT_SELF);
        }
        // Fire event 1001
        FireUserEvent(AI_FLAG_UDE_HEARTBEAT_EVENT, EVENT_HEARTBEAT_EVENT);
    }
    return bReturn;
}

// This checks fleeing, door bashing and so on, to stop the heartbeat
// and perform the override special action, rather then run normal behaviour.
int PerformSpecialAction()
{
    int nAction = GetCurrentSetAction();
    object oTarget = GetAttackTarget();
    object oRunTarget;
    switch(nAction)
    {
        // - Leader has made me a runner. I must run to a nearby group calling
        //   for help to get more men
        case AI_SPECIAL_ACTIONS_ME_RUNNER:
        {
            oRunTarget = GetAIObject(AI_RUNNER_TARGET);
            if(GetIsObjectValid(oRunTarget))
            {
                if(GetObjectSeen(oRunTarget))
                {
                    // Stop thinking we are a runner if we can see the run target
                    ResetCurrentAction();
                    AISpeakString(AI_SHOUT_HELP_MY_FRIEND);
                    return FALSE;
                }
                else
                {
                    // Else run to them
                    if(GetObjectHeard(oRunTarget))
                    {
                        AISpeakString(AI_SHOUT_HELP_MY_FRIEND);
                    }
                    ClearAllActions();
                    ActionMoveToObject(oRunTarget, TRUE);
                    return TRUE;
                }
            }
        }
        break;
        // - I am fleeing.
        case AI_SPECIAL_ACTIONS_FLEE:
        {
            oRunTarget = GetAIObject(AI_FLEE_TO);
            if(GetIsObjectValid(oRunTarget))
            {
                // If they are a leader, and seen, and they are running, we
                // obviously follow only.
                if(GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_GROUP_LEADER, AI_OTHER_COMBAT_MASTER, oRunTarget) ||
                   GetLocalInt(oRunTarget, AI_CURRENT_ACTION) == AI_SPECIAL_ACTIONS_FLEE)
                {
                    ClearAllActions();
                    // New - cast fleeing spells. Important (and only used
                    //       at higher intelligence) things like Expeditious retreat.
                    //     - Only used once - one invisibility or haste. Deleted above.
                    ActionCastFleeingSpells();
                    ActionForceFollowObject(oRunTarget, 3.0);
                }
                else if(GetObjectSeen(oRunTarget))
                {
                    // If we see the flee target, reset targets
                    ResetCurrentAction();

                    // We will delete the local int (set to TRUE) which we
                    // stopped fleeing spells from being used
                    DeleteAIInteger(AI_HEARTBEAT_FLEE_SPELLS);
                    // Speak to allies to come :-)
                    AISpeakString(AI_SHOUT_HELP_MY_FRIEND);


                    // And attack/heal self
                    ClearAllActions();
                    DetermineCombatRound();
                    // Return TRUE, we attacked
                    return TRUE;
                }
                else
                {
                    // Else flee!
                    if(GetObjectHeard(oRunTarget))
                    {
                        AISpeakString(AI_SHOUT_HELP_MY_FRIEND);
                    }
                    ClearAllActions();
                    // New - cast fleeing spells. Important (and only used
                    //       at higher intelligence) things like Expeditious retreat.
                    //     - Only used once - one invisibility or haste. Deleted above.
                    ActionCastFleeingSpells();
                    ActionMoveToObject(oRunTarget, TRUE);
                    return TRUE;
                }
            }
            else
            {
                // Check if we have bad intellgence, if we have, we will run away
                // from the nearest enemy we can see or hear.
                if(GetAIInteger(AI_INTELLIGENCE) <= 3)
                {
                    oRunTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
                    if(!GetIsObjectValid(oRunTarget))
                    {
                        oRunTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_HEARD, CREATURE_TYPE_IS_ALIVE, TRUE);
                        if(!GetIsObjectValid(oRunTarget))
                        {
                            oRunTarget = GetLastHostileActor();
                            if(!GetIsObjectValid(oRunTarget) || GetIsDead(oRunTarget))
                            {
                                // If we do not have anyone to run from, stop
                                ResetCurrentAction();
                                // Speak to allies to come :-)
                                AISpeakString(AI_SHOUT_HELP_MY_FRIEND);
                                // And attack/heal self
                                ClearAllActions();
                                DetermineCombatRound();
                                // Return TRUE, we attacked
                                return TRUE;
                            }
                        }
                    }
                    // Run from enemy (1.4: Was oTarget, now oRunTarget)
                    ClearAllActions();
                    ActionMoveAwayFromObject(oRunTarget, TRUE, 50.0);
                    return TRUE;
                }
                // If we see the flee target, reset targets
                ResetCurrentAction();
                // Speak to allies to come :-)
                AISpeakString(AI_SHOUT_HELP_MY_FRIEND);
                // And attack/heal self
                ClearAllActions();
                DetermineCombatRound();
                // Return TRUE, we attacked/healed
                return TRUE;
            }
        }
        break;
        // If this is set, we are usually in combat - and must move out of an AOE.
        case AI_SPECIAL_ACTIONS_MOVE_OUT_OF_AOE:
        {
            // We must be X distance away from a cirtain AOE, if we are not, we
            // move.
            oRunTarget = GetAIObject(AI_AOE_FLEE_FROM);

            // If not valid, or already far enough away, delete special action
            // and return false.
            if(!GetIsObjectValid(oRunTarget) ||
                GetLocalFloat(OBJECT_SELF, AI_AOE_FLEE_FROM_RANGE) < GetDistanceToObject(oRunTarget))
            {
                ResetCurrentAction();
                return FALSE;
            }
            else
            {
                // Valid and still in range
                // - Run away
                ClearAllActions();
                ActionMoveAwayFromLocation(GetLocation(oRunTarget), TRUE, GetLocalFloat(OBJECT_SELF, AI_AOE_FLEE_FROM_RANGE));
                return TRUE;
            }
        }
        break;
        // If this is the one, we will search around for enemies - usually done
        // at the end of a combat round, it is more reliable here.
        case AI_SPECIAL_ACTIONS_SEARCH_AROUND:
        {
            // If we are in combat, delete this special thing, and return FALSE
            if(GetIsObjectValid(GetAttemptedSpellTarget()) ||
               GetIsObjectValid(GetAttemptedAttackTarget()) ||
               GetIsObjectValid(GetAttackTarget()))
            {
                // Reset, and return FALSE.
                ResetCurrentAction();
                return FALSE;
            }
            // Added this so special actions do not get ignored (EG: healkitting)
            // It will not do anything, but no heartbeat will be performed. These
            // kind of actions happen at the end of combat (healing self of damage ETC)
            // So, basically, will keep in mind it's still searching, but will leave
            // it until no busy actions are being done.
            else if(GetIsBusyWithAction())
            {
                return TRUE;
            }

            // We search for a cirtain number of rounds, set in the generic AI
            // file, when we first start searching, or restart even. The generic
            // AI will not actually do search actions, and if it finds no enemy,
            // will probably just increase the integer to do more search rounds.
            // * Will be intelligence + 2 to start.
            int nRoundsRemaining = GetAIInteger(AI_SEARCH_ROUNDS_REMAINING);
            // Decrease rounds remaining
            nRoundsRemaining--;
            // Set new one onto us to use next time
            SetAIInteger(AI_SEARCH_ROUNDS_REMAINING, nRoundsRemaining);
            // * Note: If nRoundsRemaining is 0 at the end of this function, we
            //   will remove this action as the current special one.

            // Get the target to move to/around
            // * Can be invalid, but usually the creature we just killed or noticed
            //   lying on the ground.
            object oTarget = GetAIObject(AI_SEARCH_TARGET);

            // Stop now (Small amounts of movement each time seem more cautious)
            ClearAllActions();

            // Check some spells. Cast one if we have no true seeing ETC.
            SearchSpells();

            // Stealth/search.
            int bStealth = GetStealthMode(OBJECT_SELF);
            int bSearch = GetDetectMode(OBJECT_SELF);

            // We perfere to hide again if we search if set to...sneaky!
            if(GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_FORCE_HIDING, AI_OTHER_COMBAT_MASTER))
            {
                if(bStealth != STEALTH_MODE_ACTIVATED)
                {
                    SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, TRUE);
                }
            }
            else
            {
                // If we are hiding, stop to search (we shouldn't be - who knows?)
                if(bStealth == STEALTH_MODE_ACTIVATED)
                {
                    SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, FALSE);
                }
                // And search!
                if(bSearch != DETECT_MODE_ACTIVE && !GetHasFeat(FEAT_KEEN_SENSE))
                {
                     SetActionMode(OBJECT_SELF, ACTION_MODE_DETECT, TRUE);
                }
            }

            // We check around the target, if there is one.
            if(GetIsObjectValid(oTarget))
            {
                // Move to the location of oTarget
                ActionMoveToLocation(GetLocation(oTarget));

                // If it is a chest ETC. We close it.
                if(GetIsOpen(oTarget))
                {
                     if(GetObjectType(oTarget) == OBJECT_TYPE_DOOR)
                     {
                        ActionCloseDoor(oTarget);
                     }
                     else
                     {
                        // Close it
                        ActionDoCommand(DoPlaceableObjectAction(oTarget, PLACEABLE_ACTION_USE));
                     }
                }
            }
            // We will get nearest enemy at the very least
            else
            {
                // Use nearest heard
                object oEnemy = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY,
                                   OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_HEARD);
                if(GetIsObjectValid(oEnemy))
                {
                    // Move to location
                    ActionMoveToLocation(GetLocation(oEnemy));
                }
            }
            // Note: Here, we will return to spawn location after moving to the
            // object, if it is a valid setting, else we do the normal randomwalk
            location lReturnPoint = GetLocalLocation(OBJECT_SELF, AI_LOCATION + AI_RETURN_TO_POINT);
            object oReturnArea = GetAreaFromLocation(lReturnPoint);
            if (GetSpawnInCondition(AI_FLAG_OTHER_RETURN_TO_SPAWN_LOCATION, AI_OTHER_MASTER)
                && (((GetArea(OBJECT_SELF) == oReturnArea &&
                GetDistanceBetweenLocations(GetLocation(OBJECT_SELF), lReturnPoint) > 10.0) ||
                GetArea(OBJECT_SELF) != oReturnArea)))
            {
                ActionMoveToLocation(GetAILocation(AI_RETURN_TO_POINT));
            }
            else
            {
                // 72: "[Search] Searching, No one to attack. [Rounds Remaining] " + IntToString(nRoundsRemaining) + ". [Possible target] " + GetName(oTarget)
                DebugActionSpeakByInt(72, oTarget, nRoundsRemaining);
                // Randomly walk.
                ActionRandomWalk();
            }
            // If we have 0 rounds left of searching time, we turn of this special
            // action, walk waypoints, and probably rest.
            if(nRoundsRemaining == 0)
            {
                // Rest after combat?
                if(!GetIsInCombat() && GetLocalInt(OBJECT_SELF, "combat") == 1)
                {
                    // 71: "[Search] Resting"
                    //DebugActionSpeakByInt(71);
                    ActionPlayAnimation(ANIMATION_LOOPING_SIT_CROSS, 1.0, 7.0);

                    int nHitPointsPer = GetMaxHitPoints()/6;
                    if (nHitPointsPer < 1) nHitPointsPer = 1;

                    if (GetCurrentHitPoints() >= GetMaxHitPoints() - nHitPointsPer)
                        ForceRest(OBJECT_SELF);
                    else
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectHeal(nHitPointsPer), OBJECT_SELF);
                }
                // no waypoint stuff - pok
                // Delete this special action
                ResetCurrentAction();
            }
            // If we havn't bailed out early and returned FALSE (do normal hb) we
            // will return TRUE, we have something to do at least.
            return TRUE;
        }
        break;
        // Move to combat - we buff (and only buff again after 1 minute of running)
        // and either follow the person who wants us to help them, or we will run to the
        // location set.
        // * Set only by "AI_HELP_MY_FRIEND_CONSTANT" at the moment.
        case AI_SPECIAL_ACTIONS_MOVE_TO_COMBAT:
        {
            // We get a location to move to first
            location lTarget = GetAILocation(AI_MOVE_TO_COMBAT_LOCATION);
            object oObject = GetAreaFromLocation(lTarget);

            // Check if the location is valid
            if(GetIsObjectValid(oObject) && GetArea(OBJECT_SELF) == oObject)
            {
                // Just move, rapidly, to lTarget.
                ClearAllActions();

                // Buff up an action
                ActionCastMoveToCombatSpells();

                // Move (fast) to that location
                ActionMoveToLocation(lTarget, TRUE);
                // If we see/hear combat, we'll attack
                return TRUE;
            }
            else
            {
                // Get who we should "follow" or move to.
                oObject = GetAIObject(AI_MOVE_TO_COMBAT_OBJECT);

                if(GetIsObjectValid(oObject))
                {
                    // Just move, rapidly, to oTarget. It isn't "real" following,
                    // but paced. Means it looks OK. Need to test - but should be OK.
                    ClearAllActions();

                    // Buff up an action
                    ActionCastMoveToCombatSpells();

                    // Move (fast) to that location
                    ActionMoveToObject(oTarget, TRUE);
                    // If we see/hear combat, we'll attack
                    return TRUE;
                }
                else
                {
                    // Remove the special action and return FALSE
                    ResetCurrentAction();
                    return FALSE;
                }
            }
        }
        break;
    }
    // Return false to carry on a normal heartbeat
    return FALSE;
}

// Get whether the condition is set
// * Bioware SoU Waypoint call.
int GetWalkCondition(int nCondition, object oCreature=OBJECT_SELF)
{
    return (GetLocalInt(oCreature, sWalkwayVarname) & nCondition);
}

// Cast fleeing spells.
// - Invisiblity (best)
// - Haste/Expeditious Retreat
void ActionCastFleeingSpells()
{
    // Not got local
    if(GetAIInteger(AI_HEARTBEAT_FLEE_SPELLS)) return;
    // Set local
    SetAIInteger(AI_HEARTBEAT_FLEE_SPELLS, TRUE);

    // Invisibilities
    if(HeartbeatSpellCast(SPELL_IMPROVED_INVISIBILITY)) return;
    if(HeartbeatSpellCast(SPELL_INVISIBILITY)) return;

    // Haste
    if(HeartbeatSpellCast(SPELL_MASS_HASTE)) return;
    if(HeartbeatSpellCast(SPELL_HASTE)) return;
    if(HeartbeatSpellCast(SPELL_EXPEDITIOUS_RETREAT)) return;
}
// Cast fleeing spells.
// - Invisiblity (best)
// - Haste/Expeditious Retreat
void ActionCastMoveToCombatSpells()
{
    // Timer to stop too many spells at once
    if(GetLocalTimer(AI_TIMER_MOVE_TO_COMBAT_BUFF)) return;

    // We first will cast a preperation spell before jumping in!
    // This is used once per minute.
    SetLocalTimer(AI_TIMER_MOVE_TO_COMBAT_BUFF, 60.0);

    // We possibly cast a few spell first - stoneskin range, see
    // invisible range, and invisibility range.
    // Protection things
    // * Cast 1 spell!
    if(HeartbeatSpellCast(SPELL_PREMONITION)) return;
    if(HeartbeatSpellCast(SPELL_GREATER_STONESKIN)) return;
    if(HeartbeatSpellCast(SPELL_STONESKIN)) return;
    // Invisibility range
    if(HeartbeatSpellCast(SPELL_ETHEREALNESS)) return;
    if(HeartbeatSpellCast(SPELL_IMPROVED_INVISIBILITY)) return;
    if(HeartbeatSpellCast(SPELL_INVISIBILITY_SPHERE)) return;
    if(HeartbeatSpellCast(SPELL_INVISIBILITY)) return;
    // See invisible things
    if(HeartbeatSpellCast(SPELL_TRUE_SEEING)) return;
    if(HeartbeatSpellCast(SPELL_SEE_INVISIBILITY)) return;

    // Stealth! Only if we are good at it, of course.

    // Spawn in conditions for it
    if(!GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_HIDING, AI_OTHER_COMBAT_MASTER))
    {
        // Need skill or force on
        if((GetSkillRank(SKILL_HIDE) - 4 >= GetHitDice(OBJECT_SELF)) ||
            GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_FORCE_HIDING, AI_OTHER_COMBAT_MASTER))
        {
            // Use hide
            SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, TRUE);
            return;
        }
    }
}
// Used in Search(). This apply Trueseeing, See invisibility, or Invisiblity purge
// if we have neither of the 3 on us.
void SearchSpells()
{
    effect eCheck = GetFirstEffect(OBJECT_SELF);
    int nEffectType, bBreak;
    while(GetIsEffectValid(eCheck) && bBreak == FALSE)
    {
        nEffectType = GetEffectType(eCheck);
        if(nEffectType == EFFECT_TYPE_TRUESEEING ||
           nEffectType == EFFECT_TYPE_SEEINVISIBLE)
        {
            bBreak = TRUE;
        }
        eCheck = GetNextEffect(OBJECT_SELF);
    }
    // We have effects, stop.
    if(bBreak == TRUE || GetHasSpellEffect(SPELL_INVISIBILITY_PURGE))
    {
        return;
    }
    // Else we apply the best spell we have.
    if(HeartbeatSpellCast(SPELL_TRUE_SEEING)) return;
    if(HeartbeatSpellCast(SPELL_SEE_INVISIBILITY)) return;
    if(HeartbeatSpellCast(SPELL_INVISIBILITY_PURGE)) return;
}
// Attempt to cast nSpell. TRUE if true.
int HeartbeatSpellCast(int nSpell)
{
    // 1.4: added check to see if has effect already
    if(GetHasSpell(nSpell) && !GetHasSpellEffect(nSpell, OBJECT_SELF))
    {
        ActionCastSpellAtObject(nSpell, OBJECT_SELF);
        return TRUE;
    }
    return FALSE;
}

// Returns TRUE if any of the animation settings are on.
int GetHasValidAnimations()
{
    int nCheck = GetLocalInt(OBJECT_SELF, NW_GENERIC_MASTER);
    if((nCheck & NW_FLAG_AMBIENT_ANIMATIONS) ||
       (nCheck & NW_FLAG_AMBIENT_ANIMATIONS_AVIAN) ||
       (nCheck & NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS))
    {
        return TRUE;
    }
    return FALSE;
}


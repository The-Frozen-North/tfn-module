/*/////////////////////// [On Blocked] /////////////////////////////////////////
    Filename: J_AI_OnBlocked or nw_c2_defaulte
///////////////////////// [On Blocked] /////////////////////////////////////////
    Added in user defined constant - won't open any doors.
    0 = Default (even if not set) opens as appropriate
    1 = Always bashes the door.
    2 = Never open any doors
    3 = Never opens plot doors

    They will: (int is intellgience needed)
    1. Open if not trapped (7 int)
    2. Unlock if possible, and rank is high enough, and it needs no key and is not trapped (7 int)
    3. Untrap the door, if possible, if trapped (7 int)
    4. Else, if has high enough stats, try Knock. (10 int)
    6. Else Equip appropriate weapons and bash (5 int)

    Note: This also fires for blocking via. creatures. It is optimised, and
    works by re-targeting and doing a few small things to do with blocking.
///////////////////////// [History] ////////////////////////////////////////////
    1.0 - Opens with Knock. Unlocks door. Ignores trapped doors.
    1.3 - Debug messages.
        - New events, even if the change of using them is small!
        - No ClearAllactions so any previous movings will carry on once the door is gone.
        - Removed debug messages
        - Added Creature reaction code
    1.4 - Need to add a "hands" check (done on spawn, to set a setting to not
          open doors at all, IE: We do NOT have hands, do not open doors), so
          its a little more realistic "out of the box"
        - Fixed an instance of GetObjectSeen being repeated.
        - Fixed the variable AI_DOOR_INTELLIGENCE not being got via GetAIInteger().
        - Removed unneeded else statement.
///////////////////////// [Workings] ///////////////////////////////////////////
    Uses simple code to deal with a door in the best way possible.

    Uses DoDoorAction, which is added to the top of an action queue and doesn't,
    therefore, delete any ActionAttack's and so on below it. (Or I hope it
    is like this)

    Creatures are reacted by with ClearAllActions usually.
///////////////////////// [Arguments] //////////////////////////////////////////
    Arguments: GetBlockingDoor, GetIsDoorActionPossible, GetLocked, GetLockKeyRequired
               GetLockKeyTag, GetLockUnlockDC, GetPlotFlag, DoDoorAction
///////////////////////// [On Blocked] ///////////////////////////////////////*/

#include "inc_hai_other"

// Fires the end-blocked event.
void FireBlockedEvent();
// Range attack oTarget.
int RangedAttack(object oTarget = OBJECT_INVALID);

void main()
{
    // Pre-on blocked-event. Returns TRUE if we interrupt this script call.
    if(FirePreUserEvent(AI_FLAG_UDE_ON_BLOCKED_PRE_EVENT, EVENT_ON_BLOCKED_PRE_EVENT)) return;

    // AI status check. Is the AI on?
    if(GetAIOff()) return;

    // This CAN return a blocking creature.
    object oBlocker = GetBlockingDoor();
    int nBlockerType = GetObjectType(oBlocker);

    if(!GetIsObjectValid(oBlocker)) return;

    // Anyone blocked by an enemy will re-target them (and attack them), blocked
    // by someone they cannot get they will cast seeing spells and react, and if
    // blocked by a friend, they may run back and use a ranged weapon if they
    // have one.
    if(nBlockerType == OBJECT_TYPE_CREATURE)
    {
        // Are we doing something that should not be overriden? (even fleeing,
        // if stuck, we can't do anything else then move again on heartbeat!)
        if(GetIsPerformingSpecialAction()) return;

        // Blocked timer, we normally do an action. A small timer stops a lot
        // of lag.
        if(GetLocalTimer(AI_TIMER_BLOCKED)) return;

        // Set the timer for 1 second
        SetLocalTimer(AI_TIMER_BLOCKED, 1.0);

        // Is it an enemy?
        if(GetIsEnemy(oBlocker))
        {
            // Check if seen or heard
            if(GetObjectSeen(oBlocker) || GetObjectHeard(oBlocker))
            {
                // Enemy :-) We can re-target (as know of thier presence), using
                // them as a target.
                // - This overrides even casting a spell - basically, as we should
                //   be moving, this will re-cast it at someone or something in range
                SetAIObject(AI_ATTACK_SPECIFIC_OBJECT, oBlocker);

                // Check if we can do combat - if we cannot, we can re-do combat
                // next time
                if(!GetIsBusyWithAction())
                {
                    // Attacks if we are not attacking
                    ClearAllActions();
                    DetermineCombatRound(oBlocker);
                    return;
                }
            }
            else
            {
                // Invisible? Not there? Some odd error? We set that we know of
                // someone invisible, and will attack if not in combat.
                if(GetHasEffect(EFFECT_TYPE_INVISIBILITY, oBlocker) ||
                   GetStealthMode(oBlocker) == STEALTH_MODE_ACTIVATED)
                {
                    SetAIObject(AI_LAST_TO_GO_INVISIBLE, oBlocker);
                }
                // Shout to allies
                AISpeakString(AI_SHOUT_CALL_TO_ARMS);

                // Check if we can do combat
                if(!GetIsBusyWithAction())
                {
                    // Attacks if we are not attacking
                    ClearAllActions();
                    DetermineCombatRound();
                    return;
                }
            }
        }
        // Else is non-enemy, a friend or neutral
        else
        {
            // As we are blocked by them, we re-do combat - we have a choice of
            // either using a Bow to attack our target (if that was what
            // we were doing) and move back a little, or re-initiate combat

            // Were we attacking in combat?
            object oPrevious = GetAttackTarget();

            // Check action
            if(GetCurrentAction() == ACTION_ATTACKOBJECT)
            {
                // This gets set to FALSE if we can cutthrough attack,
                // or whatever.

                int bPreviousAttackFailed = FALSE;
                // Check if we can see our previous target
                if(GetObjectSeen(oPrevious) ||
                  (GetObjectHeard(oPrevious) && LineOfSightObject(OBJECT_SELF, oPrevious)))
                {
                    // We can! see if we can re-attack with ranged weapon, else
                    // doesn't matter we can see them
                    bPreviousAttackFailed = RangedAttack(oPrevious);
                }

                // If we havn't added an action yet...
                if(bPreviousAttackFailed == FALSE)
                {
                    // We have not stopped the script - so determine combat
                    // round against nearest seen or heard enemy!
                    if(!RangedAttack())
                    {
                        // Else normal round to try and get a new target
                        ClearAllActions();
                        DetermineCombatRound();
                    }
                }
                // Action attack, normally means melee attack. If we can, we
                // attack our previous target if seen, ELSE we will re-initate
                // combat.
                AISpeakString(AI_SHOUT_I_WAS_ATTACKED);

                // Fire the On blocked event as normal
                FireBlockedEvent();
                return;
            }
            else // if(nAction == ACTION_CASTSPELL and others)
            {
                // Reinitate combat, but don't attack oPrevious
                ClearAllActions();
                DetermineCombatRound();

                // Action attack, normally means melee attack. If we can, we
                // attack our previous target if seen, ELSE we will re-initate
                // combat.
                AISpeakString(AI_SHOUT_I_WAS_ATTACKED);

                // Fire the On blocked event as normal
                FireBlockedEvent();
                return;
            }
        }
    }
    // Placeable - Currently not returned, however, added just in case!
    else if(nBlockerType == OBJECT_TYPE_PLACEABLE)
    {
        // Check for plot, and therefore attack it to bring it down.
        // - Remember, ActionAttack will re-initiate when combat round fires
        //   again in 3 or 6 seconds (or less, if we just were moving)
        if(!GetPlotFlag(oBlocker) &&
            GetIsPlaceableObjectActionPossible(oBlocker, PLACEABLE_ACTION_BASH))
        {
            // Do placeable action
            DoPlaceableObjectAction(oBlocker, PLACEABLE_ACTION_BASH);
            FireBlockedEvent();
            return;
        }
        return;
    }
    // Door behaviour
    else if(nBlockerType == OBJECT_TYPE_DOOR)
    {
        int nDoorIntelligence = GetAIInteger(AI_DOOR_INTELLIGENCE);
        int nInt = GetAbilityScore(OBJECT_SELF, ABILITY_INTELLIGENCE);
        if(nDoorIntelligence == 1)// 1 = Always bashes the doors, plot, locked or anything.
        {
            DoDoorAction(oBlocker, DOOR_ACTION_BASH);
            // We re-initiate combat.
            FireBlockedEvent();
            return;
        }
        else if(nDoorIntelligence == 2)// 2 = Never open anything, bashing or not.
        {
            FireBlockedEvent();
            return;
        }
        else if(nDoorIntelligence == 3)// 3 = Never tries anything against plot doors.
        {
            if(GetPlotFlag(oBlocker))
            {
                FireBlockedEvent();
                return;
            }
        }
        if(nInt >= 5)
        {
            // Need some intelligence :-)
            if(nInt >= 7)
            {
                // Right, first, we may...shock...open it!!!
                // Checks Key, lock, trap and if the action is possible.
                if(GetIsDoorActionPossible(oBlocker, DOOR_ACTION_OPEN) &&
                  !GetLocked(oBlocker) &&
                  !GetIsTrapped(oBlocker) &&
                  (!GetLockKeyRequired(oBlocker) ||
                  (GetLockKeyRequired(oBlocker) && GetItemPossessor(GetObjectByTag(GetLockKeyTag(oBlocker))) == OBJECT_SELF)))
                {
                    DoDoorAction(oBlocker, DOOR_ACTION_OPEN);
                    FireBlockedEvent();
                    return;
                }
                // Unlock it with the skill, if it is not trapped and we can :-P
                // We take 20 off the door DC, thats our minimum roll, after all.
                if(GetLocked(oBlocker) &&
                  !GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_OPENING_LOCKED_DOORS, AI_OTHER_COMBAT_MASTER) &&
                  !GetLockKeyRequired(oBlocker) && GetHasSkill(SKILL_OPEN_LOCK) &&
                   GetIsDoorActionPossible(oBlocker, DOOR_ACTION_UNLOCK) && !GetIsTrapped(oBlocker) &&
                  (GetSkillRank(SKILL_OPEN_LOCK) >= (GetLockLockDC(oBlocker) - 20)))
                {
                    DoDoorAction(oBlocker, DOOR_ACTION_UNLOCK);
                    FireBlockedEvent();
                    return;
                }
                // Specilist thing - knock
                if(nInt >= 10)
                {
                    if((GetIsDoorActionPossible(oBlocker, DOOR_ACTION_KNOCK)) &&
                        GetLockUnlockDC(oBlocker) <= 25 &&
                       !GetLockKeyRequired(oBlocker) && GetHasSpell(SPELL_KNOCK))
                    {
                        DoDoorAction(oBlocker, DOOR_ACTION_KNOCK);
                        FireBlockedEvent();
                        return;
                    }
                }
            }
            // If Our Int is over 5, we will bash after everything else.
            if(GetIsDoorActionPossible(oBlocker, DOOR_ACTION_BASH) && !GetPlotFlag(oBlocker))
            {
                if(GetAttackTarget() != oBlocker)
                {
                    DoDoorAction(oBlocker, DOOR_ACTION_BASH);
                }
                FireBlockedEvent();
                return;
            }
        }
    }
    // Fire Blocked event
    FireBlockedEvent();
}
// Fires the end-blocked event.
void FireBlockedEvent()
{
    // Fire End-blocked-UDE
    FireUserEvent(AI_FLAG_UDE_ON_BLOCKED_EVENT, EVENT_ON_BLOCKED_EVENT);
}
// Range attack oTarget.
int RangedAttack(object oTarget)
{
    // If we are primarily melee, don't use this
    if(!GetSpawnInCondition(AI_FLAG_COMBAT_BETTER_AT_HAND_TO_HAND, AI_COMBAT_MASTER)) return FALSE;

    object oRangedTarget = oTarget;
    if(!GetIsObjectValid(oRangedTarget))
    {
        oRangedTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
        if(!GetIsObjectValid(oTarget))
        {
            oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_HEARD, CREATURE_TYPE_IS_ALIVE, TRUE);
            // heard must be in LOS to attack, as we are probably stuck
            if(!GetIsObjectValid(oTarget) && LineOfSightObject(OBJECT_SELF, oRangedTarget))
            {
                return FALSE;
            }
        }
    }
    // Ranged weapon attack against oTarget
    // doesn't matter we can see them
    object oRanged = GetAIObject(AI_WEAPON_RANGED);
    int nAmmo = GetAIInteger(AI_WEAPON_RANGED_AMMOSLOT);

    // Check ammo and validness
    if(GetIsObjectValid(oRanged) && (nAmmo == INVENTORY_SLOT_RIGHTHAND ||
       GetIsObjectValid(GetItemInSlot(nAmmo))))
    {
        // Attack with it
        ClearAllActions();
        ActionEquipItem(oRanged, INVENTORY_SLOT_RIGHTHAND);
        ActionAttack(oRangedTarget);
        // Stop
        return TRUE;
    }
    return FALSE;
}


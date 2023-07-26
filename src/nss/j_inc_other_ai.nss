/************************ [Include - Other AI Functions] ***********************
    Filename: j_inc_other_ai
************************* [Include - Other AI Functions] ***********************
    This contains fuctions and calls for these scripts:
    nw_c2_default2 - Percieve
    nw_c2_default3 - On Combat round End (For DetermineCombatRound() only)
    nw_c2_default4 - Conversation (shout)
    nw_c2_default5 - Phisical attacked
    nw_c2_default6 - Damaged
    nw_c2_default8 - Disturbed
    nw_c2_defaultb - Spell cast at
    Ones that don't use this use different/No includes.

    HOPEFULLY it will make them faster, if they don't run combat.

    They use Execute Script to initiate combat. (With the override ones
    initiating the override version, the normal initiateing the normal).
************************* [History] ********************************************
    1.3 - Added to speed up compilings and gather non-combat, or other workings
          in one place.
************************* [Workings] *******************************************
    This is included, by #include "J_INC_OTHER_AI" in other AI files.

    They then use these functions in them scripts.
************************* [Arguments] ******************************************
    Arguments: N/A
************************* Include - Other AI Functions] ***********************/

// All constants.
#include "j_inc_constants"

// Responds to it (like makinging the callers attacker thier target)
// Called in OnConversation, and thats it. Use "ShouterFriend" To stop repeated GetIsFriend calls.
void RespondToShout(object oShouter, int nShoutIndex);
// Gets the attacker or attakee of the target, which should be a friend
object GetIntruderFromShout(object oShouter);

// Shouts, or really brings all people in 60.0M(by default) to the "shouter"
void ShoutBossShout(object oEnemy);
// Checks the target for a specific EFFECT_TYPE constant value
// Returns TRUE or FALSE. Used On Damaged for polymorph checking.
int GetHasEffect(int nEffectType, object oTarget = OBJECT_SELF);
// This sets a morale penalty, to the exsisting one, if there is one.
// It will reduce itself after fDuration (or if we die, ETC, it is deleted).
// It is deleted at the end of combat as well.
void SetMoralePenalty(int iPenalty, float fDuration = 0.0);
// Removes iPenalty amount if it can.
void RemoveMoralePenalty(int iPenalty);
// At 5+ intelligence, we fire off any dispells at oPlaceables location
void SearchDispells(object oPlaceable);

// This MAY make us set a local timer to turn off hiding.
// Turn of hiding, a timer to activate Hiding in the main file. This is
// done in each of the events, with the opposition checking seen/heard.
void TurnOffHiding(object oIntruder);
// Used when we percieve a new enemy and are not in combat. Hides the creature
// appropriatly with spawn settings and ability.
// - At least it will clear all actions if it doesn't set hiding on
void HideOrClear();

// This MIGHT move to oEnemy
// - Checks special actions, such as fleeing, and may run instead!
void ActionMoveToEnemy(object oEnemy);

// Returns TRUE if we have under 0 morale, set to flee.
// - They then run! (Badly)
int PerceptionFleeFrom(object oEnemy);

/*::///////////////////////////////////////////////
//:: Name: ShoutBossShout
//::///////////////////////////////////////////////
 This is used in the OnPercieve, and if we are set to,
 we will "shout" and bring lots of allies a running
//:://///////////////////////////////////////////*/
void ShoutBossShout(object oEnemy)
{
    if(GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_BOSS_MONSTER_SHOUT, AI_OTHER_COMBAT_MASTER))
    {
        // Get the range (and default to 60.0 M)
        float fRange = IntToFloat(GetBoundriedAIInteger(AI_BOSS_MONSTER_SHOUT_RANGE, i60, 370));
        // We loop through nearest not-seen, not-heard allies and get them
        // to attack the person.
        int Cnt = i1;
        // Not seen, not heard...
        object oAlly = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND,
                                          OBJECT_SELF, Cnt, CREATURE_TYPE_IS_ALIVE, TRUE,
                                          CREATURE_TYPE_PERCEPTION, PERCEPTION_NOT_SEEN_AND_NOT_HEARD);
        // Get who thier target is.
        object oThierTarget;
        while(GetIsObjectValid(oAlly) && GetDistanceToObject(oAlly) <= fRange)
        {
            oThierTarget = GetLocalObject(oAlly, AI_TO_ATTACK);
            // If they are not attacking the enemy, we assing them to attack.
            if(oThierTarget != oEnemy)
            {
                // Can't be in combat.
                if(!GetIsInCombat(oAlly))
                {
                    // Set them to move to this
                    SetLocalObject(oAlly, AI_TO_ATTACK, oEnemy);
                    // Make them attack the person
                    SetLocalObject(oAlly, AI_TEMP_SET_TARGET, oEnemy);
                    ExecuteScript(COMBAT_FILE, oAlly);
                }
            }
            Cnt++;
            oAlly = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND,
                                       OBJECT_SELF, Cnt, CREATURE_TYPE_IS_ALIVE, TRUE,
                                       CREATURE_TYPE_PERCEPTION, PERCEPTION_NOT_SEEN_AND_NOT_HEARD);
        }
        // Remove it :-)
        DeleteSpawnInCondition(AI_FLAG_OTHER_COMBAT_BOSS_MONSTER_SHOUT, AI_OTHER_COMBAT_MASTER);
    }
}
// This MAY make us set a local timer to turn off hiding.
// Turn of hiding, a timer to activate Hiding in the main file. This is
// done in each of the events, with the opposition checking seen/heard.
void TurnOffHiding(object oIntruder)
{
    if(!GetLocalTimer(AI_TIMER_TURN_OFF_HIDE) &&
       // Are we actually seen/heard or is it just an AOE?
      (GetObjectSeen(OBJECT_SELF, oIntruder) ||
       GetObjectHeard(OBJECT_SELF, oIntruder)))
    {
        SetLocalTimer(AI_TIMER_TURN_OFF_HIDE, f18);
    }
}

// Used when we percieve a new enemy and are not in combat. Hides the creature
// appropriatly with spawn settings and ability.
// - At least it will clear all actions if it doesn't set hiding on
void HideOrClear()
{
    // Spawn in conditions for it
    if(!GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_HIDING, AI_OTHER_COMBAT_MASTER) &&
        GetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH) == FALSE)
    {
        // Need skill or force on
        if((GetSkillRank(SKILL_HIDE) - i4 >= GetHitDice(OBJECT_SELF)) ||
            GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_FORCE_HIDING, AI_OTHER_COMBAT_MASTER))
        {
            // Use hide
            ClearAllActions(TRUE);
            SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, TRUE);
            // Stop
            return;
        }
    }
    // Else clear all actions normally.
    ClearAllActions();
}

/*::///////////////////////////////////////////////
//:: Respond To Shouts
//:: Copyright (c) 2001 Bioware Corp.
//::///////////////////////////////////////////////
 Useage:

//NOTE ABOUT BLOCKERS

    int NW_GENERIC_SHOUT_BLOCKER = 2;

    It should be noted that the Generic Script for On Dialogue attempts to get a local
    set on the shouter by itself. This object represents the LastOpenedBy object.  It
    is this object that becomes the oIntruder within this function.

//NOTE ABOUT INTRUDERS

    These are the enemy that attacked the shouter.

//NOTE ABOUT EVERYTHING ELSE

    I_WAS_ATTACKED = 1;

    If not in combat, attack the attackee of the shouter. Basically the best
    way to get people to come and help us.

    CALL_TO_ARMS = 3;

    If not in combat, determine combat round. By default, it should check any
    allies it can see/hear for thier targets and help them too.

    HELP_MY_FRIEND = 4;

    This is a runner thing. Said when the runner sees the target to run to.
    Gets a local location, and sets off people to run to it.
    If no valid area for the location, no moving :-P

    We also shout this if we are fleeing. It will set the person to buff too.

    LEADER_FLEE_NOW = 5

    We flee to a pre-set object or follow the leader (who should be fleeing).

    LEADER_ATTACK_TARGET = 6

    We attack the intruder next round, by setting it as a local object to
    override other choices.

    I_WAS_KILLED = 7

    If lots are killed in one go - ouch! morale penalty each time someone dies.

    I_WAS_OPENED = 8

    Chests/Doors which say this get the AI onto the tails of those who opened it, OR
    they get searched! :-)
//::///////////////////////////////////////////////
// Modified almost completely: Jasperre
//:://///////////////////////////////////////////*/
// Gets the attacker or attakee of the target, which should be a friend
object GetIntruderFromShout(object oShouter)
{
    object oIntruder = GetAttackTarget(oShouter);
    if(!GetIsObjectValid(oIntruder) ||
        GetIgnoreNoFriend(oIntruder))
    {
        oIntruder = GetLastHostileActor(oShouter);
        if(GetIgnoreNoFriend(oIntruder))
        {
            return OBJECT_INVALID;
        }
    }
    return oIntruder;
}

void RespondToShout(object oShouter, int nShoutIndex)
{
    object oIntruder;
    // Ones we don't care about if we are in combat...
    if(nShoutIndex == i6) // "Attack specific object"
    {
        // If a leader, we set it as a local object, nothing more
        if(GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_GROUP_LEADER, AI_OTHER_COMBAT_MASTER, oShouter))
        {
            oIntruder = GetLocalObject(oShouter, AI_ATTACK_SPECIFIC_OBJECT);
            if(GetObjectSeen(oIntruder))
            {
                // Set local object to use in next DetermineCombatRound.
                // We do not interrupt current acition (EG: Life saving stoneskins!) to re-direct.
                SetAIObject(AI_ATTACK_SPECIFIC_OBJECT, oIntruder);
                // 6 second delay.
                SetLocalTimer(AI_TIMER_SHOUT_IGNORE_ANYTHING_SAID, f6);
            }
        }
        return;
    }
    else if(nShoutIndex == i5)// "leader flee now"
    {
        // If a leader, we set it as a local object, nothing more
        if(GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_GROUP_LEADER, AI_OTHER_COMBAT_MASTER, oShouter))
        {
            oIntruder = GetLocalObject(oShouter, AI_FLEE_TO);
              // RUN! If intruder set is over 5.0M or no valid intruder
            ClearAllActions();
            // 70. "[Shout] Reacting To Shout. [ShoutNo.] " + IntToString(iInput) + " [Shouter] " + GetName(oInput)
            DebugActionSpeakByInt(70, oShouter, nShoutIndex);
            SetCurrentAction(AI_SPECIAL_ACTIONS_FLEE);
            SetLocalTimer(AI_TIMER_SHOUT_IGNORE_ANYTHING_SAID, f12);
            if(GetIsObjectValid(oIntruder))
            {
                SetAIObject(AI_FLEE_TO, oIntruder);
                ActionMoveToObject(oIntruder);
            }
            else // Else, we will just follow our leader!
            {
                SetAIObject(AI_FLEE_TO, oShouter);
                ActionForceFollowObject(oShouter, f3);
            }
        }
        return;
    }
    // If the shout is number 8, it is "I was opened" and so can only be a
    // placeable or door.
    else if(nShoutIndex == i8)// "I was opened"
    {
        // We need somewhat complexe here - to get thier opener.
        int nType = GetObjectType(oShouter);
        // Check object type. If not a placeable nor door - stop script.
        if(nType == OBJECT_TYPE_PLACEABLE ||
           nType == OBJECT_TYPE_DOOR)
        {
            // Now, we assign the placeable/door to set thier opener.
            // - Need to check it works.
            AssignCommand(oShouter, SetLocalObject(oShouter, PLACEABLE_LAST_OPENED_BY, GetLastOpenedBy()));
            oIntruder = GetLocalObject(oShouter, PLACEABLE_LAST_OPENED_BY);
            if(GetIsObjectValid(oIntruder))
            {
                // Attack
                ClearAllActions();
                DetermineCombatRound(oShouter);
            }
        }
    }
    // Else, we must not be in combat for the rest
    else if(!CannotPerformCombatRound())
    {
        // Call to arms requires nothing special
        if(nShoutIndex == i3)// "Call to arms"
        {
            SetLocalTimer(AI_TIMER_SHOUT_IGNORE_ANYTHING_SAID, f6);
            // 70. "[Shout] Reacting To Shout. [ShoutNo.] " + IntToString(iInput) + " [Shouter] " + GetName(oInput)
            DebugActionSpeakByInt(70, oShouter, nShoutIndex);
            DetermineCombatRound();
        }
        // Ones we can GetIntruderFromShout(oShouter);
        if(nShoutIndex == i1 || // "I was attacked"
           nShoutIndex == i4 || // "Help my friend"
           nShoutIndex == i7)   // "I was killed"
        {
            // Am not already fighting, and we don't ignore the intruder
            oIntruder = GetIntruderFromShout(oShouter);
            if(!GetIsObjectValid(oIntruder))
            {
                return;
            }
        }
        if(nShoutIndex == i1 ||
           nShoutIndex == i7)
        {
            // Morale penalty if they were killed
            if(nShoutIndex == i7)
            {
                SetMoralePenalty((GetHitDice(oShouter)/i4), f18);
            }
            // Get intruder
            // 70. "[Shout] Reacting To Shout. [ShoutNo.] " + IntToString(iInput) + " [Shouter] " + GetName(oInput)
            DebugActionSpeakByInt(70, oShouter, nShoutIndex);
            if(GetObjectSeen(oIntruder))
            {
                // Stop, and attack, if we can see them!
                ClearAllActions();
                SetLocalTimer(AI_TIMER_SHOUT_IGNORE_ANYTHING_SAID, f9);
                DetermineCombatRound(oIntruder);
                DelayCommand(f2, AISpeakString(I_WAS_ATTACKED));
            }
            else // Else the enemy is not seen
            {
                // If I can see neither the shouter nor the enemy
                // stop what I am doing, and move to the attacker.
                // - 1.3 change. They move to the attackers location (IE directed by ally)
                ClearAllActions();
                SetLocalTimer(AI_TIMER_SHOUT_IGNORE_ANYTHING_SAID, f6);
                // This will move to oIntruder if nothing else
                DetermineCombatRound(oIntruder);
                // Shout to other allies, after a second.
                DelayCommand(f2, AISpeakString(HELP_MY_FRIEND));
            }
        }
        else if(nShoutIndex == i4)// "Help my friend"
        {
            // We move to where the runner/shouter wants us.
            location lMoveTo = GetLocalLocation(oShouter, AI_HELP_MY_FRIEND_LOCATION);
            // 70. "[Shout] Reacting To Shout. [ShoutNo.] " + IntToString(iInput) + " [Shouter] " + GetName(oInput)
            DebugActionSpeakByInt(70, oShouter, nShoutIndex);
            SetLocalTimer(AI_TIMER_SHOUT_IGNORE_ANYTHING_SAID, f6);
            if(GetIsObjectValid(GetAreaFromLocation(lMoveTo)))
            {
                ActionMoveToLocation(lMoveTo, TRUE);
                ActionDoCommand(DetermineCombatRound());
            }
            else
            {
                // If we do not know of the friend attacker, we will follow them
                ClearAllActions();
                SetSpawnInCondition(AI_FLAG_COMBAT_FLAG_FAST_BUFF_ENEMY, AI_COMBAT_MASTER);
                ActionForceFollowObject(oShouter, f3);
                ActionDoCommand(DetermineCombatRound());
            }
        }
    }
}

void SearchDispells(object oPlaceable)
{
    // No dispelling at low intelligence.
    if(GetBoundriedAIInteger(AI_INTELLIGENCE) < i5) return;
    location lPlace = GetLocation(oPlaceable);
    // Move closer if not seen.
    if(!GetObjectSeen(oPlaceable))
    {
        // Move nearer - 6 M is out of the dispell range
        ActionMoveToObject(oPlaceable, TRUE, f6);
    }
    // Dispell if we have any - at the location of oPlaceable.
    if(GetHasSpell(SPELL_LESSER_DISPEL))
    {
        ActionCastSpellAtLocation(SPELL_LESSER_DISPEL, lPlace);
    }
    else if(GetHasSpell(SPELL_DISPEL_MAGIC))
    {
        ActionCastSpellAtLocation(SPELL_DISPEL_MAGIC, lPlace);
    }
    else if(GetHasSpell(SPELL_GREATER_DISPELLING))
    {
        ActionCastSpellAtLocation(SPELL_GREATER_DISPELLING, lPlace);
    }
    else if(GetHasSpell(SPELL_MORDENKAINENS_DISJUNCTION))
    {
        ActionCastSpellAtLocation(SPELL_MORDENKAINENS_DISJUNCTION, lPlace);
    }
}

// Get Has Effect
//  Checks to see if the target has a given
//  effect, usually from a spell. Really useful this is.
int GetHasEffect(int nEffectType, object oTarget = OBJECT_SELF)
{
    effect eCheck = GetFirstEffect(oTarget);
    while(GetIsEffectValid(eCheck))
    {
        if(GetEffectType(eCheck) == nEffectType)
        {
             return TRUE;
             break;
        }
        eCheck = GetNextEffect(oTarget);
    }
    return FALSE;
}

// This sets a morale penalty, to the exsisting one, if there is one.
// It will reduce itself (by the penalty) after fDuration (or if we die, ETC, it is deleted).
// It is deleted at the end of combat as well.
void SetMoralePenalty(int iPenalty, float fDuration = 0.0)
{
    int iOriginal = GetAIInteger(AI_MORALE_PENALTY);
    int iNew = iOriginal + iPenalty;
    SetAIInteger(AI_MORALE_PENALTY, iNew);
    DelayCommand(fDuration, RemoveMoralePenalty(iPenalty));
}
void RemoveMoralePenalty(int iPenalty)
{
    int iOriginal = GetAIInteger(AI_MORALE_PENALTY);
    int iNew = iOriginal - iPenalty;
    if(iNew > 0 && !GetIsDead(OBJECT_SELF))
    {
        SetAIInteger(AI_MORALE_PENALTY, iNew);
    }
    else
    {
        DeleteAIInteger(AI_MORALE_PENALTY);
    }
}

// This MIGHT move to oEnemy
// - Checks special actions, such as fleeing, and may run instead!
void ActionMoveToEnemy(object oEnemy)
{
    // Make sure that we are not fleeing badly (-1 morale from all enemies)
    if(GetIsEnemy(oEnemy))
    {
        // -1 morale, flee
        if(PerceptionFleeFrom(oEnemy)) return;
    }
    if(GetIsPerformingSpecialAction())
    {
        // Stop if we have an action we don't want to override
        return;
    }
    // End default is move to the enemy
    ClearAllActions();
    ActionMoveToObject(oEnemy, TRUE);
    // combat round to heal/search/whatever
    if(!GetFactionEqual(oEnemy))
    {
        ActionDoCommand(DetermineCombatRound(oEnemy));
    }
}

// Returns TRUE if we have under 0 morale, set to flee.
// - They then run! (Badly)
int PerceptionFleeFrom(object oEnemy)
{
    object oRunTarget = oEnemy;
    if(GetAIInteger(AI_INTELLIGENCE) < FALSE)
    {
        // Valid run from target
        if(!GetIsObjectValid(oRunTarget))
        {
            oRunTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, i1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
            if(!GetIsObjectValid(oRunTarget))
            {
                oRunTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, i1, CREATURE_TYPE_PERCEPTION, PERCEPTION_HEARD, CREATURE_TYPE_IS_ALIVE, TRUE);
                if(!GetIsObjectValid(oRunTarget))
                {
                    oRunTarget = GetLastHostileActor();
                    if(!GetIsObjectValid(oRunTarget) || GetIsDead(oRunTarget))
                    {
                        // Stop - nothing to flee from!
                        return FALSE;
                    }
                }
            }
        }
        // Run from enemy
        ClearAllActions();
        ActionMoveAwayFromObject(oRunTarget, TRUE, f50);
        return TRUE;
    }
    // 0 or more morale.
    return FALSE;
}

// Debug: To compile this script full, uncomment all of the below.
/* - Add two "/"'s at the start of this line
void main()
{
    return;
}
//*/

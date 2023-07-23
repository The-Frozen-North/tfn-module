/*/////////////////////// [Include - Other AI Functions] ///////////////////////
    Filename: J_INC_Other_AI
///////////////////////// [Include - Other AI Functions] ///////////////////////
    This contains fuctions and calls for these scripts:
    nw_c2_default2 - Percieve
    nw_c2_default3 - On Combat round End (For DetermineCombatRound() only)
    nw_c2_default4 - Conversation (shout)
    nw_c2_default5 - Phisical attacked
    nw_c2_default6 - Damaged
    nw_c2_default8 - Disturbed
    nw_c2_defaultb - Spell cast at

    Ones that don't use this use different or no includes.

    HOPEFULLY it will make them faster, if they don't run combat.

    They use Execute Script to initiate combat. (With the override ones
    initiating the override version, the normal initiateing the normal).
///////////////////////// [History] ////////////////////////////////////////////
    1.3 - Added to speed up compilings and gather non-combat, or other workings
          in one place.
    1.4 - TO DO:
        -
///////////////////////// [Workings] ///////////////////////////////////////////
    This is included in other AI files.

    They then use these functions in them scripts.
///////////////////////// [Arguments] //////////////////////////////////////////
    Arguments: N/A
///////////////////////// [Include - Other AI Functions] /////////////////////*/

// All constants.
#include "J_INC_CONSTANTS"

// Responds  to it (like makinging the callers attacker thier target)
// Called in OnConversation, and thats it. Use "ShouterFriend" To stop repeated GetIsFriend calls.
void RespondToShout(object oShouter, int nShoutIndex);
// Gets any possible target which is attacking oShouter (and isn't an ally)
// or who oShouter is attacking. oShouter should be a ally.
object GetIntruderFromShout(object oShouter);

// Shouts, or really brings all people in 60.0M(by default) to the "shouter"
void ShoutBossShout(object oEnemy);
// This sets a morale penalty, to the exsisting one, if there is one.
// It will reduce itself after fDuration (or if we die, ETC, it is deleted).
// It is deleted at the end of combat as well.
void SetMoralePenalty(int nPenalty, float fDuration = 0.0);
// Removes nPenalty amount if it can.
void RemoveMoralePenalty(int nPenalty);
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

// This wrappers commonly used code for a "Call to arms" type response.
// * We know of no enemy, so we will move to oAlly, who either called to
//   us, or, well, we know of.
// * Calls out AI_SHOUT_CALL_TO_ARMS too.
void CallToArmsResponse(object oAlly);
// This wrappers commonly used code for a "I was attacked" type response.
// * We know there will be an enemy - or should be - and if we find one to attack
//   (using GetIntruderFromShout()) - we attack it (and call another I was attacked)
//   else, this will run CallToArmsResponse(oAlly);
// * Calls out AI_SHOUT_I_WAS_ATTACKED, or AI_SHOUT_CALL_TO_ARMS too.
void IWasAttackedResponse(object oAlly);

/*::///////////////////////////////////////////////
//:: Name: ShoutBossShout
//::///////////////////////////////////////////////
 This is used in the OnPercieve, and if we are set to,
 we will "shout" and bring lots of allies a running
//:://///////////////////////////////////////////*/
void ShoutBossShout(object oEnemy)
{
    // 1.4 - Added a 5 minute cooldown timer for this. Thusly, if the boss lingers,
    // so will the big shout they do.
    if(GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_BOSS_MONSTER_SHOUT, AI_OTHER_COMBAT_MASTER) &&
      !GetLocalTimer(AI_TIMER_BOSS_SHOUT_COOLDOWN))
    {
        // Get the range (and default to 60.0 M)
        float fRange = IntToFloat(GetBoundriedAIInteger(AI_BOSS_MONSTER_SHOUT_RANGE, 60, 370));
        // We loop through nearest not-seen, not-heard allies and get them
        // to attack the person.
        int nCnt = 1;
        // Not seen, not heard...
        object oAlly = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND,
                                          OBJECT_SELF, nCnt, CREATURE_TYPE_IS_ALIVE, TRUE,
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
            nCnt++;
            oAlly = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND,
                                       OBJECT_SELF, nCnt, CREATURE_TYPE_IS_ALIVE, TRUE,
                                       CREATURE_TYPE_PERCEPTION, PERCEPTION_NOT_SEEN_AND_NOT_HEARD);
        }
        // * Don't speak when dead. 1.4 change (an obvious one to make)
        if(CanSpeak())
        {
            // Speak a string associated with this action being carried out
            SpeakArrayString(AI_TALK_ON_LEADER_BOSS_SHOUT);
        }
        // Remove it for 5 minutes.
        SetLocalTimer(AI_TIMER_BOSS_SHOUT_COOLDOWN, 300.0);
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
        SetLocalTimer(AI_TIMER_TURN_OFF_HIDE, 18.0);
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
        int nRank = GetSkillRank(SKILL_HIDE);
        if((nRank - 4 >= GetHitDice(OBJECT_SELF) && nRank >= 7) ||
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
    way to get people to come and help us, if we know of an attacker!
    * Call this after we call DetermineCombatRound() to make sure that any
      responses know of the attackers. It doesn't matter in actual fact, but
      useful anyway.

    CALL_TO_ARMS = 3;

    If not in combat, determine combat round. By default, it should check any
    allies it can see/hear for thier targets and help them too.
    * Better if we do not know of a target (and thusly our allies wouldn't know
      of them as well) so the allies will move to us.

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
// Gets any possible target which is attacking oShouter (and isn't an ally)
// or who oShouter is attacking. oShouter should be a ally.
object GetIntruderFromShout(object oShouter)
{
    // First, get who they specifically want to attack (IE: Input target the shout
    // is usually for)
    object oIntruder = GetLocalObject(oShouter, AI_OBJECT + AI_ATTACK_SPECIFIC_OBJECT);
    if(GetIgnoreNoFriend(oIntruder) || (!GetObjectSeen(oShouter) && !GetObjectHeard(oShouter)))
    {
        // Or, we look for the last melee target (which, at least, will be set)
        oIntruder = GetLocalObject(oShouter, AI_OBJECT + AI_LAST_MELEE_TARGET);
        if(GetIgnoreNoFriend(oIntruder) || (!GetObjectSeen(oShouter) && !GetObjectHeard(oShouter)))
        {
            // Current actual attack target of the shouter
            oIntruder = GetAttackTarget(oShouter);
            if(GetIgnoreNoFriend(oIntruder) || (!GetObjectSeen(oShouter) && !GetObjectHeard(oShouter)))
            {
                // Last hostile actor of the shouter
                oIntruder = GetLastHostileActor(oShouter);
                if(GetIgnoreNoFriend(oIntruder) || (!GetObjectSeen(oShouter) && !GetObjectHeard(oShouter)))
                {
                    return OBJECT_INVALID;
                }
            }
        }
    }
    return oIntruder;
}
// Responds  to it (like makinging the callers attacker thier target)
// Called in OnConversation, and thats it. Use "ShouterFriend" To stop repeated GetIsFriend calls.
void RespondToShout(object oShouter, int nShoutIndex)
{
    // We use oIntruder to set who to attack.
    object oIntruder;
    // Check nShoutIndex against known constants
    switch(nShoutIndex)
    {
        // Note: Not checked in sequential order (especially as they are constants).
        // Instead, it is "Ones which if we are in combat, we still check" first.

        // Attack a specific object which the leader shouted about.
        case AI_SHOUT_LEADER_ATTACK_TARGET_CONSTANT:
        {
            // If a leader, we set it as a local object, nothing more
            if(GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_GROUP_LEADER, AI_OTHER_COMBAT_MASTER, oShouter))
            {
                // 70. "[Shout] Reacting To Shout. [ShoutNo.] " + IntToString(iInput) + " [Shouter] " + GetName(oInput)
                DebugActionSpeakByInt(70, oShouter, nShoutIndex);

                oIntruder = GetLocalObject(oShouter, AI_ATTACK_SPECIFIC_OBJECT);
                if(GetObjectSeen(oIntruder))
                {
                    // Set local object to use in next DetermineCombatRound.
                    // We do not interrupt current acition (EG: Life saving stoneskins!) to re-direct.
                    SetAIObject(AI_ATTACK_SPECIFIC_OBJECT, oIntruder);
                    // 6 second delay.
                    SetLocalTimer(AI_TIMER_SHOUT_IGNORE_ANYTHING_SAID, 6.0);
                }
            }
            return;
        }
        break;
        // Leader flee now - mass retreat to those who hear it.
        case AI_SHOUT_LEADER_FLEE_NOW_CONSTANT:
        {
            // If a leader, we set it as a local object, nothing more
            if(GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_GROUP_LEADER, AI_OTHER_COMBAT_MASTER, oShouter))
            {
                // Get who we are going to run too
                oIntruder = GetLocalObject(oShouter, AI_FLEE_TO);

                // RUN! If intruder set is over 5.0M or no valid intruder
                ClearAllActions();

                // 70. "[Shout] Reacting To Shout. [ShoutNo.] " + IntToString(iInput) + " [Shouter] " + GetName(oInput)
                DebugActionSpeakByInt(70, oShouter, nShoutIndex);

                // Set to run
                SetCurrentAction(AI_SPECIAL_ACTIONS_FLEE);
                // Turn on fleeing visual effect
                ApplyFleeingVisual();

                // Ignore talk for 12 seconds
                SetLocalTimer(AI_TIMER_SHOUT_IGNORE_ANYTHING_SAID, 12.0);

                // If valid, we run to the intruder
                if(GetIsObjectValid(oIntruder))
                {
                    SetAIObject(AI_FLEE_TO, oIntruder);
                    ActionMoveToObject(oIntruder);
                }
                else // Else, we will just follow our leader!
                {
                    SetAIObject(AI_FLEE_TO, oShouter);
                    ActionForceFollowObject(oShouter, 3.0);
                }
            }
            return;
        }
        break;

        // All others (IE: We need to not be in combat for these)
        // Anything that requires "DetermineCombatRound()" is here.

        // If the shout is number 8, it is "I was opened" and so can only be a
        // placeable or door.
        case AI_SHOUT_I_WAS_OPENED_CONSTANT:
        {
            // If we are already attacking, we ignore this shout.
            if(CannotPerformCombatRound()) return;

            // We need somewhat complexe here - to get thier opener.
            int nType = GetObjectType(oShouter);
            // Check object type. If not a placeable nor door - stop script.
            if(nType == OBJECT_TYPE_PLACEABLE ||
               nType == OBJECT_TYPE_DOOR)
            {
                // 70. "[Shout] Reacting To Shout. [ShoutNo.] " + IntToString(iInput) + " [Shouter] " + GetName(oInput)
                DebugActionSpeakByInt(70, oShouter, nShoutIndex);

                // Now, we assign the placeable/door to set thier opener.
                // We do this by just executing a script that does it.
                ExecuteScript(FILE_SET_OPENER, oShouter);
                // We can immediantly get this would-be attacker!
                oIntruder = GetLocalObject(oShouter, AI_PLACEABLE_LAST_OPENED_BY);
                if(GetIsObjectValid(oIntruder))
                {
                    // Attack
                    ClearAllActions();
                    DetermineCombatRound(oShouter);
                }
                else
                {
                    // Move to the object who shouted in detect mode
                    SetActionMode(OBJECT_SELF, ACTION_MODE_DETECT, TRUE);
                    ActionMoveToObject(oShouter, TRUE);
                }
            }
            return;
        }
        break;

        // Call to arms requires nothing special. It is only called if
        // There is no target the shouter has to attack specifically, rather then
        // "I_WAS_ATTACKED" which would have.
        case AI_SHOUT_CALL_TO_ARMS_CONSTANT:
        {
            // If we are already attacking, we ignore this shout.
            if(CannotPerformCombatRound()) return;

            // Ignore for 6 seconds
            SetLocalTimer(AI_TIMER_SHOUT_IGNORE_ANYTHING_SAID, 6.0);

            // 70. "[Shout] Reacting To Shout. [ShoutNo.] " + IntToString(iInput) + " [Shouter] " + GetName(oInput)
            DebugActionSpeakByInt(70, oShouter, nShoutIndex);

            // do standard Call to Arms response - IE: Move to oShouter
            CallToArmsResponse(oShouter);
            return;
        }
        break;
        // "Help my friend" is when a runner is running off (sorta fleeing) to
        // get help. This will move to the location set on them to reinforce.
        case AI_SHOUT_HELP_MY_FRIEND_CONSTANT:
        {
            // If we are already attacking, we ignore this shout.
            if(CannotPerformCombatRound()) return;

            // Ignore things for 6 seconds
            SetLocalTimer(AI_TIMER_SHOUT_IGNORE_ANYTHING_SAID, 6.0);

            // We move to where the runner/shouter wants us.
            location lMoveTo = GetLocalLocation(oShouter, AI_LOCATION + AI_HELP_MY_FRIEND_LOCATION);

            // 70. "[Shout] Reacting To Shout. [ShoutNo.] " + IntToString(iInput) + " [Shouter] " + GetName(oInput)
            DebugActionSpeakByInt(70, oShouter, nShoutIndex);

            // If the location is valid
            if(GetIsObjectValid(GetAreaFromLocation(lMoveTo)))
            {
                // New special action, but one that is overrided by combat
                SetCurrentAction(AI_SPECIAL_ACTIONS_MOVE_TO_COMBAT);
                SetAIObject(AI_MOVE_TO_COMBAT_OBJECT, oShouter);
                SetAILocation(AI_MOVE_TO_COMBAT_LOCATION, lMoveTo);

                // Move to the location of the fight, attack.
                ClearAllActions();
                // Move to the fights location
                ActionMoveToLocation(lMoveTo, TRUE);
                // When we see someone fighting, we'll DCR
                return;
            }
            else
            {
                // Else, if we do not know of the friends attackers, or the location
                // they are at, we will follow them without casting any preperation
                // spells.
                ClearAllActions();
                ActionForceFollowObject(oShouter, 3.0);
                // When we see an enemy, we'll attack!
                return;
            }
            return;
        }
        break;

        // "I was attacked" is called when a creature is hurt or sees an enemy,
        // and starts to attack them. This means they know who the enemy is -
        // and thusly we can get it from them (Ususally GetLastHostileActor()
        // "I was killed" is the same, but applies a morale penalty too
        case AI_SHOUT_I_WAS_ATTACKED_CONSTANT:
        case AI_SHOUT_I_WAS_KILLED_CONSTANT:
        {
            // If it was "I was killed", we apply a short morale penatly
            // Penalty is "Hit dice / 4 + 1" (so always 1 minimum) for 18 seconds.
            if(nShoutIndex == AI_SHOUT_I_WAS_KILLED_CONSTANT)
            {
                SetMoralePenalty(GetHitDice(oShouter)/4 + 1, 18.0);
            }

            // If we are already attacking, we ignore this shout.
            if(CannotPerformCombatRound()) return;

            // 70. "[Shout] Reacting To Shout. [ShoutNo.] " + IntToString(iInput) + " [Shouter] " + GetName(oInput)
            DebugActionSpeakByInt(70, oShouter, nShoutIndex);

            // Ignore for 6 seconds
            SetLocalTimer(AI_TIMER_SHOUT_IGNORE_ANYTHING_SAID, 6.0);

            // Respond to oShouter's request for help - find thier target, and
            // attack!
            IWasAttackedResponse(oShouter);
            return;
        }
        break;
    }
}
// At 5+ intelligence, we fire off any dispells at oPlaceables location
void SearchDispells(object oPlaceable)
{
    // No dispelling at low intelligence.
    if(GetBoundriedAIInteger(AI_INTELLIGENCE) < 5) return;
    location lPlace = GetLocation(oPlaceable);
    // Move closer if not seen.
    if(!GetObjectSeen(oPlaceable))
    {
        // Move nearer - 6 M is out of the dispell range
        ActionMoveToObject(oPlaceable, TRUE, 6.0);
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

// This sets a morale penalty, to the exsisting one, if there is one.
// It will reduce itself (by the penalty) after fDuration (or if we die, ETC, it is deleted).
// It is deleted at the end of combat as well.
void SetMoralePenalty(int nPenalty, float fDuration = 0.0)
{
    int nNewPenalty = GetAIInteger(AI_MORALE_PENALTY) + nPenalty;
    SetAIInteger(AI_MORALE_PENALTY, nNewPenalty);
    DelayCommand(fDuration, RemoveMoralePenalty(nPenalty));
}
// Removes nPenalty amount if it can.
void RemoveMoralePenalty(int nPenalty)
{
    int nNewPenalty = GetAIInteger(AI_MORALE_PENALTY) - nPenalty;
    if(nNewPenalty > 0 && !GetIsDead(OBJECT_SELF))
    {
        SetAIInteger(AI_MORALE_PENALTY, nNewPenalty);
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
            oRunTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
            if(!GetIsObjectValid(oRunTarget))
            {
                oRunTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_HEARD, CREATURE_TYPE_IS_ALIVE, TRUE);
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
        ActionMoveAwayFromObject(oRunTarget, TRUE, 50.0);
        return TRUE;
    }
    // 0 or more morale.
    return FALSE;
}
// This wrappers commonly used code for a "Call to arms" type response.
// * We know of no enemy, so we will move to oAlly, who either called to
//   us, or, well, we know of.
// * Calls out AI_SHOUT_CALL_TO_ARMS too.
void CallToArmsResponse(object oAlly)
{
    // Shout to allies to attack, or be prepared.
    AISpeakString(AI_SHOUT_CALL_TO_ARMS);

    // If we are over 2 meters away from oShouter, we move to them using
    // the special action
    if(GetDistanceToObject(oAlly) > 2.0 || !GetObjectSeen(oAlly))
    {
        // New special action, but one that is overrided by combat
        location lAlly = GetLocation(oAlly);
        SetCurrentAction(AI_SPECIAL_ACTIONS_MOVE_TO_COMBAT);
        SetAIObject(AI_MOVE_TO_COMBAT_OBJECT, oAlly);
        SetAILocation(AI_MOVE_TO_COMBAT_LOCATION, lAlly);

        // Move to the location of the fight, attack.
        ClearAllActions();
        // Move to the fights location
        ActionMoveToLocation(lAlly, TRUE);
        // When we see someone fighting, we'll DCR
        return;
    }
    else
    {
        // Determine it anyway - we will search around oShouter
        // if nothing is found...but we are near to the shouter
        DetermineCombatRound(oAlly);
        return;
    }
}
// This wrappers commonly used code for a "I was attacked" type response.
// * We know there will be an enemy - or should be - and if we find one to attack
//   (using GetIntruderFromShout()) - we attack it (and call another I was attacked)
//   else, this will run CallToArmsResponse(oAlly);
// * Calls out AI_SHOUT_I_WAS_ATTACKED, or AI_SHOUT_CALL_TO_ARMS too.
void IWasAttackedResponse(object oAlly)
{
    // Get the indruder. This is either who oShouter is currently attacking,
    // or the last attacker of them.
    object oIntruder = GetIntruderFromShout(oAlly);

    // If valid, of course attack!
    if(GetIsObjectValid(oIntruder))
    {
        // 1.4 Note:
        // * It used to check "Are they seen". Basically, this is redudant
        //   with the checks used in DetermineCombatRound(). It will do the
        //   searching using oIntruder whatever.

        // Stop, and attack
        ClearAllActions();
        DetermineCombatRound(oIntruder);

        // Shout I was attacked - we've set our intruder now
        AISpeakString(AI_SHOUT_I_WAS_ATTACKED);
        return;
    }
    // If invalid, we act as if it was "Call to arms" type thing.
    // Call to arms is better to use normally, of course.
    else
    {
        // Shout to allies to attack, or be prepared.
        AISpeakString(AI_SHOUT_CALL_TO_ARMS);

        // We see if they are attacking anything:
        oIntruder = GetAttackTarget(oAlly);
        if(!GetIsObjectValid(oIntruder))
        {
            oIntruder = GetLocalObject(oAlly, AI_OBJECT + AI_LAST_MELEE_TARGET);
        }

        // If valid, we will move to a point bisecting the intruder and oAlly, or
        // move to oAlly. Should get interrupted once we see the attack target.
        // * NEED TO TEST
        if(GetIsObjectValid(oIntruder))
        {
            // New special action, but one that is overrided by combat
            vector vTarget = GetPosition(oIntruder);
            vector vSource = GetPosition(OBJECT_SELF);
            vector vDirection = vTarget - vSource;
            float fDistance = VectorMagnitude(vDirection) / 2.0;
            vector vPoint = VectorNormalize(vDirection) * fDistance + vSource;
            location lTarget = Location(GetArea(OBJECT_SELF), vPoint, DIRECTION_NORTH);

            SetCurrentAction(AI_SPECIAL_ACTIONS_MOVE_TO_COMBAT);
            SetAIObject(AI_MOVE_TO_COMBAT_OBJECT, oAlly);
            SetAILocation(AI_MOVE_TO_COMBAT_LOCATION, lTarget);

            // Move to the location of the fight, attack.
            ClearAllActions();
            // Move to the fights location
            ActionMoveToLocation(lTarget, TRUE);
            // When we see someone fighting, we'll DCR
            return;
        }
        // If we are over 2 meters away from oShouter, we move to them using
        // the special action
        else if(GetDistanceToObject(oAlly) > 2.0 || !GetObjectSeen(oAlly))
        {
            // New special action, but one that is overrided by combat
            location lAlly = GetLocation(oAlly);
            SetCurrentAction(AI_SPECIAL_ACTIONS_MOVE_TO_COMBAT);
            SetAIObject(AI_MOVE_TO_COMBAT_OBJECT, oAlly);
            SetAILocation(AI_MOVE_TO_COMBAT_LOCATION, lAlly);

            // Move to the location of the fight, attack.
            ClearAllActions();
            // Move to the fights location
            ActionMoveToLocation(lAlly, TRUE);
            // When we see someone fighting, we'll DCR
            return;
        }
        else
        {
            // Determine it anyway - we will search around oShouter
            // if nothing is found...but we are near to the shouter
            DetermineCombatRound(oAlly);
            return;
        }
    }
}




// Debug: To compile this script full, uncomment all of the below.
/* - Add two "/"'s at the start of this line
void main()
{
    return;
}
//*/

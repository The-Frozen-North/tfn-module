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
#include "inc_hai_constant"
//#include "inc_hai_generic"
#include "x0_i0_voice"

void ResetHenchmenState()
{
    SetCommandable(TRUE);
    DeleteLocalObject(OBJECT_SELF, "NW_GENERIC_DOOR_TO_BASH");
    DeleteLocalInt(OBJECT_SELF, "NW_GENERIC_DOOR_TO_BASH_HP");
    SetLocalInt(OBJECT_SELF, "X2_L_MUTEXCOMBATROUND", FALSE);//1.72: fix for stuck issues
    //SetAssociateState(NW_ASC_IS_BUSY, FALSE);
    DeleteLocalInt(OBJECT_SELF, "busy");
    //ClearActions(CLEAR_X0_I0_ASSOC_RESETHENCHMENSTATE);
    ClearAllActions();
}

// Get the cosine of the angle between the two objects
float GetCosAngleBetween(object Loc1, object Loc2)
{
    vector v1 = GetPositionFromLocation(GetLocation(Loc1));
    vector v2 = GetPositionFromLocation(GetLocation(Loc2));
    vector v3 = GetPositionFromLocation(GetLocation(OBJECT_SELF));

    v1.x -= v3.x; v1.y -= v3.y; v1.z -= v3.z;
    v2.x -= v3.x; v2.y -= v3.y; v2.z -= v3.z;

    float dotproduct = v1.x*v2.x+v1.y*v2.y+v1.z*v2.z;

    return dotproduct/(VectorMagnitude(v1)*VectorMagnitude(v2));

}

//Pausanias: Is there a closed door in the line of sight.
// * is door in line of sight
int GetIsDoorInLineOfSight(object oTarget)
{
    float fMeDoorDist;

    object oView = GetFirstObjectInShape(SHAPE_SPHERE, 40.0,
                                         GetLocation(OBJECT_SELF),
                                         TRUE,OBJECT_TYPE_DOOR);

    float fMeTrapDist = GetDistanceBetween(oTarget,OBJECT_SELF);

    while (GetIsObjectValid(oView)) {
        fMeDoorDist = GetDistanceBetween(oView,OBJECT_SELF);
        //SpeakString("Trap3 : "+FloatToString(fMeTrapDist)+" "+FloatToString(fMeDoorDist));
        if (fMeDoorDist < fMeTrapDist && !GetIsTrapped(oView))
            if (GetIsDoorActionPossible(oView,DOOR_ACTION_OPEN) ||
                GetIsDoorActionPossible(oView,DOOR_ACTION_UNLOCK)) {
                float fAngle = GetCosAngleBetween(oView,oTarget);
                //SpeakString("Angle: "+FloatToString(fAngle));
                if (fAngle > 0.5) {
                    // if (d10() > 7)
                    // SpeakString("There's something fishy near that door...");
                    return TRUE;
                }
            }

        oView = GetNextObjectInShape(SHAPE_SPHERE,40.0,
                                     GetLocation(OBJECT_SELF),
                                     TRUE, OBJECT_TYPE_DOOR);
    }

    //SpeakString("No matches found");
    return FALSE;
}

//Pausanias: Is Object in the line of sight of the seer
int GetIsInLineOfSight(object oTarget,object oSeer=OBJECT_SELF)
{
    // * if really close, line of sight
    // * is irrelevant
    // * if this check is removed it gets very annoying
    // * because the player can block line of sight
    if (GetDistanceBetween(oTarget, oSeer) < 6.0)
    {
        return TRUE;
    }

    return LineOfSightObject(oSeer, oTarget);

}

// * attempts to disarm last trap (called from RespondToShout and heartbeat
int AttemptToDisarmTrap(object oTrap, int bWasShout = FALSE)
{
    //MyPrintString("Attempting to disarm: " + GetTag(oTrap));

    // * May 2003: Don't try to disarm a trap with no trap
    if (!GetIsObjectValid(oTrap) || !GetIsTrapped(oTrap))
    {
        return FALSE;
    }



    //1.71: ignore if ordered to deal with trap manually
    // * June 2003. If in 'do not disarm trap' mode, then do not disarm traps
    if(!bWasShout) // && !GetAssociateState(NW_ASC_DISARM_TRAPS))
    {
        return FALSE;
    }

    int bISawTrap = GetTrapDetectedBy(oTrap, OBJECT_SELF) || GetTrapDetectedBy(oTrap, GetMaster());

    int bCloseEnough = GetDistanceToObject(oTrap) <= 15.0;

    int bInLineOfSight = GetIsInLineOfSight(oTrap);


    if(!bISawTrap || !bCloseEnough || !bInLineOfSight)
    {
        //MyPrintString("Failed basic disarm check");
        if (bWasShout)
            VoiceCannotDo();
        return FALSE;
    }

    //object oTrapSaved = GetLocalObject(OBJECT_SELF, "NW_ASSOCIATES_LAST_TRAP");
    SetLocalObject(OBJECT_SELF, "NW_ASSOCIATES_LAST_TRAP", oTrap);
    // We can tell we can't do it
        string sID = ObjectToString(oTrap);
    int nSkill = GetSkillRank(SKILL_DISABLE_TRAP);
    int nTrapDC = GetTrapDisarmDC(oTrap);
    if ( nSkill > 0 && (nSkill  + 20) >= nTrapDC && GetTrapDisarmable(oTrap)) {
        //ClearActions(CLEAR_X0_INC_HENAI_AttemptToDisarmTrap);
        ClearAllActions(TRUE);
        ActionUseSkill(SKILL_DISABLE_TRAP, oTrap);
        ActionDoCommand(SetCommandable(TRUE));
        ActionDoCommand(VoiceTaskComplete());
        SetCommandable(FALSE);
        return TRUE;
    } else if (GetHasSpell(SPELL_FIND_TRAPS) && GetTrapDisarmable(oTrap) && GetLocalInt(oTrap, "NW_L_IATTEMPTEDTODISARMNOWORK") ==0)
    {
       // SpeakString("casting");
        //ClearActions(CLEAR_X0_INC_HENAI_AttemptToDisarmTrap);
        ClearAllActions(TRUE);
        ActionCastSpellAtObject(SPELL_FIND_TRAPS, oTrap);
        SetLocalInt(oTrap, "NW_L_IATTEMPTEDTODISARMNOWORK", 10);
        return TRUE;
    }
    // MODIFIED February 7 2003. Merged the 'attack object' inside of the bshout
    // this is not really something you want the henchmen just to go and do
    // spontaneously
    else if (bWasShout)
    {
        //ClearActions(CLEAR_X0_INC_HENAI_BKATTEMPTTODISARMTRAP_ThrowSelfOnTrap);
        ClearAllActions(TRUE);
        //SpeakStringByStrRef(40551); // * Out of game indicator that this trap can never be disarmed by henchman.
        if  (GetLocalInt(OBJECT_SELF, "X0_L_SAWTHISTRAPALREADY" + sID) != 10)
        {
            string sSpeak = GetStringByStrRef(40551);
            SendMessageToPC(GetMaster(), sSpeak);
            SetLocalInt(OBJECT_SELF, "X0_L_SAWTHISTRAPALREADY" + sID, 10);
        }
        if (GetObjectType(oTrap) != OBJECT_TYPE_TRIGGER)
        {
            // * because Henchmen are not allowed to switch weapons without the player's
            // * say this needs to be removed
            // it's an object we can destroy ranged
            // ActionEquipMostDamagingRanged(oTrap);
            ActionAttack(oTrap);
            SetLocalObject(OBJECT_SELF, "NW_GENERIC_DOOR_TO_BASH", oTrap);
            return TRUE;
        }

        // Throw ourselves on it nobly! :-)
        vector vPos = GetPosition(OBJECT_SELF);
        vector vTrap = GetPosition(oTrap);
        vector vDis = vTrap-vPos;
        vDis *= (VectorMagnitude(vDis) + 1.0)/ VectorMagnitude(vDis);
        ActionMoveToLocation(Location(GetArea(oTrap), GetPosition(oTrap) + vDis, VectorToAngle(vDis)));
        ActionMoveToObject(GetMaster());
        return TRUE;
    }
    else if (nSkill > 0)
    {

        // * BK Feb 6 2003
        // * Put a check in so that when a henchmen who cannot disarm a trap
        // * sees a trap they do not repeat their voiceover forever
        if  (GetLocalInt(OBJECT_SELF, "X0_L_SAWTHISTRAPALREADY" + sID) != 10)
        {
            VoiceCannotDo();
            SetLocalInt(OBJECT_SELF, "X0_L_SAWTHISTRAPALREADY" + sID, 10);
           string sSpeak = GetStringByStrRef(40551);
           SendMessageToPC(GetMaster(), sSpeak);
        }

        return FALSE;
    }

    return FALSE;
}
//* attempts to cast knock to open the door
int AttemptKnockSpell(object oLocked)
{
    // If that didn't work, let's try using a knock spell
    if (GetHasSpell(SPELL_KNOCK)
        && (GetIsDoorActionPossible(oLocked,
                                    DOOR_ACTION_KNOCK)
            || GetIsPlaceableObjectActionPossible(oLocked,
                                                  PLACEABLE_ACTION_KNOCK)))
    {
        if (!GetIsDoorInLineOfSight(oLocked))
        {
            // For whatever reason, GetObjectSeen doesn't return seen doors.
            //if (GetObjectSeen(oLocked))
            if (LineOfSightObject(OBJECT_SELF, oLocked))
            {
                //ClearActions(CLEAR_X0_INC_HENAI_AttemptToOpenLock2);
                ClearAllActions();
                VoiceCanDo();
                ActionWait(1.0);
                ActionCastSpellAtObject(SPELL_KNOCK, oLocked);
                ActionWait(1.0);
                return TRUE;
            }
        }

    }
    return FALSE;
}

int AttemptToOpenLock(object oLocked)
{

    // * September 2003
    // * if door is set to not be something
    // * henchmen should bash open  (like mind flayer beds)
    // * then ignore it.
    if (GetLocalInt(oLocked, "X2_L_BASH_FALSE") == 1)
    {
        return FALSE;
    }
    int bNeedKey = FALSE;
    int bInLineOfSight = TRUE;

    if (GetLockKeyRequired(oLocked))
    {
        bNeedKey = TRUE ;
    }

    // * October 17 2003 - BK - Decided that line of sight for doors is not relevant
    // * was causing too many errors.
    //if (bkGetIsInLineOfSight(oLocked) == FALSE)
    //{
    //    bInLineOfSight = TRUE;
   // }
    if ( !GetIsObjectValid(oLocked)
         || bNeedKey
         || !bInLineOfSight)
         //|| GetObjectSeen(oLocked) == FALSE) This check doesn't work.
         {
        // Can't open this, so skip the checks
        //MyPrintString("Failed basic check");
        VoiceCannotDo();
        return FALSE;
    }

    // We might be able to open this

    int bCanDo = FALSE;

    // First, let's see if we notice that it's trapped
    if (GetIsTrapped(oLocked) && GetTrapDetectedBy(oLocked, OBJECT_SELF))
    {
        // Ick! Try and disarm the trap first
        //MyPrintString("Trap on it to disarm");
        if (! AttemptToDisarmTrap(oLocked))
        {
            // * Feb 11 2003. Attempt to cast knock because its
            // * always safe to cast it, even on a trapped object
            if (AttemptKnockSpell(oLocked))
            {
                return TRUE;
            }
            //VoicePicklock();
            VoiceNo();
            return FALSE;
        }
    }

    // Now, let's try and pick the lock first
    int nSkill = GetSkillRank(SKILL_OPEN_LOCK);
    if (nSkill > 0) {
        nSkill += GetAbilityModifier(ABILITY_DEXTERITY);
        nSkill += 20;
    }

    if (nSkill > GetLockUnlockDC(oLocked)
        &&
        (GetIsDoorActionPossible(oLocked,
                                 DOOR_ACTION_UNLOCK)
         || GetIsPlaceableObjectActionPossible(oLocked,
                                               PLACEABLE_ACTION_UNLOCK))) {
        //ClearActions(CLEAR_X0_INC_HENAI_AttemptToOpenLock1);
        ClearAllActions();
        VoiceCanDo();
        ActionWait(1.0);
        ActionUseSkill(SKILL_OPEN_LOCK,oLocked);
        ActionWait(1.0);
        bCanDo = TRUE;
    }

    if (!bCanDo)
        bCanDo = AttemptKnockSpell(oLocked);


    if (!bCanDo
        //&& GetAbilityScore(OBJECT_SELF, ABILITY_STRENGTH) >= 16 Removed since you now have control over their bashing via dialog
        && !GetPlotFlag(oLocked)
        && (GetIsDoorActionPossible(oLocked,
                                    DOOR_ACTION_BASH)
            || GetIsPlaceableObjectActionPossible(oLocked,
                                                  PLACEABLE_ACTION_BASH))) {
        //ClearActions(CLEAR_X0_INC_HENAI_AttemptToOpenLock3);
        ClearAllActions();
        VoiceCanDo();
        ActionWait(1.0);

        // MODIFIED February 2003
        // Since the player has direct control over weapon, automatic equipping is frustrating.
        // removed.
        //        ActionEquipMostDamagingMelee(oLocked);
        ActionAttack(oLocked);
        SetLocalObject(OBJECT_SELF, "NW_GENERIC_DOOR_TO_BASH", oLocked);
        bCanDo = TRUE;
    }

    if (!bCanDo && !GetPlotFlag(oLocked) && GetHasSpell(SPELL_MAGIC_MISSILE))
    {
        //ClearActions(CLEAR_X0_INC_HENAI_AttemptToOpenLock3);
        ClearAllActions();
        ActionCastSpellAtObject(SPELL_MAGIC_MISSILE,oLocked);
        return TRUE;
    }

    // If we did it, let the player know
    if(!bCanDo) {
        VoiceCannotDo();
    } else {
        ActionDoCommand(VoiceTaskComplete());
        return TRUE;
    }

    return FALSE;
}

// Gets the closest locked object to the master.
object GetLockedObject(object oMaster);
object GetLockedObject(object oMaster)
{
    int nCnt = 1;
    object oLastObject = GetNearestObjectToLocation(OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, GetLocation(oMaster), nCnt);
    while (GetIsObjectValid(oLastObject))
    {
        //COMMENT THIS BACK IN WHEN DOOR ACTION WORKS ON PLACABLE.
        //object oItem = GetFirstItemInInventory(oLastObject);
        if(GetLocked(oLastObject))
        {
            return oLastObject;
        }
        if(++nCnt >= 10)
        {
            break;
        }
        oLastObject = GetNearestObjectToLocation(OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, GetLocation(oMaster), nCnt);
    }
    return OBJECT_INVALID;
}

// Makes the caller attempt to open the master's closest locked object.
int ManualPickNearestLock();
int ManualPickNearestLock()
{
    object oLastObject = GetLockedObject(GetMaster());

    //MyPrintString("Attempting to unlock: " + GetTag(oLastObject));
    return AttemptToOpenLock(oLastObject);
}


// Responds  to it (like makinging the callers attacker thier target)
// Called in OnConversation, and thats it. Use "ShouterFriend" To stop repeated GetIsFriend calls.
void RespondToShout(object oShouter, int nShoutIndex);
// Gets any possible target which is attacking oShouter (and isn't an ally)
// or who oShouter is attacking. oShouter should be a ally.
object GetIntruderFromShout(object oShouter);

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
//int PerceptionFleeFrom(object oEnemy);

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
    object oIntruder, oTarget;

    object oMaster = GetMaster();

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
            // morale stuff removed - pok

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
// HENCHMAN related shouts
    // * toggle search mode for henchmen
    case ASSOCIATE_COMMAND_TOGGLESEARCH:
    {
        if (GetActionMode(OBJECT_SELF, ACTION_MODE_DETECT))
        {
            SetActionMode(OBJECT_SELF, ACTION_MODE_DETECT, FALSE);
        }
        else
        {
            SetActionMode(OBJECT_SELF, ACTION_MODE_DETECT, TRUE);
        }
        break;
    }
    // * toggle stealth mode for henchmen
    case ASSOCIATE_COMMAND_TOGGLESTEALTH:
    {
        //SpeakString(" toggle stealth");
        if (GetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH))
        {
            SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, FALSE);
        }
        else
        {
            SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, TRUE);
        }
        break;
    }
    // * June 2003: Stop spellcasting
    case ASSOCIATE_COMMAND_TOGGLECASTING:
    {
        if (GetLocalInt(OBJECT_SELF, "X2_L_STOPCASTING") == 10)
        {
           // SpeakString("Was in no casting mode. Switching to cast mode");
            SetLocalInt(OBJECT_SELF, "X2_L_STOPCASTING", 0);
            VoiceCanDo();
        }
        else
        if (GetLocalInt(OBJECT_SELF, "X2_L_STOPCASTING") == 0)
        {
         //   SpeakString("Was in casting mode. Switching to NO cast mode");
            SetLocalInt(OBJECT_SELF, "X2_L_STOPCASTING", 10);
            VoiceCanDo();
        }
      break;
    }
    case ASSOCIATE_COMMAND_INVENTORY:
    // no inventory
          SendMessageToPCByStrRef(GetMaster(), 100895);
        break;

    case ASSOCIATE_COMMAND_PICKLOCK:
        ManualPickNearestLock();
        break;

    case ASSOCIATE_COMMAND_DISARMTRAP: // Disarm trap
        oTarget = GetNearestTrapToObject(oMaster);
        //1.71: if the nearest trap the master cannot be disarmed, try disarm nearest trap from self
        if(!GetIsObjectValid(oTarget) || !GetIsTrapped(oTarget) || !GetTrapDetectedBy(oTarget, OBJECT_SELF) || GetDistanceToObject(oTarget) > 15.0 || !GetIsInLineOfSight(oTarget))
        {
            oTarget = GetNearestTrapToObject();
            if(!GetIsObjectValid(oTarget) || !GetIsTrapped(oTarget))
            {
                VoiceCannotDo();
                break;
            }
        }
        AttemptToDisarmTrap(oTarget, TRUE);
        break;

    case ASSOCIATE_COMMAND_ATTACKNEAREST:
        ResetHenchmenState();
        DeleteLocalInt(OBJECT_SELF, "guard");
        DeleteLocalInt(OBJECT_SELF, "stand_ground");
        ExecuteScript("hen_detercombat");
        //DetermineCombatRound();

        // * bonus feature. If master is attacking a door or container, issues VWE Attack Nearest
        // * will make henchman join in on the fun
        oTarget = GetAttackTarget(GetMaster());
        if (GetIsObjectValid(oTarget))
        {
            if (GetObjectType(oTarget) == OBJECT_TYPE_PLACEABLE || GetObjectType(oTarget) == OBJECT_TYPE_DOOR)
            {
                ActionAttack(oTarget);
            }
        }
        break;

    case ASSOCIATE_COMMAND_FOLLOWMASTER:
        ResetHenchmenState();
        DeleteLocalInt(OBJECT_SELF, "stand_ground");
        DelayCommand(2.5, VoiceCanDo());

        //UseStealthMode();
        //UseDetectMode();
        SetAIObject(AI_FLEE_TO, oMaster);
        ActionForceFollowObject(oMaster, 2.0);
        SetLocalInt(OBJECT_SELF, "busy", 1);
        DelayCommand(5.0, DeleteLocalInt(OBJECT_SELF, "busy"));
        break;

    case ASSOCIATE_COMMAND_GUARDMASTER:
    {
        ResetHenchmenState();
        //DelayCommand(2.5, VoiceCannotDo());

        //Companions will only attack the Masters Last Attacker
        SetLocalInt(OBJECT_SELF, "guard", 1);
        DeleteLocalInt(OBJECT_SELF, "stand_ground");
        object oLastAttacker = GetLastHostileActor(GetMaster());
        // * for some reason this is too often invalid. still the routine
        // * works corrrectly
        SetLocalInt(OBJECT_SELF, "X0_BATTLEJOINEDMASTER", TRUE);
        //HenchmenCombatRound(oLastAttacker);
        DetermineCombatRound();
        break;
    }
    case ASSOCIATE_COMMAND_HEALMASTER:
        //Ignore current healing settings and heal me now

        ResetHenchmenState();
        oMaster = GetMaster();

        if(GetIsDead(oMaster))//1.71: taught henchman to resurrect his master
        {
            if(GetHasSpell(SPELL_RESURRECTION))
            {
                ActionCastSpellAtObject(SPELL_RESURRECTION, oMaster);
                DelayCommand(2.0, VoiceCanDo());
                break;
            }
            else if(GetHasSpell(SPELL_RAISE_DEAD))
            {
                ActionCastSpellAtObject(SPELL_RAISE_DEAD, oMaster);
                DelayCommand(2.0, VoiceCanDo());
                break;
            }
            int nRnd;
            talent tUse = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_CONDITIONAL_SINGLE,0);
            while(GetIsTalentValid(tUse) && nRnd++ < 10)
            {
                if(GetTypeFromTalent(tUse) == TALENT_TYPE_SPELL && (GetIdFromTalent(tUse) == SPELL_RESURRECTION || GetIdFromTalent(tUse) == SPELL_RAISE_DEAD))
                {
                    ClearAllActions();
                    ActionUseTalentOnObject(tUse,oMaster);
                    DelayCommand(2.0, VoiceCanDo());
                    return;
                }
                tUse = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_CONDITIONAL_SINGLE,0);
            }
            VoiceCannotDo();
            return;
        }

        //SetCommandable(TRUE);
        // TODO: use AI_ActionHealUndeadObject for undead healing
        /*
        if(AI_ActionHealObject(oMaster))
        {
            DelayCommand(2.0, VoiceCanDo());
            return;
        }
        */
        VoiceCannotDo();
        break;

    case ASSOCIATE_COMMAND_MASTERFAILEDLOCKPICK:
        //Check local for re-try locked doors
        if(GetLocalInt(OBJECT_SELF, "stand_ground") == 0)
        {
            oTarget = GetLockedObject(oMaster);
            AttemptToOpenLock(oTarget);
        }
        break;


    case ASSOCIATE_COMMAND_STANDGROUND:
        //No longer follow the master or guard him
        SetLocalInt(OBJECT_SELF, "stand_ground", 1);
        DeleteLocalInt(OBJECT_SELF, "guard");
        DelayCommand(2.0, VoiceCanDo());
        ActionAttack(OBJECT_INVALID);
        //ClearActions(CLEAR_X0_INC_HENAI_RespondToShout1);
        ClearAllActions(TRUE);
        break;



        // ***********************************
        // * AUTOMATIC SHOUTS - not player
        // *   initiated
        // ***********************************
    case ASSOCIATE_COMMAND_MASTERSAWTRAP:
        if(!GetIsInCombat())
        {
            if(GetLocalInt(OBJECT_SELF, "stand_ground") == 0)
            {
                oTarget = GetLastTrapDetected(oMaster);
                AttemptToDisarmTrap(oTarget);
            }
        }
        break;

    case ASSOCIATE_COMMAND_MASTERUNDERATTACK:
        // Just go to henchman combat round
        //SpeakString("here 728");

        // * July 15, 2003: Make this only happen if not
        // * in combat, otherwise the henchman will
        // * ping pong between targets
        if (!GetIsInCombat(OBJECT_SELF))
            //HenchmenCombatRound();
            DetermineCombatRound();
        break;

    case ASSOCIATE_COMMAND_MASTERATTACKEDOTHER:

        if(GetLocalInt(OBJECT_SELF, "stand_ground") == 0)
        {
            if(GetLocalInt(OBJECT_SELF, "guard") == 0)
            {
                if(!GetIsInCombat(OBJECT_SELF))
                {
                    //SpeakString("here 737");
                    object oAttack = GetAttackTarget(GetMaster());
                    // April 2003: If my master can see the enemy, then I can too.
                    if(GetIsObjectValid(oAttack) && GetObjectSeen(oAttack, GetMaster()))
                    {
                        //ClearActions(CLEAR_X0_INC_HENAI_RespondToShout2); //1.71: fix for associates casting spell over and over
                        //HenchmenCombatRound(oAttack);
                        DetermineCombatRound();
                    }
                }
            }
        }
        break;

    case ASSOCIATE_COMMAND_MASTERGOINGTOBEATTACKED:
        if(GetLocalInt(OBJECT_SELF, "stand_ground") == 0)
        {
            if(!GetIsInCombat(OBJECT_SELF))
            {   // SpeakString("here 753");
                object oAttacker = GetGoingToBeAttackedBy(GetMaster());
                // April 2003: If my master can see the enemy, then I can too.
                // Potential Side effect : Henchmen may run
                // to stupid places, trying to get an enemy
                if(GetIsObjectValid(oAttacker) && GetObjectSeen(oAttacker, GetMaster()))
                {
                   // SpeakString("Defending Master");
                    //ClearActions(CLEAR_X0_INC_HENAI_RespondToShout3); //1.71: fix for associates casting spell over and over
                    ActionMoveToObject(oAttacker, TRUE, 7.0);
                    //HenchmenCombatRound(oAttacker);
                    DetermineCombatRound();

                }
            }
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

// morale stuff removed - pok

// This MIGHT move to oEnemy
// - Checks special actions, such as fleeing, and may run instead!
void ActionMoveToEnemy(object oEnemy)
{
    // Make sure that we are not fleeing badly (-1 morale from all enemies)
    /*
    if(GetIsEnemy(oEnemy))
    {
        // -1 morale, flee
        if(PerceptionFleeFrom(oEnemy)) return;
    }
    */
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

// morale stuff removed

// This wrappers commonly used code for a "Call to arms" type response.
// * We know of no enemy, so we will move to oAlly, who either called to
//   us, or, well, we know of.
// * Calls out AI_SHOUT_CALL_TO_ARMS too.
void CallToArmsResponse(object oAlly)
{
    // Shout to allies to attack, or be prepared.
    //AISpeakString(AI_SHOUT_CALL_TO_ARMS);
    // this is commented out so it won't chain others nearby - pok

    // If we are over 20 (pok) meters away from oShouter, we move to them using
    // the special action
    if(GetDistanceToObject(oAlly) > 20.0 || !GetObjectSeen(oAlly))
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
        // this doesn't get interrupted! make DCR now - pok
        if (GetIsObjectValid(oIntruder) && !GetIsDead(oIntruder))
        {
            // Determine it anyway - we will search around oShouter
            // if nothing is found...but we are near to the shouter
            DetermineCombatRound(oAlly);
            return;
        }
        /*
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
            //ActionMoveToLocation(lTarget, TRUE);
            // move to master's location - pok
            ActionMoveToLocation(GetLocation(oMaster), TRUE);
            // When we see someone fighting, we'll DCR
            return;
        }
        */
        // If we are over 2 meters away from oShouter, we move to them using
        // the special action
        // actually lets make it so that if we are about 20m away
        else if(GetDistanceToObject(oAlly) > 20.0 || !GetObjectSeen(oAlly))
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
    }
}




// Debug: To compile this script full, uncomment all of the below.
/* - Add two "/"'s at the start of this line
void main()
{
    return;
}
//*/


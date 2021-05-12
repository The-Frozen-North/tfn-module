/*

    Henchman Inventory And Battle AI

    This file contains functions used in the default On* scripts
    for combat. It acts as filter preventing the main hench_o0_ai
    from being called more than it needs to. (Usually only to start
    combat, heartbeat, or end combat round.)

*/

#include "inc_hai_melee"
#include "inc_hai_generic"


// void main() {    }


// Sets the location of an unheard or unseen enemy
// Either moved out of range or did attack while not detected
void SetEnemyLocation(object oEnemy);

// Clears the last unheard, unseen enemy location
void ClearEnemyLocation();

// Moves to the last perceived enemy location
void MoveToLastSeenOrHeard(int bDoSearch = TRUE);

// New determinecombatround call. Determines if call should cause
// main AI script to run
void HenchDetermineCombatRound(object oIntruder = OBJECT_INVALID, int bForceInterrupt = FALSE);

// Simplified combat start, used by commoners
void HenchStartAttack(object oIntruder);

// modified TalentFlee routine
int HenchTalentFlee(object oIntruder = OBJECT_INVALID);

// modified GetNearestSeenOrHeardEnemy to not get dead creatures
object GetNearestSeenOrHeardEnemyNotDead(int bCheckIsPC = FALSE);

// modified DetermineSpecialBehavior, calls HenchDetermineCombatRound instead
void HenchDetermineSpecialBehavior(object oIntruder = OBJECT_INVALID);

// used to attack non creature items (placeables and doors)
void HenchAttackObject(object oTarget);

// associate (henchman, etc.) determines if enemy is perceived or not
int HenchGetIsEnemyPerceived();

// modified TalentAdvancedBuff routine
int HenchTalentAdvancedBuff(float fDistance);

// get nearest ally that is higher in hit dice
object GetNearestTougherFriend(object oSelf, object oPC);

// main stealth and wandering code
int DoStealthAndWander();

// checks if stealth should be removed because you or nearby friend has been detected
void CheckRemoveStealth();

// code for bashing placeables
int HenchBashDoorCheck(int bPolymorphed);


const int HENCH_AI_SCRIPT_NOT_RUN       = 0;
const int HENCH_AI_SCRIPT_IN_PROGRESS   = 1;
const int HENCH_AI_SCRIPT_ALREADY_RUN   = 2;

const string HENCH_AI_SCRIPT_RUN_STATE      =  "AIIntruder";
const string HENCH_AI_SCRIPT_FORCE          =  "AIIntruderForce";
const string HENCH_AI_SCRIPT_INTRUDER_OBJ   =  "AIIntruderObj";

const string sHenchLastHeardOrSeen          = "LastSeenOrHeard";


void SetEnemyLocation(object oEnemy)
{
    SetLocalInt(OBJECT_SELF, sHenchLastHeardOrSeen, TRUE);

    location enemyLocation = GetLocation(oEnemy);
    SetLocalLocation(OBJECT_SELF, sHenchLastHeardOrSeen, enemyLocation);

    // Get the area, position and facing
    object   oArea       = GetAreaFromLocation (enemyLocation);
    vector   vPosition   = GetPositionFromLocation (enemyLocation);
    float    fFacing     = GetFacingFromLocation (enemyLocation);

    vPosition.z += 100.0;

    // Build a new location, which faces in the opposite direction
    enemyLocation = Location (oArea, vPosition, fFacing);
    // make sure old position is gone
    object oInvisTarget = GetLocalObject(OBJECT_SELF, sHenchLastHeardOrSeen);
    if (GetIsObjectValid(oInvisTarget))
    {
        DestroyObject(oInvisTarget);
        DeleteLocalObject(OBJECT_SELF, sHenchLastHeardOrSeen);
    }

    oInvisTarget = CreateObject(OBJECT_TYPE_PLACEABLE, "plc_invisobj", enemyLocation);
    SetLocalObject(OBJECT_SELF, sHenchLastHeardOrSeen, oInvisTarget);
}


void ClearEnemyLocation()
{
    DeleteLocalInt(OBJECT_SELF, sHenchLastHeardOrSeen);
    DeleteLocalLocation(OBJECT_SELF, sHenchLastHeardOrSeen);

    object oInvisTarget = GetLocalObject(OBJECT_SELF, sHenchLastHeardOrSeen);
    if (GetIsObjectValid(oInvisTarget))
    {
        DestroyObject(oInvisTarget);
        DeleteLocalObject(OBJECT_SELF, sHenchLastHeardOrSeen);
    }
}


void MoveToLastSeenOrHeard(int bDoSearch = TRUE)
{
    location moveToLoc = GetLocalLocation(OBJECT_SELF, sHenchLastHeardOrSeen);
    if (GetDistanceBetweenLocations(GetLocation(OBJECT_SELF), moveToLoc) <= 5.0)
    {
        ClearEnemyLocation();
        // go to search
        // TODO add spells to help search
        DeleteLocalInt(OBJECT_SELF, HENCH_AI_SCRIPT_RUN_STATE);
        if (bDoSearch)
        {
            // search around for awhile
            ActionDoCommand(SetActionMode(OBJECT_SELF, ACTION_MODE_DETECT, TRUE));
            ActionRandomWalk();
            DelayCommand(10.0, HenchDetermineCombatRound());
        }
    }
    else
    {
        object oInvisTarget = GetLocalObject(OBJECT_SELF, sHenchLastHeardOrSeen);
        ActionMoveToObject(oInvisTarget, TRUE);
    }
}

//GetIsObjectValid(oTarget) && GetIsEnemy(oTarget) && GetArea(oTarget) == OBJECT_SELF && !GetIsDead(oTarget) && GetDistanceToObject(oTarget) <= 50.0
int GetIsValidTarget(object oTarget);
int GetIsValidTarget(object oTarget)
{
    if (GetIsObjectValid(oTarget) && GetIsEnemy(oTarget) && GetArea(oTarget) == OBJECT_SELF && !GetIsDead(oTarget) && GetDistanceToObject(oTarget) <= 50.0)
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

// pok - new function to retrieve a target from either the master,
// or from a party member in the master's faction (party)
// we will match it to the closest target
object GetClosestPartyTarget();
object GetClosestPartyTarget()
{
    object oMaster = GetMaster();


// no master? assume it's not in a party so no target
    if (!GetIsObjectValid(oMaster))
        return OBJECT_INVALID;

    object oTarget = GetAttackTarget(oMaster);

    object oPartyTargetPC, oPartyTargetNPC;
    float fDistance = 1000.0;
    float fTargetDistance;

// use last hostile actor as fallback
    if (!GetIsValidTarget(oTarget))
        oTarget = GetLastHostileActor(oMaster);

    if (GetIsValidTarget(oTarget))
        fDistance = GetDistanceToObject(oTarget);

    // loop PCs in party

    object oPartyPC = GetFirstFactionMember(oMaster);
    while (GetIsObjectValid(oPartyPC))
    {
        oPartyTargetPC = GetAttackTarget(oPartyPC);
        fTargetDistance = GetDistanceToObject(oPartyTargetPC);

        if (!GetIsValidTarget(oPartyTargetPC))
            oPartyTargetPC = GetLastHostileActor(oPartyPC);

        if (GetIsValidTarget(oPartyTargetPC) && fTargetDistance < fDistance)
        {
            fDistance = fTargetDistance;
            oTarget = oPartyTargetPC;
        }

        oPartyPC = GetNextFactionMember(oMaster);
    }

// loop NPCs
    object oPartyNPC = GetFirstFactionMember(oMaster, FALSE);
    while (GetIsObjectValid(oPartyNPC))
    {
        oPartyTargetNPC = GetAttackTarget(oPartyNPC);

        if (!GetIsValidTarget(oPartyTargetNPC))
            oPartyTargetNPC = GetLastHostileActor(oPartyNPC);

        fTargetDistance = GetDistanceToObject(oPartyTargetNPC);

        if (GetIsValidTarget(oPartyTargetNPC) && fTargetDistance < fDistance)
        {
            fDistance = fTargetDistance;
            oTarget = oPartyTargetNPC;
        }

        oPartyNPC = GetNextFactionMember(oMaster, FALSE);
    }

    return oTarget;
}

void HenchDetermineCombatRound(object oIntruder = OBJECT_INVALID, int bForceInterrupt = FALSE)
{
//    Jug_Debug(GetName(OBJECT_SELF) + " det com round called with " + GetName(oIntruder) + " force = " + IntToString(bForceInterrupt));

    if(GetAssociateState(NW_ASC_IS_BUSY))
    {
        return;
    }

    //string sAIScript = GetLocalString(OBJECT_SELF, "AIScript");
   // if (sAIScript == "")
    //{
      string sAIScript = "hen_ai";
    //}

    if (!GetIsValidTarget(oIntruder))
        oIntruder = GetClosestPartyTarget();

    SetLocalObject(OBJECT_SELF, HENCH_AI_SCRIPT_INTRUDER_OBJ, oIntruder);
    SetLocalInt(OBJECT_SELF, HENCH_AI_SCRIPT_FORCE, bForceInterrupt);

    if (bForceInterrupt)
    {
        SetLocalInt(OBJECT_SELF, HENCH_AI_SCRIPT_RUN_STATE, HENCH_AI_SCRIPT_IN_PROGRESS);
        ExecuteScript(sAIScript, OBJECT_SELF);
        return;
    }

    // check if we have to actually determine to rerun ai
    int iAIIntruderLevel = GetLocalInt(OBJECT_SELF, HENCH_AI_SCRIPT_RUN_STATE);

    if (iAIIntruderLevel == HENCH_AI_SCRIPT_NOT_RUN)
    {
        // first run of HenchDetermineCombatRound
        SetLocalInt(OBJECT_SELF, HENCH_AI_SCRIPT_RUN_STATE, HENCH_AI_SCRIPT_IN_PROGRESS);
        ExecuteScript(sAIScript, OBJECT_SELF);
        return;
    }
    object oLastTarget = GetLocalObject(OBJECT_SELF, sHenchLastTarget);

    if(!GetIsObjectValid(oLastTarget) || GetIsDead(oLastTarget) || !GetIsEnemy(oLastTarget) || GetLocalInt(oLastTarget, sHenchRunningAway))
    {
        oLastTarget = OBJECT_INVALID;
    }
    else if (!GetObjectSeen(oLastTarget) && !GetObjectHeard(oLastTarget))
    {
        oLastTarget = OBJECT_INVALID;
    }
    if (!GetIsObjectValid(oLastTarget))
    {
        // prevent too many calls to main script if already moving to an unseen and
        // unheard monster
        if (!GetLocalInt(OBJECT_SELF, sHenchLastHeardOrSeen) || GetObjectSeen(oIntruder) || GetObjectHeard(oIntruder))
        {
            ExecuteScript(sAIScript, OBJECT_SELF);
        }
    }
    else if (GetIsObjectValid(oIntruder))
    {
        if (GetDistanceToObject(oIntruder) <= 5.0 && GetDistanceToObject(oLastTarget) > 5.0)
        {
            ExecuteScript(sAIScript, OBJECT_SELF);
        }
        else if (GetObjectSeen(oIntruder) && !GetObjectSeen(oLastTarget))
        {
            ExecuteScript(sAIScript, OBJECT_SELF);
        }
    }
}


void HenchStartAttack(object oIntruder)
{
    SetLocalObject(OBJECT_SELF, HENCH_AI_SCRIPT_INTRUDER_OBJ, oIntruder);
    ExecuteScript("hen_attack", OBJECT_SELF);
}


// FLEE COMBAT AND HOSTILES
int HenchTalentFlee(object oIntruder = OBJECT_INVALID)
{
    object oTarget = oIntruder;
    if(!GetIsObjectValid(oIntruder))
    {
        oTarget = GetLastHostileActor();
        if(!GetIsObjectValid(oTarget) || GetIsDead(oTarget))
        {
            oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
            float fDist = GetDistanceBetween(OBJECT_SELF, oTarget);
            if(!GetIsObjectValid(oTarget))
            {
                return FALSE;
            }
        }
    }
    ClearAllActions();
    //Look at this to remove the delay
    ActionMoveAwayFromObject(oTarget, TRUE, 10.0f);
    DelayCommand(4.0, ClearAllActions());
    return TRUE;
}


object GetNearestSeenOrHeardEnemyNotDead(int bCheckIsPC = FALSE)
{
    int curCount = 1;
    object oTarget;
    while (1)
    {
        oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, curCount, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
        if (!GetIsObjectValid(oTarget))
        {
            break;
        }
        if (!GetPlotFlag(oTarget))
        {
            return oTarget;
        }
        curCount ++;
    }
    curCount = 1;
    while (1)
    {
        oTarget = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, curCount, CREATURE_TYPE_PERCEPTION, PERCEPTION_HEARD_AND_NOT_SEEN, CREATURE_TYPE_IS_ALIVE, TRUE);
        if (!GetIsObjectValid(oTarget))
        {
            return OBJECT_INVALID;
        }
        if (!GetPlotFlag(oTarget) && !(bCheckIsPC && GetIsPC(GetTopMaster(oTarget))))
        {
            return oTarget;
        }
        curCount++;
    }
    return OBJECT_INVALID;
}


//::///////////////////////////////////////////////
//:: Determine Special Behavior
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Determines the special behavior used by the NPC.
    Generally all NPCs who you want to behave differently
    than the default behavior.
    For these behaviors, passing in a valid object will
    cause the creature to become hostile the the attacker.

    MODIFIED February 7 2003:
    - Rearranged logic order a little so that the creatures
    will actually randomwalk when not fighting

    - Modified by Tony K to call HenchDetermineCombatRound

    - Modified by LoCash (Jan 12-Mar 06 2004):
      BW's original function was completely broken, it needed
      to be re-written. original code by "fendis_khan".
      many enhancements made. herbivores now work
      "out of the box" as they should, omnivores need faction
      changed to a non-Hostile. Check "Animals" in the Toolset's
      Monster palette for various examples of creatures using
      omnivore, herbivore spawn scripts.

*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Dec 14, 2001
//:://////////////////////////////////////////////

void HenchDetermineSpecialBehavior(object oIntruder = OBJECT_INVALID)
{
    object oTarget = GetNearestCreature(CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, OBJECT_SELF, 1,
                                        CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);

    // Omnivore behavior routine
    if(GetBehaviorState(NW_FLAG_BEHAVIOR_OMNIVORE))
    {
        // no current attacker and not currently in combat
        if(!GetIsObjectValid(oIntruder) && !GetIsInCombat())
        {
            // does not have a current target
            if(!GetIsObjectValid(GetAttemptedAttackTarget()) &&
               !GetIsObjectValid(GetAttemptedSpellTarget()) &&
               !GetIsObjectValid(GetAttackTarget()))
            {
                // enemy creature nearby
                if(GetIsObjectValid(oTarget) && GetDistanceToObject(oTarget) <= 13.0)
                {
                    ClearAllActions();
                    HenchDetermineCombatRound(oTarget);
                    return;
                }
                int nTarget = 1;
                oTarget = GetNearestCreature(CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, OBJECT_SELF, nTarget,
                                             CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_NEUTRAL);

                // neutral creature, too close
                while(GetIsObjectValid(oTarget) && GetDistanceToObject(oTarget) <= 7.0)
                {
                    if(GetLevelByClass(CLASS_TYPE_DRUID, oTarget) == 0 && GetLevelByClass(CLASS_TYPE_RANGER, oTarget) == 0 && GetAssociateType(oTarget) != ASSOCIATE_TYPE_ANIMALCOMPANION)
                    {
                        // oTarget has neutral reputation, and is NOT a druid or ranger or an "Animal Companion"
                        SetLocalInt(OBJECT_SELF, "lcTempEnemy", 8);
                        SetIsTemporaryEnemy(oTarget);
                        ClearAllActions();
                        HenchDetermineCombatRound(oTarget);
                        return;
                    }
                    oTarget = GetNearestCreature(CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, OBJECT_SELF, ++nTarget,
                                                 CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_NEUTRAL);
                }

                // non friend creature, too close
                nTarget = 1;
                oTarget = GetNearestCreature(CREATURE_TYPE_PERCEPTION, PERCEPTION_HEARD_AND_NOT_SEEN, OBJECT_SELF, nTarget);

                // heard neutral or enemy creature, too close
                while(GetIsObjectValid(oTarget) && GetDistanceToObject(oTarget) <= 7.0)
                {
                    if(!GetIsFriend(oTarget) && GetLevelByClass(CLASS_TYPE_DRUID, oTarget) == 0 && GetLevelByClass(CLASS_TYPE_RANGER, oTarget) == 0 && GetAssociateType(oTarget) != ASSOCIATE_TYPE_ANIMALCOMPANION)
                    {
                        // oTarget has neutral reputation, and is NOT a druid or ranger or an "Animal Companion"
                        SetLocalInt(OBJECT_SELF, "lcTempEnemy", 8);
                        SetIsTemporaryEnemy(oTarget);
                        ClearAllActions();
                        HenchDetermineCombatRound(oTarget);
                        return;
                    }
                    oTarget = GetNearestCreature(CREATURE_TYPE_PERCEPTION, PERCEPTION_HEARD_AND_NOT_SEEN, OBJECT_SELF, ++nTarget);
                }

                if(!IsInConversation(OBJECT_SELF))
                {
                    // 25% chance of just standing around instead of constantly
                    // randWalking; i thought it looked odd seeing the animal(s)
                    // in a constant state of movement, was not realistic,
                    // at least according to my Nat'l Geographic videos
                    if ( (d4() != 1) && (GetCurrentAction() == ACTION_RANDOMWALK) )
                    {
                        return;
                    }
                    else if ( (d4() == 1) && (GetCurrentAction() == ACTION_RANDOMWALK) )
                    {
                        ClearAllActions();
                        return;
                    }
                    else
                    {
                        ClearAllActions();
                        ActionRandomWalk();
                        return;
                    }
                }
            }
        }
        else if(!IsInConversation(OBJECT_SELF)) // enter combat when attacked
        {
            // after a while (20-25 seconds), omnivore (boar) "gives up"
            // chasing someone who didn't hurt it. but if the person fought back
            // this condition won't run and the boar will fight to death
            if(GetLocalInt(OBJECT_SELF, "lcTempEnemy") != FALSE && (GetLastDamager() == OBJECT_INVALID || GetLastDamager() != oTarget) )
            {
                int nPatience = GetLocalInt(OBJECT_SELF, "lcTempEnemy");
                if (nPatience <= 1)
                {
                    ClearAllActions();
                    ClearPersonalReputation(oTarget);  // reset reputation
                    DeleteLocalInt(OBJECT_SELF, "lcTempEnemy");
                    return;
                }
                SetLocalInt(OBJECT_SELF, "lcTempEnemy", --nPatience);
            }
            ClearAllActions();
            HenchDetermineCombatRound(oIntruder);
        }
    }

    // Herbivore behavior routine
    else if(GetBehaviorState(NW_FLAG_BEHAVIOR_HERBIVORE))
    {
        // no current attacker & not currently in combat
        if(!GetIsObjectValid(oIntruder) && (GetIsInCombat() == FALSE))
        {
            if(!GetIsObjectValid(GetAttemptedAttackTarget()) && // does not have a current target
               !GetIsObjectValid(GetAttemptedSpellTarget()) &&
               !GetIsObjectValid(GetAttackTarget()))
            {
                if(GetIsObjectValid(oTarget) && GetDistanceToObject(oTarget) <= 13.0) // enemy creature, too close
                {
                    ClearAllActions();
                    ActionMoveAwayFromObject(oTarget, TRUE, 16.0); // flee from enemy
                    return;
                }
                int nTarget = 1;
                oTarget = GetNearestCreature(CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, OBJECT_SELF, nTarget,
                                             CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_NEUTRAL);
                while(GetIsObjectValid(oTarget) && GetDistanceToObject(oTarget) <= 7.0) // only consider close creatures
                {
                    if(GetLevelByClass(CLASS_TYPE_DRUID, oTarget) == 0 && GetLevelByClass(CLASS_TYPE_RANGER, oTarget) == 0 && GetAssociateType(oTarget) != ASSOCIATE_TYPE_ANIMALCOMPANION)
                    {
                        // oTarget has neutral reputation, and is NOT a druid or ranger or Animal Companion
                        ClearAllActions();
                        ActionMoveAwayFromObject(oTarget, TRUE, 16.0); // run away
                        return;
                    }
                    oTarget = GetNearestCreature(CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, OBJECT_SELF, ++nTarget,
                                                 CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_NEUTRAL);
                }
                nTarget = 1;
                oTarget = GetNearestCreature(CREATURE_TYPE_PERCEPTION, PERCEPTION_HEARD_AND_NOT_SEEN, OBJECT_SELF, nTarget);
                while(GetIsObjectValid(oTarget) && GetDistanceToObject(oTarget) <= 7.0) // only consider close creatures
                {
                    if(!GetIsFriend(oTarget) && GetLevelByClass(CLASS_TYPE_DRUID, oTarget) == 0 && GetLevelByClass(CLASS_TYPE_RANGER, oTarget) == 0 && GetAssociateType(oTarget) != ASSOCIATE_TYPE_ANIMALCOMPANION)
                    {
                        // oTarget has neutral reputation, and is NOT a druid or ranger or Animal Companion
                        ClearAllActions();
                        ActionMoveAwayFromObject(oTarget, TRUE, 16.0); // run away
                        return;
                    }
                    oTarget = GetNearestCreature(CREATURE_TYPE_PERCEPTION, PERCEPTION_HEARD_AND_NOT_SEEN, OBJECT_SELF, ++nTarget);
                }
                if(!IsInConversation(OBJECT_SELF))
                {

                    // 75% chance of randomWalking around, 25% chance of just standing there. more realistic
                    if ( (d4() != 1) && (GetCurrentAction() == ACTION_RANDOMWALK) )
                    {
                        return;
                    }
                    else if ( (d4() == 1) && (GetCurrentAction() == ACTION_RANDOMWALK) )
                    {
                        ClearAllActions();
                        return;
                    }
                    else
                    {
                        ClearAllActions();
                        ActionRandomWalk();
                        return;
                    }
                }
            }
        }
        else if(!IsInConversation(OBJECT_SELF)) // NEW BEHAVIOR - run away when attacked
        {
            ClearAllActions();
            ActionMoveAwayFromLocation(GetLocation(OBJECT_SELF), TRUE, 16.0);
        }
    }
}


void HenchAttackObject(object oTarget)
{
    if (GetWeaponRanged(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND)))
    {
        UseCombatAttack(oTarget);
    }
    else if(GetHasFeat(FEAT_IMPROVED_POWER_ATTACK))
    {
        UseCombatAttack(oTarget, FEAT_IMPROVED_POWER_ATTACK);
    }
    else if(GetHasFeat(FEAT_POWER_ATTACK))
    {
        UseCombatAttack(oTarget, FEAT_POWER_ATTACK);
    }
    else if(GetHasFeat(FEAT_DIRTY_FIGHTING))
    {
        UseCombatAttack(oTarget, FEAT_DIRTY_FIGHTING);
    }
    else
    {
        UseCombatAttack(oTarget);
    }
}


int HenchGetIsEnemyPerceived()
{
    object oClosestSeen = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY,
                    OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN,
                    CREATURE_TYPE_IS_ALIVE, TRUE);

    if (GetIsObjectValid(oClosestSeen))
    {
        return TRUE;
    }
    object oClosestHeard = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY,
                    OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_HEARD_AND_NOT_SEEN,
                    CREATURE_TYPE_IS_ALIVE, TRUE);
    if (GetIsObjectValid(oClosestHeard))
    {
        if (GetDistanceToObject(oClosestHeard) <= fHenchHearingDistance)
        {
            return TRUE;
        }
        object oRealMaster = GetRealMaster();
        if (GetIsObjectValid(oRealMaster))
        {
            if (GetDistanceBetween(oRealMaster, oClosestHeard) <= fHenchMasterHearingDistance)
            {
                return TRUE;
            }
        }
    }
    return FALSE;
}


// FAST BUFF SELF
int HenchTalentAdvancedBuff(float fDistance)
{
    object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, OBJECT_SELF, 1, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);
    if(GetIsObjectValid(oPC) && GetDistanceToObject(oPC) <= fDistance)
    {
        if(!GetIsFighting(OBJECT_SELF))
        {
            ClearAllActions();
            //Combat Protections
            if(GetHasSpell(SPELL_PREMONITION))
            {
                ActionCastSpellAtObject(SPELL_PREMONITION, OBJECT_SELF, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELL_GREATER_STONESKIN))
            {
                ActionCastSpellAtObject(SPELL_GREATER_STONESKIN, OBJECT_SELF, METAMAGIC_NONE, 0, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELL_STONESKIN))
            {
                ActionCastSpellAtObject(SPELL_STONESKIN, OBJECT_SELF, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            //Visage Protections
            if(GetHasSpell(SPELL_SHADOW_SHIELD))
            {
                ActionCastSpellAtObject(SPELL_SHADOW_SHIELD, OBJECT_SELF, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELL_ETHEREAL_VISAGE))
            {
                ActionCastSpellAtObject(SPELL_ETHEREAL_VISAGE, OBJECT_SELF, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELL_GHOSTLY_VISAGE))
            {
                ActionCastSpellAtObject(SPELL_GHOSTLY_VISAGE, OBJECT_SELF, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            //Mantle Protections
            if(GetHasSpell(SPELL_GREATER_SPELL_MANTLE))
            {
                ActionCastSpellAtObject(SPELL_GREATER_SPELL_MANTLE, OBJECT_SELF, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELL_SPELL_MANTLE))
            {
                ActionCastSpellAtObject(SPELL_SPELL_MANTLE, OBJECT_SELF, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELL_LESSER_SPELL_BREACH))
            {
                ActionCastSpellAtObject(SPELL_LESSER_SPELL_BREACH, OBJECT_SELF, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            // Globes
            if(GetHasSpell(SPELL_GLOBE_OF_INVULNERABILITY))
            {
                ActionCastSpellAtObject(SPELL_GLOBE_OF_INVULNERABILITY, OBJECT_SELF, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELL_MINOR_GLOBE_OF_INVULNERABILITY))
            {
                ActionCastSpellAtObject(SPELL_MINOR_GLOBE_OF_INVULNERABILITY, OBJECT_SELF, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }

            //Misc Protections
            if(GetHasSpell(SPELL_ELEMENTAL_SHIELD))
            {
                ActionCastSpellAtObject(SPELL_ELEMENTAL_SHIELD, OBJECT_SELF, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if (GetHasSpell(SPELL_MESTILS_ACID_SHEATH)&& !GetHasSpellEffect(SPELL_MESTILS_ACID_SHEATH))
            {
                ActionCastSpellAtObject(SPELL_MESTILS_ACID_SHEATH, OBJECT_SELF, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if (GetHasSpell(SPELL_DEATH_ARMOR)&& !GetHasSpellEffect(SPELL_DEATH_ARMOR))
            {
                ActionCastSpellAtObject(SPELL_DEATH_ARMOR, OBJECT_SELF, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }

            //Elemental Protections
            if(GetHasSpell(SPELL_PROTECTION_FROM_ELEMENTS))
            {
                ActionCastSpellAtObject(SPELL_PROTECTION_FROM_ELEMENTS, OBJECT_SELF, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELL_RESIST_ELEMENTS))
            {
                ActionCastSpellAtObject(SPELL_RESIST_ELEMENTS, OBJECT_SELF, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELL_ENDURE_ELEMENTS))
            {
                ActionCastSpellAtObject(SPELL_ENDURE_ELEMENTS, OBJECT_SELF, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }

            //Mental Protections
            if(GetHasSpell(SPELL_MIND_BLANK))
            {
                ActionCastSpellAtObject(SPELL_MIND_BLANK, OBJECT_SELF, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELL_LESSER_MIND_BLANK))
            {
                ActionCastSpellAtObject(SPELL_LESSER_MIND_BLANK, OBJECT_SELF, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELL_CLARITY))
            {
                ActionCastSpellAtObject(SPELL_CLARITY, OBJECT_SELF, METAMAGIC_NONE, FALSE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            //Summon Ally
            // TODO add gate!!!!
            if(GetHasSpell(SPELL_BLACK_BLADE_OF_DISASTER))
            {
                ActionCastSpellAtLocation(SPELL_BLACK_BLADE_OF_DISASTER, GetLocation(OBJECT_SELF), METAMAGIC_NONE, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELL_ELEMENTAL_SWARM))
            {
                ActionCastSpellAtLocation(SPELL_ELEMENTAL_SWARM, GetLocation(OBJECT_SELF), METAMAGIC_NONE, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELL_SUMMON_CREATURE_IX))
            {
                ActionCastSpellAtLocation(SPELL_SUMMON_CREATURE_IX, GetLocation(OBJECT_SELF), METAMAGIC_NONE, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELL_CREATE_GREATER_UNDEAD))
            {
                ActionCastSpellAtLocation(SPELL_CREATE_GREATER_UNDEAD, GetLocation(OBJECT_SELF), METAMAGIC_NONE, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELL_GREATER_PLANAR_BINDING))
            {
                ActionCastSpellAtLocation(SPELL_GREATER_PLANAR_BINDING, GetLocation(OBJECT_SELF), METAMAGIC_NONE, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELL_SUMMON_CREATURE_VIII))
            {
                ActionCastSpellAtLocation(SPELL_SUMMON_CREATURE_VIII, GetLocation(OBJECT_SELF), METAMAGIC_NONE, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELL_MORDENKAINENS_SWORD))
            {
                ActionCastSpellAtLocation(SPELL_MORDENKAINENS_SWORD, GetLocation(OBJECT_SELF), METAMAGIC_NONE, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELL_SUMMON_CREATURE_VII))
            {
                ActionCastSpellAtLocation(SPELL_SUMMON_CREATURE_VII, GetLocation(OBJECT_SELF), METAMAGIC_NONE, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELL_CREATE_UNDEAD))
            {
                ActionCastSpellAtLocation(SPELL_CREATE_UNDEAD, GetLocation(OBJECT_SELF), METAMAGIC_NONE, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELL_PLANAR_BINDING))
            {
                ActionCastSpellAtLocation(SPELL_PLANAR_BINDING, GetLocation(OBJECT_SELF), METAMAGIC_NONE, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELL_SUMMON_CREATURE_VI))
            {
                ActionCastSpellAtLocation(SPELL_SUMMON_CREATURE_VI, GetLocation(OBJECT_SELF), METAMAGIC_NONE, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELL_SUMMON_CREATURE_V))
            {
                ActionCastSpellAtLocation(SPELL_SUMMON_CREATURE_V, GetLocation(OBJECT_SELF), METAMAGIC_NONE, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELLABILITY_SUMMON_SLAAD))
            {
                ActionCastSpellAtLocation(SPELLABILITY_SUMMON_SLAAD, GetLocation(OBJECT_SELF), METAMAGIC_NONE, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELLABILITY_SUMMON_TANARRI))
            {
                ActionCastSpellAtLocation(SPELLABILITY_SUMMON_TANARRI, GetLocation(OBJECT_SELF), METAMAGIC_NONE, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELLABILITY_SUMMON_MEPHIT))
            {
                ActionCastSpellAtLocation(SPELLABILITY_SUMMON_MEPHIT, GetLocation(OBJECT_SELF), METAMAGIC_NONE, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELLABILITY_SUMMON_CELESTIAL))
            {
                ActionCastSpellAtLocation(SPELLABILITY_SUMMON_CELESTIAL, GetLocation(OBJECT_SELF), METAMAGIC_NONE, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELL_ANIMATE_DEAD))
            {
                ActionCastSpellAtLocation(SPELL_ANIMATE_DEAD, GetLocation(OBJECT_SELF), METAMAGIC_NONE, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELL_SUMMON_CREATURE_IV))
            {
                ActionCastSpellAtLocation(SPELL_SUMMON_CREATURE_IV, GetLocation(OBJECT_SELF), METAMAGIC_NONE, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELL_SUMMON_CREATURE_III))
            {
                ActionCastSpellAtLocation(SPELL_SUMMON_CREATURE_III, GetLocation(OBJECT_SELF), METAMAGIC_NONE, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELL_SUMMON_CREATURE_II))
            {
                ActionCastSpellAtLocation(SPELL_SUMMON_CREATURE_II, GetLocation(OBJECT_SELF), METAMAGIC_NONE, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            else if(GetHasSpell(SPELL_SUMMON_CREATURE_I))
            {
                ActionCastSpellAtLocation(SPELL_SUMMON_CREATURE_I, GetLocation(OBJECT_SELF), METAMAGIC_NONE, FALSE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            }
            return TRUE;
        }
    }
    return FALSE;
}


object GetNearestTougherFriend(object oSelf, object oPC)
{
    int i = 0;

    object oFriend = oSelf;

    int nEqual = 0;
    int nNear = 0;
    while (GetIsObjectValid(oFriend))
    {
        if (GetDistanceBetween(oSelf, oFriend) < 40.0 && oFriend != oSelf)
        {
            ++nNear;
            if (GetHitDice(oFriend) > GetHitDice(oSelf))
                return oFriend;
            if (GetHitDice(oFriend) == GetHitDice(oSelf))
                ++nEqual;
        }
        ++i;
        oFriend =  GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND,
            oSelf, i);
    }

    SetLocalInt(OBJECT_SELF,"LocalBoss",FALSE);
    if (nEqual == 0)
        if (nNear > 0 || GetHitDice(oPC) - GetHitDice(OBJECT_SELF) < 2)
    {
        SetLocalInt(OBJECT_SELF,"LocalBoss",TRUE);
    }

    return OBJECT_INVALID;
}


// Auldar: Configurable distance at which to "hide", if the PC, or PC's Associate is within that distance.
// TK 40 doesn't seem to be far enough
const float stealthDistThresh = 80.0;

    // Pausanias: monsters try to find you.
int DoStealthAndWander()
{
    if (GetPlotFlag(OBJECT_SELF))
    {
        return FALSE;
    }
    int nStealthAndWander = GetMonsterOptions(HENCH_MONAI_STEALTH | HENCH_MONAI_WANDER);
    if (!nStealthAndWander)
    {
        return FALSE;
    }

    // Auldar: and they now stealth if they have some skill points (and not marked with plot flag)
    object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC);
    object oNearestHostile = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);

    if (!(GetIsObjectValid(oNearestHostile) && GetIsObjectValid(oPC) && GetIsEnemy(oPC)))
    {
        return FALSE;
    }

    int bActionsCleared = FALSE;
    if ((nStealthAndWander & HENCH_MONAI_STEALTH) && !GetPlotFlag(OBJECT_SELF) &&
        !GetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH))
    {
        // Auldar: Checking if the NPC is hostile to the PC and has skill points in Hide
        // or move silently, and it not marked Plot. If so, go stealthy even if not flagged
        // by the module creator as Stealth on spawn, as long as the PC or associate is hostile and close.
        if (CheckStealth())
        {
                // Auldar: Check how far away the nearest hostile Creature is
            float enemyDistance = GetDistanceToObject(oNearestHostile);

                // Auldar: and check if it's a PC, or a PC's associate.
            object oRealHostileMaster = GetRealMaster(oNearestHostile);
            if (((oPC == oNearestHostile) || (GetIsObjectValid(oRealHostileMaster)
                && GetIsPC(oRealHostileMaster) && GetIsEnemy(oRealHostileMaster)))
                && (enemyDistance <= stealthDistThresh) && (enemyDistance != -1.0))
            {
                ClearAllActions();
                bActionsCleared = TRUE;
                SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, TRUE);
            }
        }
        // Auldar: here ends Auldar's NPC stealth code. Back to Paus' work :)
    }
        // Auldar: Reducing the distance from 40.0 to 25.0 to reduce the "bloodbath" effect
        // requested by FoxBat.
    if ((nStealthAndWander & HENCH_MONAI_WANDER) && GetDistanceToObject(oPC) < 25.0)
    {
        int ScoutMode = GetLocalInt(OBJECT_SELF,"ScoutMode");
        if (ScoutMode == 0)
        {
           ScoutMode = d2();
           SetLocalInt(OBJECT_SELF,"ScoutMode",ScoutMode);
        }
        object oTarget = GetNearestTougherFriend(OBJECT_SELF,oPC);
        if (!GetLocalInt(OBJECT_SELF,"LocalBoss"))
        {
            int fDist = 15;
            if (!GetIsObjectValid(oTarget) || ScoutMode == 1)
            {
                fDist = 10;
                oTarget = oPC;
                if (d10() > 5) fDist = 25;
            }

            location lNew;
            if (GetLocalInt(OBJECT_SELF,"OpenedDoor"))
            {
                lNew = GetLocalLocation(OBJECT_SELF,"ScoutZone");
                SetLocalInt(OBJECT_SELF,"OpenedDoor",FALSE);
            }
            else
            {
                vector vLoc = GetPosition(oTarget);
                vLoc.x += fDist-IntToFloat(Random(2*fDist+1));
                vLoc.y += fDist-IntToFloat(Random(2*fDist+1));
                vLoc.z += fDist-IntToFloat(Random(2*fDist+1));
                lNew = Location(GetArea(oTarget),vLoc,0.);
                SetLocalLocation(OBJECT_SELF,"ScoutZone",lNew);
            }
            if (!bActionsCleared)
            {
                ClearAllActions();
            }
            ActionMoveToLocation(lNew);
            return TRUE;
        }
    }
    return FALSE;
}


void CheckRemoveStealth()
{
    if (GetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH))
    {
        int iCheckStealthAmount = GetSkillRank(SKILL_HIDE) + GetSkillRank(SKILL_MOVE_SILENTLY) + 5;

        SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, FALSE);

        location testLocation = GetLocation(OBJECT_SELF);

        object oCreature = GetFirstObjectInShape(SHAPE_SPHERE, 15.0, testLocation, TRUE);
        while(GetIsObjectValid(oCreature))
        {
            if (GetActionMode(oCreature, ACTION_MODE_STEALTH) &&
                GetIsFriend(oCreature) &&
                !GetIsPC(oCreature))
            {
                if (GetSkillRank(SKILL_HIDE, oCreature) + GetSkillRank(SKILL_MOVE_SILENTLY, oCreature) <= iCheckStealthAmount)
                {
//                  Jug_Debug(GetName(OBJECT_SELF) + " turning off stealth for + " + GetName(oCreature));
                    SetActionMode(oCreature, ACTION_MODE_STEALTH, FALSE);
                }
            }
            oCreature = GetNextObjectInShape(SHAPE_SPHERE, 15.0, testLocation, TRUE);
        }
    }
}


// Pausanias's version of the last: float GetEnemyChallenge()
// My forumla: Total Challenge of Enemy = log ( Sum (2**challenge) )
// Auldar: Changed to 1.5 at Paus' request to better mirror the 3E DMG
float GetEnemyChallenge(object oRelativeTo=OBJECT_SELF)
{
    float fChallenge = 0.;

    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, 20.0, GetLocation(OBJECT_SELF), TRUE);
    while(GetIsObjectValid(oTarget))
    {
         if (GetIsEnemy(oTarget))
         {
            if (GetObjectSeen(oTarget) || GetObjectHeard(oTarget))
            {
            //    if (!GetIsDisabled(oTarget))
                {
                    fChallenge += pow(1.5, GetChallengeRating(oTarget));
                }
            }
         }
         oTarget = GetNextObjectInShape(SHAPE_SPHERE, 20.0, GetLocation(OBJECT_SELF), TRUE);
    }
    return (log(fChallenge)/log(1.5)) - (IntToFloat(GetHitDice(oRelativeTo)) * HENCH_HITDICE_TO_CR);
}


//::///////////////////////////////////////////////
//:: Bash Doors
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Used in DetermineCombatRound to keep a
    henchmen bashing doors.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: April 4, 2002
//:://////////////////////////////////////////////

int HenchBashDoorCheck(int bPolymorphed)
{
    int bDoor = FALSE;
    //This code is here to make sure that henchmen keep bashing doors and placeables.
    object oDoor = GetLocalObject(OBJECT_SELF, "NW_GENERIC_DOOR_TO_BASH");

    if(GetIsObjectValid(oDoor))
    {
        int nDoorMax = GetMaxHitPoints(oDoor);
        int nDoorNow = GetCurrentHitPoints(oDoor);
        int nCnt = GetLocalInt(OBJECT_SELF,"NW_GENERIC_DOOR_TO_BASH_HP");
        if(GetLocked(oDoor) || GetIsTrapped(oDoor))
        {
            if(nDoorMax == nDoorNow)
            {
                nCnt++;
                SetLocalInt(OBJECT_SELF,"NW_GENERIC_DOOR_TO_BASH_HP", nCnt);
            }
            if(nCnt <= 2)
            {
                bDoor = TRUE;
                HenchAttackObject(oDoor);
            }
        }
        if(!bDoor)
        {
            DeleteLocalObject(OBJECT_SELF, "NW_GENERIC_DOOR_TO_BASH");
            DeleteLocalInt(OBJECT_SELF, "NW_GENERIC_DOOR_TO_BASH_HP");
            VoiceCuss();
            ActionDoCommand(HenchEquipDefaultWeapons());
        }
    }
    return bDoor;
}


void HenchStartRangedBashDoor(object oDoor)
{
    ActionEquipMostDamagingRanged(oDoor);
    if (GetDistanceToObject(oDoor) < 5.0)
    {
         ActionMoveAwayFromObject(oDoor, FALSE, 5.0);
    }
    else
    {
        ActionWait(0.5);
    }
    ActionAttack(oDoor);
    SetLocalObject(OBJECT_SELF, "NW_GENERIC_DOOR_TO_BASH", oDoor);
}


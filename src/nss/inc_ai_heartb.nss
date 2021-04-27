/************************ [Heartbeat Include] **********************************
    Filename: inc_ai_heartb
************************* [Heartbeat Include] **********************************
    This contains any heartbeat function calls.

    Note that the heartbeat uses ExecuteScript for larget behaviours that are
    better split up so the heartbeat is as tiny as possible.
************************* [History] ********************************************
    1.3 After Beta - Added
************************* [Workings] *******************************************
    This is included in nw_c2_default1 and ai_onheartb.

    Contains things like in inc_ai_other
************************* [Arguments] ******************************************
    Arguments: N/A
************************* [Heartbeat Include] *********************************/

#include "inc_ai_constants"

// Bioware walk waypoints condition name
const string sWalkwayVarname = "NW_WALK_CONDITION";
// Walk waypoint constant set in the SoU waypoint include
const int NW_WALK_FLAG_CONSTANT                    = 0x00000002;

// Checks:
// * Dead
// * Uncommandable
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

// Attempt to cast iSpell. TRUE if true.
int FleeingSpellCast(int iSpell);

int JumpOutOfHeartBeat()
{
    // What to return
    int iReturn = FALSE;
    // Checks:
    // * Dead + Uncommandable are in GetAIOff
    // * No valid location
    // * Petrified, paralised, ETC.
    // Note: If sleep is found, it may apply Zzzz randomly, as well as stopping.

    // Effect checking
    effect eCheck = GetFirstEffect(OBJECT_SELF);
    int iEffectType;
    while(GetIsEffectValid(eCheck) && iReturn == FALSE)
    {
        iEffectType = GetEffectType(eCheck);
        // Sleep is special
        if(iEffectType == EFFECT_TYPE_SLEEP)
        {
            iReturn = i2;// This immediantly breaks.
        }
        // ALL these stop heartbeat.
        else if(iEffectType == EFFECT_TYPE_PARALYZE || iEffectType == EFFECT_TYPE_STUNNED ||
                iEffectType == EFFECT_TYPE_FRIGHTENED || /* Removed sleep above */
                iEffectType == EFFECT_TYPE_TURNED || iEffectType == EFFECT_TYPE_PETRIFY ||
                iEffectType == EFFECT_TYPE_DAZED || iEffectType == EFFECT_TYPE_TIMESTOP ||
                iEffectType == EFFECT_TYPE_DISAPPEARAPPEAR || iEffectType == EFFECT_TYPE_CHARMED ||
                iEffectType == EFFECT_TYPE_DOMINATED || iEffectType == EFFECT_TYPE_CONFUSED)
        {
            iReturn = i1;// 1 = No Zzz. We continue to check for Zzz as well.
        }
        eCheck = GetNextEffect(OBJECT_SELF);
    }
    // Do we fire the heartbeat event?
    if(iReturn != FALSE)
    {
        // If it is sleep... Zzzzz  sometimes.
        if(iReturn == i2 && d6() == i1)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT,
                                EffectVisualEffect(VFX_IMP_SLEEP),
                                OBJECT_SELF);
        }
        FireUserEvent(
        AI_FLAG_UDE_HEARTBEAT_EVENT,
        EVENT_HEARTBEAT_EVENT);// Fire event 1001
    }
    return iReturn;
}

// This checks fleeing, door bashing and so on, to stop the heartbeat
// and perform the override special action, rather then run normal behaviour.
int PerformSpecialAction()
{
    int iAction = GetCurrentSetAction();
    object oTarget = GetAttackTarget();
    object oRunTarget;
    switch(iAction)
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
                    AISpeakString(HELP_MY_FRIEND);
                    return FALSE;
                }
                else
                {
                    // Else run to them
                    if(GetObjectHeard(oRunTarget))
                    {
                        AISpeakString(HELP_MY_FRIEND);
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
                    ActionForceFollowObject(oRunTarget, f3);
                }
                else if(GetObjectSeen(oRunTarget))
                {
                    // If we see the flee target, reset targets
                    ResetCurrentAction();
                    // We will delete the local int (set to TRUE) which we
                    // stopped fleeing spells from
                    DeleteAIInteger(AI_HEARTBEAT_FLEE_SPELLS);
                    // Speak to allies to come :-)
                    AISpeakString(HELP_MY_FRIEND);
                    // Return FALSE.
                    return FALSE;
                }
                else
                {
                    // Else flee!
                    if(GetObjectHeard(oRunTarget))
                    {
                        AISpeakString(HELP_MY_FRIEND);
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
                // Check if we have bad intellgence, and we will run away
                // from the nearest enemy if heard.
                if(GetAIInteger(AI_INTELLIGENCE) <= i3)
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
                                ResetCurrentAction();
                                return FALSE;
                            }
                        }
                    }
                    // Run from enemy
                    ClearAllActions();
                    ActionMoveAwayFromObject(oTarget, TRUE, f50);
                    return TRUE;
                }
                ResetCurrentAction();
                return FALSE;
            }
        }
        break;
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
    if(FleeingSpellCast(SPELL_IMPROVED_INVISIBILITY)) return;
    if(FleeingSpellCast(SPELL_INVISIBILITY)) return;

    // Haste
    if(FleeingSpellCast(SPELL_MASS_HASTE)) return;
    if(FleeingSpellCast(SPELL_HASTE)) return;
    if(FleeingSpellCast(SPELL_EXPEDITIOUS_RETREAT)) return;
}

// Attempt to cast iSpell. TRUE if true.
int FleeingSpellCast(int iSpell)
{
    if(GetHasSpell(iSpell))
    {
        ActionCastSpellAtObject(iSpell, OBJECT_SELF);
        return TRUE;
    }
    return FALSE;
}

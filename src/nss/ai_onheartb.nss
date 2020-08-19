//:://////////////////////////////////////////////////
//:: NW_C2_DEFAULT1
/*
  Default OnHeartbeat script for NPCs.

  This script causes NPCs to perform default animations
  while not otherwise engaged.

  This script duplicates the behavior of the default
  script and just cleans up the code and removes
  redundant conditional checks.

 */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 12/22/2002
//:://////////////////////////////////////////////////

#include "nw_i0_generic"

void main()
{
    int nCombat = GetIsInCombat(OBJECT_SELF);

    int nRest = GetLocalInt(OBJECT_SELF, "rest");
    if (nCombat && GetLocalInt(OBJECT_SELF, "rest") < 1) SetLocalInt(OBJECT_SELF, "rest", 1);

    if (nRest > 20 && !nCombat)
    {
        ClearAllActions();
        ActionRest();
    }
    else if (nRest > 0)
    {
        SetLocalInt(OBJECT_SELF, "rest", nRest+1);
    }

    // * if not runnning normal or better Ai then exit for performance reasons
    if (GetAILevel() == AI_LEVEL_VERY_LOW) return;

    // Buff ourselves up right away if we should
    // Only enemies will buff themselves.
    if(GetStandardFactionReputation(STANDARD_FACTION_DEFENDER, OBJECT_SELF) <= 10 && GetSpawnInCondition(NW_FLAG_FAST_BUFF_ENEMY))
    {
        // This will return TRUE if an enemy was within 40.0 m
        // and we buffed ourselves up instantly to respond --
        // simulates a spellcaster with protections enabled
        // already.
        if(TalentAdvancedBuff(40.0))
        {
            // This is a one-shot deal
            SetSpawnInCondition(NW_FLAG_FAST_BUFF_ENEMY, FALSE);
            if (GetLocalInt(OBJECT_SELF, "rest") < 1) SetLocalInt(OBJECT_SELF, "rest", 1);

            // This return means we skip sending the user-defined
            // heartbeat signal in this one case.
            return;
        }
    }


    if(GetHasEffect(EFFECT_TYPE_SLEEP))
    {
        // If we're asleep and this is the result of sleeping
        // at night, apply the floating 'z's visual effect
        // every so often

        if(GetSpawnInCondition(NW_FLAG_SLEEPING_AT_NIGHT))
        {
            effect eVis = EffectVisualEffect(VFX_IMP_SLEEP);
            if(d10() > 6)
            {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF);
            }
        }
    }

// don't proceed to the routines below if in conversation.
    if (IsInConversation(OBJECT_SELF)) return;

// return to the original spawn point if it is too far
    location lSpawn = GetLocalLocation(OBJECT_SELF, "spawn");
    float fDistanceFromSpawn = GetDistanceBetweenLocations(GetLocation(OBJECT_SELF), lSpawn);
    float fMaxDistance = 5.0;

// enemies have a much farther distance before they need to reset
    if (GetStandardFactionReputation(STANDARD_FACTION_DEFENDER, OBJECT_SELF) <= 10) fMaxDistance = fMaxDistance*10.0;

    if (GetLocalInt(OBJECT_SELF, "no_wander") == 1) fMaxDistance = 0.0;
// Not in combat? Different/Invalid area? Too far from spawn?
    if (GetLocalInt(OBJECT_SELF, "ambient") != 1 && !nCombat && ((fDistanceFromSpawn == -1.0) || (fDistanceFromSpawn > fMaxDistance)))
    {
        AssignCommand(OBJECT_SELF, ClearAllActions());
        MoveToNewLocation(lSpawn, OBJECT_SELF);
        return;
    }

    // If we have the 'constant' waypoints flag set, walk to the next
    // waypoint.
    else if ( GetWalkCondition(NW_WALK_FLAG_CONSTANT) )
    {
        WalkWayPoints();
    }

    // Check to see if we should be playing default animations
    // - make sure we don't have any current targets
    else if ( !GetIsObjectValid(GetAttemptedAttackTarget())
          && !GetIsObjectValid(GetAttemptedSpellTarget())
          // && !GetIsPostOrWalking())
          && !GetIsObjectValid(GetNearestSeenEnemy()))
    {
        if (GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL) || GetBehaviorState(NW_FLAG_BEHAVIOR_OMNIVORE) ||
            GetBehaviorState(NW_FLAG_BEHAVIOR_HERBIVORE))
        {
            // This handles special attacking/fleeing behavior
            // for omnivores & herbivores.
            DetermineSpecialBehavior();
        }
        else if (!IsInConversation(OBJECT_SELF))
        {
            if (GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS)
                || GetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS_AVIAN)
                || GetIsEncounterCreature())
            {
                PlayMobileAmbientAnimations();
            }
            else if (GetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS))
            {
                PlayImmobileAmbientAnimations();
            }
        }
    }

    string sScript = GetLocalString(OBJECT_SELF, "heartbeat_script");
    if (sScript != "") ExecuteScript(sScript);
}


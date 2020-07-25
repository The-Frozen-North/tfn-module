//:://////////////////////////////////////////////////
//:: NW_C2_DEFAULT6
//:: Default OnDamaged handler
/*
    If already fighting then ignore, else determine
    combat round
 */
//:://////////////////////////////////////////////////
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 12/22/2002
//:://////////////////////////////////////////////////

#include "nw_i0_generic"
#include "1_inc_general"
void main()
{
    SetLocalInt(OBJECT_SELF, "reset_timer", 1);

    object oDamager = GetLastDamager();

    if (GetIsPC(oDamager) || GetIsPC(GetMaster(oDamager))) SetLocalInt(OBJECT_SELF, "player_tagged", 1);


    if (GetCurrentHitPoints(OBJECT_SELF) <= GetMaxHitPoints(OBJECT_SELF)/3)
    {
        DoMoraleCheck(OBJECT_SELF, 10);
    }

    if(GetFleeToExit()) {
        // We're supposed to run away, do nothing
    } else if (GetSpawnInCondition(NW_FLAG_SET_WARNINGS)) {
        // don't do anything?
    } else {
        if (!GetIsObjectValid(oDamager)) {
            // don't do anything, we don't have a valid damager
        } else if (!GetIsFighting(OBJECT_SELF)) {
            // If we're not fighting, determine combat round
            if(GetBehaviorState(NW_FLAG_BEHAVIOR_SPECIAL)) {
                DetermineSpecialBehavior(oDamager);
            } else {
                if(!GetObjectSeen(oDamager)
                   && GetArea(OBJECT_SELF) == GetArea(oDamager)) {
                    // We don't see our attacker, go find them
                    ActionMoveToLocation(GetLocation(oDamager), TRUE);
                    ActionDoCommand(DetermineCombatRound());
                } else {
                    DetermineCombatRound();
                }
            }
        } else {
            // We are fighting already -- consider switching if we've been
            // attacked by a more powerful enemy
            object oTarget = GetAttackTarget();
            if (!GetIsObjectValid(oTarget))
                oTarget = GetAttemptedAttackTarget();
            if (!GetIsObjectValid(oTarget))
                oTarget = GetAttemptedSpellTarget();

            // If our target isn't valid
            // or our damager has just dealt us 25% or more
            //    of our hp in damager
            // or our damager is more than 2HD more powerful than our target
            // switch to attack the damager.
            if (!GetIsObjectValid(oTarget)
                || (
                    oTarget != oDamager
                    &&  (
                         GetTotalDamageDealt() > (GetMaxHitPoints(OBJECT_SELF) / 4)
                         || (GetHitDice(oDamager) - 2) > GetHitDice(oTarget)
                         )
                    )
                )
            {
                // Switch targets
                DetermineCombatRound(oDamager);
            }
        }
    }

    // Send the user-defined event signal
    if(GetSpawnInCondition(NW_FLAG_DAMAGED_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_DAMAGED));
    }
}

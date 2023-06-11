//::///////////////////////////////////////////////
//:: Associate: On Damaged
//:: NW_CH_AC6
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    If already fighting then ignore, else determine
    combat round
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 19, 2001
//:://////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Modified By: Deva Winblood
//:: Modified On: Jan 17th, 2008
//:: Added Support for Mounted Combat Feat Support
//:://////////////////////////////////////////////

#include "x0_inc_henai"

// Determine whether to switch to new attacker
int SwitchTargets(object oCurTarget, object oNewEnemy);

void main()
{
    object oAttacker = GetLastDamager();
    object oTarget = GetAttackTarget();
    object oDamager = oAttacker;
    object oMe=OBJECT_SELF;
    int nHPBefore;

    // UNINTERRUPTIBLE ACTIONS
    if(GetAssociateState(NW_ASC_IS_BUSY)
       || GetAssociateState(NW_ASC_MODE_STAND_GROUND)
       || GetCurrentAction() == ACTION_FOLLOW) {
        // We're busy, don't do anything
    }

    // DEFEND MASTER
    // Priority is to protect our master
    else if(GetAssociateState(NW_ASC_MODE_DEFEND_MASTER)) {
        object oMasterEnemy = GetLastHostileActor(GetMaster());

        // defend our master first
        if (GetIsObjectValid(oMasterEnemy)) {
            HenchmenCombatRound(oMasterEnemy);

        } else if ( !GetIsObjectValid(oTarget)
                || SwitchTargets(oTarget, oAttacker)) {
            HenchmenCombatRound(oAttacker);
        }
    }

    // SWITCH TO MORE DANGEROUS ATTACKER
    // If we're already fighting, possibly switch to our new attacker
    else if (GetIsObjectValid(oTarget) && SwitchTargets(oTarget, oAttacker)) {
        // Switch to the attacker
        HenchmenCombatRound(oAttacker);
    }

    // Signal the user-defined event
    if(GetSpawnInCondition(NW_FLAG_DAMAGED_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(1006));
    }
}


// Determine whether to switch to new attacker
int SwitchTargets(object oCurTarget, object oNewEnemy)
{
    return (GetIsObjectValid(oNewEnemy) && oCurTarget != oNewEnemy
            &&
            (
             // The new enemy is of a higher level
             GetHitDice(oNewEnemy) > GetHitDice(oCurTarget)
             ||
             // or we just received more than 25% of our hp in damage
             GetTotalDamageDealt() > (GetMaxHitPoints(OBJECT_SELF) / 4)
             )
            );
}

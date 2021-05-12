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

#include "inc_hai"
#include "inc_general"

void main()
{
    object oAttacker = GetLastDamager();
    object oTarget = GetAttackTarget();
    object oDamager = oAttacker;
    object oMe=OBJECT_SELF;
    int nHPBefore;

    PlayNonMeleePainSound(oDamager);

    if (GetIsEnemy(oAttacker))
        SpeakString("I_WAS_ATTACKED", TALKVOLUME_SILENT_TALK);

    if(!GetAssociateState(NW_ASC_IS_BUSY))
    {
        // Auldar: Make a check for taunting before running Ondamaged.
        if(!GetAssociateState(NW_ASC_MODE_STAND_GROUND) && (GetCurrentAction() != ACTION_FOLLOW)
            && (GetCurrentAction() != ACTION_TAUNT))
        {
            if ((GetLocalInt(OBJECT_SELF, HENCH_HEAL_SELF_STATE) == HENCH_HEAL_SELF_WAIT) &&
                (GetPercentageHPLoss(OBJECT_SELF) < 30))
            {
                // force heal
                HenchDetermineCombatRound(OBJECT_INVALID, TRUE);
            }
            else
            {
                // Auldar: Use combat checks from OnPerceive.
                if(!GetIsObjectValid(GetAttemptedAttackTarget()) &&
                   !GetIsObjectValid(GetAttackTarget()) &&
                   !GetIsObjectValid(GetAttemptedSpellTarget()))
                {
                    if(GetIsObjectValid(GetLastHostileActor()))
                    {
                        if(GetAssociateState(NW_ASC_MODE_DEFEND_MASTER))
                        {
                            if(!GetIsObjectValid(GetLastHostileActor(GetRealMaster())))
                            {
                                HenchDetermineCombatRound(GetLastHostileActor(GetRealMaster()));
                            }
                        }
                        else
                        {
                            HenchDetermineCombatRound(oAttacker);
                        }
                    }
                }
            }
        }
    }

    if(GetSpawnInCondition(NW_FLAG_DAMAGED_EVENT))
    {
        SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_DAMAGED));
    }
}


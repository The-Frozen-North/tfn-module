//::///////////////////////////////////////////////
//:: Associate On Attacked
//:: NW_CH_AC5
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    If already fighting then ignore, else determine
    combat round
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 16, 2001
//:://////////////////////////////////////////////

#include "inc_hai"


void main()
{
    if (!GetLocalInt(GetModule(),"X3_NO_MOUNTED_COMBAT_FEAT"))
    { // set variables on target for mounted combat
        SetLocalInt(OBJECT_SELF,"bX3_LAST_ATTACK_PHYSICAL",TRUE);
        SetLocalInt(OBJECT_SELF,"nX3_HP_BEFORE",GetCurrentHitPoints(OBJECT_SELF));
    } // set variables on target for mounted combat

    if(!GetAssociateState(NW_ASC_IS_BUSY))
    {
        SetCommandable(TRUE);
        // Auldar: Don't want anything to interupt a Taunt attempt.
        if(!GetAssociateState(NW_ASC_MODE_STAND_GROUND) &&  (GetCurrentAction() != ACTION_TAUNT))
        {
            CheckRemoveStealth();
            // Auldar: Use checks from OnPerceive so we don't run DCR if we have a target.
            if(!GetIsObjectValid(GetAttemptedAttackTarget()) &&
               !GetIsObjectValid(GetAttackTarget()) &&
               !GetIsObjectValid(GetAttemptedSpellTarget()))
            {
                if(GetIsObjectValid(GetLastAttacker()))
                {
                    if(GetAssociateState(NW_ASC_MODE_DEFEND_MASTER))
                    {
                        if(!GetIsObjectValid(GetLastAttacker(GetRealMaster())))
                        {
                            HenchDetermineCombatRound();
                        }
                    }
                    else
                    {
                        HenchDetermineCombatRound(GetLastAttacker());
                    }
                }
            }
            if(GetSpawnInCondition(EVENT_ATTACKED))
            {
                SignalEvent(OBJECT_SELF, EventUserDefined(EVENT_ATTACKED));
            }
        }
    }
}



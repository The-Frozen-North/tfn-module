//::///////////////////////////////////////////////
//:: x2_s2_gwdrain
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The shadow gets  special strength drain
    attack, once per round.

    The shifter's spectre form can use this ability
    but is not as effective as a real shadow
*/
//:://////////////////////////////////////////////
//:: Created By:
//:: Created On:
//:://////////////////////////////////////////////
/*
Patch 1.70

- immunity to negative levels was ommited in the case where target would ran out of
levels
- killing the target if he ran out of levels could been resisted via death immunity
- critical hit damage corrected
*/

#include "x0_i0_spells"
#include "x2_inc_shifter"

void DoDrain(object oTarget, int nDrain)
{
    effect eDrain = EffectNegativeLevel(nDrain);
    eDrain = SupernaturalEffect(eDrain);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eDrain, oTarget);
}

void main()
{
    //Declare major variables
    effect eVis = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
    object oTarget = GetSpellTargetObject();

    int nDC = ShifterGetSaveDC(OBJECT_SELF,SHIFTER_DC_EASY_MEDIUM);
    if(oTarget != OBJECT_SELF)
    {
        if (spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
        {
            int nTouch = TouchAttackMelee(oTarget);
            if (nTouch >0)
            {
                int nDrain = d2(nTouch);//correct critical hit damage calculation (will enable odd values)
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId()));
                if(!MySavingThrow(SAVING_THROW_FORT, oTarget, nDC, SAVING_THROW_TYPE_NEGATIVE))
                {
                    if(!GetIsImmune(oTarget,IMMUNITY_TYPE_NEGATIVE_LEVEL,OBJECT_SELF) && GetHitDice(oTarget)-nDrain<1)
                    {
                        effect eDeath = SupernaturalEffect(EffectDeath(TRUE));
                        ApplyEffectToObject(DURATION_TYPE_INSTANT,eDeath,oTarget);
                    }
                    else
                    {
                        DelayCommand(0.1,DoDrain(oTarget,nDrain));
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
                    }
                }
            }
        }
    }
}

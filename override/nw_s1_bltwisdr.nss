//::///////////////////////////////////////////////
//:: Bolt: Wisdom Drain
//:: NW_S1_BltWisDr
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creature must make a ranged touch attack to hit
    the intended target.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 11 , 2001
//:: Updated On: July 15, 2003 Georg Zoeller - Removed saving throws
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //Declare major variables
    object oTarget = GetSpellTargetObject();
    int nHD = GetHitDice(OBJECT_SELF);
    effect eVis = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
    effect eBolt;
//    int nDC = 10 + (nHD/2);
    int nCount = 1+(nHD/4);
//    int nDamage = d6(nCount);

    if(spellsIsTarget(oTarget, SPELL_TARGET_SINGLETARGET, OBJECT_SELF))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_BOLT_ABILITY_DRAIN_WISDOM));
        //Make a saving throw check
        if(TouchAttackRanged(oTarget))
        {
            eBolt = EffectAbilityDecrease(ABILITY_WISDOM, nCount);
            eBolt = SupernaturalEffect(eBolt);
            //Apply the VFX impact and effects
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eBolt, oTarget);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
        }
    }
}

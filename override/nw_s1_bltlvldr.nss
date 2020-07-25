//::///////////////////////////////////////////////
//:: Bolt: Level Drain
//:: NW_S1_BltLvlDr
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
//    effect eBolt = EffectNegativeLevel(1);
    int nDC = 10 + (nHD/2);
    int nCount = nHD /5;
    if(nCount < 1)
    {
        nCount = 1;
    }

    int nDamage = d6(nCount);

    if(spellsIsTarget(oTarget, SPELL_TARGET_SINGLETARGET, OBJECT_SELF))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_BOLT_LEVEL_DRAIN));
        //Make a saving throw check
        if(TouchAttackRanged(oTarget))
        {
            //eBolt = LEVEL DRAIN EFFECT
//            eBolt = SupernaturalEffect(eBolt);
            //Apply the VFX impact and effects
            //engine workaroud in order to pass the id of -1 into effect for AI purposes
            DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(EffectNegativeLevel(1)), oTarget));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
        }
    }
}

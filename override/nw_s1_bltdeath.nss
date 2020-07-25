//::///////////////////////////////////////////////
//:: Bolt: Death
//:: NW_S1_BltDeath
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
/*
Patch 1.71

- death VFX enabled
- protected against action cancel
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //Declare major variables
    object oTarget = GetSpellTargetObject();
    int nHD = GetHitDice(OBJECT_SELF);
    effect eVis = EffectVisualEffect(VFX_IMP_DEATH);
    effect eBolt = EffectDeath();
    int nDC = 10 + (nHD/2);

    if(spellsIsTarget(oTarget, SPELL_TARGET_SINGLETARGET, OBJECT_SELF))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_BOLT_DEATH));
        //Make a saving throw check
        if(TouchAttackRanged(oTarget))
        {
            //Apply the VFX impact and effects
            if(GetIsImmune(oTarget,IMMUNITY_TYPE_DEATH,OBJECT_SELF))
            {
                SetCommandable(FALSE,oTarget); //engine workaround to avoid action cancel
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eBolt, oTarget);
                SetCommandable(TRUE,oTarget);
            }
            else
            {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eBolt, oTarget);
            }
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);//re-added
        }
    }
}

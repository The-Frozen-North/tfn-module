//::///////////////////////////////////////////////
//:: Bolt: Knockdown
//:: NW_S1_BltKnckD
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creature must make a ranged touch attack to hit
    the intended target.  Reflex or Will save is
    needed to halve damage or avoid effect.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 11 , 2001
//:: Updated On: July 15, 2003 Georg Zoeller - Removed saving throws
//:://////////////////////////////////////////////
/*
Patch 1.71

- was missing no-pvp check
- damage is now doubled in case of critical hit
- added duration scaling per game difficulty
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //Declare major variables
    object oTarget = GetSpellTargetObject();
    int nHD = GetHitDice(OBJECT_SELF);
    effect eVis = EffectVisualEffect(VFX_IMP_SONIC);
    effect eBolt = EffectKnockdown();
    int nDC = 10 + (nHD/2);
    int nCount = 3;
    nCount = GetScaledDuration(nCount, oTarget);

    if(spellsIsTarget(oTarget, SPELL_TARGET_SINGLETARGET, OBJECT_SELF))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_BOLT_KNOCKDOWN));
        //Make a touch attack
        int nTouch = TouchAttackRanged(oTarget);
        if(nTouch > 0)
        {
            //Apply the VFX impact and effects
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(eBolt), oTarget, RoundsToSeconds(nCount));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
            effect eDam = EffectDamage(d6(nTouch), DAMAGE_TYPE_BLUDGEONING);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
        }
    }
}

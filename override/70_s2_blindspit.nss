//::///////////////////////////////////////////////
//:: Blinding Spittle
//:: 70_s2_blindspit
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
At 4th level, an Eye of Gruumsh can launch blinding spittle at any opponent within 20 feet.
Using a ranged touch attack (at a -4 penalty), he spits his stomach acid into the target's eyes.
An opponent who fails a Reflex save (DC 10 + eye of Gruumsh level + eye of Gruumsh's Constitution
bonus) is blinded until he or she can rinse away the spittle.
This attack has no effect on creatures that don't have eyes or don't depend on vision.
Blinding spittle is usable 2/day at 4th level and 4/day at 7th level.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch
//:: Created On: 08-11-2013
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //Declare major variables
    object oTarget = GetSpellTargetObject();
    effect eVis = EffectVisualEffect(VFX_IMP_ACID_L);
    effect eVis2 = EffectVisualEffect(VFX_IMP_ACID_S);
    effect eBolt;

    int nDC = 10+GetLevelByClass(39)+GetAbilityModifier(ABILITY_CONSTITUTION);

    if (spellsIsTarget(oTarget, SPELL_TARGET_SINGLETARGET, OBJECT_SELF))
    {

        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId()));
        //Adjust the damage based on the Reflex Save, Evasion and Improved Evasion.

        //Make a ranged touch attack
        int nTouch = TouchAttackRanged(oTarget);
        if(nTouch > 0)
        {
            if(!MySavingThrow(SAVING_THROW_REFLEX,oTarget,nDC,SAVING_THROW_TYPE_ACID))
            {
                eBolt = EffectBlindness();
                eBolt = EffectLinkEffects(eBolt,EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE));
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(eBolt), oTarget, RoundsToSeconds(3));

                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oTarget);
            }
        }
    }
}

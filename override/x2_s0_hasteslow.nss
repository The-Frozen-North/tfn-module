//::///////////////////////////////////////////////
//:: Haste or Slow
//:: x2_s0_HasteSlow.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    2/3rds of the time, Gives the targeted creature one extra partial
    action per round.
    1/3 of the time, Character can take only one partial action
    per round.
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: Jan 3/03
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    //Determine spell duration as an integer for later conversion to Rounds, Turns or Hours.
    int nDuration = spell.Level;

    if (d100() > 33)
    {// 2/3 of the time - do haste effect
    //Declare major variables
        effect eHaste = EffectHaste();
        effect eVis = EffectVisualEffect(VFX_IMP_HASTE);
        effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
        effect eLink = EffectLinkEffects(eHaste, eDur);

        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, SPELL_HASTE, FALSE));

        // Apply effects to the currently selected target.
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
    }
    else
    {//1/3 of the time - do slow effect

        //Declare major variables
        effect eSlow = EffectSlow();
        effect eDur1 = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
        effect eLink1 = EffectLinkEffects(eSlow, eDur1);

        effect eVis1 = EffectVisualEffect(VFX_IMP_SLOW);
        effect eImpact1 = EffectVisualEffect(VFX_FNF_LOS_NORMAL_30);

        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, SPELL_SLOW, FALSE));
        // Apply effects to the currently selected target.
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink1, spell.Target, DurationToSeconds(nDuration));
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis1, spell.Target);
    }
}

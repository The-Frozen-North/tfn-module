//::///////////////////////////////////////////////
//:: Blindness and Deafness
//:: [NW_S0_BlindDead.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Causes the target creature to make a Fort
//:: save or be blinded and deafened.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 12, 2001
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.SavingThrow = SAVING_THROW_FORT;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major varibles
    spellsDeclareMajorVariables();

    int nDuration = spell.Level;
    effect eBlind =  EffectBlindness();
    effect eDeaf = EffectDeaf();
    effect eVis = EffectVisualEffect(VFX_IMP_BLIND_DEAF_M);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

    effect eLink = EffectLinkEffects(eBlind, eDeaf);
    eLink = EffectLinkEffects(eLink, eDur);
    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster,spell.Id));
        //Do SR check
        if (!MyResistSpell(spell.Caster, spell.Target))
        {
            // Make Fortitude save to negate
            if (!MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, SAVING_THROW_TYPE_NONE, spell.Caster))
            {
                //Metamagic check for duration
                if (spell.Meta & METAMAGIC_EXTEND)
                {
                    nDuration = nDuration * 2;
                }
                //Apply visual and effects
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
            }
        }
    }
}

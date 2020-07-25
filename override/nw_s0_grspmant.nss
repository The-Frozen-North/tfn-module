//::///////////////////////////////////////////////
//:: Greater Spell Mantle
//:: NW_S0_GrSpTurn.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Grants the caster 1d12 + 10 spell levels of
    absorbtion.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2002
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 12;
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(VFX_DUR_SPELLTURNING);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    int nDuration = spell.Level;
    //calculate the duration with proper metamagic handling
    int nAbsorb = MaximizeOrEmpower(spell.Dice,1,spell.Meta,10);
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2; //Duration is +100%
    }
    //Link Effects
    effect eAbsob = EffectSpellLevelAbsorption(9, nAbsorb);
    effect eLink = EffectLinkEffects(eVis, eAbsob);
    eLink = EffectLinkEffects(eLink, eDur);
    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    RemoveEffectsFromSpell(spell.Target, spell.Id);
    RemoveEffectsFromSpell(spell.Target, SPELL_LESSER_SPELL_MANTLE);
    RemoveEffectsFromSpell(spell.Target, SPELL_SPELL_MANTLE);
    //Apply the VFX impact and effects
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
}

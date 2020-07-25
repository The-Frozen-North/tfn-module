//::///////////////////////////////////////////////
//:: Magic Circle Against Law
//:: NW_S0_CircLaw.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Add basic protection from law effects to
    entering allies.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow
//:: Created On: March 29, 2012
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "x0_i0_spells"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_HOURS;
    spell.TargetType = SPELL_TARGET_ALLALLIES;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables including Area of Effect Object
    spellsDeclareMajorVariables();

    effect eAOE = EffectAreaOfEffect(AOE_MOB_CIRCEVIL,"nw_s0_circlawa");
    effect eVis = EffectVisualEffect(276);
    int nAlignment = ALIGNMENT_LAWFUL;

    effect eAC = EffectACIncrease(2, AC_DEFLECTION_BONUS);
    eAC = VersusAlignmentEffect(eAC, nAlignment, ALIGNMENT_ALL);
    effect eSave = EffectSavingThrowIncrease(SAVING_THROW_ALL, 2);
    eSave = VersusAlignmentEffect(eSave, nAlignment, ALIGNMENT_ALL);
    effect eImmune = EffectImmunity(IMMUNITY_TYPE_MIND_SPELLS);
    eImmune = VersusAlignmentEffect(eImmune, nAlignment, ALIGNMENT_ALL);
    effect eDur = EffectVisualEffect(VFX_DUR_PROTECTION_GOOD_MINOR);

    effect eDur2 = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eImmune, eSave);
    eLink = EffectLinkEffects(eLink, eAC);
    eLink = EffectLinkEffects(eLink, eDur);
    eLink = EffectLinkEffects(eLink, eDur2);
    eLink = EffectLinkEffects(eLink, eVis);
    eLink = EffectLinkEffects(eLink, eAOE);

    int nDuration = spell.Level;
    //Check Extend metamagic feat.
    if (spell.Meta & METAMAGIC_EXTEND)
    {
       nDuration = nDuration *2;    //Duration is +100%
    }

    //prevent stacking
    RemoveEffectsFromSpell(spell.Target, spell.Id);

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    eVis = EffectVisualEffect(VFX_IMP_GOOD_HELP);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);

    //Create an instance of the AOE Object using the Apply Effect function
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
    spellsSetupNewAOE("VFX_MOB_CIRCEVIL");
}

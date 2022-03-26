//::///////////////////////////////////////////////
//:: Holy Aura
//:: NW_S0_HolyAura.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The cleric casting this spell gains +4 AC and
    +4 to saves. Is immune to Mind-Affecting Spells
    used by evil creatures and gains an SR of 25
    versus the spells of Evil Creatures
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Sept 28, 2001
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "nw_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = DAMAGE_BONUS_1d8;
    spell.DamageType = DAMAGE_TYPE_DIVINE;
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDuration = spell.Level;

    if (spell.Meta & METAMAGIC_EXTEND)
    {
       nDuration = nDuration * 2;    //Duration is +100%
    }

    effect eVis = EffectVisualEffect(VFX_DUR_PROTECTION_GOOD_MAJOR);
    effect eAC = EffectACIncrease(4, AC_DEFLECTION_BONUS);
    effect eSave = EffectSavingThrowIncrease(SAVING_THROW_ALL, 4);
    //Change the effects so that it only applies when the target is evil
    effect eImmune = EffectImmunity(IMMUNITY_TYPE_MIND_SPELLS);
    effect eSR = EffectSpellResistanceIncrease(25); //Check if this is a bonus or a setting.
    effect eDur = EffectVisualEffect(VFX_DUR_PROTECTION_GOOD_MAJOR);
    effect eDur2 = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eEvil = EffectDamageShield(6, spell.Dice, spell.DamageType);

    // * make them versus the alignment
    eImmune = VersusAlignmentEffect(eImmune, ALIGNMENT_ALL, ALIGNMENT_EVIL);
    eSR = VersusAlignmentEffect(eSR,ALIGNMENT_ALL, ALIGNMENT_EVIL);
    eAC =  VersusAlignmentEffect(eAC,ALIGNMENT_ALL, ALIGNMENT_EVIL);
    eSave = VersusAlignmentEffect(eSave,ALIGNMENT_ALL, ALIGNMENT_EVIL);
    eEvil = VersusAlignmentEffect(eEvil,ALIGNMENT_ALL, ALIGNMENT_EVIL);

    //Link effects
    effect eLink = EffectLinkEffects(eImmune, eSave);
    eLink = EffectLinkEffects(eLink, eAC);
    eLink = EffectLinkEffects(eLink, eSR);
    eLink = EffectLinkEffects(eLink, eDur);
    eLink = EffectLinkEffects(eLink, eDur2);
    eLink = EffectLinkEffects(eLink, eEvil);

    //--------------------------------------------------------------------------
    // GZ: Make sure this aura is only active once
    //--------------------------------------------------------------------------
    if(GetModuleSwitchValue("72_DISABLE_DAMAGE_SHIELD_STACKING"))
    {
        RemoveSpecificEffect(EFFECT_TYPE_ELEMENTALSHIELD,spell.Target);
    }
    RemoveSpellEffects(spell.Id,spell.Caster,spell.Target);

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    //Apply the VFX impact and effects
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
}

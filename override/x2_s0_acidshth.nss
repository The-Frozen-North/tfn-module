//::///////////////////////////////////////////////
//:: Mestil's Acid Sheath
//:: X2_S0_AcidShth
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This spell creates an acid shield around your
    person. Any creature striking you with its body
    does normal damage, but at the same time the
    attacker takes 1d6 points +2 points per caster
    level of acid damage. Weapons with exceptional
    reach do not endanger thier uses in this way.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2002
//:: 2003-07-07: Stacking Spell Pass, Georg Zoeller
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = DAMAGE_BONUS_1d6;
    spell.DamageType = DAMAGE_TYPE_ACID;
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(448);
    int nDuration = spell.Level;
    int nDamage = spell.Level * 2;
    effect eShield = EffectDamageShield(nDamage, spell.Dice, spell.DamageType);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    //Link effects
    effect eLink = EffectLinkEffects(eShield, eDur);
    eLink = EffectLinkEffects(eLink, eVis);

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    //Enter Metamagic conditions
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2; //Duration is +100%
    }

    // 2003-07-07: Stacking Spell Pass, Georg
    if(GetModuleSwitchValue("72_DISABLE_DAMAGE_SHIELD_STACKING"))
    {
        RemoveSpecificEffect(EFFECT_TYPE_ELEMENTALSHIELD,spell.Target);
    }
    RemoveEffectsFromSpell(spell.Target, spell.Id);

    //Apply the VFX impact and effects
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
}

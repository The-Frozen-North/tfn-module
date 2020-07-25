//::///////////////////////////////////////////////
//:: Death Armor
//:: X2_S0_DthArm
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    You are surrounded with a magical aura that injures
    creatures that contact it. Any creature striking
    you with its body or handheld weapon takes 1d4 points
    of damage +1 point per 2 caster levels (maximum +5).
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Jan 6, 2003
//:://////////////////////////////////////////////
//:: Last Updated By: Andrew Nobbs, 02/06/2003
//:: 2003-07-07: Stacking Spell Pass, Georg Zoeller

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = DAMAGE_BONUS_1d4;
    spell.DamageType = DAMAGE_TYPE_MAGICAL;
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.Limit = 5;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDuration = spell.Level;
    int nCasterLvl = spell.Level/2;
    if(nCasterLvl > spell.Limit)
    {
        nCasterLvl = spell.Limit;
    }

    effect eShield = EffectDamageShield(nCasterLvl, spell.Dice, spell.DamageType);
    effect eDur = EffectVisualEffect(VFX_DUR_DEATH_ARMOR);

    //Link effects
    effect eLink = EffectLinkEffects(eShield, eDur);

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    //Enter Metamagic conditions
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2; //Duration is +100%
    }

    //Stacking Spellpass, 2003-07-07, Georg
    if(GetModuleSwitchValue("72_DISABLE_DAMAGE_SHIELD_STACKING"))
    {
        RemoveSpecificEffect(EFFECT_TYPE_ELEMENTALSHIELD,spell.Target);
    }
    RemoveEffectsFromSpell(spell.Target, spell.Id);

    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
}

//::///////////////////////////////////////////////
//:: Epic Mage Armor
//:: X2_S2_EpMageArm
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Gives the target +20 AC Bonus to Deflection,
    Armor Enchantment, Natural Armor and Dodge.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Feb 07, 2003
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "nw_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_HOURS;
    spell.Limit = 5;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDuration = spell.Level;
    effect eVis = EffectVisualEffect(VFX_DUR_PROT_EPIC_ARMOR);
    effect eAC1, eAC2, eAC3, eAC4;
    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    //Check for metamagic extend
    if(spell.Meta & METAMAGIC_EXTEND) //Duration is +100%
    {
        nDuration = nDuration * 2;
    }
    //Set the four unique armor bonuses
    eAC1 = EffectACIncrease(spell.Limit, AC_ARMOUR_ENCHANTMENT_BONUS);
    eAC2 = EffectACIncrease(spell.Limit, AC_DEFLECTION_BONUS);
    eAC3 = EffectACIncrease(spell.Limit, AC_DODGE_BONUS);
    eAC4 = EffectACIncrease(spell.Limit, AC_NATURAL_BONUS);
    effect eDur = EffectVisualEffect(VFX_DUR_SANCTUARY);

    effect eLink = EffectLinkEffects(eAC1, eAC2);
    eLink = EffectLinkEffects(eLink, eAC3);
    eLink = EffectLinkEffects(eLink, eAC4);
    eLink = EffectLinkEffects(eLink, eDur);

    RemoveEffectsFromSpell(spell.Target, spell.Id);

    // * Brent, Nov 24, making extraodinary so cannot be dispelled
    eLink = ExtraordinaryEffect(eLink);

    //Apply the armor bonuses and the VFX impact
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, spell.Target, 1.0);
}

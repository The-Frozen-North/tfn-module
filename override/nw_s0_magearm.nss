//::///////////////////////////////////////////////
//:: Mage Armor
//:: [NW_S0_MageArm.nss]
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Gives the target +1 AC Bonus to Deflection,
    Armor Enchantment, Natural Armor and Dodge.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 12, 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk, On: April 10, 2001
//:: VFX Pass By: Preston W, On: June 22, 2001
/*
bugfix by Kovi 2002.07.23
- dodge bonus was stacking

Patch 1.70
- fixed stacking the shadow conjuration variant with itself
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_HOURS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDuration = spell.Level;

    effect eVis = EffectVisualEffect(VFX_IMP_AC_BONUS);
    effect eAC1, eAC2, eAC3, eAC4;
    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    //Check for metamagic extend
    if (spell.Meta & METAMAGIC_EXTEND) //Duration is +100%
    {
         nDuration = nDuration * 2;
    }
    //Set the four unique armor bonuses
    eAC1 = EffectACIncrease(1, AC_ARMOUR_ENCHANTMENT_BONUS);
    eAC2 = EffectACIncrease(1, AC_DEFLECTION_BONUS);
    eAC3 = EffectACIncrease(1, AC_DODGE_BONUS);
    eAC4 = EffectACIncrease(1, AC_NATURAL_BONUS);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    effect eLink = EffectLinkEffects(eAC1, eAC2);
    eLink = EffectLinkEffects(eLink, eAC3);
    eLink = EffectLinkEffects(eLink, eAC4);
    eLink = EffectLinkEffects(eLink, eDur);

    RemoveEffectsFromSpell(spell.Target, spell.Id);

    //Apply the armor bonuses and the VFX impact
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
}

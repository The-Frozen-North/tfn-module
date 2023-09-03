//::///////////////////////////////////////////////
//:: Greater Stoneskin
//:: NW_S0_GrStoneSk
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Gives the gives the creature touched 20/+5
    damage reduction.  This lasts for 1 hour per
    caster level or until 10 * Caster Level (150 Max)
    is dealt to the person.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: March 16 , 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Andrew Nobbs March 4, 2003

#include "70_inc_spells"
#include "nw_i0_spells"
#include "x2_inc_spellhook"
#include "inc_spells"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_HOURS;
    spell.Limit = 150;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nAmount = spell.Level * 10;
    int nDuration = spell.Level;
    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    //Limit the amount protection to 100 points of damage
    if (nAmount > spell.Limit)
    {
        nAmount = spell.Limit;
    }
    //Meta Magic
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration *= 2;
    }

    effect eVis2 = EffectVisualEffect(VFX_IMP_POLYMORPH);
    effect eStone = EffectDamageReduction(20, DAMAGE_POWER_PLUS_FIVE, nAmount);
    effect eVis = EffectVisualEffect(VFX_DUR_PROT_STONESKIN);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    //Link the texture replacement and the damage reduction effect
    effect eLink = EffectLinkEffects(eVis, eStone);
    eLink = EffectLinkEffects(eLink, eDur);

    //Remove effects from target if they have Greater Stoneskin cast on them already.
    RemoveEffectsFromSpell(spell.Target, spell.Id);

    RemoveDamageReductionSpellEffects(spell.Target);

    //Apply the linked effect
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, spell.Target);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
}

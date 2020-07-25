//::///////////////////////////////////////////////
//:: Epic Ward
//:: X2_S2_EpicWard.
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Makes the caster invulnerable to damage
    (equals damage reduction 50/+20)
    Lasts 1 round per level

*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: Aug 12, 2003
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "nw_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.Limit = 50;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDuration = spell.Level;
    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    int nLimit = spell.Limit*nDuration;
    //Check for metamagic extend
    if(spell.Meta & METAMAGIC_EXTEND) //Duration is +100%
    {//1.70 added in order to allow metamagic override feature
        nDuration = nDuration * 2;
    }
    effect eDur = EffectVisualEffect(VFX_DUR_PROT_EPIC_ARMOR);
    effect eProt = EffectDamageReduction(spell.Limit, DAMAGE_POWER_PLUS_TWENTY, nLimit);
    effect eLink = EffectLinkEffects(eDur, eProt);
    eLink = EffectLinkEffects(eLink, eDur);

    // * Brent, Nov 24, making extraodinary so cannot be dispelled
    eLink = ExtraordinaryEffect(eLink);

    RemoveEffectsFromSpell(spell.Target, spell.Id);
    //Apply the armor bonuses and the VFX impact
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
}

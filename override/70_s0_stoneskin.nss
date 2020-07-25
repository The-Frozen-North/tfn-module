//::///////////////////////////////////////////////
//:: Stone skin protection Multi-spell script
//:: 70_s0_stoneskin
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
Reason for this spellscript is to allow builder change all stone skill spells easily.
You can now modify all these spells in single script instead of modifying three scripts
individually.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow
//:: Created On: Sep 16, 2014
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "nw_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_HOURS;
    spell.Limit = GetSpellId() == SPELL_GREATER_STONESKIN ? 150 : 100;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nAmount, nPower, nMax, nVFX, nVFX2;
    switch(spell.Id)
    {
        case SPELL_STONESKIN:
        case SPELL_SHADES_STONESKIN:
        nAmount = 10; nPower = DAMAGE_POWER_PLUS_FIVE; nMax = spell.Limit; nVFX = VFX_DUR_PROT_STONESKIN; nVFX2 = VFX_IMP_SUPER_HEROISM;
        break;
        case SPELL_GREATER_STONESKIN:
        nAmount = 20; nPower = DAMAGE_POWER_PLUS_FIVE; nMax = spell.Limit; nVFX = VFX_DUR_PROT_STONESKIN; nVFX2 = VFX_IMP_POLYMORPH;
        break;
        case SPELL_PREMONITION:
        nAmount = 30; nPower = DAMAGE_POWER_PLUS_FIVE; nMax = 9999; nVFX = VFX_DUR_PROT_PREMONITION;
        break;
    }

    int nDuration = spell.Level;
    int nLimit = spell.Level * 10;
    if(nLimit > nMax)
    {
        nLimit = nMax;
    }
    effect eStone = EffectDamageReduction(nAmount, nPower, nLimit);
    effect eVis = EffectVisualEffect(nVFX);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    //Link the visual and the damage reduction effect
    effect eLink = EffectLinkEffects(eStone, eVis);
    eLink = EffectLinkEffects(eLink, eDur);
    //Enter Metamagic conditions
    if(spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2; //Duration is +100%
    }

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    RemoveEffectsFromSpell(spell.Target, spell.Id);
    //Apply the impact VFX
    if(nVFX2 != 0)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(nVFX2), spell.Target);
    }
    //Apply the linked effect
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
}

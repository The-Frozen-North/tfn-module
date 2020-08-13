//::///////////////////////////////////////////////
//:: Wounding Whispers
//:: x0_s0_WoundWhis.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Magical whispers cause 1d8 sonic damage to attackers who hit you.
    Made the damage slightly more than the book says because we cannot
    do the +1 per level.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2002
//:://////////////////////////////////////////////
//:: Modified for wounding whispers, July 30 2002, Brent
//:://////////////////////////////////////////////
//:: Last Update By: Andrew Nobbs May 01, 2003
/*
Patch 1.70

- damage wasn't random
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = DAMAGE_BONUS_1d6;
    spell.DamageType = DAMAGE_TYPE_SONIC;
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_POSITIVE);
    int nDuration = spell.Level;
    int nBonus = spell.Level;
    effect eShield = EffectDamageShield(nBonus, spell.Dice, spell.DamageType);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    //Link effects
    effect eLink = EffectLinkEffects(eShield, eDur);
    eLink = EffectLinkEffects(eLink, eVis);

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    if(GetModuleSwitchValue("72_DISABLE_DAMAGE_SHIELD_STACKING"))
    {
        RemoveSpecificEffect(EFFECT_TYPE_ELEMENTALSHIELD,spell.Target);
    }
    if (GetHasSpellEffect(spell.Id, spell.Target))
    {
        RemoveEffectsFromSpell(spell.Target,spell.Id);
    }

    //Enter Metamagic conditions
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2; //Duration is +100%
    }
    //Apply the VFX impact and effects
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
}

//::///////////////////////////////////////////////
//:: Stone Bones
//:: X2_S0_StnBones
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Gives the target +3 AC Bonus to Natural Armor.
    Only if target creature is undead.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 25, 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Andrew Nobbs, 02/06/2003
//:: 2003-07-07: Stacking Spell Pass, Georg Zoeller
/*
Patch 1.71

- spell work only for corporeal undeads now, as incorporeal doesn't have bones
*/

#include "70_inc_spells"
#include "nw_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_TURNS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDuration  = spell.Level * 10;
    effect eVis = EffectVisualEffect(VFX_IMP_AC_BONUS);

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    //Check for metamagic extend
    if (spell.Meta & METAMAGIC_EXTEND) //Duration is +100%
    {
         nDuration = nDuration * 2;
    }
    //Set the one unique armor bonuses
    effect eAC1 = EffectACIncrease(3, AC_NATURAL_BONUS);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eAC1, eDur);

    //Stacking Spellpass, 2003-07-07, Georg
    RemoveEffectsFromSpell(spell.Target, spell.Id);

    //Apply the armor bonuses and the VFX impact
    if(spellsIsRacialType(spell.Target, RACIAL_TYPE_UNDEAD) && !GetCreatureFlag(spell.Target, CREATURE_VAR_IS_INCORPOREAL))
    {
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
    }
    else
    {
        FloatingTextStrRefOnCreature(85390, spell.Caster); // only affects undead;
    }
}

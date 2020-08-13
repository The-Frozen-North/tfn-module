//::///////////////////////////////////////////////
//:: Legend Lore
//:: NW_S0_Lore.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Gives the caster a boost to Lore skill of 10
    plus 1 / 2 caster levels.  Lasts for 1 Turn per
    caster level.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 22, 2001
//:://////////////////////////////////////////////
//:: 2003-10-29: GZ: Corrected spell target object
//::             so potions work wit henchmen now
/*
Patch 1.71

- the spell couldn't be recast if caster had also identify effect
*/

#include "70_inc_spells"
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
    int nLevel = spell.Level;
    int nBonus = 10 + (nLevel / 2);
    effect eLore = EffectSkillIncrease(SKILL_LORE, nBonus);
    effect eVis = EffectVisualEffect(VFX_IMP_MAGICAL_VISION);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eLore, eDur);

    //Meta-Magic checks
    if(spell.Meta & METAMAGIC_EXTEND)
    {
        nLevel *= 2;
    }

    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    //Apply linked and VFX effects
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nLevel));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
}

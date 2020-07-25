//::///////////////////////////////////////////////
//:: Monstrous Regeneration
//:: X2_S0_MonRegen
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Grants the selected target 3 HP of regeneration
    every round.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 25, 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Andrew Nobbs May 09, 2003
//:: 2003-07-07: Stacking Spell Pass, Georg Zoeller
/*
Patch 1.71

- duration doubled in order to balance with regenerate spell
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;

    if (!X2PreSpellCastCode())
    {
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    /* Bug fix 21/07/03: Andrew. Lowered regen to 3 HP per round, instead of 10. */
    effect eRegen = EffectRegenerate(3, 6.0);

    effect eVis = EffectVisualEffect(VFX_IMP_HEAD_NATURE);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    effect eLink = EffectLinkEffects(eRegen, eDur);

    int nLevel = spell.Level;

    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nLevel *= 2;
    }

    // Stacking Spellpass, 2003-07-07, Georg   ... just in case
    RemoveEffectsFromSpell(spell.Target, spell.Id);

    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    //Apply effects and VFX
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nLevel));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
}

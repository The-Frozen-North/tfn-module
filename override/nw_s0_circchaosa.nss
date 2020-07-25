//::///////////////////////////////////////////////
//:: Magic Cirle Against Chaos
//:: NW_S0_CircChaosA
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Add basic protection from chaos effects to
    entering allies.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow
//:: Created On: March 29, 2012
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.TargetType = SPELL_TARGET_ALLALLIES;

    aoesDeclareMajorVariables();
    object oTarget = GetEnteringObject();

    if(!GetHasSpellEffect(spell.Id,oTarget) && spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
    {
        //Declare major variables
        int nAlignment = ALIGNMENT_CHAOTIC;
        effect eAC = EffectACIncrease(2, AC_DEFLECTION_BONUS);
        eAC = VersusAlignmentEffect(eAC, nAlignment, ALIGNMENT_ALL);
        effect eSave = EffectSavingThrowIncrease(SAVING_THROW_ALL, 2);
        eSave = VersusAlignmentEffect(eSave, nAlignment, ALIGNMENT_ALL);
        effect eImmune = EffectImmunity(IMMUNITY_TYPE_MIND_SPELLS);
        eImmune = VersusAlignmentEffect(eImmune, nAlignment, ALIGNMENT_ALL);
        effect eDur = EffectVisualEffect(VFX_DUR_PROTECTION_EVIL_MINOR);

        effect eDur2 = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
        effect eLink = EffectLinkEffects(eImmune, eSave);
        eLink = EffectLinkEffects(eLink, eAC);
        eLink = EffectLinkEffects(eLink, eDur);
        eLink = EffectLinkEffects(eLink, eDur2);
        eLink = ExtraordinaryEffect(eLink);

        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id, FALSE));

        //Apply the VFX impact and effects
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);
    }
}

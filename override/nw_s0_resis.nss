//::///////////////////////////////////////////////
//:: Resistance
//:: NW_S0_Resis
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: This spell gives the recipiant a +1 bonus to
//:: all saves.  It lasts for 1 Turn.
//:://////////////////////////////////////////////
//:: Created By: Aidan Scanlan
//:: Created On: 01/12/01
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk, On: April 11, 2001
//:: VFX Pass By: Preston W, On: Aug 7, 2001

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
    effect eSave;
    effect eVis = EffectVisualEffect(VFX_IMP_HEAD_HOLY);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    int nBonus = 1; //Saving throw bonus to be applied
    int nDuration = 2; // Turns
    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    //Check for metamagic extend
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration * 2;
    }
    //Set the bonus save effect
    eSave = EffectSavingThrowIncrease(SAVING_THROW_ALL, nBonus);
    effect eLink = EffectLinkEffects(eSave, eDur);

    //Apply the bonus effect and VFX impact
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
}

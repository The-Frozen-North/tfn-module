//::///////////////////////////////////////////////
//:: Enervation
//:: NW_S0_Enervat.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Target Loses 1d4 levels for 1 hour per caster
    level
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 7, 2002
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 4;
    spell.DurationType = SPELL_DURATION_TYPE_HOURS;
    spell.SavingThrow = SAVING_THROW_FORT;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);

    int nDrain = MaximizeOrEmpower(spell.Dice,1,spell.Meta);
    int nDuration = spell.Level;
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

    effect eDrain = EffectNegativeLevel(nDrain);
    effect eLink = EffectLinkEffects(eDrain, eDur);

    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        //Resist magic check
        if(!MyResistSpell(spell.Caster, spell.Target))
        {
            if(!MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, SAVING_THROW_TYPE_NEGATIVE, spell.Caster))
            {
                //Apply the VFX impact and effects
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
            }
        }
    }
}

//::///////////////////////////////////////////////
//:: Flare
//:: [X0_S0_Flare.nss]
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creature hit by ray loses 1 to attack rolls.

    DURATION: 10 rounds.
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: July 17 2002
//:://////////////////////////////////////////////
/*
Patch 1.71

- spell no longer works on sightless creatures
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.SavingThrow = SAVING_THROW_FORT;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(VFX_IMP_FLAME_S);

    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));

        // * Apply the hit effect so player knows something happened
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
        if(!spellsIsSightless(spell.Target))
        {
            //Make SR Check
            if (!MyResistSpell(spell.Caster, spell.Target) && !MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, SAVING_THROW_TYPE_NONE, spell.Caster))
            {
                //Set damage effect
                effect eBad = EffectAttackDecrease(1);
                //Apply the VFX impact and damage effect
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBad, spell.Target, DurationToSeconds(10));
            }
        }
    }
}

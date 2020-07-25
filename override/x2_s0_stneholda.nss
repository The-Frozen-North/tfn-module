//::///////////////////////////////////////////////
//:: Stonehold
//:: X2_S0_StneholdA
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creates an area of effect that will cover the
    creature with a stone shell holding them in
    place.
*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: August  2003
//:: Updated   : October 2003
//:://////////////////////////////////////////////
/*
Patch 1.71

- AOE effects made undispellable
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    //Declare major variables
    aoesDeclareMajorVariables();
    effect eHold = EffectParalyze();
    effect eDur = EffectVisualEffect(VFX_DUR_STONEHOLD);
    effect eLink = EffectLinkEffects(eDur, eHold);
    eLink = ExtraordinaryEffect(eLink);

    //Get the first object in the persistant area
    object oTarget = GetEnteringObject();
    if(spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
        float fDelay = GetRandomDelay(0.45, 1.85);
        //Make a SR check
        if(!MyResistSpell(aoe.Creator, oTarget, fDelay))
        {
            //engine workaround to ensure no-roll behavior if immune to paralysis
            int nSaveType = GetIsImmune(oTarget, IMMUNITY_TYPE_PARALYSIS, aoe.Creator) ? /*SAVING_THROW_TYPE_PARALYSE*/20 : SAVING_THROW_TYPE_MIND_SPELLS;
            //Make a Fort Save
            if(!MySavingThrow(spell.SavingThrow, oTarget, spell.DC, nSaveType, aoe.Creator, fDelay))
            {
                int nRounds = MaximizeOrEmpower(6, 1, spell.Meta);
                //Apply the VFX impact and linked effects
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nRounds)));
            }
        }
    }
}

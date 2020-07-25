//::///////////////////////////////////////////////
//:: Stinking Cloud On Enter
//:: NW_S0_StinkCldA.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Those within the area of effect must make a
    fortitude save or be dazed.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 17, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- alignment immune creatures were ommited
- was missing immunity feedback
- missing delay for SR and saving throw VFX added
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    //Declare major variables
    aoesDeclareMajorVariables();
    effect eStink = EffectDazed();
    effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink = EffectLinkEffects(eMind, eStink);
    eLink = EffectLinkEffects(eLink, eDur);

    effect eVis = EffectVisualEffect(VFX_IMP_DAZED_S);
    //Get the first object in the persistant area
    object oTarget = GetEnteringObject();
    if (spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
    {
        float fDelay = GetRandomDelay(0.75, 1.75);
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
        //Make a SR check
        if(!MyResistSpell(aoe.Creator, oTarget))
        {
            //Make a Fort Save
            if(!MySavingThrow(spell.SavingThrow, oTarget, spell.DC, SAVING_THROW_TYPE_POISON, aoe.Creator))
            {
                //Apply the VFX impact and linked effects
                if (!GetIsImmune(oTarget, IMMUNITY_TYPE_POISON, aoe.Creator))
                {
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(2)));
                }
                else
                {
                    //engine workaround to get proper immunity feedback
                    ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectPoison(POISON_ETTERCAP_VENOM), oTarget);
                }
            }
        }
    }
}

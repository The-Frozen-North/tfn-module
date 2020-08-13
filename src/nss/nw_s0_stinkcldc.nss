//::///////////////////////////////////////////////
//:: Stinking Cloud
//:: NW_S0_StinkCldC.nss
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
Patch 1.71

- corrected delay for VFX/saves applications
- alignment immune creatures were ommited
- was missing immunity feedback
- now properly removes any old daze effects, if the target succeds in the save
- added caster validity check
- AOE effects made undispellable
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    //Declare major variables
    aoesDeclareMajorVariables();

    //--------------------------------------------------------------------------
    // When the caster is no longer there, all functions calling
    // GetAreaOfEffectCreator will fail. Its better to remove the barrier then
    //--------------------------------------------------------------------------
    if(aoe.Creator != OBJECT_INVALID && !GetIsObjectValid(aoe.Creator))
    {
        DestroyObject(aoe.AOE);
        return;
    }

    effect eStink = EffectDazed();
    effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink = EffectLinkEffects(eMind, eStink);
    eLink = EffectLinkEffects(eLink, eDur);
    eLink = ExtraordinaryEffect(eLink);

    effect eVis = EffectVisualEffect(VFX_IMP_DAZED_S);
    effect eFind;
    float fDelay;
    //Get the first object in the persistant area
    object oTarget = GetFirstInPersistentObject(aoe.AOE);
    while(GetIsObjectValid(oTarget))
    {
        if(spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
            fDelay = GetRandomDelay(0.75, 1.75);
            //Make a SR check
            if(!MyResistSpell(aoe.Creator, oTarget, fDelay))
            {
                //Make a Fort Save
                if(!MySavingThrow(spell.SavingThrow, oTarget, spell.DC, SAVING_THROW_TYPE_POISON, aoe.Creator, fDelay))
                {
                   //Apply the VFX impact and linked effects
                   if(!GetIsImmune(oTarget, IMMUNITY_TYPE_POISON, aoe.Creator))
                   {
                       DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(2)));
                   }
                   else
                   {
                       //engine workaround to get proper immunity feedback
                       ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectPoison(POISON_ETTERCAP_VENOM), oTarget);
                   }
                }
                else
                {
                    //If the Fort save was successful remove the Dazed effect
                    eFind = GetFirstEffect(oTarget);
                    while(GetIsEffectValid(eFind))
                    {
                        if(GetEffectSpellId(eFind) == spell.Id && GetEffectCreator(eFind) == aoe.Creator)
                        {
                            RemoveEffect(oTarget, eFind);
                        }
                        eFind = GetNextEffect(oTarget);
                    }
                }
            }
        }
        //Get next target in spell area
        oTarget = GetNextInPersistentObject(aoe.AOE);
    }
}

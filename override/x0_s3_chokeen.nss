//::///////////////////////////////////////////////
//:: x0_s3_chokeen
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Choke effect on entering object
*/
//:://////////////////////////////////////////////
//:: Created By:
//:: Created On:
//:://////////////////////////////////////////////
/*
Patch 1.72
- effects made undispellable (extraordinary)
Patch 1.70
- script signalized wrong spell id
- alignment immune creatures were omitted
- was missing immunity feedback
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //declare major variables
    aoesDeclareMajorVariables();
    object oTarget = GetEnteringObject();
    effect eStink = EffectDazed();
    effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink = EffectLinkEffects(eMind, eStink);
    eLink = EffectLinkEffects(eLink, eDur);
    eLink = ExtraordinaryEffect(eLink);

    effect eVis = EffectVisualEffect(VFX_IMP_DAZED_S);

    if(spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, aoe.Creator))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
        //Make a Fort Save
        if(!MySavingThrow(SAVING_THROW_FORT, oTarget, spell.DC, SAVING_THROW_TYPE_POISON, aoe.Creator))
        {                                             //13+innate lvl=16
            if(!GetIsImmune(oTarget, IMMUNITY_TYPE_POISON, aoe.Creator))
            {
                float fDelay = GetRandomDelay(0.75, 1.75);
                //Apply the VFX impact and linked effects
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

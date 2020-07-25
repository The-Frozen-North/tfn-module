//::///////////////////////////////////////////////
//:: x0_s3_chokehb
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Heartbeat script for choking powder.
    Every round make a saving throw
    or be dazed.
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
    //Declare major variables
    aoesDeclareMajorVariables();
    effect eStink = EffectDazed();
    effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink = EffectLinkEffects(eMind, eStink);
    eLink = EffectLinkEffects(eLink, eDur);
    eLink = ExtraordinaryEffect(eLink);

    effect eVis = EffectVisualEffect(VFX_IMP_DAZED_S);
    float fDelay;
    //Get the first object in the persistant area
    object oTarget = GetFirstInPersistentObject(aoe.AOE);
    while(GetIsObjectValid(oTarget))
    {
        if(spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, aoe.Creator))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
            fDelay = GetRandomDelay(0.75, 1.75);
            //Make a SR check
            if(!MyResistSpell(aoe.Creator, oTarget, fDelay))
            {
                //Make a Fort Save
                if(!MySavingThrow(SAVING_THROW_FORT, oTarget, spell.DC, SAVING_THROW_TYPE_POISON, aoe.Creator, fDelay))
                {                                             //13+innate lvl=16
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
            }
        }
        //Get next target in spell area
        oTarget = GetNextInPersistentObject(aoe.AOE);
    }
}

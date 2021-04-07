//::///////////////////////////////////////////////
//:: Pulse: Level Drain
//:: NW_S1_PulsLvlDr
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    A wave of energy emanates from the creature which affects
    all within 10ft.  Damage can be reduced by half for all
    damaging variants.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 14, 2000
//:://////////////////////////////////////////////
/*
Patch 1.70

- wrong target check (could affect other NPCs)
- was missing signal event
- made the effect supernatural in order to remain after resting
*/

#include "x0_i0_spells"

void main()
{
    //Declare major variables
    effect eVis = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
//    effect eHowl;
    float fDelay;
    int nHD = GetHitDice(OBJECT_SELF);
    int nDC = 10 + nHD;
    effect eImpact = EffectVisualEffect(VFX_IMP_PULSE_NEGATIVE);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, GetLocation(OBJECT_SELF));
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetLocation(OBJECT_SELF));
    //Get first target in spell area
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != OBJECT_SELF && spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_PULSE_LEVEL_DRAIN));
            fDelay = GetSpellEffectDelay(GetLocation(OBJECT_SELF), oTarget)/20;
            //Make a saving throw check
            if(!MySavingThrow(SAVING_THROW_FORT, oTarget, nDC, SAVING_THROW_TYPE_NEGATIVE, OBJECT_SELF, fDelay))
            {
                //Apply the VFX impact and effects
//                eHowl = EffectNegativeLevel(1);
//                eHowl = SupernaturalEffect(eHowl);
                //engine workaround in order to pass the id of -1 into effect for AI purposes
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(EffectNegativeLevel(1)), oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
            }
        }
        //Get next target in spell area
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetLocation(OBJECT_SELF));
    }
}

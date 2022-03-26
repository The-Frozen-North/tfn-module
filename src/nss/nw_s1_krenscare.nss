//::///////////////////////////////////////////////
//:: Krenshar Fear Stare
//:: NW_S1_KrenScare
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Causes those in the gaze to be struck with fear
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 8, 2002
//:://////////////////////////////////////////////
/*
Patch 1.71

- area of effect distance united with other gaze spell abilities
- added scaling into fear effect and duration
*/

#include "x0_i0_spells"

void main()
{
    //Declare major variables
//    effect eVis = EffectVisualEffect(VFX_IMP_FEAR_S); //invalid vfx
    effect eFear = EffectFrightened();
    effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    //Link the fear and mind effects
    effect eLink = EffectLinkEffects(eMind, eDur);
    float fDelay;
    location lTarget = GetSpellTargetLocation();
    //Get first target in the spell cone
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_CONE, 11.0, lTarget, TRUE);
    effect scaledEffect;
    while(GetIsObjectValid(oTarget))
    {
        //Make faction check
        if(oTarget != OBJECT_SELF && spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
        {
            fDelay = GetDistanceToObject(oTarget)/20;
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_KRENSHAR_SCARE));
            //Make a will save
            if(!MySavingThrow(SAVING_THROW_WILL, oTarget, 12, SAVING_THROW_TYPE_FEAR))
            {
                scaledEffect = GetScaledEffect(eFear, oTarget);
                scaledEffect = EffectLinkEffects(eLink, scaledEffect);
                //Apply the linked effects and the VFX impact
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, scaledEffect, oTarget, RoundsToSeconds(3)));
            }
        }
        //Get next target in the spell cone
        oTarget = FIX_GetNextObjectInShape(SHAPE_CONE, 11.0, lTarget, TRUE);
    }
}

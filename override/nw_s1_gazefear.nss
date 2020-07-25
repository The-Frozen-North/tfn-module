//::///////////////////////////////////////////////
//:: Gaze: Fear
//:: NW_S1_GazeFear
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Cone shape that affects all within the AoE if they
    fail a Will Save.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 9, 2001
//:://////////////////////////////////////////////
/*
Patch 1.71

- blinded/sightless creatures are not affected anymore
- wrong target check (could affect other NPCs)
- added scaling into fear effect
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    if( GZCanNotUseGazeAttackCheck(OBJECT_SELF))
    {
        return;
    }

    //Declare major variables
    int nHD = GetHitDice(OBJECT_SELF);
    int nDuration = 1 + (nHD/3);
    int nDC = 10 + (nHD/2);
    location lTargetLocation = GetSpellTargetLocation();
    effect eGaze = EffectFrightened();
//    effect eVis = EffectVisualEffect(VFX_IMP_FEAR_S); //invalid vfx
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eVisDur = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);

    effect eLink = EffectLinkEffects(eDur, eVisDur);
    effect scaledEffect;
    int scaledDuration;
    //Get first target in spell area
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPELLCONE, 11.0, lTargetLocation, TRUE);
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != OBJECT_SELF && spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_GAZE_FEAR));
            //Determine effect delay
            float fDelay = GetDistanceBetween(OBJECT_SELF, oTarget)/20;
            if(GetIsAbleToSee(oTarget) && !MySavingThrow(SAVING_THROW_WILL, oTarget, nDC, SAVING_THROW_TYPE_FEAR, OBJECT_SELF, fDelay))
            {
                scaledDuration = GetScaledDuration(nDuration, oTarget);
                scaledEffect = GetScaledEffect(eGaze, oTarget);
                scaledEffect = EffectLinkEffects(eLink, scaledEffect);
                //Apply the VFX impact and effects
//                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, scaledEffect, oTarget, RoundsToSeconds(scaledDuration)));
            }
        }
        //Get next target in spell area
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPELLCONE, 11.0, lTargetLocation, TRUE);
    }
}

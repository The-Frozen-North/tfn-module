//::///////////////////////////////////////////////
//:: Howl: Paralysis
//:: NW_S1_HowlParal
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    A howl emanates from the creature which affects
    all within 10ft unless they make a save.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 14, 2000
//:://////////////////////////////////////////////
/*
Patch 1.71

- deaf/silenced creatures are not affected anymore
- wrong target check (could affect other NPCs)
- wrong duration calculation (cumulative for each target in AoE)
- added saving throw subtype (paralyse)
- added stun VFX and scaling into paralyse effect
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //Declare major variables
    effect eVis = EffectVisualEffect(VFX_IMP_STUN);
    effect eHowl = EffectParalyze();
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eDur2 = EffectVisualEffect(VFX_DUR_PARALYZE_HOLD);
    effect eImpact = EffectVisualEffect(VFX_FNF_HOWL_ODD);

    effect eLink = EffectLinkEffects(eDur2, eDur);
    float fDelay;
    int nHD = GetHitDice(OBJECT_SELF);
    int nDC = 10 + (nHD/4);
    int nDuration = 1 + (nHD/4);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, OBJECT_SELF);
    //Get first target in spell area
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, GetLocation(OBJECT_SELF));
    effect scaledEffect;
    int scaledDuration;
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != OBJECT_SELF && spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
        {
            fDelay = GetDistanceToObject(oTarget)/10;
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_HOWL_PARALYSIS));

            //Make a saving throw check
            if(GetIsAbleToHear(oTarget) && !MySavingThrow(SAVING_THROW_WILL, oTarget, nDC, /*SAVING_THROW_TYPE_PARALYSE*/20, OBJECT_SELF, fDelay))
            {
                scaledDuration = GetScaledDuration(nDuration , oTarget);
                scaledEffect = GetScaledEffect(eHowl, oTarget);
                scaledEffect = EffectLinkEffects(eLink, scaledEffect);
                //Apply the VFX impact and effects
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, scaledEffect, oTarget, RoundsToSeconds(scaledDuration)));
            }
        }
        //Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, GetLocation(OBJECT_SELF));
    }
}

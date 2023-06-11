//::///////////////////////////////////////////////
//:: Howl: Fear
//:: NW_S1_HowlFear
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
//:: Updated By: Andrew Nobbs
//:: Updated On: FEb 26, 2003
//:: Note: Changed the faction check to GetIsEnemy
//:://////////////////////////////////////////////
/*
Patch 1.72
- made effects supernatural - undispellable
Patch 1.71
- deaf/silenced creatures are not affected anymore
- wrong target check (could affect other NPCs)
- added scaling into fear effect
- added missing delay in saving throw VFX
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //Declare major variables
//    effect eVis = EffectVisualEffect(VFX_IMP_FEAR_S); //invalid vfx
    effect eHowl = EffectFrightened();
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eDur2 = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
    effect eImpact = EffectVisualEffect(VFX_FNF_HOWL_MIND);

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
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_HOWL_FEAR));

            //Make a saving throw check
            if(GetIsAbleToHear(oTarget) && !MySavingThrow(SAVING_THROW_WILL, oTarget, nDC, SAVING_THROW_TYPE_FEAR, OBJECT_SELF, fDelay))
            {
                scaledDuration = GetScaledDuration(nDuration, oTarget);
                scaledEffect = GetScaledEffect(eHowl, oTarget);
                scaledEffect = EffectLinkEffects(eLink, scaledEffect);
                //Apply the VFX impact and effects
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, SupernaturalEffect(scaledEffect), oTarget, RoundsToSeconds(scaledDuration)));
//                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
            }
        }
        //Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, GetLocation(OBJECT_SELF));
    }
}

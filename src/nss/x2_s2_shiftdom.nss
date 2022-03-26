//::///////////////////////////////////////////////
//:: Gaze: Dominate (Shifter)
//:: x2_s2_shiftdom
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Cone shape that affects all within the AoE if they
    fail a Will Save.

*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: Oct, 2003
//:://////////////////////////////////////////////
/*
Patch 1.70

- ability could been wasted on mind immune target
*/

#include "x0_i0_spells"
#include "x2_inc_shifter"

void main()
{
    //-------------------------------------------------------------------------
    // If blinded, I am not able to use this attack
    //--------------------------------------------------------------------------
    if( GZCanNotUseGazeAttackCheck(OBJECT_SELF))
    {
        return;
    }

    //--------------------------------------------------------------------------
    // Enforce artifical use limit on that ability
    //--------------------------------------------------------------------------
    /*if (ShifterDecrementGWildShapeSpellUsesLeft() <1 )
    {
        FloatingTextStrRefOnCreature(83576, OBJECT_SELF);
        return;
    }*/

    //--------------------------------------------------------------------------
    // Set up save DC and duration
    //--------------------------------------------------------------------------
    int nDuration = Random(GetAbilityModifier(ABILITY_WISDOM))+d4();
    int nDC = ShifterGetSaveDC(OBJECT_SELF,SHIFTER_DC_VERY_EASY) + GetAbilityModifier(ABILITY_WISDOM);

    location lTargetLocation = GetSpellTargetLocation();
    effect eGaze = EffectDominated();
    effect eVis = EffectVisualEffect(VFX_IMP_DOMINATE_S);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eVisDur = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DOMINATED);
    effect eLink = EffectLinkEffects(eDur, eVisDur);


    //--------------------------------------------------------------------------
    // Loop through all targets in the cone, but only dominate one!
    //--------------------------------------------------------------------------
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPELLCONE, 10.0, lTargetLocation, TRUE);
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != OBJECT_SELF && spellsIsTarget(oTarget,SPELL_TARGET_SELECTIVEHOSTILE,OBJECT_SELF))
        {
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_GAZE_DOMINATE));
            float fDelay = GetDistanceBetween(OBJECT_SELF, oTarget)/20;
            if(!GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, OBJECT_SELF))
            {
                if(!MySavingThrow(SAVING_THROW_WILL, oTarget, nDC, SAVING_THROW_TYPE_MIND_SPELLS, OBJECT_SELF, fDelay))
                {
                    //--------------------------------------------------------------------------
                    // Effects do not stack
                    //--------------------------------------------------------------------------
                    if (!GetHasSpellEffect(GetSpellId(),oTarget))
                    {
                        eGaze = GetScaledEffect(eGaze, oTarget);
                        eLink = EffectLinkEffects(eLink, eGaze);
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration)));
                        break;
                    }
                }
            }
        }
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPELLCONE, 10.0, lTargetLocation, TRUE);
    }
}

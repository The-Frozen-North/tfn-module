//::///////////////////////////////////////////////
//:: Howl of Doom
//:: NW_S1_HowlDoom
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    All those that fail the save are struck with the
    doom effect
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 8, 2002
//:://////////////////////////////////////////////
/*
Patch 1.71

- deaf/silenced creatures are not affected anymore
- wrong target check (could affect other NPCs)
- added missing delay in saving throw VFX
- this howl didn't worked before at all
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //Declare major variables
    int nHD = GetHitDice(OBJECT_SELF);
    int nDC = 10 + (nHD/4);
    int nDuration = 1 + (nHD/4);
    effect eLink = CreateDoomEffectsLink();
    effect eVis = EffectVisualEffect(VFX_IMP_DOOM);
    effect eImpact = EffectVisualEffect(VFX_FNF_HOWL_ODD);
    float fDelay;
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, OBJECT_SELF);
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, GetLocation(OBJECT_SELF));
    //Get first target in spell area
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != OBJECT_SELF && spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
        {
            fDelay = GetDistanceToObject(oTarget)/10;
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_HOWL_DOOM));
            if(GetIsAbleToHear(oTarget) && !MySavingThrow(SAVING_THROW_WILL, oTarget, nDC, SAVING_THROW_TYPE_NONE, OBJECT_SELF, fDelay))
            {
                //Apply the VFX impact and effects
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration)));
            }
        }
        //Get next target in spell area
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, GetLocation(OBJECT_SELF));
    }
}

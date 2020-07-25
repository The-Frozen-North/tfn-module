//::///////////////////////////////////////////////
//:: Pulse: Strength Drain
//:: NW_S1_PulsDeath
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
*/

#include "x0_i0_spells"

void main()
{
    //Declare major variables
    int nDamage = GetHitDice(OBJECT_SELF)/5;
    if (nDamage < 1)
    {
        nDamage = 1;
    }
    float fDelay;
    int nHD = GetHitDice(OBJECT_SELF);
    int nDC = 10 + nHD;
    effect eImpact = EffectVisualEffect(VFX_IMP_PULSE_NEGATIVE);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, OBJECT_SELF);
    effect eVis = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
    effect eHowl;
    //Get first target in spell area
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetLocation(OBJECT_SELF));
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != OBJECT_SELF && spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_PULSE_ABILITY_DRAIN_STRENGTH));
            //Determine effect delay
            fDelay = GetDistanceBetween(OBJECT_SELF, oTarget)/20;
            //Make a saving throw check
            if(!MySavingThrow(SAVING_THROW_FORT, oTarget, nDC, SAVING_THROW_TYPE_NEGATIVE, OBJECT_SELF, fDelay))
            {
                //Set the Ability mod and change to supernatural effect
                eHowl = EffectAbilityDecrease(ABILITY_STRENGTH, nDamage);
                eHowl = SupernaturalEffect(eHowl);
                //Apply the VFX impact and effects
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_PERMANENT, eHowl, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
            }
        }
        //Get first target in spell area
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetLocation(OBJECT_SELF));
    }
}

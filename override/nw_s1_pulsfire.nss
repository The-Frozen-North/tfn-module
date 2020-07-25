//::///////////////////////////////////////////////
//:: Pulse: Fire
//:: NW_S1_PulsFire
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

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //Declare major variables
    int nDamage;
    effect eVis = EffectVisualEffect(VFX_IMP_FLAME_S);
    effect eHowl;
    float fDelay;
    int nHD = GetHitDice(OBJECT_SELF);
    int nDC = 10 + nHD;
    effect eImpact = EffectVisualEffect(VFX_IMP_PULSE_FIRE);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, OBJECT_SELF);
    //Get first target in spell area
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetLocation(OBJECT_SELF));
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != OBJECT_SELF && spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_PULSE_FIRE));
            //Roll the damage
            nDamage = d6(nHD);
            //Adjust the damage based on the Reflex Save, Evasion and Improved Evasion.
            nDamage = GetSavingThrowAdjustedDamage(nDamage, oTarget, nDC, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_FIRE);
            //Determine effect delay
            fDelay = GetDistanceBetween(OBJECT_SELF, oTarget)/20;
            if(nDamage > 0)
            {
                eHowl = EffectDamage(nDamage, DAMAGE_TYPE_FIRE);
                //Apply the VFX impact and effects
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eHowl, oTarget));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
            }
        }
        //Get next target in spell area
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetLocation(OBJECT_SELF));
    }
}

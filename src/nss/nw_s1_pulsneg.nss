//::///////////////////////////////////////////////
//:: Pulse: Negative
//:: NW_S1_PulsDeath
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    A wave of energy emanates from the creature which affects
    all within 10ft.  Damage can be reduced by half for all
    damaging variants.  Undead are healed.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 14, 2000
//:://////////////////////////////////////////////
/*
Patch 1.70

- wrong target check (could affect other NPCs)
- did signalized wrong spell id
- signal event wasn't signalized properly in case of non-undead target
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //Declare major variables
    int nDamage;
    float fDelay;
    effect eVis = EffectVisualEffect(VFX_IMP_HEALING_M);
    effect eVis2 = EffectVisualEffect(VFX_IMP_NEGATIVE_ENERGY);
    effect eHowl;
    int nHD = GetHitDice(OBJECT_SELF);
    int nDC = 10 + nHD;
    effect eImpact = EffectVisualEffect(VFX_IMP_PULSE_NEGATIVE);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, OBJECT_SELF);
    //Get first target in spell area
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetLocation(OBJECT_SELF));
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != OBJECT_SELF)
        {
            //Determine effect delay
            fDelay = GetDistanceBetween(OBJECT_SELF, oTarget)/20;
            //Roll the amount to heal or damage
            nDamage = d4(nHD);
            //If the target is undead
            if(spellsIsRacialType(oTarget, RACIAL_TYPE_UNDEAD))
            {
                //Make a faction check
                if(spellsIsTarget(oTarget, SPELL_TARGET_ALLALLIES, OBJECT_SELF))
                {
                    //Fire cast spell at event for the specified target
                    SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_PULSE_NEGATIVE, FALSE));
                    //Set heal effect
                    eHowl = EffectHeal(nDamage);
                    //Apply the VFX impact and effects
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eHowl, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                }
            }
            else if(spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_PULSE_NEGATIVE));
                //Adjust the damage based on the Reflex Save, Evasion and Improved Evasion.
                nDamage = GetSavingThrowAdjustedDamage(nDamage, oTarget, nDC, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_NEGATIVE);
                if(nDamage > 0)
                {
                    //Set damage effect
                    eHowl = EffectDamage(nDamage, DAMAGE_TYPE_NEGATIVE);
                    //Apply the VFX impact and effects
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eHowl, oTarget));
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, oTarget));
                }
            }
        }
        //Get next target in spell area
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetLocation(OBJECT_SELF));
    }
}

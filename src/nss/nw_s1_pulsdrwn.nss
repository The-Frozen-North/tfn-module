//::///////////////////////////////////////////////
//:: Pulse Drown
//:: NW_S1_PulsDrwn
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    CHANGED JANUARY 2003
     - does an actual 'drown spell' on each target
     in the area of effect.
     - Each use of this spells consumes 50% of the
     elementals hit points.

*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watmaniuk
//:: Created On: April 15, 2002
//:://////////////////////////////////////////////
/*
Patch 1.70

- wrong target check (could affect other NPCs)
- added additional creatures being immune: oozes and various creatures of water
or aquatic subtype
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main ()
{
    int nDamage = GetCurrentHitPoints() / 2;
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage), OBJECT_SELF);
    //Declare major variables
    effect eVis = EffectVisualEffect(VFX_IMP_FROST_S);

    effect eImpact = EffectVisualEffect(VFX_IMP_PULSE_WATER);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, OBJECT_SELF);

    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetLocation(OBJECT_SELF));
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != OBJECT_SELF && spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_PULSE_DROWN));
            //Handle immune creatures
            if(spellsIsImmuneToDrown(oTarget))
            {
                //engine workaround to get immunity feedback
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectSpellImmunity(GetSpellId()), oTarget, 0.01);
                MyResistSpell(OBJECT_SELF, oTarget);
            }
            //Make a fortitude save                              //workaround for action cancel bug without changing save type
            else if(!MySavingThrow(SAVING_THROW_FORT, oTarget, 20, GetIsImmune(oTarget, IMMUNITY_TYPE_DEATH, OBJECT_SELF) ? SAVING_THROW_TYPE_DEATH : SAVING_THROW_TYPE_NONE))
            {
                //Apply the VFX impact and damage effect
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
                //Set damage effect to kill the target
                ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), oTarget);
            }
        }
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, GetLocation(OBJECT_SELF));
    }
}

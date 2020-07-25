//::///////////////////////////////////////////////
//:: Thunderstone
//:: x0_s3_thunder
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
 All creatures in area of effect must make a FORT
 save vs.DC 15 or be deaf for 5 rounds.
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: September 10, 2002
//:://////////////////////////////////////////////
/*
Patch 1.72
- effects made undispellable (extraordinary)
- added sonic subtype into saving throw
Patch 1.70
- wrong target check (could affect other NPCs)
*/

#include "x0_i0_spells"

void main()
{
    //Declare major variables
    object oCaster = OBJECT_SELF;
    int nDamage;
    float fDelay;
    effect eExplode = EffectVisualEffect(VFX_FNF_LOS_NORMAL_30);
    effect eVis = EffectVisualEffect(VFX_IMP_HEAD_NATURE);
    effect eDeaf = ExtraordinaryEffect(EffectDeaf());
    effect eShake = EffectVisualEffect(VFX_FNF_SCREEN_SHAKE);
    //Get the spell target location as opposed to the spell target.
    location lTarget = GetSpellTargetLocation();
    int nDuration = 5;

    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eShake, OBJECT_SELF, RoundsToSeconds(3));

    //Apply epicenter explosion on caster
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eExplode, lTarget);
    //Declare the spell shape, size and the location.  Capture the first target object in the shape.
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, lTarget, TRUE, OBJECT_TYPE_CREATURE);
    //Cycle through the targets within the spell shape until an invalid object is captured.
    while (GetIsObjectValid(oTarget))
    {
        if(oTarget != oCaster && spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, oCaster))
        {
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId(), TRUE));
            //Get the distance between the explosion and the target to calculate delay
            fDelay = GetDistanceBetweenLocations(lTarget, GetLocation(oTarget))/20;
            if(!MySavingThrow(SAVING_THROW_FORT, oTarget, 15, SAVING_THROW_TYPE_SONIC, oCaster))
            {
                // Apply effects to the currently selected target.
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDeaf, oTarget, RoundsToSeconds(nDuration)));
                //This visual effect is applied to the target object not the location as above.  This visual effect
                //represents the flame that erupts on the target not on the ground.
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
            }
        }
        //Select the next target within the spell shape.
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, lTarget, TRUE, OBJECT_TYPE_CREATURE);
    }
}

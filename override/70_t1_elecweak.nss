//::///////////////////////////////////////////////
//:: Weak Electrical Trap
//:: 70_t1_elecweak
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
2-11 damage, reflex DC 9 evasion allowed, one secondary target
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.70
//:: Created On: 03-04-2011
//:://////////////////////////////////////////////

#include "70_inc_spells"

void main()
{
    //1.72: fix for bug where traps are being triggered where they really aren't
    if(GetObjectType(OBJECT_SELF) == OBJECT_TYPE_TRIGGER && !GetIsInSubArea(GetEnteringObject()))
    {
        return;
    }
    //Declare major variables
    object oTarget = GetEnteringObject();
    effect eLightning = EffectBeam(VFX_BEAM_LIGHTNING, oTarget, BODY_NODE_CHEST);
    effect eDam;
    effect eVis = EffectVisualEffect(VFX_IMP_LIGHTNING_S);
    location lTarget = GetLocation(oTarget);
    //Adjust the trap damage based on the feats of the target
    int nDamage = GetSavingThrowAdjustedDamage(d3()+d8(), oTarget, 9, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_TRAP);

    if (nDamage > 0)
    {
        eDam = EffectDamage(nDamage, DAMAGE_TYPE_ELECTRICAL);
        DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
    }

    object o2ndTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, lTarget);
    while (GetIsObjectValid(o2ndTarget))
    {
        //check to see that the original target is not hit again.
        if(o2ndTarget != oTarget && !GetIsReactionTypeFriendly(oTarget))
        {
            //Adjust the trap damage based on the feats of the target
            nDamage = GetSavingThrowAdjustedDamage(d3()+d8(), o2ndTarget, 9, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_TRAP);

            if (nDamage > 0)
            {
                //Set the damage effect
                eDam = EffectDamage(nDamage, DAMAGE_TYPE_ELECTRICAL);
                //Apply the VFX impact and damage effect
                DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, o2ndTarget));
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, o2ndTarget);
            }

            //Connect the lightning stream from one target to another.
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLightning, o2ndTarget, 0.75);
            //Set the last target as the new start for the lightning stream
            eLightning = EffectBeam(VFX_BEAM_LIGHTNING, o2ndTarget, BODY_NODE_CHEST);
            return;//only one target so we are done here
        }
        //Get next target in the shape.
        o2ndTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, lTarget);
    }
}

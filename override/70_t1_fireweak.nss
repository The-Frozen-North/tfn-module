//::///////////////////////////////////////////////
//:: Weak Fire Trap
//:: 70_t1_fireweak
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
3d2 fire damage to all in aoe, reflex save vs DC 10 evasion allowed
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
    location lTarget = GetLocation(oTarget);
    int nDamage;
    effect eVis = EffectVisualEffect(VFX_IMP_FLAME_M);
    effect eDam;

    //Get first object in the target area
    oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_SMALL, lTarget);
    //Cycle through the target area until all object have been targeted
    while(GetIsObjectValid(oTarget))
    {
        if(!GetIsReactionTypeFriendly(oTarget))
        {
            //Adjust the trap damage based on the feats of the target
            nDamage = GetSavingThrowAdjustedDamage(d2(3),oTarget, 10, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_TRAP);

            if (nDamage > 0)
            {
                //Apply effects to the target.
                eDam = EffectDamage(nDamage, DAMAGE_TYPE_FIRE);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
                DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
            }
        }
        //Get next target in shape
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_SMALL, lTarget);
    }
}

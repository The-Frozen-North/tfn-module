//::///////////////////////////////////////////////
//:: Epic Tangle Trap
//:: 70_t1_tangepic
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
slow for 10 rounds, reflex save vs DC 40 negates
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.70
//:: Created On: 03-04-2011
//:://////////////////////////////////////////////

#include "nw_i0_spells"

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
    effect eSlow = EffectSlow();
    effect eVis = EffectVisualEffect(VFX_IMP_SLOW);

    //Find first target in the size
    oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_SMALL, lTarget);
    //Cycle through the objects in the radius
    while (GetIsObjectValid(oTarget))
    {
        if(!GetIsReactionTypeFriendly(oTarget))
        {
            if(!MySavingThrow(SAVING_THROW_REFLEX, oTarget, 40, SAVING_THROW_TYPE_TRAP))
            {
                //Apply slow effect and slow effect
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSlow, oTarget, TurnsToSeconds(1));
            }
        }
        //Get next target in the shape.
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_SMALL, lTarget);
    }
}

//::///////////////////////////////////////////////
//:: Deadly Tangle Trap
//:: NW_T1_TangStrC
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Targets within 10ft of the entering character
    are slowed unless they make a reflex save with
    a DC of 35.  Effect lasts for 5 Rounds
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 4th, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- was missing target check (trap could affect party members on low difficulty)
*/

#include "nw_i0_spells"

void main()
{
    //1.72: fix for bug where traps are being triggered where they really aren't
    if(GetObjectType(OBJECT_SELF) == OBJECT_TYPE_TRIGGER && !GetIsInSubArea(GetEnteringObject()))
    {
        return;
    }
    //Declare major variables
    int nDuration = 5;
    object oTarget = GetEnteringObject();
    location lTarget = GetLocation(oTarget);
    effect eSlow = EffectSlow();
    effect eVis = EffectVisualEffect(VFX_IMP_SLOW);

    //Find first target in the size
    oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, lTarget);
    //Cycle through the objects in the radius
    while (GetIsObjectValid(oTarget))
    {
        if(!GetIsReactionTypeFriendly(oTarget))
        {
            if(!MySavingThrow(SAVING_THROW_REFLEX, oTarget, 35, SAVING_THROW_TYPE_TRAP))
            {
                //Apply slow effect and slow effect
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSlow, oTarget, RoundsToSeconds(nDuration));
            }
        }
        //Get next target in the shape.
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, lTarget);
    }
}

//::///////////////////////////////////////////////
//:: Average Fire Trap
//:: NW_T1_FireAvgC
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Does 8d6 damage to all within 5 ft.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 4th, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- old evasion behaviour (now that evasion is applied will appear in log)
*/

#include "70_inc_spells"
#include "inc_trap"

void main()
{
    //1.72: fix for bug where traps are being triggered where they really aren't
    if(GetObjectType(OBJECT_SELF) == OBJECT_TYPE_TRIGGER && !GetIsInSubArea(GetEnteringObject()))
    {
        return;
    }
    //Declare major variables
    int bValid;
    object oTarget = GetEnteringObject();
    location lTarget = GetLocation(oTarget);
    int nDamage;
    effect eVis = EffectVisualEffect(VFX_IMP_FLAME_M, FALSE, TRAP_VFX_SIZE_AVERAGE);
    effect eDam;
    int nSaveDC = 20;

    //Get first object in the target area
    oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_SMALL, lTarget);
    //Cycle through the target area until all object have been targeted
    while(GetIsObjectValid(oTarget))
    {
        if(!GetIsReactionTypeFriendly(oTarget))
        {
            //Roll damage
            nDamage = d6(8);
            //Adjust the trap damage based on the feats of the target
            nDamage = GetSavingThrowAdjustedDamage(nDamage,oTarget,nSaveDC,SAVING_THROW_REFLEX,SAVING_THROW_TYPE_TRAP);

            if (nDamage > 0)
            {
                //Apply effects to the target.
                eDam = EffectDamage(nDamage, DAMAGE_TYPE_FIRE);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
                DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
                SetTrapTriggeredOnCreature(oTarget, "average fire trap");
            }
            //Get next target in shape
        }
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_SMALL, lTarget);
    }
}

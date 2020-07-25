//::///////////////////////////////////////////////
//:: Electrical Trap
//:: NW_T1_ElecStrC.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The creature setting off the trap is struck by
    a strong electrical current that arcs to 5 other
    targets doing 20d6 damage.  Can make a Reflex
    save for half damage.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 30, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- old evasion behaviour (now that evasion is applied will appear in log)
- all secondary targets took the same damage
- strucked one more creature above intended limit
- will make a lightning beams even on those who do not take any damage and on
the first target
- saving throw subtype changed to traps
*/

#include "70_inc_spells"

void main()
{
    //1.72: fix for bug where traps are being triggered where they really aren't
    if(GetObjectType(OBJECT_SELF) == OBJECT_TYPE_TRIGGER && !GetIsInSubArea(GetEnteringObject()))
    {
        return;
    }
    //Declare major variables
    int nSaveDC = 26;
    int nSecondary = 5;
    object oTarget = GetEnteringObject();
    effect eLightning = EffectBeam(VFX_BEAM_LIGHTNING, oTarget, BODY_NODE_CHEST);
    effect eDam;
    effect eVis = EffectVisualEffect(VFX_IMP_LIGHTNING_S);
    location lTarget = GetLocation(oTarget);
    int nCount = 0;
    //Adjust the trap damage based on the feats of the target
    int nDamage = GetSavingThrowAdjustedDamage(d6(20), oTarget, nSaveDC, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_TRAP);

    if (nDamage > 0)
    {
        eDam = EffectDamage(nDamage, DAMAGE_TYPE_ELECTRICAL);
        DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
    }

    object o2ndTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, lTarget);
    while (GetIsObjectValid(o2ndTarget) && nCount < nSecondary)
    {
        //check to see that the original target is not hit again.
        if(o2ndTarget != oTarget && !GetIsReactionTypeFriendly(oTarget))
        {
            //Adjust the trap damage based on the feats of the target
            nDamage = GetSavingThrowAdjustedDamage(d6(20), o2ndTarget, nSaveDC, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_TRAP);

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
            //Increment the count
            nCount++;
        }
        //Get next target in the shape.
        o2ndTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_LARGE, lTarget);
    }
}

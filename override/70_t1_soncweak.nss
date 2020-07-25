//::///////////////////////////////////////////////
//:: Weak Sonic Trap
//:: 70_t1_soncweak
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
1d4 sonic to all in aoe, will save vs DC 7 or stunned for 1 round
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
    effect eLink = EffectLinkEffects(EffectStunned(), EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED));
    effect eDam;
    //Apply the FNF to the spell location
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SOUND_BURST), lTarget);
    //Get the first target in the spell area
    oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, lTarget);
    while (GetIsObjectValid(oTarget))
    {
        if(!GetIsReactionTypeFriendly(oTarget))
        {
            //recalculate damage for each target again
            eDam = EffectDamage(d4(1), DAMAGE_TYPE_SONIC);
            DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
            //Make a Will roll to avoid being stunned
            if(!MySavingThrow(SAVING_THROW_WILL, oTarget, 7, SAVING_THROW_TYPE_TRAP))
            {
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(1));
            }
        }
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_MEDIUM, lTarget);
    }
}

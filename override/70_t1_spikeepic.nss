//::///////////////////////////////////////////////
//:: Epic Spike Trap
//:: 70_t1_spikeepic
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
55d6 damage, reflex save vs DC 35, evasion allowed
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
    int nDamage = GetSavingThrowAdjustedDamage(d6(55), oTarget, 35, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_TRAP, OBJECT_SELF);

    if (nDamage > 0)
    {
         ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_PIERCING), oTarget);
    }

    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_SPIKE_TRAP), GetLocation(oTarget));
}

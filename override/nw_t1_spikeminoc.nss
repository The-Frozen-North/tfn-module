//::///////////////////////////////////////////////
//:: Minor Spike Trap
//:: NW_T1_SpikeMinC
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Strikes the entering object with a spike for
    2d6 damage.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 4th , 2001
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

    int nRealDamage = GetSavingThrowAdjustedDamage(d6(2), oTarget, 15, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_TRAP, OBJECT_SELF);
    if (nRealDamage > 0)
    {
        effect eDam = EffectDamage(nRealDamage, DAMAGE_TYPE_PIERCING);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget);
    }
    effect eVis = EffectVisualEffect(VFX_IMP_SPIKE_TRAP);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, GetLocation(oTarget));
}

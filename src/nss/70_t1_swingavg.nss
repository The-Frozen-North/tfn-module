//::///////////////////////////////////////////////
//:: Average Swinging Blade Trap
//:: 70_t1_swingavg
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
twice 3d8 damage, reflex save vs DC 20, evasion allowed
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
    int nDamage = GetSavingThrowAdjustedDamage(d8(3), oTarget, 20, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_TRAP, OBJECT_SELF);

    if (nDamage > 0)
    {
         ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_SLASHING), oTarget);
    }

    nDamage = GetSavingThrowAdjustedDamage(d8(3), oTarget, 20, SAVING_THROW_REFLEX, SAVING_THROW_TYPE_TRAP, OBJECT_SELF);

    if (nDamage > 0)
    {
         ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(nDamage, DAMAGE_TYPE_SLASHING), oTarget);
    }

    effect eVFX = EffectVisualEffect(VFX_FNF_SWINGING_BLADE,TRUE);
    location lTarget = GetLocation(oTarget);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVFX, lTarget);
    DelayCommand(0.3,ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVFX, lTarget));
}

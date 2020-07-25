//::///////////////////////////////////////////////
//:: Minor Holy Trap
//:: 70_t1_holyweak
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
3d8 to undead, 1d4 to anyone else, no save allowed
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

    if(spellsIsRacialType(oTarget, RACIAL_TYPE_UNDEAD))
    {
        //Apply Holy Damage
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d8(3), DAMAGE_TYPE_DIVINE), oTarget);
    }
    else
    {
        //Apply Holy Damage
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d4(1), DAMAGE_TYPE_DIVINE), oTarget);
    }

    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_SUNSTRIKE), oTarget);
}

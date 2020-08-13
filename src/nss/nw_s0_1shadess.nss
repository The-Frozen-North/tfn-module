//::///////////////////////////////////////////////
//:: Shadow Essence On Hit
//:: NW_S0_1ShadEss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    1 Point Permenent Strength Damage
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: April 11, 2002
//:://////////////////////////////////////////////
/*
Patch 1.72
- poison immunity prevents all effects

Patch 1.71
- ability decrease effect fixed and made supernatural according to poison description
*/

#include "70_inc_poison"

void ApplyPoisonEffects(object oTarget)
{
    effect eDrain = EffectAbilityDecrease(ABILITY_STRENGTH, -1);
    eDrain = SupernaturalEffect(eDrain);
    effect eVis = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);

    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eDrain, oTarget);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
}

void main()
{
    object oTarget = OBJECT_SELF;
    object oCreator = GetPoisonEffectCreator(oTarget);

    //if character is immune to poison, print immunity feedback and exit
    if(GetIsImmune(oTarget,IMMUNITY_TYPE_POISON,OBJECT_INVALID))
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectPoison(0),oTarget);
        return;
    }

    AssignCommand(oCreator, ApplyPoisonEffects(oTarget));
}

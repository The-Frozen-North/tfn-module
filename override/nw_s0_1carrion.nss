//::///////////////////////////////////////////////
//:: Carrions Crawler Brain Juice
//:: NW_S0_1Carrion
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Induces Paralysis
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: April 11, 2002
//:://////////////////////////////////////////////
/*
Patch 1.72
- poison immunity prevents all effects

Patch 1.71
- visual effect wasn't linked with paralyse properly
- paralyse effect made extraordinary
- rewritten in order to allow neutralize poison spell remove the paralysation effect
*/

#include "70_inc_poison"

void ApplyPoisonEffects(object oTarget)
{
    effect eParal = EffectParalyze();
    effect eVis = EffectVisualEffect(VFX_DUR_PARALYZED);
    effect eLink = EffectLinkEffects(eParal, eVis);
    eLink = ExtraordinaryEffect(eLink);

    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(10));
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

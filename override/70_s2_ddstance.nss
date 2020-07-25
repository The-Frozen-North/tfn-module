//::///////////////////////////////////////////////
//:: Dwarven Defender Defensive Stance
//:: 70_s2_ddstance
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
Script for DD's defensive stance. Triggers when the defensive stance combat mode is activated.

Script only solves "OnApply" part of the feat, "OnRemove" is handled automatically by the engine.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow
//:: Created On: 29-6-2015
//:://////////////////////////////////////////////

void main()
{
    //Declare major variables
    effect eStance = EffectAbilityIncrease(ABILITY_STRENGTH,2);
    eStance = EffectLinkEffects(eStance,EffectAbilityIncrease(ABILITY_CONSTITUTION,4));
    eStance = EffectLinkEffects(eStance,EffectSavingThrowIncrease(SAVING_THROW_ALL,2));
    eStance = EffectLinkEffects(eStance,EffectACIncrease(4));
    eStance = EffectLinkEffects(eStance,EffectCutsceneImmobilize());

    ApplyEffectToObject(DURATION_TYPE_PERMANENT,ExtraordinaryEffect(eStance),OBJECT_SELF);
}

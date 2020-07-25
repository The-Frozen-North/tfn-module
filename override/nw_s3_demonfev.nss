//::///////////////////////////////////////////////
//:: Disease: Demon Fever, On Rest
//:: NW_S3_DemonFev
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    When they are damaged, they must make a Fort
    Save or incur 1 point of permanent CON damage
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Aug 15, 2001
//:://////////////////////////////////////////////

#include "70_inc_disease"

void main()
{
    Disease(2);
    //Declare major variables
    object oTarget = OBJECT_SELF;
    object eCreator = GetDiseaseEffectCreator(oTarget);
    effect eVis = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);

    //Make a saving throw check
    if(!FortitudeSave(oTarget, 18, SAVING_THROW_TYPE_DISEASE))
    {
        //Apply the VFX impact and effects
        AssignCommand(eCreator,ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(EffectAbilityDecrease(ABILITY_CONSTITUTION,1)), oTarget));
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
    }
}

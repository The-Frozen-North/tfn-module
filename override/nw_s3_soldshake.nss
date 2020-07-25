//::///////////////////////////////////////////////
//:: Disease: Soldier Shakes, On Rest
//:: NW_S3_SoldShake
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Chooses a random ability score and applies
    1 point of ability damage to that ability score
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On:  , 2001
//:://////////////////////////////////////////////

#include "70_inc_disease"

void main()
{
    Disease(15);
    //Declare major variables
    int nChoice = d6();
    effect eVis = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
    effect eAbility;
    object oTarget = OBJECT_SELF;
    object eCreator = GetDiseaseEffectCreator(oTarget);
    //Set the ability score to be lowered
    switch (nChoice)
    {
        case 1:
            nChoice = ABILITY_CHARISMA;
        break;
        case 2:
            nChoice = ABILITY_CONSTITUTION;
        break;
        case 3:
            nChoice = ABILITY_DEXTERITY;
        break;
        case 4:
            nChoice = ABILITY_INTELLIGENCE;
        break;
        case 5:
            nChoice = ABILITY_STRENGTH;
        break;
        case 6:
            nChoice = ABILITY_WISDOM;
        break;
    }
    //Apply the VFX impact and effects
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
    AssignCommand(eCreator,ApplyEffectToObject(DURATION_TYPE_PERMANENT,SupernaturalEffect(EffectAbilityDecrease(nChoice,1)), oTarget));
}

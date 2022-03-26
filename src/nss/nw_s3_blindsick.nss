//::///////////////////////////////////////////////
//:: Disease: Blind Sickness, After Rest
//:: NW_S3_BlindSick
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Every time the character takes Str damage
    they must roll or be blinded.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Aug 15, 2001
//:://////////////////////////////////////////////

#include "70_inc_disease"

void main()
{
    object oTarget = OBJECT_SELF;
    Disease(0);
    object eCreator = GetDiseaseEffectCreator(oTarget);
    //Declare major variables
    effect eVis = EffectVisualEffect(VFX_IMP_BLIND_DEAF_M);
    int nRoll = d100();
    //Roll randomly for chance to be blinded
    if(nRoll > 60)
    {
        //Apply the VFX impact and effects
        AssignCommand(eCreator,ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBlindness(), oTarget));
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
    }
}

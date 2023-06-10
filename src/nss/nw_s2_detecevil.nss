//::///////////////////////////////////////////////
//:: Detect_Evil
//:: NW_S2_DetecEvil.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    All creatures of Evil Alignment within LOS of
    the Paladin glow for a few seconds.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Aug 14, 2001
//:://////////////////////////////////////////////
/*
Patch 1.71

- wrong alignment check (was checked on caster, not target)
- spellscript changed to check class and in case the spell would be cast from
Blackguard class it will work as detect good instead
*/

#include "70_inc_spells"

void main()
{
    //Declare major variables
    int nClass = GetLastSpellCastClass();
    int nAlign = ALIGNMENT_EVIL;
    if(nClass == CLASS_TYPE_BLACKGUARD)
    {
        nAlign = ALIGNMENT_GOOD;
    }
    effect eVis = EffectVisualEffect(VFX_COM_SPECIAL_RED_WHITE);

    //Get first target in spell area
    object oTarget = GetFirstObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, GetLocation(OBJECT_SELF));
    while(GetIsObjectValid(oTarget))
    {
        //Check the current target's alignment
        if(GetAlignmentGoodEvil(oTarget) == nAlign)
        {
            //Apply the VFX
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, oTarget, 3.0);
        }
        //Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPHERE, RADIUS_SIZE_COLOSSAL, GetLocation(OBJECT_SELF));
    }
}

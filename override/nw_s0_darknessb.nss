//::///////////////////////////////////////////////
//:: Darkness: On Exit
//:: NW_S0_DarknessB.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creates a globe of darkness around those in the area
    of effect.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Feb 28, 2002
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    aoesDeclareMajorVariables();
    object oTarget = GetExitingObject();

    //Search through the valid effects on the target.
    effect eAOE = GetFirstEffect(oTarget);
    while(GetIsEffectValid(eAOE))
    {
        if(GetEffectCreator(eAOE) == aoe.Creator && GetEffectSpellId(eAOE) == spell.Id)
        {
            //If the effect was created by the spell then remove it
            RemoveEffect(oTarget, eAOE);
            break;
        }
        //Get next effect on the target
        eAOE = GetNextEffect(oTarget);
    }
}

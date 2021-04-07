//::///////////////////////////////////////////////
//:: Magic Cirle Against Good
//:: NW_S0_CircGoodB
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Add basic protection from good effects to
    entering allies.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 20, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- moving bug fixed, now caster gains benefit of aura all the time, (cannot guarantee the others,
thats module-related)
*/

#include "70_inc_spells"
#include "nw_i0_spells"

void main()
{
    //Declare major variables
    aoesDeclareMajorVariables();
    //Get the object that is exiting the AOE
    object oTarget = GetExitingObject();
    if(oTarget != aoe.Owner && GetHasSpellEffect(spell.Id, oTarget))
    {
        //Search through the valid effects on the target.
        effect eAOE = GetFirstEffect(oTarget);
        while(GetIsEffectValid(eAOE))
        {
            if(GetEffectCreator(eAOE) == aoe.Creator && GetEffectSpellId(eAOE) == spell.Id && GetEffectDurationType(eAOE) == DURATION_TYPE_PERMANENT)
            {
                //If the effect was created by the AOE then remove it
                RemoveEffect(oTarget, eAOE);
            }
            //Get next effect on the target
            eAOE = GetNextEffect(oTarget);
        }
    }
    else if(oTarget == aoe.Owner)
    {//engine workaround in case that AOE is destroyed/dispelled
    aoesCheckStillValid(aoe.AOE, oTarget, aoe.Creator, spell.Id);
    }
}

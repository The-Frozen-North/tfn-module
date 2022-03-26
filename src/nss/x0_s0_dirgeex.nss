//::///////////////////////////////////////////////
//:: Dirge: On Exit
//:: x0_s0_dirgeET.nss
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    MARCH 2003
    Remove the negative effects of the dirge.
*/
//:://////////////////////////////////////////////
//:: Created By:
//:: Created On:
//:://////////////////////////////////////////////
//:: Update Pass By:

#include "70_inc_spells"

void main()
{
    //Declare major variables
    aoesDeclareMajorVariables();
    //Get the object that is exiting the AOE
    object oTarget = GetExitingObject();

    if(oTarget != aoe.Owner && GetHasSpellEffect(spell.Id, oTarget))
    {
        DeleteLocalInt(oTarget, "X0_L_LASTPENALTY");
        //Search through the valid effects on the target.
        effect eAOE = GetFirstEffect(oTarget);
        while(GetIsEffectValid(eAOE))
        {
            if(GetEffectCreator(eAOE) == aoe.Creator && GetEffectSpellId(eAOE) == spell.Id && GetEffectDurationType(eAOE) == DURATION_TYPE_PERMANENT)
            {
                //If the effect was created by the Dirge spell then remove it
                RemoveEffect(oTarget, eAOE);
            }
            //Get next effect on the target
            eAOE = GetNextEffect(oTarget);
        }
    }
    else if(oTarget == aoe.Owner)
    {   //engine workaround in case that AOE is destroyed/dispelled
        aoesCheckStillValid(aoe.AOE, oTarget, aoe.Creator, spell.Id);
    }
}

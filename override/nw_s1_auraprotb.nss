//::///////////////////////////////////////////////
//:: Aura of Protection: On Exit
//:: NW_S1_AuraProtB.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Acts as a double strength Magic Circle against
    evil and a Minor Globe for those friends in
    the area.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On:Jan 8, 2002, 2001
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "nw_i0_spells"

void main()
{
    aoesDeclareMajorVariables();
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

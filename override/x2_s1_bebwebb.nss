//::///////////////////////////////////////////////
//:: Web: On Exit
//:: NW_S0_WebB.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creates a mass of sticky webs that cling to
    and entangle targets who fail a Reflex Save
    Those caught can make a new save every
    round.  Movement in the web is 1/5 normal.
    The higher the creatures Strength the faster
    they move within the web.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Aug 8, 2001
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x2_inc_spellhook"

void main()
{
    aoesDeclareMajorVariables();
    //Get the object that is exiting the AOE
    object oTarget = GetExitingObject();
    //Search through the valid effects on the target.
    effect eAOE = GetFirstEffect(oTarget);
    while(GetIsEffectValid(eAOE))
    {
        //If the effect was created by the Web then remove it
        if(GetEffectCreator(eAOE) == aoe.Creator)
        {
            if(GetEffectSpellId(eAOE) == spell.Id)
            {
                RemoveEffect(oTarget, eAOE);
            }
        }
        eAOE = GetNextEffect(oTarget);
    }
}

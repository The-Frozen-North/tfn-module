//::///////////////////////////////////////////////
//:: Vine Mine, Entangle B: On Exit
//:: X2_S0_VineMEntB
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Removes the entangle effect after the AOE dies.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 25, 2002
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x2_inc_spellhook"

void main()
{
    //Declare major variables
    aoesDeclareMajorVariables();
    //Get the object that is exiting the AOE
    object oTarget = GetExitingObject();
    if(GetHasSpellEffect(spell.Id, oTarget))
    {
        //Search through the valid effects on the target.
        effect eAOE = GetFirstEffect(oTarget);
        while (GetIsEffectValid(eAOE))
        {
            //If the effect was created by the Acid_Fog then remove it
            if (GetEffectCreator(eAOE) == aoe.Creator && GetEffectSpellId(eAOE) == spell.Id)
            {
                RemoveEffect(oTarget, eAOE);
            }
            //Get next effect on the target
            eAOE = GetNextEffect(oTarget);
        }
    }
}

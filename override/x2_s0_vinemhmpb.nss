//::///////////////////////////////////////////////
//:: Vine Mind, Hamper Movement: On Exit
//:: X2_S0_VineMHmpB
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creatures entering the zone of Vine Mind, Hamper
    Movement have their movement reduced by 1/2.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 25, 2002
//:://////////////////////////////////////////////
/*
Patch 1.70

- didn't removed all applications of the slow effect from this spell
*/

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
        object oCreator = GetAreaOfEffectCreator();
        //Search through the valid effects on the target.
        effect eAOE = GetFirstEffect(oTarget);
        while (GetIsEffectValid(eAOE))
        {
            //If the effect was created by the Acid_Fog then remove it
            if (GetEffectSpellId(eAOE) == SPELL_VINE_MINE_HAMPER_MOVEMENT && GetEffectCreator(eAOE) == aoe.Creator)
            {
                RemoveEffect(oTarget, eAOE);
            }
            //Get next effect on the target
            eAOE = GetNextEffect(oTarget);
        }
    }
}

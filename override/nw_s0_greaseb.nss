//::///////////////////////////////////////////////
//:: Grease: On Exit
//:: NW_S0_GreaseB.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creatures entering the zone of grease must make
    a reflex save or fall down.  Those that make
    their save have their movement reduced by 1/2.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Aug 1, 2001
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
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
            if (GetEffectCreator(eAOE) == aoe.Creator)
            {
                if(GetEffectType(eAOE) == EFFECT_TYPE_MOVEMENT_SPEED_DECREASE)
                {
                    //If the effect was created by the Acid_Fog then remove it
                    if(GetEffectSpellId(eAOE) == spell.Id)
                    {
                        RemoveEffect(oTarget, eAOE);
                        break;
                    }
                }
            }
            //Get next effect on the target
            eAOE = GetNextEffect(oTarget);
        }
    }
}

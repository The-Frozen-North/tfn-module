//::///////////////////////////////////////////////
//:: Aura of Hellfire on Exit
//:: NW_S1_AuraElecB.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Prolonged exposure to the aura of the creature
    causes fire damage to all within the aura.
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    aoesDeclareMajorVariables();
    //Get first target in spell area
    object oTarget = GetExitingObject();
    if(oTarget == aoe.Owner)
    {
    //engine workaround in case that AOE is destroyed/dispelled
    aoesCheckStillValid(aoe.AOE, oTarget, aoe.Creator, spell.Id);
    }
}

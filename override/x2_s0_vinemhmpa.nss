//::///////////////////////////////////////////////
//:: Vine Mine, Hamper Movement: On Enter
//:: X2_S0_VineMHmpA
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creatures entering the zone of Vine Mine, Hamper
    Movement have their movement reduced by 1/2.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 25, 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Andrew Nobbs, 02/06/2003
/*
Patch 1.70

- aoe signalized wrong spell ID
- incorporeal creatures could been affected
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    //Declare major variables
    aoesDeclareMajorVariables();
    object oTarget = GetEnteringObject();
    if(spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
    {
        if(!GetHasFeat(FEAT_WOODLAND_STRIDE, oTarget) && !GetCreatureFlag(oTarget, CREATURE_VAR_IS_INCORPOREAL))
        {
            //Fire cast spell at event for the target
            SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));

            effect eVis = EffectVisualEffect(VFX_IMP_SLOW);
            effect eSlow = EffectMovementSpeedDecrease(50);
            effect eLink = EffectLinkEffects(eVis, eSlow);

            //Apply reduced movement effect and VFX_Impact
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);
        }
    }
}

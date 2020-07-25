//::///////////////////////////////////////////////
//:: Grease: On Enter
//:: NW_S0_GreaseA.nss
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
/*
Patch 1.70

- incorporeal creatures could been affected
- flying creatures are immune
- speed decrease was dispellable
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
    effect eVis = EffectVisualEffect(VFX_IMP_SLOW);
    effect eSlow = EffectMovementSpeedDecrease(50);
    effect eLink = EffectLinkEffects(eVis, eSlow);
    eLink = ExtraordinaryEffect(eLink);
    object oTarget = GetEnteringObject();
    float fDelay = GetRandomDelay(1.0, 2.2);
    if(!GetHasFeat(FEAT_WOODLAND_STRIDE, oTarget) && !GetCreatureFlag(oTarget, CREATURE_VAR_IS_INCORPOREAL) && !spellsIsFlying(oTarget))
    {
        if(spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
        {
            //Fire cast spell at event for the target
            SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
            //Spell resistance check
            if(!MyResistSpell(aoe.Creator, oTarget))
            {
                //Apply reduced movement effect and VFX_Impact
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);
            }
        }
    }
}

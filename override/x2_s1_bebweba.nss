//::///////////////////////////////////////////////
//:: Web: On Enter
//:: NW_S0_WebA.nss
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
/*
Patch 1.70

- incorporeal creatures could been affected
- added missing signal event
- AOE effects made undispellable
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //Declare major variables
    aoesDeclareMajorVariables();
    effect eWeb = EffectEntangle();
    effect eVis = EffectVisualEffect(VFX_DUR_WEB);
    effect eLink = EffectLinkEffects(eWeb, eVis);
    eLink = ExtraordinaryEffect(eLink);
    object oTarget = GetEnteringObject();
//    int nHD = GetHitDice(GetAreaOfEffectCreator(OBJECT_SELF));
    int nDC = 20;
    // * the lower the number the faster you go
    int nSlow = 85 - (GetAbilityScore(oTarget, ABILITY_STRENGTH) * 2);
    if (nSlow <= 0)
    {
        nSlow = 1;
    }

    if (nSlow > 99)
    {
        nSlow = 99;
    }

    effect eSlow = EffectMovementSpeedDecrease(nSlow);
    eSlow = ExtraordinaryEffect(eSlow);
    if(!GetHasFeat(FEAT_WOODLAND_STRIDE, oTarget) && !GetCreatureFlag(oTarget, CREATURE_VAR_IS_INCORPOREAL))
    {
        if(spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, aoe.Creator))
        {
            //Fire cast spell at event for the target
            SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));

            if(!MySavingThrow(SAVING_THROW_REFLEX, oTarget, nDC, SAVING_THROW_TYPE_NONE, aoe.Creator))
            {
                //Entangle effect and Web VFX impact
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(1));
            }
            //Slow down the creature within the Web
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eSlow, oTarget);
        }
    }
}

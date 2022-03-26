//::///////////////////////////////////////////////
//:: Aura Stunning On Enter
//:: NW_S1_AuraStunA.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Upon entering the aura of the creature the player
    must make a will save or be stunned.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 25, 2001
//:://////////////////////////////////////////////
/*
Patch 1.72
- effects made undispellable (supernatural)
Patch 1.70
- wrong target check (could affect other NPCs)
- added duration scaling per game difficulty
*/

#include "x0_i0_spells"

void main()
{
    //Declare major variables
    object oCreator = GetAreaOfEffectCreator();
    object oTarget = GetEnteringObject();
    effect eVis = EffectVisualEffect(VFX_IMP_STUN);
    effect eVis2 = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
    effect eDeath = EffectStunned();
    effect eLink = EffectLinkEffects(eVis2, eDeath);
    eLink = SupernaturalEffect(eLink);
    int nDuration = GetHitDice(oCreator)/3 + 1;
    nDuration = GetScaledDuration(nDuration, oTarget);
    int nDC = 10 + GetHitDice(oCreator)/3;

    if(spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, oCreator))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_AURA_STUN));
        //Make a saving throw check
        if(!MySavingThrow(SAVING_THROW_WILL, oTarget, nDC, SAVING_THROW_TYPE_MIND_SPELLS, oCreator))
        {
            nDuration = GetScaledDuration(nDuration, oTarget);
            //Apply the VFX impact and effects
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration));
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
        }
    }
}

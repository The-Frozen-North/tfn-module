//::///////////////////////////////////////////////
//:: Aura of the Unnatural On Enter
//:: NW_S1_AuraMencA.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Upon entering the aura all animals are struck with
    fear.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 25, 2001
//:://////////////////////////////////////////////
/*
Patch 1.72
- effects made undispellable (supernatural)
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //Declare major variables
    object oCreator = GetAreaOfEffectCreator();
    effect eVis = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
    effect eFear = EffectFrightened();
    effect eLink = EffectLinkEffects(eVis, eFear);
    eLink = SupernaturalEffect(eLink);

    object oTarget = GetEnteringObject();
    int nDuration = GetHitDice(oCreator);
    int nDC = 10 + GetHitDice(oCreator)/3;
    if(spellsIsRacialType(oTarget, RACIAL_TYPE_ANIMAL) && spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, oCreator))
    {
        nDuration = (nDuration / 3) + 1;
         //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_AURA_UNNATURAL));
        //Make a saving throw check
        if (!MySavingThrow(SAVING_THROW_WILL, oTarget, nDC, SAVING_THROW_TYPE_FEAR, oCreator))
        {
            //Apply the VFX impact and effects
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration));
        }
    }
}

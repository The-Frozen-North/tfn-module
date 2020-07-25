//::///////////////////////////////////////////////
//:: Aura of Menace On Enter
//:: NW_S1_AuraMencA.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Upon entering the aura all those that fail
    a will save are stricken with Doom.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 25, 2001
//:://////////////////////////////////////////////
/*
Patch 1.72
- effects made undispellable (supernatural)
*/

#include "x0_i0_spells"

void main()
{
    //Declare major variables
    object oCreator = GetAreaOfEffectCreator();
    object oTarget = GetEnteringObject();
    int nDuration = 1 + GetHitDice(oCreator)/3;
    effect eVis = EffectVisualEffect(VFX_IMP_DOOM);
    int nDC = 10 + GetHitDice(oCreator)/3;

    effect eLink = CreateDoomEffectsLink();
    eLink = SupernaturalEffect(eLink);

    if(spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, oCreator))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_AURA_MENACE));
        //Spell Resistance and Saving throw
        if (!MySavingThrow(SAVING_THROW_WILL, oTarget, nDC, SAVING_THROW_TYPE_NONE, oCreator))
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, TurnsToSeconds(nDuration));
        }
    }
}

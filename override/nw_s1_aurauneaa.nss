//::///////////////////////////////////////////////
//:: Aura Unearthly Visage On Enter
//:: NW_S1_AuraUnEaA.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Upon entering the aura of the creature the player
    must make a will save or be killed because of the
    sheer ugliness or beauty of the creature.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 25, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- DC corrected to use HD
*/

#include "x0_i0_spells"

void main()
{
    //Declare major variables
    object oCreator = GetAreaOfEffectCreator();
    int nDC = 10 + GetHitDice(oCreator)/3;
    object oTarget = GetEnteringObject();
    effect eDeath = EffectDeath();
    effect eVis = EffectVisualEffect(VFX_IMP_DEATH);
    if(spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, oCreator))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_AURA_UNEARTHLY_VISAGE));
        //Make a saving throw check
        if(!MySavingThrow(SAVING_THROW_WILL, oTarget, nDC, SAVING_THROW_TYPE_DEATH, oCreator))
        {
            //Apply the VFX impact and effects
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, oTarget);
            //ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
        }
    }
}

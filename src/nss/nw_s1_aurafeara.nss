//::///////////////////////////////////////////////
//:: Aura of Fear On Enter
//:: NW_S1_AuraFearA.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Upon entering the aura of the creature the player
    must make a will save or be struck with fear because
    of the creatures presence.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 25, 2001
//:://////////////////////////////////////////////
/*
Patch 1.72
- effects made undispellable (supernatural)
Patch 1.71
- added scaling into fear effect
- each creature rolls only once per aura
- fear duration balanced with other auras to (1+HD/3)rounds instead of (HD)rounds
*/

#include "x0_i0_spells"

void main()
{
    //Declare major variables
    object oTarget = GetEnteringObject();
    object oCreator = GetAreaOfEffectCreator();
    if(GetGameDifficulty() < GAME_DIFFICULTY_DIFFICULT && GetLocalInt(OBJECT_SELF,ObjectToString(oTarget)))
    {
        return;
    }
    SetLocalInt(OBJECT_SELF,ObjectToString(oTarget),TRUE);
    effect eDur = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
    effect eDur2 = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eFear = EffectFrightened();
    eFear = GetScaledEffect(eFear, oTarget);
    effect eLink = EffectLinkEffects(eFear, eDur);
    eLink = EffectLinkEffects(eLink, eDur2);
    eLink = SupernaturalEffect(eLink);

    int nHD = GetHitDice(oCreator);
    int nDC = 10 + nHD/3;
    int nDuration = nHD/3 + 1;
    nDuration = GetScaledDuration(nHD, oTarget);

    if(spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, oCreator))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_AURA_FEAR));
        //Make a saving throw check
        if(!MySavingThrow(SAVING_THROW_WILL, oTarget, nDC, SAVING_THROW_TYPE_FEAR, oCreator))
        {
            //Apply the VFX impact and effects
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration));
        }
    }
}

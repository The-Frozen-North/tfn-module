//::///////////////////////////////////////////////
//:: Aura of Fear On Enter
//:: NW_S1_DragFearA.nss
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
//:: LastUpdated: 24, Oct 2003, GeorgZ
//:://////////////////////////////////////////////
/*
Patch 1.72
- effects made supernatural (not dispellable)
Patch 1.71
- added scaling into fear effect
- aoe signalized wrong spell ID
- each creature rolls only once per aura
- fear duration balanced with other auras to (1+HD/3)rounds instead of (HD)rounds
*/

#include "x0_i0_spells"

void main()
{
    //Declare major variables
    object oDragon = GetAreaOfEffectCreator();
    object oTarget = GetEnteringObject();
    if(GetGameDifficulty() < GAME_DIFFICULTY_DIFFICULT && GetLocalInt(OBJECT_SELF,ObjectToString(oTarget)))
    {
        return;
    }
    SetLocalInt(OBJECT_SELF,ObjectToString(oTarget),TRUE);
//    effect eVis = EffectVisualEffect(VFX_IMP_FEAR_S); //invalid vfx
    effect eDur = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
    effect eDur2 = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eFear = EffectFrightened();
    eFear = GetScaledEffect(eFear, oTarget);
    effect eLink = EffectLinkEffects(eFear, eDur);
    eLink = SupernaturalEffect(EffectLinkEffects(eLink, eDur2));

    int nHD = GetHitDice(oDragon);
    int nDC = GetDragonFearDC(nHD);//10 + GetHitDice(GetAreaOfEffectCreator())/3;
    int nDuration = nHD/3 + 1;
    nDuration = GetScaledDuration(nHD, oTarget);
    //--------------------------------------------------------------------------
    // Capping at 20
    //--------------------------------------------------------------------------
    if (nDuration > 20)
    {
        nDuration = 20;
    }
    //--------------------------------------------------------------------------
    // Yaron does not like the stunning beauty of a very specific dragon to
    // last more than 10 rounds ....
    //--------------------------------------------------------------------------
    if (GetTag(oDragon) == "q3_vixthra")
    {
        nDuration = 3+d6();
    }

    if(spellsIsTarget(oTarget, SPELL_TARGET_SELECTIVEHOSTILE, oDragon))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_DRAGON_FEAR));
        //Make a saving throw check
        if(!MySavingThrow(SAVING_THROW_WILL, oTarget, nDC, SAVING_THROW_TYPE_FEAR, oDragon))
        {
            //Apply the VFX impact and effects
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration));
//            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
        }
    }
}

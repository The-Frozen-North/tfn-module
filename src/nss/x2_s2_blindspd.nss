//::///////////////////////////////////////////////
//:: Haste
//:: NW_S0_Haste.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Gives the targeted creature one extra partial
    action per round.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 29, 2001
//:://////////////////////////////////////////////
// Modified March 2003: Remove Expeditious Retreat effects
/*
Patch 1.72
- fixed stacking of the spell with expeditios retreat which was still possible with potions
- effects made extraordinary
Patch 1.71
- haste from other sources won't be removed anymore
*/

#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    object oTarget = GetSpellTargetObject();

    RemoveEffectsFromSpell(spell.Target, SPELL_EXPEDITIOUS_RETREAT);

    effect eHaste = EffectHaste();
    effect eVis = EffectVisualEffect(460);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eHaste, eDur);

    //Fire cast spell at event for the specified target
    SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId(), FALSE));
    //Check for metamagic extension

    // Apply effects to the currently selected target.
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, ExtraordinaryEffect(eLink), oTarget, RoundsToSeconds(10));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
}


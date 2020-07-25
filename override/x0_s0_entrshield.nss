//::///////////////////////////////////////////////
//:: Entropic Shield
//:: x0_s0_entrshield.nss
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    20% concealment to ranged attacks including
    ranged spell attacks

    Duration: 1 turn/level

*/
//:://////////////////////////////////////////////
//:: Created By: Brent Knowles
//:: Created On: July 18, 2002
//:://////////////////////////////////////////////
//:: VFX Pass By:

#include "70_inc_spells"
#include "nw_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_TURNS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDuration = spell.Level;
    effect eVis = EffectVisualEffect(VFX_IMP_AC_BONUS);
    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    //Check for metamagic extend
    if (spell.Meta & METAMAGIC_EXTEND) //Duration is +100%
    {
         nDuration = nDuration * 2;
    }
    //Set the four unique armor bonuses
    effect eShield =  EffectConcealment(20, MISS_CHANCE_TYPE_VS_RANGED);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    effect eLink = EffectLinkEffects(eShield, eDur);
//    RemoveEffectsFromSpell(oTarget, GetSpellId());

    //Apply the armor bonuses and the VFX impact
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
}

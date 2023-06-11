//::///////////////////////////////////////////////
//:: Expeditious retreat
//:: x0_s0_exretreat.nss
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
 Increases movement rate to the max, allowing
 the spell-caster to flee.
 Also gives + 2 AC bonus
*/
//:://////////////////////////////////////////////
//:: Created By: Brent Knowles
//:: Created On: September 6, 2002
//:://////////////////////////////////////////////
//:: Last Update By: Andrew Nobbs May 01, 2003
/*
Patch 1.71

- fixed self-stacking
*/

#include "70_inc_spells"
#include "nw_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.Limit = 50;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    if (GetHasSpellEffect(SPELL_HASTE, spell.Target) == TRUE)
    {
        return ; // does nothing if caster already has haste
    }
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eFast = EffectMovementSpeedIncrease(100+spell.Limit);
    effect eLink = EffectLinkEffects(eFast, eDur);

    int nDuration = spell.Level;
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2; //Duration is +100%
    }

    //Stacking Spellpass
    RemoveEffectsFromSpell(spell.Target, spell.Id);

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    //Apply the VFX impact and effects
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
}

//::///////////////////////////////////////////////
//:: Camoflage
//:: x0_s0_camo.nss
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
 bonus +10 to Hide checks
*/
//:://////////////////////////////////////////////
//:: Created By: Brent Knowles
//:: Created On: July 19, 2002
//:://////////////////////////////////////////////
//:: VFX Pass By:
/*
Patch 1.70

- fixed minor glitch in signal event
*/

#include "70_inc_spells"
#include "x0_i0_spells"
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
    effect eVis = EffectVisualEffect(VFX_IMP_IMPROVE_ABILITY_SCORE);

    effect eHide = EffectSkillIncrease(SKILL_HIDE, 10);

    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eHide, eDur);

    int nDuration = 10 * spell.Level; // * Duration 10 turn/level
    if (spell.Meta & METAMAGIC_EXTEND)    //Duration is +100%
    {
         nDuration = nDuration * 2;
    }

    //Fire spell cast at event for target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    //Apply VFX impact and bonus effects
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
}

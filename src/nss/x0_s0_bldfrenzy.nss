//::///////////////////////////////////////////////
//:: Blood Frenzy
//:: x0_s0_bldfrenzy.nss
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
 Similar to Barbarian Rage.
 +2 Strength, Con. +1 morale bonus to Will
 -1 AC
*/
//:://////////////////////////////////////////////
//:: Created By: Brent Knowles
//:: Created On: July 19, 2002
//:://////////////////////////////////////////////
//:: VFX Pass By:
/*
Patch 1.70

- the spell couldn't be recast until expired
- caster wont utter battle cry if cast silently
*/

#include "70_inc_spells"
#include "nw_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDuration = spell.Level;
    int nIncrease = 2;
    int nSave = 1;

    if(spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration * 2;
    }

    if(spell.Meta != METAMAGIC_SILENT && !GetHasFeat(FEAT_EPIC_AUTOMATIC_SILENT_SPELL_1, spell.Caster))
    {
        PlayVoiceChat(VOICE_CHAT_BATTLECRY1);
    }

    effect eStr = EffectAbilityIncrease(ABILITY_CONSTITUTION, nIncrease);
    effect eCon = EffectAbilityIncrease(ABILITY_STRENGTH, nIncrease);
    effect eSave = EffectSavingThrowIncrease(SAVING_THROW_WILL, nSave);
    effect eAC = EffectACDecrease(1, AC_DODGE_BONUS);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    effect eLink = EffectLinkEffects(eCon, eStr);
    eLink = EffectLinkEffects(eLink, eSave);
    eLink = EffectLinkEffects(eLink, eAC);
    eLink = EffectLinkEffects(eLink, eDur);
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    //Make effect extraordinary
    eLink = MagicalEffect(eLink);
    effect eVis = EffectVisualEffect(VFX_IMP_IMPROVE_ABILITY_SCORE); //Change to the Rage VFX

    //do not stack, but also allow to recast the spell at any time
    RemoveSpellEffects(spell.Id,spell.Caster,spell.Target);

    //Apply the VFX impact and effects
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Caster);
}

/////////////////////////////////////////////////
// Bull's Strength
//-----------------------------------------------
// Created By: Brenon Holmes
// Created On: 10/12/2000
// Description: This script changes someone's strength
// Updated 2003-07-17 to fix stacking issue with blackguard
/////////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 4;
    spell.DurationType = SPELL_DURATION_TYPE_HOURS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eStr;
    effect eVis = EffectVisualEffect(VFX_IMP_IMPROVE_ABILITY_SCORE);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    int nModify = MaximizeOrEmpower(spell.Dice,1,spell.Meta,1);
    int nDuration = spell.Level;

    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    //Check for metamagic conditions
    if (spell.Class == CLASS_TYPE_BLACKGUARD || (spell.Meta & METAMAGIC_EXTEND))
    {
        nDuration = nDuration * 2;
    }
    //Set the ability bonus effect
    eStr = EffectAbilityIncrease(ABILITY_STRENGTH,nModify);
    effect eLink = EffectLinkEffects(eStr, eDur);
    
    RemoveAnimalSpellEffects(spell.Target);

    //Appyly the VFX impact and ability bonus effect
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
}

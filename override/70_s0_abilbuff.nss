//::///////////////////////////////////////////////
//:: Ability buffs Multi-spell script
//:: 70_s0_abilbuff
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
Reason for this spellscript is to allow builder change all ability buff spells easily.
You can now modify all these spells in single script instead of modifying twelve scripts
individually.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow
//:: Created On: Sep 16, 2014
//:://////////////////////////////////////////////

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
    int nAbility, nDice = 1;
    switch(spell.Id)
    {
        case SPELL_GREATER_BULLS_STRENGTH:
        nDice = 2;
        case SPELL_BULLS_STRENGTH:
        case 614://BG version
        nAbility = ABILITY_STRENGTH;
        break;
        case SPELL_GREATER_FOXS_CUNNING:
        nDice = 2;
        case SPELL_FOXS_CUNNING:
        nAbility = ABILITY_INTELLIGENCE;
        break;
        case SPELL_GREATER_OWLS_WISDOM:
        nDice = 2;
        case SPELL_OWLS_WISDOM:
        nAbility = ABILITY_WISDOM;
        break;
        case SPELL_GREATER_ENDURANCE:
        nDice = 2;
        case SPELL_ENDURANCE:
        nAbility = ABILITY_CONSTITUTION;
        break;
        case SPELL_GREATER_EAGLE_SPLENDOR:
        nDice = 2;
        case SPELL_EAGLE_SPLEDOR:
        case 482://harper version
        nAbility = ABILITY_CHARISMA;
        break;
        case SPELL_GREATER_CATS_GRACE:
        nDice = 2;
        case SPELL_CATS_GRACE:
        case 481://harper version
        nAbility = ABILITY_DEXTERITY;
        break;
    }


    effect eVis = EffectVisualEffect(VFX_IMP_IMPROVE_ABILITY_SCORE);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    int nRaise = MaximizeOrEmpower(spell.Dice,nDice,spell.Meta,1);
    int nDuration = spell.Level;
    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

    //Enter Metamagic conditions
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2; //Duration is +100%
    }
    //Set Adjust Ability Score effect
    effect eRaise = EffectAbilityIncrease(nAbility, nRaise);
    effect eLink = EffectLinkEffects(eRaise, eDur);
    //Apply the VFX impact and effects
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
}

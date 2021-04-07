//::///////////////////////////////////////////////
//:: Battletide
//:: X2_S0_BattTide
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    You create an aura that steals energy from your
    enemies. Your enemies suffer a -2 circumstance
    penalty on saves, attack rolls, and damage rolls,
    once entering the aura. On casting, you gain a
    +2 circumstance bonus to your saves, attack rolls,
    and damage rolls.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Dec 04, 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Andrew Nobbs 06/06/03
/*
Patch 1.72
- added special workaround to handle the way this spell is cast by default AI
Patch 1.71
- disabled aura stacking
- moving bug fixed, now caster gains benefit of aura all the time, (cannot guarantee the others,
thats module-related)
*/

#include "70_inc_spells"
#include "x2_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.TargetType = SPELL_TARGET_SELECTIVEHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    if(spell.Target != spell.Caster && GetIsObjectValid(spell.Target) && !GetFactionEqual(spell.Caster,spell.Target))
    {
        //fix for AI that is cheat-casting this spell onto enemies while its personal range
        spell.Target = spell.Caster;
        spell.Loc = GetLocation(spell.Caster);
    }
    effect eAOE = EffectAreaOfEffect(AOE_MOB_TIDE_OF_BATTLE);
    effect eVis = EffectVisualEffect(VFX_IMP_AURA_UNEARTHLY);
    effect eVis2 = EffectVisualEffect(VFX_IMP_HOLY_AID);
    effect eSaves = EffectSavingThrowIncrease(SAVING_THROW_ALL,2);
    effect eAttack = EffectAttackIncrease(2);
    effect eDamage = EffectDamageIncrease(2,DAMAGE_TYPE_MAGICAL);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    //Link the effects
    effect eLink = EffectLinkEffects(eAttack,eDamage);
    eLink = EffectLinkEffects(eLink,eSaves);
    eLink = EffectLinkEffects(eLink,eDur);

    eLink = EffectLinkEffects(eLink,eVis);
    eLink = EffectLinkEffects(eLink,eAOE);

    int nDuration = spell.Level;

    //Make metamagic check for extend
    if(spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2;   //Duration is +100%
    }

    //prevent stacking
    RemoveEffectsFromSpell(spell.Target, spell.Id);

    //Apply the VFX impact and linked effects
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, spell.Target);

    //Create the AOE object at the selected location
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
    spellsSetupNewAOE("VFX_MOB_BATTLETIDE");
}

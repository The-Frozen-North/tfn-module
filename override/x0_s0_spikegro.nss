//::///////////////////////////////////////////////
//:: Spike Growth
//:: x0_s0_spikegro.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    All creatures within the AoE take 1d4 points of damage
    every round.
    If you are in the area of the effect, you also get a 24 hour slow
    effect on you (will only add one)

    Lasts 1 hour/level
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: July 2002
//:://////////////////////////////////////////////
/*
Patch 1.70

- aoe did set up wrong exit script
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 4;
    spell.DamageType = DAMAGE_TYPE_PIERCING;
    spell.DurationType = SPELL_DURATION_TYPE_HOURS;
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables including Area of Effect Object
    spellsDeclareMajorVariables();
    // * passing dirge script for exit because it is an empty script (i.e., there is no special exit effects)
    effect eAOE = EffectAreaOfEffect(AOE_PER_ENTANGLE, "x0_s0_spikegroEN", "x0_s0_spikegroHB", "****");
    int nDuration = spell.Level;
//    effect eImpact = EffectVisualEffect(257);
//    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, lTarget);

    //Check Extend metamagic feat.
    if(spell.Meta & METAMAGIC_EXTEND)
    {
       nDuration = nDuration *2;    //Duration is +100%
    }
    //Create an instance of the AOE Object using the Apply Effect function
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spell.Loc, DurationToSeconds(nDuration));
    spellsSetupNewAOE("VFX_PER_ENTANGLE","x0_s0_spikegrohb");
}

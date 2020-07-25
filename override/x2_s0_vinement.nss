//::///////////////////////////////////////////////
//:: Vine Mine, Entangle
//:: X2_S0_VineMEnt
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
  Area of effect spell that places the entangled
  effect on enemies if they fail a saving throw
  each round.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 25, 2002
//:://////////////////////////////////////////////
/*
Patch 1.70

- extend metamagic didn't worked
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
        // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables including Area of Effect Object
    spellsDeclareMajorVariables();
    effect eAOE = EffectAreaOfEffect(AOE_PER_ENTANGLE, "nw_s0_entanglea", "X2_S0_VineMEntC", "X2_S0_VineMEntB");

    //--------------------------------------------------------------------------
    // 1 turn per caster is not fun, so we do 1 round per casterlevel
    //--------------------------------------------------------------------------
    int nDuration = spell.Level;
    //Check Extend metamagic feat.
    if(spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2;    //Duration is +100%
    }

    //Create an instance of the AOE Object using the Apply Effect function
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spell.Loc, DurationToSeconds(nDuration));
    spellsSetupNewAOE("VFX_PER_ENTANGLE","x2_s0_vinementc");
}

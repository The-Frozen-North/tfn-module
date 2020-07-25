//::///////////////////////////////////////////////
//:: Stinking Cloud
//:: NW_S0_StinkCld.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Those within the area of effect must make a
    fortitude save or be dazed.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 17, 2001
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.SavingThrow = SAVING_THROW_FORT;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if(!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eAOE = EffectAreaOfEffect(AOE_PER_FOGSTINK);
    int nDuration = spell.Level;
    effect eImpact = EffectVisualEffect(VFX_FNF_GAS_EXPLOSION_NATURE);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spell.Loc);
    //Make metamagic check for extend
    if(spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2;   //Duration is +100%
    }
    //Create the AOE object at the selected location
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spell.Loc, DurationToSeconds(nDuration));
    spellsSetupNewAOE("VFX_PER_FOGSTINK","nw_s0_stinkcldc");
}

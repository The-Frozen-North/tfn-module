//::///////////////////////////////////////////////
//:: Cloudkill
//:: NW_S0_CloudKill.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    All creatures with 3 or less HD die, those with
    4 to 6 HD must make a save Fortitude Save or die.
    Those with more than 6 HD take 1d10 Poison damage
    every round.
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
    spell.Dice = 10;
    spell.DamageType = DAMAGE_TYPE_ACID;
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.SavingThrow = SAVING_THROW_FORT;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eAOE = EffectAreaOfEffect(AOE_PER_FOGKILL);

    int nDuration = spell.Level / 2;
    effect eImpact = EffectVisualEffect(258);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spell.Loc);
    if(nDuration < 1)
    {
        nDuration = 1;
    }

    //Metamagic checks for entend
    if(spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2;   //Duration is +100%
    }
    //Apply the AOE object to the specified location
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spell.Loc, DurationToSeconds(nDuration));
    spellsSetupNewAOE("VFX_PER_FOGKILL","nw_s0_cloudkillc");
}

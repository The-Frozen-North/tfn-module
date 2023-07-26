//::///////////////////////////////////////////////
//:: Planar Ally
//:: X0_S0_Planar.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Summons an outsider dependant on alignment, or
    holds an outsider if the creature fails a save.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: April 12, 2001
//:://////////////////////////////////////////////
//:: Modified from Planar binding
//:: Hold ability removed for cleric version of spell

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"
#include "inc_general"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_HOURS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDuration = spell.Level;
    effect eSummon;
    effect eGate;
    int nAlign = GetAlignmentGoodEvil(spell.Caster);

    //Check for metamagic extend
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2;   //Duration is +100%
    }

    //Set the summon effect based on the alignment of the caster
    float fDelay = 3.0;
    switch (nAlign)
    {
        case ALIGNMENT_EVIL:
            eSummon = EffectSummonCreature("sum_succubus",VFX_FNF_SUMMON_GATE, fDelay);
        break;
        case ALIGNMENT_GOOD:
            eSummon = EffectSummonCreature("sum_houndarchon", VFX_FNF_SUMMON_CELESTIAL, fDelay);
        break;
        case ALIGNMENT_NEUTRAL:
            eSummon = EffectSummonCreature("sum_slaadgreen",VFX_FNF_SUMMON_MONSTER_3, 1.0);
        break;
    }
    if (GetIsPC(spell.Caster))
    {
        IncrementPlayerStatistic(spell.Caster, "creatures_summoned");
    }
    //Apply the summon effect and VFX impact
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eSummon, spell.Loc, DurationToSeconds(nDuration));
}

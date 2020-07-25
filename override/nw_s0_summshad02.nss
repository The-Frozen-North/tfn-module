//::///////////////////////////////////////////////
//:: Summon Shadow
//:: NW_S0_SummShad02.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Spell powerful ally from the shadow plane to
    battle for the wizard
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 26, 2001
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

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
    int nCasterLevel = GetLevelByClass(CLASS_TYPE_CLERIC, spell.Caster);
    effect eSummon;

    //Set the summoned undead to the appropriate template based on the caster level
    if (nCasterLevel <= 7)
    {
        eSummon = EffectSummonCreature("NW_S_SHADOW",VFX_FNF_SUMMON_UNDEAD);
    }
    else if ((nCasterLevel >= 8) && (nCasterLevel <= 10))
    {
        eSummon = EffectSummonCreature("NW_S_SHADMASTIF",VFX_FNF_SUMMON_UNDEAD);
    }
    else if ((nCasterLevel >= 11) && (nCasterLevel <= 14))
    {
        eSummon = EffectSummonCreature("NW_S_SHFIEND",VFX_FNF_SUMMON_UNDEAD); // change later
    }
    else if ((nCasterLevel >= 15))
    {
        eSummon = EffectSummonCreature("NW_S_SHADLORD",VFX_FNF_SUMMON_UNDEAD);
    }

    //Apply VFX impact and summon effect
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eSummon, spell.Loc, DurationToSeconds(24));
}

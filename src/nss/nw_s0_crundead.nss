//::///////////////////////////////////////////////
//:: Create Undead
//:: NW_S0_CrUndead.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Spell summons a Ghoul, Shadow, Ghast, Wight or
    Wraith
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: April 12, 2001
//:://////////////////////////////////////////////

#include "70_inc_spells"
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
    int nDuration = 24;
    effect eSummon;
    //Check for metamagic extend
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2;   //Duration is +100%
    }
    //Set the summoned undead to the appropriate template based on the caster level
    if (spell.Level <= 11)
    {
        eSummon = EffectSummonCreature("sum_ghoullord",VFX_FNF_SUMMON_UNDEAD);
    }
    else if ((spell.Level >= 12) && (spell.Level <= 13))
    {
        eSummon = EffectSummonCreature("sum_ghast",VFX_FNF_SUMMON_UNDEAD);
    }
    else if ((spell.Level >= 14) && (spell.Level <= 15))
    {
        eSummon = EffectSummonCreature("NW_S_WIGHT",VFX_FNF_SUMMON_UNDEAD); // change later
    }
    else if ((spell.Level >= 16))
    {
        eSummon = EffectSummonCreature("NW_S_SPECTRE",VFX_FNF_SUMMON_UNDEAD);
    }

    //Apply VFX impact and summon effect
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eSummon, spell.Loc, DurationToSeconds(nDuration));
}

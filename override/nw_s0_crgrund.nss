//::///////////////////////////////////////////////
//:: Create Greater Undead
//:: NW_S0_CrGrUnd.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Summons an undead type pegged to the character's
    level.
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
    //Make metamagic extend check
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2;   //Duration is +100%
    }
    //Determine undead to summon based on level
    if (spell.Level <= 15)
    {
        eSummon = EffectSummonCreature("NW_S_VAMPIRE",VFX_FNF_SUMMON_UNDEAD);
    }
    else if ((spell.Level >= 16) && (spell.Level <= 17))
    {
        eSummon = EffectSummonCreature("NW_S_DOOMKGHT",VFX_FNF_SUMMON_UNDEAD);
    }
    else if ((spell.Level >= 18) && (spell.Level <= 19))
    {
        eSummon = EffectSummonCreature("NW_S_LICH",VFX_FNF_SUMMON_UNDEAD);
    }
    else
    {
        eSummon = EffectSummonCreature("NW_S_MUMCLERIC",VFX_FNF_SUMMON_UNDEAD);
    }
    //Apply summon effect and VFX impact.
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eSummon, spell.Loc, DurationToSeconds(nDuration));
}

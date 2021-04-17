//::///////////////////////////////////////////////
//:: Animate Dead
//:: NW_S0_AnimDead.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Summons a powerful skeleton or zombie depending
    on caster level.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: April 11, 2001
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
    //Metamagic extension if needed
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration * 2;  //Duration is +100%
    }
    //Summon the appropriate creature based on the summoner level
    if (spell.Level <= 5)
    {
        //Tyrant Fog Zombie
        eSummon = EffectSummonCreature("sum_zombtyrant",VFX_FNF_SUMMON_UNDEAD);
    }
    else if ((spell.Level >= 6) && (spell.Level <= 9))
    {
        //Skeleton Warrior
        eSummon = EffectSummonCreature("sum_skelwar",VFX_FNF_SUMMON_UNDEAD);
    }
    else
    {
        //Skeleton Chieftain
        eSummon = EffectSummonCreature("sum_skelchief",VFX_FNF_SUMMON_UNDEAD);
    }
    //Apply the summon visual and summon the two undead.
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eSummon, spell.Loc, DurationToSeconds(nDuration));
}

//::///////////////////////////////////////////////
//:: Mummy Dust
//:: X2_S2_MumDust
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
     Summons a strong warrior mummy for you to
     command.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Feb 07, 2003
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
    //Summon the appropriate creature based on the summoner level
    //Warrior Mummy
    effect eSummon = EffectSummonCreature("X2_S_MUMMYWARR",VFX_FNF_SUMMON_EPIC_UNDEAD,1.0);
    eSummon = ExtraordinaryEffect(eSummon);
    //Apply the summon visual and summon the undead.
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eSummon, spell.Loc, DurationToSeconds(nDuration));
}

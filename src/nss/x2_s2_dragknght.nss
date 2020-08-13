//::///////////////////////////////////////////////
//:: Dragon Knight
//:: X2_S2_DragKnght
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
     Summons an adult red dragon for you to
     command.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Feb 07, 2003
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x2_inc_toollib"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.Limit = 20;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDuration = spell.Limit;
    effect eVis = EffectVisualEffect(VFX_IMP_DUST_EXPLOSION);
    effect eSummon = EffectSummonCreature("x2_s_drgred001",VFX_FNF_SUMMONDRAGON,0.0,TRUE);

    // * make it so dragon cannot be dispelled
    eSummon = ExtraordinaryEffect(eSummon);
    //Apply the summon visual and summon the dragon.
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eSummon, spell.Loc, DurationToSeconds(nDuration));
    DelayCommand(1.0,ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eVis, spell.Loc));
}

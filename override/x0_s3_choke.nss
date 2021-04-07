//::///////////////////////////////////////////////
//:: Choking Powder
//:: x0_s3_choke
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creates a stinking cloud where thrown for 5 rounds.
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: September 10, 2002
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //Declare major variables
    spellsDeclareMajorVariables();
    effect eAOE = EffectAreaOfEffect(AOE_PER_FOGSTINK, "x0_s3_chokeen", "x0_s3_chokeHB", "");
    int nDuration = 5;
    effect eImpact = EffectVisualEffect(259);
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spell.Loc);

    //Create the AOE object at the selected location
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spell.Loc, RoundsToSeconds(nDuration));
    spellsSetupNewAOE("VFX_PER_FOGSTINK","x0_s3_chokehb");
}

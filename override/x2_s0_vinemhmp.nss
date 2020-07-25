//::///////////////////////////////////////////////
//:: Vine Mine, Hamper Movement
//:: X2_S0_VineMHmp
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creatures entering the zone of grease must make
    a reflex save or fall down.  Those that make
    their save have their movement reduced by 1/2.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 25, 2002
//:://////////////////////////////////////////////
/*
Patch 1.70

- extend metamagic didn't worked
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_TURNS;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables including Area of Effect Object
    spellsDeclareMajorVariables();
    effect eAOE = EffectAreaOfEffect(AOE_PER_ENTANGLE, "X2_S0_VineMHmpA", "X2_S0_VineMHmpC", "X2_S0_VineMHmpB");
    int nDuration = spell.Level;
    //Check Extend metamagic feat.
    if(spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2;    //Duration is +100%
    }

    //Create an instance of the AOE Object using the Apply Effect function
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spell.Loc, DurationToSeconds(nDuration));
    spellsSetupNewAOE("VFX_PER_ENTANGLE","x2_s0_vinemhmpc");
}

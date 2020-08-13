//::///////////////////////////////////////////////
//:: Wall of Fire
//:: NW_S0_WallFire.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creates a wall of fire that burns any creature
    entering the area around the wall.  Those moving
    through the AOE are burned for 4d6 fire damage
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: July 17, 2001
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_FIRE;
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare Area of Effect object using the appropriate constant
    spellsDeclareMajorVariables();
    effect eAOE = EffectAreaOfEffect(AOE_PER_WALLFIRE);
    //Get the location where the wall is to be placed.
    int nDuration = spell.Level/2;
    if(nDuration < 1)
    {
        nDuration = 1;
    }

    //Check fort metamagic
    if(spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2;   //Duration is +100%
    }
    //Create the Area of Effect Object declared above.
    ApplyEffectAtLocation(DURATION_TYPE_TEMPORARY, eAOE, spell.Loc, DurationToSeconds(nDuration));
    spellsSetupNewAOE("VFX_PER_WALLFIRE","nw_s0_wallfirec");
}

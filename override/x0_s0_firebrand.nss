//::///////////////////////////////////////////////
//:: Firebrand
//:: x0_x0_Firebrand
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
// * Fires a flame arrow to every target in a
// * colossal area
// * Each target explodes into a small fireball for
// * 1d6 damage / level (max = 15 levels)
// * Only nLevel targets can be affected
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: July 29 2002
//:://////////////////////////////////////////////
//:: Last Updated By:

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageCap = 15;//max 15d6 damage
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_FIRE;
    spell.Limit = 15;//maximum 15 missiles
    spell.Range = RADIUS_SIZE_GARGANTUAN;
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_SELECTIVEHOSTILE;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    int nDamage =  spell.Level;
    if (nDamage > spell.DamageCap)
        nDamage = spell.DamageCap;

    DoMissileStorm(nDamage, spell.Limit, spell.Id, VFX_IMP_MIRV_FLAME, spell.DmgVfxL, spell.DamageType, TRUE, TRUE);
}

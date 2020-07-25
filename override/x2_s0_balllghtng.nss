//::///////////////////////////////////////////////
//:: Ball Lightning
//:: x2_s0_balllghtng
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
 Up to 15 missiles, each doing 1d6 damage to single target.
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: July 31, 2002
//:://////////////////////////////////////////////
//:: Last Updated By:
/*
Patch 1.71

- spell target area changed to the single target as per spell's description
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageCap = 1;//max 1d6 damage
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_ELECTRICAL;
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

    int nDamage = spell.Level;
    if (nDamage > spell.DamageCap)
        nDamage = spell.DamageCap;

    DoMissileStorm(nDamage, spell.Limit, spell.Id, 503, spell.DmgVfxS, spell.DamageType, FALSE, TRUE);
}

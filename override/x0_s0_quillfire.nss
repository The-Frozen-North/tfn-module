//::///////////////////////////////////////////////
//:: Quillfire
//:: [x0_s0_quillfire.nss]
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Fires a cluster of quills at a target. Ranged Attack.
    2d8 + 1 point /2 levels (max 5)

*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: July 17 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Andrew Nobbs May 02, 2003
/*
Patch 1.71

- poison made extraordinary
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 8;
    spell.DamageType = DAMAGE_TYPE_MAGICAL;
    spell.Limit = 5;
    spell.SavingThrow = SAVING_THROW_NONE;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(VFX_IMP_ACID_S);

    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        //Apply a single damage hit for each missile instead of as a single mass
        // BK: No spell resistance for quillfire
        //eMissile = EffectVisualEffect(VFX_IMP_MIRV_FLAME);
        //* apply bonus damage for level
        int nBonus = spell.Level / 2;
        if (nBonus > spell.Limit)
        {
            nBonus = spell.Limit;
        }
        //Roll damage
        int nDamage = MaximizeOrEmpower(spell.Dice,1,spell.Meta,nBonus);
        //1.72: this will do nothing by default, but allows to dynamically enforce saving throw
        if(MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, SAVING_THROW_TYPE_POISON, spell.Caster))
        {
            nDamage/= 2;
        }
        effect eDam = EffectDamage(nDamage, spell.DamageType);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, spell.Target);
        // * also applies poison damage
        effect ePoison = EffectPoison(POISON_LARGE_SCORPION_VENOM);
        ePoison = ExtraordinaryEffect(ePoison);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, ePoison, spell.Target);

        //Apply the MIRV and damage effect
        //ApplyEffectToObject(DURATION_TYPE_INSTANT, eMissile, oTarget);
    }
}

//::///////////////////////////////////////////////
//:: Ray of Frost
//:: [NW_S0_RayFrost.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
/*
    If the caster succeeds at a ranged touch attack
    the target takes 1d4 damage.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: feb 4, 2001
//:://////////////////////////////////////////////
//:: Bug Fix: Andrew Nobbs, April 17, 2003
//:: Notes: Took out ranged attack roll.
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 4;
    spell.DamageType = DAMAGE_TYPE_COLD;
    spell.SavingThrow = SAVING_THROW_NONE;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDamage = MaximizeOrEmpower(spell.Dice,1,spell.Meta,1);
    //1.72: this will do nothing by default, but allows to dynamically enforce saving throw
    nDamage = GetSavingThrowAdjustedDamage(nDamage, spell.Target, spell.DC, spell.SavingThrow, spell.SaveType, spell.Caster);
    effect eDam;
    effect eVis = EffectVisualEffect(spell.DmgVfxS);
    effect eRay = EffectBeam(VFX_BEAM_COLD, spell.Caster, BODY_NODE_HAND);

    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        //Make SR Check
        if(!MyResistSpell(spell.Caster, spell.Target))
        {
            //Set damage effect
            eDam = EffectDamage(nDamage, spell.DamageType);
            //Apply the VFX impact and damage effect
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target);
        }
    }
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRay, spell.Target, 1.7);
}

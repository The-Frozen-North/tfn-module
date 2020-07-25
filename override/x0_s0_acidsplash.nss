//::///////////////////////////////////////////////
//:: Acid Splash
//:: [X0_S0_AcidSplash.nss]
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
1d3 points of acid damage to one target.
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: July 17 2002
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 3;
    spell.DamageType = DAMAGE_TYPE_ACID;
    spell.SavingThrow = SAVING_THROW_NONE;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(spell.DmgVfxS);

    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        //Make SR Check
        if(!MyResistSpell(spell.Caster, spell.Target))
        {
            //Set damage effect
            int nDamage = MaximizeOrEmpower(spell.Dice, 1, spell.Meta);
            nDamage = GetSavingThrowAdjustedDamage(nDamage, spell.Target, spell.DC, spell.SavingThrow, spell.SaveType, spell.Caster);
            effect eBad = EffectDamage(nDamage, spell.DamageType);
            //Apply the VFX impact and damage effect
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eBad, spell.Target);
        }
    }
}

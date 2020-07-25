//::///////////////////////////////////////////////
//:: [Inflict Wounds]
//:: [X0_S0_Inflict.nss]
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
//:: This script is used by all the inflict spells
//::
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: July 2002
//:://////////////////////////////////////////////
//:: VFX Pass By:
/*
Patch 1.72
- touch attack will be skipped in case a target is a caster himself
Patch 1.71
- touch attack won't be done if target is undead
- added missing saving throw subtype as per spell's descriptor
- changed visual effect to less intrusive one
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = GetSpellId() == SPELL_INFLICT_MINOR_WOUNDS ? 1 : 8;
    spell.DamageType = DAMAGE_TYPE_NEGATIVE;
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDice = spell.Dice;
    int nNumDice = 1;
    int nMaxExtraDamage = 0;
    int vfx_impactHurt = spell.DmgVfxS;
    switch (spell.Id)
    {
/*Light*/     case 432: case 609: nMaxExtraDamage = 5; break;
/*Moderate*/  case 433: case 610: nNumDice = 2; nMaxExtraDamage = 10; break;
/*Serious*/   case 434: case 611: nNumDice = 3; nMaxExtraDamage = 15; vfx_impactHurt = spell.DmgVfxL; break;
/*Critical*/  case 435: case 612: nNumDice = 4; nMaxExtraDamage = 20; vfx_impactHurt = spell.DmgVfxL; break;
/*Minor*/     default: break;
    }

    int nExtraDamage = spell.Level; // * figure out the bonus damage
    if (nExtraDamage > nMaxExtraDamage)
    {
        nExtraDamage = nMaxExtraDamage;
    }
    //Check for metamagic
    int nDamage = MaximizeOrEmpower(nDice,nNumDice,spell.Meta,nExtraDamage);

    //Check that the target is undead
    if(spellsIsRacialType(spell.Target, RACIAL_TYPE_UNDEAD))
    {
        effect eVis2 = EffectVisualEffect(VFX_IMP_HEALING_G);
        //Figure out the amount of damage to heal
        //nHeal = nDamage;
        //Set the heal effect
        effect eHeal = EffectHeal(nDamage + nExtraDamage);
        //Apply heal effect and VFX impact
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, spell.Target);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, spell.Target);
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    }        //do touch attack only if not undead
    else if (spell.Target == spell.Caster || TouchAttackMelee(spell.Target) > 0)
    {
        if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
            if (!MyResistSpell(spell.Caster, spell.Target))
            {
                // A succesful will save halves the damage
                if(MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, spell.SaveType, spell.Caster))
                {
                    nDamage = nDamage / 2;
                }
                effect eVis = EffectVisualEffect(vfx_impactHurt);
                effect eDam = EffectDamage(nDamage,spell.DamageType);
                //Apply the VFX impact and effects
                DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target));
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
            }
        }
    }
}

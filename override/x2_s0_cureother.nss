//::///////////////////////////////////////////////
//:: x2_s0_cureother
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Cure Critical Wounds on Others - causes 5 points
    of damage to the spell caster as well.
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: Jan 2/03
//:://////////////////////////////////////////////
/*
Patch 1.71

- missing saving throw added
- the healing domain power doesn't work anymore when the spell is cast from an item
- corrected maximized spell damage
- undeads are now damaged by positive (was negative)
- target type changed from standard hostile to the single target
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 8;
    spell.DamageType = DAMAGE_TYPE_POSITIVE;
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
    int nNumDice = 4;
    int nMaxExtraDamage = 20;
    int vfx_impactHurt = spell.DmgVfxS;
    int vfx_impactHeal = VFX_IMP_SUPER_HEROISM;

    int nExtraDamage = spell.Level; // * figure out the bonus damage
    if (nExtraDamage > nMaxExtraDamage)
    {
        nExtraDamage = nMaxExtraDamage;
    }

    if(GetIsPC(spell.Target) && GetGameDifficulty() < GAME_DIFFICULTY_CORE_RULES)
    {   // * if low or normal difficulty then MAXMIZED is doubled.
        if(spell.Meta & METAMAGIC_MAXIMIZE)
        {
            nExtraDamage = nExtraDamage*2;
        }
        spell.Meta+= METAMAGIC_MAXIMIZE;
    }

    //Calculate damage
    int nDamage = MaximizeOrEmpower(nDice,nNumDice,spell.Meta,nExtraDamage);

    if(!(spell.Meta & METAMAGIC_EMPOWER) && spell.Item == OBJECT_INVALID && GetHasFeat(FEAT_HEALING_DOMAIN_POWER, spell.Caster))
    {   // * if the caster has healing domain, the spell is empowered
        nDamage = nDamage + (nDamage/2);
    }

    if (!spellsIsRacialType(spell.Target, RACIAL_TYPE_UNDEAD))
    {
        if (spell.Target != spell.Caster)
        {
            //Set the heal effect
            effect eHeal = EffectHeal(nDamage);
            //Apply heal effect and VFX impact
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, spell.Target);
            effect eVis2 = EffectVisualEffect(vfx_impactHeal);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, spell.Target);

            //Apply Damage Effect to the Caster
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(5), spell.Caster);
            //Fire cast spell at event for the specified target
            SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, SPELL_CURE_CRITICAL_WOUNDS, FALSE));
        }
    }
    //Check that the target is undead
    else
    {
        int nTouch = TouchAttackMelee(spell.Target);
        if (nTouch > 0)
        {
            if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, SPELL_CURE_CRITICAL_WOUNDS));
                if (!MyResistSpell(spell.Caster, spell.Target))
                {
                    if(MySavingThrow(spell.SavingThrow,spell.Target,spell.DC,spell.SaveType,spell.Caster))
                    {
                        nDamage/= 2;
                    }
                    effect eDam = EffectDamage(nDamage,spell.DamageType);
                    //Apply the VFX impact and effects
                    DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target));
                    effect eVis = EffectVisualEffect(vfx_impactHurt);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
                }
            }
            //Apply Damage Effect to the Caster
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(5), spell.Caster);
        }
    }
}

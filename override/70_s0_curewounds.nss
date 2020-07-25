//::///////////////////////////////////////////////
//:: Cure Wounds Multi-spell script
//:: 70_s0_curewounds
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
// Reason for this spellscript is to allow builder change all cure spells (with
// the exception of the circle of healing and "cure wounds - other" easily).
// This was possible in vanilla because all spellscripts used the function spellsCure
// from nw_i0_spells, but that had to be externalized from there to allow usage of
// the MaximizeOrEmpower function. Another choice was to change function name and
// add it into different include but this has backwards compatibility issues.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow
//:: Created On: Feb 22, 2014
//:://////////////////////////////////////////////
/*
Patch 1.72
- touch attack will be skipped in case target is a caster himself
Patch 1.71
- missing saving throw added
- the healing domain power doesn't work anymore when the spell is cast from an item
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = GetSpellId() == SPELL_CURE_MINOR_WOUNDS ? 4 : 8;
    spell.DamageType = DAMAGE_TYPE_POSITIVE;
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //declare major variables
    spellsDeclareMajorVariables();
    int nDice, nNumDice, nMaxExtraDamage, vfx_impactHurt, vfx_impactHeal;
    switch(spell.Id)
    {
        case SPELL_CURE_CRITICAL_WOUNDS:
        nDice = spell.Dice; nNumDice = 4; nMaxExtraDamage = 20; vfx_impactHurt = spell.DmgVfxL; vfx_impactHeal = VFX_IMP_HEALING_L;
        break;
        case SPELL_CURE_LIGHT_WOUNDS:
        case SPELLABILITY_LESSER_BODY_ADJUSTMENT:
        nDice = spell.Dice; nNumDice = 1; nMaxExtraDamage = 5; vfx_impactHurt = spell.DmgVfxS; vfx_impactHeal = VFX_IMP_HEALING_S;
        break;
        case SPELL_CURE_MINOR_WOUNDS:
        nDice = spell.Dice; nNumDice = 1; nMaxExtraDamage = 0; vfx_impactHurt = spell.DmgVfxS; vfx_impactHeal = VFX_IMP_HEAD_HEAL;
        break;
        case SPELL_CURE_MODERATE_WOUNDS:
        nDice = spell.Dice; nNumDice = 2; nMaxExtraDamage = 10; vfx_impactHurt = spell.DmgVfxS; vfx_impactHeal = VFX_IMP_HEALING_M;
        break;
        case SPELL_CURE_SERIOUS_WOUNDS:
        nDice = spell.Dice; nNumDice = 3; nMaxExtraDamage = 15; vfx_impactHurt = spell.DmgVfxL; vfx_impactHeal = VFX_IMP_HEALING_L;
        break;
    }

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
        spell.Meta|= METAMAGIC_MAXIMIZE;//this will make spell also maximized if not already
    }

    //Calculate damage
    int nDamage = MaximizeOrEmpower(nDice,nNumDice,spell.Meta,nExtraDamage);

    if(!(spell.Meta & METAMAGIC_EMPOWER) && spell.Item == OBJECT_INVALID && GetHasFeat(FEAT_HEALING_DOMAIN_POWER, spell.Caster))
    {   // * if the caster has healing domain, the spell is empowered
        nDamage = nDamage + (nDamage/2);
    }

    if(!spellsIsRacialType(spell.Target, RACIAL_TYPE_UNDEAD))
    {
        //Set the heal effect
        effect eHeal = EffectHeal(nDamage);
        //Apply heal effect and VFX impact
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, spell.Target);
        effect eVis2 = EffectVisualEffect(vfx_impactHeal);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, spell.Target);
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    }
    //Check that the target is undead
    else
    {
        if (spell.Target == spell.Caster || TouchAttackMelee(spell.Target) > 0)
        {
            if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
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
        }
    }
}

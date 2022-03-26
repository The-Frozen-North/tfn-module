//::///////////////////////////////////////////////
//:: Crumble
//:: X2_S0_Crumble
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
// This spell inflicts 1d6 points of damage per
// caster level to Constructs to a maximum of 15d6.
// This spell does not affect living creatures.
*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: Oct 2003/
//:: 2004-01-02: GZ: Removed Spell resistance check
//:://////////////////////////////////////////////
/*
Patch 1.71

- due to the bug, it couldn't affect neither placeables or doors
- was missing target check and could affect friendly tarets at no-pvp area
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 6;
    spell.DamageCap = 15;
    spell.DamageType = DAMAGE_TYPE_SONIC;
    spell.SavingThrow = SAVING_THROW_NONE;
    spell.SR = NO;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int  nCasterLvl = spell.Level;
    int  nType      = GetObjectType(spell.Target);

    //Maximum caster level of 15. //minimum safety check is handled in new engine
    if (nCasterLvl > spell.DamageCap)
    {
        nCasterLvl = spell.DamageCap;
    }

    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster) &&
    ((nType == OBJECT_TYPE_PLACEABLE || nType == OBJECT_TYPE_DOOR) ||
    (nType == OBJECT_TYPE_CREATURE && (spellsIsRacialType(spell.Target, RACIAL_TYPE_CONSTRUCT) || GetLevelByClass(CLASS_TYPE_CONSTRUCT,spell.Target)))))
    {
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        //1.72: this will do nothing by default, but allows to dynamically enforce spell resistance
        if (spell.SR != YES || !MyResistSpell(spell.Caster, spell.Target))
        {
            effect eCrumb = EffectVisualEffect(VFX_FNF_SCREEN_SHAKE);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eCrumb, spell.Target);

            int nDamage = MaximizeOrEmpower(spell.Dice,nCasterLvl,spell.Meta);
            //1.72: this will do nothing by default, but allows to dynamically enforce saving throw
            if(MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, spell.SaveType, spell.Caster))
            {
                nDamage/= 2;
            }

            if (nDamage > 0)
            {
                float  fDist = GetDistanceBetween(spell.Caster, spell.Target);
                float  fDelay = fDist/(3.0 * log(fDist) + 2.0);
                effect eDam = EffectDamage(nDamage, spell.DamageType);
                effect eMissile = EffectVisualEffect(VFX_FNF_MYSTICAL_EXPLOSION);
                effect eCrumb = EffectVisualEffect(VFX_FNF_SCREEN_SHAKE);
                effect eVis = EffectVisualEffect(135);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eCrumb, spell.Target);
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, spell.Target));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target));
                DelayCommand(0.5, ApplyEffectToObject(DURATION_TYPE_INSTANT, eMissile, spell.Target));
            }
        }
    }
}

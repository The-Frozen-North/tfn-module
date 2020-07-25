//::///////////////////////////////////////////////
//:: Vampiric Touch
//:: NW_S0_VampTch
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    drain 1d6
    HP per 2 caster levels from the target.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 29, 2001
//:://////////////////////////////////////////////
/*
bugfix by Kovi 2002.07.22
- did double damage with maximize
- temporary hp was stacked
2002.08.25
- got temporary hp some immune creatures (Negative Energy Protection), lost
temporary hp against other resistant (SR, Shadow Shield)

Georg 2003-09-11
- Put in melee touch attack check, as the fixed attack bonus is now calculated correctly

Patch 1.72
- touch attack will be skipped in case a target is a caster himself
Patch 1.70
- all temp hitpoints was removed even from other sources
- temp hitpoints were removed even in case that target was dead
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageCap = 10;
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_NEGATIVE;
    spell.SavingThrow = SAVING_THROW_NONE;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDDice = spell.Level/2;
    if (nDDice < 1)
    {
        nDDice = 1;
    }
    //--------------------------------------------------------------------------
    // GZ: Cap according to the book
    //--------------------------------------------------------------------------
    else if (nDDice > spell.DamageCap)
    {
        nDDice = spell.DamageCap;
    }

    //--------------------------------------------------------------------------
    //Enter Metamagic conditions
    //--------------------------------------------------------------------------

    int nDamage = MaximizeOrEmpower(spell.Dice,nDDice,spell.Meta);
    int nDuration = spell.Level/2;

    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration *= 2;
    }

    //--------------------------------------------------------------------------
    //Limit damage to max hp + 10
    //--------------------------------------------------------------------------
    int nMax = GetCurrentHitPoints(spell.Target) + 10;
    if(nMax < nDamage)
    {
        nDamage = nMax;
    }

    //1.72: this will do nothing by default, but allows to dynamically enforce saving throw
    if(MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, spell.SaveType, spell.Caster))
    {
        nDamage/= 2;
    }

    effect eHeal = EffectTemporaryHitpoints(nDamage);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eLink = EffectLinkEffects(eHeal, eDur);

    effect eDamage = EffectDamage(nDamage, spell.DamageType);
    effect eVis = EffectVisualEffect(spell.DmgVfxL);
    effect eVisHeal = EffectVisualEffect(VFX_IMP_HEALING_M);
    if(GetObjectType(spell.Target) == OBJECT_TYPE_CREATURE)
    {
        // GZ: * GetSpellCastItem() == OBJECT_INVALID is used to prevent feedback from showing up when used as OnHitCastSpell property
        if (spell.Target == spell.Caster || TouchAttackMelee(spell.Target)>0)//first touch, then ask
        {
         if(!spellsIsRacialType(spell.Target, RACIAL_TYPE_UNDEAD) && //not an undead
            !spellsIsRacialType(spell.Target, RACIAL_TYPE_CONSTRUCT) && //not an construct
            !GetHasSpellEffect(SPELL_NEGATIVE_ENERGY_PROTECTION, spell.Target) && //not protected against neg energy (this is however not versatile, spell still works on targets with 100% damage immunity or 60+ negative damage resistance from item, see below)
            spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
            {
                SignalEvent(spell.Caster, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
                SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, TRUE));
                if(!MyResistSpell(spell.Caster, spell.Target))
                {
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
                    /*
                    if we really would want this spell not to work on targets immune to negative energy
                    we should do this:
                    int previousHP = GetCurrentHitPoints(spell.Target);
                    */
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDamage, spell.Target);
                    /*
                    if(GetCurrentHitPoints(spell.Target) != previousHP)//the target wasn't 100% immune
                    {
                        //do spell effects
                    }
                    */
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVisHeal, spell.Caster);
                    RemoveTempHP(spell.Id, spell.Caster);
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Caster, HoursToSeconds(nDuration));
                }
            }
        }
    }
}

//::///////////////////////////////////////////////
//:: Healing Sting
//:: X2_S0_HealStng
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    You inflict 1d6 +1 point per level damage to
    the living creature touched and gain an equal
    amount of hit points. You may not gain more
    hit points then your maximum with the Healing
    Sting.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 19, 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Georg Zoeller, 19/10/2003

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_NEGATIVE;
    spell.SavingThrow = SAVING_THROW_FORT;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    //object oCaster = GetCurrentHitPoints(OBJECT_SELF);
    int nCasterLvl = spell.Level;
    int nDamage = MaximizeOrEmpower(spell.Dice,1,spell.Meta,spell.Level);

    //Declare effects
    effect eHeal = EffectHeal(nDamage);
    effect eVs = EffectVisualEffect(VFX_IMP_HEALING_M);
    effect eLink = EffectLinkEffects(eVs,eHeal);

    effect eDamage = EffectDamage(nDamage, spell.DamageType);
    effect eVis = EffectVisualEffect(spell.DmgVfxS);
    effect eLink2 = EffectLinkEffects(eVis,eDamage);

    if(GetObjectType(spell.Target) == OBJECT_TYPE_CREATURE)
    {
        if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster) &&
            !spellsIsRacialType(spell.Target, RACIAL_TYPE_UNDEAD) &&
            !spellsIsRacialType(spell.Target, RACIAL_TYPE_CONSTRUCT) &&
            !GetHasSpellEffect(SPELL_NEGATIVE_ENERGY_PROTECTION, spell.Target))
        {
           //Signal spell cast at event

            SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
            //Spell resistance
            if(!MyResistSpell(spell.Caster, spell.Target))
            {
                if(!MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, spell.SaveType, spell.Caster))
                {
                    //Apply effects to target and caster
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eLink2, spell.Target);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eLink, spell.Caster);
                    SignalEvent(spell.Caster, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
                }
            }
        }
    }
}

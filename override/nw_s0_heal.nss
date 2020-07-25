//::///////////////////////////////////////////////
//:: Heal
//:: [NW_S0_Heal.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Heals the target to full unless they are undead.
//:: If undead they reduced to 1d4 HP.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 12, 2001
//:://////////////////////////////////////////////
//:: Update Pass By: Preston W, On: Aug 1, 2001
/*
Patch 1.72
- touch attack will be skipped in case target is a caster himself
Patch 1.70
- dying target wasn't healed to its maximum hitpoints
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageType = DAMAGE_TYPE_POSITIVE;
    spell.SavingThrow = SAVING_THROW_NONE;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eKill, eHeal;
    int nDamage, nHeal, nModify, nTouch;
    effect eSun = EffectVisualEffect(spell.DmgVfxL);
    effect eHealVis = EffectVisualEffect(VFX_IMP_HEALING_X);
    //Check to see if the target is an undead
    if (spellsIsRacialType(spell.Target, RACIAL_TYPE_UNDEAD))
    {
        if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
            //Make a touch attack
            if (spell.Target == spell.Caster || TouchAttackMelee(spell.Target))
            {
                //Make SR check
                if (!MyResistSpell(spell.Caster, spell.Target))
                {
                    //Roll damage
                    nModify = d4();
                    //Make metamagic check
                    if (spell.Meta & METAMAGIC_MAXIMIZE)
                    {
                        nModify = 1;
                    }
                    //Figure out the amount of damage to inflict
                    nDamage = GetCurrentHitPoints(spell.Target) - nModify;
                    //1.72: this will do nothing by default, but allows to dynamically enforce saving throw
                    if(MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, spell.SaveType, spell.Caster))
                    {
                        nDamage/= 2;
                    }
                    //Set damage
                    eKill = EffectDamage(nDamage, spell.DamageType);
                    //Apply damage effect and VFX impact
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eKill, spell.Target);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eSun, spell.Target);
                }
            }
        }
    }
    else
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
        //Figure out how much to heal
        nHeal = GetMaxHitPoints(spell.Target)- GetCurrentHitPoints(spell.Target);
        //Set the heal effect
        eHeal = EffectHeal(nHeal);
        //Apply the heal effect and the VFX impact
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eHealVis, spell.Target);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eHeal, spell.Target);
    }
}

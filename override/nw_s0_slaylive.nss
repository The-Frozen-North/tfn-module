//::///////////////////////////////////////////////
//:: [Slay Living]
//:: [NW_S0_SlayLive.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Caster makes a touch attack and if the target
//:: fails a Fortitude save they die.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: January 22nd / 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk, On: April 11, 2001
//:: VFX Pass By: Preston W, On: June 25, 2001
/*
Patch 1.72
- touch attack will be skipped in case a target is a caster himself
Patch 1.71
- added missing impact damage visual effect
- touch attack occured too late
*/

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

    int nDamage;
    effect eDam;
    effect eVis = EffectVisualEffect(VFX_IMP_DEATH);
    effect eVis2 = EffectVisualEffect(spell.DmgVfxL);

    //Make melee touch attack
    if(spell.Target == spell.Caster || TouchAttackMelee(spell.Target))//touch attack first as its usual in other similar spells
    {
        if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
            //Make SR check
            if(!MyResistSpell(spell.Caster, spell.Target))
            {
                //Make Fort save
                switch(MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, SAVING_THROW_TYPE_DEATH, spell.Caster))
                {
                case 0: //failed in save
                    //Apply the death effect and VFX impact
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), spell.Target);
                    //ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
                    break;
                case 1: //succeded in save
                    //Roll damage
                    nDamage = MaximizeOrEmpower(spell.Dice,3,spell.Meta,spell.Level);
                    //Apply damage effect and VFX impact
                    eDam = EffectDamage(nDamage, spell.DamageType);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, spell.Target);
                    break;
                case 2: //immune to the death
                    // Target shouldn't take damage if they are immune to death magic.
                    break;
                }
            }
        }
    }
}

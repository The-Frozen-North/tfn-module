//::///////////////////////////////////////////////
//:: Phantasmal Killer
//:: NW_S0_PhantKill
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Target of the spell must make 2 saves or die.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Dec 14 , 2001
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 22, 2001
//:: Update Pass By: Preston W, On: Aug 3, 2001
/*
Patch 1.70

- second saving throw subtype changed to fear (as per spell's descriptors)
- missing feedback when target was fear immune
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_MAGICAL;
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDamage = MaximizeOrEmpower(spell.Dice,3,spell.Meta);
    effect eDam;
    effect eVis = EffectVisualEffect(VFX_IMP_DEATH);
    effect eVis2 = EffectVisualEffect(VFX_IMP_SONIC);
    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        //Make an SR check
        if(!MyResistSpell(spell.Caster, spell.Target))
        {
            // Immunity to fear or mind spells, makes you immune to Phantasmal Killer.
            if (!GetIsImmune(spell.Target, IMMUNITY_TYPE_FEAR, spell.Caster) && !GetIsImmune(spell.Target, IMMUNITY_TYPE_MIND_SPELLS, spell.Caster))
            {
                //Make a Will save //1.70 - removed, the immunity and feedback is now handled differently
                if (!MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, SAVING_THROW_TYPE_MIND_SPELLS, spell.Caster))
                {
                    //Make a Fort save
                    if (MySavingThrow(SAVING_THROW_FORT, spell.Target, spell.DC, SAVING_THROW_TYPE_FEAR, spell.Caster))
                    {
                         //Set the damage property
                         eDam = EffectDamage(nDamage, spell.DamageType);
                         //Apply the damage effect and VFX impact
                         ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target);
                         ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis2, spell.Target);
                    }
                    else
                    {
                         //Apply the death effect and VFX impact
                         // Immunity to death magic, should not make you immune to Phantasmal Killer.
                         // So we need to make the effect supernatural.
                         ApplyEffectToObject(DURATION_TYPE_INSTANT, SupernaturalEffect(EffectDeath()), spell.Target);
                         //uncommented because of save subtype changed
                         ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
                    }
                }
            }
            else//fear or mind spells immune
            {
                //engine workaround to get proper feedback and VFX
                eVis = EffectVisualEffect(VFX_IMP_MAGIC_RESISTANCE_USE);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectFrightened(), spell.Target, 1.0);
            }
        }
    }
}

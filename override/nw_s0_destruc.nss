//::///////////////////////////////////////////////
//:: Destruction
//:: NW_S0_Destruc
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The target creature is destroyed if it fails a
    Fort save, otherwise it takes 10d6 damage.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Aug 13, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- saving throw subtype changed to death
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_DIVINE;
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
    effect eDeath = EffectDeath();
    effect eDam;
    effect eVis = EffectVisualEffect(VFX_IMP_DESTRUCTION);
    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        //Make SR check
        if(!MyResistSpell(spell.Caster, spell.Target))
        {
            //Make a fortitude saving throw check
            switch(MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, SAVING_THROW_TYPE_DEATH, spell.Caster))
            {
            case 0: //failed in save
                //Apply the VFX impact and effects
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDeath, spell.Target);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
                break;
            case 1: //succeded in save
                nDamage = MaximizeOrEmpower(spell.Dice,10,spell.Meta);
                //Set damage effect
                eDam = EffectDamage(nDamage, spell.DamageType);
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target);
                //Apply VFX impact
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
                break;
            case 2: //immune to the death
                // Target shouldn't take damage if they are immune to death magic.
                break;
            }
        }
    }
}

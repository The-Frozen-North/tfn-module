//::///////////////////////////////////////////////
//:: Finger of Death
//:: NW_S0_FingDeath
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
// You can slay any one living creature within range.
// The victim is entitled to a Fortitude saving throw to
// survive the attack. If he succeeds, he instead
// sustains 3d6 points of damage +1 point per caster
// level.
*/
//:://////////////////////////////////////////////
//:: Created By: Noel Borstad
//:: Created On: Oct 17, 2000
//:://////////////////////////////////////////////
//:: Updated By: Georg Z, On: Aug 21, 2003 - no longer affects placeables
/*
Patch 1.71

- target selection scheme changed from selective to singe-target to allow target neutral creatures
- corrected immunity check (now handled in engine)
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
    effect eVis = EffectVisualEffect(VFX_IMP_DEATH_L);
    effect eVis2 = EffectVisualEffect(spell.DmgVfxL);

    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //GZ: I still signal this event for scripting purposes, even if a placeable
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        if(GetObjectType(spell.Target) == OBJECT_TYPE_CREATURE)
        {

            //Make SR check
            if(!MyResistSpell(spell.Caster, spell.Target))
            {
                //Make Fortitude save
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
                    //Set damage effect
                    eDam = EffectDamage(nDamage, DAMAGE_TYPE_NEGATIVE);
                    //Apply damage effect and VFX impact
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

//::///////////////////////////////////////////////
//:: Ice Dagger
//:: X2_S0_IceDagg
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
// You create a dagger shapped piece of ice that
// flies toward the target and deals 1d4 points of
// cold damage per level (maximum od 5d4)
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 25 , 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Andrew Nobbs, 02/06/2003
/*
Patch 1.70

- removed delay from VFX and effect applications
*/
#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageCap = 5;
    spell.Dice = 4;
    spell.DamageType = DAMAGE_TYPE_COLD;
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nCasterLvl = spell.Level;
    int nDamage;
    effect eVis = EffectVisualEffect(spell.DmgVfxS);
    effect eDam;

    //Limit Caster level for the purposes of damage
    if (nCasterLvl > spell.DamageCap)
    {
        nCasterLvl = spell.DamageCap;
    }
    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        //Get the distance between the explosion and the target to calculate delay
        if (!MyResistSpell(spell.Caster, spell.Target))
        {
            //Roll damage for each target
            nDamage = MaximizeOrEmpower(spell.Dice,nCasterLvl,spell.Meta);
            //Adjust the damage based on the Reflex Save, Evasion and Improved Evasion.
            nDamage = GetSavingThrowAdjustedDamage(nDamage, spell.Target, spell.DC, spell.SavingThrow, spell.SaveType, spell.Caster);
            //Set the damage effect
            eDam = EffectDamage(nDamage, spell.DamageType);
            if(nDamage > 0)
            {
                // Apply effects to the currently selected target.
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target);
                //This visual effect is applied to the target object not the location as above.  This visual effect
                //represents the flame that erupts on the target not on the ground.
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
            }
        }
    }
}

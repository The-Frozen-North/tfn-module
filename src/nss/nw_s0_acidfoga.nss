//::///////////////////////////////////////////////
//:: Acid Fog: On Enter
//:: NW_S0_AcidFogA.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    All creatures within the AoE take 2d6 acid damage
    per round and upon entering if they fail a Fort Save
    their movement is halved.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 17, 2001
//:://////////////////////////////////////////////
/*
Patch 1.71

- speed decrease was dispellable
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_ACID;
    spell.SavingThrow = SAVING_THROW_FORT;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    //Declare major variables
    aoesDeclareMajorVariables();
    int nDamage;
    effect eDam;
    effect eVis = EffectVisualEffect(spell.DmgVfxS);
    effect eSlow = EffectMovementSpeedDecrease(50);
    eSlow = ExtraordinaryEffect(eSlow);
    object oTarget = GetEnteringObject();
    float fDelay = GetRandomDelay(1.0, 2.2);
    if(spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
    {
        //Fire cast spell at event for the target
        SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
        //Spell resistance check
        if(!MyResistSpell(aoe.Creator, oTarget, fDelay))
        {
            //Roll Damage
            //Enter Metamagic conditions
            nDamage = MaximizeOrEmpower(spell.Dice,4,spell.Meta);

            //Make a Fortitude Save to avoid the effects of the movement hit.
            if(!MySavingThrow(spell.SavingThrow, oTarget, spell.DC, spell.SaveType, aoe.Creator, fDelay))
            {
                //slowing effect
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, eSlow, oTarget);
                // * BK: Removed this because it reduced damage, didn't make sense nDamage = d6();
            }

            //Set Damage Effect with the modified damage
            eDam = EffectDamage(nDamage, spell.DamageType);
            //Apply damage and visuals
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
        }
    }
}

//::///////////////////////////////////////////////
//:: Spike Growth: On Enter
//:: x0_s0_spikegroEN.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    All creatures within the AoE take 1d4 acid damage
    per round
*/
//:://////////////////////////////////////////////
//:: Created By: Brent Knowles
//:: Created On: September 6, 2002
//:://////////////////////////////////////////////
/*
Patch 1.70

- flying and incorporeal creatures are immune
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 4;
    spell.DamageType = DAMAGE_TYPE_PIERCING;
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    //Declare major variables
    aoesDeclareMajorVariables();
    object oTarget = GetEnteringObject();
    float fDelay = GetRandomDelay(1.0, 2.2);
    if(spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
    {
        //Fire cast spell at event for the target
        SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
        //Spell resistance check
        if(!spellsIsFlying(oTarget) && !GetCreatureFlag(oTarget, CREATURE_VAR_IS_INCORPOREAL) && !MyResistSpell(aoe.Creator, oTarget, fDelay))
        {
            int nDam = MaximizeOrEmpower(spell.Dice, 1, spell.Meta);

            effect eDam = EffectDamage(nDam, spell.DamageType);
            effect eVis = EffectVisualEffect(VFX_IMP_ACID_S);
            //Apply damage and visuals
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));

            // * only apply a slow effect from this spell once
            if(!GetHasSpellEffect(spell.Id, oTarget))
            {
                //Make a Reflex Save to avoid the effects of the movement hit.
                if(!MySavingThrow(spell.SavingThrow, oTarget, spell.DC, SAVING_THROW_TYPE_NONE, aoe.Creator, fDelay))
                {
                    effect eSpeed = EffectMovementSpeedDecrease(30);
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eSpeed, oTarget, HoursToSeconds(24));
                }
            }
        }
    }
}

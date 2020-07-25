//::///////////////////////////////////////////////
//:: Battletide
//:: X2_S0_BattTideA
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    You create an aura that steals energy from your
    enemies. Your enemies suffer a -2 circumstance
    penalty on saves, attack rolls, and damage rolls,
    once entering the aura. On casting, you gain a
    +2 circumstance bonus to your saves, attack rolls,
    and damage rolls.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Dec 04, 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Andrew Nobbs 06/06/03
/*
Patch 1.70

- moving bug fixed, now caster gains benefit of aura all the time, (cannot guarantee the others,
thats module-related)
- aoe signalized wrong spell ID
- damage decrease type changed to slashing so it affects any physical damage
- AOE effects made undispellable
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_SELECTIVEHOSTILE;

    //Declare major variables
    aoesDeclareMajorVariables();
    //create bad battletide effect
    effect eSaves = EffectSavingThrowDecrease(SAVING_THROW_ALL,2);
    effect eAttack = EffectAttackDecrease(2);
    effect eDamage = EffectDamageDecrease(2,DAMAGE_TYPE_BLUDGEONING|DAMAGE_TYPE_SLASHING|DAMAGE_TYPE_PIERCING);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink = EffectLinkEffects(eAttack,eDamage);
    eLink = EffectLinkEffects(eLink,eSaves);
    eLink = EffectLinkEffects(eLink,eDur);
    eLink = ExtraordinaryEffect(eLink);

    effect eVis = EffectVisualEffect(VFX_IMP_DOOM);
    object oTarget = GetEnteringObject();
    float fDelay;

    //Check faction of spell targets.
    if(oTarget != aoe.Owner && spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
        fDelay = GetRandomDelay(0.75, 1.75);

        //Make a SR check
        if(!MyResistSpell(aoe.Creator, oTarget, fDelay))
        {
            //Make a Fort Save
            if(!MySavingThrow(spell.SavingThrow, oTarget, spell.DC, SAVING_THROW_TYPE_NEGATIVE, aoe.Creator, fDelay))
            {
                //Apply the VFX impact and linked effects
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);
            }
        }
    }
}

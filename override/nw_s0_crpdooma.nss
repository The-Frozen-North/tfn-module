//::///////////////////////////////////////////////
//:: Creeping Doom: On Enter
//:: NW_S0_AcidFogA.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creature caught in the swarm take an initial
    damage of 1d20, but there after they take
    1d4 per swarm counter on the AOE.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 17, 2001
//:://////////////////////////////////////////////
/*
Patch 1.71

- removed errorneous SR check
- speed decrease was dispellable
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageType = DAMAGE_TYPE_PIERCING;
    spell.SR = NO;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    //Declare major variables
    aoesDeclareMajorVariables();
    int nDamage;
    effect eDam;
    effect eVis = EffectVisualEffect(spell.DmgVfxS);
    object oTarget = GetEnteringObject();
    effect eSpeed = EffectMovementSpeedDecrease(50);
    eSpeed = ExtraordinaryEffect(eSpeed);
    effect eVis2 = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eLink = EffectLinkEffects(eSpeed, eVis2);
    float fDelay;
    if(spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
    {
        //Fire cast spell at event for the target
        SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
        fDelay = GetRandomDelay(1.0, 1.8);
        //1.72: this will do nothing by default, but allows to dynamically enforce spell resistance
        if (spell.SR != YES || !MyResistSpell(aoe.Creator, oTarget, fDelay))
        {
            //Roll Damage
            nDamage = d20();
            //Set Damage Effect with the modified damage
            eDam = EffectDamage(nDamage, spell.DamageType);
            //Apply damage and visuals
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eSpeed, oTarget);
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
        }
    }
}

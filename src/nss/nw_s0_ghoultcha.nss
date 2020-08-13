//::///////////////////////////////////////////////
//:: Ghoul Touch: On Enter
//:: NW_S0_GhoulTchA.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The caster attempts a touch attack on a target
    creature.  If successful creature must save
    or be paralyzed. Target exudes a stench that
    causes all enemies to save or be stricken with
    -2 Attack, Damage, Saves and Skill Checks for
    1d6+2 rounds.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 7, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- fixed wrong effect linking that ommited attack penalty
- added metamagic into duration
- added saving throw subtype (poison) and immunity handling
- added missing signal event
- damage decrease type changed to slashing so it affects any physical damage
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    //Declare major variables
    aoesDeclareMajorVariables();
    object oTarget = GetEnteringObject();
    effect eVis = EffectVisualEffect(VFX_IMP_DOOM);
    effect eAttack = EffectAttackDecrease(2);
    effect eDamage = EffectDamageDecrease(2,DAMAGE_TYPE_SLASHING);
    effect eSave = EffectSavingThrowDecrease(SAVING_THROW_ALL, 2);
    effect eSkill = EffectSkillDecrease(SKILL_ALL_SKILLS, 2);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

    //Link Effects
    effect eLink = EffectLinkEffects(eDamage, eAttack);
    eLink = EffectLinkEffects(eLink, eSave);
    eLink = EffectLinkEffects(eLink, eSkill);
    eLink = EffectLinkEffects(eLink, eDur);
    //calculate the duration with proper metamagic handling
    int nDuration = MaximizeOrEmpower(6,1,spell.Meta,2);

    if(spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2; //Duration is +100%
    }

    if(oTarget != aoe.Creator && spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));

        if(!MyResistSpell(aoe.Creator, oTarget) && !MySavingThrow(spell.SavingThrow, oTarget, spell.DC, SAVING_THROW_TYPE_POISON, aoe.Creator))
        {
            if(!GetIsImmune(oTarget, IMMUNITY_TYPE_POISON, aoe.Creator))
            {
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration));
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
            }
            else
            {
                //engine workaround to get proper immunity feedback
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectPoison(POISON_ETTERCAP_VENOM), oTarget);
            }
        }
    }
}

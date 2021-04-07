//::///////////////////////////////////////////////
//:: [Scare]
//:: [NW_S0_Scare.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Will save or the target is scared for 1d4 rounds.
//:: NOTE THIS SPELL IS EQUAL TO **CAUSE FEAR** NOT SCARE.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 30, 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk, On: April 11, 2001
//:: Modified March 2003 to give -2 attack and damage penalties
/*
Patch 1.70

- attack and damage penalty affected also fear/mind immune
- damage decrease type changed to slashing so it affects any physical damage
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

   //Declare major variables
   spellsDeclareMajorVariables();
   int nDuration = d4();
   effect eScare = EffectFrightened();
   effect eSave = EffectSavingThrowDecrease(spell.SavingThrow, 2, SAVING_THROW_TYPE_MIND_SPELLS);
   effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_FEAR);
   effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);


   effect eDamagePenalty = EffectDamageDecrease(2,DAMAGE_TYPE_SLASHING);
   effect eAttackPenalty = EffectAttackDecrease(2);


   effect eLink = EffectLinkEffects(eMind, eScare);
   effect eLink2 = EffectLinkEffects(eSave, eDur);
   eLink2 = EffectLinkEffects(eLink2, eDamagePenalty);
   eLink2 = EffectLinkEffects(eLink2, eAttackPenalty);

   if(!GetIsImmune(spell.Target,IMMUNITY_TYPE_FEAR,spell.Caster) && !GetIsImmune(spell.Target,IMMUNITY_TYPE_MIND_SPELLS,spell.Caster))
   {
       //1.70: attack and damage penalty linked together, but only when target not immune
       eLink = EffectLinkEffects(eLink, eLink2);
   }

   //Check the Hit Dice of the creature
   if(GetHitDice(spell.Target) < 6 && GetObjectType(spell.Target) == OBJECT_TYPE_CREATURE)
   {
        // * added rep check April 2003
        if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
        {
            //Fire cast spell at event for the specified target
           SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
           //Make SR check
           if(!MyResistSpell(spell.Caster, spell.Target))
           {
                //Make Will save versus fear
                if(!MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, SAVING_THROW_TYPE_FEAR, spell.Caster))
                {
                   //Do metamagic checks
                   if (spell.Meta & METAMAGIC_EXTEND)
                   {
                       nDuration = nDuration * 2;
                   }

                   //Apply linked effects and VFX impact
                   ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
                }
            }
        }
    }
}

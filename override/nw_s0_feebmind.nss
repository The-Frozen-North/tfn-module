//::///////////////////////////////////////////////
//:: Feeblemind
//:: [NW_S0_FeebMind.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Target must make a Will save or take ability
//:: damage to Intelligence equaling 1d4 per 4 levels.
//:: Duration of 1 rounds per 2 levels.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Feb 2, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- caster level wasn't properly set to 1 when lower
- beam VFX didn't appeared when target resisted spell or succeeded in will save
- missing saving throw or immunity VFX
- immunity feedback was spoken as whisper
- maximized metamagic fixed (was quadrupling the result of the dice)
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 4;
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
    int nDuration = spell.Level/2;
    int nLoss = spell.Level/4;
    //Check to make at least 1d4 damage is done
    if (nLoss < 1)
    {
        nLoss = 1;
    }
    //Check to make sure the duration is 1 or greater
    if (nDuration < 1)
    {
        nDuration = 1;
    }
    //extended metamagic handling
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration * 2;
    }
    float fDuration = DurationToSeconds(nDuration);

    effect eVis = EffectVisualEffect(VFX_IMP_REDUCE_ABILITY_SCORE);
    effect eRay = EffectBeam(VFX_BEAM_MIND, spell.Caster, BODY_NODE_HAND);
    //ray VFX will now appears always
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRay, spell.Target, 1.0);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);


    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        //Make SR check
        if (!MyResistSpell(spell.Caster, spell.Target))
        {
            //Make an will save
            if(!MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, SAVING_THROW_TYPE_MIND_SPELLS, spell.Caster))
            {
              //calculate the proper ability damage value
              nLoss = MaximizeOrEmpower(spell.Dice,nLoss,spell.Meta);
              //Set the ability damage
              effect eFeeb = EffectAbilityDecrease(ABILITY_INTELLIGENCE, nLoss);
              effect eLink = EffectLinkEffects(eFeeb, eDur);

              //* Engine workaround for mind affecting spell without mind effect
              if(GetIsImmune(spell.Target,IMMUNITY_TYPE_MIND_SPELLS,spell.Caster))
              {
                  eLink = EffectDazed();//force target to overcome the spell effect and print immunity feedback instead
              }
              else
              {
                  //Apply the VFX impact only if not immune
                  ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
              }

              //Apply ability damage effect.
              ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, fDuration);
            }
        }
    }
}

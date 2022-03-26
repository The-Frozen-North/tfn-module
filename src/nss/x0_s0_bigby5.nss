//::///////////////////////////////////////////////
//:: Bigby's Crushing Hand
//:: [x0_s0_bigby5]
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Similar to Bigby's Grasping Hand.
    If Grapple succesful then will hold the opponent and do 2d6 + 12 points
    of damage EACH round for 1 round/level


   // Mark B's famous advice:
   // Note:  if the target is dead during one of these second-long heartbeats,
   // the DelayCommand doesn't get run again, and the whole package goes away.
   // Do NOT attempt to put more than two parameters on the delay command.  They
   // may all end up on the stack, and that's all bad.  60 x 2 = 120.

*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: September 7, 2002
//:://////////////////////////////////////////////
//:: VFX Pass By:
/*
Patch 1.72
- allowed the spell to stack with Bigby's Clenched Fist
- fixed few declarations of the caster level to account for spell overrides
Patch 1.71
- added duration scaling per game difficulty
- incorporeal creatures won't be grappled anymore
*/

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "x2_i0_spells"

void RunHandImpact();

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_BLUDGEONING;
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
        // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    //--------------------------------------------------------------------------
    // This spell no longer stacks. If there is one hand, that's enough
    //--------------------------------------------------------------------------
    if (GetHasSpellEffect(spell.Id,spell.Target))
    {
        FloatingTextStrRefOnCreature(100775,spell.Caster,FALSE);
        return;
    }

    int nDuration = spell.Level;
    nDuration = GetScaledDuration(nDuration, spell.Target);

    //Check for metamagic extend
    if (spell.Meta & METAMAGIC_EXTEND) //Duration is +100%
    {
         nDuration = nDuration * 2;
    }

    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, TRUE));

        //SR
        if(!MyResistSpell(spell.Caster, spell.Target))
        {
            int nCasterModifier = GetCasterAbilityModifier(spell.Caster);
            int nCasterRoll = d20(1) + nCasterModifier + spell.Level + 12 + -1;
            int nTargetRoll = GetAC(spell.Target);

            // * grapple HIT succesful,
            if (nCasterRoll >= nTargetRoll)
            {
                // * now must make a GRAPPLE check
                // * hold target for duration of spell

                nCasterRoll = d20(1) + nCasterModifier + spell.Level + 12 + 4;

                nTargetRoll = d20(1) + GetBaseAttackBonus(spell.Target) + GetSizeModifier(spell.Target) + GetAbilityModifier(ABILITY_STRENGTH, spell.Target);
                                                  //1.71: incorporeal creatures cannot be grappled
                if (nCasterRoll >= nTargetRoll && !GetCreatureFlag(spell.Target, CREATURE_VAR_IS_INCORPOREAL))
                {
                    effect eKnockdown = EffectParalyze();

                    // creatures immune to paralzation are still prevented from moving
                    if (GetIsImmune(spell.Target, IMMUNITY_TYPE_PARALYSIS, spell.Caster) ||
                        GetIsImmune(spell.Target, IMMUNITY_TYPE_MIND_SPELLS, spell.Caster))
                    {
                        eKnockdown = EffectCutsceneImmobilize();
                    }

                    effect eHand = EffectVisualEffect(VFX_DUR_BIGBYS_CRUSHING_HAND);
                    effect eLink = EffectLinkEffects(eKnockdown, eHand);
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));

                    RunHandImpact();
                    FloatingTextStrRefOnCreature(2478, spell.Caster);

                }
                else
                {
                    FloatingTextStrRefOnCreature(83309, spell.Caster);
                }
            }
        }
    }
}

void RunHandImpact()
{
    //--------------------------------------------------------------------------
    // Check if the spell has expired (check also removes effects)
    //--------------------------------------------------------------------------
    if (GZGetDelayedSpellEffectsExpired(spell.Id,spell.Target,spell.Caster))
    {
        return;
    }

    int nDam = MaximizeOrEmpower(spell.Dice,2,spell.Meta, 12);
    effect eDam = EffectDamage(nDam, spell.DamageType);
    effect eVis = EffectVisualEffect(VFX_IMP_ACID_L);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target);
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
    DelayCommand(6.0,RunHandImpact());
}

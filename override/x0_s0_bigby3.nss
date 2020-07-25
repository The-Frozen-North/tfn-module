//::///////////////////////////////////////////////
//:: Bigby's Grasping Hand
//:: [x0_s0_bigby3]
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    make an attack roll. If succesful target is held for 1 round/level


*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: September 7, 2002
//:://////////////////////////////////////////////
//:: VFX Pass By:
/*
Patch 1.71

- stunning visual effect removed if the target is mind/paralyse immune
- added duration scaling per game difficulty
- disabled self-stacking
- incorporeal creatures won't be grappled anymore
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
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
    effect eVis = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);

    //Check for metamagic extend
    if (spell.Meta & METAMAGIC_EXTEND) //Duration is +100%
    {
         nDuration = nDuration * 2;
    }

    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, TRUE));

        // Check spell resistance
        if(!MyResistSpell(spell.Caster, spell.Target))
        {
            // Check caster ability vs. target's AC

            int nCasterModifier = GetCasterAbilityModifier(spell.Caster);
            int nCasterRoll = d20(1) + nCasterModifier + spell.Level + 10 + -1;

            int nTargetRoll = GetAC(spell.Target);

            // * grapple HIT succesful,
            if (nCasterRoll >= nTargetRoll)
            {
                // * now must make a GRAPPLE check to
                // * hold target for duration of spell
                // * check caster ability vs. target's size & strength
                nCasterRoll = d20(1) + nCasterModifier + spell.Level + 10 +4;

                nTargetRoll = d20(1) + GetBaseAttackBonus(spell.Target) + GetSizeModifier(spell.Target) + GetAbilityModifier(ABILITY_STRENGTH, spell.Target);
                                                  //1.71: incorporeal creatures cannot be grappled
                if (nCasterRoll >= nTargetRoll && !GetCreatureFlag(spell.Target, CREATURE_VAR_IS_INCORPOREAL))
                {
                    // Hold the target paralyzed
                    effect eKnockdown = EffectParalyze();

                    // creatures immune to paralzation are still prevented from moving
                    if (GetIsImmune(spell.Target, IMMUNITY_TYPE_PARALYSIS, spell.Caster) ||
                        GetIsImmune(spell.Target, IMMUNITY_TYPE_MIND_SPELLS, spell.Caster))
                    {
                        eKnockdown = EffectCutsceneImmobilize();
                    }
                    else
                    {
                        eKnockdown = EffectLinkEffects(eVis, eKnockdown);
                    }

                    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
                    effect eHand = EffectVisualEffect(VFX_DUR_BIGBYS_GRASPING_HAND);
                    effect eLink = EffectLinkEffects(eKnockdown, eDur);
                    eLink = EffectLinkEffects(eHand, eLink);

                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eLink, spell.Target,DurationToSeconds(nDuration));

//                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, oTarget,RoundsToSeconds(nDuration));
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

//::///////////////////////////////////////////////
//:: Bigby's Forceful Hand
//:: [x0_s0_bigby2]
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    dazed vs strength check (+14 on strength check); Target knocked down.
    Target dazed down for 1 round per level of caster

*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: September 7, 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Andrew Nobbs May 01, 2003
/*
Patch 1.72
- stun vfx will no longer appear on target who has not been affected by this spell at all
Patch 1.71
- disabled self-stacking
- added duration scaling per game difficulty
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.SavingThrow = SAVING_THROW_NONE;
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
        // Apply the impact effect
        effect eImpact = EffectVisualEffect(VFX_IMP_BIGBYS_FORCEFUL_HAND);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, spell.Target);
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, TRUE));
        if(!MyResistSpell(spell.Caster, spell.Target))
        {
            int nCasterRoll = d20(1) + 9;
            int nTargetRoll = d20(1) + GetAbilityModifier(ABILITY_STRENGTH, spell.Target) + GetSizeModifier(spell.Target);
            // * bullrush succesful, knockdown target for duration of spell              //1.72: this will do nothing by default, but allows to dynamically enforce saving throw
            if (nCasterRoll >= nTargetRoll || (spell.SavingThrow != SAVING_THROW_NONE && !MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, SAVING_THROW_TYPE_NONE, spell.Caster)))
            {
                effect eVis = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
                effect eKnockdown = EffectDazed();
                effect eKnockdown2 = EffectKnockdown();
                effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
                //Link effects
                effect eLink = EffectLinkEffects(eKnockdown, eDur);
                eLink = EffectLinkEffects(eLink, eKnockdown2);
                eLink = EffectLinkEffects(eLink, eVis);
                //Apply the penalty
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
                // * Bull Rush succesful
                FloatingTextStrRefOnCreature(8966,spell.Caster, FALSE);
            }
            else
            {
                FloatingTextStrRefOnCreature(8967,spell.Caster, FALSE);
            }
        }
    }
}

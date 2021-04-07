//::///////////////////////////////////////////////
//:: Bigby's Clenched Fist
//:: [x0_s0_bigby4]
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Does an attack EACH ROUND for 1 round/level.
    If the attack hits does
     1d8 +12 points of damage

    Any creature struck must make a FORT save or
    be stunned for one round.

    GZ, Oct 15 2003:
    Changed how this spell works by adding duration
    tracking based on the VFX added to the character.
    Makes the spell dispellable and solves some other
    issues with wrong spell DCs, checks, etc.

*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: September 7, 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Georg Zoeller October 15, 2003
/*
Patch 1.72

- allowed the spell to stack with Bigby's Crushing Hand
*/

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "x2_i0_spells"

void RunHandImpact();

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 8;
    spell.DamageType = DAMAGE_TYPE_BLUDGEONING;
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.SavingThrow = SAVING_THROW_FORT;
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
    if (spell.Meta & METAMAGIC_EXTEND)
    {
         nDuration = nDuration * 2;
    }

    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, TRUE));

        if(!MyResistSpell(spell.Caster, spell.Target))
        {
            int nCasterModifier = GetCasterAbilityModifier(spell.Caster);
            effect eHand = EffectVisualEffect(VFX_DUR_BIGBYS_CLENCHED_FIST);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eHand, spell.Target, DurationToSeconds(nDuration));

            RunHandImpact();
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

    int nCasterModifiers = GetCasterAbilityModifier(spell.Caster) + spell.Level;
    int nCasterRoll = d20(1) + nCasterModifiers + 11 + -1;
    int nTargetRoll = GetAC(spell.Target);
    if (nCasterRoll >= nTargetRoll)
    {
       int nDam  = MaximizeOrEmpower(spell.Dice, 1, spell.Meta, 11);
       effect eDam = EffectDamage(nDam, spell.DamageType);
       effect eVis = EffectVisualEffect(VFX_IMP_ACID_L);

       ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target);
       ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);

       if (!MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, SAVING_THROW_TYPE_NONE, spell.Caster))
       {
           ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectStunned(), spell.Target, RoundsToSeconds(1));
       }

       DelayCommand(6.0,RunHandImpact());
   }
}

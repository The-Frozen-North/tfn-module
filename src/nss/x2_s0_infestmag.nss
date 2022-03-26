//::///////////////////////////////////////////////
//:: Infestation of Maggots
//:: X2_S0_InfestMag.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    You infest  a target with maggotlike creatures.
    They deal 1d4 points of temporary Constitution
    damage each round. Each round the subject makes
    a new Fortitude save. The spell ends if the
    target succeeds at its saving throw.

    If the targets constitution would drop to 0
    through this spell, and the player is playing
    on hardcore difficulty, the target is
    is killed instantly.

*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 19, 2002
//:://////////////////////////////////////////////
//:: Rewritten By: Georg Zoeller, Oct 2003
/*
Patch 1.71

- spell did nothing if target suffers with secondary effect from this spell
- killing method could fail in special case (magic damage immune/resistant creature)
- disease immune creatures aren't affected now
- removed incorrect delay from VFX and effect applications
- duration shortened to 1round/2levels to match spell description
*/

#include "70_inc_spells"
#include "x2_i0_spells"
#include "x2_inc_spellhook"

void DoInitialDamage(int nDamage, object oTarget);
void RunInfestImpact();

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 4;
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.SavingThrow = SAVING_THROW_FORT;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    //--------------------------------------------------------------------------
    // Calculate the duration
    //--------------------------------------------------------------------------
    int nDuration  = spell.Level/2;

    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration * 2;
    }

    //--------------------------------------------------------------------------
    // Setup DC, effects and projectile timing
    //--------------------------------------------------------------------------
    //float  fDist   = GetDistanceToObject(spell.Target);
    //float  fDelay  = fDist/25.0; //no delay because there is no projectile
    effect eDur = EffectVisualEffect(VFX_DUR_FLIES);

    //--------------------------------------------------------------------------
    // Do Safety check, SR and Saves...
    //--------------------------------------------------------------------------
    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));

        if(!MyResistSpell(spell.Caster, spell.Target))
        {
            if (!MySavingThrow(spell.SavingThrow,spell.Target,spell.DC,SAVING_THROW_TYPE_DISEASE,spell.Caster))
            {
                if(GetIsImmune(spell.Target, IMMUNITY_TYPE_DISEASE, spell.Caster))
                {
                    //engine workaround to get proper immunity feedback
                    ApplyEffectToObject(DURATION_TYPE_PERMANENT,EffectDisease(DISEASE_MUMMY_ROT),spell.Target);
                    //target immune, don't do anything then
                    return;
                }
                int nDamage = MaximizeOrEmpower(spell.Dice,1,spell.Meta);
                //even if the spell affects the target already, allow to do at least initial damage
                DelayCommand(0.1,DoInitialDamage(nDamage,spell.Target));

                //--------------------------------------------------------------------------
                // This spell no longer stacks. If there is one of that type, thats ok
                //--------------------------------------------------------------------------
                if (GetHasSpellEffect(spell.Id, spell.Target))
                {
                    FloatingTextStrRefOnCreature(100775,spell.Caster,FALSE);
                    return;
                }
                //---------------------------------------------------------------
                // Apply Effects, Schedule damage ticks
                //---------------------------------------------------------------
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, spell.Target, DurationToSeconds(nDuration));
                //SetLocalInt(oTarget,"XP2_L_SPELL_SAVE_DC_" + IntToString (SPELL_INFESTATION_OF_MAGGOTS), nDC);
                DelayCommand(6.0, RunInfestImpact());
            }
        }
    }
}

void RunInfestImpact()
{
    //--------------------------------------------------------------------------
    // Check if the spell has expired (check also removes effects)
    //--------------------------------------------------------------------------
    if (GZGetDelayedSpellEffectsExpired(spell.Id, spell.Target, spell.Caster))
    {
        return;
    }

    if (!GetIsDead(spell.Target))
    {
//         int nDC = GetLocalInt(oTarget,"XP2_L_SPELL_SAVE_DC_" + IntToString (SPELL_INFESTATION_OF_MAGGOTS));

         if (!MySavingThrow(spell.SavingThrow,spell.Target,spell.DC,SAVING_THROW_TYPE_DISEASE,spell.Caster))
         {
            //engine workaround to get proper immunity feedback
            if(GetIsImmune(spell.Target, IMMUNITY_TYPE_DISEASE, spell.Caster))
            {   //this can happen only if target swap item with disease immunity, but can happen
                ApplyEffectToObject(DURATION_TYPE_PERMANENT,EffectDisease(DISEASE_MUMMY_ROT),spell.Target);
                GZRemoveSpellEffects(spell.Id, spell.Target);
                return;
            }
            //------------------------------------------------------------------
            // Setup Ability Score Damage
            //------------------------------------------------------------------
            effect eVis    = EffectVisualEffect(VFX_IMP_DISEASE_S);
            int    nDamage = MaximizeOrEmpower(spell.Dice,1,spell.Meta);

            effect eDam = ExtraordinaryEffect(EffectAbilityDecrease(ABILITY_CONSTITUTION,nDamage));

            //------------------------------------------------------------------
            // The trick that allows this spellscript to do stacking ability
            // score damage (which is not possible to do from normal scripts)
            // is that the ability score damage is done from a delaycommanded
            // function which will sever the connection between the effect
            // and the SpellId
            //------------------------------------------------------------------

            ApplyEffectToObject(DURATION_TYPE_INSTANT,eVis,spell.Target);

            //------------------------------------------------------------------
            // If the target already is down to 3 points of constitution,
            // kill him. For immortal creatures, end the spell
            // This only kicks in in Hardcore+ difficulty
            //------------------------------------------------------------------
            if (GetAbilityScore(spell.Target,ABILITY_CONSTITUTION)<=3 && GetGameDifficulty() >= GAME_DIFFICULTY_CORE_RULES)
            {
                 if (!GetImmortal(spell.Target))
                 {
                     FloatingTextStrRefOnCreature(100932,spell.Target);
                     effect eVfx = EffectVisualEffect(VFX_IMP_DEATH_L);
                     ApplyEffectToObject(DURATION_TYPE_INSTANT,eVfx,spell.Target);
                     effect eKill = SupernaturalEffect(EffectDeath(FALSE,FALSE));
                     ApplyEffectToObject(DURATION_TYPE_INSTANT,eKill,spell.Target);
                 }
                 else
                 {
                     GZRemoveSpellEffects(spell.Id, spell.Target);
                 }
            }
            else
            {
                 ApplyEffectToObject(DURATION_TYPE_PERMANENT, eDam, spell.Target);
                 DelayCommand(6.0, RunInfestImpact());
            }

         }
         else
         {
//            DeleteLocalInt(oTarget,"XP2_L_SPELL_SAVE_DC_" + IntToString (SPELL_INFESTATION_OF_MAGGOTS));
            GZRemoveSpellEffects(spell.Id, spell.Target);
         }
    }
}

void DoInitialDamage(int nDamage, object oTarget)
{
    //------------------------------------------------------------------
    // Setup Ability Score Damage
    //------------------------------------------------------------------
    effect eVis    = EffectVisualEffect(VFX_IMP_DISEASE_S);

    effect eDam = ExtraordinaryEffect(EffectAbilityDecrease(ABILITY_CONSTITUTION,nDamage));

    ApplyEffectToObject(DURATION_TYPE_INSTANT,eVis,oTarget);

    //------------------------------------------------------------------
    // If the target already is down to 3 points of constitution,
    // kill him. For immortal creatures, end the spell
    // This only kicks in in Hardcore+ difficulty
    //------------------------------------------------------------------
    if (GetAbilityScore(oTarget,ABILITY_CONSTITUTION)<=3 &&GetGameDifficulty() >= GAME_DIFFICULTY_CORE_RULES)
    {
        if (!GetImmortal(oTarget))
        {
            FloatingTextStrRefOnCreature(100932,oTarget);
            effect eVfx = EffectVisualEffect(VFX_IMP_DEATH_L);
            ApplyEffectToObject(DURATION_TYPE_INSTANT,eVfx,oTarget);
            effect eKill = SupernaturalEffect(EffectDeath(FALSE,FALSE));
            ApplyEffectToObject(DURATION_TYPE_INSTANT,eKill,oTarget);
        }
    }
    else
    {
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eDam, oTarget);
    }
}

//::///////////////////////////////////////////////
//:: Combust
//:: X2_S0_Combust
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
/*
   The initial eruption of flame causes  2d6 fire damage +1
   point per caster level(maximum +10)
   with no saving throw.

   Further, the creature must make
   a Reflex save or catch fire taking a further 1d6 points
   of damage. This will continue until the Reflex save is
   made.

   There is an undocumented artificial limit of
   10 + casterlevel rounds on this spell to prevent
   it from running indefinitly when used against
   fire resistant creatures with bad saving throws

*/
//:://////////////////////////////////////////////
// Created: 2003/09/05 Georg Zoeller
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x2_i0_spells"
#include "x2_inc_toollib"
#include "x2_inc_spellhook"

void RunCombustImpact();

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_FIRE;
    spell.Limit = 10;
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    //--------------------------------------------------------------------------
    // Calculate the damage, 2d6 + casterlevel, capped at +10
    //--------------------------------------------------------------------------
    int nDamage = spell.Level;
    if (nDamage > spell.Limit)
    {
        nDamage = spell.Limit;
    }
    nDamage = MaximizeOrEmpower(spell.Dice,2,spell.Meta,nDamage);

    //--------------------------------------------------------------------------
    // Calculate the duration (we need a duration or bad things would happen
    // if someone is immune to fire but fails his safe all the time)
    //--------------------------------------------------------------------------
    int nDuration = 10 + spell.Level;

    //--------------------------------------------------------------------------
    // Setup Effects
    //--------------------------------------------------------------------------
    effect eDam      = EffectDamage(nDamage, spell.DamageType);
    effect eDur      = EffectVisualEffect(VFX_DUR_INFERNO_CHEST);

    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));

       //-----------------------------------------------------------------------
       // Check SR
       //-----------------------------------------------------------------------
        if(!MyResistSpell(spell.Caster, spell.Target))
        {
            //-------------------------------------------------------------------
            // Apply VFX
            //-------------------------------------------------------------------
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target);
            TLVFXPillar(VFX_IMP_FLAME_M, spell.Loc, 5, 0.1,0.0, 2.0);

            //------------------------------------------------------------------
            // This spell no longer stacks. If there is one of that type,
            // that's enough
            //------------------------------------------------------------------
            if (GetHasSpellEffect(spell.Id,spell.Target) || GetHasSpellEffect(SPELL_INFERNO,spell.Target))
            {
                FloatingTextStrRefOnCreature(100775,spell.Caster,FALSE);
                return;
            }

            //------------------------------------------------------------------
            // Apply the VFX that is used to track the spells duration
            //------------------------------------------------------------------
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, spell.Target, RoundsToSeconds(nDuration));

            //------------------------------------------------------------------
            // Tick damage after 6 seconds again
            //------------------------------------------------------------------
            DelayCommand(6.0, RunCombustImpact());
        }
    }
}

void RunCombustImpact()
{
     //--------------------------------------------------------------------------
    // Check if the spell has expired (check also removes effects)
    //--------------------------------------------------------------------------
    if (GZGetDelayedSpellEffectsExpired(spell.Id,spell.Target,spell.Caster))
    {
        return;
    }

    if (!GetIsDead(spell.Target))
    {
        if(!MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, spell.SaveType, spell.Caster))
        { //hmm evasion not allowed? interesting, probably the only such spell
            //------------------------------------------------------------------
            // Calculate the damage, 1d6 + casterlevel, capped at +10
            //------------------------------------------------------------------
            int nDamage = spell.Level;
            if (nDamage > spell.Limit)
            {
                nDamage = spell.Limit;
            }
            nDamage = MaximizeOrEmpower(spell.Dice,1,spell.Meta,nDamage);

            effect eDmg = EffectDamage(nDamage,spell.DamageType);
            effect eVFX = EffectVisualEffect(spell.DmgVfxS);

            ApplyEffectToObject(DURATION_TYPE_INSTANT,eDmg,spell.Target);
            ApplyEffectToObject(DURATION_TYPE_INSTANT,eVFX,spell.Target);

            //------------------------------------------------------------------
            // After six seconds (1 round), check damage again
            //------------------------------------------------------------------
            DelayCommand(6.0,RunCombustImpact());
        }
        else
        {
            GZRemoveSpellEffects(spell.Id, spell.Target);
        }
   }
}

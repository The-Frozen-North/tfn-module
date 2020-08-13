//::///////////////////////////////////////////////
//:: Hellish Inferno
//:: x0_s0_inferno.nss
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
/*
    NPC only spell for yaron

    like normal inferno but lasts only 5 rounds,
    ticks twice per round, adds attack and damage
    penalty.

*/
//:://////////////////////////////////////////////
// Georg Z, 19-10-2003
//:://////////////////////////////////////////////
/*
Patch 1.71

- damage decrease type changed to slashing so it affects any physical damage
- was missing target check and could affect friendly tarets at no-pvp area
- was missing delay in SR VFX
- incorrect VFX when spell was resisted
> now does at least initial damage instead of nothing
*/

#include "70_inc_spells"
#include "x2_i0_spells"
#include "x2_inc_spellhook"

void RunImpact();

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageType = DAMAGE_TYPE_FIRE;
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.SavingThrow = SAVING_THROW_NONE;
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
    int nDuration = spell.Level/2;

    if (nDuration < 1)
    {
        nDuration = 1;
    }
    else if (nDuration > 6)
    {
        nDuration = 6;
    }
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration * 2;
    }
    //workaround for already existing effect check because of ray effect
    int bHasSpellEffects = GetHasSpellEffect(spell.Id,spell.Target);
    //--------------------------------------------------------------------------
    // Flamethrower VFX, thanks to Alex
    //--------------------------------------------------------------------------
    effect eRay = EffectBeam(444,spell.Caster,BODY_NODE_CHEST);
    //----------------------------------------------------------------------
    // Engulf the target in flame
    //----------------------------------------------------------------------
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRay, spell.Target, 3.0);

    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        float fDelay = GetDistanceBetween(spell.Target, spell.Caster)/13;

        if(!MyResistSpell(spell.Caster, spell.Target, fDelay))
        {
            //1.72: this will do nothing by default, but allows to dynamically enforce saving throw
            if(!MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, spell.SaveType, spell.Caster))
            {
                effect eDam  = EffectDamage(d6(2), spell.DamageType);
                effect eDam2 = EffectDamage(d6(1), DAMAGE_TYPE_DIVINE);
                effect eVis = EffectVisualEffect(spell.DmgVfxS);
                eDam = EffectLinkEffects(eVis,eDam); // flare up
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target));
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam2, spell.Target));

                //--------------------------------------------------------------------------
                // This spell no longer stacks. If there is one hand, that's enough
                //--------------------------------------------------------------------------
                if (bHasSpellEffects)
                {
                    FloatingTextStrRefOnCreature(100775,spell.Caster,FALSE);
                    return;
                }

                effect eAttackDec = EffectAttackDecrease(4);
                effect eDamageDec = EffectDamageDecrease(4,DAMAGE_TYPE_BLUDGEONING|DAMAGE_TYPE_SLASHING|DAMAGE_TYPE_PIERCING);
                effect eLink = EffectLinkEffects(eAttackDec, eDamageDec);
                effect eDur = EffectVisualEffect(VFX_DUR_INFERNO_CHEST);

                DelayCommand(fDelay,ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration)));

                DelayCommand(fDelay,ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eDur,spell.Target,DurationToSeconds(nDuration)));
                DelayCommand(fDelay+3.0,RunImpact());
            }
        }
    }
}

void RunImpact()
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
        //* GZ: Removed Meta magic, does not work in delayed functions
        effect eDam  = EffectDamage(d6(2), spell.DamageType);//could be added again, but this is not a player spell anymore
        effect eDam2 = EffectDamage(d6(1), DAMAGE_TYPE_DIVINE);
        effect eVis = EffectVisualEffect(spell.DmgVfxS);
        eDam = EffectLinkEffects(eVis,eDam); // flare up
        ApplyEffectToObject (DURATION_TYPE_INSTANT,eDam,spell.Target);
        ApplyEffectToObject (DURATION_TYPE_INSTANT,eDam2,spell.Target);
        DelayCommand(3.0, RunImpact());
    }
}

//::///////////////////////////////////////////////
//:: Inferno
//:: x0_s0_inferno.nss
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Does 2d6 fire per round
    Duration: 1 round per level
*/
//:://////////////////////////////////////////////
//:: Created By: Aidan Scanlan
//:: Created On: 01/09/01
//:://////////////////////////////////////////////
//:: Rewritten: Georg Zoeller, 2003-Oct-19
//::            - VFX update
//::            - Spell no longer stacks with itself
//::            - Spell can now be dispelled
//::            - Spell is now much less cpu expensive
/*
Patch 1.72
- allowed spell to do at least initial damage in case target is already affected by the continuous damage
Patch 1.70
- was missing target check and could affect friendly tarets at no-pvp area
- was missing delay in SR VFX
- incorrect VFX when spell was resisted
*/

#include "70_inc_spells"
#include "x2_i0_spells"
#include "x2_inc_spellhook"

void RunImpact();

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_FIRE;
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

    //workaround for already existing effect check because of ray effect
    int bHasSpellEffects = GetHasSpellEffect(spell.Id,spell.Target);

    //--------------------------------------------------------------------------
    // Calculate the duration
    //--------------------------------------------------------------------------
    int nDuration = spell.Level;

    if (spell.Meta & METAMAGIC_EXTEND)
    {
       nDuration = nDuration * 2;
    }

    //--------------------------------------------------------------------------
    // Flamethrower VFX, thanks to Alex
    //--------------------------------------------------------------------------
    effect eRay      = EffectBeam(444,spell.Caster,BODY_NODE_CHEST);
    effect eDur      = EffectVisualEffect(VFX_DUR_INFERNO_CHEST);

    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));

        float fDelay = GetDistanceBetween(spell.Target, spell.Caster)/13;

        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eRay, spell.Target, 3.0);

        if(!MyResistSpell(spell.Caster, spell.Target, fDelay))
        {
            //1.72: this will do nothing by default, but allows to dynamically enforce saving throw
            if(!MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, spell.SaveType, spell.Caster))
            {
                //----------------------------------------------------------------------
                // Do the initial 3d6 points of damage
                //----------------------------------------------------------------------
                int nDamage = MaximizeOrEmpower(spell.Dice,2,spell.Meta);
                effect eDam = EffectDamage(nDamage, spell.DamageType);
                effect eVis = EffectVisualEffect(spell.DmgVfxS);

                DelayCommand(fDelay,ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target));
                DelayCommand(fDelay,ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target));
                //--------------------------------------------------------------------------
                // This spell no longer stacks. If there is one of that type, thats ok
                //--------------------------------------------------------------------------
                if (GetHasSpellEffect(spell.Id,spell.Target) || GetHasSpellEffect(SPELL_COMBUST,spell.Target))
                {
                    FloatingTextStrRefOnCreature(100775,spell.Caster,FALSE);
                    return;
                }
                //----------------------------------------------------------------------
                // Apply the VFX that is used to track the spells duration
                //----------------------------------------------------------------------
                DelayCommand(fDelay,ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eDur,spell.Target,DurationToSeconds(nDuration)));
                DelayCommand(fDelay+6.0,RunImpact());
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
        //----------------------------------------------------------------------
        // Calculate Damage
        //----------------------------------------------------------------------
        int nDamage = MaximizeOrEmpower(spell.Dice,2,spell.Meta);
        effect eDam = EffectDamage(nDamage, spell.DamageType);
        effect eVis = EffectVisualEffect(spell.DmgVfxS);
        eDam = EffectLinkEffects(eVis,eDam); // flare up
        ApplyEffectToObject (DURATION_TYPE_INSTANT,eDam,spell.Target);
        DelayCommand(6.0,RunImpact());
    }
}

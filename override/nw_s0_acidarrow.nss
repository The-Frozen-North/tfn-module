//::///////////////////////////////////////////////
//:: Melf's Acid Arrow
//:: MelfsAcidArrow.nss
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
/*
    An acidic arrow springs from the caster's hands
    and does 3d6 acid damage to the target.  For
    every 3 levels the caster has the target takes an
    additional 1d6 per round.
*/
/////////////////////////////////////////////////////////
//:://////////////////////////////////////////////
//:: Created By: Aidan Scanlan
//:: Created On: 01/09/01
//:://////////////////////////////////////////////
//:: Rewritten: Georg Zoeller, Oct 29, 2003
//:: Now uses VFX to track its own duration, cutting
//:: down the impact on the CPU to 1/6th
//:://////////////////////////////////////////////
/*
Patch 1.72
- fixed nonfunctional spell overrides
Patch 1.70
- allowed spell to do at least initial damage in case target is already affected by the continuous damage
- SR VFX wasn't delayed
- incorrect VFX when spell was resisted
*/

#include "70_inc_spells"
#include "x2_inc_spellhook"
#include "x2_i0_spells"

void RunImpact();

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Dice = 6;
    spell.DamageType = DAMAGE_TYPE_ACID;
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
    // Calculate the duration
    //--------------------------------------------------------------------------
    int nDuration = spell.Level/3;

    if (nDuration < 1)
    {
        nDuration = 1;
    }

    if (spell.Meta & METAMAGIC_EXTEND)
    {
       nDuration = nDuration * 2;
    }

    //--------------------------------------------------------------------------
    // Setup VFX
    //--------------------------------------------------------------------------
    effect eVis      = EffectVisualEffect(spell.DmgVfxL);
    effect eDur      = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eArrow    = EffectVisualEffect(VFX_DUR_MIRV_ACID);
    int bInEffect    = GetHasSpellEffect(spell.Id, spell.Target);

    ApplyEffectToObject(DURATION_TYPE_INSTANT, eArrow, spell.Target);
    //--------------------------------------------------------------------------
    // Set the VFX to be non dispelable, because the acid is not magic
    //--------------------------------------------------------------------------
    eDur = ExtraordinaryEffect(eDur);
     // * Dec 2003- added the reaction check back i
    if (spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));

        float fDist = GetDistanceToObject(spell.Target);
        float fDelay = fDist/25.0;//(3.0 * log(fDist) + 2.0);


        if(!MyResistSpell(spell.Caster, spell.Target, fDelay))
        {
            //1.72: this will do nothing by default, but allows to dynamically enforce saving throw
            if(!MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, spell.SaveType, spell.Caster))
            {
                //----------------------------------------------------------------------
                // Do the initial 3d6 points of damage
                //----------------------------------------------------------------------
                int nDamage = MaximizeOrEmpower(spell.Dice,3,spell.Meta);
                effect eDam = EffectDamage(nDamage, spell.DamageType);

                DelayCommand(fDelay,ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target));
                DelayCommand(fDelay,ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target));
                //--------------------------------------------------------------------------
                // This spell no longer stacks. If there is one of that type, thats ok
                //--------------------------------------------------------------------------
                if (bInEffect)
                {
                    FloatingTextStrRefOnCreature(100775,spell.Caster,FALSE);
                    return;
                }
                //----------------------------------------------------------------------
                // Apply the VFX that is used to track the spells duration
                //----------------------------------------------------------------------
                DelayCommand(fDelay,ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eDur,spell.Target,DurationToSeconds(nDuration)));
                DelayCommand(6.0,RunImpact());
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
        int nDamage = MaximizeOrEmpower(spell.Dice,1,spell.Meta);
        effect eDam = EffectDamage(nDamage, spell.DamageType);
        effect eVis = EffectVisualEffect(spell.DmgVfxS);
        eDam = EffectLinkEffects(eVis,eDam); // flare up
        ApplyEffectToObject (DURATION_TYPE_INSTANT,eDam,spell.Target);
        DelayCommand(6.0,RunImpact());
    }
}

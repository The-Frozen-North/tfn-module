//::///////////////////////////////////////////////
//:: Horizikaul's Boom
//:: X2_S0_HoriBoom
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
// You blast the target with loud and high-pitched
// sounds. The target takes 1d4 points of sonic
// damage per two caster levels (maximum 5d4) and
// must make a Will save or be deafened for 1d4
// rounds.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 22, 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Andrew Nobbs, 02/06/2003
/*
Patch 1.71

- saving throw subtype corrected to sonic as per spell's descriptor (this will
make a mind immune creature force to take their save against the deafness here)
- silenced creatures will be immune to the deafness effect
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageCap = 5;
    spell.Dice = 4;
    spell.DamageType = DAMAGE_TYPE_SONIC;
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nCasterLvl = spell.Level/2;
    int nRounds = d4(1);
    effect eVis = EffectVisualEffect(spell.DmgVfxS);
    effect eDeaf = EffectDeaf();
    //Minimum caster level of 1, maximum of 15.
    if(nCasterLvl < 1)
    {
        nCasterLvl = 1;
    }
    else if (nCasterLvl > spell.DamageCap)
    {
        nCasterLvl = spell.DamageCap;
    }
    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        if(!MyResistSpell(spell.Caster, spell.Target))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
            //Roll damage
            int nDam = MaximizeOrEmpower(spell.Dice,nCasterLvl,spell.Meta);
            //Set damage effect
            effect eDam = EffectDamage(nDam, spell.DamageType);
            //Apply the MIRV and damage effect
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, spell.Target);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);

            if(!GetHasEffect(EFFECT_TYPE_SILENCE,spell.Target) && !MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, SAVING_THROW_TYPE_SONIC, spell.Caster))
            {
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDeaf, spell.Target, RoundsToSeconds(nRounds));
            }
        }
    }
}

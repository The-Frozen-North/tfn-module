//::///////////////////////////////////////////////
//:: Doom
//:: NW_S0_Doom.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    If the target fails a save they recieve a -2
    penalty to all saves, attack rolls, damage and
    skill checks for the duration of the spell.

    July 22 2002 (BK): Made it mind affecting.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Oct 22, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- missing saving throw VFX added
- immunity feedback corrected
- SR check moved before saving throw check
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_TURNS;
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(VFX_IMP_DOOM);
    effect eLink = CreateDoomEffectsLink();

    int nDuration = spell.Level;
    //Meta-Magic checks
    if(spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration *= 2;
    }
    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
        //Spell Resistance check
        if(!MyResistSpell(spell.Caster, spell.Target))
        {
            //will saving throw
            if(!MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, SAVING_THROW_TYPE_MIND_SPELLS, spell.Caster))
            {
                //* Engine workaround for mind affecting spell without mind effect
                if(GetIsImmune(spell.Target, IMMUNITY_TYPE_MIND_SPELLS, spell.Caster))
                {
                    eLink = EffectDazed();//force target to overcome the spell effect and print immunity feedback instead
                    nDuration = 1;//for safety
                }
                else
                {
                    //apply doom VFX only if not immune
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
                }
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
            }
        }
    }
}

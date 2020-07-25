//::///////////////////////////////////////////////
//:: Hold Monster
//:: NW_S0_HoldMon
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Will hold any monster in place for 1
    round per caster level.
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Soleski
//:: Created On: Jan 18, 2001
//:://////////////////////////////////////////////
//:: Update Pass By: Preston W, On: Aug 1, 2001
/*
Patch 1.71

- added missing saving throw subtype as per spell's descriptor
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nDuration = spell.Level;
    nDuration = GetScaledDuration(nDuration, spell.Target);
    effect eParal = EffectParalyze();
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eDur2 = EffectVisualEffect(VFX_DUR_PARALYZED);
    effect eDur3 = EffectVisualEffect(VFX_DUR_PARALYZE_HOLD);

    effect eLink = EffectLinkEffects(eDur2, eDur);
    eLink = EffectLinkEffects(eLink, eParal);
    eLink = EffectLinkEffects(eLink, eDur3);


    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
       //Fire cast spell at event for the specified target
       SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
       //Make SR check
       if (!MyResistSpell(spell.Caster, spell.Target))
       {
            //Make Will save
            if (!MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, SAVING_THROW_TYPE_MIND_SPELLS, spell.Caster))
            {
                //Check for metamagic extend
                if (spell.Meta & METAMAGIC_EXTEND)
                {
                    nDuration = nDuration * 2;
                }
                //Apply the paralyze effect and the VFX impact
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
            }
        }
    }
}

//::///////////////////////////////////////////////
//:: [Dominate Monster]
//:: [NW_S0_DomMon.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Will save or the target monster is Dominated for
    3 turns +1 per caster level.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 29, 2001
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 20, 2001
//:: Update Pass By: Preston W, On: July 30, 2001
/*
Patch 1.70

- won't fire signal event on wrong targets
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
    effect eDom = EffectDominated();
    eDom = GetScaledEffect(eDom, spell.Target);
    effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DOMINATED);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

    //Link domination and persistant VFX
    effect eLink = EffectLinkEffects(eMind, eDom);
    eLink = EffectLinkEffects(eLink, eDur);

    effect eVis = EffectVisualEffect(VFX_IMP_DOMINATE_S);
    int nDuration = 3 + spell.Level/2;

    nDuration = GetScaledDuration(nDuration, spell.Target);

    //Make sure the target is a monster
    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
        //Make SR Check
        if (!MyResistSpell(spell.Caster, spell.Target))
        {
            //Make a Will Save
            if (!MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, SAVING_THROW_TYPE_MIND_SPELLS, spell.Caster))
            {
                //Check for Metamagic extension
                if (spell.Meta & METAMAGIC_EXTEND)
                {
                    nDuration = nDuration * 2;
                }
                //Apply linked effects and VFX Impact
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
            }
        }
    }
}

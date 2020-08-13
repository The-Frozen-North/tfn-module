//::///////////////////////////////////////////////
//:: [Dominate Animal]
//:: [NW_S0_DomAn.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Will save or the target is dominated for 1 round
//:: per caster level.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 30, 2001
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
    effect eDom = EffectDominated();
    effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DOMINATED);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

    //Link domination and persistant VFX
    effect eLink = EffectLinkEffects(eMind, eDom);
    eLink = EffectLinkEffects(eLink, eDur);

    effect eVis = EffectVisualEffect(VFX_IMP_DOMINATE_S);
    int nDuration = 3 + spell.Level;

    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
        //Make sure the target is an animal
        if (spellsIsRacialType(spell.Target, RACIAL_TYPE_ANIMAL))
        {
           //Make SR check
           if (!MyResistSpell(spell.Caster, spell.Target))
           {
                //Will Save for spell negation
                if (!MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, SAVING_THROW_TYPE_MIND_SPELLS, spell.Caster))
                {
                    //Check for Metamagic extension
                    if (spell.Meta & METAMAGIC_EXTEND)
                    {
                        nDuration = nDuration * 2;
                    }
                    //Apply linked effect and VFX impact
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
                }
            }
        }
    }
}

//::///////////////////////////////////////////////
//:: [Dominate Person]
//:: [NW_S0_DomPers.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Will save or the target is dominated for 1 round
//:: per caster level.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 29, 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk, On: April 6, 2001
//:: Last Updated By: Preston Watamaniuk, On: April 10, 2001
//:: VFX Pass By: Preston W, On: June 20, 2001
/*
Patch 1.70

- added monstrous races to race-check
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
    eDom = GetScaledEffect(eDom, spell.Target);
    effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DOMINATED);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

    //Link duration effects
    effect eLink = EffectLinkEffects(eMind, eDom);
    eLink = EffectLinkEffects(eLink, eDur);

    effect eVis = EffectVisualEffect(VFX_IMP_DOMINATE_S);
    int nDuration = 2 + spell.Level/3;
    nDuration = GetScaledDuration(nDuration, spell.Target);

    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
        //Make sure the target is a humanoid
        if (AmIAHumanoid(spell.Target))
        {
           //Make SR Check
           if (!MyResistSpell(spell.Caster, spell.Target))
           {
                //Make Will Save
                if (!MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, SAVING_THROW_TYPE_MIND_SPELLS, spell.Caster, 1.0))
                {
                    //Check for metamagic extension
                    if (spell.Meta & METAMAGIC_EXTEND)
                    {
                        nDuration = nDuration * 2;
                    }
                    //Apply linked effects and VFX impact
                    DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration)));
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
                }
            }
        }
    }
}

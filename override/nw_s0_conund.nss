//::///////////////////////////////////////////////
//:: [Control Undead]
//:: [NW_S0_ConUnd.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
/*
    A single undead with up to 3 HD per caster level
    can be dominated.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Feb 2, 2001
//:://////////////////////////////////////////////
//:: Last Updated By: Preston Watamaniuk
//:: Last Updated On: April 6, 2001
/*
Patch 1.71

- added effect and duration scaling in order not to dominate undead PC
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_HOURS;
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eControl = EffectDominated();
    eControl = GetScaledEffect(eControl, spell.Target);
    effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DOMINATED);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    effect eVis = EffectVisualEffect(VFX_IMP_DOMINATE_S);
    effect eLink = EffectLinkEffects(eMind, eControl);
    eLink = EffectLinkEffects(eLink, eDur);


    int nDuration = spell.Level;
    int nHD = spell.Level * 2;
    nDuration = GetScaledDuration(nDuration, spell.Target);

    if (spellsIsRacialType(spell.Target, RACIAL_TYPE_UNDEAD) && GetHitDice(spell.Target) <= nHD)
    {
        if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
        {
           //Fire cast spell at event for the specified target
           SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
           if (!MyResistSpell(spell.Caster, spell.Target))
           {
                //Make a Will save
                if (!MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, SAVING_THROW_TYPE_NONE, spell.Caster, 1.0))
                {
                    //Make meta magic
                    if (spell.Meta & METAMAGIC_EXTEND)
                    {
                        nDuration = nDuration * 2;
                    }
                    //Apply VFX impact and Link effect
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
                    DelayCommand(1.0, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration)));
                    //Increment HD affected count
                }
            }
        }
    }
}

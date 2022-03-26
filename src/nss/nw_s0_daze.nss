//::///////////////////////////////////////////////
//:: [Daze]
//:: [NW_S0_Daze.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Will save or the target is dazed for 1 round
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 15, 2001
//:://////////////////////////////////////////////
//:: Update Pass By: Preston W, On: July 27, 2001

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.Limit = 5;
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_SINGLETARGET;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);
    effect eDaze = EffectDazed();
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

    effect eLink = EffectLinkEffects(eMind, eDaze);
    eLink = EffectLinkEffects(eLink, eDur);

    effect eVis = EffectVisualEffect(VFX_IMP_DAZED_S);
    int nDuration = 2;
    //check meta magic for extend
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = 4;
    }

    //Make sure the target is a humaniod
    if (AmIAHumanoid(spell.Target) == TRUE)
    {
        if(GetHitDice(spell.Target) <= spell.Limit)
        {
            if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));
                //Make SR check
                if (!MyResistSpell(spell.Caster, spell.Target))
                {
                    //Make Will Save to negate effect
                    if (!MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, SAVING_THROW_TYPE_MIND_SPELLS, spell.Caster))
                    {
                        //Apply VFX Impact and daze effect
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
                        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
                    }
                }
            }
        }
    }
}

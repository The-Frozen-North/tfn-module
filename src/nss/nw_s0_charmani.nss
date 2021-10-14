//::///////////////////////////////////////////////
//:: [Charm Person or Animal]
//:: [NW_S0_DomAni.nss]
//:: Copyright (c) 2000 Bioware Corp.
//:://////////////////////////////////////////////
//:: Will save or the target is dominated for 1 round
//:: per caster level.
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 29, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- wont affect wrong target at all (previously could still took spell mantle)
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

    effect eVis = EffectVisualEffect(VFX_IMP_CHARM);
    effect eCharm = EffectCharmed();
    eCharm = GetScaledEffect(eCharm, spell.Target);
    effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);
    //Link the charm and duration visual effects
    effect eLink = EffectLinkEffects(eMind, eCharm);
    eLink = EffectLinkEffects(eLink, eDur);

    int nCasterLevel = spell.Level;
    int nDuration = 2 + nCasterLevel/3;
    nDuration = GetScaledDuration(nDuration, spell.Target);
    //Meta magic duration check
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration * 2;
    }
    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire spell cast at event to fire on the target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
        if(AmIAHumanoid(spell.Target) || spellsIsRacialType(spell.Target, RACIAL_TYPE_ANIMAL))
        {
            //Make SR Check
            if (!MyResistSpell(spell.Caster, spell.Target))
            {
                //Make Will Save
                if (!MySavingThrow(spell.SavingThrow, spell.Target, spell.DC, SAVING_THROW_TYPE_MIND_SPELLS, spell.Caster))
                {
                    //Apply impact effects and linked duration and charm effect
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);


                    SetLocalInt(spell.Target, "charmed", 1);
                    DelayCommand(DurationToSeconds(nDuration), DeleteLocalInt(spell.Target, "charmed"));
                }
            }
        }
    }
}

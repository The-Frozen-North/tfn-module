//::///////////////////////////////////////////////
//:: Tasha's Hideous Laughter
//:: [x0_s0_laugh.nss]
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Target is held, laughing for the duration
    of the spell (1d3 rounds)

*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: September 6, 2002
//:://////////////////////////////////////////////
/*
Patch 1.70

- alignment immune creatures were ommited
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
    int nDamage = 0;
    int nCnt;
    effect eVis = EffectVisualEffect(VFX_IMP_WILL_SAVING_THROW_USE);


    int nDuration = d3(1);
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2; //Duration is +100%
    }

    int nModifier = 0;

    // * creatures of different race find different things funny
    if (GetRacialType(spell.Target) != GetRacialType(spell.Caster))
    {
        nModifier = 4;
    }
    if(spellsIsTarget(spell.Target, spell.TargetType, spell.Caster))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id));

        if (!spellsIsMindless(spell.Target))
        {
            if (!MyResistSpell(spell.Caster, spell.Target) && !MySavingThrow(spell.SavingThrow, spell.Target, spell.DC-nModifier, SAVING_THROW_TYPE_MIND_SPELLS, spell.Caster))
            {
                if (!GetIsImmune(spell.Target,IMMUNITY_TYPE_MIND_SPELLS,spell.Caster))
                {
                    effect eDur = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_DISABLED);
                    float fDur = DurationToSeconds(nDuration);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
                    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, spell.Target, fDur);

                /*    string szLaughMale = "as_pl_laughingm2";
                    string szLaughFemale = "as_pl_laughingf3";

                    if (GetGender(oTarget) == GENDER_FEMALE)
                    {
                        PlaySound(szLaughFemale);
                    }
                    else
                    {
                        PlaySound(szLaughMale);
                    }      */
                    AssignCommand(spell.Target, ClearAllActions());
                    AssignCommand(spell.Target, PlayVoiceChat(VOICE_CHAT_LAUGH));
                    AssignCommand(spell.Target, ActionPlayAnimation(ANIMATION_LOOPING_TALK_LAUGHING));
                    effect eLaugh = EffectKnockdown();
                    DelayCommand(0.3, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLaugh, spell.Target, fDur));
                }
            }
        }
    }
}

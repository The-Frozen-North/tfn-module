//::///////////////////////////////////////////////
//:: Remove Effects
//:: NW_SO_RemEffect
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Takes the place of
        Remove Disease
        Neutralize Poison
        Remove Paralysis
        Remove Curse
        Remove Blindness / Deafness
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 8, 2002
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.Range = RADIUS_SIZE_MEDIUM;
    spell.TargetType = SPELL_TARGET_ALLALLIES;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    int nEffect1;
    int nEffect2;
    int nEffect3;
    int bAreaOfEffect = FALSE;

    effect eVis = EffectVisualEffect(VFX_IMP_REMOVE_CONDITION);
    //Check for which removal spell is being cast.
    if(spell.Id == SPELL_REMOVE_BLINDNESS_AND_DEAFNESS)
    {
        nEffect1 = EFFECT_TYPE_BLINDNESS;
        nEffect2 = EFFECT_TYPE_DEAF;
        bAreaOfEffect = TRUE;
    }
    else if(spell.Id == SPELL_REMOVE_CURSE)
    {
        nEffect1 = EFFECT_TYPE_CURSE;
    }
    else if(spell.Id == SPELL_REMOVE_DISEASE || spell.Id == SPELLABILITY_REMOVE_DISEASE)
    {
        nEffect1 = EFFECT_TYPE_DISEASE;
        if(GetGameDifficulty() < GAME_DIFFICULTY_CORE_RULES)
        {
            nEffect2 = EFFECT_TYPE_ABILITY_DECREASE;
        }
        else
        {
            string eCreator;
            effect eEffect = GetFirstEffect(spell.Target);
            while(GetIsEffectValid(eEffect))
            {
                eCreator = GetTag(GetEffectCreator(eEffect));
                if((GetEffectType(eEffect) == EFFECT_TYPE_ABILITY_DECREASE && eCreator != "70_EC_POISON") || eCreator == "70_EC_DISEASE")
                {
                    RemoveEffect(spell.Target,eEffect);
                }
                eEffect = GetNextEffect(spell.Target);
            }
        }
    }
    else if(spell.Id == SPELL_NEUTRALIZE_POISON)
    {
        nEffect1 = EFFECT_TYPE_POISON;
        if(GetGameDifficulty() < GAME_DIFFICULTY_CORE_RULES)
        {
            nEffect2 = EFFECT_TYPE_DISEASE;
            nEffect3 = EFFECT_TYPE_ABILITY_DECREASE;
        }
        else
        {
            string eCreator;
            effect eEffect = GetFirstEffect(spell.Target);
            while(GetIsEffectValid(eEffect))
            {
                eCreator = GetTag(GetEffectCreator(eEffect));
                if((GetEffectType(eEffect) == EFFECT_TYPE_ABILITY_DECREASE && eCreator != "70_EC_DISEASE") || eCreator == "70_EC_POISON")
                {
                    RemoveEffect(spell.Target,eEffect);
                }
                eEffect = GetNextEffect(spell.Target);
            }
        }
    }


    // * March 2003. Remove blindness and deafness should be an area of effect spell
    if (bAreaOfEffect == TRUE)
    {
        effect eImpact = EffectVisualEffect(VFX_FNF_LOS_HOLY_30);
        effect eLink;

        spellsGenericAreaOfEffect(spell.Caster, spell.Loc, SHAPE_SPHERE, spell.Range,
            spell.Id, eImpact, eLink, eVis,
            DURATION_TYPE_INSTANT, 0.0,
            spell.TargetType, FALSE, TRUE, nEffect1, nEffect2);
        return;
    }
    //Fire cast spell at event for the specified target
    SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
    //Remove effects
    RemoveSpecificEffect(nEffect1, spell.Target);
    if(nEffect2 != 0)
    {
        RemoveSpecificEffect(nEffect2, spell.Target);
    }
    if(nEffect3 != 0)
    {
        RemoveSpecificEffect(nEffect3, spell.Target);
    }
    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, spell.Target);
}

//::///////////////////////////////////////////////
//:: Remove Fear
//:: NW_S0_RmvFear.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    All allies within a 10ft radius have their fear
    effects removed and are granted a +4 Save versus
    future fear effects.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: April 13, 2001
//:://////////////////////////////////////////////
/*
Patch 1.72
- spell target area changed to the large as per spell's description
Patch 1.71
- signal event will fire regardless of the occurence of the paralyze effect
- spell affected one more creature than intented
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;
    spell.Range = RADIUS_SIZE_LARGE;
    spell.TargetType = SPELL_TARGET_ALLALLIES;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eFear;
    int nDuration = 100;
    effect eSave = EffectSavingThrowIncrease(SAVING_THROW_WILL, 4, SAVING_THROW_TYPE_FEAR);
    effect eMind = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_POSITIVE);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eImpact = EffectVisualEffect(VFX_FNF_LOS_HOLY_10);

    effect eLink = EffectLinkEffects(eMind, eSave);
    eLink = EffectLinkEffects(eLink, eDur);
    float fDelay;
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spell.Loc);
    effect eVis = EffectVisualEffect(VFX_IMP_REMOVE_CONDITION);

    if(spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration*2;
    }

    //Get first target in the spell area
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc);
    while (GetIsObjectValid(oTarget))
    {
        //Only remove the fear effect from the people who are friends.
        if(spellsIsTarget(oTarget,spell.TargetType,spell.Caster))
        {
            fDelay = GetRandomDelay();
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, SPELL_REMOVE_FEAR, FALSE));
            eFear = GetFirstEffect(oTarget);
            //Get the first effect on the current target
            while(GetIsEffectValid(eFear))
            {
                if (GetEffectType(eFear) == EFFECT_TYPE_FRIGHTENED)
                {
                    //Remove any fear effects and apply the VFX impact
                    RemoveEffect(oTarget, eFear);
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
                }
                //Get the next effect on the target
                eFear = GetNextEffect(oTarget);
            }
            //Apply the linked effects
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, DurationToSeconds(nDuration)));
        }
        //Get the next target in the spell area.
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc);
    }
}

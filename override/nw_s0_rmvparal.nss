//::///////////////////////////////////////////////
//:: Remove Paralysis
//:: NW_S0_RmvParal
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Removes the paralysis and hold effects from the
    targeted creature.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Jan 20, 2002
//:://////////////////////////////////////////////
/*
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
    spell.TargetType = SPELL_TARGET_ALLALLIES;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spell.Range = RADIUS_SIZE_LARGE;
    spellsDeclareMajorVariables();
    effect eParal;
    effect eVis = EffectVisualEffect(VFX_IMP_REMOVE_CONDITION);
    effect eImpact = EffectVisualEffect(VFX_FNF_LOS_HOLY_20);
    int nCnt = 0;
    int nRemove = (spell.Level/4)+1;
    float fDelay;
    ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eImpact, spell.Loc);
    //Get the first effect on the target
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc);
    while(GetIsObjectValid(oTarget) && nCnt < nRemove)
    {
        if(spellsIsTarget(oTarget,spell.TargetType,spell.Caster))
        {
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(spell.Caster, SPELL_REMOVE_PARALYSIS, FALSE));
            fDelay = GetRandomDelay();
            eParal = GetFirstEffect(oTarget);
            while(GetIsEffectValid(eParal))
            {
                //Check if the current effect is of correct type
                if (GetEffectType(eParal) == EFFECT_TYPE_PARALYZE)
                {
                    //Remove the effect and apply VFX impact
                    RemoveEffect(oTarget, eParal);
                    DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
                    nCnt++;
                }
                //Get the next effect on the target
                eParal = GetNextEffect(oTarget);
            }
        }
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE, spell.Range, spell.Loc);
    }
}

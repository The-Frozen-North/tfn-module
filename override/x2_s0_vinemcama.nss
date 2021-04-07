//::///////////////////////////////////////////////
//:: Vine Mine, Camouflage: On Enter
//:: X2_S0_VineMCamA
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Friendly creatures entering the zone of Vine Mine,
    Camouflage have a +4 added to hide checks.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 25, 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Andrew Nobbs, 02/06/2003
/*
Patch 1.70

- aoe signalized wrong spell ID
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.TargetType = SPELL_TARGET_ALLALLIES;

    //Declare major variables
    aoesDeclareMajorVariables();
    object oTarget = GetEnteringObject();
    if(spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
    {
        if(!GetHasSpellEffect(spell.Id, oTarget))
        {
            //Fire cast spell at event for the target
            SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id, FALSE));

            effect eVis = EffectVisualEffect(VFX_IMP_HEAD_NATURE);
            effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
            effect eSkill = EffectSkillIncrease(SKILL_HIDE, 4);
            effect eLink = EffectLinkEffects(eDur, eSkill);
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);
        }
    }
}

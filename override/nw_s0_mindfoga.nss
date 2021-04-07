//::///////////////////////////////////////////////
//:: Mind Fog: On Enter
//:: NW_S0_MindFogA.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creates a bank of fog that lowers the Will save
    of all creatures within who fail a Will Save by
    -10.  Affect lasts for 2d6 rounds after leaving
    the fog
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Aug 1, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- was missing immunity feedback
- wrong SR check
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.SavingThrow = SAVING_THROW_WILL;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    //Declare major variables
    aoesDeclareMajorVariables();
    object oTarget = GetEnteringObject();
    effect eVis = EffectVisualEffect(VFX_DUR_MIND_AFFECTING_NEGATIVE);
    effect eLower = EffectSavingThrowDecrease(spell.SavingThrow, 10);
    effect eLink = EffectLinkEffects(eVis, eLower);
    int bValid = FALSE;
    float fDelay = GetRandomDelay(1.0, 2.2);
    if(spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
        //Make SR check
        effect eAOE = GetFirstEffect(oTarget);
        if(GetHasSpellEffect(spell.Id, oTarget))
        {
            while (GetIsEffectValid(eAOE))
            {
                //If the effect was created by the Mind_Fog then remove it
                if (GetEffectSpellId(eAOE) == spell.Id && aoe.Creator == GetEffectCreator(eAOE))
                {
                    if(GetEffectType(eAOE) == EFFECT_TYPE_SAVING_THROW_DECREASE)
                    {
                        RemoveEffect(oTarget, eAOE);
                        bValid = TRUE;
                    }
                }
                //Get the next effect on the creation
                eAOE = GetNextEffect(oTarget);
            }
        //Check if the effect has been put on the creature already.  If no, then save again
        //If yes, apply without a save.
        }
        if(!bValid)
        {
            if(!MyResistSpell(aoe.Creator, oTarget))
            {
                //Make Will save to negate
                if(!MySavingThrow(spell.SavingThrow, oTarget, spell.DC, SAVING_THROW_TYPE_MIND_SPELLS, aoe.Creator))
                {
                    if(!GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, aoe.Creator))
                    {
                        //Apply VFX impact and lowered save effect
                        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget));
                    }
                    else
                    {
                        //engine workaround in order to get proper feedback
                        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectFrightened(), oTarget, 1.0);
                    }
                }
            }
        }
        else
        {
            if(!GetIsImmune(oTarget, IMMUNITY_TYPE_MIND_SPELLS, aoe.Creator))
            {
                //Apply VFX impact and lowered save effect
                ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget);
            }
            else
            {
                //engine workaround in order to get proper feedback
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, EffectFrightened(), oTarget, 1.0);
            }
        }
    }
}

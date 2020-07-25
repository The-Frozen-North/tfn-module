//::///////////////////////////////////////////////
//:: Vine Mine, Entangle C
//:: X2_S0_VineMEntC
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Upon entering the AOE the target must make
    a reflex save or be entangled by vegitation
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 25, 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Georg Zoeller, 14/08/2003
/*
Patch 1.70

- aoe signalized wrong spell ID
- incorporeal creatures could been affected
- added delay into applications of effects and VFXs
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.SavingThrow = SAVING_THROW_REFLEX;
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    //Declare major variables
    aoesDeclareMajorVariables();

    //--------------------------------------------------------------------------
    // GZ 2003-Oct-15
    // When the caster is no longer there, all functions calling
    // GetAreaOfEffectCreator will fail. Its better to remove the barrier then
    //--------------------------------------------------------------------------
    if (aoe.Creator != OBJECT_INVALID && !GetIsObjectValid(aoe.Creator))
    {
        DestroyObject(aoe.AOE);
        return;
    }

    effect eHold = EffectEntangle();
    effect eEntangle = EffectVisualEffect(VFX_DUR_ENTANGLE);
    //Link Entangle and Hold effects
    effect eLink = EffectLinkEffects(eHold, eEntangle);
    float fDelay;

    object oTarget = GetFirstInPersistentObject(aoe.AOE);
    while(GetIsObjectValid(oTarget))
    {
        if(!GetHasFeat(FEAT_WOODLAND_STRIDE, oTarget) && !GetCreatureFlag(oTarget, CREATURE_VAR_IS_INCORPOREAL))
        {
            if(spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
            {
                //Fire cast spell at event for the specified target
                SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
                //random delay so each creature in AOE will be affected in different moment
                fDelay = GetRandomDelay();
                //Make SR check
                if(!GetHasEffect(EFFECT_TYPE_ENTANGLE, oTarget) && !MyResistSpell(aoe.Creator, oTarget, fDelay))
                {
                    //Make reflex save
                    if(!MySavingThrow(spell.SavingThrow, oTarget, spell.DC, SAVING_THROW_TYPE_NONE, aoe.Creator, fDelay))
                    {
                       //Apply linked effects
                       DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(2)));
                    }
                }
            }
        }
        //Get next target in the AOE
        oTarget = GetNextInPersistentObject(aoe.AOE);
    }
}

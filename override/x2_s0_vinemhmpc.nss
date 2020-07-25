//::///////////////////////////////////////////////
//:: Vine Mine, Hamper Movement: Heartbeat
//:: X2_S0_VineMHmpC
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creatures entering the zone of Vine Mine, Hamper
    Movement have their movement reduced by 1/2.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Now 25, 2002
//:://////////////////////////////////////////////
//:: Last Updated By: Andrew Nobbs, 02/06/2003
/*
Patch 1.70

- aoe signalized wrong spell ID
- incorporeal creatures could been affected
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.TargetType = SPELL_TARGET_STANDARDHOSTILE;

    //Declare major variables
    aoesDeclareMajorVariables();

    //--------------------------------------------------------------------------
    // GZ 2003-Oct-15
    // When the caster is no longer there, all functions calling
    // GetAreaOfEffectCreator will fail. Its better to remove the barrier then
    //--------------------------------------------------------------------------
    if(aoe.Creator != OBJECT_INVALID && !GetIsObjectValid(aoe.Creator))
    {
        DestroyObject(aoe.AOE);
        return;
    }

    effect eVis = EffectVisualEffect(VFX_IMP_SLOW);
    effect eSlow = EffectMovementSpeedDecrease(50);
    effect eLink = EffectLinkEffects(eVis, eSlow);
    float fDelay;

    //Get first target in spell area
    object oTarget = GetFirstInPersistentObject(aoe.AOE);
    while(GetIsObjectValid(oTarget))
    {
        if(!GetHasFeat(FEAT_WOODLAND_STRIDE, oTarget) && !GetCreatureFlag(oTarget, CREATURE_VAR_IS_INCORPOREAL))
        {
            if(spellsIsTarget(oTarget, spell.TargetType, aoe.Creator))
            {
                SignalEvent(oTarget, EventSpellCastAt(aoe.AOE, spell.Id));
                fDelay = GetRandomDelay(0.0, 2.0);
                DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, oTarget));
            }
        }
        //Get next target in spell area
        oTarget = GetNextInPersistentObject(aoe.AOE);
    }
}

//::///////////////////////////////////////////////////
//:: X0_S1_PETRGAZE
//:: Petrification gaze monster ability.
//:: Fortitude save (DC 15) or be turned to stone permanently.
//:: This will be changed to a temporary effect.
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 11/14/2002
//::///////////////////////////////////////////////////
//:: Used by Basilisk
/*
Pach 1.72
- fixed casting the spell on self not finding any targets in AoE
Patch 1.71
- blinded/sightless creatures are not affected anymore
- was missing blinded check
*/

#include "70_inc_spells"
#include "x2_i0_spells"

void main()
{
    //--------------------------------------------------------------------------
    // Make sure we are not blind
    //--------------------------------------------------------------------------
    if( GZCanNotUseGazeAttackCheck(OBJECT_SELF))
    {
        return;
    }

    int nHitDice = GetHitDice(OBJECT_SELF);
    int nSpellID = GetSpellId();
    float fDelay;

    location lTargetLocation = GetSpellTargetLocation();
    if(lTargetLocation == GetLocation(OBJECT_SELF))
    {
        vector vFinalPosition = GetPositionFromLocation(lTargetLocation);
        vFinalPosition.x+= cos(GetFacing(OBJECT_SELF));
        vFinalPosition.y+= sin(GetFacing(OBJECT_SELF));
        lTargetLocation = Location(GetAreaFromLocation(lTargetLocation),vFinalPosition,GetFacingFromLocation(lTargetLocation));
    }

    //Get first target in spell area
    object oTarget = GetFirstObjectInShape(SHAPE_SPELLCONE, 11.0, lTargetLocation, TRUE);
    while(GetIsObjectValid(oTarget))
    {
        if(oTarget != OBJECT_SELF && spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
        {
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, nSpellID));
            fDelay = GetDistanceBetween(OBJECT_SELF, oTarget)/20;

            if(GetIsAbleToSee(oTarget))
            {
                DelayCommand(fDelay, DoPetrification(nHitDice, OBJECT_SELF, oTarget, nSpellID, 13));
            }
        }

        //Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPELLCONE, 11.0, lTargetLocation, TRUE);
    }
}

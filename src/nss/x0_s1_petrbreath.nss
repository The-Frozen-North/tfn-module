//::///////////////////////////////////////////////////
//:: X0_S1_PETRBREATH
//:: Petrification breath monster ability.
//:: Fortitude save (DC 17) or be turned to stone permanently.
//:: This will be changed to a temporary effect.
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 11/14/2002
//::///////////////////////////////////////////////////
/*
Pach 1.72
- added code to make this spell functional in case it is ever used on self
*/

#include "x0_i0_spells"

void main()
{
    object oTarget = GetSpellTargetObject();
    int nHitDice = GetHitDice(OBJECT_SELF);

    location lTargetLocation = GetSpellTargetLocation();
    if(lTargetLocation == GetLocation(OBJECT_SELF))
    {
        vector vFinalPosition = GetPositionFromLocation(lTargetLocation);
        vFinalPosition.x+= cos(GetFacing(OBJECT_SELF));
        vFinalPosition.y+= sin(GetFacing(OBJECT_SELF));
        lTargetLocation = Location(GetAreaFromLocation(lTargetLocation),vFinalPosition,GetFacingFromLocation(lTargetLocation));
    }

    //Get first target in spell area
    oTarget = GetFirstObjectInShape(SHAPE_SPELLCONE, 11.0, lTargetLocation, TRUE);
    while(GetIsObjectValid(oTarget))
    {
        if(spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, OBJECT_SELF))
        {
            int nSpellID = GetSpellId();
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, nSpellID));
            float fDelay = GetDistanceBetween(OBJECT_SELF, oTarget)/20;

            object oSelf = OBJECT_SELF;
            DelayCommand(fDelay, DoPetrification(nHitDice, oSelf, oTarget, nSpellID, 17));
        }
        //Get next target in spell area
        oTarget = GetNextObjectInShape(SHAPE_SPELLCONE, 11.0, lTargetLocation, TRUE);
    }
}

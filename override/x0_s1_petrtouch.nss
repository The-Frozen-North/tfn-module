//::///////////////////////////////////////////////////
//:: X0_S1_PETRGAZE
//:: Petrification touch attack monster ability.
//:: Fortitude save (DC 15) or be turned to stone permanently.
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 11/14/2002
//::///////////////////////////////////////////////////
/*
Patch 1.70

- duration corrected (was target's HD instead of caster's)
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    object oTarget = GetSpellTargetObject();
    int nHitDice = GetHitDice(OBJECT_SELF);

    if(spellsIsTarget(oTarget, SPELL_TARGET_SINGLETARGET, OBJECT_SELF))
    {
        int nSpellID = GetSpellId();
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, nSpellID));
        DoPetrification(nHitDice, OBJECT_SELF, oTarget, nSpellID, 15);
    }
}

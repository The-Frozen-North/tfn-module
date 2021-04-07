//::///////////////////////////////////////////////////
//:: X0_TRAPFTL_HMONS
//:: OnTriggered script for a projectile trap
//:: Spell fired: SPELL_HOLD_MONSTER
//:: Spell caster level: 17
//::
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 11/17/2002
//::///////////////////////////////////////////////////

#include "x0_i0_projtrap"

void main()
{
    //1.70: DC and metamagic override for the spell cast by projectile trap, adjust as you see fit
    SetLocalInt(OBJECT_SELF, "DC", 30);
    SetLocalInt(OBJECT_SELF, "Metamagic", METAMAGIC_NONE);

    TriggerProjectileTrap(SPELL_HOLD_MONSTER, GetEnteringObject(), 17);
}

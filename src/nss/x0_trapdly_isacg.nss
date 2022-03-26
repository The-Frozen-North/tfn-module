//::///////////////////////////////////////////////////
//:: X0_TRAPDLY_ISACG
//:: OnTriggered script for a projectile trap
//:: Spell fired: SPELL_ISAACS_GREATER_MISSILE_STORM
//:: Spell caster level: 11
//::
//:: Copyright (c) 2002 Floodgate Entertainment
//:: Created By: Naomi Novik
//:: Created On: 11/17/2002
//::///////////////////////////////////////////////////

#include "x0_i0_projtrap"

void main()
{
    //1.70: DC and metamagic override for the spell cast by projectile trap, adjust as you see fit
    SetLocalInt(OBJECT_SELF, "DC", 0);
    SetLocalInt(OBJECT_SELF, "Metamagic", METAMAGIC_NONE);

    TriggerProjectileTrap(SPELL_ISAACS_GREATER_MISSILE_STORM, GetEnteringObject(), 11);
}

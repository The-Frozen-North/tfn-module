//::///////////////////////////////////////////////
//:: Tyrant Fog Zombie Mist
//:: NW_S1_TyrantFog.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creatures entering the area around the zombie
    must save or take 1 point of Constitution
    damage.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 25, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- was dispellable
*/

#include "70_inc_spells"

void main()
{
    //Set and apply AOE effect
    spellsDeclareMajorVariables();
    effect eAOE = EffectAreaOfEffect(AOE_MOB_TYRANT_FOG);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(eAOE), spell.Caster);
    object oAOE = spellsSetupNewAOE("VFX_MOB_TYRANT_FOG");
    SetAreaOfEffectUndispellable(oAOE);
}

//::///////////////////////////////////////////////
//:: Aura of Horrific Appearance - Sea Hag
//:: nw_s1_HorrAppr.nss
//:: Copyright (c) 2004 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Objects entering the aura must make a fortitude saving
    throw (DC 11) or suffer 2D8 points of Strength
    Ability Damage
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Hayward
//:: Created On: January 9, 2004
//:://////////////////////////////////////////////
/*
Patch 1.70

- was dispellable
*/

#include "70_inc_spells"

void main()
{
    //Set the AOE effect and place it in the world.  The Aura abilities
    //are all permamnent and do not require recasting.
    spellsDeclareMajorVariables();
    effect eAOE = EffectAreaOfEffect(AOE_MOB_HORRIFICAPPEARANCE);
    eAOE = SupernaturalEffect(eAOE);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, eAOE, spell.Caster);
    object oAOE = spellsSetupNewAOE("VFX_MOB_HORRIFICAPPEARANCE");
    SetAreaOfEffectUndispellable(oAOE);
}

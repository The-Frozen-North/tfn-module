//::///////////////////////////////////////////////
//:: Troglidyte Stench
//:: nw_s1_TrogStench.nss
//:: Copyright (c) 2004 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Objects entering the aura must make a fortitude saving
    throw (DC 13) or suffer 1d6 points of Strength
    Ability Damage
*/
//:://////////////////////////////////////////////
//:: Created By: Craig Welburn
//:: Created On: Nov 6, 2004
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
    effect eStench = EffectAreaOfEffect(AOE_MOB_TROGLODYTE_STENCH);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(eStench), spell.Caster);
    object oAOE = spellsSetupNewAOE("VFX_MOB_TROGLODYTE_STENCH");
    SetAreaOfEffectUndispellable(oAOE);
}

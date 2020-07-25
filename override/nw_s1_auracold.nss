//::///////////////////////////////////////////////
//:: Aura of Cold
//:: NW_S1_AuraCold.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Prolonged exposure to the aura of the creature
    causes cold damage to all within the aura.
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
    effect eAOE = EffectAreaOfEffect(AOE_MOB_FROST);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(eAOE), spell.Caster);
    object oAOE = spellsSetupNewAOE("VFX_MOB_FROST","nw_s1_auracoldc");
    SetAreaOfEffectUndispellable(oAOE);
}

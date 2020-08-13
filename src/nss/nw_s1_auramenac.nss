//::///////////////////////////////////////////////
//:: Aura of Menace
//:: NW_S1_AuraMenac.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Upon entering the aura all creatures of type animal
    are struck with fear.
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
    //Set and apply AOE object
    spellsDeclareMajorVariables();
    effect eAOE = EffectAreaOfEffect(AOE_MOB_MENACE);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(eAOE), OBJECT_SELF);
    object oAOE = spellsSetupNewAOE("VFX_MOB_MENACE");
    SetAreaOfEffectUndispellable(oAOE);
}

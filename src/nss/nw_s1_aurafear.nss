//::///////////////////////////////////////////////
//:: Aura of Fear
//:: NW_S1_AuraFear.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Upon entering the aura of the creature the player
    must make a will save or be struck with fear because
    of the creatures presence.
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
    effect eAOE = EffectAreaOfEffect(AOE_MOB_FEAR);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(eAOE), spell.Caster);
    object oAOE = spellsSetupNewAOE("VFX_MOB_FEAR");
    SetAreaOfEffectUndispellable(oAOE);
}

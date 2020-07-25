//::///////////////////////////////////////////////
//:: Dragon Aura of Fear
//:: NW_S1_AuraDrag.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Upon entering the aura of the creature the player
    must make a will save or be struck with fear because
    of the creatures presence.

    GZ, OCT 2003
    Since Druids and Shifter's can now use this as well,
    make their version last level /4 rounds

*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: April 17, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- was dispellable
*/

#include "70_inc_spells"
#include "nw_i0_spells"

void main()
{
    //Set and apply AOE effect
    spellsDeclareMajorVariables();
    effect eAOE = EffectAreaOfEffect(36);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(eAOE), spell.Caster);
    object oAOE = spellsSetupNewAOE("VFX_MOB_DRAGON_FEAR");
    SetAreaOfEffectUndispellable(oAOE);
}

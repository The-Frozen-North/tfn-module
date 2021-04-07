//::///////////////////////////////////////////////
//:: Aura of Blinding
//:: NW_S1_AuraBlind.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Upon entering the aura of the creature the player
    must make a will save or be blinded because of the
    sheer ugliness or beauty of the creature.
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
    //Set the AOE effect and place it in the world.  The Aura abilities
    //are all permamnent and do not require recasting.
    spellsDeclareMajorVariables();
    effect eAOE = EffectAreaOfEffect(AOE_MOB_BLINDING);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(eAOE), OBJECT_SELF);
    object oAOE = spellsSetupNewAOE("VFX_MOB_BLINDING");
    SetAreaOfEffectUndispellable(oAOE);
}

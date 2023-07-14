//::///////////////////////////////////////////////
//:: Ballista Fireball
//:: x2_p1_ballista
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
// A fireball fired from a ballista is a burst of flame
// that detonates with a low roar and inflicts 2d6 points
// of damage to all creatures
// within the area. Unattended objects also take
// damage. The explosion creates almost no pressure.
*/
//:://////////////////////////////////////////////
//:: Created By: Keith Warner
//:: Created On: Dec 6/02
//:://////////////////////////////////////////////
//

#include "nw_i0_spells"
/*
// playing sound on a creature is... iffy at best when using assign commands. this is hacky but works
void DoSound(location lLocation)
{
    object oWP = CreateObject(OBJECT_TYPE_PLACEABLE, "_invisible", lLocation);
    DelayCommand(0.01, AssignCommand(oWP, PlaySound("jst_lancebreak")));
    AssignCommand(GetModule(), DestroyObject(oWP, 3.0));
}
*/

void main()
{
    //Declare major variables

    int nDamage;
    float fDelay;
    effect eVis = EffectVisualEffect(VFX_COM_CHUNK_STONE_SMALL, 0, 0.25);
    effect eSound = EffectVisualEffect(VFX_COM_CHUNK_RED_BALLISTA, 0, 0.001);
    effect eDam;
    object oTarget = GetSpellTargetObject();

    //Roll damage for each target
    nDamage = d8(4);
    //Adjust the damage based on the Reflex Save, Evasion and Improved Evasion.
    nDamage = GetReflexAdjustedDamage(nDamage, oTarget, 15);
    //Set the damage effect
    eDam = EffectDamage(nDamage, DAMAGE_TYPE_PIERCING);
    if(nDamage > 0)
    {
        // Apply effects to the currently selected target.
        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eSound, oTarget));
        //DelayCommand(fDelay, DoSound(GetLocation(oTarget)));
     }
}


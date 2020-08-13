//::///////////////////////////////////////////////
//:: Holy Water
//:: x0_s3_holy
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Grenade.
    Fires at a target. If hit, the target takes
    direct damage. If missed, all enemies within
    an area of effect take splash damage.

    HOWTO:
    - If target is valid attempt a hit
       - If miss then MISS
       - If hit then direct damage
    - If target is invalid or MISS
       - have area of effect near target
       - everyone in area takes splash damage
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: September 10, 2002
//:://////////////////////////////////////////////
/*
Patch 1.70

- critical hit damage corrected
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
spell.Level = 2;
DoGrenade(4,1, VFX_IMP_HEAD_HOLY, VFX_FNF_LOS_NORMAL_20, DAMAGE_TYPE_DIVINE, RADIUS_SIZE_HUGE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE, RACIAL_TYPE_UNDEAD);
}

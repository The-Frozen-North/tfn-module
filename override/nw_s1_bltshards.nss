//::///////////////////////////////////////////////
//:: Bolt: Shards
//:: NW_S1_BltShard
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Creature must make a ranged touch attack to hit
    the intended target.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 11 , 2001
//:: Updated On: July 15, 2003 Georg Zoeller - Removed saving throws
//:://////////////////////////////////////////////
/*
Patch 1.70

- critical hit damage corrected
*/

#include "70_inc_spells"
#include "x0_i0_spells"

void main()
{
    //Declare major variables
    object oTarget = GetSpellTargetObject();
    int nHD = GetHitDice(OBJECT_SELF);
    effect eBolt;
    int nDC = 10 + (nHD/2);
    int nCount = nHD /2;
    if(nCount < 1)
    {
        nCount = 1;
    }

    if(spellsIsTarget(oTarget, SPELL_TARGET_SINGLETARGET, OBJECT_SELF))
    {
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_BOLT_SHARDS));

        //Make a ranged touch attack
        int nTouch = TouchAttackRanged(oTarget);
        if(nTouch > 0)
        {
            int nDamage = d6(nCount*nTouch);//correct critical hit damage calculation (will enable odd values)
            //Set damage effect
            eBolt = EffectDamage(nDamage, DAMAGE_TYPE_PIERCING, DAMAGE_POWER_PLUS_ONE);
            //Apply the VFX impact and effects
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eBolt, oTarget);
        }
    }
}

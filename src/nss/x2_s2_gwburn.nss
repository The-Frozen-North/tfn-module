//::///////////////////////////////////////////////
//:: Outsider Shape - Azer - Fire stream
//:: x2_s2_gwburn
//:: Copyright (c) 2003Bioware Corp.
//:://////////////////////////////////////////////
/*

  Azer shoot fire ability. The fire they breathe
  is natural, so there is no SR check against it

*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: July, 07, 2003
//:://////////////////////////////////////////////
/*
Patch 1.70

- damage wasn't calculated properly ((levels)*(1d4outcome) instead of (levels)d4)
- saving throw removed (this is bolt, they don't have saving throws)
- critical hit damage corrected
*/

#include "x2_inc_shifter"

void main()
{
    //--------------------------------------------------------------------------
    // Enforce artifical use limit on that ability
    //--------------------------------------------------------------------------
    /*    if (ShifterDecrementGWildShapeSpellUsesLeft() <1 )
    {
        FloatingTextStrRefOnCreature(83576, OBJECT_SELF);
        return;
    }
    */

    //--------------------------------------------------------------------------
    // Create VFX
    //--------------------------------------------------------------------------
    object oTarget = GetSpellTargetObject();
    int     nTouch = TouchAttackRanged(oTarget);
    effect eRay      = EffectBeam(444,OBJECT_SELF,BODY_NODE_CHEST,(nTouch == 0));
    effect eDur      = EffectVisualEffect(VFX_DUR_INFERNO_CHEST);


    float fDelay = GetDistanceBetween(oTarget, OBJECT_SELF)/14;

    ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eRay,oTarget,1.7);
    SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId()));

    if (nTouch > 0)
    {
        int nNumDice = GetLevelByClass(CLASS_TYPE_SHIFTER,OBJECT_SELF)/3;
        //correct damage and critical hit calculation
        int nDamage = d4(nNumDice*nTouch)+GetAbilityModifier(ABILITY_WISDOM,OBJECT_SELF)*nTouch;

        effect eDamage = EffectDamage(nDamage,DAMAGE_TYPE_FIRE);
        effect eHit = EffectVisualEffect(VFX_IMP_FLAME_S);

        eHit = EffectLinkEffects(eDamage,eHit);
        DelayCommand(fDelay,ApplyEffectToObject(DURATION_TYPE_TEMPORARY,eDur,oTarget,3.0));
        DelayCommand(fDelay+0.3,ApplyEffectToObject(DURATION_TYPE_INSTANT,eHit,oTarget));
    }
}

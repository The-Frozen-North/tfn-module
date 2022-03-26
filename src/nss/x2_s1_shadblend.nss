//::///////////////////////////////////////////////
//:: Shadow Dragon: Blend into shadows
//:: x2_s1_shadblend
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*

   The shadow dragons blend into shadows ability.
   Will give him 9/10th concealments


    If you set the variable X2_AREA_NO_SHADOWS
    TRUE on the area, the ability will not work

*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: 2003-08-27
//:://////////////////////////////////////////////
/*
Patch 1.70

- fixed AI behavior when creature is under continual spell effect
- VFX improved to better suit actual effect
*/

#include "x2_inc_switches"

void main()
{
    //Declare major variables
    object oTarget = GetSpellTargetObject();
    effect eVis = EffectVisualEffect(VFX_DUR_PROT_SHADOW_ARMOR);
    effect eVis2 = EffectVisualEffect(VFX_DUR_INVISIBILITY);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eBlend = EffectConcealment(90);
    effect eLink = EffectLinkEffects(eVis, eBlend);
    eLink = EffectLinkEffects(eLink, eDur);
    eLink = EffectLinkEffects(eLink, eVis2);
    int nDuration = 10; // 10 rounds

    //Fire cast spell at event for the specified target
    SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, GetSpellId(), FALSE));
    //Apply the VFX impact and effects
    if(!GetHasSpellEffect(GetSpellId(),OBJECT_SELF))
    {
        // if we are under effect of continual flame, this does not work
        if(!GetHasSpellEffect(SPELL_CONTINUAL_FLAME,OBJECT_SELF))
        {
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(nDuration));
        }
        else
        {
            //1.70: fix for default AI, in this case creature tried to use this ability again and again as long as she had uses
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, oTarget, RoundsToSeconds(nDuration));
        }
     }
}

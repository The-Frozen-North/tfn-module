//::///////////////////////////////////////////////
//:: Steam Mephit Breath
//:: NW_S1_MephSteam
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Steam Mephit shoots out a bolt of steam
    that causes 1d4 damage and reduces AC by 4
    and Attack by 2
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: May 11, 2001
//:://////////////////////////////////////////////
/*
Patch 1.70

- saving throw removed (this is bolt, they don't have saving throws)
- critical hit damage corrected
*/

void main()
{
    //Declare major variables
    object oTarget = GetSpellTargetObject();
    int nHD = GetHitDice(OBJECT_SELF);
    effect eVis = EffectVisualEffect(VFX_IMP_ACID_S);
    effect eBolt, eAttack, eAC;
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_NEGATIVE);

    //Make a ranged touch attack
    int nTouch = TouchAttackRanged(oTarget);
    if(nTouch > 0)
    {
        int nDamage = d4(nTouch);//correct critical hit damage calculation (will enable odd values)
        //Fire cast spell at event for the specified target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_MEPHIT_STEAM_BREATH));

        //Set damage, AC mod and attack mod effects
        eBolt = EffectDamage(nDamage, DAMAGE_TYPE_FIRE);
        eAC = EffectACDecrease(4);
        eAttack = EffectAttackDecrease(2);
        effect eLink = EffectLinkEffects(eAC, eAttack);
        eLink = EffectLinkEffects(eLink, eDur);

        //Apply the VFX impact and effects
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, RoundsToSeconds(3));
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eBolt, oTarget);
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget);
    }
}

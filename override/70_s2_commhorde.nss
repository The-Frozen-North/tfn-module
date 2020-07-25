//::///////////////////////////////////////////////
//:: Command Horde
//:: 70_s2_commhorde
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
At 1st level, the Eye of Gruumsh may grant a +2 morale bonus on Will saving throws to
any nongood orcs or half-orcs with Hit Dice lower than his character level within 30 feet.
The effect lasts for 1 hour per eye of Gruumsh level.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch
//:: Created On: 08-11-2013
//:://////////////////////////////////////////////

#include "x2_i0_spells"

void main()
{
    //Declare major variables
    object oCaster = OBJECT_SELF;
    effect eSaving =  EffectSavingThrowIncrease(SAVING_THROW_WILL, 2, SAVING_THROW_TYPE_ALL);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    effect eVis = EffectVisualEffect(VFX_IMP_HEAD_HOLY);
    //Link Effects
    effect eLink = EffectLinkEffects(eSaving, eDur);
    int nHD = GetHitDice(oCaster);
    int nLevel = GetLevelByClass(39);
    float fDelay;

    if(!GetHasEffect(EFFECT_TYPE_SILENCE))
    {
        PlayVoiceChat(VOICE_CHAT_BATTLECRY1);
    }

    location lTarget = GetSpellTargetLocation();
    object oTarget = FIX_GetFirstObjectInShape(SHAPE_SPHERE,RADIUS_SIZE_COLOSSAL,lTarget,TRUE);
    while(GetIsObjectValid(oTarget))
    {
        if(spellsIsTarget(oTarget,SPELL_TARGET_ALLALLIES,oCaster) && GetAlignmentGoodEvil(oTarget) != ALIGNMENT_GOOD && GetHitDice(oTarget) < nHD)
        {
            fDelay = GetRandomDelay();
            //Fire cast spell at event for the specified target
            SignalEvent(oTarget, EventSpellCastAt(oCaster, 478, FALSE));

            DelayCommand(fDelay, RemoveEffectsFromSpell(oTarget, GetSpellId()));
            //Apply the VFX impact and effects
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oTarget, HoursToSeconds(nLevel)));
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oTarget));
        }
        oTarget = FIX_GetNextObjectInShape(SHAPE_SPHERE,RADIUS_SIZE_COLOSSAL,lTarget,TRUE);
    }
}

//::///////////////////////////////////////////////
//:: Mighty Rage
//:: X2_S2_MghtyRage
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The Str and Con of the Barbarian increases,
    Will Save are +2, AC -2.
    Greater Rage starts at level 15.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: May 16, 2003
//:://////////////////////////////////////////////
/*
Patch 1.72
- fixed stacking of the ac penalty
Patch 1.70
- can be now activated even when the activator is under effect of the standard rage,
but still doesn't stack
- thundering rage benefit is given into creature weapons or gauntlets (only deafness)
if the activator don't have any weapons
- under silence effect barbarian wont utter battle cry
*/

#include "x2_i0_spells"

void main()
{
    //Declare major variables
    int nLevel = GetLevelByClass(CLASS_TYPE_BARBARIAN);
    if(!GetHasEffect(EFFECT_TYPE_SILENCE))
    {
        PlayVoiceChat(VOICE_CHAT_BATTLECRY1);
    }
    //Determine the duration by getting the con modifier after being modified
    int nCon = 3 + GetAbilityModifier(ABILITY_CONSTITUTION) + 8;
    effect eStr = EffectAbilityIncrease(ABILITY_CONSTITUTION, 8);
    effect eCon = EffectAbilityIncrease(ABILITY_STRENGTH, 8);
    effect eSave = EffectSavingThrowIncrease(SAVING_THROW_WILL, 4);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    effect eLink = EffectLinkEffects(eCon, eStr);
    eLink = EffectLinkEffects(eLink, eSave);
    eLink = EffectLinkEffects(eLink, eDur);
    SignalEvent(OBJECT_SELF, EventSpellCastAt(OBJECT_SELF, GetSpellId(), FALSE));
    //Make effect extraordinary
    eLink = ExtraordinaryEffect(eLink);
    effect eVis = EffectVisualEffect(VFX_IMP_IMPROVE_ABILITY_SCORE); //Change to the Rage VFX

    //does not stack with standard rage and neither with itself
    RemoveEffectsFromSpell(OBJECT_SELF, SPELLABILITY_BARBARIAN_RAGE);
    RemoveEffectsFromSpell(OBJECT_SELF, SPELLABILITY_EPIC_MIGHTY_RAGE);
    if (nCon > 0)
    {
        //Apply the VFX impact and effects
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, OBJECT_SELF, RoundsToSeconds(nCon));
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF) ;
        // 2003-07-08, Georg: Rage Epic Feat Handling
        CheckAndApplyEpicRageFeats(nCon);
    }
}

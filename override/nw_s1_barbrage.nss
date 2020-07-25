//::///////////////////////////////////////////////
//:: Barbarian Rage
//:: NW_S1_BarbRage
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    The Str and Con of the Barbarian increases,
    Will Save are +2, AC -2.
    Greater Rage starts at level 15.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Aug 13, 2001
//:://////////////////////////////////////////////
/*
Patch 1.72
- fixed stacking of the ac penalty
Patch 1.71
- added support for Swing Blindly feat of Eye of the Gruumsh class
Patch 1.70
- stacked with mighty rage
- since the use per day is consumed, instead of doing nothing, reactivating this
ability will overwrite old bonuses
- thundering rage benefit is given into creature weapons or gauntlets (only deafness)
if the activator doesn't have any weapons
- under silence effect barbarian won't utter battle cry
*/

#include "x2_i0_spells"

void main()
{
    //Declare major variables
    int nLevel = GetLevelByClass(CLASS_TYPE_BARBARIAN)+GetLevelByClass(CLASS_TYPE_EYE_OF_GRUUMSH);//1.72: Eye of Gruumsh should stack with barbarian for determining rage uses and bonuses
    int nIncrease;
    int nSave;
    if (nLevel < 15)
    {
        nIncrease = 4;
        nSave = 2;
    }
    else
    {
        nIncrease = 6;
        nSave = 3;
    }
    int nGruumshBonus;
    if(GetHasFeat(483))
    {
        nGruumshBonus = 4;
    }

    if(!GetHasEffect(EFFECT_TYPE_SILENCE))
    {
        PlayVoiceChat(VOICE_CHAT_BATTLECRY1);
    }
    //Determine the duration by getting the con modifier after being modified
    int nCon = 3 + GetAbilityModifier(ABILITY_CONSTITUTION) + nIncrease;
    effect eCon = EffectAbilityIncrease(ABILITY_CONSTITUTION, nIncrease);
    effect eStr = EffectAbilityIncrease(ABILITY_STRENGTH, nIncrease + nGruumshBonus);
    effect eSave = EffectSavingThrowIncrease(SAVING_THROW_WILL, nSave);
    effect eAC = EffectACDecrease(2+(nGruumshBonus/2), AC_DODGE_BONUS);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);

    effect eLink = EffectLinkEffects(eCon, eStr);
    eLink = EffectLinkEffects(eLink, eSave);
    eLink = EffectLinkEffects(eLink, eAC);
    eLink = EffectLinkEffects(eLink, eDur);
    SignalEvent(OBJECT_SELF, EventSpellCastAt(OBJECT_SELF, SPELLABILITY_BARBARIAN_RAGE, FALSE));
    //Make effect extraordinary
    eLink = ExtraordinaryEffect(eLink);
    effect eVis = EffectVisualEffect(VFX_IMP_IMPROVE_ABILITY_SCORE); //Change to the Rage VFX

    //does not stack with mighty rage and neither with itself
    RemoveEffectsFromSpell(OBJECT_SELF, SPELLABILITY_EPIC_MIGHTY_RAGE);
    RemoveEffectsFromSpell(OBJECT_SELF, SPELLABILITY_BARBARIAN_RAGE);
    if (nCon > 0)
    {
        //Apply the VFX impact and effects
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, OBJECT_SELF, RoundsToSeconds(nCon));
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, OBJECT_SELF);

        // 2003-07-08, Georg: Rage Epic Feat Handling
        CheckAndApplyEpicRageFeats(nCon);
    }
}

#include "nwnx_visibility"

void main()
{
// don't proceed if in combat
    if (GetIsInCombat()) return;

    object oArea = GetArea(OBJECT_SELF);

// if outside and day time, "disable" the creature
// we don't want to use the limbo feature, as I think it may interfere with creature clean up when an area resets
    if (!GetIsAreaInterior(oArea) && GetIsDay())
    {
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, UnyieldingEffect(EffectCutsceneGhost()), OBJECT_SELF);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, UnyieldingEffect(  EffectCutsceneParalyze()), OBJECT_SELF);
        NWNX_Visibility_SetVisibilityOverride(OBJECT_INVALID, OBJECT_SELF, NWNX_VISIBILITY_HIDDEN);
        SetPlotFlag(OBJECT_SELF, TRUE);
    }
    else
    {
        effect eEffect = GetFirstEffect(OBJECT_SELF);

        while (GetIsEffectValid(eEffect))
        {
            int nType = GetEffectType(eEffect);
            if (nType == EFFECT_TYPE_CUTSCENEGHOST || nType == EFFECT_TYPE_CUTSCENE_PARALYZE)
            {
                // Effect removal during an effect loop has caused issues in the past, better to wait until after the script completes to do it
                DelayCommand(0.0, RemoveEffect(OBJECT_SELF, eEffect));
            }
            
            eEffect = GetNextEffect(OBJECT_SELF);
        }

        NWNX_Visibility_SetVisibilityOverride(OBJECT_INVALID, OBJECT_SELF, NWNX_VISIBILITY_DEFAULT);
        SetPlotFlag(OBJECT_SELF, FALSE);
    }
}

/*
    Script: ef_s_travel
    Author: Daz

    Description: An Equinox Framework System that gives players a movement speed
                 increase when they're travelling on roads and a movement speed decrease
                 while in water.

    @SKIPSYSTEM
*/

#include "nwnx_area"

const string TRAVEL_EFFECT_TAG                  = "TravelEffectTag";
// const float  TRAVEL_EFFECT_DURATION             = 300.0f;
const float  TRAVEL_IMPACT_DELAY_TIMER          = 0.5f;

void Travel_ApplyEffect(object oPlayer, int nMaterial, effect eEffect)
{
    if (GetSurfaceMaterial(GetLocation(oPlayer)) == nMaterial)
    {
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, HideEffectIcon(TagEffect(SupernaturalEffect(eEffect), TRAVEL_EFFECT_TAG)), oPlayer);
    }
}

void RemoveEffectsWithTag(object oObject, string sTag)
{
    effect eEffect = GetFirstEffect(oObject);
    while (GetIsEffectValid(eEffect))
    {
        if (GetEffectTag(eEffect) == sTag)
            RemoveEffect(oObject, eEffect);
        eEffect = GetNextEffect(oObject);
    }
}

// @NWNX[NWNX_ON_MATERIALCHANGE_AFTER]
void main()
{
    object oPlayer = OBJECT_SELF;
    // if (!GetIsPC(oPlayer) || GetIsDM(oPlayer)) return;
    int nMaterial = GetSurfaceMaterial(GetLocation(OBJECT_SELF));
    effect eEffect;
    vector vPosition;
    string sTileResRef, sTileResRefStart;

    switch (nMaterial)
    {
        case 4: // Stone
        case 5: // Wood
        // case 9: // Carpet
        case 10: // Metal
            eEffect = EffectMovementSpeedIncrease(15);
            break;
        case 1: // Dirt, need to check tile resref because there can be dirt surfaces on non-roads
            vPosition = GetPosition(oPlayer);
            sTileResRef = NWNX_Area_GetTileModelResRef(GetArea(oPlayer), vPosition.x, vPosition.y);
            sTileResRefStart = GetStringLeft(sTileResRef, 7);

            if (sTileResRefStart == "ttr01_h" || // rural road
                sTileResRefStart == "tno01_h" || // castle exterior rural road
                sTileResRefStart == "trm02_h" || // medieval rural 2 road
                sTileResRefStart == "trm02_j" || // medieval rural 2 path
                sTileResRefStart == "trm02_r" || // medieval rural 2 path on windmill
                sTileResRefStart == "trm02_u" || // medieval rural 2 path on inn
                sTileResRefStart == "trs02_j" || // early winter road
                sTileResRefStart == "ttf02_g" || // forest facelift road
                sTileResRefStart == "tcm02_h" || // medieval city 2 road
                sTileResRefStart == "tts01_h" || // winter rural road
                sTileResRefStart == "tts02_h") // winter facelift rural road
            {
                eEffect = EffectMovementSpeedIncrease(10);
            }
            break;
        case 11: // Puddles
        case 12: // Swamp
        case 13: // Mud
            eEffect = EffectMovementSpeedDecrease(10);
            break;
        case 6: // Water
            eEffect = EffectMovementSpeedDecrease(20);
            break;
    }

    RemoveEffectsWithTag(oPlayer, TRAVEL_EFFECT_TAG);

    int nFootstepType = GetFootstepType(oPlayer);
    int nAppearance = GetAppearanceType(oPlayer);

    if (GetRacialType(oPlayer) != RACIAL_TYPE_OOZE) // oozes have an invalid footstep type, but should be affected by travel effects
    {
        if (nFootstepType == FOOTSTEP_TYPE_FEATHER_WING || // flying creatures do not benefit from travel effects
        nFootstepType == FOOTSTEP_TYPE_SEAGULL ||
        nFootstepType == FOOTSTEP_TYPE_LEATHER_WING ||
        nFootstepType == -1 || // lantern archons, wraiths, etc. invalid footsteps. means shadows are unaffected as well
        nAppearance == APPEARANCE_TYPE_HELMED_HORROR ||
        nAppearance == APPEARANCE_TYPE_BAT_HORROR||
        nAppearance == APPEARANCE_TYPE_BEHOLDER || // these have a footstep type of 3, odd. soft footsteps
        nAppearance == APPEARANCE_TYPE_BEHOLDER_EYEBALL ||
        nAppearance == APPEARANCE_TYPE_BEHOLDER_MAGE ||
        nAppearance == APPEARANCE_TYPE_BEHOLDER_MOTHER)
        {
            return;
        }
    }

    if (GetEffectType(eEffect))
    {
        Travel_ApplyEffect(oPlayer, nMaterial, eEffect);
        // DelayCommand(TRAVEL_IMPACT_DELAY_TIMER, Travel_ApplyEffect(oPlayer, nMaterial, eEffect));
    }
}

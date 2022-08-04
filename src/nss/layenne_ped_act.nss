// Conversation action script for layenne's tomb pedestals

// LocalInt - "layenne_gem" - string, one of "amethyst" "sapphire" "emerald" "diamond"
// This is set by the area refresh script
// LocalInt - "layenne_filled" - int, 1 if this pedestal has taken its gem

// Script params:

// "fill" - a string containing the kind of gem the player is trying to put in

#include "inc_key"

void main()
{
    object oPC = GetPCSpeaker();
    string sGemInserted = GetScriptParam("fill");
    string sMyGem = GetLocalString(OBJECT_SELF, "layenne_gem");
    if (sGemInserted == sMyGem)
    {
        string sGemTag;
        int nSuccessVFX;
        int nLightVFX;
        string sPlaceableVFX;
        string sPlaceableVFX2;
        if (sMyGem == "amethyst")
        {
            sGemTag = "q_gemofmisery";
            nSuccessVFX = VFX_DUR_AURA_PURPLE;
            nLightVFX = VFX_DUR_LIGHT_PURPLE_15;
            sPlaceableVFX = "plc_magicpurple";
            sPlaceableVFX2 = "plc_solpurple";
        }
        else if (sMyGem == "diamond")
        {
            sGemTag = "q_gemofhonor";
            nSuccessVFX = VFX_DUR_AURA_WHITE;
            nLightVFX = VFX_DUR_LIGHT_WHITE_15;
            sPlaceableVFX = "plc_magicwhite";
            sPlaceableVFX2 = "plc_solwhite";
        }
        else if (sMyGem == "emerald")
        {
            sGemTag = "q_gemofduty";
            nSuccessVFX = VFX_DUR_AURA_GREEN;
            nLightVFX = 179;
            sPlaceableVFX = "plc_magicgreen";
            sPlaceableVFX2 = "plc_solgreen";
        }
        else if (sMyGem == "sapphire")
        {
            sGemTag = "q_gemofpain";
            nSuccessVFX = VFX_DUR_AURA_BLUE;
            nLightVFX = VFX_DUR_LIGHT_BLUE_15;
            sPlaceableVFX = "plc_magicblue";
            sPlaceableVFX2 = "plc_solblue";

        }
        RemoveKeyFromPlayer(oPC, sGemTag);
        SetLocalInt(OBJECT_SELF, "layenne_filled", 1);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectVisualEffect(nSuccessVFX), OBJECT_SELF);
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectVisualEffect(nLightVFX), OBJECT_SELF);
        //ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectVisualEffect(nLightVFX), OBJECT_SELF);
        object oVFX = CreateObject(OBJECT_TYPE_PLACEABLE, sPlaceableVFX, GetLocation(OBJECT_SELF));
        SetLocalObject(OBJECT_SELF, "VFX1", oVFX);
        oVFX = CreateObject(OBJECT_TYPE_PLACEABLE, sPlaceableVFX2, GetLocation(OBJECT_SELF));
        SetLocalObject(OBJECT_SELF, "VFX2", oVFX);
        // Was this the last one?
        int i;
        int bAllFilled = TRUE;
        for (i=1; i<=4; i++)
        {
            object oPed = GetObjectByTag("LayennePedestal" + IntToString(i));
            if (!GetLocalInt(oPed, "layenne_filled"))
            {
                bAllFilled = FALSE;
                break;
            }
        }

        object oTarget = GetWaypointByTag("LayenneCentralPedestal");

        if (bAllFilled)
        {
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_SUMMON_GATE), GetLocation(oTarget));
            object oPed = CreateObject(OBJECT_TYPE_PLACEABLE, "layenne_cent_ped", GetLocation(oTarget));
            SetObjectVisualTransform(oPed, OBJECT_VISUAL_TRANSFORM_SCALE, 1.3);
            SetObjectVisualTransform(oPed, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, -4.0);
            SetObjectVisualTransform(oPed, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, 0.0, OBJECT_VISUAL_TRANSFORM_LERP_LINEAR, 3.5);
            ExecuteScript("treas_init", oPed);
        }

        return;
    }
    // If we got here, the PC can't tell their colours apart.
    int nDamageType;
    effect eVis;
    effect eImpact;
    float fRadius = RADIUS_SIZE_COLOSSAL;

    if (sGemInserted == "amethyst")
    {
        eVis = EffectBeam(VFX_BEAM_FIRE, OBJECT_SELF, BODY_NODE_CHEST);
        eImpact = EffectVisualEffect(VFX_IMP_FLAME_M);
        nDamageType = DAMAGE_TYPE_FIRE;
    }
    else if (sGemInserted == "diamond")
    {
        eVis = EffectBeam(VFX_BEAM_LIGHTNING, OBJECT_SELF, BODY_NODE_CHEST);
        eImpact = EffectVisualEffect(VFX_IMP_LIGHTNING_M);
        nDamageType = DAMAGE_TYPE_ELECTRICAL;
    }
    else if (sGemInserted == "sapphire")
    {
        eVis = EffectBeam(VFX_BEAM_COLD, OBJECT_SELF, BODY_NODE_CHEST);
        eImpact = EffectVisualEffect(VFX_IMP_FROST_L);
        nDamageType = DAMAGE_TYPE_COLD;
    }
    else if (sGemInserted == "emerald")
    {
        eVis = EffectBeam(VFX_BEAM_DISINTEGRATE, OBJECT_SELF, BODY_NODE_CHEST);
        eImpact = EffectVisualEffect(VFX_IMP_ACID_L);
        nDamageType = DAMAGE_TYPE_ACID;
    }

    location lSelf = GetLocation(OBJECT_SELF);
    object oTest = GetFirstObjectInShape(SHAPE_SPHERE, fRadius, lSelf, TRUE);
    while (GetIsObjectValid(oTest))
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, eImpact, oTest);
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eVis, oTest, 3.0);
        // This is intended to have a nonzero chance to kill people who can't see colours correctly or blindly follow OC guides :)
        DelayCommand(0.0, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDamage(d6(8), nDamageType), oTest));
        oTest = GetNextObjectInShape(SHAPE_SPHERE, fRadius, lSelf, TRUE);
    }
}

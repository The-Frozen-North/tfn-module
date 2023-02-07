#include "inc_quest"
#include "nwnx_visibility"
#include "nwnx_object"

void RemoveAllEffects(object oObj)
{
    effect eTest = GetFirstEffect(oObj);
    while (GetIsEffectValid(eTest))
    {
        DelayCommand(0.0, RemoveEffect(oObj, eTest));
        eTest = GetNextEffect(oObj);
    }
}

object GetPentagramDummy(int nIndex)
{
    if (nIndex >= 1 && nIndex <= 5)
    {
        return GetObjectByTag("jhareg_pedestal_dummy" + IntToString(nIndex));
    }
    if (nIndex < 1)
    {
        return GetPentagramDummy(5);
    }
    // 5+ gets the first
    return GetPentagramDummy(1);
}

void RestOfRefresh();

void main()
{
    object oPC = GetEnteringObject();

    // Destroy old Belial
    object oBelial = GetLocalObject(OBJECT_SELF, "belial");
    DestroyObject(oBelial);
    
    // Belial's hitbox needs to shift before making a new one, or he appears offset
    DelayCommand(6.0, RestOfRefresh());
}

void RestOfRefresh()
{
    // Enable brazier usability, and make it alight again
    object oBrazier = GetObjectByTag("jhareg_brazier");
    SetUseableFlag(oBrazier, TRUE);
    AssignCommand(oBrazier, PlayAnimation(ANIMATION_PLACEABLE_ACTIVATE));
    SetPlaceableIllumination(oBrazier, 0);
    RecomputeStaticLighting(OBJECT_SELF);
    NWNX_Object_SetDialogResref(oBrazier, "jharegk_brazier");
    
    // Spawn new Belial
    object oBelial = CreateObject(OBJECT_TYPE_CREATURE, "belial", GetLocation(GetWaypointByTag("BelialSpawnPoint")));
    //SetObjectVisualTransform(oBelial, OBJECT_VISUAL_TRANSFORM_SCALE, 1.5);
    ApplyEffectToObject(DURATION_TYPE_PERMANENT, SupernaturalEffect(EffectCutsceneParalyze()), oBelial);
    SetLocalObject(OBJECT_SELF, "belial", oBelial);
    
    // invulnerable
    SetPlotFlag(oBelial, TRUE);
    
    // Pentagram
    int i;
    for (i=1; i<=5; i++)
    {
        object oThis = GetPentagramDummy(i);
        RemoveAllEffects(oThis);
    }
    for (i=1; i<=5; i++)
    {
        object oThis = GetPentagramDummy(i);
        //AssignCommand(oThis, SpeakString(IntToString(i)));
        object oNext = GetPentagramDummy(i+1);
        DelayCommand(IntToFloat(i), ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(VFX_BEAM_SILENT_EVIL, oThis, BODY_NODE_CHEST, FALSE, 1.0), oNext));
        //SendMessageToPC(GetFirstPC(), "Beam between " + ObjectToString(oThis) + " " + IntToString(i) + " and " + ObjectToString(oNext) + " " + IntToString(i+1));
    }
    
    // candelabra glow
    int j;
    for (i=1; i<=5; i++)
    {
        for (j=0; j<2; j++)
        {
            string sDirection = "";
            if (i >= 2 && i <= 4)
            {
                sDirection = j == 0 ? "l" : "r";
            }
            else if (j == 1)
            {
                // 1 and 5 don't have a l/r
                continue;
            }
            object oThis = GetObjectByTag("jhareg_candelabra_" + IntToString(i) + sDirection);
            //ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(VFX_BEAM_FIRE_W, oThis, BODY_NODE_CHEST, FALSE, 1.0), oBelial);
            //ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectBeam(VFX_BEAM_SILENT_FIRE, oThis, BODY_NODE_CHEST, FALSE, 1.0), oBelial);
            RemoveAllEffects(oThis);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectVisualEffect(VFX_DUR_AURA_ORANGE), oThis);
            SetUseableFlag(oThis, FALSE);
            
        }
    }
    return;
}

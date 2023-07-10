#include "nwnx_events"
#include "x0_i0_position"
#include "inc_webhook"

void main()
{
    object oItem = StringToObject(NWNX_Events_GetEventData("ITEM"));
    string sTag = GetTag(OBJECT_SELF);

    if (sTag == "mer_eltoora")
    {
        object oIdentifier = GetObjectByTag("eltoora");
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGICAL_VISION), oIdentifier);
        TurnToFaceObject(GetItemPossessor(oItem), oIdentifier);
    }
    else if (sTag == "mer_camilla")
    {
        object oIdentifier = GetObjectByTag("camilla");
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGICAL_VISION), oIdentifier);
        TurnToFaceObject(GetItemPossessor(oItem), oIdentifier);
    }
    else if (sTag == "mer_arto")
    {
        object oIdentifier = GetObjectByTag("arto");
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGICAL_VISION), oIdentifier);
        TurnToFaceObject(GetItemPossessor(oItem), oIdentifier);
    }
    else if (sTag == "mer_gulhrys")
    {
        object oIdentifier = GetObjectByTag("gulhrys");
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGICAL_VISION), oIdentifier);
        TurnToFaceObject(GetItemPossessor(oItem), oIdentifier);
    }
    else if (sTag == "mer_elaith")
    {
        object oIdentifier = GetObjectByTag("elaith");
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGICAL_VISION), oIdentifier);
        TurnToFaceObject(GetItemPossessor(oItem), oIdentifier);
    }
    else if (sTag == "mer_haljal")
    {
        object oIdentifier = GetObjectByTag("haljal");
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGICAL_VISION), oIdentifier);
        TurnToFaceObject(GetItemPossessor(oItem), oIdentifier);
    }
    else if (sTag == "mer_henchman")
    {
        object oIdentifier = GetObjectByTag("hen_sharwyn");
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGICAL_VISION), oIdentifier);
        TurnToFaceObject(GetItemPossessor(oItem), oIdentifier);
    }
}

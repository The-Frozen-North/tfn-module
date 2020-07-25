#include "nwnx_events"
#include "nwnx_object"
#include "x0_i0_position"

void main()
{
    object oItem = NWNX_Object_StringToObject(NWNX_Events_GetEventData("ITEM"));

    object oIdentifier = GetObjectByTag("eltoora");
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGICAL_VISION), oIdentifier);
    TurnToFaceObject(GetItemPossessor(oItem), oIdentifier);
}

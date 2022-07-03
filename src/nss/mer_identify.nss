#include "nwnx_events"
#include "x0_i0_position"
#include "inc_webhook"

void main()
{
    object oItem = StringToObject(NWNX_Events_GetEventData("ITEM"));

    object oIdentifier = GetObjectByTag("eltoora");
    // Eltoora was probably the only identifying merchant once upon a time, but
    // that isn't the case any more
    if (GetArea(OBJECT_SELF) == oIdentifier)
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGICAL_VISION), oIdentifier);
        TurnToFaceObject(GetItemPossessor(oItem), oIdentifier);
    }
}

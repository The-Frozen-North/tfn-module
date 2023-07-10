#include "nwnx_events"
#include "x0_i0_position"
#include "inc_webhook"

void main()
{
    object oItem = StringToObject(NWNX_Events_GetEventData("ITEM"));
    string sTag = GetTag(OBJECT_SELF);

    object oIdentifier = OBJECT_INVALID;
    if (sTag == "mer_eltoora")
    {
        oIdentifier = GetObjectByTag("eltoora");
    }
    else if (sTag == "mer_camilla")
    {
        oIdentifier = GetObjectByTag("camilla");
    }
    else if (sTag == "mer_arto")
    {
        oIdentifier = GetObjectByTag("arto");
    }
    else if (sTag == "mer_gulhrys")
    {
        oIdentifier = GetObjectByTag("gulhrys");
    }
    else if (sTag == "mer_elaith")
    {
        oIdentifier = GetObjectByTag("elaith");
    }
    else if (sTag == "mer_haljal")
    {
        oIdentifier = GetObjectByTag("haljal");
    }
    else if (sTag == "mer_henchman")
    {
        oIdentifier = GetObjectByTag("hen_sharwyn");
    }
    if (GetIsObjectValid(oIdentifier))
    {
        ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_MAGICAL_VISION), oIdentifier);
        TurnToFaceObject(GetItemPossessor(oItem), oIdentifier);
    }
    ValuableItemWebhook(OBJECT_SELF, oItem, FALSE);
}

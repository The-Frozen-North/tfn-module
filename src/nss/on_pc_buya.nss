#include "nwnx_events"
#include "inc_webhook"

void main()
{
    int nResult = StringToInt(NWNX_Events_GetEventData("RESULT"));
    if (nResult)
    {
        if (GetIsPC(OBJECT_SELF))
        {
            object oItem = StringToObject(NWNX_Events_GetEventData("ITEM"));
            ValuableItemWebhook(OBJECT_SELF, oItem, TRUE);
        }
    }
}

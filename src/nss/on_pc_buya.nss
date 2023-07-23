#include "nwnx_events"
#include "inc_webhook"
#include "inc_general"

void main()
{
    int nResult = StringToInt(NWNX_Events_GetEventData("RESULT"));
    if (nResult)
    {
        if (GetIsPC(OBJECT_SELF))
        {
            object oItem = StringToObject(NWNX_Events_GetEventData("ITEM"));

            IncrementPlayerStatistic(OBJECT_SELF, "gold_spent_from_buying", StringToInt(NWNX_Events_GetEventData("PRICE")));
            IncrementPlayerStatistic(OBJECT_SELF, "items_bought");

            ValuableItemWebhook(OBJECT_SELF, oItem, TRUE);
        }
    }
}

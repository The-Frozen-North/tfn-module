#include "inc_general"

void main()
{
    if (GetIsPC(OBJECT_SELF))
    {
        int nOldMax = GetPlayerStatistic(OBJECT_SELF, "most_gold_carried");
        if (GetGold(OBJECT_SELF) > nOldMax)
        {
            SetPlayerStatistic(OBJECT_SELF, "most_gold_carried", GetGold(OBJECT_SELF));
        }
    }
}
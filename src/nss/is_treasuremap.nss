#include "inc_treasuremap"
#include "inc_itemevent"

void main()
{
    if (GetCurrentItemEventType() == ITEM_EVENT_ACTIVATED)
    {
        object oMap = GetSpellCastItem();   
        UseTreasureMap(oMap);
    }
}

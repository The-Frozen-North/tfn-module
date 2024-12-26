#include "inc_treasuremap"
#include "inc_loot"
#include "inc_itemevent"

void main()
{
    
    //_TreasureMapDrawCurrentLocation();
    WriteTimestampedLogEntry(JsonDump(GetItemPropertiesAsText(GetItemInSlot(INVENTORY_SLOT_CHEST))));
    
}
#include "nwnx_events"
#include "inc_debug"
#include "inc_general"

void main()
{
    object oStore = StringToObject(NWNX_Events_GetEventData("STORE"));
    SendDebugMessage("store: "+GetTag(oStore));
    string sString = GetLocalString(oStore, "target_pawnshop");
    SendDebugMessage("target pawnshop: "+sString);
    object oTargetPawnStore = GetObjectByTag(sString);
    if (StringToInt(NWNX_Events_GetEventData("RESULT")) == TRUE)
    {
        IncrementPlayerStatistic(OBJECT_SELF, "gold_earned_from_selling", StringToInt(NWNX_Events_GetEventData("PRICE")));
        IncrementPlayerStatistic(OBJECT_SELF, "items_sold");
        
        if (GetIsObjectValid(oTargetPawnStore))
        {
            SendDebugMessage("item sold");
            object oItem = StringToObject(NWNX_Events_GetEventData("ITEM"));
            CopyItem(oItem, oTargetPawnStore, TRUE);
            DestroyObject(oItem);
        }
    }
}

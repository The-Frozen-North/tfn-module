#include "nwnx_events"
#include "nwnx_object"
#include "inc_nwnx"

void main()
{
    object oTarget = NWNX_Object_StringToObject(NWNX_Events_GetEventData("BARTER_TARGET"));
    object oInitiator = OBJECT_SELF;

    object oDM;
    if (GetIsDM(oInitiator))
    {
        oDM = oInitiator;
    }
    else if (GetIsDM(oTarget))
    {
        oDM = oTarget;
    }

// only proceed if a DM exists in the transaction
    if (!GetIsObjectValid(oDM))
        return;

// Only log complete barters
    if (StringToInt(NWNX_Events_GetEventData("BARTER_COMPLETE")))
    {
// count up to 32 items, to be extra safe.
// according to the GUI, there is a maximum of 32 items
        int i;
        object oTargetItem, oInitiatorItem;
        string sTargetItems, sInitiatorItems;
        for (i = 0; i < 32; i++)
        {
            oInitiatorItem = NWNX_Object_StringToObject(NWNX_Events_GetEventData("BARTER_INITIATOR_ITEM"+IntToString(i)));
            if (GetIsObjectValid(oInitiatorItem))
            {
                sInitiatorItems = sInitiatorItems + IntToString(GetItemStackSize(oInitiatorItem))+"x "+GetName(oInitiatorItem)+" ";
            }

            oTargetItem = NWNX_Object_StringToObject(NWNX_Events_GetEventData("BARTER_TARGET_ITEM"+IntToString(i)));
            if (GetIsObjectValid(oTargetItem))
            {
                sTargetItems = sTargetItems + IntToString(GetItemStackSize(oTargetItem))+"x "+GetName(oTargetItem)+" ";
            }
        }

        if (sTargetItems == "")
            sTargetItems = "no items";

        if (sInitiatorItems == "")
            sInitiatorItems = "no items";

        string sMessage = "DM: "+GetName(oInitiator)+" has traded the following items to "+GetName(oTarget)+": "+sInitiatorItems+" in return for the following items: "+sTargetItems;

        WriteTimestampedLogEntry(sMessage);
        SendDiscordLogMessage(sMessage);
    }
}

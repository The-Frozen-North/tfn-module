#include "inc_housing"
#include "inc_itemupdate"

void main()
{
    object oPC = GetEnteringObject();

    if (GetIsPC(oPC))
    {
        ExploreAreaForPlayer(OBJECT_SELF, oPC);

        if (GetHomeTag(oPC) == GetTag(OBJECT_SELF))
        {
            object oObject = GetFirstObjectInArea(OBJECT_SELF);

            string sCDKey = GetPCPublicCDKey(oPC);

            vector vObject;
            string sResRef, sStorageTag;
            object oStorage;
            location lObject;
            
            json jItemQueue = JsonArray();
            int bUpdateStorage = DoesPCsHouseItemsNeedAnUpdateCheck(oPC);

            while (GetIsObjectValid(oObject))
            {
                if (GetObjectType(oObject) == OBJECT_TYPE_PLACEABLE)
                {
                    sResRef = GetResRef(oObject);

                    if (GetStringLeft(sResRef, 7) == "storage")
                    {
                        vector vObject = GetPosition(oObject);
                        sStorageTag = sCDKey+"_"+sResRef;

                        lObject = Location(OBJECT_SELF, Vector(vObject.x, vObject.y, -500.0), GetFacing(oObject));

// let's see if the PC storage already exists in the server
                        oStorage = GetObjectByTag(sStorageTag);

// doesn't exist? let's bring one from the DB then
                        if (!GetIsObjectValid(oStorage))
                            oStorage = RetrieveCampaignObject(sCDKey, sStorageTag, lObject);

// still doesn't exist? then let's create one
                        if (!GetIsObjectValid(oStorage))
                            oStorage = CreateObject(OBJECT_TYPE_PLACEABLE, "_pc_storage", lObject, FALSE, sStorageTag);
                        
                        if (bUpdateStorage)
                        {
                            WriteTimestampedLogEntry("Queue container for item update: " + GetName(oStorage));
                            jItemQueue = AddInventoryItemsToItemUpdateQueue(oStorage, jItemQueue);
                        }

                        AssignCommand(oStorage, ActionJumpToLocation(lObject));

                        SetLockKeyRequired(oStorage, TRUE);
                        SetPortraitResRef(oStorage, GetPortraitResRef(oObject));
                        SetName(oStorage, GetName(oObject));
                    }
                }

                oObject = GetNextObjectInArea(OBJECT_SELF);
            }
            //if (DoesPCsHouseItemsNeedAnUpdateCheck(oPC))
            if (bUpdateStorage)
            {
                json jUpdateData = JsonObject();
                ProcessItemUpdateQueue(jItemQueue, jUpdateData, oPC, 1, ITEM_UPDATE_QUEUE_REPORT_CDKEY_DB);
            }
        }
    }
}

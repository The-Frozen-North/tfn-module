// Deals specifically with updating existing items
// to new versions with changed properties etc
#include "inc_treasure"
#include "inc_debug"
#include "util_i_itemprop"
#include "nw_inc_nui"

// Get the hash of an item's itemproperties
// (and several other things intrinsic to the item, such as additional gold cost).
// Does NOT include appearance, as PCs might have customised that
// if bForce == 0, it will just load the last known one
// after editing an item, this needs to be called with bForce = 1
int GetItemPropertiesHash(object oItem, int bForce=0);

struct ItemPropertyUpdateInfo
{
    json jOldProps; // Json array of item property strings on the original item
    json jNewProps; // Json array of item property strings on the new item
    int nUpdateFlags; // ITEM_UPDATE_* flags
};

const int ITEM_UPDATE_ITEMPROPERTIES = 1;
const int ITEM_UPDATE_ADDITIONALGOLDCOST = 2;

// Update oItem to its "newer" form.
// Returns a Json object saying what was updated.
struct ItemPropertyUpdateInfo UpdateItemProperties(object oItem);

// Returns the gold cost of oItem after identification.
// Retains the original identified state of the item.
int GetIdentifiedGoldCost(object oItem);

// Update all of oPC's items they have equipped and in inventory.
// this does NOT check their house.
// if bDisplayNUI a UI pops up when done that lists which items were changed.
// The actual updating is staggered slightly due to potential server load issues, the UI appearing will be delayed.
void UpdatePCOwnedItemProperties(object oPC, int bDisplayNUI=1);

// Build a queue of items to update, then process it with a slight delay.
// And maybe show a PC a NUI saying what got updated at the end.
json AddInventoryItemsToItemUpdateQueue(object oInventory, json jQueue);
json AddEquippedItemsToItemUpdateQueue(object oCreature, json jQueue);
// nVarReportType sets a variable when the queue is done.
// ITEM_UPDATE_QUEUE_REPORT_NONE does nothing
// ITEM_UPDATE_QUEUE_REPORT_PC_BIC writes a value in the PC's BIC sqlite db to mark their owned items as done
// ITEM_UPDATE_QUEUE_REPORT_CDKEY_DB writes a value in the PC's cdkey db to mark their house's items as done
void ProcessItemUpdateQueue(json jQueue, json jUpdateData, object oPCToShowNUI=OBJECT_INVALID, int bDisplayNUI=1, int nVarReportType=0, int nArrayPosition=0);

// Whether or not a PC's carried and equipped items need an update check
int DoesPCsItemsNeedAnUpdateCheck(object oPC);
// Whether or not a PC's house items need an update check
int DoesPCsHouseItemsNeedAnUpdateCheck(object oPC);


const int ITEM_UPDATE_QUEUE_REPORT_NONE = 0;
const int ITEM_UPDATE_QUEUE_REPORT_PC_BIC = 1;
const int ITEM_UPDATE_QUEUE_REPORT_CDKEY_DB = 2;



int GetItemPropertiesHash(object oItem, int bForce=0)
{
    int nRet = GetLocalInt(oItem, "properties_hash");
    if (nRet == 0 || bForce)
    {
        json jItem = ObjectToJson(oItem);
        // Note: temporary itemproperties seem to live in EffectList, not PropertiesList
        // so this SHOULD be safe for people walking home with Darkfired weapons or whatever
        json jProperties = JsonPointer(jItem, "/PropertiesList");
        // Manually add keys for everything else that needs to go into the hash
        jProperties = JsonObjectSet(jProperties, "_AdditionalGold", JsonInt(NWNX_Item_GetAddGoldPieceValue(oItem)));
        nRet = NWNX_Util_Hash(JsonDump(jProperties));
    }
    return nRet;
}

void VoidGetItemPropertiesHash(object oItem, int bForce=1)
{
    GetItemPropertiesHash(oItem, bForce);
}

int GetIdentifiedGoldCost(object oItem)
{
    int bIdentified = GetIdentified(oItem);
    SetIdentified(oItem, 1);
    int nRet = GetGoldPieceValue(oItem);
    SetIdentified(oItem, bIdentified);
    return nRet;
}

struct ItemPropertyUpdateInfo UpdateItemProperties(object oItem)
{
    struct ItemPropertyUpdateInfo sRet;
    object oTreasureStorage = GetTFNEquipmentByName(oItem);
    if (!GetIsObjectValid(oTreasureStorage))
    {
        return sRet;
    }

    int nGoldValue = GetIdentifiedGoldCost(oItem);

    // do nothing if we made an oopsie and there happens to be a an item that is greater than 22000 gold. theoretically, this should never happen as we filter out items that are greater than 22000 gold when seeding.
    if (nGoldValue > MAX_VALUE)
    {
        return sRet;
    }

    int nThisHash = GetItemPropertiesHash(oItem);
    int nTreasureHash = GetItemPropertiesHash(oTreasureStorage);
    if (nThisHash != nTreasureHash)
    {
        int nNewGold = NWNX_Item_GetAddGoldPieceValue(oTreasureStorage);
        if (nNewGold != NWNX_Item_GetAddGoldPieceValue(oItem))
        {
            NWNX_Item_SetAddGoldPieceValue(oItem, nNewGold);
            sRet.nUpdateFlags |= ITEM_UPDATE_ADDITIONALGOLDCOST;
            // If gold price doesn't match at this point, we can instantly know that
            // something itemproperty related has been changed
            // Or we can force it to hash again, so now it should only have the itemprop list to compare.
            nThisHash = GetItemPropertiesHash(oItem, 1);
            if (nGoldValue != GetIdentifiedGoldCost(oTreasureStorage) || nThisHash != nTreasureHash)
            {
                sRet.nUpdateFlags |= ITEM_UPDATE_ITEMPROPERTIES;
            }
        }
        else
        {
            // Then the hash change must be itemprops!
            sRet.nUpdateFlags |= ITEM_UPDATE_ITEMPROPERTIES;
        }
        
        // This could go in the if block for gold cost difference
        // but for safety's sake I don't know if I trust it
        sRet.jOldProps = JsonArray();
        sRet.jNewProps = JsonArray();
        
        itemproperty ipTest = GetFirstItemProperty(oItem);
        while (GetIsItemPropertyValid(ipTest))
        {
            RemoveItemProperty(oItem, ipTest);
            sRet.jOldProps = JsonArrayInsert(sRet.jOldProps, JsonString(ItemPropertyToString(ipTest)));
            ipTest = GetNextItemProperty(oItem);
        }
        
        ipTest = GetFirstItemProperty(oTreasureStorage);
        while (GetIsItemPropertyValid(ipTest))
        {
            AddItemProperty(DURATION_TYPE_PERMANENT, ipTest, oItem);
            sRet.jNewProps = JsonArrayInsert(sRet.jNewProps, JsonString(ItemPropertyToString(ipTest)));
            ipTest = GetNextItemProperty(oTreasureStorage);
        }
        // Force update the saved hash
        DelayCommand(0.01, VoidGetItemPropertiesHash(oItem, 1));
        SendDebugMessage("Update item: " + GetName(oItem) + " -> flags = " + IntToString(sRet.nUpdateFlags), TRUE);
    }
    return sRet;
}

// Keep an object recording what was changed on which item, and do the updating and add to the json object
json _UpdateItemPropertiesToJson(json jData, object oItem)
{
    struct ItemPropertyUpdateInfo sUpdate = UpdateItemProperties(oItem);
    // If no update flags, there's no need to report anything as changed
    // or it's just adding stuff to the json object for no good reason
    if (sUpdate.nUpdateFlags == 0)
    {
        return jData;
    }

    // do not report anything as changed if the item properties are the same. Sort the array because we don't care about order
    if (JsonArrayTransform(sUpdate.jOldProps, JSON_ARRAY_SORT_ASCENDING) == JsonArrayTransform(sUpdate.jNewProps, JSON_ARRAY_SORT_ASCENDING))
    {
        return jData;
    }

    json jValue = JsonObject();
    jValue = JsonObjectSet(jValue, "flags", JsonInt(sUpdate.nUpdateFlags));
    jValue = JsonObjectSet(jValue, "oldprops", sUpdate.jOldProps);
    jValue = JsonObjectSet(jValue, "newprops", sUpdate.jNewProps);
    jValue = JsonObjectSet(jValue, "identified", JsonInt(GetIdentified(oItem)));
    string sName = GetName(oItem);
    if (!GetIdentified(oItem))
    {
        sName = GetStringByStrRef(StringToInt(Get2DAString("baseitems", "Name", GetBaseItemType(oItem)))) + " (unidentified)";
    }
    jValue = JsonObjectSet(jValue, "name", JsonString(sName));
    jData = JsonObjectSet(jData, ObjectToString(oItem), jValue);
    return jData;
}

// This is a little more involved than it might otherwise be
// because it seems sensible to delay checking each item slightly to avoid a single server hit of massive iterations
// So what we actually do is build a queue of items to process
// then do each one individually, save the result, then display the results

json AddInventoryItemsToItemUpdateQueue(object oInventory, json jQueue)
{
    object oTest = GetFirstItemInInventory(oInventory);
    while (GetIsObjectValid(oTest))
    {
        jQueue = JsonArrayInsert(jQueue, JsonString(ObjectToString(oTest)));
        oTest = GetNextItemInInventory(oInventory);
    }
    return jQueue;
}

// Deliberately skipping creature items here.
json AddEquippedItemsToItemUpdateQueue(object oCreature, json jQueue)
{
    int nSlot;
    for (nSlot=0; nSlot<INVENTORY_SLOT_CWEAPON_L; nSlot++)
    {
        jQueue = JsonArrayInsert(jQueue, JsonString(ObjectToString(GetItemInSlot(nSlot, oCreature))));
    }
    return jQueue;
}

void DisplayUpdatedItemNUI(json jUpdateData, object oPC)
{
    if (!GetIsObjectValid(oPC) || !GetIsPC(oPC))
    {
        WriteTimestampedLogEntry("DisplayUpdatedItemNUI: passed PC isn't a PC or has logged out...");
        return;
    }
    //WriteTimestampedLogEntry(JsonDump(jUpdateData));
    json jKeys = JsonObjectKeys(jUpdateData);
    int nNumKeys = JsonGetLength(jKeys);
    WriteTimestampedLogEntry("DisplayUpdatedItemNUI passed json data with " + IntToString(nNumKeys) + " keys");
    int nNumRows = 0;
    json jLayout = JsonArray();
    //json jLabel = NuiLabel(JsonString("Strangely, the magic properties of some of your items have changed..."), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_MIDDLE));
    json jLabel = NuiText(JsonString("Strangely, the magic properties of some of your items have changed..."), FALSE, NUI_SCROLLBARS_NONE);
    jLabel = NuiWidth(jLabel, 350.0);
    jLabel = NuiHeight(jLabel, 40.0);
    json jLabelRow = JsonArray();
    jLabelRow = JsonArrayInsert(jLabelRow, jLabel);
    jLayout = JsonArrayInsert(jLayout, NuiRow(jLabelRow));
    
    json jGroupRows = JsonArray();
    int i;
    float fReqHeight = 18.0;
    for (i=0; i<nNumKeys; i++)
    {
        string sKey = JsonGetString(JsonArrayGet(jKeys, i));
        json jItemRecord = JsonObjectGet(jUpdateData, sKey);
        int nFlags = JsonGetInt(JsonObjectGet(jItemRecord, "flags"));
        // For now, no reporting items that only had additional gold changed. 
        // only those whose itemprops changed
        if (nFlags & ITEM_UPDATE_ITEMPROPERTIES)
        {
            json jThisRow = JsonArray();
            json jNameLabel = NuiLabel(JsonObjectGet(jItemRecord, "name"), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_MIDDLE));
            jNameLabel = NuiWidth(jNameLabel, 270.0);
            jNameLabel = NuiHeight(jNameLabel, 35.0);
            jThisRow = JsonArrayInsert(jThisRow, jNameLabel);
            if (JsonGetInt(JsonObjectGet(jItemRecord, "identified")))
            {
                json jInspect = NuiButtonImage(JsonString("ir_examine"));
                jInspect = NuiHeight(jInspect, 35.0);
                jInspect = NuiWidth(jInspect, 35.0);
                jInspect = NuiId(jInspect, "inspect_" + sKey);
                jThisRow = JsonArrayInsert(jThisRow, jInspect);
            }
            jGroupRows = JsonArrayInsert(jGroupRows, NuiRow(jThisRow));
            fReqHeight += 41.0;
            nNumRows++;
        }
        else
        {
            //WriteTimestampedLogEntry("flags for " + JsonGetString(JsonObjectGet(jItemRecord, "name")) + " = " + IntToString(nFlags));
        }
    }
    // If no rows, don't make a UI show up
    if (nNumRows == 0)
    {
        WriteTimestampedLogEntry("DisplayUpdatedItemNUI: no item property updated rows to report");
        return;
    }
    if (fReqHeight > 300.0)
    {
        fReqHeight = 300.0;
    }
    json jContentGroup = NuiGroup(NuiCol(jGroupRows));
    jContentGroup = NuiWidth(jContentGroup, 350.0);
    jContentGroup = NuiHeight(jContentGroup, fReqHeight);
    json jContentRow = JsonArray();
    jContentRow = JsonArrayInsert(jContentRow, jContentGroup);
    
    jLayout = JsonArrayInsert(jLayout, NuiRow(jContentRow));
    json jWindow = NuiWindow(NuiCol(jLayout), JsonString("Item Changes"), NuiRect(-1.0, -1.0, 400.0, fReqHeight + 140.0), JsonBool(TRUE), JsonBool(FALSE), JsonBool(TRUE), JsonBool(FALSE), JsonBool(TRUE));
    int nToken = NuiCreate(oPC, jWindow, "itemchanges");
    NuiSetUserData(oPC, nToken, jUpdateData);
}

void ProcessItemUpdateQueue(json jQueue, json jUpdateData, object oPCToShowNUI=OBJECT_INVALID, int bDisplayNUI=1, int nVarReportType=0, int nArrayPosition=0)
{
    if (JsonGetLength(jQueue) <= nArrayPosition)
    {
        WriteTimestampedLogEntry("Finished processing item update queue. PC = " + GetName(oPCToShowNUI) + ", show ui = " + IntToString(bDisplayNUI));
        if (GetIsObjectValid(oPCToShowNUI))
        {
            if (bDisplayNUI)
            {
                DisplayUpdatedItemNUI(jUpdateData, oPCToShowNUI);
            }
            if (nVarReportType == ITEM_UPDATE_QUEUE_REPORT_PC_BIC)
            {
                SQLocalsPlayer_SetInt(oPCToShowNUI, "item_revision", GetCampaignInt("treasures", "fingerprint_time"));
            }
            else if (nVarReportType == ITEM_UPDATE_QUEUE_REPORT_CDKEY_DB)
            {
                string sKey = GetPCPublicCDKey(oPCToShowNUI, TRUE);
                SetCampaignInt(sKey, "house_item_revision", GetCampaignInt("treasures", "fingerprint_time"));
            }
        }
        return;
    }
    object oItem = StringToObject(JsonGetString(JsonArrayGet(jQueue, nArrayPosition)));
    if (GetIsObjectValid(oItem))
    {
        jUpdateData = _UpdateItemPropertiesToJson(jUpdateData, oItem);
    }
    DelayCommand(0.03, ProcessItemUpdateQueue(jQueue, jUpdateData, oPCToShowNUI, bDisplayNUI, nVarReportType, nArrayPosition+1));
}

// Update all of oPC's items they have equipped and in inventory.
// this does NOT check their house.
// if bDisplayNUI a UI pops up when done that lists which items were changed.
// The actual updating is staggered slightly due to potential server load issues, the UI appearing will be delayed.
void UpdatePCOwnedItemProperties(object oPC, int bDisplayNUI=1)
{
    if (!GetIsObjectValid(oPC))
    {
        return;
    }
    if (!GetIsObjectValid(GetArea(oPC)))
    {
        DelayCommand(1.0, UpdatePCOwnedItemProperties(oPC, bDisplayNUI));
        return;
    }
    if (!DoesPCsItemsNeedAnUpdateCheck(oPC))
    {
        return;
    }
    json jData = JsonArray();
    jData = AddEquippedItemsToItemUpdateQueue(oPC, jData);
    jData = AddInventoryItemsToItemUpdateQueue(oPC, jData);
    json jUpdateData = JsonObject();
    ProcessItemUpdateQueue(jData, jUpdateData, oPC, bDisplayNUI, ITEM_UPDATE_QUEUE_REPORT_PC_BIC);
}

int DoesPCsItemsNeedAnUpdateCheck(object oPC)
{
    if (SQLocalsPlayer_GetInt(oPC, "item_revision") != GetCampaignInt("treasures", "fingerprint_time"))
    {
        WriteTimestampedLogEntry("Need to update " + GetName(oPC) + "'s items");
        return 1;
    }
    WriteTimestampedLogEntry("Items of " + GetName(oPC) + " are already up to date!");
    return 0;
}

int DoesPCsHouseItemsNeedAnUpdateCheck(object oPC)
{
    string sKey = GetPCPublicCDKey(oPC, TRUE);
    if (GetCampaignInt(sKey, "house_item_revision") != GetCampaignInt("treasures", "fingerprint_time"))
    {
        WriteTimestampedLogEntry("Need to update " + GetName(oPC) + "'s house items");
        return 1;
    }
    WriteTimestampedLogEntry("Items in " + GetName(oPC) + "'s house are already up to date!");
    return 0;
}

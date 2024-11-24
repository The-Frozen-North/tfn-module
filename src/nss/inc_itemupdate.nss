// Deals specifically with updating existing items
// to new versions with changed properties etc
#include "inc_treasure"
#include "inc_debug"
#include "nw_inc_nui"
#include "x3_inc_string"

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

// Flags for what was updated.
// This is only triggered if visible item property text changes. Any invisible changes will go unmentioned.
const int ITEM_UPDATE_ITEMPROPERTIES = 1;
const int ITEM_UPDATE_ADDITIONALGOLDCOST = 2;
const int ITEM_UPDATE_TAG = 4;

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

// the new 2da changes has made ammo very, very expensive. in order to deprecate the ammo, we will need to divide their total cost by this amount
// for example, a stack of +3 darts is 1009200. after dividing it by 10000 we will get 126.15, so in that case we will give the player back 100 gold.
// it's a little more generous than it should be
const int ITEM_UPDATE_AMMO_DIVISION_FACTOR = 17000; 
const int ITEM_UPDATE_THROWING_WEAPON_DIVISION_FACTOR = 10000; 

// we should definitely cap this if the numbers happen to be off
const int ITEM_UPDATE_AMMO_MAX_GOLD_REFUND = 100;

const int ITEM_UPDATE_FABRICATOR_MAX_GOLD_REFUND = 4000;

// just handles throwing weapons, fabricators, and ammo for now
// returns TRUE if an item was destroyed by this deprecation
int DeprecateItem(object oItem, object oPC)
{   

    // there was a bug where crafted ammo was never cleaned up for some reason, do it immediately
    int nBaseItemType = GetBaseItemType(oItem);
    if (GetTag(oItem) == "crafted_ammo")
    {
        
        //int nDivider = ITEM_UPDATE_THROWING_WEAPON_DIVISION_FACTOR;

        //if (nBaseItemType == BASE_ITEM_ARROW || nBaseItemType == BASE_ITEM_BOLT || nBaseItemType == BASE_ITEM_BULLET)
       // {
        //    int nDivider = ITEM_UPDATE_AMMO_DIVISION_FACTOR;    
        //}

        //int nRefund = GetGoldPieceValue(oItem) / nDivider;

        //if (nRefund > ITEM_UPDATE_AMMO_MAX_GOLD_REFUND) nRefund = ITEM_UPDATE_AMMO_MAX_GOLD_REFUND;

        SendColorMessageToPC(oPC, GetName(oItem) + " was deprecated", MESSAGE_COLOR_DANGER);//, refunded: "+IntToString(nRefund), MESSAGE_COLOR_DANGER);

        DestroyObject(oItem);

        //GiveGoldToCreature(oPC, nRefund);

        return TRUE;
    }    
    
    if (nBaseItemType == BASE_ITEM_ARROW || nBaseItemType == BASE_ITEM_BOLT || nBaseItemType == BASE_ITEM_BULLET || nBaseItemType == BASE_ITEM_THROWINGAXE || nBaseItemType == BASE_ITEM_SHURIKEN || nBaseItemType == BASE_ITEM_DART)
    {
        if (!IsAmmoInfinite(oItem))
            return FALSE; // do nothing if it has no properties. even the fabricator has properties

        if (GetLocalInt(oItem, "infinite") == 1)
            return FALSE; // if already deemed infinite, do not do anything to this item
    }

    // check if it is a new PC, otherwise this can be exploited by players coming in with custom items and a hacked character
    if (GetXP(oPC) < 1)
        return FALSE;

    if (GetXP(oPC) > 1 && GetTag(oItem) == "ammo_maker" && nBaseItemType == BASE_ITEM_MISCLARGE)
    {
        SetIdentified(oItem, TRUE);
        // unfortunately we have removed the fabricator chest so this will be very hard to do. we only stored the tag of the item

        // old ammo sample tag: ammo_Arrow1
        // even if we can get the tag, there's no guarantee it was set properly. the only thing we can do is attempt to find it through name...

        string sName = GetName(oItem);
        string sOriginalName = sName;

        int nBaseItem = -1;

        // we must compare with the exact name, there is a throwing axe called "Rhyte's Last Arrow" ><
        if (FindSubString(sName, "Arrow Fabricator") > -1)
        {
            nBaseItem = BASE_ITEM_ARROW;
        }
        else if (FindSubString(sName, "Bolt Fabricator") > -1)
        {
            nBaseItem = BASE_ITEM_BOLT;
        }
        else if (FindSubString(sName, "Throwing Axe Fabricator") > -1)
        {
            nBaseItem = BASE_ITEM_THROWINGAXE;
        }
        else if (FindSubString(sName, "Shuriken Fabricator") > -1)
        {
            nBaseItem = BASE_ITEM_SHURIKEN;
        }
        else if (FindSubString(sName, "Bullet Fabricator") > -1)
        {
            nBaseItem = BASE_ITEM_BULLET;
        }
        else if (FindSubString(sName, "Dart Fabricator") > -1)
        {
            nBaseItem = BASE_ITEM_DART;
        }

        //SendMessageToPC(GetFirstPC(), "Base item: "+IntToString(nBaseItem));
        
        // remove the last parantheses to make it easier later on, keep the first one so we can find use it to extract the name
        sName = StringReplace(sName, ")", "");
        int nNamePosition = FindSubString(sName, "(");

        // If we couldn't find a parantheses or the correct base item, this wasn't a valid item. Do nothing in this case
        if (nNamePosition == 0)
        {
            SendColorMessageToPC(oPC, sOriginalName + " was not a valid ammo maker due to an invalid name and was destroyed without refund.", MESSAGE_COLOR_DANGER);
            DestroyObject(oItem);
            return TRUE;
        }
        else if (nBaseItem == -1)
        {
            SendColorMessageToPC(oPC, sOriginalName + " was not a valid ammo maker due to an invalid item type and was destroyed without refund.", MESSAGE_COLOR_DANGER);
            DestroyObject(oItem);
            return TRUE;
        }


        sName = GetSubString(sName, nNamePosition + 1, 32);

        //SendMessageToPC(GetFirstPC(), "Extracted name: |"+sName+"|");

        object oTFN = GetTFNEquipmentFromName(sName, nBaseItem);

        int nRefund = GetGoldPieceValue(oItem) / 2;
        if (nRefund > ITEM_UPDATE_FABRICATOR_MAX_GOLD_REFUND) nRefund = ITEM_UPDATE_FABRICATOR_MAX_GOLD_REFUND;

        //SendMessageToPC(GetFirstPC(), "Found item: "+GetName(oTFN));

        if (!GetIsObjectValid(oTFN))
        {           
            SendColorMessageToPC(oPC, sOriginalName + " was deprecated but the item cannot be found, refunded: " + IntToString(nRefund), MESSAGE_COLOR_DANGER);
            DestroyObject(oItem);

            GiveGoldToCreature(oPC, nRefund);

            return TRUE;            
        }

        SendColorMessageToPC(oPC, sOriginalName + " was deprecated and replaced with the infinite item equivalent.", MESSAGE_COLOR_DANGER);
        DestroyObject(oItem);
        
        object oNewItem = CopyItem(oTFN, oPC, TRUE);
        InitializeItem(oNewItem);

        // just do them a favor and identify it for them at this point
        SetIdentified(oNewItem, TRUE);

        return TRUE;
    }
    else if (nBaseItemType == BASE_ITEM_ARROW || nBaseItemType == BASE_ITEM_BOLT || nBaseItemType == BASE_ITEM_BULLET || nBaseItemType == BASE_ITEM_THROWINGAXE || nBaseItemType == BASE_ITEM_SHURIKEN || nBaseItemType == BASE_ITEM_DART)
    { // for all arrows, bolts, and bullets, throwing weapons just destroy them all and give the player a refund
        SetIdentified(oItem, TRUE);

        if (GetItemHasItemProperty(oItem, ITEM_PROPERTY_BOOMERANG))
        {
            SetLocalInt(oItem, "infinite", 1); // set this boomerang item to infinite so it never goes through this process again
            return FALSE; // do nothing and let the script change the properties on this item if already infinite from before
        }
        /*
        int nDivider = ITEM_UPDATE_THROWING_WEAPON_DIVISION_FACTOR;

        if (nBaseItemType == BASE_ITEM_ARROW || nBaseItemType == BASE_ITEM_BOLT || nBaseItemType == BASE_ITEM_BULLET)
        {
            int nDivider = ITEM_UPDATE_AMMO_DIVISION_FACTOR;    
        }

        int nRefund = GetGoldPieceValue(oItem) / nDivider;

        if (nRefund > ITEM_UPDATE_AMMO_MAX_GOLD_REFUND) nRefund = ITEM_UPDATE_AMMO_MAX_GOLD_REFUND;
        */
        SendColorMessageToPC(oPC, GetName(oItem) + " was deprecated", MESSAGE_COLOR_DANGER);//, refunded: "+IntToString(nRefund), MESSAGE_COLOR_DANGER);

        DestroyObject(oItem);

        //GiveGoldToCreature(oPC, nRefund);

        return TRUE;
    }

    // no branches were hit
    return FALSE;
}

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
        jProperties = JsonObjectSet(jProperties, "_ItemTag", JsonString(GetTag(oItem)));
        
        // Remove UsesPerDay from the structure
        // This is actually the remaining number of uses per day
        // so if a PC logs out having used an item it will change its hash
        
        /*
        "value":[
            {
                "ChanceAppear":{"type":"byte","value":100},
                "CostTable":{"type":"byte","value":3},
                "CostValue":{"type":"word","value":9},
                "CustomTag":{"type":"cexostring","value":""},
                "Param1":{"type":"byte","value":255},
                "Param1Value":{"type":"byte","value":0},
                "PropertyName":{"type":"word","value":15},
                "Subtype":{"type":"word","value":33},
                "Useable":{"type":"byte","value":1},
                "UsesPerDay":{"type":"byte","value":2},
                "__struct_id":0
            }
            ,
            <another object like the above that represents the next property>
            ]        
        
        */
        
        json jValue = JsonObjectGet(jProperties, "value");
        int nNumItems = JsonGetLength(jValue);
        int i;
        //WriteTimestampedLogEntry("Item " + GetName(oItem) + " has " + JsonDump(jValue));
        json jNewValues = JsonArray();
        for (i=0; i<nNumItems; i++)
        {
            json jItemPropObj = JsonArrayGet(jValue, i);
            //WriteTimestampedLogEntry("Object " + IntToString(i) + " = " + JsonDump(jItemPropObj));
            json jItemPropModified = JsonObjectDel(jItemPropObj, "UsesPerDay");
            //WriteTimestampedLogEntry("Deleted usesperday " + JsonDump(jItemPropModified));
            jNewValues = JsonArrayInsert(jNewValues, jItemPropModified);
        }
        //WriteTimestampedLogEntry("New values " + JsonDump(jNewValues));
        jProperties = JsonObjectSet(jProperties, "value", jNewValues);
        //WriteTimestampedLogEntry("Item property dump: " + JsonDump(jProperties));
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

    int nThisHash = GetItemPropertiesHash(oItem);
    int nTreasureHash = GetItemPropertiesHash(oTreasureStorage);
    if (nThisHash != nTreasureHash)
    {
        int nNewGold = NWNX_Item_GetAddGoldPieceValue(oTreasureStorage);
        if (nNewGold != NWNX_Item_GetAddGoldPieceValue(oItem))
        {
            NWNX_Item_SetAddGoldPieceValue(oItem, nNewGold);
            sRet.nUpdateFlags |= ITEM_UPDATE_ADDITIONALGOLDCOST;
        }
                
        // This could go in the if block for gold cost difference
        // but for safety's sake I don't know if I trust it
        sRet.jOldProps = GetItemPropertiesAsText(oItem);
        sRet.jNewProps = GetItemPropertiesAsText(oTreasureStorage);
        
        if (JsonDump(sRet.jOldProps) != JsonDump(sRet.jNewProps))
        {
            // Be silent about changes that don't display a difference
            sRet.nUpdateFlags |= ITEM_UPDATE_ITEMPROPERTIES;
        }
        
        if (GetTag(oTreasureStorage) != GetTag(oItem))
        {
            sRet.nUpdateFlags |= ITEM_UPDATE_TAG;
            int bEquipped = 0;
            if (GetObjectType(GetItemPossessor(oItem)) == OBJECT_TYPE_CREATURE)
            {
                int nSlot;
                for (nSlot=0; nSlot<=INVENTORY_SLOT_HIGHEST; nSlot++)
                {
                    if (GetItemInSlot(nSlot, GetItemPossessor(oItem)) == oItem)
                    {
                        bEquipped = 1;
                        break;
                    }
                }
            }
            // Fire the unequip/equip scripts for the item?
            if (bEquipped)
                ItemEventCallEventOnItem(oItem, ITEM_EVENT_UNEQUIP, GetItemPossessor(oItem), TRUE);
            SetTag(oItem, GetTag(oTreasureStorage));
            if (bEquipped)
                ItemEventCallEventOnItem(oItem, ITEM_EVENT_EQUIP, GetItemPossessor(oItem), TRUE);
        }
        
        itemproperty ipTest = GetFirstItemProperty(oItem);
        while (GetIsItemPropertyValid(ipTest))
        {
            RemoveItemProperty(oItem, ipTest);
            ipTest = GetNextItemProperty(oItem);
        }
        
        ipTest = GetFirstItemProperty(oTreasureStorage);
        while (GetIsItemPropertyValid(ipTest))
        {
            AddItemProperty(DURATION_TYPE_PERMANENT, ipTest, oItem);
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

    // this will be an issue if the PC is invalid! Gold may not be refunded!
    // only do it if it is a PC, do not do it on the storage itself
    if (nVarReportType == ITEM_UPDATE_QUEUE_REPORT_PC_BIC)
    {
        DeprecateItem(oItem, oPCToShowNUI);
    }

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

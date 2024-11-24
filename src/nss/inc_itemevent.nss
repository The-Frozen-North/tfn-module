#include "nwnx_events"
#include "nwnx_effect"
#include "inc_debug"
#include "util_i_itemprop"

/*
General item event framework.

This is intended to make all of an item's functionality run through one script per item, despite the fact they might need to capture a whole variety of events.
These use the NWNX_Events data system (see NWNX_Events_GetEventData) to pass attributes around.
The same script file can ALSO be used for EffectRunScript with the help of GetLastRunScriptEffectScriptType.

When an item is equipped, its script (is_<tag>) is called with the event ITEM_EVENT_EQUIP.
When unequipped, it gets called with the event ITEM_EVENT_UNEQUIP.

All other events are not triggered unless specifically subscribed to via ItemEventSubscribe.
Extending subscriptions to ANY event raised by the NWNX_Events system - including all of the events the plugin provides - should be possible, but new events need adding to ItemEventsInitialise.
(And should be added to the list below)
This also means that appropriate events can have results changed or be skipped.

Once unequipped, the item's script won't get called for more events.

Polymorph notes:
When a creature polymorphs, it fires ITEM_EVENT_UNEQUIP for all its items, copies all the scripts over, and then fires ITEM_EVENT_EQUIP for the new creature items the effects got merged onto.
ITEM_EVENT_ACTIVATED is not copied for weapons whose properties are merged onto a hide.
When unpolymorphed, ITEM_EVENT_UNEQUIP is fired for the creature items, then ITEM_EVENT_EQUIP is fired for equipped items.

Because of this, a creature's hide POTENTIALLY SHARES EVENT SCRIPTS and any local variables used by scripts might overlap if not named carefully.

    
*/

// List of subscribable item events

// Equip event for THIS item only - when the item is equipped, this is called in the NWNX_ON_ITEM_EQUIP_AFTER of the item in question
// This is also called for each equipped item when logging in.
// When polymorphing, is called for merged items (eg creature hide).
// when unpolymorphing, is called for all items equipped on the creature.
// Is called after item version updates change an equipped item's tag.
// Does not require subscription. An item's script is always called for this by default.
// When using DURATION_TYPE_EQUIPPED in this slot, make sure to use SetEffectCreator to point the creator to the item.
// Parameters: as NWNX_ON_ITEM_EQUIP_AFTER, except for the special cases defined above (PC login, polymorphing, item updates). These cases will not have retrievable parameters.
const string ITEM_EVENT_EQUIP = "ITEM_EVENT_EQUIP";

// Unequip item for THIS item only - this is called in NWNX_ON_ITEM_UNEQUIP_BEFORE
// Called on items when they are merged for polymorph, and on polymorph merged items on unpolymorph.
// Is called immediately before item version updates change an equipped item's tag.
// Does not require subscription. An item's script is always called for this by default.
// May be skipped, except when polymorph/item version updates are involved.
// Parameters: as NWNX_ON_ITEM_UNEQUIP_BEFORE, except when polymorphing and due to item updates.
const string ITEM_EVENT_UNEQUIP = "ITEM_EVENT_UNEQUIP";

// Item activate script, for activations of unique power properties
// OBJECT_SELF = the owner of the item that was activated
// Does not require subscription. An item's script is always called for this by default.
const string ITEM_EVENT_ACTIVATED = "ITEM_EVENT_ACTIVATED";

// This event is triggered when the examine handler finds material properties on an object.
// It is a request to return an array of strings to display in place of the material properties in the examine info screen.
// Use ItemEventAddCustomPropertyText to add a response.
// Each Material property consumes one response.
// Does not require subscription. An item's script is always called for this by default.
// No parameters. OBJECT_SELF could be pretty much anything and should not be used in this event.
const string ITEM_EVENT_CUSTOM_PROPERTIES = "ITEM_EVENT_CUSTOM_PROPERTIES";

// Hookable for when the creature wearing the item is damaged.
// Parameters: None. Use NWNX_Damage_GetDamageEventData to retrieve them.
// OBJECT_SELF = the wearer
// NWNX_Damage_SetDamageEventData can probably also be used.
const string ITEM_EVENT_WEARER_DAMAGED = "ITEM_EVENT_WEARER_DAMAGED";

// Hookable for when the creature wearing the item damages something else.
// Parameters: None. Use NWNX_Damage_GetDamageEventData to retrieve them.
// OBJECT_SELF = the victim that they damaged
// NWNX_Damage_SetDamageEventData can probably also be used.
const string ITEM_EVENT_WEARER_DAMAGES = "ITEM_EVENT_WEARER_DAMAGES";

// Hookable for when the creature wearing the item is attacked.
// Parameters: None. Use NWNX_Damage_GetAttackEventData to retrieve them.
// OBJECT_SELF = the attacker
// NWNX_Damage_SetAttackEventData can probably also be used.
const string ITEM_EVENT_WEARER_ATTACKED = "ITEM_EVENT_WEARER_ATTACKED";

// Hookable for when the creature wearing the item damages something else.
// Parameters: None. Use NWNX_Damage_GetAttackEventData to retrieve them.
// OBJECT_SELF = the wearer
// NWNX_Damage_SetAttackEventData can probably also be used.
const string ITEM_EVENT_WEARER_ATTACKS = "ITEM_EVENT_WEARER_ATTACKS";


// Hookable event for equipping any OTHER item.
// Parameters: as NWNX_ON_ITEM_EQUIP_AFTER.
// Maybe useful for if you want an item to behave differently depending on whether the PC has certain kinds of weapons.
const string ITEM_EVENT_EQUIP_OTHER_AFTER = "ITEM_EVENT_EQUIP_AFTER"; 

const string ITEM_EVENT_START_COMBAT_ROUND_AFTER = "ITEM_EVENT_START_COMBAT_ROUND_AFTER";       // as NWNX_ON_START_COMBAT_ROUND_AFTER


////////////////////////////////
// General functions for usage in item scripts

// Returns the event name of the event currently running the event script.
// This is a ITEM_EVENT_* constant
string GetCurrentItemEventType();

// Return the object reference of the item that caused the event triggering the script to be run.
object GetCurrentItemEventItem();

// For use in item event scripts only.
// Subscribes the current item to the named event.
// Currently only one script is supported per event.
// If sScript is provided, specifies the script called by this event.
// Otherwise, the event will just call the currently running script.
void ItemEventSubscribe(string sEvent, string sScript="");

// Return the name of the script that the item event system thinks is currently running.
string GetCurrentItemEventScript();

// For use in ITEM_EVENT_CUSTOM_PROPERTIES only. 
// It is a request to return an array of strings to display in place of the material properties in the examine info screen.
// Add sText as one string to replace a Material item property on the item's examine window.
// Each Material property consumes one string added in this way.
void ItemEventAddCustomPropertyText(string sText);

//////////////////////////////////////
// Utility functions for item scripts

// Remove all temporary itemproperties on oItem tagged with sTag.
// If sTag is not set, will remove all properties tagged with the name of the currently running item event script instead.
void RemoveAllTaggedTemporaryItemProperties(object oItem, string sTag="");

// Remove all effects on oCreature tagged with sTag.
// If sTag is not set, will remove all properties tagged with the name of the currently running item event script instead.
void RemoveAllTaggedEffects(object oCreature, string sTag="");

// Returns a DAMAGE_TYPE_* constant for the last weapon used by oCreature, or 0 if nothing valid can be found.
// If the weapon can deal multiple damage types, returns one at random.
// This is useful for typing "base weapon" damage.
int GetDamageTypeOfLastUsedWeapon(object oCreature);

// Convert all of oItem's item properties to a JsonArray of strings, with each property taking one element.
// Handles Material property custom text replacement.
json GetItemPropertiesAsText(object oItem);


//////////////////////////////////////
// Functions that are probably for system usage only

// Run this on module load.
// This sets up the subscriptions for the event system itself - there is no way to map an event name to a creature taking part in the event except manually
// So that part has to be done by hand...
void ItemEventsInitialise();

// Return whether oCreature thinks it might have subscribers to sEvent.
// It might not actually (if it unequipped the last item doing them) but we can't know that without iterating over its slots.
int ItemEventDoesCreateHaveSubscribersToEvent(string sEvent, object oCreature);

// Call the handler of sEvent on oItem.
// Returns 1 if something was called, else 0.
// oExecuteScriptAs is passed as the second parameter to ExecuteScript.
// If bFallbackToDefaultScript, will default to "is_" + GetTag(oItem) if no script was set.
int ItemEventCallEventOnItem(object oItem, string sEvent, object oExecuteScriptAs=OBJECT_SELF, int bFallbackToDefaultScript=FALSE);

// Call all item subscribers of sEvent on oCreature.
// Checks with ItemEventDoesCreateHaveSubscribersToEvent first to make sure there are actual subscribers before doing anything.
// If no subscribers found, updates the marker.
// If oExcludeThisItem is passed, events won't be called for this item.
void ItemEventCallSubscribersForCreature(string sEvent, object oCreature, object oExcludeThisItem=OBJECT_SELF);

// Return an array of strings containing text for oItem's custom properties.
// These should be used to override Material item properties on the object.
json ItemEventGetCustomPropertyText(object oItem);

// Perform polymorph merging of oSource into oDest.
// If bIsWeapon, ITEM_EVENT_ACTIVATED is not merged onto oDest if it is a creature hide.
void ItemEventsPolymorphMerge(object oSource, object oDest, int bIsWeapon);

const string VAR_ITEM_EVENT_MARKER_STEM = "itm_evt_";
const int INVENTORY_SLOT_HIGHEST = INVENTORY_SLOT_CARMOUR;
const string VAR_ITEM_EVENT_RUNNING_SCRIPT = "VAR_ITEM_EVENT_RUNNING_SCRIPT";
const string VAR_ITEM_EVENT_RUNNING_EVENT = "VAR_ITEM_EVENT_RUNNING_EVENT";
const string VAR_ITEM_EVENT_CAUSING_ITEM = "VAR_ITEM_EVENT_CAUSING_ITEM";

// Set on polymorph merge targets to signal that this item has multiple scripts per event
// this is a json array of OIDs of the items merged onto it
const string VAR_ITEM_EVENT_COMBINED = "itm_event_combined";

// Set on polymorph merge targets to mark what the original item was when the script was called
// This is purely so that ItemEventSubscribe can know what the original item was...
const string VAR_ITEM_MERGED_ORIGINAL_ITEM = "itm_event_mergedorig";

// For combined targets: do not call the target script for an item with this variable+event+script set.
const string VAR_ITEM_IGNORE_STEM = "itm_evt_ignore_";

///////////////////////

int ItemEventDoesCreateHaveSubscribersToEvent(string sEvent, object oCreature)
{
    return GetLocalInt(oCreature, VAR_ITEM_EVENT_MARKER_STEM+sEvent);
}

void ItemEventCallEventScriptOnItem(object oItem, string sEvent, string sScript, object oExecuteScriptAs=OBJECT_SELF)
{
    object oModule = GetModule();
    SetLocalString(oModule, VAR_ITEM_EVENT_RUNNING_SCRIPT, sScript);
    SetLocalString(oModule, VAR_ITEM_EVENT_RUNNING_EVENT, sEvent);
    SetLocalObject(oModule, VAR_ITEM_EVENT_CAUSING_ITEM, oItem);
    ExecuteScript(sScript, oExecuteScriptAs);
}

string ItemEventGetScriptFromItem(object oItem, string sEvent, int bFallbackToDefaultScript)
{
    string sVar = VAR_ITEM_EVENT_MARKER_STEM+sEvent;
    string sScript = GetLocalString(oItem, sVar);
    if (sScript == "" && bFallbackToDefaultScript)
    {
        sScript = "is_" + GetTag(oItem);
    }
    return sScript;
}

void ItemEventsPolymorphMerge(object oSource, object oDest, int bIsWeapon)
{
    json jCombined = GetLocalJson(oDest, VAR_ITEM_EVENT_COMBINED);
    if (jCombined == JsonNull())
    {
        jCombined = JsonArray();
        SetLocalJson(oDest, VAR_ITEM_EVENT_COMBINED, jCombined);
    }
    JsonArrayInsertInplace(jCombined, JsonString(ObjectToString(oSource)));
    SendDebugMessage("Merge " + GetName(oSource) + " -> " + GetName(oDest));
    SetLocalObject(oDest, VAR_ITEM_MERGED_ORIGINAL_ITEM, oSource);
    ItemEventCallEventOnItem(oSource, ITEM_EVENT_UNEQUIP, OBJECT_SELF, TRUE);
    string sScript = ItemEventGetScriptFromItem(oSource, ITEM_EVENT_EQUIP, TRUE);
    ItemEventCallEventScriptOnItem(oDest, ITEM_EVENT_EQUIP, sScript);
    // Block item activate effects if copying from weapon to hide
    if (bIsWeapon && GetBaseItemType(oDest) == BASE_ITEM_CREATUREITEM)
    {
        SetLocalInt(oDest, VAR_ITEM_IGNORE_STEM + ITEM_EVENT_ACTIVATED + ObjectToString(oSource), 1);
    }
}

void CallEquipEventsForEquippedItems(object oPC)
{
    int nSlot;
    for (nSlot=0; nSlot<=INVENTORY_SLOT_HIGHEST; nSlot++)
    {
        object oItem = GetItemInSlot(nSlot, oPC);
        if (GetIsObjectValid(oItem))
        {
            ItemEventCallEventOnItem(oItem, ITEM_EVENT_EQUIP, GetItemPossessor(oItem), TRUE);
        }
    }
}

int ItemEventCallEventOnItem(object oItem, string sEvent, object oExecuteScriptAs=OBJECT_SELF, int bFallbackToDefaultScript=FALSE)
{
    if (!GetIsObjectValid(oItem))
        return 0;
    json jCombined = GetLocalJson(oItem, VAR_ITEM_EVENT_COMBINED);
    if (jCombined != JsonNull())
    {
        int nLength = JsonGetLength(jCombined);
        int i;
        int nNumExecuted = 0;
        for (i=0; i<nLength; i++)
        {
            object oRetrieved = StringToObject(JsonGetString(JsonArrayGet(jCombined, i)));
            SetLocalObject(oItem, VAR_ITEM_MERGED_ORIGINAL_ITEM, oRetrieved);
            string sScript = GetLocalString(oItem, VAR_ITEM_EVENT_MARKER_STEM+sEvent+ObjectToString(oRetrieved));
            if (sScript == "" && bFallbackToDefaultScript)
            {
                sScript = ItemEventGetScriptFromItem(oRetrieved, sEvent, bFallbackToDefaultScript);
            }
            if (sScript != "")
            {
                if (GetLocalInt(oItem, VAR_ITEM_IGNORE_STEM + sEvent + ObjectToString(oRetrieved)))
                {
                    continue;
                }
                SendDebugMessage("Call (merged) " + sScript + " for " + sEvent + " on " + GetName(oItem) + " from merged " + GetName(oRetrieved));
                ItemEventCallEventScriptOnItem(oItem, sEvent, sScript, oExecuteScriptAs);
                nNumExecuted++;
            }
        }
        return nNumExecuted;
    }
    string sScript = ItemEventGetScriptFromItem(oItem, sEvent, bFallbackToDefaultScript);
    if (sScript != "")
    {
        SendDebugMessage("Call " + sScript + " for " + GetName(oItem) + "'s " + sEvent);
        ItemEventCallEventScriptOnItem(oItem, sEvent, sScript, oExecuteScriptAs);
        return 1;
    }
    return 0;
}


void ItemEventCallSubscribersForCreature(string sEvent, object oCreature, object oExcludeThisItem=OBJECT_SELF)
{
    if (ItemEventDoesCreateHaveSubscribersToEvent(sEvent, oCreature))
    {
        int nNumEvents = 0;
        
        int nSlot;
        for (nSlot=0; nSlot<=INVENTORY_SLOT_HIGHEST; nSlot++)
        {
            object oItem = GetItemInSlot(nSlot, oCreature);
            if (GetIsObjectValid(oItem))
            {
                // If we are told to exclude a specific item, and this item is valid, do NOT remove the marker on the creature
                if (oItem == oExcludeThisItem)
                {
                    nNumEvents++;
                }
                else
                {
                    nNumEvents += ItemEventCallEventOnItem(oItem, sEvent);
                }
            }
        }
        
        if (nNumEvents == 0)
        {
            DeleteLocalInt(oCreature, VAR_ITEM_EVENT_MARKER_STEM+sEvent);
        }
    }
}


string GetCurrentItemEventType()
{
    return GetLocalString(GetModule(), VAR_ITEM_EVENT_RUNNING_EVENT);
}


object GetCurrentItemEventItem()
{
    return GetLocalObject(GetModule(), VAR_ITEM_EVENT_CAUSING_ITEM);
}


string GetCurrentItemEventScript()
{
    return GetLocalString(GetModule(), VAR_ITEM_EVENT_RUNNING_SCRIPT);
}

void ItemEventSubscribe(string sEvent, string sScript="")
{
    object oItem = GetCurrentItemEventItem();
    string sVar = VAR_ITEM_EVENT_MARKER_STEM+sEvent;
    if (sScript == "")
        sScript = GetCurrentItemEventScript();
    
    if (!GetLocalInt(GetModule(), "item_event_sub_" + sEvent))
    {
        WriteTimestampedLogEntry("ERROR: item script " + sScript + " is trying to subscribe to event " + sEvent + " but ItemEventsInitialise hasn't mapped this event, ignoring");
        return;
    }
    
    json jCombined = GetLocalJson(oItem, VAR_ITEM_EVENT_COMBINED);
    if (jCombined != JsonNull())
    {
        object oMergedOriginal = GetLocalObject(oItem, VAR_ITEM_MERGED_ORIGINAL_ITEM);
        SetLocalString(oItem, VAR_ITEM_EVENT_MARKER_STEM+sEvent+ObjectToString(oMergedOriginal), sScript);
    }
    else
    {
        SetLocalString(oItem, sVar, sScript);
    }
    SetLocalInt(GetItemPossessor(oItem), sVar, 1);
    SendDebugMessage("Subscribed " + GetName(GetItemPossessor(oItem)) + "'s " + GetName(oItem) + " to " + sEvent);
}

void RemoveAllTaggedTemporaryItemProperties(object oItem, string sTag="")
{
    if (sTag == "")
        sTag = GetCurrentItemEventScript();
    itemproperty ipTest = GetFirstItemProperty(oItem);
    while (GetIsItemPropertyValid(ipTest))
    {
        if (GetItemPropertyDuration(ipTest) > 0 && GetItemPropertyTag(ipTest) == sTag)
        {
            DelayCommand(0.0, RemoveItemProperty(oItem, ipTest));
        }
        ipTest = GetNextItemProperty(oItem);
    }
    
}

void RemoveAllTaggedEffects(object oCreature, string sTag="")
{
    if (sTag == "")
        sTag = GetCurrentItemEventScript();
    effect eTest = GetFirstEffect(oCreature);
    while (GetIsEffectValid(eTest))
    {
        if (GetEffectTag(eTest) == sTag)
        {
            RemoveEffect(oCreature, eTest);
        }
        eTest = GetNextEffect(oCreature);
    }
}


int GetDamageTypeOfLastUsedWeapon(object oCreature)
{
    object oWeapon = GetLastWeaponUsed(oCreature);
    if (!GetIsObjectValid(oWeapon))
    {
        oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCreature);
    }
    // I am going to have to assume this is fighting unarmed
    if (!GetIsObjectValid(oWeapon))
    {
        return DAMAGE_TYPE_BLUDGEONING;
    }
    int nBaseItem = GetBaseItemType(oWeapon);
    int nWeaponType = StringToInt(Get2DAString("baseitems", "WeaponType", nBaseItem));
    json jPossibles = JsonArray();
    if (nWeaponType == 1)
        JsonArrayInsertInplace(jPossibles, JsonInt(DAMAGE_TYPE_PIERCING));
    else if (nWeaponType == 2)
        JsonArrayInsertInplace(jPossibles, JsonInt(DAMAGE_TYPE_BLUDGEONING));
    else if (nWeaponType == 3)
        JsonArrayInsertInplace(jPossibles, JsonInt(DAMAGE_TYPE_SLASHING));
    else if (nWeaponType == 4)
    {
        JsonArrayInsertInplace(jPossibles, JsonInt(DAMAGE_TYPE_PIERCING));
        JsonArrayInsertInplace(jPossibles, JsonInt(DAMAGE_TYPE_SLASHING));
    }
    else if (nWeaponType == 5)
    {
        JsonArrayInsertInplace(jPossibles, JsonInt(DAMAGE_TYPE_PIERCING));
        JsonArrayInsertInplace(jPossibles, JsonInt(DAMAGE_TYPE_BLUDGEONING));
    }
    
    itemproperty ipTest = GetFirstItemProperty(oWeapon);
    while (GetIsItemPropertyValid(ipTest))
    {
        int nIPType = GetItemPropertyType(ipTest);
        if (nIPType == ITEM_PROPERTY_EXTRA_MELEE_DAMAGE_TYPE || nIPType == ITEM_PROPERTY_EXTRA_RANGED_DAMAGE_TYPE)
        {
            int nIPConst = GetItemPropertyParam1Value(ipTest);
            if (nIPConst == IP_CONST_DAMAGETYPE_BLUDGEONING)
                JsonArrayInsertInplace(jPossibles, JsonInt(DAMAGE_TYPE_BLUDGEONING));
            else if (nIPConst == IP_CONST_DAMAGETYPE_PIERCING)
                JsonArrayInsertInplace(jPossibles, JsonInt(DAMAGE_TYPE_PIERCING));
            else if (nIPConst == IP_CONST_DAMAGETYPE_SLASHING)
                JsonArrayInsertInplace(jPossibles, JsonInt(DAMAGE_TYPE_SLASHING));
        }
        ipTest = GetNextItemProperty(oWeapon);
    }
    int nIndex = Random(JsonGetLength(jPossibles));
    return JsonGetInt(JsonArrayGet(jPossibles, nIndex));
}

void ItemEventAddCustomPropertyText(string sText)
{
    json jArr = GetLocalJson(GetModule(), "ITEM_EVENT_CUSTOM_PROPERTY_TEXT");
    JsonArrayInsertInplace(jArr, JsonString(sText));
}

json ItemEventGetCustomPropertyText(object oItem)
{
    json jArr = JsonArray();
    SetLocalJson(GetModule(), "ITEM_EVENT_CUSTOM_PROPERTY_TEXT", jArr);
    ItemEventCallEventOnItem(oItem, ITEM_EVENT_CUSTOM_PROPERTIES, OBJECT_SELF, TRUE);
    return GetLocalJson(GetModule(), "ITEM_EVENT_CUSTOM_PROPERTY_TEXT");
}

json GetItemPropertiesAsText(object oItem)
{
    json jCustom = ItemEventGetCustomPropertyText(oItem);
    int nCustomIndex = 0;
    itemproperty ipTest = GetFirstItemProperty(oItem);
    json jOutput = JsonArray();
    while (GetIsItemPropertyValid(ipTest))
    {
        string sProp;
        if (GetItemPropertyType(ipTest) == ITEM_PROPERTY_MATERIAL)
        {
            sProp = "Special: " + JsonGetString(JsonArrayGet(jCustom, nCustomIndex));
            nCustomIndex++;
        }
        else
        {
            sProp = ItemPropertyToString(ipTest);
        }
        if (sProp != "")
        {
            JsonArrayInsertInplace(jOutput, JsonString(sProp));
        }
        ipTest = GetNextItemProperty(oItem);
    }
    return jOutput;
}

string ItemEventMapBuildScript(string sEvent, string sCreatureText="OBJECT_SELF", string sExtraInclude="", string sCondition="", string sSpecificItemExclusion="")
{
    string sContent = "#" + "include \"inc_itemevent\"\n";
    if (sExtraInclude != "")
        sContent += "#" + "include \"" + sExtraInclude + "\"\n";
    sContent += "void main()\n";
    sContent += "{\n";
    if (sCondition != "")
        sContent += "if (" + sCondition + ")\n   ";
    string sSpecificExclusionArgList = "";
    if (sSpecificItemExclusion != "")
    {
        sSpecificExclusionArgList = ", " + sSpecificItemExclusion;
    }
    sContent += "ItemEventCallSubscribersForCreature(\"" + sEvent + "\", " + sCreatureText + sSpecificExclusionArgList + ");\n";
    sContent += "}\n";
    return sContent;
}

void ItemEventMarkEventMapped(string sEvent)
{
    SetLocalInt(GetModule(), "item_event_sub_" + sEvent, 1);
}

void ItemEventMapEvent(string sEvent, string sSubscriptionEventName, string sScriptContent="")
{
    object oModule = GetModule();
    if (!GetLocalInt(oModule, "item_event_sub_" + sEvent))
    {
        int nIndex = GetLocalInt(oModule, "item_event_index");
        string sScriptName = "__itemevth" + IntToString(nIndex);
        if (sScriptContent == "")
            sScriptContent = ItemEventMapBuildScript(sEvent);
        
        string sErr = CompileScript(sScriptName, sScriptContent);
        if (sErr != "")
        {
            WriteTimestampedLogEntry("ERROR: Failed to compile handler script for item event mapping to " + sEvent + ": " + sErr);
            WriteTimestampedLogEntry(sScriptContent);
            return;
        }
        WriteTimestampedLogEntry("Successfully compiled item event handler " + sScriptName + " for " + sEvent);
        NWNX_Events_SubscribeEvent(sSubscriptionEventName, sScriptName);
        ItemEventMarkEventMapped(sEvent);
        nIndex++;
        SetLocalInt(oModule, "item_event_index", nIndex);
    }
}

void ItemEventsInitialise()
{
    // Guarding against multiple usage of this seems sensible - do not want to be firing duplicates of each event
    if (!GetLocalInt(GetModule(), "ITEM_EVENT_INIT"))
    {
        // Main equip/unequip handlers
        string sScript = "#" + "include \"inc_itemevent\"\n";
        sScript += "void main()\n";
        sScript += "{\n";
        sScript += "object oItem = StringToObject(NWNX_Events_GetEventData(\"ITEM\"));";
        sScript += "ItemEventCallEventScriptOnItem(oItem, ITEM_EVENT_EQUIP, \"is_\" + GetTag(oItem));";
        sScript += "}";
        ItemEventMapEvent(ITEM_EVENT_EQUIP, "NWNX_ON_ITEM_EQUIP_AFTER", sScript);
        sScript = "#" + "include \"inc_itemevent\"\n";
        sScript += "void main()\n";
        sScript += "{\n";
        sScript += "object oItem = StringToObject(NWNX_Events_GetEventData(\"ITEM\"));";
        sScript += "ItemEventCallEventScriptOnItem(oItem, ITEM_EVENT_UNEQUIP, \"is_\" + GetTag(oItem));";
        sScript += "}";
        ItemEventMapEvent(ITEM_EVENT_UNEQUIP, "NWNX_ON_ITEM_UNEQUIP_BEFORE", sScript);
        
        // Called in on_item_act.nss
        ItemEventMarkEventMapped(ITEM_EVENT_ACTIVATED);
        
        // Called in on_pc_examineb.nss
        ItemEventMarkEventMapped(ITEM_EVENT_CUSTOM_PROPERTIES);
        
        // These are called directly in on_damage.nss
        ItemEventMarkEventMapped(ITEM_EVENT_WEARER_DAMAGED);
        ItemEventMarkEventMapped(ITEM_EVENT_WEARER_DAMAGES);
        
        // These are called directly in on_attack.nss
        ItemEventMarkEventMapped(ITEM_EVENT_WEARER_ATTACKED);
        ItemEventMarkEventMapped(ITEM_EVENT_WEARER_ATTACKS);
        
        
        ItemEventMapEvent(ITEM_EVENT_EQUIP_OTHER_AFTER, "NWNX_ON_ITEM_EQUIP_AFTER", ItemEventMapBuildScript(ITEM_EVENT_EQUIP_OTHER_AFTER, "OBJECT_SELF", "", "", "OBJECT_SELF"));
        ItemEventMapEvent(ITEM_EVENT_START_COMBAT_ROUND_AFTER, "NWNX_ON_START_COMBAT_ROUND_AFTER");
        SetLocalInt(GetModule(), "ITEM_EVENT_INIT", 1);
    }
    
}

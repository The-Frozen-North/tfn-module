#include "inc_persist"
#include "nwnx_util"

// A light blue/purple. It's pretty.
const string KEY_ITEM_NAME_COLOR = "<c\xa9\x96\xff>";

// Include for key functions.

int GetHasKey(object oPC, string sKeyTag);
void AddKeyToPlayer(object oPC, object oKey);
void RemoveKeyFromPlayer(object oPC, string sKeyTag);
int GetNumKeysOwned(object oPC);

string GetKeyName(string sKeyTag);
string GetKeyDescription(string sKeyTag);

////////////////

string GetKeyName(string sKeyTag)
{
    return GetCampaignString("key_info", sKeyTag + "_name");
}

string GetKeyDescription(string sKeyTag)
{
    return GetCampaignString("key_info", sKeyTag + "_desc");
}

void AddKeyToPlayer(object oPC, object oKey)
{
    string sKeyTag = GetTag(oKey);
    SQLocalsPlayer_SetInt(oPC, "haskeytag_" + sKeyTag, 1);
    string sDesc = GetDescription(oKey);
    SetCampaignString("key_info", sKeyTag + "_desc", sDesc);
    string sName = NWNX_Util_StripColors(GetName(oKey));
    SetCampaignString("key_info", sKeyTag + "_name", sName);
    object oBag = GetItemPossessedBy(oPC, "keybag");
    if (!GetIsObjectValid(oBag))
    {
        FloatingTextStringOnCreature("*You decide to start a collection of keys in a small bag, and stash the " + sName + " in it*", oPC, FALSE);
        object oKeybag = CreateItemOnObject("keybag", oPC, 1, "keybag");
        SetItemCursedFlag(oKeybag, TRUE);
        SetIdentified(oKeybag, TRUE);
        SetDroppableFlag(oKeybag, FALSE);
        SetPickpocketableFlag(oKeybag, FALSE);
        SetPlotFlag(oKeybag, TRUE);
    }
    else
    {
        FloatingTextStringOnCreature("*You stash away the "+sName+" in your key bag*", oPC, FALSE);
    }
    DestroyObject(oKey);
}

void RemoveKeyFromPlayer(object oPC, string sKeyTag)
{
    if (GetHasKey(oPC, sKeyTag))
    {
        string sName = GetKeyName(sKeyTag);
        FloatingTextStringOnCreature("*You have removed "+sName+" from your key bag*", oPC, FALSE);
        SQLocalsPlayer_DeleteInt(oPC, "haskeytag_" + sKeyTag);
    }
}

int GetHasKey(object oPC, string sKeyTag)
{
    return SQLocalsPlayer_GetInt(oPC, "haskeytag_" + sKeyTag);
}

int GetNumKeysOwned(object oPC)
{
    return SQLocalsPlayer_Count(oPC, SQLOCALSPLAYER_TYPE_INT, "haskeytag_*");
}

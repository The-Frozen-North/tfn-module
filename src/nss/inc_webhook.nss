// Adapted from Dark Sun. https://github.com/tinygiant98/darksun-sot/tree/webhook
// ds_wh_i_main.nss

const int LOG_IN = 1;
const int LOG_OUT = 2;

// the row in env.2da where the discord secret is stored
const int ENV_DISCORD_KEY_ROW = 2;
// the row in env.2da where the discord secret for sending bug reports is stored
const int ENV_DISCORD_BUG_REPORT_KEY_ROW = 3;

const string PLAYER_COLOR = "#42bcf5";
const string LEVEL_UP_COLOR = "#ddf542";
const string DEATH_COLOR = "#ed5426";
const string BOSS_DEFEATED_COLOR = "#ffd700";
const string SERVER_COLOR = "#b0b0b0";
const string VALUABLE_ITEM_COLOR = "#96e6ff";
const string HOUSE_BUY_COLOR = "#a000a0";
const string QUEST_COMPLETE_COLOR = "#50ffa0";
const string BUG_REPORT_COLOR = "#ffa500";

#include "nwnx_player"
#include "nwnx_webhook_rch"
#include "inc_nwnx"
#include "inc_debug"
#include "inc_xp"
#include "inc_follower"
#include "inc_henchman"
#include "inc_general"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

int HideDiscord(object oPC);
int HideDiscord(object oPC)
{
    if (GetCampaignInt(GetPCPublicCDKey(GetPCSpeaker()), "hide_discord")) return TRUE;

    return FALSE;
}

string GetDiscordKey();
string GetDiscordKey()
{
    return Get2DAString("env", "Value", ENV_DISCORD_KEY_ROW);
}

int DiscordEnabled();
int DiscordEnabled()
{
// do we have a discord key set?
    if (GetDiscordKey() != "") return TRUE;

    return FALSE;
}

int GetPlayerCount()
{
    object oPCCount = GetFirstPC();
    int nPCs = 0;

    while (GetIsObjectValid(oPCCount))
    {
        nPCs = nPCs + 1;
        oPCCount = GetNextPC();
    }

    return nPCs;
}

string GetClassAndLevel(int nPosition, object oCreature)
{
    int nClass = GetClassByPosition(nPosition, oCreature);

    if (nClass == CLASS_TYPE_INVALID)
        return "";

    string sClass = GetStringByStrRef(StringToInt(Get2DAString("classes", "Name", nClass)));

    if (sClass != "")
    {
        return sClass+" "+IntToString(GetLevelByPosition(nPosition, oCreature));
    }
    else
    {
        return "";
    }
}

string GetClassesAndLevels(object oCreature)
{
    string sClass = GetClassAndLevel(1, oCreature);
    string sClassLabel = "CLASS";

    if (GetLevelByPosition(2, oCreature) > 0)
        sClass = sClass+"/"+GetClassAndLevel(2, oCreature);

    if (GetLevelByPosition(3, oCreature) > 0)
        sClass = sClass+"/"+GetClassAndLevel(3, oCreature);

    return sClass;
}

const string SERVER_BOT = "nwnx-webhook";

const string LOGO = "https://i.postimg.cc/vZxdfwBS/dssot-logo-001-2.png";

string GetPartySizeString(object oPC)
{
    object oPartyMember = GetFirstFactionMember(oPC);
    int nNumPCs = 0;
    int nNumNPCS = 0;
    while (GetIsObjectValid(oPartyMember))
    {
        nNumPCs++;
        nNumNPCS += GetFollowerCount(oPartyMember);
        nNumNPCS += GetHenchmanCount(oPartyMember);
        oPartyMember = GetNextFactionMember(oPC);
    }
    string sOut = "0 NPCs";
    //string sOut = IntToString(nNumNPCS + nNumPCs);
    if (nNumNPCS > 0)
    {
        sOut = IntToString(nNumNPCS) + " NPC" + (nNumNPCS > 1 ? "s" : "");
    }
    return sOut;
}

// For adding additional info in fields, and without hardcoding it for each webhook type in case the format changes
// Here's a little function that writes it into enumerated slots
// Field indexes start at 1
struct NWNX_WebHook_Message SetWebhookCustomField(struct NWNX_WebHook_Message stMessage, int nCustomFieldIndex, string sName, string sValue)
{
    if (nCustomFieldIndex == 1)
    {
        stMessage.sField3Name = sName;
        stMessage.sField3Value = sValue;
    }
    else if (nCustomFieldIndex == 2)
    {
        stMessage.sField6Name = sName;
        stMessage.sField6Value = sValue;
    }
    // I would add a debug error line here, but if anyone tries to make a webhook with an unavailable index without
    // adding it here first, I would think it would be VERY obvious in the webhook output!
    return stMessage;
}


struct NWNX_WebHook_Message BuildWebhookMessageTemplate(object oPC)
{
    struct NWNX_WebHook_Message stMessage;
    stMessage.sAuthorName = GetName(oPC);
    stMessage.sAuthorIconURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oPC)) + "t.png";
    stMessage.sThumbnailURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oPC)) + "m.png";

    // Fields are always 3 to a line
    // If there aren't 3 discord spaces the other fields out evently

    stMessage.sField1Name = "PLAYERS";
    stMessage.sField1Value = IntToString(GetPlayerCount());
    stMessage.iField1Inline = TRUE;

    stMessage.sField2Name = "ACCOUNT";
    stMessage.sField2Value = GetPCPlayerName(oPC);
    stMessage.iField2Inline = TRUE;

    string sClassLabel = "CLASS";

    if (GetLevelByPosition(2, oPC) > 0)
      sClassLabel = "CLASSES";

    // To get two rows of two items and aligned neatly, two dummy fields are needed
    // Might replace these with something someday, who knows

    stMessage.sField3Name = " ";
    stMessage.sField3Value = "";
    stMessage.iField3Inline = TRUE;

    stMessage.sField4Name = "PARTY SIZE";
    stMessage.sField4Value = GetPartySizeString(oPC);
    stMessage.iField4Inline = TRUE;

    stMessage.sField5Name = sClassLabel;
    stMessage.sField5Value = GetClassesAndLevels(oPC);
    stMessage.iField5Inline = TRUE;

    stMessage.sField6Name = " ";
    stMessage.sField6Value = "";
    stMessage.iField6Inline = TRUE;

    //stMessage.sField5Name = "LOREM";
    //stMessage.sField5Value = "Yummy sweetrolls.";
    //stMessage.iField5Inline = TRUE;
    //
    //stMessage.sField6Name = "IPSUM";
    //stMessage.sField6Value = "What is it? Dragons?";
    //stMessage.iField6Inline = TRUE;



    return stMessage;
}

void SendDiscordMessage(string sMessage, string sDiscordKey)
{
// TODO: Refactor to include "inc_webhook" and use the same constant instead of a "magic number"
    string sDiscordKey = Get2DAString("env", "Value", 2);

    if (sDiscordKey == "") return;

    if (GetLocalInt(GetModule(), "dev") == 0)
    {
        NWNX_WebHook_SendWebHookHTTPS("discordapp.com", sDiscordKey, sMessage);
    }
    else
    {
        // Try anyway
        NWNX_WebHook_SendWebHookHTTPS("discordapp.com", sDiscordKey, sMessage);
        // But the log is good
        WriteTimestampedLogEntry("Webhook message: " + sMessage);
    }
}

void LogWebhook(object oPC, int nLogMode)
{
    if (!DiscordEnabled()) return;

    string sConstructedMsg;
    string sName = GetName(oPC);
    struct NWNX_WebHook_Message stMessage = BuildWebhookMessageTemplate(oPC);

    string sTitle, sDescription = "**" + sName + "** has ";
    int nPlayers = GetPlayerCount();

    if (nLogMode == LOG_IN)
    {
        sTitle = "LOGIN";
        sDescription += "logged in!";
    }
    else if (nLogMode == LOG_OUT)
    {
        sTitle = "LOGOUT";
        sDescription += "logged out!";
        nPlayers = nPlayers - 1;
    }

    stMessage.sTitle = sTitle;
    stMessage.sColor = PLAYER_COLOR;
    stMessage.sAuthorName = sName;
    stMessage.sDescription = sDescription;

    stMessage.sField1Value = IntToString(nPlayers);

    //stMessage.sFooterText = GetName(GetModule());

    sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discord.com", GetDiscordKey(), stMessage);
    SendDiscordMessage(sConstructedMsg, GetDiscordKey());
}

void LevelUpWebhook(object oPC)
{
  if (!DiscordEnabled()) return;
  if (HideDiscord(oPC)) return;

  string sConstructedMsg;
  struct NWNX_WebHook_Message stMessage = BuildWebhookMessageTemplate(oPC);
  stMessage.sColor = LEVEL_UP_COLOR;
  stMessage.sTitle = "LEVEL UP";
  stMessage.sDescription = "**"+GetName(oPC)+"** has leveled up to "+IntToString(GetHitDice(oPC))+"!";
  stMessage.sThumbnailURL = "https://raw.githubusercontent.com/nwn-rs/assets/build8193.36/png/po_levelup.png";

  //stMessage.sFooterText = GetName(GetModule());
  //stMessage.iTimestamp = SQLite_GetTimeStamp();
  sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discordapp.com", GetDiscordKey(), stMessage);
  SendDiscordLogMessage(sConstructedMsg);
  SendMessageToAllPCs(GetName(oPC)+" has leveled up to "+IntToString(GetHitDice(oPC))+"!");
}

// sends a web hook to discord if you were petrified
void DeathWebhook(object oPC, object oKiller, int bPetrified = FALSE);
void DeathWebhook(object oPC, object oKiller, int bPetrified = FALSE)
{
    if (!DiscordEnabled()) return;
    if (HideDiscord(oPC)) return;

    string sConstructedMsg;
    struct NWNX_WebHook_Message stMessage = BuildWebhookMessageTemplate(oPC);
    stMessage.sColor = DEATH_COLOR;
    stMessage.sTitle = "DEATH";
    string sAction = "killed";
    stMessage.sThumbnailURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oKiller)) + "m.png";

    if (bPetrified)
    {
      stMessage.sTitle = "PETRIFICATION";
      sAction = "petrified";
    }

    string sName = GetName(oKiller);

    if (sName == "")
    {
       string sTrap = GetLocalString(oPC, "trap_triggered");
       if (sTrap != "")
       {
          sName = "a "+sTrap;
          //stMessage.sThumbnailURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/po_plc_t07_m.png";
          stMessage.sThumbnailURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/po_plc_piratex_m.png";
       }
       else
       {
          sName = "an unknown object";
       }
    }
    else
    {
       sName = "**"+sName+"**";
       if (GetIsObjectValid(GetMaster(oKiller)))
       {
            int nAssociateType = GetAssociateType(oKiller);
            if (nAssociateType == ASSOCIATE_TYPE_FAMILIAR || nAssociateType == ASSOCIATE_TYPE_ANIMALCOMPANION || nAssociateType == ASSOCIATE_TYPE_SUMMONED)
            {
                sName = "**" + GetName(GetMaster(oKiller)) + "'s " + GetName(oKiller) + "**";
            }
       }
    }
    stMessage.sDescription = "**"+GetName(oPC)+"** was "+sAction+" by "+sName+".";

    //stMessage.sFooterText = GetName(GetModule());
    //stMessage.iTimestamp = SQLite_GetTimeStamp();
    sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discordapp.com", GetDiscordKey(), stMessage);
    SendDiscordMessage(sConstructedMsg, GetDiscordKey());
    SendMessageToAllPCs(GetName(oPC)+" was "+sAction+" by "+sName+".");
}

// sends a web hook to discord if you killed a boss
void BossDefeatedWebhook(object oPC, object oDead);
void BossDefeatedWebhook(object oPC, object oDead)
{
    if (!DiscordEnabled()) return;
    if (HideDiscord(oPC)) return;

// don't continue if this isn't set, prevents it from being played twice
    if (GetLocalInt(oDead, "defeated_webhook") != 1)
    {
       return;
    }
// maybe an associate killed the oDead? try to get the master in that case
    if (!GetIsPC(oPC))
    {
       oPC = GetMaster(oPC);
    }

// still not a PC? do nothing
    if (!GetIsPC(oPC))
    {
       return;
    }

// do not send the webhook if the PC is higher/equal level to the boss
    if (GetHitDice(oPC) >= GetHitDice(oDead))
    {
      return;
    }

    string sConstructedMsg;
    struct NWNX_WebHook_Message stMessage = BuildWebhookMessageTemplate(oPC);
    stMessage.sThumbnailURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oDead)) + "m.png";
    stMessage.sColor = BOSS_DEFEATED_COLOR;
    stMessage.sTitle = "BOSS DEFEATED";

    stMessage.sDescription = "**"+GetName(oPC)+"** has defeated **"+GetName(oDead)+"**!";

    //stMessage.sFooterText = GetName(GetModule());
    //stMessage.iTimestamp = SQLite_GetTimeStamp();
    sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discordapp.com", GetDiscordKey(), stMessage);
    SendDiscordMessage(sConstructedMsg, GetDiscordKey());
    SendMessageToAllPCs(GetName(oPC)+" has defeated "+GetName(oDead)+"!");

    // delete this so it doesn't trigger again
    DeleteLocalInt(oDead, "defeated_webhook");
}

void ServerWebhook(string sTitle, string sDescription)
{
  if (!DiscordEnabled()) return;
  string sConstructedMsg;
  struct NWNX_WebHook_Message stMessage;
  stMessage.sUsername = SERVER_BOT;
  stMessage.sColor = SERVER_COLOR;
  stMessage.sTitle = sTitle;

  stMessage.sDescription = sDescription;

  //stMessage.sAuthorName = GetName(oPC);
  stMessage.sThumbnailURL = "https://nwn.wiki/download/thumbnails/3473429/logo-small.png";


  //stMessage.sFooterText = GetName(GetModule());
  //stMessage.iTimestamp = SQLite_GetTimeStamp();
  sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discordapp.com", GetDiscordKey(), stMessage);
  SendDiscordMessage(sConstructedMsg, GetDiscordKey());
}

void ValuableItemWebhook(object oPC, object oItem, int nIsPurchased=FALSE);
void ValuableItemWebhook(object oPC, object oItem, int nIsPurchased=FALSE)
{
    if (!DiscordEnabled()) return;
    if (HideDiscord(oPC)) return;

    if (GetGoldPieceValue(oItem) < 14000)
    {
        return;
    }
    // Hopefully all cases of double reporting are fixed, but for safety's sake
    // This specifically stops the webhook firing twice for the player who identified an item for any reason
    // The lore event is by far the most dodgy detection...
    if (GetLocalObject(oItem, "webhook_valuable_identifier") == oPC)
    {
        return;
    }
    string sConstructedMsg;
    string sName = GetName(oPC);
    struct NWNX_WebHook_Message stMessage = BuildWebhookMessageTemplate(oPC);

    // Messages work out to be like this:
    // PC has purchased an Amulet of Protection!
    // PC has identified an Amulet of Protection!

    string sAcquisitionMethod = nIsPurchased ? "purchased" : "identified";

    string sTitle;
    string sDescription = "**" + sName + "** has " + sAcquisitionMethod;
    string sNonDiscordDescription = sName + " has " + sAcquisitionMethod;
    int nPlayers = GetPlayerCount();

    stMessage = SetWebhookCustomField(stMessage, 1, "ITEM TYPE", GetStringByStrRef(StringToInt(Get2DAString("baseitems", "Name", GetBaseItemType(oItem)))));
    stMessage = SetWebhookCustomField(stMessage, 2, "VALUE", IntToString(GetGoldPieceValue(oItem)));

    string sItemName = GetName(oItem);
    string sFirstLetter = GetStringLowerCase(GetStringLeft(sItemName, 1));
    if (sFirstLetter == "a" || sFirstLetter == "e" || sFirstLetter == "i" ||
        sFirstLetter == "o" || sFirstLetter == "u")
    {
        sDescription += " an **" + sItemName + "**!";
        sNonDiscordDescription += " an " + sItemName + "!";
    }
    else
    {
        sDescription += " a **" + sItemName + "**!";
        sNonDiscordDescription += " a " + sItemName + "!";
    }

    sTitle = "VALUABLE ITEM";

    stMessage.sTitle = sTitle;
    stMessage.sColor = VALUABLE_ITEM_COLOR;
    stMessage.sDescription = sDescription;

    // strongbox stMessage.sThumbnailURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/po_plc_a09_m.png";
    // chest transparent https://nwn.sfo2.digitaloceanspaces.com/portrait/po_plc_a08_m.png
    // gold pile transparent https://nwn.sfo2.digitaloceanspaces.com/portrait/po_plc_c08_m.png
    // gold chest transparent https://nwn.sfo2.digitaloceanspaces.com/portrait/po_plc_c09_m.png
    // pirate gold chest black https://nwn.sfo2.digitaloceanspaces.com/portrait/po_pwc_ches01_m.png

    stMessage.sThumbnailURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/po_pwc_ches01_m.png";


    //SendDebugMessage("ValuableItemWebhook: " + sDescription);
    sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discord.com", GetDiscordKey(), stMessage);
    SendDiscordMessage(sConstructedMsg, GetDiscordKey());
    SendMessageToAllPCs(sNonDiscordDescription);
}


void HouseBuyWebhook(object oPC, int nGoldCost, object oArea);
void HouseBuyWebhook(object oPC, int nGoldCost, object oArea)
{
    if (!DiscordEnabled()) return;
    if (HideDiscord(oPC)) return;

    string sConstructedMsg;
    string sName = GetName(oPC);
    struct NWNX_WebHook_Message stMessage = BuildWebhookMessageTemplate(oPC);

    // PC has purchased a house in Area for Gold!
    string sTitle = "HOUSE PURCHASED";
    string sDescription = "**" + sName + "** has purchased a house in " + GetName(oArea) + " for " + IntToString(nGoldCost) + " gold!";

    stMessage.sTitle = sTitle;
    stMessage.sColor = HOUSE_BUY_COLOR;
    stMessage.sAuthorName = sName;

    stMessage.sDescription = sDescription;

    // bed black https://nwn.sfo2.digitaloceanspaces.com/portrait/po_plc_x0_bdb_m.png
    // balcony, not really a house but closest to uploaded https://nwn.sfo2.digitaloceanspaces.com/portrait/po_plc_balce02_m.png
    // actual house, this is preferred but not uploaded https://nwn.sfo2.digitaloceanspaces.com/portrait/po_tm_tnohsa01_m.png

    stMessage.sThumbnailURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/po_plc_balce02_m.png";

    //SendDebugMessage("HouseBuyWebhook: " + sDescription);
    sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discord.com", GetDiscordKey(), stMessage);
    SendDiscordMessage(sConstructedMsg, GetDiscordKey());
    SendMessageToAllPCs(sName + " has purchased a house in " + GetName(oArea) + " for " + IntToString(nGoldCost) + " gold!");
}


void QuestCompleteWebhook(object oPC, string sQuestName, object oQuestObject);
void QuestCompleteWebhook(object oPC, string sQuestName, object oQuestObject)
{
    if (!DiscordEnabled()) return;
    if (HideDiscord(oPC)) return;

    // do not send a message for minor or progression quests
    if (FindSubString(sQuestName, "Curing") >= 0 ||
        FindSubString(sQuestName, "Oath") >= 0 ||
        FindSubString(sQuestName, "Missing Druid") >= 0 ||
        FindSubString(sQuestName, "Supplies for Neverwinter") >= 0 ||
        FindSubString(sQuestName, "Escaped Convict") >= 0 ||
        FindSubString(sQuestName, "Art Theft") >= 0 ||
        FindSubString(sQuestName, "Artifact Recovery") >= 0 ||
        FindSubString(sQuestName, "The Serpent's Gems") >= 0)
    {
        return;
    }

    string sConstructedMsg;
    string sName = GetName(oPC);
    struct NWNX_WebHook_Message stMessage = BuildWebhookMessageTemplate(oPC);

    string sTitle = "QUEST COMPLETED";
    string sDescription = "**" + sName + "** has completed **" + sQuestName + "**!";

    stMessage.sTitle = sTitle;
    stMessage.sColor = QUEST_COMPLETE_COLOR;

    stMessage.sDescription = sDescription;

    // use the quest giver's portrait
    stMessage.sThumbnailURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oQuestObject)) + "m.png";


    //SendDebugMessage("QuestCompleteWebhook: " + sDescription);
    sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discord.com", GetDiscordKey(), stMessage);
    SendDiscordMessage(sConstructedMsg, GetDiscordKey());
    SendMessageToAllPCs(sName + " has completed " + sQuestName + "!");
}

void BugReportWebhook(object oPC, string sMessage);
void BugReportWebhook(object oPC, string sMessage)
{
    string sDiscordKey = Get2DAString("env", "Value", ENV_DISCORD_BUG_REPORT_KEY_ROW);
    // SendDebugMessage("key " + sDiscordKey);
    if (sDiscordKey == "") return;
    // string sDiscordKey = GetDiscordKey();

    string sConstructedMsg;
    string sName = GetName(oPC);
    struct NWNX_WebHook_Message stMessage = BuildWebhookMessageTemplate(oPC);

    string sTitle = "BUG REPORT";

    stMessage.sTitle = sTitle;
    stMessage.sColor = BUG_REPORT_COLOR;
    stMessage.sUsername = "nwnx-webhook-bugs";

    stMessage.sDescription = sMessage;

    sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discord.com", sDiscordKey, stMessage);
    SendDiscordMessage(sConstructedMsg, sDiscordKey);
}


// Adapted from Dark Sun. https://github.com/tinygiant98/darksun-sot/tree/webhook
// ds_wh_i_main.nss

const int LOG_IN = 1;
const int LOG_OUT = 2;

const string PLAYER_COLOR = "#42bcf5";
const string LEVEL_UP_COLOR = "#ddf542";
const string DEATH_COLOR = "#ed5426";
const string BOSS_DEFEATED_COLOR = "#ffd700";
const string SERVER_COLOR = "#9fe4fc";
const string VALUABLE_ITEM_COLOR = "#96e6ff";
const string HOUSE_BUY_COLOR = "#a000a0";
const string QUEST_COMPLETE_COLOR = "#50ffa0";

#include "nwnx_player"
#include "nwnx_webhook_rch"
#include "inc_nwnx"
#include "inc_debug"

// -----------------------------------------------------------------------------
//                              Function Prototypes
// -----------------------------------------------------------------------------

// -----------------------------------------------------------------------------
//                             Function Definitions
// -----------------------------------------------------------------------------

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

void LogWebhook(object oPC, int nLogMode)
{
    string sConstructedMsg;
    string sName = GetName(oPC);
    struct NWNX_WebHook_Message stMessage;

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

    stMessage.sUsername = SERVER_BOT;
    stMessage.sTitle = sTitle;
    stMessage.sColor = PLAYER_COLOR;
    stMessage.sAuthorName = sName;
    stMessage.sAuthorIconURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oPC)) + "t.png";
    stMessage.sThumbnailURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oPC)) + "m.png";
    stMessage.sDescription = sDescription;

    stMessage.sField1Name = "PLAYERS";
    stMessage.sField1Value = IntToString(nPlayers);
    stMessage.iField1Inline = TRUE;

    //stMessage.sFooterText = GetName(GetModule());
    //stMessage.iTimestamp = GetUnixTimeStamp();

    stMessage.sField2Name = "ACCOUNT";
    stMessage.sField2Value = GetPCPlayerName(oPC);
    stMessage.iField2Inline = TRUE;

    string sClassLabel = "CLASS";

    if (GetLevelByPosition(2, oPC) > 0)
        sClassLabel = "CLASSES";

    stMessage.sField3Name = sClassLabel;
    stMessage.sField3Value = GetClassesAndLevels(oPC);
    stMessage.iField3Inline = TRUE;

    sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discord.com", Get2DAString("env", "Value", 2), stMessage);
    SendDiscordLogMessage(sConstructedMsg);
}

void LevelUpWebhook(object oPC)
{
  string sConstructedMsg;
  struct NWNX_WebHook_Message stMessage;
  stMessage.sUsername = SERVER_BOT;
  stMessage.sColor = LEVEL_UP_COLOR;
  stMessage.sTitle = "LEVEL UP";
  stMessage.sDescription = "**"+GetName(oPC)+"** has leveled up to "+IntToString(GetHitDice(oPC))+"!";

  stMessage.sAuthorName = GetName(oPC);
  stMessage.sAuthorIconURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oPC)) + "t.png";
  stMessage.sThumbnailURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oPC)) + "m.png";

  stMessage.sField1Name = "PLAYERS";
  stMessage.sField1Value = IntToString(GetPlayerCount());
  stMessage.iField1Inline = TRUE;

  stMessage.sField2Name = "ACCOUNT";
  stMessage.sField2Value = GetPCPlayerName(oPC);
  stMessage.iField2Inline = TRUE;

  string sClassLabel = "CLASS";

  if (GetLevelByPosition(2, oPC) > 0)
      sClassLabel = "CLASSES";

  stMessage.sField3Name = sClassLabel;
  stMessage.sField3Value = GetClassesAndLevels(oPC);
  stMessage.iField3Inline = TRUE;


  //stMessage.sFooterText = GetName(GetModule());
  //stMessage.iTimestamp = SQLite_GetTimeStamp();
  sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discordapp.com", Get2DAString("env", "Value", 2), stMessage);
  SendDiscordLogMessage(sConstructedMsg);
}

// sends a web hook to discord if you were petrified
void DeathWebhook(object oPC, object oKiller, int bPetrified = FALSE);
void DeathWebhook(object oPC, object oKiller, int bPetrified = FALSE)
{
  string sConstructedMsg;
  struct NWNX_WebHook_Message stMessage;
  stMessage.sUsername = SERVER_BOT;
  stMessage.sColor = DEATH_COLOR;
  stMessage.sTitle = "DEATH";
  string sAction = "killed";

  if (bPetrified)
  {
    stMessage.sTitle = "PETRIFICATION";
    sAction = "petrified";
  }

  string sName = GetName(oKiller);
  if (sName == "")
  {
     sName = "an unknown object";
  }
  else
  {
     sName = "**"+sName+"**";
  }
  stMessage.sDescription = "**"+GetName(oPC)+"** was "+sAction+" by "+sName+".";

  stMessage.sAuthorName = GetName(oPC);
  stMessage.sAuthorIconURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oPC)) + "t.png";
  stMessage.sThumbnailURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oKiller)) + "m.png";

  stMessage.sField1Name = "PLAYERS";
  stMessage.sField1Value = IntToString(GetPlayerCount());
  stMessage.iField1Inline = TRUE;

  stMessage.sField2Name = "ACCOUNT";
  stMessage.sField2Value = GetPCPlayerName(oPC);
  stMessage.iField2Inline = TRUE;

  string sClassLabel = "CLASS";

  if (GetLevelByPosition(2, oPC) > 0)
      sClassLabel = "CLASSES";

  stMessage.sField3Name = sClassLabel;
  stMessage.sField3Value = GetClassesAndLevels(oPC);
  stMessage.iField3Inline = TRUE;


  //stMessage.sFooterText = GetName(GetModule());
  //stMessage.iTimestamp = SQLite_GetTimeStamp();
  sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discordapp.com", Get2DAString("env", "Value", 2), stMessage);
  SendDiscordLogMessage(sConstructedMsg);
}

// sends a web hook to discord if you killed a boss
void BossDefeatedWebhook(object oPC, object oDead);
void BossDefeatedWebhook(object oPC, object oDead)
{
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
  struct NWNX_WebHook_Message stMessage;
  stMessage.sUsername = SERVER_BOT;
  stMessage.sColor = BOSS_DEFEATED_COLOR;
  stMessage.sTitle = "BOSS DEFEATED";

  stMessage.sDescription = "**"+GetName(oPC)+"** has defeated **"+GetName(oDead)+"**!";

  stMessage.sAuthorName = GetName(oPC);
  stMessage.sAuthorIconURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oPC)) + "t.png";
  stMessage.sThumbnailURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oDead)) + "m.png";

  stMessage.sField1Name = "PLAYERS";
  stMessage.sField1Value = IntToString(GetPlayerCount());
  stMessage.iField1Inline = TRUE;

  stMessage.sField2Name = "ACCOUNT";
  stMessage.sField2Value = GetPCPlayerName(oPC);
  stMessage.iField2Inline = TRUE;

  string sClassLabel = "CLASS";

  if (GetLevelByPosition(2, oPC) > 0)
      sClassLabel = "CLASSES";

  stMessage.sField3Name = sClassLabel;
  stMessage.sField3Value = GetClassesAndLevels(oPC);
  stMessage.iField3Inline = TRUE;


  //stMessage.sFooterText = GetName(GetModule());
  //stMessage.iTimestamp = SQLite_GetTimeStamp();
  sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discordapp.com", Get2DAString("env", "Value", 2), stMessage);
  SendDiscordLogMessage(sConstructedMsg);

// delete this so it doesn't trigger again
  DeleteLocalInt(oDead, "defeated_webhook");
}

void ServerWebhook(string sTitle, string sDescription)
{
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
  sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discordapp.com", Get2DAString("env", "Value", 2), stMessage);
  SendDiscordLogMessage(sConstructedMsg);
}

void ValuableItemWebhook(object oPC, object oItem, int nIsPurchased=FALSE);
void ValuableItemWebhook(object oPC, object oItem, int nIsPurchased=FALSE)
{
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
    struct NWNX_WebHook_Message stMessage;

    // Messages work out to be like this:
    // PC has purchased an Amulet of Protection!
    // PC has identified an Amulet of Protection!

    string sAcquisitionMethod = nIsPurchased ? "purchased" : "identified";

    string sTitle;
    string sDescription = "**" + sName + "** has " + sAcquisitionMethod;
    int nPlayers = GetPlayerCount();

   string sItemName = GetName(oItem);
    string sFirstLetter = GetStringLowerCase(GetStringLeft(sItemName, 1));
    if (sFirstLetter == "a" || sFirstLetter == "e" || sFirstLetter == "i" ||
        sFirstLetter == "o" || sFirstLetter == "u")
    {
        sDescription += " an " + sItemName + "!";
    }
    else
    {
        sDescription += " a " + sItemName + "!";
    }

    sTitle = "VALUABLE ITEM";

    stMessage.sUsername = SERVER_BOT;
    stMessage.sTitle = sTitle;
    stMessage.sColor = VALUABLE_ITEM_COLOR;
    stMessage.sAuthorName = sName;
    stMessage.sAuthorIconURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oPC)) + "t.png";
    stMessage.sThumbnailURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oPC)) + "m.png";
    stMessage.sDescription = sDescription;

    stMessage.sField1Name = "PLAYERS";
    stMessage.sField1Value = IntToString(nPlayers);
    stMessage.iField1Inline = TRUE;

    stMessage.sField2Name = "ACCOUNT";
    stMessage.sField2Value = GetPCPlayerName(oPC);
    stMessage.iField2Inline = TRUE;

    string sClassLabel = "CLASS";

    if (GetLevelByPosition(2, oPC) > 0)
        sClassLabel = "CLASSES";

    stMessage.sField3Name = sClassLabel;
    stMessage.sField3Value = GetClassesAndLevels(oPC);
    stMessage.iField3Inline = TRUE;

    //SendDebugMessage("ValuableItemWebhook: " + sDescription);
    sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discord.com", Get2DAString("env", "Value", 2), stMessage);
    SendDiscordLogMessage(sConstructedMsg);
}


void HouseBuyWebhook(object oPC, int nGoldCost, object oArea);
void HouseBuyWebhook(object oPC, int nGoldCost, object oArea)
{
    string sConstructedMsg;
    string sName = GetName(oPC);
    struct NWNX_WebHook_Message stMessage;

    // PC has purchased a house in Area for Gold!
    string sTitle = "HOUSE PURCHASED";
    string sDescription = "**" + sName + "** has purchased a house in " + GetName(oArea) + " for " + IntToString(nGoldCost) + " gold!";
    int nPlayers = GetPlayerCount();

    stMessage.sUsername = SERVER_BOT;
    stMessage.sTitle = sTitle;
    stMessage.sColor = HOUSE_BUY_COLOR;
    stMessage.sAuthorName = sName;
    stMessage.sAuthorIconURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oPC)) + "t.png";
    stMessage.sThumbnailURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oPC)) + "m.png";
    stMessage.sDescription = sDescription;

    stMessage.sField1Name = "PLAYERS";
    stMessage.sField1Value = IntToString(nPlayers);
    stMessage.iField1Inline = TRUE;

    stMessage.sField2Name = "ACCOUNT";
    stMessage.sField2Value = GetPCPlayerName(oPC);
    stMessage.iField2Inline = TRUE;

    string sClassLabel = "CLASS";

    if (GetLevelByPosition(2, oPC) > 0)
        sClassLabel = "CLASSES";

    stMessage.sField3Name = sClassLabel;
    stMessage.sField3Value = GetClassesAndLevels(oPC);
    stMessage.iField3Inline = TRUE;

    //SendDebugMessage("HouseBuyWebhook: " + sDescription);
    sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discord.com", Get2DAString("env", "Value", 2), stMessage);
    SendDiscordLogMessage(sConstructedMsg);
}


void QuestCompleteWebhook(object oPC, string sQuestName);
void QuestCompleteWebhook(object oPC, string sQuestName)
{
    string sConstructedMsg;
    string sName = GetName(oPC);
    struct NWNX_WebHook_Message stMessage;

    // PC has purchased a house in Area for Gold!
    string sTitle = "QUEST COMPLETED";
    string sDescription = "**" + sName + "** has completed " + sQuestName + "!";
    int nPlayers = GetPlayerCount();

    stMessage.sUsername = SERVER_BOT;
    stMessage.sTitle = sTitle;
    stMessage.sColor = QUEST_COMPLETE_COLOR;
    stMessage.sAuthorName = sName;
    stMessage.sAuthorIconURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oPC)) + "t.png";
    stMessage.sThumbnailURL = "https://nwn.sfo2.digitaloceanspaces.com/portrait/" + GetStringLowerCase(GetPortraitResRef(oPC)) + "m.png";
    stMessage.sDescription = sDescription;

    stMessage.sField1Name = "PLAYERS";
    stMessage.sField1Value = IntToString(nPlayers);
    stMessage.iField1Inline = TRUE;

    stMessage.sField2Name = "ACCOUNT";
    stMessage.sField2Value = GetPCPlayerName(oPC);
    stMessage.iField2Inline = TRUE;

    string sClassLabel = "CLASS";

    if (GetLevelByPosition(2, oPC) > 0)
        sClassLabel = "CLASSES";

    stMessage.sField3Name = sClassLabel;
    stMessage.sField3Value = GetClassesAndLevels(oPC);
    stMessage.iField3Inline = TRUE;

    //SendDebugMessage("QuestCompleteWebhook: " + sDescription);
    sConstructedMsg = NWNX_WebHook_BuildMessageForWebHook("discord.com", Get2DAString("env", "Value", 2), stMessage);
    SendDiscordLogMessage(sConstructedMsg);
}


#include "inc_xp"
#include "inc_debug"
#include "inc_gold"
#include "inc_loot"
#include "inc_treasure"
#include "inc_persist"
#include "util_i_csvlists"
#include "inc_sqlite_time"
#include "inc_webhook"

const float AOE_QUEST_SIZE = 75.0;

const int BLUFF_CHAOS_SHIFT = 4;

const int BOUNTY_RESET_TIME =  21600; // 6 hours

// 0xffdc14 - a slightly darkened yellow
const int HILITE_QUEST_ELIGIBLE = 16768020;
const string QUEST_GIVER_NAME_COLOR = "<c\xff\xdc\x14>";
// A light green
const string QUEST_ITEM_NAME_COLOR = "<c\xb9\xff\xb9>";

// Max number of quest_X variables to check per creature
const int HIGHEST_QUEST_COUNT = 20;

// Set a player's quest entry.
void SetQuestEntry(object oPC, string sQuestEntry, int nValue);

// Attempts to advance a quest based on variables on an object. quest#: ##_<quest_name>, zero padded.
// Leave quest#_prereq<1-9> for no prerequisite quest stages.
// quest#_reward_xp_tier, quest#_reward_xp_level, quest#_reward_gold
// quest#_reward_item - must be a resref
void AdvanceQuest(object oQuestObject, object oPC, int nTarget, int bBluff = FALSE);

// Same as advance quest, but in an AoE sphere.
void AdvanceQuestSphere(object oQuestObject, int nTarget, float fRadius = 30.0);

// if the PC is NOT at quest#: ##_<quest_name>, zero padded
// and quest#_prereq<1-9>: ##_<quest_name>, zero padded is met, return TRUE
// if bBluff, allow skipping of one quest stage
int GetIsQuestStageEligible(object oQuestObject, object oPC, int nTarget, int bBluff = FALSE);

// Returns TRUE if the PC is at or past quest#: ##_<quest_name>, zero padded
int GetIsAtQuestStage(object oQuestObject, object oPC, int nTarget);

// Returns TRUE if the PC is currently at quest#: ##_<quest_name>, zero padded
int GetIsCurrentlyAtQuestStage(object oQuestObject, object oPC, int nTarget);

// Get the PC's quest entry by string. Returns quest stage.
int GetQuestEntry(object oPC, string sQuestEntry, int bForceJournal = FALSE);

// Refreshes the PC's completed bounties
void RefreshCompletedBounties(object oPC, int nTime, string sList);

// Update the hilite colour overrides for quest creatures in oArea for oPC.
void UpdateQuestgiverHighlights(object oArea, object oPC);

// True of oPC is eligible for a quest stage handed out by oNPC.
// Also ignores "no highlight" quests.
int IsPCEligibleForQuestFromNPC(object oNPC, object oPC);

// Variables on quest givers/items:

// You refer to specific stages of quests with<stage, zero padded to 2 chars>_<journal tag>

// questX -> <quest stage>
// questX_prereqY -> <quest stage>
// questX_reward_item -> resref of item to give
// questX_reward_gold -> base gold, modified by Cha
// questX_pc_script -> script name to be executed on the PC advancing the quest
// questX_self_script -> script name to be executed on the NPC or thing advancing the quest
// questX_reward_xp_level -> level to reward XP for, should be about the level PCs are expected to be when doing this
// questX_reward_xp_tier -> a value 1-4, 1 is a very minor task. XP doubles every increase to this value
// questX_nohighlight -> 1. This makes it so that the questgiver doesn't get a yellow highlight for PCs eligible to reach questX's quest stage
//                          Used for NPCs that need to check quest states (eg a gate guard) but don't actually advance PCs to them.
// questX_jumpstage -> 1. Normally, in order to be eligible for a quest stage, the PC has to be at the stage directly before.
//                        (02_q_example would require a pc to have 01_q_example). This bypasses that, and allows "skipping"
//                        values, but only if the new stage number is HIGHER than the old.


// -------------------------------------------------------------------------
// FUNCTIONS
// -------------------------------------------------------------------------

int GetQuestEntry(object oPC, string sQuestEntry, int bForceJournal = FALSE)
{
    int nQuestInt = SQLocalsPlayer_GetInt(oPC, sQuestEntry);

    if (nQuestInt > 0 && (bForceJournal || GetLocalInt(oPC, "NW_JOURNAL_ENTRY"+sQuestEntry) < nQuestInt)) AddJournalQuestEntry(sQuestEntry, nQuestInt, oPC, FALSE, FALSE, TRUE);


    return nQuestInt;
}

void GetQuestEntries(object oPC)
{
    string sList = GetLocalString(GetModule(), "quests");

    int i;
    for (i = 0; i < CountList(sList); i++)
        GetQuestEntry(oPC, GetListItem(sList, i), TRUE);

    sList = GetLocalString(GetModule(), "bounties");

    for (i = 0; i < CountList(sList); i++)
        GetQuestEntry(oPC, GetListItem(sList, i), TRUE);
}

void RefreshCompletedBounty(object oPC, string sQuest, int nTime)
{
// Failsafe to do this for bounties only
    if (GetStringLeft(sQuest, 2) != "b_") return;

    string sReset = sQuest+"_reset";
    int nReset = SQLocalsPlayer_GetInt(oPC, sReset);

    if (nReset > 0 && ((nTime >= nReset) || (GetIsDevServer() && GetIsDeveloper(oPC))))
    {
        SQLocalsPlayer_DeleteInt(oPC, sReset);
        SQLocalsPlayer_DeleteInt(oPC, sQuest);
        RemoveJournalQuestEntry(sQuest, oPC, FALSE);
        FloatingTextStringOnCreature("*One of your completed bounties is available again.*", oPC, FALSE);
    }
}

void RefreshCompletedBounties(object oPC, int nTime, string sList)
{
    int i;
    for (i = 0; i < CountList(sList); i++)
        RefreshCompletedBounty(oPC, GetListItem(sList, i), nTime);
}

void SetQuestEntry(object oPC, string sQuestEntry, int nValue)
{
// Fail safe to not override the quest entry if set lower.
    if (SQLocalsPlayer_GetInt(oPC, sQuestEntry) >= nValue) return;

    SQLocalsPlayer_SetInt(oPC, sQuestEntry, nValue);
    GetQuestEntry(oPC, sQuestEntry);
}

int GetIsAtQuestStage(object oQuestObject, object oPC, int nTarget)
{
    string sQuestTarget = "quest"+IntToString(nTarget);

    string sQuest = GetLocalString(oQuestObject, sQuestTarget);
    string sQuestName = GetSubString(sQuest, 3, 27);
    int nQuestStage = StringToInt(GetSubString(sQuest, 0, 2));

// must be 1 or higher or it won't show
    if (nQuestStage < 1) return FALSE;

    if (GetQuestEntry(oPC, sQuestName) >= nQuestStage) return TRUE;

    return FALSE;
}

int GetIsCurrentlyAtQuestStage(object oQuestObject, object oPC, int nTarget)
{
    string sQuestTarget = "quest"+IntToString(nTarget);

    string sQuest = GetLocalString(oQuestObject, sQuestTarget);
    string sQuestName = GetSubString(sQuest, 3, 27);
    int nQuestStage = StringToInt(GetSubString(sQuest, 0, 2));

// must be 1 or higher or it won't show
    if (nQuestStage < 1) return FALSE;

    if (GetQuestEntry(oPC, sQuestName) == nQuestStage) return TRUE;

    return FALSE;
}

int GetIsQuestStageEligible(object oQuestObject, object oPC, int nTarget, int bBluff = FALSE)
{
    string sQuestTarget = "quest"+IntToString(nTarget);

    string sQuest = GetLocalString(oQuestObject, sQuestTarget);
    string sQuestName = GetSubString(sQuest, 3, 27);
    int nQuestStage = StringToInt(GetSubString(sQuest, 0, 2));
    //SendMessageToPC(oPC, "Stage = " + IntToString(nQuestStage) + ", entry = " + IntToString(GetQuestEntry(oPC, sQuestName)));
// Player must be behind by 1 of their quest entry. Skipped on bluff.

    int bJump = GetLocalInt(oQuestObject, sQuestTarget + "_jumpstage");

    int nCurrent = GetQuestEntry(oPC, sQuestName);
    if (bJump)
    {
        if (nQuestStage <= nCurrent) return FALSE;
    }
    else if (!bBluff && nCurrent != (nQuestStage-1)) return FALSE;

    int i;
    for (i = 1; i < HIGHEST_QUEST_COUNT; i++)
    {
// return if there is a prerequisite quest stage and the player does not meet it
        string sPrereqQuest = GetLocalString(oQuestObject, sQuestTarget+"_prereq"+IntToString(i));
        string sPrereqQuestName = GetSubString(sPrereqQuest, 3, 27);
        int nPrereqQuestStage = StringToInt(GetSubString(sPrereqQuest, 0, 2));

        if ((sPrereqQuestName != "") && (nPrereqQuestStage > 0) && (GetQuestEntry(oPC, sPrereqQuestName) < nPrereqQuestStage))
        {
            return FALSE;
            break;
        }
    }

    if (GetIsAtQuestStage(oQuestObject, oPC, nTarget) == TRUE) return FALSE;
    return TRUE;
}


void AdvanceQuest(object oQuestObject, object oPC, int nTarget, int bBluff = FALSE)
{
    if (GetIsQuestStageEligible(oQuestObject, oPC, nTarget, bBluff) != TRUE) return;

    string sQuestTarget = "quest"+IntToString(nTarget);

    string sQuest = GetLocalString(oQuestObject, sQuestTarget);
    string sQuestName = GetSubString(sQuest, 3, 27);
    int nQuestStage = StringToInt(GetSubString(sQuest, 0, 2));

// Set the quest stage for the PC
    SetQuestEntry(oPC, sQuestName, nQuestStage);

// if there is a pc script for this stage, execute it on thepc
    string sPCScript = GetLocalString(oQuestObject, sQuestTarget+"_pc_script");
    if (sPCScript != "") ExecuteScript(sPCScript, oPC);

// if there is a self script for this stage, execute it on itself
    string sScript = GetLocalString(oQuestObject, sQuestTarget+"_self_script");
    if (sScript != "") ExecuteScript(sScript);

// if there is an XP tier and level, give it to them
    int nXPLevel = GetLocalInt(oQuestObject, sQuestTarget+"_reward_xp_level");
    int nXPTier = GetLocalInt(oQuestObject, sQuestTarget+"_reward_xp_tier");

    if (nXPTier > 0 && nXPLevel > 0) GiveQuestXPToPC(oPC, nXPTier, nXPLevel, bBluff);

// if there is an item to reward, give
    string sRewardItem = GetLocalString(oQuestObject, sQuestTarget+"_reward_item");

    if (sRewardItem != "")
    {
        object oItem = CreateItemOnObject(sRewardItem, oPC, 1);
        InitializeItem(oItem);
        SetIdentified(oItem, TRUE);
    }

// if there is a gold reward...
    int nRewardGold = CharismaModifiedGold(oPC, GetLocalInt(oQuestObject, sQuestTarget+"_reward_gold"));

    if (nRewardGold > 0)
    {
        GiveGoldToCreature(oPC, nRewardGold);
    }

    if (GetStringLeft(sQuestName, 2) == "b_" && NWNX_Player_GetQuestCompleted(oPC, sQuestName))
    {
        string sVar = sQuestName+"_reset";

        if (SQLocalsPlayer_GetInt(oPC, sVar) == 0) SQLocalsPlayer_SetInt(oPC, sVar, SQLite_GetTimeStamp()+BOUNTY_RESET_TIME);
    }

    if (GetObjectType(oQuestObject) == OBJECT_TYPE_ITEM)
        FloatingTextStringOnCreature("*You stash away "+GetName(oQuestObject)+" for safe keeping*", oPC, FALSE);

    struct NWNX_Player_JournalEntry jeQuest = NWNX_Player_GetJournalEntry(oPC, sQuestName);
    if (GetStringLeft(sQuestName, 2) != "b_" && jeQuest.nQuestCompleted)
    {
        QuestCompleteWebhook(oPC, jeQuest.sName, oQuestObject);
    }

    // record stat for bounties
    if (GetStringLeft(sQuestName, 2) == "b_" && jeQuest.nQuestCompleted)
    {
        IncrementPlayerStatistic(oPC, "bounties_completed");
    }
    else if (jeQuest.nQuestCompleted)
    {
        IncrementPlayerStatistic(oPC, "quests_completed");
    }

    UpdateQuestgiverHighlights(GetArea(oQuestObject), oPC);
}

void AdvanceQuestSphere(object oQuestObject, int nTarget, float fRadius = 30.0)
{
    location lLocation = GetLocation(oQuestObject);

    object oPC = GetFirstObjectInShape(SHAPE_SPHERE, fRadius, lLocation, FALSE, OBJECT_TYPE_CREATURE);

    while (GetIsObjectValid(oPC))
    {
        if (GetIsPC(oPC)) AdvanceQuest(oQuestObject, oPC, 1);

        oPC = GetNextObjectInShape(SHAPE_SPHERE, fRadius, lLocation, FALSE, OBJECT_TYPE_CREATURE);
    }
}

int IsPCEligibleForQuestFromNPC(object oNPC, object oPC)
{
    //SendMessageToPC(GetFirstPC(), "Found a PC");
    int i;
    for (i = 1; i < HIGHEST_QUEST_COUNT; i++)
    {
        if (!GetLocalInt(oNPC, "quest" + IntToString(i) + "_nohighlight"))
        {
            if (GetIsQuestStageEligible(oNPC, oPC, i))
            {
                return 1;
            }
        }
    }
    return 0;
}

void ClearAllQuestgiverHighlightsInAreaForPC(object oArea, object oPC)
{
    string sList = GetLocalString(oArea, "quest_npcs");
    int nCount = CountList(sList);
    int i;
    for (i=0; i<nCount; i++)
    {
        object oGiver = StringToObject(GetListItem(sList, i));
        if (GetIsObjectValid(oGiver))
        {
            NWNX_Player_SetCreatureNameOverride(oPC, oGiver, "");
            NWNX_Player_SetObjectHiliteColorOverride(oPC, oGiver, -1);
        }
    }
}

void UpdateQuestgiverHighlights(object oArea, object oPC)
{
    string sList = GetLocalString(oArea, "quest_npcs");
    int nCount = CountList(sList);
    int i;
    for (i=0; i<nCount; i++)
    {
        object oGiver = StringToObject(GetListItem(sList, i));
        if (GetIsObjectValid(oGiver))
        {
            int nHasQuest = 0;
            int j;
            for (j=0; j<HIGHEST_QUEST_COUNT; j++)
            {
                if (GetIsQuestStageEligible(oGiver, oPC, j) && !GetLocalInt(oGiver, "quest" + IntToString(j) + "_nohighlight"))
                {
                    nHasQuest = 1;
                    break;
                }
            }

            if (nHasQuest)
            {
                NWNX_Player_SetCreatureNameOverride(oPC, oGiver, QUEST_GIVER_NAME_COLOR + GetName(oGiver) + "</c>");
                NWNX_Player_SetObjectHiliteColorOverride(oPC, oGiver, HILITE_QUEST_ELIGIBLE);
            }
            else
            {
                NWNX_Player_SetCreatureNameOverride(oPC, oGiver, "");
                NWNX_Player_SetObjectHiliteColorOverride(oPC, oGiver, -1);
            }
        }
    }
}

//void main(){}

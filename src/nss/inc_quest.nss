#include "inc_xp"
#include "inc_gold"
#include "inc_loot"
#include "inc_treasure"
#include "inc_persist"
#include "util_i_csvlists"
#include "nwnx_time"

const float AOE_QUEST_SIZE = 75.0;

const int BOUNTY_RESET_TIME =  21600; // 6 hours

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

    if (nReset > 0 && nTime >= nReset)
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

// Player must be behind by 1 of their quest entry. Skipped on bluff.
    if (!bBluff && GetQuestEntry(oPC, sQuestName) != (nQuestStage-1)) return FALSE;

    int i;
    for (i = 1; i < 10; i++)
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

        if (SQLocalsPlayer_GetInt(oPC, sVar) == 0) SQLocalsPlayer_SetInt(oPC, sVar, NWNX_Time_GetTimeStamp()+BOUNTY_RESET_TIME);
    }

    FloatingTextStringOnCreature("*Your journal has been updated*", oPC, FALSE);
    if (GetObjectType(oQuestObject) == OBJECT_TYPE_ITEM)
        FloatingTextStringOnCreature("*You stash away "+GetName(oQuestObject)+" for safe keeping*", oPC, FALSE);
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

//void main(){}

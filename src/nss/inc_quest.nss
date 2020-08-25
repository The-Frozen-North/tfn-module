#include "inc_xp"
#include "inc_gold"
#include "inc_loot"
#include "inc_treasure"
#include "inc_persist"

const float AOE_QUEST_SIZE = 75.0;

const int BOUNTY_RESET_TIME =  21600; // 6 hours

// Set a player's quest entry.
void SetQuestEntry(object oPC, string sQuestEntry, int nValue);

// Attempts to advance a quest based on variables on an object. quest#: ##_<quest_name>, zero padded.
// Leave quest#_prereq<1-9> for no prerequisite quest stages.
// quest#_reward_xp_tier, quest#_reward_xp_level, quest#_reward_gold
// quest#_reward_item - must be a resref
void AdvanceQuest(object oQuestObject, object oPC, int nTarget, int bPersuadeBonusGold = FALSE);

// Same as advance quest, but in an AoE sphere.
void AdvanceQuestSphere(object oQuestObject, int nTarget, float fRadius = 30.0);

// if the PC is NOT at quest#: ##_<quest_name>, zero padded
// and quest#_prereq<1-9>: ##_<quest_name>, zero padded is met, return TRUE
int GetIsQuestStageEligible(object oQuestObject, object oPC, int nTarget);

// Returns TRUE if the PC is at or past quest#: ##_<quest_name>, zero padded
int GetIsAtQuestStage(object oQuestObject, object oPC, int nTarget);

// Returns TRUE if the PC is currently at quest#: ##_<quest_name>, zero padded
int GetIsCurrentlyAtQuestStage(object oQuestObject, object oPC, int nTarget);

// Get the PC's quest entry by string. Returns quest stage.
int GetQuestEntry(object oPC, string sQuestEntry);

// Refreshes the PC's completed bounties
void RefreshCompletedBounties(object oPC, int nTime);

// -------------------------------------------------------------------------
// FUNCTIONS
// -------------------------------------------------------------------------

int GetQuestEntry(object oPC, string sQuestEntry)
{
    int nQuestInt = NWNX_Object_GetInt(oPC, sQuestEntry);

    if (nQuestInt > 0) AddJournalQuestEntry(sQuestEntry, nQuestInt, oPC, FALSE);

    return nQuestInt;
}

void GetQuestEntries(object oPC)
{
    GetQuestEntry(oPC, "b_mummy");
    GetQuestEntry(oPC, "b_wererat");

    GetQuestEntry(oPC, "q_rescue");
    GetQuestEntry(oPC, "q_brother");
    GetQuestEntry(oPC, "q_kidnapped");
    GetQuestEntry(oPC, "q_animal_rescue");

    GetQuestEntry(oPC, "q_undead_infestation");
    GetQuestEntry(oPC, "q_combat_training");
    GetQuestEntry(oPC, "q_sword_coast_boys");
    GetQuestEntry(oPC, "q_wailing");
    GetQuestEntry(oPC, "q_maze");
    GetQuestEntry(oPC, "q_prison_riot");

    GetQuestEntry(oPC, "q_cockatrice");
    GetQuestEntry(oPC, "q_dryad");
    GetQuestEntry(oPC, "q_pureblood");
    GetQuestEntry(oPC, "q_intellect");
}

void RefreshCompletedBounty(object oPC, string sQuest, int nTime)
{
// Failsafe to do this for bounties only
    if (GetStringLeft(sQuest, 2) != "b_") return;

    string sReset = sQuest+"_reset";
    int nReset = NWNX_Object_GetInt(oPC, sReset);

    if (nReset > 0 && nTime >= nReset)
    {
        NWNX_Object_DeleteInt(oPC, sReset);
        NWNX_Object_DeleteInt(oPC, sQuest);
        RemoveJournalQuestEntry(sQuest, oPC, FALSE);
        FloatingTextStringOnCreature("*One of your completed bounties is available again.*", oPC, FALSE);
    }
}

void RefreshCompletedBounties(object oPC, int nTime)
{
    RefreshCompletedBounty(oPC, "b_mummy", nTime);
    RefreshCompletedBounty(oPC, "b_wererat", nTime);
}

void SetQuestEntry(object oPC, string sQuestEntry, int nValue)
{
// Fail safe to not override the quest entry if set lower.
    if (NWNX_Object_GetInt(oPC, sQuestEntry) >= nValue) return;

    NWNX_Object_SetInt(oPC, sQuestEntry, nValue, TRUE);
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

int GetIsQuestStageEligible(object oQuestObject, object oPC, int nTarget)
{
    string sQuestTarget = "quest"+IntToString(nTarget);

    string sQuest = GetLocalString(oQuestObject, sQuestTarget);
    string sQuestName = GetSubString(sQuest, 3, 27);
    int nQuestStage = StringToInt(GetSubString(sQuest, 0, 2));

// Player must be behind by 1 of their quest entry
    if (GetQuestEntry(oPC, sQuestName) != (nQuestStage-1)) return FALSE;

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


void AdvanceQuest(object oQuestObject, object oPC, int nTarget, int bPersuadeBonusGold = FALSE)
{
    if (GetIsQuestStageEligible(oQuestObject, oPC, nTarget) != TRUE) return;

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

    if (nXPTier > 0 && nXPLevel > 0) GiveQuestXPToPC(oPC, nXPTier, nXPLevel);

// if there is an item to reward, give
    string sRewardItem = GetLocalString(oQuestObject, sQuestTarget+"_reward_item");

    if (sRewardItem != "")
    {
        object oItem = CreateItemOnObject(sRewardItem, oPC, 1);
        AddEnchantedWeightReduction(oItem);
        SetIdentified(oItem, TRUE);
    }

// if there is a gold reward...
    int nRewardGold = CharismaModifiedGold(oPC, GetLocalInt(oQuestObject, sQuestTarget+"_reward_gold"));

    if (nRewardGold > 0)
    {
// alter the amount of bonus gold if present. typically used for persuade
        if (bPersuadeBonusGold == TRUE) nRewardGold = FloatToInt(IntToFloat(nRewardGold) * PERSUADE_BONUS_MODIFIER);
        GiveGoldToCreature(oPC, nRewardGold);
    }

    if (GetStringLeft(sQuestName, 2) == "b_" && NWNX_Player_GetQuestCompleted(oPC, sQuestName))
    {
        string sVar = sQuestName+"_reset";

        if (NWNX_Object_GetInt(oPC, sVar) == 0) NWNX_Object_SetInt(oPC, sVar, NWNX_Time_GetTimeStamp()+BOUNTY_RESET_TIME, TRUE);
    }

    FloatingTextStringOnCreature("*Your journal has been updated*", oPC, FALSE);
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

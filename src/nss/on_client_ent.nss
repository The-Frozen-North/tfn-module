#include "inc_quest"
#include "inc_henchman"
#include "x3_inc_string"
#include "inc_nwnx"
#include "nwnx_damage"

void CreateItemIfBlank(object oPC, string sItem)
{
    object oItem = GetItemPossessedBy(oPC, sItem);

    if (!GetIsObjectValid(oItem))
    {
        oItem = CreateItemOnObject(sItem, oPC, 1);
        SetItemCursedFlag(oItem, TRUE);
        SetDroppableFlag(oItem, FALSE);
        SetPickpocketableFlag(oItem, FALSE);
        SetPlotFlag(oItem, TRUE);
    }
}

void main()
{
    object oPC = GetEnteringObject();

    string sType = "player";

    if (GetIsDM(oPC)) sType = "dungeon master";

    object oPCCount = GetFirstPC();
    int nPCs = 0;

    while (GetIsObjectValid(oPCCount))
    {
        nPCs = nPCs + 1;
        oPCCount = GetNextPC();
    }

    string sMessage = PlayerDetailedName(oPC)+" has entered the game as a "+sType;

    WriteTimestampedLogEntry(sMessage);

    SendDiscordLogMessage(sMessage+" - there " + (nPCs == 1 ? "is" : "are") + " now " + IntToString(nPCs) + " player" + (nPCs == 1 ? "" : "s") + " online.");

// assign the PC a UUID if it doesn't have one
    GetObjectUUID(oPC);

// Do this only for PCs
    if (!GetIsPC(oPC)) return;

    NWNX_Damage_SetAttackEventScript("pc_attack", oPC);
    SetEventScript(oPC, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "on_pc_damaged");

    DeleteLocalInt(oPC,"70_applied_darkvision");
    DeleteLocalInt(oPC,"70_applied_lowlightvision");
    ExecuteScript("70_featfix",oPC);

    //SetEventScript(oPC,EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED,"70_mod_attacked");
    //SetEventScript(oPC,EVENT_SCRIPT_CREATURE_ON_DAMAGED,"70_mod_damaged");

// If the PC has more than 0 XP, then do this.
// Safe to assume a non-new character in this way.
    if (GetXP(oPC) > 0)
    {
        GetQuestEntries(oPC);
        RefreshCompletedBounties(oPC, NWNX_Time_GetTimeStamp(), GetLocalString(GetModule(), "bounties"));

// henchman need to be rehired as they are "fired" when logging out
        RehireHenchman(oPC);

        int nCurrentHP = GetCurrentHitPoints(oPC);
        int nStoredHP = NWNX_Object_GetInt(oPC, "CURRENT_HP");

// if the stored hp is 0 or less, assume some kind of error or the variable doesnt exist
// in that case make it the current hp
        if (nStoredHP <= 0) nStoredHP = nCurrentHP;


// kill player if marked as dead
        if (NWNX_Object_GetInt(oPC, "DEAD") == 1)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), oPC);
        }
// otherwise, handle hp
        else
        {
            NWNX_Object_SetCurrentHitPoints(oPC, nStoredHP);
        }
    }
// otherwise, assume they're new and do the whole new PC routine
    else
    {
        DelayCommand(0.01, ExecuteScript("new_character", oPC));
    }

    SetQuestEntry(oPC, "q_wailing", 1);

    DelayCommand(4.0, CreateItemIfBlank(oPC, "_pc_handbook"));
    DelayCommand(4.5, CreateItemIfBlank(oPC, "_dev_tool"));
    DelayCommand(5.0, FloatingTextStringOnCreature("Welcome to The Frozen North!", oPC, FALSE));
    DelayCommand(6.0, FloatingTextStringOnCreature("Please read your \"Adventurer's Handbook\" for rules and information.", oPC, FALSE));
    DelayCommand(7.0, FloatingTextStringOnCreature("https://discord.gg/qKqRUDZ", oPC, FALSE));

}

#include "1_inc_quest"
#include "1_inc_henchman"
#include "x3_inc_string"
#include "1_inc_nwnx"

void StripItems(object oPC)
{
    int nSlot;

    // Destroy the items in the main inventory.
    object oItem = GetFirstItemInInventory(oPC);
    while ( oItem != OBJECT_INVALID ) {
        DestroyObject(oItem);
        oItem = GetNextItemInInventory(oPC);
    }
    // Destroy equipped items.
    for ( nSlot = 0; nSlot < NUM_INVENTORY_SLOTS; ++nSlot )
        DestroyObject(GetItemInSlot(nSlot, oPC));

    // Remove all gold.
    AssignCommand(oPC, TakeGoldFromCreature(GetGold(oPC), oPC, TRUE));
}

void CreateBook(object oPC)
{
    object oBook = GetItemPossessedBy(oPC, "_pc_handbook");

    if (!GetIsObjectValid(oBook))
    {
        oBook = CreateItemOnObject("_pc_handbook", oPC, 1);
        SetItemCursedFlag(oBook, TRUE);
        SetDroppableFlag(oBook, FALSE);
        SetPickpocketableFlag(oBook, FALSE);
        SetPlotFlag(oBook, TRUE);
    }
}

void main()
{
    object oPC = GetEnteringObject();

    string sMessage = PlayerDetailedName(oPC)+" has entered the game.";

    WriteTimestampedLogEntry(sMessage);

    SendDiscordLogMessage(sMessage);

// assign the PC a UUID if it doesn't have one
    GetObjectUUID(oPC);

// Do this only for PCs
    if (!GetIsPC(oPC)) return;

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

// henchman need to be rehired as they are "fired" when logging out
        RehireHenchman(oPC);

// retrieve their saved location
        float fLocX = NWNX_Object_GetFloat(oPC, "LOC_X");
        float fLocY = NWNX_Object_GetFloat(oPC, "LOC_Y");
        float fLocZ = NWNX_Object_GetFloat(oPC, "LOC_Z");
        float fLocO = NWNX_Object_GetFloat(oPC, "LOC_O");
        string fLocA = NWNX_Object_GetString(oPC, "LOC_A");

        location lLocation = Location(GetObjectByTag(fLocA), Vector(fLocX, fLocY, fLocZ), fLocO);

        DelayCommand(2.0, AssignCommand(oPC, JumpToLocation(lLocation)));

        int nCurrentHP = GetCurrentHitPoints(oPC);
        int nStoredHP = NWNX_Object_GetInt(oPC, "CURRENT_HP");

// if the stored hp is 0 or less, assume some kind of error or the variable doesnt exist
// in that case make it the current hp
        if (nStoredHP <= 0) nStoredHP = nCurrentHP;


// kill player if marked as dead
        if (NWNX_Object_GetInt(oPC, "DEAD") == 1)
        {
            DelayCommand(4.5, ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), oPC));
        }
// otherwise, handle hp
        else
        {
            DelayCommand(4.5, NWNX_Object_SetCurrentHitPoints(oPC, nStoredHP));
        }
    }
// otherwise, assume they're new and do the whole new PC routine
    else
    {
        StripItems(oPC);
        DelayCommand(0.01, ExecuteScript("3_new_character", oPC));
    }

    SetQuestEntry(oPC, "q_wailing", 1);

    DelayCommand(4.0, CreateBook(oPC));
    DelayCommand(5.0, FloatingTextStringOnCreature("Welcome to The Frozen North!", oPC, FALSE));
    DelayCommand(6.0, FloatingTextStringOnCreature("Please read your \"Adventurer's Handbook\" for rules and information.", oPC, FALSE));
    DelayCommand(7.0, FloatingTextStringOnCreature("https://discord.gg/qKqRUDZ", oPC, FALSE));

}

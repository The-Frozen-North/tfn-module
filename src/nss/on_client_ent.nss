#include "inc_quest"
#include "inc_henchman"
#include "x3_inc_string"
#include "inc_webhook"
#include "nwnx_damage"
#include "nwnx_item"
#include "inc_nwnx"
#include "inc_general"
#include "inc_sqlite_time"
#include "inc_mappin"
#include "inc_housing"
#include "inc_horse"
#include "inc_restxp"
#include "inc_itemupdate"
#include "nwnx_feedback"

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

    if (!GetHasEffect(EFFECT_TYPE_POLYMORPH))
    {
        SetLocalInt(OBJECT_SELF, "BASE_RACE_SET", 1);
        SetLocalInt(OBJECT_SELF, "BASE_RACE", GetRacialType(oPC));
    }

    SetCampaignString(GetPCPublicCDKey(oPC), "player_name", GetPCPlayerName(oPC));

    InitializeHouseMapPin(oPC);

    AddRestedXPOnLogin(oPC);

    string sType = "player";
    string sMessage = PlayerDetailedName(oPC)+" has entered the game as a "+sType;

    // Remove DM entangle effects
    if (GetIsDM(oPC))
    {
        effect e = GetFirstEffect(oPC);
        while (GetIsEffectValid(e))
        {
            if (GetEffectType(e) == EFFECT_TYPE_VISUALEFFECT &&
                GetEffectInteger(e, 0) == VFX_DUR_ENTANGLE)
                RemoveEffect(oPC, e);

            e = GetNextEffect(oPC);
        }
    }

    // Map Pins
    MapPin_LoadPCMapPins(oPC);

    WriteTimestampedLogEntry(sMessage);
    LogWebhook(oPC, LOG_IN);

// assign the PC a UUID if it doesn't have one
    GetObjectUUID(oPC);

// Do this only for PCs
    if (!GetIsPC(oPC)) return;

    SetEventScript(oPC, EVENT_SCRIPT_CREATURE_ON_DAMAGED, "on_pc_damaged");
    SetEventScript(oPC, EVENT_SCRIPT_CREATURE_ON_BLOCKED_BY_DOOR, "on_pc_blocked");
    SetEventScript(oPC, EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED, "on_pc_spellcast");
    SetEventScript(oPC, EVENT_SCRIPT_CREATURE_ON_SPELLCASTAT, "on_pc_attacked");
    GiveHiPSFeatSafely(oPC);

// these items are deprecated
    DestroyObject(GetItemPossessedBy(oPC, "_pc_handbook"));
    DestroyObject(GetItemPossessedBy(oPC, "_stone_recall"));
    DestroyObject(GetItemPossessedBy(oPC, "_unstucker"));

    DeleteLocalInt(oPC, "ambushed");

    DeleteLocalInt(oPC,"70_applied_darkvision");
    DeleteLocalInt(oPC,"70_applied_lowlightvision");
    DeleteLocalInt(oPC, "healers_kit_cd");
    ExecuteScript("70_featfix",oPC);

    DetermineHorseEffects(oPC);

    // NWNX_FEEDBACK_COMBAT_RUNNING_OUT_OF_AMMO = 24
    NWNX_Feedback_SetFeedbackMessageHidden(24, 1, oPC);

    //SetEventScript(oPC,EVENT_SCRIPT_CREATURE_ON_MELEE_ATTACKED,"70_mod_attacked");
    //SetEventScript(oPC,EVENT_SCRIPT_CREATURE_ON_DAMAGED,"70_mod_damaged");

// If the PC has more than 0 XP, then do this.
// Safe to assume a non-new character in this way.
    if (GetXP(oPC) > 0)
    {
        GetQuestEntries(oPC);
        RefreshCompletedBounties(oPC, SQLite_GetTimeStamp(), GetLocalString(GetModule(), "bounties"));

// henchman need to be rehired as they are "fired" when logging out
        RehireHenchman(oPC);

        int nCurrentHP = GetCurrentHitPoints(oPC);
        int nStoredHP = SQLocalsPlayer_GetInt(oPC, "CURRENT_HP");

// only do this if PCs aren't dead and this is their first log-in
        if (!GetIsDead(oPC) && nStoredHP > 0)
            DetermineDeathEffectPenalty(oPC, nStoredHP);

// if the stored hp is 0 or less, assume some kind of error or the variable doesnt exist
// in that case make it the current hp
        if (nStoredHP <= 0) nStoredHP = nCurrentHP;


// kill player if marked as dead
        if (SQLocalsPlayer_GetInt(oPC, "DEAD") == 1)
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectDeath(), oPC);
        }
        else if (SQLocalsPlayer_GetInt(oPC, "PETRIFIED") == 1)
        {
            DelayCommand(0.05, ApplyEffectToObject(DURATION_TYPE_PERMANENT, EffectPetrify(), oPC));
        }
// otherwise, handle hp
        else
        {
            SetCurrentHitPoints(oPC, nStoredHP);
        }

        // Items you can't drop shouldn't have weight
        object oTest = GetFirstItemInInventory(oPC);
        while (GetIsObjectValid(oTest))
        {
            if (GetPlotFlag(oTest))
            {
                NWNX_Item_SetWeight(oTest, 0);
            }
            oTest = GetNextItemInInventory(oPC);
        }
    }
// otherwise, assume they're new and do the whole new PC routine
    else
    {
        DelayCommand(0.01, ExecuteScript("new_character", oPC));
    }

    SetQuestEntry(oPC, "q_wailing", 1);

    if (GetIsDeveloper(oPC))
    {
        DelayCommand(4.0, CreateItemIfBlank(oPC, "_dev_tool"));
    }
    else
    {
        DestroyObject(GetItemPossessedBy(oPC, "_dev_tool"));
    }

    
    DelayCommand(4.0, CreateItemIfBlank(oPC, "_pc_menu_toggler"));
    DelayCommand(5.0, FloatingTextStringOnCreature("Welcome to The Frozen North!", oPC, FALSE));
    DelayCommand(6.0, FloatingTextStringOnCreature("Please read the \"Information\" tab on the player menu for rules and information.", oPC, FALSE));
    DelayCommand(7.0, FloatingTextStringOnCreature("https://discord.gg/qKqRUDZ", oPC, FALSE));
    string sRespawn = SQLocalsPlayer_GetString(oPC, "respawn");
    if (sRespawn != "")
    {
        sRespawn = GetRespawnLocationName(oPC);
        DelayCommand(9.0, FloatingTextStringOnCreature("You have chosen to respawn in " + sRespawn + ".", oPC, FALSE));
    }
    
    ShowOrHideXPBarUI(oPC);
    UpdatePCOwnedItemProperties(oPC);
}

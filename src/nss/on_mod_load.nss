#include "x2_inc_switches"
#include "x2_inc_restsys"
#include "inc_treasure"
#include "inc_webhook"
#include "inc_housing"
#include "inc_weather"
#include "inc_merchant"
#include "nwnx_admin"
#include "nwnx_weapon"
#include "nwnx_events"
#include "nwnx_util"
#include "util_i_csvlists"
#include "nwnx_chat"
#include "nwnx_feedback"
#include "inc_sqlite_time"
#include "70_inc_switches"
#include "util_i_csvlists"
#include "inc_prettify"
#include "inc_loot"
#include "inc_areadist"
#include "nwnx_damage"
#include "inc_itemevent"

const int SEED_SPAWNS = 1;
const int SEED_TREASURES = 1;
const int SEED_SPELLBOOKS = 0;
// These two check to see if stuff needs updating before doing it
// Turning them off might shave off 1-2mins from a seeding run but that is about it
// When run from scratch they are by far the slowest of the bunch
const int SEED_AREA_CONNECTIONS = 1; // ~7 minutes if changed else just ~1 minute of area_init loop
const int SEED_PRETTIFY_PLACEABLES = 1; // ~40 minutes
const int SEED_TREASUREMAPS = 1;        // ~4 hours

void LoadTreasureContainer(string sTag, float x = 1.0, float y = 1.0, float z = 1.0)
{
    object oContainer = RetrieveCampaignObject("treasures", sTag, Location(GetObjectByTag("_TREASURE"), Vector(x, y, z), 0.0));
    if (GetIsObjectValid(oContainer)) SendDebugMessage("loaded "+GetName(oContainer));
}

void LoadTreasureContainerByBaseItem(string sTag, float x = 1.0, float y = 1.0, float z = 1.0)
{
    object oContainer = RetrieveCampaignObject("treasures", sTag, Location(GetObjectByTag("_TREASUREBASEITM"), Vector(x, y, z), 0.0));
    if (GetIsObjectValid(oContainer)) SendDebugMessage("loaded "+GetName(oContainer));
}

void SpawnPCBloodstains()
{
    // get ALL the bloodstains, let players leave their "mark" :)
    int i;
    for (i=0; i <= MAX_NUMBER_BLOODSTAINS; i++)
    {
        location lLoc = GetCampaignLocation("pcbloodstains", "Pos" + IntToString(i));

        if (GetIsObjectValid(GetAreaFromLocation(lLoc)))
        {
            CreateObject(OBJECT_TYPE_PLACEABLE, "_pc_bloodstain", lLoc);
        }
    }
}

void EnsureAreaBilateralLinkages()
{
    // Ensure area linkages go both ways
    // This CAN'T BE DONE IN area_init because not all the area tags will be set yet
    // (GetObjectByTag will be a lot more efficient)
    object oArea = GetFirstArea();
    while (GetIsObjectValid(oArea))
    {
        int nLink = 1;
        while (1)
        {
            object oLinked = GetObjectByTag(GetLocalString(oArea, "link" + IntToString(nLink)));
            if (!GetIsObjectValid(oLinked))
            {
                break;
            }
            int nLinkedIndex = 1;
            int bFoundSelf = 0;
            while (1)
            {
                object oLinkedAreaOfOther = GetObjectByTag(GetLocalString(oLinked, "link" + IntToString(nLinkedIndex)));
                if (!GetIsObjectValid(oLinkedAreaOfOther))
                {
                    break;
                }
                if (oLinkedAreaOfOther == oArea)
                {
                    bFoundSelf = 1;
                    break;
                }
                nLinkedIndex++;
            }
            if (!bFoundSelf)
            {
                WriteTimestampedLogEntry("Area " + GetTag(oArea) + " has linked area " + GetTag(oLinked) + " which doesn't link back to it, adding at index " + IntToString(nLinkedIndex));
                SetLocalString(oLinked, "link" + IntToString(nLinkedIndex), GetTag(oArea));
            }
            nLink++;
        }
        oArea = GetNextArea();
    }
}

void InitialiseAreas()
{
    object oArea = GetFirstArea();
    while (GetIsObjectValid(oArea))
   {
       string sAreaResRef = GetResRef(oArea);
// Skip the system areas or copied areas. They are prepended with an underscore.
       if (GetStringLeft(sAreaResRef, 1) == "_")
       {
           oArea = GetNextArea();
           continue;
       }

        // Skip prefab areas
        if (GetStringLeft(GetName(oArea), 8) == "_PREFAB_")
        {
            oArea = GetNextArea();
            continue;
        }

       ExecuteScript("area_init", oArea);

       oArea = GetNextArea();
   }

}

void SeedMonitor()
{
    int nStage = GetLocalInt(GetModule(), "seed_stage");
    int nComplete = GetLocalInt(GetModule(), "seed_complete");
    if (nComplete)
    {
        SetLocalInt(GetModule(), "seed_stage", nStage+1);
        // spawns
        if (nStage == 0)
        {
            // Self-contained, one script instance for now
            if (SEED_SPAWNS)
            {
                DeleteLocalInt(GetModule(), "seed_complete");

                // Destroy the databases to give it a clean slate.
                DestroyCampaignDatabase("spawns");

                object oArea = GetFirstArea();
                string sAreaResRef;

                // Loop through all areas in the module.
                while (GetIsObjectValid(oArea))
                {

                    // Skip the system areas. They are prepended with an underscore.
                    if (GetStringLeft(GetResRef(oArea), 1) == "_")
                    {
                        oArea = GetNextArea();
                        continue;
                    }

                    // Skip prefab areas
                    if (GetStringLeft(GetName(oArea), 8) == "_PREFAB_")
                    {
                        oArea = GetNextArea();
                        continue;
                    }

                    ExecuteScript("seed_area_spawns", oArea);

                    oArea = GetNextArea();

               }
               SetCampaignInt("spawns", "finished", 1);
               SetLocalInt(GetModule(), "seed_complete", 1);
            }
        }
        else if (nStage == 1)
        {
            // Treasures
            // Not self contained, but will set seed_complete when done
            if (SEED_TREASURES)
            {
                DeleteLocalInt(GetModule(), "seed_complete");
                ExecuteScript("seed_treasure");
            }
        }
        else if (nStage == 2)
        {
            // Spellbooks
            // Not self contained, but will set seed_complete when done
            if (SEED_SPELLBOOKS)
            {
                DeleteLocalInt(GetModule(), "seed_complete");
                ExecuteScript("seed_rand_spells");
            }
        }
        else if (nStage == 3)
        {
            // Prettify, self contained for now
            if (SEED_PRETTIFY_PLACEABLES)
            {
               DeleteLocalInt(GetModule(), "seed_complete");
               object oArea = GetFirstArea();
               string sAreaResRef;

               while (GetIsObjectValid(oArea))
               {
                   // This does, surprisingly, manage to TMI without continuously bumping down the VM instruction limit
                   NWNX_Util_SetInstructionsExecuted(0);
                   // Skip the system areas. They are prepended with an underscore.
                   if (GetStringLeft(GetResRef(oArea), 1) == "_")
                   {
                       oArea = GetNextArea();
                       continue;
                   }

                    // Skip prefab areas
                    if (GetStringLeft(GetName(oArea), 8) == "_PREFAB_")
                    {
                        oArea = GetNextArea();
                        continue;
                    }

                   string sScript = GetLocalString(oArea, "prettify_script");
                   if (sScript != "")
                   {
                        if (DoesAreaNeedPrettifySeeding(oArea))
                        {
                            ExecuteScript(sScript, oArea);
                            WriteTimestampedLogEntry("Finished prettify seed script for " + GetResRef(oArea));
                            UpdatePrettifySavedHashForArea(oArea);
                        }
                        else
                        {
                            WriteTimestampedLogEntry(GetResRef(oArea) + "'s tiles are unchanged, no need to reprettify");
                        }
                   }

                   oArea = GetNextArea();

               }
               SetLocalInt(GetModule(), "seed_complete", 1);
            }
        }
        else if (nStage == 4)
        {
            // Treasure maps, self contained for now
            if (SEED_TREASUREMAPS)
            {
                ExecuteScript("seed_treasuremap");
            }
        }
        else if (nStage == 5)
        {
            if (SEED_AREA_CONNECTIONS)
            {
                // This is needed to set up connection lists for all areas
                InitialiseAreas();
                PrepareAreaTransitionDB();
            }
        }
        else
        {
            // Done!
            WriteTimestampedLogEntry("Finished seeding!");
            WriteTimestampedLogEntry("Spawns were " + (SEED_SPAWNS ? "" : "NOT ") + "seeded.");
            WriteTimestampedLogEntry("Treasures were " + (SEED_TREASURES ? "" : "NOT ") + "seeded.");
            WriteTimestampedLogEntry("Random spellbooks were " + (SEED_SPELLBOOKS ? "" : "NOT ") + "seeded.");
            WriteTimestampedLogEntry("Area connections were " + (SEED_AREA_CONNECTIONS ? "" : "NOT ") + "seeded.");
            WriteTimestampedLogEntry("Prettify placeables were " + (SEED_PRETTIFY_PLACEABLES ? "" : "NOT ") + "seeded.");
            WriteTimestampedLogEntry("Treasure map locations were " + (SEED_TREASUREMAPS ? "" : "NOT ") + "seeded.");
            NWNX_Administration_ShutdownServer();
            return;
        }
    }
    DelayCommand(1.0, SeedMonitor());
}

void main()
{
// Set a very high instruction limit so we can run the initialization scripts without TMI
    NWNX_Util_SetInstructionLimit(52428888);

// We do some things different on DEV and local (without NWNX), such as ignoring webhooks and having verbose debug messages
    if ((SQLite_GetTimeStamp() == 0) || FindSubString(NWNX_Administration_GetServerName(), "DEV") > -1)
    {
        SetLocalInt(OBJECT_SELF, "dev", 1);
        SetLocalInt(OBJECT_SELF, "debug_verbose", 1);
    }

    if (FindSubString(NWNX_Administration_GetServerName(), "SEED") > -1)
    {
        // Fix area tags to be their resrefs
        // This is normally done a bit later in module loading
        // This otherwise breaks things relying on area tags and GetAreaByTag later
        // because if you save something with a tag that gets changed, then when it comes to real runtime
        // it changes!
        // And suddenly the efficient search of GetObjectByTag falls flat on its face and you find yourself wanting to loop over areas instaed
        object oArea = GetFirstArea();
        while (GetIsObjectValid(oArea))
        {
            string sResRef = GetResRef(oArea);
            // Skip the system areas or copied areas. They are prepended with an underscore.
            if (GetStringLeft(sResRef, 1) != "_")
            {
                SetTag(oArea, sResRef);

            }

            // Skip prefab areas
            if (GetStringLeft(GetName(oArea), 8) == "_PREFAB_")
            {
                oArea = GetNextArea();
                continue;
            }

            oArea = GetNextArea();
            continue;
        }

        // Set stage complete so the monitor knows to start
        SetLocalInt(OBJECT_SELF, "seed_complete", 1);
        SeedMonitor();



       return;
    }
    else
    {
        if (GetCampaignInt("spawns", "finished") != 1)
        {
            NWNX_Administration_SetPlayerPassword(GetRandomUUID());
            SendDebugMessage("Spawns database is not complete", TRUE);
            SendDiscordLogMessage("Cannot start server - Spawns database is not complete");
            DelayCommand(60.0, NWNX_Administration_ShutdownServer());
            return;
        }
        else if (GetCampaignInt("treasures", "finished") != 1)
        {
            NWNX_Administration_SetPlayerPassword(GetRandomUUID());
            SendDebugMessage("Treasures database is not complete", TRUE);
            SendDiscordLogMessage("Cannot start server - Treasures database is not complete");
            DelayCommand(60.0, NWNX_Administration_ShutdownServer());
            return;
        }

    }

    SetCalendar(1372, d12(), 1);
    SetTime(d12(2), 0, 0, 0);

// Set up some server options
    //NWNX_Administration_SetPlayOption(NWNX_ADMINISTRATION_OPTION_ENFORCE_LEGAL_CHARACTERS, TRUE);
    NWNX_Administration_SetPlayOption(NWNX_ADMINISTRATION_OPTION_ITEM_LEVEL_RESTRICTIONS, TRUE);
    NWNX_Administration_SetPlayOption(NWNX_ADMINISTRATION_OPTION_AUTO_FAIL_SAVE_ON_1, TRUE);
    NWNX_Administration_SetPlayOption(NWNX_ADMINISTRATION_OPTION_EXAMINE_EFFECTS, FALSE);
    NWNX_Administration_SetPlayOption(NWNX_ADMINISTRATION_OPTION_USE_MAX_HITPOINTS, TRUE);
    NWNX_Administration_SetPlayOption(NWNX_ADMINISTRATION_OPTION_RESTORE_SPELLS_USES, FALSE);
    NWNX_Administration_SetPlayOption(NWNX_ADMINISTRATION_OPTION_HIDE_HITPOINTS_GAINED, FALSE);
    NWNX_Administration_SetPlayOption(NWNX_ADMINISTRATION_OPTION_PVP_SETTING, 2);
    NWNX_Administration_SetPlayOption(NWNX_ADMINISTRATION_OPTION_VALIDATE_SPELLS, TRUE);

// Save initial passwords for use after everything is initialized and ready
    SetLocalString(GetModule(), "PlayerPassword", NWNX_Administration_GetPlayerPassword());
    SetLocalString(GetModule(), "DMPassword", NWNX_Administration_GetDMPassword());

// Set a password until everything is initialized and ready
    NWNX_Administration_SetPlayerPassword(GetRandomUUID());

// Initialize monk weapons
    //NWNX_Weapon_SetWeaponIsMonkWeapon(BASE_ITEM_QUARTERSTAFF);
    //NWNX_Weapon_SetWeaponIsMonkWeapon(BASE_ITEM_SHURIKEN);

// Apply weapon focus and weapon specialization to creature attacks
    NWNX_Weapon_SetWeaponSpecializationFeat(BASE_ITEM_CSLASHWEAPON, FEAT_WEAPON_SPECIALIZATION_UNARMED_STRIKE);
    NWNX_Weapon_SetWeaponFocusFeat(BASE_ITEM_CSLASHWEAPON, FEAT_WEAPON_FOCUS_UNARMED_STRIKE);

    NWNX_Weapon_SetWeaponSpecializationFeat(BASE_ITEM_CSLSHPRCWEAP, FEAT_WEAPON_SPECIALIZATION_UNARMED_STRIKE);
    NWNX_Weapon_SetWeaponFocusFeat(BASE_ITEM_CSLSHPRCWEAP, FEAT_WEAPON_FOCUS_UNARMED_STRIKE);

    NWNX_Weapon_SetWeaponSpecializationFeat(BASE_ITEM_CBLUDGWEAPON, FEAT_WEAPON_SPECIALIZATION_UNARMED_STRIKE);
    NWNX_Weapon_SetWeaponFocusFeat(BASE_ITEM_CBLUDGWEAPON, FEAT_WEAPON_FOCUS_UNARMED_STRIKE);

    NWNX_Weapon_SetWeaponSpecializationFeat(BASE_ITEM_CPIERCWEAPON, FEAT_WEAPON_SPECIALIZATION_UNARMED_STRIKE);
    NWNX_Weapon_SetWeaponFocusFeat(BASE_ITEM_CPIERCWEAPON, FEAT_WEAPON_FOCUS_UNARMED_STRIKE);

    NWNX_Chat_RegisterChatScript("on_nwnx_chat");

// Hide XP gained messages because we handle it ourselves
    NWNX_Feedback_SetFeedbackMessageHidden(182, TRUE);
    //NWNX_Feedback_SetFeedbackMessageHidden(13, TRUE); // hide lock feedback as we also handle it ourselves

// Events.

    NWNX_Events_SubscribeEvent("NWNX_ON_TRAP_ENTER_BEFORE", "on_trap_enterb");
    NWNX_Events_SubscribeEvent("NWNX_ON_ITEM_USE_LORE_BEFORE", "on_pc_loreb");
    NWNX_Events_SubscribeEvent("NWNX_ON_ITEM_USE_LORE_AFTER", "on_pc_lorea");
    NWNX_Events_SubscribeEvent("NWNX_ON_ITEM_EQUIP_BEFORE", "on_pc_equipb");
    NWNX_Events_SubscribeEvent("NWNX_ON_ITEM_DECREMENT_STACKSIZE_BEFORE", "on_stack_decb");
    NWNX_Events_SubscribeEvent("NWNX_ON_SPELL_INTERRUPTED_AFTER", "on_spellinta");

    NWNX_Events_SubscribeEvent("NWNX_ON_USE_ITEM_AFTER", "on_use_itema");

    NWNX_Events_SubscribeEvent("NWNX_ON_MATERIALCHANGE_AFTER", "on_matchangea");

// Whitelist DMs.
    NWNX_Events_SubscribeEvent("NWNX_ON_CLIENT_CONNECT_BEFORE", "on_pc_connectb");

    NWNX_Events_SubscribeEvent("NWNX_ON_QUICKCHAT_BEFORE", "on_pc_voiceb");
    NWNX_Events_SubscribeEvent("NWNX_ON_CLIENT_CONNECT_AFTER", "on_pc_connect");
    NWNX_Events_SubscribeEvent("NWNX_ON_CLIENT_DISCONNECT_AFTER", "on_pc_dconnect");

    NWNX_Events_SubscribeEvent("NWNX_ON_USE_SKILL_BEFORE", "on_pc_skillb");
    NWNX_Events_SubscribeEvent("NWNX_ON_USE_SKILL_AFTER", "on_pc_skilla");

    NWNX_Events_SubscribeEvent("NWNX_ON_STEALTH_ENTER_BEFORE", "on_pc_stealth");

    NWNX_Events_SubscribeEvent("NWNX_ON_TRAP_RECOVER_BEFORE", "on_pc_trap");
    NWNX_Events_SubscribeEvent("NWNX_ON_TRAP_FLAG_BEFORE", "on_pc_trap");
    NWNX_Events_SubscribeEvent("NWNX_ON_TRAP_DISARM_BEFORE", "on_pc_trap");
    NWNX_Events_SubscribeEvent("NWNX_ON_TRAP_SET_BEFORE", "on_pc_trap");

    NWNX_Events_SubscribeEvent("NWNX_ON_OBJECT_LOCK_BEFORE", "on_pc_lock");
    NWNX_Events_SubscribeEvent("NWNX_ON_OBJECT_UNLOCK_BEFORE", "on_pc_unlock");

    NWNX_Events_SubscribeEvent("NWNX_ON_ITEM_PAY_TO_IDENTIFY_AFTER", "mer_identify");

    NWNX_Events_SubscribeEvent("NWNX_ON_ELC_VALIDATE_CHARACTER_AFTER", "on_validatea");

    NWNX_Events_SubscribeEvent("NWNX_ON_STORE_REQUEST_SELL_AFTER", "on_storesella");

    NWNX_Events_SubscribeEvent("NWNX_ON_STORE_REQUEST_BUY_BEFORE", "on_pc_buyb");
    NWNX_Events_SubscribeEvent("NWNX_ON_STORE_REQUEST_BUY_AFTER", "on_pc_buya");

    NWNX_Events_SubscribeEvent("NWNX_ON_EXAMINE_OBJECT_BEFORE", "on_pc_examineb");
    NWNX_Events_SubscribeEvent("NWNX_ON_EXAMINE_OBJECT_AFTER", "on_pc_examinea");

    NWNX_Events_SubscribeEvent("NWNX_ON_EFFECT_APPLIED_AFTER", "on_effect_applya");

    NWNX_Events_SubscribeEvent("NWNX_ON_EFFECT_APPLIED_AFTER", "on_request_buya");
    NWNX_Events_SubscribeEvent("NWNX_ON_EFFECT_APPLIED_AFTER", "on_request_sella");

// seems to happen a little too early, like 0.5 second too early?
    //NWNX_Events_SubscribeEvent("NWNX_ON_BROADCAST_CAST_SPELL_AFTER", "remove_invis");
    NWNX_Events_SubscribeEvent("NWNX_ON_CAST_SPELL_AFTER", "remove_invis");

// no spellcasting while mounted and in combat
    NWNX_Events_SubscribeEvent("NWNX_ON_CAST_SPELL_BEFORE", "cast_ride_chk");
    NWNX_Events_SubscribeEvent("NWNX_ON_BROADCAST_CAST_SPELL_BEFORE", "cast_ride_chkbc");

// We must skip this if polymorphed or bartering.
    NWNX_Events_SubscribeEvent("NWNX_ON_SERVER_CHARACTER_SAVE_BEFORE", "on_pc_save");

// Following actions are not allowed under any circumstance
    NWNX_Events_SubscribeEvent("NWNX_ON_DM_CHANGE_DIFFICULTY_BEFORE", "dm_never");
    NWNX_Events_SubscribeEvent("NWNX_ON_DM_SET_FACTION_BEFORE", "dm_never");
    NWNX_Events_SubscribeEvent("NWNX_ON_DM_SET_FACTION_REPUTATION_BEFORE", "dm_never");
    NWNX_Events_SubscribeEvent("NWNX_ON_DM_SET_TIME_BEFORE", "dm_never");
    NWNX_Events_SubscribeEvent("NWNX_ON_DM_SET_DATE_BEFORE", "dm_never");
    NWNX_Events_SubscribeEvent("NWNX_ON_DM_SET_STAT_BEFORE", "dm_chk_dev");

// Following DM events are not allowed except by developer
    NWNX_Events_SubscribeEvent("NWNX_ON_DM_GIVE_ITEM_BEFORE", "dm_chk_dev");
    NWNX_Events_SubscribeEvent("NWNX_ON_DM_SET_VARIABLE_BEFORE", "dm_chk_dev");
    NWNX_Events_SubscribeEvent("NWNX_ON_DM_GIVE_LEVEL_BEFORE", "dm_chk_dev");

    NWNX_Events_SubscribeEvent("NWNX_ON_DEBUG_RUN_SCRIPT_BEFORE", "dm_chk_dev");
    NWNX_Events_SubscribeEvent("NWNX_ON_DEBUG_RUN_SCRIPT_CHUNK_BEFORE", "dm_chk_dev");

// Following DM events can be done by DMs, but there is a limit unless developer
    NWNX_Events_SubscribeEvent("NWNX_ON_DM_GIVE_GOLD_BEFORE", "dm_chk_limit");
    NWNX_Events_SubscribeEvent("NWNX_ON_DM_GIVE_XP_BEFORE", "dm_chk_limit");
    NWNX_Events_SubscribeEvent("NWNX_ON_DM_GIVE_ALIGNMENT_BEFORE", "dm_chk_limit");

// Log barters as a developer
    NWNX_Events_SubscribeEvent("NWNX_ON_BARTER_END_BEFORE", "dm_barter_endb");

// Check certain areas and do not allow system areas except by developer
    NWNX_Events_SubscribeEvent("NWNX_ON_DM_JUMP_TO_POINT_BEFORE", "dm_chk_area_dev");
    NWNX_Events_SubscribeEvent("NWNX_ON_DM_JUMP_TARGET_TO_POINT_BEFORE", "dm_chk_area_dev");
    NWNX_Events_SubscribeEvent("NWNX_ON_DM_JUMP_ALL_PLAYERS_TO_POINT_BEFORE", "dm_chk_area_dev");

    NWNX_Events_SubscribeEvent("NWNX_ON_DM_GOTO_BEFORE", "dm_chk_goto_dev");

// Check and do certain logic on spawning of objects.
    NWNX_Events_SubscribeEvent("NWNX_ON_DM_SPAWN_OBJECT_BEFORE", "dm_spawnb");
    NWNX_Events_SubscribeEvent("NWNX_ON_DM_SPAWN_OBJECT_AFTER", "dm_spawna");

    NWNX_Events_SubscribeEvent("NWNX_ON_INPUT_DROP_ITEM_BEFORE", "on_item_dropb");

    NWNX_Events_SubscribeEvent("NWNX_ON_CALENDAR_DUSK", "on_calendar_dusk");

    NWNX_Events_SubscribeEvent("NWNX_ON_INVENTORY_ADD_GOLD_AFTER", "on_inv_addgolda");
    
    NWNX_Events_SubscribeEvent("NWNX_ON_UNPOLYMORPH_BEFORE", "on_unpolyb");
    NWNX_Events_SubscribeEvent("NWNX_ON_UNPOLYMORPH_AFTER", "on_unpolya");

    NWNX_Damage_SetDamageEventScript("on_damage");
    NWNX_Damage_SetAttackEventScript("on_attack");


    ServerWebhook("The Frozen North is starting!", "The Frozen North server is starting up. Once the module is stable and ready for players to login, we'll let you know.");

   // Multiple henchmen on the server, so let's set a high limit.
   SetMaxHenchmen(999);

   // * 1.72: Activating this switch below will allow to use only one damage shield spell at once.
   // * Affected spells: elemental shield, mestil's acid sheat, aura vs alignment, death armor
   // * and wounding whispers.
   // * When one of these spells is cast, any other such spell is dispelled.
   SetModuleSwitch (MODULE_SWITCH_DISABLE_DAMAGE_SHIELD_STACKING, TRUE);

   // * 1.72: Activating this switch below will allow to use only one weapon boost spell at once.
   // * Affected spells: magic weapon, greater magic weapon, bless weapon, flame weapon, holy sword,
   // * deafning clang, keen edge, darkfire and black staff.
   // * When one of these spells is cast on same item, the item gets stripped of all
   // * temporary itemproperties.
   SetModuleSwitch (MODULE_SWITCH_DISABLE_WEAPON_BOOST_STACKING, TRUE);

   // * 1.72: This switch controlls how much persistent AOE spells of the same type can player cast
   // * in the same area. This will stop the cheesy tactics to stack dozen of blade barries or
   // * acid fogs and lure monsters into it.
   // * Unlike weapon boosts and damage shields, this switch allows to set specific number of
   // * allowed aoes spells, so 1 = max 1, 2 = max 2 etc.
   SetModuleSwitch (MODULE_SWITCH_DISABLE_AOE_SPELLS_STACKING, 1);

   // * 1.72: Activating this switch below will enable hardcore DnD rules for evasion and improved
   // * evasion. Evasion feats will only work in light or no armor. Also a character must not
   // * be helpless ie. under effects of stun, paralysis, petrify, sleep or timestop.
   SetModuleSwitch (MODULE_SWITCH_HARDCORE_EVASION_RULES, FALSE);

   // * 1.72: Activating this switch below will disable "polymorph end" check which is
   // * performed every 6 seconds via pseudo heartbeat in order to clean all polymorph
   // * related effects such as ability bonuses, temporary hp etc. in case a module doesn't
   // * have properly merged module events with 1.72. Activating this switch will disable
   // * this check which is useful in multiplayer to make the polymorph new system more optimized.
   // * Make sure that you got OnEquip and OnUnEquip events merged properly before disabling this!
   // SetModuleSwitch (MODULE_SWITCH_POLYMORPH_DISABLE_POLYMORPH_END_CHECK, TRUE);

   // * 1.72: Activating this switch below will allow to merge every items the character wears into
   // * every polymorph shape in game even Tenser's transformation. This automatically enables
   // * the "merge arms" switch.
   // * Note: for unarmed shapes only defensive properties from weapon will merge.
   SetModuleSwitch (MODULE_SWITCH_POLYMORPH_MERGE_EVERYTHING, TRUE);

   // * 1.72: Activating this switch below will allow to merge intelligence, charisma and wisdom from
   // * all items no matter if the shape merges them or not. The reason for this is when you want to
   // * stop losing spellslots from ability increases on items while polymorphed.
   // * In case the player is a monk, he will get AC decrease matching the increase in wisdom
   // * over what shape normally allows.
   // * Note, use this switch only when module is not running NWNX. NWN(C)X_Patch handles this
   // * automatically in a better way - slots which would be normally lost will only be
   // * consumed. Also note this won't fix, unlike NWNX, losing spell slots from bonus spell slot
   // * itemproperties.
   SetModuleSwitch (MODULE_SWITCH_POLYMORPH_MERGE_CASTING_ABILITY, TRUE);

   // * 1.71: Activating this switch below will enforce the SoU empower spell feat behavior.
   // * This behavior empowers only dice values and any bonuses are added to the final result.
   // * Note: By default, empower spell feat empowers result of dice+bonus reaching much higher
   // * values, often outshining the maximized spell feat result.
   // SetModuleSwitch (MODULE_SWITCH_SOU_EMPOWER_SPELL_BEHAVIOR, TRUE);

   // * 1.71: Activating this switch below will enable to summon more than one summoned
   // * creature at the same time. Value TRUE/1 means unlimited, but it can be set to 2,3, etc.
   // SetModuleSwitch (MODULE_SWITCH_UNLIMITED_SUMMONING, TRUE);

   // * 1.71: Activating this switch below will stack multiple same bonuses and penalties
   // * to the single ability together, by default only highest applies.
   SetModuleSwitch (MODULE_SWITCH_POLYMORPH_STACK_ABILITY_BONUSES, TRUE);

   // * 1.71: Activating this switch below will enable to merge bracers/gloves when polymorphing.
   // * This will work only for shapes that merges items. Also only defensive abilities works.
   SetModuleSwitch (MODULE_SWITCH_POLYMORPH_MERGE_ARMS, TRUE);

   // * 1.71: Activating this switch below will calculate Pale master levels into
   // * caster level calculation. This will affect only arcane spells cast normally.
   // * Not all PM levels counts, under default 2DA setting the bonus to the caster
   // * level is (PM level/2)+1 - even levels do not affect spellcasting abilities.
   SetModuleSwitch (MODULE_SWITCH_PALEMASTER_ADDS_CASTER_LEVEL, TRUE);

   // * 1.71: Activating this switch below will restrict usage of the musical instruments.
   // * Possible values:
   // * 1: instruments will be restricted to the Perform skill, DC for success
   // * is then same as for UMD, 7+(3*SpellLevel)
   // * 2: instruments will be restricted to the bard song feat, just the way
   // * the Lich lyric are, each casting will decrement one use of the bard song feat
   // SetModuleSwitch (MODULE_SWITCH_RESTRICT_MUSICAL_INSTRUMENTS, 1);

   // * 1.71: Activating this switch below will shorten the duration of all disable effects
   // * (stun, paralyse, charm, daze, confusion, dominate, entangle, knockdown, grapple)
   // * to the constant of 3rounds (unless effect comes from extended spell)
   // * Possible values:
   // * 1: apply only when caster isn't PC and target is PC or his associate
   // * 2: apply regardless of who is caster but only when target is PC or his associate
   // * 3: apply regardless of who is caster and who target
   // SetModuleSwitch (MODULE_SWITCH_SHORTENED_DURATION_OF_DISABLE_EFFECTS, 1);

   // * 1.71: By default creature affected by the poison effect itself is virtually
   // * immune to other poisons until this effect wears off. This switch changes this
   // * behavior and adds greater effect to the poisons.
   SetModuleSwitch (MODULE_SWITCH_ALLOW_POISON_STACKING, TRUE);

   // * 1.71: Activating one of the switches below will enable to various weapon boost spells to
   // * affect additional weapons. Of course the spells still apply other rules such as slashing only
   // * etc. so this will not allow to cast keen on gloves.
   SetModuleSwitch (MODULE_SWITCH_ALLOW_BOOST_THROWING_WEAPONS, TRUE);
   SetModuleSwitch (MODULE_SWITCH_ALLOW_BOOST_RANGED_AND_AMMO, TRUE);
   SetModuleSwitch (MODULE_SWITCH_ALLOW_BOOST_GLOVES, TRUE);

   // * 1.70: Activating the switch below will enable the AOE heartbeat workaround solution
   // * if the default heartbeat solution doesn't work and AOEs do nothing
   // SetModuleSwitch (MODULE_SWITCH_AOE_HEARTBEAT_WORKAROUND, TRUE);

   // * 1.70: Activating the switch below will enable item sold to store tracking, once the limit
   // * of sold items, in this case 100, will be reached, oldest item sold to store will be destroyed
   // SetModuleSwitch (MODULE_SWITCH_OVERFILLED_STORES_ISSUE_FIX, 100);

   // * 1.70: Activating the switch below will disable the spell resist check inside AOEs, thus
   // * these spells will ignore spell resistance, spell mantle and even spell immunity
   // SetModuleSwitch (MODULE_SWITCH_AOE_IGNORES_SPELL_RESISTANCE, TRUE);

   // * 1.70: Activating the switch below will revert the 1.70's "Spell Immunity precedence"
   // inside ResistSpell check back to the 1.69 behavior where spell mantle "goes first".
   // SetModuleSwitch (MODULE_SWITCH_SPELL_MANTLE_169_BEHAVIOR, TRUE);

   // * 1.70: Activating the switch below will revert the 1.70's Dusty Rose ioun stone dodge AC
   // balance change back to the 1.69 deflection.
   // SetModuleSwitch (MODULE_SWITCH_DUSTYROSE_IOUNSTONE_169_AC_TYPE, TRUE);

   // * 1.70: Activating the switch below will disable the 1.70's feature that mark item as stolen
   // This was already modifed personally so don't use it.
   // SetModuleSwitch (MODULE_SWITCH_CONTINUAL_FLAME_ALLOW_EXPLOIT, TRUE);

   // * Setting the switch below will enable a seperate Use Magic Device Skillcheck for
   // * rogues when playing on Hardcore+ difficulty. This only applies to scrolls
   SetModuleSwitch (MODULE_SWITCH_ENABLE_UMD_SCROLLS, TRUE);

   // * Activating the switch below will make AOE spells hurt neutral NPCS by default
   SetModuleSwitch (MODULE_SWITCH_AOE_HURT_NEUTRAL_NPCS, TRUE);

   // * AI: Activating the switch below will make the creaures using the WalkWaypoint function
   // * able to walk across areas
   // SetModuleSwitch (MODULE_SWITCH_ENABLE_CROSSAREA_WALKWAYPOINTS, TRUE);

   // * Spells: Activating the switch below will make the Glyph of Warding spell behave differently:
   // * The visual glyph will disappear after 6 seconds, making them impossible to spot
   // SetModuleSwitch (MODULE_SWITCH_ENABLE_INVISIBLE_GLYPH_OF_WARDING, TRUE);

   // * Craft Feats: Want 50 charges on a newly created wand? We found this unbalancing,
   // * but since it is described this way in the book, here is the switch to get it back...
   // SetModuleSwitch (MODULE_SWITCH_ENABLE_CRAFT_WAND_50_CHARGES, TRUE);

   // * Craft Feats: Use this to disable Item Creation Feats if you do not want
   // * them in your module
   // SetModuleSwitch (MODULE_SWITCH_DISABLE_ITEM_CREATION_FEATS, TRUE);

   // * Palemaster: Deathless master touch in PnP only affects creatures up to a certain size.
   // * We do not support this check for balancing reasons, but you can still activate it...
   // SetModuleSwitch (MODULE_SWITCH_SPELL_CORERULES_DMASTERTOUCH, TRUE);

   // * Epic Spellcasting: Some Epic spells feed on the liveforce of the caster. However this
   // * did not fit into NWNs spell system and was confusing, so we took it out...
   // SetModuleSwitch (MODULE_SWITCH_EPIC_SPELLS_HURT_CASTER, TRUE);

    // SetModuleSwitch (MODULE_SWITCH_RESTRICT_USE_POISON_TO_FEAT, TRUE);

    // * Spellcasting: Some people don't like caster's abusing expertise to raise their AC
    // * Uncommenting this line will drop expertise mode whenever a spell is cast by a player
    // SetModuleSwitch (MODULE_VAR_AI_STOP_EXPERTISE_ABUSE, TRUE);


    // * Item Event Scripts: The game's default event scripts allow routing of all item related events
    // * into a single file, based on the tag of that item. If an item's tag is "test", it will fire a
    // * script called "test" when an item based event (equip, unequip, acquire, unacquire, activate,...)
    // * is triggered. Check "x2_it_example.nss" for an example.
    // * This feature is disabled by default.
   SetModuleSwitch (MODULE_SWITCH_ENABLE_TAGBASED_SCRIPTS, TRUE);
   SetUserDefinedItemEventPrefix("is_");

   SetEventScript(GetModule(), EVENT_SCRIPT_MODULE_ON_PLAYER_GUIEVENT, "on_guiselect");
   SetEventScript(GetModule(), EVENT_SCRIPT_MODULE_ON_NUI_EVENT, "on_nuievent");

// Load treasure tables
   int nIndex;
   for (nIndex = 1; nIndex < 6; nIndex++)
   {
      LoadTreasureContainer("_ArmorCommonT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 0.0);
      LoadTreasureContainer("_ArmorUncommonT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 1.0);
      LoadTreasureContainer("_ArmorRareT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 2.0);

      LoadTreasureContainer("_RangeCommonT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 4.0);
      LoadTreasureContainer("_RangeUncommonT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 5.0);
      LoadTreasureContainer("_RangeRareT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 6.0);

      LoadTreasureContainer("_MeleeCommonT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 8.0);
      LoadTreasureContainer("_MeleeUncommonT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 9.0);
      LoadTreasureContainer("_MeleeRareT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 10.0);

      LoadTreasureContainer("_ApparelCommonT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 12.0);
      LoadTreasureContainer("_ApparelUncommonT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 13.0);
      LoadTreasureContainer("_ApparelRareT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 14.0);

      LoadTreasureContainer("_ScrollsT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 16.0);

      LoadTreasureContainer("_PotionsT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 18.0);

      LoadTreasureContainer("_MiscT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 20.0);
      LoadTreasureContainer("_MiscConsT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 21.0);

      LoadTreasureContainer("_ArmorCommonT"+IntToString(nIndex)+"NonUnique", IntToFloat(nIndex)*2.0, 22.0);
      LoadTreasureContainer("_ArmorUncommonT"+IntToString(nIndex)+"NonUnique", IntToFloat(nIndex)*2.0, 23.0);
      LoadTreasureContainer("_ArmorRareT"+IntToString(nIndex)+"NonUnique", IntToFloat(nIndex)*2.0, 24.0);

      LoadTreasureContainer("_RangeCommonT"+IntToString(nIndex)+"NonUnique", IntToFloat(nIndex)*2.0, 26.0);
      LoadTreasureContainer("_RangeUncommonT"+IntToString(nIndex)+"NonUnique", IntToFloat(nIndex)*2.0, 27.0);
      LoadTreasureContainer("_RangeRareT"+IntToString(nIndex)+"NonUnique", IntToFloat(nIndex)*2.0, 28.0);

      LoadTreasureContainer("_MeleeCommonT"+IntToString(nIndex)+"NonUnique", IntToFloat(nIndex)*2.0, 30.0);
      LoadTreasureContainer("_MeleeUncommonT"+IntToString(nIndex)+"NonUnique", IntToFloat(nIndex)*2.0, 31.0);
      LoadTreasureContainer("_MeleeRareT"+IntToString(nIndex)+"NonUnique", IntToFloat(nIndex)*2.0, 32.0);

      LoadTreasureContainer("_PotionsT"+IntToString(nIndex)+"NonUnique", IntToFloat(nIndex)*2.0, 34.0);

      LoadTreasureContainer("_JewelsT"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 35.0);

      int nBaseItem;
      int nOffset = 0;
      for (nBaseItem=0; nBaseItem<=BASE_ITEM_WHIP; nBaseItem++)
      {
          if (nBaseItem == BASE_ITEM_ARMOR)
          {
                int nBaseAC;
                for (nBaseAC = 0; nBaseAC <= 8; nBaseAC++)
                {
                    LoadTreasureContainerByBaseItem("_BaseItem" + IntToString(nBaseItem) + "T"+IntToString(nIndex)+ "AC" + IntToString(nBaseAC) + "NonUnique", IntToFloat(nIndex)*2.0, IntToFloat(nOffset));
                    LoadTreasureContainerByBaseItem("_BaseItem" + IntToString(nBaseItem) + "T"+IntToString(nIndex) + "AC" + IntToString(nBaseAC), IntToFloat(nIndex)*2.0, 0.5  + IntToFloat(nOffset));
                    nOffset += 1;
                }
          }
          else
          {
                LoadTreasureContainerByBaseItem("_BaseItem" + IntToString(nBaseItem) + "T"+IntToString(nIndex)+"NonUnique", IntToFloat(nIndex)*2.0, IntToFloat(nOffset));
                LoadTreasureContainerByBaseItem("_BaseItem" + IntToString(nBaseItem) + "T"+IntToString(nIndex), IntToFloat(nIndex)*2.0, 0.5  + IntToFloat(nOffset));
                nOffset += 1;
          }
      }
   }

   BuildTreasureStagingToObjectsDB();
   SetLocalInt(GetModule(), "treasure_ready", 1);
   CalculatePlaceableLootValues();


   LoadAllPrettifyPlaceables();

// Loop through all objects in the module.
   InitialiseAreas();
   EnsureAreaBilateralLinkages();

   // Add quests that don't have variables set on any creature here
   // The above only scours the module for quests on creatures, some quests are purely scripted
   // and without being put in the quests list they aren't loaded into PC journals on join
   SetLocalString(OBJECT_SELF, "quests", AddListItem(GetLocalString(OBJECT_SELF, "quests"), "q_cockatrice_fbasilisk", TRUE));
   SetLocalString(OBJECT_SELF, "quests", AddListItem(GetLocalString(OBJECT_SELF, "quests"), "q_cockatrice_fgorgon", TRUE));
   SetLocalString(OBJECT_SELF, "quests", AddListItem(GetLocalString(OBJECT_SELF, "quests"), "q_daelan", TRUE));
   SetLocalString(OBJECT_SELF, "quests", AddListItem(GetLocalString(OBJECT_SELF, "quests"), "q_linu", TRUE));
   SetLocalString(OBJECT_SELF, "quests", AddListItem(GetLocalString(OBJECT_SELF, "quests"), "q_sharwyn", TRUE));
   SetLocalString(OBJECT_SELF, "quests", AddListItem(GetLocalString(OBJECT_SELF, "quests"), "q_tomi", TRUE));

   string sQuests = GetLocalString(OBJECT_SELF, "quests");
   string sBounties = GetLocalString(OBJECT_SELF, "bounties");


   WriteTimestampedLogEntry("Total Quests: "+IntToString(CountList(sQuests)));
   WriteTimestampedLogEntry("Quests: "+sQuests);

   WriteTimestampedLogEntry("Total Bounties: "+IntToString(CountList(sBounties)));
   WriteTimestampedLogEntry("Bounties: "+sBounties);

    // Global Weather Script
    SetGlobalWeather();

   // Generate Merchants
    object oStore;
    location lLocation = Location(GetObjectByTag("_BASE"), Vector(1.0, 1.0, 1.0), 0.0);
    int nNow = SQLite_GetTimeStamp();
    int i;
    for (i = 1; i < 25; i++)
    {
        oStore = CreateObject(OBJECT_TYPE_STORE, "merchant"+IntToString(i), lLocation);
        SetLocalInt(oStore, MERCHANT_STORE_LAST_RESTOCKED_AT, nNow);
        ExecuteScript(""+GetTag(oStore), oStore);
    }

    SendDebugMessage("Merchants created", TRUE);

    SpawnPCBloodstains();

    InitPlaceablesTable();
    
    ItemEventsInitialise();

    CreateHouseTemplatesInAllCardinalDirections();

    // as we do assign commands and other things when creating the templates, we should delay house seeding in case things screw up
    DelayCommand(5.0, InitializeAllHouses());

// set Yesgar to spawn 1 minute after module starts
    SetLocalInt(OBJECT_SELF, "yesgar_count", 190);

// Treasures cause heavy delay on starting a module
// It can be skipped, but it will cause merchants to lose most of their inventory
// As well as cause no treasure to be generated.
// For testing purposes, we shall skip creating treasures if local/no NWNX.
   if (FALSE && FindSubString(NWNX_Administration_GetServerName(), "NT") == -1)
   {
        ExecuteScript("gen_treasure", OBJECT_SELF);
   }
   else
   {
        SetLocalInt(GetModule(), "treasure_ready", 1);
   }

   ExecuteScript("tlk_overrides");
   
   // This sets up dynamic lighting - the script is part of the base game and can be found in installdir/ovr
   ExecuteScript("nw_dynlight");
}

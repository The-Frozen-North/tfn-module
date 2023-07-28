#include "inc_nui_config"
#include "inc_debug"
#include "inc_sqlite_time"

// Pop up the player stats UI for oPC showing them their own stats.
void ShowPlayerStatsUI(object oPC);

// Update a bind for oPlayer's stats UI if they have it open.
// Passing "" for sBind will update the whole thing.
void UpdatePlayerStatsUIBindIfOpen(object oPlayer, string sBind="");


// Categories:

// General
// Activities
// Gold and Treasure
// Kills and Deaths
// Magic Combat
// Martial Combat
// Damage

// GENERAL

// time_played
// quests_completed
// bounties_completed
// treasure_maps_completed
// henchman_recruited
// followers_recruited
// rest_ambushes

// traps_triggered
// assassination_attempts_thwarted

// KILLS AND DEATHS
// enemies_killed
// enemies_killed_with_credit
    // derive: percentage_kills_in_party
// bosses_killed
// most_powerful_killed (s)

// kill_xp_value
// total_xp_from_partys_kills
    // derive: percentage_xp_value_kills_in_party
// respawned

// deaths
// revived
// deaths_from_traps
// deaths_from_players
// deaths_from_allies
// followers_died
// henchman_died
// innocents_killed
// allies_killed

// MAGIC COMBAT

// spells_cast
// spells_cast_from_scroll
// spells_cast_from_item
// own_spells_interrupted
// other_spells_interrupted
// incoming_spells_resisted
// outgoing_spells_resisted
// creatures_summoned

// MARTIAL COMBAT

// attacks_hit
// attacks_missed
// attacks_hit_by
// attacks_missed_by
// attacks_of_opportunity_hit
// attacks_of_opportunity_missed
// attacks_of_opportunity_hit_by
// attacks_of_opportunity_missed_by
// sneak_attacks_hit
// sneak_attacks_missed
// sneak_attacks_hit_by
// sneak_attacks_missed_by
// critical_hits_landed
// critical_hits_taken
// natural_one_attack_rolls

// DAMAGE

// damage_dealt
// damage_taken

// physical_damage_dealt
// acid_damage_dealt
// cold_damage_dealt
// divine_damage_dealt
// electrical_damage_dealt
// fire_damage_dealt
// negative_damage_dealt
// positive_damage_dealt
// magic_damage_dealt
// sonic_damage_dealt
// physical_damage_taken
// acid_damage_taken
// cold_damage_taken
// divine_damage_taken
// electrical_damage_taken
// fire_damage_taken
// negative_damage_taken
// positive_damage_taken
// magic_damage_taken
// sonic_damage_taken


// ACTIVITIES

// potions_drunk
// locks_unlocked
// locks_bashed
// key_doors_opened
// ferries_used
// long_travel_used
// times_mounted
// time_spent_in_house
// times_rested_in_house

// persuade_failed
// persuade_succeeded
// bluff_failed
// bluff_succeeded
// pickpockets_succeeded
// pickpockets_failed

// GOLD AND TREASURE

// gold_looted
// gold_earned_from_selling
// gold_spent_from_buying
// most_gold_carried
// treasures_looted
// items_bought
// items_sold
// item_gold_value_assigned
// henchman_item_gold_value_assigned
// gold_spent_on_ferries
// gold_spent_on_long_travel


const float PLAYERSTATSWINDOW_BUTTONCOLUMN_WIDTH = 180.0;

json _PreparePlayerStatsPanelItem(string sKey, string sLabel, string sTooltip)
{
    json jRet = JsonObject();
    jRet = JsonObjectSet(jRet, "key", JsonString(sKey));
    jRet = JsonObjectSet(jRet, "label", JsonString(sLabel));
    jRet = JsonObjectSet(jRet, "tooltip", JsonString(sTooltip));
    return jRet;
}

json _GetPlayerStatsPanelBreakdown()
{
    json jRet = GetLocalJson(GetModule(), "playerstats_panel_breakdown");
    if (jRet == JsonNull() || GetIsDevServer())
    {
        jRet = JsonObject();
        json jGeneral = JsonArray();
        jGeneral = JsonArrayInsert(jGeneral, _PreparePlayerStatsPanelItem("time_played", "Time Played", "Total character logged in time."));
        jGeneral = JsonArrayInsert(jGeneral, _PreparePlayerStatsPanelItem("quests_completed", "Quests Completed", "Non-bounty quests completed."));
        jGeneral = JsonArrayInsert(jGeneral, _PreparePlayerStatsPanelItem("bounties_completed", "Bounties Completed", "Number of bounties (repeatable) completed."));
        jGeneral = JsonArrayInsert(jGeneral, _PreparePlayerStatsPanelItem("treasure_maps_completed", "Treasure Maps Completed", "Number of treasure maps completed."));
        jGeneral = JsonArrayInsert(jGeneral, _PreparePlayerStatsPanelItem("henchman_recruited", "Henchmen Recruited", "Number of henchmen recruited."));
        jGeneral = JsonArrayInsert(jGeneral, _PreparePlayerStatsPanelItem("followers_recruited", "Followers Recruited", "Number of non-henchman followers recruited."));
        jGeneral = JsonArrayInsert(jGeneral, _PreparePlayerStatsPanelItem("rest_ambushes", "Rest Ambushes", "Number of times enemies interrupted resting."));
        jGeneral = JsonArrayInsert(jGeneral, _PreparePlayerStatsPanelItem("traps_triggered", "Traps Triggered", "Number of traps triggered."));
        jGeneral = JsonArrayInsert(jGeneral, _PreparePlayerStatsPanelItem("assassination_attempts_thwarted", "Assassination Attempts Survived", "The number of assassination attempts against you that failed."));
        jRet = JsonObjectSet(jRet, "general", jGeneral);
        
        json jKillsDeaths = JsonArray();
        jKillsDeaths = JsonArrayInsert(jKillsDeaths, _PreparePlayerStatsPanelItem("enemies_killed", "Enemies Killed", "Enemies directly killed by you or creatures you summoned."));
        jKillsDeaths = JsonArrayInsert(jKillsDeaths, _PreparePlayerStatsPanelItem("bosses_killed", "Bosses Killed", "Bosses directly killed by you or creatures you summoned."));
        jKillsDeaths = JsonArrayInsert(jKillsDeaths, _PreparePlayerStatsPanelItem("percentage_kills_in_party", "Party Kill Percentage", "The percentage of party kills that were directly killed by you or creatures you summoned."));
        jKillsDeaths = JsonArrayInsert(jKillsDeaths, _PreparePlayerStatsPanelItem("most_powerful_killed", "Most Powerful Killed", "The most powerful enemy killed by you or creatures you summoned."));
        jKillsDeaths = JsonArrayInsert(jKillsDeaths, _PreparePlayerStatsPanelItem("enemies_killed_with_credit", "Total Credited Kills", "The number of kills that you or your party have contributed towards."));
        jKillsDeaths = JsonArrayInsert(jKillsDeaths, _PreparePlayerStatsPanelItem("kill_xp_value", "XP from Personal Kills", "The total XP from enemies directly killed by you or creatures you summoned ."));
        jKillsDeaths = JsonArrayInsert(jKillsDeaths, _PreparePlayerStatsPanelItem("total_xp_from_partys_kills", "XP from Party Kills", "The total XP from kills that you or your party have contributed towards."));
        jKillsDeaths = JsonArrayInsert(jKillsDeaths, _PreparePlayerStatsPanelItem("percentage_xp_value_kills_in_party", "Party XP Value Kill Percentage", "Kills by you or creatures you summoned make up this percentage of the total experience you have gained from kills."));
        jKillsDeaths = JsonArrayInsert(jKillsDeaths, _PreparePlayerStatsPanelItem("respawned", "Respawns", "The number of times you have respawned at a temple."));
        jKillsDeaths = JsonArrayInsert(jKillsDeaths, _PreparePlayerStatsPanelItem("deaths", "Deaths", "The number of times you have died."));
        jKillsDeaths = JsonArrayInsert(jKillsDeaths, _PreparePlayerStatsPanelItem("revived", "Revives", "The number of times you have been revived by a nearby ally when out of combat."));
        jKillsDeaths = JsonArrayInsert(jKillsDeaths, _PreparePlayerStatsPanelItem("deaths_from_traps", "Deaths from Traps", "The number of times you have been killed by a trap."));
        jKillsDeaths = JsonArrayInsert(jKillsDeaths, _PreparePlayerStatsPanelItem("deaths_from_players", "Deaths from Players", "The number of times you have been killed by another player."));
        jKillsDeaths = JsonArrayInsert(jKillsDeaths, _PreparePlayerStatsPanelItem("deaths_from_allies", "Deaths from Allies", "The number of times you have been killed by an ally."));
        jKillsDeaths = JsonArrayInsert(jKillsDeaths, _PreparePlayerStatsPanelItem("followers_died", "Follower Deaths", "The number of your followers that have died."));
        jKillsDeaths = JsonArrayInsert(jKillsDeaths, _PreparePlayerStatsPanelItem("henchman_died", "Henchman Deaths", "The number of times your henchmen have died."));
        jKillsDeaths = JsonArrayInsert(jKillsDeaths, _PreparePlayerStatsPanelItem("innocents_killed", "Innocents Killed", "The number of innocent civilians you have killed."));
        jKillsDeaths = JsonArrayInsert(jKillsDeaths, _PreparePlayerStatsPanelItem("allies_killed", "Allies Killed", "The number of non-innocent allies you have killed."));
        jRet = JsonObjectSet(jRet, "killsdeaths", jKillsDeaths);
        
        json jMagicCombat = JsonArray();
        jMagicCombat = JsonArrayInsert(jMagicCombat, _PreparePlayerStatsPanelItem("spells_cast", "Spells Cast", "The number of spells cast through regular spellbooks."));
        jMagicCombat = JsonArrayInsert(jMagicCombat, _PreparePlayerStatsPanelItem("spells_cast_from_scroll", "Spells Cast via Scroll", "The number of spells cast off scrolls."));
        jMagicCombat = JsonArrayInsert(jMagicCombat, _PreparePlayerStatsPanelItem("spells_cast_from_item", "Spells Cast via Item", "The number of spells cast off items that were not scrolls or potions."));
        jMagicCombat = JsonArrayInsert(jMagicCombat, _PreparePlayerStatsPanelItem("own_spells_interrupted", "Own Spells Interrupted", "The number of times your own spells have been interrupted by damage."));
        jMagicCombat = JsonArrayInsert(jMagicCombat, _PreparePlayerStatsPanelItem("other_spells_interrupted", "Other Spells Interrupted", "The number of times your damage has interrupted other creatures' spells."));
        jMagicCombat = JsonArrayInsert(jMagicCombat, _PreparePlayerStatsPanelItem("incoming_spells_resisted", "Spells Resisted", "The number of spells you have resisted with spell resistance."));
        jMagicCombat = JsonArrayInsert(jMagicCombat, _PreparePlayerStatsPanelItem("outgoing_spells_resisted", "Own Spells Resisted", "The number of times other creatures have resisted your spells."));
        jMagicCombat = JsonArrayInsert(jMagicCombat, _PreparePlayerStatsPanelItem("creatures_summoned", "Creatures Summoned", "The number of creatures you have summoned."));
        jRet = JsonObjectSet(jRet, "magiccombat", jMagicCombat);
        
        json jMartialCombat = JsonArray();
        jMartialCombat = JsonArrayInsert(jMartialCombat, _PreparePlayerStatsPanelItem("attacks_hit", "Attacks Landed", "The number of attacks you have hit with."));
        jMartialCombat = JsonArrayInsert(jMartialCombat, _PreparePlayerStatsPanelItem("attacks_missed", "Attacks Missed", "The number of attacks you have missed with."));
        jMartialCombat = JsonArrayInsert(jMartialCombat, _PreparePlayerStatsPanelItem("attacks_hit_by", "Attacks Taken", "The number of attacks you have been hit with."));
        jMartialCombat = JsonArrayInsert(jMartialCombat, _PreparePlayerStatsPanelItem("attacks_missed_by", "Attacks Avoided", "The number of attacks against you that have missed."));
        jMartialCombat = JsonArrayInsert(jMartialCombat, _PreparePlayerStatsPanelItem("critical_hits_landed", "Critical Hits Landed", "The number of critical hits you have performed."));
        jMartialCombat = JsonArrayInsert(jMartialCombat, _PreparePlayerStatsPanelItem("critical_hits_taken", "Critical Hits Suffered", "The number of critical hits that have been landed on you."));
        jMartialCombat = JsonArrayInsert(jMartialCombat, _PreparePlayerStatsPanelItem("natural_one_attack_rolls", "Natural 1 Attack Rolls", "The number of times you have rolled a 1 on an attack roll."));
        jMartialCombat = JsonArrayInsert(jMartialCombat, _PreparePlayerStatsPanelItem("attacks_of_opportunity_hit", "Attacks of Opportunity Landed", "The number of attacks of opportunity you have hit with."));
        jMartialCombat = JsonArrayInsert(jMartialCombat, _PreparePlayerStatsPanelItem("attacks_of_opportunity_missed", "Attacks of Opportunity Missed", "The number of attacks of opportunity you have missed with."));
        jMartialCombat = JsonArrayInsert(jMartialCombat, _PreparePlayerStatsPanelItem("attacks_of_opportunity_hit_by", "Attacks of Opportunity Taken", "The number of attacks of opportunity you have been hit with."));
        jMartialCombat = JsonArrayInsert(jMartialCombat, _PreparePlayerStatsPanelItem("attacks_of_opportunity_missed_by", "Attacks of Opportunity Avoided", "The number of attacks of opportunity against you that have missed."));
        jMartialCombat = JsonArrayInsert(jMartialCombat, _PreparePlayerStatsPanelItem("sneak_attacks_hit", "Sneak Attacks Landed", "The number of sneak/death attacks you have hit with."));
        jMartialCombat = JsonArrayInsert(jMartialCombat, _PreparePlayerStatsPanelItem("sneak_attacks_missed", "Sneak Attacks Missed", "The number of sneak/death attacks you have missed with."));
        jMartialCombat = JsonArrayInsert(jMartialCombat, _PreparePlayerStatsPanelItem("sneak_attacks_hit_by", "Sneak Attacks Taken", "The number of sneak/death attacks you have been hit with."));
        jMartialCombat = JsonArrayInsert(jMartialCombat, _PreparePlayerStatsPanelItem("sneak_attacks_missed_by", "Sneak Attacks Avoided", "The number of sneak/death attacks against you that have missed."));
        jRet = JsonObjectSet(jRet, "martialcombat", jMartialCombat);
        
        json jDamage = JsonArray();
        jDamage = JsonArrayInsert(jDamage, _PreparePlayerStatsPanelItem("damage_dealt", "Damage Dealt", "Total damage inflicted."));
        jDamage = JsonArrayInsert(jDamage, _PreparePlayerStatsPanelItem("damage_taken", "Damage Taken", "Total damage recieved."));
        jDamage = JsonArrayInsert(jDamage, _PreparePlayerStatsPanelItem("physical_damage_dealt", "Physical Damage Dealt", "Total blunt/pierce/bludgeoning damage inflicted."));
        jDamage = JsonArrayInsert(jDamage, _PreparePlayerStatsPanelItem("acid_damage_dealt", "Acid Damage Dealt", "Total acid damage inflicted."));
        jDamage = JsonArrayInsert(jDamage, _PreparePlayerStatsPanelItem("cold_damage_dealt", "Cold Damage Dealt", "Total cold damage inflicted."));
        jDamage = JsonArrayInsert(jDamage, _PreparePlayerStatsPanelItem("divine_damage_dealt", "Divine Damage Dealt", "Total divine damage inflicted."));
        jDamage = JsonArrayInsert(jDamage, _PreparePlayerStatsPanelItem("electrical_damage_dealt", "Electrical Damage Dealt", "Total electrical damage inflicted."));
        jDamage = JsonArrayInsert(jDamage, _PreparePlayerStatsPanelItem("fire_damage_dealt", "Fire Damage Dealt", "Total fire damage inflicted."));
        jDamage = JsonArrayInsert(jDamage, _PreparePlayerStatsPanelItem("negative_damage_dealt", "Negative Damage Dealt", "Total negative energy damage inflicted."));
        jDamage = JsonArrayInsert(jDamage, _PreparePlayerStatsPanelItem("positive_damage_dealt", "Positive Damage Dealt", "Total positive energy damage inflicted."));
        jDamage = JsonArrayInsert(jDamage, _PreparePlayerStatsPanelItem("magic_damage_dealt", "Magical Damage Dealt", "Total magical damage inflicted."));
        jDamage = JsonArrayInsert(jDamage, _PreparePlayerStatsPanelItem("sonic_damage_dealt", "Sonic Damage Dealt", "Total sonic damage inflicted."));
        jDamage = JsonArrayInsert(jDamage, _PreparePlayerStatsPanelItem("physical_damage_taken", "Physical Damage Taken", "Total blunt/pierce/bludgeoning damage recieved."));
        jDamage = JsonArrayInsert(jDamage, _PreparePlayerStatsPanelItem("acid_damage_taken", "Acid Damage Taken", "Total acid damage recieved."));
        jDamage = JsonArrayInsert(jDamage, _PreparePlayerStatsPanelItem("cold_damage_taken", "Cold Damage Taken", "Total cold damage recieved."));
        jDamage = JsonArrayInsert(jDamage, _PreparePlayerStatsPanelItem("divine_damage_taken", "Divine Damage Taken", "Total divine damage recieved."));
        jDamage = JsonArrayInsert(jDamage, _PreparePlayerStatsPanelItem("electrical_damage_Taken", "Electrical Damage taken", "Total electrical damage recieved."));
        jDamage = JsonArrayInsert(jDamage, _PreparePlayerStatsPanelItem("fire_damage_taken", "Fire Damage Taken", "Total fire damage recieved."));
        jDamage = JsonArrayInsert(jDamage, _PreparePlayerStatsPanelItem("negative_damage_taken", "Negative Damage Taken", "Total negative energy damage recieved."));
        jDamage = JsonArrayInsert(jDamage, _PreparePlayerStatsPanelItem("positive_damage_taken", "Positive Damage Taken", "Total positive energy damage recieved."));
        jDamage = JsonArrayInsert(jDamage, _PreparePlayerStatsPanelItem("magic_damage_taken", "Magical Damage Taken", "Total magical damage recieved."));
        jDamage = JsonArrayInsert(jDamage, _PreparePlayerStatsPanelItem("sonic_damage_taken", "Sonic Damage Taken", "Total sonic damage recieved."));
        jRet = JsonObjectSet(jRet, "damage", jDamage);

        json jActivities = JsonArray();
        jActivities = JsonArrayInsert(jActivities, _PreparePlayerStatsPanelItem("potions_drunk", "Potions Consumed", "Total number of potions drunk."));
        jActivities = JsonArrayInsert(jActivities, _PreparePlayerStatsPanelItem("locks_unlocked", "Locks Picked", "Total number of locked objects picked open."));
        jActivities = JsonArrayInsert(jActivities, _PreparePlayerStatsPanelItem("locks_bashed", "Locks Bashed", "Total number of locked objects bashed open."));
        jActivities = JsonArrayInsert(jActivities, _PreparePlayerStatsPanelItem("key_doors_opened", "Key Doors Opened", "Number of locked doors opened with keys."));
        jActivities = JsonArrayInsert(jActivities, _PreparePlayerStatsPanelItem("ferries_used", "Neverwinter Ferries Used", "Number of Neverwinter ferry trips taken."));
        jActivities = JsonArrayInsert(jActivities, _PreparePlayerStatsPanelItem("long_travel_used", "Long Travels Used", "Number of long travel trips (eg: river boats) taken."));
        jActivities = JsonArrayInsert(jActivities, _PreparePlayerStatsPanelItem("times_mounted", "Times Mounted Horse", "Number of long travel trips (eg: river boats) taken."));
        jActivities = JsonArrayInsert(jActivities, _PreparePlayerStatsPanelItem("time_spent_in_house", "Time Spent in House", "Amount of (logged in) time spent in your own house."));
        jActivities = JsonArrayInsert(jActivities, _PreparePlayerStatsPanelItem("times_rested_in_house", "Times Rested in House", "Number of times rested in your own house (that have given Rested XP)."));
        jActivities = JsonArrayInsert(jActivities, _PreparePlayerStatsPanelItem("persuade_succeeded", "Persuade Attempts Succeeded", "Number of successful persuade attempts."));
        jActivities = JsonArrayInsert(jActivities, _PreparePlayerStatsPanelItem("persuade_failed", "Persuade Attempts Failed", "Number of failed persuade attempts."));
        jActivities = JsonArrayInsert(jActivities, _PreparePlayerStatsPanelItem("bluff_succeeded", "Bluff Attempts Succeeded", "Number of successful bluff attempts."));
        jActivities = JsonArrayInsert(jActivities, _PreparePlayerStatsPanelItem("bluff_failed", "Bluff Attempts Failed", "Number of failed bluff attempts."));
        jActivities = JsonArrayInsert(jActivities, _PreparePlayerStatsPanelItem("pickpockets_succeeded", "Pickpocket Attempts Succeeded", "Number of successful pickpocket attempts."));
        jActivities = JsonArrayInsert(jActivities, _PreparePlayerStatsPanelItem("pickpockets_failed", "Pickpocket Attempts Failed", "Number of failed pickpocket attempts."));
        jRet = JsonObjectSet(jRet, "activities", jActivities);
        
        json jGoldTreasure = JsonArray();
        jGoldTreasure = JsonArrayInsert(jGoldTreasure, _PreparePlayerStatsPanelItem("gold_looted", "Gold Looted", "Total amount of raw gold looted."));
        jGoldTreasure = JsonArrayInsert(jGoldTreasure, _PreparePlayerStatsPanelItem("gold_earned_from_selling", "Gold from Selling", "Total amount of gold obtained from selling goods to shops."));
        jGoldTreasure = JsonArrayInsert(jGoldTreasure, _PreparePlayerStatsPanelItem("gold_spent_from_buying", "Gold Spent", "Total amount of gold spent on items and services in both shops and dialogue."));
        jGoldTreasure = JsonArrayInsert(jGoldTreasure, _PreparePlayerStatsPanelItem("items_bought", "Items Bought", "Total number of items bought from stores."));
        jGoldTreasure = JsonArrayInsert(jGoldTreasure, _PreparePlayerStatsPanelItem("items_sold", "Items Sold", "Total number of items sold to stores."));
        jGoldTreasure = JsonArrayInsert(jGoldTreasure, _PreparePlayerStatsPanelItem("most_gold_carried", "Most Gold Carried", "Highest amount of gold carried at any time."));
        jGoldTreasure = JsonArrayInsert(jGoldTreasure, _PreparePlayerStatsPanelItem("treasures_looted", "Treasures Looted", "Number of objects looted."));
        jGoldTreasure = JsonArrayInsert(jGoldTreasure, _PreparePlayerStatsPanelItem("item_gold_value_assigned", "Item Gold Value Assigned", "Total gold value of all items assigned to you in loot."));
        jGoldTreasure = JsonArrayInsert(jGoldTreasure, _PreparePlayerStatsPanelItem("henchman_item_gold_value_assigned", "Henchman Item Gold Value Assigned", "Total gold value of all items assigned to henchmen in the same party as you."));
        jGoldTreasure = JsonArrayInsert(jGoldTreasure, _PreparePlayerStatsPanelItem("gold_spent_on_ferries", "Gold Spent on Neverwinter Ferries", "Total gold spent on Neverwinter ferries."));
        jGoldTreasure = JsonArrayInsert(jGoldTreasure, _PreparePlayerStatsPanelItem("gold_spent_on_long_travel", "Gold Spent on Long Travel", "Total gold spent on longer travel (eg boat trips)."));
        jRet = JsonObjectSet(jRet, "goldtreasure", jGoldTreasure);
        
        SetLocalJson(GetModule(), "playerstats_panel_breakdown", jRet);
    }
    return jRet;
}

json _PlayerStatsCategoryToNui(json jPanel, string sCategory)
{
    json jRet = GetLocalJson(GetModule(), "playerstats_panel_nui_" + sCategory);
    if (jRet == JsonNull() || GetIsDevServer())
    {
        json jArray = JsonObjectGet(jPanel, sCategory);
        int nLength = JsonGetLength(jArray);
        json jRows = JsonArray();
        int i;
        for (i=0; i<nLength; i++)
        {
            json jThisEntry = JsonArrayGet(jArray, i);
            json jBind = JsonObjectGet(jThisEntry, "key");
            json jLabel = JsonObjectGet(jThisEntry, "label");
            json jTooltip = JsonObjectGet(jThisEntry, "tooltip");
            
            json jNuiLabel = NuiWidth(NuiHeight(NuiTooltip(NuiLabel(jLabel, JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_MIDDLE)), jTooltip), 40.0), 265.0);
            json jThisRow = JsonArray();
            jThisRow = JsonArrayInsert(jThisRow, jNuiLabel);
            json jValueLabel = NuiLabel(NuiBind(JsonGetString(jBind)), JsonInt(NUI_HALIGN_LEFT), JsonInt(NUI_VALIGN_MIDDLE));
            jThisRow = JsonArrayInsert(jThisRow, jValueLabel);
            jRows = JsonArrayInsert(jRows, NuiRow(jThisRow));
        }
        
        jRet = NuiGroup(NuiCol(jRows));
        
        SetLocalJson(GetModule(), "playerstats_panel_nui_" + sCategory, jRet);
    }
    return jRet;
}


void ShowPlayerStatsUI(object oPC)
{
    if (!GetIsPC(oPC) || !GetIsObjectValid(oPC))
    {
        return;
    }
    if (NuiFindWindow(oPC, "playerstats") != 0)
    {
        return;
    }
    
    json jTop = JsonArray();
    json jThisCharacterButton = NuiTooltip(NuiId(NuiHeight(NuiWidth(NuiButton(NuiBind("switchviewbuttontext")), 220.0), 40.0), "toggleallcharacters"), NuiBind("switchbuttontooltip"));
    jTop = JsonArrayInsert(jTop, jThisCharacterButton);
    json jTopRow = NuiRow(jTop);
    
    
    json jLeftButtonList = JsonArray();
    
    json jWindowConfigOptionButton = NuiButton(JsonString("General"));
    jWindowConfigOptionButton = NuiHeight(jWindowConfigOptionButton, 40.0);
    jWindowConfigOptionButton = NuiWidth(jWindowConfigOptionButton, PLAYERSTATSWINDOW_BUTTONCOLUMN_WIDTH - (NUI_SPACE_WIDTH*2));
    jWindowConfigOptionButton = NuiId(jWindowConfigOptionButton, "category_general");
    jLeftButtonList = JsonArrayInsert(jLeftButtonList, jWindowConfigOptionButton);
    
    jWindowConfigOptionButton = NuiButton(JsonString("Activities"));
    jWindowConfigOptionButton = NuiHeight(jWindowConfigOptionButton, 40.0);
    jWindowConfigOptionButton = NuiWidth(jWindowConfigOptionButton, PLAYERSTATSWINDOW_BUTTONCOLUMN_WIDTH - (NUI_SPACE_WIDTH*2));
    jWindowConfigOptionButton = NuiId(jWindowConfigOptionButton, "category_activities");
    jLeftButtonList = JsonArrayInsert(jLeftButtonList, jWindowConfigOptionButton);
    
    jWindowConfigOptionButton = NuiButton(JsonString("Gold and Treasure"));
    jWindowConfigOptionButton = NuiHeight(jWindowConfigOptionButton, 40.0);
    jWindowConfigOptionButton = NuiWidth(jWindowConfigOptionButton, PLAYERSTATSWINDOW_BUTTONCOLUMN_WIDTH - (NUI_SPACE_WIDTH*2));
    jWindowConfigOptionButton = NuiId(jWindowConfigOptionButton, "category_goldtreasure");
    jLeftButtonList = JsonArrayInsert(jLeftButtonList, jWindowConfigOptionButton);
    
    jWindowConfigOptionButton = NuiButton(JsonString("Kills and Deaths"));
    jWindowConfigOptionButton = NuiHeight(jWindowConfigOptionButton, 40.0);
    jWindowConfigOptionButton = NuiWidth(jWindowConfigOptionButton, PLAYERSTATSWINDOW_BUTTONCOLUMN_WIDTH - (NUI_SPACE_WIDTH*2));
    jWindowConfigOptionButton = NuiId(jWindowConfigOptionButton, "category_killsdeaths");
    jLeftButtonList = JsonArrayInsert(jLeftButtonList, jWindowConfigOptionButton);
    
    jWindowConfigOptionButton = NuiButton(JsonString("Martial Combat"));
    jWindowConfigOptionButton = NuiHeight(jWindowConfigOptionButton, 40.0);
    jWindowConfigOptionButton = NuiWidth(jWindowConfigOptionButton, PLAYERSTATSWINDOW_BUTTONCOLUMN_WIDTH - (NUI_SPACE_WIDTH*2));
    jWindowConfigOptionButton = NuiId(jWindowConfigOptionButton, "category_martialcombat");
    jLeftButtonList = JsonArrayInsert(jLeftButtonList, jWindowConfigOptionButton);
    
    jWindowConfigOptionButton = NuiButton(JsonString("Magic Combat"));
    jWindowConfigOptionButton = NuiHeight(jWindowConfigOptionButton, 40.0);
    jWindowConfigOptionButton = NuiWidth(jWindowConfigOptionButton, PLAYERSTATSWINDOW_BUTTONCOLUMN_WIDTH - (NUI_SPACE_WIDTH*2));
    jWindowConfigOptionButton = NuiId(jWindowConfigOptionButton, "category_magiccombat");
    jLeftButtonList = JsonArrayInsert(jLeftButtonList, jWindowConfigOptionButton);
    
    jWindowConfigOptionButton = NuiButton(JsonString("Damage"));
    jWindowConfigOptionButton = NuiHeight(jWindowConfigOptionButton, 40.0);
    jWindowConfigOptionButton = NuiWidth(jWindowConfigOptionButton, PLAYERSTATSWINDOW_BUTTONCOLUMN_WIDTH - (NUI_SPACE_WIDTH*2));
    jWindowConfigOptionButton = NuiId(jWindowConfigOptionButton, "category_damage");
    jLeftButtonList = JsonArrayInsert(jLeftButtonList, jWindowConfigOptionButton);
    
    
    json jButtonGroup = NuiGroup(NuiCol(jLeftButtonList));
    jButtonGroup = NuiHeight(jButtonGroup, 600.0);
    jButtonGroup = NuiWidth(jButtonGroup, PLAYERSTATSWINDOW_BUTTONCOLUMN_WIDTH);
    jButtonGroup = NuiId(jButtonGroup, "buttonlist");
    
    //json jConfigArea = NuiGroup(NuiCol(JsonArray()));
    json jConfigArea = _PlayerStatsCategoryToNui(_GetPlayerStatsPanelBreakdown(), "general");
    jConfigArea = NuiHeight(jConfigArea, 600.0);
    jConfigArea = NuiWidth(jConfigArea, 450.0);
    jConfigArea = NuiId(jConfigArea, "configarea");
    
    json jContentRow = JsonArray();
    jContentRow = JsonArrayInsert(jContentRow, jButtonGroup);
    jContentRow = JsonArrayInsert(jContentRow, jConfigArea);
    jContentRow = NuiRow(jContentRow);
    
    json jLayout = JsonArray();
    jLayout = JsonArrayInsert(jLayout, jTopRow);
    jLayout = JsonArrayInsert(jLayout, jContentRow);
    //jLayout = JsonArrayInsert(jLayout, jButtonGroup);
    
    jLayout = NuiCol(jLayout);
    
    SetInterfaceFixedSize("nui_playerstats", 670.0, 720.0);
    json jGeometry = GetPersistentWindowGeometryBind(oPC, "playerstats", NuiRect(-1.0, -1.0, 670.0, 720.0));
    json jNui = EditableNuiWindow("playerstats", "Player Stats", jLayout, "Player Stats", jGeometry, 0, 0, 1, JsonBool(0), JsonBool(1));
    int nToken = NuiCreate(oPC, jNui, "playerstats");
    SetIsInterfaceConfigurable(oPC, nToken, 0, 1);
    LoadNuiConfigBinds(oPC, nToken);
    
    json jUserData = NuiGetUserData(oPC, nToken);
    jUserData = JsonObjectSet(jUserData, "activepanel", JsonString("character"));
    jUserData = JsonObjectSet(jUserData, "activecategory", JsonString("general"));
    NuiSetUserData(oPC, nToken, jUserData);
    NuiSetBind(oPC, nToken, "switchviewbuttontext", JsonString("View all Character Stats"));
    NuiSetBind(oPC, nToken, "switchbuttontooltip", JsonString("Currently displaying this character's stats."));
    
    UpdatePlayerStatsUIBindIfOpen(oPC, "");
}

void _UpdateQueuedPlayerStatsBinds(object oPC)
{
    int nToken = NuiFindWindow(oPC, "playerstats");
    if (nToken != 0)
    {
        json jUserData = NuiGetUserData(oPC, nToken);
        jUserData = JsonObjectDel(jUserData, "bindblocked");
        json jArray = JsonObjectGet(jUserData, "bindupdatequeue");
        int nLength = JsonGetLength(jArray);
        int i;
        //SendDebugMessage("Clear bind update queue: length = " + IntToString(nLength));
        for (i=0; i<nLength; i++)
        {
            string sBind = JsonGetString(JsonArrayGet(jArray, i));
            //SendDebugMessage("Really updating bind: " + sBind);
            SetScriptParam("updatebind", sBind);
            SetScriptParam("pc", ObjectToString(oPC));
            SetScriptParam("token", IntToString(nToken));
            ExecuteScript("playerstats_evt");
        }
        jUserData = JsonObjectDel(jUserData, "bindupdatequeue");
        NuiSetUserData(oPC, nToken, jUserData);        
    }
}

void UpdatePlayerStatsUIBindIfOpen(object oPlayer, string sBind="")
{
    int nToken = NuiFindWindow(oPlayer, "playerstats");
    if (nToken != 0)
    {
        if (sBind == "")
        {
            SetScriptParam("updateallbinds", "1");
            SetScriptParam("pc", ObjectToString(oPlayer));
            SetScriptParam("token", IntToString(nToken));
            ExecuteScript("playerstats_evt");
        }
        else
        {
            json jUserData = NuiGetUserData(oPlayer, nToken);
            // Maybe make a queue?
            json jBlocked = JsonObjectGet(jUserData, "bindblocked");
            if (jBlocked == JsonNull())
            {
                jUserData = JsonObjectSet(jUserData, "bindblocked", JsonInt(1));
                AssignCommand(GetModule(), DelayCommand(6.0, _UpdateQueuedPlayerStatsBinds(oPlayer)));
            }
            json jArray = JsonObjectGet(jUserData, "bindupdatequeue");
            if (jArray == JsonNull())
            {
                jArray = JsonArray();
            }
            if (JsonFind(jArray, JsonString(sBind)) == JsonNull())
            {
                jArray = JsonArrayInsert(jArray, JsonString(sBind));
            }
            //SendDebugMessage("Save bind update queue, contains " + IntToString(JsonGetLength(jArray)) + " items");
            jUserData = JsonObjectSet(jUserData, "bindupdatequeue", jArray);
            NuiSetUserData(oPlayer, nToken, jUserData);
        }
        
    }
}
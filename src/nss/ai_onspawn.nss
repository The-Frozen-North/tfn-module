/*/////////////////////// [On Spawn] ///////////////////////////////////////////
    Filename: J_AI_OnSpawn or nw_c2_default9
///////////////////////// [On Spawn] ///////////////////////////////////////////
    This file contains options that will determine some AI behaviour, and a lot
    of toggles for turning things on/off. A big read, but might be worthwhile.

    The documentation is actually fully in the readme files, under the name
    "On Spawn.html", under "AI File Explanations".

    The order of the options:

    - Important Spawn Settings                   N/A
    - Targeting & Fleeing                       (AI_TARGETING_FLEE_MASTER)
    - Fighting & Spells                         (AI_COMBAT_MASTER)
    - Other Combat - Healing, Skills & Bosses   (AI_OTHER_COMBAT_MASTER)
    - Other - Death corpses, minor things       (AI_OTHER_MASTER)
    - User Defined                              (AI_UDE_MASTER)
    - Shouts                                     N/A
    - Default Bioware settings (WP's, Anims)    (NW_GENERIC_MASTER)

    The OnSpawn file is a settings file. These things are set onto a creature, to
    define cirtain actions. If more than one creature has this script, they all
    use the settings, unless If/Else statements are used somehow. There is also
    the process of setting any spells/feats availible, and hiding and walk waypoints
    are started.

    Other stuff:
    - Targeting is imporant :-D
    - If you delete this script, there is a template for the On Spawn file
      in the zip it came in, for use in the "scripttemplate" directory.
///////////////////////// [History] ////////////////////////////////////////////
    Note: I have removed:
    - Default "Teleporting" and exit/return (this seemed bugged anyway, or useless)
    - Spawn in animation. This can be, of course, re-added.
    - Day/night posting. This is uneeded, with a changed walk waypoints that does it automatically.

    1.0-1.2 - Used short amount of spawn options.
    1.3 - All constants names are changed, I am afraid.
        - Added Set/Delete/GetAIInteger/Constant/Object. This makes sure that the AI
          doesn't ever interfere with other things - it pre-fixes all stored things
          with AI_INTEGER_ (and so on)
    1.4 - TO DO: Clear up some old non-working ones
        - Added in User Defined part of the script, an auto-turn-off-spells for
          Ranger and Paladin classes. Need to test - perhaps 1.64 fixed it?


        Spawn options changed:
        - Removed AI level settings (can still be done manually)
        - Added optional (and off by default) fear-visual for fleeing


///////////////////////// [Workings] ///////////////////////////////////////////
    Note: You can do without all the comments (it may be that you don't want
    the extra KB it adds or something, although it does not at all slow down a module)
    so as long as you have these at the end:

    AI_SetUpEndOfSpawn();
    DelayCommand(2.0, SpawnWalkWayPoints());

    Oh, and the include file (Below, "j_inc_spawnin") must be at the top like
    here. Also recommended is the AI_INTELLIGENCE and AI_MORALE being set (if
    not using custom AI).
///////////////////////// [Arguments] //////////////////////////////////////////
    Arguments: GetIsEncounterCreature
///////////////////////// [On Spawn] /////////////////////////////////////////*/

// Treasure Includes - See end of spawn for uncomment options.

//#include "nw_o2_coninclude"
// Uncomment this if you want default NwN Treasure - Uses line "GenerateNPCTreasure()" at the end of spawn.
// - This generates random things from the default pallet based on the creatures level + race

//#include "x0_i0_treasure"
// Uncomment this if you want the SoU Treasure - Uses line "CTG_GenerateNPCTreasure()" at the end of spawn.
// - This will spawn treasure based on chests placed in the module. See "x0_i0_treasure" for more information.

// This is required for all spawn in options!
#include "inc_ai_spawn"

#include "inc_respawn"
#include "nwnx_creature"
#include "inc_loot"

void CopyKey()
{
// duplicate the key but make it unpickpocketable/undroppable
    object oItem = GetFirstItemInInventory();
    object oNewItem;

    while (GetIsObjectValid(oItem))
    {
        if (GetBaseItemType(oItem) == BASE_ITEM_KEY)
        {
            oNewItem = CopyItem(oItem, OBJECT_SELF, TRUE);
            SetDroppableFlag(oNewItem, FALSE);
            SetPickpocketableFlag(oNewItem, FALSE);
            break;
        }

        oItem = GetNextItemInInventory();
    }
}

void main()
{
/************************ [Important Spawn Settings] **************************/
    int nIntelligence = GetAbilityScore(OBJECT_SELF, ABILITY_INTELLIGENCE)/2;
    if (nIntelligence > 10) nIntelligence = 10;
    if (nIntelligence < 1) nIntelligence = 1;
    SetAIInteger(AI_INTELLIGENCE, nIntelligence);
        // Intelligence value of the creauture. Can be 1-10, read readme's for help.


    int nMorale = 10;
    if (GetClassByPosition(1) == CLASS_TYPE_COMMONER) nMorale = -1;

    SetAIInteger(AI_MORALE, nMorale);
        // Will save (See readme). Remember: -1 or below means they always flee.
    //SetCustomAIFileName("CUSTOM_AI_FILE");
        // Sets our custom AI file. Really, only animation settings will apply when this is set.
        // - Can sort actions against a imputted target (EG: On Percieved enemy) by
        //   "GetLocalObject(OBJECT_SELF, "AI_TEMP_SET_TARGET");"
/************************ [Important Spawn Settings] **************************/

/************************ [Targeting] ******************************************
    All targeting settings.
************************* [Targeting] *****************************************/
    //SetSpawnInCondition(AI_FLAG_TARGETING_LIKE_LOWER_HP, AI_TARGETING_FLEE_MASTER);
        // We only attack the lowest current HP.
    //SetSpawnInCondition(AI_FLAG_TARGETING_LIKE_LOWER_AC, AI_TARGETING_FLEE_MASTER);
        // We only attack the lowest AC (as in 1.2).
    //SetSpawnInCondition(AI_FLAG_TARGETING_LIKE_LOWER_HD, AI_TARGETING_FLEE_MASTER);
        // Target the lowest hit dice
    //SetSpawnInCondition(AI_FLAG_TARGETING_LIKE_MAGE_CLASSES, AI_TARGETING_FLEE_MASTER);
        // We go straight for mages/sorcerors. Nearest one.
    //SetSpawnInCondition(AI_FLAG_TARGETING_LIKE_ARCHERS, AI_TARGETING_FLEE_MASTER);
        // We go for the nearest enemy with a ranged weapon equipped.
    //SetSpawnInCondition(AI_FLAG_TARGETING_LIKE_PCS, AI_TARGETING_FLEE_MASTER);
        // We go for the nearest seen PC enemy.

    //SetAIConstant(AI_FAVOURED_ENEMY_RACE, RACIAL_TYPE_HUMAN);
        // The AI attacks the nearest enemy, seen, of this race. Use the RACIAL_* constants.
    //SetAIConstant(AI_FAVOURED_ENEMY_CLASS, CLASS_TYPE_BARD);
        // The AI attacks the nearest enemy, seen, of this class. Use the CLASS_* constants.

    // Target changing - see readme for info.
    //SetAIInteger(AI_MAX_TURNS_TO_ATTACK_ONE_TARGET, 6);
        // Maximum rounds to attack the current target, before re-checking.
    // % Chance to re-set each target type each round (Could result in current target still)
    //SetAIInteger(AI_MELEE_LAST_TO_NEW_TARGET_CHANCE, 20);
    //SetAIInteger(AI_RANGED_LAST_TO_NEW_TARGET_CHANCE, 20);
    //SetAIInteger(AI_SPELL_LAST_TO_NEW_TARGET_CHANCE, 20);

    // We only target PC's if there are any in range if this is set
    //SetSpawnInCondition(AI_FLAG_TARGETING_FILTER_FOR_PC_TARGETS, AI_TARGETING_FLEE_MASTER);

    // Main explanation of AI_SetAITargetingValues, see the AI readme (spawn file)
    // - Remember, uncommenting one will just ignore it (so will never check target's
    //   AC without TARGETING_AC on)

    AI_SetAITargetingValues(TARGETING_MANTALS, TARGET_LOWER, 1, 12);
        // Spell mantals are checked only for the spell target. Either Absense of or got any.
    AI_SetAITargetingValues(TARGETING_RANGE, TARGET_HIGHER, 2, 9);
        // Range - very imporant! Basis for all ranged/spell attacks.
    AI_SetAITargetingValues(TARGETING_AC, TARGET_LOWER, 2, 6);
        // AC is used for all phisical attacks. Lower targets lower (By default).
    AI_SetAITargetingValues(TARGETING_SAVES, TARGET_LOWER, 2, 4);
        // Used for spell attacks. Saves are sorta a AC versus spells.

    // Phisical protections. Used by spells, ranged and melee.
    // Jasperre - simple check if we are a fighter (hit lower phisicals) or a
    //            mage (attack higher!)
    if(GetBaseAttackBonus(OBJECT_SELF) > ((GetHitDice(OBJECT_SELF)/2) + 1))
    {
        // Fighter/Clerics (It is over a mages BAB + 1 (IE 0.5 BAB/Level) target lower
        AI_SetAITargetingValues(TARGETING_PHISICALS, TARGET_LOWER, 2, 6);
    }
    else
    {
        // Mages target higher (so dispel/elemental attack those who fighters
        // cannot hit as much). (the lowest BAB, under half our hit dice in BAB)
        AI_SetAITargetingValues(TARGETING_PHISICALS, TARGET_HIGHER, 1, 5);
    }
    // Base attack bonus. Used for spells and phisical attacks. Checked with GetBaseAttackBonus.
    AI_SetAITargetingValues(TARGETING_BAB, TARGET_LOWER, 1, 4);
    // Hit dice - how powerful in levels the enemy is. Used for all checks.
    AI_SetAITargetingValues(TARGETING_HITDICE, TARGET_LOWER, 1, 3);

    //AI_SetAITargetingValues(TARGETING_HP_PERCENT, TARGET_LOWER, 1, 3);
    //AI_SetAITargetingValues(TARGETING_HP_CURRENT, TARGET_LOWER, 1, 3);
    //AI_SetAITargetingValues(TARGETING_HP_MAXIMUM, TARGET_LOWER, 1, 3);
        // The HP's are the last thing to choose a target with.
/************************ [Targeting] *****************************************/

/************************ [Fleeing] ********************************************
    Fleeing - these are toggled on/off by FEARLESS flag.

    3 or under intelligence will just run away. 4 or more will know where allies
    are, and if there are none, will not run.
************************* [Fleeing] *******************************************/
    //SetSpawnInCondition(AI_FLAG_FLEEING_FEARLESS, AI_TARGETING_FLEE_MASTER);
        // Forces them to not flee. This may be set with AI_SetMaybeFearless at the end.
    //SetSpawnInCondition(AI_FLAG_FLEEING_NEVER_FIGHT_IMPOSSIBLE_ODDS, AI_TARGETING_FLEE_MASTER);
        // This will make the creature never fight against impossible odds (8HD+ different)
    //SetSpawnInCondition(AI_FLAG_FLEEING_TURN_OFF_GROUP_MORALE, AI_TARGETING_FLEE_MASTER);
        // This turns OFF any sort of group morale bonuses.

    //SetAIInteger(AMOUNT_OF_HD_DIFFERENCE_TO_CHECK, -2);
        // If enemy is within this amount of HD, we do not check morale.
    //SetAIInteger(BASE_MORALE_SAVE, 20);
        // Base DC of the will save. It is set to 20 + HD difference - Morale - Group morale mod.
    //SetAIInteger(HP_PERCENT_TO_CHECK_AT, 80);
        // %HP needed to be at to check morale. This doesn't affect "Never fight impossible odds"
    //SetSpawnInCondition(AI_FLAG_FLEEING_NO_OVERRIDING_HP_AMOUNT, AI_TARGETING_FLEE_MASTER);
        // This will turn off overriding HP checks. AI may decide to run even
        // not at the %HP above, this turns the checks off.

    SetAIInteger(AI_DAMAGE_AT_ONCE_FOR_MORALE_PENALTY, GetMaxHitPoints()/6);
        // Damage needed to be done at once to get a massive morale penalty (Below)
    SetAIInteger(AI_DAMAGE_AT_ONCE_PENALTY, 6);
        // Penalty for the above, set for some time to negativly affect morale. Added to save DC for fleeing.

    //SetSpawnInCondition(AI_FLAG_FLEEING_FLEE_TO_NEAREST_NONE_SEEN, AI_TARGETING_FLEE_MASTER);
        // If set, just runs to nearest non-seen ally, and removes the loop for a good group of allies to run to.

    //SetSpawnInCondition(AI_FLAG_FLEEING_FLEE_TO_OBJECT, AI_TARGETING_FLEE_MASTER);
        // They will flee to the nearest object of the tag below, if set.
    //SetLocalString(OBJECT_SELF, AI_FLEE_OBJECT, "BOSS_TAG_OR_WHATEVER");
        // This needs setting if the above is to work.

    //SetSpawnInCondition(AI_FLAG_FLEEING_USE_VISUAL_EFFECT, AI_TARGETING_FLEE_MASTER);
        // If this is on, we play a visual effect while we flee.
/************************ [Fleeing] *******************************************/

/************************ [Combat - Fighters] **********************************
    Fighter (Phiscal attacks, really) specific stuff - disarmed weapons, better
    at hand to hand, and archer behaviour.
************************* [Combat - Fighters] *********************************/
    //SetSpawnInCondition(AI_FLAG_COMBAT_PICK_UP_DISARMED_WEAPONS, AI_COMBAT_MASTER);
        // This sets to pick up weapons which are disarmed.

    //SetAIInteger(AI_RANGED_WEAPON_RANGE, 3);
        // This is the range at which they go into melee (from using a ranged weapon). Default is 3 or 5.

    //SetSpawnInCondition(AI_FLAG_COMBAT_BETTER_AT_HAND_TO_HAND, AI_COMBAT_MASTER);
        // Set if you want them to move forwards into HTH sooner. Will always
        // if the enemy is a mage/archer, else % based on range.

    if (GetWeaponRanged(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND)))
    {
        SetSpawnInCondition(AI_FLAG_COMBAT_ARCHER_ATTACKING, AI_COMBAT_MASTER);
            // For archers. If they have ally support, they'd rather move back & shoot then go into HTH.
        SetSpawnInCondition(AI_FLAG_COMBAT_ARCHER_ALWAYS_MOVE_BACK, AI_COMBAT_MASTER);
            // This forces the move back from attackers, and shoot bows. Very small chance to go melee.
        //SetSpawnInCondition(AI_FLAG_COMBAT_ARCHER_ALWAYS_USE_BOW, AI_COMBAT_MASTER);
            // This will make the creature ALWAYs use any bows it has. ALWAYS.
    }
    //SetSpawnInCondition(AI_FLAG_COMBAT_NO_GO_FOR_THE_KILL, AI_COMBAT_MASTER);
        // Turns off any attempts to kill dying PCs, or attack low hit point people.
        // This is only ever attempted at 9 or 10 intelligence anyway.
/************************ [Combat - Fighters] *********************************/

/************************ [Combat - Spell Casters] *****************************
    Spellcaster AI has been improved significantly. As well as adding all new spells,
    now spellcasters more randomly choose spells from the same level (EG: they
    may choose not to cast magic missile, and cast negative energy ray instead).

    There are also options here for counterspelling, fast buffing, Cheat cast spells,
    dispelling, spell triggers, long ranged spells first, immunity toggles, and AOE settings.
************************* [Combat - Spell Casters] ****************************/

    //SetSpawnInCondition(AI_FLAG_COMBAT_LONGER_RANGED_SPELLS_FIRST, AI_COMBAT_MASTER);
        // Casts spells only if the caster would not move into range to cast them.
        // IE long range spells, then medium, then short (unless the enemy comes to us!)
    //SetSpawnInCondition(AI_FLAG_COMBAT_FLAG_FAST_BUFF_ENEMY, AI_COMBAT_MASTER);
        // When an enemy comes in 40M, we fast-cast many defensive spells, as if prepared.
    //SetSpawnInCondition(AI_FLAG_COMBAT_SUMMON_FAMILIAR, AI_COMBAT_MASTER);
        // The caster summons thier familiar/animal companion. Either a nameless Bat or Badger respectivly.

    // Counterspelling/Dispelling...
    // It checks for these classes within the 20M counterspell range.
    //SetSpawnInCondition(AI_FLAG_COMBAT_COUNTER_SPELL_ARCANE, AI_COMBAT_MASTER);
        // If got dispels, it counterspells Arcane (Mage/Sorceror) spellcasters.
    //SetSpawnInCondition(AI_FLAG_COMBAT_COUNTER_SPELL_DIVINE, AI_COMBAT_MASTER);
        // If got dispels, it counterspells Divine (Cleric/Druid) spellcasters.
    //SetSpawnInCondition(AI_FLAG_COMBAT_COUNTER_SPELL_ONLY_IN_GROUP, AI_COMBAT_MASTER);
        // Recommended. Only counterspells with 5+ allies in group.

    //SetSpawnInCondition(AI_FLAG_COMBAT_DISPEL_MAGES_MORE, AI_COMBAT_MASTER);
        // Targets seen mages to dispel, else uses normal spell target.
    SetSpawnInCondition(AI_FLAG_COMBAT_DISPEL_IN_ORDER, AI_COMBAT_MASTER);
        // This will make the mage not dispel just anything all the time, but important (spell-stopping)
        // things first, others later, after some spells. If off, anything is dispelled.

    // AOE's
    //SetSpawnInCondition(AI_FLAG_COMBAT_NEVER_HIT_ALLIES, AI_COMBAT_MASTER);
        // Override toggle. Forces to never cast AOE's if it will hit an ally + harm them.
    //SetSpawnInCondition(AI_FLAG_COMBAT_AOE_DONT_MIND_IF_THEY_SURVIVE, AI_COMBAT_MASTER);
        // Allies who will survive the blast are ignored for calculating best target.
    //SetAIInteger(AI_AOE_ALLIES_LOWEST_IN_AOE, 3);
        // Defualt: 3. If amount of allies in blast radius are equal or more then
        // this, then that location is ignored.
    //SetAIInteger(AI_AOE_HD_DIFFERENCE, -8);
        // Very weak allies (who are not comparable to us) are ignored if we would hit them.

    // For these 2, if neither are set, the AI will choose AOE more if there are
    // lots of enemies, or singles if there are not many.
    //SetSpawnInCondition(AI_FLAG_COMBAT_SINGLE_TARGETING, AI_COMBAT_MASTER);
        // For Same-level spells, single target spells are used first.
    //SetSpawnInCondition(AI_FLAG_COMBAT_MANY_TARGETING, AI_COMBAT_MASTER);
        // For Same-level spells, AOE spells are used first.

    SetSpawnInCondition(AI_FLAG_COMBAT_IMPROVED_INSTANT_DEATH_SPELLS, AI_COMBAT_MASTER);
        // A few Death spells may be cast top-prioritory if the enemy will always fail saves.
    SetSpawnInCondition(AI_FLAG_COMBAT_IMPROVED_SUMMON_TARGETING, AI_COMBAT_MASTER);
        // Will use a better target to summon a creature at (EG: Ranged attacker)
    SetSpawnInCondition(AI_FLAG_COMBAT_IMPROVED_IMMUNITY_CHECKING, AI_COMBAT_MASTER);
        // Turns On "GetIsImmune" checks. Auto on for 7+ Intel.
    SetSpawnInCondition(AI_FLAG_COMBAT_IMPROVED_SPECIFIC_SPELL_IMMUNITY, AI_COMBAT_MASTER);
        // Turns On checks for Globes & levels of spells. Auto on for 9+ Intel.

    //SetSpawnInCondition(AI_FLAG_COMBAT_MORE_ALLY_BUFFING_SPELLS, AI_COMBAT_MASTER);
        // This will make the caster buff more allies - or, in fact, use spells
        // to buff allies which they might have not used before.

    //SetSpawnInCondition(AI_FLAG_COMBAT_USE_ALL_POTIONS, AI_COMBAT_MASTER);
        // Uses all buffing spells before melee.

    //SetAICheatCastSpells(SPELL_MAGIC_MISSILE, SPELL_ICE_DAGGER, SPELL_HORIZIKAULS_BOOM, SPELL_MELFS_ACID_ARROW, SPELL_NEGATIVE_ENERGY_RAY, SPELL_FLAME_ARROW);
        // Special: Mages cast for ever with this set.

    // Spell triggers
    //SetSpellTrigger(SPELLTRIGGER_NOT_GOT_FIRST_SPELL, FALSE, 1, SPELL_PREMONITION);
        // This is just an example. See readme for more info.

/************************ [Combat - Spell Casters] ****************************/

/************************ [Combat - Dragons] ***********************************
    I have a fondness for dragons - in NWN they are deprived of many abilities. Here
    are some new ones for your enjoyment! Switches and flying for ANYTHING! :-)
************************* [Combat - Dragons] **********************************/

    //SetSpawnInCondition(AI_FLAG_COMBAT_NO_WING_BUFFET, AI_COMBAT_MASTER);
        //This sets so there is no Dragon wing buffet. Readme has details of it.
    //SetAIInteger(AI_DRAGON_FREQUENCY_OF_BUFFET, 3);
        // Min. Amount of Rounds between each buffet. See readme for counter defaults. Def: 3
    //SetAIInteger(AI_DRAGON_FREQUENCY_OF_BREATH, 3);
        // Min. Amount of Rounds between each breath use. See readme for counter defaults. Def: 3

    // Default checks for dragon flying automatic turning on of flying.
    if(GetLevelByClass(CLASS_TYPE_DRAGON) || GetRacialType(OBJECT_SELF) == RACIAL_TYPE_DRAGON)
    {
        SetSpawnInCondition(AI_FLAG_COMBAT_FLYING, AI_COMBAT_MASTER);
        // This turns ON combat flying. I think anything winged looks A-OK. See readme for info.
    }
/************************ [Combat - Dragons] **********************************/

/************************ [Combat Other - Healers/Healing] *********************
    Healing behaviour - not specifically clerics. See readme.
************************* [Combat Other - Healers/Healing] ********************/
    //SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_HEAL_AT_PERCENT_NOT_AMOUNT, AI_OTHER_COMBAT_MASTER);
        // if this is set, we ignore the amount we need to be damaged, as long
        // as we are under AI_HEALING_US_PERCENT.
    //SetAIInteger(AI_HEALING_US_PERCENT, 50);
        // % of HP we need to be at until we heal us at all. Default: 50
    //SetAIInteger(AI_HEALING_ALLIES_PERCENT, 60);
        // % of HP allies would need to be at to heal them Readme = info. Default: 60
    SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_WILL_RAISE_ALLIES_IN_BATTLE, AI_OTHER_COMBAT_MASTER);
        // Turns on rasing dead with Resurrection/Raise dead.
    //SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_CURING, AI_OTHER_COMBAT_MASTER);
        // This turns off all healing.
    //SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_ONLY_CURE_SELF, AI_OTHER_COMBAT_MASTER);
        // This turns off ally healing.
    //SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_ONLY_RESTORE_SELF, AI_OTHER_COMBAT_MASTER);
        // This turns off ally restoring (Remove/Restoration).
    //SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_USE_BAD_HEALING_SPELLS, AI_OTHER_COMBAT_MASTER);
        // This forces all cure spells to be used, check readme.
    //SetAIInteger(SECONDS_BETWEEN_STATUS_CHECKS, 30);
        // Seconds between when we loop everyone for bad effects like Fear/stun ETC. If not set, done each round.
    //SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_GIVE_POTIONS_TO_HELP, AI_OTHER_COMBAT_MASTER);
        // ActionGiveItem standard healing potion's to allies who need them, if they possess them.

/************************ [Combat Other - Healers/Healing] ********************/

/************************ [Combat Other - Skills] ******************************
    Skills are a part of fighting - EG Taunt. These are mainly on/off switches.
    A creature will *may* use it if they are not set to "NO_" for the skill.
************************* [Combat Other - Skills] *****************************/

    // "NO" - This is for forcing the skill NEVER to be used by the combat AI.
    // "FORCE" - This forces it on (and to be used), except if they have no got the skill.

    SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_PICKPOCKETING, AI_OTHER_COMBAT_MASTER);
    //SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_FORCE_PICKPOCKETING, AI_OTHER_COMBAT_MASTER);
    //SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_TAUNTING, AI_OTHER_COMBAT_MASTER);
    //SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_FORCE_TAUNTING, AI_OTHER_COMBAT_MASTER);
    //SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_EMPATHY, AI_OTHER_COMBAT_MASTER);
    //SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_FORCE_EMPATHY, AI_OTHER_COMBAT_MASTER);
    //SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_HIDING, AI_OTHER_COMBAT_MASTER);
    //SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_FORCE_HIDING, AI_OTHER_COMBAT_MASTER);
    //SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_OPENING_LOCKED_DOORS, AI_OTHER_COMBAT_MASTER);
    //SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_FORCE_OPENING_LOCKED_DOORS, AI_OTHER_COMBAT_MASTER);
    //SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_USING_HEALING_KITS, AI_OTHER_COMBAT_MASTER);
    //SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_PARRYING, AI_OTHER_COMBAT_MASTER);
    //SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_FORCE_PARRYING, AI_OTHER_COMBAT_MASTER);
    //SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_SEARCH, AI_OTHER_COMBAT_MASTER);
    //SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_FORCE_SEARCH, AI_OTHER_COMBAT_MASTER);
    // - Concentration - special notes in the readme
    //SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_CONCENTRATION, AI_OTHER_COMBAT_MASTER);
    //SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_FORCE_CONCENTRATION, AI_OTHER_COMBAT_MASTER);

/************************ [Combat Other - Skills] *****************************/

/************************ [Combat Other - Leaders] *****************************
    Leaders/Bosses can be set to issue some orders and inspire more morale - and bring
    a lot of allies to a battle at once!
************************* [Combat Other - Leaders] ****************************/
    if (GetLocalInt(OBJECT_SELF, "boss") == 1 || GetLocalInt(OBJECT_SELF, "semiboss") == 1)
    {
        SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_GROUP_LEADER, AI_OTHER_COMBAT_MASTER);
            // Special leader. Can issuse some orders. See readme for details.

        SetSpawnInCondition(AI_FLAG_OTHER_COMBAT_BOSS_MONSTER_SHOUT, AI_OTHER_COMBAT_MASTER);
            // Boss shout. 1 time use - calls all creatures in X meters (below) for battle!
        //SetAIInteger(AI_BOSS_MONSTER_SHOUT_RANGE, 60);
            // Defaults to a 60 M range. This can change it. Note: 1 toolset square = 10M.
    }
/************************ [Combat Other - Leaders] ****************************/

/************************ [Other - Behaviour/Generic] **************************
    This is generic behaviours - alright, really it is all things that cannot
    really be categorised.
************************* [Other - Behaviour/Generic] *************************/

    //SetSpawnInCondition(AI_FLAG_OTHER_NO_CLEAR_ACTIONS_BEFORE_CONVERSATION, AI_OTHER_MASTER);
        // No ClearAllActions() before BeginConversation. May keep a creature sitting.
    //SetSpawnInCondition(AI_FLAG_OTHER_NO_POLYMORPHING, AI_OTHER_MASTER);
        // This will stop all polymorphing spells feats from being used.
    //SetSpawnInCondition(AI_FLAG_OTHER_CHEAT_MORE_POTIONS, AI_OTHER_MASTER);
        // If at low HP, and no potion, create one and use it.
    //SetAIConstant(AI_POLYMORPH_INTO, POLYMORPH_TYPE_WEREWOLF);
        // Polymorph to this creature when damaged (once, natural effect).

    //AI_CreateRandomStats(-3, 3, 6);
        // Create (Effect-applied) random statistics.
    //AI_CreateRandomOther(-2, 2, -2, 2, -2, 2, -2, 2);
        // Create (Effect-applied) random HP, saves, AC.

    //SetSpawnInCondition(AI_FLAG_OTHER_RETURN_TO_SPAWN_LOCATION, AI_OTHER_MASTER);
        // This will store our spawn location, and then move back there after combat.
    SetSpawnInCondition(AI_FLAG_OTHER_DONT_RESPOND_TO_EMOTES, AI_OTHER_MASTER);
        // This will ignore ALL chat by PC's (Enemies) who speak actions in Stars - *Bow*

    //SetSpawnInCondition(AI_FLAG_OTHER_DONT_SHOUT, AI_OTHER_MASTER);
        // Turns off all silent talking NPC's do to other NPC's.

    //SetSpawnInCondition(AI_FLAG_OTHER_SEARCH_IF_ENEMIES_NEAR, AI_OTHER_MASTER);
        // Move randomly closer to enemies in range set below.
    //SetAIInteger(AI_SEARCH_IF_ENEMIES_NEAR_RANGE, 25);
        // This is the range creatures use, in metres.

    //SetSpawnInCondition(AI_FLAG_OTHER_ONLY_ATTACK_IF_ATTACKED, AI_OTHER_MASTER);
        // One shot. We won't instantly attack a creature we see. See readme.

    //SetAIInteger(AI_DOOR_INTELLIGENCE, 1);
        // 3 Special "What to do with Doors" settings. See readme. Good for animals.

    //SetSpawnInCondition(AI_FLAG_OTHER_REST_AFTER_COMBAT, AI_OTHER_MASTER);
        // When combat is over, creature rests. Useful for replenising health.

    //SetSpawnInCondition(AI_FLAG_OTHER_NO_PLAYING_VOICE_CHAT, AI_OTHER_MASTER);
        // Stops any use of "PlayVoiceChat". Use with Custom speakstrings.

          /*** Death settings - still under AI_OTHER_MASTER ***/

    //AI_SetDeathResRef("Resref Here");
        // Creates a creature from the string set. Instantly destroys this creatures body on death.

    //SetAIConstant(AI_DEATH_VISUAL_EFFECT, VFX_FNF_IMPLOSION);
        // Fires this visual effect number instantly on death. Use FNF and IMP ones.

    //SetAIInteger(AI_CORPSE_DESTROY_TIME, 30);
        // Seconds before body finally gets destroyed. Used for Clerical Raise Dead on NPC's.

    //SetSpawnInCondition(AI_FLAG_OTHER_TURN_OFF_CORPSES, AI_OTHER_MASTER);
        // This turns off the SetDestroyable() usually performed, and the above timer.

    //SetSpawnInCondition(AI_FLAG_OTHER_USE_BIOWARE_LOOTING, AI_OTHER_MASTER);
        // Makes the death file use Bioware's cool SetLootable() feature when corpses would disappear.

      /*** Lag and a few performance settings - still under AI_OTHER_MASTER ***/

    //SetSpawnInCondition(AI_FLAG_OTHER_LAG_NO_ITEMS, AI_OTHER_MASTER);
        // The creature doesn't check for, or use any items that cast spells.
    //SetSpawnInCondition(AI_FLAG_OTHER_LAG_NO_SPELLS, AI_OTHER_MASTER);
        //The creature doesn't ever cast spells (and never checks them)
    //SetSpawnInCondition(AI_FLAG_OTHER_LAG_NO_LISTENING, AI_OTHER_MASTER);
        // The creature doesn't  have SetListening() set. Turns of the basic listening for shouts.
    SetSpawnInCondition(AI_FLAG_OTHER_LAG_EQUIP_MOST_DAMAGING, AI_OTHER_MASTER);
        // Uses EquipMostDamaging(), like Bioware code. No shield/second weapon equipped.
    //SetSpawnInCondition(AI_FLAG_OTHER_LAG_NO_CURING_ALLIES, AI_OTHER_MASTER);
        // This will stop checks for and curing of allies ailments.
    //SetSpawnInCondition(AI_FLAG_OTHER_LAG_IGNORE_HEARTBEAT, AI_OTHER_MASTER);
        // Stops the heartbeat running (Except Pre-Heartbeat-event).
    //SetSpawnInCondition(AI_FLAG_OTHER_LAG_TARGET_NEAREST_ENEMY, AI_OTHER_MASTER);
        // Ignores targeting settings. VERY good for lag/bad AI. Attacks nearest seen enemy.

/************************ [Other - Behaviour/Generic] *************************/

/************************ [User Defined and Shouts] ****************************
    The user defined events, set up to fire here.
    - New "Start combat attack" and "End Combat Attack" events
    - New "Pre" events. Use these to optionally stop a script from firing
      under cirtain circumstances as well! (Read nw_c2_defaultd or j_ai_onuserdef)
    (User Defined Event = UDE)
************************* [User Defined and Shouts] ***************************/

    // This is REQUIRED if we use any Pre-events. If not there, it will default
    // to the default User Defined Event script for the default AI.
    SetCustomUDEFileName("k_ai_onuserdef");

    //SetSpawnInCondition(AI_FLAG_UDE_HEARTBEAT_EVENT, AI_UDE_MASTER);             // UDE 1001
    //SetSpawnInCondition(AI_FLAG_UDE_HEARTBEAT_PRE_EVENT, AI_UDE_MASTER);         // UDE 1021
    //SetSpawnInCondition(AI_FLAG_UDE_PERCIEVE_EVENT, AI_UDE_MASTER);              // UDE 1002
    //SetSpawnInCondition(AI_FLAG_UDE_PERCIEVE_PRE_EVENT, AI_UDE_MASTER);          // UDE 1022
    //SetSpawnInCondition(AI_FLAG_UDE_END_COMBAT_ROUND_EVENT, AI_UDE_MASTER);      // UDE 1003
    //SetSpawnInCondition(AI_FLAG_UDE_END_COMBAT_ROUND_PRE_EVENT, AI_UDE_MASTER);  // UDE 1023
    //SetSpawnInCondition(AI_FLAG_UDE_ON_DIALOGUE_EVENT, AI_UDE_MASTER);           // UDE 1004
    //SetSpawnInCondition(AI_FLAG_UDE_ON_DIALOGUE_PRE_EVENT, AI_UDE_MASTER);       // UDE 1024
    //SetSpawnInCondition(AI_FLAG_UDE_ATTACK_EVENT, AI_UDE_MASTER);                // UDE 1005
    //SetSpawnInCondition(AI_FLAG_UDE_ATTACK_PRE_EVENT, AI_UDE_MASTER);            // UDE 1025
    //SetSpawnInCondition(AI_FLAG_UDE_DAMAGED_EVENT, AI_UDE_MASTER);               // UDE 1006
    //SetSpawnInCondition(AI_FLAG_UDE_DAMAGED_PRE_EVENT, AI_UDE_MASTER);           // UDE 1026
    //SetSpawnInCondition(AI_FLAG_UDE_DEATH_EVENT, AI_UDE_MASTER);                 // UDE 1007
    //SetSpawnInCondition(AI_FLAG_UDE_DEATH_PRE_EVENT, AI_UDE_MASTER);             // UDE 1027
    //SetSpawnInCondition(AI_FLAG_UDE_DISTURBED_EVENT, AI_UDE_MASTER);             // UDE 1008
    //SetSpawnInCondition(AI_FLAG_UDE_DISTURBED_PRE_EVENT, AI_UDE_MASTER);         // UDE 1028
    //SetSpawnInCondition(AI_FLAG_UDE_RESTED_EVENT, AI_UDE_MASTER);                // UDE 1009
    //SetSpawnInCondition(AI_FLAG_UDE_RESTED_PRE_EVENT, AI_UDE_MASTER);            // UDE 1029
    //SetSpawnInCondition(AI_FLAG_UDE_SPELL_CAST_AT_EVENT, AI_UDE_MASTER);         // UDE 1011
    //SetSpawnInCondition(AI_FLAG_UDE_SPELL_CAST_AT_PRE_EVENT, AI_UDE_MASTER);     // UDE 1031
    //SetSpawnInCondition(AI_FLAG_UDE_ON_BLOCKED_EVENT, AI_UDE_MASTER);            // UDE 1015
    //SetSpawnInCondition(AI_FLAG_UDE_ON_BLOCKED_PRE_EVENT, AI_UDE_MASTER);        // UDE 1035

    //SetSpawnInCondition(AI_FLAG_UDE_COMBAT_ACTION_EVENT, AI_UDE_MASTER);         // UDE 1012
        // Fires when we have finnished all combat actions.
    //SetSpawnInCondition(AI_FLAG_UDE_COMBAT_ACTION_PRE_EVENT, AI_UDE_MASTER);     // UDE 1032
        // This fires at the start of DetermineCombatRound() *IF they can do an action*.
    //SetSpawnInCondition(AI_FLAG_UDE_DAMAGED_AT_1_HP, AI_UDE_MASTER);             // UDE 1014
        // Fires when we are damaged, and are at 1 HP. Use for immortal-flagged creatures.

 /*** Speakstrings - as it were, said under cirtain conditions % chance each time ***/

    //AI_SetSpawnInSpeakArray(AI_TALK_ON_CONVERSATION, 100, 4, "Hello there", "I hope you enjoy your stay", "Do you work here too?", "*Hic*");
        // On Conversation - see readme. Replaces BeginConversation().

    // Morale
    //AI_SetSpawnInSpeakArray(AI_TALK_ON_MORALE_BREAK, 100, 3, "No more!", "I'm outta here!", "Catch me if you can!");
        // Spoken at running point, if they run to a group of allies.
    //AI_SetSpawnInSpeakArray(AI_TALK_ON_CANNOT_RUN, 100, 3, "Never give up! Never surrender!", "I've no where to run, so make my day!", "RRRAAAAA!!!");
        // Spoken at running point, if they can find no ally to run to, and 4+ Intelligence. See readme
    //AI_SetSpawnInSpeakValue(AI_TALK_ON_STUPID_RUN, "Ahhhhgggg! NO MORE! Run!!");
        // As above, when morale breaks + no ally, but they panic and run from enemy at 3 or less intelligence.

    // Combat
    //AI_SetSpawnInSpeakArray(AI_TALK_ON_COMBAT_ROUND_EQUAL, 5, 4, "Come on!", "You won't win!", "We are not equals! I am better!", "Nothing will stop me!");
    //AI_SetSpawnInSpeakArray(AI_TALK_ON_COMBAT_ROUND_THEM_OVER_US, 5, 4, "I'll try! try! and try again!", "Tough man, are we?", "Trying out your 'skills'? Pathetic excuse!", "Nothing good will come from killing me!");
    //AI_SetSpawnInSpeakArray(AI_TALK_ON_COMBAT_ROUND_US_OVER_THEM, 5, 4, "My strength is mighty then yours!", "You will definatly die!", "NO chance for you!", "No mercy! Not for YOU!");
        // Spoken each DetermineCombatRound. % is /1000. See readme for Equal/Over/Under values.
    //AI_SetSpawnInSpeakArray(AI_TALK_ON_TAUNT, 100, 3, "You're going down!", "No need to think, let my blade do it for you!", "Time to meet your death!");
        // If the creature uses thier skill, taunt, on an enemy this will be said.

    // Event-driven.
    //AI_SetSpawnInSpeakArray(AI_TALK_ON_PERCIEVE_ENEMY, 70, 6, "Stand and fight, lawbreaker!", "Don't run from the law!", "I have my orders!", "I am ready for violence!", "CHARGE!", "Time you died!");
        // This is said when they see/hear a new enemy, and start attacking them.
    //AI_SetSpawnInSpeakArray(AI_TALK_ON_DAMAGED, 20, 2, "Ouch, damn you!", "Haha! Nothing will stop me!");
        // A random value is set to speak when damaged, and may fire same time as below ones.
    //AI_SetSpawnInSpeakArray(AI_TALK_ON_PHISICALLY_ATTACKED, 20, 2, "Hah! Mear weapons won't defeat me!", "Pah! You cannot defeat me with such rubbish!");
        // This is said when an enemy attacks the creature with a melee/ranged weapon.
    //AI_SetSpawnInSpeakArray(AI_TALK_ON_HOSTILE_SPELL_CAST_AT, 20, 2, "No one spell will stop me!", "Is that all you have!?!");
        // This is said when an enemy attacks the creature with a hostile spell.
    //AI_SetSpawnInSpeakValue(AI_TALK_ON_DEATH, "Agggggg!");
        // This will ALWAYS be said, whenever the creature dies.

    // Specific potion ones.
    //AI_SetSpawnInSpeakValue(AI_TALK_WE_PASS_POTION, "Here! Catch!");
        // This will be spoken when the creature passes a potion to an ally. See readme.
    //AI_SetSpawnInSpeakValue(AI_TALK_WE_GOT_POTION, "Got it!");
        // This will be spoken by the creature we pass the potion too, using AssignCommand().

    // Leader ones
    //AI_SetSpawnInSpeakValue(AI_TALK_ON_LEADER_SEND_RUNNER, "Quickly! We need help!");
        // This will be said when the leader, if this creature, sends a runner.
    //AI_SetSpawnInSpeakValue(AI_TALK_ON_LEADER_ATTACK_TARGET, "Help attack this target!");
        // When the leader thinks target X should be attacked, it will say this.
    //AI_SetSpawnInSpeakValue(AI_TALK_ON_LEADER_BOSS_SHOUT, "Come my minions! To battle!");
        // This will be said when the leader, if this creature, sees an enemy and uses his "Boss Monster Shout", if turned on.


/************************ [User Defined and Shouts] ***************************/

/************************ [Bioware: Animations/Waypoints/Treasure] *************
    All Bioware Stuff. I'd check out "x0_c2_spwn_def" for the SoU/Hordes revisions.
************************* [Bioware: Animations/Waypoints/Treasure] ************/

    // SetSpawnInCondition(NW_FLAG_STEALTH, NW_GENERIC_MASTER);
    // SetSpawnInCondition(NW_FLAG_SEARCH, NW_GENERIC_MASTER);
        // Uses said skill while WalkWaypoints()

    // SetSpawnInCondition(NW_FLAG_DAY_NIGHT_POSTING, NW_GENERIC_MASTER);
        // Separate the NPC's waypoints into day & night. See comment in "nw_i0_generic" for use.

    // SetSpawnInCondition(NW_FLAG_IMMOBILE_AMBIENT_ANIMATIONS, NW_GENERIC_MASTER);
        // This will cause an NPC to use common animations it possesses,
        // and use social ones to any other nearby friendly NPCs.
    // SetSpawnInCondition(NW_FLAG_AMBIENT_ANIMATIONS, NW_GENERIC_MASTER);
        // Same as above, except NPC will wander randomly around the area.

    // SetAnimationCondition(NW_ANIM_FLAG_IS_CIVILIZED);
        // Interacts with placeables + More civilized actions. See Readme.
    // SetAnimationCondition(NW_ANIM_FLAG_CHATTER);
        // Will use random voicechats during animations, if Civilized
    // SetAnimationCondition(NW_ANIM_FLAG_IS_MOBILE_CLOSE_RANGE);
        // Will move around the area a bit more, if using Immobile Animations. See readme.

    // Treasure generating.
    //CTG_GenerateNPCTreasure();
        // SoU. Requires "x0_i0_treasure" to be uncommented. See readme.
    //GenerateNPCTreasure();
        // Default NwN. Requires "nw_o2_coninclude" to be uncommented. See readme.

/************************ [Bioware: Animations/Waypoints/Treasure] ************/

    // AI Behaviour. DO NOT CHANGE! DO NOT CHANGE!!!
    AI_SetUpEndOfSpawn();
        // This MUST be called. It fires these events:
        // SetUpSpells, SetUpSkillToUse, SetListeningPatterns, SetWeapons, AdvancedAuras.
        // These MUST be called! the AI might fail to work correctly if they don't fire!

/************************ [User] ***********************************************
    This is the ONLY place you should add user things, on spawn, such as
    visual effects or anything, as it is after SetUpEndOfSpawn. By default, this
    does have encounter animations on. This is here, so is easily changed :-D

    Be careful otherwise.

    Notes:
    - SetListening is already set to TRUE, unless AI_FLAG_OTHER_LAG_NO_LISTENING is on.
    - SetListenPattern's are set from 0 to 7.
    - You can use the wrappers AI_SpawnInInstantVisual and AI_SpawnInPermamentVisual
      for visual effects (Instant/Permament as appropriate).
************************* [User] **********************************************/
    // Example (and default) of user addition:
    // - If we are from an encounter, set mobile (move around) animations.
    int iAreaCR = GetLocalInt(GetArea(OBJECT_SELF), "cr");

    switch (GetRacialType(OBJECT_SELF))
    {
        case RACIAL_TYPE_DWARF:
        case RACIAL_TYPE_ELF:
        case RACIAL_TYPE_GNOME:
        case RACIAL_TYPE_HALFLING:
        case RACIAL_TYPE_HALFORC:
        case RACIAL_TYPE_HUMAN:
        case RACIAL_TYPE_HALFELF:
            if (GetLocalInt(OBJECT_SELF, "no_potion") != 1 && d4() == 1)
            {
                object oPotion = CreateItemOnObject("cure_potion1", OBJECT_SELF);
                SetDroppableFlag(oPotion, FALSE);
                SetPickpocketableFlag(oPotion, TRUE);
            }

            if (d10() == 1)
            {
                object oItem = GenerateTierItem(GetHitDice(OBJECT_SELF), iAreaCR, OBJECT_SELF, "Misc");
                SetDroppableFlag(oItem, FALSE);
                SetPickpocketableFlag(oItem, TRUE);
            }

            object oGold = CreateItemOnObject("nw_it_gold001", OBJECT_SELF, d2(GetHitDice(OBJECT_SELF)));
            SetDroppableFlag(oGold, FALSE);
            SetPickpocketableFlag(oGold, TRUE);
        break;
    }

       NWNX_Creature_SetCorpseDecayTime(OBJECT_SELF, 1200000);
       NWNX_Creature_SetDisarmable(OBJECT_SELF, TRUE);

// Set cr integer on self. This is used for determining treasure.
    SetLocalInt(OBJECT_SELF, "cr", FloatToInt(GetChallengeRating(OBJECT_SELF)));
    SetLocalInt(OBJECT_SELF, "area_cr", iAreaCR);

    object oItem = GetFirstItemInInventory();
    object oNewItem;

    DelayCommand(3.0, CopyKey());

    //int nRace = GetRacialType(oCreature);

    SetSpawn();

    string sScript = GetLocalString(OBJECT_SELF, "spawn_script");
    if (sScript != "") ExecuteScript(sScript);

    // If we are a ranger or paladin class, do not cast spells. This can be
    // manually removed if wished. To get the spells they have working correctly,
    // remove this, and use Monster Abilties instead of thier normal class spells.
//    if(GetLevelByClass(CLASS_TYPE_RANGER) >= 1 || GetLevelByClass(CLASS_TYPE_PALADIN) >= 1)
//    {
//        SetSpawnInCondition(AI_FLAG_OTHER_LAG_NO_SPELLS, AI_OTHER_MASTER);
//    }

/************************ [User] **********************************************/

    // Note: You shouldn't really remove this, even if they have no waypoints.
    DelayCommand(2.0, SpawnWalkWayPoints());
        // Delayed walk waypoints, as to not upset instant combat spawning.
        // This will also check if to change to day/night posts during the walking, no heartbeats.
}


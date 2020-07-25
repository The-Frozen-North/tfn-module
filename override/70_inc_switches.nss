////////////////////////////////////////////////////////////////////////////////
//                     COMMUNITY PATCH MODULE SWITCHES                        //
////////////////////////////////////////////////////////////////////////////////

#include "x2_inc_switches"

//------------------------------------------------------------------------------
// * This switch will modify the curse to bypass the ability decrease immunity
// * such as from negative energy protection spell.
// * Note: Dependant on NWN(C)X_Patch plugin.
//------------------------------------------------------------------------------
const string MODULE_SWITCH_CURSE_IGNORE_ABILITY_DECREASE_IMMUNITY = "72_CURSE_IGNORE_ABILITY_DECREASE_IMMUNITY";

//------------------------------------------------------------------------------
// * This switch will allow to use only one damage shield spell at once: elemental shield,
// * mestil's acid sheat, aura vs alignment, death armor, wounding whispers.
// * When one of these spells is cast, any other such spell is dispelled.
//------------------------------------------------------------------------------
const string MODULE_SWITCH_DISABLE_DAMAGE_SHIELD_STACKING = "72_DISABLE_DAMAGE_SHIELD_STACKING";

//------------------------------------------------------------------------------
// * This switch will allow to use only one weapon boost spell at once: magic weapon,
// * greater magic weapon, bless weapon, flame weapon, holy sword, deafning clang,
// * keen edge, darkfire and black staff.
// * When one of these spells is cast on same item, the item gets stripped of all
// * temporary itemproperties.
//------------------------------------------------------------------------------
const string MODULE_SWITCH_DISABLE_WEAPON_BOOST_STACKING = "72_DISABLE_WEAPON_BOOST_STACKING";

//------------------------------------------------------------------------------
// * This switch controlls how much persistent AOE spells of the same type can player cast
// * in the same area. This will stop the cheesy tactics to stack dozen of blade barries or
// * acid fogs and lure monsters into it.
// * Unlike weapon boosts and damage shields, this switch allows to set specific number of
// * allowed aoes spells, so 1 = max 1, 2 = max 2 etc.
//------------------------------------------------------------------------------
const string MODULE_SWITCH_DISABLE_AOE_SPELLS_STACKING = "72_DISABLE_AOE_SPELLS_STACKING";

//------------------------------------------------------------------------------
// * This switch will enable hardcore DnD rules for initiative.
// * Character who loses initiative roll is considered flatfooted against attacker who won
// * the check until he attacks for the first time. Unlike DnD, the ammount of time the
// * character is flatfooted is reduced to first flurry. Still, that gives considerable
// * benefit to the attacker and makes intiative and feats improving initiative usefull.
// * Note: Dependant on NWN(C)X_Patch plugin.
//------------------------------------------------------------------------------
const string MODULE_SWITCH_HARDCORE_INITIATIVE = "72_HARDCORE_INITIATIVE";

//------------------------------------------------------------------------------
// * This switch will enable hardcore DnD rules for uncanny dodge 2 and sneak attack.
// * Character with uncanny dodge II can no longer be flanked.
// * This defense denies another rogue the ability to sneak attack the character by flanking
// * her, unless the attacker has at least four more rogue levels than the target does.
// * Classes granting uncanny dodge stacks together for a purpose of this calculation.
// * Note: Dependant on NWN(C)X_Patch plugin.
//------------------------------------------------------------------------------
const string MODULE_SWITCH_HARDCORE_UNCANNY_DODGE = "72_HARDCORE_UNCANNY_DODGE";

//------------------------------------------------------------------------------
// * This switch will enable hardcore DnD rules for evasion and improved evasion.
// * Evasion feats will only work in light or no armor. Also a character must not
// * be helpless ie. under effects of stun, paralysis, petrify, sleep or timestop.
//------------------------------------------------------------------------------
const string MODULE_SWITCH_HARDCORE_EVASION_RULES = "72_HARDCORE_EVASION_RULES";

//------------------------------------------------------------------------------
// * This switch will give flying creatures immunity to all ground traps.
// * Specific traps can be set to ignore this immunity via "DISALLOW_FLYING" int 1
// * variable on trigger.
// * Note: Dependant on NWN(C)X_Patch plugin.
//------------------------------------------------------------------------------
const string MODULE_SWITCH_ENABLE_FLYING_TRAP_IMMUNITY = "72_ENABLE_FLYING_TRAP_IMMUNITY";

//------------------------------------------------------------------------------
// * This switch will disable all monk abilities in polymorph. That is monk AC from
// * high wisdom, monk AC from class levels, monk speed and monk unarmed attack progression.
// * Note: Dependant on NWN(C)X_Patch plugin.
//------------------------------------------------------------------------------
const string MODULE_SWITCH_DISABLE_MONK_ABILITIES_IN_POLYMORPH = "72_DISABLE_MONK_IN_POLYMORPH";

//------------------------------------------------------------------------------
// * This switch will detach immunity to paralysis from the immunity to mind spells.
// * This is usefull if you want to nerf the classic mind immunity spells and give higher
// * meaning to the freedom of movement, PM/RDD or items with paralysis immunity.
// * Note: Dependant on NWN(C)X_Patch plugin.
//------------------------------------------------------------------------------
const string MODULE_SWITCH_DISABLE_PARALYZE_MIND_SPELL_IMMUNITY = "72_DISABLE_PARALYZE_MIND_SPELL_IMMUNITY";

//------------------------------------------------------------------------------
// * This switch will detach immunity to sneak attacks from the immunity to critical hits.
// * This will allow to make a creature immune to critical hits but not sneak attack.
// * Applies also to the Death Attack.
// * Note: Dependant on NWN(C)X_Patch plugin.
//------------------------------------------------------------------------------
const string MODULE_SWITCH_DISABLE_SNEAK_ATTACK_CRITICAL_IMMUNITY = "72_DISABLE_SNEAK_CRITICAL_IMMUNITY";

//------------------------------------------------------------------------------
// * This switch will completely disable all AC bonuses from tumble.
// * Note: Dependant on NWN(C)X_Patch plugin.
//------------------------------------------------------------------------------
const string MODULE_SWITCH_DISABLE_TUMBLE_AC_BONUS = "72_DISABLE_TUMBLE_AC";

//------------------------------------------------------------------------------
// * This switch will enforce a one roll only rule for devastating critical ability.
// * This is a very efficient method of making this feat more balanced yet still allow
// * to slain a monster with single blow as this was designed.
// * Value of 1 - works for everyone
// * Value of 2 - works only for players, monster's devastating isn't affected
// * Note: Dependant on NWN(C)X_Patch plugin. CURRENTLY NONFUNCTIONAL !!!
//------------------------------------------------------------------------------
const string MODULE_SWITCH_DEVASTATING_CRITICAL_ONCE_PER_TARGET = "72_DEVAST_ONCE_PER_TARGET";

//------------------------------------------------------------------------------
// * This switch will disable "polymorph end" check which is performed every 6 seconds
// * via pseudo heartbeat in order to clean all polymorph related effects such as
// * ability bonuses, temporary hp etc. in case a module doesn't have properly
// * merged module events with 1.72. Activating this switch will disable this check
// * which is useful in multiplayer to make the polymorph new system more optimized.
// * Make sure that you got OnEquip and OnUnEquip events merged properly before
// * disabling this!
//------------------------------------------------------------------------------
const string MODULE_SWITCH_POLYMORPH_DISABLE_POLYMORPH_END_CHECK = "72_POLYMORPH_DISABLE_POLYMORPH_END_CHECK";

//------------------------------------------------------------------------------
// * This switch will allow to merge every items the character wears into every
// * polymorph shape in game even Tenser's transformation. This automatically enables
// * the "merge arms" switch.
// * Note: for unarmed shapes only defensive properties from weapon will merge.
//------------------------------------------------------------------------------
const string MODULE_SWITCH_POLYMORPH_MERGE_EVERYTHING = "72_POLYMORPH_MERGE_EVERYTHING";

//------------------------------------------------------------------------------
// * This switch will merge intelligence, charisma and wisdom from all items no matter
// * if the shape merges them or not. The reason for this is when you want to stop
// * losing spellslots from ability increases on items while polymorphed.
// * In case the player is a monk, he will get AC decrease matching the increase in wisdom
// * over what shape normally allows.
// * Note, use this switch only when module is not running NWNX. NWNX_Patch handles this
// * automatically in a better way - slots which would be normally lost will only be
// * consumed. Also note this won't fix, unlike NWNX, losing spell slots from bonus spell slot
// * itemproperties.
//------------------------------------------------------------------------------
const string MODULE_SWITCH_POLYMORPH_MERGE_CASTING_ABILITY = "72_POLYMORPH_MERGE_CASTING_ABILITY";

//------------------------------------------------------------------------------
// * This switch will make all associates to jump with player when using area transition
// * leading into spot within the same area.
//------------------------------------------------------------------------------
const string MODULE_SWITCH_JUMP_ASSOCIATES_WITH_PLAYER = "72_JUMP_ASSOCIATES_WITH_PLAYER";

//------------------------------------------------------------------------------
// * This switch will allow to open henchman inventory even in modules where this feature
// * wasn't implemented (like NWN Original Campaign).
//------------------------------------------------------------------------------
const string MODULE_SWITCH_MANAGE_HENCHMAN_INVENTORY = "71_MANAGE_OC_HENCHMAN_INVENTORY";

//------------------------------------------------------------------------------
// * This switch will change the behavior of the Empower Spell feat to what it was
// * introduced in the Shadows of the Undertide expansion. This behavior empowers
// * only the result of the dice values and any bonus is just added to the result.
//------------------------------------------------------------------------------
const string MODULE_SWITCH_SOU_EMPOWER_SPELL_BEHAVIOR = "71_SOU_EMPOWER_SPELL_BEHAVIOR";

//------------------------------------------------------------------------------
// * This switch will allow to summon and keep multiple creatures at the same time.
// * Value of 1 means unlimited summoning, while higher values holds a max limit
// * of the number of summoned creatures at the same time.
//------------------------------------------------------------------------------
const string MODULE_SWITCH_UNLIMITED_SUMMONING = "71_UNLIMITED_SUMMONING";

//------------------------------------------------------------------------------
// * This switch will enable stacking some of the item properties merged on skin when
// * polymorhing. By default only highest bonus applies.
// * With this switch active, all ability bonuses, ability penalties, skill bonuses,
// * skill penalties, saving throw bonuses and saving throw penalties stacks together.
//------------------------------------------------------------------------------
const string MODULE_SWITCH_POLYMORPH_STACK_ABILITY_BONUSES = "71_POLYMORPH_STACK_ABILITY_BONUSES";

//------------------------------------------------------------------------------
// * This switch will merge bracers or gloves in the "items" category.
//------------------------------------------------------------------------------
const string MODULE_SWITCH_POLYMORPH_MERGE_ARMS = "71_POLYMORPH_MERGE_ARMS";

//------------------------------------------------------------------------------
// * This switch will add Shifter levels into the Druid caster level calculation.
// * This works only for druid spells cast normally, this won't work for druid
// * spells cast from item, as special ability or from feat.
//------------------------------------------------------------------------------
const string MODULE_SWITCH_SHIFTER_ADDS_CASTER_LEVEL = "72_SHIFTER_ADDS_CASTER_LEVEL";

//------------------------------------------------------------------------------
// * This switch will apply Pale Master levels into the caster level calculation
// * this works only for arcane spells cast normally, this won't work for arcane
// * spells cast from item, as special ability or from feat
// * This feature is taking into consideration the 2da settings in classes.2da
// * if the builder changes the ArcSpellLvlMod for PM the formula will respect this.
//------------------------------------------------------------------------------
const string MODULE_SWITCH_PALEMASTER_ADDS_CASTER_LEVEL = "71_PALEMASTER_ADDS_CASTER_LEVEL";

//------------------------------------------------------------------------------
// * This switch will restrict usage of musical instruments by a two choices:
// * With value 1, instruments will be restricted to the Perform skill, DC for success
// * is then same as for UMD, 7+(3*SpellLevel)
// * With value 2, instruments will be restricted to the bard song feat, just the way
// * the Lich lyric are, each casting will decrement one use of the bard song feat
// * 1.72: Value 3 combine both restrictions. Also this switch can be set to specific
// * item and will override module-wide settings (so its possible to make an item without
// * restriction when restrictions are enabled or unique item with both restrictions
// * while not imposing any restriction on other musical instruments)
//------------------------------------------------------------------------------
const string MODULE_SWITCH_RESTRICT_MUSICAL_INSTRUMENTS = "71_RESTRICT_MUSICAL_INSTRUMENTS";

//------------------------------------------------------------------------------
// * This switch will change the behavior of GetScaledDuration function and allow
// * to shorten duration to 3 rounds considering who is target and who is caster.
// * By default duration is scaled only for "disable" effects like fear or paralysis.
// * Values:
// * 1: apply only when caster isn't PC and target is PC or his associate
// * 2: apply regardless of who is caster but only when target is PC or his associate
// * 3: apply regardless of who is caster and who target
//------------------------------------------------------------------------------
const string MODULE_SWITCH_SHORTENED_DURATION_OF_DISABLE_EFFECTS = "71_SHORTENED_DURATION_OF_DISABLE_EFFECTS";

//------------------------------------------------------------------------------
// * Set to TRUE if you want to allow stack poisons. By default, character cannot
// * be poisoned anymore if he is poisoned already. With this switch, the poison
// * effect itself is removed from character with also the green HP bar indicating that
// * player is poisoned but the poison is still running in background, unless cured.
// * Standard methods for removing poison except healer's kit will still work.
//------------------------------------------------------------------------------
const string MODULE_SWITCH_ALLOW_POISON_STACKING = "71_ALLOW_POISON_STACKING";

//------------------------------------------------------------------------------
// * By setting this to TRUE, weapon-boost spells like flame weapon will be able
// * to target and boost throwing weapons just like any other weapon.
//------------------------------------------------------------------------------
const string MODULE_SWITCH_ALLOW_BOOST_THROWING_WEAPONS = "72_ALLOW_BOOST_THROWING";

//------------------------------------------------------------------------------
// * By setting this to TRUE, weapon-boost spells like flame weapon will be able
// * to target and boost ranged weapons and ammunition just like any other weapon.
//------------------------------------------------------------------------------
const string MODULE_SWITCH_ALLOW_BOOST_RANGED_AND_AMMO = "72_ALLOW_BOOST_AMMO";

//------------------------------------------------------------------------------
// * By setting this to TRUE, weapon-boost spells like flame weapon will be able
// * to target and boost gloves just like any other weapon.
//------------------------------------------------------------------------------
const string MODULE_SWITCH_ALLOW_BOOST_GLOVES = "71_ALLOW_BOOST_GLOVES";

//------------------------------------------------------------------------------
// * Set to TRUE if you have issues with AOE spells not working properly - not
// * running their heartbeat. Then spellscripts will use special workaround that
// * fixes it. In addition to this we recommend to remove references to all
// * hearbeats scripts in vfx_persistent.2da
//------------------------------------------------------------------------------
const string MODULE_SWITCH_AOE_HEARTBEAT_WORKAROUND = "70_AOE_HEARTBEAT_WORKAROUND";

//------------------------------------------------------------------------------
// * Set to TRUE if you don't want the new ResistSpell behavior where spell immunity
// * is checked before spell mantle.
//------------------------------------------------------------------------------
const string MODULE_SWITCH_SPELL_MANTLE_169_BEHAVIOR = "70_RESISTSPELL_SPELLMANTLE_GOES_FIRST";

//------------------------------------------------------------------------------
// * Set this switch if you have issues with stores overfilled with sold items
// * causing huge lags when opened. This switch in fact controls how many items
// * sold by players can be in single store in one time. Older items will
// * disappear when this cap is reached. Recommended value is 100.
//------------------------------------------------------------------------------
const string MODULE_SWITCH_OVERFILLED_STORES_ISSUE_FIX = "70_OVERFILLED_STORES_ISSUE_FIX";

//------------------------------------------------------------------------------
// * Set to TRUE if you want to avoid exploits with AOE spells or if you feel
// * that "no SR" behavior is appropriate to your setting.
//------------------------------------------------------------------------------
const string MODULE_SWITCH_AOE_IGNORES_SPELL_RESISTANCE = "70_AOE_IGNORE_SPELL_RESISTANCE";

//------------------------------------------------------------------------------
// * By setting this variable with a value of 1 on a player will allow this
// * creature to ignore dying. As such he will be able to controll his character
// * even with hitpoints under 1. This feature works only on players as NPCs dies
// * immediately on 0 hitpoints.
// * NOTE: this feature requires the NWNX_Patch plugin and won't work without it!
//------------------------------------------------------------------------------
const string CREATURE_VAR_IMMUNITY_DYING = "IMMUNITY_DYING";

//------------------------------------------------------------------------------
// * By setting this variable with a value of 1 on a creature will guarantee
// * this creature immunity to being flanked. That grants immunity to sneak attack
// * caused by flanking and virtually +2AC as the flanking attackers won't get the
// * +2AB bonus to hit.
// * NOTE: this feature requires the NWNX_Patch plugin and won't work without it!
//------------------------------------------------------------------------------
const string CREATURE_VAR_IMMUNITY_FLANKING = "IMMUNITY_FLANKING";

//------------------------------------------------------------------------------
// * By setting this variable with a value of 1 on a creature will guarantee
// * this creature absolute immunity to devastating critical ability
// * NOTE: this feature requires the NWNX_Patch plugin and won't work without it!
//------------------------------------------------------------------------------
const string CREATURE_VAR_IMMUNITY_DEVASTATING_CRITICAL = "IMMUNITY_DEVAST";

//------------------------------------------------------------------------------
// * By setting this variable with a value of 1 on a creature will guarantee
// * this creature absolute immunity to polymorph abilities.
// * NOTE1: This doesn't prevent the creature from polymorphing self.
// * NOTE2: There is no ability which could polymorph other creatures in vanilla,
// * this is an extra feature for custom content made spells and abilities.
//------------------------------------------------------------------------------
const string CREATURE_VAR_IMMUNITY_POLYMORPH = "IMMUNITY_POLYMORPH";

//------------------------------------------------------------------------------
// * By setting this variable with a value of 1 on a creature will guarantee
// * this creature absolute immunity to time stop.
// * NOTE: This works only with timestop spellscript from community patch.
//------------------------------------------------------------------------------
const string CREATURE_VAR_IMMUNITY_TIME_STOP = "IMMUNITY_TIMESTOP";

//------------------------------------------------------------------------------
// * By setting this variable with a value of 1 on a creature will guarantee
// * this creature absolute immunity to any petrification spell or special ability!
//------------------------------------------------------------------------------
const string CREATURE_VAR_IMMUNITY_PETRIFICATION = "IMMUNITY_PETRIFICATION";

//------------------------------------------------------------------------------
// * By setting this variable with a value of 1 on a creature will guarantee
// * this creature absolute immunity to any drown spell or special ability!
//------------------------------------------------------------------------------
const string CREATURE_VAR_IMMUNITY_DROWN = "IMMUNITY_DROWN";

//------------------------------------------------------------------------------
// * By setting this variable with a value of 1 on a creature will guarantee
// * this creature absolute immunity to the planar rift (BBotD onhit)!
//------------------------------------------------------------------------------
const string CREATURE_VAR_IMMUNITY_PLANAR_RIFT = "IMMUNITY_PLANAR_RIFT";

//------------------------------------------------------------------------------
// * By setting this variable with a value of 1 on a creature will make
// * this creature recognized by certain spells as flying.
//------------------------------------------------------------------------------
const string CREATURE_VAR_IS_FLYING = "FLYING";

//------------------------------------------------------------------------------
// * By setting this variable with a value of 1 on a creature will make
// * this creature recognized by certain spells as mindless.
//------------------------------------------------------------------------------
const string CREATURE_VAR_IS_MINDLESS = "MINDLESS";

//------------------------------------------------------------------------------
// * By setting this variable with a value of 1 on a creature will make
// * this creature recognized by certain spells as sightless.
//------------------------------------------------------------------------------
const string CREATURE_VAR_IS_SIGHTLESS = "SIGHTLESS";

//------------------------------------------------------------------------------
// * By setting this variable with a value of 1 on a creature will make
// * this creature recognized by certain spells as vulnerable to light.
//------------------------------------------------------------------------------
const string CREATURE_VAR_IS_LIGHTVULNERABLE = "LIGHTVULNERABLE";

//------------------------------------------------------------------------------
// * Setting this variable on a creature with any special ability will override (or modify by specified value)
// * her caster level, which can't be set in toolset greater than 15. Now ANY
// * positive value is possible! However overriden caster level does not penetrate
// * spell resistance of monks of level 12 and higher properly.
// * For monk's SR, the spell still counts with original caster level set in toolset.
// * Also note, that if you set the caster level override lower than original, the
// * spell retains the original caster level for spell resistance penetration
// * purposes and the override will affect only damage/duration. (This is intended)
//------------------------------------------------------------------------------
const string CREATURE_VAR_SPECIAL_ABILITY_CASTER_LEVEL_OVERRIDE = "SPECIAL_ABILITY_CASTER_LEVEL_OVERRIDE";
const string CREATURE_VAR_SPECIAL_ABILITY_CASTER_LEVEL_MODIFIER = "SPECIAL_ABILITY_CASTER_LEVEL_MODIFIER";

//------------------------------------------------------------------------------
// * Setting this variable on a creature will override metamagic applied for every
// * special ability since AI is not able to use it. Possible values:
// * 1 or METAMAGIC_EMPOWER - always empowered
// * 2 or METAMAGIC_EXTEND - always extended
// * 4 or METAMAGIC_MAXIMIZE - always maximized
// * other metamagic have by default no effect after spell is cast
//------------------------------------------------------------------------------
const string CREATURE_VAR_SPECIAL_ABILITY_METAMAGIC_OVERRIDE = "SPECIAL_ABILITY_METAMAGIC_OVERRIDE";

//------------------------------------------------------------------------------
// * Setting this variable on a creature will override (or modify by specified value)
// * difficulty class for every special ability.
//------------------------------------------------------------------------------
const string CREATURE_VAR_SPECIAL_ABILITY_DC_OVERRIDE = "SPECIAL_ABILITY_DC_OVERRIDE";
const string CREATURE_VAR_SPECIAL_ABILITY_DC_MODIFIER = "SPECIAL_ABILITY_DC_MODIFIER";

//------------------------------------------------------------------------------
// * Same as above but applies for spells cast from spellbook, can be used even on PC
// * but remember it is not persistent by default
//------------------------------------------------------------------------------
const string CREATURE_VAR_SPELL_CASTER_LEVEL_OVERRIDE = "SPELL_CASTER_LEVEL_OVERRIDE";
const string CREATURE_VAR_SPELL_CASTER_LEVEL_MODIFIER = "SPELL_CASTER_LEVEL_MODIFIER";
const string CREATURE_VAR_SPELL_METAMAGIC_OVERRIDE = "SPELL_METAMAGIC_OVERRIDE";
const string CREATURE_VAR_SPELL_DC_OVERRIDE = "SPELL_DC_OVERRIDE";
const string CREATURE_VAR_SPELL_DC_MODIFIER = "SPELL_DC_MODIFIER";

//------------------------------------------------------------------------------
// * Same as above but applies for spells cast from items
//------------------------------------------------------------------------------
const string ITEM_VAR_CASTER_LEVEL_OVERRIDE = "ITEM_CASTER_LEVEL_OVERRIDE";
const string ITEM_VAR_CASTER_LEVEL_MODIFIER = "ITEM_CASTER_LEVEL_MODIFIER";
const string ITEM_VAR_METAMAGIC_OVERRIDE = "ITEM_METAMAGIC_OVERRIDE";
const string ITEM_VAR_DC_OVERRIDE = "ITEM_DC_OVERRIDE";
const string ITEM_VAR_DC_MODIFIER = "ITEM_DC_MODIFIER";

//------------------------------------------------------------------------------
// * Set this variable to 1 if you dont want spell resistance, spell immunity or
// * spell mantle to block any spell cast by the creature/placeable.
//------------------------------------------------------------------------------
const string CREATURE_VAR_NO_SR_CHECK = "DISABLE_RESIST_SPELL_CHECK";

//------------------------------------------------------------------------------
// * Setting this variable on a creature will allow that creature to use barbarian
// * rage ability, including mighty rage. By default, only Xanos the henchman is
// * able to activate real rage with the battlecry.
//------------------------------------------------------------------------------
const string CREATURE_VAR_ALLOW_USE_BARBARIAN_RAGE = "70_ALLOW_RAGE";

//Works as SetModuleSwitch but also sets the switch into database so it will work in multiple modules.
void SetGlobalSwitch(string sModuleSwitchConstant,int bValue);

////////////////////////////////////////////////////////////////////////////////

void SetGlobalSwitch(string sModuleSwitchConstant,int bValue)
{
 if(sModuleSwitchConstant == "X0_G_ALLOWSPELLSTOHURT" && bValue)
 {
 bValue = 10;
 }
SetLocalInt(GetModule(),sModuleSwitchConstant,bValue);
SetCampaignInt("CPP",GetStringLeft(sModuleSwitchConstant,32),bValue);//1.72: globalize
SetLocalString(GetModule(),"NWNX!PATCH!SWITCH","1");//1.72: support for nwnx-dependant switches
DeleteLocalString(GetModule(),"NWNX!PATCH!SWITCH");
}

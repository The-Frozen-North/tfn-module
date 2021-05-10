/*/////////////////////// [Include - Combat] ///////////////////////////////////
    Filename: J_INC_Generic_AI
///////////////////////// [Include - Combat] ///////////////////////////////////
    This is included in j_ai_detercombat, and executed via the main call
    AI_DetermineCombatRound, to determine a hostile action to do against the enemy.

    It works through a "List" of things, until it finds an appropriate action
    to undertake.

    It basically runs through:

    - Should I move out of an AOE spell?
    - Special abilities like Auras
    - Fleeing
    - Spells
    - Feats (For combat, like Bulls Strength)
    - Melee attack (Ranged and Melee)
///////////////////////// [History] ////////////////////////////////////////////
    1.3 - All functions prefixed to AI_
        - Lot more documentation
        - All parts changed, mainly:
            - Better targeting
            - Different Effect Setting
            - More randomised spellcasting
    1.4 - Bugfixes. Quite a few minor, usually. Some major ones.
        - Sub-spells merged into normal spell routines, it was a waste of space spliting.
        - Ethereal creatures can be sometimes seen (but not attacked).
          This is now taken into account. AI_GetTargetSanityCheck includes it,
          and a new function handles behaviour when faced with *just* 1 ethereal enemy
        - Removed quite a few Global* variables already - some were not even used
          and some used once or twice!
        - AI_ActionCastSpell() behaviour changed. New global variables track
          if it is now pointless (for a time) to check cirtain levels of spells,
          and delay checking again for 3 minutes. Increase in lag compensated by
          a much better bit of code and less global variables. IE: IGNORE TALENTS
        - Removed redudant AI_ActionUseFeatOnObject(). Added new
          AI_ActionUseSpellLikeFeat() which replaced all of its uses (and should fix
          some feat related bugs with the AI). Hardly any ActionUseFeat() calls
          are now used, except for Combat offensive feats (EG: Knockdown) which
          are without scripts.

        ADDIONTAL:
        - Need to therefore sort out casting spells from items, and potion usage. both
          have been removed from this version so far - will be put back in better later.

        - TO DO:
        - See bugs file
        - Stuff to optimise
        - Sort out items!
        - AI_ActionCastSpellRandom should be streamlined into AI_ActionCastSpell, but
          add another integer thingy. Makes it much easier. CAn have a new constant
          like "NOT_RANDOM = -1", so randomness is ignored.
        - Better allied buffing strategies and stuff. Stay invisible and use
          spells appropriate to level and range of allies. Such things like mage
          armor can be useful too (if we have it, AC increase are always good!)
    TEMP:
    - Until solved, removed all checks for AI_VALID_SPELLS things.

///////////////////////// [Workings] ///////////////////////////////////////////
    This is included in "J_AI_DeterCombat". It is the main combat include file
    and determines what to do by checking a lot of conditions.

    It has 2 User-defined Events:
    EVENT_COMBAT_ACTION_EVENT                 = 1012;
    EVENT_COMBAT_ACTION_PRE_EVENT             = 1032;

    Useful to check special things, and can be used to override default AI
    actions, or to change them once they have happened. See the user defined
    file for workings of the Pre events.
///////////////////////// [Arguments] //////////////////////////////////////////
    Arguments: Global* Objects/Integers/Toggles, GetSpawnInCondition,
               GetCommandable, AI_ActionCast* AI_ActionUse*
               (Other AI_Action* things) ClearAllActions, GetAC,
               GetCurrentHitPoints, GetMaxHitPoints,
               GetHitDice, GetCurrentAction (and lots more...).
///////////////////////// [Include - Combat] /////////////////////////////////*/

/*/////////////////////// [Intelligence Documentation] /////////////////////////
    Intelligence

    in?tel?li?gence    ( P )  Pronunciation Key  (n-tl-jns)
    n.

    1. a, The capacity to acquire and apply knowledge.
       b, The faculty of thought and reason.
       c, Superior powers of mind.
    2. An intelligent, incorporeal being, especially an angel.
    3. Information; news.

    4. a, Secret information, especially about an actual or potential enemy.
       b, An agency, staff, or office employed in gathering such information.
       c, Espionage agents, organizations, and activities considered as a
          group: ?Intelligence is nothing if not an institutionalized black
                  market in perishable commodities? (John le Carr?).

    We'll take 1. a, as our definition of intelligence in my AI files.

    It basically has an underlaying effect on how creatures work - it will
    affect some of the AI's choices and decisions.

    It will not affect everything. It will never affect anything you can
    specifically set in the spawn file, except in rare circumstances. It does
    have no effect on: Targeting, Counterspelling, Shouting, Seeing/Percieving.

    -





///////////////////////// [Intelligence Documentation] ///////////////////////*/

// Include: All constants. Also contains Get/Set/Delete Spawn In Conditions.
#include "inc_hai_constant"
// Sets effects. This doesn't have to be seperate, but I like it seperate.
#include "inc_hai_seteffx"

/******************************************************************************/
// Combat include, spell effect/immune constants
/******************************************************************************/
// Spell targets, note, have the least immunities, but these ARE set here...
// The spell target genrally is the best average lowest save, or a specific low
// save if we want to specify (and low SR).
// List (use Global to not conflict with the nwscript.nss!)
// - GlobalTargetImmunitiesHex
const int GlobalImmunityFear                      = 0x00000001;
const int GlobalImmunityNecromancy                = 0x00000002;
const int GlobalImmunityMind                      = 0x00000004;
const int GlobalImmunityNegativeLevel             = 0x00000008;
const int GlobalImmunityEntangle                  = 0x00000008;
const int GlobalImmunitySleep                     = 0x00000010;
const int GlobalImmunityPoison                    = 0x00000020;
const int GlobalImmunityDisease                   = 0x00000040;
const int GlobalImmunityDomination                = 0x00000080;
const int GlobalImmunityStun                      = 0x00000100;
const int GlobalImmunityCurse                     = 0x00000200;
const int GlobalImmunityConfusion                 = 0x00000400;
const int GlobalImmunityBlindDeaf                 = 0x00000800;
const int GlobalImmunityDeath                     = 0x00000800;
const int GlobalImmunityNegativeEnergy            = 0x00001000;
const int GlobalImmunityMantalProtection          = 0x00002000; // Its own immunity, checked sometimes.
const int GlobalImmunityPetrify                   = 0x00004000;
//const int GlobalImmunityFlying                    = 0x00008000; // Earthquake ETC.
const int GlobalImmunitySlow                      = 0x00010000;

    /*************************** Globals set-up ********************************
    We set up all spells and categories, as well as all targets we may use (its
    much easier than inputting countless entries into function headers). Any
    sort of globals that are required are also added here - anything that would
    pop up in more than one place, or would change from one or more event.
    **************************** Globals set-up *******************************/

// OUR GLOBAL CONSTANTS
int GlobalIntelligence, GlobalOurHitDice, GlobalOurAC,
    GlobalOurBaseAttackBonus, // Used and set for melee. USes GetBaseAttackBonus, as weapons are not set.
    GlobalSilenceSoItems, // This is set to TRUE if we are affected with silence
                  // - meaning no proper spells! ALWAYS off if we have auto-silence.
    GlobalInTimeStop,// This is used a LOT to see if we are in time stop
    GlobalOurChosenClass, GlobalOurChosenClassLevel, // Our chosen class and level of it.
    GlobalSpellAbilityModifier, GlobalSpellBaseSaveDC,// Spell globals - IE save DCs etc.
    GlobalSaveStupidity, // This is 10 - Intelligence. Makes Save DC checks different
                 // for lower casters - they may cast even if the enemy always saves!
    GlobalSpellPenetrationRoll, // SR penetration roll.
    GlobalOurCurrentHP, GlobalOurMaxHP, GlobalOurPercentHP,// HP globals.
    SRA, // "Spell range attacking", mage behavnOur, used for constant checking.
    GlobalWeAreSorcerorBard,// Just is GetLevelByClass(CLASS_TYPE_SORCERER/BARD),
                            // but a global. With summoning, it won't summon a similar one if the old is at low HP
    GlobalCanSummonSimilarLevel,// Checked for when set up. If a level over 0, we may
                                // Summon another spell monster at a similar level.
                                // The level is set when we cast a spell of it.
    GlobalTimeStopArraySize,
    GlobalLastSpellValid, // Random spells, if this is set to > 0, it casts it after random chances of others
    GlobalRandomCastModifier,// Random casting, the extra % added - 2xIntelligence
    GlobalWeAreBuffer; // Are we a spell buffer? AI_FLAG_COMBAT_MORE_ALLY_BUFFING_SPELLS


// OUR GLOBAL TARGETS

// Melee is actually ANY target we are attacking (depends on ranges and things).
// If OBJECT_INVALID (default) then we don't do the action!
object GlobalMeleeTarget,  // Set from either a ranged or melee target :-)
       GlobalRangedTarget, // Ranged target
       GlobalSpellTarget,  // Spell target
       GlobalDispelTarget, // Used for breaching too
       GlobalNearestEnemySeen, GlobalNearestEnemyHeard,
       GlobalNearestSeenAlly, GlobalNearestAlly,
       GlobalNearestLeader,
       GlobalBuffAlly;

// ENEMY/ALLY INTEGERS, VLAIDS ETC.

// Counting etc...global integers
    // Must be TRUE else we think there is no enemies to attack.
int GlobalAnyValidTargetObject,
    // Counts of 0 or more - specifically in our line of sight.
    GlobalEnemiesIn4Meters, GlobalTotalSeenHeardEnemies,
    // Ranged/Melee Attackers. Ranged attackers = Attackers with bows.
    GlobalMeleeAttackers, GlobalRangedAttackers,
    // Total allies. We don't count ourselves. 1.4: Removed Total People, never needed!
    GlobalTotalAllies,
    // Average's - BAB, HDs.
    GlobalAverageEnemyBAB, GlobalAverageEnemyHD,
    GlobalAverageFriendlyHD,
    // Melee target things...
    GlobalMeleeTargetAC,
    // Any VALID objects. GetIsObjectValid.
    GlobalValidLeader, GlobalValidAlly, GlobalValidSeenAlly,
    GlobalValidNearestSeenEnemy, GlobalValidNearestHeardEnemy,
    // Dispel counter. Is 1-5.
    GlobalDispelTargetHighestDispel, GlobalDispelTargetHighestBreach,
    // Spell target globals. Used for one target, throughout the spells...
    // - Saves
    GlobalSpellTargetWill, GlobalSpellTargetFort, GlobalSpellTargetReflex,
    // - Target HD, HP and race
    GlobalSpellTargetHitDice, GlobalSpellTargetCurrentHitPoints, GlobalSpellTargetRace,
    // - TRUE if seen can see spell target
    GlobalSeenSpell,
    // Special Spell things - friendly, hostile for spells (!GetIsReactionType,
    // GetIsReactionType etc.).
    GlobalFriendlyFireHostile, GlobalFriendlyFireFriendly,
    // Spell target immunity hex - this is the only one not set to local integer
    // for global effects.
    GlobalTargetImmunitiesHex,
    // If GlobalSpellTarget is immune to our spells VIA. Spell reistance or
    // spell immunity, then hostile SPELL (not abilities) are not used.
    // - This is a NUMBER - all <= X will NOT work against the enemy
    GlobalNormalSpellsNoEffectLevel;

// RANGES, Ie FLOATS :-)
float GlobalRangeToMeleeTarget, GlobalSpellTargetRange, GlobalRangeToNearestEnemy,
      GlobalRangeToAlly, GlobalOurReach, GlobalRangeToFuthestEnemy, GlobalBuffRangeAddon;

// New constant ACTION_MODE_ for "AI_SetMeleeMode()" default value. 0 and upwards
// are used.
const int ACTION_MODE_ALL_OFF = -1;

    /*************************** Functions to order ****************************
    This should be empty each patch. If you start adding your own things, adding
    them here makes changes easy to know about, if you like. I do, anyway :-P
    **************************** Functions to order ***************************/

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@ CORE AI FUNCTIONS @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

// Main call. It goes though many lines of code to decide what to do in combat
// To lengthy to explain here. Basically, input an object, it should attack
// it, or a better target. Define OnSpawn many behaviours to influence choice.
void AI_DetermineCombatRound(object oIntruder = OBJECT_INVALID);

// These all have the pre-name AttemptX - as they can return TRUE or FALSE
//***************************** AttemptSpell ***********************************

// Called from AI_AttemptAllSpells, this will run through the spell lists, until
// it casts on, else it will return FALSE.
// * nLowestSpellLevel - If it is set to more than 1, then all spells of that
//      level and lower are just ignored. Used for dragons. Default 0.
// * nBABCheckHighestLevel - We check our BAB to see if attacking them would probably
//      be a better thing to do. Default 3, it adds 5DC for each level.
// * bFirstRunThrough - used for personal spells (cast on us) like the ranged checks, for SRA.
// * bRangeLongValid etc - used for ranged spell attacking. bFirstRunThrough is a personal version.
// * bSingleSpellsFirst - Check AI_AttemptAllSpells().
// See AI_AttemptAllSpells() for more info.
int AI_RunThroughSpells(int nLowestSpellLevel, int nBABCheckHighestLevel, int bSingleSpellsFirst, int bSingleSpellOverride, int bMultiSpellOverride, int bFirstRunThrough = TRUE, int bRangeLongValid = FALSE, int bRangeMediumValid = FALSE, int bRangeShortValid = FALSE, int bRangeTouchValid = FALSE);
// This will attempt to cast a spell from all the spells we know.
// It calls AI_RunThroughSpells() to work.
// * nLowestSpellLevel - If it is set to more than 1, then all spells of that
//      level and lower are just ignored. Used for dragons. Default 0.
// * nBABCheckHighestLevel - We check our BAB to see if attacking them would probably
//      be a better thing to do. Default 3, it adds 5DC for each level.
// NOTE 1: If GlobalItemsOnly is set, we only check for item talents!
// NOTE 2: It uses the SAME target, but for ranged attacking, we use a float range to check range :-)
int AI_AttemptAllSpells(int nLowestSpellLevel = 0, int nBABCheckHighestLevel = 3);
// Returns TRUE if we counterspell a counter spell target, only does it
// if we have Dispels, and if set to want to be in a group, we are in one :-)
int AI_AttemptCounterSpell();
//***************************** AttemptSpell ***********************************

//***************************** AttemptAttack **********************************

// Used to attack. Called from AI_AttemptMeleeAttackWrapper
// We do this after we buff up with potions, and so on.
// 1 - Checks our global ranged/melee targets, range too, equips weapons.
// 2 - Checks for a feat to use (IE ranged, called shot ETC, else knockdown ETC).
// 3 - Else normal attack the target, if no feat.
int AI_EquipAndAttack();
// Used to attack. Called in determine conbat round.
// Wrappers the function AI_EquipAndAttack(), and therefore debug codes.
int AI_AttemptMeleeAttackWrapper();
// This will:
// - Get the nearest dying PC and kill them off.
// - Use the lowest HP person, and kill them off.
// - Also will check for anyone with the sleep effect, to try and Coup de Grace.
// Requires high Intelligence, And so on, of course.
int AI_AttemptGoForTheKill();
// We will, normally, use a breath weapon, and if we want to, wing buffet
// It does cast high level spells, using AttemptSpellAllSpells, with
// level 9 ones more often than level 5-7, and 8 are somewhat used :-)
int AI_AttemptDragonCombat();
// Either the chosen class is a dragon, or the appearance type is a dragon type,
// we return TRUE.
int AI_GetIsDragon();

// Beholders have special rays for eyes. This is used if the setting is set
// on spawn for beholders, or if the appearance is a beholder.
int AI_AttemptBeholderCombat();
// Beholder teleport attempt. Flees from combat.
int AI_ActionBeholderTeleport();
// Taken from x2_ai_mflayer.
// Bioware's implimenation of the Mind Suck.
void MindFlayerSuck(object oTarget);
// Illithid Use special attacks.
// This is set on spawn, or by the user on spawn.
int AI_AttemptMindflayerCombat();
//***************************** AttemptAttack **********************************

//****************************** AttemptFeat ***********************************

// Turning will be attempted in this function. It checks if we have any turning
// left, then will check if we want to turn (we don't turn every round constantly)
// then we check for creatures to turn - if there are any, we turn undead.
int AI_AttemptFeatTurning();
// This will use bard song, or damage with curse song! Both have special
// cases for the deafness and silence (introduced in later patches) and some
// other stuff.
int AI_AttemptFeatBardSong();
// Runs through summoning a familiar - uses the feat if it has it.
// INCLUDES companion as well! Will attack at range with a bow if possible.
int AI_AttemptFeatSummonFamiliar();
// This uses the best combat feat or spell it can, such as barbarian rage, divine power,
// bulls strength and so on. Spells may depend on melee enemy, or HD, or both, or range of enemy.
// Target is used for race's ect.
int AI_AttemptFeatCombatHostile();
//****************************** AttemptFeat ***********************************

//**************************** AttemptSpecial **********************************

// This will fire any aura's they have, quickened cast, and added to the top of
// thier action queue.
void AI_ActionAbilityAura();
// This will check if we do not have nSpellID's effects, have got nSpellID, and
// cheat-instant cast the spell if we do. This means that we can use it unlimited
// times (incase it gets dnSpelled!)
void AI_AttemptCastAuraSpell(int nSpellID);
// Runs though several basic checks. True, if any are performed
// 1 - Darkness. If so, dispel (inc. Ultravision) or move out (INT>=4)
// 2 - AOE spells. Move away from enemy if got effects (more so if no one near) (INT>=3)
// 3 - If invisible, need to move away from any combations. (INT>=6)
// - Returns TRUE if we did anything that would mean we don't want to do
//   another action
int AI_AttemptSpecialChecks();
// This is a good check against the enemies (highest AC one) Damage against concentration
// Also, based on allies, enemies, and things, may move back (random chance, bigger with
// more bad things, like no stoneskins, no invisibility etc.)
// We will do this more at mid-intelligence, and better checks at most intelligence.
// * Not used on spells which require no requirement (EG: pulses ETC)
int AI_AttemptConcentrationCheck(object oTarget);
// This may make the archer retreat - if they are set to, and have a ranged weapon
// and don't have point blank shot, and has a nearby ally. (INT>=1 if set to does it more if higher).
// added optional object pass through - pok
int AI_AttemptArcherRetreat(object oIntruder = OBJECT_INVALID);
// Will polymorph Self if not already so. Will return TRUE if it casts best on self.
int AI_AttemptPolyMorph();
// This will cheat-cast nSpell at oTarget. Note that we will know if we have it
// by checking what appearance we have.
void AI_ActionCastShifterSpell(int nSpell, object oTarget = OBJECT_SELF);
//**************************** AttemptSpecial **********************************

//**************************** AttemptSkills ***********************************

// This will use empathy, taunt, and if set, pickpocketing. Most are random, and
// checks are made.Heal is done in healing functions.Done against best melee target,
// or closest seen/heard.
int AI_AttemptHostileSkills();
// Uses iSkill on GlobalMeleeTarget
// - Fired from AI_AttemptHostileSkills.
void AI_ActionUseSkillOnMeleeTarget(int iSkill);
//**************************** AttemptSkills ***********************************

//******************************** Other ***************************************
// Sets a value, 1-5, for what we can Dispel. Also sets a 1-5 value for breach spells.
// The values are NOT, I repeat NOT what the spell level are. Generally, they
// class spell-stopping spells as a higher prioritory to Dispel!
// * 5 - Dispeled before hostile spells are cast at target
// * 4 - Dispeled just before level 7 or so spells.
// * 3 - Dispeled just before level 4 or so spells
// * 2 - Dispeled just before level 2 or so spells.
// * 1 - Lowest prioritory - Dispeled at the end.
// There are NO cantrips included (level 0 spells).
// - Targets GlobalDispelTarget
void AI_SetDispelableEnchantments();
// Returns a dismissal target - a target with a master, and they
// are a Familiar, Animal companion or summon.
// - Nearest one in 10 M. Seen ones only.
object AI_GetDismissalTarget();
// This will run through most avalible protections spells.
// - TRUE if we cast any.
// Used when invisible to protect before we break the invisibility.
// - We may cast many on allies too
int AI_ActionCastWhenInvisible();
// This will loop seen allies in a cirtain distance, and get the first one without
// the spells effects of nSpell1 to nSpell4 (and do not have the spells).
// - Quite expensive loop. Only used if we have the spell (nSpellToUse1+)
//   in the first place (no items!) and not the timer which stops it for a few rounds (on nSpellToUse1)
// - TRUE if it casts its any of nSpellToUseX's.
// * It has only a % chance to cast if GlobalWeAreBuffer is not TRUE.
int AI_ActionCastAllyBuffSpell(float fMaxRange, int nPercent, int nSpellToUse1, int nSpellToUse2 = AI_SPELL_INVALID, int nSpellToUse3 = AI_SPELL_INVALID, int nSpellToUse4 = AI_SPELL_INVALID, int nSpellOther1 = AI_SPELL_INVALID, int nSpellOther2 = AI_SPELL_INVALID);
// This will shout, maybe, some commands to allies. Or just command them!
void AI_ActionLeaderActions();
// Dispels or moves out of the oAOE.
// - If we have >= nMax AND <= nDamage HP...
//   AND under nPercent total HP...
// - We Dispel, or move out of the AOE. Move if friendly.
// - Use local object set to nSpell, which should be the nearest of the spell.
int AI_ActionDispelAOE(int nSpell, int bDamageOnly, float fRange, int nDamage, int nMax, int nPercent);
// Casts the breach range of spells on GlobalDispelTarget. TRUE if any are cast.
int AI_ActionCastBreach();
// Casts the dispel range of spells on GlobalDispelTarget. TRUE if any are cast.
int AI_ActionCastDispel();
// This wrappers AI_ActionCastBreach() and AI_ActionCastDispel(). Input
// nValue for 1 (Lowest priority) to 5, to see if we'll use them. Returns
// TRUE if any are cast.
int AI_ActionAttemptDispel(int nValue, int bRangeMediumValid);
// Wrappers Premonition, Greater Stoneskin and Stoneskin.
// Includes Shades Stoneskin too. SPELL_SHADES_STONESKIN
// - nLowest - 8 = Prem, 6 = Greater, 4 = Stoneskin
// - Checks AI_GetAIHaveSpellsEffect(GlobalHasStoneSkinProtections)
int AI_SpellWrapperPhisicalProtections(int nLowest = 1);
// Wrappers Energy Buffer, Protection From Elements, Resist Elements, Endure elements
// - nLowest - Goes 5, 3, 2, 1.
// - Checks AI_GetAIHaveSpellsEffect(GlobalHasElementalProtections)
int AI_SpellWrapperElementalProtections(int nLowest = 1);
// Wrappers Haste and Mass Haste.
// - nLowest - 6 = Mass, 3 = Haste
// - Checks AI_GetAIHaveSpellsEffect(GlobalHasStoneSkinProtections)
int AI_SpellWrapperHasteEnchantments(int nLowest = 1);
// Wrappers Shadow Shield, Ethereal Visage and Ghostly Visage.
// Includes Greater Shadow Conjuration Ghostly Visage (SPELL_GREATER_SHADOW_CONJURATION_MIRROR_IMAGE
// - nLowest - 7 = Shadow, 6 = Ethereal 2 = Ghostly
// - Checks AI_GetAIHaveSpellsEffect(GlobalHasVisageProtections)
int AI_SpellWrapperVisageProtections(int nLowest = 1);
// Wrappers All Mantals (Greater, Normal, Lesser) (Spell Mantals)
// - nLowest - 9 = Greater, 7 = Normal. 5 = Lesser
// - Checks AI_GetAIHaveSpellsEffect(GlobalHasMantalProtections)
int AI_SpellWrapperMantalProtections(int nLowest = 1);
// Wrappers All Globes (Greater, Shadow Conjuration, Minor)
// - nLowest - 6 = Greater, 4 = Shadow/Minor
// - Checks AI_GetAIHaveSpellsEffect(GlobalHasGlobeProtections)
int AI_SpellWrapperGlobeProtections(int nLowest = 1);
// Wrappers All Shields - Elemental Shield, Wounding Whispers
// - nLowest - 4 = Elemental, 3 = Wounding, Acid Sheath, 2 = Death Armor.
// - Checks AI_GetAIHaveSpellsEffect(GlobalHasElementalShieldSpell)
int AI_SpellWrapperShieldProtections(int nLowest = 1);
// Wrappers All Mind resistance spells - Mind blank, Lesser and Clarity. bioware likes 3's...
// - nLowest - 8 = Mind Blank, 5 = Lesser, 2 = Clarity
// - Checks AI_GetAIHaveSpellsEffect(GlobalHasMindResistanceProtections)
int AI_SpellWrapperMindResistanceProtections(int nLowest = 1);
// Wrappers All Consealment spells - Improved Invisiblity. Displacement.
// - nLowest - 4 = Improved Invisiblit, 3 = Displacement
// - Checks !AI_GetAIHaveEffect(GlobalEffectInvisible, oTarget) && !AI_GetAIHaveSpellsEffect(GlobalHasConsealmentSpells, oTarget)
int AI_SpellWrapperConsealmentEnhancements(object oTarget, int nLowest = 1);
// Shades darkness, assassin feat, normal spell.
int AI_SpellWrapperDarknessSpells(object oTarget);
// Invisibility spells + feats
int AI_SpellWrapperNormalInvisibilitySpells();
//******************************** Other ***************************************

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@ HEALING FUNCTIONS @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

//*************************** AttemptHealing ***********************************
// If our current HP is under the percent given, it will check things to heal itself, and use them.
// Used for animals ETC as well. They just don't use potions.
// This will also check levels, for appropriate healing.
// Set nMyHD to higher to use lower level spells.
// * Will un-polymorph if we are heavily damaged and can heal ourselves.
int AI_AttemptHealingSelf();
// Raises dead, and casts healing spells to heal allies.
// Leaders are checked first.
int AI_AttemptHealingAlly();
// This will heal oTarget using the best spell it can, even ones it can
// spontaeously cast.
// - Just does best spell.
// - May use spontaneous ones as well. :-)
// - Called from AI_AttemptHealing_Self and AI_AttemptHealing_Ally
// * bPotionsValid is only used if oTarget is OBJECT_SELF, IE: We put it in, so
//   not to use potions as an invalid race. if oTarget != OBJECT_SELF, it is ignored
int AI_ActionHealObject(object oTarget, int bPotionsValid = FALSE);
// Heals oTarget using undead negative energy type spells
// More basic then the normal healing routines.
// TRUE if it casts anything.
int AI_ActionHealUndeadObject(object oTarget);
// Uses spells to cure conditions. Needs to be checked fully
// - Uses allies own integers to check thier effects
// - Loops spells (Best => worst) and if we havn't cast it in an amount of time
//   we check effects (Us, leader, allies seen) until we find someone (nearest)
//   who we can cast it on.
int AI_AttemptCureCondition();
// Get the nearest seen ally creature with the effect.
// - Checks us first
// - Then checks leader
// - Then loops seen allies within 20M.
// See: AI_AttemptCureCondition
object AI_GetNearestAllyWithEffect(int nEffectHex);
// Returns the nearest ally with nMin effects, and X more based on HD.
// - Checks us first. True if (HD/6) Effects and (nMin - 1) effects
// - Checks leader next. True if (HD/5) Effects and (nMin - 2) effects
// - Checks allies after. True if (HD/4) Effects and (nMin) effects
object AI_GetNearestAllyWithRestoreEffects(int nMin);

// This will return the best spontaeous healing spell, so:
// * It uses just normal GetHasSpell for the clerical healing spells.
int AI_GetBestSpontaeousHealingSpell();

//*************************** AttemptHealing ***********************************

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@ TARGETING & ACTUAL ACTION FUNCTIONS @@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
// Actions are ActionX

//*************************** ActionsSpells ************************************

// Special case - it checks the talent again, in silence (if not already so) and
// uses the item, if it is an equal talent.
// - Will call a Shile Equip
// Returns TRUE if we did find the right talent, and it was cast.
int AI_ActionCastItemEqualTo(object oTarget, int nSpellID, int bLocation);
// This attempts to check the talent TALENT_CATEGORY_HARMFUL_RANGED, 2, which
// holds grenades. Easy checks.
// - TRUE if they fire a grenade.
int AI_AttemptGrenadeThrowing(object oTarget);
// This will cast the spell of ID in this order [Note: Always adds to time stop, as it will be on self, and benifical):
// 1. If they have the spell normally.
// * We always attack with a bow at ranged, but may attack normally after the spell.
// * If nRequirement is 0, it is considered innate.
// * If bSubspell is TRUE, we will cheat-cast and derement it.
int AI_ActionCastSpell(int nSpellID, object oTarget = OBJECT_SELF, int nRequirement = 0, int bLocation = FALSE, int bSubSpell = FALSE);
// This is used for INFLICT/CURE spells, as GetHasSpell also can return 1+ for
// any extra castings - like if we had 2 light wounds and 2 blesses, it'd return
// 4.
// This, when cast, removes one of the spell being cast, after cheat casting it.
// - DecrementRemainingSpells will work this way quite well, but no choice in
//   what to remove, it is faster then 1.3 beta which modified the spell scripts.
int AI_ActionCastSpontaeousSpell(int nSpellID, object oTarget);
// This will cast the spell of ID in this order [Note: Always adds to time stop, as it will be on self, and benifical):
// 0. If d100() is <= nRandom.
// 1. If they have the spell normally
// 2. If they have an item with the spell.
// 3. If they have a potion of the right type.
// - If we are at range from nearest enemy, we attack with a ranged weapon, else do nothing more.
// - If nTalent is -1, we do not check items.
// - Sets GlobalLastSpellValid to nSpellID if we can cast it, but don't randomly.
int AI_ActionCastSpellRandom(int nSpellID, int nRandom, object oTarget = OBJECT_SELF, int nRequirement = 0, int bLocation = FALSE);
// This will cast the spell/feat nSpellId (Or with nFeat), depending if it is a spell or a feat,
// at the summon location chosen before. Works similar to normal spells but
// at a special location.
// * If it is a feat, we use nFeat to define the feat, and nSpellId to define the
//   spellability to use.
// * If nRequirement is -1, it is a feat. If 0, it is innate (as spells)
int AI_ActionCastSummonSpell(int nSpellId, int nRequirement = 0, int nSummonLevel = 0, int nFeat = 0);
// This willcast nFirst -> nFirst + nAmount polymorph spell. It will check
// if we have nMaster (Either by feat or spell, depending on bFeat).
// TRUE if we polymorph.
// * Only decrements if bRemove is TRUE
int AI_ActionPolymorph(int nMaster, int nFirstSpell, int nAmount, int bFeat = FALSE, int bRemove = TRUE);

// Used with GlobalLastSpellValid. If GlobalLastSpellValid is 0, sets locals for
// use later, and sets GlobalLastSpellValid to the spell in question.
void AI_SetBackupCastingSpellValues(int nSpellID, object oTarget, int bLocation, int nRequirement);
// This will used a stored GlobalLastSpellValid to see if it should cast that
// spell (or attempt to!) as a backup. Uses stored targets from when it did know
// it was valid.
int AI_ActionCastBackupRandomSpell();

// If they have nFeat, they cheat-cast nSpell at oTarget.
// - This is a workaround for any feat, which acts as a spell, IE: A spell like feat,
//   (a feat with casting times and so on) and more importantly, also will cast
//   the nSpell if they have it anyway! so is useful for any feat.2da which
//   references the spells.2da for its effects.
// 1.4: Added the fact they can be normal spells.
int AI_ActionUseSpellLikeFeat(int nFeat, int nSpell, object oTarget = OBJECT_SELF);
// Wrappers action Use Talent with debug string
// * Used in healing, to cast "Heal" range before other healing spells.
// Might well remove!
void AI_ActionUseTalentDebug(talent tChosenTalent, object oTarget);
// Wrapper to check all dragon breaths, against oTarget
int AI_ActionDragonBreath(object oTarget, int nWingCounter);
// Uses tBreath if they are not immune
// - TRUE if used.
int AI_ActionUseBreath(object oTarget, talent tBreath, int nSpellID);
// This tests breath attacks or the use of the Wing Buffet, randomised each round
// and not used constantly.
// * oTarget - target to breath on (ouch, bad breath!)
int AI_DragonBreathOrWing(object oTarget);

// Only TRUE if we have a flee object.
// - Uses sArray to debug and speak
int AI_ActionFlee(string sArray);
//*************************** ActionsSpells ************************************

//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@ ALL INFO FUNCTIONS @@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@
//@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@

// Equips the best shield we have.
// - Used before we cast a spell so casters can gain maximum AC.
void AI_EquipBestShield();
// Turns on/off all melee things (not stealth or search!) but not nMode.
// * Use ACTION_MODE_ALL_OFF if you want all things off.
void AI_SetMeleeMode(int nMode = ACTION_MODE_ALL_OFF);

// GETTING ENEMY INFO

// We set up targets to Global* variables, GlobalSpellTarget, GlobalRangeTarget,
// and GlobalMeleeTarget. Counts enemies, and so on.
// - Uses oIntruder (to attack or move near) if anything.
// - We return TRUE if it ActionAttack's, or moves to an enemy - basically
//   that we cannot do an action, but shouldn't search. False if normal.
int AI_SetUpAllObjects(object oInputBackup);
// This sets up US, the user! :-)
// - Determines class to use, dragon or not.
// - And some other things that don't need to check allies/enemies for.
// - Intelligence and so on, global effects of us and so on ;-)
void AI_SetUpUs();
// Sets up all our effects, ones to heal as well.
void AI_SetUpUsEffects();
// Using the array ARRAY_ENEMY_RANGE, we return a % of seen/heard people who
// DO have any of the spells which see through the invisiblity spells.
// * nLimit - when we get to this number of people who have invisiblity, we stop and return 100%
// If ANY of the people are attacking us and have the effect, we return +30% for each.
int AI_GetSpellWhoCanSeeInvis(int nLimit);

// Returns the object to the specifications:
// * fRange - Within fRange (fTouchRange 2.25, fShortRange 8.0, fMediumRange 20.0, fLongRange = 40.0)
// * fSpread - Radius Size - RADIUS_SIZE_* constants (1.67 to 10.0M)
// * nLevel - Used for saving throws/globe checks. Level of the spell added to save checks
// * nSaveType = FALSE - SAVING_THROW_FORT/REFLEX/WILL. Not type, but the main save applied with it.
// * nShape = SHAPE_SPHERE - SHAPE_* constants.
// * bFriendlyFire = FALSE - Can this hurt allies? Best thing is to put
//      GlobalFriendlyFireHostile - GetIsReactionTypeHostile(oTarget) == TRUE
//      GlobalFriendlyFireFriendly - GetIsReactionTypeFriendly(oTarget) == FALSE
//      FALSE - Cannot hurt allies (GetIsEnemy/!GetIsFriend used)
// * bDeathImmune = FALSE - Does it use a death save? (!GetIsImmune)
// * bNecromanticSpell = FALSE - Is it a necromancy spell? Undead are also checked in this.
object AI_GetBestAreaSpellTarget(float fRange, float fSpread, int nLevel, int nSaveType = FALSE, int nShape = SHAPE_SPHERE, int bFriendlyFire = FALSE, int bDeathImmune = FALSE, int bNecromanticSpell = FALSE);

// Gets an approprate summoning location. If we are set to summon better, we
// should get a good location between us and an enemy, else, it'll just return
// our location.
location AI_GetSummonLocation();

// Returns the object to the specifications:
// Within nRange (float)
// The most targets around the creature in nRange, in nSpread.
// Can be the caster, of course
//object AI_GetBestFriendyAreaSpellTarget(float fRange, float fSpread, int nShape = SHAPE_SPHERE);

// Returns 1-4 for tiny-huge weapons. Used for disarm etc.
int AI_GetWeaponSize(object oItem);
// This returns TRUE if the target will always resist the spell given the parameters.
// - Uses GlobalOurChosenClassLevel for our level check.
int AI_SpellResistanceImmune(object oTarget);
// If the target will always save against nSaveType, and will take no damage, returns TRUE
// * Target is GlobalSpellTarget. Save is GlobalSpellTargetWill ETC.
// * nSaveType - SAVING_THROW WILL/REFLEX/FORTITUDE
// * nSpellLevel - Level of the spell being cast.
int AI_SaveImmuneSpellTarget(int nSaveType, int nSpellLevel);
// If the target will always save against nSaveType, and will take no damage, returns TRUE
// * oTarget - who saving against spell.
// * nSaveType - SAVING_THROW WILL/REFLEX/FORTITUDE
//  * The save used is GetReflexSavingThrow* ETC.
// * nSpellLevel - Level of the spell being cast.
int AI_SaveImmuneAOE(object oTarget, int nSaveType, int nSpellLevel);
// Gets the percent, of X vs Y,  nNumber/nTotal * 100 = %.
int AI_GetPercentOf(int nNumber, int nTotal);
// This returns a number, 1-4. This number is the levels
// of spell they will be totally immune to.
int AI_GetSpellLevelEffect(object oTarget);
// Input oTarget and nLevel and it will check if they are automatically
// immune to the spell being cast.
int AI_GetSpellLevelEffectAOE(object oTarget, int nLevel = 9);
// Returns TRUE if any of the checks the oGroupTarget is immune to.
int AI_AOEDeathNecroCheck(object oGroupTarget, int bNecromanticSpell, int bDeathImmune);
// Returns the healing "Rank" of nSpellId (made up by me) which the spell is.
// Used in healing, Heal (+Mass Heal) is done seperatly in the healing routines.
// * Returns a default of 0 if no valid healing spell is found (Or was a Heal spell)
// * Use bSelf to be TRUE if you want to include "Cure Other" spells in Hordes
int AI_GetHealingSpellRank(int nSpellId, int bSelf = FALSE);
// This will return the average amount healed by nSpellId, determined as if they
// were the minimum level used to cast it, and average rolls were performed.
// * Used in healing to check if we should bother using the spell yet, eg:
//   a 50HP person with a ciritical wounds potion might take it at 10HP, not 25HP,
//   because it heals a lot.
int AI_GetHealingSpellPower(int nSpellId);
// TRUE if the spell is one recorded as being cast before in time stop.
// - Checks Global "Are we in time stop?" and returns FALSE if not in time stop
int AI_CompareTimeStopStored(int nSpell1, int nSpell2 = AI_SPELL_INVALID, int nSpell3 = AI_SPELL_INVALID, int nSpell4 = AI_SPELL_INVALID);
// Sets the spell to be stored in our time stop array.
void AI_SetTimeStopStored(int nSpell);
// Deletes all time stopped stored numbers.
void AI_DeleteTimeStopStored();
// Sets the Global Hex for the enemy spell target immunties.
// 7+ Intelligence also uses GetIsImmune.
// The target is GlobalSpellTarget.
// - Uses effects loop and GetIsImmune to comprehend the most.
void AI_SortSpellImmunities();
// This will, in most occasion, ClearAllActions.
// If it does NOT, it returns FALSE, if we are doing something more important,
// and we perform that action again (or carry on doing it).
// - This also sets shadowdancer hiding if no one has trueseeing nearby
int AI_StopWhatWeAreDoing();
// Turn of hiding if turn of timer is on, and turn of searching if it is
// active.
// This should be called before any action using a feat, spell or similar, if
// we need to move.
void AI_ActionTurnOffHiding();

// Simple return TRUE if it matches hex GlobalTargetImmunitiesHex
int AI_GetSpellTargetImmunity(int nImmunityHex);
// Sets nImmunityHex to GlobalTargetImmunitiesHex.
void AI_SetSpellTargetImmunity(int nImmunityHex);

// This returns an object, not seen not heard ally, who we
// might flee to. Uses a loop, and runs only when we are going to flee for sure.
object AI_GetNearbyFleeObject();
// This returns the best primary or secondary weapon from sArray.
// It actually returns the number value, IE the place it is at. Easy to get all info from there.
// - Use nType...
//    - 0 = Highest Value :-)
//    - 1 = Highest Damage
//    - 2 = Biggest
//    - 3 = Smallest
int AI_GetWeaponArray(string sArray, object oCannotBe = OBJECT_INVALID, int nType = 0);
// Just sorts out sOriginalArrayName to sNewArrayName based on range only.
// - Also sets maxint to MAXINT_ + sNewArrayName
// - Closest to futhest
void AI_TargetingArrayDistanceStore(string sOriginalArrayName, string  sNewArrayName);
// Just sorts out sOriginalArrayName to sNewArrayName based on nType.
// nType 1 = AC, nType 2 = Total Saves, nType 3 = Phisical Protections,
// nType 4 = BAB, nType 5 = Hit Dice, nType 6 = Percent HP, nType 7 = Current HP,
// nType 8 = Maximum HP. 9 = Attacking us or not. 10 = Is a PC.
void AI_TargetingArrayIntegerStore(int nType, string sOriginalArrayName);
// This sets ARRAY_TEMP_ARRAY of integer values to sNewArrayName.
// - nTypeOfTarget, used TARGET_LOWER, TARGET_HIGHER.
// - We work until nMinimum is filled, or we get to nMinimum and we get to
//   a target with value > iInputMinimum. (20 - 25 > X?)
// Returns the amount of targets set in sNewArrayName.
int AI_TargetingArrayLimitTargets(string sNewArrayName, int nTypeOfTarget, int iInputMinLimit, int nMinLoop, int nMaxLoop);
// This sets ARRAY_TEMP_ARRAY of float values to sNewArrayName.
// - nTypeOfTarget, used TARGET_LOWER, TARGET_HIGHER.
// - We work until nMinimum is filled, or we get to nMinimum and we get to
//   a target with value > iInputMinimum. (20.0 - 25.0 > X?)
// Returns the amount of targets set in sNewArrayName.
int AI_TargetingArrayLimitTargetsFloat(string sNewArrayName, int nTypeOfTarget, float fInputMinLimit, int nMinLoop, int nMaxLoop);
// Deletes all FLoats, Integers and Objects set to sArray for valid
// objects got by GetLocalObject to sArray.
void AI_TargetingArrayDelete(string sArray);
// Check if oTarget is:
// - Dead, Petrified, AI Ignore ON, A DM, Invalid
// - Not: Seen or heard (IE: We cannot see or hear them)
// Returns: TRUE if it is SANE to attack oTarget
// Returns: FALSE if oTarget is currently ethereal. That is handled in a seperate place.
int AI_GetTargetSanityCheck(object oTarget);


// my functions - pok

void PlayVoiceChatIfNotDead(int iVoice)
{
    if (GetIsDead(OBJECT_SELF)) return;
    PlayVoiceChat(iVoice);
}

void DoCombatVoice()
{
    if (GetIsDead(OBJECT_SELF)) return;

    string sBattlecryScript = GetLocalString(OBJECT_SELF, "battlecry_script");
    if (sBattlecryScript != "")
    {
        ExecuteScript(sBattlecryScript, OBJECT_SELF);
    }
    else
    {
        int nRand = 40;
        if (GetLocalInt(OBJECT_SELF, "boss") == 1) nRand = nRand/2;
        int iVoice = -1;
        switch (Random(nRand))
        {
            case 0: iVoice = VOICE_CHAT_BATTLECRY1; break;
            case 1: iVoice = VOICE_CHAT_BATTLECRY2; break;
            case 2: iVoice = VOICE_CHAT_BATTLECRY3; break;
            case 3: iVoice = VOICE_CHAT_ATTACK; break;
            case 4: iVoice = VOICE_CHAT_TAUNT; break;
            case 5: iVoice = VOICE_CHAT_LAUGH; break;
            case 6: iVoice = VOICE_CHAT_ENEMIES; break;
        }

        if (iVoice >= 0)
        {
            float fDelay = IntToFloat(Random(10) + 1) / 10.0;
            DelayCommand(fDelay, PlayVoiceChatIfNotDead(iVoice));
        }
    }
}

//GetIsObjectValid(oTarget) && GetIsEnemy(oTarget) && GetArea(oTarget) == OBJECT_SELF && !GetIsDead(oTarget) && GetDistanceToObject(oTarget) <= 50.0
int GetIsValidTarget(object oTarget);
int GetIsValidTarget(object oTarget)
{
    if (GetIsObjectValid(oTarget) && GetIsEnemy(oTarget) && GetArea(oTarget) == OBJECT_SELF && !GetIsDead(oTarget) && GetDistanceToObject(oTarget) <= 50.0)
    {
        return TRUE;
    }
    else
    {
        return FALSE;
    }
}

// pok - new function to retrieve a target from either the master,
// or from a party member in the master's faction (party)
// we will match it to the closest target
object GetClosestPartyTarget();
object GetClosestPartyTarget()
{
    object oMaster = GetMaster();


// no master? assume it's not in a party so no target
    if (!GetIsObjectValid(oMaster))
        return OBJECT_INVALID;

    object oTarget = GetAttackTarget(oMaster);

    object oPartyTargetPC, oPartyTargetNPC;
    float fDistance = 1000.0;
    float fTargetDistance;

// use last hostile actor as fallback
    if (!GetIsValidTarget(oTarget))
        oTarget = GetLastHostileActor(oMaster);

    if (GetIsValidTarget(oTarget))
        fDistance = GetDistanceToObject(oTarget);

    // loop PCs in party

    object oPartyPC = GetFirstFactionMember(oMaster);
    while (GetIsObjectValid(oPartyPC))
    {
        oPartyTargetPC = GetAttackTarget(oPartyPC);
        fTargetDistance = GetDistanceToObject(oPartyTargetPC);

        if (!GetIsValidTarget(oPartyTargetPC))
            oPartyTargetPC = GetLastHostileActor(oPartyPC);

        if (GetIsValidTarget(oPartyTargetPC) && fTargetDistance < fDistance)
        {
            fDistance = fTargetDistance;
            oTarget = oPartyTargetPC;
        }

        oPartyPC = GetNextFactionMember(oMaster);
    }

// loop NPCs
    object oPartyNPC = GetFirstFactionMember(oMaster, FALSE);
    while (GetIsObjectValid(oPartyNPC))
    {
        oPartyTargetNPC = GetAttackTarget(oPartyNPC);

        if (!GetIsValidTarget(oPartyTargetNPC))
            oPartyTargetNPC = GetLastHostileActor(oPartyNPC);

        fTargetDistance = GetDistanceToObject(oPartyTargetNPC);

        if (GetIsValidTarget(oPartyTargetNPC) && fTargetDistance < fDistance)
        {
            fDistance = fTargetDistance;
            oTarget = oPartyTargetNPC;
        }

        oPartyNPC = GetNextFactionMember(oMaster, FALSE);
    }

    return oTarget;
}



/*::///////////////////////////////////////////////
//:: Name: AI_SetSpellTargetImmunity, AI_GetSpellTargetImmunity
//::///////////////////////////////////////////////
    Immunity settings for spells.
//:://///////////////////////////////////////////*/

// Simple return TRUE if it matches hex.
// - Uses GlobalSpellTarget for target object
int AI_GetSpellTargetImmunity(int nImmunityHex)
{
    return (GlobalTargetImmunitiesHex & nImmunityHex);
}
// Sets nImmunityHex to GlobalTargetImmunitiesHex.
void AI_SetSpellTargetImmunity(int nImmunityHex)
{
     GlobalTargetImmunitiesHex = GlobalTargetImmunitiesHex | nImmunityHex;
}
/*::///////////////////////////////////////////////
//:: Name: AI_SetUpUsEffects
//::///////////////////////////////////////////////
    Sets up the effects. Used before the uncommandable, so we
    know if we are or not! (EG stun)
//:://///////////////////////////////////////////*/
void AI_SetUpUsEffects()
{
    // Set locals and whatever on self.
    AI_SetEffectsOnTarget();
    // Set global time stop
    GlobalInTimeStop = AI_GetAIHaveEffect(GlobalEffectTimestop);
}
// Gets the percent, of X vs Y,  nNumber/nTotal * 100 = %.
int AI_GetPercentOf(int nNumber, int nTotal)
{
    return FloatToInt((IntToFloat(nNumber)/IntToFloat(nTotal)) * 100);
}
/*::///////////////////////////////////////////////
//:: Name: AI_SetTimeStopStored
//::///////////////////////////////////////////////
 Sets the spell to be stored in our time stop array.
//:://///////////////////////////////////////////*/
void AI_SetTimeStopStored(int nSpell)
{
    // Time stop check
    if(!GlobalInTimeStop) return;
    if(GlobalTimeStopArraySize < 0)
    {
        GlobalTimeStopArraySize = 1;// Size is now 1
        SetAIConstant(TIME_STOP_LAST_ + IntToString(1), nSpell);
        SetAIInteger(TIME_STOP_LAST_ARRAY_SIZE, GlobalTimeStopArraySize);
    }
    else if(GlobalTimeStopArraySize == 0)
    {
        GlobalTimeStopArraySize = GetAIInteger(TIME_STOP_LAST_ARRAY_SIZE);
        GlobalTimeStopArraySize++;
        SetAIConstant(TIME_STOP_LAST_ + IntToString(GlobalTimeStopArraySize), nSpell);
        SetAIInteger(TIME_STOP_LAST_ARRAY_SIZE, GlobalTimeStopArraySize);
    }
    else // Is over 0
    {
        GlobalTimeStopArraySize++;
        SetAIConstant(TIME_STOP_LAST_ + IntToString(GlobalTimeStopArraySize), nSpell);
        SetAIInteger(TIME_STOP_LAST_ARRAY_SIZE, GlobalTimeStopArraySize);
    }
}
/*::///////////////////////////////////////////////
//:: Name: DeleteTimeStopStored
//::///////////////////////////////////////////////
 Deletes all time stopped stored numbers.
//:://///////////////////////////////////////////*/
void AI_DeleteTimeStopStored()
{
    GlobalTimeStopArraySize = GetAIInteger(TIME_STOP_LAST_ARRAY_SIZE);
    if(GlobalTimeStopArraySize)
    {
        int nCnt;
        for(nCnt = 1; nCnt <= GlobalTimeStopArraySize; nCnt++)
        {
            DeleteAIConstant(TIME_STOP_LAST_ + IntToString(nCnt));
        }
    }
    DeleteAIInteger(TIME_STOP_LAST_ARRAY_SIZE);
    GlobalTimeStopArraySize = -1;
}
/*::///////////////////////////////////////////////
//:: Name: GetWeaponSize
//::///////////////////////////////////////////////
 Returns 1-4 for tiny-huge weapons. Used for disarm etc.
//::////////////////////////////////////////////*/
int AI_GetWeaponSize(object oItem)
{
    // Ignore invalid weapons
    if(!GetIsObjectValid(oItem)) return FALSE;

    // Returns shields as 0, the default return value of weapons not found in
    // this.
    switch(GetBaseItemType(oItem))
    {
        // Tiny
        // 22, 42, 59.
        case BASE_ITEM_DAGGER:
        case BASE_ITEM_KUKRI:
        case BASE_ITEM_SHURIKEN:
            return 1;// WEAPON_SIZE_TINY
        break;
        // Small
        // 0, 7, 9, 14, 31, 37, 38, 40, 60, 61, 63
        case BASE_ITEM_SHORTSWORD:
        case BASE_ITEM_LIGHTCROSSBOW:
        case BASE_ITEM_LIGHTMACE:
        case BASE_ITEM_DART:
        case BASE_ITEM_LIGHTHAMMER:
        case BASE_ITEM_HANDAXE:
        case BASE_ITEM_KAMA:
        case BASE_ITEM_SICKLE:
        case BASE_ITEM_SLING:
        case BASE_ITEM_THROWINGAXE:
        case BASE_ITEM_WHIP:    // Hordes
            return 2;// WEAPON_SIZE_SMALL
        break;
        // Medium
        // 1, 2, 3, 4, 5, 6, 11, 28, 41, 47, 51, 53, 56
        case BASE_ITEM_LONGSWORD:
        case BASE_ITEM_BATTLEAXE:
        case BASE_ITEM_BASTARDSWORD:
        case BASE_ITEM_LIGHTFLAIL:
        case BASE_ITEM_WARHAMMER:
        case BASE_ITEM_HEAVYCROSSBOW:
        case BASE_ITEM_SHORTBOW:
        case BASE_ITEM_CLUB:
        case BASE_ITEM_KATANA:
        case BASE_ITEM_MORNINGSTAR:
        case BASE_ITEM_RAPIER:
        case BASE_ITEM_SCIMITAR:
        case BASE_ITEM_DWARVENWARAXE: // Hordes
            return 3;// WEAPON_SIZE_MEDIUM;
        break;
        // Large weapons
        // 8, 10, 12, 13, 18, 32, 33, 35, 45, 50, 55, 57, 58
        case BASE_ITEM_LONGBOW:
        case BASE_ITEM_HALBERD:
        case BASE_ITEM_TWOBLADEDSWORD:
        case BASE_ITEM_GREATSWORD:
        case BASE_ITEM_GREATAXE:
        case BASE_ITEM_DIREMACE:
        case BASE_ITEM_DOUBLEAXE:
        case BASE_ITEM_HEAVYFLAIL:
        case BASE_ITEM_MAGICSTAFF:
        case BASE_ITEM_QUARTERSTAFF:
        case BASE_ITEM_SCYTHE:
        case BASE_ITEM_SHORTSPEAR:
        case BASE_ITEM_TRIDENT:
            return 4;// WEAPON_SIZE_LARGE;
        break;
    }
    return FALSE;
}
/*::///////////////////////////////////////////////
//:: Name AI_GetWeaponArray
//::///////////////////////////////////////////////
 This returns the best primary or secondary weapon from sArray.
 It actually returns the number value, IE the place it is at. Easy to get all info from there.
 - Use nType...
    - 0 = Highest Value :-)
    - 1 = Highest Damage
    - 2 = Biggest
    - 3 = Smallest
//::///////////////////////////////////////////////
//:: Created By: Jasperre
//:://///////////////////////////////////////////*/
int AI_GetWeaponArray(string sArray, object oCannotBe = OBJECT_INVALID, int nType = 0)
{
    int nMax = GetLocalInt(OBJECT_SELF, MAXINT_ + sArray);
    int nCnt, nReturn, nLastValue, nCurrentValue;
    string sCurrentName;
    object oCurrentWeapon;
    if(nMax)
    {
        for(nCnt = 1; nCnt <= nMax; nCnt++)   // uses: "break;" to break early.
        {
            sCurrentName = sArray + IntToString(nCnt);
            oCurrentWeapon = GetLocalObject(OBJECT_SELF, sCurrentName);// Object
            if(GetIsObjectValid(oCurrentWeapon) &&
               oCurrentWeapon != oCannotBe)
            {
                // Highest value (But cannot be oCannotBe of course)
                if(nType == 0)
                {
                    nReturn = nCnt;// It is highest to lowest value anyway
                    break;
                }
                // 1 = Highest Damage
                else if(nType == 1)
                {
                    // Get the current item value - the damage done by a weapon
                    nCurrentValue = GetLocalInt(OBJECT_SELF, sCurrentName + WEAP_DAMAGE);
                    // > because if only equal, one was higher value
                    if(nCurrentValue > nLastValue)
                    {
                        nLastValue = nCurrentValue;
                        nReturn = nCnt;
                    }
                }
                // 2 = Biggest
                // 3 = Smallest
                else
                {
                    // Get the current item value - that is, the size value
                    nCurrentValue = GetLocalInt(OBJECT_SELF, sCurrentName + WEAP_SIZE);
                    // Biggest weapon first (Primary weapon usually)
                    if(nType == 2)
                    {
                        if(nCurrentValue > nLastValue)// > because if only equal, one was higher value
                        {
                            nLastValue = nCurrentValue;
                            nReturn = nCnt;
                        }
                    }
                    // Smallest weapon first (Off-hand weapon ususally)
                    else // if(nType == 3)
                    {
                        if(nCurrentValue < nLastValue)// > because if only equal, one was higher value
                        {
                            nLastValue = nCurrentValue;
                            nReturn = nCnt;
                        }
                    }
                }
            }
        }
    }
    return nReturn;
}
// Equips the best shield we have.
// - Used before we cast a spell so casters can gain maximum AC.
void AI_EquipBestShield()
{
    // Get the shield to use/equip (we might have it equipped already)
    object oShield = GetAIObject(AI_WEAPON_SHIELD);
    // Test for equipping - we check if it is valid, if we have it, and if
    // it is even equipped already, of course. This is only called just before
    // an action - might add in a "reset shield" if it is invalid or lost
    // from us, somehow.
    if(GetIsObjectValid(oShield) &&
       GetItemPossessor(oShield) == OBJECT_SELF &&
       GetItemInSlot(INVENTORY_SLOT_LEFTHAND) != oShield)
    {
        // Equip it. No need for anything else. Lefthand == Offhand (or Shield hand)
        ActionEquipItem(oShield, INVENTORY_SLOT_LEFTHAND);
    }
}

// Turns on/off all melee things (not stealth or search!) but not nMode.
void AI_SetMeleeMode(int nMode = ACTION_MODE_ALL_OFF)
{
    if(nMode != ACTION_MODE_ALL_OFF)
    {
        if(!GetActionMode(OBJECT_SELF, nMode))
        {
            SetActionMode(OBJECT_SELF, nMode, TRUE);
        }
    }
    // Turn off all the rest
    int nCnt;
    // 0 = stealth, 1 = search (ignore these 2), 3 = parry. 11 = DF.
    for(nCnt = ACTION_MODE_PARRY; nCnt <= ACTION_MODE_DIRTY_FIGHTING; nCnt++)
    {
        if(nCnt != nMode)
        {
            if(GetActionMode(OBJECT_SELF, nCnt))
            {
                SetActionMode(OBJECT_SELF, nCnt, FALSE);
            }
        }
    }
}

// Turn of hiding if turn of timer is on, and turn of searching if it is
// active.
// This should be called before any action using a feat, spell or similar, if
// we need to move.
void AI_ActionTurnOffHiding()
{
    // 1.4: Changed both the checks to use GetActionMode. Looks cleaner.
    // Turn of searching and hiding here, if we want to!
    if(!GetHasFeat(FEAT_KEEN_SENSE) &&
       !GetActionMode(OBJECT_SELF, ACTION_MODE_DETECT))
    {
        SetActionMode(OBJECT_SELF, ACTION_MODE_DETECT, FALSE);
    }
    // Turn of hiding if we have been seen lately.
    if(GetLocalTimer(AI_TIMER_TURN_OFF_HIDE) &&
      !GetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH))
    {
        SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, FALSE);
    }
}

/*::///////////////////////////////////////////////
//:: Name AI_EquipAndAttack
//::///////////////////////////////////////////////
    This was a bioware script. It has been changed a lot.
    Best target if normal int (equal or more than 2).

    Will play a random attack taunt, sometimes.
//::///////////////////////////////////////////////
//:: Created By: Jasperre
//:://///////////////////////////////////////////*/
int AI_EquipAndAttack()
{
    DoCombatVoice();

    // - Flying
    // no dragons? - pok
    /*
    if(GlobalRangeToMeleeTarget > 8.0 &&
       GetSpawnInCondition(AI_FLAG_COMBAT_FLYING, AI_COMBAT_MASTER))
    {
        SetAIObject(AI_FLYING_TARGET, GlobalMeleeTarget);
        ExecuteScript(FILE_FLY_ATTACK, OBJECT_SELF);
        return TRUE;
    }
    */

    // Set up the range to use weapons at, before moving into HTH
    // Default is 5.0 (+ Some for creature size) with no changes...
    float fRange = 5.0;
    // Might have some pre-set range OnSpawn
    int nRangeFromSetup = GetAIInteger(AI_RANGED_WEAPON_RANGE);
    if(nRangeFromSetup >= 1)
    {
        fRange = IntToFloat(nRangeFromSetup);
    }
    // If our intelligence is enough, we make it 3.0.
    else if(GlobalIntelligence >= 5)
    {
        fRange = 3.0;
    }
    // We add a base of X for monster sizes
    fRange += (IntToFloat(GetCreatureSize(OBJECT_SELF))/4.0);

    // bRangedAttack = TRUE, then equip ranged weapons
    int bRangedAttack = FALSE;

    // Now check for it...
    // If range to melee target is OVER fRange...
    // - Or setting to always use bow
    if(GlobalRangeToMeleeTarget > fRange ||
       GetSpawnInCondition(AI_FLAG_COMBAT_ARCHER_ALWAYS_USE_BOW, AI_COMBAT_MASTER))
    {
        bRangedAttack = TRUE;
    }

    // Special check for AI_FLAG_COMBAT_BETTER_AT_HAND_TO_HAND.
    // Either a % chance, or that they have no enemy in X distance, and we are
    // in Y distance.
    // We always run in at 8 or less M too.
    if(bRangedAttack == TRUE && GetSpawnInCondition(AI_FLAG_COMBAT_BETTER_AT_HAND_TO_HAND, AI_COMBAT_MASTER))
    {
        // If they are under 8M away, always run in - 80% chance
        if(GlobalRangeToMeleeTarget < 8.0 && d10() <= 8)
        {
            bRangedAttack = FALSE;
        }
        else
        {
            // Get distance from melee target to nearest ally to it.
            float fAllyToMelee = GetDistanceBetween(GlobalMeleeTarget, GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, GlobalMeleeTarget, 1, CREATURE_TYPE_IS_ALIVE, TRUE));

            // Check thier range to ours
            // - Basically, if GlobalRangeToMeleeTarget - fAllyToMelee, is
            //   a difference of Random(4) + 4;, we move in.
            // + 60% chance!
            if((GlobalRangeToMeleeTarget - fAllyToMelee) <= (IntToFloat(Random(4) + 4)) &&
               d10() <= 6)
            {
                bRangedAttack = FALSE;
            }
        }
    }

    // Declare everything
    object oEquipped;
    int bRanged, bNeedMoreAC;
    // Done in melee attacking, if we want more AC - IE expertise.
        //bNeedMoreAC;


    //object oShield = GetAIObject(AI_WEAPON_SHIELD);
    //int bValidShield = GetIsObjectValid(oShield);
    // SPECIAL: We will just use default calls FIRST and stop IF we have this set
    // same checks to choose between them though :-P


    // 1: "[DCR:Melee] Most Damaging Weapon. Target: " + GetName(GlobalMeleeTarget)
    //DebugActionSpeakByInt(1, GlobalMeleeTarget);

    // bRangedAttack = 1 then ranged.
    if(bRangedAttack)
    {
        ActionEquipMostDamagingRanged(GlobalMeleeTarget);
        bRanged = TRUE;
    }
    // Special near-range always attack with a bow option.
    else if(GetSpawnInCondition(AI_FLAG_COMBAT_ARCHER_ALWAYS_USE_BOW, AI_COMBAT_MASTER))
    {
        ActionEquipMostDamagingRanged(GlobalMeleeTarget);
        bRanged = TRUE;
    }
    // Spcial - if we are set to always move back, 1/10 times we don't equip HTH.
    // BUT we will attack in HTH if the last target was this target.
    else if(GetLocalInt(OBJECT_SELF, "range") == 1
         && d10() != 1)
    {
        ActionEquipMostDamagingRanged(GlobalMeleeTarget);
        bRanged = TRUE;
    }
    // Else we should always be in HTH range.
    else // if(!bRangedAttack)
    {
        ActionEquipMostDamagingMelee(GlobalMeleeTarget, TRUE);
    }

    oEquipped = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);

    // intelligent weapon/shield/etc choosing removed - pok

    // we won't equip a shield if we are not effective to enemy - pok

    // Now, we should have equipped something :-D
    // GlobalMeleeTargetAC

    // We randomly hit, determined by our intelligence.
    // If we have higher intelligence, we take our rolls to be higher, so we use feats more.
    int nOurHit;
    // add a base value...so 18 for Int. 10. 0 for Int. 1.
    nOurHit = GlobalOurBaseAttackBonus + ((GlobalIntelligence * 2) - 2);
    // Randomise...should never get results over 20 now. (0-20 for INT 1, 0-2 for INT 10)
    nOurHit += Random(20 - ((GlobalIntelligence - 1) * 2));

    // 1.3 - Add Dexterity to ranged feat checking, strength to melee

    // Note:
    // - 8+ Intelligence also checks DISCIPLINE.

/*  Ability: Strength.
    Requires Training: No.
    Classes: All.

    A successful check allows the character to resist any combat feat
    (Disarm, Called Shot, or Knockdown).

    Check: The DC is equal to the attacker's attack roll.
    Use: Automatic. */

    // We therefore make ValidFeat mean FALSE if the target has too much
    // disipline (by a margin)
    int bDisciplineFeats = TRUE;
    if(GlobalIntelligence >= 8)
    {
        // If thier rank - 20 is over our BAB + XX, then no go, as it is very
        // likely they'll pass the check.
        // * Was no second parameter (thusly OBJECT_SELF). 1.4 fix - change to
        //   opponents skill!
        if(GetSkillRank(SKILL_DISCIPLINE, GlobalMeleeTarget) - 25 >= nOurHit)
        {
            // No feats
            bDisciplineFeats = FALSE;
        }
    }

    // Note: If we can only hit on a 20, and have 7+ Intelligence, we make it
    // use ANY feat (as they will have the same chance of hitting - a critical -
    // as a normal attack)
    if(GlobalOurBaseAttackBonus + 20 <= GlobalMeleeTargetAC)
    {
        nOurHit = GlobalOurBaseAttackBonus + 100;// Massive amount - we act as if we rolled 100!
    }
    // We turn off hiding/searching as we will at least do ActionAttack...
    AI_ActionTurnOffHiding();

    // Ranged weapon?
    if(bRanged && !AI_GetAIHaveEffect(GlobalEffectPolymorph))
    {
        // RANGED: Add dexterity
        nOurHit += GetAbilityModifier(ABILITY_DEXTERITY);
        int nAC = GetAC(GlobalRangedTarget);

        // you can't use power attack with throwing axes - pok

        // Rapid shot - This provides another attack, at -2 to hit.
        if((nOurHit - 2) >= GlobalMeleeTargetAC && GetHasFeat(FEAT_RAPID_SHOT))
        {
            AI_SetMeleeMode(ACTION_MODE_RAPID_SHOT);
            ActionAttack(GlobalRangedTarget);
            return FEAT_RAPID_SHOT;
        }
        // Called shot is -4, but some good things...does it work though?  Uncommented till sure
        else if(((nOurHit - 4) >= nAC) &&
             GetHasFeat(FEAT_CALLED_SHOT) && bDisciplineFeats &&
            !GetHasFeatEffect(FEAT_CALLED_SHOT, GlobalRangedTarget))
        {
            AI_SetMeleeMode();
            ActionUseFeat(FEAT_CALLED_SHOT, GlobalRangedTarget);
            return FEAT_CALLED_SHOT;
        }
        else
        {
            // Normal (Ranged) attack
            ActionAttack(GlobalRangedTarget);
            return AI_NORMAL_RANGED_ATTACK;
        }
    }
    // Parry the enemy, if we have only 1 target attacking us, and have
    // decent skill.
    else if(!bRanged && !GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_PARRYING, AI_OTHER_COMBAT_MASTER) &&
            // 1 attacker, and the melee target is attacking us.
            GlobalMeleeAttackers <= 1 && GetAttackTarget(GlobalMeleeTarget) == OBJECT_SELF &&
            // Not got a ranged weapon - enemy target that is
            !GetWeaponRanged(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, GlobalMeleeTarget)) &&
            // Got skill rank of greater than 0 base.
          ((GetSkillRank(SKILL_PARRY, OBJECT_SELF, TRUE) > 0) ||
            // Or forced
            GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_FORCE_PARRYING, AI_OTHER_COMBAT_MASTER)))
    {
        // Set parry mode
        AI_SetMeleeMode(ACTION_MODE_PARRY);
        ActionAttack(GlobalMeleeTarget);
        return AI_PARRY_ATTACK;
    }
    else if(!bRanged)
    {
        // Death attack - if we are hidden, or we have invisiblity effects
        // - A basic "seen or heard" check, backwards (slightly cheating!)
        if(GetHasFeat(FEAT_PRESTIGE_DEATH_ATTACK_1) &&
          (!GetObjectSeen(OBJECT_SELF, GlobalMeleeTarget) ||
           !GetObjectSeen(OBJECT_SELF, GlobalMeleeTarget)))
        {
            // This doesn't seem to be "useable" and is meant to be automatic.
            // However, using something that decreases our attack will be silly
            // so we will just ActionAttack the target.
            ActionAttack(GlobalMeleeTarget);
            return FEAT_PRESTIGE_DEATH_ATTACK_1;
        }
        // Check for defensive stance
        if(GetHasFeat(FEAT_DWARVEN_DEFENDER_DEFENSIVE_STANCE) &&
          !GetHasFeatEffect(FEAT_DWARVEN_DEFENDER_DEFENSIVE_STANCE) &&
           GlobalRangeToMeleeTarget < 3.0 &&
           GetLastAttackMode() != COMBAT_MODE_DEFENSIVE_STANCE)
        {
            // Use defensive stance on self (Hopefully these checks won't override each other)
            ActionUseFeat(FEAT_DWARVEN_DEFENDER_DEFENSIVE_STANCE, OBJECT_SELF);
            // Note - fall through and carry on
        }
        // MELEE
        // - Add strength
        nOurHit += GetAbilityModifier(ABILITY_STRENGTH);

        // More things to declare.
        int nTargetWeaponSize, nTargetCreatureRace, nOurWeaponSize,
            bCanUseMonks, nTargetAlignment, nAddingModifier, nMonkLevels;
        // Monk levels
        nMonkLevels = GetLevelByClass(CLASS_TYPE_MONK);
        if(!nMonkLevels) nMonkLevels = 1;
        nTargetCreatureRace = GetRacialType(GlobalMeleeTarget);//done later.
        nTargetAlignment = GetAlignmentGoodEvil(GlobalMeleeTarget);
        // Now, monk, can it be done...
        // weapon is removed because you can't use stunning/quivering with! - pok
        if((!GetIsObjectValid(oEquipped)) &&
             nTargetCreatureRace != RACIAL_TYPE_CONSTRUCT &&
             nTargetCreatureRace != RACIAL_TYPE_UNDEAD)
        {
            bCanUseMonks = TRUE;
        }

        // always use smite, because it gives +ab anyways regardless of alignment - pok
        // For use against them evil pests! Top - one use only anyway.
        if(GetHasFeat(FEAT_SMITE_EVIL))
        {
            AI_SetMeleeMode();
            ActionUseFeat(FEAT_SMITE_EVIL, GlobalMeleeTarget);
            return FEAT_SMITE_EVIL;
        }
        // For use against them evil pests! Top - one use only anyway.
        else if(GetHasFeat(FEAT_SMITE_GOOD))
        {
            AI_SetMeleeMode();
            ActionUseFeat(FEAT_SMITE_GOOD, GlobalMeleeTarget);
            return FEAT_SMITE_GOOD;
        }

        // We may use Expertiese if we are being attacked, and above we tried
        // to equip a shield...
        // - Need more help around us (some allies) and people atually attacking us, or low HP.
        if((GlobalOurPercentHP <= 20) ||
           (bNeedMoreAC && GlobalMeleeAttackers && GlobalTotalAllies >= 2))
        {
            // +10 AC, -10 BAB
            if(GetHasFeat(FEAT_IMPROVED_EXPERTISE))
            {
                AI_SetMeleeMode(ACTION_MODE_IMPROVED_EXPERTISE);
                return FEAT_IMPROVED_EXPERTISE;
            }
            else if(GetHasFeat(FEAT_EXPERTISE))
            {
                AI_SetMeleeMode(ACTION_MODE_EXPERTISE);
                return FEAT_EXPERTISE;
            }
        }
        // First, we have the little-known-about monk powerful feats...
        // Instant death, what can be better? >:-D
        if(bCanUseMonks && GetHasFeat(FEAT_QUIVERING_PALM) &&
           nOurHit + 5 >= GlobalMeleeTargetAC &&
           GlobalOurHitDice >= GetHitDice(GlobalMeleeTarget))
        {
            // Ok, not too random. Thier roll is not d20 + fort save, it is random(15) + 5.
            // - Our hit is 10 + Monk class/2 + Wisdom...
            if((10 + (nMonkLevels / 2) + GetAbilityModifier(ABILITY_WISDOM)) >=
            // - This must be over thier Fortitude save, add 5 and 0-15.
               (GetFortitudeSavingThrow(GlobalMeleeTarget) + 5 + Random(15)))
            {
                AI_SetMeleeMode();
                ActionUseFeat(FEAT_QUIVERING_PALM, GlobalMeleeTarget);
                return FEAT_QUIVERING_PALM;
            }
        }
        // We see if we want to use Whirlwind attack!
        // - Check for amount of melee attackers. If 5 or more, use this.
        // - We may use it later at 2 or more. :-)
        // If we don't have 5 or more, we use some of the better single target
        // feats before. This requires no BAB check - it is done at max BAB
        if(// 90% chance of using it with 6+ melee attackers, and 8+ enemies in 4M
           (d10() <= 9 && (GlobalEnemiesIn4Meters >= 8 ||
            GlobalMeleeAttackers >= 6)) ||
           // OR, 70% chance of using if we'll get more attacks if we used
           // whirlwind then if we used
           (d10() <= 7 && (GlobalOurBaseAttackBonus/5 < (GlobalEnemiesIn4Meters - 1))) ||
           // Lastly 40% chance if we have 4+ melee, or 5+ in range
           (d10() <= 4 && (GlobalEnemiesIn4Meters >= 5 ||
            GlobalMeleeAttackers >= 4)))
        {
            // - Free attack to all in 10'! This should be anyone in 6.6M or so.
            if(GetHasFeat(FEAT_IMPROVED_WHIRLWIND))
            {
                AI_SetMeleeMode();
                ActionUseFeat(FEAT_IMPROVED_WHIRLWIND, OBJECT_SELF);
                // And attack after (as it doesn't seem to take a round to use)
                ActionAttack(GlobalMeleeTarget);
                return FEAT_IMPROVED_WHIRLWIND;
            }
            // All in 5' is still alright. 5 Feet = 3.3M or so.
            else if(GetHasFeat(FEAT_WHIRLWIND_ATTACK))
            {
                AI_SetMeleeMode();
                ActionUseFeat(FEAT_WHIRLWIND_ATTACK, OBJECT_SELF);
                // And attack after (as it doesn't seem to take a round to use)
                ActionAttack(GlobalMeleeTarget);
                return FEAT_WHIRLWIND_ATTACK;
            }
        }
        // Sap can be used by anyone, any weapon, I think...
        // Almost Auto stun, great stuff. Help From toolset:
/*  Sap
    Type of Feat: General
    Prerequisite: Base Attack Bonus +1, Called Shot.
    Required for: Stunning Fist.
    Specifics: A character with this feat is able to make a special stun
    attack in melee. He makes an attack roll with a -4 penalty, and if the hit
    successfully deals damage the defender must make a Discipline check with a
    DC equal to the attacker's attack roll. If the defender fails, he or she is
    dazed for 12 seconds.
    Use: Selected.  */
        if(!GetHasFeatEffect(FEAT_SAP, GlobalMeleeTarget) &&
            GetHasFeat(FEAT_SAP) &&
            nOurHit - 4 >= GlobalMeleeTargetAC &&
           !AI_GetAIHaveEffect(GlobalEffectUncommandable, GlobalMeleeTarget) &&
           !AI_GetAIHaveEffect(GlobalEffectDazed, GlobalMeleeTarget))
        {
            AI_SetMeleeMode();
            ActionUseFeat(FEAT_SAP, GlobalMeleeTarget);
            return FEAT_SAP;
        }
        // Knockdown is great! One of the best ever!(and VERY, VERY overpowered)
        if(bDisciplineFeats && !GetHasFeatEffect(FEAT_KNOCKDOWN, GlobalMeleeTarget) &&
           !GetHasFeatEffect(FEAT_IMPROVED_KNOCKDOWN, GlobalMeleeTarget) &&
           !AI_GetAIHaveEffect(GlobalEffectUncommandable, GlobalMeleeTarget) &&
           !AI_GetAIHaveEffect(GlobalEffectDazed, GlobalMeleeTarget))
        {
            // These return 1-5, based on size.
            int nTargetCreatureSize = GetCreatureSize(GlobalMeleeTarget);
            int nOurSize = GetCreatureSize(OBJECT_SELF);
            // By far the BEST feat to use - knocking them down lets you freely attack them!
            if(GetHasFeat(FEAT_IMPROVED_KNOCKDOWN))
            {
                // Imporved affects like if we were 1 size larger - thus we can affect 2 sizes bigger targets
                if((nOurSize + 2) >= nTargetCreatureSize)
                {
                    // Modifier, adds anything from -4 to 0 to 4.
                    // Test: Us, size 3, them size 1. 3 - 1 = 2. 2 * 4 = +8 to hit.
                    nAddingModifier = (nOurSize - nTargetCreatureSize) * 4;
                    // We are 1 size bigger, so its evens (we add 4 onto -4)
                    if(nAddingModifier + nOurHit >= GlobalMeleeTargetAC)
                    {
                        AI_SetMeleeMode();
                        ActionUseFeat(FEAT_IMPROVED_KNOCKDOWN, GlobalMeleeTarget);
                        return FEAT_IMPROVED_KNOCKDOWN;
                    }
                }
            }
            // Knockdown, we can hit on 1 size above or smaller.
            else if(GetHasFeat(FEAT_KNOCKDOWN))
            {
                // Only works on our size, above 1, or smaller.
                if((nOurSize + 1) >= nTargetCreatureSize)
                {
                    // Same as above, but we always take 4 more.
                    nAddingModifier = ((nOurSize - nTargetCreatureSize) * 4) - (4);
                    // Calculate
                    if(nAddingModifier + nOurHit >= GlobalMeleeTargetAC)
                    {
                        AI_SetMeleeMode();
                        ActionUseFeat(FEAT_KNOCKDOWN, GlobalMeleeTarget);
                        return FEAT_KNOCKDOWN;
                    }
                }
            }
        }
        // Ki damage :-) max roll of damage for weapons for Weapon Master - Hordes
        // - Note that this a lot of uses. Test for usefulness!
        // 1.4: Moved below "disabling" combat feats. This is more useful if they
        // cannot move.
        if(GetHasFeat(FEAT_KI_DAMAGE))
        {
            AI_SetMeleeMode();
            ActionUseFeat(FEAT_KI_DAMAGE, GlobalMeleeTarget);
            return FEAT_KI_DAMAGE;
        }
        // Define sizes of weapons, ETC.
        // Check if they are disarmable.
        if(bDisciplineFeats && GetIsCreatureDisarmable(GlobalMeleeTarget))
        {
            nOurWeaponSize = AI_GetWeaponSize(oEquipped);
            nTargetWeaponSize = AI_GetWeaponSize(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, GlobalMeleeTarget));
            // No AOO, and only a -4 penalty to hit.
            if(GetHasFeat(FEAT_IMPROVED_DISARM))
            {
                // We need to have valid sizes, so no odd weapons or shields to attack with...
                if(nOurWeaponSize && nTargetWeaponSize)// Are both != 0?
                {
                    // Apply weapon size penalites/bonuses to check - Use right weapons.
                    // We times it by 4.
                    // Test: Us, size 3, them size 1. (3 - 1 = 2) then (2 * 4 = 8) So +8 to hit.
                    nAddingModifier = (nOurWeaponSize - nTargetWeaponSize) * 4;
                    if((nAddingModifier + nOurHit - 4) >= GlobalMeleeTargetAC)
                    {
                        AI_SetMeleeMode();
                        ActionUseFeat(FEAT_IMPROVED_DISARM, GlobalMeleeTarget);
                        return FEAT_IMPROVED_DISARM;
                    }
                }
            }
            // Provokes an AOO. Improved does not, but this is -6,
            // and bonuses depend on weapons used (sizes)
            else if(GetHasFeat(FEAT_DISARM))
            {
                // We need to have valid sizes, so no odd weapons or shields to attack with...
                if(nOurWeaponSize && nTargetWeaponSize)// Are both != 0?
                {
                    // Apply weapon size penalites/bonuses to check - Use left weapons.
                    nAddingModifier = (nOurWeaponSize - nTargetWeaponSize) * 4;
                    // We take 6 and then 1 per melee attacker (AOOs)
                    if((nAddingModifier + nOurHit - 6 - GlobalMeleeAttackers) >= GlobalMeleeTargetAC)
                    {
                        AI_SetMeleeMode();
                        ActionUseFeat(FEAT_DISARM, GlobalMeleeTarget);
                        return FEAT_DISARM;
                    }
                }
            }
        }
        // Next, stunning fist.
        // Stuns the target, making them unable to move. -4 attack.
        // DC (fort) of 10 + HD/2 + wis mod.
        if(bCanUseMonks && GetHasFeat(FEAT_STUNNING_FIST) &&
          !AI_GetAIHaveEffect(GlobalEffectUncommandable, GlobalMeleeTarget) &&
          !AI_GetAIHaveEffect(GlobalEffectDazed, GlobalMeleeTarget))
        {
            // Start adding modifier at 0.
            nAddingModifier = 0;
            // If not a monk, its -4 to hit. Monk levels defaults to 1 if 0
            if(nMonkLevels == TRUE) nAddingModifier - 4;
            // We hit ETC.
            // Save is above
            if(nOurHit >= GlobalMeleeTargetAC &&
            // Save
              (10 + (GlobalOurHitDice / 2) + GetAbilityModifier(ABILITY_WISDOM)
               >= GetFortitudeSavingThrow(GlobalMeleeTarget) + 5 + Random(15)))
            {
                AI_SetMeleeMode();
                ActionUseFeat(FEAT_STUNNING_FIST, GlobalMeleeTarget);
                return FEAT_STUNNING_FIST;
            }
        }
        // We see if we want to use Whirlwind attack!
        // - Check for amount of melee attackers. If 5 or more, use this.
        // - We may use it later at 2 or more. :-)
        // If we don't have 5 or more, we use some of the better single target
        // feats before. This requires no BAB check - it is done at max BAB
        if(GlobalEnemiesIn4Meters >= 2)
        {
            // - Free attack to all in 10'! This should be anyone in 6.6M or so.
            if(GetHasFeat(FEAT_IMPROVED_WHIRLWIND))
            {
                AI_SetMeleeMode();
                ActionUseFeat(FEAT_IMPROVED_WHIRLWIND, OBJECT_SELF);
                return FEAT_IMPROVED_WHIRLWIND;
            }
            // All in 5' is still alright. 5 Feet = 3.3M or so.
            else if(GetHasFeat(FEAT_WHIRLWIND_ATTACK))
            {
                AI_SetMeleeMode();
                ActionUseFeat(FEAT_WHIRLWIND_ATTACK, OBJECT_SELF);
                return FEAT_WHIRLWIND_ATTACK;
            }
        }
        // Next, flurry of blows...
        // removed bCanUseMonks check because it wouldnt work vs. golems
        if((!GetIsObjectValid(oEquipped) || GetBaseItemType(oEquipped) == BASE_ITEM_KAMA || GetBaseItemType(oEquipped) == BASE_ITEM_QUARTERSTAFF) && nOurHit - 2 >= GlobalMeleeTargetAC &&
           GetHasFeat(FEAT_FLURRY_OF_BLOWS))
        {
            AI_SetMeleeMode(ACTION_MODE_FLURRY_OF_BLOWS);
            ActionAttack(GlobalMeleeTarget);
            return FEAT_FLURRY_OF_BLOWS;
        }
        // Expertise, special case: If we have a high BAB verus thier AC.
        // Only basic for now...
        if(GetHasFeat(FEAT_IMPROVED_EXPERTISE))
        {
            // Our hit is over thier AC, and thier BAB hits us all the time...
            // OR when there are 3+
            if((nOurHit >= GlobalMeleeTargetAC &&
                // Add 5 to thier hit
                GetBaseAttackBonus(GlobalMeleeTarget) + 5 >= GlobalOurAC) ||
                GlobalMeleeAttackers >= 3)
            {
                AI_SetMeleeMode(ACTION_MODE_IMPROVED_EXPERTISE);
                ActionAttack(GlobalMeleeTarget);
                return FEAT_IMPROVED_EXPERTISE;
            }
        }
        if(GetHasFeat(FEAT_EXPERTISE))
        {
            // Expertise, we may use even if we can hit only sometimes, and
            // they always hit up sometiems (50% time)
            // OR when there are 1 + 1/2HD attackers.
            if((nOurHit >= GlobalMeleeTargetAC &&
                // Add 10 to thier hit
                GetBaseAttackBonus(GlobalMeleeTarget) + 10 >= GlobalOurAC) ||
                GlobalMeleeAttackers >= 2)
            {
                AI_SetMeleeMode(ACTION_MODE_EXPERTISE);
                ActionAttack(GlobalMeleeTarget);
                return FEAT_EXPERTISE;
            }
        }
        // At a -2 to hit, this can disarm the arms or legs...speed or attack bonus
        if((nOurHit - 4) >= GlobalMeleeTargetAC && bDisciplineFeats &&
            GetHasFeat(FEAT_CALLED_SHOT) &&
           !GetHasFeatEffect(FEAT_CALLED_SHOT, GlobalMeleeTarget))
        {
            AI_SetMeleeMode();
            ActionUseFeat(FEAT_CALLED_SHOT, GlobalMeleeTarget);
            return FEAT_CALLED_SHOT;
        }
        // -10 to hit, for +10 damage. Good, I guess, in some circumstances.
        // Uses base attack bonus, no additions.
        if(GetHasFeat(FEAT_IMPROVED_POWER_ATTACK) &&
           GlobalOurBaseAttackBonus >= GlobalMeleeTargetAC)
        {
            AI_SetMeleeMode(ACTION_MODE_IMPROVED_POWER_ATTACK);
            ActionAttack(GlobalMeleeTarget);
            return FEAT_IMPROVED_POWER_ATTACK;
        }
        // is a -5 to hit. Uses random 5, to randomise a bit,
        // I guess. Still means a massive BAB will use it.
        // Uses base attack bonus, no additions.
        if(GetHasFeat(FEAT_POWER_ATTACK) &&
          ((GlobalOurBaseAttackBonus + Random(5)) >= GlobalMeleeTargetAC))
        {
            AI_SetMeleeMode(ACTION_MODE_POWER_ATTACK);
            ActionAttack(GlobalMeleeTarget);
            return FEAT_POWER_ATTACK;
        }
        // Either: Bad chance to hit, or only one attack, we use this for 1d4 more damage
        if(GetHasFeat(FEAT_DIRTY_FIGHTING) &&
           GlobalOurBaseAttackBonus / 5 < 1 ||
           GlobalOurBaseAttackBonus + 15 < GlobalMeleeTargetAC)
        {
            AI_SetMeleeMode(ACTION_MODE_DIRTY_FIGHTING);
            ActionAttack(GlobalMeleeTarget);
            return FEAT_DIRTY_FIGHTING;
        }
    }

    // If we have not used any, well...oh well! Attack!!
    ActionAttack(GlobalMeleeTarget);
    return AI_NORMAL_MELEE_ATTACK;
}
// Wrapper for AI_AttemptAttack_MeleeAttack
// Includes debug string
int AI_AttemptMeleeAttackWrapper()
{
    // Errors
    // We will exit if no valid melee target/dead
    if(!GetIsObjectValid(GlobalMeleeTarget) || GetIsDead(GlobalMeleeTarget))
    {
        // 3: "[DCR:Melee] Melee Code. No valid melee target/Dead. Exiting"
        DebugActionSpeakByInt(3);
        return FALSE;
    }
    int nFeat = AI_EquipAndAttack();
    // 4: "[DCR:Melee] Melee attack. [Target] " + GetName(GlobalMeleeTarget) + " [Feat/Attack] " + IntToString(nFeat)
    DebugActionSpeakByInt(4, GlobalMeleeTarget, nFeat);
    return nFeat;
}
/*::///////////////////////////////////////////////
//:: Spell casting functions
//::///////////////////////////////////////////////
    Spell casting functions.
//::///////////////////////////////////////////////
//:: Created by : Jasperre
//:://///////////////////////////////////////////*/
// Used with GlobalLastSpellValid. If GlobalLastSpellValid is 0, sets locals for
// use later, and sets GlobalLastSpellValid to the spell in question.
void AI_SetBackupCastingSpellValues(int nSpellID, object oTarget, int bLocation, int nRequirement)
{
    if(GlobalLastSpellValid <= FALSE)
    {
        // Set last spell
        GlobalLastSpellValid = nSpellID;
        // Set values using 1 name, + a number
        int nCnt = 1;
        // SET...
        // target
        SetAIObject(GLOBAL_LAST_SPELL_INFORMATION + IntToString(nCnt), oTarget);
        // location
        nCnt++;
        SetAIInteger(GLOBAL_LAST_SPELL_INFORMATION + IntToString(nCnt), bLocation);
        // Requirements
        nCnt++;
        SetAIInteger(GLOBAL_LAST_SPELL_INFORMATION + IntToString(nCnt), nRequirement);
    }
}

/*::///////////////////////////////////////////////
//:: Name AttemptSpecialConcentrationCheck
//::///////////////////////////////////////////////
    This is a good check against the enemies (highest AC one) Damage against concentration
    Also, based on allies, enemies, and things, may move back (random chance, bigger with
    more bad things, like no stoneskins, no invisibility etc.)
    We will do this more at mid-intelligence, and better checks at most intelligence.
//::///////////////////////////////////////////////
//:: Created By: Jasperre
//:://///////////////////////////////////////////*/

int AI_AttemptConcentrationCheck(object oTarget)
{
    // Total off check
    if(GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_FORCE_CONCENTRATION, AI_OTHER_MASTER) ||
    // Or has no moving back needed.
       GetHasFeat(FEAT_EPIC_IMPROVED_COMBAT_CASTING) ||
    // Or has all spells quickened!
       GetHasFeat(FEAT_EPIC_AUTOMATIC_QUICKEN_3) ||
       // - Ignore 1, but not 3 or 2.
       GetHasFeat(FEAT_EPIC_AUTOMATIC_QUICKEN_2))
    {
        return FALSE;
    }

    // No defensive casting at all - pok

    if(// Check if we have the feat FEAT_EPIC_IMPROVED_COMBAT_CASTING - no AOO
      !GetHasFeat(FEAT_EPIC_IMPROVED_COMBAT_CASTING) &&
       // We will never do anything if no melee attackers, or no ally that can help repel them
       GlobalMeleeAttackers > FALSE &&
       // Target of the spell is not us, if it is us, we don't WANT to move!! (EG: Stoneskin casting)
       oTarget != OBJECT_SELF &&
       // Do not move if we have protection spells, as it will be as good as we can get from stopping damage
       // - May change
      !AI_GetAIHaveSpellsEffect(GlobalHasStoneSkinProtections) &&
       // We have an ally in 4M
       GlobalValidAlly && GlobalRangeToAlly < 4.0 &&
       // Intelligence AND class mage
      ((GlobalIntelligence >= 4 &&
       (GlobalOurChosenClass == CLASS_TYPE_WIZARD ||
        GlobalOurChosenClass == CLASS_TYPE_SORCERER ||
        GlobalOurChosenClass == CLASS_TYPE_FEY)) ||
        // Or override
        GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_FORCE_CONCENTRATION, AI_OTHER_MASTER)))
    {
        // First - checks concentration...
        int nConcentration = GetSkillRank(SKILL_CONCENTRATION);
        // If we have 0 concentration, we always run!


        // Else we run back based on our concentration compared to how much
        // damage we can take.
        // - NOTE: Once we can activate defensive casting, we should do so and ignore AOO.

        // We may walk back quite often if there are quite a few allies around
        // who'd benifit (IE from a person running after someone and might gain
        // AOO)
        // - We count up the melee enemy
        // - We see how many compared to our protections
        // - We move back quite often if the enemy are comparable levels and
        //   they are of comparable BAB (Consider average AC and average BAB)

           // We always move back if low concentration...under half our hit dice.
        if(nConcentration <= GlobalOurHitDice/2 ||
           // Or that the average HD is quite high (compared to 2/3 our HD)
           GlobalAverageEnemyHD >= ((GlobalOurHitDice * 3) / 2) ||
           // Or that the average BAB is quite high (compared to 2/3 our AC)
           GlobalAverageEnemyBAB >= ((GlobalOurAC * 3) / 2))
        {
            // We check the counter
            int nCounter = GetAIInteger(AI_CONCENTRATIONMOVE_COUNTER);
            nCounter++;
            SetAIInteger(AI_CONCENTRATIONMOVE_COUNTER, nCounter);
            // If the counter is <= 5, we will move back, else we've been moving
            // back for 5 turns already! Stop and do something useful...
            if(nCounter <= 5)
            {
                ClearAllActions();
                // 6: "[DCR:Caster] Moving away from AOO's. [Enemy] " + GetName(GlobalSpellTarget)
                //DebugActionSpeakByInt(6, GlobalSpellTarget);
                ActionMoveAwayFromLocation(GetLocation(GlobalMeleeTarget), TRUE, 10.0);
                return TRUE;
            }
            else if(nCounter >= 10)
            {
                // Reset once we get to 10 rounds.
                DeleteAIInteger(AI_CONCENTRATIONMOVE_COUNTER);
            }
            else
            {
                // Counter between 5 and 10 - do normal things
                return FALSE;
            }
        }
        // If we don't move back, we reset the counter for time we have moved back
        DeleteAIInteger(AI_CONCENTRATIONMOVE_COUNTER);
    }
    return FALSE;
}
// This is used for INFLICT spells, as GetHasSpell also can return 1+ for
// any extra castings - like if we had 2 light wounds and 2 blesses, it'd return
// 4.
// Input the nSpellID, oTarget in to cast the spell. TRUE if casted. No items checked.
int AI_ActionCastSpontaeousSpell(int nSpellID, object oTarget)
{
    // don't cast spells on dead targets - pok
    if (GetIsDead(oTarget))
        return FALSE;

    if(GetHasSpell(nSpellID) && GetObjectSeen(oTarget))
    {
        // Note: Not stored or used in time stop
        // 8: "[DCR: Casting] Workaround for Spontaeous [SpellID] " + IntToString(nSpellID) + " [Target] " + GetName(oTarget)
        DebugActionSpeakByInt(8, oTarget, nSpellID);
        // Equip the best shield we have
        AI_EquipBestShield();
        // 1.4 tested this. Just casting the spell doesn't work, sillily. Still
        // stands there!

        // Decrement the spell being cast by one as we cheat cast it
        DecrementRemainingSpellUses(OBJECT_SELF, nSpellID);
        // Cheat cast, it'll remove inflict wounds if it is an inflict spell anyway.
        ActionCastSpellAtObject(nSpellID, oTarget, METAMAGIC_NONE);
        return TRUE;
    }
    return FALSE;
}

// This will cast the spell of ID in this order [Note: Always adds to time stop, as it will be on self, and benifical):
// 1. If they have the spell normally.
// * We always attack with a bow at ranged, but may attack normally after the spell.
// * If nTalent is 0, we do not cast it unless nRequirement is also 0.
// * If nRequirement is 0, it is considered innate.
// * Input nItemTalentValue and nPotionTalentValue to check item talents. -1 == No item.
// * If bSubspell is TRUE, we will cheat-cast and derement it.
int AI_ActionCastSpell(int nSpellID, object oTarget = OBJECT_SELF, int nRequirement = 0, int bLocation = FALSE, int bSubSpell = FALSE)
{
    // don't cast spells on dead targets - pok unless it is raise dead or resurrect
    if (bLocation == FALSE && nSpellID != SPELL_RAISE_DEAD && nSpellID != SPELL_RESURRECTION && GetIsDead(oTarget))
        return FALSE;

    // If it is not ever cast at location, but the target is ethreal, stop NOW
    if(bLocation == FALSE && (GetIsEthereal(oTarget) || !GetObjectSeen(oTarget))) return FALSE;

    // Check GetHasSpell as long as we are not silenced, and have right modifier, and
    // the object is seen (this is a backup for it!)
    if(!GlobalSilenceSoItems &&
      (!nRequirement || GlobalSpellAbilityModifier >= nRequirement) &&
       GetHasSpell(nSpellID))
    {
        // Make sure it is a spell, not an ability
        if(nRequirement > FALSE)
        {
            // Attempt Concentration Check (Casting a spell, not an item)
            if(AI_AttemptConcentrationCheck(oTarget)) return TRUE;
        }
        else
        {
            // Turn off all modes - remember, we can't use expertise with spellcasting!
            AI_SetMeleeMode();
        }
        // Set time stop stored to this spell.
        AI_SetTimeStopStored(nSpellID);

        // 9: "[DCR:Casting] NormalSpell [ID] " + IntToString(nSpellID) + " [Target] " + GetName(oTarget) + " [Location] " + IntToString(bLocation)
        DebugActionSpeakByInt(9, oTarget, nSpellID, IntToString(bLocation));

        // We turn off hiding/searching
        AI_ActionTurnOffHiding();

        // Equip the best shield we have
        AI_EquipBestShield();

        // Note: 1.3 fix. Action Cast At Object will be used if we can see
        // the target, even if it is a location spell
        if(GetObjectSeen(oTarget) && !GetIsEthereal(oTarget))
        {
            // aim at the object directly!
            // - See 1.3 fix below. Basically, this should use Meta Magic normally
            ActionCastSpellAtObject(nSpellID, oTarget, METAMAGIC_ANY, bSubSpell);
        }
        // If location...
        else //if(bLocation)
        {
            // Fire ActionSpellAtLocation at the given location
            // 1.3 fix - Until ActionCastSpellAtLocation works with METAMAGIC
            //           it will cheat-cast, and decrement the spell by one, with no metamagic.
            //ActionCastSpellAtLocation(nSpellID, GetLocation(oTarget), METAMAGIC_NONE, TRUE);
            //DecrementRemainingSpellUses(OBJECT_SELF, nSpellID);
            // 1.4 attempted check fix
            ActionCastSpellAtLocation(nSpellID, GetLocation(oTarget), METAMAGIC_ANY, bSubSpell);
        }
        // If bSubSpell was true, so we cheat-cast it, decrement the spell by 1
        if(bSubSpell == TRUE)
        {
            DecrementRemainingSpellUses(OBJECT_SELF, nSpellID);
        }
        // Alway stop - we use else here, so we always do an action! :-D
        return TRUE;
    }
    return FALSE;
}
// This will cast the spell of ID in this order [Note: Always adds to time stop, as it will be on self, and benifical):
// 0. If d100() is <= nRandom.
// 1. If they have the spell normally
// 2. If they have an item with the spell.
// 3. If they have a potion of the right type.
// - If we are at range from nearest enemy, we attack with a ranged weapon, else do nothing more.
// - If nTalent is -1, we do not check items.
// - Sets GlobalLastSpellValid to nSpellID if we can cast it, but don't randomly.
//     Then you can use AI_ActionCastBackupRandomSpell to see if we can cast it later.
int AI_ActionCastSpellRandom(int nSpellID, int nRandom, object oTarget = OBJECT_SELF, int nRequirement = 0, int bLocation = FALSE)
{
    // don't cast spells on dead targets - pok
    if (bLocation == FALSE && GetIsDead(oTarget))
        return FALSE;

    // If it is not ever cast at location, but the target is ethreal, stop NOW
    if(bLocation == FALSE && (GetIsEthereal(oTarget) || !GetObjectSeen(oTarget))) return FALSE;

    // Check GetHasSpell as long as we are not silenced, and have right modifier, and
    // the object is seen (this is a backup for it!)
    if(!GlobalSilenceSoItems &&
      (!nRequirement || GlobalSpellAbilityModifier >= nRequirement) &&
       GetHasSpell(nSpellID))
    {
        if(d100() <= nRandom + GlobalRandomCastModifier)
        {
            // Make sure it is a spell, not an ability
            if(nRequirement > FALSE)
            {
                // Attempt Concentration Check (Casting a spell, not an item)
                if(AI_AttemptConcentrationCheck(oTarget)) return TRUE;
            }
            else
            {
                // Turn off all modes - remember, we can't use expertise with spellcasting!
                AI_SetMeleeMode();
            }
            // Set time stop stored to this spell.
            AI_SetTimeStopStored(nSpellID);
            // 12: "[DCR:Casting] NormalRandomSpell. [ID] " + IntToString(nSpellID) + " [Target] " + GetName(oTarget) + " [Location] " + IntToString(bLocation)
            DebugActionSpeakByInt(12, oTarget, nSpellID, IntToString(bLocation));
            // We turn off hiding/searching
            AI_ActionTurnOffHiding();
            // Equip the best shield we have
            AI_EquipBestShield();
            // Note: 1.3 fix. Action Cast At Object will be used if we can see
            // the target, even if it is a location spell
            if(GetObjectSeen(oTarget) && !GetIsEthereal(oTarget))
            {
                // aim at the object directly!
                // - See 1.3 fix below. Basically, this should use Meta Magic normally
                ActionCastSpellAtObject(nSpellID, oTarget);
            }
            // If location...
            else //if(bLocation)
            {
                // Fire ActionSpellAtLocation at the given location
                // 1.3 fix - Until ActionCastSpellAtLocation works with METAMAGIC
                //           it will cheat-cast, and decrement the spell by one, with no metamagic.
                //ActionCastSpellAtLocation(nSpellID, GetLocation(oTarget), METAMAGIC_NONE, TRUE);
                //DecrementRemainingSpellUses(OBJECT_SELF, nSpellID);
                // 1.4 attempted fix.
                ActionCastSpellAtLocation(nSpellID, GetLocation(oTarget));
            }
            // Alway stop - we use else here, so we always do an action! :-D
            return TRUE;
        }
        else
        {
            // Don't use acid fog as this (Spell 0). If we have one already set,
            // this is a worse spell :-)
            AI_SetBackupCastingSpellValues(nSpellID, oTarget, bLocation, nRequirement);

            // Always return FALSE.
            return FALSE;
        }
    }
    return FALSE;
}
// This will used a stored GlobalLastSpellValid to see if it should cast that
// spell (or attempt to!) as a backup. Uses stored targets from when it did know
// it was valid.
int AI_ActionCastBackupRandomSpell()
{
    // Need a valid spell
    if(GlobalLastSpellValid > FALSE)
    {
        object oTarget;
        int nSpell, bLocation, nRequirement;
        nSpell = GlobalLastSpellValid;
        // Delete again for other castings
        GlobalLastSpellValid = FALSE;
        // 13: "[DCR:Casting] Backup spell caught: " + IntToString(nSpell)
        DebugActionSpeakByInt(13, OBJECT_INVALID, nSpell);

        // Get things from GLOBAL_LAST_SPELL_INFORMATION1 to GLOBAL...ATION5
        int nCnt = 1;
        // GET...
        // target
        oTarget = GetAIObject(GLOBAL_LAST_SPELL_INFORMATION + IntToString(nCnt));
        // location
        nCnt++;
        bLocation = GetAIInteger(GLOBAL_LAST_SPELL_INFORMATION + IntToString(nCnt));
        // reqirement
        nCnt++;
        nRequirement = GetAIInteger(GLOBAL_LAST_SPELL_INFORMATION + IntToString(nCnt));

        // Cast spell at 100% chance, and innate (already checked nRequirement)
        // - Should cast.
        if(AI_ActionCastSpell(nSpell, oTarget, nRequirement, bLocation)) return TRUE;
    }
    return FALSE;
}
// This will cast the spell/feat nSpellId (Or with nFeat), depending if it is a spell or a feat,
// at the summon location chosen before. Works similar to normal spells but
// at a special location.
// * If it is a feat, we use nFeat to define the feat, and nSpellId to define the
//   spellability to use.
// * If nRequirement is -1, it is a feat. If 0, it is innate (as spells)
int AI_ActionCastSummonSpell(int nSpellId, int nRequirement = 0, int nSummonLevel = 0, int nFeat = 0)
{
    // Feat
    if(nRequirement == -1)
    {
        // Use the new function for 1.4, to encompass spell-like-feats.
        if(AI_ActionUseSpellLikeFeat(nFeat, nSpellId))
        {
            // 14: "[DCR:Feat] [ID] " + IntToString(nFeat) + " [Enemy] " + GetName(oObject)
            DebugActionSpeakByInt(14, OBJECT_SELF, nFeat);
            SetAIInteger(AI_LAST_SUMMONED_LEVEL, nSummonLevel);
            return TRUE;
        }
    }
    else
    {
        // Check GetHasSpell as long as we are not silenced, and have right modifier, and
        // the object is seen (this is a backup for it!)
        if(!GlobalSilenceSoItems &&
          (nRequirement == FALSE || GlobalSpellAbilityModifier >= nRequirement) &&
           GetHasSpell(nSpellId))
        {
            // Make sure it is a spell, not an ability
            if(nRequirement > FALSE)
            {
                // Attempt Concentration Check (Casting a spell, not an item)
                if(AI_AttemptConcentrationCheck(GlobalSpellTarget)) return TRUE;
            }
            else
            {
                // Turn off all modes - remember, we can't use expertise with spellcasting!
                AI_SetMeleeMode();
            }
            // Set time stop stored to this spell.
            AI_SetTimeStopStored(nSpellId);

            // 9: "[DCR:Casting] NormalSpell [ID] " + IntToString(nSpellId) + " [Target] " + GetName(oTarget) + " [Location] " + IntToString(bLocation)
            DebugActionSpeakByInt(9, GlobalSpellTarget, nSpellId);

            // We turn off hiding/searching
            AI_ActionTurnOffHiding();
            // Equip the best shield we have
            AI_EquipBestShield();

            // Target a special location.
            location lTarget = AI_GetSummonLocation();

            // Fire ActionSpellAtLocation at the given location
            // 1.3 fix - Until ActionCastSpellAtLocation works with METAMAGIC
            //           it will cheat-cast, and decrement the spell by one, with no metamagic.
            // no cheat casting - pok
            ActionCastSpellAtLocation(nSpellId, lTarget, METAMAGIC_NONE);
            //DecrementRemainingSpellUses(OBJECT_SELF, nSpellId);
            // Alway stop - we use else here, so we always do an action! :-D
            return TRUE;
        }
    }
    // No summon created
    return FALSE;
}
// Gets an approprate summoning location. If we are set to summon better, we
// should get a good location between us and an enemy, else, it'll just return
// our location.
location AI_GetSummonLocation()
{
    // Get the location to cast the summoning spell at.
    // It will be a location between us and our melee target, or
    // our last hostile actor, if not in 5 M, or else us
    location lTarget;
    // - Summon spells have a 8M, short, range.
    object oTarget = OBJECT_INVALID;
    if(GetSpawnInCondition(AI_FLAG_COMBAT_IMPROVED_SUMMON_TARGETING, AI_COMBAT_MASTER))
    {
        oTarget = GetLastHostileActor();

// use party target as a fallback - pok
        if (!GetIsObjectValid(oTarget))
            oTarget = GetClosestPartyTarget();

        if(AI_GetTargetSanityCheck(oTarget) && GetDistanceToObject(oTarget) <= 16.0)
        {
            // Use oTarget (Last hostile actor)
            // oTarget = oTarget;
        }
        else if(GetDistanceToObject(GlobalRangedTarget) <= 16.0)
        {
            // Use our GlobalRangedTarget
            oTarget = GlobalRangedTarget;
        }
        if(GetDistanceToObject(GlobalMeleeTarget) <= 16.0)
        {
            // Use our GlobalMeleeTarget
            oTarget = GlobalMeleeTarget;
        }
        else
        {
            // Just cast it at ourselves.
            return GetLocation(OBJECT_SELF);
        }
    }
    else
    {
        // Just cast it at ourselves.
        return GetLocation(OBJECT_SELF);
    }

    // Taken from bioware's summon allies - half way between the targets.
    // Because we get a maximum range of 16, it means the range will be 8.
    vector vTarget = GetPosition(oTarget);
    vector vSource = GetPosition(OBJECT_SELF);
    vector vDirection = vTarget - vSource;
    float fDistance = VectorMagnitude(vDirection) / 2.0;
    vector vPoint = VectorNormalize(vDirection) * fDistance + vSource;
    lTarget = Location(GetArea(OBJECT_SELF), vPoint, DIRECTION_NORTH);

    // Return lTarget.
    return lTarget;
}
// If they have nFeat, they cheat-cast nSpell at oTarget.
// - This is a workaround for any feat, which acts as a spell, IE: A spell like feat,
//   (a feat with casting times and so on) and more importantly, also will cast
//   the nSpell if they have it anyway! so is useful for any feat.2da which
//   references the spells.2da for its effects.
// 1.4: Added the fact they can be normal spells.
int AI_ActionUseSpellLikeFeat(int nFeat, int nSpell, object oTarget = OBJECT_SELF)
{
    // Check for nSpell's and nFeat's effect. nSpell is probably the more important.
    if(GetHasSpellEffect(nSpell, oTarget) || GetHasFeatEffect(nFeat, oTarget)) return FALSE;

    // If they have the spell (or monster ability version)
    if(GetHasSpell(nSpell))
    {
        // Cast it as a normal spell. Can be assigned via. monster abilties.
        // Cheat cast the spell

        // We turn off hiding/searching
        AI_ActionTurnOffHiding();

        // Cast it normally.
        ActionCastSpellAtObject(nSpell, oTarget);
        return TRUE;
    }
    else if(GetHasFeat(nFeat))
    {
        // 14: "[DCR:Feat] [ID] " + IntToString(nFeat) + " [Enemy] " + GetName(oTarget)
        DebugActionSpeakByInt(14, oTarget, nFeat);

        // We turn off hiding/searching
        AI_ActionTurnOffHiding();

        // Cheat cast the spell
        ActionCastSpellAtObject(nSpell, oTarget, METAMAGIC_NONE, TRUE);

        // Decrement casting of it.
        DecrementRemainingFeatUses(OBJECT_SELF, nFeat);
        return TRUE;
    }
    return FALSE;
}

// This attempts to check the talent TALENT_CATEGORY_HARMFUL_RANGED, 2, which
// holds grenades. Easy checks.
// TRUE if they fire a grenade.
int AI_AttemptGrenadeThrowing(object oTarget)
{
    // 1.4 Pre-beta - no items for now.
    return FALSE;
/*
    int bReturn = FALSE;
    // Check if the items is a grenade:
    // SPELL_GRENADE_ACID - 1d6 Acid Damge/Target, or 1 splash.
    // SPELL_GRENADE_CALTROPS - Up to 25 normal damage, at 1 Damage/round to an AOE
    // SPELL_GRENADE_CHICKEN - Chicken - fires a chicken and fireball
    // SPELL_GRENADE_CHOKING - Stinking cloud type effect, dazes on fort save.
    // SPELL_GRENADE_FIRE - 1d6 fire damage/target, or 1 splash
    // SPELL_GRENADE_HOLY - 2d4 Divine Damage to undead, 1 to undead in splash
    // SPELL_GRENADE_TANGLE - Entangles spell target, reflex save.
    // SPELL_GRENADE_THUNDERSTONE - Deafens against a DC 15 fort save, AOE.

    // 744   Grenade_FireBomb - Big fire 'nade. Has an AOE after
    // 745   Grenade_AcidBomb - Big Acid 'nade. Has an AOE after damage

    if((ItemHostRanged >= SPELL_GRENADE_FIRE &&
        ItemHostRanged <= SPELL_GRENADE_CALTROPS) ||
        ItemHostRanged == 744 || ItemHostRanged == 745)
    {
        // We have a valid item grenade. We then throw it (or attempt to!)
        // - Check holy grenade not firing Versus non-undead
        if(ItemHostRanged == SPELL_GRENADE_HOLY &&
           GetRacialType(oTarget) != RACIAL_TYPE_UNDEAD)
        {
            // Stop as they are not undead
            return FALSE;
        }

        // We fire the spell at the target if they are seen
        // - If SpellTargetSeen is TRUE, fire at them
        int bLocation = FALSE;
        if(!GlobalSeenSpell)
        {
            bLocation = TRUE;
        }

        // Apply EffectCutsceneImmobilize. It only removes ones with no spell ID anyway :-D
        AI_SpecialActionApplyItem();

        talent tBestOfIt = GetCreatureTalentBest(TALENT_CATEGORY_HARMFUL_RANGED, 20);
        // JUST to make sure!
        if(GetIsTalentValid(tBestOfIt) &&
           GetIdFromTalent(tBestOfIt) == ItemHostRanged)
        {
            // 15: "[DCR:Casting] Grenade [ID] " + IntToString(ItemHostRanged) + " [Target] " + GetName(oTarget) + " [Location] " + IntToString(bLocation)
            DebugActionSpeakByInt(15, GlobalSpellTarget, IntToString(bLocation));
            // Equip the best shield we have
            AI_EquipBestShield();
            // Use this only for items, so we should not have the spell.
            if(bLocation)
            {
                ActionUseTalentAtLocation(tBestOfIt, GetLocation(oTarget));
            }
            else //if(!GetObjectSeen(GlobalSpellTarget)) // Should be seen - checked before.
            {
                ActionUseTalentOnObject(tBestOfIt, oTarget);
            }
            bReturn = TRUE;
        }
        // remove the EffectCutsceneImmobilize, if so.
        AI_SpecialActionRemoveItem();

        // Lasts...recheck items
        // TALENT_CATEGORY_HARMFUL_RANGED is always checked for items.
        ActionDoCommand(AI_SetItemTalentValue(TALENT_CATEGORY_HARMFUL_RANGED));
    }
    return bReturn;*/
}
/*::///////////////////////////////////////////////
//:: Name: GetBestSpontaeousHealingSpell
//::///////////////////////////////////////////////
// This will return the best spontaeous healing spell, so:
// - It uses just normal GetHasSpell for the clerical healing spells.
//::///////////////////////////////////////////////
//:: Created By: Jasperre
//::////////////////////////////////////////////*/
int AI_GetBestSpontaeousHealingSpell()
{
    if(GetHasSpell(SPELL_CURE_CRITICAL_WOUNDS))
    {
        return SPELL_CURE_CRITICAL_WOUNDS;
    }
    else if(GetHasSpell(SPELL_CURE_SERIOUS_WOUNDS))
    {
        return SPELL_CURE_SERIOUS_WOUNDS;
    }
    else if(GetHasSpell(SPELL_CURE_MODERATE_WOUNDS))
    {
        return SPELL_CURE_MODERATE_WOUNDS;
    }
    else if(GetHasSpell(SPELL_CURE_LIGHT_WOUNDS))
    {
        return SPELL_CURE_LIGHT_WOUNDS;
    }
    else if(GetHasSpell(SPELL_CURE_MINOR_WOUNDS))
    {
        return SPELL_CURE_MINOR_WOUNDS;
    }
    // False = no spell
    return FALSE;
}

/*::///////////////////////////////////////////////
//:: Name: AI_SetUpUs
//::///////////////////////////////////////////////
  This sets up US, the user! :-)
  - Determines class to use, dragon or not.
  - And some other things that don't need to check allies/enemies for.
  - Intelligence and so on, global effects of us and so on ;-)
//:://///////////////////////////////////////////*/
void AI_SetUpUs()
{
    int nLastSpellType, nClass1, nClass2, nClass3, nLevel1, nLevel2, nLevel3,
        nState1, nState2, nState3, nUseClass, nCurrent;
    object oSummon;
    float fTotal;
    // We set up what intelligence we have (level). See OnSpawn for more info
    // Default is 10, top 10, bottom 1.
    GlobalIntelligence = GetBoundriedAIInteger(AI_INTELLIGENCE, 10, 10, 1);
    // Checks the 3 classes, and returns one of them randomly based on how many they
    // have in that level compared to the other 2.
    GlobalOurHitDice = GetHitDice(OBJECT_SELF);
    // HP
    GlobalOurCurrentHP = GetCurrentHitPoints();
    GlobalOurMaxHP = GetMaxHitPoints();
    // Use Floats to get Decimal places.
    GlobalOurPercentHP = AI_GetPercentOf(GlobalOurCurrentHP, GlobalOurMaxHP);
    // AI - just normal. More added/subtracted be;pw
    GlobalOurAC = GetAC(OBJECT_SELF);
    switch(GetCreatureSize(OBJECT_SELF))
    {
        case CREATURE_SIZE_TINY: GlobalOurAC += 2; break;
        case CREATURE_SIZE_SMALL: GlobalOurAC += 1; break;
        case CREATURE_SIZE_LARGE: GlobalOurAC -= 1; break;
        case CREATURE_SIZE_HUGE: GlobalOurAC -= 2; break;
    }
    GlobalOurBaseAttackBonus = GetBaseAttackBonus(OBJECT_SELF);
    // Spell Ranged Attacking
    if(GetSpawnInCondition(AI_FLAG_COMBAT_LONGER_RANGED_SPELLS_FIRST, AI_COMBAT_MASTER))
    {
        SRA = TRUE;
    }
    // Set up the extra % to random cast
    GlobalRandomCastModifier = GlobalIntelligence * 2;
    // - 2% extra at 1, 20% at 10 :-)

    // Set if we are a global buffer
    GlobalWeAreBuffer = GetSpawnInCondition(AI_FLAG_COMBAT_MORE_ALLY_BUFFING_SPELLS, AI_COMBAT_MASTER);

    // Set if we only use items
    GlobalSilenceSoItems = AI_GetAIHaveEffect(GlobalEffectSilenced);

    // If we have any of the silent feats, epic, we ignore any silence we have.
    if(GlobalSilenceSoItems)
    {
        if(GetHasFeat(FEAT_EPIC_AUTOMATIC_SILENT_SPELL_1) ||
           GetHasFeat(FEAT_EPIC_AUTOMATIC_SILENT_SPELL_2) ||
           GetHasFeat(FEAT_EPIC_AUTOMATIC_SILENT_SPELL_3))
        {
            GlobalSilenceSoItems = FALSE;
        }
    }

    // Our reach is the distance we can immediantly attack, normally.
    GlobalOurReach = IntToFloat(GetCreatureSize(OBJECT_SELF) * 4) + 1.0;
    // Sets up the class to use.
    fTotal = IntToFloat(GlobalOurHitDice);
    nClass1 = GetClassByPosition(1);
    nClass2 = GetClassByPosition(2);
    nClass3 = GetClassByPosition(3);

    // If we only have one class, we buckle out here.
    if(nClass2 == CLASS_TYPE_INVALID)
    {
        GlobalOurChosenClass = nClass1;
        GlobalOurChosenClassLevel = GetLevelByClass(nClass1);
    }
    else
    {
        // Else, we DO do this each round, because if we have more then one
        // class, we randomly choose which one we "are", for cirtain (although
        // not many) choices made in the AI.
        nLevel1 = GetLevelByClass(nClass1);
        nLevel2 = GetLevelByClass(nClass2);
        nLevel3 = GetLevelByClass(nClass3);
        // Set up how much % each class occupies.
        nState1 = FloatToInt((IntToFloat(nLevel1) / fTotal) * 100);
        nState2 = FloatToInt((IntToFloat(nLevel2) / fTotal) * 100) + nState1;
        nState3 = FloatToInt((IntToFloat(nLevel3) / fTotal) * 100) + nState2;
        // Randomise the % we pick
        nUseClass = d100();
        // Set the class, and that classes level.
        if(nUseClass <= nState1)
        {
            GlobalOurChosenClass = nClass1;
            GlobalOurChosenClassLevel = nLevel1;
        }
        else if(nUseClass > nState1 && nUseClass <= nState2)
        {
            GlobalOurChosenClass = nClass2;
            GlobalOurChosenClassLevel = nLevel2;
        }
        else
        {
            GlobalOurChosenClass = nClass3;
            GlobalOurChosenClassLevel = nLevel3;
        }
    }

    // Intelligence based spellcaster.
    if(GlobalOurChosenClass == CLASS_TYPE_WIZARD)
    {
        GlobalSpellAbilityModifier = GetAbilityScore(OBJECT_SELF, ABILITY_INTELLIGENCE);
        GlobalSpellBaseSaveDC = 10 + GetAbilityModifier(ABILITY_INTELLIGENCE);
    }
    // Wisdom based spellcaster
    else if(GlobalOurChosenClass == CLASS_TYPE_DRUID ||
            GlobalOurChosenClass == CLASS_TYPE_CLERIC)
    {
        GlobalSpellAbilityModifier = GetAbilityScore(OBJECT_SELF, ABILITY_WISDOM);
        GlobalSpellBaseSaveDC = 10 + GetAbilityModifier(ABILITY_WISDOM);
    }
    // Charisma
    else if(GlobalOurChosenClass == CLASS_TYPE_BARD ||
            GlobalOurChosenClass == CLASS_TYPE_SORCERER)
    {
        // Summoning specials (and some others). If we are a bard/sorceror, it means
        // we cast 1 from X spells, not just "Only got that spell".
        GlobalWeAreSorcerorBard = TRUE;
        // Charisma based spellcaster
        GlobalSpellAbilityModifier = GetAbilityScore(OBJECT_SELF, ABILITY_CHARISMA);
        GlobalSpellBaseSaveDC = 10 + GetAbilityModifier(ABILITY_CHARISMA);
    }
    else // Monster
    {
        // - We set ability modifier to 25, so that they cast all spells
        //   and monster abilties
        GlobalSpellAbilityModifier = 25;
        GlobalSpellBaseSaveDC = 10 + GetAbilityModifier(ABILITY_CHARISMA);
    }
    // Set up GlobalSaveStupidity, 10 - Intelligence
    // 0 is better then 10! Bascially, if they are immune (EG: Massive fortitude
    // fighter VS death save) then taking 10 from thier save stat means a lower
    // intelligence caster will fire it against immune beings.
    // - Also used in AOE checking.
    GlobalSaveStupidity = 10 - GlobalIntelligence;

    // Set up SR roll
    // - 20 + Class level + 2 for spell penetration, +4 for greater.
    // - We always take it as a 20 - but we set this for a huge amount.
    //   NOTE: we check HD only - because of monster abilities.
    GlobalSpellPenetrationRoll = GlobalOurHitDice + 20;
    // Check for feats
    if(GetHasFeat(FEAT_EPIC_SPELL_PENETRATION))
    {
        GlobalSpellPenetrationRoll += 6;
    }
    else if(GetHasFeat(FEAT_GREATER_SPELL_PENETRATION))
    {
        GlobalSpellPenetrationRoll += 4;
    }
    else if(GetHasFeat(FEAT_SPELL_PENETRATION))
    {
        GlobalSpellPenetrationRoll += 2;
    }
    // Summon checking (special)
    // Used for summoned creatures.
    oSummon = GetAssociate(ASSOCIATE_TYPE_SUMMONED);
    if(GetIsObjectValid(oSummon) && !GetIsDead(oSummon))
    {
        // If valid, we can use the level of the last cast to check if valid.
        int nCurrentSummonLevel = GetAIInteger(AI_LAST_SUMMONED_LEVEL);
        // - Never replace epic, or elemental sparm, or balors (10, 11/12)
        // - Never replace sorcerors or bards
        if(!GlobalWeAreSorcerorBard && nCurrentSummonLevel <= 9)
        {
            // We check thier HP. If they are under x6% and under 30HP, we may summon
            // a summon over this one that exsists.
            nCurrent = GetCurrentHitPoints(oSummon);
            if(((nCurrent * 6) < GetMaxHitPoints(oSummon)) && (nCurrent <= 30))
            {
                // Make it -1, so that we will say, summon a level 5 summon
                // over a damaged level 6, but never a level 2 summon in replacement.
                GlobalCanSummonSimilarLevel = nCurrentSummonLevel - 1;
            }
        }
        // If we have not set GlobalCanSummonSimilarLevel, we set it so we
        // should not summon anything at all!
        if(!GlobalCanSummonSimilarLevel)
        {
            GlobalCanSummonSimilarLevel = 100;
        }
    }
    else
    {
        // Reset to 0, false, to summon any monster
        DeleteAIInteger(AI_LAST_SUMMONED_LEVEL);
        GlobalCanSummonSimilarLevel = FALSE;
    }
}
/*::///////////////////////////////////////////////
//:: Name: AI_GetNearbyFleeObject
//::///////////////////////////////////////////////
 This returns an object, not seen not heard ally, who we
 might flee to. Uses a loop, and runs only when we are going to flee for sure.
//:://///////////////////////////////////////////*/
object AI_GetNearbyFleeObject()
{
    object oReturn, oGroup, oEndReturn;
    int nCnt;
    string sCheck;
    if(GetSpawnInCondition(AI_FLAG_FLEEING_FLEE_TO_NEAREST_NONE_SEEN, AI_TARGETING_FLEE_MASTER))
    {
        oReturn = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND,
                                     OBJECT_SELF, 1,
                                     CREATURE_TYPE_PERCEPTION, PERCEPTION_NOT_SEEN_AND_NOT_HEARD,
                                     CREATURE_TYPE_IS_ALIVE, TRUE);
        if(GetIsObjectValid(oReturn)) // Need LOS check
        {
            return oReturn;
        }
    }
    if(GetSpawnInCondition(AI_FLAG_FLEEING_FLEE_TO_OBJECT, AI_TARGETING_FLEE_MASTER))
    {
        sCheck = GetLocalString(OBJECT_SELF, AI_FLEE_OBJECT);
        if(sCheck != "")
        {
            // We need to get the nearest of sCheck objects we cannot see nor hear, and
            // over 6 meters just in case.
            nCnt = 1;
            oReturn = GetNearestObjectByTag(sCheck, OBJECT_SELF, nCnt);
            while(GetIsObjectValid(oReturn))
            {
                // this should be simple enough to break when the object is valid.
                if(!GetObjectSeen(oReturn) && !GetObjectHeard(oReturn) &&
                    GetDistanceToObject(oReturn) > 6.0) // (must be same area)
                {
                    // Stop if valid
                    return oReturn;
                }
                nCnt++;
                oReturn = GetNearestObjectByTag(sCheck, OBJECT_SELF, nCnt);
            }
            if(!GetIsObjectValid(oReturn))
            {
                // Just get any!
                oReturn = GetObjectByTag(sCheck);
                if(GetIsObjectValid(oReturn))
                {
                    return oReturn;
                }
            }
        }
    }
    // Reset
    oReturn = OBJECT_INVALID;
    oGroup = OBJECT_INVALID;
    // By default:
    // At 1-3 INT, we run to the nearest non-seen, non-heard.
    // At 4-7, we run to the best ally group, within 35M, or an ally who is +5 our HD.
    // At 8+, we run to the best group, in 70M, or an ally who is +8 our HD, and we shout for help (HB)

    if(GlobalIntelligence <= 3)
    {
        // Don't care if not valid!
        oReturn = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND,
                                     OBJECT_SELF, 1,
                                     CREATURE_TYPE_PERCEPTION, PERCEPTION_NOT_SEEN_AND_NOT_HEARD,
                                     CREATURE_TYPE_IS_ALIVE, TRUE);
        return oReturn;
    }

    // Counters ETC
    int nBestAllyGroupTotal, nCurrentGroupHD, nGroupCnt, nIfHigherBreak;
    // Set floats
    float fMaxCheckForGroup, fMaxGroupRange;
    // Check range (Ie people we get near to us, need to be in this range)
    fMaxCheckForGroup = 100.0;// 10 tiles
    if(GlobalIntelligence >= 8) fMaxCheckForGroup *= 2; // Double check range.
    fMaxGroupRange = 15.0;// Default. No need to change.

    // We break when we have a group totaling some value of our HD...
    // It goes up as intelligence does.(IE 4, 5, 6, 7, 8, 9 or 10 * HD/2 + 1)
    nIfHigherBreak = GlobalOurHitDice * ((GlobalIntelligence / 2) + 1);
    // Note to self: THis means highest intelligence runs futhest away, hopefully smarter.
    // Note: Need an acceptable limit. 10 * 20 is 200, now max 140 with
    // level 40 creatures running around.
    if(nIfHigherBreak > 140) nIfHigherBreak = 140;

    nCnt = 1;// Start at 1 nearest.
    // Nearest ally is got...we use not seen/not heard, not PC and friendly.
    // Making it oReturn might return something at the very least.
    oReturn = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND,
                                 OBJECT_SELF, nCnt,
                                 CREATURE_TYPE_IS_ALIVE, TRUE,
                                 CREATURE_TYPE_PERCEPTION, PERCEPTION_NOT_SEEN_AND_NOT_HEARD);
    // Need to be valid, the things we get, and not in X float meters.
    while(GetIsObjectValid(oReturn) &&  GetDistanceToObject(oReturn) <= fMaxCheckForGroup)
    {
        // Loop the people around him,
        nCurrentGroupHD = GetHitDice(oReturn);
        nGroupCnt = 1;
        oGroup = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND,
                                    oReturn, nGroupCnt,
                                    CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_NOT_PC,
                                    CREATURE_TYPE_PERCEPTION, PERCEPTION_NOT_SEEN_AND_NOT_HEARD);
        // Remember 15M range limit.
        while(GetIsObjectValid(oGroup) &&
              GetDistanceBetween(oReturn, oGroup) <= fMaxGroupRange)
        {
            nCurrentGroupHD += GetHitDice(oGroup);
            // Get next group object
            nGroupCnt++;
            oGroup = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND,
                                        oReturn, nGroupCnt,
                                        CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_NOT_PC,
                                        CREATURE_TYPE_PERCEPTION, PERCEPTION_NOT_SEEN_AND_NOT_HEARD);
        }
        // Break time.
        // It is (Int * HD/2 + 1), max 140. Shouldn't be too bad.
        if(nCurrentGroupHD > nIfHigherBreak)
        {
            // Return this person
            return oReturn;
        }
        // Sets the ally, if got lots of allies. (Or a mass of HD)
        else if(nCurrentGroupHD > nBestAllyGroupTotal)
        {
            nBestAllyGroupTotal = nCurrentGroupHD;
            oEndReturn = oReturn;
        }
        nCnt++;
        oReturn = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND,
                                     OBJECT_SELF, nCnt,
                                     CREATURE_TYPE_IS_ALIVE, TRUE,
                                     CREATURE_TYPE_PERCEPTION, PERCEPTION_NOT_SEEN_AND_NOT_HEARD);
    }
    // By default, return nothing (oEndReturn = OBJECT_INVALID unless set in loop)
    return oEndReturn;
}
/*::///////////////////////////////////////////////
//:: Name: AI_CompareTimeStopStored
//::///////////////////////////////////////////////
 TRUE if the spell is one recorded as being cast before in time stop.
 - Checks Global "Are we in time stop?" and returns FALSE if not in time stop
//:://///////////////////////////////////////////*/
int AI_CompareTimeStopStored(int nSpell1, int nSpell2 = AI_SPELL_INVALID, int nSpell3 = AI_SPELL_INVALID, int nSpell4 = AI_SPELL_INVALID)
{
    // Set array size is under 0, IE no array, stop.
    if(GlobalTimeStopArraySize < 0) return FALSE;
    if(GlobalInTimeStop)
    {
        int nSpell = AI_SPELL_INVALID;
        int nCnt;
        if(GlobalTimeStopArraySize == 0)
        {
            GlobalTimeStopArraySize = GetAIInteger(TIME_STOP_LAST_ARRAY_SIZE);
            if(GlobalTimeStopArraySize == 0)
            {
                GlobalTimeStopArraySize = -1;
            }
        }
        if(GlobalTimeStopArraySize > 0)
        {
            for(nCnt = 1; nCnt <= GlobalTimeStopArraySize; nCnt++)
            {
                nSpell = GetAIConstant(TIME_STOP_LAST_ + IntToString(nCnt));
                if(nSpell == nSpell1 ||
                   nSpell == nSpell2 ||
                   nSpell == nSpell3 ||
                   nSpell == nSpell4)
                {
                    return TRUE;
                }
            }
        }
    }
    return FALSE;
}
/*::///////////////////////////////////////////////
//:: Name: AI_GetBestFriendyAreaSpellTarget
//::///////////////////////////////////////////////
 Returns the object to the specifications:
 Within nRange (float)
 The most targets around the creature in nRange, in nSpread.
 Can be the caster, of course
//:://///////////////////////////////////////////*/
/* UNCOMMENT
object AI_GetBestFriendyAreaSpellTarget(float fRange, float fSpread, int nShape)
{
    object oGroupies, oSpellTarget, oTarget;
    int nCountOnPerson, nMostOnPerson, nCnt;
    location lTarget;
    // Will always at least return ourselves.
    oSpellTarget = OBJECT_SELF;
    nCnt = 1;
    // Gets the nearest friend...the loops takes care of range.
    oTarget = GetLocalObject(OBJECT_SELF, ARRAY_ALLIES_RANGE_SEEN + IntToString(nCnt));
    // Start loop. Checks range here.
    while(GetIsObjectValid(oTarget) && GetDistanceToObject(oTarget) <= fRange)
    {
        lTarget = GetLocation(oTarget);
        // Starts the count at 0, as first object in shape will also include the target.
        nCountOnPerson = 0;
        // Reset/Start counting the spread on oTarget.
        oGroupies = GetFirstObjectInShape(nShape, fSpread, lTarget);
        // If oGroupies is invalid, nothing.
        while(GetIsObjectValid(oGroupies))
        {
            // Only add one if the person is an friend
            if(GetIsFriend(oGroupies))
            {
                nCountOnPerson++;
            }
            oGroupies = GetNextObjectInShape(nShape, fSpread, lTarget);
        }
        if(nCountOnPerson > nMostOnPerson)
        {
            nMostOnPerson = nCountOnPerson;
            oSpellTarget = oTarget;
        }
        nCnt++;
        oTarget = GetLocalObject(OBJECT_SELF, ARRAY_ALLIES_RANGE + IntToString(nCnt));
    }
    // Will always return self if anything
    return oSpellTarget;
}      END UNCOMMENT*/
// If the target will always save against nSaveType, and will take no damage, returns TRUE
// * Target is GlobalSpellTarget. Save is GlobalSpellTargetWill ETC.
// * nSaveType - SAVING_THROW WILL/REFLEX/FORTITUDE
// * nSpellLevel - Level of the spell being cast.
int AI_SaveImmuneSpellTarget(int nSaveType, int nSpellLevel)
{
    if(nSaveType == SAVING_THROW_FORT)
    {
        // Basic one here. Some addition and comparison.
        if(GlobalSpellTargetFort - GlobalSaveStupidity >= (GlobalSpellBaseSaveDC + nSpellLevel)) return TRUE;
    }
    else if(nSaveType == SAVING_THROW_REFLEX)
    {
        // Evasion - full damaged saved if the save is sucessful.
        if(GetHasFeat(FEAT_EVASION, GlobalSpellTarget) ||
           GetHasFeat(FEAT_IMPROVED_EVASION, GlobalSpellTarget))
        {
            if(GlobalSpellTargetReflex - GlobalSaveStupidity >= (GlobalSpellBaseSaveDC + nSpellLevel)) return TRUE;
        }
    }
    else if(nSaveType == SAVING_THROW_WILL)
    {
        // Slippery mind has a re-roll. 1.3 - Ignore
        if(GlobalSpellTargetWill - GlobalSaveStupidity >= (GlobalSpellBaseSaveDC + nSpellLevel))
        {
            return TRUE;
        }
    }
    return FALSE;
}
// If the target will always save against nSaveType, and will take no damage, returns TRUE
// * oTarget - who saving against spell.
// * nSaveType - SAVING_THROW WILL/REFLEX/FORTITUDE
//  * The save used is GetReflexSavingThrow* ETC.
// * nSpellLevel - Level of the spell being cast.
int AI_SaveImmuneAOE(object oTarget, int nSaveType, int nSpellLevel)
{
    // GlobalSaveStupidity = 10 - Intelligence. Basically, lower intellgence
    // will fire spells which may do nothing more often.

    // Return if no level (innate ability normally)
    if(nSpellLevel == FALSE) return FALSE;
    if(nSaveType == SAVING_THROW_FORT)
    {
        // Basic one here. Some addition and comparison.
        if(GetFortitudeSavingThrow(oTarget) - GlobalSaveStupidity >= (GlobalSpellBaseSaveDC + nSpellLevel)) return TRUE;
    }
    else if(nSaveType == SAVING_THROW_REFLEX)
    {
        // Evasion - full damaged saved if the save is sucessful.
        if(GetHasFeat(FEAT_EVASION, oTarget) ||
           GetHasFeat(FEAT_IMPROVED_EVASION, oTarget))
        {
            if(GetReflexSavingThrow(oTarget)- GlobalSaveStupidity >= (GlobalSpellBaseSaveDC + nSpellLevel)) return TRUE;
        }
    }
    else if(nSaveType == SAVING_THROW_WILL)
    {
        // Slippery mind has a re-roll. We ignore in 1.3
        if(GetWillSavingThrow(oTarget) - GlobalSaveStupidity >= (GlobalSpellBaseSaveDC + nSpellLevel))
        {
            return TRUE;
        }
    }
    return FALSE;
}
/*::///////////////////////////////////////////////
//:: Name: SpellResistanceImmune
//::///////////////////////////////////////////////
 This checks targets spell resistance. If our level + 20 is below thier
 resistance, the spell won't affect them.
//::////////////////////////////////////////////*/
int AI_SpellResistanceImmune(object oTarget)
{
    // Check the targets spell resistance VS our GlobalSpellPenetrationRoll
    // GlobalSpellPenetrationRoll = Our Hit Dice + Special help feats.
    if(GetSpellResistance(oTarget) >= GlobalSpellPenetrationRoll)
    {
        return TRUE;
    }
    // Note: Removed monk feat, and spell resistance spell, but not sure if
    // it checks alignment-orientated SR's...
    // 1.4: Removed redudant code. Even if it isn't checked, not much is lost.
    return FALSE;
}
/*::///////////////////////////////////////////////
//:: Name: GetSpellLevelEffect
//::///////////////////////////////////////////////
 This returns a number, 1-4. This number is the levels
 of spell they will be totally immune to.
//::////////////////////////////////////////////*/
int AI_GetSpellLevelEffect(object oTarget)
{
    int nNatural = GetLocalInt(oTarget, AI_SPELL_IMMUNE_LEVEL);
    // Stop here, if natural is over 4
    if(nNatural > 4) return nNatural;

    // Big globe affects 4 or lower spells
    if(GetHasSpellEffect(SPELL_GLOBE_OF_INVULNERABILITY, oTarget) || nNatural >= 4)
        return 4;
    // Minor globe is 3 or under
    if(GetHasSpellEffect(SPELL_MINOR_GLOBE_OF_INVULNERABILITY, oTarget) ||
       // Shadow con version
       GetHasSpellEffect(SPELL_GREATER_SHADOW_CONJURATION_MINOR_GLOBE, oTarget) ||
       nNatural >= 3)
        return 3;
    // 2 and under is ethereal visage.
    if(GetHasSpellEffect(SPELL_ETHEREAL_VISAGE, oTarget) || nNatural >= 2)
        return 2;
    // Ghostly Visarge affects 1 or 0 level spells, and any spell immunity.
    if(GetHasSpellEffect(SPELL_GHOSTLY_VISAGE, oTarget) || nNatural >= 1 ||
       // Or shadow con version.
       GetHasSpellEffect(SPELL_GREATER_SHADOW_CONJURATION_MIRROR_IMAGE, oTarget))
        return 1;
    // Return nNatural, which is 0-9
    return FALSE;
}
// Input oTarget and nLevel and it will check if they are automatically
// immune to the spell being cast.
int AI_GetSpellLevelEffectAOE(object oTarget, int nLevel = 9)
{
    // Return if no level (innate ability normally)
    if(nLevel == FALSE) return FALSE;
    // Checks any NPC natural total spell immunities (like globes, but on hides)
    // - On PC's, the local will return 0. this saves an extra !GetIsPC check.
    if(nLevel <= GetLocalInt(oTarget, AI_SPELL_IMMUNE_LEVEL))
    {
        return TRUE;
    }
    // Big globe affects 4 or lower spells
    if(nLevel <= 4 && GetHasSpellEffect(SPELL_GLOBE_OF_INVULNERABILITY, oTarget))
    {
        return TRUE;
    }
    // Minor globe is 3 or under
    if(nLevel <= 3 && (GetHasSpellEffect(SPELL_MINOR_GLOBE_OF_INVULNERABILITY, oTarget) ||
    // Shadow con version
       GetHasSpellEffect(SPELL_GREATER_SHADOW_CONJURATION_MINOR_GLOBE, oTarget)))
    {
        return TRUE;
    }
    // 2 and under is ethereal visage.
    if(nLevel <= 2 && GetHasSpellEffect(SPELL_ETHEREAL_VISAGE, oTarget))
    {
        return TRUE;
    }
    // 1 and under is ghostly visage.
    if(nLevel <= 1 && (GetHasSpellEffect(SPELL_GHOSTLY_VISAGE, oTarget) ||
       GetHasSpellEffect(SPELL_GREATER_SHADOW_CONJURATION_MIRROR_IMAGE)))
    {
        return TRUE;
    }
    // False if a level 5+ spell
    return FALSE;
}

// Returns TRUE if any of the checks the oGroupTarget is immune to.
int AI_AOEDeathNecroCheck(object oGroupTarget, int bNecromanticSpell, int bDeathImmune)
{
    if(bNecromanticSpell)
    {
        if(GetHasSpellEffect(SPELL_DEATH_WARD, oGroupTarget) ||
           GetHasSpellEffect(SPELL_UNDEATHS_ETERNAL_FOE, oGroupTarget)) return TRUE;
    }
    if(bDeathImmune)
    {
        return GetIsImmune(oGroupTarget, IMMUNITY_TYPE_DEATH);
    }
    return FALSE;
}
/*:://////////////////////////////////////////////
//:: Name Get the best HOSTILE spell target
//:: Function Name  AI_GetBestAreaSpellTarget
//:://////////////////////////////////////////////
    Returns the object to the specifications:
    * fRange - Within fRange (fTouchRange 2.25, fShortRange 8.0, fMediumRange 20.0, fLongRange = 40.0)
    * fSpread - Radius Size - RADIUS_SIZE_* constants (1.67 to 10.0M)
    * nLevel - Used for saving throws/globe checks. Level of the spell added to save checks
    * nSaveType = FALSE - SAVING_THROW_FORT/REFLEX/WILL. Not type, but the main save applied with it.
    * nShape = SHAPE_SPHERE - SHAPE_* constants.
    * bFriendlyFire = FALSE - Can this hurt allies? Best thing is to put
         GlobalFriendlyFireHostile - GetIsReactionTypeHostile(oTarget) == TRUE
         GlobalFriendlyFireFriendly - GetIsReactionTypeFriendly(oTarget) == FALSE
         FALSE - Cannot hurt allies (GetIsEnemy/!GetIsFriend used)
    * bDeathImmune = FALSE - Does it use a death save? (!GetIsImmune)
    * bNecromanticSpell = FALSE - Is it a necromancy spell? Undead are also checked in this.

    1.4 change: Cones ignore bFriendlyFire.
    1.4: MAYBE: should make it so fRange is ignored - since if we want SRA, we
         will loop the SpellAllSpells() up to 4 times.
//:://////////////////////////////////////////////
//:: Created By: Jasperre
//::////////////////////////////////////////////*/
object AI_GetBestAreaSpellTarget(float fRange, float fSpread, int nLevel, int nSaveType = FALSE, int nShape = SHAPE_SPHERE, int bFriendlyFire = FALSE, int bDeathImmune = FALSE, int bNecromanticSpell = FALSE)
{
    // If it is a cone, we ignore bFriendlyFire and set it to FALSE
    if(nShape == SHAPE_CONE || nShape == SHAPE_SPELLCONE)
    {
        bFriendlyFire = FALSE;
    }
    // Before we start, if it can harm us, we don't fire it if there are no
    // enemies out of the blast, if it was centered on us
    if(bFriendlyFire)
    {
        if(GlobalRangeToFuthestEnemy <= fSpread) return OBJECT_INVALID;
    }
    // Delcare objects
    // (Target = Loop of nearest creatures. oResturnTarget = Who to return,
    //  and oGroupTarget is GetFirst/Next in nShape around oTarget)
    object oTarget, oReturnTarget, oGroupTarget;
    // Delcare Integers
    int nCnt, nCntEnemiesOnTarget, nCntAlliesOnTarget, iNoHittingAllies,
        nMostOnPerson, nMaxAlliesToHit, nOurToughness;
    // Declare Booleans
    int bWillHitAlly, bNoHittingAllies, bCheckAlliesHP;
    location lTarget;
    // Float values
    float fDistance, fTargetMustBeFrom;

    // - We don't check specific immunities with cirtain properties/settings
    // If we have NOT got the setting and <= 6 int
    if(GlobalIntelligence <= 6 &&
      !GetSpawnInCondition(AI_FLAG_COMBAT_IMPROVED_IMMUNITY_CHECKING, AI_COMBAT_MASTER))
    {
        bDeathImmune = FALSE;
        bNecromanticSpell = FALSE;
    }
    // NOT got extra checks in.
    if(!GetSpawnInCondition(AI_FLAG_COMBAT_IMPROVED_SPECIFIC_SPELL_IMMUNITY, AI_COMBAT_MASTER))
    {
        nLevel = 5; // This makes the spell think it gets past globes.
        // - Problem is that the save DC will increase. Won't affect much.
    }

    // We set up the distance that oTarget must be away from us, if it is
    // no friendly fire, it will be 0.0 meters, so we always use them.
    // - defaults to 0.0 meters unless FF is on
    if(bFriendlyFire)
    {
        fTargetMustBeFrom = fSpread + 0.3;
    }

    // Can we hit allies?
    bNoHittingAllies = GetSpawnInCondition(AI_FLAG_COMBAT_NEVER_HIT_ALLIES, AI_COMBAT_MASTER);
    // Do we check thier HP? (Allies) to see if they survive?
    bCheckAlliesHP = GetSpawnInCondition(AI_FLAG_COMBAT_AOE_DONT_MIND_IF_THEY_SURVIVE, AI_COMBAT_MASTER);

    // We will subtract all non-enemies within -8 challenge, upwards.
    nOurToughness = GlobalOurHitDice - GetBoundriedAIInteger(AI_AOE_HD_DIFFERENCE, -8, 0, -30);
    // The maximum number of allies we can hit...
    nMaxAlliesToHit = GetBoundriedAIInteger(AI_AOE_ALLIES_LOWEST_IN_AOE, 4, 90, 1);
    // The target to return - set to invalid to start
    oReturnTarget = OBJECT_INVALID;

    nCnt = 1;
    // - 1.3 Change - made to target only creatures (trying to better performance)
    oTarget = GetNearestObject(OBJECT_TYPE_CREATURE, OBJECT_SELF, nCnt);
    // Need distance a lot.
    fDistance = GetDistanceToObject(oTarget);
    // Need to see the target, within nRange around self.
    while(GetIsObjectValid(oTarget) && fDistance <= fRange)
    {
        // Need seen/heard target
        // * The actual target can be a dead person, or anything, just something
        //   with a valid location. We thusly do not use AI_GetTargetSanityCheck()
        // * NOTE: Ethereal checks NOT here, we can target any ethereal persons
        //   location (which might be better!)
        if(GetObjectSeen(oTarget) || GetObjectHeard(oTarget))
        {
            // Will not fire on self, if it is too near.
            if(fDistance > fTargetMustBeFrom)
            {
                // Reset Targets
                // - The person starts the spread at 0, because the object in shape
                //   will return the target as well.
                nCntEnemiesOnTarget = FALSE;
                nCntAlliesOnTarget = FALSE;
                bWillHitAlly = FALSE;
                // Must sue this - needs to use the correct shape
                // This only gets creatures in shape to check.
                lTarget = GetLocation(oTarget);
                oGroupTarget = GetFirstObjectInShape(nShape, fSpread, lTarget);
                // If oGroupies is invalid, nothing. Should not - as target will be returned at least.
                while(GetIsObjectValid(oGroupTarget) && bWillHitAlly != TRUE)
                {
                    // Sanity check for checking oGroupTarget
                    if(oGroupTarget != OBJECT_SELF &&
                    // * This adds a check for seen or heard, which makes it more
                    //   realistic!
                       AI_GetTargetSanityCheck(oGroupTarget) &&
                      !AI_SpellResistanceImmune(oGroupTarget))
                    {
                        // Check necromancy immunity, and death immunity.
                        // + Save check
                        // + Level Immunity check
                        if(!AI_AOEDeathNecroCheck(oGroupTarget, bNecromanticSpell, bDeathImmune) &&
                           !AI_SaveImmuneAOE(oGroupTarget, nSaveType, nLevel) &&
                           !AI_GetSpellLevelEffectAOE(oGroupTarget, nLevel))
                        {
                            if(GetIsEnemy(oGroupTarget))
                            {
                                // Only add one if the person is an enemy,
                                // and the spell will affect them
                                nCntEnemiesOnTarget++;
                            }
                            // But else if friendly fire, we will subract
                            // similar non-allies.
                            else if(bFriendlyFire &&
                                   (GetIsFriend(oGroupTarget) || GetFactionEqual(oGroupTarget)) &&
                                    GetHitDice(oGroupTarget) >= nOurToughness)
                            {
                                if(bNoHittingAllies)
                                {
                                    bWillHitAlly = TRUE;
                                }
                                // We ignore if not got the setting to check HP,
                                // else, we take one from the nCntEnemiesOnTarget.
                                else if(bCheckAlliesHP && GetCurrentHitPoints(oGroupTarget) < 50)
                                {
                                    nCntAlliesOnTarget++;
                                }
                            }
                        }
                    }
                    // Get next target in shape
                    oGroupTarget = GetNextObjectInShape(nShape, fSpread, lTarget);
                }
                // Make the spell target oTarget if so.
                // If it is >= then we set it - it is a futher away target!
                if(bWillHitAlly != TRUE && nCntEnemiesOnTarget >= 1 &&
                   nCntAlliesOnTarget <= nMaxAlliesToHit &&
                  ((nCntEnemiesOnTarget - nCntAlliesOnTarget) >= nMostOnPerson))
                {
                    nMostOnPerson = nCntEnemiesOnTarget - nCntAlliesOnTarget;
                    oReturnTarget = oTarget;
                }
            }
        }
        // Gets the next nearest.
        nCnt++;
        oTarget = GetNearestObject(OBJECT_TYPE_CREATURE, OBJECT_SELF, nCnt);
        fDistance = GetDistanceToObject(oTarget);
    }
    // Will OBJECT_INVALID, or the best target in range.
    return oReturnTarget;
}
/*::///////////////////////////////////////////////
//:: Name: AI_SortSpellImmunities
//::///////////////////////////////////////////////
 Sets the Global Hex for the enemy spell target immunties.
 - Uses effects loop and GetIsImmune to comprehend the most.
//::///////////////////////////////////////////////
//:: Created By: Jasperre
//:://///////////////////////////////////////////*/
void AI_SortSpellImmunities()
{
    // Error checking
    if(!GetIsObjectValid(GlobalSpellTarget)) return;
    // Get our good/evil alignment, for the purposes of the mind immunity
    // commonly employed via. Protection From Alignment
    int nGoodEvil = GetAlignmentGoodEvil(OBJECT_SELF);

    // Check effects of GlobalSpellTarget
    effect eCheck = GetFirstEffect(GlobalSpellTarget);
    while(GetIsEffectValid(eCheck))
    {
        switch(GetEffectType(eCheck))
        {
            case EFFECT_TYPE_TURNED:
            case EFFECT_TYPE_FRIGHTENED:
            {
                AI_SetSpellTargetImmunity(GlobalImmunityFear);
            }
            break;
            case EFFECT_TYPE_STUNNED:
            case EFFECT_TYPE_PARALYZE: // Count as stun. Near as dammit
            case EFFECT_TYPE_DAZED: // Here for now :-)
            {
                AI_SetSpellTargetImmunity(GlobalImmunityStun);
            }
            break;
            case EFFECT_TYPE_SLEEP:
            {
                AI_SetSpellTargetImmunity(GlobalImmunitySleep);
            }
            break;
            case EFFECT_TYPE_POISON:
                AI_SetSpellTargetImmunity(GlobalImmunityPoison);
            break;
            case EFFECT_TYPE_NEGATIVELEVEL:
                AI_SetSpellTargetImmunity(GlobalImmunityNegativeLevel);
            break;
            case EFFECT_TYPE_ENTANGLE:
                AI_SetSpellTargetImmunity(GlobalImmunityEntangle);
            break;
            case EFFECT_TYPE_DOMINATED:
            case EFFECT_TYPE_CHARMED:
                AI_SetSpellTargetImmunity(GlobalImmunityMind);
            break;
            case EFFECT_TYPE_CONFUSED:
            {
                AI_SetSpellTargetImmunity(GlobalImmunityConfusion);
            }
            break;
            case EFFECT_TYPE_DISEASE:
                AI_SetSpellTargetImmunity(GlobalImmunityDisease);
            break;
            case EFFECT_TYPE_CURSE:
                AI_SetSpellTargetImmunity(GlobalImmunityCurse);
            break;
            case EFFECT_TYPE_BLINDNESS:
            case EFFECT_TYPE_DEAF:
                AI_SetSpellTargetImmunity(GlobalImmunityBlindDeaf);
            break;
            case EFFECT_TYPE_SLOW:
                AI_SetSpellTargetImmunity(GlobalImmunitySlow);
            break;
            // All
            case EFFECT_TYPE_PETRIFY:
            // * This should never be set, we do not target petrified people!
                AI_SetSpellTargetImmunity(GlobalImmunityPetrify);
            break;
            // Defualt, check spell ID
            default:
            {
                switch(GetEffectSpellId(eCheck))
                {
                    // Mantals
                    case SPELL_GREATER_SPELL_MANTLE:
                    case SPELL_SPELL_MANTLE:
                    case SPELL_LESSER_SPELL_MANTLE:
                         AI_SetSpellTargetImmunity(GlobalImmunityMantalProtection);
                    break;
                    // If the target has death ward, they are immune.
                    case SPELL_DEATH_WARD:
                         AI_SetSpellTargetImmunity(GlobalImmunityDeath);
                    break;
                    // Spells that stop negative energy spells: Shadow Shield, Negative energy protection
                    case SPELL_SHADOW_SHIELD:
                    case SPELL_UNDEATHS_ETERNAL_FOE:// New one SoU
                    {
                        AI_SetSpellTargetImmunity(GlobalImmunityNegativeEnergy);
                        AI_SetSpellTargetImmunity(GlobalImmunityNecromancy);
                    }
                    break;
                    case SPELL_NEGATIVE_ENERGY_PROTECTION:
                        AI_SetSpellTargetImmunity(GlobalImmunityNegativeEnergy);
                    break;
                    case SPELL_CLARITY:
                    case SPELL_MIND_BLANK:
                    case SPELL_LESSER_MIND_BLANK:// New one SoU
                        AI_SetSpellTargetImmunity(GlobalImmunityMind);
                    break;
                    case SPELL_UNHOLY_AURA:
                    case SPELL_MAGIC_CIRCLE_AGAINST_GOOD:
                    case SPELL_PROTECTION_FROM_GOOD:// New one SoU
                        if(nGoodEvil == ALIGNMENT_GOOD) AI_SetSpellTargetImmunity(GlobalImmunityMind);
                    break;
                    case SPELL_HOLY_AURA:
                    case SPELL_PROTECTION_FROM_EVIL:
                    case SPELL_MAGIC_CIRCLE_AGAINST_EVIL:// New one SoU
                        if(nGoodEvil == ALIGNMENT_EVIL) AI_SetSpellTargetImmunity(GlobalImmunityMind);
                    break;
                }
            }
            break;
        }
        eCheck = GetNextEffect(GlobalSpellTarget);
    }
    // Immunity Things
    // We only use these if 7+ Intelligence
    if(GlobalIntelligence >= 7 ||
       GetSpawnInCondition(AI_FLAG_COMBAT_IMPROVED_IMMUNITY_CHECKING, AI_COMBAT_MASTER))
    {
        // Necromancy immune if undead
        if(!AI_GetSpellTargetImmunity(GlobalImmunityNecromancy) &&
           (GlobalSpellTargetRace == RACIAL_TYPE_UNDEAD ||
            GlobalSpellTargetRace == RACIAL_TYPE_CONSTRUCT))
            AI_SetSpellTargetImmunity(GlobalImmunityNecromancy);
        // Death immunity
        if(!AI_GetSpellTargetImmunity(GlobalImmunityDeath) &&
           (GetIsImmune(GlobalSpellTarget, IMMUNITY_TYPE_DEATH) ||
            GlobalSpellTargetRace == RACIAL_TYPE_UNDEAD ||
            GlobalSpellTargetRace == RACIAL_TYPE_CONSTRUCT))
            AI_SetSpellTargetImmunity(GlobalImmunityDeath);
        // confusion immunity
        if(!AI_GetSpellTargetImmunity(GlobalImmunityConfusion) &&
            GetIsImmune(GlobalSpellTarget, IMMUNITY_TYPE_CONFUSED))
            AI_SetSpellTargetImmunity(GlobalImmunityConfusion);
        // Negative level immunity
        if(!AI_GetSpellTargetImmunity(GlobalImmunityNegativeLevel) &&
            GetIsImmune(GlobalSpellTarget, IMMUNITY_TYPE_NEGATIVE_LEVEL))
            AI_SetSpellTargetImmunity(GlobalImmunityNegativeLevel);
        // Mind immunity
        if(!AI_GetSpellTargetImmunity(GlobalImmunityMind) &&
            GetIsImmune(GlobalSpellTarget, IMMUNITY_TYPE_MIND_SPELLS))
            AI_SetSpellTargetImmunity(GlobalImmunityMind);
        // Old ones, I doubt needed with GetIsImmune in.
        // - Dragon race, Construct, Undead and Empty Body.
        // Fear checking
        if(!AI_GetSpellTargetImmunity(GlobalImmunityFear) &&
           (AI_GetSpellTargetImmunity(GlobalImmunityMind) ||
            GetIsImmune(GlobalSpellTarget, IMMUNITY_TYPE_FEAR)))
        {
            AI_SetSpellTargetImmunity(GlobalImmunityFear);
        }
        // Old ones for fear.
        // - Undead, Dragon, Construct, Outsider
        // - Feat Aura of courage, resist natures lure
        // This stops curses.
        if(!AI_GetSpellTargetImmunity(GlobalImmunityCurse) &&
            GetIsImmune(GlobalSpellTarget, IMMUNITY_TYPE_CURSED))
            AI_SetSpellTargetImmunity(GlobalImmunityCurse);
        // This stops poison.
        if(!AI_GetSpellTargetImmunity(GlobalImmunityPoison) &&
            GetIsImmune(GlobalSpellTarget, IMMUNITY_TYPE_POISON))
            AI_SetSpellTargetImmunity(GlobalImmunityPoison);
        // This will stop blindness/deafness spells
        if(!AI_GetSpellTargetImmunity(GlobalImmunityBlindDeaf) &&
           (GetIsImmune(GlobalSpellTarget, IMMUNITY_TYPE_BLINDNESS) ||
            GetIsImmune(GlobalSpellTarget, IMMUNITY_TYPE_DEAFNESS)))
            AI_SetSpellTargetImmunity(GlobalImmunityBlindDeaf);
        // Stun (And paralsis)
        if(!AI_GetSpellTargetImmunity(GlobalImmunityStun) &&
           (GetIsImmune(GlobalSpellTarget, IMMUNITY_TYPE_STUN) ||
            GetIsImmune(GlobalSpellTarget, IMMUNITY_TYPE_PARALYSIS)))
            AI_SetSpellTargetImmunity(GlobalImmunityStun);
        // This stops entanglement.
        if(!AI_GetSpellTargetImmunity(GlobalImmunityEntangle) &&
           (GetIsImmune(GlobalSpellTarget, IMMUNITY_TYPE_ENTANGLE) ||
            GetHasFeat(FEAT_WOODLAND_STRIDE, GlobalSpellTarget)))
            AI_SetSpellTargetImmunity(GlobalImmunityEntangle);
        // Sleep
        if(!AI_GetSpellTargetImmunity(GlobalImmunitySleep) &&
           (GetIsImmune(GlobalSpellTarget, IMMUNITY_TYPE_SLEEP) ||
            GetHasFeat(FEAT_IMMUNITY_TO_SLEEP, GlobalSpellTarget)))
            AI_SetSpellTargetImmunity(GlobalImmunitySleep);
        // Poison
        if(!AI_GetSpellTargetImmunity(GlobalImmunityPoison) &&
            GetIsImmune(GlobalSpellTarget, IMMUNITY_TYPE_POISON))
            AI_SetSpellTargetImmunity(GlobalImmunityPoison);
        // Disease
        if(!AI_GetSpellTargetImmunity(GlobalImmunityDisease) &&
            GetIsImmune(GlobalSpellTarget, IMMUNITY_TYPE_DISEASE))
            AI_SetSpellTargetImmunity(GlobalImmunityDisease);
        // We don't check these feats for immune disease/poison till checked
        // if the immune doesn't include htem
        //  GetHasFeat(FEAT_RESIST_DISEASE, GlobalSpellTarget)
        //  GetHasFeat(FEAT_VENOM_IMMUNITY, GlobalSpellTarget)
        //  GetHasFeat(FEAT_DIAMOND_BODY, GlobalSpellTarget)
        if(!AI_GetSpellTargetImmunity(GlobalImmunitySlow) &&
            GetIsImmune(GlobalSpellTarget, IMMUNITY_TYPE_SLOW))
            AI_SetSpellTargetImmunity(GlobalImmunitySlow);
        // Domination (+Charm)
        if(!AI_GetSpellTargetImmunity(GlobalImmunityDomination))
        {
            if(GetIsObjectValid(GetMaster(GlobalSpellTarget)) ||
               GlobalSpellTargetRace == RACIAL_TYPE_ELEMENTAL ||
               GlobalSpellTargetRace == RACIAL_TYPE_UNDEAD ||
               GlobalSpellTargetRace == RACIAL_TYPE_VERMIN ||
               GlobalSpellTargetRace == RACIAL_TYPE_CONSTRUCT ||
               GetIsImmune(GlobalSpellTarget, IMMUNITY_TYPE_DOMINATE) ||
               GetIsImmune(GlobalSpellTarget, IMMUNITY_TYPE_CHARM) ||
               GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_DOMINATED)))
            {
                AI_SetSpellTargetImmunity(GlobalImmunityDomination);
            }
        }
    }
    // We won't use petrify on those immune, though. This is taken from
    // x0_0_spells. Stops silly basalisks or something. :-)
    // - ANY intelligence
    if(!AI_GetSpellTargetImmunity(GlobalImmunityPetrify))
    {
        switch(GetAppearanceType(GlobalSpellTarget))
        {
            case APPEARANCE_TYPE_BASILISK:
            case APPEARANCE_TYPE_COCKATRICE:
            case APPEARANCE_TYPE_MEDUSA:
            case APPEARANCE_TYPE_ALLIP:
            case APPEARANCE_TYPE_ELEMENTAL_AIR:
            case APPEARANCE_TYPE_ELEMENTAL_AIR_ELDER:
            case APPEARANCE_TYPE_ELEMENTAL_EARTH:
            case APPEARANCE_TYPE_ELEMENTAL_EARTH_ELDER:
            case APPEARANCE_TYPE_ELEMENTAL_FIRE:
            case APPEARANCE_TYPE_ELEMENTAL_FIRE_ELDER:
            case APPEARANCE_TYPE_ELEMENTAL_WATER:
            case APPEARANCE_TYPE_ELEMENTAL_WATER_ELDER:
            case APPEARANCE_TYPE_GOLEM_STONE:
            case APPEARANCE_TYPE_GOLEM_IRON:
            case APPEARANCE_TYPE_GOLEM_CLAY:
            case APPEARANCE_TYPE_GOLEM_BONE:
            case APPEARANCE_TYPE_GORGON:
            case APPEARANCE_TYPE_HEURODIS_LICH:
            case APPEARANCE_TYPE_LANTERN_ARCHON:
            case APPEARANCE_TYPE_SHADOW:
            case APPEARANCE_TYPE_SHADOW_FIEND:
            case APPEARANCE_TYPE_SHIELD_GUARDIAN:
            case APPEARANCE_TYPE_SKELETAL_DEVOURER:
            case APPEARANCE_TYPE_SKELETON_CHIEFTAIN:
            case APPEARANCE_TYPE_SKELETON_COMMON:
            case APPEARANCE_TYPE_SKELETON_MAGE:
            case APPEARANCE_TYPE_SKELETON_PRIEST:
            case APPEARANCE_TYPE_SKELETON_WARRIOR:
            case APPEARANCE_TYPE_SKELETON_WARRIOR_1:
            case APPEARANCE_TYPE_SPECTRE:
            case APPEARANCE_TYPE_WILL_O_WISP:
            case APPEARANCE_TYPE_WRAITH:
            case APPEARANCE_TYPE_BAT_HORROR:
                AI_SetSpellTargetImmunity(GlobalImmunityPetrify);
            break;
        }
    }
    // Earthquake check removed.
/*   Still got:
    IMMUNITY_TYPE_ABILITY_DECREASE          IMMUNITY_TYPE_AC_DECREASE
    IMMUNITY_TYPE_ATTACK_DECREASE           IMMUNITY_TYPE_CRITICAL_HIT
    IMMUNITY_TYPE_DAMAGE_DECREASE           IMMUNITY_TYPE_DAMAGE_IMMUNITY_DECREASE
    IMMUNITY_TYPE_MOVEMENT_SPEED_DECREASE   IMMUNITY_TYPE_SAVING_THROW_DECREASE
    IMMUNITY_TYPE_SILENCE                   IMMUNITY_TYPE_SKILL_DECREASE
    IMMUNITY_TYPE_SPELL_RESISTANCE_DECREASE IMMUNITY_TYPE_TRAP   */

}

/*::///////////////////////////////////////////////
//:: Name: AI_ActionDispelAOE
//::///////////////////////////////////////////////
    Dispels or moves out of the oAOE.
    - If we have >= nMax AND <= nDamage HP...
      AND under nPercent total HP...
        - We Dispel, or move out of the AOE. Move if friendly.
    Note: We get nearest AOE of sAOE tag. Must be valid as well.

    1.3 - Added
//::///////////////////////////////////////////////
//:: Created By: Jasperre
//:://///////////////////////////////////////////*/
int AI_ActionDispelAOE(int nSpell, int bDamageOnly, float fRange, int nDamage, int nMax, int nPercent)
{
    object oAOE = GetAIObject(AI_TIMER_AOE_SPELL_EVENT + IntToString(nSpell));
    // Get damage done
    int nLastDamage = GetAIInteger(ObjectToString(oAOE));
    // Delete/clean up
    DeleteAIInteger(ObjectToString(oAOE));
    // Check we will be affected, or are affected, by the AOE at all!
    if(GetIsObjectValid(oAOE) && GetDistanceToObject(oAOE) <= fRange &&
       // + Damaged from that AOE, or affected by that AOE.
      (nLastDamage >= TRUE || (GetHasSpellEffect(nSpell) && !bDamageOnly)))
    {
        // Either Under nMax AND under
        if((GlobalOurMaxHP >= nMax && GlobalOurCurrentHP <= nDamage) ||
            GlobalOurPercentHP <= nPercent || !GlobalAnyValidTargetObject)
        {
            // 16: "[AOE Call] Moving out of/Dispeling an AOE. [Tag] " + GetTag(oAOE)
            DebugActionSpeakByInt(16, oAOE);
            // If an enemy, Dispel it.
            if(!GetIsFriend(GetAreaOfEffectCreator(oAOE)))
            {
                // 11 = Harmful AOE indis. 2 = Harmful ranged.
                // Gust of Wind. Level 3 (Bard/Mage) Dispels all AOE's in radius, and save VS fort for 3 round knockdown.
                if(AI_ActionCastSpell(SPELL_GUST_OF_WIND, oAOE, 13, TRUE)) return TRUE;
                // Worst to best, then move...wind gust best!
                // - Note that they have a % chance to remove stuff...
                if(AI_ActionCastSpell(SPELL_LESSER_DISPEL, oAOE, 12, TRUE)) return TRUE;
                if(AI_ActionCastSpell(SPELL_DISPEL_MAGIC, oAOE, 13, TRUE)) return TRUE;
                if(AI_ActionCastSpell(SPELL_GREATER_DISPELLING, oAOE, 16, TRUE)) return TRUE;
                if(AI_ActionCastSpell(SPELL_MORDENKAINENS_DISJUNCTION, oAOE, 19, TRUE)) return TRUE;
            }
            // Else move. We force this until we are out of the AOE
            SetAIObject(AI_AOE_FLEE_FROM, oAOE);
            SetLocalFloat(OBJECT_SELF, AI_AOE_FLEE_FROM_RANGE, fRange + GlobalOurReach);
            SetCurrentAction(AI_SPECIAL_ACTIONS_MOVE_OUT_OF_AOE);
            ActionMoveAwayFromLocation(GetLocation(oAOE), TRUE, fRange + GlobalOurReach);
            return TRUE;
        }
    }
    return FALSE;
}
/*::///////////////////////////////////////////////
//:: Name: Special Checks
//::///////////////////////////////////////////////
    This will check for darkness, AOE spells,
    time stop stored, and a few other things.
//::///////////////////////////////////////////////
//:: Created By: Jasperre
//::////////////////////////////////////////////*/
int AI_AttemptSpecialChecks()
{
    // Delete stored ints if not in time stop.
    if(!GlobalInTimeStop) AI_DeleteTimeStopStored();

    // - Fleeing is performed in ClearAllAction()'s wrapper

    // Darkness! the ENEMY OF THE ARTIFICAL INTELlIGENCE!!! MUAHAHAH! WE COMBAT IT WELL! (sorta)
    if((AI_GetAIHaveSpellsEffect(GlobalEffectDarkness) &&
       !AI_GetAIHaveEffect(GlobalEffectUltravision) &&
       !AI_GetAIHaveEffect(GlobalEffectTrueSeeing))
      // Check nearest enemy with darkness effect. Use heard only (they won't be seen!)
       || GetIsObjectValid(GetNearestCreature(CREATURE_TYPE_HAS_SPELL_EFFECT, SPELL_DARKVISION, OBJECT_SELF, 1, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, CREATURE_TYPE_PERCEPTION, PERCEPTION_HEARD)))
    {
        // Ultravision - Talent category 10 (Benificial enchancement Self).
        if(AI_ActionCastSpell(SPELL_DARKVISION, OBJECT_SELF, 13, FALSE)) return TRUE;
        // 1.30/SoU trueeing should Dispel it. (Benificial conditional AOE)
        if(AI_ActionCastSpell(SPELL_TRUE_SEEING, OBJECT_SELF, 16, FALSE)) return TRUE;

        // If we are a rubbish fightingclass OR we cannot hear any enemy to attack...move or something.
        if(!GlobalValidNearestSeenEnemy &&
           // If only someone else has it, don't worry, its only if we cannot see anyone
          (GlobalOurChosenClass == CLASS_TYPE_WIZARD ||
           GlobalOurChosenClass == CLASS_TYPE_SORCERER ||
           GlobalOurChosenClass == CLASS_TYPE_FEY))
        {
            // 17: "[DCR:Special] Darkness + Caster. No seen enemy. Dispel/Move."
            DebugActionSpeakByInt(17);
            // Dispel it - trying nearest creature, if has darkness as well
            // 11 = Harmful AOE indis. 2 = Harmful ranged.
            // WORST to BEST as all of them never check caster levels for AOEs (Silly bioware!)
            if(AI_ActionCastSpell(SPELL_LESSER_DISPEL, OBJECT_SELF, 12, TRUE)) return TRUE;
            if(AI_ActionCastSpell(SPELL_DISPEL_MAGIC, OBJECT_SELF, 13, TRUE)) return TRUE;
            if(AI_ActionCastSpell(SPELL_GREATER_DISPELLING, OBJECT_SELF, 16, TRUE)) return TRUE;
            if(AI_ActionCastSpell(SPELL_MORDENKAINENS_DISJUNCTION, OBJECT_SELF, 19, TRUE)) return TRUE;

            ActionMoveAwayFromLocation(GetLocation(OBJECT_SELF), TRUE, 6.0);
            return TRUE;
        }
    }
    object oInvisible = GetAIObject(AI_LAST_TO_GO_INVISIBLE);
    DeleteAIObject(AI_LAST_TO_GO_INVISIBLE);
    // Intelligence: 8+ means HIPS check. There is a 80% chance.
    if((!GetIsObjectValid(oInvisible) || GetObjectSeen(oInvisible)) &&
         GlobalIntelligence >= 8 && d10() <= 8)
    {
        // Makes the AI cast seeing spells against shadowdancers who will HIPS
        oInvisible = GetNearestCreature(CREATURE_TYPE_CLASS, CLASS_TYPE_SHADOWDANCER, OBJECT_SELF, 1, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, CREATURE_TYPE_IS_ALIVE, TRUE);
        DeleteAILocation(AI_LAST_TO_GO_INVISIBLE);
    }
    // If we have a previously set invisible enemy or if high intelligence, a shadowdancer in range.
    if(GetIsObjectValid(oInvisible))
    {
        // 1.30/SoU trueeing should Dispel it. (Benificial conditional AOE)
        if(AI_ActionCastSpell(SPELL_TRUE_SEEING, OBJECT_SELF, 16, FALSE)) return TRUE;
        // Invisiblity purge! SpellConAre
        if(AI_ActionCastSpell(SPELL_INVISIBILITY_PURGE, OBJECT_SELF, 14, FALSE)) return TRUE;
        // This should work well as well! SpellConSinTar
        if(AI_ActionCastSpell(SPELL_SEE_INVISIBILITY, OBJECT_SELF, 12, FALSE)) return TRUE;

        location lTarget = GetAILocation(AI_LAST_TO_GO_INVISIBLE);
        DeleteAILocation(AI_LAST_TO_GO_INVISIBLE);

        // Check location validness
        if(GetIsObjectValid(GetAreaFromLocation(lTarget)))
        {
            // We will cast at thier previous location, using a temp object we actually
            // create there for a few seconds.
            oInvisible = CreateObject(OBJECT_TYPE_PLACEABLE, "", lTarget);
            // Check range
            if(GetIsObjectValid(oInvisible) &&
               GetDistanceToObject(oInvisible) < 40.0)
            {
                // 1.4: Temp: Cast at location with the base spells only
                if(GetHasSpell(SPELL_MORDENKAINENS_DISJUNCTION))
                {
                    ActionCastSpellAtLocation(SPELL_MORDENKAINENS_DISJUNCTION, lTarget);
                    return TRUE;
                }
                else if(GetHasSpell(SPELL_GREATER_DISPELLING))
                {
                    ActionCastSpellAtLocation(SPELL_GREATER_DISPELLING, lTarget);
                    return TRUE;
                }
                else if(GetHasSpell(SPELL_DISPEL_MAGIC))
                {
                    ActionCastSpellAtLocation(SPELL_DISPEL_MAGIC, lTarget);
                    return TRUE;
                }
                else if(GetHasSpell(SPELL_LESSER_DISPEL))
                {
                    ActionCastSpellAtLocation(SPELL_LESSER_DISPEL, lTarget);
                    return TRUE;
                }

                // Best to worst
                //if(AI_ActionCastSpell(SPELL_MORDENKAINENS_DISJUNCTION, oInvisible, 19, TRUE)) return TRUE;
                //if(AI_ActionCastSpell(SPELL_GREATER_DISPELLING, oInvisible, 16, TRUE)) return TRUE;
                //if(AI_ActionCastSpell(SPELL_DISPEL_MAGIC, oInvisible, 13, TRUE)) return TRUE;
                //if(AI_ActionCastSpell(SPELL_LESSER_DISPEL, oInvisible, 12, TRUE)) return TRUE;
            }
        }
    }
    // AOE spells
    // - Either we Dispel it or move out of it.
    //   - Dispeling more if higher INT.
    // - We always move if it does great damage
    // - Low intelligence ignores this (probably to thier doom).

    // We have already:
    // - Set if there is an AOE that affects us cast at us.
    // - Checked any saves avalible, and immunities (Intelligence based)

    // Delcarations.
    object oAOE = GetNearestObject(OBJECT_TYPE_AREA_OF_EFFECT);
    float fDistance = GetDistanceToObject(oAOE);

    // First check: We randomly check this if INT 1-5, and always check 6+
    if(GlobalIntelligence >= (6 - d6()) &&
    // Second: Need a valid AOE, of course!
       GetIsObjectValid(oAOE) &&
    // Third: Needs to be in 10.0 M
       fDistance <= RADIUS_SIZE_COLOSSAL)
    {
        int bElemental = AI_GetAIHaveSpellsEffect(GlobalHasElementalProtections);
        int bPhisical = AI_GetAIHaveSpellsEffect(GlobalHasStoneSkinProtections);
        // We can check the timers added to spells, to check for AOEs we are in.

        // Long range ones...already made sure of collosal range!
        // Storm of vengance...a lot of damage (so we need only 30HP left)
        // Stats: Raduis 10! d6(3) , Get Is Friend/Friendly.
        // Either: Electical (reflex) and stun (failed save), else Acid, d6(6).
        if(GetLocalTimer(AI_TIMER_AOE_SPELL_EVENT + IntToString(SPELL_STORM_OF_VENGEANCE)) && !bElemental)
        {
            if(AI_ActionDispelAOE(SPELL_STORM_OF_VENGEANCE, TRUE, RADIUS_SIZE_COLOSSAL, 30, 50, 20)) return TRUE;
        }
        // Next range...6.7
        if(fDistance <= RADIUS_SIZE_HUGE)
        {
            // Creeping doom!
            // This can get a lot of damage. We might check the counter status...
            // Stats: Radius 6.7. Initial d20 damage (can't stop), Slow as well. Reaction Type Friendly.
            // d6(Amount of rounds in effect) each round after that, HURTS! (up to 1000)
            if(GetLocalTimer(AI_TIMER_AOE_SPELL_EVENT + IntToString(SPELL_CREEPING_DOOM)) && !bPhisical)
            {
                if(AI_ActionDispelAOE(SPELL_CREEPING_DOOM, TRUE, RADIUS_SIZE_HUGE, GetLocalInt(oAOE, "NW_SPELL_CONSTANT_CREEPING_DOOM1" + ObjectToString(GetAreaOfEffectCreator(oAOE))) * 6, 40, 40)) return TRUE;
            }
            // Stinking cloud!
            // No damage, only daze. If we are immune to it - fine.
            // Note: PATCH 1.30 should make daze walkable - we can wait
            // to be affected then walk out of the area :-)
            // Only fortitude save.
            if(GetLocalTimer(AI_TIMER_AOE_SPELL_EVENT + IntToString(SPELL_STINKING_CLOUD)))
            {
                if(AI_ActionDispelAOE(SPELL_STINKING_CLOUD, TRUE, RADIUS_SIZE_HUGE, 25, 60, 35)) return TRUE;
            }
            // Grease
            // Stats: Radius 6. (count as 6.7) We get slowed (unless Woodland Stride) in it always.
            // On a reflex save each round, knockdown effect (4 seconds). Reaction Type Friendly.
            if(GetLocalTimer(AI_TIMER_AOE_SPELL_EVENT + IntToString(SPELL_GREASE)))
            {
                if(AI_ActionDispelAOE(SPELL_GREASE, FALSE, RADIUS_SIZE_HUGE, 10, 25, 15)) return TRUE;
            }
            // Wall of fire...
            // Stats: 10M x 2M rectangle. d6(4) Fire damage (Reflex save).
            // Notes: level 5/6 spell. Not bad, up to 24 damage! Reaction Type Frendly.
            if(GetLocalTimer(AI_TIMER_AOE_SPELL_EVENT + IntToString(SPELL_WALL_OF_FIRE)) && !bElemental)
            {
                if(AI_ActionDispelAOE(SPELL_WALL_OF_FIRE, TRUE, RADIUS_SIZE_HUGE, 20, 50, 25)) return TRUE;
            }
            // Blade Barrier (special shape!)
            // Stats: 10M x 1M rectangle. d6(CasterLevel) Piercing damage (Reflex save).
            // Notes: LOTs of damage! warning about this one! Reaction Type friendly.
            if(GetLocalTimer(AI_TIMER_AOE_SPELL_EVENT + IntToString(SPELL_BLADE_BARRIER)) &&  !bPhisical)
            {
                if(AI_ActionDispelAOE(SPELL_BLADE_BARRIER, TRUE, RADIUS_SIZE_HUGE, 30, 50, 35)) return TRUE;
            }
            // Next range...5.0
            if(fDistance <= RADIUS_SIZE_LARGE)
            {
                // Acid Fog spell
                // Stats: Radius 5. Damage: d6(2), Fort/2. Slow on failed Fort save (On Enter)
                // Notes: Level 6 spell. Uses ReactionType, not GetFriend.
                if(GetLocalTimer(AI_TIMER_AOE_SPELL_EVENT + IntToString(SPELL_ACID_FOG)) && !bElemental)
                {
                    // Ignore slowing effect
                    if(AI_ActionDispelAOE(SPELL_ACID_FOG, TRUE, RADIUS_SIZE_HUGE, 20, 40, 25)) return TRUE;
                }
                // Inceniary Cloud spell
                // Stats: Radius 5. Damage: d6(4), Reflex. Slow always.
                // Notes: Level 8 spell. Uses ReactionTypeFriendly, not GetFriend.
                if(GetLocalTimer(AI_TIMER_AOE_SPELL_EVENT + IntToString(SPELL_INCENDIARY_CLOUD)) && !bElemental)
                {
                    // Ignore slow
                    if(AI_ActionDispelAOE(SPELL_INCENDIARY_CLOUD, TRUE, RADIUS_SIZE_HUGE, 30, 50, 35)) return TRUE;
                }
                // Cloudkill spell
                // Stats: Radius 5. Under 3HD Die. 4-7 Save VS Death (Fort)
                // All Damage d10(), no save.
                if(GetLocalTimer(AI_TIMER_AOE_SPELL_EVENT + IntToString(SPELL_CLOUDKILL)))
                {
                    // Damage only
                    if(AI_ActionDispelAOE(SPELL_CLOUDKILL, TRUE, RADIUS_SIZE_HUGE, 15, 30, 25)) return TRUE;
                }
                // Evards Black Tenticals.
                // Stats: Radius 5. 1d6 damage if d20 + 5 hits the target. (Reaction Type Hostile)
                // May paralize them as well, on a fort save. Up to 5 of these tenticals BTW.
                if(GetLocalTimer(AI_TIMER_AOE_SPELL_EVENT + IntToString(SPELL_EVARDS_BLACK_TENTACLES)) && !bPhisical)
                {
                    if(AI_ActionDispelAOE(SPELL_EVARDS_BLACK_TENTACLES, TRUE, RADIUS_SIZE_HUGE, 15, 30, 25)) return TRUE;
                }
                // Mind Fog spell
                // Stats: Radius 5.
                // -10 to will saves, if fail a will save (and it continues out of it).
                if(GetLocalTimer(AI_TIMER_AOE_SPELL_EVENT + IntToString(SPELL_MIND_FOG)) &&
                   GetLocalInt(OBJECT_SELF, AI_ABILITY_DECREASE) > FALSE)
                {
                    // No damage
                    if(AI_ActionDispelAOE(SPELL_MIND_FOG, FALSE, RADIUS_SIZE_HUGE, 15, 30, 25)) return TRUE;
                }
                // Entangle
                // Stats: Radius 5. Reaction Type hostile used.
                // Entangle effect against a reflex save each round (for 12 seconds).
                if(GetLocalTimer(AI_TIMER_AOE_SPELL_EVENT + IntToString(SPELL_ENTANGLE)) &&
                   AI_GetAIHaveEffect(GlobalEffectEntangle))
                {
                    // No damage
                    if(AI_ActionDispelAOE(SPELL_ENTANGLE, FALSE, RADIUS_SIZE_HUGE, 15, 30, 25)) return TRUE;
                }
                // Vine mine
                // Stats: Radius as Entangle - Radius 5
                if(GetLocalTimer(AI_TIMER_AOE_SPELL_EVENT + IntToString(SPELL_VINE_MINE_ENTANGLE)) &&
                   AI_GetAIHaveEffect(GlobalEffectEntangle))
                {
                    // " "
                    if(AI_ActionDispelAOE(SPELL_VINE_MINE_ENTANGLE, FALSE, RADIUS_SIZE_HUGE, 15, 30, 25)) return TRUE;
                }
                // Hamper movement one
                if(GetLocalTimer(AI_TIMER_AOE_SPELL_EVENT + IntToString(SPELL_VINE_MINE_HAMPER_MOVEMENT)) &&
                   AI_GetAIHaveEffect(GlobalEffectMovementSpeedDecrease))
                {
                    if(AI_ActionDispelAOE(SPELL_VINE_MINE_HAMPER_MOVEMENT, FALSE, RADIUS_SIZE_HUGE, 15, 30, 25)) return TRUE;
                }
            }
            // Web
            // Stats: 6.67 Radius
            // Notes: Just a large entange + Slow for anyone.
            if(GetLocalTimer(AI_TIMER_AOE_SPELL_EVENT + IntToString(SPELL_WEB)) &&
               AI_GetAIHaveEffect(GlobalEffectEntangle))
            {
                if(AI_ActionDispelAOE(SPELL_WEB, FALSE, RADIUS_SIZE_HUGE, 30, 50, 35)) return TRUE;
            }
        }
    }
    // End AOE
    return FALSE;
}
/*::///////////////////////////////////////////////
//:: AI_GetHealingSpellRank, AI_GetHealingSpellPower
//::///////////////////////////////////////////////
    Returns the rank (the first) and the spell power/average healing (the latter)
//::///////////////////////////////////////////////
//:: Created by: Jasperre
//:://///////////////////////////////////////////*/
// Returns the healing "Rank" of nSpellId (made up by me) which the spell is.
// Used in healing, Heal (+Mass Heal) is done seperatly in the healing routines.
// * Returns a default of 0 if no valid healing spell is found (Or was a Heal spell)
// * Use bSelf to be TRUE if you want to include "Cure Other" spells in Hordes
int AI_GetHealingSpellRank(int nSpellId, int bSelf = FALSE)
{
    // On error - return 0 rank, or 0 heal.
    if(nSpellId <= FALSE) return FALSE;
    switch(nSpellId)
    {
        // Each spell has a specific rank, such as Heal is highest, Cure Minor is
        // lowest.
        // Critical: Rank 10
        case SPELL_CURE_CRITICAL_WOUNDS: return 10; break;
        // Cure light wounds (Lesser Body Adjustment is the same script) is rank 2
        case SPELLABILITY_LESSER_BODY_ADJUSTMENT:
        case SPELL_CURE_LIGHT_WOUNDS:
            return 2;
        break;
        // Cure minor - lowest, rank 1.
        case SPELL_CURE_MINOR_WOUNDS: return 1; break;
        // Moderate rank 3.
        case SPELL_CURE_MODERATE_WOUNDS: return 3; break;
        // Serious rank 4.
        case SPELL_CURE_SERIOUS_WOUNDS: return 4; break;
        // Healing circle, rank 4. AOE healing isn't returned in the same talent
        // as Single Target healing.
        case SPELL_HEALING_CIRCLE: return 4; break;
        // Cure Critical Wounds other depends on if bSelf is FALSE.
        case AI_SPELLABILITY_CURE_CRITICAL_WOUNDS_OTHER: return 9; break;
    }
    // On error - return 0 rank
    return FALSE;
}

// This will return the average amount healed by nSpellId, determined as if they
// were the minimum level used to cast it, and average rolls were performed.
// * Used in healing to check if we should bother using the spell yet, eg:
//   a 50HP person with a ciritical wounds potion might take it at 10HP, not 25HP,
//   because it heals a lot.
int AI_GetHealingSpellPower(int nSpellId)
{
    // On error - return 0 rank, or 0 heal.
    if(nSpellId <= FALSE) return FALSE;
    switch(nSpellId)
    {
        // RANK - NAME = D8 AMOUNTs + RANGE OF CLERIC LEVELS ADDED. MAX.
        // AVERAGE OF DICE. ABOUT 2/3 OF MODIFIERS.

        //  20 - Critical = 4d8 + 7-20. Max of 32. Take as 24. Take modifiers as 10.
        case SPELL_CURE_CRITICAL_WOUNDS: return 35; break;
        // 10 - Lesser Bodily Adjustment = 1d8 + 1-5. Max of 8. Take as 6. Take modifiers as 3.
        // NOTE: same spell script as Cure Light Wounds, but no concentration check!
        // 8 - Light = 1d8 + 2-5. Max of 8. Take as 6. Take modifiers as 3.
        case SPELLABILITY_LESSER_BODY_ADJUSTMENT:
        case SPELL_CURE_LIGHT_WOUNDS:
            return 9;
        break;
        // 4 - Minor = 1. Max of 1. Take as 1. Take modifiers as 0.
        case SPELL_CURE_MINOR_WOUNDS: return 1; break;
        // 12 - Moderate = 2d8 + 3-10. Max of 16. Take as 12. Take modifiers as 5.
        case SPELL_CURE_MODERATE_WOUNDS: return 17; break;
        // 16 - Serious = 3d8 + 5-15. Max of 24. Take as 18. Take modifiers as 7.
        case SPELL_CURE_SERIOUS_WOUNDS: return 25; break;
        // 14 - Healing circle = 1d8 + 9-20. Max of 8. Take as 8. Take modifiers as 10.
        case SPELL_HEALING_CIRCLE: return 18; break;
        // As cure critical wounds, but cures another and damages us...
        // Rank is 0 if this spell is put in and the target isn't us. We don't
        // need a bSelf check therefore.
        //  20 - Critical = 4d8 + 7-20. Max of 32. Take as 24. Take modifiers as 9.
        case AI_SPELLABILITY_CURE_CRITICAL_WOUNDS_OTHER: return 35; break;
    }
    // On error - return 0 rank, or 0 heal.
    return FALSE;
}

// Wrappers action Use Talent with debug string
void AI_ActionUseTalentDebug(talent tChosenTalent, object oTarget)
{
    // 18: "[DRC:Talent] Using Talent (Healing). [TalentID] " + IntToString(GetIdFromTalent(tChosenTalent)) + " [Target] " + GetName(oTarget)
    DebugActionSpeakByInt(18, oTarget, GetIdFromTalent(tChosenTalent));
    // Moved Equip best shield in here
    AI_EquipBestShield();
    ActionUseTalentOnObject(tChosenTalent, oTarget);
}
/*::///////////////////////////////////////////////
//:: Name: AI_ActionHealObject
//::///////////////////////////////////////////////
 This will heal oTarget using the best spell it can, even ones it can
 spontaeously cast.
 - Just does best spell.
 - May use spontaneous ones as well. :-)
 - Called from AI_AttemptHealing_Self and AI_AttemptHealing_Ally
//::///////////////////////////////////////////////
//:: Created By: Jasperre
//::////////////////////////////////////////////*/
int AI_ActionHealObject(object oTarget, int bPotionsValid = FALSE)
{
    // Set healing talents
    talent tAOEHealing, tTouchHealing, tPotionHealing;
    // These are left at 0 if we have no SpawnInCondition setting them.
    int nAOEHealingValue, nTouchHealingValue, nPotionValue;

    // We set up OnSpawn if any of the 3 talents are valid
    tAOEHealing = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_HEALING_AREAEFFECT, 20);
    nAOEHealingValue = GetIdFromTalent(tAOEHealing);

    // Touch healing (Cure XXX wounds, Heal...)
    tTouchHealing = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_HEALING_TOUCH, 20);
    nTouchHealingValue = GetIdFromTalent(tTouchHealing);

    // First, we check for heal spells in the talents we have. They are special cases!
    int nTargetCurrentHP, nTargetMaxHP, nTargetPercentHP, bTargetSelf;
    // If the target is ourselves...
    if(oTarget == OBJECT_SELF)
    {
        nTargetCurrentHP = GlobalOurCurrentHP;
        nTargetMaxHP = GlobalOurMaxHP;
        nTargetPercentHP = GlobalOurPercentHP;
        bTargetSelf = TRUE;
        // We might use potions
        if(bPotionsValid == TRUE)
        {
            tPotionHealing = GetCreatureTalentBest(TALENT_CATEGORY_BENEFICIAL_HEALING_POTION, 20);
            nPotionValue = GetIdFromTalent(tPotionHealing);
        }
    }
    // Something else
    else
    {
        // If not us, we don't know HP values.
        nTargetCurrentHP = GetCurrentHitPoints(oTarget);
        nTargetMaxHP = GetMaxHitPoints(oTarget);
        // Percent = Current/Max * 100
        nTargetPercentHP = AI_GetPercentOf(nTargetCurrentHP, nTargetMaxHP);
        bTargetSelf = FALSE;
    }

    // Check for heal amounts, oTarget might have to be X damaged.
    // - If we have someone using knockdown on us, we make SURE we cast it sooner
    if(nTargetCurrentHP < 25 || nTargetPercentHP < 30 ||
        // High damage at once for target (over 40)
      (GetLocalInt(oTarget, AI_INTEGER + AI_HIGHEST_DAMAGE_AMOUNT) > 40 && nTargetPercentHP < 40) ||
        // Had knockdown used on us lately - we'll heal allies sooner if this is
        // the case too!
      (GetLocalTimer(AI_TIMER_KNOCKDOWN) &&
      (nTargetCurrentHP < 40 || nTargetPercentHP < 40)))
    {
        // If we have heal, we will use it now.
        // * Potion, then Touch, then Mass heal.
        if(bPotionsValid && nPotionValue == SPELL_HEAL)
        {
            // Potion spell
            AI_ActionUseTalentDebug(tPotionHealing, OBJECT_SELF);
            return TRUE;
        }
        else if(nTouchHealingValue == SPELL_HEAL)
        {
            // Touch heal spell
            AI_ActionUseTalentDebug(tTouchHealing, oTarget);
            return TRUE;
        }
        else if(nAOEHealingValue == SPELL_MASS_HEAL)
        {
            // Mass heal spell
            AI_ActionUseTalentDebug(tAOEHealing, oTarget);
            return TRUE;
        }
    }
    // Else, another talent - IE critical wounds and under.
    int nSponteousHealingValue = AI_GetBestSpontaeousHealingSpell();

    // Are any of them valid?
    if(nSponteousHealingValue >= 1 ||
       nAOEHealingValue >= 1 || nTouchHealingValue >= 1 || nPotionValue >= 1)
    {
        // We must work out the rank of each thing we can use, IE 10 best,
        // 1 worst or whatever :-D
        int nSpontaeousRank, nPotionRank, nAOERank, nTouchRank, nRank,
            nDamageNeededToBeDone, nRankOfSpell, // nRank must be 0, which it starts at.
        // Spontaeous or a talent? 1 = Talent, 2 = Spontaeous, 0 = Error/none
            nTalentOrSpon;
        // What talent should we use?
        talent tToUse;

        // Set the healing ranks.
        nSpontaeousRank = AI_GetHealingSpellRank(nSponteousHealingValue, bTargetSelf);
        nAOERank = AI_GetHealingSpellRank(nAOEHealingValue, bTargetSelf);
        nTouchRank = AI_GetHealingSpellRank(nTouchHealingValue, bTargetSelf);
        nPotionRank = AI_GetHealingSpellRank(nPotionValue, bTargetSelf);

        // Need a valid rank - we COULD get healing feats with these talents
        if(nAOERank >= 1 || nAOERank >= 1 || nPotionRank >= 1 || nSpontaeousRank >= 1)
        {
            // Determine what to use...
            // 1.4 - Cleaned this up. Less lines.
            // A Potion? We like these...a lot. No concentration checks!
            if(bPotionsValid && nPotionRank >= nAOERank &&
               nPotionRank >= nSpontaeousRank && nPotionRank >= nTouchRank)
            {
                // 1 = Talent
                nTalentOrSpon = 1;
                // Use a potion, so get the potion information
                tToUse = tPotionHealing;
                nRank = nPotionRank;
                nDamageNeededToBeDone = AI_GetHealingSpellPower(nPotionValue);
            }
            // Test touch rank
            else if(nTouchRank >= nAOERank && nTouchRank >= nSpontaeousRank)
            {
                // 1 = Talent
                nTalentOrSpon = 1;
                // Use a touch healing spell
                tToUse = tTouchHealing;
                nRank = nTouchRank;
                nDamageNeededToBeDone = AI_GetHealingSpellPower(nTouchHealingValue);
            }
            // Test AOE rank
            else if(nAOERank >= nSpontaeousRank)
            {
                // 1 = Talent
                nTalentOrSpon = 1;
                // Use a AOE healing spell
                tToUse = tAOEHealing;
                nRank = nPotionRank;
                nDamageNeededToBeDone = AI_GetHealingSpellPower(nAOEHealingValue);
            }
            else if(nSpontaeousRank >= 1)
            {
                // 2 = Spontaeous
                nTalentOrSpon = 2;
                // Use a spontaeous healing spell
                nRank = nSpontaeousRank;
                nDamageNeededToBeDone = AI_GetHealingSpellPower(nSponteousHealingValue);
            }
            // Now, have we a talent or spell to use?
            if(nTalentOrSpon >= 1 && nRank >= 1)
            {
                // If the current HP is under the damage that is healed,
                // or under 25% left :-)
                if(nTargetCurrentHP <= (nTargetMaxHP - nDamageNeededToBeDone) ||
                  (nTargetPercentHP < 25))
                {
                    // Level check. Our HD must be a suitble amount, or no melee attackers.
                    // Even if we are healing others - we don't bother with bad healing

                    // Rank of the spell, can be in a range over our HD -5.
                    if(((nRank - GlobalOurHitDice) >= -5) ||
                        // OR Rank of 16+ (critical wounds or more) are always done.
                        (nRank >= 16) ||
                        // OR no valid nearest enemy.
                        (!GlobalAnyValidTargetObject) ||
                        // OR 0 Melee attackers, and a larger range (up to -10 our HD)
                        ((GlobalMeleeAttackers < 1) && ((nRank - GlobalOurHitDice) >= -10)))
                    {
                        // Use it...and attack with a bow. Always return TRUE.
                        // Need only one debug :-P
                        // 19: "[DCR:Healing] (Should) Healing [Target]" + GetName(oTarget) + " [CurrentHP|Max|ID|Rank|Power] " + IntToString((10000 * nTargetCurrentHP) + (1000 * nTargetMaxHP) + (100 * GetIdFromTalent(tToUse)) + (10 * iRank) + (nDamageNeededToBeDone))
                        DebugActionSpeakByInt(19, oTarget, ((10000 * nTargetCurrentHP) + (1000 * nTargetMaxHP) + (100 * GetIdFromTalent(tToUse)) + (10 * nRank) + (nDamageNeededToBeDone)));

                        // Talent!
                        if(nTalentOrSpon == 1)
                        {
                            if(GetIsTalentValid(tToUse))
                            {
                                AI_EquipBestShield();
                                // No AI_ActionUseTalentDebug, just normal. Debug string above.
                                DeleteLocalInt(OBJECT_SELF, AI_SPONTAEUOUSLY_CAST_HEALING);
                                ActionUseTalentOnObject(tToUse, oTarget);
                                return TRUE;
                            }
                        }
                        // Spontaeous Spell!
                        else //if(nTalentOrSpon == 2) // (is always 2 or 1 or 0)
                        {
                            // Use the same thing as the inflict spell
                            if(AI_ActionCastSpontaeousSpell(nSponteousHealingValue, oTarget)) return TRUE;
                        }
                    }
                }
            }
        }
        // Else, no healing is valid...ranks, ETC.
        else
        // Check if it is us and so on.
        // If it is us, and we have no potion spell,
        if(oTarget == OBJECT_SELF &&
           GlobalOurPercentHP < 40 && !nPotionRank &&
           GetSpawnInCondition(AI_FLAG_OTHER_CHEAT_MORE_POTIONS, AI_OTHER_MASTER))
        {
            if(!GetIsObjectValid(GetItemPossessedBy(OBJECT_SELF, "nw_it_mpotion003")))
            {
                // 20: "[DCR Healing] Boss Action, create Critical Wounds potion"
                DebugActionSpeakByInt(20);
                // 1.4 - This is now made undroppable, so will not be looted.
                object oPotion = CreateItemOnObject("nw_it_mpotion003");
                SetDroppableFlag(oPotion, FALSE);
            }
        }
    }
    return FALSE;
}
/*::///////////////////////////////////////////////
//:: Name: AI_ActionHealUndeadObject
//::///////////////////////////////////////////////
 This will heal oTarget using the best negative energy spell it can use,
 - Used best spell (including harm, ETC)
//::///////////////////////////////////////////////
//:: Created By: Jasperre
//:://///////////////////////////////////////////*/
int AI_ActionHealUndeadObject(object oTarget)
{
    // First, we check for heal spells in the talents we have. They are special cases!
    int nTargetCurrentHP, nTargetMaxHP, nTargetPercentHP;
    // Test if we are targeting ourselves.
    if(oTarget == OBJECT_SELF)
    {
        // We set this to the right value if the target is us.
        nTargetCurrentHP = GlobalOurCurrentHP;
        nTargetMaxHP = GlobalOurMaxHP;
        nTargetPercentHP = GlobalOurPercentHP;
    }
    else
    {
        // If not us, we don't know HP values.
        nTargetCurrentHP = GetCurrentHitPoints(oTarget);
        nTargetMaxHP = GetMaxHitPoints(oTarget);
        // Percent = Current/Max * 100
        nTargetPercentHP = AI_GetPercentOf(nTargetCurrentHP, nTargetMaxHP);
    }
    // Check for Harm amounts, oTarget might have to be X damaged.
    if(nTargetCurrentHP < 25 || nTargetPercentHP < 30 ||
        // High damage at once for target (over 40)
      (GetLocalInt(oTarget, AI_INTEGER + AI_HIGHEST_DAMAGE_AMOUNT) > 40 && nTargetPercentHP < 40) ||
        // Had knockdown used on us lately
      (GetLocalTimer(AI_TIMER_KNOCKDOWN) &&
      (nTargetCurrentHP < 40 || nTargetPercentHP < 40)))
    {
        // If us, use harm self
        if(oTarget == OBJECT_SELF)
        {
            // Innate ability. Under healing self, so leave as innate.
            if(AI_ActionCastSpell(AI_SPELLABILITY_UNDEAD_HARM_SELF, oTarget)) return TRUE;
        }
        // Use it...if we have it. Healing with harm rocks!
        if(AI_ActionCastSpell(SPELL_HARM, oTarget, 16, FALSE)) return TRUE;
    }
    // Other Under things!
    // Inflict range...always use top 2.
    if(AI_ActionCastSpontaeousSpell(SPELL_INFLICT_CRITICAL_WOUNDS, oTarget)) return TRUE;
    if(AI_ActionCastSpontaeousSpell(SPELL_INFLICT_SERIOUS_WOUNDS, oTarget)) return TRUE;
    // Circle of doom: d8 + Caster level heal. Category 1.
    if(AI_ActionCastSpell(SPELL_CIRCLE_OF_DEATH, oTarget, 15, TRUE)) return TRUE;
    // Negative Energy Burst...this is good enough to always use normally...same as Circle of doom! (d8 + caster)
    if(AI_ActionCastSpell(SPELL_NEGATIVE_ENERGY_BURST, oTarget, 13, TRUE)) return TRUE;
    // Lower ones ain't too good for some HD (ours!)
    if(!GlobalAnyValidTargetObject || GlobalOurHitDice <= 12)
    {
        if(AI_ActionCastSpontaeousSpell(SPELL_INFLICT_MODERATE_WOUNDS, oTarget)) return TRUE;
        if(!GlobalAnyValidTargetObject || GlobalOurHitDice <= 6)
        {
            if(AI_ActionCastSpontaeousSpell(SPELL_INFLICT_LIGHT_WOUNDS, oTarget)) return TRUE;
            if(!GlobalAnyValidTargetObject || GlobalOurHitDice <= 2)
            {
                if(AI_ActionCastSpontaeousSpell(SPELL_INFLICT_MINOR_WOUNDS, oTarget)) return TRUE;
            }
        }
    }
    // No undead healing cast
    return FALSE;
}
/*::///////////////////////////////////////////////
//:: Name: TalentHealingSelf
//::///////////////////////////////////////////////
    Uses the best it can.
    1. If it is heal, they need to be under half HP and under 40 HP
    2. If not, it has to be under half HP and not be heal/mass heal
    3. Testing to see if harm will be cast by undead

    1.3 changes: A few bug fixes...not sure what was wrong before.
//::///////////////////////////////////////////////
//:: Created By: Jasperre
//:://///////////////////////////////////////////*/
int AI_AttemptHealingSelf()
{
    // Flag for "Do not heal anyone". Useful also for stopping non-healers
    // even checking.
    if(GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_CURING, AI_OTHER_COMBAT_MASTER)) return FALSE;

    // If we are polymorphed, cannot heal anyone - thats cheating. Using our
    // class feats we shouldn't have access to also isn't a nice idea.
    if(AI_GetAIHaveEffect(GlobalEffectPolymorph)) return FALSE;

    // Determine what we should heal at...
    int nPercent = GetBoundriedAIInteger(AI_HEALING_US_PERCENT, 50, 100, 1);
    int nRace = GetRacialType(OBJECT_SELF);

    // What % are we at? It is GlobalOurPercentHP
    // Are we under the right %?
    if(GlobalOurPercentHP <= nPercent)
    {
        // We can't be a silly race!
        if(nRace != RACIAL_TYPE_UNDEAD &&
           nRace != RACIAL_TYPE_CONSTRUCT)
        {
            int nWillHeal;
            // If we can heal self with feats...use them! No AOO
            if(GetHasFeat(FEAT_WHOLENESS_OF_BODY) &&
              ((GlobalOurCurrentHP <= GetLevelByClass(CLASS_TYPE_MONK, OBJECT_SELF) * 2) ||
                GlobalOurPercentHP < 20))
            {
                if(AI_ActionUseSpellLikeFeat(FEAT_WHOLENESS_OF_BODY, SPELLABILITY_WHOLENESS_OF_BODY)) return TRUE;
            }
            // Only use this on ourselves.
            if(GetHasFeat(FEAT_LAY_ON_HANDS))
            {
                // This does the actual formula...note, putting ones to stop DIVIDE BY ZERO errors
                int nChr = GetAbilityModifier(ABILITY_CHARISMA);
                if(nChr < 1) nChr = 1;// Error checking
                int nLevel = GetLevelByClass(CLASS_TYPE_PALADIN);
                if(nLevel < 1) nLevel = 1;// Error checking
                //Caluclate the amount needed to be at, to use.
                int nHeal = nLevel * nChr;
                if(nHeal < 1) nHeal = 1;// Error checking
                // We can be under the amount healed, or under 30
                if(GlobalOurCurrentHP < nHeal ||
                   GlobalOurPercentHP < 30)
                {
                    if(AI_ActionUseSpellLikeFeat(FEAT_LAY_ON_HANDS, SPELLABILITY_LAY_ON_HANDS)) return TRUE;
                }
            }
            // Note: Feat Lesser Bodily Adjustment uses cure light wounds spell script.
            // Odd classes mean no potions.
            int bPotions = TRUE;
            if(nRace == RACIAL_TYPE_ABERRATION ||
               nRace == RACIAL_TYPE_BEAST || nRace == RACIAL_TYPE_ELEMENTAL ||
               nRace == RACIAL_TYPE_VERMIN || nRace == RACIAL_TYPE_MAGICAL_BEAST ||
               nRace == RACIAL_TYPE_DRAGON || nRace == RACIAL_TYPE_ANIMAL)
                bPotions = FALSE;

            // Lets see if we can use a healing kit! Only a valid race (as potions)
            if(bPotions && GetAIInteger(AI_VALID_HEALING_KITS) &&
              !GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_USING_HEALING_KITS, AI_OTHER_COMBAT_MASTER))
            {
                // Healing Kits
                int nHealLeft = GetAIInteger(AI_VALID_HEALING_KITS);
                object oKit;
                // We have a healing kit?
                if(nHealLeft > 0)
                {
                    // Get the kit
                    object oKit = GetAIObject(AI_VALID_HEALING_KIT_OBJECT);
                    // Oh, if we don't have one, re-set them, and only them.
                    if(!GetIsObjectValid(oKit) && nHealLeft >= 2)
                    {
                        SetAIInteger(RESET_HEALING_KITS, TRUE);
                        //ExecuteScript(FILE_RE_SET_WEAPONS, OBJECT_SELF);
                    }
                    // Need a valid kit and skill to be worth using :-)
                    if((GetSkillRank(SKILL_HEAL) >= (GlobalOurHitDice / 3) ||
                        GlobalOurPercentHP < 30))
                    {
                        AI_EquipBestShield();
                        // 21: "[DCR:Casting] Healing self with healing kit, [Kit] " + GetName(oKit)
                        DebugActionSpeakByInt(21, oKit);
                        ActionUseSkill(SKILL_HEAL, OBJECT_SELF, 0, oKit);
                        return TRUE;
                    }
                }
            }
            // Finally, heal self with potions, spells or whatever.
            return AI_ActionHealObject(OBJECT_SELF, bPotions);
        }
        else if(nRace == RACIAL_TYPE_UNDEAD)
        {
            // Undead can cast some spells to heal...
            return AI_ActionHealUndeadObject(OBJECT_SELF);
        }
    }
    return FALSE;
}
/*::///////////////////////////////////////////////
//:: Name: TalentCureCondition
//::///////////////////////////////////////////////
    Uses spells to cure conditions. Needs to be checked fully
    - Uses allies own integers to check thier effects
    - Loops spells (Best => worst) and if we havn't cast it in an amount of time
        we check effects (Us, leader, allies seen) until we find someone (nearest)
        who we can cast it on.
//::///////////////////////////////////////////////
//:: Created By: Jasperre
//::////////////////////////////////////////////*/
int AI_AttemptCureCondition()
{
    // Set OnSpawn if we have any of the spells we use.
    if(/*!GetSpawnInCondition(AI_VALID_CURE_CONDITION_SPELLS, AI_VALID_SPELLS) ||*/
        GetSpawnInCondition(AI_FLAG_OTHER_LAG_NO_CURING_ALLIES, AI_OTHER_MASTER) ||
        GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_CURING, AI_OTHER_COMBAT_MASTER)) return FALSE;

    // If we are polymorphed, cannot heal anyone - thats cheating. Using our
    // class feats we shouldn't have access to also isn't a nice idea.
    if(AI_GetAIHaveEffect(GlobalEffectPolymorph)) return FALSE;

    // Check timer
    if(GetLocalTimer(AI_TIMER_CURE_CONDITION)) return FALSE;

    int nTimer = GetAIInteger(SECONDS_BETWEEN_STATUS_CHECKS);
    if(nTimer >= 1)
    {
        // Set timer
        SetLocalTimer(AI_TIMER_CURE_CONDITION, IntToFloat(nTimer));
    }

    // Cure spells:
    // SPELL_GREATER_RESTORATION - Ability Decrease, AC decrease, Attack decrease,
    //  Damage Decrease, Damage Immunity Decrease, Saving Throw Decrease,
    //  Spell resistance Decrease, Skill decrease, Blindness, Deaf, Curse, Disease,
    //  Poison, Charmed, Dominated, Dazed, Confused, Frightened, Negative level,
    //  Paralyze, Slow, Stunned.
    // SPELL_RESTORATION - Ability Decrease, AC decrease, Attack Decrease,
    //  Damage Decrease, Damage Immunity Decrease, Saving Throw Decrease,
    //  Spell Resistance Decrease, Skill Decrease, Blindess, Deaf, Paralyze, Negative level
    // SPELL_LESSER_RESTORATION - Ability Decrease, AC decrease, Attack Decrease,
    //  Damage Decrease, Damage Immunity Decrease, Saving throw Decrease,
    //  Spell Resistance Decrease, Skill decrease.
    // - More Specific ones.
    // SPELL_FREEDOM - Paralyze, Entangle, Slow, Movement speed decrease. (+Immunity!)
    // SPELL_REMOVE_BLINDNESS_AND_DEAFNESS - Blindess, Deaf.
    // SPELL_NEUTRALIZE_POISON - Poison
    // SPELL_REMOVE_DISEASE - Disease
    // SPELL_REMOVE_CURSE - Curse

    // Note: We like to dispel anything that stuns us - EG paralyze effects,
    // stunning, confusion, dazedness VIA Greater Restoration, after that,
    // blindness (A great inhibiter) and then poison disease and curse.

    // Check seen allies in 20M
    // Work in a loop of all creatures to check the loop only once.

    // To prioritise (IE: Ignore our poison, but heal someone who is petrified)
    // we loop all targets, and set them to variable objects for this function.
    int bPetrify, bParalsis, bDazed, bBlind, bNegative, nAbilityDamage,
        bSlow, bEntangle,/* Set bEntangle to  bSpeedDecrease too */ bDeaf,
        bCurse, bDisease, bPoison, bFear, bStun;
    // Objects which have those effects
    object oPetrify, oParalsis, oDazed, oBlind, oNegative, oAbilityDamage,
        oSlow, oEntangle,/* Set oEntangle to oSpeedDecrease too */ oDeaf,
        oCurse, oDisease, oPoison, oFear, oStun;

    // THOUGHTS:

    // Perhaps have heal self, then check very bad conditoins (paralysis, petrify)
    // unless a really damaged ally is nearby, then heal, then remove the not so
    // bad effects.

    // However, start with us!
    int nCnt = 0;// When we add 1, we'll get the first target.
    int nEffectHex, nAbility;
    object oHeal = OBJECT_SELF;
    while(GetIsObjectValid(oHeal) && GetDistanceToObject(oHeal) <= 20.0)
    {
        // Don't target undead
        if(GetRacialType(oHeal) != RACIAL_TYPE_UNDEAD)
        {
            // Go through possible effects in priority order.
            nEffectHex = GetLocalInt(oHeal, AI_EFFECT_HEX);
            if(bPetrify != TRUE && (nEffectHex & GlobalEffectPetrify))
            {
                oPetrify = oHeal;
                bPetrify = TRUE;
            }
            // Paralsis
            if(bParalsis != TRUE && (nEffectHex & GlobalEffectParalyze))
            {
                oParalsis = oHeal;
                bParalsis = TRUE;
            }
            // Stun
            if(bStun != TRUE && (nEffectHex & GlobalEffectStun))
            {
                oStun = oHeal;
                bStun = TRUE;
            }
            // Fear
            if(bFear != TRUE && (nEffectHex & GlobalEffectFear))
            {
                oFear = oHeal;
                bFear = TRUE;
            }
            // Dazed
            if(bDazed != TRUE && (nEffectHex & GlobalEffectDazed))
            {
                oDazed = oHeal;
                bDazed = TRUE;
            }
            // Blindness
            if(bBlind != TRUE && (nEffectHex & GlobalEffectBlindness))
            {
                oBlind = oHeal;
                bBlind = TRUE;
            }
            // Negative level is tough
            if(bNegative != TRUE && (nEffectHex & GlobalEffectNegativeLevel))
            {
                oNegative = oHeal;
                bNegative = TRUE;
            }
            // Slow - only set if they are not hasted. It'd be a waste otherwise.
            if(bSlow != TRUE && (nEffectHex & GlobalEffectSlowed) &&
              !AI_GetAIHaveEffect(GlobalEffectHaste, oHeal))
            {
                oSlow = oHeal;
                bSlow = TRUE;
            }
            // Entangle OR movement slowed.
            if(bEntangle != TRUE && ((nEffectHex & GlobalEffectSlowed) ||
              (nEffectHex & GlobalEffectMovementSpeedDecrease)))
            {
                oEntangle = oHeal;
                bEntangle = TRUE;
            }
            // Deafness
            if(bDeaf != TRUE && (nEffectHex & GlobalEffectDeaf))
            {
                oDeaf = oHeal;
                bDeaf = TRUE;
            }
            // Curse
            if(bCurse != TRUE && (nEffectHex & GlobalEffectCurse))
            {
                oCurse = oHeal;
                bCurse = TRUE;
            }
            // Disease
            if(bDisease != TRUE && (nEffectHex & GlobalEffectDisease))
            {
                oDisease = oHeal;
                bDisease = TRUE;
            }
            // Poison
            if(bPoison != TRUE && (nEffectHex & GlobalEffectPoison))
            {
                oPoison = oHeal;
                bPoison = TRUE;
            }
            // Lots of negative effects.
            // Set all 3 here.

            // Returns the nearest ally with nMin effects, and X more based on HD.
            // - Checks us first. True if (HD/6) Effects and (nMin - 1) effects
            // - Checks leader next. True if (HD/5) Effects and (nMin - 2) effects
            // - Checks allies after. True if (HD/4) Effects and (nMin) effects
            nAbility = GetLocalInt(oHeal, AI_ABILITY_DECREASE);

            // Must have more ability decreases then the last one checked, and
            // more damage then a cirtain amount compared to the hit dice, or
            // at least 10.
            // A LOT more simple then before.
            if(nAbility > nAbilityDamage && nAbility >= 10 &&
               nAbility >= GetHitDice(oHeal) / 4)
            {
                nAbilityDamage = nAbility;
                oAbilityDamage = oHeal;
            }
        }
        // If we are blind, we cannot target others to heal them. We must only
        // target ourselves (if anyone!)
        if(AI_GetAIHaveEffect(GlobalEffectBlindness, OBJECT_SELF))
        {
            // Break.
            break;
        }
        // Carry on loop
        nCnt++;
        oHeal = GetLocalObject(OBJECT_SELF, ARRAY_ALLIES_RANGE_SEEN + IntToString(nCnt));
    }


    // Lastly, ability damage ETC can come in after the stuns, or right at
    // the end, depending on the amount.

    // Petrify - remove it first.
    if(bPetrify)
    {
        // Only one
        if(AI_ActionCastSpell(SPELL_STONE_TO_FLESH, oPetrify)) return TRUE;
    }
    // First, Paralysis should be removed (Includes stunning)
    if(bParalsis)
    {
        // Freedom first
        if(AI_ActionCastSpell(SPELL_FREEDOM_OF_MOVEMENT, oParalsis)) return TRUE;
        if(AI_ActionCastSpell(SPELL_GREATER_RESTORATION, oParalsis)) return TRUE;
    }
    // Stun - only G.Restoration removes this.
    if(bStun)
    {
        if(AI_ActionCastSpell(SPELL_GREATER_RESTORATION, oStun)) return TRUE;
    }
    // Daze
    if(bDazed)
    {
        // Freedom first
        if(AI_ActionCastSpell(SPELL_FREEDOM_OF_MOVEMENT, oDazed)) return TRUE;
        if(AI_ActionCastSpell(SPELL_GREATER_RESTORATION, oDazed)) return TRUE;
    }
    // Fear
    if(bFear)
    {
        // Freedom first
        if(AI_ActionCastSpell(SPELL_REMOVE_FEAR, oFear)) return TRUE;
        if(AI_ActionCastSpell(SPELL_GREATER_RESTORATION, oFear)) return TRUE;
    }
    // Next? blindness
    if(bBlind)
    {
        // Remove first
        if(AI_ActionCastSpell(SPELL_REMOVE_BLINDNESS_AND_DEAFNESS, oBlind)) return TRUE;
        if(AI_ActionCastSpell(SPELL_FREEDOM_OF_MOVEMENT, oBlind)) return TRUE;
        if(AI_ActionCastSpell(SPELL_RESTORATION, oBlind)) return TRUE;
        if(AI_ActionCastSpell(AI_SPELLABILITY_RESTORATION_OTHERS, oBlind)) return TRUE;
        if(AI_ActionCastSpell(SPELL_GREATER_RESTORATION, oBlind)) return TRUE;
    }
    // Lots of negative effects.
    if(nAbilityDamage >= 7)
    {
        // Only these can remove ability decreases ETC.
        if(AI_ActionCastSpell(SPELL_LESSER_RESTORATION, oAbilityDamage)) return TRUE;
        if(AI_ActionCastSpell(SPELL_RESTORATION, oAbilityDamage)) return TRUE;
        if(AI_ActionCastSpell(AI_SPELLABILITY_RESTORATION_OTHERS, oAbilityDamage)) return TRUE;
        if(AI_ActionCastSpell(SPELL_GREATER_RESTORATION, oAbilityDamage)) return TRUE;
    }
    // Negative level is tough
    if(bNegative)
    {
        // Only these can remove it
        if(AI_ActionCastSpell(SPELL_RESTORATION, oNegative)) return TRUE;
        if(AI_ActionCastSpell(AI_SPELLABILITY_RESTORATION_OTHERS, oNegative)) return TRUE;
        if(AI_ActionCastSpell(SPELL_GREATER_RESTORATION, oNegative)) return TRUE;
    }
    // Slow
    if(bSlow)
    {
        // haste - we don't set we have this OnSpawn, because if we have not
        // got any other healing cure spells, we're probably not meant to cast it on slowed people.
        if(AI_ActionCastSpell(SPELL_MASS_HASTE, oSlow)) return TRUE;
        if(AI_ActionCastSpell(SPELL_HASTE, oSlow)) return TRUE;
    }
    // Heal things with freedom of movement/greater restoration
    if(bSlow)
    {
        oHeal = oSlow;
    }
    else if(bEntangle)
    {
        oHeal = oSlow;
    }
    // If got either, then oHeal will be the appropriate one to heal ith FoM
    if(bSlow || bEntangle)
    {
        // Freedom first
        if(AI_ActionCastSpell(SPELL_FREEDOM_OF_MOVEMENT, oHeal)) return TRUE;
        if(AI_ActionCastSpell(SPELL_GREATER_RESTORATION, oHeal)) return TRUE;
    }
    // Deafness
    if(bDeaf)
    {
        // Remove first
        if(AI_ActionCastSpell(SPELL_REMOVE_BLINDNESS_AND_DEAFNESS, oDeaf)) return TRUE;
        if(AI_ActionCastSpell(SPELL_FREEDOM_OF_MOVEMENT, oDeaf)) return TRUE;
        if(AI_ActionCastSpell(SPELL_RESTORATION, oDeaf)) return TRUE;
        if(AI_ActionCastSpell(AI_SPELLABILITY_RESTORATION_OTHERS, oDeaf)) return TRUE;
        if(AI_ActionCastSpell(SPELL_GREATER_RESTORATION, oDeaf)) return TRUE;
    }
    // Quite a few negative effects (5 or more)
    if(nAbilityDamage >= 5)
    {
        // Only these can remove ability decreases ETC.
        if(AI_ActionCastSpell(SPELL_LESSER_RESTORATION, oAbilityDamage)) return TRUE;
        if(AI_ActionCastSpell(SPELL_RESTORATION, oAbilityDamage)) return TRUE;
        if(AI_ActionCastSpell(AI_SPELLABILITY_RESTORATION_OTHERS, oBlind)) return TRUE;
        if(AI_ActionCastSpell(SPELL_GREATER_RESTORATION, oAbilityDamage)) return TRUE;
    }
    // Curse
    if(bCurse)
    {
        // Remove first
        if(AI_ActionCastSpell(SPELL_REMOVE_CURSE, oCurse)) return TRUE;
        if(AI_ActionCastSpell(SPELL_GREATER_RESTORATION, oCurse)) return TRUE;
    }
    // Disease
    if(bDisease)
    {
        // Remove first
        if(AI_ActionCastSpell(SPELL_REMOVE_DISEASE, oDisease)) return TRUE;
        if(AI_ActionCastSpell(SPELL_GREATER_RESTORATION, oDisease)) return TRUE;
    }
    // Poison
    if(bPoison)
    {
        // Remove first
        if(AI_ActionCastSpell(SPELL_NEUTRALIZE_POISON, oPoison)) return TRUE;
        if(AI_ActionCastSpell(SPELL_GREATER_RESTORATION, oPoison)) return TRUE;
    }
    // See if there is anyone with a decent amount of effects.
    // Some negative effects (3 or more)
    if(nAbilityDamage >= 3)
    {
        // Only these can remove ability decreases ETC.
        if(AI_ActionCastSpell(SPELL_LESSER_RESTORATION, oAbilityDamage)) return TRUE;
        if(AI_ActionCastSpell(SPELL_RESTORATION, oAbilityDamage)) return TRUE;
        if(AI_ActionCastSpell(AI_SPELLABILITY_RESTORATION_OTHERS, oAbilityDamage)) return TRUE;
        if(AI_ActionCastSpell(SPELL_GREATER_RESTORATION, oAbilityDamage)) return TRUE;
    }
    return FALSE;
}

/*::///////////////////////////////////////////////
//:: Name: TalentHeal
//::///////////////////////////////////////////////
  HEAL ALL ALLIES
    Only if they are in sight, and are under a percent%. Always nearest...
//::///////////////////////////////////////////////
//:: Created By: Jasperre
//::////////////////////////////////////////////*/
int AI_AttemptHealingAlly()
{
    // If we are polymorphed, cannot heal anyone - thats cheating. Using our
    // class feats we shouldn't have access to also isn't a nice idea.
    if(AI_GetAIHaveEffect(GlobalEffectPolymorph)) return FALSE;

    // leaders will alwys be the master
    object oMaster = GetMaster();

    // Are we able to raise allies?
    if(GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_WILL_RAISE_ALLIES_IN_BATTLE, AI_OTHER_COMBAT_MASTER))
    {

        // Leader - if dead, make sure we raise them!
        if(GetIsObjectValid(oMaster) &&
           GetIsDead(oMaster) &&
          !GetLocalInt(oMaster, AI_INTEGER + I_AM_TOTALLY_DEAD))
        {
            // Talent 7 - Conditional single.
            if(AI_ActionCastSpell(SPELL_RESURRECTION, oMaster, 17, FALSE)) return TRUE;
            if(AI_ActionCastSpell(SPELL_RAISE_DEAD, oMaster, 15, FALSE)) return TRUE;
        }
        // Get the nearest ally, seen, who is dead
        // - This can cause problems as no looping dead people, as there is a
        //   "totally dead" flag, used for bioware's lootable corpses.
        int nCnt = 1;
        object oDead = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, FALSE, OBJECT_SELF, nCnt, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
        // Loop the dead people we see (allied ones) if we test just one - it/
        // can go wrong.
        while(GetIsObjectValid(oDead))
        {
            if(GetIsObjectValid(oDead) && !GetIgnore(oDead) &&
              !GetLocalInt(oDead, AI_INTEGER + I_AM_TOTALLY_DEAD))
            {
                if(AI_ActionCastSpell(SPELL_RESURRECTION, oDead, 17, FALSE)) return TRUE;
                if(AI_ActionCastSpell(SPELL_RAISE_DEAD, oDead, 15, FALSE)) return TRUE;
            }
            // Get next dead seen ally
            nCnt++;
            oDead = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, FALSE, OBJECT_SELF, nCnt, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
        }
    }
    // Do we heal allies? Spawn toggles for this. Only cure self means we don't
    // target others at all.
    if(!GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_ONLY_CURE_SELF, AI_OTHER_COMBAT_MASTER) &&
       !GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_CURING, AI_OTHER_COMBAT_MASTER))
    {
        // We always heal leaders
        // - Might make % HP checks.

        //if(GlobalValidLeader)
        if (GetIsObjectValid(oMaster))
        {
            //if(AI_ActionHealObject(GlobalNearestLeader)) return TRUE;
            if(AI_ActionHealObject(oMaster)) return TRUE;
        }
        // Else we may heal a set ally
        else if(GlobalValidSeenAlly)
        {
            // We run through a loop, and get who we might heal ;-)
            int nNeedToBeAt = GetBoundriedAIInteger(AI_HEALING_ALLIES_PERCENT, 60, 100, 1);
            object oAllyToHeal, oLoopTarget;
            int nCnt, nPercentHitPoints, nChosenPercentHitPoints;
            float fDistance, fChosenLastDistance;
            // bSummonHeal will be TRUE to heal associates only if we have <= 3 allies in total
            int bSummonHeal = FALSE;
            if(GlobalTotalAllies <= 3)
            {
                bSummonHeal = TRUE;
            }
            fChosenLastDistance = 60.0;// So 1st target in health band gets picked
            nCnt = 1;
            oLoopTarget = GetLocalObject(OBJECT_SELF, ARRAY_ALLIES_RANGE_SEEN + IntToString(nCnt));
            while(GetIsObjectValid(oLoopTarget))
            {
                if(GetRacialType(oLoopTarget) != RACIAL_TYPE_CONSTRUCT &&
                  (GetAssociateType(oLoopTarget) == ASSOCIATE_TYPE_NONE || bSummonHeal == TRUE))
                {
                    // We do actually not ALWAYS use the nearest dead person, nor
                    // the most damaged in 20M or so. We use a mixture - the most
                    // damaged in a cirtain range.
                    nPercentHitPoints = AI_GetPercentOf(GetCurrentHitPoints(oLoopTarget), GetMaxHitPoints(oLoopTarget));
                    // Do we consider them needing healing?
                    if(nPercentHitPoints <= nNeedToBeAt)
                    {
                        // Distance to them - we may not just heal the nearest under 60%
                        fDistance = GetDistanceToObject(oLoopTarget);
                        if(fDistance < fChosenLastDistance ||
                          (fDistance < (fChosenLastDistance + 5.0) &&
                           nPercentHitPoints < nChosenPercentHitPoints - 10))
                        {
                            oAllyToHeal = oLoopTarget;
                            fChosenLastDistance = fDistance;
                            nChosenPercentHitPoints = nPercentHitPoints;
                        }
                    }
                }
                nCnt++;
                oLoopTarget = GetLocalObject(OBJECT_SELF, ARRAY_ALLIES_RANGE_SEEN + IntToString(nCnt));
            }
            // Did we find someone to heal?
            if(nChosenPercentHitPoints > 0)
            {
                int nAllyHealRace = GetRacialType(oAllyToHeal);
                // Undead - negative energy heals!
                if(nAllyHealRace == RACIAL_TYPE_UNDEAD)
                {
                    // Stop now whatever, true or false.
                    return AI_ActionHealUndeadObject(oAllyToHeal);
                }
                else //if(nAllyHealRace != RACIAL_TYPE_CONSTRUCT) // Checked earlier
                {
                    if(AI_ActionHealObject(oAllyToHeal))
                    {
                        return TRUE;
                    }
                    // This will, if they have any (Standard ones! unless you add them in)
                    // healing potions, they will, if close and no cleric, pass them to
                    // people who need them. It uses ActionGiveItem so may move to target.
                    // There are extra speakstrings for these events.

                    // potion passing code removed - pok
                }
            }
        }
    }
    return FALSE;
}

/*::///////////////////////////////////////////////
//:: Name: DoSummonFamiliar
//::///////////////////////////////////////////////
    This will, if it can, summon a familiar, or
    animal companion, and if set to want to.
//::///////////////////////////////////////////////
//:: Created By: Jasperre
//::////////////////////////////////////////////*/
int AI_AttemptFeatSummonFamiliar()
{
    if(GetSpawnInCondition(AI_FLAG_COMBAT_SUMMON_FAMILIAR, AI_COMBAT_MASTER))
    {
        // Summon our familiar (Bat) first.
        if(!GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_FAMILIAR)))
        {
            // We use the new function. We use the spellability, as to not
            // cause any errors (hopefully)
            if(AI_ActionUseSpellLikeFeat(FEAT_SUMMON_FAMILIAR, SPELLABILITY_SUMMON_FAMILIAR))
            {
                // 22: "[DCR:Feat] Summoning my familiar"
                DebugActionSpeakByInt(22);
                return TRUE;
            }
        }
        // Else, check for our companion (Badger)
        else if(!GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION)))
        {
            // Same as above for Summoning my Animal Companion.
            if(AI_ActionUseSpellLikeFeat(FEAT_ANIMAL_COMPANION, SPELLABILITY_SUMMON_ANIMAL_COMPANION))
            {
                // 23: "[DCR:Feat] Summoning my animal companion"
                DebugActionSpeakByInt(23);
                return TRUE;
            }
        }
    }
    return FALSE;
}
// Morale Flee removed - pok

/*::///////////////////////////////////////////////
//:: Name: GoForTheKill
//::///////////////////////////////////////////////
    Very basic at the moment. This will, if thier inteligence is
    high and they can be hit relitivly easily, and at low HP
    will attack in combat. May add some spells, if I can be bothered.
//::///////////////////////////////////////////////
//:: Created By: Jasperre
//::////////////////////////////////////////////*/
int AI_AttemptGoForTheKill()
{
    // Turn off script
    if(GetSpawnInCondition(AI_FLAG_COMBAT_NO_GO_FOR_THE_KILL, AI_COMBAT_MASTER) ||
       GlobalIntelligence <= 8)
    {
        return FALSE;
    }

    // Finish off a dead PC, or dying one, out of combat.
    // modifed to use party target
    // the better alternative would be to use party target, but filter to lowest HP - pok
    object oTempEnemy = GetClosestPartyTarget();
    int bSleepingOnly = TRUE;
   if(!GetIsObjectValid(oTempEnemy) || AI_GetAIHaveEffect(GlobalEffectPetrify, oTempEnemy))
    {
        // This means we only attack in melee (no spells, no ranged)
        bSleepingOnly = TRUE;
        oTempEnemy = GetNearestCreature(
                     CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY,
                     OBJECT_SELF, 1,
                     CREATURE_TYPE_HAS_SPELL_EFFECT, SPELL_SLEEP,
                     CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
        // Dragon sleep breath
        if(!GetIsObjectValid(oTempEnemy) || GetHitDice(oTempEnemy) > 4 ||
            AI_GetAIHaveEffect(GlobalEffectPetrify, oTempEnemy))
        {
            oTempEnemy = GetNearestCreature(
                     CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY,
                     OBJECT_SELF, 1,
                     CREATURE_TYPE_HAS_SPELL_EFFECT, SPELLABILITY_DRAGON_BREATH_SLEEP,
                     CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
            // Could add something about Paralyzed people here...
        }
    }
    float fDistance = GetDistanceToObject(oTempEnemy);
     // Valid, and is not "dead dead"
    if(GetIsObjectValid(oTempEnemy) &&
    // -10 is TOTALLY dead.
       GetCurrentHitPoints(oTempEnemy) > -10 &&
     // Intelligence 9+. 10 will attack with many enemies, 9 with 1 or under
     ((GlobalMeleeAttackers <= 3 &&
       GlobalIntelligence >= 10) ||
       GlobalMeleeAttackers <= 1) &&
     // Make sure it isn't too far, and they are only sleeping
      (bSleepingOnly == FALSE ||
       fDistance < 6.0) &&
     // Big AC check, but mages with +1, VS ac of 30 won't hit :-)
       GlobalOurBaseAttackBonus >= GetAC(oTempEnemy) - 25)
    {
        // 26: "[DCR:GFTK] Attacking a PC who is dying/asleep! [Enemy]" + GetName(oTempEnemy)
        DebugActionSpeakByInt(26, oTempEnemy);
        // Attempt default most damaging to try and do most damage.
        if(fDistance > GlobalRangeToMeleeTarget)
        {
            ActionEquipMostDamagingRanged(oTempEnemy);
        }
        else
        {
            ActionEquipMostDamagingMelee(oTempEnemy);
        }
        ActionAttack(oTempEnemy);
        return TRUE;
    }

    // Now, we check for most damaged member of the nearest enemies faction.
    // - Uses bioware function - just...simpler
    // - Only with 9+ int
    oTempEnemy = GetFactionMostDamagedMember(GlobalMeleeTarget);
    // - Effect, if lots of people can attack this, like with ranged things,
    //   it can lead to some bloody deaths, especially for some classes.
    // - Note: Intelligence of 9+ shouldn't be used for low levels!
    if(GetIsObjectValid(oTempEnemy))
    {
        // From 1-6, or 1-10 HP they need.
        int nHP = GetCurrentHitPoints(oTempEnemy);
        int nBeBelow = 6 + Random(4);
        int bHTH = FALSE;// TRUE = melee
        fDistance = GetDistanceToObject(oTempEnemy);
        // If in melee range, we set to melee, and add stength to what we can knock off!
        if(fDistance <= 4.0)
        {
            bHTH = TRUE;
            nBeBelow += GetAbilityModifier(ABILITY_STRENGTH);
        }
        // Check...
        if(GetCurrentHitPoints(oTempEnemy) <= nBeBelow &&
           GetMaxHitPoints(oTempEnemy) >= 20)
        {
            // We also need to check if we can hit them to kill them!
            // - Either high BAB against thier AC (take roll as 15+)
            if(GlobalOurBaseAttackBonus >= GetAC(oTempEnemy) - 15 ||
            // - or it is 0.75 of our hit dice (IE cleric or better).
               GlobalOurBaseAttackBonus >= ((GetHitDice(oTempEnemy) * 3) / 2))
            {
                if(bHTH)
                {
                    ActionEquipMostDamagingMelee(oTempEnemy);
                }
                // We take a big risk here... we equip a ranged (default call)
                // not how good it is, things in the way, or
                // if we don't have ammo or even have it!
                // - EquipsMelee Anyway.
                // - Still needs to be valid, else we do normal actions.
                else if(GetIsObjectValid(GetAIObject(AI_WEAPON_RANGED)))
                {
                    ActionEquipMostDamagingRanged(oTempEnemy);
                }
                else // If we have no ranged wepaon, ignore this.
                {
                    return FALSE;
                }
                ActionAttack(oTempEnemy);
                return TRUE;
            }
            // Else, we do spells! Just a few...
            else
            {
                // This stops us being unprotected, as there may be melee attackers.
                if(!bHTH || GlobalMeleeAttackers < 3)
                {
                    // Spells are done with little consideration for immunities.
                    // - Saves power, and shows fury to knock out.
                    // - All auto-hit, no-save spells.
                    // - No items.
                    // - Checks immunity level, incase of globes.
                    int nImmuneLevel = AI_GetSpellLevelEffect(oTempEnemy);

                    // Isaacs storms are long range beasts!
                    // Greater Missile Storm. Level 6 (Wizard). 2d6 * Caster level dice up to 20, divided between targets.
                    if(AI_ActionCastSpell(SPELL_ISAACS_GREATER_MISSILE_STORM, oTempEnemy, 16)) return TRUE;

                    if(nImmuneLevel < 4)
                    {
                        // Lesser Missile Storm. Level 4 (Wizard). 1d6 * Caster level dice up to 10, divided between targets.
                        if(AI_ActionCastSpell(SPELL_ISAACS_LESSER_MISSILE_STORM, oTempEnemy, 14)) return TRUE;

                        if(nImmuneLevel < 3)
                        {
                            // Searing light. Level 3 (Cleric). Full level: 1-10d6 VS undead. Half Level: 1-5d6 VS constructs. 1-5d8 VS Others.
                            if(AI_ActionCastSpell(SPELL_SEARING_LIGHT, oTempEnemy, 13)) return TRUE;

                            if(nImmuneLevel < 2)
                            {
                                // Acid arrow. Level 2 (Wizard). 3d6 damage on hit. 1d6 for more rounds after.
                                if(AI_ActionCastSpell(SPELL_MELFS_ACID_ARROW, oTempEnemy, 12)) return TRUE;

                                if(nImmuneLevel < 1)
                                {
                                    // Magic missile. Good knockout spell. Shield stops it.
                                    if(!GetHasSpellEffect(SPELL_SHIELD, oTempEnemy))
                                    {
                                        // Shad. conjuration version.
                                        if(AI_ActionCastSpell(SPELL_SHADOW_CONJURATION_MAGIC_MISSILE, oTempEnemy, 11, FALSE, TRUE)) return TRUE;

                                        // Magic Missile. Level 1 (Wizard). 1-5 missiles, 1-9 levels. 1d4+1 damage/missile.
                                        if(AI_ActionCastSpell(SPELL_MAGIC_MISSILE, oTempEnemy, 11)) return TRUE;
                                    }

                                    // Negative energy ray - note will save!
                                    if(fDistance < fMediumRange &&
                                       !AI_SaveImmuneAOE(oTempEnemy, SAVING_THROW_WILL, 1))
                                    {
                                        // Negative Energy Ray. Level 1 (Mage) 2 (Cleric) 1d6(CasterLevel/2) to 5d6 negative damage.
                                        if(AI_ActionCastSpell(SPELL_NEGATIVE_ENERGY_RAY, oTempEnemy, 11)) return TRUE;
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    return FALSE;
}
/*::///////////////////////////////////////////////
//:: Name: AbilityAura
//::///////////////////////////////////////////////
    This will use all aura (or "Persistant") abilties.

    Note:

    - They are cheat cast. If removed, as DMG, they are instantly re-applied as
      a free action!
    - They are cast instantly for the above reason, and cheat-cast.
//::///////////////////////////////////////////////
//:: Created By: Jasperre
//::////////////////////////////////////////////*/
void AI_AttemptCastAuraSpell(int nSpellID)
{
    if(GetHasSpell(nSpellID) && !GetHasSpellEffect(nSpellID))
    {
        // Cheat/fast cast the aura.
        ActionCastSpellAtObject(nSpellID, OBJECT_SELF, METAMAGIC_NONE, TRUE, 20, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
    }
}
// This will fire any aura's they have, quickened cast, and added to the top of
// thier action queue.
void AI_ActionAbilityAura()
{
    int nCnt;
    // We can loop around a few:
    // 195        AURA_BLINDING
    // 196        Aura_Cold
    // 197        Aura_Electricity
    // 198        Aura_Fear
    // 199        Aura_Fire
    // 200        Aura_Menace
    // 201        Aura_Protection
    // 202        Aura_Stun
    // 203        Aura_Unearthly_Visage
    // 204        Aura_Unnatural
    for(nCnt = SPELLABILITY_AURA_BLINDING; nCnt <= SPELLABILITY_AURA_UNNATURAL; nCnt++)
    {
        // Wrapper function.
        AI_AttemptCastAuraSpell(nCnt);
    }
    // Other auras we would have unlimited uses in
    AI_AttemptCastAuraSpell(SPELLABILITY_DRAGON_FEAR);
    AI_AttemptCastAuraSpell(SPELLABILITY_TYRANT_FOG_MIST);
    AI_AttemptCastAuraSpell(AI_SPELLABILITY_AURA_OF_HELLFIRE);
    AI_AttemptCastAuraSpell(SPELLABILITY_AURA_HORRIFICAPPEARANCE);

    // Then, ones that are limited duration, or limited uses.
    if(!GetHasSpellEffect(SPELLABILITY_MUMMY_BOLSTER_UNDEAD) &&
        GetHasSpell(SPELLABILITY_MUMMY_BOLSTER_UNDEAD))
    {
        ActionCastSpellAtObject(SPELLABILITY_MUMMY_BOLSTER_UNDEAD, OBJECT_SELF);
    }
    // This acts like an ability - well, from my perspective. We add actions
    // after it, and it is important to keep up.
    // * Quick note: requires at least 1 monk level to work.
    // * Note 2: Uses the new spell-like-feat abilties function, which did the
    //   same stuff as before, but is easier to debug etc. (although, empty body
    //   was a feat which worked fine).
    AI_ActionUseSpellLikeFeat(FEAT_EMPTY_BODY, SPELLABILITY_EMPTY_BODY);
}
/*::///////////////////////////////////////////////
//:: Name LeaderActions
//::///////////////////////////////////////////////
    This will make the leader "command" allies. Moving
    one to get others, orshout attack my target.
//::///////////////////////////////////////////////
//:: Created By: Jasperre
//::////////////////////////////////////////////*/
void AI_ActionLeaderActions()
{
    // We only advance if we are the group leader.
    if(GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_GROUP_LEADER, AI_OTHER_COMBAT_MASTER))
    {
        // Does the enemy out class us by a random amount? (2-6 HD difference).
        // Sends a runner.
        if(GlobalAverageEnemyHD > (GlobalAverageFriendlyHD + d4() + 2))
        {
            if(GlobalValidAlly && !GetLocalTimer(AI_TIMER_LEADER_SENT_RUNNER))
            {
                object oBestAllies = AI_GetNearbyFleeObject();
                if(GetIsObjectValid(oBestAllies)) // Send a runner...
                {
                    // * Don't speak when silenced or deaf, 1.4 change.
                    if(!AI_GetAIHaveEffect(GlobalEffectDeaf) && !AI_GetAIHaveEffect(GlobalEffectSilenced))
                    {
                        // Speak array.
                        SpeakArrayString(AI_TALK_ON_LEADER_SEND_RUNNER);
                    }
                    // All we need to do is set an action on the nearest ally,
                    // and the object to run to.
                    SetLocalObject(GlobalNearestAlly, AI_OBJECT + AI_RUNNER_TARGET, oBestAllies);
                    // Set action.
                    SetLocalInt(GlobalNearestAlly, AI_CURRENT_ACTION, AI_SPECIAL_ACTIONS_ME_RUNNER);
                    // Don't send another for 50 seconds.
                    SetLocalTimer(AI_TIMER_LEADER_SENT_RUNNER, 50.0);
                }
            }
        }
        // Second, we shout for people to target this person - IF we need help
        // - Example, low HP us, high HP them.
        // - Uses melee target.
        int nLeaderCountForShout = GetAIInteger(AI_LEADER_SHOUT_COUNT);
        nLeaderCountForShout++;
        if(nLeaderCountForShout >= 5)
        {
            // Check HD difference
            if(GetHitDice(GlobalMeleeTarget) - 5 > GlobalAverageEnemyHD)
            {
                // Set who we want them to attack.
                SetAIObject(AI_ATTACK_SPECIFIC_OBJECT, GlobalMeleeTarget);
                // Shout counter re-set
                nLeaderCountForShout = FALSE;

                // * Don't speak when silenced or deaf, 1.4 change.
                if(!AI_GetAIHaveEffect(GlobalEffectDeaf) && !AI_GetAIHaveEffect(GlobalEffectSilenced))
                {
                    // Speak random custom shout (like "You lot, attack this one!")
                    SpeakArrayString(AI_TALK_ON_LEADER_ATTACK_TARGET);
                }

                // Speak a silent AI shout
                AISpeakString(AI_SHOUT_LEADER_ATTACK_TARGET);
            }
        }
        SetAIInteger(AI_LEADER_SHOUT_COUNT, nLeaderCountForShout);
    }
}
/*::///////////////////////////////////////////////
//:: Name ArcherRetreat
//::///////////////////////////////////////////////
    This may make the archer retreat - if we have an ally helping, and
    we have a nearby enemy. Means the loss of AOO's.
//::///////////////////////////////////////////////
//:: Created By: Jasperre
//::////////////////////////////////////////////*/
int AI_AttemptArcherRetreat(object oIntruder = OBJECT_INVALID)
{
    // Many conditions - we must have it to start!
    if(GetLocalInt(OBJECT_SELF, "range") == 1)
    {
        // Enemy range must be close (HTH distance, roughly) and we must have
        // a close ally. ELSE we'll just get lots of AOO and die running (pointless)
        // * Was > 1, now >= 1, 1.4 fix.
        //if((GlobalEnemiesIn4Meters >= 1 && GlobalValidAlly && GlobalRangeToAlly < 4.0) ||
        //    GetSpawnInCondition(AI_FLAG_COMBAT_ARCHER_ALWAYS_MOVE_BACK, AI_COMBAT_MASTER))

        // only retreat is enemies are close
        //if(GlobalEnemiesIn4Meters >= 1)
        // only check distance and if there is a melee target

        object oTarget = GlobalMeleeTarget;
        // no global melee target or its dead?
        // use oIntruder then

        if (!GetIsObjectValid(oTarget) || GetIsDead(oTarget))
            oTarget = oIntruder;

        // return if there is no good melee target at this point
        if (!GetIsObjectValid(oTarget) || GetIsDead(oTarget))
            return FALSE;

        float fDistance = GetDistanceToObject(GlobalMeleeTarget);
        if(GetIsObjectValid(GlobalMeleeTarget) && fDistance >= 2.0 && fDistance <= 8.0)
        {
            // ammo and other checks removed
            // only check if main hand isn't ranged - pok
            if(!GetWeaponRanged(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND)))
            {
                ActionEquipMostDamagingRanged();
            }
            // This action will cancle next round if we are far enough
            // away from enemies.
            //ActionMoveAwayFromObject(GlobalMeleeTarget, TRUE, 15.0);

            float fDistance = IntToFloat(8+d8());

            ActionMoveAwayFromLocation(GetLocation(oTarget), TRUE, fDistance);

            // start attacking after a while - pok
            DelayCommand(fDistance/3.0, ActionAttack(oTarget));
            return TRUE;

        }
    }
    return FALSE;
}
/*::///////////////////////////////////////////////
//:: Name UseTurning
//::///////////////////////////////////////////////
    This, if we have the feat, will turn things it can.
    Need to really make sure it works well, and maybe
    make an interval between one and another.
//::///////////////////////////////////////////////
//:: Created By: Bioware. Edited by Jasperre.
//::////////////////////////////////////////////*/
int AI_AttemptFeatTurning()
{
    // We loop the targets and see who we come up with to hit!
    // - Use ranged enemy checks, seen/heard and only if we have any
    //   valid races in the area.
    if(GetHasFeat(FEAT_TURN_UNDEAD))
    {
        // The turn level is set OnSpawn if we have FEAT_TURN_UNDEAD
        int nTurnLevel = GetAIInteger(AI_TURNING_LEVEL);
        // Error checking
        if(nTurnLevel <= 0) return FALSE;

        // We then loop through targets nearby, up to 20M. We can easily use
        // GetHasSpellEffect(AI_SPELL_FEAT_TURN_UNDEAD)
        // and for the epic feat
        // GetHasSpellEffect(AI_SPELL_FEAT_PLANAR_TURNING)

        // Ok, so how does turning work?
        // - Basically, all undead/virmin/elementals or outsiders are turned,
        //   with constructs being damaged (which still rocks!)
        // - Works agasints non-friends.
        // - If we have nClassLevel/2 >= nHD (nHD = GetHitDice(oTarget) + GetTurnResistanceHD(oTarget)
        //   then kill, else turn.
        // - Only can turn if nHD <= nTurnLevel.
        // - 20M range.
        // Flags for bonus turning types
        int bElemental = GetHasFeat(FEAT_AIR_DOMAIN_POWER) + GetHasFeat(FEAT_EARTH_DOMAIN_POWER) + GetHasFeat(FEAT_FIRE_DOMAIN_POWER) + GetHasFeat(FEAT_WATER_DOMAIN_POWER);
        int bVermin = GetHasFeat(FEAT_PLANT_DOMAIN_POWER) + GetHasFeat(FEAT_ANIMAL_COMPANION);
        int bConstructs = GetHasFeat(FEAT_DESTRUCTION_DOMAIN_POWER);
        int bPlanarTurning = GetHasFeat(AI_FEAT_EPIC_PLANAR_TURNING);
        // Outsiders can be turned via. Epic Planar Turning too.
        int bOutsider = bPlanarTurning + GetHasFeat(FEAT_GOOD_DOMAIN_POWER) + GetHasFeat(FEAT_EVIL_DOMAIN_POWER);
        int nHD, nRacial, bValid;
        // Loop, using a sort of loop used for the turning check.
        // - Same GetNearestCreature() as 1.64 has: Alive + Seen.
        // - We stop if, when we would use it, it'd re-apply effects to one
        //   already turned.
        // - We stop if we get to something we can turn!
        int nCnt = 1;
        object oTarget = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, OBJECT_SELF, nCnt, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
        while(GetIsObjectValid(oTarget) && bValid == FALSE && GetDistanceToObject(oTarget) <= 20.0)
        {
            // Same check as in turn undead script.
            if(!GetIsFriend(oTarget))
            {
                nHD = GetHitDice(oTarget) + GetTurnResistanceHD(oTarget);
                nRacial = GetRacialType(oTarget);
                // Planar creatures add spell resistance (don't bother if can't turn them)
                if(nRacial == RACIAL_TYPE_OUTSIDER && bOutsider)
                {
                    if(bPlanarTurning)
                    {
                        // Half with the epic feat
                        nHD += (GetSpellResistance(oTarget)/2);
                    }
                    else
                    {
                        // Full SR added without the epic feat.
                        nHD += GetSpellResistance(oTarget);
                    }
                }
                if(nHD <= nTurnLevel)
                {
                    // If we would try and re-apply effects, then break and do
                    // not use
                    if(GetHasSpellEffect(AI_SPELL_FEAT_TURN_UNDEAD, oTarget) ||
                       GetHasSpellEffect(AI_SPELL_FEAT_PLANAR_TURNING, oTarget))
                    {
                        bValid = 2;
                    }
                    // Else Check the various domain turning types
                    else if(nRacial == RACIAL_TYPE_UNDEAD ||
                           (nRacial == RACIAL_TYPE_VERMIN && bVermin) ||
                           (nRacial == RACIAL_TYPE_ELEMENTAL && bElemental) ||
                           (nRacial == RACIAL_TYPE_CONSTRUCT && bConstructs) ||
                           (nRacial == RACIAL_TYPE_OUTSIDER && bOutsider))
                    {
                        bValid = TRUE;
                    }
                }
            }
            // Next alive, seen creature.
            nCnt++;
            oTarget = GetNearestCreature(CREATURE_TYPE_IS_ALIVE, TRUE, OBJECT_SELF, nCnt, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
        }
        // If valid, use it
        if(bValid == TRUE)
        {
            // 28: "[DCR:Turning] Using Turn Undead"
            DebugActionSpeakByInt(28);
            // We do not bother turning off hiding/searching - but we do check
            // expertise!
            if(GlobalIntelligence >= 4)
            {
                if(GetHasFeat(FEAT_IMPROVED_EXPERTISE))
                {
                    AI_SetMeleeMode(ACTION_MODE_IMPROVED_EXPERTISE);
                }
                else if(GetHasFeat(FEAT_EXPERTISE))
                {
                    AI_SetMeleeMode(ACTION_MODE_EXPERTISE);
                }
            }
            // Note: No equipping shield, do it ASAP. Usually a shield is
            // already equipped anyway, if we had one.
            ActionUseFeat(FEAT_TURN_UNDEAD, OBJECT_SELF);
            return TRUE;
        }
    }
    // Else nothing to do it against or no feat.
    return FALSE;
}
/*::///////////////////////////////////////////////
//:: Name TalentBardSong
//::///////////////////////////////////////////////
    This, if we have the feat, and not the effects,
    will use it on ourselves.
//::///////////////////////////////////////////////
//:: Created By: Bioware
//::////////////////////////////////////////////*/
int AI_AttemptFeatBardSong()
{
    // Got it and not silenced
    if(GetHasFeat(FEAT_BARD_SONGS) && !AI_GetAIHaveEffect(GlobalEffectSilenced))
    {
        // The spell script used is 411 - it is also now named in the AI constant file
        // Get nearest without this spell's effect to check too
        object oSonged = GetNearestCreature(CREATURE_TYPE_DOES_NOT_HAVE_SPELL_EFFECT, AI_SPELLABILITY_BARD_SONG, OBJECT_SELF, 1, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_FRIEND, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
        if((/* 1.4: Noticed no need for below check
            !GetHasSpellEffect(AI_SPELLABILITY_BARD_SONG, oSonged) && */
            !GetHasFeatEffect(FEAT_BARD_SONGS, oSonged) &&
            // Do not use if we are deaf...
            !AI_GetAIHaveEffect(GlobalEffectDeaf, oSonged)) ||
            // ...but we could use it if we have an undeaf ally in 8M
            (GetIsObjectValid(oSonged) && GetDistanceToObject(oSonged) < 8.0 &&
            !AI_GetAIHaveEffect(GlobalEffectDeaf, oSonged)))
        {
            // 29: "[DCR:Bard Song] Using"
            DebugActionSpeakByInt(29);
            // We do not bother turning off hiding/searching
            ActionUseFeat(FEAT_BARD_SONGS, OBJECT_SELF);
            return TRUE;
        }
        // We may use curse song!
        else if(GetHasFeat(FEAT_CURSE_SONG))
        {
            // get nearest without this spell's effect
            oSonged = GetNearestCreature(CREATURE_TYPE_DOES_NOT_HAVE_SPELL_EFFECT, SPELLABILITY_EPIC_CURSE_SONG, OBJECT_SELF, 1, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
            // If they are not cursed, IE valid, in 8M (1.4 change: was 6),
            // and not deaf, we try it.
            if(GetIsObjectValid(oSonged) &&
               GetDistanceToObject(oSonged) <= 8.0 &&
              !AI_GetAIHaveEffect(GlobalEffectDeaf, oSonged))
            {
                // 30: "[DCR:Bard Curse Song] Using"
                DebugActionSpeakByInt(30);
                // We do not bother turning off hiding/searching
                ActionUseFeat(FEAT_CURSE_SONG, OBJECT_SELF);
                return TRUE;
            }
        }
    }
    return FALSE;
}

// Wrappers for spellcasting groups of spells.

// Wrappers Greater and Lesser spell breach.
int AI_ActionCastBreach()
{
    // Greater Spell Breach. Level 6 (Wizard). Dispels cirtain protections automatically + lowers spell resistance
    if(AI_ActionCastSpell(SPELL_GREATER_SPELL_BREACH, GlobalDispelTarget, 16, FALSE)) return TRUE;
    // Lesser Spell Breach. Level 4 (Wizard) Dispels cirtain protections automatically + lowers spell resistance
    if(AI_ActionCastSpell(SPELL_LESSER_SPELL_BREACH, GlobalDispelTarget, 14, FALSE)) return TRUE;
    return FALSE;
}
// Wrappers all dispel spells
int AI_ActionCastDispel()
{
    // Mordenkainens Disjunction. Level 9 (Wizard). Acts like a breach, dispel AND lowers SR, in a big area.
    if(AI_ActionCastSpell(SPELL_MORDENKAINENS_DISJUNCTION, GlobalDispelTarget, 19, FALSE)) return TRUE;
    // Greater Dispeling. Level 5 (Bard/Innate) 6 (Cleric/Druid/Mage) General dispel up to 15 caster levels.
    if(AI_ActionCastSpell(SPELL_GREATER_DISPELLING, GlobalDispelTarget, 16, FALSE)) return TRUE;
    // Dispel Magic. Level 3 (Bard/Cleric/Paladin/Mage/Innate) 6 (Druid) General dispel up to 10 caster levels.
    if(AI_ActionCastSpell(SPELL_DISPEL_MAGIC, GlobalDispelTarget, 13, FALSE)) return TRUE;
    // Only lesser if under 15 HD, because it may not be worth it (DC wise)
    if(GlobalAverageEnemyHD < 15)
    {
        // Lesser Dispel. Level 1 (Bard) 2 (Cleric/Druid/Mage/Innate). General dispel up to 5 caster levels.
        if(AI_ActionCastSpell(SPELL_LESSER_DISPEL, GlobalDispelTarget, 12, FALSE)) return TRUE;
    }
    return FALSE;
}
// This wrappers AI_ActionCastBreach() and AI_ActionCastDispel(). Input
// nValue for 1 (Lowest priority) to 5, to see if we'll use them. Returns
// TRUE if any are cast.
int AI_ActionAttemptDispel(int nValue, int bRangeMediumValid)
{
    // All range medium spells. Shouldn't use them in Time Stop.
    if(bRangeMediumValid && !GlobalInTimeStop)
    {
        // Dispel number need to be nValue at least to use a breach
        if(GlobalDispelTargetHighestBreach >= nValue)
        {
            // Wrapers Greater and Lesser Breach.
            if(AI_ActionCastBreach()) return TRUE;
        }
        // Dispel >= nValue
        if(GlobalDispelTargetHighestDispel >= nValue)
        {
            // Wrappers the dispel spells
            if(AI_ActionCastDispel()) return TRUE;
        }
    }
    // No dispels cast.
    return FALSE;
}
// Wrappers Premonition, Greater Stoneskin and Stoneskin.
// Includes Shades Stoneskin too. SPELL_SHADES_STONESKIN
// - nLowest - 8 = Prem, 6 = Greater, 4 = Stoneskin
// - Checks AI_GetAIHaveSpellsEffect(GlobalHasStoneSkinProtections)
int AI_SpellWrapperPhisicalProtections(int nLowest = 1)
{
    // Stoneskin - protection from attackers.
    if(!AI_GetAIHaveSpellsEffect(GlobalHasStoneSkinProtections))
    {
        // Epic Warding (Mage Only) - Damage reduction 50/+20. Lasts 1 round per level.
        if(AI_ActionUseSpellLikeFeat(FEAT_EPIC_SPELL_EPIC_WARDING, AI_SPELL_EPIC_WARDING)) return TRUE;

        // Psionic Inertial Barrier
        if(AI_ActionCastSpell(AI_SPELLABILITY_PSIONIC_INERTIAL_BARRIER)) return TRUE;

        if(nLowest <= 8)
        {
            // Preminition is 30/+5 damage resistance. Level 8 spell. Always class
            // as level 9. (Mage)
            if(AI_ActionCastSpell(SPELL_PREMONITION, OBJECT_SELF, 18, FALSE)) return TRUE;
            if(nLowest <= 6)
            {
                // Then, greater stoneskin protects a lot of damage - 20/+5.
                // We also consider this to be a high-level spell. Level 6 (Mage) 7 (druid)
                if(AI_ActionCastSpell(SPELL_GREATER_STONESKIN, OBJECT_SELF, 16, FALSE)) return TRUE;
                if(nLowest <= 4)
                {
                    // Shades stoneskin. SPELL_SHADES_STONESKIN (Cast via. subspell)
                    if(AI_ActionCastSpell(SPELL_SHADES_STONESKIN, OBJECT_SELF, 16, FALSE, TRUE)) return TRUE;

                    // Stoneskin is next, level 4, but 10/+5 resistance Level 4 (Mage) 5 (Druid)
                    if(AI_ActionCastSpell(SPELL_STONESKIN, OBJECT_SELF, 14, FALSE)) return TRUE;
                }
            }
        }
    }
    return FALSE;
}
// Wrappers Energy Buffer, Protection From Elements, Resist Elements, Endure elements
// - nLowest - Goes 5, 3, 2, 1.
// - Checks AI_GetAIHaveSpellsEffect(GlobalHasElementalProtections)
int AI_SpellWrapperElementalProtections(int nLowest = 1)
{
    // Elemental protections (fireball ETC)
    if(!AI_GetAIHaveSpellsEffect(GlobalHasElementalProtections) && nLowest <= 5)
    {
        // Energy buffer - 40/- resistance to the damage.
        // 6 for druids ETC, but 5 Mage/Innate.
        if(AI_ActionCastSpell(SPELL_ENERGY_BUFFER, OBJECT_SELF, 15, FALSE)) return TRUE;
        if(nLowest <= 3)
        {
            // Protection from elements - 30/- resistance to the damage. Level 3
            if(AI_ActionCastSpell(SPELL_PROTECTION_FROM_ELEMENTS, OBJECT_SELF, 13, FALSE)) return TRUE;
            if(nLowest <= 2)
            {
                // Resist elements - 20/- resistance to the damage. Level 2
                if(AI_ActionCastSpell(SPELL_RESIST_ELEMENTS, OBJECT_SELF, 12, FALSE)) return TRUE;
                if(nLowest <= 1)
                {
                    // Endure elements - 10/- resistance to the damage. Level 1
                    if(AI_ActionCastSpell(SPELL_ENDURE_ELEMENTS, OBJECT_SELF, 11, FALSE)) return TRUE;
                }
            }
        }
    }
    return FALSE;
}
// Wrappers Haste and Mass Haste.
// - nLowest - 6 = Mass, 3 = Haste
// - Checks AI_GetAIHaveSpellsEffect(GlobalHasStoneSkinProtections)
int AI_SpellWrapperHasteEnchantments(int nLowest = 1)
{
    // Excelent to cast this normally - +4AC. Probably normally best after protections from
    // phisical attacks.
    if(!AI_GetAIHaveEffect(GlobalEffectHaste) && nLowest <= 6)
    {
        // The feat, for haste, called blinding speed.
        if(AI_ActionUseSpellLikeFeat(FEAT_EPIC_BLINDING_SPEED, AI_SPELLABILITY_BLINDING_SPEED)) return TRUE;

        // Mass haste, level 6 spell. (Mage/Bard) Affects allies, and adds +1 action, +4 AC and +150% move
        if(AI_ActionCastSpell(SPELL_MASS_HASTE, OBJECT_SELF, 16, FALSE)) return TRUE;

        if(nLowest <= 3)
        {
            // Haste, Level 3 spell. (Mage/Bard), see mass haste.
            if(AI_ActionCastSpell(SPELL_HASTE, OBJECT_SELF, 13, FALSE)) return TRUE;
        }
    }
    return FALSE;
}
// Wrappers Shadow Shield, Ethereal Visage and Ghostly Visage.
// Includes Greater Shadow Conjuration Ghostly Visage (SPELL_GREATER_SHADOW_CONJURATION_MIRROR_IMAGE
// - nLowest - 7 = Shadow, 6 = Ethereal 2 = Ghostly
// - Checks AI_GetAIHaveSpellsEffect(GlobalHasVisageProtections)
int AI_SpellWrapperVisageProtections(int nLowest = 1)
{
    // Visages are generally lower DR, with some spell-resisting or effect-immunty extras.
    if(!AI_GetAIHaveSpellsEffect(GlobalHasVisageProtections) && nLowest <= 7)
    {
        // Shadow Shield - has 10/+3 damage reduction
        // Level 7 (Mage)
        if(AI_ActionCastSpell(SPELL_SHADOW_SHIELD, OBJECT_SELF, 17, FALSE)) return TRUE;
        if(nLowest <= 6)
        {
            // Ethereal Visage (level 6 (Mage)) is 20/+3 damage reduction - no limit!
            // + Immunity to level 2, 1, 0 level spells.
            if(AI_ActionCastSpell(SPELL_ETHEREAL_VISAGE, OBJECT_SELF, 16, FALSE)) return TRUE;
            if(nLowest <= 2)
            {
                // This is the shadow dancer evade
                if(AI_ActionUseSpellLikeFeat(FEAT_SHADOW_EVADE, SPELL_SHADOW_EVADE)) return TRUE;

                // This is the assassin ghostly visage.
                if(AI_ActionUseSpellLikeFeat(FEAT_PRESTIGE_SPELL_GHOSTLY_VISAGE, SPELLABILITY_AS_GHOSTLY_VISAGE)) return TRUE;

                // This is ghostly visage, dispite the spell constant name. G.Shadow conjuration
                // * Cast as a sub-spell.
                if(AI_ActionCastSpell(SPELL_GREATER_SHADOW_CONJURATION_MIRROR_IMAGE, OBJECT_SELF, 15, FALSE, TRUE)) return TRUE;

                // Ghostly Visage is only 5/+1, but could work at the lower levels! Immunity to 1-0 spells too.
                // Level 2 (Mage).
                if(AI_ActionCastSpell(SPELL_GHOSTLY_VISAGE, OBJECT_SELF, 12, FALSE)) return TRUE;
            }
        }
    }
    return FALSE;
}
// Wrappers All Mantals (Greater, Normal, Lesser) (Spell Mantals)
// - nLowest - 9 = Greater, 7 = Normal. 5 = Lesser
// - Checks AI_GetAIHaveSpellsEffect(GlobalHasMantalProtections)
int AI_SpellWrapperMantalProtections(int nLowest = 1)
{
    // Provides total spell immunity (for most spells, say, 99%) until runs out/dispeled.
    if(!AI_GetAIHaveSpellsEffect(GlobalHasMantalProtections) && nLowest <= 9)
    {
        // Greater Spell mantal. Level 9 (Mage), for d12() + 10 spell levels protected.
        if(AI_ActionCastSpell(SPELL_GREATER_SPELL_MANTLE, OBJECT_SELF, 19, FALSE)) return TRUE;
        if(nLowest <= 7)
        {
            // Normal, level 7 spell (Mage). d6() + 8 spell levels protected.
            if(AI_ActionCastSpell(SPELL_SPELL_MANTLE, OBJECT_SELF, 17, FALSE)) return TRUE;
            if(nLowest <= 5)
            {
                // Lesser, level 5 spell (Mage). d4() + 6 spell levels protected.
                if(AI_ActionCastSpell(SPELL_LESSER_SPELL_MANTLE, OBJECT_SELF, 15, FALSE)) return TRUE;
            }
        }
    }
    return FALSE;
}
// Wrappers All Globes (Greater, Shadow Conjuration, Minor)
// - nLowest - 6 = Greater, 4 = Shadow/Minor
// - Checks AI_GetAIHaveSpellsEffect(GlobalHasGlobeProtections)
int AI_SpellWrapperGlobeProtections(int nLowest = 1)
{
    // Immunity to most spells of X or under. Good because level 4 spells have a large selection of AOE ones.
    if(!AI_GetAIHaveSpellsEffect(GlobalHasGlobeProtections) && nLowest <= 6)
    {
        // Normal globe, level 6 spell (Mage). Protects vurses 4 or lower spells.
        if(AI_ActionCastSpell(SPELL_GLOBE_OF_INVULNERABILITY, OBJECT_SELF, 16, FALSE)) return TRUE;
        // Note! Ethereal Visage protects VS 0, 1, 2 levels spells.
        if(nLowest <= 4)
        {
            // SPELL_GREATER_SHADOW_CONJURATION_MINOR_GLOBE.
            // As Minor globe, except shadow version. Cast as sub-spell.
            if(AI_ActionCastSpell(SPELL_GREATER_SHADOW_CONJURATION_MINOR_GLOBE, OBJECT_SELF, 15, FALSE, TRUE)) return TRUE;

            // Minor globe, level 4 spell (Mage). Protects vurses 3 or lower spells.
            if(AI_ActionCastSpell(SPELL_MINOR_GLOBE_OF_INVULNERABILITY, OBJECT_SELF, 14, FALSE)) return TRUE;
        }
    }
    return FALSE;
}
// Wrappers All Shields - Elemental Shield, Wounding Whispers
// - nLowest - 4 = Elemental, 3 = Wounding.
// - Checks AI_GetAIHaveSpellsEffect(GlobalHasElementalShieldSpell)
int AI_SpellWrapperShieldProtections(int nLowest = 1)
{
    // These help deflect damage :-D
    if(!AI_GetAIHaveEffect(GlobalEffectDamageShield) && nLowest <= 4)
    {
        // Elemental Shield. Level 4 (Mage). Does some damage to melee attackers (Casterlvl + d6(), Fire). +50% cold/fire resistance.
        if(AI_ActionCastSpell(SPELL_ELEMENTAL_SHIELD, OBJECT_SELF, 14, FALSE)) return TRUE;
        if(nLowest <= 3)
        {
            // Acid Sheath. Level 3 (Mage) Does some damage to melee attackers (2 * CasterLvl + 1d6, Acid).
            if(AI_ActionCastSpell(SPELL_MESTILS_ACID_SHEATH, OBJECT_SELF, 13, FALSE)) return TRUE;

            // Wounding Whispers. Level 3 (bard) Does some damage to melee attackers (Casterlvl + d6(), Sonic).
            if(AI_ActionCastSpell(SPELL_WOUNDING_WHISPERS, OBJECT_SELF, 13, FALSE)) return TRUE;

            if(nLowest <= 2)
            {
                // Death Armor. Level 2 (Mage) Does some damage to melee attackers (Caster Level/2 (to +5) + 1d4, Magical)
                if(AI_ActionCastSpell(SPELL_DEATH_ARMOR, OBJECT_SELF, 13, FALSE)) return TRUE;
            }
        }
    }
    return FALSE;
}
// Wrappers All Mind resistance spells - Mind blank, Lesser and Clarity. bioware likes 3's...
// - nLowest - 8 = Mind Blank, 5 = Lesser, 2 = Clarity
// - Checks AI_GetAIHaveSpellsEffect(GlobalHasMindResistanceProtections)
int AI_SpellWrapperMindResistanceProtections(int nLowest = 1)
{
    // immunties against mind - cool :-D (but not 100% useful).
    // Might add more "if they cast a mind spell, we cast this to stop more" in sometime
    if(!AI_GetAIHaveSpellsEffect(GlobalHasMindResistanceProtections) && nLowest <= 8)
    {
        // Mind Blank. Level 8 (Mage) Mind immunity (and clean up)
        if(AI_ActionCastSpell(SPELL_MIND_BLANK, OBJECT_SELF, 18, FALSE)) return TRUE;
        if(nLowest <= 5)
        {
            // Lesser Mind Blank. Level 5 (Mage) Mind immunity (and clean up)
            if(AI_ActionCastSpell(SPELL_LESSER_MIND_BLANK, OBJECT_SELF, 15, FALSE)) return TRUE;
            if(nLowest <= 2)
            {
                // Clarity. Level 2 (Bard/Innate) 3 (Cleric/Mage) Mind immunity (and clean up)
                if(AI_ActionCastSpell(SPELL_CLARITY, OBJECT_SELF, 12, FALSE)) return TRUE;
            }
        }
    }
    return FALSE;
}

// Wrappers All Consealment spells - Improved Invisiblity. Displacement.
// - nLowest - 4 = Improved Invisiblit, 3 = Displacement
// - Checks !AI_GetAIHaveEffect(GlobalEffectInvisible, oTarget) && !AI_GetAIHaveSpellsEffect(GlobalHasConsealmentSpells, oTarget)
int AI_SpellWrapperConsealmentEnhancements(object oTarget, int nLowest = 1)
{
    if(!AI_GetAIHaveEffect(GlobalEffectInvisible, oTarget) &&
       !GetHasSpellEffect(SPELL_DISPLACEMENT, oTarget))
    {
        if(oTarget == OBJECT_SELF)
        {
            // Shadow dragon special consealment
            if(AI_ActionCastSpell(AI_SPELLABILITY_SHADOWBLEND)) return TRUE;
        }
        if(nLowest <= 4)
        {
            if(oTarget == OBJECT_SELF)
            {
                // Improved Invis - assassin
                if(AI_ActionUseSpellLikeFeat(FEAT_PRESTIGE_INVISIBILITY_2, SPELLABILITY_AS_IMPROVED_INVISIBLITY)) return TRUE;
            }
            // Improved Invis. Level 4 (Bard, Mage). 50% consealment + invisibility.
            if(AI_ActionCastSpell(SPELL_IMPROVED_INVISIBILITY, oTarget, 14, FALSE)) return TRUE;

            if(nLowest <= 3)
            {
                // Displacement. Level 3 (Mage). 50% consealment.
                if(AI_ActionCastSpell(SPELL_DISPLACEMENT, oTarget, 13, FALSE)) return TRUE;
            }
        }
    }
    return FALSE;
}
// Shades darkness, assassin feat, normal spell.
int AI_SpellWrapperDarknessSpells(object oTarget)
{
    // Special Assassin Version
    if(AI_ActionUseSpellLikeFeat(FEAT_PRESTIGE_DARKNESS, SPELLABILITY_AS_DARKNESS, oTarget)) return TRUE;
    // Shades one. Cast as sub-spell.
    if(AI_ActionCastSpell(SPELL_SHADOW_CONJURATION_DARKNESS, oTarget, 14, TRUE, TRUE)) return TRUE;
    // Darkness. Area of consealment. Level 2 (Cleric/Bard/Mage) Specail Assassin.
    if(AI_ActionCastSpell(SPELL_DARKNESS, oTarget, 12, TRUE)) return TRUE;

    return FALSE;
}
// Invisibility spells + feats
int AI_SpellWrapperNormalInvisibilitySpells()
{
    // Special Harper Version - Normal invisibility.
    if(AI_ActionUseSpellLikeFeat(FEAT_HARPER_INVISIBILITY, AI_SPELLABILITY_HARPER_INVISIBILITY)) return TRUE;
    // Special Assassin Version - Normal invisibility.
    if(AI_ActionUseSpellLikeFeat(FEAT_PRESTIGE_INVISIBILITY_1, SPELLABILITY_AS_INVISIBILITY)) return TRUE;
    // Cast invisiblity spells!
    // Invisiblity Sphere. Level 3 (Bard, Mage). Invisibility till attacked for an area!
    if(AI_ActionCastSpell(SPELL_INVISIBILITY_SPHERE, OBJECT_SELF, 13, FALSE)) return TRUE;
    // Shad. conjuration. Cast as sub-spell.
    if(AI_ActionCastSpell(SPELL_SHADOW_CONJURATION_INIVSIBILITY, OBJECT_SELF, 12, FALSE, TRUE)) return TRUE;
    // Invisiblity. Level 2 (Bard, Mage). Invisibility till attacked.
    if(AI_ActionCastSpell(SPELL_INVISIBILITY, OBJECT_SELF, 12, FALSE)) return TRUE;

    return FALSE;
}

// This will loop seen allies in a cirtain distance, and get the first one without
// the spells effects of nSpell1 to nSpell4 (and do not have the spells).
// - Quite expensive loop. Only used if we have the spell (nSpellToUse1+)
//   in the first place (no items!) and not the timer which stops it for a few rounds (on nSpellToUse1)
// - TRUE if it casts its any of nSpellToUseX's.
// * It has only a % chance to cast if GlobalWeAreBuffer is not TRUE.
int AI_ActionCastAllyBuffSpell(float fMaxRange, int nPercent, int nSpellToUse1, int nSpellToUse2 = AI_SPELL_INVALID, int nSpellToUse3 = AI_SPELL_INVALID, int nSpellToUse4 = AI_SPELL_INVALID, int nSpellOther1 = AI_SPELL_INVALID, int nSpellOther2 = AI_SPELL_INVALID)
{
    // Not in time stop
    if(GlobalInTimeStop) return FALSE;

    // Check buff ally is valid
    if(!GetIsObjectValid(GetLocalObject(OBJECT_SELF, ARRAY_ALLIES_RANGE_SEEN_BUFF + "1"))) return FALSE;

    // Check % (buffers add 150, so always pass this)
    if(d100() > (nPercent +                           // Default %
                (150 * GlobalWeAreBuffer) -          // Always cast if buffer
                (GlobalWeAreSorcerorBard * 50) +     // Much less (50%) if sorceror/bard
                (FloatToInt(GlobalRangeToMeleeTarget))// Add a little for range to melee target
                )) return FALSE;

    // Check local timer for the top spell to cast against the ally. Only the
    // top spell is timed.
    if(GetLocalTimer(AI_TIMER_BUFF_ALLY_SPELL + IntToString(nSpellToUse1))) return FALSE;

    // Set local timer to not use it for a while
    SetLocalTimer(AI_TIMER_BUFF_ALLY_SPELL + IntToString(nSpellToUse1), 18.0);

    // Check if we have the spell
    if(!GetHasSpell(nSpellToUse1) && !GetHasSpell(nSpellToUse2) &&
       !GetHasSpell(nSpellToUse3) && !GetHasSpell(nSpellToUse4)) return FALSE;

    // - This lets real-hardcode buffers go to a longer range.
    float fRangeToGoTo = fMaxRange + GlobalBuffRangeAddon;
    // Loop nearest to futhest allies
    int nCnt = 1;
    object oAlly = GetLocalObject(OBJECT_SELF, ARRAY_ALLIES_RANGE_SEEN_BUFF + IntToString(nCnt));
    // Loop Targets
    // - nCnt is our breaker. We only check 10 nearest allies, and set to 20 if break.
    while(GetIsObjectValid(oAlly) && nCnt <= 10 && GetDistanceToObject(oAlly) <= fRangeToGoTo)
    {
        // Check for thier effects
        if((nSpellToUse1 == AI_SPELL_INVALID || !GetHasSpellEffect(nSpellToUse1, oAlly)) &&
           (nSpellToUse2 == AI_SPELL_INVALID || !GetHasSpellEffect(nSpellToUse2, oAlly)) &&
           (nSpellToUse3 == AI_SPELL_INVALID || !GetHasSpellEffect(nSpellToUse3, oAlly)) &&
           (nSpellToUse4 == AI_SPELL_INVALID || !GetHasSpellEffect(nSpellToUse4, oAlly)) &&
           (nSpellOther1 == AI_SPELL_INVALID || !GetHasSpellEffect(nSpellOther1, oAlly)) &&
           (nSpellOther2 == AI_SPELL_INVALID || !GetHasSpellEffect(nSpellOther2, oAlly)) &&
           !GetHasSpell(nSpellToUse1, oAlly) && !GetHasSpell(nSpellToUse2, oAlly) &&
           !GetHasSpell(nSpellToUse3, oAlly) && !GetHasSpell(nSpellToUse4, oAlly))
        {
            // Break with this ally as target
            nCnt = 20;
        }
        else
        {
            // Get Next ally
            nCnt++;
            oAlly = GetLocalObject(OBJECT_SELF, ARRAY_ALLIES_RANGE_SEEN_BUFF + IntToString(nCnt));
        }
    }
    // If valid, cast at the target and return TRUE.
    if(nCnt == 20)
    {
        // oAlly is our buff target - cast the best to worst on it!
        if(nSpellToUse1 != AI_SPELL_INVALID)
            if(AI_ActionCastSpell(nSpellToUse1, oAlly)) return TRUE;
        if(nSpellToUse2 != AI_SPELL_INVALID)
            if(AI_ActionCastSpell(nSpellToUse2, oAlly)) return TRUE;
        if(nSpellToUse3 != AI_SPELL_INVALID)
            if(AI_ActionCastSpell(nSpellToUse3, oAlly)) return TRUE;
        if(nSpellToUse4 != AI_SPELL_INVALID)
            if(AI_ActionCastSpell(nSpellToUse4, oAlly)) return TRUE;
    }
    // Return FALSE - no spell cast
    return FALSE;
}

// This will run through most avalible protections spells.
// - TRUE if we cast any.
// Used when invisible to protect before we break the invisibility.
// - We may cast many on allies too
int AI_ActionCastWhenInvisible()
{
    // We run through some spells. Primarily, protection then buffs.
    // We don't target others else we'd break the invisiblity.

    // Haste's
    if(AI_SpellWrapperHasteEnchantments()) return TRUE;

    // Stoneskin - protection from attackers.
    if(AI_SpellWrapperPhisicalProtections()) return TRUE;

    // Mantals
    if(AI_SpellWrapperMantalProtections()) return TRUE;

    // Elemental protections (fireball ETC)
    if(AI_SpellWrapperElementalProtections()) return TRUE;

    // Visages
    if(AI_SpellWrapperVisageProtections()) return TRUE;

    // Globes
    if(AI_SpellWrapperGlobeProtections()) return TRUE;

    // Shields
    if(AI_SpellWrapperShieldProtections()) return TRUE;

    // Mind resistances
    if(AI_SpellWrapperMindResistanceProtections()) return TRUE;

    // Thats us done, what about allies?
    // - Buffs for allies (Reference!)
    //   Stoneskin (+ Greater)
    //   Improved Invisibility, Displacement
    //   Haste, Mass Haste
    //   Energy Protections (Buffer, Protection From, Resist, Endure)
    //   Ultravision (special case: Nearest seen ally with Darkness and not this effect)
    //   Spell Resistance
    //   Death Ward (If we can see arcane spellcasters, as it only provides death immunity)
    //   Regenerate, Monstourous Regeneration
    //   Negative Energy Protection (If we see any clerics, druids, with harm, else only self)

    // Only if buffer:
    //   Mage armor, Barkskin
    //   Bless, Aid
    //   Bulls Strength, Cats Grace, Endurance
    //   Stone bones - On undead only.

    // Not cast:
    //   Weapon spells (Blackstaff ETC) - We wouldn't have many.
    //   Protection From Spells - AOE, and the AOE includes us anyway (so gets captured when we cast it)
    //   Mind blanks - Mind protection, not worth casting on allies, its more for removal.
    //   Normal invisilbilties - They would normally be broken right away.
    //   Natures Balance - Healing AOE only really, mostly enemy SR lowering in AOE.
    //   Prayer - Cast on self
    //   Freedom of movement - More removal if anyone needs it. Doesn't stop too much.

    // Much lower % as sorceror or bard.

    // Try stoneskins as a main one
    if(AI_ActionCastAllyBuffSpell(6.0, 100, SPELL_GREATER_STONESKIN, SPELL_STONESKIN)) return TRUE;

    // Hastes!
    if(AI_ActionCastAllyBuffSpell(8.0, 100, SPELL_HASTE, SPELL_MASS_HASTE)) return TRUE;

    // Consealment spells
    if(AI_ActionCastAllyBuffSpell(6.0, 100, SPELL_IMPROVED_INVISIBILITY, SPELL_DISPLACEMENT)) return TRUE;

    // Elemental protections
    if(AI_ActionCastAllyBuffSpell(6.0, 100, SPELL_ENERGY_BUFFER, SPELL_PROTECTION_FROM_ELEMENTS, SPELL_RESIST_ELEMENTS, SPELL_ENDURE_ELEMENTS)) return TRUE;

    // If we have the setting to buff allies, we carry on buffing with some
    // other spells.
    if(GlobalWeAreBuffer)
    {
        // Some AC protections
        if(AI_ActionCastAllyBuffSpell(6.0, 100, SPELL_MAGE_ARMOR, SPELL_BARKSKIN)) return TRUE;

        // Bulls Strength, Cats Grace, Endurance
        if(AI_ActionCastAllyBuffSpell(10.0, 100, SPELL_ENDURANCE, SPELL_CATS_GRACE, SPELL_ENDURANCE, -1, SPELL_GREATER_BULLS_STRENGTH, SPELL_GREATER_CATS_GRACE)) return TRUE;

        // Bless, Aid
        if(AI_ActionCastAllyBuffSpell(6.0, 100, SPELL_AID, SPELL_BLESS)) return TRUE;
    }
    // Return FALSE - nothing cast
    return FALSE;
}

// Using the array ARRAY_ENEMY_RANGE, we return a % of seen/heard people who
// DO have any of the spells which see through the invisiblity spells.
// * nLimit - when we get to this number of people who have invisiblity, we stop and return 100%
// If ANY of the people are attacking us and have the effect, we return +30% for each.
int AI_GetSpellWhoCanSeeInvis(int nLimit)
{
    // Loop LOS range enemies.
    int nCnt = 1;
    int nHasSeeingTotal, nTotal, nAdditional;
    // Loop start
    object oEnemy = GetLocalObject(OBJECT_SELF, ARRAY_ENEMY_RANGE_SEEN + IntToString(nCnt));
    while(GetIsObjectValid(oEnemy) && nAdditional < 100)
    {
        // Seen/heard check is already done
        // Add one to total.
        nTotal++;
        // Make this the total of any seeing spells.
        if(GetHasSpellEffect(SPELL_SEE_INVISIBILITY, oEnemy) ||
           GetHasSpellEffect(SPELL_TRUE_SEEING, oEnemy))// || don't check skins for true seeing - pok
        // - We obviously can tell with creatures with true seeing hides. Only checking hides!
           //GetItemHasItemProperty(GetItemInSlot(INVENTORY_SLOT_CARMOUR, oEnemy), ITEM_PROPERTY_TRUE_SEEING))
        {
            nHasSeeingTotal++;
            // Limit checking
            if(nHasSeeingTotal >= nLimit)
            {
                nAdditional += 100;
            }
            // Special: If they are attacking us (with it) we add 30%
            // to outcome, and add 1.
            else if(GetAttackTarget(oEnemy) == OBJECT_SELF)
            {
                nAdditional += 30;
            }
        }
        nCnt++;
        oEnemy = GetLocalObject(OBJECT_SELF, ARRAY_ENEMY_RANGE_SEEN + IntToString(nCnt));
    }
    if(nHasSeeingTotal > FALSE)
    {
        return AI_GetPercentOf(nHasSeeingTotal, nTotal) + nAdditional;
    }
    return FALSE;
}

// Returns a dismissal target - a target with a master, and they
// are a Familiar, Animal companion or summon.
// - Nearest one in 10 M. Seen ones only.
object AI_GetDismissalTarget()
{
    object oMaster, oReturn;
    int nCnt = 1;
    string sCnt = IntToString(nCnt);
    object oLoopTarget = GetLocalObject(OBJECT_SELF, ARRAY_ENEMY_RANGE_SEEN + sCnt);
    float fDistance = GetLocalFloat(OBJECT_SELF, ARRAY_ENEMY_RANGE_SEEN + sCnt);
    while(GetIsObjectValid(oLoopTarget) && fDistance <= 10.0)
    {
        // Check if they are a valid summon/familar/comapnion
        oMaster = GetMaster(oLoopTarget);
        //Is that master valid and is he an enemy
        if(GetIsObjectValid(oMaster) && GetIsEnemy(oMaster))
        {
            //Is the creature a summoned associate
            if(GetAssociate(ASSOCIATE_TYPE_SUMMONED, oMaster) == oLoopTarget ||
               GetAssociate(ASSOCIATE_TYPE_FAMILIAR, oMaster) == oLoopTarget ||
               GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION, oMaster) == oLoopTarget)
            {
                // Stop and break
                oReturn = oLoopTarget;
                break;
            }
        }
        // Get next target
        nCnt++;
        sCnt = IntToString(nCnt);
        fDistance = GetLocalFloat(OBJECT_SELF, ARRAY_ENEMY_RANGE_SEEN + sCnt);
        oLoopTarget = GetLocalObject(OBJECT_SELF, ARRAY_ENEMY_RANGE_SEEN + sCnt);
    }
    return oReturn;
}
/*::///////////////////////////////////////////////
//:: Name ImportAllSpells
//::///////////////////////////////////////////////
    Taken from Jugulators improved spell AI (but now, hardly any of it remains!).
    This is a very heavily changed version. If they can cast spells
    or abilities, this will run though them and choose which
    to cast. It will cast location spells at location, meaning heard
    enemies may still be targeted.

    Incudes, nearer the bottom, if we are not a spellcaster, and
    our BAB is high compared to thier AC, we will HTH attack
    rather than carry on casting low level spells.

    Now: 1.3, it uses setups of what to do from OnSpawn to the best of its
    abilities. It already has chosen an appropriate target (And decerned its
    properties, immunities).

    Note: These are some of the non-verbal and non-stomatic componants:

    - Non-Verbal Spells -
    Clarity, Lesser Dispel, and Ethereal Visage.

    - Non-Somatic Spells -
    Darkness, Knock, Light, Mass Charm, Mordenkainen's Disjunction, Polymorph
    Self, Power Word Kill, Power Word Stun, Wail of the Banshee, Word of Faith,
    and War Cry.

    We ALWAYS use the nearest seen, if no one else :-P.

    Note: On Setup, like fighter choices, we normally perfere futher away targets
    which we can see :-) as fighters go for nearer ones, but they must be the
    best!

    This attempts to cast a spell, running down the lists.
    The only variable is nLowest and iBAB level's, targets are globally set.
    - nLowestSpellLevel - If it is set to more than 1, then all spells of that
         level and lower are just ignored. Used for dragons. Default 0.
    - nBABCheckHighestLevel - We check our BAB to see if attacking them would probably
         be a better thing to do. Default 3, it adds 5DC for each level.
    - nLastCheckedRange - 1 = Minimum, 4 = Longest. If it runs through once, and
         with "ranged attacking", doesn't find any spells to cast at the "long" range,
         then it will attempt to see if there are any spells for "meduim" etc.
         - Range: Long 40, Medium: 20, Short: 10, Touch: 2.25 (Game meters). Personal = 0
    NOTE 1: If GlobalItemsOnly is set, we only check for item talents!
    NOTE 2: It uses the SAME target, but for ranged attacking, we use a float range to check range :-)

    Notes on touch attacks:
    [Quote]
    Here's how the AC is added up for touch attacks:

    Armor bonus: no
    Shield bonus: no
    Deflection bonus: yes
    Natural bonus: no
    Dodge bonus: yes
    Dexterity modifier: yes
    Monk wisdom: yes
//::///////////////////////////////////////////////
//:: Created By: Jugulator, Modified (very) Heavily: Jasperre
//::////////////////////////////////////////////*/

// This will attempt to cast a spell from all the spells we know.
// It calls AI_RunThroughSpells() to work.
// * nLowestSpellLevel - If it is set to more than 1, then all spells of that
//      level and lower are just ignored. Used for dragons. Default 0.
// * nBABCheckHighestLevel - We check our BAB to see if attacking them would probably
//      be a better thing to do. Default 3, it adds 5DC for each level.
// NOTE 1: If GlobalItemsOnly is set, we only check for item talents!
// NOTE 2: It uses the SAME target, but for ranged attacking, we use a float range to check range :-)
int AI_AttemptAllSpells(int nLowestSpellLevel = 0, int nBABCheckHighestLevel = 3)
{
    // Invalid time to cast spells?
    // Checks for valid numbers, ETC.
    if(AI_GetAIHaveEffect(GlobalEffectPolymorph) ||
       GetSpawnInCondition(AI_FLAG_OTHER_LAG_NO_SPELLS, AI_OTHER_MASTER) ||
    // Do we have any spells to cast?
//      (GlobalSilenceSoItems && !GobalOtherItemsValid && !GobalPotionsValid) ||
//      (!SpellAnySpellValid && !GobalOtherItemsValid && !GobalPotionsValid) ||
       !GetIsObjectValid(GlobalSpellTarget) || GetIsDead(GlobalSpellTarget)) // check dead - pok
    {
        // 31: "[DCR: All Spells] Error! No casting (No spells, items, target Etc)."
        //DebugActionSpeakByInt(31);
        return FALSE;
    }
    // 11: "[DCR: All Spells] [Modifier|BaseDC|SRA] " + IntToString(iInput)
    // Input: 100 * GlobalSpellAbilityModifier) + 10 * GlobalSpellBaseSaveDC + SRA
    //DebugActionSpeakByInt(32, OBJECT_INVALID, (100 * GlobalSpellAbilityModifier) + (10 * GlobalSpellBaseSaveDC) + (SRA));

    // All the inputs (plus for SRA a few extra ones) for the spells function
    // we calculate now. SRA is quite common, so useful not to do repetitive
    // code.
    int bRangeLongValid, bRangeMediumValid, bRangeShortValid, bRangeTouchValid,
        bDoneMedium, bDoneShort, bDoneTouch, bSingleSpellsFirst,
        bSingleSpellOverride, bMultiSpellOverride;

    // This forces the use of AOE spells over single target spells.
    bMultiSpellOverride = GetSpawnInCondition(AI_FLAG_COMBAT_MANY_TARGETING, AI_COMBAT_MASTER);
    // This forices the use single target spells before multiple target spells.
    bSingleSpellOverride = GetSpawnInCondition(AI_FLAG_COMBAT_SINGLE_TARGETING, AI_COMBAT_MASTER);

    // if bSingleSpellsFirst == TRUE, we try our single spells before the
    // AOE spells. If false, don't bother. Not set if not seen target.
    // 1.4: More realistic checking. Test:
    // * Must be 4 or less enemies seen to do single ones first
    // * Have to have:
    //   - A lot of allies compared to enemies
    //   - Only one enemy seen
    if(GlobalSeenSpell && GlobalTotalSeenHeardEnemies <= 4 &&
      (GlobalTotalSeenHeardEnemies - 2 <= (GlobalTotalAllies) ||
       GlobalTotalSeenHeardEnemies <= 1))
    {
        bSingleSpellsFirst = TRUE;
    }
    // Else, it might set to TRUE because of the spawn setting for it.
    else if(bSingleSpellOverride)
    {
        // Might be forced via. the setting, to use single target spells before
        // multiple target spells.
        bSingleSpellsFirst = TRUE;
    }

    // Check which ranges are valid
    // - Range: Long 40, Medium: 20, Short: 10, Touch: 2.25 (Game meters). Personal = 0
    // If spell ranged attacking is NOT on, we will always use all ranges.
    if(!SRA)
    {
        bRangeLongValid = TRUE;
        bRangeMediumValid = TRUE;
        bRangeShortValid = TRUE;
        bRangeTouchValid = TRUE;
    }
    // Ranges...
    // If set to TRUE, we will cast spells that use that range.
    // If set to FALSE, we will ignore spells that use that range.
    // First run through!
    else
    {
        // Long
        // * Always (to start with) set this to TRUE
        bRangeLongValid = TRUE;
        // Note: if there was a bDoneLong, it'd always be TRUE

        // Check medium range
        if(GlobalSpellTargetRange <= fMediumRange)
        {
            bRangeMediumValid = TRUE;
            bDoneMedium = TRUE;

            // Check short range
            if(GlobalSpellTargetRange <= fShortRange)
            {
                bRangeShortValid = TRUE;
                bDoneShort = TRUE;

                // Check touch range
                if(GlobalSpellTargetRange <= fTouchRange)
                {
                    bRangeTouchValid = TRUE;
                    bDoneTouch = TRUE;
                }
            }
        }
    }

    // Start by casting them all normally
    // * IE: bFirstRunThrough is TRUE, all ranges valid are as above.
    int bResult = AI_RunThroughSpells(nLowestSpellLevel, nBABCheckHighestLevel, bSingleSpellsFirst, bSingleSpellOverride, bMultiSpellOverride, TRUE, bRangeLongValid, bRangeMediumValid, bRangeShortValid, bRangeTouchValid);

    // If bResult is FALSE, and SRA is ON, we might run it again with medium
    // range now set to TRUE (unles it was already!)
    if(bResult == FALSE && SRA == TRUE)
    {
        // Check if we have done all the ranges.
        if(bDoneMedium && bDoneShort && bDoneTouch)
        {
            // Cannot do any more
            return FALSE;
        }
        else
        {
            // We will now be able to flip medium range.
            if(bDoneMedium == FALSE)
            {
                // Do a new loop. Took out the ones we have already done :-)
                // 34: "[DCR: All Spells] Ranged Spells. Should use closer spells/move nearer"
                DebugActionSpeakByInt(34);
                bDoneMedium = TRUE;
                bResult = AI_RunThroughSpells(nLowestSpellLevel, nBABCheckHighestLevel, bSingleSpellsFirst, bSingleSpellOverride, bMultiSpellOverride, FALSE, FALSE, TRUE);
            }
        }
    }
    // If bResult is FALSE, and SRA is ON, we might run it again with shout range.
    if(bResult == FALSE && SRA == TRUE)
    {
        // Check if we have done all the ranges.
        if(bDoneMedium && bDoneShort && bDoneTouch)
        {
            // Cannot do any more
            return FALSE;
        }
        else
        {
            // We will now be able to flip short range.
            if(bDoneShort == FALSE)
            {
                // Do a new loop. Took out the ones we have already done :-)
                // 34: "[DCR: All Spells] Ranged Spells. Should use closer spells/move nearer"
                DebugActionSpeakByInt(34);
                bDoneShort = TRUE;
                bResult = AI_RunThroughSpells(nLowestSpellLevel, nBABCheckHighestLevel, bSingleSpellsFirst, bSingleSpellOverride, bMultiSpellOverride, FALSE, FALSE, FALSE, TRUE);
            }
        }
    }
    // If bResult is FALSE, and SRA is ON, we might run it again with touch range.
    if(bResult == FALSE && SRA == TRUE)
    {
        // Check if we have done all the ranges.
        if(bDoneMedium && bDoneShort && bDoneTouch)
        {
            // Cannot do any more
            return FALSE;
        }
        else
        {
            // We will now be able to flip short range.
            if(bDoneTouch == FALSE)
            {
                // Do a new loop. Took out the ones we have already done :-)
                // 34: "[DCR: All Spells] Ranged Spells. Should use closer spells/move nearer"
                DebugActionSpeakByInt(34);
                bDoneTouch = TRUE;
                bResult = AI_RunThroughSpells(nLowestSpellLevel, nBABCheckHighestLevel, bSingleSpellsFirst, bSingleSpellOverride, bMultiSpellOverride, FALSE, FALSE, FALSE, FALSE, TRUE);
            }
        }
    }
    // Return bResult.
    return bResult;
}

// Called from AI_AttemptAllSpells, this will run through the spell lists, until
// it casts on, else it will return FALSE.
// * nLowestSpellLevel - If it is set to more than 1, then all spells of that
//      level and lower are just ignored. Used for dragons. Default 0.
// * nBABCheckHighestLevel - We check our BAB to see if attacking them would probably
//      be a better thing to do. Default 3, it adds 5DC for each level.
// * bFirstRunThrough - used for personal spells (cast on us) like the ranged checks, for SRA.
// * bRangeLongValid etc - used for ranged spell attacking. bFirstRunThrough is a personal version.
// See AI_AttemptAllSpells() for more info.
int AI_RunThroughSpells(int nLowestSpellLevel, int nBABCheckHighestLevel, int bSingleSpellsFirst, int bSingleSpellOverride, int bMultiSpellOverride, int bFirstRunThrough = TRUE, int bRangeLongValid = FALSE, int bRangeMediumValid = FALSE, int bRangeShortValid = FALSE, int bRangeTouchValid = FALSE)
{
    // Sets up AOE target object to get.
    object oAOE, oRandomSpellNotUsedAOE, oPurge;
    // (oRandomSpellNotUsedAOE is set when we radomise a spell, and the spell
    //  isn't cast, but could be!)

    // Declare integers
    int nCnt, bBreak, /* Counter things */
        nPercentWhoSeeInvis, nNeedToBeBelow;

    // Saves. Stops them firing spells they would ALWAYs save against.
    // GlobalSpellTargetWill, GobalSpellTargetFort, GlobalSpellTargetReflex.


    // There is also the case of people immune to normal spells (such as
    // Fireball) but not spells like Gaze of Death.
    // - Set to the level of silence we cannot use, BTW.
    // - Set to 10 if we have 90% or more spell failure.
    // - Also includes any globes, ETC.
    // - We use "if(GlobalNormalSpellsNoEffectLevel < 9)" for level 9 spells.
    //GlobalNormalSpellsNoEffectLevel = 1-10. 10 being absolutely nothing.
    //      - EG: Set to 3, means 0, 1, 2, 3 have 0% chance of affecting them.

/*::9999999999999999999999999999999999999999999999999999999999999999999999999999
//::    Level 9 spells.
//::9999999999999999999999999999999999999999999999999999999999999999999999999999
    NOTE ABOUT HOW I DO SPELL LEVELS OF EACH SPELL!
    Because there are spells for several classes, the same spell, such as Wall
    of Fire, I take the MAGE (Sorceror/Wizard) class. This is because it will
    then vary the sorcerors spells he casts. I then, if it is not a Mage spell,
    generally take the lowest spell number (EG: Death Ward, level 4 cleric/bard,
    5 druid, and I'l take it as a level 4). This does not mean it will be cast
    in the bracket for spell level X - especially if it is not a hostile spell.

    H = Hordes only (And I think includes SoU spells)
    S = SoU only

    Protections are important, and are cast sometimes many levels above other
    spells of thier level, like casting Stoneskin before Wail of the Banshee.

    Thoughts -level 9 spells are the powerhouses, or so they say. They are actually
    not...good. Most are death save based, and so many higher-level PC's will
    be immune with there being Death Ward handy/Shadow shield. Some good spells
    however - energy drain is powerful and has maximum save DC, even if it is
    necromantic. Storm of Vengance is a really powerful AOE persistant spell,
    and the damaging spells are not half bad. Also, powerful summons at level 9!

    Epic:
H   [Epic Mage Armor] - +5 of the 4 different AC types. Just +5 dodge is a great asset.
H   [Hellball] - Long range AOE - 10d6 sonic, acid, fire and lightning damage to all in area. Reflex only halves.
H   [Ruin] - 35d6 divine damage, fort save for half.
H   [Mummy Dust] - Powerful summon that cannot be dnSpelled. 24 Hours.
H   [Dragon Knight] - Powerful dragon summon that cannot be dnSpelled. 20 rounds.
H   [Epic Warding] - Damage reduction 50/+20. Lasts 1 round per level.

    AOE:
    [Wail Of the Banshee] - Save VS death (fort) or die. Doesn't affect caster. 10M Range.
    [Wierd] - Save VS Will & Fort. Doesn't affect allies. 10M AOE.
    [Meteor Swarm] - Non-friends in 10M are done with 20d6 damage. Reflex Save.
    [Storm of Vengance] - Anyone in the AOE (10M where cast) gets reflex-electic, and alway-acid damage.
    [Implosion] - +3 Save DC, VS death, medium AOE. Not affect self (but affects anyone else)

    [Modenkainens Disjunction] - Powerful Dispel. VERY powerful - acts like a breach as well!

    Single:
    [Dominate Monster] - Save VS Will else dominated - anything! (3 turns +1 per caster level.)
    [Energy Drain] - Save VS Fort or negative levels - 2d4. If it goes to 0 levels, kills. Also lots of negative stats! (Supernatural Effect)
S   [Bigby's Crushing Hand] - (2d6 + 12 damage/round)

    Defender:
    [Greater Spell Mantal] - Stops spells. d12 + 10
    [Time Stop] - 9 Seconds (Default amount anyway) that we stop everyone but ourselves.
S   [Undeath's Eternal Foe] Stops negative damage, ability score draining, negative levels, immunity poisons, immunity diseases.

    Summon:
    [Gate] - Balor. Short duration, powerful, (has spells) but need prot. From evil.
    [Elemental Swarm] - Great! After one powerful one dies, another is summoned. Greater Elements
    [Summon Creature 9] - Summons a random Elder Elemental. Normally 24HRS duration.
    [Innate Summons] - Almost all innate ones are so easy to cast (no concentration) we cast them here.
            - Summon Celestial (One Will'o'whisp)
            - Summon Mephit    (One Mephit)
            - Summon Slaad     (One red slaad)
            - Summon Tanarri   (One subbucus)
H           - Summon Baatezu   (One Erinyes) (Hordes)
H   [Black Blade of Disaster] - A powerful greatsword fights. Please note: AI abuses the "concentration" rules for it!

    Other:

    These will be cast all the time :-) [Dismissal] is included - a special case
    for any dismissal targets, of course.

    Same with [Haste]/[Mass Haste]. These are almost too good to miss!

S   [Greater Sanctuary (Etherealness)] is a VERY powerful spell - if we cast
        this, we can normally cast defensive spells while invisible - cool :-)
        - We cast quite a few invisible-based spells near the top of our list.

    [Time stop] is a special case - we cast it first if we have 2 or more, cast
    haste, then we are able to cast it again and get the maximum, safe, usage
    out of it.

H   [Crumble] - Constructs only.

    Also note that [Stoneskin] (and variants) are usually cast at an upmost prioritory,
    as mages have bad armor, saves and HP :-)

    Creatures with very powerful enchantments to dispel are dispeled, if they have
    level 5 defenses.

    Harm/Heal are also cast here, to knock out enemies early on (if in range,
    of course)

    Do Prismatic AC bonus adding here
//::99999999999999999999999999999999999999999999999999999999999999999999999999*/

    // No BAB check.

    // Not in time stop
    if(bFirstRunThrough && !GlobalInTimeStop && GlobalIntelligence >= (6 - d4()))
    {
        // We do this once, mind you, when we start at nLastCheckedRange == 4.
        // Get a nearby enemy summon - 10M range.
        oAOE = AI_GetDismissalTarget();
        // Is it valid?
        if(GetIsObjectValid(oAOE))
        {
            // Banishment. Level 6 (Cleric/Innate) 7 (Mage). Destroys outsiders as well as all summons in area around caster (10M)
            if(AI_ActionCastSpell(SPELL_BANISHMENT, OBJECT_SELF, 17, TRUE)) return TRUE;

            // Dismissal is short range anyway. Enemy must be within 5M to be targeted.
            // Dismissal. Level 4 (Bard/Cleric/Innate) 5 (Mage). At a will save (VS DC + 6) destroy summons/familiars/companions in area.
            if(AI_ActionCastSpell(SPELL_DISMISSAL, oAOE, 15, TRUE)) return TRUE;
        }
    }

    // Time Stop - Never casts again in a timestop
    // This will cast it very first if we have 2 or more (Sorceror)
    if(bFirstRunThrough && !GlobalInTimeStop && GlobalIntelligence >= 10 &&
       GetHasSpell(SPELL_TIME_STOP) >= 2)
    {
        // Time Stop. Level 9 (Mage). 9 Seconds (by default. Meant to be 1d4 + 1) of frozen time for caster. Meant to be a rare spell.
        if(AI_ActionCastSpell(SPELL_TIME_STOP, OBJECT_SELF, 19, FALSE)) return TRUE;
    }

    // Special case - Lots of phisical damage requires maximum protectoin.
    // For this, we may even consider visage's to be worth something over stoneskin
    // if we have no stoneskins :-D
    // - We cast this if we have many melee attackers or total attackers.
    // - To save time stop checking, we don't do this in time stop.
    if(GlobalIntelligence >= 7 && !GlobalInTimeStop && bFirstRunThrough &&
       !AI_GetAIHaveSpellsEffect(GlobalHasStoneSkinProtections) &&
       !AI_GetAIHaveSpellsEffect(GlobalHasVisageProtections) &&
       // Formula - IE They do 40 damage, we must be level 10 or less. :-)
       // - As this is mainly for mages, we don't bother about how much HP left.
      (GetAIInteger(AI_HIGHEST_PHISICAL_DAMAGE_AMOUNT) >= GlobalOurHitDice * 4 ||
      // - Do we have anyone in 20M?
      (GlobalRangeToNearestEnemy <= 20.0 &&
      // BAB check as well
       GlobalAverageEnemyBAB >= GlobalOurHitDice / 2)))
    {
        // Stoneskins and so forth first, then visages.

        // We think that Stoneskin (which has /+5) is better then 15/+3
        if(AI_SpellWrapperPhisicalProtections(nLowestSpellLevel)) return TRUE;

        // Visage - lowest of Ethereal (6) however. Ghostly? Don't bother
        if(nLowestSpellLevel <= 6)
        {
            if(AI_SpellWrapperVisageProtections(6)) return TRUE;
        }
    }
    // END phisical protections override check

    // Haste - First. Good one, I suppose. Should check for close (non-hasted)
    // allies, to choose between them.
    if(bFirstRunThrough && !AI_GetAIHaveEffect(GlobalEffectHaste) &&
       !AI_CompareTimeStopStored(SPELL_HASTE, SPELL_MASS_HASTE))
    {
        // I don't want to bother checking for allies for MASS_HASTE because
        // mass haste is a good duration/harder to Dispel compared to haste
        // anyway.
        // - Should this be moved down?
        if(AI_SpellWrapperHasteEnchantments(nLowestSpellLevel)) return TRUE;
    }

    // Now the normal time stop. Power to the lords of time! (sorry, a bit over the top!)
    // - Top prioritory. If you don't want it to cast it first, don't give it to them!
    if(bFirstRunThrough && !GlobalInTimeStop)
    {
        // Time Stop. Level 9 (Mage). 9 Seconds (by default. Meant to be 1d4 + 1) of frozen time for caster. Meant to be a rare spell.
        if(AI_ActionCastSpell(SPELL_TIME_STOP, OBJECT_SELF, 19, FALSE)) return TRUE;
    }

    // Special case - if lots of damage has been done elemetally wise, we will
    // cast elemental protections (if not cast already).
    // - To save time stop checking, we don't do this in time stop.
    // - Only done if 4 or more intelligence.
    if(!AI_GetAIHaveSpellsEffect(GlobalHasElementalProtections) &&
       !GlobalInTimeStop && bFirstRunThrough && GlobalIntelligence >= 4 &&
       // Formula - IE They do 40 damage, we must be level 10 or less. :-)
       // - As this is mainly for mages, we don't bother about how much HP left.
      (GetAIInteger(MAX_ELEMENTAL_DAMAGE) >= GlobalOurHitDice * 4 ||
       // OR last hit was major compared to total HP
       GetAIInteger(LAST_ELEMENTAL_DAMAGE) >= GlobalOurMaxHP/4))
    {
        if(AI_SpellWrapperElementalProtections(nLowestSpellLevel))
        {
            // Reset and return, if we cast something!
            DeleteAIInteger(MAX_ELEMENTAL_DAMAGE);
            return TRUE;
        }
    }
    // END special elemental override check

    // Epic mage armor after specials. Not the best place...
    // +20 AC is good, normally.
    if(bFirstRunThrough && !AI_GetAIHaveSpellsEffect(GlobalHasOtherACSpell))
    {
        // Epic Mage Armor. (Mage only) +5 of the 4 different AC types. Just +5 dodge is a great asset.
        if(AI_ActionUseSpellLikeFeat(FEAT_EPIC_SPELL_MAGE_ARMOUR, SPELL_EPIC_MAGE_ARMOR)) return TRUE;
    }

    // Visibility Protections - going invisible!
    // - We only do this not in time stop
    // - We must be invisible
    // - We must be of a decnt intelligence (5+)
    // - We must make sure we don't already have all the protections listed
    // - We MUST have not run through this once already.
    if(!GlobalInTimeStop && GlobalIntelligence >= 5 && bFirstRunThrough)
    {
        // First, check if we already have any effects.
        // - If we have GlobalEffectEthereal, then we cast all (non-see through)
        if(AI_GetAIHaveEffect(GlobalEffectEthereal) ||
        // - If we have darkness, we'll protect ourselves. (Ultravision or not!)
        //  * We can ultra vision in the override special actions part of the AI.
           AI_GetAIHaveEffect(GlobalEffectDarkness))
        {
            // Do some protection spells. :-)
            // - And on allies!
            if(AI_ActionCastWhenInvisible()) return TRUE;
        }
        // - If we have GlobalEffectInvisible, then we check who can see us.
        //  * If we have the timer Do not hide, and we didn't hide last
        //    turn, then we don't do it.
        else if(AI_GetAIHaveEffect(GlobalEffectInvisible))
        {
            if(!GetObjectSeen(OBJECT_SELF, GlobalMeleeTarget) ||
                GetLocalTimer(AI_TIMER_JUST_CAST_INVISIBILITY))
            {
                // Do some protection spells. :-)
                // - And on allies!
                if(AI_ActionCastWhenInvisible()) return TRUE;
            }
        }
        // Else, no invisibility, so we may well cast it >:-D
        // - Only cast it if we are not a sorceror or bard, or we have not got
        //   cirtain protections (important ones!)
        // - Cast if any class other then bard/sorceror because we get advantages
        //   to use other spells and attacks.
        else if(!GlobalWeAreSorcerorBard ||
                !AI_GetAIHaveSpellsEffect(GlobalHasElementalProtections) ||
                !AI_GetAIHaveSpellsEffect(GlobalHasStoneSkinProtections) ||
                !AI_GetAIHaveSpellsEffect(GlobalHasMantalProtections) ||
                 GlobalOurPercentHP >= 100)
        {
            // Is it a good time? (EG we want to flee, or want more protections :-) ).
            // - Do we HAVE THE SPELLS?!
            // - Are we overwhelmed?
            // - Is the enemy a lot stronger?
            //  * Fleeing that uses this does it in the flee section (not in yet)
            //  * More protections for concentation is done in that section (not in yet)

            // 1. Greater Sanctuary (Etherealness).
            // This is easily the best one there is! always works 100%%%!
            // Etherealness. Total invisibility! Level 6 (Cleric) 8 (Mage) 7 (Innate).
            if(AI_ActionCastSpell(SPELL_ETHEREALNESS, OBJECT_SELF, 17)) return TRUE;
            // Monster ability - Actually called Etherealness.
            if(AI_ActionCastSpell(AI_SPELLABILITY_ETHEREALNESS)) return TRUE;

            // 2. Darkness
            // We cast this hopefully most of the time. We will cast it a lot if we have
            // many melee attackers, else we'll cast it if we have ultravision/trueseeing
            if(GlobalMeleeAttackers >= GlobalOurHitDice / 3 ||
               AI_GetAIHaveEffect(GlobalEffectUltravision) ||
               AI_GetAIHaveEffect(GlobalEffectTrueSeeing) ||
               GetHasSpell(SPELL_DARKVISION) || GetHasSpell(SPELL_TRUE_SEEING))
            {
                // Darkness's
                AI_SpellWrapperDarknessSpells(OBJECT_SELF);
            }
            // 3. Normal invisiblity.
            // We need to make sure it won't be Dispeled by invis purge.
            oPurge = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY,
                                        OBJECT_SELF, 1,
                                        CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN,
                                        CREATURE_TYPE_HAS_SPELL_EFFECT, SPELL_INVISIBILITY_PURGE);
            if(!GetIsObjectValid(oPurge) || GetDistanceToObject(oPurge) > 10.0)
            {
                // Also, we can't go invisible if any enemies who are attacking us,
                // can see us. We also won't if over 50 (or whatever)% of the enemy have got
                // seeing spells.
                // What % though? MORE if we have limited, selected spell (non-sorceror/bard)
                // LESS if we do have other spells to take its place.
                nPercentWhoSeeInvis = AI_GetSpellWhoCanSeeInvis(4);

                // Here, we make sure it is less then 80% for mages, and less then
                // 30% for sorcerors or bards.
                nNeedToBeBelow = 80;
                // Use global
                if(GlobalWeAreSorcerorBard) nNeedToBeBelow = 30;

                if(nPercentWhoSeeInvis <= nNeedToBeBelow + d20())
                {
                    // If within d20 of the needed amount, we do cast improved
                    // invisibility.
                    // Improved Invis - assassin
                    if(AI_ActionUseSpellLikeFeat(FEAT_PRESTIGE_INVISIBILITY_2, SPELLABILITY_AS_IMPROVED_INVISIBLITY))
                    {
                        SetLocalTimer(AI_TIMER_JUST_CAST_INVISIBILITY, 12.0);
                        return TRUE;
                    }
                    // Improved Invis. Level 4 (Bard, Mage). 50% consealment + invisibility.
                    if(AI_ActionCastSpell(SPELL_IMPROVED_INVISIBILITY, OBJECT_SELF, 14, FALSE))
                    {
                        SetLocalTimer(AI_TIMER_JUST_CAST_INVISIBILITY, 12.0);
                        return TRUE;
                    }
                    // Other invisibilities.
                    if(nPercentWhoSeeInvis <= nNeedToBeBelow)
                    {
                        // Invisibility
                        if(AI_SpellWrapperNormalInvisibilitySpells())
                        {
                            SetLocalTimer(AI_TIMER_JUST_CAST_INVISIBILITY, 12.0);
                            return TRUE;
                        }
                    }
                }
            }
        }
    }

    // Massive summoning spells
    // Normally, no...always, these are only owned by intelligent creatures, no
    // need to random cast or anything.
    if(bFirstRunThrough && GlobalCanSummonSimilarLevel <= 12)
    {
        // Dragon Knight - Powerful dragon summon that cannot be dnSpelled. 20 rounds.
        if(AI_ActionUseSpellLikeFeat(FEAT_EPIC_SPELL_DRAGON_KNIGHT, SPELL_EPIC_DRAGON_KNIGHT))
        {
            // Set level to 12
            SetAIInteger(AI_LAST_SUMMONED_LEVEL, 12);
            return TRUE;
        }
    }
    if(bFirstRunThrough && GlobalCanSummonSimilarLevel <= 11)
    {
        // Mummy Dust - Powerful summon that cannot be dnSpelled. 24 Hours.
        if(AI_ActionUseSpellLikeFeat(FEAT_EPIC_SPELL_MUMMY_DUST, SPELL_EPIC_MUMMY_DUST))
        {
            // Set level to 11
            SetAIInteger(AI_LAST_SUMMONED_LEVEL, 11);
            return TRUE;
        }
    }
    // This is POWERFUL!
    if(bFirstRunThrough && GlobalCanSummonSimilarLevel <= 10)
    {
        // Black Blade of Disaster. Level 9 (Mage) A powerful greatsword fights. Please note: AI abuses the "concentration" rules for it!
        if(AI_ActionCastSummonSpell(SPELL_BLACK_BLADE_OF_DISASTER, 19, 10)) return TRUE;
    }

    // If we are in time stop, or no enemy in 4 m, we will buff our appropriate stat.
    // Level 2 spells. GlobalIntelligence >= 6
    // NOte: CHANGE TO RANDOM ROLL, MORE CHANCE AT INT 10
    // Put just above first hostile spells.
    // - Always cast if we have stoneskin effects.
    if((GlobalInTimeStop || GlobalRangeToNearestEnemy > 4.0 ||
        AI_GetAIHaveSpellsEffect(GlobalHasStoneSkinProtections)) &&
       !GlobalIntelligence >= 6 && bFirstRunThrough &&
       !AI_CompareTimeStopStored(SPELL_FOXS_CUNNING, SPELL_OWLS_WISDOM,
                                 SPELL_EAGLE_SPLEDOR))
    {
        if(GlobalOurChosenClass == CLASS_TYPE_WIZARD)
        {
            if(!AI_GetAIHaveSpellsEffect(GlobalHasFoxesCunningSpell) &&
               !AI_CompareTimeStopStored(SPELL_FOXS_CUNNING, SPELL_GREATER_FOXS_CUNNING))
            {
                // Greater first. This provides +2d4 + 1.
                // foxes cunning :-) - No items, innate.
                if(AI_ActionCastSpell(SPELL_GREATER_FOXS_CUNNING)) return TRUE;
                // Lesser one - but we have items for it.
                if(AI_ActionCastSpell(SPELL_FOXS_CUNNING, OBJECT_SELF, 12)) return TRUE;
            }
        }
        else if(GlobalOurChosenClass == CLASS_TYPE_DRUID || GlobalOurChosenClass == CLASS_TYPE_CLERIC)
        {
            if(!AI_GetAIHaveSpellsEffect(GlobalHasOwlsWisdomSpell) &&
               !AI_CompareTimeStopStored(AI_SPELL_OWLS_INSIGHT, SPELL_GREATER_OWLS_WISDOM, SPELL_OWLS_WISDOM))
            {
                // Owls insight is cool - 2x caster level in wisdom = +plenty of DC.
                // Owls Insight. Level 5 (Druid).
                if(AI_ActionCastSpell(AI_SPELL_OWLS_INSIGHT, OBJECT_SELF, 15)) return TRUE;
                // Greater first. This provides +2d4 + 1.
                // owls wisdom :-)
                if(AI_ActionCastSpell(SPELL_GREATER_OWLS_WISDOM)) return TRUE;
                // Lesser one - but we have items for it.
                if(AI_ActionCastSpell(SPELL_OWLS_WISDOM, OBJECT_SELF, 12)) return TRUE;
            }
        }
        else // Monsters probably benifit from this as well.
        {
            if(!AI_GetAIHaveSpellsEffect(GlobalHasEaglesSpledorSpell) &&
               !AI_CompareTimeStopStored(SPELL_GREATER_EAGLE_SPLENDOR, SPELL_EAGLE_SPLEDOR))
            {
                // Greater first. This provides +2d4 + 1.
                // eagles splendor :-)
                if(AI_ActionCastSpell(SPELL_GREATER_EAGLE_SPLENDOR)) return TRUE;
                // Lesser one - but we have items for it.
                if(AI_ActionCastSpell(SPELL_EAGLE_SPLEDOR, OBJECT_SELF, 12)) return TRUE;
            }
        }
    }

    // Special behavnOur: Constructs...
    // - These are bastards, and have either total immunity to spells or massive
    //   SR.
    // - GlobalNormalSpellNoEffectLevel will already be set.
    if(bFirstRunThrough && GlobalIntelligence >= 5 &&
       GlobalSpellTargetRace == CLASS_TYPE_CONSTRUCT)
    {
        // These spells go through any ristances (I mean, "Spell Immunity: Level 9 or lower")

        // Ruin - (Epic) - 35d6 divine damage, fort save for half.
        if(AI_ActionUseSpellLikeFeat(FEAT_EPIC_SPELL_RUIN, SPELL_EPIC_RUIN, GlobalSpellTarget)) return TRUE;

        // Crumble. Level 6 (Druid) - Up to 15d6 damage to a construct.
        if(AI_ActionCastSpell(SPELL_CRUMBLE, GlobalSpellTarget, 16, FALSE)) return TRUE;
    }

    // Cast prismatic AC bonus spell - defective force
    if(!GetHasSpellEffect(AI_SPELLABILITY_PRISMATIC_DEFLECTING_FORCE))
    {
        // Deflecting Force - adds charisma bonus to defeltection AC.
        if(AI_ActionCastSpell(AI_SPELLABILITY_PRISMATIC_DEFLECTING_FORCE)) return TRUE;
    }

    // Try a finger/destruction spell, if their fortitude save is really, really low.
    // Will not use these 2 twice in time stop, as they *should* die instantly
    if(GlobalNormalSpellsNoEffectLevel < 7 && bFirstRunThrough &&
       GetSpawnInCondition(AI_FLAG_COMBAT_IMPROVED_INSTANT_DEATH_SPELLS, AI_COMBAT_MASTER) &&
       GlobalSeenSpell && bRangeShortValid &&
      !AI_CompareTimeStopStored(SPELL_DESTRUCTION, SPELL_FINGER_OF_DEATH))
    {
        // Check low saves, IE always fails, no immunities and no mantals.
        if((GlobalSpellTargetFort + 20) <= (GlobalSpellBaseSaveDC + 7) &&
           !AI_GetSpellTargetImmunity(GlobalImmunityNecromancy) &&
           !AI_GetSpellTargetImmunity(GlobalImmunityDeath) &&
           !AI_GetSpellTargetImmunity(GlobalImmunityMantalProtection))
        {
            // Note: No items, because it will be a much lower save.

            // Destruction, level 7 (Cleric). Fort (Death) for Death if fail, or 10d6 damage if pass.
            if(AI_ActionCastSpell(SPELL_DESTRUCTION, GlobalSpellTarget, 17)) return TRUE;
            // Finger of Death. Leve 7 (Mage). Fort (Death) for death if fail, or d6(3) + nCasterLvl damage if pass.
            if(AI_ActionCastSpell(SPELL_FINGER_OF_DEATH, GlobalSpellTarget, 17)) return TRUE;
        }
    }

    // Now will cast mantal if not got one and nearest enemy is a spellcaster...
    if(GlobalMeleeAttackers <= 1 /*We won't cast it with melee attackers - cast phisicals first*/ &&
      !GlobalInTimeStop && GlobalIntelligence >= 7 && bFirstRunThrough &&
      !AI_GetAIHaveSpellsEffect(GlobalHasMantalProtections) &&
      /* Check for mage classes...spell target only */
      (GetLevelByClass(CLASS_TYPE_WIZARD, GlobalSpellTarget) >= GlobalSpellTargetHitDice/3) &&
      (GetLevelByClass(CLASS_TYPE_SORCERER, GlobalSpellTarget) >= GlobalSpellTargetHitDice/3))
    {
        // Cast mantals, or spell resistance...or Protection from spells.
        if(AI_SpellWrapperMantalProtections()) return TRUE;

        // Protection from spells. Level 7 (Mage), for +8 on all saves (Area effect too!)
        if(AI_ActionCastSpell(SPELL_PROTECTION_FROM_SPELLS, OBJECT_SELF, 17, FALSE)) return TRUE;

        // Spell resistance. Level 5 (Cleric/Druid) 12 + Caster level (no limit) in spell resistance.
        if(AI_ActionCastSpell(SPELL_SPELL_RESISTANCE, OBJECT_SELF, 15, FALSE)) return TRUE;
    }

    if(bFirstRunThrough)
    {
        // Haste for allies
        // - 60% chance of casting. More below somewhere (near stoneskin
        if(AI_ActionCastAllyBuffSpell(6.0, 60, SPELL_MASS_HASTE, SPELL_HASTE)) return TRUE;
        // Ultravision for allies
        // - 90% chance of casting.
        // - Only cast if a valid enemy in darkness is near
        if(GetIsObjectValid(GetNearestCreature(CREATURE_TYPE_HAS_SPELL_EFFECT, SPELL_DARKVISION, OBJECT_SELF, 1, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, CREATURE_TYPE_PERCEPTION, PERCEPTION_HEARD)))
        {
            // Darkvision (Ultravision) but not trueseeing, is cast.
            if(AI_ActionCastAllyBuffSpell(8.0, 90, SPELL_DARKVISION, SPELL_TRUE_SEEING)) return TRUE;
        }
    }
    // Epic killing spells. Hellball is very important to fire off!
    // - We fire this off at the futhest target in 40M

    // Futhest one away.
    if(bFirstRunThrough && GlobalSeenSpell)
    {
        // Hellball. (Epic) Long range AOE - 10d6 sonic, acid, fire and lightning damage to all in area. Reflex only halves.
        // We just use spell target. Tough luck, we probably will be in the AOE
        // whatever target we want!
        if(AI_ActionUseSpellLikeFeat(FEAT_EPIC_SPELL_HELLBALL, SPELL_EPIC_HELLBALL, GlobalSpellTarget)) return TRUE;

        // Ruin - a lot of damage, no SR, and only a half save thing for damage
        if(AI_ActionUseSpellLikeFeat(FEAT_EPIC_SPELL_RUIN, SPELL_EPIC_RUIN, GlobalSpellTarget)) return TRUE;
    }

    // These 3 will not be wasted on mantals.
    if(bFirstRunThrough && GlobalNormalSpellsNoEffectLevel < 9 &&// PW kill is level 9
       !AI_GetSpellTargetImmunity(GlobalImmunityMantalProtection) &&
       !AI_CompareTimeStopStored(SPELL_CLOUDKILL, SPELL_POWER_WORD_KILL, SPELL_CIRCLE_OF_DEATH))
    {
        // INSTANT DEATH SPELLS...if conditions are met.
        // - These will instantly kill a target. It does cheat to do it. Only
        //   does this if set (Not AI intelligence related)
        // Most useful for high-levels not getting killed by much lower levels
        // (EG: Lich getting defeated by a enemy with only knockdown or something)
        if(GetSpawnInCondition(AI_FLAG_COMBAT_IMPROVED_INSTANT_DEATH_SPELLS, AI_COMBAT_MASTER))
        {
            // Cloudkill here - if average HD is < 7
            // Random is < 7, always if under 4
            // Damage, slow, long range. Also, AOE :-)
            if(bRangeLongValid && (GlobalAverageEnemyHD < 4) ||
              ((GlobalAverageEnemyHD < 7) && (d10() < 4)) &&
                GlobalNormalSpellsNoEffectLevel < 5)
            {
                // Cloud Kill. Level 5 (Mage). Kills if under level 7, else acid damage.
                if(AI_ActionCastSpell(SPELL_CLOUDKILL, GlobalSpellTarget, 15, TRUE)) return TRUE;
            }
            // Power Word: Kill
            // If improved, will check HP, else just casts it.
            if(bRangeShortValid && GlobalSpellTargetCurrentHitPoints < 100)
            {
                // Power Word Kill. Level 9 (Mage). If target has less then 100HP, dies.
                if(AI_ActionCastSpell(SPELL_POWER_WORD_KILL, GlobalSpellTarget, 19, TRUE)) return TRUE;
            }
        }
        // Circle of Death
        // CONDITION: Average enemy party hd less than 10
        // This spell only effects level 1-9 people. Good cleaner for lower monsters!
        // Meduim ranged spell.
        if(bRangeMediumValid && GlobalAverageEnemyHD <= 9 &&
           GlobalNormalSpellsNoEffectLevel < 6)
        {
            // Circle of death. Level 6 (Mage). Medium ranged, Large AOE, kills 10HD or less people (to d4(casterlevel)).
            if(AI_ActionCastSpell(SPELL_CIRCLE_OF_DEATH, GlobalSpellTarget, 16, TRUE)) return TRUE;
        }
    }

    if(bFirstRunThrough)
    {
        // Physical Damage Protections (Self)
        // Stoneskins, (Greater, normal) + Premonition provide instant damage reduction.
        if(AI_SpellWrapperPhisicalProtections(nLowestSpellLevel)) return TRUE;
    }


    // Do not check spell resistance (GlobalNormalSpellsNoEffectLevel) here.
    // We only use pulses 80% of the time.
    if(bRangeTouchValid && !GlobalInTimeStop &&
       GlobalSpellTargetRange < fTouchRange && d10() <= 8)
    {
/* These are the pulses. Not much I can be bothered to check for. All good stuff!
 281 | Pulse_Drown - None Constructs, Undeads, Elementals DIE if fail a fort check, DC: 20.
 282 | Pulse_Spores - Soldier Shakes (Disease) is applied to those in the area.
 283 | Pulse_Whirlwind - Large. Reflex DC 14 check, or Knockdown (2 rounds) and d3(HD) Damage.
 284 | Pulse_Fire - Huge. d6(HD) in fire damage. Reflex Save, DC: 10 + HD
 285 | Pulse_Lightning - Huge. d6(HD) in electrical damage. Reflex Save, DC: 10 + HD
 286 | Pulse_Cold - Huge. d6(HD) in cold damage. Reflex Save, DC: 10 + HD
 287 | Pulse_Negative - Large. Heals (Undead) allies. Harms all non-undead. Damage/Heal: d4(HD). Reflex Save, DC: 10 + HD.
 288 | Pulse_Holy - Large. Heals (Non-undead) allies. Harms all undead. Damage/Heal: d4(HD). Reflex Save, DC: 10 + HD.
 289 | Pulse_Death - Large. Death if fail Fort Save, DC: 10 + HD
 290 | Pulse_Level_Drain - 1 Negative Level, if fail Fort Save, DC: 10 + HD.
 291 | Pulse_Ability_Drain_Intelligence - Large. -(HD/5) INT, if fail fort save VS: 10 + HD.
 292 | Pulse_Ability_Drain_Charisma - Large. -(HD/5) CHA, if fail fort save VS: 10 + HD.
 293 | Pulse_Ability_Drain_Constitution - Large. -(HD/5) CON, if fail fort save VS: 10 + HD.
 294 | Pulse_Ability_Drain_Dexterity - Large. -(HD/5) DEX, if fail fort save VS: 10 + HD.
 295 | Pulse_Ability_Drain_Strength - Large. -(HD/5) STR, if fail fort save VS: 10 + HD.
 296 | Pulse_Ability_Drain_Wisdom - Large. -(HD/5) WIS, if fail fort save VS: 10 + HD.
 297 | Pulse_Poison - Varying Poison instantly applied. Check nw_"1"_pulspois.nss, and poison.2da files.
 298 | Pulse_Disease - Varying Save. See diseases.2da, and it is based on the
              race of the caster, below are the diseases applied:
        Vermin = Vermin Madness. Undead = Filth Fever. Outsider = Demon Fever.
        Magical Beast = Soldier Shakes. Aberration = Blinding Sickness.
        ANYTHING ELSE = Mindfire.  */
        for(nCnt = SPELLABILITY_PULSE_DROWN/*281*/; nCnt <= SPELLABILITY_PULSE_DISEASE/*289*/; nCnt++)
        {
            // All innate, so no matter about talents really.
            if(AI_ActionCastSpell(nCnt)) return TRUE;
        }
    }

    // Then harm/heal. (Needs 20 HP, and be challenging to us).
    if((GlobalAverageEnemyHD >= (GlobalOurHitDice - 5)) &&
        GlobalSpellTargetCurrentHitPoints > 20 && bRangeTouchValid &&
       !AI_CompareTimeStopStored(SPELL_HARM, SPELL_MASS_HEAL, SPELL_HEAL) &&
        GlobalNormalSpellsNoEffectLevel < 8)// Mass heal = 8.
    {
        if(GlobalSeenSpell && GlobalSpellTargetRace != RACIAL_TYPE_UNDEAD &&
           GlobalSpellTargetRace != RACIAL_TYPE_CONSTRUCT &&
           GlobalSpellTargetRace != RACIAL_TYPE_INVALID)
        {
            // If we are undead, we make sure we leave at least 1 for our own healing.
            if(GlobalNormalSpellsNoEffectLevel < 6 &&
              (GetRacialType(OBJECT_SELF) != RACIAL_TYPE_UNDEAD ||
               GetHasSpell(SPELL_HARM) >= 2))
            {
                // Harm
                // CONDITION: 6+ hit dice and NOT undead! :) Also checks HP
                // Harm Level 6 (Cleric) 7 (Druid) Makes the target go down to 1d4HP (or heals undead as heal)
                if(AI_ActionCastSpell(SPELL_HARM, GlobalSpellTarget, 16, FALSE)) return TRUE;
            }
        }
        // (Mass) Heal (used as Harm for undead)
        // CONDITION: Undead at 4+ hd. Never casts twice in time stop, and not over 20 HP.
        else if(GlobalSpellTargetRace == RACIAL_TYPE_UNDEAD &&
                GlobalIntelligence >= 7)
        {
            // Really, talent 4, heal area effect, no items are set in this though.
            // Mass Heal. Level 8 (Cleric) 9 (Druid) mass "heal" damage/healing.
            if(AI_ActionCastSpell(SPELL_MASS_HEAL, GlobalSpellTarget, 18, TRUE)) return TRUE;

            // Never use last 2 heals for harming. Level 6 (Cleric) 7 (Druid)
            // - 1.3, changed to 3+ only, because, basically, healing self will
            //   probably be better. Undead and constructs also keep it, it must
            //   be for healing allies.
            if(GlobalSeenSpell && GlobalNormalSpellsNoEffectLevel < 6 &&
               GetHasSpell(SPELL_HEAL) >= 3)
            {
                // Heal. Level 6 (Cleric) 7 (Druid). For undead: As harm, else full healing.
                if(AI_ActionCastSpell(SPELL_HEAL, GlobalSpellTarget, 16)) return TRUE;
            }
        }
    }

    // Power Word: Stun. Special "knock out them" spell.
    // Is not immune to mind spell (I think this is a valid check) and not already stunned.
    // Really, if under < 151 HP to be affected
    // Wierdly, this is considered a "Area effect" spell. Nope - jsut a VERY nice normal one. (I like it!)
    // - We can cast this later. Here, we only cast if low amount of enemies :-D
    if(GlobalSpellTargetCurrentHitPoints <= 150 &&
       GlobalNormalSpellsNoEffectLevel < 7 &&
       GlobalTotalSeenHeardEnemies < 3 && GlobalAverageEnemyHD > 10 &&
       GlobalSeenSpell && bRangeTouchValid &&
      !AI_GetSpellTargetImmunity(GlobalImmunityStun) &&
      !AI_GetSpellTargetImmunity(GlobalImmunityMind) &&
      !AI_CompareTimeStopStored(SPELL_POWER_WORD_STUN))
    {
        // Power Word Stun. Level 7 (Wizard). Stun duration based on HP.
        if(AI_ActionCastSpell(SPELL_POWER_WORD_STUN, GlobalSpellTarget, 17, FALSE)) return TRUE;
    }

    // Elemental shield here, if over 0 melee attackers (and 30% chace) or
    // over 1-4 attackers (level based). Doesn't double cast, and not more then 1 at once.
    if(bFirstRunThrough &&
    // - Checks if we have the effects or not in a second
      ((GlobalMeleeAttackers > (GlobalOurHitDice / 4) ||
       (GlobalMeleeAttackers > 0 && d10() > 6))) &&
       !AI_CompareTimeStopStored(SPELL_ELEMENTAL_SHIELD, SPELL_WOUNDING_WHISPERS,
                                 SPELL_DEATH_ARMOR, SPELL_MESTILS_ACID_SHEATH))
    {
        if(AI_SpellWrapperShieldProtections(nLowestSpellLevel)) return TRUE;
    }

    // Dispel Good spells on the enemy.
    // - Dispel Level 5 here.
    // Basically, level 5 spells are mantals and spell-stoppers, or an alful
    // lot of lower level spells.
    if(AI_ActionAttemptDispel(5, bRangeMediumValid)) return TRUE;

    // Consealment Protections
    // We do displacement then blindness/deafness. We only attempt blindness/deafness
    // if we are not a sorceror/bard mind you.
    if(bFirstRunThrough && !GlobalInTimeStop && // No Consealment in time stop.
       GlobalSeenSpell &&
      !AI_GetAIHaveEffect(GlobalEffectInvisible) &&
      !AI_GetAIHaveSpellsEffect(GlobalHasConsealmentSpells))
    {
        // Imp. Invis and displacement...
        if(AI_SpellWrapperConsealmentEnhancements(OBJECT_SELF, nLowestSpellLevel)) return TRUE;

        // Cast darkness on any enemy in range, if we have ultravision (or its
        // effects)
        // Need range check, with SRA, of course
        if(bRangeLongValid && (AI_GetAIHaveEffect(GlobalEffectUltravision) ||
           AI_GetAIHaveEffect(GlobalEffectTrueSeeing) ||
           GetHasSpell(SPELL_DARKVISION) || GetHasSpell(SPELL_TRUE_SEEING)))
        {
            // Cast at nearest without darkness!
            oAOE = GetNearestCreature(CREATURE_TYPE_DOES_NOT_HAVE_SPELL_EFFECT, SPELL_DARKVISION, OBJECT_SELF, 1, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
            if(GetIsObjectValid(oAOE) && !GetHasSpellEffect(SPELL_TRUE_SEEING, oAOE)
               && !GetHasSpellEffect(SPELL_DARKVISION, oAOE))
            {
                // Darkness
                if(AI_SpellWrapperDarknessSpells(oAOE)) return TRUE;
            }
        }

        // Blindness/deafness. No casting in time stop is simpler.
        if(bRangeMediumValid && GlobalNormalSpellsNoEffectLevel < 8 &&
          !AI_GetSpellTargetImmunity(GlobalImmunityBlindDeaf) &&
          !GlobalWeAreSorcerorBard &&
          !AI_SaveImmuneSpellTarget(SAVING_THROW_FORT, 8))
        {
            // Mass Blindness and Deafness. Level 8 (Mage) AOE fort save, enemies only, who save or are blinded and deafened.
            if(AI_ActionCastSpell(SPELL_MASS_BLINDNESS_AND_DEAFNESS, GlobalSpellTarget, 18, TRUE)) return TRUE;
        }
    }

    // Ally spells. A great variety that we cast above.
    if(bFirstRunThrough)
    {
        // Haste again - 90% chance
        if(AI_ActionCastAllyBuffSpell(6.0, 90, SPELL_MASS_HASTE, SPELL_HASTE)) return TRUE;
        // Cast phisical stoneskins on allies - 80% chance, as it is quite good.
        if(AI_ActionCastAllyBuffSpell(6.0, 80, SPELL_GREATER_STONESKIN, SPELL_STONESKIN)) return TRUE;
        // Consealment spells
        if(AI_ActionCastAllyBuffSpell(6.0, 60, SPELL_IMPROVED_INVISIBILITY, SPELL_DISPLACEMENT)) return TRUE;
    }

    //Gate
    //CONDITION: Protection from Evil active on self
    // Balors rock, literally! If not, I kill dem all!! >:-D
    if(bFirstRunThrough && GlobalCanSummonSimilarLevel <= 10 &&
       AI_GetAIHaveSpellsEffect(GlobalHasProtectionEvilSpell))
    {
        // Gate. Level 9 (Mage/Innate). Summons a balor, who would normally attack caster if not protected from evil, else powerful summon
        if(AI_ActionCastSummonSpell(SPELL_GATE, 19, 10)) return TRUE;
    }

    //Protection from Evil / Magic Circle Against Evil
    // ... in preparation for Gate!
    if(bFirstRunThrough && GetHasSpell(SPELL_GATE) &&
       !AI_GetAIHaveSpellsEffect(GlobalHasProtectionEvilSpell))
    {
        // Magic Circle against Alignment. Level 3 (Mage/Cleric/Bard/Paladin/Innate). +2 AC, mind spell immunity VS them.
        if(AI_ActionCastSpell(SPELL_MAGIC_CIRCLE_AGAINST_EVIL, OBJECT_SELF, 13, FALSE, TRUE)) return TRUE;
        // Protection From Evil. Level 1(Mage/Cleric/Bard/Paladin/Innate). +4 AC, mind spell immunity VS them.
        if(AI_ActionCastSpell(SPELL_PROTECTION_FROM_EVIL, OBJECT_SELF, 11, FALSE, TRUE)) return TRUE;
    }
    // None for allies. Won't bother (unless it is a problem!).
    // - If adding, we will get the nearest without the spells effects.

    // GlobalCanSummonSimilarLevel can be 1-12. (10 is elemental swarm, balor) (11, 12 epic)
    if(bFirstRunThrough && GlobalCanSummonSimilarLevel <= 9)
    {
        // Elemental swarm. Level 9 (Druid) Never replaced until no summon left - summons consecutive 4 huge elementals
        if(AI_ActionCastSummonSpell(SPELL_ELEMENTAL_SWARM, 19, 10)) return TRUE;
        // Summon an eldar elemental.
        if(AI_ActionCastSummonSpell(SPELL_SUMMON_CREATURE_IX, 19, 9)) return TRUE;
        // No-concentration summoned creatures.
        if(AI_ActionCastSummonSpell(AI_SPELLABILITY_SUMMON_BAATEZU, FALSE, 9)) return TRUE;
        if(AI_ActionCastSummonSpell(SPELLABILITY_SUMMON_TANARRI, FALSE, 9)) return TRUE;
        if(AI_ActionCastSummonSpell(SPELLABILITY_SUMMON_SLAAD, FALSE, 9)) return TRUE;
        if(AI_ActionCastSummonSpell(SPELLABILITY_SUMMON_CELESTIAL, FALSE, 9)) return TRUE;
        if(AI_ActionCastSummonSpell(SPELLABILITY_SUMMON_MEPHIT, FALSE, 9)) return TRUE;
        if(AI_ActionCastSummonSpell(SPELLABILITY_NEGATIVE_PLANE_AVATAR, FALSE, 9)) return TRUE;
    }

    // Dominate spells
    // - Dominate monster is level 9. Others are worth casting if valid.
    // Needs to not be immune, and be of right race for DOM PERSON
    // No time stop, and a valid will save to even attempt.
    if(!GlobalInTimeStop && GlobalSeenSpell && bRangeMediumValid &&
       !AI_GetSpellTargetImmunity(GlobalImmunityMind) &&
       !AI_GetSpellTargetImmunity(GlobalImmunityDomination) &&
       (GlobalOurHitDice - GlobalAverageEnemyHD) <= 8)
    {
        // Will save VS mind spells.
        if(GlobalNormalSpellsNoEffectLevel < 9 &&
          !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 9))
        {
            // Dominate Monster. Level 9 (Mage) Dominates (VS. Mind will save) ANYTHING!
            if(AI_ActionCastSpell(SPELL_DOMINATE_MONSTER, GlobalSpellTarget, 19, FALSE)) return TRUE;

            if(GlobalNormalSpellsNoEffectLevel < 5 &&
               !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 5))
            {
                // Dominate person
                if(!GetIsPlayableRacialType(GlobalSpellTarget))
                {
                    // Dominate Person. Level 5 (Mage). Only affects PC races. Dominate on failed will.
                    if(AI_ActionCastSpell(SPELL_DOMINATE_PERSON, GlobalSpellTarget, 15, FALSE)) return TRUE;
                }
                // Mass charm. sorcerors/bards have better things (20% casting chance)
                if(!GlobalWeAreSorcerorBard || d10() <= 2)
                {
                    // For mass charm, we don't bother if they don't have a decent chance to fail (ues as level 5 spell for save DC)
                    // Mass Charm. Level 8 (Mage) 1 Round/2caster levels of charm. Affects PC races only + humanoids.
                    if(AI_ActionCastSpell(SPELL_MASS_CHARM, GlobalSpellTarget, 18, TRUE)) return TRUE;
                }
            }
        }
    }

    // Protection from Spells
    // - CONDITION: Enemies less than 5 levels below me (powerful enemies)
    // - CONDITION 2: At least 1 ally
    // - We cast this lower down if we don't cast it here.
    if(bFirstRunThrough &&
      (((GlobalOurHitDice - GlobalAverageEnemyHD) <= 5 &&
         GlobalValidSeenAlly && GlobalRangeToAlly < 5.0) ||
        ((GlobalOurHitDice - GlobalAverageEnemyHD) <= 10)))
    {
        if(AI_ActionCastSpell(SPELL_PROTECTION_FROM_SPELLS, OBJECT_SELF, 17, FALSE)) return TRUE;
    }

    //Mantle Protections
    //CONDITION: Enemies less than 5 levels below me (powerful enemies)
    // Will chance casting these anyway, if no melee attackers, and the enemy has a valid talent.
    // Yes, talents include items...ahh well.
    if(bFirstRunThrough && ((GlobalOurHitDice - GlobalAverageEnemyHD) <= 5))
    {
        if(AI_SpellWrapperMantalProtections(nLowestSpellLevel)) return TRUE;
    }

    // All these are short-ranged death!
    // - What do we want to cast? Eh? Well, we might as well randomly choose
    //   one of the level 9 main hostile spells. This includes single target spells,
    //   BUT we may use sigle target spells first if not many enemies.

    // - Energy Drain (powerful, lowers statistics)
    // - Bigby's Crushing Hand (2d6 + 12 damage/round)

    // - Storm of vengance is a massive electrical/acid storm. Cast, we may move out later.
    // - Implosion has a +3 fort Save DC (great!) (only medium radius)
    // - Wail of the banshee has a collosal area and 1 save.
    // - Wierd doesn't affect allies, 2 saves, collosal area.
    // - Meteor Storm is like a huge fireball based on the caster, 20d6 damage.

    // Single target spells first check
    if(bSingleSpellsFirst && GlobalNormalSpellsNoEffectLevel < 9)
    {
        // Crushing hand is indefinatly better, but depends...I think energy drain
        // has its merits of being permament! :-D

// Explanation on bigby's spells - hitting, grappling.
// HIT: Beat GetAC(oTarget) with Primary Stat + Caster Level + d20 + 9-11 (7, 8, 9 level spells)
// GRAPPLE: Beat BAB + Size Mod of opposing. d20 + nCasterModifier + Caster Level + 14-16.
// Basically, we won't check this, as the caster level + the 9-11 + primary stat can beat AC.
// Ok, I can't be bothered to check it :-P

        // 70% chance of Crushing Hand.
        // We try and not cast it twice on the same target (for a starter, wasting spells)
        if(bRangeLongValid && !GetHasSpellEffect(SPELL_BIGBYS_CRUSHING_HAND, GlobalSpellTarget))
        {
            // Bigby's Crushing Hand. Level 9 (Mage). 2d6 + 12 damage/round.
            if(AI_ActionCastSpellRandom(SPELL_BIGBYS_CRUSHING_HAND, 60, GlobalSpellTarget, 19, FALSE)) return TRUE;
        }

        if(bRangeShortValid && GlobalSpellTargetRace != RACIAL_TYPE_UNDEAD &&
          !AI_GetSpellTargetImmunity(GlobalImmunityNecromancy) &&
          !AI_SaveImmuneSpellTarget(SAVING_THROW_FORT, 9))
        {
            // 40% chance of energy drain, as we think single target spells are better.
            // Energy Drain. Level 9 (Mage). 2d4 negative levels! -BAB, Saves, Stats! :-)
            if(AI_ActionCastSpellRandom(SPELL_ENERGY_DRAIN, 40, GlobalSpellTarget, 19, FALSE)) return TRUE;
        }

        // Single spell override backup casting
        if(bSingleSpellOverride) if(AI_ActionCastBackupRandomSpell()) return TRUE;
    }

    // AOE targets. Most...but not all...are short-range spells.
    if(bRangeShortValid) // No GlobalNormalSpellsNoEffectLevel for this. AOE spells may affect someone who is not immune!
    {
        // Storm - a very good AOE spell. May as well use here!
        // AOE is 10M across.
        // - May add in elemental protections check.
        // 40% chance (especially as it is only a clerical spell)
        if(!GlobalInTimeStop && GlobalSpellTargetRange < 6.0)
        {
            if(AI_ActionCastSpellRandom(SPELL_STORM_OF_VENGEANCE, 40, OBJECT_SELF, 19, TRUE)) return TRUE;
        }
        // Implosion - great spell! Instant death on a +3 save (!). Short range.
        if(GetHasSpell(SPELL_IMPLOSION))
        {
            // Its save is at 9 + 3 = 12 DC. Death save, and can kill allies not in PvP
            // - Note that because we check natural "globes" in this, the level is set to 9.
            oAOE = AI_GetBestAreaSpellTarget(fShortRange, RADIUS_SIZE_MEDIUM, 9, SAVING_THROW_FORT, SHAPE_SPHERE, GlobalFriendlyFireFriendly, TRUE);
            // If valid, 40% chance of casting this one before others.
            if(GetIsObjectValid(oAOE))
            {
                // Implosion. Level 9 (Cleric). Instant death at +3 save. Note: Medium radius (others are collosal)
                if(AI_ActionCastSpellRandom(SPELL_IMPLOSION, 30, oAOE, 19, TRUE)) return TRUE;
            }
        }
        // Wail of the Banshee
        // Fort save, else death, and it never affects us, but can kill allies.
        if(GetHasSpell(SPELL_WAIL_OF_THE_BANSHEE))
        {
            // Collosal range, fortitude, necromancy and death saves.
            oAOE = AI_GetBestAreaSpellTarget(fShortRange, RADIUS_SIZE_COLOSSAL, 9, SAVING_THROW_FORT, SHAPE_SPHERE, GlobalFriendlyFireFriendly, TRUE, TRUE);
            // If valid, 40% of firing.
            if(GetIsObjectValid(oAOE))
            {
                // Wail of the Banshee. Level 9 (Mage/Innate). Caster cries out, kills everything that cannot save in area affected.
                if(AI_ActionCastSpellRandom(SPELL_WAIL_OF_THE_BANSHEE, 30, oAOE, 19, TRUE)) return TRUE;
            }
        }
        // Weird - item immunity fear? Need to test
        // Never affects allies. Will save type - if the will is always
        // saved, it does nothing at all.
        if(GetHasSpell(SPELL_WEIRD))
        {
            // Get AOE object - this is a small (8M) range, collosal size, doesn't affect allies.
            oAOE = AI_GetBestAreaSpellTarget(fShortRange, RADIUS_SIZE_COLOSSAL, 9, SAVING_THROW_WILL);
            // Is it valid? 40% chance of casting.
            if(GetIsObjectValid(oAOE))
            {
                // Wierd. Level 9 (Wizard/Innate). 2 saves (will/fort) against death. Doesn't kill allies! (Illusion)
                if(AI_ActionCastSpellRandom(SPELL_WEIRD, 30, oAOE, 19, TRUE)) return TRUE;
            }
        }
        //Meteor Swarm
        // CONDITION: Closest enemy 5 ft. (1.5 meters) from me
        // Changed to 10M ... the collosal sized actially used (on self)
        // But only if the enemy is. Removed enemy fire, for now.
        // 40% chance.
        if(GlobalSpellTargetRange < 5.0)
        {
            if(AI_ActionCastSpellRandom(SPELL_METEOR_SWARM, 30, OBJECT_SELF, 19, TRUE)) return TRUE;
        }
    }

    // Multi spell override backup casting
    if(bMultiSpellOverride) if(AI_ActionCastBackupRandomSpell()) return TRUE;

    // Finally, the single target spells again. IE cast them after the AOE ones
    // if we don't choose an AOE one.
    if(GlobalSeenSpell && GlobalNormalSpellsNoEffectLevel < 9)
    {
        // 50% chance of Crushing Hand.
        // We try and not cast it twice on the same target (for a starter, wasting spells)
        if(bRangeLongValid && !GetHasSpellEffect(SPELL_BIGBYS_CRUSHING_HAND, GlobalSpellTarget))
        {
            // Bigby's Crushing Hand. Level 9 (Mage). 2d6 + 12 damage/round.
            if(AI_ActionCastSpellRandom(SPELL_BIGBYS_CRUSHING_HAND, 40, GlobalSpellTarget, 19, FALSE)) return TRUE;
        }

        // Short range, not undead ETC.
        if(bRangeShortValid && !AI_GetSpellTargetImmunity(GlobalImmunityNecromancy) &&
           GlobalSpellTargetRace != RACIAL_TYPE_UNDEAD &&
          !AI_SaveImmuneSpellTarget(SAVING_THROW_FORT, 9))
        {
            // 30% chance of energy drain
            // Energy Drain. Level 9 (Mage). 2d4 negative levels! -BAB, Saves, Stats! :-)
            if(AI_ActionCastSpellRandom(SPELL_ENERGY_DRAIN, 30, GlobalSpellTarget, 19, FALSE)) return TRUE;
        }
    }

    // Backup, obviously, that we might not randomly choose Implision, if it
    // fails the 40% check. Might sitll have the item/spell though!
    if(AI_ActionCastBackupRandomSpell()) return TRUE;

    if(bFirstRunThrough)
    {
        // Finally, we might as well cast that new (SoU) cleric spell which stops
        // many negative effects :-)
        // Undeath's Eternal Foe. Stops negative damage, ability score draining,
        // negative levels, immunity poisons, immunity diseases.
        // Level 9 (Cleric)
        if(AI_ActionCastSpell(SPELL_UNDEATHS_ETERNAL_FOE, OBJECT_SELF, 19, FALSE)) return TRUE;
    }
/*::8888888888888888888888888888888888888888888888888888888888888888888888888888
    Level 8 Spells.
//::8888888888888888888888888888888888888888888888888888888888888888888888888888
    Thoughts - LOTS of AOE spells here for all classes. *shrugs* all good too!
    massive damage and decent saves. Will random cast most of them. Ones for
    Sorcerors that they'll want to random cast are [Sunburst] (100% chance VS undead!)
    [Incendiary Cloud], [Horrid Wilting] (both are decent damage) [Clenched fist].

    AOE:
    [Natures Balance] - -1d4(CasterLevel/5) SR for enemies. 3d8 + Caster Level in healing for allies. Large area. Short range. Druid only.
    [Sunbeam] - Blindness VS Reflex. d6(CasterLevel) divine VS undead, else 3d6 others. ReactionType.
S   [Sun Burst] - Similar to sunbeam. 6d6 to others. Vampires die + all undead d6(Caster level) damage.
S   [Earthquake] - 1d6(caster level) in damage to AOE, except caster.
    [Fire Storm] - 1d6(Caster level) in fire/divine damage. No allies. collosal over caster.
S   [Bombardment] - 1d8(caster level) in fire damage. Like Horrid Wilting. Reflex save/long range/collosal
  X [Mass Charm] - Charm a lot of enemies in an area. Cast above
  X [Mass Blindness/Deafness] - Blind and death on fortitude save. Cast above
    [Incendiary Cloud] - 4d6 Fire damage/round in the large AOE.
    [Horrid Wilting] - d8(CasterLevel) in negative energy. Fort for half. Necromancy.

    Single:
S   [Bigby's Clenched Fist] - Attack Each Round. 1d8 + 12 damage/round. Fort VS stunning as well.

    Defender:
    [Aura Versus Alignment] - d6 + d8 damage shield, 25SR, 4Saves, 4AC, mind immune VS alignemnt
  X [Premonition] - 30/+5 DR. Cast up above this, though.
  X [Mind blank] - Mind immunity/cleansing. Not cast normally, except in invisbility.
S X [Greater Sanctuary (Etherealness)] - Total invisiblity (Bugged I say). Cast above.

    Summon:
    [Create Greater Undead] - Create Vampire, Doom knight, Lich, Mummy Cleric.
    [Summon Creature VIII (8)] - Greater Elemental.
    [Greater Planar Binding] - Death Slaad (Evil) Vrock (Neutral) Trumpet Archon (Good)

    Other:

    Undead are targeted here by undead-specific spells more often the PC's.

    Regenerate is cast if we have damage.

    Gazes (monster gazes) are powerful AOE cone spells. Cast at the taget.
//::88888888888888888888888888888888888888888888888888888888888888888888888888*/

    // Jump out if we don't want to cast level 8 spells/abilities.
    if(nLowestSpellLevel > 8) return FALSE;

    int nEnemyAlignment = GetAlignmentGoodEvil(GlobalSpellTarget);
    if(bFirstRunThrough)
    {
        // Aura Vs. Alignment. d6 + d8 damage shield, 25SR, 4Saves, 4AC, mind immune VS alignemnt
        if(GetAlignmentGoodEvil(GlobalSpellTarget) == ALIGNMENT_EVIL)
        {
            // Holy: Versus Evil. Level 8 (Cleric). Cast as subspell.
            if(AI_ActionCastSpell(SPELL_HOLY_AURA, OBJECT_SELF, 18, FALSE, TRUE)) return TRUE;
        }
        else if(nEnemyAlignment == ALIGNMENT_GOOD)
        {
            // Unholy Holy: Versus Good. Level 8 (Cleric), Cast as subspell.
            if(AI_ActionCastSpell(SPELL_UNHOLY_AURA, OBJECT_SELF, 18, FALSE, TRUE)) return TRUE;
        }
    }

    // Cast regeneration + Natures Balance here if we are lacking HP.
    if(bFirstRunThrough && GlobalOurPercentHP <= 70)
    {
        if(!GetHasSpellEffect(SPELL_REGENERATE))
        {
            // Regeneration. Level 6 (Druid) 7 (Cleric). 6HP/Round. Good for persistant healing.
            if(AI_ActionCastSpell(SPELL_REGENERATE, OBJECT_SELF, 17, FALSE)) return TRUE;
        }
        // Cast at us, might as well.
        // Natures Balance. Level 8 (Druid). Lowers SR of enemies by 1d4(CasterLevel/5) + Healing (3d6 + CasterLevel) for allies.
        if(AI_ActionCastSpell(SPELL_NATURES_BALANCE, OBJECT_SELF, 18, TRUE)) return TRUE;
    }

    // Undead spells. We can cast sunbeam/sunburst (VERY similar!) and Searing Light.
    // We do cast this against non-undead, but later on.
    // We only do this if at 5+ intelligence. Those below are stupid :-)
    if(GlobalSpellTargetRace == RACIAL_TYPE_UNDEAD &&
       GlobalIntelligence >= 5 && GlobalNormalSpellsNoEffectLevel < 8)
    {
        // First, Undead to Death - Slays 1d4HD worth of undead/level.
        //        (Max 20d4). Lowest first.
        // - Will save!
        // - 20M radius (but this we can ignore)
        // - Takes into account all SR and so forth.
        if(GlobalNormalSpellsNoEffectLevel < 6 &&
          !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 6) &&
           bRangeMediumValid)
        {
            // Undead to Death. Level 6 (Cleric) Slays 1d4HD worth of undead/level. (Max 20d4). Lowest first.
            if(AI_ActionCastSpell(SPELL_UNDEATH_TO_DEATH, GlobalSpellTarget, 16, TRUE)) return TRUE;
        }
        // SUNBURST: 6d6 to non-undead. Kills vampires. Blindness. Limit of 25 dice for undead damage. Medium range/colosal size
        // SUNBEAM: 3d6 to non-undead. Blindness. Limit of 20 dice for undead damage. Medium range/colosal size
        // Really silly. Only druids/mages get SunBurst...and druids get Sunbeam anyway!
        // *sigh* Only difference is sunburst has a higher limit for damage, kills
        // vampires, and does 6d6 damage to non-undead, so marginally better.

        // Won't even randomly choose between them. Not worth it.
        if(bRangeShortValid)
        {
            // Sunburst. Level 8 (Druid/Mage) 6d6 to non-undead. Kills vampires. Blindness. Limit of 25 dice for undead damage. Medium range/colosal size
            if(AI_ActionCastSpell(SPELL_SUNBURST, GlobalSpellTarget, 18, TRUE)) return TRUE;
            // Sunbeam. Level 8 (Cleric/Druid) 3d6 to non-undead. Blindness. Limit of 20 dice for undead damage. Medium range/colosal size
            if(AI_ActionCastSpell(SPELL_SUNBEAM, GlobalSpellTarget, 18, TRUE)) return TRUE;

            // If we can't destroy them, dominate them!
            if(GlobalSpellTargetHitDice < GlobalOurChosenClassLevel * 3 &&
               GlobalNormalSpellsNoEffectLevel < 8 && GlobalSeenSpell &&
              !GetIsObjectValid(GetAssociate(ASSOCIATE_TYPE_DOMINATED)))
            {
                // Control undead. Level 6 (Cleric) 7 (Mage). Dominates 1 undead up to 3x Caster level.
                if(AI_ActionCastSpell(SPELL_CONTROL_UNDEAD, GlobalSpellTarget, 17, FALSE)) return TRUE;
            }
        }
        // Medium spell
        if(GlobalNormalSpellsNoEffectLevel < 3 && GlobalSeenSpell)
        {
            // Searing light. Level 3 (Cleric). Full level: 1-10d6 VS undead. Half Level: 1-5d6 VS constructs. 1-5d8 VS Others.
            if(AI_ActionCastSpell(SPELL_SEARING_LIGHT, GlobalSpellTarget, 13, FALSE)) return TRUE;
        }
    }

    // Gazes have short ranges - 80% chance.
    // Why this high? (compared to say, fire storm?) because they are innate
    // and so no concentration checks, and pretty good DC's.
    if(bRangeShortValid && d10() <= 8) // No GlobalNormalSpellsNoEffectLevel check
    {
        // We cast all of these, but randomly. It works through with most powerful
        // getting the highest %'s of course :-)
        if(!AI_GetSpellTargetImmunity(GlobalImmunityDeath))
        {
            // Death gazes first - Golem one is the most deadly!
            // 50% chance of either.
            if(AI_ActionCastSpellRandom(SPELLABILITY_GOLEM_BREATH_GAS, 40, GlobalSpellTarget, FALSE, TRUE)) return TRUE;
            if(AI_ActionCastSpellRandom(SPELLABILITY_GAZE_DEATH, 40, GlobalSpellTarget, FALSE, TRUE)) return TRUE;
        }
        // Petrify - SoU. 50% chance (almost like death!)
        if(!AI_GetSpellTargetImmunity(GlobalImmunityPetrify))
        {
            if(AI_ActionCastSpellRandom(SPELLABILITY_GAZE_PETRIFY, 40, GlobalSpellTarget, FALSE, TRUE)) return TRUE;
        }
        // Destroy X are powerful. 50% chance each. They are basically as DEATH but for alignments.
        if(nEnemyAlignment == ALIGNMENT_GOOD)
        {
            if(AI_ActionCastSpellRandom(SPELLABILITY_GAZE_DESTROY_GOOD, 40, GlobalSpellTarget, FALSE, TRUE)) return TRUE;
        }
        else if(nEnemyAlignment == ALIGNMENT_EVIL)
        {
            if(AI_ActionCastSpellRandom(SPELLABILITY_GAZE_DESTROY_EVIL, 40, GlobalSpellTarget, FALSE, TRUE)) return TRUE;
        }
        if(GetAlignmentLawChaos(GlobalSpellTarget) == ALIGNMENT_CHAOTIC)
        {
            if(AI_ActionCastSpellRandom(SPELLABILITY_GAZE_DESTROY_CHAOS, 40, GlobalSpellTarget, FALSE, TRUE)) return TRUE;
        }
        else if(GetAlignmentLawChaos(GlobalSpellTarget) == ALIGNMENT_LAWFUL)
        {
            if(AI_ActionCastSpellRandom(SPELLABILITY_GAZE_DESTROY_LAW, 40, GlobalSpellTarget, FALSE, TRUE)) return TRUE;
        }
        // Can't be immune to mind
        if(!AI_GetSpellTargetImmunity(GlobalImmunityMind))
        {
            // Fear (and fixed: Added Krenshar Scare) 30%
            if(!AI_GetSpellTargetImmunity(GlobalImmunityFear))
            {
                if(AI_ActionCastSpellRandom(SPELLABILITY_KRENSHAR_SCARE, 30, GlobalSpellTarget, FALSE, TRUE)) return TRUE;
                if(AI_ActionCastSpellRandom(SPELLABILITY_GAZE_FEAR, 30, GlobalSpellTarget, FALSE, TRUE)) return TRUE;
            }
            // Domination/Charm 30%
            if(!AI_GetSpellTargetImmunity(GlobalImmunityDomination))
            {
                if(AI_ActionCastSpellRandom(SPELLABILITY_GAZE_DOMINATE, 30, GlobalSpellTarget, FALSE, TRUE)) return TRUE;
                if(AI_ActionCastSpellRandom(SPELLABILITY_GAZE_CHARM, 30, GlobalSpellTarget, FALSE, TRUE)) return TRUE;
            }
            // Other random mind things
            if(AI_ActionCastSpellRandom(SPELLABILITY_GAZE_PARALYSIS, 30, GlobalSpellTarget, FALSE, TRUE)) return TRUE;
            if(AI_ActionCastSpellRandom(SPELLABILITY_GAZE_STUNNED, 30, GlobalSpellTarget, FALSE, TRUE)) return TRUE;
            if(AI_ActionCastSpellRandom(SPELLABILITY_GAZE_CONFUSION, 30, GlobalSpellTarget, FALSE, TRUE)) return TRUE;
            if(AI_ActionCastSpellRandom(SPELLABILITY_GAZE_DOOM, 30, GlobalSpellTarget, FALSE, TRUE)) return TRUE;
        }
    }

    // Level 8 summons. 20HD or under, or 2 melee enemy and under.
    if(bFirstRunThrough && GlobalCanSummonSimilarLevel <= 8 &&
      (GlobalOurHitDice <= 20 || GlobalMeleeAttackers <= 2))
    {
        // Pale Master's Summon Greater undead
        if(AI_ActionCastSummonSpell(SPELLABILITY_PM_SUMMON_GREATER_UNDEAD, -1, 8, FEAT_SUMMON_GREATER_UNDEAD)) return TRUE;

        // Create Greater Undead. Level 8 (Cleric) Create Vampire, Doom knight, Lich, Mummy Cleric.
        if(AI_ActionCastSummonSpell(SPELL_CREATE_GREATER_UNDEAD, 18, 8)) return TRUE;
        // Summon an Greater elemental. Summon 8 - Druid/Cleric/Bard/Mage.
        if(AI_ActionCastSummonSpell(SPELL_SUMMON_CREATURE_VIII, 18, 8)) return TRUE;
        // Greater Planar Binding. Level 8 (Mage) Death Slaad (Evil) Vrock (Neutral) Trumpet Archon (Good)
        if(AI_ActionCastSummonSpell(SPELL_GREATER_PLANAR_BINDING, 18, 8)) return TRUE;
    }

    // Level 8 general attack spells.
    // Randomly pick one:
// [Sunbeam] - Blindness VS Reflex. d6(CasterLevel) divine VS undead, else 3d6 others. ReactionType.
// [Sun Burst] - Similar to sunbeam. 6d6 to others. Vampires die + all undead d6(Caster level) damage.
// [Earthquake] - 1d6(caster level) in damage to AOE, except caster.
// [Fire Storm] - 1d6(Caster level) in fire/divine damage. No allies. collosal over caster.
// [Bombardment] - 1d8(caster level) in fire damage. Like Horrid Wilting. Reflex save/long range/collosal
// [Incendiary Cloud] - 4d6 Fire damage/round in the large AOE.
// [Horrid Wilting] - d8(CasterLevel) in negative energy. Fort for half. Necromancy.

// Single:
// [Bigby's Clenched Fist] - Attack Each Round. 1d8 + 12 damage/round. Fort VS stunning as well.

    // Is it best to cast Single Spells First?
    // 70% if favourable.
    if(bSingleSpellsFirst && GlobalSeenSpell && GlobalNormalSpellsNoEffectLevel < 8)
    {
        if(!GetHasSpellEffect(SPELL_BIGBYS_CLENCHED_FIST, GlobalSpellTarget) &&
           !AI_CompareTimeStopStored(SPELL_BIGBYS_CLENCHED_FIST) &&
            bRangeLongValid)
        {
            // Bigby's Clenched Fist. Level 8 (Mage) Attack Each Round. 1d8 + 12 damage/round. Fort VS stunning as well.
            if(AI_ActionCastSpellRandom(SPELL_BIGBYS_CLENCHED_FIST, 60, GlobalSpellTarget, 18, FALSE)) return TRUE;
        }
        // No other single spells for level 8.

        // Single spell override backup casting
        if(bSingleSpellOverride) if(AI_ActionCastBackupRandomSpell()) return TRUE;
    }


    // Area of effect spells. Go through - some do have higher %'s then othres.

    // Fire storm - cast on self with a 10M range around caster (circle). 60% chance.
    if(bRangeShortValid && GlobalSpellTargetRange <= 8.0 &&
       GlobalNormalSpellsNoEffectLevel < 8 &&
      !AI_SaveImmuneSpellTarget(SAVING_THROW_REFLEX, 8))
    {
        // Fire storm. Level 8 (Cleric). 1d6(Caster level) in fire/divine damage. No allies. collosal over caster.
        if(AI_ActionCastSpellRandom(SPELL_FIRE_STORM, 50, OBJECT_SELF, 18, TRUE)) return TRUE;
    }
    // Horrid Wilting
    // Never affects allies. Fortitude - necromancy spell too. Lots of damage.
    if(GetHasSpell(SPELL_HORRID_WILTING))
    {
        // Won't cast if got lots of undead. 20M range, huge radius.
        oAOE = AI_GetBestAreaSpellTarget(fMediumRange, RADIUS_SIZE_HUGE, 8, SAVING_THROW_FORT, SHAPE_SPHERE, FALSE, FALSE, TRUE);
        // Is it valid? 60% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Horrid Wilting. Level 8 (Mage). d8(CasterLevel) in negative energy. Fort for half. Necromancy.
            if(AI_ActionCastSpellRandom(SPELL_HORRID_WILTING, 50, oAOE, 18, TRUE)) return TRUE;
        }
    }
    // Bombardment. Similar to the above. Long range, relfex save, not affect allies.
    if(GetHasSpell(SPELL_BOMBARDMENT))
    {
        // 40M range, collosal area. Relfex save.
        oAOE = AI_GetBestAreaSpellTarget(fLongRange, RADIUS_SIZE_COLOSSAL, 8, SAVING_THROW_REFLEX);
        // Is it valid? 60% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Bombardment. Level 8 (Druid) 1d8(caster level) in fire damage. Like Horrid Wilting. Reflex save/long range/collosal
            if(AI_ActionCastSpellRandom(SPELL_BOMBARDMENT, 50, oAOE, 18, TRUE)) return TRUE;
        }
    }
    // Earthquake. No SR, long range, affects anyone except caster.
    if(GetHasSpell(SPELL_EARTHQUAKE))
    {
        // 40M range, collosal area. Relfex save.
        oAOE = AI_GetBestAreaSpellTarget(fLongRange, RADIUS_SIZE_COLOSSAL, 8, SAVING_THROW_REFLEX);
        // Is it valid? 50% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Earthquake] - 1d6(caster level) (to 10d6) in damage to AOE, except caster.
            if(AI_ActionCastSpellRandom(SPELL_EARTHQUAKE, 40, oAOE, 18, TRUE)) return TRUE;
        }
    }
    // Incendiary Cloud. Long range, the AOE is 5.0M across. 4d6Damage/round is quite good.
    if(!AI_CompareTimeStopStored(SPELL_INCENDIARY_CLOUD) &&
        GetHasSpell(SPELL_INCENDIARY_CLOUD))
    {
        // 40M range, lagre (5.0 across) area. Relfex saves.
        oAOE = AI_GetBestAreaSpellTarget(fLongRange, RADIUS_SIZE_LARGE, 8, SAVING_THROW_REFLEX);
        // Is it valid? 50% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Earthquake] - 1d6(caster level) (to 10d6) in damage to AOE, except caster.
            if(AI_ActionCastSpellRandom(SPELL_INCENDIARY_CLOUD, 40, oAOE, 18, TRUE)) return TRUE;
        }
    }
    // Sunbeam and burst. Very similar spells and if they are not undead, then
    // there should be very little chance of casting it.
    // - Won't bother getting nearest undead.
    if(GlobalInTimeStop && bRangeLongValid &&
      (GetHasSpell(SPELL_SUNBEAM) || GetHasSpell(SPELL_SUNBURST)))
    {
        // 40M range, lagre (5.0 across) area. Relfex saves.
        oAOE = AI_GetBestAreaSpellTarget(fLongRange, RADIUS_SIZE_LARGE, 8, SAVING_THROW_REFLEX);
        // Is it valid? 20% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Sunburst. Level 8 (Druid/Mage) 6d6 to non-undead. Kills vampires. Blindness. Limit of 25 dice for undead damage. Medium range/colosal size
            if(AI_ActionCastSpellRandom(SPELL_SUNBURST, 10, oAOE, 18, TRUE)) return TRUE;
            // Sunbeam. Level 8 (Cleric/Druid) 3d6 to non-undead. Blindness. Limit of 20 dice for undead damage. Medium range/colosal size
            if(AI_ActionCastSpellRandom(SPELL_SUNBEAM, 10, oAOE, 18, TRUE)) return TRUE;
        }
    }

    // Multi spell override backup casting
    if(bMultiSpellOverride) if(AI_ActionCastBackupRandomSpell()) return TRUE;

    // Single spells at end
    if(GlobalSeenSpell && GlobalNormalSpellsNoEffectLevel < 8)
    {
        // 40% chance
        if(!GetHasSpellEffect(SPELL_BIGBYS_CLENCHED_FIST, GlobalSpellTarget) &&
           !AI_CompareTimeStopStored(SPELL_BIGBYS_CLENCHED_FIST) &&
            bRangeLongValid)
        {
            // Bigby's Clenched Fist. Level 8 (Mage) Attack Each Round. 1d8 + 12 damage/round. Fort VS stunning as well.
            if(AI_ActionCastSpellRandom(SPELL_BIGBYS_CLENCHED_FIST, 30, GlobalSpellTarget, 18, FALSE)) return TRUE;
        }
        // No other single spells for level 8.

        // Single spell override backup casting
        if(bSingleSpellOverride) if(AI_ActionCastBackupRandomSpell()) return TRUE;
    }

    // Check if we had any of the above we didn't cast based on the %
    if(AI_ActionCastBackupRandomSpell()) return TRUE;

/*::7777777777777777777777777777777777777777777777777777777777777777777777777777
    Level 7 Spells.
//::7777777777777777777777777777777777777777777777777777777777777777777777777777
    Thoughts - well, quite a varied amount of spells. Among classes, there are
    some variety. SoU adds Banishment, and Bigby's. Quite a few death spells
    but note: Word of faith is very effective against 11s and under - stun, for
    under 4's, death!

    Hordes adds Great Thunderclap - requires 3 saves! :-)

    AOE:
S X [Banishment] - Destroys summons (familiars, creatures, spells) to a 2xCasters HD limit.
    [Word of Faith] - Enemies only. 4 Or Down die. 4+ Confuse Stun, Blind. 8+ Stun + Blind. 12+ Only Blind. (1Round/2Casterlevels) outsiders killed.
    [Creeping Doom] - Until 1000 damage, d6 + d6/round stayed in damage in an AOE.
    [Delayed Fireball Blast] - Up to 20d6 fire reflex damage. Can be set up as a trap (heh, nah!)
    [Prismatic Spray] - Random damage/effects. Chance of doing double amount of effects.
H   [Great Thunderclap] - Will VS 1 round stun. Fort VS 1 Turn Deaf. Reflex VS 1 Round Knockdown.

    Single:
    [Distruction] - Short ranged instant death for fort, else take 10d6 Negative energy. Death + Necromantic.
S   [Bigby's Grasping Hand] - Hold target if sucessful grapple
  X [Control Undead] - Yep, controls undead! Dominates them. Cast above near sunbeam.
    [Finger of Death] - Short ranged instant Death on fort else 3d6 negative energy.
    [Power Word, Stun] - Instant stun based on HP of target. Cast above if few targets. Here if more.

    Defender:
    [Aura of Vitality] - +4 STR, CON, DEX for all allies.
    [Protection From Spells] +8 to all saves. Cast above, backup here.
    [Shadow Shield] - Necromancy/negative energy immunity. Some other resistances and some DR.
  X [Spell Mantle] - 1d8 + 8 spells stopped. Cast above (This is good VS anything that casts spells)
    [Regenerate] - 6HP/Round healed. Cast above if damaged. Cast here anyway :-)

    Summon:
    [Summon Monster VII (7)] - Huge elemental
    [Mordenkainen's Sword] - Good, nay, very good hitting summon.

    Other:
  X [Greater Restoration] - Heals lots of effects.
  X [Resurrection] - Resurrection :-) cast on dead people not here.

    Do Palemaster Death touch here. Always use it if they are not immune.
//::77777777777777777777777777777777777777777777777777777777777777777777777777*/

    // Jump out if we don't want to cast level 7 spells.
    if(nLowestSpellLevel > 7) return FALSE;

    // Cast Shadow Shield only first. Good protections really :-)
    // Visages are generally lower DR, with some spell-resisting or effect-immunty extras.

    if(bFirstRunThrough)
    {
        // Shadow Shield - has 10/+3 damage reduction + lots of stuff. Level 7 (Mage)
        if(AI_SpellWrapperVisageProtections(7)) return TRUE;

        // Protection From Spells.
        if(!AI_GetAIHaveSpellsEffect(GlobalHasProtectionSpellsSpell))
        {
            // Protection from spells. Level 7 (Mage), for +8 on all saves (Area effect too!)
            if(AI_ActionCastSpell(SPELL_PROTECTION_FROM_SPELLS, OBJECT_SELF, 17, FALSE)) return TRUE;
        }
    }

    // Palemaster death touch
    // DC 17 + (Pale Master - 10) /2.
    if(bRangeTouchValid && GlobalSeenSpell)
    {
        // Cannot affect creatures over large size
        // - Module switch, but always checked here.
        if(GetCreatureSize(GlobalSpellTarget) <= CREATURE_SIZE_LARGE &&
          !AI_GetSpellTargetImmunity(GlobalImmunityNecromancy) &&
          !AI_GetSpellTargetImmunity(GlobalImmunityDeath) &&
        // Fort save DC 17 + 1 per level over 10 (epic levels). Keep this test.
          GlobalSpellTargetFort <= 16)
        {
            // Use the feat
            if(AI_ActionUseSpellLikeFeat(FEAT_DEATHLESS_MASTER_TOUCH, SPELLABILITY_PM_DEATHLESS_MASTER_TOUCH, GlobalSpellTarget)) return TRUE;
        }
        // Undead graft paralyzes!
        if(GlobalSpellTargetRace !=  RACIAL_TYPE_ELF &&
        // Fort save - 14 + Palemaster levels / 2
          !GlobalSpellTargetFort < (14 + GetLevelByClass(CLASS_TYPE_PALEMASTER)/2))
        {
            // Use the feat
            if(AI_ActionUseSpellLikeFeat(FEAT_UNDEAD_GRAFT_1, SPELLABILITY_PM_UNDEAD_GRAFT_1, GlobalSpellTarget)) return TRUE;
            // 2 versions
            if(AI_ActionUseSpellLikeFeat(FEAT_UNDEAD_GRAFT_2, SPELLABILITY_PM_UNDEAD_GRAFT_2, GlobalSpellTarget)) return TRUE;
        }
    }

    // Hostile spells here.
    // We randomly choose one to cast (with higher %'s for some!)
// AOE:
// [Word of Faith] - Enemies only. 4 Or Down die. 4+ Confuse Stun, Blind. 8+ Stun + Blind. 12+ Only Blind. (1Round/2Casterlevels) outsiders killed.
// [Creeping Doom] - Until 1000 damage, d6 + d6/round stayed in damage in an AOE.
// [Delayed Fireball Blast] - Up to 20d6 fire reflex damage. Can be set up as a trap (heh, nah!)
// [Prismatic Spray] - Random damage/effects. Chance of doing double amount of effects.
// [Great Thunderclap] - Will VS 1 round stun. Fort VS 1 Turn Deaf. Reflex VS 1 Round Knockdown.
// [Stonehold] - AOE - Will Encase people in stone (Paralysis) VS Will Mind throw. (Save each round)
// Single:
// [Distruction] - Short ranged instant death for fort, else take 10d6 Negative energy. Death + Necromantic.
// [Bigby's Grasping Hand] - Hold target if sucessful grapple
// [Finger of Death] - Short ranged instant Death on fort else 3d6 negative energy.
// [Power Word, Stun] - Instant stun based on HP of target. Cast above if few targets. Here if more.

    // Is it best to target with single-target spells first? Most are pretty good :-D
    // 60-70% if favourable.
    if(bSingleSpellsFirst && GlobalSeenSpell && GlobalNormalSpellsNoEffectLevel < 7)
    {
        // Killing spells. These, if sucessful, rend all status-effect spells redundant.
        // - Only fired if they are not immune :-D
        if(bRangeShortValid && !AI_CompareTimeStopStored(SPELL_DESTRUCTION, SPELL_FINGER_OF_DEATH) &&
          !AI_SaveImmuneSpellTarget(SAVING_THROW_FORT, 7) &&
          !AI_GetSpellTargetImmunity(GlobalImmunityNecromancy) &&
          !AI_GetSpellTargetImmunity(GlobalImmunityDeath))
        {
            // Destruction, level 7 (Cleric). Fort (Death) for Death if fail, or 10d6 damage if pass.
            if(AI_ActionCastSpellRandom(SPELL_DESTRUCTION, 60, GlobalSpellTarget, 17, FALSE)) return TRUE;
            // Finger of Death. Level 7 (Mage). Fort (Death) for death if fail, or d6(3) + nCasterLvl damage if pass.
            if(AI_ActionCastSpellRandom(SPELL_FINGER_OF_DEATH, 50, GlobalSpellTarget, 17, FALSE)) return TRUE;
        }
        // Is not immune to mind spell (I think this is a valid check) and not already stunned.
        // Really, if under < 151 HP to be affected - short ranged, and seen.
        if (GlobalSpellTargetCurrentHitPoints <= 150 && bRangeShortValid &&
           !AI_GetSpellTargetImmunity(GlobalImmunityStun) &&
           !AI_GetSpellTargetImmunity(GlobalImmunityMind) &&
           !AI_CompareTimeStopStored(SPELL_POWER_WORD_STUN))
        {
            // Power Word Stun. Level 7 (Wizard). Stun duration based on HP.
            if(AI_ActionCastSpellRandom(SPELL_POWER_WORD_STUN, 60, GlobalSpellTarget, 17, FALSE)) return TRUE;
        }
        // Bigbiy's Grasping hand last. We don't bother checking for grapple checks -
        // they mainly work anyway, if anything. Powerful in its own right, as
        // it holds on a sucessful check.
        if(bRangeLongValid && !GetHasSpellEffect(SPELL_BIGBYS_GRASPING_HAND, GlobalSpellTarget) &&
           !AI_CompareTimeStopStored(SPELL_BIGBYS_GRASPING_HAND) &&
           !AI_GetSpellTargetImmunity(GlobalImmunityStun))
        {
            // Bigby's Grasping Hand. Level 7 (Mage) Hold target if sucessful grapple
            if(AI_ActionCastSpellRandom(SPELL_BIGBYS_GRASPING_HAND, 40, GlobalSpellTarget, 18, FALSE)) return TRUE;
        }
        // Single spell override backup casting
        if(bSingleSpellOverride) if(AI_ActionCastBackupRandomSpell()) return TRUE;
    }

    // AOE spells now.
// [Word of Faith] - Enemies only. 4 Or Down die. 4+ Confuse Stun, Blind. 8+ Stun + Blind. 12+ Only Blind. (1Round/2Casterlevels) outsiders killed.
// [Creeping Doom] - Until 1000 damage, d6 + d6/round stayed in damage in an AOE.
// [Delayed Fireball Blast] - Up to 20d6 fire reflex damage. Can be set up as a trap (heh, nah!)
// [Prismatic Spray] - Random damage/effects. Chance of doing double amount of effects.
// [Great Thunderclap] - Will VS 1 round stun. Fort VS 1 Turn Deaf. Reflex VS 1 Round Knockdown.

    // Word of faith
    // Doesn't hurt allies, will-based save, at the very least blindness :-D Medium range, collosal size
    if(bRangeMediumValid && GetHasSpell(SPELL_WORD_OF_FAITH))
    {
        // 20M medium range, colossal size, will save to deflect.
        oAOE = AI_GetBestAreaSpellTarget(fMediumRange, RADIUS_SIZE_COLOSSAL, 7, SAVING_THROW_WILL);
        // Is it valid? 70% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Word of Faith. Level 7 (Cleric) Enemies only affected. 4 Or Down die. 4+ [Confuse|Stun|Blind]. 8+ [Stun|Blind]. 12+ [Blind]. (1Round/2Casterlevels) outsiders killed.
            if(AI_ActionCastSpellRandom(SPELL_WORD_OF_FAITH, 60, oAOE, 17, TRUE)) return TRUE;
        }
    }
    // Creeping Doom
    // Damage to all in AOE, to 1000 damage. d6(rounds in it) basically. Good AOE spell.
    // Only 50% chance of casting, to not cast too many.
    if(bRangeMediumValid && !GlobalInTimeStop && GetHasSpell(SPELL_CREEPING_DOOM))
    {
        // 20M medium range, we'll say a huge size. No save can stop all damage ;-)
        oAOE = AI_GetBestAreaSpellTarget(fMediumRange, RADIUS_SIZE_HUGE, 7, FALSE, SHAPE_SPHERE, GlobalFriendlyFireFriendly);
        // Is it valid? 50% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Creeping Doom. Level 7 (Druid) Until 1000 damage, d6 + d6/round stayed in damage in an AOE.
            if(AI_ActionCastSpellRandom(SPELL_CREEPING_DOOM, 40, oAOE, 17, TRUE)) return TRUE;
        }
    }
    // Delayed Fireball Blast. Big fireball. Lots of fire damage - reflex saves.
    if(bRangeMediumValid && GetHasSpell(SPELL_DELAYED_BLAST_FIREBALL) &&
      !AI_CompareTimeStopStored(SPELL_DELAYED_BLAST_FIREBALL, SPELL_FIREBALL))
    {
        // 20M medium range, blast is RADIUS_SIZE_HUGE, lower then Fireball, but more deadly (both save + damage)
        oAOE = AI_GetBestAreaSpellTarget(fMediumRange, RADIUS_SIZE_HUGE, 7, SAVING_THROW_REFLEX, SHAPE_SPHERE, GlobalFriendlyFireFriendly);
        // Is it valid? 60% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Delayed Fireball Blast. Level 7 (Mage) Up to 20d6 fire reflex damage. Can be set up as a trap (heh, nah!)
            if(AI_ActionCastSpellRandom(SPELL_DELAYED_BLAST_FIREBALL, 50, oAOE, 17, TRUE)) return TRUE;
        }
    }
    // Great Thunderclap is OK, but doesn't really do too much. If anything, the
    // 3 saves are cool :-P
    if(bRangeMediumValid && !AI_CompareTimeStopStored(SPELL_GREAT_THUNDERCLAP) &&
       GetHasSpell(SPELL_GREAT_THUNDERCLAP))
    {
        // 20M medium range, hits a gargantuan area.
        // - We ignore saves for this.
        // - Doesn't actually hit ourselves. Won't bother checking this though.
        oAOE = AI_GetBestAreaSpellTarget(fMediumRange, RADIUS_SIZE_GARGANTUAN, 7, SAVING_THROW_ALL, SHAPE_SPHERE, GlobalFriendlyFireFriendly);
        // Is it valid? 50% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Great Thunderclap. Level 7 (Mage)  Will VS 1 round stun. Fort VS 1 Turn Deaf. Reflex VS 1 Round Knockdown.
            if(AI_ActionCastSpellRandom(SPELL_GREAT_THUNDERCLAP, 40, oAOE, 17, TRUE)) return TRUE;
        }
    }
    // Lastly, AOE wise, it is prismatic spray. Comparable, if a little (or very!)
    // erratic. We might as well cast this whatever (So if they all are immune
    // to the delay fireballs we have, this does good damage compared to 0!)
    if(bRangeShortValid && !AI_CompareTimeStopStored(SPELL_PRISMATIC_SPRAY) &&
       GetHasSpell(SPELL_PRISMATIC_SPRAY))
    {
        // 8M short range, blast is a cone, and no save. Spell script has fSpread at 11.0
        oAOE = AI_GetBestAreaSpellTarget(fShortRange, 11.0, 7, FALSE, SHAPE_SPELLCONE, GlobalFriendlyFireFriendly);
        // Is it valid? 40% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Prismatic Spray. Level 7 (Mage) Random damage/effects. Chance of doing double amount of effects.
            if(AI_ActionCastSpellRandom(SPELL_PRISMATIC_SPRAY, 30, oAOE, 17, TRUE)) return TRUE;
        }
    }
    // Multi spell override backup casting
    if(bMultiSpellOverride) if(AI_ActionCastBackupRandomSpell()) return TRUE;

    // Level 7 summon spells. Also cast the unique class-based summons (like
    // a blackguards undead, a shadowdancers shadow ETC).
    if(bFirstRunThrough && GlobalCanSummonSimilarLevel <= 7)
    {
        // Always use our feat-based ones (not level dependant) as they increase
        // with level.
        // - Shadow based on level (Shadowdancer Shadow)
        if(AI_ActionCastSummonSpell(SPELL_SUMMON_SHADOW, -1, 7, FEAT_SUMMON_SHADOW)) return TRUE;
        // - Undead warrior (EG: doomknight) based on level
        if(AI_ActionCastSummonSpell(SPELLABILITY_BG_CREATEDEAD, -1, 7, AI_FEAT_BG_CREATE_UNDEAD)) return TRUE;
        // - Shadow based on level
        if(AI_ActionCastSummonSpell(SPELLABILITY_BG_FIENDISH_SERVANT, -1, 7, AI_FEAT_BG_FIENDISH_SERVANT)) return TRUE;
        // Pale master - Summon Undead feat.
        if(AI_ActionCastSummonSpell(SPELLABILITY_PM_SUMMON_UNDEAD, -1, 7, FEAT_SUMMON_UNDEAD)) return TRUE;

        // Then, the normal summons.
        if(GlobalOurHitDice <= 18 || GlobalMeleeAttackers <= 2)
        {
            // Mordenkainen's Sword Level 7 (Mage). Good, nay, very good hitting summon.
            if(AI_ActionCastSummonSpell(SPELL_MORDENKAINENS_SWORD, 17, 7)) return TRUE;

            // Summon Monster VII (7). Level 7 (Cleric, Mage, Druid, etc) Huge elemental
            if(AI_ActionCastSummonSpell(SPELL_SUMMON_CREATURE_VII, 17, 7)) return TRUE;
        }
    }

    // Now, back to single spell targets again.
    if(GlobalSeenSpell && GlobalNormalSpellsNoEffectLevel < 7)
    {
        // Killing spells. These, if sucessful, rend all status-effect spells redundant.
        // - Only fired if they are not immune :-D
        if(bRangeShortValid && !AI_CompareTimeStopStored(SPELL_DESTRUCTION, SPELL_FINGER_OF_DEATH) &&
          !AI_SaveImmuneSpellTarget(SAVING_THROW_FORT, 7) &&
          !AI_GetSpellTargetImmunity(GlobalImmunityNecromancy) &&
          !AI_GetSpellTargetImmunity(GlobalImmunityDeath))
        {
            // Destruction, level 7 (Cleric). Fort (Death) for Death if fail, or 10d6 damage if pass.
            if(AI_ActionCastSpellRandom(SPELL_DESTRUCTION, 30, GlobalSpellTarget, 17, FALSE)) return TRUE;
            // Finger of Death. Leve 7 (Mage). Fort (Death) for death if fail, or d6(3) + nCasterLvl damage if pass.
            if(AI_ActionCastSpellRandom(SPELL_FINGER_OF_DEATH, 20, GlobalSpellTarget, 17, FALSE)) return TRUE;
        }
        // Bigbiy's Grasping hand last. We don't bother checking for grapple checks -
        // they mainly work anyway, if anything. Powerful in its own right, as
        // it holds on a sucessful check.
        if(bRangeLongValid && !GetHasSpellEffect(SPELL_BIGBYS_GRASPING_HAND, GlobalSpellTarget) &&
           !AI_CompareTimeStopStored(SPELL_BIGBYS_GRASPING_HAND) &&
           !AI_GetSpellTargetImmunity(GlobalImmunityStun))
        {
            // Bigby's Grasping Hand. Level 7 (Mage) Hold target if sucessful grapple
            if(AI_ActionCastSpellRandom(SPELL_BIGBYS_GRASPING_HAND, 20, GlobalSpellTarget, 18, FALSE)) return TRUE;
        }
        // Is not immune to mind spell (I think this is a valid check) and not already stunned.
        // Really, if under < 151 HP to be affected - short ranged
        if (GlobalSpellTargetCurrentHitPoints <= 150 && bRangeShortValid &&
           !AI_GetSpellTargetImmunity(GlobalImmunityStun) &&
           !AI_GetSpellTargetImmunity(GlobalImmunityMind) &&
           !AI_CompareTimeStopStored(SPELL_POWER_WORD_STUN))
        {
            // Power Word Stun. Level 7 (Wizard). Stun duration based on HP.
            if(AI_ActionCastSpellRandom(SPELL_POWER_WORD_STUN, 20, GlobalSpellTarget, 17, FALSE)) return TRUE;
        }
    }

    // Backup casting of the level 7 hostle spells, just below the last
    // level 7 summon spells :-)
    if(AI_ActionCastBackupRandomSpell()) return TRUE;

/*::6666666666666666666666666666666666666666666666666666666666666666666666666666
    Level 6 Spells.
//::6666666666666666666666666666666666666666666666666666666666666666666666666666
    Thoughts - a great variety of spells here, from defenses like Greater Stoneskin,
    down to versitile Shades, Flesh to stone and chain lightning. For all classes,
    level 6 spells give the greatest variety.

    Hordes adds a few, as does SoU.

    AOE:
    [Acid Fog] - Acid damage in an AOE, including slow in AOE. 1d6/round in fog.
    [Chain Lightning] - Target enemies only. Up to 20d6 for primary, 10d6 for secondary in reflex electical damage.
  X [Circle of Death] - Under 9HD people save or die. 1d4 creatures/caster leve. Cast above
S   [Isaac's Greater Missile Storm] - !!! To 20 missiles, 2d6 Damage/Missile, hits only enemies in AOE around target. No save!
    [Blade Barrier] - Lots of spikes = Lots of damage. Piercing, relfex saves.
H X [Undead to Death] - Slays 1d4HD worth of undead/level. (Max 20d4). Lowest first.

    Cast as single target:

H   [Evil Blight] - All in a collosal area have a curse (-3 stats) on them. Will save.

    Mobile AOE:

S   [Dirge] - Continual Strength Damage to those in the AOE (Mobile, on self)

    [Greater Dispeling] - Dispels all effects on 1 target, or 1 on an area of targets. (to 15 caster levels)
    [Greater Spell Breach] - Strips 6 protection spells, then lowers SR of target.

    Single:
S   [Bigby's Forceful Hand] - Bullrush to make the target Knockdowned and Dazed all in one.
S   [Flesh to Stone] - Petrifies a target on a fortitude save.
    [Harm] - 1d4 HP left on target, if touch attacked.
S   [Drown] - Up to 90% of current HP damage done. Fort save for none.
H X [Crumble] - 1d6/level damage (to 15d6) only to constructs.

    Defender:
    [Ethereal Visage] - 25% consealment. 20/+3 DR. 0/1/2 spells immune to.
    [Globe of Invulnerability] - Immunity to 4, 3, 2, 1, 0 level spells.
    [Greater Stoneskin] - 20/+5 DR. We cast this here, if we have not got it, to prepare for Premonition going down.
  X [Mass Haste] - Haste for allies in area.

    Summon:
    [Summon Monster VI (6)] - Dire Tiger
    [Planar Binding] - Summons Subbucus (Evil), Hound Arcon (Good), Green Slaad (Neutral). AI won't target outsiders specifically.
    [Create Undead] - Creates a lowish undead to aid the caster.
    [Planar Ally] - Waoh! Same as planar binding! Exactly! :-) (except no stopping outsiders)

    Other:
XXXX[Legend Lore] - Lots of lore. Never cast.
  X [Shades] - Offense and defense spells. NPC's can cast these right now. Cast same time as normal versions
  X [Stone to Flesh] - Un-petrifies a target.
  X [Tenser's Transformation] - Uses polymorph, so cast after spells. Massive HP boost and BAB boost.
  X [True Seeing] - See invisible creatures/hidden ones (thats a bug) meant to stop illusions. Cast in special cases.
  X [Heal] - Heals all damage/harms undead.
  X [Healing Circle] - Heals damage as critcal wounds in an AOE.

    Note that there are some monster abilities - the howl attacks, here.
    Sorta like pulses, 80% chance to check them, that sort of thing :-D

    We also cast visage protections here. Ghoslty, no, not until level 3 spells.

    We also cast, as a starter, elemental protections :-)

    We check if we can cast Golem Ranged Slam here too.

    Trying to do dragon diciple breath too! :-)

    Hag horrific eye, from the hag in 1.62, added in as well.
//::66666666666666666666666666666666666666666666666666666666666666666666666666*/

    // Jump out if we don't want to cast level 6 spells.
    if(nLowestSpellLevel > 6) return FALSE;

    if(bFirstRunThrough)
    {
        // Best elemental protection (maybe % chance here...and later do it 100%)
        if(AI_SpellWrapperElementalProtections(nLowestSpellLevel)) return TRUE;

        // Visage - eathereal :-)
        // Ethereal Visage. Level 6 (Mage) 25% consealment. 20/+3 DR. 0/1/2 spells immune to.
        if(AI_SpellWrapperVisageProtections(6)) return TRUE;

        // Globe of Invunrability. We cast minor globe if we have under 10HD (Else we'll try
        // it lower down anyway)
        if(GlobalOurHitDice <= 10)
        {
            if(AI_SpellWrapperGlobeProtections(nLowestSpellLevel)) return TRUE;
        }
        else
        {
            if(AI_SpellWrapperGlobeProtections(6)) return TRUE;
        }

        // Cast Greater Stoneskin if not got the specific greater stoneskin spell
        // because we want to prepare for premonition going down, and we must have
        // checked all level 7, 8 and 9 spells anyway
        if(!GetHasSpellEffect(SPELL_GREATER_STONESKIN))
        {
            // Then, greater stoneskin protects a lot of damage -
            // Greater Stoneskin. Level 6 (Mage) 7 (druid) 20/+5 phiscial damage reduction
            if(AI_ActionCastSpell(SPELL_GREATER_STONESKIN, OBJECT_SELF, 16, FALSE)) return TRUE;
        }
    }

    // Dispel level 4 protections (Hastes, regenerates, tensors...)
    if(AI_ActionAttemptDispel(4, bRangeMediumValid)) return TRUE;

    if(bFirstRunThrough)
    {
        // Cast more buff spells
        // Buffing spells (energy buffer and downwards)
        // 40% chance.
        if(AI_ActionCastAllyBuffSpell(6.0, 40, SPELL_ENERGY_BUFFER, SPELL_PROTECTION_FROM_ELEMENTS, SPELL_RESIST_ELEMENTS, SPELL_ENDURE_ELEMENTS)) return TRUE;
    }

    // Dirge.
    // - Cast always, basically. Boring :-) but its an OK spell
    if(bFirstRunThrough && !GetHasSpellEffect(SPELL_DIRGE))
    {
        // Dirge. Level 6 (Bard). Continual Strength Damage to those in the AOE (Mobile, on self)
        if(AI_ActionCastSpell(SPELL_DIRGE, GlobalSpellTarget, 15, FALSE)) return TRUE;
    }

    // Golem ranged slam. 80% chance of using.
    if(bRangeLongValid && GlobalSeenSpell && d10() <= 8)
    {
        // Golem Ranged Slam. Long ranged, Random(30) + 30 Blud damage. Can do knockdown too.
        if(AI_ActionCastSpell(AI_SPELLABILITY_GOLEM_RANGED_SLAM, GlobalSpellTarget)) return TRUE;
    }

    // Evil eye. DC 11 Fort save, or big ability damage. 60% chance of casting.
    if(bRangeShortValid && GlobalSeenSpell && GlobalSpellTargetFort <= 30 && d10() <= 6)
    {
        // Evil eye, short range. 5 ability damage to str. and con., and 1/5 possibly of doing all 6 damage. Fort for none (DC 11)
        if(AI_ActionCastSpell(SPELLABILITY_SEAHAG_EVILEYE, GlobalSpellTarget)) return TRUE;
    }

    // Dragon Diciple breath.
    if(bRangeTouchValid &&
       // Reflex save. 19 + 1 per 4 levels after 10.
       GlobalSpellTargetReflex < (19 + (GetLevelByClass(CLASS_TYPE_DRAGONDISCIPLE) - 10)/4))
    {
        // Dragon diciple breath - x2_s2_descbreath
        if(AI_ActionUseSpellLikeFeat(FEAT_DRAGON_DIS_BREATH, AI_SPELLABILITY_DIS_BREATH, GlobalSpellTarget)) return TRUE;
    }

    // Howl! HOOOOOOOOWWWWWWWWWWWLLLLLLLLL! Collosal range on self.
    // Most are decent enough to cast as level 6 spells, centred on self, 80% chance to cast.
    // We also randomly choose one (and always cast one if we can cast one :-) )
    if(bRangeTouchValid && GlobalSeenSpell && d10() <= 8)
    {
        // We cast all of these, but randomly. It works through with most powerful
        // getting the highest %'s of course :-)
        if(!AI_GetSpellTargetImmunity(GlobalImmunityDeath))
        {
            // 50% chance of death howl.
            if(AI_ActionCastSpellRandom(SPELLABILITY_HOWL_DEATH, 40)) return TRUE;
        }
        // Sonic damage is powerful - 40%
        // Fortitude save or sonic damage d6(HD/4) :-)
        if(AI_ActionCastSpellRandom(SPELLABILITY_HOWL_SONIC, 30)) return TRUE;

        // Can't be immune to mind for most of the rest
        if(!AI_GetSpellTargetImmunity(GlobalImmunityMind))
        {
            // Mind blast
            if(AI_ActionCastSpellRandom(AI_SPELLABILITY_MINDFLAYER_MINDBLAST_10, 20)) return TRUE;
            // Other one
            if(AI_ActionCastSpellRandom(AI_SPELLABILITY_MINDFLAYER_PARAGON_MINDBLAST, 20)) return TRUE;
            // Other one 2
            if(AI_ActionCastSpellRandom(AI_SPELLABILITY_PSIONIC_MASS_CONCUSSION, 20)) return TRUE;

            // Fear howl. 40% chance
            if(!AI_GetSpellTargetImmunity(GlobalImmunityFear))
            {
                if(AI_ActionCastSpellRandom(SPELLABILITY_HOWL_FEAR, 20)) return TRUE;
            }
            // Paralisis and daze (mind effects, and stunning ones)
            if(!AI_GetSpellTargetImmunity(GlobalImmunityStun))
            {
                if(AI_ActionCastSpellRandom(SPELLABILITY_HOWL_PARALYSIS, 20)) return TRUE;
                if(AI_ActionCastSpellRandom(SPELLABILITY_HOWL_DAZE, 20)) return TRUE;
            }
        }
        // Doom last. -X's amounts of stats. Also note, don't cast if already
        // affected :-)
        if(!GetHasSpellEffect(SPELLABILITY_HOWL_DOOM))
        {
            if(AI_ActionCastSpellRandom(SPELLABILITY_HOWL_DOOM, 20)) return TRUE;
        }

        // Harpy song.
        if(AI_ActionCastSpellRandom(AI_SPELLABILITY_HARPYSONG, 20)) return TRUE;

        // Finally, if we got the 80% chance of using one, and none of them
        // random cast, backup with this.
        if(AI_ActionCastBackupRandomSpell()) return TRUE;
    }

    // Now, randomish attack spells we possess.
// AOE:
// [Acid Fog] - Acid damage in an AOE, including slow in AOE. 1d6/round in fog.
// [Chain Lightning] - Target enemies only. Up to 20d6 for primary, 10d6 for secondary in reflex electical damage.
// [Isaac's Greater Missile Storm] - !!! To 20 missiles, 2d6 Damage/Missile, hits only enemies in AOE around target. No save!
// [Blade Barrier] - Lots of spikes = Lots of damage. Piercing, relfex saves.

// Single:
// [Bigby's Forceful Hand] - Bullrush to make the target Knockdowned and Dazed all in one.
// [Flesh to Stone] - Petrifies a target on a fortitude save.
// [Harm] - 1d4 HP left on target, if touch attacked.
// [Drown] Up to 90% of current HP damage done. Fort save for none.
// [Evil Blight] - All in a collosal area have a curse (-3 stats) on them. Will save.

    // Is it best to target with single-target spells first? Flesh to stone
    // alone makes single target level 6 spells decent enough :-)
    // 60-70% if favourable.
    if(bSingleSpellsFirst && GlobalSeenSpell && GlobalNormalSpellsNoEffectLevel < 6)
    {
        // Drown! We don't do this if they are under 30HP already.
        // 80% chance to cast if we have it, and not immune to the save.
        if(bRangeMediumValid && !AI_CompareTimeStopStored(SPELL_DROWN) &&
          !AI_SaveImmuneSpellTarget(SAVING_THROW_FORT, 6) &&
           GlobalSpellTargetCurrentHitPoints >= 30)
        {
            // Drown. level 6 (Druid) Up to 90% of current HP damage done. Fort save for none.
            if(AI_ActionCastSpellRandom(SPELL_DROWN, 70, GlobalSpellTarget, 16, FALSE)) return TRUE;
        }
        // Flesh to Stone is a good spell - petrify attack.
        // 70% chance to cast if we have it, and not immune to the save.
        if(bRangeMediumValid && !AI_CompareTimeStopStored(SPELL_FLESH_TO_STONE) &&
          !AI_GetSpellTargetImmunity(GlobalImmunityPetrify) &&
          !AI_SaveImmuneSpellTarget(SAVING_THROW_FORT, 6))
        {
            // Flesh to Stone. - Petrifies a target on a fortitude save.
            if(AI_ActionCastSpellRandom(SPELL_FLESH_TO_STONE, 60, GlobalSpellTarget, 16, FALSE)) return TRUE;
        }
        // Evil Blight. This is an AOE curse, but note that we cannot check
        // if an AOE already has it.
        if(bRangeMediumValid && !AI_CompareTimeStopStored(AI_SPELL_EVIL_BLIGHT) &&
          !AI_GetSpellTargetImmunity(GlobalImmunityCurse) &&
          !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 6))
        {
            // Evil Blight. Level 6 (Mage) -3 Curse to all in AOE (Will save)
            if(AI_ActionCastSpellRandom(AI_SPELL_EVIL_BLIGHT, 60, GlobalSpellTarget, 16, FALSE)) return TRUE;
        }
        // Bigby's Forceful hand. No need to check for bullrush attack. It
        // will knockdown and daze a target :-) Quite powerful as no save.
        // (Count as stun for immunity - that is anyting that stops them moving (daze included))
        // - Should affect mind-immune people. Bioware will fix this, been told. No mind check
        if(bRangeLongValid && !GetHasSpellEffect(SPELL_BIGBYS_FORCEFUL_HAND, GlobalSpellTarget) &&
           !AI_CompareTimeStopStored(SPELL_BIGBYS_FORCEFUL_HAND) &&
           !AI_GetSpellTargetImmunity(GlobalImmunityStun))
        {
            // Bigby's Forceful Hand. Level 6 (Mage) Bullrush to make the target Knockdowned and Dazed all in one.
            if(AI_ActionCastSpellRandom(SPELL_BIGBYS_FORCEFUL_HAND, 30, GlobalSpellTarget, 16, FALSE)) return TRUE;
        }
        // Single spell override backup casting
        if(bSingleSpellOverride) if(AI_ActionCastBackupRandomSpell()) return TRUE;
    }
    // AOE spells - including the now-infamous Isaac's Greater Missile Storm!
// [Acid Fog] - Acid damage in an AOE, including slow in AOE. 1d6/round in fog.
// [Chain Lightning] - Target enemies only. Up to 20d6 for primary, 10d6 for secondary in reflex electical damage.
// [Isaac's Greater Missile Storm] - !!! To 20 missiles, 2d6 Damage/Missile, hits only enemies in AOE around target. No save!
// [Blade Barrier] - Lots of spikes = Lots of damage. Piercing, relfex saves.

    // Isaac's Greater Missile Storm - only hits enemies, targeted on an area
    // around the caster, lots of missiles which do 2d6 MAGICAL energy each!!!
    // Ok, this is sad, but because it goes well targeting many, or one target,
    // we will target this at the spell target regardless of range (which is
    // long anyway!) or better (more in AOE) targets. 80% chance of casting.
    // Cast at ground.

    if(bRangeLongValid && GlobalSeenSpell && GlobalNormalSpellsNoEffectLevel < 6)
    {
        // Isaac's Greater Missile Storm. Level 6 (Mage) !!! To 20 missiles, 2d6 Damage/Missile, hits only enemies in AOE around target. No save!
        if(AI_ActionCastSpellRandom(SPELL_ISAACS_GREATER_MISSILE_STORM, 70, GlobalSpellTarget, 16, TRUE)) return TRUE;
    }

    // Chain lightning is a decent-damage, no, good-damage spell, like fireball,
    // but a better way - it damages all enemies only :-D
    // Because it damages enemies only, we aim it at the current spell target,
    // because it needs a target (and it must be a seen one!)
    if(bRangeLongValid && GlobalSeenSpell &&
      !AI_CompareTimeStopStored(SPELL_CHAIN_LIGHTNING) &&
      !AI_SaveImmuneSpellTarget(SAVING_THROW_REFLEX, 6))
    {
        // Collosal area, long range, reflex throw. 60% chance of casting.
        // Chain Lightning. Level 6 (Mage). Target enemies only. Up to 20d6 for primary, 10d6 for secondary in reflex electical damage.
        if(AI_ActionCastSpellRandom(SPELL_CHAIN_LIGHTNING, 50, GlobalSpellTarget, 16, FALSE)) return TRUE;
    }
    // Blade Barrier - lots of damage, up to 20d6 damage to targets :-)
    // Wierd shape, however. It is 2M across one way, but 10M long, retangle.
    // We just target a large (5.0) area, and as long as it hits an enemy object,
    // it is great!
    if(bRangeMediumValid && !AI_CompareTimeStopStored(SPELL_BLADE_BARRIER) &&
       GetHasSpell(SPELL_BLADE_BARRIER))
    {
        // 20M medium range, large area we'll say. Reflex save
        oAOE = AI_GetBestAreaSpellTarget(fMediumRange, RADIUS_SIZE_LARGE, 6, SAVING_THROW_REFLEX);
        // Is it valid? 50% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Blade Barrier. Level 6 (Cleric) Lots of spikes = Lots of damage (to 20d6). Piercing, relfex saves.
            if(AI_ActionCastSpellRandom(SPELL_BLADE_BARRIER, 40, oAOE, 16, TRUE)) return TRUE;
        }
    }

    // Level 6 summons
    if(bFirstRunThrough && GlobalCanSummonSimilarLevel <= 6 &&
      (GlobalOurHitDice <= 16 || GlobalMeleeAttackers <= 2))
    {
        // Summon Monster VI (6). Level 6 (Most classes) Dire Tiger
        if(AI_ActionCastSummonSpell(SPELL_SUMMON_CREATURE_VI, 16, 6)) return TRUE;
        // Planar Binding. Level 6 (Mage). Summons Subbucus (Evil), Hound Arcon (Good), Green Slaad (Neutral). AI won't target outsiders specifically.
        if(AI_ActionCastSummonSpell(SPELL_PLANAR_BINDING, 16, 6)) return TRUE;
        // Create Undead. Level 6 (Cleric) 8 (Mage). Creates a lowish undead to aid the caster.
        if(AI_ActionCastSummonSpell(SPELL_SUMMON_CREATURE_VI, 16, 6)) return TRUE;
        // Planar Ally. Level 6 (Cleric) - Waoh! Same as planar binding! Exactly! :-) (except no stopping outsiders)
        if(AI_ActionCastSummonSpell(SPELL_PLANAR_ALLY, 16, 6)) return TRUE;
    }

    // Multi spell override backup casting
    if(bMultiSpellOverride) if(AI_ActionCastBackupRandomSpell()) return TRUE;

    // Lastly, the single-target spells again :-)
    if(GlobalSeenSpell && GlobalNormalSpellsNoEffectLevel < 6)
    {
        // Flesh to Stone is a good spell - petrify attack.
        // 50% chance to cast if we have it, and not immune to the save.
        if(bRangeMediumValid && !AI_CompareTimeStopStored(SPELL_FLESH_TO_STONE) &&
          !AI_GetSpellTargetImmunity(GlobalImmunityPetrify) &&
          !AI_SaveImmuneSpellTarget(SAVING_THROW_FORT, 6))
        {
            // Flesh to Stone. - Petrifies a target on a fortitude save.
            if(AI_ActionCastSpellRandom(SPELL_FLESH_TO_STONE, 40, GlobalSpellTarget, 16, FALSE)) return TRUE;
        }
        // Evil Blight. This is an AOE curse, but note that we cannot check
        // if an AOE already has it.
        if(bRangeMediumValid && !AI_CompareTimeStopStored(AI_SPELL_EVIL_BLIGHT) &&
          !AI_GetSpellTargetImmunity(GlobalImmunityCurse) &&
          !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 6))
        {
            // Evil Blight. Level 6 (Mage) -3 Curse to all in AOE (Will save)
            if(AI_ActionCastSpellRandom(AI_SPELL_EVIL_BLIGHT, 30, GlobalSpellTarget, 16, FALSE)) return TRUE;
        }
        // Bigby's Forceful hand. No need to check for bullrush attack. It
        // will knockdown and daze a target :-) Quite powerful as no save.
        // (Count as stun for immunity - that is anyting that stops them moving (daze included))
        // - Should affect mind-immune people. Bioware will fix this, been told. No mind check
        if(bRangeLongValid && !GetHasSpellEffect(SPELL_BIGBYS_FORCEFUL_HAND, GlobalSpellTarget) &&
           !AI_CompareTimeStopStored(SPELL_BIGBYS_FORCEFUL_HAND) &&
           !AI_GetSpellTargetImmunity(GlobalImmunityStun))
        {
            // Bigby's Forceful Hand. Level 6 (Mage) Bullrush to make the target Knockdowned and Dazed all in one.
            if(AI_ActionCastSpellRandom(SPELL_BIGBYS_FORCEFUL_HAND, 20, GlobalSpellTarget, 16, FALSE)) return TRUE;
        }
    }

    // % casting recast again, before next set
    if(AI_ActionCastBackupRandomSpell()) return TRUE;

    // Acid fog - slow, and damage in acid fog.
    // Decent..but ...well, its alright :-)
    // THIS is spell 0 spell :-) we cast 100% and no backup casting.
    if(bRangeLongValid && !GlobalInTimeStop && GetHasSpell(SPELL_ACID_FOG))
    {
        // 40M spell range, 5M radius (large) fortitude save, but doesn't stop damage.
        oAOE = AI_GetBestAreaSpellTarget(fLongRange, RADIUS_SIZE_LARGE, 6);
        // Is it valid? 40% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Acid Fog. Level 6 (Mage) Acid damage in an AOE, including slow in AOE. 1d6/round in fog.
            if(AI_ActionCastSpell(SPELL_ACID_FOG, oAOE, 16, TRUE)) return TRUE;
        }
    }

/*::5555555555555555555555555555555555555555555555555555555555555555555555555555
    Level 5 Spells.
//::5555555555555555555555555555555555555555555555555555555555555555555555555555
    Thoughts - A good variety of AOE spells, but lacking good single target spells
    generally. Of course, some spells are cast at different levels :-P . Slay
    living is probably the lowest Save-Or-Die spell, while the rest give decent
    damage (AOE spells that is). Some specilist spells include Mind Fog and
    Feeble Mind :-)

    AOE:
    [Cloudkill] - Acid damage, and kills level 7s or below. AOE.
    [Cone of Cold] - Cone of damage, up to 15d6 to those in the cone. Reflex for none.
  X [Dismissal] - Destroys summons in AOE against a will save + 6DC. Cast above
S   [Firebrand] - Missile storm - hits enemies up to caster level (max 15) for 1d6 fire reflex damage.
    [Mind Fog] - Minus 10 to all will saves within the AOE.
    [Circle of Doom] - 1d8 + 1/caster level in negative damage
    [Flame Strike] - Up to 15d6 in Fire + Divine damage. Reflex based. Medium area.
H   [Ball Lightning] - 1d6/missile, to 15 missiles. Reflex based. Cast at singal target (like missile storms)
HXXX[Vine mine] - Entangle, 50% movement, or Camoflage. Note: Not cast ever! Stupid spell!

    [Battletide] - +2 Save/Attack/Damage to cast. -2 to enemies who enter. Mobile AOE on self.

    Single:
S   [Bigby's Interposing Hand] -10 to hit for 1 target.
  X [Dominate Person] - Dominates 1 humanoid person. Cast above
    [Feeblemind] - 1d4/4 caster levels in intelligence decrease, if fail will save.
    [Hold Monster] - Paralyze's an enemy monster (any race)
    [Slay Living] - Touch attack + Fortitude Save, creature dies, else d6(3) negative damage.
H   [Inferno] - 2d6 Fire damage/round like acid arrow. No save, only SR.

    Defender:
    [Energy Buffer] - 40/- elemental resistance to Cold, Acid, Fire, Sonic and electicity, to 60 damage total.
  X [Lesser Spell Mantle] - 1d4 + 6 spells immune to. Cast above
    [Spell Resistance] - 12 + Caster Level in spell resistance.
H X [Mestil's Acid Sheath] - 1d6 + 2/level in acid damage to attackers.

    Summon:
    [Summon Creature V (5)] - Dire Bear
    [Lesser Planar Binding] - Imp (Evil), Slaad Red (Neutral), Lantern Archon (Good)

    Other:
    [Greater Shadow Conjuration] - Variety of spells, illision based.
    [Lesser Mind Blank] - Protection VS mind spells and rids bad mind things.
    [Raise Dead] - Raises a dead person :-)
    [Awaken] - Helps animal companion greatly.
S   [Owl's Insight] - + Half caster level in wisdom.
H   [Monsterous Regeneration] - +3 Regeneration for CasterLevel/2 + 1.

    We check level 3 dispels here.

    Resistance to fire ETc (energy buffer, elemental resistances) are cast
    in the level 6 set.

    Cones breath things too here.

    Giant Hurl Rocks are also here (and some other hurling things)
//::55555555555555555555555555555555555555555555555555555555555555555555555555*/

    // Jump out if we don't want to cast level 5 spells.
    if(nLowestSpellLevel > 5) return FALSE;

    // Monsterous Regeneration if we have 70% or less HP
    if(bFirstRunThrough && GlobalOurPercentHP <= 70 &&
       !GetHasSpellEffect(SPELL_MONSTROUS_REGENERATION))
    {
        // Monsterous Regeneration. Level 5 (Cleric/Druid) +3 Regeneration for CasterLevel/2 + 1.
        if(AI_ActionCastSpell(SPELL_MONSTROUS_REGENERATION, OBJECT_SELF, 15, FALSE)) return TRUE;
    }

    // Spell reistance - feel the vibes :-) Cast above also if mages around, or need spell protections.
    if(bFirstRunThrough && !AI_GetAIHaveSpellsEffect(GlobalHasSpellResistanceSpell))
    {
        // Spell Resistance. Level 5 (Druid/Cleric) 12 + Caster Level in spell resistance.
        if(AI_ActionCastSpell(SPELL_SPELL_RESISTANCE, OBJECT_SELF, 15, FALSE)) return TRUE;
    }

    // Dispel level 3 protections (Hastes, regenerates, tensors...)
    if(AI_ActionAttemptDispel(3, bRangeMediumValid)) return TRUE;

    // Battletide is not bad. Level 5 (Cleric)
    // - Oddly classed under SpellHostAreaDis
    if(bFirstRunThrough && !GetHasSpellEffect(SPELL_BATTLETIDE))
    {
        // Battletide. Level 5 (Cleric). -2 Attack/Saves/damage to enemies who come in. +2 to same for caster.
        if(AI_ActionCastSpell(SPELL_BATTLETIDE, GlobalSpellTarget, 15, FALSE)) return TRUE;
    }

    // Giant Hurl Rock
    if(bRangeLongValid && GlobalSeenSpell)
    {
        // Giant Hurl Rock is for d6(HD/5) + Str. Damage. Huge AOE and bludgeoning damage.
        if(AI_ActionCastSpell(AI_SPELLABILITY_GIANT_HURL_ROCK, GlobalSpellTarget, FALSE, TRUE)) return TRUE;

        // Battle Boulder Toss - from Campaign, but is an ability too. d6(3)+5 Bud dam.
        if(AI_ActionCastSpell(AI_SPELLABILITY_BATTLE_BOULDER_TOSS, GlobalSpellTarget, FALSE, TRUE)) return TRUE;
    }

    // Monster cones - these ignore the GlobalNormalSpellsNoEffectLevel toggle.
    if(bRangeShortValid)
    {
        // Small-distance, cone-based spell.
        // - Take it as no level, and no save. These scale up with the HD of the
        //   monster, so on average should be used all the time.
        oAOE = AI_GetBestAreaSpellTarget(fShortRange, 11.0, FALSE, SAVING_THROW_ALL, SHAPE_SPELLCONE, GlobalFriendlyFireFriendly);
        // Is it valid? 50% for each.
        if(GetIsObjectValid(oAOE))
        {
            // Cones
            // Uses the AOE object for cone of cold.
            // These are the "Cones". Appropriate to put it here, don'tca think?
            for(nCnt = SPELLABILITY_CONE_ACID; nCnt <= SPELLABILITY_CONE_SONIC; nCnt++)
            {
                if(AI_ActionCastSpellRandom(nCnt, 40, oAOE, FALSE, TRUE)) return TRUE;
            }
            if(AI_ActionCastSpellRandom(SPELLABILITY_HELL_HOUND_FIREBREATH, 40, oAOE, FALSE, TRUE)) return TRUE;
        }
    }


    // Mind fog cast here, lower prioritory, if the spell target has high will.
    // Long range.
    if(bRangeLongValid && (GlobalSpellTargetWill / 2 >= GlobalSpellAbilityModifier))
    {
        // Mind Fog. Level 5 (Mage/Bard) - Minus 10 to all will saves within the AOE.
        if(AI_ActionCastSpell(SPELL_MIND_BLANK, GlobalSpellTarget, 15, TRUE)) return TRUE;
    }

    // Feeblemind is Good if in medium range, and is a mage :-)
    if(bRangeMediumValid && GlobalSeenSpell &&
       GetLevelByClass(CLASS_TYPE_WIZARD, GlobalSpellTarget) >= GlobalOurHitDice/4)
    {
        // Feeblemind. Level 5 (Mage) 1d4/4 caster levels in intelligence decrease, if fail will save.
        if(AI_ActionCastSpell(SPELL_FEEBLEMIND, GlobalSpellTarget, 15, FALSE)) return TRUE;
    }
    // Randomise one of the many level 5 spells.
// AOE:
// [Cloudkill] - Acid damage, and kills level 7s or below. AOE.
// [Cone of Cold] - Cone of damage, up to 15d6 to those in the cone. Reflex for none.
// [Firebrand] - Missile storm - hits enemies up to caster level (max 15) for 1d6 fire reflex damage.
// [Circle of Doom] - 1d8 + 1/caster level in negative damage
// [Flame Strike] - Up to 15d6 in Fire + Divine damage. Reflex based. Medium area.
// [Ball Lightning] - 1d6/missile, to 15 missiles. Reflex based. Cast at singal target (like missile storms)
// Single:
// [Bigby's Interposing Hand] -10 to hit for 1 target.
// [Hold Monster] - Paralyze's an enemy monster (any race)
// [Slay Living] - Touch attack + Fortitude Save, creature dies, else d6(3) negative damage.
// [Inferno] - 2d6 Fire damage/round like acid arrow. No save, only SR.

    // Is it best to target with single-target spells first? Some pretty
    // good level 5 spells - Hold monster and Slay Living are useful :-)
    // 60-70% if favourable.
    if(bSingleSpellsFirst && GlobalSeenSpell && GlobalNormalSpellsNoEffectLevel < 5)
    {
        // Slay living. 60% chance to cast - it is a touch spell.
        if(bRangeTouchValid && !AI_CompareTimeStopStored(SPELL_SLAY_LIVING) &&
          !AI_GetSpellTargetImmunity(GlobalImmunityDeath) &&
          !AI_GetSpellTargetImmunity(GlobalImmunityNecromancy) &&
          !AI_SaveImmuneSpellTarget(SAVING_THROW_FORT, 5))
        {
            // Slay Living. Level 5 (Cleric). Touch attack + Fortitude Save, creature dies, else d6(3) negative damage.
            if(AI_ActionCastSpellRandom(SPELL_SLAY_LIVING, 50, GlobalSpellTarget, 15, FALSE)) return TRUE;
        }
        // Hold monster - Paralyze's an enemy monster (any race)
        // Decent enough, if not stunned already - 60%
        if(bRangeMediumValid && !AI_CompareTimeStopStored(SPELL_HOLD_MONSTER) &&
          !AI_GetSpellTargetImmunity(GlobalImmunityStun) &&
          !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 5))
        {
            // Hold monster - Paralyze's an enemy monster (any race)
            if(AI_ActionCastSpellRandom(SPELL_HOLD_MONSTER, 50, GlobalSpellTarget, 15, FALSE)) return TRUE;
        }
        // Inferno - the Druids Acid Arrow (more damage, however, each round).
        // ---- No save!!
        if(bRangeShortValid && !GetHasSpellEffect(SPELL_INFERNO))
        {
            // Inferno. Level 5 (Druid) 2d6 Fire damage/round like acid arrow. No save, only SR.
            if(AI_ActionCastSpellRandom(SPELL_INFERNO, 50, GlobalSpellTarget, 15, FALSE)) return TRUE;
        }
        // Bigby's Interposing Hand. No save, only SR. -10 attack rolls for them
        // is good if they have highish BAB. Check here.
        // (Count as stun for immunity - that is anyting that stops them moving (daze included))
        // - Should affect mind-immune people. Bioware will fix this, been told. No mind check
        if(bRangeLongValid && !AI_CompareTimeStopStored(SPELL_BIGBYS_INTERPOSING_HAND) &&
           !GetHasSpellEffect(SPELL_BIGBYS_INTERPOSING_HAND, GlobalSpellTarget) &&
            GetBaseAttackBonus(GlobalSpellTarget) >= GlobalOurHitDice/2)
        {
            // Bigby's Interposing Hand. Level 5 (Mage) No save, only SR. -10 attack rolls for target
            if(AI_ActionCastSpellRandom(SPELL_BIGBYS_INTERPOSING_HAND, 50, GlobalSpellTarget, 16, FALSE)) return TRUE;
        }
        // Single spell override backup casting
        if(bSingleSpellOverride) if(AI_ActionCastBackupRandomSpell()) return TRUE;
    }
// AOE:
// [Cloudkill] - Acid damage, and kills level 7s or below. AOE.
// [Cone of Cold] - Cone of damage, up to 15d6 to those in the cone. Reflex for none.
// [Firebrand] - Missile storm - hits enemies up to caster level (max 15) for 1d6 fire reflex damage.
// [Circle of Doom] - 1d8 + 1/caster level in negative damage
// [Flame Strike] - Up to 15d6 in Fire + Divine damage. Reflex based. Medium area.
// [Ball Lightning] - 1d6/missile, to 15 missiles. Reflex based. Cast at singal target (like missile storms)

    // Firebrand - good, because it hits only enemies (up to 15! thats plenty)
    // and 1d6 damage each. Mainly, it doesn't hit allies :-D
    if(bRangeMediumValid && !AI_CompareTimeStopStored(SPELL_FIREBRAND) &&
       GetHasSpell(SPELL_FIREBRAND))
    {
        // 20M medium range, colossal area. Reflex save - doesn't hit allies too.
        oAOE = AI_GetBestAreaSpellTarget(fMediumRange, RADIUS_SIZE_COLOSSAL, 5, SAVING_THROW_REFLEX);
        // Is it valid? 60% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Firebrand Level 5 (Mage) Missile storm - hits enemies up to caster level (max 15) for 1d6 fire reflex damage.
            if(AI_ActionCastSpellRandom(SPELL_FIREBRAND, 50, oAOE, 15, TRUE)) return TRUE;
        }
    }
    // Ball lightning - Medium spell, and missile storm. We cast this at the target.
    if(bRangeMediumValid && GlobalSeenSpell &&
      !AI_SaveImmuneSpellTarget(SAVING_THROW_REFLEX, 5))
    {
        // Ball Lightning. Level 5 (Mage) 1d6/missile, to 15 missiles. Reflex based. Cast at singal target (like missile storms)
        if(AI_ActionCastSpellRandom(SPELL_BALL_LIGHTNING, 40, oAOE, 15, TRUE)) return TRUE;
    }

    // (Shades) Cone of Cold. Later patches lets Shades hit allies (grr)
    if(bRangeShortValid &&
      (GetHasSpell(SPELL_SHADES_CONE_OF_COLD) || GetHasSpell(SPELL_CONE_OF_COLD)))
    {
        // Small-distance, cone-based spell. Reflex save
        oAOE = AI_GetBestAreaSpellTarget(fShortRange, 11.0, 5, SAVING_THROW_REFLEX, SHAPE_SPELLCONE, GlobalFriendlyFireFriendly);
        // Is it valid? 100% chance of casting (Can't be bothered to create a special random version of SubSpell)
        if(GetIsObjectValid(oAOE))
        {
            // Shades Cone of Cold. Level 7 (Mage). Cone of damage, up to 15d6 to those in the cone. Reflex for none.
            if(AI_ActionCastSpell(SPELL_SHADES_CONE_OF_COLD, oAOE, 17, TRUE, TRUE)) return TRUE;

            // Cone of Cold. Level 5 (Mage). Cone of damage, up to 15d6 to those in the cone. Reflex for none.
            if(AI_ActionCastSpellRandom(SPELL_CONE_OF_COLD, 40, oAOE, 15, TRUE)) return TRUE;
        }
    }
    // Flame Strike - Up to 15d6 in Fire + Divine damage. Reflex based. Medium area.
    if(bRangeMediumValid && GetHasSpell(SPELL_FLAME_STRIKE))
    {
        // Small-distance, cone-based spell. Reflex save
        oAOE = AI_GetBestAreaSpellTarget(fMediumRange, RADIUS_SIZE_MEDIUM, 5, SAVING_THROW_REFLEX, SHAPE_SPHERE, GlobalFriendlyFireFriendly);
        // Is it valid? 50% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Flame Strike. Level 5 (Cleric) Up to 15d6 in Fire + Divine damage. Reflex based. Medium area.
            if(AI_ActionCastSpellRandom(SPELL_FLAME_STRIKE, 40, oAOE, 15, TRUE)) return TRUE;
        }
    }
    // Circle of Doom - 1d8 + 1/caster level in negative damage
    if(bRangeMediumValid && GetHasSpell(SPELL_CIRCLE_OF_DOOM))
    {
        // Shpere, medium and reflex save.
        oAOE = AI_GetBestAreaSpellTarget(fMediumRange, RADIUS_SIZE_MEDIUM, 5, SAVING_THROW_REFLEX, SHAPE_SPHERE, GlobalFriendlyFireFriendly);
        // Is it valid? 50% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Circle of Doom. Level 5 (Cleric) 1d8 + 1/caster level in negative damage
            if(AI_ActionCastSpellRandom(SPELL_CIRCLE_OF_DOOM, 40, oAOE, 15, TRUE)) return TRUE;
        }
    }
    // Cloudkill. Acid damage, and kills level 7s or below. AOE. Quite good persistant damage.
    if(bRangeLongValid && GetHasSpell(SPELL_CLOUDKILL))
    {
        // No save (fortitude only halfs damage) but large (5M across) AOE - and long range
        oAOE = AI_GetBestAreaSpellTarget(fLongRange, RADIUS_SIZE_LARGE, 5, FALSE, SHAPE_SPHERE, GlobalFriendlyFireFriendly);
        // Is it valid? 50% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Cloudkill. Level 5 (Mage) Acid damage, and kills level 7s or below. AOE. Quite good persistant damage.
            if(AI_ActionCastSpellRandom(SPELL_CLOUDKILL, 40, oAOE, 15, TRUE)) return TRUE;
        }
    }

    // Multi spell override backup casting
    if(bMultiSpellOverride) if(AI_ActionCastBackupRandomSpell()) return TRUE;

    // Level 5 summons
    if(bFirstRunThrough && GlobalCanSummonSimilarLevel <= 5 &&
      (GlobalOurHitDice <= 14 || GlobalMeleeAttackers <= 2))
    {
        // Summon Monster V (5). Level 5 (Most classes) Dire Bear
        if(AI_ActionCastSummonSpell(SPELL_SUMMON_CREATURE_V, 15, 5)) return TRUE;
        // Lesser Planar Binding. Level 5 (Mage). Summons Imp (Evil), Slaad Red (Neutral), Lantern Archon (Good)
        if(AI_ActionCastSummonSpell(SPELL_LESSER_PLANAR_BINDING, 15, 5)) return TRUE;
    }

    // Single spells again.
    if(GlobalSeenSpell && GlobalNormalSpellsNoEffectLevel < 5)
    {
        // Slay living. 60% chance to cast - it is a touch spell.
        if(bRangeTouchValid && !AI_CompareTimeStopStored(SPELL_SLAY_LIVING) &&
          !AI_GetSpellTargetImmunity(GlobalImmunityDeath) &&
          !AI_GetSpellTargetImmunity(GlobalImmunityNecromancy) &&
          !AI_SaveImmuneSpellTarget(SAVING_THROW_FORT, 5))
        {
            // Slay Living. Level 5 (Cleric). Touch attack + Fortitude Save, creature dies, else d6(3) negative damage.
            if(AI_ActionCastSpellRandom(SPELL_SLAY_LIVING, 30, GlobalSpellTarget, 15, FALSE)) return TRUE;
        }
        // Hold monster - Paralyze's an enemy monster (any race)
        // Decent enough, if not stunned already - 60%
        if(bRangeMediumValid && !AI_CompareTimeStopStored(SPELL_HOLD_MONSTER) &&
          !AI_GetSpellTargetImmunity(GlobalImmunityStun) &&
          !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 5))
        {
            // Hold monster - Paralyze's an enemy monster (any race)
            if(AI_ActionCastSpellRandom(SPELL_HOLD_MONSTER, 20, GlobalSpellTarget, 15, FALSE)) return TRUE;
        }
        // Inferno - the Druids Acid Arrow (more damage, however, each round).
        // ---- No save!!
        if(bRangeShortValid)
        {
            // Inferno. Level 5 (Druid) 2d6 Fire damage/round like acid arrow. No save, only SR.
            if(AI_ActionCastSpellRandom(SPELL_INFERNO, 20, GlobalSpellTarget, 15, FALSE)) return TRUE;
        }
        // Bigby's Interposing Hand. No save, only SR. -10 attack rolls for them
        // is good if they have highish BAB. Check here.
        // (Count as stun for immunity - that is anyting that stops them moving (daze included))
        // - Should affect mind-immune people. Bioware will fix this, been told. No mind check
        if(bRangeLongValid && !AI_CompareTimeStopStored(SPELL_BIGBYS_INTERPOSING_HAND) &&
           !GetHasSpellEffect(SPELL_BIGBYS_INTERPOSING_HAND, GlobalSpellTarget) &&
            GetBaseAttackBonus(GlobalSpellTarget) >= GlobalOurHitDice/2)
        {
            // Bigby's Interposing Hand. Level 5 (Mage) No save, only SR. -10 attack rolls for target
            if(AI_ActionCastSpellRandom(SPELL_BIGBYS_INTERPOSING_HAND, 20, GlobalSpellTarget, 16, FALSE)) return TRUE;
        }
    }

    // Pass random spell not cast, but have, here.
    if(AI_ActionCastBackupRandomSpell()) return TRUE;

/*::4444444444444444444444444444444444444444444444444444444444444444444444444444
    Level 4 Spells.
//::4444444444444444444444444444444444444444444444444444444444444444444444444444
    Thoughts -Quite a few decent enough spells here. Nothing to catch your eye,
    except maybe the overused Ice Storm or Wall of Fire. hammer of the gods
    is a good clerical AOE spell and phantasmal killer is probably the first
    Instant-death spells (but requires 2 save"1").

    AOE:
    [Confusion] - confuse people Vs Mind Will in an area.
    [Evard's Black Tentacles] - Rolls VS
    [Fear] - Save VS mind will or fear, in an area.
    [Ice Storm] - 2d6 (Blud) + 3d6 / 3 caster levels (cold) damage. No save!
S   [Isaac's Lesser Missile Storm] - 1d6 per each 1-10 missile divided around enemies in AOE.
    [Wall of Fire] - 4d6 fire reflex damage in a retangle persistant AOE
    [Hammer of the Gods] - divine damage d8(half caster level) to 5. Can Daze. Will save.
    [War Cry] Will save or fear (like a howl) and all allies get +2 attack/damage

    Single:
    [Bestow Curse] - Curse = -2 in all stats against a fortitude save.
    [Charm Monster] - Charm a single monster (any race) VS will and mind
    [Contagion] - Disease (Static DC!) if fail fortitude save
    [Enervation] - 1d4 negative levels, fortitude save
    [Phantasmal Killer] Will save (Illusion) then fort save, or death.
S   [Inflict Critical Wounds] - 3d8 + 1/caster level to +20, in negative energy.
    [Poison] - Inflicts poison (sadly, static fortitude save)

  X [Lesser Spell Breach] - Breach an amount of spell protections and lowers SR.

    Defender:
    [Elemental Shield] +50% Cold/Fire resistance. 1d6 + Caster level reflected damage to melee attackers.
  X [Improved Invisibility] +50% consealment, invisiblity (unseen) until hostile action. Cast above to at least conseal
    [Minor Globe of Invulnerability] - 0/1/2/3 level hostile spells immune to.
    [Stoneskin] - 10/+5 DR. We cast this here, sorceror behavnOur and backup for greater stoneskin
    [Death Ward] - Death Immunity - death magic.

    Summon:
    [Summon Creature IV (4)] Summons a Dire Spider

    Other:
  X [Polymorph Self] - Troll, umber Hulk, Pixie, Zombie, Giant spider. Cast after spells to fight.
  X [Shadow Conjuration] - Shadow spells.
    [Cure Critical Wounds] - Cures wounds
  X [Divine Power] + Temp HP, +BAB, +Strength to 18. Done before melee
    [Freedom of Movement] - Slowing removed. Immunity to slowing effects and stuff.
    [Neutralize Poison] - Rids poison
    [Restoration] - Restores lost statistics
S   [Mass Camouflage] +10 Hide
H X [Holy Sword] - Paladins sword gains the "Holy Avenger" property - +1d6 divine, +5 enchant, 25% dispel.
//::44444444444444444444444444444444444444444444444444444444444444444444444444*/

    // Jump out if we don't want to cast level 4 spells.
    if(nLowestSpellLevel > 4) return FALSE;

    if(bFirstRunThrough)
    {
        // Cast normal stoneskin to prepare for greater stoneskin going down.
        // as par greater stoneskin, we must also have used level 5, 6, 7 8 and 9 spells
        // anyway! That, and this is good for sorcerors.
        if(!GetHasSpellEffect(SPELL_STONESKIN) && !GetHasSpellEffect(SPELL_SHADES_STONESKIN))
        {
            // Shades stoneskin. SPELL_SHADES_STONESKIN (Cast via. subspell)
            if(AI_ActionCastSpell(SPELL_SHADES_STONESKIN, OBJECT_SELF, 16, FALSE, TRUE)) return TRUE;

            // Stoneskin. Level 4 (Mage) 5 (Druid) 10/+5 phisical damage reduction
            if(AI_ActionCastSpell(SPELL_STONESKIN, OBJECT_SELF, 14, FALSE)) return TRUE;
        }

        // Check for Arcane Archer feats here
        if(GetLevelByClass(CLASS_TYPE_ARCANE_ARCHER))
        {
            // Arrow of death. DC20 or die.
            if(AI_ActionUseSpellLikeFeat(FEAT_PRESTIGE_ARROW_OF_DEATH, SPELLABILITY_AA_ARROW_OF_DEATH, GlobalSpellTarget)) return TRUE;
            // Fireball arrow - won't harm allies
            if(AI_ActionUseSpellLikeFeat(FEAT_PRESTIGE_IMBUE_ARROW, SPELLABILITY_AA_IMBUE_ARROW, GlobalSpellTarget)) return TRUE;
            // Seeker Arrow is cool
            if(AI_ActionUseSpellLikeFeat(FEAT_PRESTIGE_SEEKER_ARROW_2, SPELLABILITY_AA_SEEKER_ARROW_2, GlobalSpellTarget)) return TRUE;
            // Hail of arrows is neat
            if(AI_ActionUseSpellLikeFeat(FEAT_PRESTIGE_HAIL_OF_ARROWS, SPELLABILITY_AA_HAIL_OF_ARROWS, GlobalSpellTarget)) return TRUE;
            // Seeker Arrow is cool
            if(AI_ActionUseSpellLikeFeat(FEAT_PRESTIGE_SEEKER_ARROW_1, SPELLABILITY_AA_SEEKER_ARROW_1, GlobalSpellTarget)) return TRUE;
        }

        // Elemental Shield is a good spell - reflected damage. It is normally
        // cast above with more melee attackers. Here by backup. Shield-based spell
        // (EffectDamageShield())

        // Elemental Shield. Level 5 (Mage) +50% Cold/Fire resistance. 1d6 + Caster level reflected damage to melee attackers.
        // (Use this but with Input 4)
        if(AI_SpellWrapperShieldProtections(4)) return TRUE;

        // Minor globe backup casting.
        if(AI_SpellWrapperGlobeProtections(nLowestSpellLevel)) return TRUE;

        // Not bad, immunity to death/
        // - Might add in opposing casting if they start casting death spells.
        if(!AI_GetAIHaveSpellsEffect(GlobalHasDeathWardSpell))
        {
            // Death Ward. Level 4 (Cleric/Paladin) 5 (Druid). Immunity to death (Death-based spells nromally, like Wail).
            if(AI_ActionCastSpell(SPELL_DEATH_WARD, OBJECT_SELF, 14, FALSE)) return TRUE;
        }

        // Some lower end ally buffs

        // Spell Resistance.
        if(AI_ActionCastAllyBuffSpell(10.0, 60, SPELL_SPELL_RESISTANCE)) return TRUE;

        if(GetBaseAttackBonus(GlobalSpellTarget) < GlobalSpellTargetHitDice - 2)
        {
            // Death Ward if we can see an enemy spellcaster.
            if(AI_ActionCastAllyBuffSpell(10.0, 60, SPELL_DEATH_WARD)) return TRUE;
        }
    }

    // BAB check
    // - BAB checks check our BASE attack bonus, no modifiers. Basically, as
    //   normally even mages have a +X to attack, this provides a good indicator
    //   if we are going to easy, or very easily, hit the enemy.
    // - Clerics, Druids and Bards must be able to hit even better then normal.
    if(bFirstRunThrough && !SRA &&
       GlobalOurChosenClass != CLASS_TYPE_WIZARD &&
       GlobalOurChosenClass != CLASS_TYPE_SORCERER &&
       GlobalOurChosenClass != CLASS_TYPE_FEY)
    {
        // If a druid, cleric, and so on, have to be able to hit better then
        // more then normal
        if(GlobalOurChosenClass == CLASS_TYPE_CLERIC ||
           GlobalOurChosenClass == CLASS_TYPE_DRUID ||
           GlobalOurChosenClass == CLASS_TYPE_BARD)
        {
            // BAB check for level 4 spells.
            if(GlobalOurBaseAttackBonus - 5 >= GlobalMeleeTargetAC) return FALSE;
        }
        // Demons, fighters, anything else really.
        else
        {
            // BAB check for level 4 spells.
            if(GlobalOurBaseAttackBonus >= GlobalMeleeTargetAC) return FALSE;
        }
    }

    // Hostile spells
// Single:
// [Enervation] - 1d4 negative levels, fortitude save
// [Phantasmal Killer] Will save (Illusion) then fort save, or death.

// [Poison] - Inflicts poison (sadly, static fortitude save)
// [Bestow Curse] - Curse = -2 in all stats against a fortitude save.
// [Charm Monster] - Charm a single monster (any race) VS will and mind
// [Contagion] - Disease (Static DC!) if fail fortitude save

    // Is it best to target with single-target spells first?
    // Inflict critical, as well as some others, are quite powerful for level 3.
    // 60-70% if favourable.
    // - We don't cast Bestow Curse, Charm Monster, Poison, or Contagion above
    //   AOE spells. We cast critical wounds only at the very end.
    if(bSingleSpellsFirst && GlobalSeenSpell && GlobalNormalSpellsNoEffectLevel < 4 &&
       // All level 4, all fort saves
       !AI_SaveImmuneSpellTarget(SAVING_THROW_FORT, 4))
    {
        // Phantismal Killer. Will and Fortitude save VS death. :-)
        if(bRangeMediumValid && !AI_CompareTimeStopStored(SPELL_PHANTASMAL_KILLER) &&
          !AI_GetSpellTargetImmunity(GlobalImmunityDeath) &&
          !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 4))
        {
            // Phantasmal Killer. Level 4 (Mage). Will save (Illusion) then fort save, or death.
            if(AI_ActionCastSpellRandom(SPELL_PHANTASMAL_KILLER, 50, GlobalSpellTarget, 14, FALSE)) return TRUE;
        }
        // Enervation. 1d4 negative levels. Short range
        if(bRangeMediumValid && !AI_GetSpellTargetImmunity(GlobalImmunityNecromancy) &&
          !AI_GetSpellTargetImmunity(GlobalImmunityNegativeEnergy))
        {
            // Enervation. Level 4 (Mage). 1d4 negative levels, fortitude save
            if(AI_ActionCastSpellRandom(SPELL_ENERVATION, 40, GlobalSpellTarget, 14, FALSE)) return TRUE;
        }
        // Single spell override backup casting
        if(bSingleSpellOverride) if(AI_ActionCastBackupRandomSpell()) return TRUE;
    }

// AOE:
// [Confusion] - confuse people Vs Mind Will in an area.
// [Evard's Black Tentacles] - Rolls VS AC and damage 1-5 lots of 2d6 blud.
// [Fear] - Save VS mind will or fear, in an area.
// [Ice Storm] - 2d6 (Blud) + 3d6 / 3 caster levels (cold) damage. No save!
// [Isaac's Lesser Missile Storm] - 1d6 per each 1-10 missile divided around enemies in AOE.
// [Wall of Fire] - 4d6 fire reflex damage in a retangle persistant AOE
// [Hammer of the Gods] - divine damage d8(half caster level) to 5. Can Daze. Will save.
// [War Cry] Will save or fear (like a howl) and all allies get +2 attack/damage

    if(GlobalNormalSpellsNoEffectLevel < 4)
    {
        if(bRangeLongValid && GlobalSeenSpell)
        {
            // Lesser missile storm. 1d6/missile. 1-10 missiles basically. Enemies only!
            // Just cast at the enemy.
            // Isaac's Lesser Missile Storm. Level 4 (Mage) 1d6 per each 1-10 missile divided around enemies in AOE.
            if(AI_ActionCastSpellRandom(SPELL_ISAACS_LESSER_MISSILE_STORM, 70, GlobalSpellTarget, 14, TRUE)) return TRUE;
        }

        // War cry here. No need to check if they run off - helps allies.
        if(GlobalSpellTargetRange <= RADIUS_SIZE_COLOSSAL)
        {
            // War Cry. Level 4 (Bard) Will save or fear (like a howl) and all allies get +2 attack/damage
            if(AI_ActionCastSpellRandom(SPELL_WAR_CRY, 30, OBJECT_SELF, 14, TRUE)) return TRUE;
        }
    }

    // Ice storm. plenty of damage :-)
    if(bRangeLongValid && GetHasSpell(SPELL_ICE_STORM))
    {
        // Shpere, huge and no save :-) - long range too.
        oAOE = AI_GetBestAreaSpellTarget(fLongRange, RADIUS_SIZE_HUGE, 4, FALSE, SHAPE_SPHERE, GlobalFriendlyFireFriendly);
        // Is it valid? 60% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Ice Storm. Level 4 (Mage) 5 (Druid) 6 (Bard) - 2d6 (Blud) + 3d6 / 3 caster levels (cold) damage. No save!
            if(AI_ActionCastSpellRandom(SPELL_ICE_STORM, 50, oAOE, 14, TRUE)) return TRUE;
        }
    }
    // Confusion - confusion! Decent especially against PC's.
    if(bRangeMediumValid && GetHasSpell(SPELL_CONFUSION))
    {
        // Shpere, huge and no save :-)
        oAOE = AI_GetBestAreaSpellTarget(fMediumRange, RADIUS_SIZE_LARGE, 4, SAVING_THROW_WILL, SHAPE_SPHERE, GlobalFriendlyFireHostile);
        // Is it valid? 60% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Ice Storm. Level 4 (Mage) 5 (Druid) 6 (Bard) - 2d6 (Blud) + 3d6 / 3 caster levels (cold) damage. No save!
            if(AI_ActionCastSpellRandom(SPELL_CONFUSION, 50, oAOE, 14, TRUE)) return TRUE;
        }
    }
    // Hammer of the Gods. Divine damage is good, as well as save VS daze.
    if(bRangeMediumValid && GetHasSpell(SPELL_HAMMER_OF_THE_GODS))
    {
        // Shpere, no friends affected, we cast even if saves VS will. :-)
        oAOE = AI_GetBestAreaSpellTarget(fMediumRange, RADIUS_SIZE_HUGE, 4);
        // Is it valid? 50% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Hammer of the Gods. Level 4 (Cleric). Divine damage d8(half caster level) to 5d8. Can Daze. Will save.
            if(AI_ActionCastSpellRandom(SPELL_HAMMER_OF_THE_GODS, 40, oAOE, 14, TRUE)) return TRUE;
        }
    }
    // Fear - fear!
    if(bRangeMediumValid && GetHasSpell(SPELL_FEAR))
    {
        // Shpere, no friends affected, we cast even if saves VS will. :-)
        oAOE = AI_GetBestAreaSpellTarget(fMediumRange, RADIUS_SIZE_LARGE, 4, SAVING_THROW_WILL, SHAPE_SPHERE, GlobalFriendlyFireHostile);
        // Is it valid? 50% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Fear. Level 4 (Mage) 3 (Bard). Save VS mind will or fear, in an area.
            if(AI_ActionCastSpellRandom(SPELL_FEAR, 40, oAOE, 14, TRUE)) return TRUE;
        }
    }
    // Wall of Fire.
    if(bRangeMediumValid &&
      (GetHasSpell(SPELL_WALL_OF_FIRE) || GetHasSpell(SPELL_SHADES_WALL_OF_FIRE)))
    {
        // Ok, retangle. Take it as a medium sized sphere.
        oAOE = AI_GetBestAreaSpellTarget(fMediumRange, RADIUS_SIZE_MEDIUM, 4, SAVING_THROW_REFLEX, SHAPE_SPHERE, GlobalFriendlyFireFriendly);
        // Is it valid? 50% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Shades version. Cast as subspell.
            if(AI_ActionCastSpell(SPELL_SHADES_WALL_OF_FIRE, oAOE, 14, TRUE, TRUE)) return TRUE;

            // Wall of Fire. Level 4 (Mage) 5 (Druid) 4d6 fire reflex damage in a retangle persistant AOE
            if(AI_ActionCastSpellRandom(SPELL_WALL_OF_FIRE, 40, oAOE, 14, TRUE)) return TRUE;
        }
    }
    // Evard's Black Tentacles. AC attack and damage (fort or paralysis on enter)
    // Casts if average HD is under 10
    if(bRangeMediumValid && GlobalAverageEnemyHD <= 10 &&
       GetHasSpell(SPELL_EVARDS_BLACK_TENTACLES))
    {
        // 5M sized AOE spell, medium range.
        oAOE = AI_GetBestAreaSpellTarget(fMediumRange, RADIUS_SIZE_LARGE, 4, FALSE, SHAPE_SPHERE, GlobalFriendlyFireFriendly);
        // Is it valid? 40% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Evard's Black Tentacles. Level 4 (Mage) AC attack and damage (2d6 x 1-5 hits) (fort or paralysis on enter)
            if(AI_ActionCastSpellRandom(SPELL_EVARDS_BLACK_TENTACLES, 30, oAOE, 14, TRUE)) return TRUE;
        }
    }

    // Multi spell override backup casting
    if(bMultiSpellOverride) if(AI_ActionCastBackupRandomSpell()) return TRUE;

    // Level 4 summons
    if(bFirstRunThrough && GlobalCanSummonSimilarLevel <= 4 &&
      (GlobalOurHitDice <= 12 || GlobalMeleeAttackers <= 2))
    {
        // Summon Monster IV (4). Level 4 (Most classes) Summons a Dire Spider
        if(AI_ActionCastSummonSpell(SPELL_SUMMON_CREATURE_IV, 14, 4)) return TRUE;
    }

// [Enervation] - 1d4 negative levels, fortitude save
// [Phantasmal Killer] Will save (Illusion) then fort save, or death.
// [Inflict Critical Wounds] - 3d8 + 1/caster level to +20, in negative energy.

// [Poison] - Inflicts poison (sadly, static fortitude save)
// [Bestow Curse] - Curse = -2 in all stats against a fortitude save.
// [Charm Monster] - Charm a single monster (any race) VS will and mind
// [Contagion] - Disease (Static DC!) if fail fortitude save

    // All single target spells, even poison and so on.
    if(GlobalSeenSpell && GlobalNormalSpellsNoEffectLevel < 4)
    {
        // All but charm are fortitude based.
        if(!AI_SaveImmuneSpellTarget(SAVING_THROW_FORT, 4))
        {
            // Phantismal Killer. Will and Fortitude save VS death. :-)
            if(bRangeMediumValid && !AI_CompareTimeStopStored(SPELL_PHANTASMAL_KILLER) &&
              !AI_GetSpellTargetImmunity(GlobalImmunityDeath) &&
              !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 4))
            {
                // Phantasmal Killer. Level 4 (Mage). Will save (Illusion) then fort save, or death.
                if(AI_ActionCastSpellRandom(SPELL_PHANTASMAL_KILLER, 50, GlobalSpellTarget, 14, FALSE)) return TRUE;
            }
            // Enervation. 1d4 negative levels. Short range
            if(bRangeMediumValid && !AI_GetSpellTargetImmunity(GlobalImmunityNecromancy) &&
              !AI_GetSpellTargetImmunity(GlobalImmunityNegativeEnergy))
            {
                // Enervation. Level 4 (Mage). 1d4 negative levels, fortitude save
                if(AI_ActionCastSpellRandom(SPELL_ENERVATION, 40, GlobalSpellTarget, 14, FALSE)) return TRUE;
            }
            // Contagion. Disease! Quite good, but still check spell save DC at fort above.
            // Necromancy.
            if(bRangeTouchValid && !AI_GetSpellTargetImmunity(GlobalImmunityNecromancy) &&
              !AI_GetSpellTargetImmunity(GlobalImmunityDisease))
            {
                // Blackguard Ability
                if(AI_ActionUseSpellLikeFeat(FEAT_CONTAGION, SPELLABILITY_BG_CONTAGION, GlobalMeleeTarget)) return TRUE;

                // Contagion. Level 4 (Mage) 3 (Cleric/Bard). Random disease (Set DC's!) against a fortitude saving throw.
                if(AI_ActionCastSpellRandom(SPELL_CONTAGION, 40, GlobalSpellTarget, 14, FALSE)) return TRUE;
            }
            // Poison - Inflicts poison (sadly, static fortitude save) Necro spell.
            if(bRangeTouchValid && !AI_GetSpellTargetImmunity(GlobalImmunityNecromancy) &&
              !AI_GetSpellTargetImmunity(GlobalImmunityPoison))
            {
                // Poison. Level 4 (Cleric) 3 (Druid) Large Scorion Venom poison (Set DC!) against a fortitude saving throw.
                if(AI_ActionCastSpellRandom(SPELL_POISON, 40, GlobalSpellTarget, 14, FALSE)) return TRUE;
            }
            // Bestow Curse - Inflicts poison (sadly, static fortitude save) Necro spell.
            if(bRangeTouchValid && !AI_GetSpellTargetImmunity(GlobalImmunityCurse))
            {
                // Bestow Curse. Level 4 (Mage) 3 (Cleric/Bard) -2 to all stats VS Fortitude save.
                if(AI_ActionCastSpellRandom(SPELL_BESTOW_CURSE, 40, GlobalSpellTarget, 14, FALSE)) return TRUE;
            }
        }
        // Charm Monster. Charms any monster. Will save, mind based.
        if(!AI_GetSpellTargetImmunity(GlobalImmunityMind) && bRangeShortValid &&
           !AI_GetSpellTargetImmunity(GlobalImmunityDomination) &&
           !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 4))
        {
            // Charm Monster. Level 4 (mage) 3 (Bard). Charm any monster, will save to resist.
            if(AI_ActionCastSpellRandom(SPELL_CHARM_MONSTER, 30, GlobalSpellTarget, 14, FALSE)) return TRUE;
        }
    }

    // Backup cast anything we didn't choose to before
    if(AI_ActionCastBackupRandomSpell()) return TRUE;

    // Critical wounds - damage at a touch attack.
    if(GlobalSeenSpell && GlobalNormalSpellsNoEffectLevel < 4 && bRangeTouchValid)
    {
        // Cast Cure Critical Wounds (Which acts the same way for undead as
        // inflict critical does)
        if(GlobalSpellTargetRace == RACIAL_TYPE_UNDEAD)
        {
            // Cure Critical Wounds. Level 4 (Cleric) 3d8 + 1/caster level to +20, in positive energy.
            if(AI_ActionCastSpontaeousSpell(SPELL_CURE_CRITICAL_WOUNDS, GlobalSpellTarget)) return TRUE;
        }
        if(!AI_GetSpellTargetImmunity(GlobalImmunityNecromancy) &&
           !AI_GetSpellTargetImmunity(GlobalImmunityNegativeEnergy))
        {
            // Blackguard ability
            if(AI_ActionUseSpellLikeFeat(FEAT_INFLICT_CRITICAL_WOUNDS, SPELLABILITY_BG_INFLICT_CRITICAL_WOUNDS, GlobalSpellTarget)) return TRUE;

            // Inflict Critical Wounds. Level 4 (Cleric) 3d8 + 1/caster level to +20, in negative energy.
            if(AI_ActionCastSpontaeousSpell(SPELL_INFLICT_CRITICAL_WOUNDS, GlobalSpellTarget)) return TRUE;
        }
    }

/*::3333333333333333333333333333333333333333333333333333333333333333333333333333
    Level 3 Spells.
//::3333333333333333333333333333333333333333333333333333333333333333333333333333
    Thoughts - This is a level where mages pick up - IE fireball! Many decent AOE
    and single-target spells, which scale up pretty well for mid and high level
    casters. Also dispels level 2 protections before other things.

    AOE:
    [Fireball] - THE ONE SPELL TO RULE THEM ALL! - ok, basically the 1 D&D spell
      which is most famous - and frequently the last word a mage says before it kills him!
      up to 10d6 reflex fire damage, in a large AOE hit area. Allies are hit too! (as we all know...)
S   [Gust of Wind] Knockdown enemies VS reflex. Main thing is Dispeling AOE's, and 1 is always kept in reserve.
    [Lightning Bolt] An "oh, other spell" to fireball. Does a different damage type. can be more useful - different shape! Can't hit caster! 10d6 reflex electrical
    [Negative Energy Burst] 1d8 + 1-20 (caster level) negative damage, and -1 STR/4 caster levels. Heals undead.
    [Slow] -50% speed, -1 Attack, -4 AC (I think) to those in an AOE - doesn't hit allies.
    [Stinking Cloud] - Dazes those in the AOE, if fail VS will.
    [Call Lightning] - Lightning damage - To 10d6 reflex electrical. Never hits allies. Smaller AOE then fireball
S   [Spike Growth] - Damage to those in the AOE, and slow for 24 Hours!
H   [Mestals Acid Breath] - A cone of up to 10d6 (acid) damage. Reflex save.
H   [Scintillating Sphere] - Explosion of up to 10d6 Damage (Electical) - An electiric fireball (reflex save)
H   [Glyph of Warding] - AOE, if entered, does up to 1d6/2 caster levels (to 5d6) damage.

    [Dispel Magic] - Dispels all magic (at a max of +10 check) or 1 from all in AOE

    Single:
    [Flame Arrow] 4d6 Reflex Fire Damage for each missile - 1/4 caster levels.
    [Hold Person] Paralyze's 1 humanoid target (Playable Race/humanoid), if they fail a will save.
    [Vampiric Touch] 1d6(caster level/2) in negative damage, heals us with temp HP.
    [Dominate Animal] Dominates an animal only. Will save.
S   [Quillfire] 1 quill at 1d8 + 1-5 damage. Scorpion poison too.
    [Searing Light] Maxs of 10d6 to undead, 5d8 to others, 5d6 to constructs. Divine damage. Done above (way above) VS undead
S   [Inflict Serious Wounds] - Touch attack, hit means 3d8 + 1-15 damage.
H   [Healing Sting] - 1d6 + 1/Caster evel damage, and healed for that amount. Fort save for none.
H   [Infestation of Maggots] - 1d4 Temp constitution damage/round. (1 round/caster level)

    Defender:
S X [Displacement] - 50% consealment. Cast above to conseal ourselves sooner (50% missing is good! stoneskin lasts twice as long!)
    [Magic Circle Against Alignment] +AC, +mind immunity etc. In a persistant AOE around caster.
  X [Protection From Elements] 30/- elemental protection, until 40 damage.
    [Negative Energy Protection] Immunity to negative energy
S   [Wounding Whispers] 1d6 + Caster level in refelected sonic damage.
H   [Magical Vestment] - Gives 1 suit of armor/shield a +1 AC bonus/3 caster levels (to +5)

    Summon:
    [Animate Dead] - Skeleton or zomie summon. Tough DR, long lasting, but hard to heal.
    [Summon Creature III] - Summons a Dire Wolf.

    Other:
  X [Clairaudience/Clairvoyance] +20 spot.
    [Clarity] - Mind resistance, clears hostile mind effects.
XXXX[Find Traps] - Finds and disarms traps. Never cast - unless I add it for PC traps.
  X [Haste] +1 action. +4 AC. +150% speed. Good spell, cast right near top for maximum effect.
  X [Invisibility Sphere] - Allies in area become invisible. Cast above (nearly first spell!) if want to go invis.
S   [Greater Magic Fang] - Helps animal companion a lot :-)
  X [Cure Serious Wounds] 3d8 + 1-15 damage healed.
  X [Invisibility Purge] - AOE around us which removes Invisiblity effects. Cast as special
  X [Prayer] +HP, +Attack +Damage for one person. Cast just before melee
  X [Remove Blindness/Deafness] - Removes blindness and deafness!
  X [Remove Curse] - " " curse
  X [Remove Disease] - " " Disease
H X [Greater Magical Weapon] - Up to +5 enchantment for weapon (cast before melee)
H X [Keen Edge] - Keens a weapon.
H X [Blade Thirst] - +3 enchantment bonus to 1 slashing weapon.
H X [Darkfire] - +1d6 + 1/caster level (to +10) in fire damage applied to non-magic weapon.

    Dispels all level 2 protections here.

    Bolts cast here.
//::33333333333333333333333333333333333333333333333333333333333333333333333333*/

    // Jump out if we don't want to cast level 3 spells.
    if(nLowestSpellLevel > 3) return FALSE;

    // Dispel level 2 protections (Hastes, regenerates, tensors...)
    if(AI_ActionAttemptDispel(2, bRangeMediumValid)) return TRUE;

    if(bFirstRunThrough)
    {
        // Greater magic fang
        oAOE = GetAssociate(ASSOCIATE_TYPE_ANIMALCOMPANION);
        if(GetIsObjectValid(oAOE) && !GetHasSpellEffect(SPELL_GREATER_MAGIC_FANG, oAOE))
        {
            // Greater MAgic fang. Level 3 (Ranger/Druid) +Attack, +DR to animal companion
            if(AI_ActionCastSpell(SPELL_GREATER_MAGIC_FANG, oAOE, 13, FALSE)) return TRUE;
        }

        // Divine Shield - a feat, but a damn good one.
        // Up to +5 Dodge AC.
        if(GetHasFeat(FEAT_TURN_UNDEAD))
        {
            // Divine Shield
            if(AI_ActionUseSpellLikeFeat(FEAT_DIVINE_SHIELD, SPELL_DIVINE_SHIELD)) return TRUE;
        }

        // Magical vestment - this adds up to +5 AC to armor or shield!
        // - Affects only our equipped armor.
        oAOE = GetItemInSlot(INVENTORY_SLOT_CHEST);
        // Makes sure it is valid
        if(GetIsObjectValid(oAOE) && !GetHasSpellEffect(SPELL_MAGIC_VESTMENT))
        {
            // Cast it at the armor
            // Magical Vestment. Level 3 (Cleric) Gives 1 suit of armor/shield a +1 AC bonus/3 caster levels (to +5)
            if(AI_ActionCastSpell(SPELL_MAGIC_VESTMENT, oAOE, 13, FALSE)) return TRUE;
        }

        // Regenerations
        if(AI_ActionCastAllyBuffSpell(10.0, 50, SPELL_REGENERATE, SPELL_MONSTROUS_REGENERATION)) return TRUE;

        // Bulls Strength, Cats Grace, Endurance
        if(AI_ActionCastAllyBuffSpell(10.0, 50, SPELL_ENDURANCE, SPELL_CATS_GRACE, SPELL_ENDURANCE, -1, SPELL_GREATER_BULLS_STRENGTH, SPELL_GREATER_CATS_GRACE)) return TRUE;
    }

    // BAB check
    // - BAB checks check our BASE attack bonus, no modifiers. Basically, as
    //   normally even mages have a +X to attack, this provides a good indicator
    //   if we are going to easy, or very easily, hit the enemy.
    // - Clerics, Druids and Bards must be able to hit even better then normal.
    if(bFirstRunThrough && !SRA &&
       GlobalOurChosenClass != CLASS_TYPE_WIZARD &&
       GlobalOurChosenClass != CLASS_TYPE_SORCERER &&
       GlobalOurChosenClass != CLASS_TYPE_FEY)
    {
        // If a druid, cleric, and so on, have to be able to hit better then
        // more then normal
        if(GlobalOurChosenClass == CLASS_TYPE_CLERIC ||
           GlobalOurChosenClass == CLASS_TYPE_DRUID ||
           GlobalOurChosenClass == CLASS_TYPE_BARD)
        {
            // BAB check for level 3 spells.
            // Must be able to hit them 100% of the time.
            if(GlobalOurBaseAttackBonus >= GlobalMeleeTargetAC) return FALSE;
        }
        // Demons, fighters, anything else really.
        else
        {
            // BAB check for level 3 spells.
            // 75% chance of hitting them outright.
            if(GlobalOurBaseAttackBonus + 5 >= GlobalMeleeTargetAC) return FALSE;
        }
    }

    // Bolts 80% chance. Not too good, but oh well.
    if(GlobalSeenSpell && bRangeMediumValid && d10() <= 8)
    {
        // All ability Draining Bolts. All creature, so no limits.
        if(GetAbilityScore(GlobalSpellTarget, ABILITY_DEXTERITY) >= 10)
            if(AI_ActionCastSpellRandom(SPELLABILITY_BOLT_ABILITY_DRAIN_DEXTERITY, 30, GlobalSpellTarget)) return TRUE;
        if(GetAbilityScore(GlobalSpellTarget, ABILITY_WISDOM) >= 12)
            if(AI_ActionCastSpellRandom(SPELLABILITY_BOLT_ABILITY_DRAIN_WISDOM, 30, GlobalSpellTarget)) return TRUE;
        if(GetAbilityScore(GlobalSpellTarget, ABILITY_CONSTITUTION) >= 12)
            if(AI_ActionCastSpellRandom(SPELLABILITY_BOLT_ABILITY_DRAIN_CONSTITUTION, 30, GlobalSpellTarget)) return TRUE;
        if(GetAbilityScore(GlobalSpellTarget, ABILITY_STRENGTH) >= 12)
            if(AI_ActionCastSpellRandom(SPELLABILITY_BOLT_ABILITY_DRAIN_STRENGTH, 30, GlobalSpellTarget)) return TRUE;
        if(GetAbilityScore(GlobalSpellTarget, ABILITY_CHARISMA) >= 14)
            if(AI_ActionCastSpellRandom(SPELLABILITY_BOLT_ABILITY_DRAIN_CHARISMA, 30, GlobalSpellTarget)) return TRUE;
        if(GetAbilityScore(GlobalSpellTarget, ABILITY_INTELLIGENCE) >= 14)
            if(AI_ActionCastSpellRandom(SPELLABILITY_BOLT_ABILITY_DRAIN_INTELLIGENCE, 30, GlobalSpellTarget)) return TRUE;
        // And the damaging bolts/status affecting bolts.
        // I really can't be bothered to add in a lot of checks for immunities.
        // Might do later.
        for(nCnt = SPELLABILITY_BOLT_ACID; nCnt <= SPELLABILITY_BOLT_WEB; nCnt++)
        {
            if(AI_ActionCastSpellRandom(nCnt, 30, GlobalSpellTarget)) return TRUE;
        }
        // Manticore spikes
        if(AI_ActionCastSpellRandom(SPELLABILITY_MANTICORE_SPIKES, 30, GlobalSpellTarget)) return TRUE;
        // Shifter one
        if(AI_ActionCastSpellRandom(AI_SPELLABILITY_GWILDSHAPE_SPIKES, 30, GlobalSpellTarget)) return TRUE;
        // Azer blast
        if(AI_ActionCastSpellRandom(AI_SPELLABILITY_AZER_FIRE_BLAST, 30, GlobalSpellTarget)) return TRUE;
        // Shadow attack
        if(!GetHasSpellEffect(AI_SPELLABILITY_SHADOW_ATTACK, GlobalSpellTarget))
        {
            if(AI_ActionCastSpellRandom(AI_SPELLABILITY_SHADOW_ATTACK, 30, GlobalSpellTarget)) return TRUE;
        }
        // Petrify last.
        if(!AI_GetSpellTargetImmunity(GlobalImmunityPetrify))
        {
            if(AI_ActionCastSpellRandom(SPELLABILITY_TOUCH_PETRIFY, 30, GlobalSpellTarget)) return TRUE;
        }

        // Backup casting
        if(AI_ActionCastBackupRandomSpell()) return TRUE;
    }

// Hostile spells - randomise a bit (remember, some are cast sooner still)

// Single:
// [Flame Arrow] 4d6 Reflex Fire Damage for each missile - 1/4 caster levels.
// [Hold Person] Paralyze's 1 humanoid target (Playable Race/humanoid), if they fail a will save.
// [Searing Light] Maxs of 10d6 to undead, 5d8 to others, 5d6 to constructs. Divine damage. Done above (way above) VS undead
// [Dominate Animal] Dominates an animal only. Will save.
// [Quillfire] 1 quill at 1d8 + 1-5 damage. Scorpion poison too.
// [Vampiric Touch] 1d6(caster level/2) in negative damage, heals us with temp HP.
// [Healing Sting] - 1d6 + 1/Caster evel damage, and healed for that amount. For save for none.
// [Infestation of Maggots] - 1d4 Temp constitution damage/round. (1 round/caster level)

// [Inflict Serious Wounds] - Touch attack, hit means 3d8 + 1-15 damage.

    // Is it best to target with single-target spells first?
    // Flame arrow, searing light and hold person are quite effective.
    // 60-70% if favourable.
    // - We don't cast inflict serious wounds here. GetHasSpell bodges with spontaeous spells.
    if(bSingleSpellsFirst && GlobalSeenSpell && GlobalNormalSpellsNoEffectLevel < 3)
    {
        // Flame arrow - not THE best spell, but well worth it. Also it is long range.
        if(bRangeLongValid && !AI_SaveImmuneSpellTarget(SAVING_THROW_REFLEX, 3))
        {
            // Flame Arrow. Level 3 (Mage) 4d6 Reflex Fire Damage for each missile - 1/4 caster levels.
            if(AI_ActionCastSpellRandom(SPELL_FLAME_ARROW, 60, GlobalSpellTarget, 13, FALSE)) return TRUE;
        }
        // All others are in medium range or smaller
        if(bRangeMediumValid)
        {
            // Hold Person - must be playable race, of course. Still quite powerful - as it paralyzes.
            if(!AI_GetSpellTargetImmunity(GlobalImmunityStun) &&
               !AI_GetSpellTargetImmunity(GlobalImmunityMind) &&
               !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 3) &&
               // 1.4 - Added test for correct race.
               (GetIsPlayableRacialType(GlobalSpellTarget) ||
                GlobalSpellTargetRace == RACIAL_TYPE_HUMANOID_GOBLINOID ||
                GlobalSpellTargetRace == RACIAL_TYPE_HUMANOID_MONSTROUS ||
                GlobalSpellTargetRace == RACIAL_TYPE_HUMANOID_ORC ||
                GlobalSpellTargetRace == RACIAL_TYPE_HUMANOID_REPTILIAN))
            {
                // Hold Person. Level 3 (Mage) 2 (Cleric/Bard) Paralyze's 1 humanoid target (Playable Race/humanoid), if they fail a will save.
                if(AI_ActionCastSpellRandom(SPELL_HOLD_PERSON, 40, GlobalSpellTarget, 13, FALSE)) return TRUE;
            }
            // Searing light does good type of damage - divine, and is alright damage amount (up to 5d8) and more importantly, no save!
            // Searing Light. Level 3 (Cleric). Maxs of 10d6 to undead, 5d8 to others, 5d6 to constructs. Divine damage. Done above (way above) VS undead
            if(AI_ActionCastSpellRandom(SPELL_SEARING_LIGHT, 30, GlobalSpellTarget, 13, FALSE)) return TRUE;
            // Dominate Animal. Must be an animal, duh! Dominates an animal only. Will save.
            if(!AI_GetSpellTargetImmunity(GlobalImmunityDomination) &&
               !AI_GetSpellTargetImmunity(GlobalImmunityMind) &&
               !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 3))
            {
                // Dominate Animal. Level 3 (Druid)  Dominates an animal only. Will save.
                if(AI_ActionCastSpellRandom(SPELL_DOMINATE_ANIMAL, 30, GlobalSpellTarget, 13, FALSE)) return TRUE;
            }
        }
        if(bRangeShortValid)
        {
            // Quillfire. Poison isn't bad, and a little damage :-)
            if(!AI_GetSpellTargetImmunity(GlobalImmunityDomination) &&
               !AI_GetSpellTargetImmunity(GlobalImmunityMind) &&
               !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 3))
            {
                // Quillfire. Level 3 (Mage) 1 quill at 1d8 + 1-5 damage. Scorpion poison too.
                if(AI_ActionCastSpellRandom(SPELL_QUILLFIRE, 30, GlobalSpellTarget, 13, FALSE)) return TRUE;
            }
        }
        if(bRangeTouchValid)
        {
            // These 3 are necromantic
            if(!AI_GetSpellTargetImmunity(GlobalImmunityNecromancy))
            {
                // Infestation of maggots - lots of CON damage over time. :-)
                if(!GetHasSpellEffect(SPELL_INFESTATION_OF_MAGGOTS, GlobalSpellTarget))
                {
                    // Infestation of Maggots. Level 3 (Druid) 1d4 Temp constitution damage/round. (1 round/caster level)
                    if(AI_ActionCastSpellRandom(SPELL_INFESTATION_OF_MAGGOTS, 40, GlobalSpellTarget, 13, FALSE)) return TRUE;
                }
                // These 2 are negative energy
                if(!AI_GetSpellTargetImmunity(GlobalImmunityNegativeEnergy))
                {
                    // Healing sting isn't too bad. At least no immunities
                    // and levels up OK. Negative energy damage, however.
                    if(!AI_SaveImmuneSpellTarget(SAVING_THROW_FORT, 3))
                    {
                        // Healing Sting. Level 3 (Druid). 1d6 + 1/Caster evel damage, and healed for that amount. Fort save for none.
                        if(AI_ActionCastSpellRandom(SPELL_HEALING_STING, 40, GlobalSpellTarget, 13, FALSE)) return TRUE;
                    }
                    // Vampiric touch - good spell and scales nicely, and
                    // heals :-D
                    // Vampiric Touch. Level 3 (Mage) 1d6(caster level/2) in negative damage, heals us with temp HP.
                    if(AI_ActionCastSpellRandom(SPELL_VAMPIRIC_TOUCH, 30, GlobalSpellTarget, 13, FALSE)) return TRUE;
                }
            }
        }
        // Single spell override backup casting
        if(bSingleSpellOverride) if(AI_ActionCastBackupRandomSpell()) return TRUE;
    }
    // AOE spells
// [Fireball] - Up to 10d6 reflex fire damage, in a large AOE hit area. Allies are hit too! (as we all know...)
// [Call Lightning] - Lightning damage - To 10d6 reflex electrical. Never hits allies. Smaller AOE then fireball
// [Lightning Bolt] An "oh, other spell" to fireball. Does a different damage type. can be more useful - different shape! Can't hit caster! 10d6 reflex electrical
// [Slow] -50% speed, -1 Attack, -4 AC (I think) to those in an AOE - doesn't hit allies.
// [Negative Energy Burst] 1d8 + 1-20 (caster level) negative damage, and -1 STR/4 caster levels. Heals undead.
// [Stinking Cloud] - Dazes those in the AOE, if fail VS will.
// [Spike Growth] - Damage to those in the AOE, and slow for 24 Hours!
// [Gust of Wind] Knockdown enemies VS reflex. Main thing is Dispeling AOE's, and 1 is always kept in reserve.
// [Mestals Acid Breath] - A cone of up to 10d6 (acid) damage. Reflex save.
// [Scintillating Sphere] - Explosion of up to 10d6 Damage (Electical) - An electiric fireball (reflex save)
// [Glyph of Warding] - AOE, if entered, does up to 1d6/2 caster levels (to 5d6) damage.

    // Real fireball is hot! (Ban pun there...)
    // Scintillating Sphere is also fire-ball like, but electrical damage *shrugs*
    if(bRangeLongValid && (GetHasSpell(SPELL_FIREBALL) ||
       GetHasSpell(SPELL_SCINTILLATING_SPHERE) || GetHasSpell(SPELL_SHADES_FIREBALL)))
    {
        // Huge, long ranged, reflex based save. Normal = reaction friendly.
        oAOE = AI_GetBestAreaSpellTarget(fLongRange, RADIUS_SIZE_HUGE, 3, SAVING_THROW_REFLEX, SHAPE_SPHERE, GlobalFriendlyFireFriendly);
        // Is it valid? 70% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // (Shades) Fireball. Level 7 (Mage) Up to 10d6 reflex fire damage, in a large AOE hit area. Shades now hits allies.
            if(AI_ActionCastSpell(SPELL_SHADES_FIREBALL, oAOE, 17, TRUE, TRUE)) return TRUE;

            // Fireball. Level 3 (Mage) Up to 10d6 reflex fire damage, in a large AOE hit area. Allies are hit too! (as we all know...)
            if(AI_ActionCastSpellRandom(SPELL_FIREBALL, 60, oAOE, 13, TRUE)) return TRUE;

            // Scintillating Sphere. Level 3 (Mage) Explosion of up to 10d6 Damage (Electical) - An electiric fireball (reflex save)
            if(AI_ActionCastSpellRandom(SPELL_SCINTILLATING_SPHERE, 60, oAOE, 13, TRUE)) return TRUE;
        }
    }
    // Call Lightning - Never hits allies, so excelent to cast :-)
    if(bRangeLongValid && GetHasSpell(SPELL_CALL_LIGHTNING))
    {
        // Huge, long ranged, reflex based save. No enemies hit!
        oAOE = AI_GetBestAreaSpellTarget(fLongRange, RADIUS_SIZE_HUGE, 3, SAVING_THROW_REFLEX);
        // Is it valid? 70% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Call Lightning. Level 3 (Druid) Lightning damage - To 10d6 reflex electrical. Never hits allies. Smaller AOE then fireball
            if(AI_ActionCastSpellRandom(SPELL_CALL_LIGHTNING, 60, oAOE, 13, TRUE)) return TRUE;
        }
    }
    // Mestils acid breath is on the standard 10d6 max damage. Acid + cone
    if(bRangeShortValid && GetHasSpell(SPELL_MESTILS_ACID_BREATH))
    {
        // Short, cone based.
        oAOE = AI_GetBestAreaSpellTarget(fShortRange, 11.0, 3, SAVING_THROW_REFLEX, SHAPE_SPELLCONE, GlobalFriendlyFireFriendly);
        // Is it valid? 60% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Mestals Acid Breath. Level 3 (Mage) A cone of up to 10d6 (acid) damage. Reflex save.
            if(AI_ActionCastSpellRandom(SPELL_MESTILS_ACID_BREATH, 50, oAOE, 13, TRUE)) return TRUE;
        }
    }
    // Lightning Bolt. Basically, a fireball in a line. :-)
    // Requires a target object to hit.
    if(bRangeMediumValid && GetHasSpell(SPELL_LIGHTNING_BOLT))
    {
        // Requries an object. Hits allies. 30 spell cylinder range.
        oAOE = AI_GetBestAreaSpellTarget(fMediumRange, 30.0, 3, SAVING_THROW_REFLEX, SHAPE_SPELLCYLINDER, GlobalFriendlyFireFriendly);
        // Is it valid? 50% chance of casting - only if seen
        if(GetIsObjectValid(oAOE) && GetObjectSeen(oAOE))
        {
            // Lightning Bolt. Level 3 (Mage) An "oh, other spell" to fireball. Does a different damage type. can be more useful - different shape! Can't hit caster! 10d6 reflex electrical
            if(AI_ActionCastSpellRandom(SPELL_LIGHTNING_BOLT, 40, oAOE, 13, FALSE)) return TRUE;
        }
    }
    // Slow is a good AOE - hits enemies, and slows them (Will save)
    if(bRangeShortValid && GetHasSpell(SPELL_SLOW))
    {
        // Slow - doesn't hit allies. Colossal range.
        oAOE = AI_GetBestAreaSpellTarget(fShortRange, RADIUS_SIZE_COLOSSAL, 3, SAVING_THROW_WILL);
        // Is it valid? 50% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Slow. Level 3 (Mage/bard) -50% speed, -1 Attack, -4 AC (I think) to those in an AOE - doesn't hit allies.
            if(AI_ActionCastSpellRandom(SPELL_SLOW, 40, oAOE, 13, TRUE)) return TRUE;
        }
    }
    // Negative Energy Burst.  Negative damage (to non-undead) and strength loss.
    if(bRangeMediumValid && GetHasSpell(SPELL_NEGATIVE_ENERGY_BURST))
    {
        // Necromantic spell, hits allies.
        oAOE = AI_GetBestAreaSpellTarget(fMediumRange, RADIUS_SIZE_HUGE, 3, FALSE, SHAPE_SPHERE, GlobalFriendlyFireFriendly, FALSE, TRUE);
        // Is it valid? 50% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Negative Energy Burst. Level 3 (Mage) 1d8 + 1-20 (caster level) negative damage, and -1 STR/4 caster levels. Heals undead.
            if(AI_ActionCastSpellRandom(SPELL_NEGATIVE_ENERGY_BURST, 40, oAOE, 13, TRUE)) return TRUE;
        }
    }
    // Stinking Cloud. Daze, lots of daze (will based)
    if(bRangeMediumValid && GetHasSpell(SPELL_STINKING_CLOUD))
    {
        // Allies are hit, will save to be immune.
        oAOE = AI_GetBestAreaSpellTarget(fMediumRange, RADIUS_SIZE_LARGE, 3, SAVING_THROW_WILL, SHAPE_SPHERE, GlobalFriendlyFireFriendly);
        // Is it valid? 50% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Stinking Cloud. Level 3 (Mage) Dazes those in the AOE, if fail VS will.
            if(AI_ActionCastSpellRandom(SPELL_STINKING_CLOUD, 40, oAOE, 13, TRUE)) return TRUE;
        }
    }
    // Spike Growth. Alright AOE - 30% speed decrease for 24HRS is the best bit.
    if(bRangeMediumValid && GetHasSpell(SPELL_SPIKE_GROWTH))
    {
        // Allies are hit, will save to be immune.
        oAOE = AI_GetBestAreaSpellTarget(fMediumRange, RADIUS_SIZE_LARGE, 3, SAVING_THROW_WILL, SHAPE_SPHERE, GlobalFriendlyFireFriendly);
        // Is it valid? 50% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Spike Growth. Level 3 (Druid) AOE - 30% speed decrease for 24HRS + 1d4 piercing damage/round.
            if(AI_ActionCastSpellRandom(SPELL_SPIKE_GROWTH, 40, oAOE, 13, TRUE)) return TRUE;
        }
    }
    // Gust of Wind. Always need 2 of these (1 to dispel AOE's)
    if(bRangeMediumValid && GetHasSpell(SPELL_GUST_OF_WIND) >= 2)
    {
        // Allies are hit, will save to be immune.
        oAOE = AI_GetBestAreaSpellTarget(fMediumRange, RADIUS_SIZE_HUGE, 3, SAVING_THROW_FORT, SHAPE_SPHERE, GlobalFriendlyFireFriendly);
        // Is it valid? 50% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Gust of Wind. Level 3 (Bard/Mage) Dispels all AOE's in radius, and save VS fort for 3 round knockdown.
            if(AI_ActionCastSpellRandom(SPELL_GUST_OF_WIND, 40, oAOE, 13, TRUE)) return TRUE;
        }
    }
    // Glyph of Warding is cast last, lowest %, and just at spell target.
    // This is because it is good for setting up traps, but not that good
    // in combat, apart from the damage type. 30%
    if(GlobalSeenSpell && bRangeShortValid)
    {
        // Glyph of Warding. Level 3 (Mage) AOE, if entered, does up to 1d6/2 caster levels (to 5d6) damage.
        if(AI_ActionCastSpellRandom(SPELL_GLYPH_OF_WARDING, 20, GlobalSpellTarget, 13, TRUE)) return TRUE;
    }

    // Multi spell override backup casting
    if(bMultiSpellOverride) if(AI_ActionCastBackupRandomSpell()) return TRUE;

    // Level 3 summons
    if(bFirstRunThrough && GlobalCanSummonSimilarLevel <= 3 &&
      (GlobalOurHitDice <= 10 || GlobalMeleeAttackers <= 2))
    {
        // Pale master - Feat Animate Dead
        if(AI_ActionCastSummonSpell(SPELLABILITY_PM_ANIMATE_DEAD, -1, 3, FEAT_ANIMATE_DEAD)) return TRUE;

        // Animate Dead. Level 3 (Mage). Skeleton or zomie summon. Tough DR, long lasting, but hard to heal.
        if(AI_ActionCastSummonSpell(SPELL_ANIMATE_DEAD, 13, 3)) return TRUE;

        // Summon Monster III (3). Level 3 (Most classes) Summons a Dire Wolf.
        if(AI_ActionCastSummonSpell(SPELL_SUMMON_CREATURE_III, 13, 3)) return TRUE;
    }

    // Single target spells.
    // - We don't cast inflict serious wounds. GetHasSpell bodges with spontaeous spells.
    if(GlobalSeenSpell && GlobalNormalSpellsNoEffectLevel < 3)
    {
        // Flame arrow - not THE best spell, but well worth it. Also it is long range.
        if(bRangeLongValid && !AI_SaveImmuneSpellTarget(SAVING_THROW_REFLEX, 3))
        {
            // Flame Arrow. Level 3 (Mage) 4d6 Reflex Fire Damage for each missile - 1/4 caster levels.
            if(AI_ActionCastSpellRandom(SPELL_FLAME_ARROW, 30, GlobalSpellTarget, 13, FALSE)) return TRUE;
        }
        // All others are in medium range or smaller
        if(bRangeMediumValid)
        {
            // Hold Person - must be playable race, of course. Still quite powerful - as it paralyzes.
            if(!AI_GetSpellTargetImmunity(GlobalImmunityStun) &&
               !AI_GetSpellTargetImmunity(GlobalImmunityMind) &&
               !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 3) &&
               // 1.4 - Added test for correct race.
               (GetIsPlayableRacialType(GlobalSpellTarget) ||
                GlobalSpellTargetRace == RACIAL_TYPE_HUMANOID_GOBLINOID ||
                GlobalSpellTargetRace == RACIAL_TYPE_HUMANOID_MONSTROUS ||
                GlobalSpellTargetRace == RACIAL_TYPE_HUMANOID_ORC ||
                GlobalSpellTargetRace == RACIAL_TYPE_HUMANOID_REPTILIAN))
            {
                // Hold Person. Level 3 (Mage) 2 (Cleric/Bard) Paralyze's 1 humanoid target (Playable Race/humanoid), if they fail a will save.
                if(AI_ActionCastSpellRandom(SPELL_HOLD_PERSON, 20, GlobalSpellTarget, 13, FALSE)) return TRUE;
            }
            // Searing light does good type of damage - divine, and is alright damage amount (up to 5d8) and more importantly, no save!
            // Searing Light. Level 3 (Cleric). Maxs of 10d6 to undead, 5d8 to others, 5d6 to constructs. Divine damage. Done above (way above) VS undead
            if(AI_ActionCastSpellRandom(SPELL_SEARING_LIGHT, 10, GlobalSpellTarget, 13, FALSE)) return TRUE;
            // Dominate Animal. Must be an animal, duh! Dominates an animal only. Will save.
            if(!AI_GetSpellTargetImmunity(GlobalImmunityDomination) &&
               !AI_GetSpellTargetImmunity(GlobalImmunityMind) &&
               !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 3))
            {
                // Dominate Animal. Level 3 (Druid)  Dominates an animal only. Will save.
                if(AI_ActionCastSpellRandom(SPELL_DOMINATE_ANIMAL, 10, GlobalSpellTarget, 13, FALSE)) return TRUE;
            }
        }
        if(bRangeShortValid)
        {
            // Quillfire. Poison isn't bad, and a little damage :-)
            if(!AI_GetSpellTargetImmunity(GlobalImmunityDomination) &&
               !AI_GetSpellTargetImmunity(GlobalImmunityMind) &&
               !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 3))
            {
                // Quillfire. Level 3 (Mage) 1 quill at 1d8 + 1-5 damage. Scorpion poison too.
                if(AI_ActionCastSpellRandom(SPELL_QUILLFIRE, 10, GlobalSpellTarget, 13, FALSE)) return TRUE;
            }
        }
        if(bRangeTouchValid)
        {
            // These 3 are necromantic
            if(!AI_GetSpellTargetImmunity(GlobalImmunityNecromancy))
            {
                // Infestation of maggots - lots of CON damage over time. :-)
                if(!GetHasSpellEffect(SPELL_INFESTATION_OF_MAGGOTS, GlobalSpellTarget))
                {
                    // Infestation of Maggots. Level 3 (Druid) 1d4 Temp constitution damage/round. (1 round/caster level)
                    if(AI_ActionCastSpellRandom(SPELL_INFESTATION_OF_MAGGOTS, 20, GlobalSpellTarget, 13, FALSE)) return TRUE;
                }
                // These 2 are negative energy
                if(!AI_GetSpellTargetImmunity(GlobalImmunityNegativeEnergy))
                {
                    // Healing sting isn't too bad. At least no immunities
                    // and levels up OK. Negative energy damage, however.
                    if(!AI_SaveImmuneSpellTarget(SAVING_THROW_FORT, 3))
                    {
                        // Healing Sting. Level 3 (Druid). 1d6 + 1/Caster evel damage, and healed for that amount. Fort save for none.
                        if(AI_ActionCastSpellRandom(SPELL_HEALING_STING, 20, GlobalSpellTarget, 13, FALSE)) return TRUE;
                    }
                    // Vampiric touch - good spell and scales nicely, and
                    // heals :-D
                    // Vampiric Touch. Level 3 (Mage) 1d6(caster level/2) in negative damage, heals us with temp HP.
                    if(AI_ActionCastSpellRandom(SPELL_VAMPIRIC_TOUCH, 10, GlobalSpellTarget, 13, FALSE)) return TRUE;
                }
            }
        }
    }

    // Backup spell
    if(AI_ActionCastBackupRandomSpell()) return TRUE;

    // Serious wounds - damage at a touch attack.
    if(GlobalSeenSpell && GlobalNormalSpellsNoEffectLevel < 3 && bRangeTouchValid)
    {
        // Cast Cure Critical Wounds (Which acts the same way for undead as
        // inflict critical does)
        if(GlobalSpellTargetRace == RACIAL_TYPE_UNDEAD)
        {
            // Cure Serious Wounds. Level 3 (Cleric) Touch attack, hit means 3d8 + 1-15 positive damage.
            if(AI_ActionCastSpontaeousSpell(SPELL_CURE_SERIOUS_WOUNDS, GlobalSpellTarget)) return TRUE;
        }
        if(!AI_GetSpellTargetImmunity(GlobalImmunityNecromancy) &&
           !AI_GetSpellTargetImmunity(GlobalImmunityNegativeEnergy))
        {
            // Blackguard ability
            if(AI_ActionUseSpellLikeFeat(FEAT_INFLICT_SERIOUS_WOUNDS, SPELLABILITY_BG_INFLICT_SERIOUS_WOUNDS, GlobalMeleeTarget)) return TRUE;

            // Inflict Serious Wounds. Level 3 (Cleric) Touch attack, hit means 3d8 + 1-15 negative damage.
            if(AI_ActionCastSpontaeousSpell(SPELL_INFLICT_SERIOUS_WOUNDS, GlobalSpellTarget)) return TRUE;
        }
    }

/*::2222222222222222222222222222222222222222222222222222222222222222222222222222
    Level 2 Spells.
//::2222222222222222222222222222222222222222222222222222222222222222222222222222
    Thoughts - Lacking in AOE spells, as it is lower levels, it really
    lacks a lot of spells anyway. A few decent damage spells, but many of the
    spells are special-case healing, or cast elsewhere. Dispels all level 1
    protections here.

    AOE:
S   [Balagarn's Iron Horn] Need to beat (Enemy STR + d20) with 20 + d20. If so, 6 second knockdown
    [Web] - Reflex saves or entangles and stuck in the web. AOE, quite large, persistant.
    [Sound Burst] - 1d8 sonic damage + Stun unless save VS will.
    [Silence] - Silence AOE that moves with target. Applie silence to those in the AOE.
H   [Cloud of Bewilderment] - Enemies only are stunned and blinded in the AOE. Fort save.
H   [Gedlee's Electric Loop] - All in AOE have 1d6 Electric dam (to 5d6) + will save for 1 round stun.

    [Lesser Dispel] - Can be cast in silence (Stomatic only). Dispel up to +5 check.

    Single:
    [Blindness/Deafness] - Blindness/deafness on Fort save failure.
    [Ghoul Touch] - Fort save VS paralysis and an AOE on target which gives -2 attack/damage to enemies nearby.
    [Melf's Acid Arrow] - 3d6 Impact and 1d6 damage for up to 7 rounds (caster level/3) after that
S   [Tasha's Hideous Laughter] Knockdown for 1d3 rounds, if
    [Charm Person or Animal] Charms an animal, or humanoid, if fail mind will save.
S   [Flame Lash] 2d6 + 1d6/3 caster levels of fire damage. Reflex save.
    [Hold Animal] Paralyze's an amimal race target, if they fail a will save.
S   [Inflict Moderate Wounds] 2d8 + 1-10 damage on a touch attack
H   [Continual Flame] 2d6 + 1 Caster Level (to +10) Fire dam. Reflex save. Every round after, reflex (until sucess) at 1d6 damage.

    Defender:
  X [Darkness]- Darkness. Supposedly caster can see. Basically an area of blindness countered with ultravision
    [Ghostly Visage] - 5/+1 DR. 0/1 spell immunity. 10% consealment.
  X [Invisibility] - Invisbile (not inaudible) until a hostile action.
  X [Resist Elements] - Resists 20/- elemental damage, until 30 damage is done. Cast above
    [Barkskin] - 1-6 = +3, 7-12 = +4. 13+ = +5 natural armor AC bonus.
H   [Death Armor] - 1d4 + 1/2 caster levels (to +5) damage shield (Magical damage!)
H   [Stone Bones] - An undead target gets +3 natural AC.

    Summon:
    [Summon Creature II] - Summons a Dire Boar

    Other:
  X [Bull's Strength] +Strength stat. Cast before melee normally.
  X [Cat's Grace] *bulls strength*
  X [Continual Flame] - Light for ever.
  X [Eagle's Splendor] *bulls strength*
  X [Endurance] *bulls strength*
  X [Fox's Cunning] *bulls strength*
  X [Knock] - Unlocks doors. Done OnBlocked.
  X [Owl's Wisdom] *bulls strength*
  X [See Invisibility] Cast in special cases. Pierces Invisiblity.
  X [Ultravision] Lets you see fully in Darkness AOE's.
S X [Blood Frenzy] Rage - +3STR, CON - 2 AC.
S X [One with the Land] +4 Hide, Move Silently, Set Traps and Animal Empthy. not cast in this AI
  X [Aid] +1d8 HP bonus, +1 attack/damage.
  X [Cure Moderate Wounds] Cures 2d8 Damage + 1-10.
  X [Lesser Restoration] Removes some bad effects.
  X [Remove Paralysis] Removes paralysis!
H X [Flame Weapon] - 1d4 + 1/caster level (to +10) fire damage to a weapon.
H X [Aura of Glory] - +4 Char, and allies get +4 VS Fear effects.

//::22222222222222222222222222222222222222222222222222222222222222222222222222*/

    // Jump out if we don't want to cast level 2 spells.
    if(nLowestSpellLevel > 2) return FALSE;

    if(bFirstRunThrough)
    {
        // Barkskin (if not already)
        if(!AI_GetAIHaveSpellsEffect(GlobalHasNaturalACSpell))
        {
            // This is natural AC, and only for undead. Cast it on ourselves, or
            // our summoned undead monster.
            if(GetRacialType(OBJECT_SELF) == RACIAL_TYPE_UNDEAD)
            {
                // Stone bones - cast if we do not have a natural armor AC spell.
                if(AI_ActionCastSpell(SPELL_STONE_BONES, OBJECT_SELF, 12, FALSE)) return TRUE;
            }
            else if(GetRacialType(GlobalBuffAlly) == RACIAL_TYPE_UNDEAD)
            {
                // Stone bones - cast if we do not have a natural armor AC spell.
                if(AI_ActionCastSpell(SPELL_STONE_BONES, GlobalBuffAlly, 12, FALSE)) return TRUE;
            }
            // Barkskin. Level 2 (Druid). 1-6 = +3, 7-12 = +4. 13+ = +5 natural armor AC bonus.
            if(AI_ActionCastSpell(SPELL_BARKSKIN, OBJECT_SELF, 12, FALSE)) return TRUE;
        }
        // See AC notes in level 1 spells.

        // Cast ally buff spells if we are a buffer
        if(GlobalWeAreBuffer)
        {
            // Some AC protections
            if(AI_ActionCastAllyBuffSpell(6.0, 100, SPELL_BARKSKIN, SPELL_MAGE_ARMOR)) return TRUE;
        }

        // All visage spells here.
        if(AI_SpellWrapperVisageProtections(nLowestSpellLevel)) return TRUE;

        // Eyeball rays. Low stuff, but hey, whatever, eh?
        // Random cast these. 3 random ones.
        if(bRangeMediumValid)
        {
            // Random cast. Each one has 30-50 % chance. Doesn't matter which we use!
            if(AI_ActionCastSpellRandom(AI_SPELLABILITY_EYEBALL_RAY_0, 40, GlobalSpellTarget)) return TRUE;
            if(AI_ActionCastSpellRandom(AI_SPELLABILITY_EYEBALL_RAY_1, 40, GlobalSpellTarget)) return TRUE;
            if(AI_ActionCastSpellRandom(AI_SPELLABILITY_EYEBALL_RAY_2, 40, GlobalSpellTarget)) return TRUE;

            // Backup cast
            if(AI_ActionCastBackupRandomSpell()) return TRUE;
        }
    }

    // Dispel level 1 protections (Hastes, regenerates, tensors...)
    if(AI_ActionAttemptDispel(1, bRangeMediumValid)) return TRUE;

    // BAB check
    // - BAB checks check our BASE attack bonus, no modifiers. Basically, as
    //   normally even mages have a +X to attack, this provides a good indicator
    //   if we are going to easy, or very easily, hit the enemy.
    // - Clerics, Druids and Bards must be able to hit even better then normal.
    if(bFirstRunThrough && !SRA &&
       GlobalOurChosenClass != CLASS_TYPE_WIZARD &&
       GlobalOurChosenClass != CLASS_TYPE_SORCERER &&
       GlobalOurChosenClass != CLASS_TYPE_FEY)
    {
        // If a druid, cleric, and so on, have to be able to hit better then
        // more then normal
        if(GlobalOurChosenClass == CLASS_TYPE_CLERIC ||
           GlobalOurChosenClass == CLASS_TYPE_DRUID ||
           GlobalOurChosenClass == CLASS_TYPE_BARD)
        {
            // BAB check for level 3 spells.
            // Must be able to hit them 75% of the time.
            if(GlobalOurBaseAttackBonus + 5 >= GlobalMeleeTargetAC) return FALSE;
        }
        // Demons, fighters, anything else really.
        else
        {
            // BAB check for level 3 spells.
            // 50% chance of hitting them outright.
            if(GlobalOurBaseAttackBonus + 10 >= GlobalMeleeTargetAC) return FALSE;
        }
    }

    // Level 2 random hostile spell
// Single:
// [Melf's Acid Arrow] - 3d6 Impact and 1d6 damage for up to 7 rounds (caster level/3) after that
// [Hold Animal] Paralyze's an amimal race target, if they fail a will save.
// [Blindness/Deafness] - Blindness/deafness on Fort save failure.
// [Tasha's Hideous Laughter] Knockdown for 1d3 rounds, if fail will save. -4 DC if different races
// [Charm Person or Animal] Charms an animal, or humanoid, if fail mind will save.
// [Flame Lash] 2d6 + 1d6/3 caster levels of fire damage. Reflex save.
// [Ghoul Touch] - Fort save VS paralysis and an AOE on target which gives -2 attack/damage to enemies nearby.
// [Continual Flame] 2d6 + 1 Caster Level (to +10) Fire dam. Reflex save. Every round after, reflex (until sucess) at 1d6 damage.

    // Is it best to target with single-target spells first?
    // Acid arrow, flame lash all scale well, while blindness/deafness is a good spell too.
    // 60-70% if favourable.
    // - We don't cast inflict serious wounds here. GetHasSpell bodges with spontaeous spells.
    if(bSingleSpellsFirst && GlobalSeenSpell && GlobalNormalSpellsNoEffectLevel < 2)
    {
        // Ghoul Touch. Paralysis is good :-D
        if(bRangeTouchValid && !AI_GetSpellTargetImmunity(GlobalImmunityNecromancy) &&
           !AI_SaveImmuneSpellTarget(SAVING_THROW_FORT, 2))
        {
            // Ghoul Touch. Level 2 (Mage) - Fort save VS paralysis and an AOE on target which gives -2 attack/damage to enemies nearby.
            if(AI_ActionCastSpellRandom(SPELL_GHOUL_TOUCH, 50, GlobalSpellTarget, 12, FALSE)) return TRUE;
        }
        if(bRangeLongValid)
        {
            // Greater shadow conjuration
            // This if statement here is because AI_ActionCastSpellRandom() doesn't have
            // support for bSubSpell. Will probably change later.
            if(d10() <= 6)
            {
                if(AI_ActionCastSpell(SPELL_GREATER_SHADOW_CONJURATION_ACID_ARROW, GlobalSpellTarget, 12, FALSE, TRUE)) return TRUE;
            }
            // Acid arrow - decent enough, and persistant damage, and no save. Long range too!
            // Melf's Acid Arrow. Level 2 (Mage) 3d6 Impact and 1d6 damage for up to 7 rounds (caster level/3) after that
            if(AI_ActionCastSpellRandom(SPELL_MELFS_ACID_ARROW, 60, GlobalSpellTarget, 12, FALSE)) return TRUE;
        }
        // Continual flame isn't a bad spell - touch spell, and does
        // continual damage (reflex based)
        if(bRangeTouchValid && !AI_SaveImmuneSpellTarget(SAVING_THROW_REFLEX, 2))
        {
            // Continual Flame. Level 2 (Mage) 3 (Cleric) 2d6 + 1 Caster Level (to +10) Fire dam. Reflex save. Every round after, reflex (until sucess) at 1d6 damage.
            if(AI_ActionCastSpellRandom(SPELL_CONTINUAL_FLAME, 60, GlobalSpellTarget, 12, FALSE)) return TRUE;
        }
        // Flame Lash is an alright amount of flame damage.
        if(bRangeShortValid && !AI_SaveImmuneSpellTarget(SAVING_THROW_REFLEX, 2))
        {
            // [Flame Lash] 2d6 + 1d6/3 caster levels of fire damage. Reflex save.
            if(AI_ActionCastSpellRandom(SPELL_FLAME_LASH, 50, GlobalSpellTarget, 12, FALSE)) return TRUE;
        }
        if(bRangeMediumValid)
        {
            // Hold Animal - animals are paralyzed on a will save failure.
            if(GlobalSpellTargetRace == RACIAL_TYPE_ANIMAL &&
              !AI_GetSpellTargetImmunity(GlobalImmunityStun) &&
              !AI_GetSpellTargetImmunity(GlobalImmunityMind) &&
              !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 2))
            {
                // Hold Animal. Level 2 (Druid/Ranger) Paralyze's an amimal race target, if they fail a will save.
                if(AI_ActionCastSpellRandom(SPELL_HOLD_ANIMAL, 50, GlobalSpellTarget, 12, FALSE)) return TRUE;
            }
            // Blindness/Deafness is a pretty good spell.
            if(!AI_GetSpellTargetImmunity(GlobalImmunityBlindDeaf) &&
               !AI_SaveImmuneSpellTarget(SAVING_THROW_FORT, 2))
            {
                // Blindness/Deafness. Level 2 (Mage/Bard) 3 (Cleric) Blindness/deafness on Fort save failure.
                if(AI_ActionCastSpellRandom(SPELL_BLINDNESS_AND_DEAFNESS, 50, GlobalSpellTarget, 12, FALSE)) return TRUE;
            }
            // Tasha's Hideous Laughter is knockdown - not too bad.
            // - We don't bother with the +4/-4.
            if(!AI_GetSpellTargetImmunity(GlobalImmunityMind) &&
               !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 2))
            {
                // Tasha's Hideous Laughter. Level 2 (Bard/Mage) Knockdown for 1d3 rounds, if fail will save. -4 DC if different races
                if(AI_ActionCastSpellRandom(SPELL_TASHAS_HIDEOUS_LAUGHTER, 50, GlobalSpellTarget, 12, FALSE)) return TRUE;
            }
        }
        if(bRangeShortValid)
        {
            // Charm Person or Animal. Charms an animal, or humanoid, if fail mind will save.
            if(!AI_GetSpellTargetImmunity(GlobalImmunityDomination) &&
               !AI_GetSpellTargetImmunity(GlobalImmunityMind) &&
              (GetIsPlayableRacialType(GlobalSpellTarget) || GlobalSpellTargetRace == RACIAL_TYPE_ANIMAL) &&
               !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 2))
            {
                // Charm Person or Animal. Level 2 (Druid) Charms an animal, or humanoid, if fail mind will save.
                if(AI_ActionCastSpellRandom(SPELL_CHARM_PERSON_OR_ANIMAL, 50, GlobalSpellTarget, 12, FALSE)) return TRUE;
            }
        }

        // Single spell override backup casting
        if(bSingleSpellOverride) if(AI_ActionCastBackupRandomSpell()) return TRUE;
    }

// AOE:
// [Silence] - Silence AOE that moves with target. Applies silence to those in the AOE.
// [Web] - Reflex saves or entangles and stuck in the web. AOE, quite large, persistant.
// [Balagarn's Iron Horn] Need to beat (Enemy STR + d20) with 20 + d20. If so, 6 second knockdown
// [Sound Burst] - 1d8 sonic damage + Stun unless save VS will.
// [Cloud of Bewilderment] - Creatures are stunned and blinded in the AOE. Fort save.
// [Gedlee's Electric Loop] - All in AOE have 1d6 Electric dam (to 5d6) + will save for 1 round stun.

    // Silence - must be a mage or sorceror. No talent for this, BTW. Also
    // note: can't have the spell's effects already, and must be over 10M away.
    if(bRangeLongValid && GlobalSeenSpell && GlobalSpellTargetRange >= 10.0 &&
       !GetHasSpellEffect(SPELL_SILENCE, GlobalSpellTarget) &&
       (GetLevelByClass(CLASS_TYPE_WIZARD, GlobalSpellTarget) ||
        GetLevelByClass(CLASS_TYPE_SORCERER, GlobalSpellTarget) ||
        GetLevelByClass(CLASS_TYPE_CLERIC, GlobalSpellTarget)))
    {
        // Silence. Level 2 (Mage/Cleric/Bard) Silence AOE that moves with target. Applies silence to those in the AOE.
        if(AI_ActionCastSpellRandom(SPELL_SILENCE, 60, GlobalSpellTarget, 12)) return TRUE;
    }
    // Gedlee's Electric Loop is a good damaging AOE spell - and the only mage level 2 one.
    // - Note, it is set as DiscrnMinate, but is really IndiscrnMinate (ReactionType)
    if(bRangeShortValid && GetHasSpell(SPELL_GEDLEES_ELECTRIC_LOOP))
    {
        // Small, short ranged, and reflex save based.
        oAOE = AI_GetBestAreaSpellTarget(fShortRange, RADIUS_SIZE_SMALL, 2, SAVING_THROW_REFLEX, SHAPE_SPHERE, GlobalFriendlyFireFriendly);
        // Is it valid? 70% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Gedlee's Electric Loop. Level 2 (Mage) All in AOE have 1d6 Electric dam (to 5d6) + will save for 1 round stun.
            if(AI_ActionCastSpellRandom(SPELL_GEDLEES_ELECTRIC_LOOP, 60, oAOE, 12, TRUE)) return TRUE;
        }
    }
    // Web - sticky stuff. Illusion version first :-D
    if(bRangeMediumValid && (GetHasSpell(SPELL_WEB) ||
       GetHasSpell(SPELL_GREATER_SHADOW_CONJURATION_WEB) ||
       GetHasSpell(AI_SPELLABILITY_BEBELITH_WEB)))
    {
        // large AOE, medium ranged, reflex based save. Reaction friendly.
        oAOE = AI_GetBestAreaSpellTarget(fMediumRange, RADIUS_SIZE_LARGE, 2, SAVING_THROW_REFLEX, SHAPE_SPHERE, GlobalFriendlyFireFriendly);
        // Is it valid? 70% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Beblith version
            if(AI_ActionCastSpellRandom(AI_SPELLABILITY_BEBELITH_WEB, 60, oAOE)) return TRUE;

            // Shades vesion. Shades is Level 6. Cast as subspell.
            if(AI_ActionCastSpell(SPELL_GREATER_SHADOW_CONJURATION_WEB, oAOE, 16, TRUE, TRUE)) return TRUE;

            // Web. Level 2 (Mage) Entangles on reflex sve.
            if(AI_ActionCastSpellRandom(SPELL_WEB, 60, oAOE, 12, TRUE)) return TRUE;
        }
    }
    // Cloud of Bewilderment is an alright AOE - stun and blindness :-)
    // Note - Only casts if the target is not immune to stun nor blindness!
    if(bRangeMediumValid &&
      !AI_GetSpellTargetImmunity(GlobalImmunityBlindDeaf) &&
      !AI_GetSpellTargetImmunity(GlobalImmunityStun) &&
       GetHasSpell(SPELL_CLOUD_OF_BEWILDERMENT))
    {
        //  5M radius (large) AOE, short ranged, fort based save. Reaction friendly.
        oAOE = AI_GetBestAreaSpellTarget(fShortRange, RADIUS_SIZE_LARGE, 2, SAVING_THROW_FORT, SHAPE_SPHERE, GlobalFriendlyFireFriendly);
        // Is it valid? 60% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Cloud of Bewilderment. Level 2 (Mage/Bard) Creatures are stunned and blinded in the AOE. Fort save.
            // Web. Level 2 (Mage) Entangles on reflex sve.
            if(AI_ActionCastSpellRandom(SPELL_CLOUD_OF_BEWILDERMENT, 50, oAOE, 12, TRUE)) return TRUE;
        }
    }
    // Balagarn's Iron Horn is only a 6 second knockdown, not too bad.
    // Mainly, it has no save. Caster gets +20 on d20, enemy gets strength bonus.
    // It is a personal, affects us spell :-)
    if(GlobalSpellTargetRange <= 5.0)
    {
        // Balagarn's Iron Horn. Level 2 (Mage) Need to beat (Enemy STR + d20) with 20 + d20. If so, 6 second knockdown
        if(AI_ActionCastSpellRandom(SPELL_BALAGARNSIRONHORN, 60, OBJECT_SELF, 12, TRUE)) return TRUE;
    }
    // Sound burst - best part is the stun! Trust me!  Long range too!
    if(bRangeLongValid && GetHasSpell(SPELL_SOUND_BURST))
    {
        // Medium AOE, medium ranged, will based save. Reaction friendly.
        oAOE = AI_GetBestAreaSpellTarget(fMediumRange, RADIUS_SIZE_MEDIUM, 2, SAVING_THROW_WILL, SHAPE_SPHERE, GlobalFriendlyFireFriendly);
        // Is it valid? 60% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Sound burst. Level 2 (cleric). 1d8 Sonic damage, and if fail will save, stunned for 2 rounds.
            if(AI_ActionCastSpellRandom(SPELL_SOUND_BURST, 50, oAOE, 12, TRUE)) return TRUE;
        }
    }

    // Multi spell override backup casting
    if(bMultiSpellOverride) if(AI_ActionCastBackupRandomSpell()) return TRUE;

    // Level 2 summons
    if(bFirstRunThrough && GlobalCanSummonSimilarLevel <= 2 &&
      (GlobalOurHitDice <= 8 || GlobalMeleeAttackers <= 2))
    {
        // Summon Monster II (2). Level 2 (Most classes) Summons a Dire Boar.
        if(AI_ActionCastSummonSpell(SPELL_SUMMON_CREATURE_II, 12, 2)) return TRUE;
    }

    // Single spells, lower %'s
    // - We don't cast inflict serious wounds. GetHasSpell bodges with spontaeous spells.
    if(GlobalSeenSpell && GlobalNormalSpellsNoEffectLevel < 2)
    {
        // Ghoul Touch. Paralysis is good :-D
        if(bRangeTouchValid && !AI_GetSpellTargetImmunity(GlobalImmunityNecromancy) &&
           !AI_SaveImmuneSpellTarget(SAVING_THROW_FORT, 2))
        {
            // Ghoul Touch. Level 2 (Mage) - Fort save VS paralysis and an AOE on target which gives -2 attack/damage to enemies nearby.
            if(AI_ActionCastSpellRandom(SPELL_GHOUL_TOUCH, 30, GlobalSpellTarget, 12, FALSE)) return TRUE;
        }
        if(bRangeLongValid)
        {
            // Temp addition because ActionCastSpellRandom() doesn't support subspells just yet.
            if(d10() <= 4)
            {
                // Greater shadow conjuration
                if(AI_ActionCastSpell(SPELL_GREATER_SHADOW_CONJURATION_ACID_ARROW, GlobalSpellTarget, 12, FALSE, TRUE)) return TRUE;
            }
            // Acid arrow - decent enough, and persistant damage, and no save. Long range too!
            // Melf's Acid Arrow. Level 2 (Mage) 3d6 Impact and 1d6 damage for up to 7 rounds (caster level/3) after that
            if(AI_ActionCastSpellRandom(SPELL_MELFS_ACID_ARROW, 30, GlobalSpellTarget, 12, FALSE)) return TRUE;
        }
        // Continual flame isn't a bad spell - touch spell, and does
        // continual damage (reflex based)
        if(bRangeTouchValid && !AI_SaveImmuneSpellTarget(SAVING_THROW_REFLEX, 2))
        {
            // Continual Flame. Level 2 (Mage) 3 (Cleric) 2d6 + 1 Caster Level (to +10) Fire dam. Reflex save. Every round after, reflex (until sucess) at 1d6 damage.
            if(AI_ActionCastSpellRandom(SPELL_CONTINUAL_FLAME, 30, GlobalSpellTarget, 12, FALSE)) return TRUE;
        }
        // Flame Lash is an alright amount of flame damage.
        if(bRangeShortValid && !AI_SaveImmuneSpellTarget(SAVING_THROW_REFLEX, 2))
        {
            // [Flame Lash] 2d6 + 1d6/3 caster levels of fire damage. Reflex save.
            if(AI_ActionCastSpellRandom(SPELL_FLAME_LASH, 30, GlobalSpellTarget, 12, FALSE)) return TRUE;
        }
        if(bRangeMediumValid)
        {
            // Hold Animal - animals are paralyzed on a will save failure.
            if(GlobalSpellTargetRace == RACIAL_TYPE_ANIMAL &&
              !AI_GetSpellTargetImmunity(GlobalImmunityStun) &&
              !AI_GetSpellTargetImmunity(GlobalImmunityMind) &&
              !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 2))
            {
                // Hold Animal. Level 2 (Druid/Ranger) Paralyze's an amimal race target, if they fail a will save.
                if(AI_ActionCastSpellRandom(SPELL_HOLD_PERSON, 30, GlobalSpellTarget, 12, FALSE)) return TRUE;
            }
            // Blindness/Deafness is a pretty good spell.
            if(!AI_GetSpellTargetImmunity(GlobalImmunityBlindDeaf) &&
               !AI_SaveImmuneSpellTarget(SAVING_THROW_FORT, 2))
            {
                // Blindness/Deafness. Level 2 (Mage/Bard) 3 (Cleric) Blindness/deafness on Fort save failure.
                if(AI_ActionCastSpellRandom(SPELL_BLINDNESS_AND_DEAFNESS, 30, GlobalSpellTarget, 12, FALSE)) return TRUE;
            }
            // Tasha's Hideous Laughter is knockdown - not too bad.
            // - We don't bother with the +4/-4.
            if(!AI_GetSpellTargetImmunity(GlobalImmunityMind) &&
               !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 2))
            {
                // Tasha's Hideous Laughter. Level 2 (Bard/Mage) Knockdown for 1d3 rounds, if fail will save. -4 DC if different races
                if(AI_ActionCastSpellRandom(SPELL_TASHAS_HIDEOUS_LAUGHTER, 30, GlobalSpellTarget, 12, FALSE)) return TRUE;
            }
        }
        if(bRangeShortValid)
        {
            // Charm Person or Animal. Charms an animal, or humanoid, if fail mind will save.
            if(!AI_GetSpellTargetImmunity(GlobalImmunityDomination) &&
               !AI_GetSpellTargetImmunity(GlobalImmunityMind) &&
              (GetIsPlayableRacialType(GlobalSpellTarget) || GlobalSpellTargetRace == RACIAL_TYPE_ANIMAL) &&
               !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 2))
            {
                // Charm Person or Animal. Level 2 (Druid) Charms an animal, or humanoid, if fail mind will save.
                if(AI_ActionCastSpellRandom(SPELL_CHARM_PERSON_OR_ANIMAL, 20, GlobalSpellTarget, 12, FALSE)) return TRUE;
            }
        }
    }

    // Backup casting
    if(AI_ActionCastBackupRandomSpell()) return TRUE;

    // Moderate wounds - damage at a touch attack.
    if(GlobalSeenSpell && GlobalNormalSpellsNoEffectLevel < 3 && bRangeTouchValid)
    {
        // Cast Cure Critical Wounds (Which acts the same way for undead as
        // inflict critical does)
        if(GlobalSpellTargetRace == RACIAL_TYPE_UNDEAD)
        {
            // Cure Moderate Wounds. Level 2 (Cleric) Touch attack, hit means 2d8 + 1-10 positive damage.
            if(AI_ActionCastSpontaeousSpell(SPELL_INFLICT_MODERATE_WOUNDS, GlobalSpellTarget)) return TRUE;
        }
        if(!AI_GetSpellTargetImmunity(GlobalImmunityNecromancy) &&
           !AI_GetSpellTargetImmunity(GlobalImmunityNegativeEnergy))
        {
            // Blackguard ability
            if(AI_ActionUseSpellLikeFeat(FEAT_INFLICT_MODERATE_WOUNDS, SPELLABILITY_BG_INFLICT_SERIOUS_WOUNDS, GlobalMeleeTarget)) return TRUE;

            // Inflict Moderate Wounds. Level 2 (Cleric) Touch attack, hit means 2d8 + 1-10 negative damage.
            if(AI_ActionCastSpontaeousSpell(SPELL_INFLICT_MODERATE_WOUNDS, GlobalSpellTarget)) return TRUE;
        }
    }

/*::1111111111111111111111111111111111111111111111111111111111111111111111111111
    Level 1 Spells.
//::1111111111111111111111111111111111111111111111111111111111111111111111111111
    Thoughts - Not bad AOE spells, better at lower levels or with more people.
    Magic missile is a decent spell for level 1, as it goes up to level 9 :-) and
    is a classic. Others are simple enough, doing small amounts of damage or
    doing some ability daamge, or sleep for limited hit dice creatures. Useful
    AC enhancing spells at level 1 though!

    AOE:
    [Burning Hands] - 1d4/level to 5d4 Reflex Fire damage to a cone AOE.
    [Color Spray] - effect based on HD - Sleep Stun and Blindness if fail will save
    [Grease] - Reflex save or knockdown, and slow in AOE.
    [Sleep] - 8HD or under creatures, will save VS sleep. Can do more then 1, if total HD affected under d4 + 4.
    [Entangle] - Entangles creatures in the AOE so they cannot move, reflex save, every round.
S   [Bane] - -1 to all saves VS fear, attack rolls, damage. Opposite of Bless.

    Single:
    [Charm Person] - Charms one humanoid if they fail a mind will save.
    [Magic Missile] - 1d4 + 1 damage/missile. 1 missile for 2 caster levels. Max 5 at level 9.
    [Negative Energy Ray] 1d6(CasterLevel/2) to 5d6 negative damage.
    [Doom] -2 Saves, Damage, to hit at a mind will save.
    [Ray of Enfeeblement] - d6 + (Caster level/2) strength damage to d6 + 10. Fort save.
    [Scare] - 1d4 round of fear, saving throw VS will, for 5HD or less creature
H   [Horzilkaul's Boom] - 1d4/2 caster levels (to 5d4) sonic damage, + Will VS deafness.
H   [Ice Dagger] - Reflex-based, 1d4/Level (to 5d4) ice damage.

S   [Inflict Light Wounds] 1d8 + 1-5 negative damage on touch attack.

    Defender:
  X [Endure Elements] 10/- Elemental resistance until 20 damage has been done
    [Mage Armor] +1 Dodge/Armor/Deflection/Natural AC bonuses. (total +4)
    [Protection From Alignment] +2 AC, mind immunity from alignment
S   [Shield] +4 Armor AC and immunity to magic missile.
S   [Shield of Faith] +2 deflection AC bonus, +1 every 6 levels (max +5)
S   [Entropic Shield] 20% Consealment VS ranged attacks.
H X [Iron Guts] +4 Saves VS poison. (cast as level 0 spell...this is specilised!)

    Summon:
    [Summon Creature I] - Summons a dire badger
H   [Shelgarn's Persistant Blade] - Summons a dagger for the caster.

    Other:
SXXX[Amiplify] +20 to listen checks.
S X [Expeditious Retreat] - 150% movement speed. Cast before melee.
XXXX[Identify] - Extra lore. Not cast
S X [True Strike] +9 attack for a single attack.
  X [Cure Light Wounds] 1d8 + 1-5 healing damage
  X [Bless] +1 to attack rolls, damage for AOE, +2 VS fear saves.
S X [Divine Favor] +1/3 caster levels attack bonus, to +5.
  X [Remove Fear] Removes fear!
  X [Sanctuary] Will saving throw for enemies to spot you. Kinda a bad invisiblity.
SXXX[Camouflage] +10 hide for self.
S   [Magic Fang] + 1 attack/damage to animal companion statistics.
H X [Magic Weapon] +1 enchantment to 1 weapon.
H X [Bless Weapon] +1 enchantment and +2d6 dam VS Undead to 1 weapon.
H X [Deafening Clang] +1 enchantment. +3 sonic damage. On Hit: Deafness, on a weapon.

//::11111111111111111111111111111111111111111111111111111111111111111111111111*/

    // Jump out if we don't want to cast level 1 spells.
    if(nLowestSpellLevel > 1) return FALSE;

    // Ok, AC increasing/defensive spells first.
    if(bFirstRunThrough)
    {
        // Entropic shield. 20% VS ranged attackers - we need some ranged attackers
        // OR people far away (After other AC spells). Also no normal consealment spells (they don't stack)
        if(GlobalRangedAttackers &&
          !AI_GetAIHaveSpellsEffect(GlobalHasConsealmentSpells) &&
          !AI_GetAIHaveSpellsEffect(GlobalHasRangedConsealment) &&
          !AI_GetAIHaveEffect(GlobalEffectInvisible))
        {
            // Entropic Shield. Level 1 (Cleric) 20% Consealment VS ranged attacks.
            if(AI_ActionCastSpell(SPELL_ENTROPIC_SHIELD, OBJECT_SELF, 11, FALSE)) return TRUE;
        }

        // We don't cast AC spells which will not do well over other AC inducing spells
        // - Shield + Divine Shield == Deflection. Never cast together
        // - Barkskin, Stone Bones == Natural
        // - Mage armor (+Epic) == Narual, Deflection, Dodge, Armor. Never cast with both Barkskin and Shield.

        // Out of the deflection spells, Shield first then Shield of Faith.
        if(!AI_GetAIHaveSpellsEffect(GlobalHasDeflectionACSpell))
        {
            // Shield. Level 1 (Mage) +4 Armor AC and immunity to magic missile.
            if(AI_ActionCastSpell(SPELL_SHIELD, OBJECT_SELF, 11, FALSE)) return TRUE;
            // Shield of Faith. Level 1 (Cleric) +2 deflection AC bonus, +1 every 6 levels (max +5)
            if(AI_ActionCastSpell(SPELL_SHIELD_OF_FAITH, OBJECT_SELF, 11, FALSE)) return TRUE;
        }
        // If we have not got natural or other AC, we cast mage armor.
        if(!AI_GetAIHaveSpellsEffect(GlobalHasNaturalACSpell) &&
           !AI_GetAIHaveSpellsEffect(GlobalHasOtherACSpell))
        {
            // Shadow conjuration version
            if(AI_ActionCastSpell(SPELL_SHADOW_CONJURATION_MAGE_ARMOR, OBJECT_SELF, 11, FALSE, TRUE)) return TRUE;
            // Mage Armor. Level 1 (Mage) +1 Dodge/Armor/Deflection/Natural AC bonuses. (total +4)
            if(AI_ActionCastSpell(SPELL_MAGE_ARMOR, OBJECT_SELF, 11, FALSE)) return TRUE;
        }

        // Cast Entropic shield if nearest enemy is over 4 M away.
        if(!GlobalEnemiesIn4Meters &&
           !AI_GetAIHaveSpellsEffect(GlobalHasConsealmentSpells) &&
           !AI_GetAIHaveSpellsEffect(GlobalHasRangedConsealment) &&
           !AI_GetAIHaveEffect(GlobalEffectInvisible))
        {
            // Entropic Shield. Level 1 (Cleric) 20% Consealment VS ranged attacks.
            if(AI_ActionCastSpell(SPELL_ENTROPIC_SHIELD, OBJECT_SELF, 11, FALSE)) return TRUE;
        }

        // Cheat and use protection froms. Have to rely upon talents :-/
        // as cannot specify using ActionCast - it plain don't wanna work.
        // Both cast as subspells.
        if(nEnemyAlignment == ALIGNMENT_GOOD &&
          !AI_GetAIHaveSpellsEffect(GlobalHasProtectionGoodSpell))
        {
            // Protection From Alignment. Level 1 (Bard/Cleric/Paladin/Mage). +2 AC, mind immunity from alignment
            if(AI_ActionCastSpell(SPELL_PROTECTION_FROM_GOOD, OBJECT_SELF, 11, FALSE, TRUE)) return TRUE;
        }
        else if(nEnemyAlignment == ALIGNMENT_EVIL &&
               !AI_GetAIHaveSpellsEffect(GlobalHasProtectionEvilSpell))
        {
            if(AI_ActionCastSpell(SPELL_PROTECTION_FROM_EVIL, OBJECT_SELF, 11, FALSE, TRUE)) return TRUE;
        }

        // Ally buff spells if buffer
        if(GlobalWeAreBuffer)
        {
            // Bless, Aid
            if(AI_ActionCastAllyBuffSpell(6.0, 100, SPELL_AID, SPELL_BLESS)) return TRUE;
        }
    }

    // BAB check
    // - BAB checks check our BASE attack bonus, no modifiers. Basically, as
    //   normally even mages have a +X to attack, this provides a good indicator
    //   if we are going to easy, or very easily, hit the enemy.
    // - Clerics, Druids and Bards must be able to hit even better then normal.
    if(bFirstRunThrough && !SRA &&
       GlobalOurChosenClass != CLASS_TYPE_WIZARD &&
       GlobalOurChosenClass != CLASS_TYPE_SORCERER &&
       GlobalOurChosenClass != CLASS_TYPE_FEY)
    {
        // If a druid, cleric, and so on, have to be able to hit better then
        // more then normal
        if(GlobalOurChosenClass == CLASS_TYPE_CLERIC ||
           GlobalOurChosenClass == CLASS_TYPE_DRUID ||
           GlobalOurChosenClass == CLASS_TYPE_BARD)
        {
            // BAB check for level 4 spells. 50%
            if(GlobalOurBaseAttackBonus+ 10 >= GlobalMeleeTargetAC) return FALSE;
        }
        // Demons, fighters, anything else really.
        else
        {
            // BAB check for level 4 spells. 25%
            if(GlobalOurBaseAttackBonus + 15 >= GlobalMeleeTargetAC) return FALSE;
        }
    }

    // Try grenades - we always throw these. They are about level 1 standard of DC's
    // and effects. Not too bad, when NPC's get a chance to use them! :-)
    if(bRangeMediumValid)
    {
        // - Note, these are also always thrown before melee, if the person has <5 HD.
        // - Reasons for not casting are really the BAB checks.
        if(AI_AttemptGrenadeThrowing(GlobalSpellTarget)) return TRUE;
    }

    // Random hostile spell
// [Magic Missile] - 1d4 + 1 damage/missile. 1 missile for 2 caster levels. Max 5 at level 9.
// [Negative Energy Ray] 1d6(CasterLevel/2) to 5d6 negative damage.
// [Scare] - 1d4 round of fear, saving throw VS will, for 5HD or less creature
// [Ray of Enfeeblement] - d6 + (Caster level/2) strength damage to d6 + 10. Fort save.
// [Doom] -2 Saves, Damage, to hit at a mind will save.
// [Charm Person] - Charms one humanoid if they fail a mind will save.
// [Horzilkaul's Boom] - 1d4/2 caster levels (to 5d4) sonic damage, + Will VS deafness.
// [Ice Dagger] - Reflex-based, 1d4/Level (to 5d4) ice damage.

    // Is it best to target with single-target spells first?
    // Magic missile, negative energy ray and flame lash are better at damaging
    // one target, if there is one target, then the AOE spells usually.
    // 60-70% if favourable.
    // - We don't cast inflict light wounds. GetHasSpell bodges with spontaeous spells.
    if(bSingleSpellsFirst && GlobalSeenSpell && GlobalNormalSpellsNoEffectLevel < 1)
    {
        // Magic Missile - Is a nice long range spell. Can do damage to almost anything.
        if(bRangeLongValid && !GetHasSpellEffect(SPELL_SHIELD, GlobalSpellTarget))
        {
            // as others, AI_ActionCastSpellRandom() ain't got subspell suppor yet.
            if(d10() <= 6)
            {
                // Shad. conjuration
                if(AI_ActionCastSpell(SPELL_SHADOW_CONJURATION_MAGIC_MISSILE, GlobalSpellTarget, 11, FALSE, TRUE)) return TRUE;
            }
            // Magic Missile. Level 1 (Mage) 1d4 + 1 damage/missile. 1 missile for 2 caster levels. Max 5 at level 9.
            if(AI_ActionCastSpellRandom(SPELL_MAGIC_MISSILE, 60, GlobalSpellTarget, 11, FALSE)) return TRUE;
        }
        // Horizikaul's boom is sonic damage - no save! Also, goes also to 5d4 (at level 10 anyway). Comparable to MM!
        if(bRangeShortValid)
        {
            // Horzilkaul's Boom. Level 1 (Mage) 1d4/2 caster levels (to 5d4) sonic damage, + Will VS deafness.
            if(AI_ActionCastSpellRandom(SPELL_HORIZIKAULS_BOOM, 50, GlobalSpellTarget, 11, FALSE)) return TRUE;
        }
        if(bRangeMediumValid)
        {
            // Negative energy ray is similar to Magic Missile, but heals undead. can do more dmage then MM, but more random - d6 compared to d4 + 1.
            if(GlobalSpellTargetRace != RACIAL_TYPE_UNDEAD &&
               GlobalSpellTargetRace != RACIAL_TYPE_CONSTRUCT &&
              !AI_GetSpellTargetImmunity(GlobalImmunityNecromancy) &&
              !AI_GetSpellTargetImmunity(GlobalImmunityNegativeEnergy))
            {
                // Negative Energy Ray. Level 1 (Mage) 2 (Cleric) 1d6(CasterLevel/2) to 5d6 negative damage.
                if(AI_ActionCastSpellRandom(SPELL_NEGATIVE_ENERGY_RAY, 50, GlobalSpellTarget, 11, FALSE)) return TRUE;
            }
            // Doom does some...stuff. The damage -2 is best. Will save negates.
            if(!GetHasSpellEffect(SPELL_DOOM, GlobalSpellTarget) &&
               !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 1))
            {
                // Doom. Level 1 (Mage) -2 Saves, Damage, to hit at a mind will save.
                if(AI_ActionCastSpellRandom(SPELL_DOOM, 50, GlobalSpellTarget, 11, FALSE)) return TRUE;
            }
        }
        if(bRangeShortValid)
        {
            // Damage with Ice Dagger is not bad - it is cirtinly comparable to MM! Saves though...
            if(!AI_SaveImmuneSpellTarget(SAVING_THROW_REFLEX, 1))
            {
                // Ice Dagger. Level 1 (Mage) Reflex-based, 1d4/Level (to 5d4) ice damage.
                if(AI_ActionCastSpellRandom(SPELL_ICE_DAGGER, 50, GlobalSpellTarget, 11, FALSE)) return TRUE;
            }
            // Scare - needs 5HD or under HD
            if(!AI_GetSpellTargetImmunity(GlobalImmunityFear) &&
               !AI_GetSpellTargetImmunity(GlobalImmunityNecromancy) &&
               !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 1))
            {
                // Scare. Level 1 (Mage) 1d4 round of fear, saving throw VS will, for 5HD or less creature
                if(AI_ActionCastSpellRandom(SPELL_SCARE, 50, GlobalSpellTarget, 11, FALSE)) return TRUE;
            }
            // Ray of Enfeeblement pities high strength enemies. d6 + 1-10 str. Loss
            if(GetAbilityScore(GlobalSpellTarget, ABILITY_STRENGTH) >= 14 &&
               !GetHasSpellEffect(SPELL_RAY_OF_ENFEEBLEMENT, GlobalSpellTarget) &&
               !AI_GetSpellTargetImmunity(GlobalImmunityNecromancy) &&
               !AI_SaveImmuneSpellTarget(SAVING_THROW_FORT, 1))
            {
                // Ray of Enfeeblement. Level 1 (Mage) d6 + (Caster level/2) strength damage to d6 + 10. Fort save.
                if(AI_ActionCastSpellRandom(SPELL_RAY_OF_ENFEEBLEMENT, 40, GlobalSpellTarget, 11, FALSE)) return TRUE;
            }
            // Charm Person charms them. Might as well... (Bit bad this spell)
            if(GetIsPlayableRacialType(GlobalSpellTarget) &&
               !AI_GetSpellTargetImmunity(GlobalImmunityDomination) &&
               !AI_GetSpellTargetImmunity(GlobalImmunityMind) &&
               !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 2))
            {
                // Charm Person. Level 1 (Mage/Bard) Charms one humanoid if they fail a mind will save.
                if(AI_ActionCastSpellRandom(SPELL_CHARM_PERSON, 30, GlobalSpellTarget, 11, FALSE)) return TRUE;
            }
        }
        // Single spell override backup casting
        if(bSingleSpellOverride) if(AI_ActionCastBackupRandomSpell()) return TRUE;
    }

    // Random AOE spell.
// [Burning Hands] - 1d4/level to 5d4 Reflex Fire damage to a cone AOE.
// [Color Spray] - effect based on HD - Sleep Stun and Blindness if fail will save
// [Grease] - Reflex save or knockdown, and slow in AOE.
// [Sleep] - 8HD or under creatures, will save VS sleep. Can do more then 1, if total HD affected under d4 + 4.
// [Bane] - -1 to all saves VS fear, attack rolls, damage. Opposite of Bless.
// [Entangle] - Entangles creatures in the AOE so they cannot move, reflex save, every round.

    // Burning hands - fire reflex damage to a cone
    if(bRangeShortValid && GetHasSpell(SPELL_BURNING_HANDS))
    {
        // Cone AOE, short ranged, reflex based save. Reaction friendly.
        oAOE = AI_GetBestAreaSpellTarget(fShortRange, 10.0, 1, SAVING_THROW_REFLEX, SHAPE_SPELLCONE, GlobalFriendlyFireFriendly);
        // Is it valid? 70% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Burning Hands. Level 1 (Mage) 1d4/level to 5d4 Reflex Fire damage to a cone AOE.
            if(AI_ActionCastSpellRandom(SPELL_BURNING_HANDS, 60, oAOE, 11, TRUE)) return TRUE;
        }
    }
    // Color Spray - Does at least blind higher levels. Will save, however, negates
    if(bRangeShortValid && GetHasSpell(SPELL_COLOR_SPRAY))
    {
        // Cone AOE, short ranged, reflex based save. Reaction friendly.
        oAOE = AI_GetBestAreaSpellTarget(fShortRange, 10.0, 1, SAVING_THROW_WILL, SHAPE_SPELLCONE, GlobalFriendlyFireFriendly);
        // Is it valid? 70% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Color Spray. Level 1 (Mage) - effect based on HD - Sleep Stun and Blindness if fail will save
            if(AI_ActionCastSpellRandom(SPELL_COLOR_SPRAY, 50, oAOE, 11, TRUE)) return TRUE;
        }
    }
    // Grease means knockdown - good if they are not immune to knockdown :-P (reflex save)
    if(bRangeLongValid && GetHasSpell(SPELL_GREASE))
    {
        // Take as Medium AOE, long ranged, reflex based save. Reaction friendly.
        oAOE = AI_GetBestAreaSpellTarget(fLongRange, RADIUS_SIZE_MEDIUM, 1, SAVING_THROW_REFLEX, SHAPE_SPHERE, GlobalFriendlyFireFriendly);
        // Is it valid? 60% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Grease. Level 1 (Mage) Reflex save or knockdown, and slow in AOE.
            if(AI_ActionCastSpellRandom(SPELL_GREASE, 50, oAOE, 11, TRUE)) return TRUE;
        }
    }
    // Sleep - 8HD or less average HD for enemy to target this.
    if(bRangeMediumValid && GlobalAverageEnemyHD <= 8 &&
      (GetHasSpell(SPELL_SLEEP) || GetHasFeat(FEAT_HARPER_SLEEP)))
    {
        // Huge AOE, medium ranged, will based save. Reaction type enemy
        oAOE = AI_GetBestAreaSpellTarget(fMediumRange, RADIUS_SIZE_HUGE, 1, SAVING_THROW_WILL, SHAPE_SPHERE, GlobalFriendlyFireHostile);
        // Is it valid? 60% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // The harper sleep
            if(AI_ActionUseSpellLikeFeat(FEAT_HARPER_SLEEP, AI_SPELLABILITY_HARPER_SLEEP, oAOE)) return TRUE;

            // Sleep. Level 1 (Mage) 8HD or under creatures, will save VS sleep. Can do more then 1, if total HD affected under d4 + 4.
            if(AI_ActionCastSpellRandom(SPELL_SLEEP, 50, oAOE, 11, TRUE)) return TRUE;
        }
    }
    // Bane is...alright, I guess. Will save, however. It doesn't affect allies though!
    if(bRangeLongValid && GetHasSpell(SPELL_BANE))
    {
        // collosal AOE, long ranged, will based save. No allies
        oAOE = AI_GetBestAreaSpellTarget(fMediumRange, RADIUS_SIZE_COLOSSAL, 1, SAVING_THROW_WILL);
        // Is it valid? 60% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Sleep. Level 1 (Mage) 8HD or under creatures, will save VS sleep. Can do more then 1, if total HD affected under d4 + 4.
            if(AI_ActionCastSpellRandom(SPELL_BANE, 50, oAOE, 11, TRUE)) return TRUE;
        }
    }
    // Entangle stops them moving - not a bad spell to say the least, I guess
    if(bRangeLongValid && GetHasSpell(SPELL_ENTANGLE))
    {
        // Huge AOE, Long ranged, reflex based save. Reaction type friendly
        oAOE = AI_GetBestAreaSpellTarget(fLongRange, RADIUS_SIZE_HUGE, 1, SAVING_THROW_REFLEX, SHAPE_SPHERE, GlobalFriendlyFireFriendly);
        // Is it valid? 60% chance of casting.
        if(GetIsObjectValid(oAOE))
        {
            // Entangle. Level 1 (Druid/Ranger) Entangles creatures in the AOE so they cannot move, reflex save, every round.
            if(AI_ActionCastSpellRandom(SPELL_ENTANGLE, 50, oAOE, 11, TRUE)) return TRUE;
        }
    }

    // Multi spell override backup casting
    if(bMultiSpellOverride) if(AI_ActionCastBackupRandomSpell()) return TRUE;

    // Level 1 summons
    if(bFirstRunThrough && GlobalCanSummonSimilarLevel <= 1 && GlobalOurHitDice <= 10 &&
      (GlobalOurHitDice <= 6 || GlobalMeleeAttackers <= 2))
    {
        // Shelgarn's Persistant Blade. Level 1 (Mage only) Summons a dagger for the caster.
        if(AI_ActionCastSummonSpell(SPELL_SHELGARNS_PERSISTENT_BLADE, 11, 1)) return TRUE;
        // Summon Monster I (1). Level 1 (Most classes) Summons a Dire Badger.
        if(AI_ActionCastSummonSpell(SPELL_SUMMON_CREATURE_I, 11, 1)) return TRUE;
    }

    // Single spells again
    // Similar %'s as it is level 1 spells.
    // - We don't cast inflict light wounds. GetHasSpell bodges with spontaeous spells.
    if(GlobalSeenSpell && GlobalNormalSpellsNoEffectLevel < 1)
    {
        // Magic Missile - Is a nice long range spell. Can do damage to almost anything.
        if(bRangeLongValid && !GetHasSpellEffect(SPELL_SHIELD, GlobalSpellTarget))
        {
            // Shad. conjuration
            if(d10() <= 4)
            {
                if(AI_ActionCastSpell(SPELL_SHADOW_CONJURATION_MAGIC_MISSILE, GlobalSpellTarget, 11, FALSE, TRUE)) return TRUE;
            }
            // Magic Missile. Level 1 (Mage) 1d4 + 1 damage/missile. 1 missile for 2 caster levels. Max 5 at level 9.
            if(AI_ActionCastSpellRandom(SPELL_MAGIC_MISSILE, 30, GlobalSpellTarget, 11, FALSE)) return TRUE;
        }
        // Horizikaul's boom is sonic damage - no save! Also, goes also to 5d4 (at level 10 anyway). Comparable to MM!
        if(bRangeShortValid)
        {
            // Horzilkaul's Boom. Level 1 (Mage) 1d4/2 caster levels (to 5d4) sonic damage, + Will VS deafness.
            if(AI_ActionCastSpellRandom(SPELL_HORIZIKAULS_BOOM, 30, GlobalSpellTarget, 11, FALSE)) return TRUE;
        }
        if(bRangeMediumValid)
        {
            // Negative energy ray is similar to Magic Missile, but heals undead. can do more dmage then MM, but more random - d6 compared to d4 + 1.
            if(GlobalSpellTargetRace != RACIAL_TYPE_UNDEAD &&
               GlobalSpellTargetRace != RACIAL_TYPE_CONSTRUCT &&
              !AI_GetSpellTargetImmunity(GlobalImmunityNecromancy) &&
              !AI_GetSpellTargetImmunity(GlobalImmunityNegativeEnergy))
            {
                // Negative Energy Ray. Level 1 (Mage) 2 (Cleric) 1d6(CasterLevel/2) to 5d6 negative damage.
                if(AI_ActionCastSpellRandom(SPELL_NEGATIVE_ENERGY_RAY, 30, GlobalSpellTarget, 11, FALSE)) return TRUE;
            }
            // Doom does some...stuff. The damage -2 is best. Will save negates.
            if(!GetHasSpellEffect(SPELL_DOOM, GlobalSpellTarget) &&
               !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 1))
            {
                // Doom. Level 1 (Mage) -2 Saves, Damage, to hit at a mind will save.
                if(AI_ActionCastSpellRandom(SPELL_DOOM, 30, GlobalSpellTarget, 11, FALSE)) return TRUE;
            }
        }
        if(bRangeShortValid)
        {
            // Damage with Ice Dagger is not bad - it is cirtinly comparable to MM! Saves though...
            if(!AI_SaveImmuneSpellTarget(SAVING_THROW_REFLEX, 1))
            {
                // Ice Dagger. Level 1 (Mage) Reflex-based, 1d4/Level (to 5d4) ice damage.
                if(AI_ActionCastSpellRandom(SPELL_ICE_DAGGER, 30, GlobalSpellTarget, 11, FALSE)) return TRUE;
            }
            // Scare - needs 5HD or under HD
            if(!AI_GetSpellTargetImmunity(GlobalImmunityFear) &&
               !AI_GetSpellTargetImmunity(GlobalImmunityNecromancy) &&
               !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 1))
            {
                // Scare. Level 1 (Mage) 1d4 round of fear, saving throw VS will, for 5HD or less creature
                if(AI_ActionCastSpellRandom(SPELL_SCARE, 20, GlobalSpellTarget, 11, FALSE)) return TRUE;
            }
            // Ray of Enfeeblement pities high strength enemies. d6 + 1-10 str. Loss
            if(GetAbilityScore(GlobalSpellTarget, ABILITY_STRENGTH) >= 14 &&
               !GetHasSpellEffect(SPELL_RAY_OF_ENFEEBLEMENT, GlobalSpellTarget) &&
               !AI_GetSpellTargetImmunity(GlobalImmunityNecromancy) &&
               !AI_SaveImmuneSpellTarget(SAVING_THROW_FORT, 1))
            {
                // Ray of Enfeeblement. Level 1 (Mage) d6 + (Caster level/2) strength damage to d6 + 10. Fort save.
                if(AI_ActionCastSpellRandom(SPELL_RAY_OF_ENFEEBLEMENT, 20, GlobalSpellTarget, 11, FALSE)) return TRUE;
            }
            // Charm Person charms them. Might as well... (Bit bad this spell)
            if(GetIsPlayableRacialType(GlobalSpellTarget) &&
               !AI_GetSpellTargetImmunity(GlobalImmunityDomination) &&
               !AI_GetSpellTargetImmunity(GlobalImmunityMind) &&
               !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 2))
            {
                // Charm Person. Level 1 (Mage/Bard) Charms one humanoid if they fail a mind will save.
                if(AI_ActionCastSpellRandom(SPELL_CHARM_PERSON, 10, GlobalSpellTarget, 11, FALSE)) return TRUE;
            }
        }
    }

    // Backup casting
    if(AI_ActionCastBackupRandomSpell()) return TRUE;

    // Light wounds - damage at a touch attack.
    if(GlobalSeenSpell && GlobalNormalSpellsNoEffectLevel < 3 && bRangeTouchValid)
    {
        // Cast Cure Critical Wounds (Which acts the same way for undead as
        // inflict critical does)
        if(GlobalSpellTargetRace == RACIAL_TYPE_UNDEAD)
        {
            // Cure Light Wounds. Level 1 (Cleric) Touch attack, hit means 1d8 + 1-5 positive damage.
            if(AI_ActionCastSpontaeousSpell(SPELL_CURE_MODERATE_WOUNDS, GlobalSpellTarget)) return TRUE;
        }
        if(!AI_GetSpellTargetImmunity(GlobalImmunityNecromancy) &&
           !AI_GetSpellTargetImmunity(GlobalImmunityNegativeEnergy))
        {
            // Inflict Light Wounds. Level 1 (Cleric) Touch attack, hit means 1d8 + 1-5 negative damage.
            if(AI_ActionCastSpontaeousSpell(SPELL_INFLICT_LIGHT_WOUNDS, GlobalSpellTarget)) return TRUE;
        }
    }

    // Lastly, cheat cast spells. We cast these if we run out of all others
    // - Cast ABOVE level 0 spells.
    if(GetAIConstant(AI_CHEAT_CAST_SPELL + "1") >= FALSE)
    {
        // It is normally 6 spells. It will default to the first if one
        // we pick is not valid.
        int nSpell = GetAIConstant(AI_CHEAT_CAST_SPELL + IntToString(d6()));
        if(nSpell <= 0)
        {
            nSpell = GetAIConstant(AI_CHEAT_CAST_SPELL + "1");
        }
        // 33: "[DCR:Casting] Cheat Spell. End of Spells. [Spell] " + IntToString(nSpell) + "[Target]" + GetName(GlobalSpellTarget)
        DebugActionSpeakByInt(33, GlobalSpellTarget, nSpell);
        ActionCastSpellAtObject(nSpell, GlobalSpellTarget, METAMAGIC_NONE, TRUE);
        return TRUE;
    }

/*::0000000000000000000000000000000000000000000000000000000000000000000000000000
    Level 0 Spells.
//::0000000000000000000000000000000000000000000000000000000000000000000000000000
    Thoughts - These are backup spells, even at level 1. To be honest, ray
    of frost at level 1-3 is a good spell, even 5+ it is alright, as it has
    no save. (Shame it isn't like Acid Splash, as in correct D&D damage).
    Daze is also useful in some situations. No AOE spells and the defensive
    spells are nothing to speak of, however.

    AOE:
  X [None]

    Single:
    [Ray of frost] 1d4 + 1 cold damage, at no save.
S   [Flare] Target gets -1 to attack rolls if they fail a fortitude save
    [Daze] If <= 5 Hit dice, target is dazed on a failed fortitude save.
S   [Acid Splash] 1d3 Acid damage, no save. Longer range then ray of frost.
S   [Electric Jolt] 1d3 Electrical damage, no save. Longer range then ray of frost.
S   [Inflict Minor Wounds] 1 Negative damage, on a touch attack. Heals undead.

    Defender:
    [Resistance] +1 to all saves for 2 turns
    [Virtue] +1 HP, 1 turn/caster level.

    Summon:
  X [None]

    Other:
  X [Cure Minor Wounds] - Heals 4 hit points (meant to be only 1)
    [Light] 20M of light around the target.
//::00000000000000000000000000000000000000000000000000000000000000000000000000*/

    // Jump out if we don't want to cast level 0 spells.
    if(nLowestSpellLevel > 0) return FALSE;

    // BAB check.
    if(!SRA && GlobalOurChosenClass != CLASS_TYPE_WIZARD &&
               GlobalOurChosenClass != CLASS_TYPE_SORCERER &&
               GlobalOurChosenClass != CLASS_TYPE_FEY)
    {
        // BAB check for level 0 spells.
        if(GlobalOurBaseAttackBonus >= GetAC(GlobalSpellTarget)) return FALSE;
        // HD check
        if(GlobalOurHitDice > 8) return FALSE;
    }

    if(bFirstRunThrough)
    {
        // Need no enemies in 4 meters.
        if(!GlobalEnemiesIn4Meters)
        {
            // Not sure of effectiveness...so acting as a cantrip.
            // Sanctuary. Level 1 (Cleric). Will save (low DC!) or cannot see target.
            if(AI_ActionCastSpell(SPELL_SANCTUARY, OBJECT_SELF, 11, FALSE)) return TRUE;
        }
        // Iron guts are very specifically VS poisoners - I'd see the use if I saw
        // spiders. I won't bother adding them checks, however, because frankly NPC's
        // won't use this much
        if(!GetHasSpellEffect(SPELL_IRONGUTS))
        {
            // Iron Guts. Level 1 (Mage) +4 Saves VS poison. (cast as level 0 spell...this is specilised!)
            if(AI_ActionCastSpell(SPELL_IRONGUTS, OBJECT_SELF, 11, FALSE)) return TRUE;
        }
    }

    // Note: Also, as these are always the worst, last things to use in combat, we
    //       don't care about ranges :-P
    // Note 2: We have the required amount of stat to 0. We check, On Spawn,
    //         if we can cast spells (IE right stats) and these are the worst we can cast.
    if(GlobalNormalSpellsNoEffectLevel < 1 && GlobalSeenSpell)
    {
        // Random cast one of the 5 hostile cantrip spells
        // Daze!
        if(bRangeLongValid &&
           GlobalSpellTargetHitDice <= 5 &&
          !AI_GetSpellTargetImmunity(GlobalImmunityMind) &&
          !AI_SaveImmuneSpellTarget(SAVING_THROW_WILL, 0))
        {
            // Daze. Level 0 (Mage/Bard) If <= 5 Hit dice, target is dazed on a failed fortitude save.
            if(AI_ActionCastSpellRandom(SPELL_DAZE, 50, GlobalSpellTarget, 10, FALSE)) return TRUE;
        }
        if(bRangeMediumValid)
        {
            // Minor damage. Moderate range. 60% chance of casting.
            if(AI_ActionCastSpellRandom(SPELL_RAY_OF_FROST, 50, GlobalSpellTarget, 10, FALSE)) return TRUE;
        }
        if(bRangeLongValid)
        {
            // Long range, for Acid Splash and Electric Jolt. Random cast one of them
            if(AI_ActionCastSpellRandom(SPELL_ELECTRIC_JOLT, 40, GlobalSpellTarget, 10, FALSE)) return TRUE;
            if(AI_ActionCastSpellRandom(SPELL_ACID_SPLASH, 40, GlobalSpellTarget, 10, FALSE)) return TRUE;
        }
        // Flare is OK - low 10% cast, but will backup cast at end.
        if(bRangeMediumValid && !GetHasSpellEffect(SPELL_FLARE, GlobalSpellTarget) &&
           !AI_SaveImmuneSpellTarget(SAVING_THROW_FORT, 0))
        {
            // Flare. Level 0 (Bard/Mage) Target gets -1 to attack rolls if they fail a fortitude save
            if(AI_ActionCastSpellRandom(SPELL_FLARE, 0, GlobalSpellTarget, 10, FALSE)) return TRUE;
        }

        // Backup casting
        if(AI_ActionCastBackupRandomSpell()) return TRUE;
    }
    // Need decent % HP and no enemies in 4 Meters to cast these
    if(bFirstRunThrough && GlobalOurPercentHP >= 60 && !GlobalEnemiesIn4Meters)
    {
        if(!GetHasSpellEffect(SPELL_VIRTUE))
        {
            // Virtue. Level 0 (Druid/Cleric/Paladin) +1 HP, 1 turn/caster level.
            if(AI_ActionCastSpell(SPELL_VIRTUE, OBJECT_SELF, 10, FALSE)) return TRUE;
        }
        if(!GetHasSpellEffect(SPELL_RESISTANCE))
        {
            // Resistance. Level 0 (Mage/Cleric/Bard/Druid) 1 (Paladin) +1 to all saves for 2 turns
            if(AI_ActionCastSpell(SPELL_RESISTANCE, OBJECT_SELF, 10, FALSE)) return TRUE;
        }
        // Light
        if(!GetHasSpellEffect(SPELL_LIGHT))
        {
            // Light. Level 0 (Mage/Cleric/Druid/Bard) 20M of light around the target.
            if(AI_ActionCastSpell(SPELL_LIGHT, OBJECT_SELF, 10)) return TRUE;
        }
    }
    // Minor wounds - damage at a touch attack.
    // HARDLY worth it, but use it anyway...if we pass the BAB check that is :-)
    if(GlobalSeenSpell && GlobalNormalSpellsNoEffectLevel < 1 && bRangeTouchValid &&
      !AI_GetSpellTargetImmunity(GlobalImmunityNecromancy) &&
      !AI_GetSpellTargetImmunity(GlobalImmunityNegativeEnergy))
    {
        // Inflict Minor Wounds. Level 0 (Cleric) Touch attack, hit means 1 negative damage.
        if(AI_ActionCastSpontaeousSpell(SPELL_INFLICT_MINOR_WOUNDS, GlobalSpellTarget)) return TRUE;
    }

    // Return false. No spell cast.
    return FALSE;
}


/*::///////////////////////////////////////////////
//:: Name ActionDragonBreath
//::///////////////////////////////////////////////
    Wrapper to use dragon breath. TRUE if:
    1. They don't have the spell's effects (unless iDamaging is TRUE)
    2. We have it!

    After it is used, nWingCounter is set, debug message, and re-set counter to 0.
//::///////////////////////////////////////////////
//:: Created By: Jasperre
//:://///////////////////////////////////////////*/

// Either the chosen class is a dragon, or the appearance type is a dragon type,
// we return TRUE.
int AI_GetIsDragon()
{
    // Basic check
    if(GlobalOurChosenClass == CLASS_TYPE_DRAGON)
    {
        return TRUE;
    }
    // Appearance type (includes if we polymorph into one!)
    switch(GetAppearanceType(OBJECT_SELF))
    {
        case APPEARANCE_TYPE_DRAGON_BLACK:
        case APPEARANCE_TYPE_DRAGON_BLUE:
        case APPEARANCE_TYPE_DRAGON_BRASS:
        case APPEARANCE_TYPE_DRAGON_BRONZE:
        case APPEARANCE_TYPE_DRAGON_COPPER:
        case APPEARANCE_TYPE_DRAGON_GOLD:
        case APPEARANCE_TYPE_DRAGON_GREEN:
        case APPEARANCE_TYPE_DRAGON_RED:
        case APPEARANCE_TYPE_DRAGON_SILVER:
        case APPEARANCE_TYPE_DRAGON_WHITE:
        // Sorta dragons
        case APPEARANCE_TYPE_FAERIE_DRAGON:
        case APPEARANCE_TYPE_PSEUDODRAGON:
        // Tiny ones!
        case APPEARANCE_TYPE_WYRMLING_BLACK:
        case APPEARANCE_TYPE_WYRMLING_BLUE:
        case APPEARANCE_TYPE_WYRMLING_BRASS:
        case APPEARANCE_TYPE_WYRMLING_BRONZE:
        case APPEARANCE_TYPE_WYRMLING_COPPER:
        case APPEARANCE_TYPE_WYRMLING_GOLD:
        case APPEARANCE_TYPE_WYRMLING_GREEN:
        case APPEARANCE_TYPE_WYRMLING_RED:
        case APPEARANCE_TYPE_WYRMLING_SILVER:
        case APPEARANCE_TYPE_WYRMLING_WHITE:
        // Hordes ones
        case APPEARANCE_TYPE_DRAGON_PRIS: // Dragon_Pris 425
        case APPEARANCE_TYPE_DRAGON_SHADOW: // Dragon_Shadow 418
        case APPEARANCE_TYPE_DRACOLICH: // Dracolich 405
            return TRUE;
        break;
    }
    return FALSE;
}

// Uses tBreath if they are not immune
// - TRUE if used.
int AI_ActionUseBreath(object oTarget, talent tBreath, int nSpellID)
{
    int iImmune = FALSE;// If TRUE, don't use it it
    // Go through them...
    switch(nSpellID)
    {
        case SPELLABILITY_DRAGON_BREATH_FEAR: iImmune = GetIsImmune(oTarget, IMMUNITY_TYPE_FEAR); break;
        case SPELLABILITY_DRAGON_BREATH_PARALYZE: iImmune = GetIsImmune(oTarget, IMMUNITY_TYPE_PARALYSIS); break;
        case SPELLABILITY_DRAGON_BREATH_SLEEP: iImmune = GetIsImmune(oTarget, IMMUNITY_TYPE_SLEEP); break;
        case SPELLABILITY_DRAGON_BREATH_SLOW: iImmune = GetIsImmune(oTarget, IMMUNITY_TYPE_SLOW); break;
        case SPELLABILITY_DRAGON_BREATH_WEAKEN: iImmune = GetIsImmune(oTarget, IMMUNITY_TYPE_ABILITY_DECREASE); break;
    }
    // Use it!
    if(!iImmune)
    {
        // 35: "[DCR:Dragon] Breath weapon & attacking [Breath ID] " + IntToString(nSpellID) + " [Target] " + GetName(oTarget)
        DebugActionSpeakByInt(35, oTarget, nSpellID);
        ActionUseTalentAtLocation(tBreath, GetLocation(oTarget));
        ActionAttack(oTarget);
        return TRUE;
    }
    return FALSE;
}
int AI_ActionDragonBreath(object oTarget, int nWingCounter)
{
    // Get a random breath...
    talent tBreath = GetCreatureTalentRandom(TALENT_CATEGORY_DRAGONS_BREATH);
    if(GetIsTalentValid(tBreath))
    {
        int nTypeRandom, nTypeBest;
        // Check if it affects them
        nTypeRandom = GetIdFromTalent(tBreath);
        if(!GetHasSpellEffect(nTypeRandom, oTarget))
        {
            if(AI_ActionUseBreath(oTarget, tBreath, nTypeRandom)) return TRUE;
        }
        else
        {
            // Try again...best this time
            tBreath = GetCreatureTalentBest(TALENT_CATEGORY_DRAGONS_BREATH, 20);
            if(GetIsTalentValid(tBreath))
            {
                nTypeBest = GetIdFromTalent(tBreath);
                if(nTypeBest != nTypeRandom && !GetHasSpellEffect(nTypeBest, oTarget))
                {
                    if(AI_ActionUseBreath(oTarget, tBreath, nTypeBest)) return TRUE;
                }
            }
        }
    }
    return FALSE;
}
// This tests breath attacks or the use of the Wing Buffet, randomised each round
// and not used constantly.
// * oTarget - target to breath on (ouch, bad breath!)
int AI_DragonBreathOrWing(object oTarget)
{
    int bBreath = GetIsTalentValid(GetCreatureTalentBest(TALENT_CATEGORY_DRAGONS_BREATH, MAXCR));
    // Breath attack, or wing buffet. Which one?!
    // Check if we can do either...and that we are huge - IE not persuado dragon!
    if(bBreath || GetCreatureSize(OBJECT_SELF) >= CREATURE_SIZE_HUGE)
    {
        // Adds one to all things, by default, every call. This will randomise when to use things.
        int nBreath = GetAIInteger(AI_DRAGONS_BREATH);
        int nWing = GetAIInteger(AI_WING_BUFFET);
        int nAboveXBreath = GetBoundriedAIInteger(AI_DRAGON_FREQUENCY_OF_BUFFET, 3);
        int nAboveXWing = GetBoundriedAIInteger(AI_DRAGON_FREQUENCY_OF_BREATH, 3);
        // There is a small chance of actuall reducing it for one after it, or
        // adding another!
        if(d20() == 1 && (nWing > FALSE || nBreath > FALSE))// 5% chance of x2 the number!
        {
            nWing *= 2;
            nBreath *= 2;
        }
        else if(d20() == 1)// 5% of reducing each by 1.
        {
            nWing--;
            nBreath--;
        }
        else // Else we add 1 as normal
        {
            // Add one...
            nWing++;
            nBreath++;
        }
        // Set normal values to locals again
        SetAIInteger(AI_WING_BUFFET, nWing);
        SetAIInteger(AI_DRAGONS_BREATH, nBreath);
        // Check 1. If breath is over 2 of wing, we may use it.
        if(!GetSpawnInCondition(AI_FLAG_COMBAT_NO_WING_BUFFET, AI_COMBAT_MASTER) &&
            nBreath >= nAboveXBreath && nBreath >= (nWing + 2) && bBreath)
        {
            // We don't attack, with breath, our own dragons (IE as 3E rules, and
            //  the factmost dragons do have that immunity to that damage in place)
            if(GetAppearanceType(oTarget) != GetAppearanceType(OBJECT_SELF))
            {
                if(AI_ActionDragonBreath(oTarget, nWing))
                {
                    SetAIInteger(AI_DRAGONS_BREATH, 0);
                    return TRUE;
                }
            }
        }
        // Else wing must be higher, or no breath!
        // So we use wing buffet, re-set that, then try breath to end...
        if(nWing >= nAboveXWing &&
           GetCreatureSize(OBJECT_SELF) >= CREATURE_SIZE_HUGE &&
           GetCreatureSize(oTarget) < CREATURE_SIZE_HUGE)
        {
            // 36: "[DCR:Dragon] Wing Buffet [Target] " + GetName(oTarget)
            DebugActionSpeakByInt(36, oTarget);
            // Reset wing buffet counter
            SetAIInteger(AI_WING_BUFFET, 0);
            SetAIInteger(AI_DRAGONS_BREATH, nBreath);
            // - Not action do command, just Execute Script
            // no dragon associates! - pok
            //ExecuteScript(FILE_DRAGON_WING_BUFFET, OBJECT_SELF);
            return TRUE;
        }
        // Breath final...
        if(bBreath && nBreath >= nAboveXBreath)
        {
            // Breaths.
            if(AI_ActionDragonBreath(oTarget, nWing))
            {
                SetAIInteger(AI_DRAGONS_BREATH, 0);
                return TRUE;
            }
        }
    }//End any check
    return FALSE;
}
/*::///////////////////////////////////////////////
//:: Name TalentDragonCombat
//::///////////////////////////////////////////////
    Main call for dragons. This will cast major spells,
    use feats, wing buffet and breath weapons.
//::///////////////////////////////////////////////
//:: Created By: Bioware. Heavily Modified: Jasperre
//::////////////////////////////////////////////*/
int AI_AttemptDragonCombat()
{
    // We will attempt all spells possible with SRA on
    if(SRA)
    {
        if(AI_AttemptAllSpells()) return TRUE;
    }

    // Dragons can be tiny winey, and so we might attempt more spells in 1.4.

    // Now, we use DRAGONS BREATH! MUHAHAHAHAH!
    // OR wing buffet! Yeehaw!
    // - This is done on a breath by breath basis, with GetAppearance checking!
    // - Basically, these are as powerful (if not more so) then level 9 spells
    if(AI_DragonBreathOrWing(GlobalMeleeTarget)) return TRUE;

    // Chance each round to use best spells possible.
    // We, always,  love level 9 spells! just great, especially if the dragon has them!
    if(AI_AttemptAllSpells(9)) return TRUE;

    // We may attack our GlobalMeleeTarget if they are very weak in the AC
    // department!
    // - We will always hit
    // - They have no DR protections
    // - They have under 50 current hit points
    // - They are in HTH combat range.
    if(GlobalOurBaseAttackBonus - 5 >= GlobalMeleeTargetAC &&
      !GetHasSpellEffect(AI_SPELL_EPIC_WARDING, GlobalMeleeTarget) &&
      !GetHasSpellEffect(SPELL_STONESKIN, GlobalMeleeTarget) &&
      !GetHasSpellEffect(SPELL_GREATER_STONESKIN, GlobalMeleeTarget) &&
      !GetHasSpellEffect(SPELL_PREMONITION, GlobalMeleeTarget) &&
      !GetHasSpellEffect(SPELL_SHADES_STONESKIN, GlobalMeleeTarget) &&
       GetCurrentHitPoints(GlobalMeleeTarget) < 50 && GlobalRangeToMeleeTarget < 4.0)
    {
         // We then attack with feats, or whatever :-)
        // - This includes flying
        AI_AttemptMeleeAttackWrapper();
        return TRUE;
    }

    // We will, if a low level dragon (awwwww! cute!) will cast more spells
    // then normal. We have already used our breath weapon, but lower level
    // dragons have more spells (or may be half-dragons).
    if(GlobalOurHitDice <= 8 || (GlobalOurHitDice <= 14 && d100() <= 40))
    {
        // Attempt all spells.
        // * Still uses nBABCheckHighestLevel, to not cast the lowest if we have
        //   a very high BAB.
        if(AI_AttemptAllSpells()) return TRUE;
    }
    else
    {
        // We will use more spells if there are more enemies - as AOE spells will
        // be *maybe* better to use.
        int nSpellLowestMinus;
        if(GlobalMeleeAttackers >= 4 || GlobalTotalSeenHeardEnemies >= 6)
        {
            // -6
            nSpellLowestMinus = 6;
        }
        else
        {
            // -2d4
            nSpellLowestMinus = d4(2);
        }
        // We randomly choose what to use...
        if(AI_AttemptAllSpells(9 - nSpellLowestMinus, 0 + Random(6)))
        {
            // We also ActionAttack the enemy, as to move closer :-)
            ActionAttack(GlobalMeleeTarget);
            return TRUE;
        }
    }
    // We then attack with feats, or whatever :-)
    // - This includes flying
    return AI_AttemptMeleeAttackWrapper();
}
// Beholder teleport attempt. Flees from combat.
int AI_ActionBeholderTeleport()
{
    // By default, we use Bioware's Beholder escape points, but then we check
    // for allies to flee too.
    // 1.4 adds this. Only FLEES however! It norally is never quicker to go
    // nearer...
    if(GetLocalInt(OBJECT_SELF,"X2_BEHOLDER_AI_NOJUMP"))
    {
        return TRUE;
    }

    // Get nearest exit point to us
    object oExit = GetNearestObjectByTag("X2_WP_BEHOLDER_TUNNEL");

    if(GetIsObjectValid(oExit))
    {
        float fDist = GetDistanceBetween(oExit, GlobalMeleeTarget);
        int bJump;

        if((fDist >= 10.0f) && (fDist <= 40.0f))
        {
           bJump = TRUE;
        }

        if(!bJump)
        {
            oExit = GetNearestObjectByTag("X2_WP_BEHOLDER_TUNNEL", OBJECT_SELF, 2);
        }
        if(GetIsObjectValid(oExit))
        {
            fDist = GetDistanceBetween(oExit, GlobalMeleeTarget);

            if((fDist >= 8.0f) && (fDist <= 50.0f))
            {
                bJump = TRUE;
            }
        }

        if(bJump)
        {
            int nAni = GetLocalInt(oExit, "X2_L_BEH_USE_ANI");
            if (nAni == 0)
            {
                nAni = 1;// Fly "up".
            }
            effect eAppear = EffectDisappearAppear(GetLocation(oExit), nAni) ;
            eAppear = SupernaturalEffect(eAppear);
            object oSelf = OBJECT_SELF;
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eAppear, oSelf, 4.0f);
            // make the beholder enter combat again
            DelayCommand(4.1, ActionCastSpellAtObject(AI_SPELLABILITY_BEHOLDER_MAGIC_CONE, GlobalSpellTarget, METAMAGIC_ANY, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE));
            return TRUE;
        }
    }
    // End Bioware

    // Go from futhest to nearest seen allies
    int nCnt = GetLocalInt(OBJECT_SELF, MAXINT_ + ARRAY_ALLIES_RANGE_SEEN);
    if(nCnt <= FALSE) return FALSE;
    int bBreak = FALSE;
    object oEnemy = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_HEARD, CREATURE_TYPE_IS_ALIVE, TRUE);
    if(!GetIsObjectValid(oEnemy) || GetDistanceToObject(oEnemy) > 5.0) return FALSE;
    // Loop futhest to nearest
    object oAlly = GetLocalObject(OBJECT_SELF, ARRAY_ALLIES_RANGE_SEEN + IntToString(nCnt));
    while(GetIsObjectValid(oAlly) && bBreak != TRUE)
    {
        // Check nearest enemy to the ally.
        oEnemy = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, oAlly, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_HEARD, CREATURE_TYPE_IS_ALIVE, TRUE);
        if(GetDistanceToObject(oEnemy) > 5.0)
        {
            bBreak = TRUE;
        }
        else
        {
            // Next futhest.
            nCnt--;
            oAlly = GetLocalObject(OBJECT_SELF, ARRAY_ALLIES_RANGE_SEEN + IntToString(nCnt));
        }
    }
    // If true, we run to the ally
    if(bBreak)
    {
        // 37: "[DCR] Beholder Teleport"
        DebugActionSpeakByInt(37);
        effect eBeholder = EffectDisappearAppear(GetLocation(oAlly));
        float fTime = 3.0 + (GetDistanceToObject(oAlly)/10.0);
        // Apply effect
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eBeholder, OBJECT_SELF, fTime);
        // Determine Combat Round
        DelayCommand(fTime + 1.0, DetermineCombatRound(GlobalMeleeTarget));
    }
    return FALSE;
}
// Beholders have special rays for eyes. This is used if the setting is set
// on spawn for beholders, or if the appearance is a beholder.
int AI_AttemptBeholderCombat()
{
    // We will randomly teleport away if low HP, then heal
    if(GlobalOurPercentHP < GetBoundriedAIInteger(AI_HEALING_US_PERCENT, 50, 100, 1))
    {
        // Randomly teleport directly to an ally with no one near to them.
        if(AI_ActionBeholderTeleport())
        {
            return TRUE;
        }
        // Else attempt to heal because we are far enough away.
        else if(AI_AttemptHealingSelf())
        {
            return TRUE;
        }
    }

    // We will attempt high-level spells first.
    // - This will also make them use protections of course
    // - Only level 9 and 8 spells.
    if(AI_AttemptAllSpells(8)) return TRUE;

    // We attempt to fire beholder rays, or do antimagic cone.
    // 736   Beholder_Special_Spell_AI - Handles Beholder rays
    // 727   Beholder_Anti_Magic_Cone  - Dispels all Magical effects, and...
    /*  Beholder anti magic cone
        30m cone,
        100% spell failure to all targets,
        100% spellresistance to all targets
        9 seconds duration
        No save  */

    // Cast the antimagic cone randomly, if the target is nearish.
    if(d100() <= 60 && GlobalSpellTargetRange <= 15.0)
    {
        // 38: "[DCR] Beholder Rays"
        DebugActionSpeakByInt(38);
        ActionCastSpellAtLocation(AI_SPELLABILITY_BEHOLDER_MAGIC_CONE, GetLocation(GlobalSpellTarget), METAMAGIC_ANY, TRUE, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
        return TRUE;
    }
    // 80% chance of rays if at range (must be seen!)
    else if(d100() <= 80 && GlobalSeenSpell)
    {
        // 38: "[DCR] Beholder Rays"
        DebugActionSpeakByInt(38);
        ActionCastSpellAtObject(AI_SPELLABILITY_BEHOLDER_ALLRAYS, GlobalSpellTarget, METAMAGIC_ANY, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
        return TRUE;
    }
    // Then magic or bust - no BAB checks
    else if(AI_AttemptAllSpells(FALSE, FALSE))
    {
        return TRUE;
    }
    // Else there is a 20% chance of melee attack if enemy is at low HP
    else if(GetCurrentHitPoints(GlobalMeleeTarget) <= 30 &&
            GlobalMeleeTargetAC <= 25 &&
            GlobalRangeToMeleeTarget < 5.0 && d100() <= 40)
    {
        if(AI_AttemptMeleeAttackWrapper())
        {
            return TRUE;
        }
        else
        {
            // 38: "[DCR] Beholder Rays"
            DebugActionSpeakByInt(38);
            ActionCastSpellAtObject(AI_SPELLABILITY_BEHOLDER_ALLRAYS, GlobalSpellTarget, METAMAGIC_ANY, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
            return TRUE;
        }
    }
    // Then rays finally, as a default thing.
    else
    {
        // 38: "[DCR] Beholder Rays"
        DebugActionSpeakByInt(38);
        ActionCastSpellAtObject(AI_SPELLABILITY_BEHOLDER_ALLRAYS, GlobalSpellTarget, METAMAGIC_ANY, TRUE, 0, PROJECTILE_PATH_TYPE_DEFAULT, TRUE);
        return TRUE;
    }
    // Should never return FALSE.
    return FALSE;
}
// Taken from x2_ai_mflayer.
// Bioware's implimenation of the Mind Suck.
void MindFlayerSuck(object oTarget)
{
    // Move closer!
    ActionMoveToObject(oTarget, FALSE, 1.0);
    ActionDoCommand(SetFacingPoint(GetPosition(oTarget)));
    ActionWait(0.5);
    // normal brain suck
    ActionCastSpellAtObject(AI_SPELLABILITY_SUCKBRAIN, oTarget, METAMAGIC_ANY, TRUE);
}
// Illithid Use special attacks.
// This is set on spawn, or by the user on spawn.
int AI_AttemptMindflayerCombat()
{
    // We may attempt a brain suck as Bioware's mind flayer would.

    // - Mind attack if the melee enemy is NOT polymorphed,
    //   but is stunned/paralyzed or Dazed + % chance

    // Check polymorph
    if(AI_GetAIHaveEffect(GlobalEffectPolymorph, GlobalMeleeTarget)) return FALSE;

    // Stunned, held, sleep, etc. uncommandable, it is 100%
    if(AI_GetAIHaveEffect(GlobalEffectUncommandable, GlobalMeleeTarget) ||
    // 30% with daze only.
      (AI_GetAIHaveEffect(GlobalEffectUncommandable, GlobalMeleeTarget) && d100() <= 30))
    {
        // Bioware function.
        MindFlayerSuck(GlobalMeleeTarget);
        return TRUE;
    }
    // 70% chance of mind blast
    else if(GetDistanceToObject(GlobalMeleeTarget) < 5.0 && d100() <= 70)
    {
        // Special mind blast
        ActionCastSpellAtObject(SPELLABILITY_MINDBLAST, OBJECT_SELF, METAMAGIC_ANY, TRUE);
        return TRUE;
    }
    // 40% chance of pyionic charm monster
    else if(GetDistanceToObject(GlobalMeleeTarget) < 8.0 && d100() <= 40 &&
           !GetHasSpellEffect(SPELLABILITY_CHARMMONSTER, GlobalMeleeTarget) &&
            GetHasSpell(SPELLABILITY_CHARMMONSTER))
    {
        // Special mind blast
        ActionCastSpellAtObject(SPELLABILITY_CHARMMONSTER, GlobalMeleeTarget, METAMAGIC_ANY, TRUE);
        return TRUE;
    }
    // False means no special mind flayer attacks.
    return FALSE;
}


// Sets a value, 1-5, for what we can Dispel. Also sets
// a 1-5 value for breach spells.
// The values are NOT, I repeat NOT what the spell level are. Generally, they
// class spell-stopping spells as a higher prioritory to Dispel!
// * 5 - Dispeled before hostile spells are cast at target
// * 4 - Dispeled just before level 7 or so spells.
// * 3 - Dispeled just before level 4 or so spells
// * 2 - Dispeled just before level 2 or so spells.
// * 1 - Lowest prioritory - Dispeled at the end.
// There are NO cantrips included (level 0 spells).
void AI_SetDispelableEnchantments()
{
    // We CANNOT dispel any of the epic spells, so we DO NOT check for them
    // here!!!

    // Summons dispelling
    object oMaster = GetMaster(GlobalDispelTarget);
    if(GetIsObjectValid(oMaster))
    {
        // First, is it the black blade we can dispel? (If cast aganst the master)
        if(GetTag(GlobalDispelTarget) == "x2_s_bblade")
        {
            // Check if seen
            if(GetObjectSeen(oMaster) || GetObjectHeard(oMaster))
            {
                // Dispel the caster
                GlobalDispelTarget = oMaster;
                GlobalDispelTargetHighestDispel = 5;
                return;
            }
            else
            {
                // Else, not seen or heard, so we try and dispel just the sword
                // * Its an evil sword and must die!
                GlobalDispelTargetHighestDispel = 5;
                return;
            }
        }
        // Check if we can dispel the master of the summon
        else if(GetObjectSeen(oMaster) || GetObjectHeard(oMaster))
        {
            // Dispel the caster
            GlobalDispelTarget = oMaster;
            GlobalDispelTargetHighestDispel = 5;
            return;
        }
        // Else - normal dispel behavour. I don't think targeting dispels at
        // a summon will kill them!
    }

    // We check the spell it has been cast from :-)
    int nSpellID, nSpellCounter;
    // We check all of thier effects.
    effect eCheck = GetFirstEffect(GlobalDispelTarget);
    // Loop around valid effects.
    while(GetIsEffectValid(eCheck) &&
          // Break loop if we are already at 5
          GlobalDispelTargetHighestDispel < 5 &&
          GlobalDispelTargetHighestBreach < 5)
    {
        nSpellID = GetEffectSpellId(eCheck);
        // Make sure that it is equal, or over, 0 (IE acid fog)
        // - Must be magical, else DispelMagic will not work.
        if(nSpellID >= 0 && GetEffectSubType(eCheck) == SUBTYPE_MAGICAL)
        {
            // We then switch the spells (I tihnk it is easier to debug :-) )
            // and set what level of benifical enchantment it is :-)
            switch(nSpellID)
            {
                // * 5 - Dispeled before hostile spells are cast at target
                // Level 5 Breach Spells - should be Dispeled before attacking.
                case SPELL_GREATER_SPELL_MANTLE: // Stops all offensive spells!
                case SPELL_SPELL_MANTLE:         // Stops all offensive spells!
                case SPELL_LESSER_SPELL_MANTLE:  // Stops all offensive spells!
                case SPELL_SHADOW_SHIELD:  // Immunity to negative energy, death spells + Necromancy! - so Dispel
                case SPELL_ENERGY_BUFFER:  // 40/- Elemental reistance can stop some level 9 spells! :-)
                {
                    if(GlobalDispelTargetHighestDispel < 5) GlobalDispelTargetHighestDispel = 5;
                    if(GlobalDispelTargetHighestBreach < 5) GlobalDispelTargetHighestBreach = 5;
                    nSpellCounter++;
                }
                break;
                // Level 5 other spells.
                case SPELL_UNDEATHS_ETERNAL_FOE:  // Stops quite a bit, and is a level 9 cleric spell.
                case SPELL_HOLY_AURA:  // 25 spell resistance! (and mind immunity)
                case SPELL_UNHOLY_AURA:// 25 spell resistance! (and mind immunity)
                case SPELL_SPELL_RESISTANCE: // 11 + Caster level in spell resistance.
                case SPELL_DEATH_WARD: // Immunity to death spells - so Dispel
                case SPELL_NEGATIVE_ENERGY_PROTECTION:// Immunity to negative energy, - so Dispel
                case SPELL_TRUE_SEEING:// Can see anything - powerful against invis!
                case SPELL_SHAPECHANGE:// VERY Powerful polymorphing.
                case SPELL_PROTECTION_FROM_SPELLS:// +8 on all saves
                {
                    if(GlobalDispelTargetHighestDispel < 5) GlobalDispelTargetHighestDispel = 5;
                    if(GlobalDispelTargetHighestBreach < 5) GlobalDispelTargetHighestBreach = 5;
                    nSpellCounter++;
                }
                break;
                // * 4 - Dispeled just before level 7 or so spells.
                case SPELL_PREMONITION: // Damage reduction 30/+5. Do this for fighters.
                {
                    if(GlobalDispelTargetHighestDispel < 4) GlobalDispelTargetHighestDispel = 4;
                    if(GlobalDispelTargetHighestBreach < 4) GlobalDispelTargetHighestBreach = 4;
                    nSpellCounter++;
                }
                break;
                // Most other decent protection spells, especially ones which will
                // disrupt all castings.
                case SPELL_CLARITY:     // Immunity: mind spells.
                case SPELL_MASS_HASTE:  // Why should they be hasted! >:-D
                case SPELL_HASTE:       // Why should they be hasted! >:-D
                case SPELL_PROTECTION_FROM_ELEMENTS: // 30/- Protection
                case SPELL_REGENERATE:  // +5 regen is quite powerful!
                case SPELL_TENSERS_TRANSFORMATION://ANother powerful +AB ETC spell.
                // High level summons
                case SPELL_ELEMENTAL_SWARM:   // Swarm
                case SPELL_SUMMON_CREATURE_IX:// 9
                case SPELL_BLACK_BLADE_OF_DISASTER: // Black blade
                case SPELL_SUMMON_CREATURE_VIII:// 8
                {
                    if(GlobalDispelTargetHighestDispel < 4) GlobalDispelTargetHighestDispel = 4;
                    nSpellCounter++;
                }
                break;
                // * 3 - Dispeled just before level 4 or so spells
                case SPELL_GLOBE_OF_INVULNERABILITY: // Stops level 1-4 spells.
                case SPELL_GREATER_STONESKIN:  // 20/+5 DR. Help fighters half-way though spells.
                case SPELL_RESIST_ELEMENTS:    // 20/- Protection
                {
                    if(GlobalDispelTargetHighestDispel < 3) GlobalDispelTargetHighestDispel = 3;
                    if(GlobalDispelTargetHighestBreach < 3) GlobalDispelTargetHighestBreach = 3;
                    nSpellCounter++;
                }
                break;
                // Increases in abilites, and some which stop level 4, or nearby, spells.
                case SPELL_AURA_OF_VITALITY: // "All allies within the AOE gain +4 Str, Con, Dex"!!
                case SPELL_FREEDOM_OF_MOVEMENT:// Freedom - web ETC may be affected (and slow!)
                case SPELL_MAGIC_CIRCLE_AGAINST_EVIL:// +saves, AC, and mind immunity
                case SPELL_MAGIC_CIRCLE_AGAINST_GOOD:// +saves, AC, and mind immunity
                case SPELL_SEE_INVISIBILITY: // See through invisiblity
                case SPELL_MESTILS_ACID_SHEATH: // 2/level + 1d6 acid damage - damage shield.
                // Quite High level summons
                case SPELL_SUMMON_CREATURE_VII: // 7
                case SPELL_SUMMON_CREATURE_VI:  // 6
                case SPELL_SUMMON_CREATURE_V:   // 5
                {
                    if(GlobalDispelTargetHighestDispel < 3) GlobalDispelTargetHighestDispel = 3;
                    nSpellCounter++;
                }
                break;
                // * 2 - Dispeled just before level 2 or so spells.
                case SPELL_MINOR_GLOBE_OF_INVULNERABILITY:    // Immunity 1-2 level spells.
                case SPELL_ETHEREAL_VISAGE: // Immunity 1-2 level spells (and some DR)
                case SPELL_ENDURE_ELEMENTS: // 10/- Reduction.     SPELL_GHOSTLY_VISAGE
                case SPELL_GHOSTLY_VISAGE:  // 0-1 level spell immunity, and 10% consealment
                case SPELL_STONESKIN:       // 10/+5 DR. Help fighters just before low-end spells.
                case SPELL_SHADES_STONESKIN:// Shades version of above.
                {
                    if(GlobalDispelTargetHighestDispel < 2) GlobalDispelTargetHighestDispel = 2;
                    if(GlobalDispelTargetHighestBreach < 2) GlobalDispelTargetHighestBreach = 2;
                    nSpellCounter++;
                }
                break;
                // Things that stop level 2 or 1 spells, and low-end ones which
                // may hinder lower-end castings, and very powreful benifical
                // enhancements.
                case SPELL_DISPLACEMENT:    // +50% consealment. Helps fighters.
                case SPELL_EXPEDITIOUS_RETREAT:// +150% speed. Dispel here.
                case SPELL_GREATER_SHADOW_CONJURATION_MINOR_GLOBE: // Immunity 1-2 level spells.
                case SPELL_PROTECTION_FROM_EVIL:// Mind immunity mostly.
                case SPELL_PROTECTION_FROM_GOOD:// Mind immunity mostly.
                case SPELL_SHIELD:      // +AC + Immunity magic missile
                // Enhancements
                case SPELL_DIVINE_POWER:// +Stat, HP, base attack bonus.
                case SPELL_DIVINE_FAVOR:// +1-5 Attack/damage
                case SPELL_ELEMENTAL_SHIELD: // +Damage Sheild (gives HTH attackers damage)
                // Moderate level summons
                case SPELL_SUMMON_CREATURE_IV:  // 4
                case SPELL_SUMMON_CREATURE_III: // 3
                {
                    if(GlobalDispelTargetHighestDispel < 2) GlobalDispelTargetHighestDispel = 2;
                    nSpellCounter++;
                }
                break;
                // * 1 - Lowest prioritory - Dispeled at the end.
                // The rest - mostly low-end AC increases, bless and so forth.
                // Before we attack, we Dispel them (and therefore help allies!)
                case SPELL_MAGE_ARMOR:  // +AC
                {
                    if(GlobalDispelTargetHighestDispel < 1) GlobalDispelTargetHighestDispel = 1;
                    if(GlobalDispelTargetHighestBreach < 1) GlobalDispelTargetHighestBreach = 1;
                    nSpellCounter++;
                }
                // Non-breach
                case SPELL_AID:         // +Some HP and attack
                case SPELL_AMPLIFY:     // +20 listen
                case SPELL_BARKSKIN:    // +AC
                case SPELL_BLESS:       // +Attack, damage (AOE)
                case SPELL_BLOOD_FRENZY:// +Attack, damage (Rage-like)
                case SPELL_BULLS_STRENGTH:// +Stat
                case SPELL_CATS_GRACE:  // +Stat
                case SPELL_EAGLE_SPLEDOR:// +Stat
                case SPELL_ENTROPIC_SHIELD:  // +20% consealment VS ranged.
                case SPELL_OWLS_WISDOM:  // +Stat
                case AI_SPELL_OWLS_INSIGHT: // +Stat  (Owls insight)
                case SPELL_SANCTUARY:   // Invisiblity-like.
                case SPELL_SHIELD_OF_FAITH:// +2-5 AC
                case SPELL_WAR_CRY:     // +Attack, damage
                case SPELL_WOUNDING_WHISPERS:// +Damage Sheild (gives HTH attackers damage)
                case SPELL_STONE_BONES: // +3 AC to undead.
                case SPELL_BATTLETIDE:  // +2 Saves, attack, damage, also a negative AOE.
                // Low level summons
                case SPELL_SUMMON_CREATURE_II:  // 2
                case SPELL_SUMMON_CREATURE_I:   // 1
                {
                    if(GlobalDispelTargetHighestDispel < 1) GlobalDispelTargetHighestDispel = 1;
                    nSpellCounter++;
                }
                break;
            }
        }
        eCheck = GetNextEffect(GlobalDispelTarget);
    }
    // If we cannot see GlobalDispelTarget, set GlobalDispelTargetHighestBreach to
    // 0 anyway. Cannot cast Breach against something we cannot see!
    if(!GetObjectSeen(GlobalDispelTarget)) GlobalDispelTargetHighestBreach = 0;

    // We might dispel anything.
    if(!GetSpawnInCondition(AI_FLAG_COMBAT_DISPEL_IN_ORDER, AI_COMBAT_MASTER))
    {
        if(GlobalDispelTargetHighestBreach) GlobalDispelTargetHighestBreach = 5;
        if(GlobalDispelTargetHighestDispel) GlobalDispelTargetHighestDispel = 5;
    }
    // Do we have a ton of spells? We add 1 to the prioritory for every 10 spells
    // applied.
    if(nSpellCounter > 5) GlobalDispelTargetHighestDispel += nSpellCounter / 10;
    if(GlobalDispelTargetHighestDispel > 5) GlobalDispelTargetHighestDispel = 5;
}

// Just sorts out sOriginalArrayName to sNewArrayName based on range only.
void AI_TargetingArrayDistanceStore(string sOriginalArrayName, string sNewArrayName)
{
    int bFilterPC;
    if(sOriginalArrayName == ARRAY_TEMP_ENEMIES &&
       GetSpawnInCondition(AI_FLAG_TARGETING_FILTER_FOR_PC_TARGETS, AI_TARGETING_FLEE_MASTER))
    {
        // Check for the nearest seen, enemy PC.
        bFilterPC = GetIsObjectValid(GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, OBJECT_SELF, 1, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN));
    }
    // Make sure sNewArrayName is cleared
    DeleteLocalInt(OBJECT_SELF, MAXINT_ + sNewArrayName);
    int nCnt = 1;
    float fSetUpRange;
    // Now, we check for things like if to do melee or ranged, or whatever :-)
    object oTarget = GetLocalObject(OBJECT_SELF, sOriginalArrayName + IntToString(nCnt));
    while(GetIsObjectValid(oTarget))
    {
        if(!bFilterPC || GetIsPC(oTarget))
        {
            fSetUpRange = GetDistanceToObject(oTarget);
            // We set it to sNewArrayName - highest to lowest.
            SetArrayFloatValue(sNewArrayName, oTarget, fSetUpRange);
        }
        // Next one
        nCnt++;
        oTarget = GetLocalObject(OBJECT_SELF, sOriginalArrayName + IntToString(nCnt));
    }
    // If we have no valid targets, and PC's are on, we try again.
    if(bFilterPC && !GetIsObjectValid(GetLocalObject(OBJECT_SELF, sNewArrayName + "1")))
    {
        // Re-run again.
        nCnt = 1;
        oTarget = GetLocalObject(OBJECT_SELF, sOriginalArrayName + IntToString(nCnt));
        while(GetIsObjectValid(oTarget))
        {
            fSetUpRange = GetDistanceToObject(oTarget);
            // We set it to sNewArrayName - highest to lowest.
            SetArrayFloatValue(sNewArrayName, oTarget, fSetUpRange);
            // Next one
            nCnt++;
            oTarget = GetLocalObject(OBJECT_SELF, sOriginalArrayName + IntToString(nCnt));
        }
    }
    // delete old ones.
    int iCheck;
    for(iCheck = 1; iCheck <= nCnt; iCheck++)
    {
        // Delete the old one
        DeleteLocalObject(OBJECT_SELF, sOriginalArrayName + IntToString(nCnt));
    }
}

// Just sorts out sOriginalArrayName to sNewArrayName based on nType.
// nType 1 = AC, nType 2 = Total Saves, nType 3 = Phisical Protections,
// nType 4 = BAB, nType 5 = Hit Dice, nType 6 = Percent HP, nType 7 = Current HP,
// nType 8 = Maximum HP. 9 = Attacking us or not.
void AI_TargetingArrayIntegerStore(int nType, string sOriginalArrayName)
{
    int nCnt = 1;
    int nValue;
    // Now, we check for things like if to do melee or ranged, or whatever :-)
    object oTarget = GetLocalObject(OBJECT_SELF, sOriginalArrayName + IntToString(nCnt));
    while(GetIsObjectValid(oTarget))
    {
        if(nType == 1)
        {
            // AC
            nValue = GetAC(oTarget);
        }
        else if(nType == 2)
        {
            // Total saving throws.
            nValue = GetFortitudeSavingThrow(oTarget) +
                     GetReflexSavingThrow(oTarget) +
                     GetReflexSavingThrow(oTarget);
        }
        else if(nType == 3)
        {
            // Damage reduction
            // 30/+5
            if(GetHasSpellEffect(SPELL_PREMONITION, oTarget))
            {
                nValue = 30;
            }
            // 20/+5, 20/+3
            else if(GetHasSpellEffect(SPELL_GREATER_STONESKIN, oTarget) ||
                    GetHasSpellEffect(SPELL_ETHEREAL_VISAGE, oTarget))
            {
                nValue = 20;
            }
            // 10/+5 10/+3
            else if(GetHasSpellEffect(SPELL_SHADOW_SHIELD, oTarget) ||
                    GetHasSpellEffect(SPELL_STONESKIN, oTarget) ||
                    GetHasSpellEffect(SPELL_SHADES_STONESKIN, oTarget))
            {
                nValue = 10;
            }
            // 5/+1
            else if(GetHasSpellEffect(SPELL_GHOSTLY_VISAGE, oTarget))
            {
                nValue = 5;
            }
            else
            {
                nValue = 0;
            }
        }
        else if(nType == 4)
        {
            // BAB
            nValue = GetBaseAttackBonus(oTarget);
        }
        else if(nType == 5)
        {
            // Hit dice
            nValue = GetHitDice(oTarget);
        }
        else if(nType == 6)
        {
            // %HP
            nValue = AI_GetPercentOf(GetCurrentHitPoints(oTarget), GetMaxHitPoints(oTarget));
        }
        else if(nType == 7)
        {
            // Current
            nValue = GetCurrentHitPoints(oTarget);
        }
        else if(nType == 8)
        {
            // Max
            nValue = GetMaxHitPoints(oTarget);
        }
        else if(nType == 9)
        {
            // Sneak attack.
            nValue = FALSE;
            if(GetAttackTarget(oTarget) != OBJECT_SELF &&
              !GetIsImmune(oTarget, IMMUNITY_TYPE_SNEAK_ATTACK))
            {
                nValue = TRUE;
            }
        }
        // We set it to the new array name - highest to lowest.
        SetArrayIntegerValue(ARRAY_TEMP_ARRAY, oTarget, nValue);
        // Delete the old one
        if(nType != 9)// Sneak attack, if not a valid sneak target, we target normally so don't delete
        {
            DeleteLocalObject(OBJECT_SELF, sOriginalArrayName + IntToString(nCnt));
        }
        // Next target
        nCnt++;
        oTarget = GetLocalObject(OBJECT_SELF, sOriginalArrayName + IntToString(nCnt));
    }
}
// Deletes all FLoats, Integers and Objects set to sArray for valid
// objects got by GetLocalObject to sArray.
void AI_TargetingArrayDelete(string sArray)
{
    int nCnt = 1;
    string sCnt = IntToString(nCnt);
    object oLocal = GetLocalObject(OBJECT_SELF, sArray + sCnt);
    while(GetIsObjectValid(oLocal))
    {
        // Delete all
        DeleteLocalFloat(OBJECT_SELF, sArray + sCnt);
        DeleteLocalInt(OBJECT_SELF, sArray + sCnt);
        DeleteLocalObject(OBJECT_SELF, sArray + sCnt);
        // Get next object
        nCnt++;
        sCnt = IntToString(nCnt);
        oLocal = GetLocalObject(OBJECT_SELF, sArray + sCnt);
    }
    DeleteLocalInt(OBJECT_SELF, MAXINT_ + sArray);
}

// This sets ARRAY_TEMP_ARRAY of integer values to sNewArrayName.
// - nTypeOfTarget, used TARGET_LOWER, TARGET_HIGHER.
// - We work until nMinimum is filled, or we get to nMinimum and we get to
//   a target with value > iInputMinimum. (20 - 25 > X?)
int AI_TargetingArrayLimitTargets(string sNewArrayName, int nTypeOfTarget, int iInputMinLimit, int nMinLoop, int nMaxLoop)
{
    int iAddEachTime, nValue, nCnt, nCnt2, nCnt3, bBreak, nLowestHighestValue;
    string sCnt;
    object oSetUpTarget;
    // Is it lowest to highest, or highest to lowest?
    // - 1. Lowest to highest
    if(nTypeOfTarget == TARGET_LOWER)
    {
        iAddEachTime = 1;
        nCnt = 1;
    }
    else // if(nTypeOfTarget == TARGET_HIGHER)
    {
        // Change to start at top value, and work down.
        iAddEachTime = -1;
        nCnt = GetLocalInt(OBJECT_SELF, MAXINT_ + ARRAY_TEMP_ARRAY);
    }

    // Start loop from array based on AC. Overrides exsisting targets
    // - Use temp enemy array. ARRAY_TEMP_ARRAY
    nCnt2 = 0;
    sCnt = IntToString(nCnt);
    oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_TEMP_ARRAY + sCnt);
    while(GetIsObjectValid(oSetUpTarget) && bBreak != TRUE)
    {
        // We check AC or whatever...
        nValue = GetLocalInt(OBJECT_SELF, ARRAY_TEMP_ARRAY + sCnt);
        // Delete objects
        DeleteLocalObject(OBJECT_SELF, ARRAY_TEMP_ARRAY + sCnt);
        DeleteLocalInt(OBJECT_SELF, ARRAY_TEMP_ARRAY + sCnt);
        // Check values.
        // we check if we have under minimum OR it is under/over X.
        // As it is in value order, once we get to a point to stop, we
        // break the loop.
        if((nCnt2 < nMaxLoop) &&
           ((nCnt2 < nMinLoop) /*Default, get minimum targets*/
         || (nValue - nLowestHighestValue < iInputMinLimit && nTypeOfTarget == TARGET_LOWER)// Lowest to highest (20 - 25 < X?)
         || (nLowestHighestValue - nValue < iInputMinLimit && nTypeOfTarget == TARGET_HIGHER)))// Highest to lowest  (25 - 20 < X?)
        {
            // Set this as the newest highest/lowest value
            nLowestHighestValue = nValue;
            // Add it to array.
            nCnt2++;
            sCnt = IntToString(nCnt2);
            SetLocalObject(OBJECT_SELF, sNewArrayName + sCnt, oSetUpTarget);
            SetLocalInt(OBJECT_SELF, sNewArrayName + sCnt, nValue);
        }
        else  // else break out. (If got to max targets, got to a target we don't want to target)
        {
            for(nCnt3 = nCnt; bBreak != TRUE; nCnt3 += iAddEachTime)
            {
                // Remove all other values in the loop.
                sCnt = IntToString(nCnt3);
                if(GetIsObjectValid(GetLocalObject(OBJECT_SELF, ARRAY_TEMP_ARRAY + sCnt)))
                {
                    DeleteLocalInt(OBJECT_SELF, ARRAY_TEMP_ARRAY + sCnt);
                    DeleteLocalObject(OBJECT_SELF, ARRAY_TEMP_ARRAY + sCnt);
                }
                else
                {
                    bBreak = TRUE;
                }
            }
            bBreak = TRUE;
        }
        // Get next AC target - we add X, which is either +1 or -1, to
        // continue a loop going up or down.
        nCnt += iAddEachTime;
        sCnt = IntToString(nCnt);
        oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_TEMP_ARRAY + sCnt);
    }
    // Start resetting temp array used in the rest.
    DeleteLocalInt(OBJECT_SELF, MAXINT_ + ARRAY_TEMP_ARRAY);
    // Returns the amount of targets stored.
    return nCnt2;
}
// This sets ARRAY_TEMP_ARRAY of float values to sNewArrayName.
// - nTypeOfTarget, used TARGET_LOWER, TARGET_HIGHER.
// - We work until nMinimum is filled, or we get to nMinimum and we get to
//   a target with value > iInputMinimum. (20.0 - 25.0 > X?)
// Returns the amount of targets set in sNewArrayName.
int AI_TargetingArrayLimitTargetsFloat(string sNewArrayName, int nTypeOfTarget, float fInputMinLimit, int nMinLoop, int nMaxLoop)
{
    int iAddEachTime, nCnt, nCnt2, nCnt3, bBreak;
    float fValue, fLowestHighestValue;
    string sCnt;
    object oSetUpTarget;
    // Is it lowest to highest, or highest to lowest?
    // - 1. Lowest to highest
    if(nTypeOfTarget == TARGET_LOWER)
    {
        iAddEachTime = 1;
        nCnt = 1;
    }
    else // if(nTypeOfTarget == TARGET_HIGHER)
    {
        // Change to start at top value, and work down.
        iAddEachTime = -1;
        nCnt = GetLocalInt(OBJECT_SELF, MAXINT_ + ARRAY_TEMP_ARRAY);
    }

    // Start loop from array based on AC. Overrides exsisting targets
    // - Use temp enemy (AC) array.
    nCnt2 = FALSE;// Reset counter
    nCnt = 1;
    sCnt = IntToString(nCnt);
    oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_TEMP_ARRAY + sCnt);
    while(GetIsObjectValid(oSetUpTarget) && bBreak != TRUE)
    {
        // We check range normally...
        fValue = GetLocalFloat(OBJECT_SELF, ARRAY_TEMP_ARRAY + sCnt);
        // Check values.
        // we check if we have under minimum OR it is under/over X.
        // As it is in value order, once we get to a point to stop, we
        // break the loop.
        if((nCnt2 < nMaxLoop) &&
          ((nCnt2 < nMinLoop) /*Default, get minimum targets*/
        || (fValue - fLowestHighestValue < fInputMinLimit && nTypeOfTarget == TARGET_LOWER)// Lowest to highest (20 - 25 < X?)
        || (fLowestHighestValue - fValue < fInputMinLimit && nTypeOfTarget == TARGET_HIGHER)))// Highest to lowest  (25 - 20 < X?)
        {
            // Set fLowestHighestValue
            fLowestHighestValue = fValue;
            // Add it to array.
            nCnt2++;
            sCnt = IntToString(nCnt2);
            SetLocalObject(OBJECT_SELF, sNewArrayName + sCnt, oSetUpTarget);
            SetLocalFloat(OBJECT_SELF, sNewArrayName + sCnt, fValue);
        }
        else  // else break out. (If got to max targets, got to a target we don't want to target)
        {
            for(nCnt3 = nCnt; bBreak != TRUE; nCnt3 += iAddEachTime)
            {
                // Remove all other values in the loop.
                sCnt = IntToString(nCnt3);
                if(GetIsObjectValid(GetLocalObject(OBJECT_SELF, ARRAY_TEMP_ARRAY + sCnt)))
                {
                    DeleteLocalFloat(OBJECT_SELF, ARRAY_TEMP_ARRAY + sCnt);
                    DeleteLocalObject(OBJECT_SELF, ARRAY_TEMP_ARRAY + sCnt);
                }
                else
                {
                    bBreak = TRUE;
                }
            }
            bBreak = TRUE;
        }
        // Delete objects
        DeleteLocalObject(OBJECT_SELF, ARRAY_TEMP_ARRAY + sCnt);
        DeleteLocalFloat(OBJECT_SELF, ARRAY_TEMP_ARRAY + sCnt);
        // Get next AC target - we add X, which is either +1 or -1, to
        // continue a loop going up or down.
        nCnt += iAddEachTime;
        sCnt = IntToString(nCnt);
        oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_TEMP_ARRAY + sCnt);
    }
    // Start resetting temp array used in the rest.
    DeleteLocalInt(OBJECT_SELF, MAXINT_ + ARRAY_TEMP_ARRAY);
    // Returns the amount of targets stored.
    return nCnt2;
}

// Check if oTarget is:
// - Dead, Petrified, AI Ignore ON, A DM, Invalid
// - Not: Seen or heard (IE: We cannot see or hear them)
// Returns: TRUE if it is SANE to attack oTarget
int AI_GetTargetSanityCheck(object oTarget)
{
    // Ethereal check
    if(GetIsEthereal(oTarget)) return FALSE;

    if(!GetIsObjectValid(oTarget) && // Isn't valid
        GetIsDead(oTarget) ||        // Is dead
        GetIsDM(oTarget) ||          // Is DM
        GetIgnore(oTarget) ||        // Is ignored
        AI_GetAIHaveEffect(GlobalEffectPetrify, oTarget) ||  // Is petrified
      (!GetObjectSeen(oTarget) && !GetObjectHeard(oTarget))) // Is not seen nor heard.
    {
        // If we cannot see or hear the target, or they are an invalid target,
        // it is NOT sane to atack them - return FALSE
        return FALSE;
    }
    // Else, return TRUE - we CAN attack them!
    return TRUE;
}

// We set up targets to Global* variables, GlobalSpellTarget, GlobalRangeTarget,
// and GlobalMeleeTarget. Counts enemies, and so on.
// - Uses oIntruder (to attack or move near) if anything.
// - We return TRUE if it ActionAttack's, or moves to an enemy - basically
//   that we cannot do an action, but shouldn't search. False if normal.
int AI_SetUpAllObjects(object oInputBackup)
{
    // Delete past arrays
    AI_TargetingArrayDelete(ARRAY_ENEMY_RANGE);
    AI_TargetingArrayDelete(ARRAY_ENEMY_RANGE_SEEN);
    AI_TargetingArrayDelete(ARRAY_ENEMY_RANGE_HEARD);
    AI_TargetingArrayDelete(ARRAY_ALLIES_RANGE);
    AI_TargetingArrayDelete(ARRAY_ALLIES_RANGE_SEEN);
    AI_TargetingArrayDelete(ARRAY_ALLIES_RANGE_SEEN_BUFF);

    // We always use range as at least 1 of the ways to get best target.
    float fCurrentRange, fSetMaxWeCanGoTo;
    location lSelf = GetLocation(OBJECT_SELF);
    int nCnt, nCnt2, nCnt3, bBreak;//Counter loop.
    int nValue, nMaxTurnsAttackingX, nMaximum, nMinimum, nRemainingTargets, nTypeOfTarget;
    string sCnt; // IntToString(nCnt) :-)
    object oTempLoopObject, oSetUpTarget, oLastTarget, oInputBackUpToAttack;

    // Note: Here we check if oIntruder is a sane thing to attack.
    if(AI_GetTargetSanityCheck(oInputBackup))
    {
        oInputBackUpToAttack = oInputBackup;
    }
    // Note: oIntruder is still used to search near if anything.

    // SRA - Spell Ranged Attacking uses the nearest seen, or the nearest heard,
    // for the spell target (not ranged or melee, however)
    if(SRA)
    {
        // Checked below for validness ETC.
        GlobalSpellTarget = GlobalNearestEnemySeen;
    }

    // we have a max amount of rounds to attack one target.
    nMaxTurnsAttackingX = GetBoundriedAIInteger(AI_MAX_TURNS_TO_ATTACK_ONE_TARGET, 6, 40, 1);

    // Start...
    // Gets all CREATURES within 50M andin LOS. THIS IS THE MAJOR OBJECT LOOP OF THE AI!
    oSetUpTarget = GetFirstObjectInShape(SHAPE_SPHERE, 50.0, lSelf, TRUE);
    while(GetIsObjectValid(oSetUpTarget))
    {
        // We totally ignore DM's, and AI_IGNORE people
        // * 1.4: We also ignore all Etherealness (even if they are visible).
        //        A new function is added after targeting to react to the
        //        ethereal people we *may* see via. trueseeing, and cannot see anything
        //        else by casting defensive only spells, healing, summoning,
        //        and making sure we stay in combat!
        // * Ignore:
        // - Dead
        // - Petrified
        // - AI Ignore ON
        // - DM
        // - Invalid
        // Must be: Seen or heard
        // Else, we ignore them. Special cases can get dead people (raising,
        // killing off) but unseen/unheard people are, in the case of the AI,
        // unknown about unless we specifically know they went/came invisible
        if(AI_GetTargetSanityCheck(oSetUpTarget) && oSetUpTarget != OBJECT_SELF)
        {
            // If the target is a friend, we add 1 to targets, and set in array.
            if(GetIsFriend(oSetUpTarget) || GetFactionEqual(oSetUpTarget))
            {
                GlobalTotalAllies++;
                SetLocalObject(OBJECT_SELF, ARRAY_TEMP_ALLIES + IntToString(GlobalTotalAllies), oSetUpTarget);
            }
            // Enemy...add to enemy array, even if not seen nor heard.
            else if(GetIsEnemy(oSetUpTarget))
            {
                //SpeakString("Enemy (no dead) in LOS:" + GetName(oSetUpTarget));
                // We set up a "Seen or heard" enemies counter below
                nCnt++;
                SetLocalObject(OBJECT_SELF, ARRAY_TEMP_ENEMIES + IntToString(nCnt), oSetUpTarget);
            }
            // Well, we have enemies in range. We check if we need to re-set constants
            // based on a timer. If done, set a timer.
            // * 1.4 : Removes the timer! This is now done each time the AI runs,
            //   and as the Bioware AI does loops of all effects quite often, this,
            //   even if not a large improvement of performance, is easier for the AI
            //   and me to write and code.
            // * 1.4 changes also fix some remove condition problems of the
            //   local not being updated.
            // Always set up effects - allied, neutral, or enemy!
            AI_SetEffectsOnTarget(oSetUpTarget);
        }
        oSetUpTarget = GetNextObjectInShape(SHAPE_SPHERE, 50.0, lSelf, TRUE);
    }
    // The first simple one is therefore done :-)

/*:://////////////////////////////////////////////
    Special case:

    If we have NO nearest seen/heard enemies (GetNearest* calls) we:
    - Check allies for thier targets

    Nothing else for now.
//::////////////////////////////////////////////*/


/*:://////////////////////////////////////////////
    Enemies

    Set up finalish arrays of enemies, and lots of counting numbers.
//::////////////////////////////////////////////*/

    // Next, we loop on range. Allies and Enemies
    AI_TargetingArrayDistanceStore(ARRAY_TEMP_ENEMIES, ARRAY_ENEMY_RANGE);

    // Before we start re-setting targets, we do set up an extra 2 arrays based
    // on seen and heard (one OR the other) arrays for the enemy. These are objects in our LOS.
    nCnt = 1;
    nCnt2 = FALSE;// Counter for seen
    nCnt3 = FALSE;// Counter for heard
    nValue = FALSE;// Counter for BAB
    bBreak = FALSE;// Counter for HD
    GlobalEnemiesIn4Meters = FALSE;// Make sure at 0
    GlobalMeleeAttackers = FALSE;// Make sure at 0
    GlobalRangedAttackers = FALSE;// Make sure at 0
    oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_ENEMY_RANGE + IntToString(nCnt));
    while(GetIsObjectValid(oSetUpTarget))
    {
        fCurrentRange = GetLocalFloat(OBJECT_SELF, ARRAY_ENEMY_RANGE + IntToString(nCnt));

        // 1.4 change here. Already checked for dead and petrifed creatures
        // in setting all arrays of enemies and allies.

        // Count ranged and melee attackers.
        if(GetAttackTarget(oSetUpTarget) == OBJECT_SELF)
        {
            // Melee/ranged attacker?
            if(GetWeaponRanged(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oSetUpTarget)))
            {
                // - 1.3 beta fixed this. I didn't notice I got these mixed up :-P
                GlobalRangedAttackers++;
            }
            else
            {
                GlobalMeleeAttackers++;
            }
        }
        // Total enemies in 4M
        if(fCurrentRange <= 4.0)
        {
             GlobalEnemiesIn4Meters++;
        }
        // It is nearest to futhest. Just set each one in one of 2 arrays.
        if(GetObjectSeen(oSetUpTarget))
        {
            // bBreak counts average HD
            bBreak += GetHitDice(oSetUpTarget);
            // Value counts BAB
            nValue += GetBaseAttackBonus(oSetUpTarget);
            // Add to total seen/heard enemies
            GlobalTotalSeenHeardEnemies++;
            // Object seen.
            nCnt2++;
            SetLocalFloat(OBJECT_SELF, ARRAY_ENEMY_RANGE_SEEN + IntToString(nCnt2), fCurrentRange);
            SetLocalObject(OBJECT_SELF, ARRAY_ENEMY_RANGE_SEEN + IntToString(nCnt2), oSetUpTarget);
        }
        else if(GetObjectHeard(oSetUpTarget))
        {
            // bBreak counts average HD
            bBreak += GetHitDice(oSetUpTarget);
            // Value counts BAB
            nValue += GetBaseAttackBonus(oSetUpTarget);
            // Add to total seen/heard enemies
            GlobalTotalSeenHeardEnemies++;
            // Object heard.
            nCnt3++;
            SetLocalFloat(OBJECT_SELF, ARRAY_ENEMY_RANGE_HEARD + IntToString(nCnt3), fCurrentRange);
            SetLocalObject(OBJECT_SELF, ARRAY_ENEMY_RANGE_HEARD + IntToString(nCnt3), oSetUpTarget);
        }
        // Next enemy
        nCnt++;
        oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_ENEMY_RANGE + IntToString(nCnt));
    }
    // Set GlobalRangeToFuthestEnemy.
    // - Using futhest heard should be good enough.
    GlobalRangeToFuthestEnemy = GetLocalFloat(OBJECT_SELF, ARRAY_ENEMY_RANGE_HEARD + IntToString(nCnt3));

    // We need value just above to calcualte these, else leave at 0.
    if(GlobalTotalSeenHeardEnemies >= 1 && bBreak >= 1)
    {
        // Average enemy HD
        GlobalAverageEnemyHD = bBreak / GlobalTotalSeenHeardEnemies;
        if(GlobalAverageEnemyHD < 1) GlobalAverageEnemyHD = 1;
        // Average BAB
        GlobalAverageEnemyBAB = nValue / GlobalTotalSeenHeardEnemies;
        if(GlobalAverageEnemyBAB < 0) GlobalAverageEnemyBAB = 0;
    }

/*:://////////////////////////////////////////////
    Friends

    Sets up all allies things
//::////////////////////////////////////////////*/

    // Friendly (ally) targets too - for curing ETC.
    AI_TargetingArrayDistanceStore(ARRAY_TEMP_ALLIES, ARRAY_ALLIES_RANGE);

    // Spells which affect GetIsReactionType
    oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_ALLIES_RANGE + "1");

    // If not valid, use self
    if(!GetIsObjectValid(oSetUpTarget))
    {
        // Use nearest us, just for testing.
        GlobalFriendlyFireHostile = GetIsReactionTypeHostile(OBJECT_SELF);
        GlobalFriendlyFireFriendly = GetIsReactionTypeFriendly(OBJECT_SELF);
    }

    // Use nearest ally, just for testing.
    GlobalFriendlyFireHostile = GetIsReactionTypeHostile(oSetUpTarget);
    GlobalFriendlyFireFriendly = GetIsReactionTypeFriendly(oSetUpTarget);
    GlobalNearestAlly = oSetUpTarget;
    GlobalValidAlly = GetIsObjectValid(GlobalNearestAlly);
    GlobalRangeToAlly = GetDistanceToObject(oSetUpTarget);

    // 0 Seen/heard. We don't check enemies numbers - they could be hidden.
    if(!GlobalValidNearestSeenEnemy && !GlobalValidNearestHeardEnemy)
    {
        bBreak = FALSE;
        // Loop allies for ANY target, and move to them! (Attack in HTH, this
        // lets us re-set targets On Percieve)
        nCnt = -1;
        // Allys
        oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_ALLIES_RANGE + IntToString(nCnt));
        while(GetIsObjectValid(oSetUpTarget) && bBreak != TRUE)
        {
            // It is nearest to futhest.
            oTempLoopObject = GetAttackTarget(oSetUpTarget);
            if(GetIsObjectValid(oTempLoopObject))
            {
                // If a valid attack object, we stop!
                bBreak = TRUE;
            }
            else
            {
                // Next ally
                nCnt++;
                oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_ALLIES_RANGE + IntToString(nCnt));
            }
        }
        // We move to the target if we have one.
        if(bBreak)
        {
            // Just a temp most damaging melee. Normally, it is best to
            // just Move to the target
            // 39: "[DCR:Targeting] No valid enemies in sight, moving to allies target's. [Target] " + GetName(oSetUpTarget)
            DebugActionSpeakByInt(39, oSetUpTarget);
            AI_EquipBestShield();
            ActionEquipMostDamagingMelee();
            ActionMoveToLocation(GetLocation(oSetUpTarget), TRUE);
            return TRUE;
        }
    }
    // What other ally stuff?
    // - Nearest leader
    // - Who to heal? (Most damaged in X range of lesser damaged ones)
    // - Who to heal effects from? (Not done here!)
    // - Nearest ally
    // - Buff ally
    if(GlobalValidAlly)
    {
        // Set up an array of seen ranged-based allies, for healing and for
        // healing effects, and for buffing.
        nCnt = 1;
        nCnt2 = 0;
        nCnt3 = 0;
        nValue = FALSE;  // Just a temp for leader status set
        oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_ALLIES_RANGE + IntToString(nCnt));
        while(GetIsObjectValid(oSetUpTarget))
        {
            nCnt3 += GetHitDice(oSetUpTarget);
            if(GetObjectSeen(oSetUpTarget))
            {
                nCnt2++;
                SetLocalObject(OBJECT_SELF, ARRAY_ALLIES_RANGE_SEEN + IntToString(nCnt2), oSetUpTarget);
                // Set global nearest seen leader for morale ETC.
                if(GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_GROUP_LEADER, AI_OTHER_COMBAT_MASTER, oSetUpTarget)
                   && nValue != TRUE)
                {
                    GlobalNearestLeader = oSetUpTarget;
                    nValue = TRUE;
                }
            }
            // Next ally
            nCnt++;
            oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_ALLIES_RANGE_SEEN + IntToString(nCnt));
        }
        GlobalValidLeader = nValue;
        if(nCnt >= 1 && nCnt3 >= 1)
        {
            GlobalAverageFriendlyHD = nCnt3 / nCnt;
        }
        // Set nearest seen ally.
        GlobalNearestSeenAlly = GetLocalObject(OBJECT_SELF, ARRAY_ALLIES_RANGE_SEEN + "1");
        GlobalValidSeenAlly = GetIsObjectValid(GlobalNearestSeenAlly);

        // We set up buff allies in a new array.
        // - We may set up summons (or people with masters) if we have under
        //   <= 3 people, or it is of comparable hit dice to us.
        nCnt = 1;
        nCnt2 = FALSE;
        fSetMaxWeCanGoTo = 20.0;
        // we add this onto any ranges we input, so how far we'll move to.
        GlobalBuffRangeAddon = 0.0;
        // nValue is the limit of buff targets
        // - Less if sorceror/bard (very few)
        // - More if proper buffer
        nValue = 5;
        if(GlobalWeAreSorcerorBard)
        {
            nValue = 2;
        }
        // If we are set to buff allies, we extend the range.
        if(GetSpawnInCondition(AI_FLAG_COMBAT_MORE_ALLY_BUFFING_SPELLS, AI_COMBAT_MASTER))
        {
            nValue = 8;
            fSetMaxWeCanGoTo = 40.0;
            GlobalBuffRangeAddon = 30.0;
        }
        oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_ALLIES_RANGE_SEEN + IntToString(nCnt));
        // Loop allies
        // - Only up to 10.
        // - Check masters as above.
        while(GetIsObjectValid(oSetUpTarget) && nCnt2 <= nValue &&
              GetDistanceToObject(oSetUpTarget) <= fSetMaxWeCanGoTo)
        {
            // No arcane spellcasters.
            if(!GetLevelByClass(CLASS_TYPE_SORCERER, oSetUpTarget) &&
               !GetLevelByClass(CLASS_TYPE_WIZARD, oSetUpTarget) &&
            // - Master check
              (GlobalTotalAllies <= 3 ||
               !GetIsObjectValid(GetMaster(oSetUpTarget)) ||
                GetHitDice(oSetUpTarget) >= GlobalOurHitDice - 5))
            {
                // Add to new array
                nCnt2++;
                SetLocalObject(OBJECT_SELF, ARRAY_ALLIES_RANGE_SEEN_BUFF + IntToString(nCnt2), oSetUpTarget);
            }
            // Next seen ally
            nCnt++;
            oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_ALLIES_RANGE_SEEN + IntToString(nCnt));
        }
    }

/*:://////////////////////////////////////////////
    Well, do we change our targets?

    There is a max limit (default of 6) rounds that we attack targets, melee
    ranged and spell.

    There is also a random % to re-set the target, for each type.

    Leaders override all 3 targets, and set it to it.

    And finally, the target we had last time must be:
    - Not dead
    - Seen or heard (Spell targets must be seen if there is a valid seen enemy)
    - Not attacking us if we have sneak attack (Ranged/Melee target)
//::////////////////////////////////////////////*/

    // Leader checking
    oSetUpTarget = GetAIObject(AI_ATTACK_SPECIFIC_OBJECT);
    // Always delete
    DeleteAIObject(AI_ATTACK_SPECIFIC_OBJECT);
    // Our specific target to attack
    // - sanity check just in case
    if(AI_GetTargetSanityCheck(oSetUpTarget))
    {
        // 40: "[DCR:Targeting] Override Target Seen. [Name]" + GetName(oSetUpTarget)
        DebugActionSpeakByInt(40, oSetUpTarget);
        // Melee target, we must check if we have any valid.
        GlobalMeleeTarget = oSetUpTarget;
        GlobalRangedTarget = oSetUpTarget;
        GlobalSpellTarget = oSetUpTarget;
    }
    // Lagbusting, get nearest
    // * This is under AI_OTHER_MASTER. 1.4 fix.
    else if(GetSpawnInCondition(AI_FLAG_OTHER_LAG_TARGET_NEAREST_ENEMY, AI_OTHER_MASTER))
    {
        if(GetIsObjectValid(GlobalNearestEnemySeen))
        {
            // The validness of these are checked later anyway
            GlobalMeleeTarget = GlobalNearestEnemySeen;
            GlobalRangedTarget = GlobalNearestEnemySeen;
            GlobalSpellTarget = GlobalNearestEnemySeen;
        }
    }
    // We may also make it so that we target only the lowest AC and so on...
    // LIKE_LOWER_HP, LIKE_LOWER_AC, LIKE_MAGE_CLASSES, LIKE_ARCHERS
    else if(GetSpawnInCondition(AI_FLAG_TARGETING_LIKE_LOWER_HP, AI_TARGETING_FLEE_MASTER))
    {
        // We use this check - inbuilt, automatic, and also is simple!
        oSetUpTarget = GetFactionMostDamagedMember(GlobalNearestEnemySeen);
        if(AI_GetTargetSanityCheck(oSetUpTarget))
        {
            if(GetDistanceToObject(GlobalNearestEnemyHeard) > 4.0 ||
               GetDistanceToObject(oSetUpTarget) < 3.0)
            {
                GlobalMeleeTarget = oSetUpTarget;
            }
            GlobalRangedTarget = oSetUpTarget;
            GlobalSpellTarget = oSetUpTarget;
        }
    }
    // HD
    else if(GetSpawnInCondition(AI_FLAG_TARGETING_LIKE_LOWER_HD, AI_TARGETING_FLEE_MASTER))
    {
        // We use this check - inbuilt, automatic, and also is simple!
        oSetUpTarget = GetFactionWeakestMember(GlobalNearestEnemySeen);
        if(AI_GetTargetSanityCheck(oSetUpTarget))
        {
            if(GetDistanceToObject(GlobalNearestEnemyHeard) > 4.0 ||
               GetDistanceToObject(oSetUpTarget) < 3.0)
            {
                GlobalMeleeTarget = oSetUpTarget;
            }
            GlobalRangedTarget = oSetUpTarget;
            GlobalSpellTarget = oSetUpTarget;
        }
    }
    // AC
    else if(GetSpawnInCondition(AI_FLAG_TARGETING_LIKE_LOWER_AC, AI_TARGETING_FLEE_MASTER))
    {
        // We use this check - inbuilt, automatic, and also is simple!
        oSetUpTarget = GetFactionWorstAC(GlobalNearestEnemySeen);
        if(AI_GetTargetSanityCheck(oSetUpTarget))
        {
            // Make sure the nearest seen is not in front of the worst AC.
            if(GetDistanceToObject(GlobalNearestEnemyHeard) > 4.0 ||
               GetDistanceToObject(oSetUpTarget) < 3.0)
            {
                GlobalMeleeTarget = oSetUpTarget;
            }
            GlobalRangedTarget = oSetUpTarget;
            GlobalSpellTarget = oSetUpTarget;
        }
    }
    // Ranged attackers
    else if(GetSpawnInCondition(AI_FLAG_TARGETING_LIKE_ARCHERS, AI_TARGETING_FLEE_MASTER))
    {
        // Get nearest one who is attacking us.
        nCnt = 1;
        oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_ENEMY_RANGE_SEEN + IntToString(nCnt));
        while(GetIsObjectValid(oSetUpTarget))
        {
            // All the array is already sane targets.

            // have they got a ranged weapon?
            if(GetWeaponRanged(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oSetUpTarget)))
            {
                // Only set to melee if quite near.
                if(GetDistanceToObject(GlobalNearestEnemyHeard) > 4.0 ||
                   GetDistanceToObject(oSetUpTarget) < 3.0)
                {
                    GlobalMeleeTarget = oSetUpTarget;
                }
                GlobalRangedTarget = oSetUpTarget;
                GlobalSpellTarget = oSetUpTarget;
                break;
            }
            nCnt++;
            oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_ENEMY_RANGE_SEEN + IntToString(nCnt));
        }
    }
    // Mage classes
    else if(GetSpawnInCondition(AI_FLAG_TARGETING_LIKE_MAGE_CLASSES, AI_TARGETING_FLEE_MASTER))
    {
        // Sorceror
        oSetUpTarget = GetNearestCreature(CREATURE_TYPE_CLASS, CLASS_TYPE_SORCERER, OBJECT_SELF, 1, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, CREATURE_TYPE_IS_ALIVE, TRUE);
        // If the sorceror isn't sane, we will check for wizards.
        if(!AI_GetTargetSanityCheck(oSetUpTarget))
        {
            // Wizard
            oSetUpTarget = GetNearestCreature(CREATURE_TYPE_CLASS, CLASS_TYPE_WIZARD, OBJECT_SELF, 1, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, CREATURE_TYPE_IS_ALIVE, TRUE);
        }
        // If valid, use
        if(AI_GetTargetSanityCheck(oSetUpTarget))
        {
            // Only set to melee if quite near.
            if(GetDistanceToObject(GlobalNearestEnemyHeard) > 4.0 ||
               GetDistanceToObject(oSetUpTarget) < 3.0)
            {
                GlobalMeleeTarget = oSetUpTarget;
            }
            GlobalRangedTarget = oSetUpTarget;
            GlobalSpellTarget = oSetUpTarget;
        }
    }
    nValue = GetAIConstant(AI_FAVOURED_ENEMY_RACE);
    if(nValue >= FALSE)
    {
        oSetUpTarget = GetNearestCreature(CREATURE_TYPE_RACIAL_TYPE, nValue, OBJECT_SELF, 1, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
        if(AI_GetTargetSanityCheck(oSetUpTarget))
        {
            // Make sure the nearest seen is not in front of the worst AC.
            if(GetDistanceToObject(GlobalNearestEnemyHeard) > 4.0 ||
               GetDistanceToObject(oSetUpTarget) < 3.0)
            {
                GlobalMeleeTarget = oSetUpTarget;
            }
            GlobalRangedTarget = oSetUpTarget;
            GlobalSpellTarget = oSetUpTarget;
        }
    }
    else
    {
        nValue = GetAIConstant(AI_FAVOURED_ENEMY_CLASS);
        if(nValue >= FALSE)
        {
            oSetUpTarget = GetNearestCreature(CREATURE_TYPE_CLASS, nValue, OBJECT_SELF, 1, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
            if(AI_GetTargetSanityCheck(oSetUpTarget))
            {
                // Make sure the nearest seen is not in front of the worst AC.
                if(GetDistanceToObject(GlobalNearestEnemyHeard) > 4.0 ||
                   GetDistanceToObject(oSetUpTarget) < 3.0)
                {
                    GlobalMeleeTarget = oSetUpTarget;
                }
                GlobalRangedTarget = oSetUpTarget;
                GlobalSpellTarget = oSetUpTarget;
            }
        }
    }

/*:://////////////////////////////////////////////
    Melee targeting

    This uses some of the closer people or all within reach (determined before)

    After getting the right people, we determine with AC, HP and some other
    things, which are the best.
//::////////////////////////////////////////////*/

    // Do we want to change melee targets?
    oLastTarget = GetAIObject(AI_LAST_MELEE_TARGET);

    // bValid is the counter for attacking target X...
    bBreak = GetAIInteger(AI_MELEE_TURNS_ATTACKING);
    bBreak++;
    SetAIInteger(AI_MELEE_TURNS_ATTACKING, bBreak);
    // We set this to 0 if we our oSetUpTarget != GlobalMeleeTarget below changing.

    // Check %
    // If we have an override, we don't check for targets, but run Global*
    // setups at the end still, but with the target being oOverride.

    // - No valid override target
    if(!GetIsObjectValid(GlobalMeleeTarget) &&
    // 1. If the last target isn't a sane target...
       (!AI_GetTargetSanityCheck(oLastTarget) ||
    // 2. ...Or must pass a % roll to change (or check for new) targets...
        d100() <= GetBoundriedAIInteger(AI_MELEE_LAST_TO_NEW_TARGET_CHANCE, 20, 100) ||
    // 3. ...OR last target attacked for X rounds we limit ourselves to.
        bBreak >= nMaxTurnsAttackingX))
    {
        // Loop targets, ETC, and get GlobalMeleeTarget normally.
        // Set up melee  = ARRAY_MELEE_ENEMY

        // Note: if we start getting wide gaps between group A and object B, we
        // stop, because they are probably behind more enemies :-D
        // Note 2: We only use seen enemies as a prioritory, else heard ones (like
        //         invisible ones)

        // 1. Nearby SEEN enemies. Obviously nearest to furthest!
        // IE the maximum and minimum targets for the range checking.
        nMinimum = GetBoundriedAIInteger(TARGETING_RANGE + MINIMUM, 2, 40, 1);
        nMaximum = GetBoundriedAIInteger(TARGETING_RANGE + MAXIMUM, 8, 40, 1);

        // fSetMaxWeCanGoTo = Maximum range away from us (GetDistanceToObject) that
        // we can go to. This is increased if we have tumble (compared to level) or
        // spring attack is king :-D
        fSetMaxWeCanGoTo = GlobalOurReach + 1.0;// Have 1 extra as well
        // We add a lot for spring attack - 3d4 (3 to 12)
        // OR we have 13+ (IE a very high chance of suceeding) in tumble

        // give caster movement a higher chance regardless of spring attack or tumble - pok
        //if(GetHasFeat(FEAT_SPRING_ATTACK) || GetSkillRank(SKILL_TUMBLE) >= 13)
        //{
            fSetMaxWeCanGoTo += IntToFloat(d4(3));
        //}
        /*
        else if(GetHasSkill(SKILL_TUMBLE))
        {
            // Else we add some for tumble
            bBreak = GetSkillRank(SKILL_TUMBLE) - GlobalOurHitDice;
            if(bBreak > FALSE)
            {
                // * Basis of Skill Rank - Our Hit Dice. 5 tumble on a level 2 makes +3M Range.
                fSetMaxWeCanGoTo += IntToFloat(bBreak);
            }
        }
        */
        bBreak = FALSE;
        // Start loop from array based on range.
        // - Use seen array!
        // - Break if we have added enough targets to our array.
        nRemainingTargets = FALSE;
        nCnt = 1;
        sCnt = IntToString(nCnt);
        oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_ENEMY_RANGE_SEEN + sCnt);
        while(GetIsObjectValid(oSetUpTarget) && nRemainingTargets < nMaximum)
        {
            // If seen, we check range...
            fCurrentRange = GetLocalFloat(OBJECT_SELF, ARRAY_ENEMY_RANGE_SEEN + sCnt);
            // We start from the closest, so we need to cancle those out which
            // are too far away.
            // we check if it is in our reach. If so, we add it.
            if(fCurrentRange < fSetMaxWeCanGoTo || nRemainingTargets < nMinimum)
            {
                nRemainingTargets++;
                sCnt = IntToString(nRemainingTargets);
                SetLocalObject(OBJECT_SELF, ARRAY_MELEE_ENEMY + sCnt, oSetUpTarget);
                SetLocalFloat(OBJECT_SELF, ARRAY_MELEE_ENEMY + sCnt, fCurrentRange);
            }
            // Get next nearest SEEN
            nCnt++;
            sCnt = IntToString(nCnt);
            oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_ENEMY_RANGE_SEEN + sCnt);
        }
        // 1a. If not valid, just use nearest seen if valid
        if(!nRemainingTargets && GlobalValidNearestSeenEnemy)
        {
            nRemainingTargets = 1;
            SetLocalObject(OBJECT_SELF, ARRAY_MELEE_ENEMY + "1", GlobalNearestEnemySeen);
            SetLocalFloat(OBJECT_SELF, ARRAY_MELEE_ENEMY + "1", GetDistanceToObject(GlobalNearestEnemySeen));
        }
        else
        {
            // 2. Make sure the nearest HEARD is NOT very close compared to the nearest
            //    SEEN OR we have no nearest seen.
            // Check if we have no seen objects set, or the nearest heard is nearer then the futhest seen by 4M
            fCurrentRange = GetDistanceToObject(GlobalNearestEnemyHeard);
            if(GlobalValidNearestHeardEnemy && (!nRemainingTargets ||
              // Range to nearest heard is nearer then the melee enemy
              (fCurrentRange > 0.0 && ((fCurrentRange + 4.0) <
              // Nearest melee range enemy we've set to seen
               GetLocalFloat(OBJECT_SELF, ARRAY_MELEE_ENEMY + "1")))))
            {
                //  - We half the amount we need for this range check
                // Maximum
                nMaximum /= 2;
                if(nMaximum < 1) nMaximum = 1;
                // Minimum
                nMinimum /= 2;
                if(nMinimum < 1) nMinimum = 1;
                // Start loop from array based on range. Overrides exsisting targets
                // - Use heard enemy array.
                nCnt = 1;
                nRemainingTargets = FALSE;
                sCnt = IntToString(nCnt);
                oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_ENEMY_RANGE_HEARD + sCnt);
                while(GetIsObjectValid(oSetUpTarget) && nRemainingTargets < nMaximum)
                {
                    // If seen, we check range...
                    fCurrentRange = GetLocalFloat(OBJECT_SELF, ARRAY_ENEMY_RANGE_HEARD + sCnt);
                    // We start from the closest, so we need to cancle those out which
                    // are too far away.
                    if(fCurrentRange < fSetMaxWeCanGoTo || nRemainingTargets < nMinimum)
                    {
                        nRemainingTargets++;
                        sCnt = IntToString(nRemainingTargets);
                        SetLocalObject(OBJECT_SELF, ARRAY_MELEE_ENEMY + sCnt, oSetUpTarget);
                        SetLocalFloat(OBJECT_SELF, ARRAY_MELEE_ENEMY + sCnt, fCurrentRange);
                    }
                    // Get next HEARD
                    nCnt++;
                    sCnt = IntToString(nCnt);
                    oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_ENEMY_RANGE_HEARD + sCnt);
                }
            }
        }
        // Now, do we have any Melee Targets?
        if(!nRemainingTargets)
        {
            // If not, what can we use?
            // - We use the Inputted target!
            // - We use anyone who allies are attacking!
            // - We use anyone we hear!

            // Inputted target (EG last attack that GetObjectSeen doesn't return
            // for).
            oSetUpTarget = oInputBackUpToAttack;
            if(!GetIsObjectValid(oSetUpTarget))
            {
                // Anyone we hear
                oSetUpTarget = GlobalNearestEnemyHeard;
                if(!GetIsObjectValid(oSetUpTarget))
                {
                    // We get who our allies are attacking
                    nCnt = 1;
                    oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_ALLIES_RANGE + IntToString(nCnt));
                    while(GetIsObjectValid(oSetUpTarget) && bBreak != TRUE)
                    {
                        // Get the allies attack target. If valid, attack it!
                        oTempLoopObject = GetAttackTarget(oSetUpTarget);
                        if(AI_GetTargetSanityCheck(oTempLoopObject))
                        {
                            oSetUpTarget = oTempLoopObject;
                            bBreak = TRUE;
                        }
                        else
                        {
                            nCnt++;
                            oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_ALLIES_RANGE + IntToString(nCnt));
                        }
                    }
                    // Don't attack anyone we got in the loop, of course.
                    if(GetIsFriend(oSetUpTarget) || GetFactionEqual(oSetUpTarget))
                    {
                        oSetUpTarget = OBJECT_INVALID;
                    }
                }
            }
            // Do we have a target from those backups above?
            // - If so, we ActionAttack it so we move near it, as it is not in
            //   our LOS, or isn't in our seen range in our LOS.
            if(GetIsObjectValid(oSetUpTarget))
            {
                // 41: [DCR:Targeting] No seen in LOS, Attempting to MOVE to something [Target]" + GetName(oSetUpTarget)
                DebugActionSpeakByInt(41, oSetUpTarget);
                DeleteAIObject(AI_LAST_MELEE_TARGET);
                DeleteAIObject(AI_LAST_SPELL_TARGET);
                DeleteAIObject(AI_LAST_RANGED_TARGET);
                AI_EquipBestShield(); // in case of an ambush, be ready
                ActionMoveToLocation(GetLocation(oSetUpTarget), TRUE);
                return TRUE;
            }
            // If it doesn't have anything we can see/move to/attack/search
            // near, then we make sure have make sure we have no target
            // (GlobalAnyValidTargetObject) and break the function, so we can stop.
            // "else"
            GlobalAnyValidTargetObject = FALSE;
            return FALSE;
        }
        // If only one, choose it
        else if(nRemainingTargets == 1)
        {
            GlobalMeleeTarget = GetLocalObject(OBJECT_SELF, ARRAY_MELEE_ENEMY + "1");
        }
        else //if(nRemainingTargets > 1)
        {
            // If we have any set targets (heard/seen ones) then we
            // will reduce the amount by AC, HP (current Percent/max/current)
            // and HD and BAB

            // We only use range as a default. The rest are done in order if they
            // are set! :-D

            // We check for PC targets
            // DODODODO

        // Target:
        // AC                - Used only for phisical attacks (TARGETING_AC)
        // Phisical Protections - Used for both spells and melee (TARGETING_PHISICALS)
        // Base Attack Bonus - Used for both spells and melee (TARGETING_BAB)
        // Hit Dice          - Used for both spells and melee (TARGETING_HITDICE)
        // HP Percent        - Used for both spells and melee (TARGETING_HP_PERCENT)
        // HP Current        - Used for both spells and melee (TARGETING_HP_CURRENT)
        // HP Maximum        - Used for both spells and melee (TARGETING_HP_MAXIMUM)

            // 0. Sneak attack check
            if(GetHasFeat(FEAT_SNEAK_ATTACK))
            {
                // We normally get the nearest enemy who is not attacking us, and
                // actually stop!
                AI_TargetingArrayIntegerStore(9, ARRAY_MELEE_ENEMY);

                // Get the closest who isn't attacking us.
                oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_TEMP_ARRAY + "1");
                if(GetAttackTarget(oSetUpTarget) != OBJECT_SELF)
                {
                    GlobalMeleeTarget = oSetUpTarget;
                    nRemainingTargets = FALSE;
                }
                // If we have trouble using that one, IE they are attacking us, we
                // just use normal methods.
            }
            // 1. AC
            nMinimum = GetAIInteger(TARGETING_AC + MINIMUM);
            // Do we do AC? And over one target...
            // - nCnt2 is the total target stored in the last array.
            if(nMinimum && nRemainingTargets >= 2)
            {
                // If so, is it lowest or highest?
                nTypeOfTarget = GetAIInteger(TARGETING_AC);
                nMaximum = GetAIInteger(TARGETING_AC + MAXIMUM);

                // We then set the array up in a new temp array. 1 = AC.
                AI_TargetingArrayIntegerStore(1, ARRAY_MELEE_ENEMY);

                // We loop through all the targets in the temp array (we also
                // delete the temp array targets!) and set what ones we want to target
                // based on AC.
                // - Continue until nMinimum is reached.
                // - Never go over nMaximum
                // - After nMinimum we make sure the AC differences is not a major one of
                // over 5.
                nRemainingTargets = AI_TargetingArrayLimitTargets(ARRAY_MELEE_ENEMY, nTypeOfTarget, 5, nMinimum, nMaximum);
            }
            // Most others are similar (and all integer values so easy to check)
            // 2. Phisical protections.
            nMinimum = GetAIInteger(TARGETING_PHISICALS + MINIMUM);
            if(nMinimum && nRemainingTargets >= 2)
            {
                // If so, is it lowest or highest?
                nTypeOfTarget = GetAIInteger(TARGETING_PHISICALS);
                nMaximum = GetAIInteger(TARGETING_PHISICALS + MAXIMUM);
                // We then set the array up in a new temp array. 3 = phisicals.
                AI_TargetingArrayIntegerStore(3, ARRAY_MELEE_ENEMY);
                // We loop as AC, basically. As it is stored based on the amount
                // of DR offered, we set the limit to 6, so if everyone had
                // 0 DR, and 1 had 5, it'd add the 5 for the hell of it. If everyone
                // had 20, and one had 25 it'd take the 25 too, but not a 30.
                nRemainingTargets = AI_TargetingArrayLimitTargets(ARRAY_MELEE_ENEMY, nTypeOfTarget, 6, nMinimum, nMaximum);
            }
            // 4. BAB
            nMinimum = GetAIInteger(TARGETING_BAB + MINIMUM);
            if(nMinimum && nRemainingTargets >= 2)
            {
                // If so, is it lowest or highest?
                nTypeOfTarget = GetAIInteger(TARGETING_BAB);
                nMaximum = GetAIInteger(TARGETING_BAB + MAXIMUM);
                // We then set the array up in a new temp array. 4 = BAB
                AI_TargetingArrayIntegerStore(4, ARRAY_MELEE_ENEMY);
                // We loop as AC, basically. As it is BAB, IE how much chance
                // they'll hit us (they might all hit on a 20, but it also shows
                // who are the best fighters!). Set to 5, like AC.
                nRemainingTargets = AI_TargetingArrayLimitTargets(ARRAY_MELEE_ENEMY, nTypeOfTarget, 5, nMinimum, nMaximum);
            }
            // 5. Hit Dice
            nMinimum = GetAIInteger(TARGETING_HITDICE + MINIMUM);
            if(nMinimum && nRemainingTargets >= 2)
            {
                // If so, is it lowest or highest?
                nTypeOfTarget = GetAIInteger(TARGETING_HITDICE);
                nMaximum = GetAIInteger(TARGETING_HITDICE + MAXIMUM);
                // We then set the array up in a new temp array. 5 = Hit dice
                AI_TargetingArrayIntegerStore(5, ARRAY_MELEE_ENEMY);
                // We loop as AC. Hit Dice is even easier. We set the limit to
                // a max of 4.
                nRemainingTargets = AI_TargetingArrayLimitTargets(ARRAY_MELEE_ENEMY, nTypeOfTarget, 4, nMinimum, nMaximum);
            }
            // 6. Percent HP
            nMinimum = GetAIInteger(TARGETING_HP_PERCENT + MINIMUM);
            if(nMinimum && nRemainingTargets >= 2)
            {
                // If so, is it lowest or highest?
                nTypeOfTarget = GetAIInteger(TARGETING_HP_PERCENT);
                nMaximum = GetAIInteger(TARGETING_HP_PERCENT + MAXIMUM);
                // We then set the array up in a new temp array. 6 = %
                AI_TargetingArrayIntegerStore(6, ARRAY_MELEE_ENEMY);
                // We loop as AC. Current Hit Points are easy, and are done
                // by %ages. We set the % to 15 difference max.
                nRemainingTargets = AI_TargetingArrayLimitTargets(ARRAY_MELEE_ENEMY, nTypeOfTarget, 15, nMinimum, nMaximum);
            }
            // 7. Current HP
            nMinimum = GetAIInteger(TARGETING_HP_CURRENT + MINIMUM);
            if(nMinimum && nRemainingTargets >= 2)
            {
                // If so, is it lowest or highest?
                nTypeOfTarget = GetAIInteger(TARGETING_HP_CURRENT);
                nMaximum = GetAIInteger(TARGETING_HP_CURRENT + MAXIMUM);
                // We then set the array up in a new temp array. 7 = current HP
                AI_TargetingArrayIntegerStore(7, ARRAY_MELEE_ENEMY);
                // We loop as AC. Current Hit points? Well, we set this limit to
                // Our Hit Dice * 2.
                nRemainingTargets = AI_TargetingArrayLimitTargets(ARRAY_MELEE_ENEMY, nTypeOfTarget, GlobalOurHitDice * 2, nMinimum, nMaximum);
            }
            // 8. Maximum HP
            nMinimum = GetAIInteger(TARGETING_HP_MAXIMUM + MINIMUM);
            if(nMinimum && nRemainingTargets >= 2)
            {
                // If so, is it lowest or highest?
                nTypeOfTarget = GetAIInteger(TARGETING_HP_MAXIMUM);
                nMaximum = GetAIInteger(TARGETING_HP_MAXIMUM + MAXIMUM);
                // We then set the array up in a new temp array. 8 = maximum
                AI_TargetingArrayIntegerStore(8, ARRAY_MELEE_ENEMY);
                // We loop as AC. Max hit Hit points? Well, we set this limit to
                // Our Hit Dice * 3.
                nRemainingTargets = AI_TargetingArrayLimitTargets(ARRAY_MELEE_ENEMY, nTypeOfTarget, GlobalOurHitDice * 3, nMinimum, nMaximum);
            }
            // WHEW!
            // Now we should have 1 or more chosen targets in ARRAY_MELEE_ARRAY.
            // iRemaining Targets is the array size...we mearly choose a random
            // one, or the first one if there is only one :-D

            // If only one, choose it
            if(nRemainingTargets == 1)
            {
                GlobalMeleeTarget = GetLocalObject(OBJECT_SELF, ARRAY_MELEE_ENEMY + "1");
            }
            // Check for 2+, if 0, we haven't got one to set!
            else if(nRemainingTargets >= 2)
            {
                // Else Roll dice
                nCnt = Random(nRemainingTargets) + 1;
                // Set random target
                GlobalMeleeTarget = GetLocalObject(OBJECT_SELF, ARRAY_MELEE_ENEMY + IntToString(nCnt));
            }
        }
    }
    // Else, it is oLastTarget that will be our target, if a sane target!
    else if(AI_GetTargetSanityCheck(oLastTarget))
    {
        // Only set this if oLastTarget is valid. It might not be. Thanks Chris (1.4 fix)
        GlobalMeleeTarget = oLastTarget;
    }

    // If it is a new target, reset attacking counter to 0
    if(GlobalMeleeTarget != oLastTarget)
    {
        DeleteAIInteger(AI_MELEE_TURNS_ATTACKING);
    }

/*:://////////////////////////////////////////////
    Ranged targeting

    This uses more stuff then melee targeting - for a start, range is optional!

    By default, it sets up all seen targets to the array, else all heard.
//::////////////////////////////////////////////*/

    // Do we want to change melee targets?
    oLastTarget = GetAIObject(AI_LAST_RANGED_TARGET);

    // bValid is the counter for attacking target X...
    bBreak = GetAIInteger(AI_RANGED_TURNS_ATTACKING);
    bBreak++;
    SetAIInteger(AI_RANGED_TURNS_ATTACKING, bBreak);
    // We set this to 0 if we our oLastTarget != GlobalMeleeTarget below changing.

    // Check %
    // We use the same temp reset from before, because phisical attacking
    // would be range or melee ;-)

    // - No valid override target, we have got a ranged weapon...
    if(!GetIsObjectValid(GlobalRangedTarget) && GetIsObjectValid(GetAIObject(AI_WEAPON_RANGED)) &&
    // 1. If the last target isn't a sane target...
       (!AI_GetTargetSanityCheck(oLastTarget) ||
    // 2. ...Or must pass a % roll to change (or check for new) targets...
        d100() <= GetBoundriedAIInteger(AI_RANGED_LAST_TO_NEW_TARGET_CHANCE, 20, 100) ||
    // 3. ...OR last target attacked for X rounds we limit ourselves to.
        bBreak >= nMaxTurnsAttackingX))
    {
        // 1. Set up all seen, else all heard, to the range array.
        nCnt = 1;
        nRemainingTargets = 0;
        oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_ENEMY_RANGE_SEEN + IntToString(nCnt));
        while(GetIsObjectValid(oSetUpTarget))
        {
            nRemainingTargets++;
            SetLocalObject(OBJECT_SELF, ARRAY_RANGED_ENEMY + IntToString(nRemainingTargets), oSetUpTarget);
            // Get Next seen
            nCnt++;
            oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_ENEMY_RANGE_SEEN + IntToString(nCnt));
        }
        // If we don't have any seen, used heard.
        if(!nRemainingTargets)
        {
            nCnt = 1;
            nRemainingTargets = 0;
            oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_ENEMY_RANGE_HEARD + IntToString(nCnt));
            while(GetIsObjectValid(oSetUpTarget))
            {
                nRemainingTargets++;
                SetLocalObject(OBJECT_SELF, ARRAY_RANGED_ENEMY + IntToString(nRemainingTargets), oSetUpTarget);
                // Get Next seen
                nCnt++;
                oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_ENEMY_RANGE_HEARD + IntToString(nCnt));
            }
        }
        // If not valid, set to melee target at the end

        // Do we have exactly 1 target? (nRemainingTargets == 1)
        if(nRemainingTargets == 1)
        {
            // Then we make this our target and end it.
            GlobalRangedTarget = GetLocalObject(OBJECT_SELF, ARRAY_RANGED_ENEMY + "1");
        }
        // Else we set up using range ETC, if we have more then 1.
        else if(nRemainingTargets)
        {
            // Range - they are already in range order. As it is used for
            // spells, it uses the same function.
    // Range             - Used only for ranged phisical attacks and spell attacks  (TARGETING_RANGE)
    //                      - Melee - Range is used to see what it can reach, and the MAX and MIN are taken to account
    // AC                - Used only for phisical attacks (TARGETING_AC)
    // Saving Throws     - Used only for spell attacks (TARGETING_SAVES)
    // Phisical Protections - Used for both spells and phisical attacks (TARGETING_PHISICALS)
    // Base Attack Bonus - Used for both spells and phisical attacks (TARGETING_BAB)
    // Hit Dice          - Used for both spells and phisical attacks (TARGETING_HITDICE)
    // HP Percent        - Used for both spells and phisical attacks (TARGETING_HP_PERCENT)
    // HP Current        - Used for both spells and phisical attacks (TARGETING_HP_CURRENT)
    // HP Maximum        - Used for both spells and phisical attacks (TARGETING_HP_MAXIMUM)
            // 0. Sneak attack check
            if(GetHasFeat(FEAT_SNEAK_ATTACK))
            {
                // We normally get the nearest enemy who is not attacking us, and
                // actually stop!
                AI_TargetingArrayIntegerStore(9, ARRAY_RANGED_ENEMY);

                // Get the closest who isn't attacking us.
                oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_TEMP_ARRAY + "1");
                if(GetAttackTarget(oSetUpTarget) != OBJECT_SELF)
                {
                    GlobalMeleeTarget = oSetUpTarget;
                    nRemainingTargets = FALSE;
                }
                // If we have trouble using that one, IE they are attacking us, we
                // just use normal methods.

                // Delete temp array
                AI_TargetingArrayDelete(ARRAY_TEMP_ARRAY);
            }
            nMinimum = GetAIInteger(TARGETING_RANGE + MINIMUM);
            // 1. Do we do range?
            if(nMinimum && nRemainingTargets >= 2)
            {
                // If so, is it lowest or highest?
                nTypeOfTarget = GetAIInteger(TARGETING_RANGE);
                nMaximum = GetAIInteger(TARGETING_RANGE + MAXIMUM);

                // We then set the array up in a new temp array.
                AI_TargetingArrayDistanceStore(ARRAY_RANGED_ENEMY, ARRAY_TEMP_ARRAY);
                // We loop range. Maximum one can be from another when got to the
                // minimum is 5.0 M
                nRemainingTargets = AI_TargetingArrayLimitTargetsFloat(ARRAY_RANGED_ENEMY, nTypeOfTarget, 5.0, nMinimum, nMaximum);
            }
            // 2. AC
            nMinimum = GetAIInteger(TARGETING_AC + MINIMUM);
            // Do we do AC? And over one target...
            if(nMinimum && nRemainingTargets >= 2)
            {
                // If so, is it lowest or highest?
                nTypeOfTarget = GetAIInteger(TARGETING_AC);
                nMaximum = GetAIInteger(TARGETING_AC + MAXIMUM);

                // We then set the array up in a new temp array. 1 = AC.
                AI_TargetingArrayIntegerStore(1, ARRAY_RANGED_ENEMY);

                // We loop through all the targets in the temp array (we also
                // delete the temp array targets!) and set what ones we want to target
                // based on AC.
                // - Continue until nMinimum is reached.
                // - Never go over nMaximum
                // - After nMinimum we make sure the AC differences is not a major one of
                // over 5.
                nRemainingTargets = AI_TargetingArrayLimitTargets(ARRAY_RANGED_ENEMY, nTypeOfTarget, 5, nMinimum, nMaximum);
            }
            // Most others are similar (and all integer values so easy to check)
            // 3. Phisical protections.
            nMinimum = GetAIInteger(TARGETING_PHISICALS + MINIMUM);
            if(nMinimum && nRemainingTargets >= 2)
            {
                // If so, is it lowest or highest?
                nTypeOfTarget = GetAIInteger(TARGETING_PHISICALS);
                nMaximum = GetAIInteger(TARGETING_PHISICALS + MAXIMUM);
                // We then set the array up in a new temp array. 3 = phisicals.
                AI_TargetingArrayIntegerStore(3, ARRAY_RANGED_ENEMY);
                // We loop as AC, basically. As it is stored based on the amount
                // of DR offered, limit is 0, not 6. Can't be any different.
                nRemainingTargets = AI_TargetingArrayLimitTargets(ARRAY_RANGED_ENEMY, nTypeOfTarget, 0, nMinimum, nMaximum);
            }
            // 4. BAB
            nMinimum = GetAIInteger(TARGETING_BAB + MINIMUM);
            if(nMinimum && nRemainingTargets >= 2)
            {
                // If so, is it lowest or highest?
                nTypeOfTarget = GetAIInteger(TARGETING_BAB);
                nMaximum = GetAIInteger(TARGETING_BAB + MAXIMUM);
                // We then set the array up in a new temp array. 4 = BAB
                AI_TargetingArrayIntegerStore(4, ARRAY_RANGED_ENEMY);
                // We loop as AC, basically. As it is BAB, IE how much chance
                // they'll hit us (they might all hit on a 20, but it also shows
                // who are the best fighters!). Set to 5, like AC.
                nRemainingTargets = AI_TargetingArrayLimitTargets(ARRAY_RANGED_ENEMY, nTypeOfTarget, 5, nMinimum, nMaximum);
            }
            // 5. Hit Dice
            nMinimum = GetAIInteger(TARGETING_HITDICE + MINIMUM);
            if(nMinimum && nRemainingTargets >= 2)
            {
                // If so, is it lowest or highest?
                nTypeOfTarget = GetAIInteger(TARGETING_HITDICE);
                nMaximum = GetAIInteger(TARGETING_HITDICE + MAXIMUM);
                // We then set the array up in a new temp array. 5 = Hit dice
                AI_TargetingArrayIntegerStore(5, ARRAY_RANGED_ENEMY);
                // We loop as AC. Hit Dice is even easier. We set the limit to
                // a max of 4.
                nRemainingTargets = AI_TargetingArrayLimitTargets(ARRAY_RANGED_ENEMY, nTypeOfTarget, 4, nMinimum, nMaximum);
            }
            // 6. Percent HP
            nMinimum = GetAIInteger(TARGETING_HP_PERCENT + MINIMUM);
            if(nMinimum && nRemainingTargets >= 2)
            {
                // If so, is it lowest or highest?
                nTypeOfTarget = GetAIInteger(TARGETING_HP_PERCENT);
                nMaximum = GetAIInteger(TARGETING_HP_PERCENT + MAXIMUM);
                // We then set the array up in a new temp array. 5 = Hit dice
                AI_TargetingArrayIntegerStore(6, ARRAY_RANGED_ENEMY);
                // We loop as AC. Current Hit Points are easy, and are done
                // by %ages. We set the % to 15 difference max.
                nRemainingTargets = AI_TargetingArrayLimitTargets(ARRAY_RANGED_ENEMY, nTypeOfTarget, 15, nMinimum, nMaximum);
            }
            // 7. Current HP
            nMinimum = GetAIInteger(TARGETING_HP_CURRENT + MINIMUM);
            if(nMinimum && nRemainingTargets >= 2)
            {
                // If so, is it lowest or highest?
                nTypeOfTarget = GetAIInteger(TARGETING_HP_CURRENT);
                nMaximum = GetAIInteger(TARGETING_HP_CURRENT + MAXIMUM);
                // We then set the array up in a new temp array. 5 = Hit dice
                AI_TargetingArrayIntegerStore(7, ARRAY_RANGED_ENEMY);
                // We loop as AC. Current Hit points? Well, we set this limit to
                // Our Hit Dice * 2.
                nRemainingTargets = AI_TargetingArrayLimitTargets(ARRAY_RANGED_ENEMY, nTypeOfTarget, GlobalOurHitDice * 2, nMinimum, nMaximum);
            }
            // 8. Maximum HP
            nMinimum = GetAIInteger(TARGETING_HP_MAXIMUM + MINIMUM);
            if(nMinimum && nRemainingTargets >= 2)
            {
                // If so, is it lowest or highest?
                nTypeOfTarget = GetAIInteger(TARGETING_HP_MAXIMUM);
                nMaximum = GetAIInteger(TARGETING_HP_MAXIMUM + MAXIMUM);
                // We then set the array up in a new temp array. 5 = Hit dice
                AI_TargetingArrayIntegerStore(8, ARRAY_RANGED_ENEMY);
                // We loop as AC. Max hit Hit points? Well, we set this limit to
                // Our Hit Dice * 3.
                nRemainingTargets = AI_TargetingArrayLimitTargets(ARRAY_RANGED_ENEMY, nTypeOfTarget, GlobalOurHitDice * 3, nMinimum, nMaximum);
            }
            // End narrowing down on ARRAY_RANGED_ENEMY

            // If only one, choose it
            if(nRemainingTargets == 1)
            {
                GlobalRangedTarget = GetLocalObject(OBJECT_SELF, ARRAY_RANGED_ENEMY + "1");
            }
            // Check for 2+, if 0, we haven't got one to set!
            else if(nRemainingTargets >= 2)
            {
                // Else Roll dice
                nCnt = Random(nRemainingTargets) + 1;
                // Set random target
                GlobalRangedTarget = GetLocalObject(OBJECT_SELF, ARRAY_RANGED_ENEMY + IntToString(nCnt));
            }
        }
    }
    // Else, it is oLastTarget that will be our target
    else if(AI_GetTargetSanityCheck(oLastTarget))
    {
        // Only set this if oLastTarget is valid. It might not be. Thanks Chris (1.4 fix)
        GlobalRangedTarget = oLastTarget;
    }

    // If not valid, set to melee target (Can happen if we have no ranged weapon)
    if(!AI_GetTargetSanityCheck(GlobalRangedTarget))
    {
        GlobalRangedTarget = GlobalMeleeTarget;
    }

    // If it is a new target, reset attacking counter to 0
    if(GlobalRangedTarget != oLastTarget)
    {
        DeleteAIInteger(AI_RANGED_TURNS_ATTACKING);
    }

/*:://////////////////////////////////////////////
    Spell targeting

    Spell targeting is similar to ranged targeting. It is only reset if
    iResetTargets is true.

    We never actually set a target if they are totally immune to our spells, uses
    AI_SpellResistanceImmune for the checks.
//::////////////////////////////////////////////*/

    // Do we want to change melee targets?
    oLastTarget = GetAIObject(AI_LAST_SPELL_TARGET);

    // bValid is the counter for attacking target X...
    bBreak = GetAIInteger(AI_SPELL_TURNS_ATTACKING);
    bBreak++;
    SetAIInteger(AI_SPELL_TURNS_ATTACKING, bBreak);
    // We set this to 0 if we our oLastTarget != GlobalMeleeTarget below changing.

    // - No valid override target
    if(!GetIsObjectValid(GlobalRangedTarget) &&
    // 1a. If the last target isn't a sane target...
       (!AI_GetTargetSanityCheck(oLastTarget) ||
    // 1b. The last target has an immune level of 9 (we reset targets each possible time
    //     then)
        GetLocalInt(oLastTarget, AI_SPELL_IMMUNE_LEVEL) >= 9 ||
    // 2. ...Or must pass a % roll to change (or check for new) targets...
        d100() <= GetBoundriedAIInteger(AI_SPELL_LAST_TO_NEW_TARGET_CHANCE, 20, 100) ||
    // 3. ...OR last target attacked for X rounds we limit ourselves to.
        bBreak >= nMaxTurnsAttackingX))
    {
        // 1. Set up all seen, else all heard, to the range array.
        nCnt = 1;
        nRemainingTargets = 0;
        oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_ENEMY_RANGE_SEEN + IntToString(nCnt));
        while(GetIsObjectValid(oSetUpTarget))
        {
            // Totally immune to our spells - ignore!
            if(!AI_SpellResistanceImmune(oSetUpTarget) &&
                GetLocalInt(GlobalSpellTarget, AI_SPELL_IMMUNE_LEVEL) < 9)
            {
                nRemainingTargets++;
                SetLocalObject(OBJECT_SELF, ARRAY_SPELL_ENEMY + IntToString(nRemainingTargets), oSetUpTarget);
            }
            // Get Next seen
            nCnt++;
            oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_ENEMY_RANGE_SEEN + IntToString(nCnt));
        }
        // If we don't have any seen, used heard.
        if(!nRemainingTargets)
        {
            nCnt = 1;
            nRemainingTargets = 0;
            oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_ENEMY_RANGE_HEARD + IntToString(nCnt));
            while(GetIsObjectValid(oSetUpTarget))
            {
                // Totally immune to our spells - ignore!
                if(!AI_SpellResistanceImmune(oSetUpTarget) &&
                    GetLocalInt(GlobalSpellTarget, AI_SPELL_IMMUNE_LEVEL) < 9)
                {
                    nRemainingTargets++;
                    SetLocalObject(OBJECT_SELF, ARRAY_SPELL_ENEMY + IntToString(nRemainingTargets), oSetUpTarget);
                }
                // Get Next seen
                nCnt++;
                oSetUpTarget = GetLocalObject(OBJECT_SELF, ARRAY_ENEMY_RANGE_HEARD + IntToString(nCnt));
            }
        }
        // If not valid, its invalid! As this is the last thing, return -1.
        // This CAN happen!
        // - If we have all targets naturally immune to spells via. spell reistance.
        //   we can set GlobalNormalSpellsNoEffectLevel to 10, below, to stop all spells
        // - After this lot of things, we do check for validness and set to melee target if no one else

        // MELEE Targets get checked for LOS, so they should always move
        // to people we should  attack ABOVE
        // Do we have exactly 1 target? (nRemainingTargets == 1)
        if(nRemainingTargets == 1)
        {
            // Then we make this our target and end it.
            GlobalSpellTarget = GetLocalObject(OBJECT_SELF, ARRAY_SPELL_ENEMY + "1");
        }
        // Else we set up using range ETC, if we have more then 1.
        else if(nRemainingTargets > 1)
        {
            // ARRAY_SPELL_ENEMY
            // Similar to Ranged attacking for range setting :-D

            // Range - they are already in range order. As it is used for
            // spells, it uses the same function.

    // PC, Mantals.
    // Range             - Used only for ranged phisical attacks and spell attacks  (TARGETING_RANGE)
    //                      - Melee - Range is used to see what it can reach, and the MAX and MIN are taken to account
    // AC                - Used only for phisical attacks (TARGETING_AC)
    // Saving Throws     - Used only for spell attacks (TARGETING_SAVES)
    // Phisical Protections - Used for both spells and phisical attacks (TARGETING_PHISICALS)
    // Base Attack Bonus - Used for both spells and phisical attacks (TARGETING_BAB)
    // Hit Dice          - Used for both spells and phisical attacks (TARGETING_HITDICE)
    // HP Percent        - Used for both spells and phisical attacks (TARGETING_HP_PERCENT)
    // HP Current        - Used for both spells and phisical attacks (TARGETING_HP_CURRENT)
    // HP Maximum        - Used for both spells and phisical attacks (TARGETING_HP_MAXIMUM)

            // -1. Is it a PC...
            // - Type 10
            nMinimum = GetAIInteger(TARGETING_ISPC + MINIMUM);
            if(nMinimum && nRemainingTargets >= 2)
            {
                // If so, is it lowest or highest?
                nTypeOfTarget = GetAIInteger(TARGETING_ISPC);
                nMaximum = GetAIInteger(TARGETING_ISPC + MAXIMUM);
                // We then set the array up in a new temp array. 10 = PC.
                AI_TargetingArrayIntegerStore(10, ARRAY_SPELL_ENEMY);
                // We loop and set up, with no difference in PC status, IE we should always choose those who are PCs.
                nRemainingTargets = AI_TargetingArrayLimitTargets(ARRAY_SPELL_ENEMY, nTypeOfTarget, 0, nMinimum, nMaximum);
            }
            // 0. Mantals
            // - Type 10
            nMinimum = GetAIInteger(TARGETING_ISPC + MINIMUM);
            if(nMinimum && nRemainingTargets >= 2)
            {
                // If so, is it lowest or highest?
                nTypeOfTarget = GetAIInteger(TARGETING_ISPC);
                nMaximum = GetAIInteger(TARGETING_ISPC + MAXIMUM);
                // We then set the array up in a new temp array. 10 = PC.
                AI_TargetingArrayIntegerStore(10, ARRAY_SPELL_ENEMY);
                // We loop and set up, with no difference in PC status, IE we should always choose those who are PCs.
                nRemainingTargets = AI_TargetingArrayLimitTargets(ARRAY_SPELL_ENEMY, nTypeOfTarget, 0, nMinimum, nMaximum);
            }
            nMinimum = GetAIInteger(TARGETING_RANGE + MINIMUM);
            // 1. Do we do range?
            if(nMinimum && nRemainingTargets >= 2)
            {
                // If so, is it lowest or highest?
                nTypeOfTarget = GetAIInteger(TARGETING_RANGE);
                nMaximum = GetAIInteger(TARGETING_RANGE + MAXIMUM);

                // We then set the array up in a new temp array
                AI_TargetingArrayDistanceStore(ARRAY_SPELL_ENEMY, ARRAY_TEMP_ARRAY);
                // We loop range. Maximum one can be from another when got to the
                // minimum is 5.0 M
                nRemainingTargets = AI_TargetingArrayLimitTargetsFloat(ARRAY_SPELL_ENEMY, nTypeOfTarget, 5.0, nMinimum, nMaximum);
            }
            // 2. Saving Throws
            nMinimum = GetAIInteger(TARGETING_SAVES + MINIMUM);
            // Do we do saves? And over one target...
            if(nMinimum && nRemainingTargets >= 2)
            {
                // If so, is it lowest or highest?
                nTypeOfTarget = GetAIInteger(TARGETING_SAVES);
                nMaximum = GetAIInteger(TARGETING_SAVES + MAXIMUM);

                // We then set the array up in a new temp array. 2 = total saves.
                AI_TargetingArrayIntegerStore(2, ARRAY_SPELL_ENEMY);

                // Saves are basically a spells' AC, or at least may hamper
                // spells' power.
                // - difference of 4
                nRemainingTargets = AI_TargetingArrayLimitTargets(ARRAY_SPELL_ENEMY, nTypeOfTarget, 4, nMinimum, nMaximum);
            }
            // Most others are similar (and all integer values so easy to check)
            // 3. Phisical protections.
            nMinimum = GetAIInteger(TARGETING_PHISICALS + MINIMUM);
            if(nMinimum && nRemainingTargets >= 2)
            {
                // If so, is it lowest or highest?
                nTypeOfTarget = GetAIInteger(TARGETING_PHISICALS);
                nMaximum = GetAIInteger(TARGETING_PHISICALS + MAXIMUM);
                // We then set the array up in a new temp array. 3 = phisicals.
                AI_TargetingArrayIntegerStore(3, ARRAY_SPELL_ENEMY);
                // We loop as AC, basically. As it is stored based on the amount
                // of DR offered, limit is 0, not 6. Can't be any different.
                nRemainingTargets = AI_TargetingArrayLimitTargets(ARRAY_SPELL_ENEMY, nTypeOfTarget, 0, nMinimum, nMaximum);
            }
            // 4. BAB
            nMinimum = GetAIInteger(TARGETING_BAB + MINIMUM);
            if(nMinimum && nRemainingTargets >= 2)
            {
                // If so, is it lowest or highest?
                nTypeOfTarget = GetAIInteger(TARGETING_BAB);
                nMaximum = GetAIInteger(TARGETING_BAB + MAXIMUM);
                // We then set the array up in a new temp array. 4 = BAB
                AI_TargetingArrayIntegerStore(4, ARRAY_SPELL_ENEMY);
                // We loop as AC, basically. As it is BAB, IE how much chance
                // they'll hit us (they might all hit on a 20, but it also shows
                // who are the best fighters!). Set to 5, like AC.
                nRemainingTargets = AI_TargetingArrayLimitTargets(ARRAY_SPELL_ENEMY, nTypeOfTarget, 5, nMinimum, nMaximum);
            }
            // 5. Hit Dice
            nMinimum = GetAIInteger(TARGETING_HITDICE + MINIMUM);
            if(nMinimum && nRemainingTargets >= 2)
            {
                // If so, is it lowest or highest?
                nTypeOfTarget = GetAIInteger(TARGETING_HITDICE);
                nMaximum = GetAIInteger(TARGETING_HITDICE + MAXIMUM);
                // We then set the array up in a new temp array. 5 = Hit dice
                AI_TargetingArrayIntegerStore(5, ARRAY_SPELL_ENEMY);
                // We loop as AC. Hit Dice is even easier. We set the limit to
                // a max of 4.
                nRemainingTargets = AI_TargetingArrayLimitTargets(ARRAY_SPELL_ENEMY, nTypeOfTarget, 4, nMinimum, nMaximum);
            }
            // 6. Percent HP
            nMinimum = GetAIInteger(TARGETING_HP_PERCENT + MINIMUM);
            if(nMinimum && nRemainingTargets >= 2)
            {
                // If so, is it lowest or highest?
                nTypeOfTarget = GetAIInteger(TARGETING_HP_PERCENT);
                nMaximum = GetAIInteger(TARGETING_HP_PERCENT + MAXIMUM);
                // We then set the array up in a new temp array. 6 = % HP
                AI_TargetingArrayIntegerStore(6, ARRAY_SPELL_ENEMY);
                // We loop as AC. Current Hit Points are easy, and are done
                // by %ages. We set the % to 15 difference max.
                nRemainingTargets = AI_TargetingArrayLimitTargets(ARRAY_SPELL_ENEMY, nTypeOfTarget, 15, nMinimum, nMaximum);
            }
            // 7. Current HP
            nMinimum = GetAIInteger(TARGETING_HP_CURRENT + MINIMUM);
            if(nMinimum && nRemainingTargets >= 2)
            {
                // If so, is it lowest or highest?
                nTypeOfTarget = GetAIInteger(TARGETING_HP_CURRENT);
                nMaximum = GetAIInteger(TARGETING_HP_CURRENT + MAXIMUM);
                // We then set the array up in a new temp array. 7 = Current
                AI_TargetingArrayIntegerStore(7, ARRAY_SPELL_ENEMY);
                // We loop as AC. Current Hit points? Well, we set this limit to
                // Our Hit Dice * 2.
                nRemainingTargets = AI_TargetingArrayLimitTargets(ARRAY_SPELL_ENEMY, nTypeOfTarget, GlobalOurHitDice * 2, nMinimum, nMaximum);
            }
            // 8. Maximum HP
            nMinimum = GetAIInteger(TARGETING_HP_MAXIMUM + MINIMUM);
            if(nMinimum && nRemainingTargets >= 2)
            {
                // If so, is it lowest or highest?
                nTypeOfTarget = GetAIInteger(TARGETING_HP_MAXIMUM);
                nMaximum = GetAIInteger(TARGETING_HP_MAXIMUM + MAXIMUM);
                // We then set the array up in a new temp array. 8 = Maximum
                AI_TargetingArrayIntegerStore(8, ARRAY_SPELL_ENEMY);
                // We loop as AC. Max hit Hit points? Well, we set this limit to
                // Our Hit Dice * 3.
                nRemainingTargets = AI_TargetingArrayLimitTargets(ARRAY_SPELL_ENEMY, nTypeOfTarget, GlobalOurHitDice * 3, nMinimum, nMaximum);
            }
            // End narrowing down on ARRAY_SPELL_ENEMY

            // If only one, choose it
            if(nRemainingTargets == 1)
            {
                GlobalSpellTarget = GetLocalObject(OBJECT_SELF, ARRAY_SPELL_ENEMY + "1");
            }
            // Check for 2+, if 0, we haven't got one to set!
            else if(nRemainingTargets >= 2)
            {
                // Else Roll dice
                nCnt = Random(nRemainingTargets - 1) + 1;
                // Set random target
                GlobalSpellTarget = GetLocalObject(OBJECT_SELF, ARRAY_SPELL_ENEMY + IntToString(nCnt));
            }
        }
    }
    // Else, it is oLastTarget that will be our target
    else if(AI_GetTargetSanityCheck(oLastTarget))
    {
        // Only set this if oLastTarget is valid. It might not be. Thanks Chris (1.4 fix)
        GlobalSpellTarget = oLastTarget;
    }

    // If not (sane) valid, set to melee target
    if(!AI_GetTargetSanityCheck(GlobalSpellTarget))
    {
        GlobalSpellTarget = GlobalMeleeTarget;
    }

    // If it is a new target, reset attacking counter to 0
    if(GlobalSpellTarget != oLastTarget)
    {
        DeleteAIInteger(AI_SPELL_TURNS_ATTACKING);
    }

    // Set the final objects we chose
    SetAIObject(AI_LAST_MELEE_TARGET, GlobalMeleeTarget);
    SetAIObject(AI_LAST_SPELL_TARGET, GlobalSpellTarget);
    SetAIObject(AI_LAST_RANGED_TARGET, GlobalRangedTarget);

    // Set Global* things for melee target
    GlobalRangeToMeleeTarget = GetDistanceToObject(GlobalMeleeTarget);
    GlobalMeleeTargetAC = GetAC(GlobalMeleeTarget);
    // Generic check.
    // - Set to TRUE, we should always have GlobalMeleeTarget as valid
    GlobalAnyValidTargetObject = TRUE;//GetIsObjectValid(GlobalMeleeTarget);

    // Sort immunities
    AI_SortSpellImmunities();

    // Set Global* things for spell target
    //GlobalNormalSpellsNoEffectLevel
    // - The level of spells which are not affected - IE, if set to 3, then
    //   spell levels 0, 1, 2, 3 will NOT be cast. Abilites are still used!

    // REMEMBER:
    // - We still can cast summons, and friendly spells!
    // - AOE spells may still affect someone in range
    // - Breaches can breach natural spell resistance.

    // If they are spell resistance immune, we do not cast any normal spells
    // against them, except if we are a mage class
    // * We only obviously get a spell resistance immune person if we
    //   have no one who is not immune via. SR. If they are immune, we just set
    //   to not use spells.
    if(AI_SpellResistanceImmune(GlobalSpellTarget))
    {
        // Note: We set the breach level to max, 5, so that we use breaches
        // to bring down the SR of an enemy!
        // * This 5 number is checked just below, for when GlobalDispelTarget is set.
        // To do this, we will breach this target
        GlobalDispelTargetHighestBreach = 5;

        // Class checks. If not a mage caster, we will not use spells
        if(GlobalOurChosenClass != CLASS_TYPE_WIZARD &&
           GlobalOurChosenClass != CLASS_TYPE_SORCERER &&
           GlobalOurChosenClass != CLASS_TYPE_FEY)
        {
            // 10 means we do not want to cast any normal spells
            GlobalNormalSpellsNoEffectLevel = 10;
        }
        else
        {
            // We will set this to 5, level 5 spells and under stopped, if
            // we are a mage. This is done because SR isn't absolute, and also
            // that some spells might get through...
            GlobalNormalSpellsNoEffectLevel = 5;
        }
    }

    // Set the value to 10 if we have a 90% or greater chance of failing spells
    // due to any armor, or any spell failure stuff.
    if(GetArcaneSpellFailure(OBJECT_SELF) >= 90 &&
       GlobalNormalSpellsNoEffectLevel < 9)
    {
        // Always set to 10 if it is an effect
        // * Never cast normal spells (monster abilties are fine!)
        if(AI_GetAIHaveEffect(GlobalEffectSpellFailure))
        {
            GlobalNormalSpellsNoEffectLevel = 10;
        }
        // - If we have auto-still, Leave it as it is if we can still all spells automatically
        else if(!GetHasFeat(FEAT_EPIC_AUTOMATIC_STILL_SPELL_3) &&
                !GetHasFeat(FEAT_EPIC_AUTOMATIC_STILL_SPELL_2) &&
                !GetHasFeat(FEAT_EPIC_AUTOMATIC_STILL_SPELL_1))
        {
            // Else do not cast as in armor
            GlobalNormalSpellsNoEffectLevel = 10;
        }
    }

    // We may set GlobalNormalSpellsNoEffectLevel to 1-4 if the enemy has some
    // extra spell immunities.
    if(GlobalNormalSpellsNoEffectLevel < 9  &&
       // Global setting needed
      (GlobalIntelligence >= 9 ||
       GetSpawnInCondition(AI_FLAG_COMBAT_IMPROVED_SPECIFIC_SPELL_IMMUNITY, AI_COMBAT_MASTER)))
    {
        // This check now includes natural effect level
        nValue = AI_GetSpellLevelEffect(GlobalSpellTarget);
        if(GlobalNormalSpellsNoEffectLevel < nValue)
        {
            GlobalNormalSpellsNoEffectLevel = nValue;
        }
    }

    // Important variables regarding GlobalSpellTarget
    GlobalSpellTargetWill = GetWillSavingThrow(GlobalSpellTarget);
    GlobalSpellTargetFort = GetFortitudeSavingThrow(GlobalSpellTarget);
    GlobalSpellTargetReflex = GetReflexSavingThrow(GlobalSpellTarget);
    GlobalSpellTargetHitDice = GetHitDice(GlobalSpellTarget);
    GlobalSpellTargetCurrentHitPoints = GetCurrentHitPoints(GlobalSpellTarget);
    // This is one of the most important.
    GlobalSeenSpell = GetObjectSeen(GlobalSpellTarget);
    GlobalSpellTargetRace = GetRacialType(GlobalSpellTarget);
    // Range
    GlobalSpellTargetRange = GetDistanceToObject(GlobalSpellTarget);

    // Set dispel target.
    // 1.4 - if GlobalDispelTargetHighestBreach is already 5, we want to
    // target the SR immune-to-spells person we are targeting.
    if(GlobalDispelTargetHighestBreach == 5)
    {
        // Obviously valid. We only use SR Spell Breach reducing spells, unless
        // they have Spell Resistance cast on them
        GlobalDispelTarget = GlobalSpellTarget;

        // If they have spell resistance, we will attempt to dispel it normally,
        // because it gives a massive boost to SR (11 + Caster level) and should
        // make the target targetable for spells like normal.
        if(GetHasSpellEffect(SPELL_SPELL_RESISTANCE, GlobalDispelTarget))
        {
            GlobalDispelTargetHighestDispel = 5;
        }
    }
    else
    {
        // Should dispel something normally.

        // * 1.4 - This now checks for if they uncommandable etc.
        if(GetSpawnInCondition(AI_FLAG_COMBAT_DISPEL_MAGES_MORE, AI_COMBAT_MASTER))
        {
            // Sorcerors, to mages, to clerics, to druids.
            GlobalDispelTarget = GetNearestCreature(CREATURE_TYPE_CLASS, CLASS_TYPE_SORCERER, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);
            // Checks for each: If the target is insane to attack, or uncommandable, ignore
            if(!AI_GetTargetSanityCheck(GlobalDispelTarget) ||
                AI_GetAIHaveEffect(GlobalEffectUncommandable, GlobalDispelTarget))
            {
                GlobalDispelTarget = GetNearestCreature(CREATURE_TYPE_CLASS, CLASS_TYPE_WIZARD, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);
                if(!AI_GetTargetSanityCheck(GlobalDispelTarget) ||
                    AI_GetAIHaveEffect(GlobalEffectUncommandable, GlobalDispelTarget))
                {
                    GlobalDispelTarget = GetNearestCreature(CREATURE_TYPE_CLASS, CLASS_TYPE_CLERIC, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);
                    if(!AI_GetTargetSanityCheck(GlobalDispelTarget) ||
                        AI_GetAIHaveEffect(GlobalEffectUncommandable, GlobalDispelTarget))
                    {
                        GlobalDispelTarget = GetNearestCreature(CREATURE_TYPE_CLASS, CLASS_TYPE_DRUID, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY);
                    }
                }
            }
            // None valid? set to spell target. Even fighters can use potions!
            if(!AI_GetTargetSanityCheck(GlobalDispelTarget) ||
                AI_GetAIHaveEffect(GlobalEffectUncommandable, GlobalDispelTarget))
            {
                GlobalDispelTarget = GlobalSpellTarget;
            }
        }
        else
        {
            // Default to spell target if we don't target wizard classes specifically
            GlobalDispelTarget = GlobalSpellTarget;
        }
        // If it *is* a good choice, we then set up dispelable enchantments.
        // If it isn't, we don't, and thusly the global variable for dispel level is
        // never set.
        // * Already done sanity check
        if(GetIsObjectValid(GlobalDispelTarget))
        {
            // Set enchantments
            AI_SetDispelableEnchantments();
        }
    }
    // Delete everything
    AI_TargetingArrayDelete(ARRAY_TEMP_ENEMIES);
    AI_TargetingArrayDelete(ARRAY_TEMP_ALLIES);
    AI_TargetingArrayDelete(ARRAY_TEMP_ARRAY);
    AI_TargetingArrayDelete(ARRAY_MELEE_ENEMY);
    AI_TargetingArrayDelete(ARRAY_RANGED_ENEMY);
    AI_TargetingArrayDelete(ARRAY_SPELL_ENEMY);

    DebugActionSpeak("*** TARGETING. Input Backup: " + GetName(oInputBackUpToAttack) +
     "| MELEE: " + GetName(GlobalMeleeTarget) + "| M.VALID: " + IntToString(AI_GetTargetSanityCheck(GlobalMeleeTarget)) + "| M.SEEN: " + IntToString(GetObjectSeen(GlobalMeleeTarget)) + "| M.HEARD: " + IntToString(GetObjectHeard(GlobalMeleeTarget)) +
     "| RANGED: " + GetName(GlobalRangedTarget) + "| R.VALID: " + IntToString(AI_GetTargetSanityCheck(GlobalRangedTarget)) + "| R.SEEN: " + IntToString(GetObjectSeen(GlobalRangedTarget)) + "| R.HEARD: " + IntToString(GetObjectHeard(GlobalRangedTarget)) +
     "| SPELL: " + GetName(GlobalSpellTarget) + "| S.VALID: " + IntToString(AI_GetTargetSanityCheck(GlobalSpellTarget)) + "| S.SEEN: " + IntToString(GetObjectSeen(GlobalSpellTarget)) + "| S.HEARD: " + IntToString(GetObjectHeard(GlobalSpellTarget)) +
     "| NEAR HEARD: " + GetName(GlobalNearestEnemyHeard) + "| VALID: " + IntToString(AI_GetTargetSanityCheck(GlobalNearestEnemyHeard)) + "| VALID2 " + IntToString(GlobalValidNearestHeardEnemy) +
     "| NEAR SEEN: " + GetName(GlobalNearestEnemySeen) + "| VALID: " + IntToString(AI_GetTargetSanityCheck(GlobalNearestEnemySeen))  + "| VALID2 " + IntToString(GlobalValidNearestSeenEnemy));

    // FALSE lets us continue with the script.
    // - GlobalAnyValidTargetObject is set to TRUE if we want to attack anything.
    return FALSE;
}// END ALL TARGETING


/*::///////////////////////////////////////////////
//:: Name AttemptHostileSkills
//::///////////////////////////////////////////////
 This will use empathy, taunt, and if set, pickpocketing. Most are random, and
 checks are made.Heal is done in healing functions.Done against best melee target,
 or closest seen/heard.
//::///////////////////////////////////////////////
//:: Created By: Jasperre
//::////////////////////////////////////////////*/
// Uses iSkill on GlobalMeleeTarget
// - Fired from AI_AttemptHostileSkills.
void AI_ActionUseSkillOnMeleeTarget(int iSkill)
{
    // 42: "[DCR:Skill] Using agressive skill (+Attack). [Skill] " + IntToString(iSkill) + " [Enemy]" + GetName(GlobalMeleeTarget)
    DebugActionSpeakByInt(42, GlobalMeleeTarget, iSkill);
    // We turn off hiding/searching
    AI_ActionTurnOffHiding();
    // Simple most damaging
    // - Equip shield first
    AI_EquipBestShield();
    ActionEquipMostDamagingMelee(GlobalMeleeTarget);
    ActionUseSkill(iSkill, GlobalMeleeTarget);
    ActionWait(2.0);
    ActionAttack(GlobalMeleeTarget);
}
int AI_AttemptHostileSkills()
{
    if(GlobalRangeToMeleeTarget < 4.0 &&
      !GetSpawnInCondition(AI_FLAG_COMBAT_ARCHER_ALWAYS_USE_BOW, AI_COMBAT_MASTER) &&
      !SRA)// Spell ranged attacking = AI_FLAG_COMBAT_LONGER_RANGED_SPELLS_FIRST
    {
        // Handles it better like this...
        int iEmpathyDC, iRace;
        // Either: Not turned off, and intelligence >= 3, OR forced, and has it.
        if((!GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_PICKPOCKETING, AI_OTHER_COMBAT_MASTER) &&
             GlobalIntelligence >= 3) ||
             GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_FORCE_PICKPOCKETING, AI_OTHER_COMBAT_MASTER))
        {
            SpeakString("Seting for NO: " + IntToString(GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_PICKPOCKETING, AI_OTHER_COMBAT_MASTER)) + " YES: " + IntToString(GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_FORCE_PICKPOCKETING, AI_OTHER_COMBAT_MASTER)));
            // Need appropriate level of skill, checked On Spawn, or overriden...
            AI_ActionUseSkillOnMeleeTarget(SKILL_PICK_POCKET);
            return TRUE;
        }
        // If we have 50% in taunt (a decent amount), and concentration ETC are OK...do it!
        if(!GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_TAUNTING, AI_OTHER_COMBAT_MASTER) &&
           !GetLocalTimer(AI_TIMER_TAUNT))
        {
            if(GlobalIntelligence >= 2 ||
               GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_FORCE_TAUNTING, AI_OTHER_COMBAT_MASTER))
            {
                // Random determine if we use it...
                if(GetSkillRank(SKILL_TAUNT) + Random(10) >=
                   GetSkillRank(SKILL_CONCENTRATION, GlobalMeleeTarget) + Random(10))
                {
                    // If randomly used, we set a timer for longer, and attack with it.
                    SetLocalTimer(AI_TIMER_TAUNT, 24.0);
                    // * Don't speak when silenced or deaf, 1.4 change.
                    if(!AI_GetAIHaveEffect(GlobalEffectDeaf) && !AI_GetAIHaveEffect(GlobalEffectSilenced))
                    {
                        SpeakArrayString(AI_TALK_ON_TAUNT);
                    }
                    AI_ActionUseSkillOnMeleeTarget(SKILL_TAUNT);
                    return TRUE;
                }
                else // 2 rounds until next check...
                {
                    SetLocalTimer(AI_TIMER_TAUNT, 12.0);
                }
            }
        }
        // Animal empathy. Int 3
        if(!GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_EMPATHY, AI_OTHER_COMBAT_MASTER) &&
           !GetLocalTimer(AI_TIMER_EMPATHY))
        {
            if(GlobalIntelligence >= 3 ||
               GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_FORCE_EMPATHY, AI_OTHER_COMBAT_MASTER))
            {
                iEmpathyDC = 20;
                iRace = GetRacialType(GlobalMeleeTarget);
                // we add 4 (to make DC 24 + HD) if a special animal. R_T_ANIMAL is DC 20
                if(iRace == RACIAL_TYPE_BEAST || iRace == RACIAL_TYPE_MAGICAL_BEAST)
                {
                    iEmpathyDC += 4;
                }
                else if(iRace != RACIAL_TYPE_ANIMAL)
                {
                    // Else, if we are not a beast, magical beast, nor animal,
                    // we don't use it!
                    SetLocalTimer(AI_TIMER_EMPATHY, 18.0);
                    // - Last skill we can use, so just return FALSE.
                    return FALSE;
                }
                // We check our skill against it...
                if((GetSkillRank(SKILL_ANIMAL_EMPATHY) + 10) >= (GetHitDice(GlobalMeleeTarget) + 20))
                {
                    // If randomly used, we set a timer for longer, and attack with it.
                    SetLocalTimer(AI_TIMER_EMPATHY, 24.0);
                    AI_ActionUseSkillOnMeleeTarget(SKILL_ANIMAL_EMPATHY);
                    return TRUE;
                }
                else // 2 rounds until next check...
                {
                    SetLocalTimer(AI_TIMER_EMPATHY, 12.0);
                }
            }
        }
    }
    return FALSE;
}
/*::///////////////////////////////////////////////
//:: Name CastCombatHostileSpells
//::///////////////////////////////////////////////
    This will cast all buffs needed, or wanted, before actual combat.
    EG bulls strength for HTH, Cats grace for ranged and so on. Rages
    here, else it may run out if we use spells, and other lower spells as well.
//::///////////////////////////////////////////////
//:: Created By: Jasperre
//::////////////////////////////////////////////*/
int AI_AttemptFeatCombatHostile()
{
    // Get our right hand (primary) weapon
    object oPrimaryWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);

    // Of course, we use, or attempt to use, our Divine Domain Powers, if
    // we have them! They are spells, of no talent (or no talent I want to check)
    if(!AI_GetAIHaveSpellsEffect(GlobalHasDomainSpells))
    {
        if(AI_ActionCastSpell(SPELLABILITY_BATTLE_MASTERY)) return TRUE; // STRENGTH domain
        if(AI_ActionCastSpell(SPELLABILITY_DIVINE_STRENGTH)) return TRUE; // STRENGTH domain
        if(AI_ActionCastSpell(SPELLABILITY_BATTLE_MASTERY)) return TRUE;  // WAR domain
        if(AI_ActionCastSpell(SPELLABILITY_DIVINE_TRICKERY)) return TRUE; // TRICKERY domain
    }
    // Special power. Not, I think, a domain one.
    if(AI_ActionCastSpell(SPELLABILITY_ROGUES_CUNNING)) return TRUE;

    // These are good-ass strength spells. They are basically
    // powerful combat-orientated, strenth-inducing ones :-D
    // Divine Power: Category 10, benifical Enhance self. Lvl 4.
    if(AI_ActionCastSpell(SPELL_DIVINE_POWER, OBJECT_SELF, 14, FALSE)) return TRUE;

    // We may cast cats grace, if they are 6M or over away, we have
    // a ranged weapon equipped or we have lowish AC compared to HD.
    if(GlobalOurAC < GlobalOurHitDice + 6 + Random(4) ||
       GlobalRangeToMeleeTarget > 6.0 ||
       GetWeaponRanged(oPrimaryWeapon))
    {
        // Include harper cats grace.
        if(!AI_GetAIHaveSpellsEffect(GlobalHasCatsGraceSpell))
        {
            // Greater cats grace gives 2d4 + 1
            if(AI_ActionCastSpell(SPELL_GREATER_CATS_GRACE)) return TRUE;

            // Special harper feat version
            if(AI_ActionUseSpellLikeFeat(FEAT_HARPER_CATS_GRACE, AI_SPELLABILITY_HARPER_CATS_GRACE)) return TRUE;

            // Cats Grace. Level 2 (Mage/Bard/Ranger). + d4() + 1 dexterity.
            if(AI_ActionCastSpell(SPELL_CATS_GRACE, OBJECT_SELF, 12, FALSE)) return TRUE;
        }
    }
    // Include blackguard bulls strength.
    if(!AI_GetAIHaveSpellsEffect(GlobalHasBullsStrengthSpell))
    {
        // Greater version gives 2d4 + 1.
        if(AI_ActionCastSpell(SPELL_GREATER_BULLS_STRENGTH)) return TRUE;

        // Blackguard version
        if(AI_ActionUseSpellLikeFeat(FEAT_BULLS_STRENGTH, SPELLABILITY_BG_BULLS_STRENGTH)) return TRUE;

        // Bulls Strength. Level 2 (Mage/Cleric/Bard/Paladin/Druid). + d4() + 1 strength.
        if(AI_ActionCastSpell(SPELL_BULLS_STRENGTH, OBJECT_SELF, 12, FALSE)) return TRUE;
    }

    // Other helping spells, lower ranks. If we can't hit much, we cast this.
    // - Some help more then others.
    // - We ignore some if in HTH and have low HD compared to spell.
    if((GlobalOurHitDice < 15 || GlobalMeleeAttackers < 1) &&
       // We only add 15, as we don't apply strength ETC. at the mo.
       (GlobalOurBaseAttackBonus - 15 < GlobalMeleeTargetAC) &&
       (!AI_GetAIHaveSpellsEffect(GlobalHasAidingSpell)))
    {
        // Prayer. Level 3 (Paladin/Cleric). +1 Attack, damage, saves to all allies in 10M Including self.
        if(AI_ActionCastSpell(SPELL_PRAYER, OBJECT_SELF, 13, FALSE)) return TRUE;
        if(GlobalOurHitDice < 14)
        {
            // Aid. Level 2 (Cleric/Paladin) 3 (Ranger) +1 Attack Rolls, +1d8 HP
            if(AI_ActionCastSpell(SPELL_AID, OBJECT_SELF, 12, FALSE)) return TRUE;
            if(GlobalOurHitDice < 12)
            {
                // Bless. Level 1 (Cleric/Paladin). +1 Saves, +1 Damage, to allies in area.
                if(AI_ActionCastSpell(SPELL_BLESS, OBJECT_SELF, 11, FALSE)) return TRUE;
            }
        }
    }
    // Attack bonus spells/feats, that directly add to our attack bonus.

    // Divine might adds charisma bonus to Attack.
    if(GetHasFeat(FEAT_TURN_UNDEAD))
    {
        // +Cha bonus to attack bonus.
        if(AI_ActionUseSpellLikeFeat(FEAT_DIVINE_MIGHT, SPELL_DIVINE_MIGHT)) return TRUE;
    }

    // We now cast the spells which will affect our weapon (if we have one!)
    // Only cast these if we have a valid right hand weapon.
    if(GetIsObjectValid(oPrimaryWeapon) &&
      // Casts on melee weapons only, except if set to always use range
     (!GetWeaponRanged(oPrimaryWeapon) ||
       GetSpawnInCondition(AI_FLAG_COMBAT_ARCHER_ALWAYS_USE_BOW, AI_COMBAT_MASTER)) &&
      // We do it VIA. the medium of one integer.
      !AI_GetAIHaveSpellsEffect(GlobalHasWeaponHelpSpell))
    {
        // Cast best to worst, only one in affect at once, however.

        // Blackstaff. Great stuff for a STAFF ONLY.
        if(GetBaseItemType(oPrimaryWeapon) == BASE_ITEM_QUARTERSTAFF)
        {
            // Blackstaff. Level 8 (Mage). Adds +4 enhancement bonus, On Hit: Dispel.
            if(AI_ActionCastSpell(SPELL_BLACKSTAFF, oPrimaryWeapon, 18, FALSE)) return TRUE;
        }
        if(!GetItemHasItemProperty(oPrimaryWeapon, ITEM_PROPERTY_ENHANCEMENT_BONUS))
        {
            // Greater Magical Weapon - up to +5
            // Greater Magic Weapon. Level 3 (Mage/Bard/Paladin) 4 (Cleric). Grants a +1/3 caster levels (to +5).
            if(AI_ActionCastSpell(SPELL_GREATER_MAGIC_WEAPON, oPrimaryWeapon, 14, FALSE)) return TRUE;
        }
        // Blade Thurst - cast on any weapon. No bother to check type.
        // Blade Thurst. Level 3 (Ranger). +3 Damage for a slashing weapon.
        if(AI_ActionCastSpell(SPELL_BLADE_THIRST, oPrimaryWeapon, 13, FALSE)) return TRUE;

        // Cannot have On Hit property already
        if(!GetItemHasItemProperty(oPrimaryWeapon, ITEM_PROPERTY_ON_HIT_PROPERTIES))
        {
            // Bless weapon
            if(GetRacialType(GlobalMeleeTarget) == RACIAL_TYPE_UNDEAD)
            {
                // Bless weapon. Level 1 (Paladin). +1 Attack Bonus, +2d6 Damage to melee weapon VS undead
                if(AI_ActionCastSpell(SPELL_BLESS_WEAPON, oPrimaryWeapon, 11, FALSE)) return TRUE;
            }

            // Dark Fire. Level 3 (Cleric). 1d6 fire damage +1/level to a maximum of +10.
            if(AI_ActionCastSpell(SPELL_DARKFIRE, oPrimaryWeapon, 13, FALSE)) return TRUE;

            // Flame Weapon. Level 2 (Mage). 1d4 fire damage +1/level to a maximum of +10.
            if(AI_ActionCastSpell(SPELL_FLAME_WEAPON, oPrimaryWeapon, 12, FALSE)) return TRUE;
        }

        // Not if we are already keen :-)
        if(!GetItemHasItemProperty(oPrimaryWeapon, ITEM_PROPERTY_KEEN))
        {
            // Keen Edge. Level 1 (Bard/Mage/Paladin). Adds the Keen property to a weapon
            if(AI_ActionCastSpell(SPELL_BLADE_THIRST, oPrimaryWeapon, 11, FALSE)) return TRUE;
        }

        // Magic weapon - +1
        if(!GetItemHasItemProperty(oPrimaryWeapon, ITEM_PROPERTY_ENHANCEMENT_BONUS))
        {
            // Magic Weapon. Level 1 (Bard/Cleric/Paladin/Ranger/Mage). +1 Enchantment to melee weapon.
            if(AI_ActionCastSpell(SPELL_MAGIC_WEAPON, oPrimaryWeapon, 11, FALSE)) return TRUE;
        }
    }
    // We also will throw grenades here, if we are at a cirtain HD - 5 or under,
    // because we may have ignored them in the spells part.

    // Try grenades - we always throw these. They are about level 1 standard of DC's
    // and effects. Not too bad, when NPC's get a chance to use them! :-)
    if(GlobalOurHitDice <= 5 ||
    // Will throw at range if under 10 HD
      (GlobalRangeToMeleeTarget > 5.0 && GlobalOurHitDice < 10))
    {
        if(AI_AttemptGrenadeThrowing(GlobalMeleeTarget)) return TRUE;
    }

    // Here, we use all potions if set too...
    /*
    if(GetSpawnInCondition(AI_FLAG_COMBAT_USE_ALL_POTIONS, AI_COMBAT_MASTER))
    {
        int nUsed = FALSE;
        // Check protection potion
        if(PotionPro > FALSE && !GetHasSpellEffect(PotionPro))
        {
            nUsed = PotionPro;
            ActionUseTalentOnObject(tPotionPro, OBJECT_SELF);
        }
        // Check enhancement potion
        else if(PotionEnh > FALSE  && !GetHasSpellEffect(PotionEnh))
        {
            nUsed = PotionEnh;
            ActionUseTalentOnObject(tPotionEnh, OBJECT_SELF);
        }
        // Check conditional potion
        else if(PotionCon > FALSE  && !GetHasSpellEffect(PotionCon))
        {
            nUsed = PotionCon;
            ActionUseTalentOnObject(tPotionCon, OBJECT_SELF);
        }
        if(nUsed > FALSE)
        {
            // 43 "[DCR:Pre-Melee Spells] All Potions Using. [Spell ID] " + IntToString(nUsed)
            DebugActionSpeakByInt(43, OBJECT_INVALID, nUsed);
            return TRUE;
        }
    }
    */
    // Rage - check effects via the set effects..
    if(!AI_GetAIHaveSpellsEffect(GlobalHasRageSpells))
    {
        // Rage: either:
        //    +6, to STR, CON, +4 will. -2 AC.
        // or +4, to STR, CON, +2 will. -2 AC.
        if(AI_ActionUseSpellLikeFeat(FEAT_BARBARIAN_RAGE, SPELLABILITY_BARBARIAN_RAGE)) return TRUE;

        // Blood frenzy. Level 2 (druid) as rage, for the most part. +2, to STR, CON, Will, -1 AC though.
        if(AI_ActionCastSpell(SPELL_BLOOD_FRENZY, OBJECT_SELF, 12)) return TRUE;
        if(AI_ActionCastSpell(SPELLABILITY_RAGE_5)) return TRUE;
        if(AI_ActionCastSpell(SPELLABILITY_RAGE_4)) return TRUE;
        if(AI_ActionCastSpell(SPELLABILITY_FEROCITY_3)) return TRUE;
        if(AI_ActionCastSpell(SPELLABILITY_INTENSITY_3)) return TRUE;
        if(AI_ActionCastSpell(SPELLABILITY_RAGE_3)) return TRUE;
        if(AI_ActionCastSpell(SPELLABILITY_INTENSITY_2)) return TRUE;
        if(AI_ActionCastSpell(SPELLABILITY_FEROCITY_2)) return TRUE;
        if(AI_ActionCastSpell(SPELLABILITY_INTENSITY_1)) return TRUE;
        if(AI_ActionCastSpell(SPELLABILITY_FEROCITY_1)) return TRUE;
    }
    // Cast expeditious retreat if we want to get into combat quicker
    if(GlobalRangeToMeleeTarget >= 20.0 &&
      !GetWeaponRanged(oPrimaryWeapon) &&
      !AI_GetAIHaveEffect(GlobalEffectHaste) &&
      !GetHasSpellEffect(SPELL_EXPEDITIOUS_RETREAT))
    {
        // Expeditious Retreat. Level 1 (Bard/Mage). +150% movement speed.
        if(AI_ActionCastSpell(SPELL_EXPEDITIOUS_RETREAT, OBJECT_SELF, 11, FALSE)) return TRUE;
    }
    // Cast true strike if we are RIGHT near the melee target, or are using
    // a ranged weapon
    if((GlobalRangeToMeleeTarget < 3.0 ||
        GetWeaponRanged(oPrimaryWeapon)) &&
       !GetHasSpellEffect(SPELL_TRUE_STRIKE))
    {
        // True Strike. Level 1 (Mage). +20 attack bonus for 9 seconds (IE about 1, or 2, attacks)
        if(AI_ActionCastSpell(SPELL_TRUE_STRIKE, OBJECT_SELF, 11, FALSE))
        {
            // 44: "[DCR:Pre-Melee Spells] True Strike Emptive attack [Target] " + GetName(GlobalMeleeTarget)
            DebugActionSpeakByInt(44, GlobalMeleeTarget);
            // Add attack to end of action queue. Should do this next round
            // anyway
            if(GlobalRangeToMeleeTarget <= 4.0)
            {
                ActionEquipMostDamagingMelee(GlobalMeleeTarget);
            }
            else
            {
                ActionEquipMostDamagingRanged(GlobalMeleeTarget);
            }
            ActionAttack(GlobalMeleeTarget);
            return TRUE;
        }
    }
    return FALSE;
}
/*::///////////////////////////////////////////////
//:: Name PolyMorph
//::///////////////////////////////////////////////
    If we are not affected by polymorph, going down from
    best to worst, we will polymorph. Use after combat buffs,
    after spells (although because some are random, this
    may fire when they still have some) and before we attack.
//::///////////////////////////////////////////////
//:: Created By: Jasperre
//::////////////////////////////////////////////*/

// This will cheat-cast nSpell at oTarget. Note that we will know if we have it
// by checking what appearance we have.
void AI_ActionCastShifterSpell(int nSpell, object oTarget = OBJECT_SELF)
{
    // Cheat cast the spell. We know we must have it.
    ActionCastSpellAtObject(nSpell, oTarget, METAMAGIC_NONE, TRUE);
}
// This willcast nFirst -> nFirst + nAmount polymorph spell. It will check
// if we have nMaster (Either by feat or spell, depending on bFeat).
// TRUE if we polymorph.
// * Only decrements if bRemove is TRUE
int AI_ActionPolymorph(int nMaster, int nFirstSpell, int nAmount, int bFeat = FALSE, int bRemove = TRUE)
{
    if((bFeat && GetHasFeat(nMaster)) ||
      (!bFeat && GetHasSpell(nMaster)))
    {
        // Randomise
        // EG: Got from 300 to 303, so nAmount is 3 and we input 300 as the start one,
        // meaning we add 0 (to get 300) 1 (to get 301) or 2 (to get 302, all 3 options covered)
        int nCast = nFirstSpell + Random(nAmount);

        // Debug
        // 11: "[DCR:Casting] SubSpecialSpell. [ID] " + IntToString(iInput) + " [Target] " + GetName(oInput) + " [Location] " + sInput; break;
        DebugActionSpeakByInt(11, OBJECT_SELF, nCast);

        // If a spell, we concentration check it :-)
        if(!bFeat)
        {
            AI_AttemptConcentrationCheck(GlobalSpellTarget);
        }

        // Cast it
        // no cheat casting bruh - pok
        ActionCastSpellAtObject(nCast, OBJECT_SELF, METAMAGIC_NONE);

        /*
        if(bRemove)
        {
            // Decrement one or the other
            if(bFeat)
            {
                // Feat
                DecrementRemainingFeatUses(OBJECT_SELF, nMaster);
            }
            else
            {
                // Spell
                DecrementRemainingSpellUses(OBJECT_SELF, nMaster);
            }
        }
        */
        // Add Action Attack melee target :-D
        ActionAttack(GlobalMeleeTarget);
        return TRUE;
    }
    return FALSE;
}
// Will polymorph Self if not already so. Will return TRUE if it casts best on self.
int AI_AttemptPolyMorph()
{
    if(!GetSpawnInCondition(AI_FLAG_OTHER_NO_POLYMORPHING, AI_OTHER_MASTER) &&
       // We don't polymorph as an archer.
       GetLocalInt(OBJECT_SELF, "range") != 1)
    {
        // Spells that are tensers transformation and polymorth here.
        // Will cast 100% on all shapechanges. Need to make it check for any spells.
        // Check values needed
        if(!AI_GetAIHaveEffect(GlobalEffectPolymorph))
        {
            // Epic shapechanging feats
            // - Dragon - just different breaths.
                // 707   Greater_Wild_Shape_Red_dragon
                // 708   Greater_Wild_Shape_Blue_dragon
                // 709   Greater_Wild_Shape_Green_dragon
            if(AI_ActionPolymorph(FEAT_EPIC_WILD_SHAPE_DRAGON, 707, 3, TRUE)) return TRUE;
            // Construct feat
                // 738   Construct_Shape_StoneGolem
                // 739   Construct_Shape_DemonFleshGolem
                // 740   Construct_Shape_IronGolem
            if(AI_ActionPolymorph(FEAT_EPIC_CONSTRUCT_SHAPE, 738, 3, TRUE)) return TRUE;
            // Outsider shape
                // 733   Outsider_Shape_Azer
                // 734   Outsider_Shape_Rakshasa
                // 735   Outsider_Shape_DeathSlaad
            if(AI_ActionPolymorph(FEAT_EPIC_OUTSIDER_SHAPE, 733, 3, TRUE)) return TRUE;
            // Undead - any of them
                // 704   Undead_Shape_risen_lord
                // 705   Undead_Shape_Vampire
                // 706   Undead_Shape_Spectre
            if(AI_ActionPolymorph(FEAT_EPIC_WILD_SHAPE_UNDEAD, 704, 3, TRUE)) return TRUE;
            // Shapechange
                // 392   Shapechange_RED_DRAGON
                // 393   Shapechange_FIRE_GIANT
                // 394   Shapechange_BALOR
                // 395   Shapechange_DEATH_SLAAD
                // 396   Shapechange_IRON_GOLEM
            if(AI_ActionPolymorph(SPELL_SHAPECHANGE, 392, 5)) return TRUE;
            // Druid feat. Elements.
                // 397   Elemental_Shape_FIRE
                // 398   Elemental_Shape_WATER
                // 399   Elemental_Shape_EARTH
                // 400   Elemental_Shape_AIR
            if(AI_ActionPolymorph(FEAT_EPIC_DRUID_INFINITE_ELEMENTAL_SHAPE, 397, 4, TRUE, FALSE)) return TRUE;
            if(AI_ActionPolymorph(FEAT_ELEMENTAL_SHAPE, 397, 4, TRUE)) return TRUE;
            // Wildshape 4 is next best
            // - Infinite and normal shapes
            // - Not in any order (doh!)
                // 671   Greater_Wild_Shape_Beholder
                // 679   Greater_Wild_Shape_Medusa
                // 691   Greater_Wild_Shape_Mindflayer
                // 694   Greater_Wild_Shape_DireTiger
            // Random choose one
            int nSpell = 671;
            switch(d4())
            {
                case 1: nSpell = 671; break;
                case 2: nSpell = 679; break;
                case 3: nSpell = 691; break;
                case 4: nSpell = 694; break;
            }
            if(AI_ActionPolymorph(FEAT_EPIC_SHIFTER_INFINITE_WILDSHAPE_4, nSpell, FALSE, TRUE, FALSE)) return TRUE;
            if(AI_ActionPolymorph(FEAT_GREATER_WILDSHAPE_4, nSpell, TRUE)) return TRUE;
            // Humanoid shape
                // 682   Humanoid_Shape_Drow
                // 683   Humanoid_Shape_Lizardfolk
                // 684   Humanoid_Shape_KoboldAssa
            if(AI_ActionPolymorph(FEAT_EPIC_SHIFTER_INFINITE_HUMANOID_SHAPE, 682, 3, TRUE, FALSE)) return TRUE;
            if(AI_ActionPolymorph(FEAT_HUMANOID_SHAPE, 682, 3, TRUE)) return TRUE;
            // 3 - Infinite and normal shapes
            // 3 - Not in any order (doh!)
                // 670   Greater_Wild_Shape_Basilisk
                // 673   Greater_Wild_Shape_Drider
                // 674   Greater_Wild_Shape_Manticore
            // Random choose one
            nSpell = 670;
            switch(d3())
            {
                case 1: nSpell = 670; break;
                case 2: nSpell = 673; break;
                case 3: nSpell = 674; break;
            }
            if(AI_ActionPolymorph(FEAT_EPIC_SHIFTER_INFINITE_WILDSHAPE_3, nSpell, FALSE, TRUE, FALSE)) return TRUE;
            if(AI_ActionPolymorph(FEAT_GREATER_WILDSHAPE_3, nSpell, TRUE)) return TRUE;
            // 2 - Infinite and normal shapes
            // 2 - Not in any order (doh!)
                // 672   Greater_Wild_Shape_Harpy
                // 678   Greater_Wild_Shape_Gargoyle
                // 680   Greater_Wild_Shape_Minotaur
            if(AI_ActionPolymorph(FEAT_EPIC_SHIFTER_INFINITE_WILDSHAPE_2, nSpell, FALSE, TRUE, FALSE)) return TRUE;
            if(AI_ActionPolymorph(FEAT_GREATER_WILDSHAPE_2, nSpell, TRUE)) return TRUE;
            // 1 - Infinite and normal shapes - In order
                // 658   Greater_Wild_Shape_Wyrmling_Red
                // 659   Greater_Wild_Shape_Wyrmling_Blue
                // 660   Greater_Wild_Shape_Wyrmling_Black
                // 661   Greater_Wild_Shape_Wyrmling_White
                // 662   Greater_Wild_Shape_Wyrmling_Green
            if(AI_ActionPolymorph(FEAT_EPIC_SHIFTER_INFINITE_WILDSHAPE_1, 658, 5, TRUE, FALSE)) return TRUE;
            if(AI_ActionPolymorph(FEAT_GREATER_WILDSHAPE_1, 658, 5, TRUE)) return TRUE;

            // We can have items for this polymorph spell :-)
            if(AI_ActionCastSpell(SPELL_TENSERS_TRANSFORMATION, OBJECT_SELF, 16)) return TRUE;

            // Animal wildshape
                // 401   Wild_Shape_BROWN_BEAR
                // 402   Wild_Shape_PANTHER
                // 403   Wild_Shape_WOLF
                // 404   Wild_Shape_BOAR
                // 405   Wild_Shape_BADGER
            if(AI_ActionPolymorph(FEAT_EPIC_DRUID_INFINITE_WILDSHAPE, 401, 5, TRUE, FALSE)) return TRUE;
            if(AI_ActionPolymorph(FEAT_WILD_SHAPE, 401, 5, TRUE)) return TRUE;

            // Shapechange into - Troll, Pixie, Uber Hulk, Giant Spider, Zombie
                // 387   Polymorph_GIANT_SPIDER
                // 388   Polymorph_TROLL
                // 389   Polymorph_UMBER_HULK
                // 390   Polymorph_PIXIE
                // 391   Polymorph_ZOMBIE
            if(AI_ActionPolymorph(SPELL_POLYMORPH_SELF, 387, 5)) return TRUE;
        }
        else /*Else we have it*/if(d10() <= 6)
        {
            // The special abilities VIA. Shapechanger!
            // - We check our appearance and cast as appropriately.
            // - 60% base chance of casting an ability or spell.

            switch(GetAppearanceType(OBJECT_SELF))
            {
                case APPEARANCE_TYPE_ELEMENTAL_WATER:
                case APPEARANCE_TYPE_ELEMENTAL_WATER_ELDER:
                {
                    // We can cast Pulse Drown unlimited times/day.
                    // Only use if above 50HP, and enemy has less then 20 Fortitude
                    // and is within 4M
                    if(GlobalRangeToMeleeTarget < 4.0 && GlobalOurCurrentHP > 50 &&
                       GetFortitudeSavingThrow(GlobalMeleeTarget) < 18)
                    {
                        AI_ActionCastShifterSpell(SPELLABILITY_PULSE_DROWN);
                        return TRUE;
                    }
                    return FALSE;
                }
                break;
                case APPEARANCE_TYPE_ELEMENTAL_AIR:
                case APPEARANCE_TYPE_ELEMENTAL_AIR_ELDER:
                {
                    // Can use Pulse: Whirlwind unlimited times/day.
                    // DC 14 or knockdown + some damage.
                    if(GlobalRangeToMeleeTarget < 4.0 && GetReflexSavingThrow(GlobalMeleeTarget) < 15)
                    {
                        AI_ActionCastShifterSpell(SPELLABILITY_PULSE_WHIRLWIND);
                        return TRUE;
                    }
                    return FALSE;
                }
                break;
                // Wyrmling Breath Attacks are in the default dragon behavnOur
                // (we check for dragon appearance and check talents)
                case APPEARANCE_TYPE_MANTICORE:
                {
                    // Can use Spike Attack (Greater Wild Shape Version) at
                    // some reflex save or other.
                    if(GlobalRangeToMeleeTarget < 10.0 &&
                       GetReflexSavingThrow(GlobalMeleeTarget) < (18+ d6()))
                    {
                        AI_ActionCastShifterSpell(AI_SPELLABILITY_GWILDSHAPE_SPIKES, GlobalMeleeTarget);
                        return TRUE;
                    }
                    return FALSE;
                }
                break;
                // Drow/Drider : Don't bother with darkness.
                case APPEARANCE_TYPE_HARPY:// Harpy! 491
                {
                    // Harpysong - charm enemies. Will saving throw.
                    if(GlobalRangeToMeleeTarget < 4.0 &&
                       GetWillSavingThrow(GlobalMeleeTarget) < (14 + d4()))
                    {
                        AI_ActionCastShifterSpell(AI_SPELLABILITY_HARPYSONG);
                        return TRUE;
                    }
                    return FALSE;
                }
                break;
                case APPEARANCE_TYPE_BASILISK:
                case APPEARANCE_TYPE_MEDUSA:
                {
                    // Limited petrify gaze attack
                    // Pretty cool.
                    if(GetLocalInt(OBJECT_SELF,"X2_GWILDSHP_LIMIT_" + IntToString(AI_SPELLABILITY_GWILDSHAPE_STONEGAZE)) &&
                       GlobalRangeToMeleeTarget < 4.0 &&
                       GetFortitudeSavingThrow(GlobalMeleeTarget) < (14 + d4()))
                    {
                        AI_ActionCastShifterSpell(AI_SPELLABILITY_GWILDSHAPE_STONEGAZE, GlobalMeleeTarget);
                        return TRUE;
                    }
                    return FALSE;
                }
                break;
                case APPEARANCE_TYPE_MINDFLAYER: // Mind Flayer 413
                {
                    // Psionic Inertial Barrier ability - unlimited uses.
                    if(!GetHasSpellEffect(AI_SPELLABILITY_PSIONIC_INERTIAL_BARRIER))
                    {
                        AI_ActionCastShifterSpell(AI_SPELLABILITY_PSIONIC_INERTIAL_BARRIER);
                        return TRUE;
                    }
                    // Else, we have Mind Blast. Limited uses, but stuns!
                    else if(!GetHasSpellEffect(AI_SPELLABILITY_GWILDSHAPE_MINDBLAST, GlobalMeleeTarget) &&
                             GetLocalInt(OBJECT_SELF,"X2_GWILDSHP_LIMIT_" + IntToString(AI_SPELLABILITY_GWILDSHAPE_MINDBLAST)) &&
                             GlobalRangeToMeleeTarget < 8.0)
                    {
                        AI_ActionCastShifterSpell(AI_SPELLABILITY_GWILDSHAPE_MINDBLAST);
                        return TRUE;
                    }
                    return FALSE;
                }
                break;
                // Vampires have domination gaze (limited uses)
                case APPEARANCE_TYPE_VAMPIRE_FEMALE: // Vampires
                case APPEARANCE_TYPE_VAMPIRE_MALE:   // Vampires
                {
                    // Limited Domination Gazes.
                    if(GetLocalInt(OBJECT_SELF, "X2_GWILDSHP_LIMIT_" + IntToString(AI_SPELLABILITY_VAMPIRE_DOMINATION_GAZE)) &&
                       !GetHasSpellEffect(AI_SPELLABILITY_VAMPIRE_DOMINATION_GAZE, GlobalMeleeTarget) &&
                        GetWillSavingThrow(GlobalMeleeTarget) < (14 + d4()) &&
                       // This is a simple check for "have we got a dominated guy already"
                       !AI_GetSpellTargetImmunity(GlobalImmunityDomination))
                    {
                        AI_ActionCastShifterSpell(AI_SPELLABILITY_VAMPIRE_DOMINATION_GAZE, GlobalMeleeTarget);
                        return TRUE;
                    }
                    return FALSE;
                }
                break;
                case APPEARANCE_TYPE_SPECTRE:
                {
                    // Unlimited invisibility, and unlimited "spectre attack".
                    // 60% chance of using the spectre attack.
                    if(d10() <= 6 && GetFortitudeSavingThrow(GlobalMeleeTarget) < (14 + d10()) &&
                      !GetIsImmune(GlobalMeleeTarget, IMMUNITY_TYPE_NEGATIVE_LEVEL))
                    {
                        AI_ActionCastShifterSpell(AI_SPELLABILITY_SHIFTER_SPECTRE_ATTACK, GlobalMeleeTarget);
                        return TRUE;
                    }
                    // Else invisiblity
                    if(!AI_GetAIHaveEffect(GlobalEffectInvisible))
                    {
                        AI_ActionCastShifterSpell(AI_SPELLABILITY_VAMPIRE_INVISIBILITY);
                        return TRUE;
                    }
                    return FALSE;
                }
                break;
                case APPEARANCE_TYPE_WILL_O_WISP:
                {
                    // Unlimited invisibility. Uses the base 60% chance above to
                    // cast this.
                    if(!AI_GetAIHaveEffect(GlobalEffectInvisible))
                    {
                        AI_ActionCastShifterSpell(SPELL_INVISIBILITY);
                        return TRUE;
                    }
                    return FALSE;
                }
                break;
                case APPEARANCE_TYPE_AZER_MALE:// Azer man - 428
                case APPEARANCE_TYPE_AZER_FEMALE:// Azer female - 429
                {
                    // Unlimited fire attacks.
                    // Burning hands and azer blast.
                    // 80% chance of azer blast
                    if(GetReflexSavingThrow(GlobalMeleeTarget) < (14 + d6()) &&
                       d10() <= 8)
                    {
                        AI_ActionCastShifterSpell(AI_SPELLABILITY_AZER_FIRE_BLAST, GlobalMeleeTarget);
                        return TRUE;
                    }
                    // Else burning hands might be attempted (also randomly)
                    if(GetReflexSavingThrow(GlobalMeleeTarget) < (12 + d4()))
                    {
                        AI_ActionCastShifterSpell(SPELL_BURNING_HANDS, GlobalMeleeTarget);
                        return TRUE;
                    }
                    return FALSE;
                }
                break;
                case APPEARANCE_TYPE_SLAAD_DEATH:
                {
                    // Unlimited spittle attacks. Just need the base 60% chance above.
                    AI_ActionCastShifterSpell(AI_SPELLABILITY_SLAAD_CHAOS_SPITTLE, GlobalMeleeTarget);
                    return TRUE;
                }
                break;
                case APPEARANCE_TYPE_RAKSHASA_TIGER_FEMALE:
                case APPEARANCE_TYPE_RAKSHASA_TIGER_MALE:
                {
                    // Unlimited spells - 3.
                    // - Dispel Magic
                    // - Ice Storm
                    // - Mestils Acid Breath.
                    // Randomise each one.

                    // Dispel magic against the global dispel target.
                    if(d10() <= 6 && GlobalDispelTargetHighestDispel >= 1)
                    {
                        AI_ActionCastShifterSpell(SPELL_DISPEL_MAGIC, GlobalDispelTarget);
                        return TRUE;
                    }
                    // Ice storm, woo.
                    else if(d10() <= 6)
                    {
                        AI_ActionCastShifterSpell(SPELL_ICE_STORM, GlobalMeleeTarget);
                        return TRUE;
                    }
                    // Mestils Acid Breath.
                    else
                    {
                        AI_ActionCastShifterSpell(SPELL_MESTILS_ACID_BREATH, GlobalMeleeTarget);
                        return TRUE;
                    }
                    return FALSE;
                }
                break;
                case APPEARANCE_TYPE_GOLEM_IRON:
                {
                    // Unlimited spells Iron Golem Breath.
                    if(GetFortitudeSavingThrow(GlobalMeleeTarget) < 20)
                    {
                        AI_ActionCastShifterSpell(SPELLABILITY_GOLEM_BREATH_GAS, GlobalMeleeTarget);
                        return TRUE;
                    }
                    return FALSE;
                }
                break;
                case APPEARANCE_TYPE_GOLEM_STONE:
                {
                    // Unlimited spells: Throw rocks
                    if(GetReflexSavingThrow(GlobalMeleeTarget) < 20 + d6())
                    {
                        AI_ActionCastShifterSpell(AI_SPELLABILITY_GIANT_HURL_ROCK, GlobalMeleeTarget);
                        return TRUE;
                    }
                    return FALSE;
                }
                break;
                case APPEARANCE_TYPE_KOBOLD_A:// Kobold (assassin)302
                {
                    // Unlimited invisibility
                    if(!AI_GetAIHaveEffect(GlobalEffectInvisible))
                    {
                        AI_ActionCastShifterSpell(AI_SPELLABILITY_VAMPIRE_INVISIBILITY);
                        return TRUE;
                    }
                    return FALSE;
                }
                break;
            }
        }
    }
    return FALSE;
}
// Returns TRUE if we counterspell GlobalCounterspellTarget, only does it
// if we have Dispels, and if set to want to be in a group, we are in one :-)
int AI_AttemptCounterSpell()
{
    // Check for 5+ allies if counter spell in group. If <= 4, return FALSE
    if(GetSpawnInCondition(AI_FLAG_COMBAT_COUNTER_SPELL_ONLY_IN_GROUP, AI_COMBAT_MASTER) &&
       GlobalTotalAllies <= 4)
    {
       return FALSE;
    }
    // Need a dispel spell
    if(!(GetHasSpell(SPELL_MORDENKAINENS_DISJUNCTION) ||
         GetHasSpell(SPELL_GREATER_DISPELLING) ||
         GetHasSpell(SPELL_DISPEL_MAGIC) ||
         GetHasSpell(SPELL_LESSER_DISPEL)))
    {
        return FALSE;
    }
    object oLoopTarget, oCounterspellTarget;
    int nCnt, nCasterLevels, nHighestLevels;
    float fDistance;
    // Try and get a Arcane caster to counter
    if(GetSpawnInCondition(AI_FLAG_COMBAT_COUNTER_SPELL_ARCANE, AI_COMBAT_MASTER))
    {
        // Loop seen enemies - must be within 20M and valid
        nCnt = 1;
        oLoopTarget = GetLocalObject(OBJECT_SELF, ARRAY_ENEMY_RANGE_SEEN + IntToString(nCnt));
        fDistance = GetLocalFloat(OBJECT_SELF, ARRAY_ENEMY_RANGE_SEEN + IntToString(nCnt));
        while(GetIsObjectValid(oLoopTarget) && fDistance <= 20.0)
        {
            // Check caster levels
            nCasterLevels = GetLevelByClass(CLASS_TYPE_WIZARD, oLoopTarget) +
                            GetLevelByClass(CLASS_TYPE_SORCERER, oLoopTarget) +
                            GetLevelByClass(CLASS_TYPE_BARD, oLoopTarget);
            // Check if higher.
            if(nCasterLevels > nHighestLevels)
            {
                nHighestLevels = nCasterLevels;
                oCounterspellTarget = oLoopTarget;
            }
            // Get next target
            nCnt++;
            oLoopTarget = GetLocalObject(OBJECT_SELF, ARRAY_ENEMY_RANGE_SEEN + IntToString(nCnt));
            fDistance = GetLocalFloat(OBJECT_SELF, ARRAY_ENEMY_RANGE_SEEN + IntToString(nCnt));
        }
    }
    // If not valid, might check divine
    if(!GetIsObjectValid(oCounterspellTarget) &&
        nHighestLevels >= GlobalOurHitDice / 3 &&
        GetSpawnInCondition(AI_FLAG_COMBAT_COUNTER_SPELL_DIVINE, AI_COMBAT_MASTER))
    {
        // Loop seen enemies - must be within 20M and valid
        nHighestLevels = FALSE;
        nCnt = 1;
        oLoopTarget = GetLocalObject(OBJECT_SELF, ARRAY_ENEMY_RANGE_SEEN + IntToString(nCnt));
        fDistance = GetLocalFloat(OBJECT_SELF, ARRAY_ENEMY_RANGE_SEEN + IntToString(nCnt));
        while(GetIsObjectValid(oLoopTarget) && fDistance <= 20.0)
        {
            // Check caster levels
            nCasterLevels = GetLevelByClass(CLASS_TYPE_CLERIC, oLoopTarget) +
                            GetLevelByClass(CLASS_TYPE_DRUID, oLoopTarget);
            // Check if higher.
            if(nCasterLevels > nHighestLevels)
            {
                nHighestLevels = nCasterLevels;
                oCounterspellTarget = oLoopTarget;
            }
            // Get next target
            nCnt++;
            oLoopTarget = GetLocalObject(OBJECT_SELF, ARRAY_ENEMY_RANGE_SEEN + IntToString(nCnt));
            fDistance = GetLocalFloat(OBJECT_SELF, ARRAY_ENEMY_RANGE_SEEN + IntToString(nCnt));
        }
    }
    // Check if valid
    if(GetIsObjectValid(oCounterspellTarget))
    {
        // 45: "[DCR:CounterSpell] Counterspelling. [Target] " + GetName(oCounterspellTarget)
        DebugActionSpeakByInt(45, oCounterspellTarget);
        AI_SetMeleeMode(ACTION_MODE_COUNTERSPELL);
        ActionCounterSpell(oCounterspellTarget);
        return TRUE;
    }
    return FALSE;
}
// This will, in most occasion, ClearAllActions.
// If it does NOT, it returns FALSE, if we are doing something more important,
// and we perform that action again (or carry on doing it).
int AI_StopWhatWeAreDoing()
{
    // - New wrappered function
    // * Includes fleeing and things.
    if(GetIsPerformingSpecialAction())
    {
        return FALSE;
    }
    // See if we need ClearAllActions(TRUE) for HIPS
    if(GetHasFeat(FEAT_HIDE_IN_PLAIN_SIGHT) &&
       GetStealthMode(OBJECT_SELF) == STEALTH_MODE_DISABLED &&
      !GetSpawnInCondition(AI_FLAG_OTHER_COMBAT_NO_HIDING, AI_OTHER_COMBAT_MASTER))
    {
        // Check for nearest person with trueseeing (which pierces hiding)
        if(!GetIsObjectValid(GetNearestCreature(CREATURE_TYPE_HAS_SPELL_EFFECT, SPELL_TRUE_SEEING, OBJECT_SELF, 1, CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY)))
        {
            ClearAllActions(TRUE);
            SetActionMode(OBJECT_SELF, ACTION_MODE_STEALTH, TRUE);
            return TRUE;
        }
    }
    // Else we return TRUE, meaning we have cleared all actions
    ClearAllActions();
    return TRUE;
}

/************************ [AI_DetermineCombatRound] ****************************
    This will do an action - EG: ActionAttack, against oIntruder, or against
    the best (or random) target in range.

    At the end of combat, it heals up and searches for more enemies before
    resuming normal activities.
************************* [History] ********************************************
    1.0 - Started
    1.2 - Fixed minor bugs
    1.3 - Global targets added, cleaned up as Global* constants are used.
************************* [Workings] *******************************************
    It will start by checking the creatures effects, if they cannot move, nothing
    is done. Daze, however, forces them to move away from last attacker.

    We then make sure we are not in an AOE spell, and not fleeing, if we are in
    either, we react accordingly.

    After that, it sets up Global* targets, SpellTarget, RangedTarget, MeleeTarget,
    and the integers such as GlobalAverageEnemyHD.

    If none are valid, it will search, but if we know there is an enemy around,
    we move to them.

    If there is a valid target, at least one object Seen or Heard in our LOS, then
    we perform a set of checks, and choose an action - normally using Class
    abilities - such as Turn Undead, and Bard Songs, then spells, and finally
    using Combat spells, and attacking the target using feats. Skills are also
    used after spells.

    Dragons also run Wing Buffet, as well as using Breath attacks.
************************* [Arguments] ******************************************
    Arguments: oIntruder
************************* [AI_DetermineCombatRound] ***************************/
void AI_DetermineCombatRound(object oIntruder = OBJECT_INVALID)
{
    // 46: "[DRC] START [Intruder]" + GetName(oIntruder)
    DebugActionSpeakByInt(46, oIntruder);

    // Useful in the IsUncommandable check - we don't loop effects more than once.
    AI_SetUpUsEffects();

    // New check - If they are commandable, and no stupid ones.
    if(AI_GetAIHaveEffect(GlobalEffectUncommandable) ||
       GetHasFeatEffect(FEAT_IMPROVED_KNOCKDOWN) ||
       GetHasFeatEffect(FEAT_KNOCKDOWN) ||
       GetAIOff())
    {
        DeleteAIObject(AI_LAST_MELEE_TARGET);
        DeleteAIObject(AI_LAST_SPELL_TARGET);
        DeleteAIObject(AI_LAST_RANGED_TARGET);
        // 47: "[DCR] [PREMITURE EXIT] Cannot Do Anything."
        DebugActionSpeakByInt(47);
        return;
    }
    // 1.30 - daze is now as 3E rules,  you can move around walking, but no
    // attacking, casting or anything else :-(
    else if(AI_GetAIHaveEffect(GlobalEffectDazed))
    {
        // 48: "[DCR] [PREMITURE EXIT] Dazed move away."
        DebugActionSpeakByInt(48);
        // Equip best shield for most AC
        AI_EquipBestShield();
        // Move away from the nearest heard enemy

        GlobalNearestEnemyHeard = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_HEARD, CREATURE_TYPE_IS_ALIVE, TRUE);
        if(GetIsObjectValid(GlobalNearestEnemyHeard))
        {
            //ActionMoveAwayFromObject(GlobalNearestEnemyHeard, TRUE);
            // use location instead - pok
            ActionMoveAwayFromLocation(GetLocation(GlobalNearestEnemyHeard), TRUE);
        }
        else
        {
            ActionMoveAwayFromLocation(GetLocation(OBJECT_SELF), TRUE);
        }
        return;
    }
    // Tempory integer
    int nTempInt;

    // We stop  - ClearAllActions normally
    // NOTE: This returns FALSE if we don't stop actions - and want to carry on
    // doing the thing before! like fleeing! (or we do it in the Stop thing).
    if(!AI_StopWhatWeAreDoing())
    {
        // 49: "[DCR] [PREMITURE EXIT] Fleeing or otherwise"
        DebugActionSpeakByInt(49);
        return;
    }

    // If oIntruder is valid, we will face them (this helps stops sneak
    // attacks if we then cast something on ourselves, ETC).

    object oPartyTarget = GetClosestPartyTarget();

    // use master' party target if oIntruder isn't valid or is dead - pok
    if ((!GetIsObjectValid(oIntruder) || GetIsDead(oIntruder)) && GetIsObjectValid(oPartyTarget))
        oIntruder = oPartyTarget;

    // only continue if the intruder exists and is not dead
    // - pok
    if(GetIsObjectValid(oIntruder) && !GetIsDead(oIntruder))
    {

        DoCombatVoice();

        // Face the intruder.
        SetFacingPoint(GetPosition(oIntruder));
    }

    // Then we check all objects. we are going to perform a normal, or fleeing
    // action this round, or action call.

    // Sets up us!
    AI_SetUpUs();

    // We set up 2 other targets...for testing against ETC.
    // 1.4 - Simple loop here, we need to check AI_GetTargetSanityCheck().
    nTempInt = 1;
    object oEnemy = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, nTempInt);

// replace enemy if invalid or dead with party target - pok
    if ((!GetIsObjectValid(oEnemy) || GetIsDead(oEnemy)) && GetIsObjectValid(oPartyTarget))
        oEnemy = oPartyTarget;

    while(GetIsObjectValid(oEnemy) &&
         !GetIsObjectValid(GlobalNearestEnemyHeard) &&
         !GetIsObjectValid(GlobalNearestEnemySeen))
    {
        // Make a sanity check to use oEnemy at all.
        if(AI_GetTargetSanityCheck(oEnemy))
        {
            if(!GetIsObjectValid(GlobalNearestEnemyHeard) && GetObjectHeard(oEnemy))
            {
                GlobalNearestEnemyHeard = oEnemy;
            }
            if(!GetIsObjectValid(GlobalNearestEnemySeen) && GetObjectSeen(oEnemy))
            {
                GlobalNearestEnemySeen = oEnemy;
            }
        }
        nTempInt++;
        oEnemy = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, nTempInt);
    }
    // Valid?
    GlobalValidNearestSeenEnemy = GetIsObjectValid(GlobalNearestEnemySeen);
    GlobalValidNearestHeardEnemy = GetIsObjectValid(GlobalNearestEnemyHeard);

    // Speakstring arrays
    // * Don't speak when under silence or deafness.
    if(GlobalValidNearestHeardEnemy &&
      !AI_GetAIHaveEffect(GlobalEffectSilenced) && !AI_GetAIHaveEffect(GlobalEffectDeaf))
    {
        // Add in range checking here
        if(GetDistanceToObject(GlobalNearestEnemyHeard) < GetDistanceToObject(GlobalNearestEnemySeen))
        {
            GlobalRangeToNearestEnemy = GetDistanceToObject(GlobalNearestEnemyHeard);
        }
        else
        {
            GlobalRangeToNearestEnemy = GetDistanceToObject(GlobalNearestEnemySeen);
        }

        nTempInt = GetHitDice(GlobalNearestEnemyHeard);
        // THEM_OVER_US - They have 5+ levels over us.
        if(nTempInt - 5 >= GlobalOurHitDice)
        {
            SpeakArrayString(AI_TALK_ON_COMBAT_ROUND_THEM_OVER_US, TRUE);
        }
        // US_OVER_THEM - We have 5+ levels over them.
        else if(GlobalOurHitDice - 5 >= nTempInt)
        {
            SpeakArrayString(AI_TALK_ON_COMBAT_ROUND_US_OVER_THEM, TRUE);
        }
        // EQUAL        - Thier HD is within 4HD of us (EG: Us 10, them 10)
        else //if(iTempInt - 4 <= GlobalOurHitDice && iTempInt + 4 >= GlobalOurHitDice)
        {
            SpeakArrayString(AI_TALK_ON_COMBAT_ROUND_EQUAL, TRUE);
        }
    }
    else
    {
        GlobalRangeToNearestEnemy = 0.0;
    }

    // We may Dispel AOE's, move out of it, or ignore AOE's, EG Darkness.
    // Dragons may use this (though small chance)
    // Done before other things - best get out of some bad spells else they kill us!
    // - Returns TRUE if we did anything that would mean we don't want to do
    //   another action
    if(AI_AttemptSpecialChecks()){return;}

    // If this is set to FALSE, we do not set up normal targets.
    nTempInt = TRUE;

    // Check for our nearest heard enemy...
    if(!GlobalValidNearestHeardEnemy)
    {
        // If we do not have a valid nearest heard enemy - but have got a seen
        // enemy with etherealness - we attack that ethereal creature *now*
        oEnemy = GetNearestCreature(CREATURE_TYPE_REPUTATION, REPUTATION_TYPE_ENEMY, OBJECT_SELF, 1, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);
        if(!GetIgnoreNoFriend(oEnemy) && !GetIsEthereal(oEnemy))
        {
            // We attack just this enemy. We specially set variables usually
            // set in AI_SetUpAllObjects().
            GlobalMeleeTarget = oEnemy;
            GlobalSpellTarget = oEnemy;
            GlobalRangedTarget = oEnemy;

            // Make sure we cannot see oEnemy
            GlobalSeenSpell = FALSE;

            nTempInt = FALSE;
        }
        else
        {
            // Else...normal behaviour with no enemy found
        }
    }

    // If nTempInt was set to FALSE above, we do not set targets normally.
    if(nTempInt == TRUE)
    {
        // Sets up who to attack.
        // - Uses oIntruder (to attack or move near) if anything.
        // - We return TRUE if it ActionAttack's, or moves to an enemy - basically
        //   that we cannot do an action, but shouldn't search. False if normal.
        // - We do this after AOE checking and special spells.
        if(AI_SetUpAllObjects(oIntruder)){return;}
    }

    // We then check if we have anyone to attack :-) This is a global integer.
    if(GlobalAnyValidTargetObject)
    {
        // We do our auras. Quicken casted.
        AI_ActionAbilityAura();

        // We may flee from massive odds, or if we panic...or commoner fleeing
        // no morale panic - pok
        //if(AI_AttemptMoraleFlee()){return;}

        //no beholders or mindflayers - pok

        // We will attempt to heal ourselves first as a prioritory.
        // Dragons may use this.
        if(AI_AttemptHealingSelf()){return;}
        // We will attempt to heal a previously set ally, with spells.
        // Dragons use this, not always (and like to save spells for themselves).
        if(AI_AttemptHealingAlly()){return;}
        // We will cure, normally our conditions, or an allies. Things like
        // blindness always, with other things later.
        // Dragons use this, mostly with themselves.
        if(AI_AttemptCureCondition()){return;}

        // This is a good thing to use first. Dragons may use this.
        if(AI_AttemptFeatBardSong()){return;}
        // We may summon our monster. Always first, because its our's and personal. Dragons may use this (though small chance)
        // we won't summon pets. and if we do, i'll handle it on a heartbeat - pok
        //if(AI_AttemptFeatSummonFamiliar()){return;}
        // Turning, any sort of unturned and non-resistant creatures.
        // Used about every 3 rounds. Dragons may use this.
        if(AI_AttemptFeatTurning()){return;}

        // no dragons conditional - pok

        // We may move back as an archer, or even always do if set to. Normally
        // only if we have help do we retreat out of AOO range.
        // Will, if we can, cast invisibility first, or move back if we have it.
        if(AI_AttemptArcherRetreat(oIntruder)){return;}

        // This may knockout dying PC's or coup de grace sleeping PC's nearby.
        if(AI_AttemptGoForTheKill()){return;}

        // Spells attempt
        if(AI_AttemptAllSpells()){return;}

        // We will attempt pickpocket/taunt/animal empathy after spells, before polymorph
        if(AI_AttemptHostileSkills()){return;}

        // Attempt to cast all the buffing spells for melee - EG: Divine power,
        // magical weapons, and ability enchanters.
        if(AI_AttemptFeatCombatHostile()){return;}

        // We polymorph before attacking, if set so we can.
        if(AI_AttemptPolyMorph()){return;}

        // This is called to attack, and should always attack something really.
        if(AI_AttemptMeleeAttackWrapper()){return;}
    }
    // Else behavnOur - we don't have a target. Any healing, extra or anything
    // here. Then searching, and finally walking waypoints.
    else
    {
        // We will attempt to heal ourselves first as a prioritory.
        // Dragons may use this.
        if(AI_AttemptHealingSelf()){return;}
        // We will attempt to heal a previously set ally, with spells.
        // Dragons use this, not always (and like to save spells for themselves).
        if(AI_AttemptHealingAlly()){return;}
        // We will cure, normally our conditions, or an allies. Things like
        // blindness always, with other things later.
        // Dragons use this, mostly with themselves.
        if(AI_AttemptCureCondition()){return;}
    }
// This is a call to the function which determines which way point to go back to.
// This will only run if it cannot heal self, is not in an AOE spell, and no target.
    // 50: "[DRC] END - DELETE PAST TARGETS"
    DebugActionSpeakByInt(50);
    // Delete any last melee targets.
    DeleteAIObject(AI_LAST_MELEE_TARGET);
    DeleteAIObject(AI_LAST_SPELL_TARGET);
    DeleteAIObject(AI_LAST_RANGED_TARGET);
    DeleteLocalObject(OBJECT_SELF, "NW_GENERIC_LAST_ATTACK_TARGET");

    // 1.4 changes: Search.

    // Search is initilised by just making sure we have a cirtain special
    // action set to be done (IE: AI_SPECIAL_ACTIONS_SEARCH_AROUND)
    // * The amount of rounds to search is set to AI_SEARCH_ROUNDS_REMAINING, and
    //   is decreased each round. If a new combat round occurs (usually does!)
    //   then, of course, this will be reset.
    // * We search for nIntelligence rounds + 2.

    // If a Search will occur around a set object, we set it to AI_SEARCH_TARGET,
    // and will move to that persons location first.
    // * oTarget should be perhaps our last killed person, or somesuch.
    SetAIInteger(AI_SEARCH_ROUNDS_REMAINING, GlobalIntelligence + 2);
    SetAIObject(AI_SEARCH_TARGET, oIntruder);
    SetCurrentAction(AI_SPECIAL_ACTIONS_SEARCH_AROUND);
}

// Debug: To compile this script full, uncomment all of the below.
/* - Add two "/"'s at the start of this line
void main()
{
    return;
}
//*/


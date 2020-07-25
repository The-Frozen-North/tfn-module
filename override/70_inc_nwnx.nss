//::///////////////////////////////////////////////
//:: Community Patch 1.72 library with NWNX dependant functions for builders
//:: 70_inc_nwnx
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*

*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow
//:: Created On: 06-03-2016
//:://////////////////////////////////////////////

const int REST_EVENTTYPE_REST_FORCEREST = 4;

const int DURATION_TYPE_EQUIPPED = 3;
const int DURATION_TYPE_INNATE = 4;

const int AREA_DAYTIME_RESET_DEFAULT = -1;
const int AREA_DAYTIME_DAY = 0;
const int AREA_DAYTIME_DAWN = 1;
const int AREA_DAYTIME_DUSK = 2;
const int AREA_DAYTIME_NIGHT = 3;

const int EFFECT_TRUETYPE_INVALIDEFFECT                    =  0;
const int EFFECT_TRUETYPE_HASTE                            =  1;
const int EFFECT_TRUETYPE_DAMAGE_RESISTANCE                =  2;
const int EFFECT_TRUETYPE_SLOW                             =  3;
const int EFFECT_TRUETYPE_RESURRECTION                     =  4;
const int EFFECT_TRUETYPE_DISEASE                          =  5;
const int EFFECT_TRUETYPE_SUMMON_CREATURE                  =  6;
const int EFFECT_TRUETYPE_REGENERATE                       =  7;
const int EFFECT_TRUETYPE_SETSTATE                         =  8;
const int EFFECT_TRUETYPE_SETSTATE_INTERNAL                =  9;
const int EFFECT_TRUETYPE_ATTACK_INCREASE                  = 10;
const int EFFECT_TRUETYPE_ATTACK_DECREASE                  = 11;
const int EFFECT_TRUETYPE_DAMAGE_REDUCTION                 = 12;
const int EFFECT_TRUETYPE_DAMAGE_INCREASE                  = 13;
const int EFFECT_TRUETYPE_DAMAGE_DECREASE                  = 14;
const int EFFECT_TRUETYPE_TEMPORARY_HITPOINTS              = 15;
const int EFFECT_TRUETYPE_DAMAGE_IMMUNITY_INCREASE         = 16;
const int EFFECT_TRUETYPE_DAMAGE_IMMUNITY_DECREASE         = 17;
const int EFFECT_TRUETYPE_ENTANGLE                         = 18;
const int EFFECT_TRUETYPE_DEATH                            = 19;
const int EFFECT_TRUETYPE_KNOCKDOWN                        = 20;
const int EFFECT_TRUETYPE_DEAF                             = 21;
const int EFFECT_TRUETYPE_IMMUNITY                         = 22;
const int EFFECT_TRUETYPE_SET_AI_STATE                     = 23;
const int EFFECT_TRUETYPE_ENEMY_ATTACK_BONUS               = 24;
const int EFFECT_TRUETYPE_ARCANE_SPELL_FAILURE             = 25;
const int EFFECT_TRUETYPE_SAVING_THROW_INCREASE            = 26;
const int EFFECT_TRUETYPE_SAVING_THROW_DECREASE            = 27;
const int EFFECT_TRUETYPE_MOVEMENT_SPEED_INCREASE          = 28;
const int EFFECT_TRUETYPE_MOVEMENT_SPEED_DECREASE          = 29;
const int EFFECT_TRUETYPE_VISUALEFFECT                     = 30;
const int EFFECT_TRUETYPE_AREA_OF_EFFECT                   = 31;
const int EFFECT_TRUETYPE_BEAM                             = 32;
const int EFFECT_TRUETYPE_SPELL_RESISTANCE_INCREASE        = 33;
const int EFFECT_TRUETYPE_SPELL_RESISTANCE_DECREASE        = 34;
const int EFFECT_TRUETYPE_POISON                           = 35;
const int EFFECT_TRUETYPE_ABILITY_INCREASE                 = 36;
const int EFFECT_TRUETYPE_ABILITY_DECREASE                 = 37;
const int EFFECT_TRUETYPE_DAMAGE                           = 38;
const int EFFECT_TRUETYPE_HEAL                             = 39;
const int EFFECT_TRUETYPE_LINK                             = 40;
const int EFFECT_TRUETYPE_HASTE_INTERNAL                   = 41;
const int EFFECT_TRUETYPE_SLOW_INTERNAL                    = 42;
const int EFFECT_TRUETYPE_MODIFYNUMATTACKS                 = 44;
const int EFFECT_TRUETYPE_CURSE                            = 45;
const int EFFECT_TRUETYPE_SILENCE                          = 46;
const int EFFECT_TRUETYPE_INVISIBILITY                     = 47;
const int EFFECT_TRUETYPE_AC_INCREASE                      = 48;
const int EFFECT_TRUETYPE_AC_DECREASE                      = 49;
const int EFFECT_TRUETYPE_SPELL_IMMUNITY                   = 50;
const int EFFECT_TRUETYPE_DISPEL_ALL_MAGIC                 = 51;
const int EFFECT_TRUETYPE_DISPEL_BEST_MAGIC                = 52;
const int EFFECT_TRUETYPE_TAUNT                            = 53;
const int EFFECT_TRUETYPE_LIGHT                            = 54;
const int EFFECT_TRUETYPE_SKILL_INCREASE                   = 55;
const int EFFECT_TRUETYPE_SKILL_DECREASE                   = 56;
const int EFFECT_TRUETYPE_HITPOINTCHANGEWHENDYING          = 57;
const int EFFECT_TRUETYPE_SETWALKANIMATION                 = 58;
const int EFFECT_TRUETYPE_LIMIT_MOVEMENT_SPEED             = 59;
const int EFFECT_TRUETYPE_DAMAGE_SHIELD                    = 61;
const int EFFECT_TRUETYPE_POLYMORPH                        = 62;
const int EFFECT_TRUETYPE_SANCTUARY                        = 63;
const int EFFECT_TRUETYPE_TIMESTOP                         = 64;
const int EFFECT_TRUETYPE_SPELL_LEVEL_ABSORPTION           = 65;
const int EFFECT_TRUETYPE_ICON                             = 67;
const int EFFECT_TRUETYPE_RACIAL_TYPE                      = 68;
const int EFFECT_TRUETYPE_VISION                           = 69;
const int EFFECT_TRUETYPE_SEEINVISIBLE                     = 70;
const int EFFECT_TRUETYPE_ULTRAVISION                      = 71;
const int EFFECT_TRUETYPE_TRUESEEING                       = 72;
const int EFFECT_TRUETYPE_BLINDNESS                        = 73;
const int EFFECT_TRUETYPE_DARKNESS                         = 74;
const int EFFECT_TRUETYPE_MISS_CHANCE                      = 75;
const int EFFECT_TRUETYPE_CONCEALMENT                      = 76;
const int EFFECT_TRUETYPE_TURN_RESISTANCE_INCREASE         = 77;
const int EFFECT_TRUETYPE_BONUS_SPELL_OF_LEVEL             = 78;//warning: nonfunctional
const int EFFECT_TRUETYPE_DISAPPEARAPPEAR                  = 79;
const int EFFECT_TRUETYPE_DISAPPEAR                        = 80;
const int EFFECT_TRUETYPE_APPEAR                           = 81;
const int EFFECT_TRUETYPE_NEGATIVE_LEVEL                   = 82;
const int EFFECT_TRUETYPE_BONUS_FEAT                       = 83;
const int EFFECT_TRUETYPE_WOUNDING                         = 84;
const int EFFECT_TRUETYPE_SWARM                            = 85;
const int EFFECT_TRUETYPE_VAMPIRIC_REGENERATION            = 86;
const int EFFECT_TRUETYPE_DISARM                           = 87;
const int EFFECT_TRUETYPE_TURN_RESISTANCE_DECREASE         = 88;
const int EFFECT_TRUETYPE_BLINDNESS_INACTIVE               = 89;
const int EFFECT_TRUETYPE_PETRIFY                          = 90;
const int EFFECT_TRUETYPE_ITEMPROPERTY                     = 91;
const int EFFECT_TRUETYPE_SPELL_FAILURE                    = 92;
const int EFFECT_TRUETYPE_CUTSCENEGHOST                    = 93;
const int EFFECT_TRUETYPE_CUTSCENEIMMOBILE                 = 94;
const int EFFECT_TRUETYPE_DEFENSIVESTANCE                  = 95;
const int EFFECT_TRUETYPE_NWNXPATCH_MODIFYBAB              = 96;
const int EFFECT_TRUETYPE_NWNXPATCH_IGNORE_ARCANE_SPELL_FAILURE = 97;

struct MemorizedSpellSlot
{
    int id, ready, meta, domain;
};

struct CombatAttackData
{
    int AttackDeflected,AttackResult,AttackType,Concealment,CoupDeGrace,CriticalThreat,DeathAttack,KillingBlow,MissedBy,SneakAttack,ThreatRoll,ToHitMod,ToHitRoll,WeaponType;
};

////////////////////////////////////////////////////////////////////////////////
//                          System Functions                                  //
////////////////////////////////////////////////////////////////////////////////

//Determines whether the nwnx_patch or nwncx_patch plugin is running and working. This is usefull in single player
//modules where builder wants to use some custom feature from patch plugin but doesn't want to restrict the module
//to require patch 1.72. If patch plugin won't run, he can code it differently and print some feedback stating he
//needs to play module with 1.72 to obtain that feature.
//The return value is a patch plugin version ie. 124 (for 1.24) or 0 if nwnx is not running.
int NWNXPatch_IsInUse();

//Determines whether specific player uses NWNCX_Patch or not. This is usefull in multiplayer to maybe restrict some
//content or even entrance into server by specific nwncx_patch version.
//This function won't work in singleplayer.
//The return value is a nwncx_patch version ie. 124 (for 1.24) or 0 if player doesn't use nwncx_patch.
//int NWNXPatch_VerifyClientRunningNWNCX(object oPlayer);

//Returns id of the player language
//Note that the function is - to make it more efficient - storing last value for each
//player into local variable and will return it from there to avoid making NWNX calls.
//Player language usually doesn't change, and if so, it is when player logs out, switch
//languge and logs back in. Therefore it is recommended to run this function in OnClientEnter
//with parameter bReadFromNWNX = TRUE
int NWNXPatch_GetPlayerLanguage(object oPlayer, int bReadFromNWNX=FALSE);

//Returns object from hexadecimal ID - basically reverted ObjectToString
object NWNXPatch_GetObjectById(string sId);

//Plays a movie. Note: player needs to run NWN via NWNCX with nwncx_patch and have specified video in movies folder
//void NWNXPatch_PlayMovie(object oPlayer, string sMovieName);

//Returns level at which is nFeat granted by nClass or 0 if its not.
//nClass - CLASS_TYPE_*
//nFeat - FEAT_*
int NWNXPatch_GetIsFeatGranted(int nClass, int nFeat);

//Highligt specific object for player.
//nColor - FOG_COLOR_*
//void NWNXPatch_HighlightObject(object oPlayer, object oObject, int nColor);

//Unhighlight specific object for player
//void NWNXPatch_UnhighlightObject(object oPlayer, object oObject);

//Disable or enable the "highlight all objects" client feature (ie. TAB button).
//void NWNXPatch_SetDisableObjectHighlight(object oPlayer, int bDisable);

//Boots a PC displaying a tlk entry rather than the standard "You have been booted"
//Note: in singleplayer, booting player gives no message either way
void NWNXPatch_BootPCWithMessage(object oPC, int nTlkEntry);

//Returns player bic file name. Doesn't work in localvault/singleplayer mode.
string NWNXPatch_GetPCFileName(object oPC);

//Enables player to cast in polymorph
//Note: polymorph has only two modes, in default mode (nCastingAllowed=0), radial menu won't show normal spells but
//shows polymorph spells such as dragon breath. In the second mode (nCastingAllowed=1) it will show normal spells but
//polymorph specific spells like dragon breath will not be there. Therefore you need to workaround this and add
//polymorph specific spells as feats/special abilities
//void NWNXPatch_SetCanCastInPolymorph(object oPlayer, int nCastingAllowed);

//Dynamically registers nEffectTrueType event to fire for specific object, regardless of settings in effects.2da
//nEffectTrueType - EFFECT_TRUETYPE_*
void NWNXPatch_RegisterEffectEvent(object oObject, int nEffectTrueType);

//Cancels previous effect registration from object, if any.
//nEffectTrueType - EFFECT_TRUETYPE_*
void NWNXPatch_UnregisterEffectEvent(object oObject, int nEffectTrueType);

//returns TRUE if nEffectTrueType event has been registered using NWNXPatch_RegisterEffectEvent function
int NWNXPatch_GetIsEffectEventRegistered(object oObject, int nEffectTrueType);

//Forces update player's character sheet.
void NWNXPatch_UpdateCombatInformation(object oPlayer);

// Gets a value from an INI file on the server and returns it as a string
// avoid using this function in loops
// - sIniFile: path to and full name of the ini fle; "starting" folder is NWN/logs so to get value from nwnplayer.ini, use ./nwnplayer.ini
// - sIniSection: the name of the section in the ini
// - sKey: the name of the key in the ini
// * returns an empty string if file, row, or column not found
string NWNXPatch_GetINIString(string sIniFile, string sIniSection, string sKey);

//This function will shutdown server. It does not save players, so make sure they are booted prior calling this.
void NWNXPatch_ShutdownServer();

//Returns the name of the currently running script.
string NWNXPatch_GetCurrentScriptName(int nDepth=0);

////////////////////////////////////////////////////////////////////////////////
//                            Area Functions                                  //
////////////////////////////////////////////////////////////////////////////////

//Returns number of areas in module+1, -1 on error
int NWNXPatch_GetNumAreas();

//Returns nTh area in module, starting position is 0, OBJECT_INVALID on error
object NWNXPatch_GetNthArea(int nTh);

//Returns area NoRest flag, -1 on error
int NWNXPatch_GetNoRestFlag(object oArea);

//Sets area NoRest flag to desired value
//note: this doesn't work as it should as client will still think rest is disabled
//in area, to workaround this issue either start with rest-enabled or use ActionRest
void NWNXPatch_SetNoRestFlag(object oArea, int bNoRest);

//returns surface material ID used on given position, refers to surfacemat.2da, 0 on error
int NWNXPatch_GetSurfaceMaterial(location lLocation);

//returns nTh (1-3) animloop value (1/0), -1 on error
int NWNXPatch_GetTileAnimLoop(location lLocation, int nTh);

//Sets tile nTh (1-3) animloop value to nValue
void NWNXPatch_SetTileAnimLoop(location lLocation, int nTh, int nValue);

//Returns area PvP settings, -1 on error
int NWNXPatch_GetPvPSettings(object oArea);

//Sets area PvP settings to desired value
void NWNXPatch_SetPvPSettings(object oArea, int nPvP);

//Returns area wind settings, -1 on error
int NWNXPatch_GetAreaWind(object oArea);

//Sets area wind settings to desired value, allowed values: 0,1,2 only
void NWNXPatch_SetAreaWind(object oArea, int nWind);

//Changes area daytime (day,nigh,dusk,dawn) indepentantly on module time.
//Once set, area daytime will no longer update automatically based on module time.
//To revert this behavior use AREA_DAYTIME_RESET_DEFAULT.
//Function has secondary usage, if you specify player object instead of area, only
//given player will see the changes and the actual daytime in area remains same for
//all other players.
//There is no GetAreaDayTime for obvious reasons, to workaround it, you need to
//store previous values using local variables.
//nDayTime - AREA_DAYTIME_*
void NWNXPatch_SetAreaDayTime(object oArea, int nDayTime);

//Returns area ambient color value.
//nType - FOG_TYPE_SUN or FOG_TYPE_MOON
int NWNXPatch_GetAreaAmbientColor(object oArea, int nType);

//Sets area ambient color value.
//nType: FOG_TYPE_*
//nColor: FOG_COLOR_*
//Also, keep in mind that whether the color is changed depends on area setting and actual time.
//If the area is set to always night, you will never be able to make changes to sun colors work.
void NWNXPatch_SetAreaAmbientColor(object oArea, int nType, int nColor);

//Returns area diffuse color value.
//nType - FOG_TYPE_SUN or FOG_TYPE_MOON
int NWNXPatch_GetAreaDiffuseColor(object oArea, int nType);

//Sets area diffuse color value.
//nType: FOG_TYPE_*
//nColor: FOG_COLOR_*
//Also, keep in mind that whether the color is changed depends on area setting and actual time.
//If the area is set to always night, you will never be able to make changes to sun colors work.
void NWNXPatch_SetAreaDiffuseColor(object oArea, int nType, int nColor);

//Returns whether are shadows enabled or not
//nType - FOG_TYPE_SUN or FOG_TYPE_MOON
int NWNXPatch_GetAreaShadowsEnabled(object oArea, int nType);

//Sets whether are shadows enabled or not
//nType - FOG_TYPE_SUN or FOG_TYPE_MOON
void NWNXPatch_SetAreaShadowsEnabled(object oArea, int nType, int bShadowsEnabled);

//Returns chance of lightning in area
int NWNXPatch_GetAreaChanceOfLightning(object oArea);

//Sets chance of lightning in area
//Lightnings only appear during rain weather
void NWNXPatch_SetAreaChanceOfLightning(object oArea, int nChance);

//Returns spot modifier in area
int NWNXPatch_GetAreaSpotModifier(object oArea);

//Sets spot modifier in area
void NWNXPatch_SetAreaSpotModifier(object oArea, int nModifier);

//Returns listen modifier in area
int NWNXPatch_GetAreaListenModifier(object oArea);

//Sets spot modifier in area
void NWNXPatch_SetAreaListenModifier(object oArea, int nModifier);

////////////////////////////////////////////////////////////////////////////////
//                           Object Functions                                 //
////////////////////////////////////////////////////////////////////////////////

//Prints all effects and their values into nwnx_patch.txt logfile (client in "/logs" server in "/logs.0")
void NWNXPatch_DumpEffects(object oObject);

//Directly set object hitpoints to desired value, object gets no feedback of lost/gain hitpoints.
//oObject - creature, placeable, doors
//nHP - must not exceed object maximum hitpoints
void NWNXPatch_SetCurrentHitPoints(object oObject, int nHP);

//Sets object tag. Works on all objects, even players.
void NWNXPatch_SetTag(object oObject, string sTag);

//Sets trap flagged status. Use on trap trigger or trapped object
void NWNXPatch_SetTrapFlagged(object oObject, int bFlagged);

//Sets trap creator. Use on trap trigger or trapped object
void NWNXPatch_SetTrapCreator(object oObject, object oCreator);

//Returns object conversation resref, works on doors, placeables and creatures only
string NWNXPatch_GetConversation(object oObject);

//Sets object conversation resref, works on doors, placeables and creatures only
void NWNXPatch_SetConversation(object oObject, string sConversation);

////////////////////////////////////////////////////////////////////////////////
//                            Item Functions                                  //
////////////////////////////////////////////////////////////////////////////////

//Sets item base item type.
//nBaseItemType - BASE_ITEM_*
//Note: this doesn't work well with client. Item laying on the ground will not change until
//player picks him up or re-enter area. Item in player inventory will not change if player
//have inventory open. You need to make a copy after change and destroy original to avoid this.
void NWNXPatch_SetBaseItemType(object oItem, int nBaseItemType);

//This function marks weapon as finnesable. Finessable weapons allows to count dexterity modifier into attack roll.
void NWNXPatch_SetWeaponIsFinessable(object oWeapon);

//Returns true if the weapon is finessable
int NWNXPatch_GetWeaponIsFinessable(object oWeapon);

//This function marks weapon as monk weapon. Monk weapons allows monk to use unarmed base attack bonus and progression.
void NWNXPatch_SetWeaponIsMonkWeapon(object oWeapon);

//Returns true if the weapon is monk weapon.
int NWNXPatch_GetWeaponIsMonkWeapon(object oWeapon);

//Overrides vanilla item level restriction to specific level.
//Note, this function works only if vanilla ILR is enabled!
void NWNXPatch_SetItemLevelRestriction(object oItem, int nLevel);

//Returns weapon critical threat
//Function is not dependant on oCreature to be valid, can be set without it ie.
//NWNXPatch_GetWeaponCriticalThreat(OBJECT_INVALID,oWeapon); in which case it will
//return weapon critical threat without creature modifiers such as Improved Critical
//or Ki Critical feats.
//To get critical threat for unarmed use valid oCreature and OBJECT_INVALID for
//oWeapon instead.
int NWNXPatch_GetWeaponCriticalThreat(object oCreature, object oWeapon);

//Overrides vanilla weapon critical threat with custom value
//Function is not dependant on oCreature to be valid, can be set without it ie.
//SetWeaponCriticalThreat(OBJECT_INVALID,oWeapon,15);
//To set critical threat for unarmed use valid oCreature and OBJECT_INVALID
//for oWeapon instead.
void NWNXPatch_SetWeaponCriticalThreat(object oCreature, object oWeapon, int nThreat);

//Returns weapon critical multiplier
//Function is not dependant on oCreature to be valid, can be set without it ie.
//NWNXPatch_GetWeaponCriticalMultiplier(OBJECT_INVALID,oWeapon); in which case it will
//return weapon critical multiplier without creature modifiers such Increased
//Multiplier feat
//To get critical threat for unarmed use valid oCreature and OBJECT_INVALID for
//oWeapon instead.
int NWNXPatch_GetWeaponCriticalMultiplier(object oCreature, object oWeapon);

//Overrides vanilla weapon critical multiplier with custom value
//Function is not dependant on oCreature to be valid, can be set without it ie.
//SetWeaponCriticalMultiplier(OBJECT_INVALID,oWeapon,3);
//To set critical multiplier for unarmed use valid oCreature and OBJECT_INVALID
//for oWeapon instead.
void NWNXPatch_SetWeaponCriticalMultiplier(object oCreature, object oWeapon, int nMultiplier);

//Checks if the creature has enough item in inventory to put item into, returns
//true if yes, false otherwise
int NWNXPatch_CheckItemFitsInventory(object oCreature, object oItem);

////////////////////////////////////////////////////////////////////////////////
//                           Trigger Functions                                //
////////////////////////////////////////////////////////////////////////////////



////////////////////////////////////////////////////////////////////////////////
//                          Creature Functions                                //
////////////////////////////////////////////////////////////////////////////////

//Gives creature a new feat.
//nFeat - FEAT_*
//nLevel - set if the feat should be tied with specific level - the feat is then automatically removed when level is lost
void NWNXPatch_AddFeat(object oCreature, int nFeat, int nLevel=0);

//Removes feat from creature.
//bRemoveFromLevel - if TRUE, feat is removed also from any level-up feat lists, when FALSE
//feat will be removed only from general list of feats
void NWNXPatch_RemoveFeat(object oCreature, int nFeat, int bRemoveFromLevel=TRUE);

//returns base AC value
//nType - AC_NATURAL_BONUS, AC_ARMOUR_ENCHANTMENT_BONUS or AC_SHIELD_ENCHANTMENT_BONUS
int NWNXPatch_GetBaseAC(object oCreature, int nType);

//sets base AC value
//nType - AC_NATURAL_BONUS, AC_ARMOUR_ENCHANTMENT_BONUS or AC_SHIELD_ENCHANTMENT_BONUS
//nAC - -127 to +127
void NWNXPatch_SetBaseAC(object oCreature, int nType, int nAC);

//Sets creature size
//nSize - CREATURE_SIZE_*
void NWNXPatch_SetCreatureSize(object oCreature, int nSize);

//Returns creature equippment weight in pounds, -1 on error
int NWNXPatch_GetEquippmentWeight(object oCreature);

//Directly set creature gold to desired value, creature gets no feedback of lost/gain gold.
void NWNXPatch_SetGold(object oCreature, int nGold);

//Returns creature soundset
int NWNXPatch_GetSoundsetId(object oCreature);

//Sets creature soundset
void NWNXPatch_SetSoundsetId(object oCreature, int nSoundset);

//Transports creature to limbo, creatures in limbo runs no scripts, eats no resources
//you can get creature back from limbo with JumpToObject/Location function, you just
//need to keep the creature object
void NWNXPatch_JumpToLimbo(object oCreature);

//Returns the actual speed value.
//bBase - if TRUE returns speed value without feat modifications like monk speed
float NWNXPatch_GetMovementRateFactor(object oCreature, int bBase = FALSE);

//Returns 1 if oFlankedBy is flanking oCreature, 0 if not, -1 on error
int NWNXPatch_GetFlanked(object oCreature, object oFlankedBy);

//Returns 1 if oCreature is flatfooted, 0 if not, -1 on error
int NWNXPatch_GetIsFlatfooted(object oCreature);

//Returns 1 if creature is lighly encumbered, 2 if heavily, 0 if not, -1 on error
int NWNXPatch_GetEncumbranceState(object oCreature);

//Sets creature movement rate
//nMovRate refers to the creaturespeed.2da
void NWNXPatch_SetMovementRate(object oCreature, int nMovRate);

//Cause oAttacker to get Attack of Opportunity on oCreature
//note: this is not guarantee the AoO will happen, it still won't go over AOO limit
//and other restrictions coded inside of the softcoded AoO script 70_s2_aoo
//bAllowRanged = TRUE enables aoo with ranged weapon
void NWNXPatch_BroadcastAttackOfOpportunity(object oCreature, object oAttacker, int bAllowRanged=FALSE);

//Sets creature race. This doesn't change creature appearance, only racial type
//nRace - RACIAL_TYPE_*
void NWNXPatch_SetRacialType(object oCreature, int nRace);

//Directly set creature XP to desired value, creature gets no feedback of lost/gain experiences.
void NWNXPatch_SetXP(object oCreature, int nXP);

//Sets creature age
void NWNXPatch_SetAge(object oCreature, int nAge);

//Sets creature gender
//Warning: from technical limitations, gender is not updated by its appearance until relogging/reloading.
void NWNXPatch_SetGender(object oCreature, int nGender);

//Sets a base ability score to newScore value.
//nAbility - ABILITY_*
//newScore - 3 to 255
void NWNXPatch_SetAbilityScore(object oCreature, int nAbility, int newScore);

//Returns encounter object the creature was spawned from, OBJECT_INVALID if not an encounter creature
object NWNXPatch_GetEncounterFrom(object oCreature);

//Returns BodyBag model id.
int NWNXPatch_GetBodyBag(object oCreature);

//Sets BodyBag model id.
//nBodyBag - 0 to 6, refers to bodybag.2da
void NWNXPatch_SetBodyBag(object oCreature, int nBodyBag);

//Returns Faction ID.
int NWNXPatch_GetFactionId(object oCreature);

//Sets Faction ID.
void NWNXPatch_SetFactionId(object oCreature, int nFactionId);

//Returns starting package.
int NWNXPatch_GetStartingPackage(object oCreature);

//Sets starting package.
void NWNXPatch_SetStartingPackage(object oCreature, int nPackage);

//Removes item from creature without feedback for owner
void NWNXPatch_TakeItemFromCreature(object oCreature, object oItem);

//Causes player to possess creature. Possession has a same limits like familiar possession,
//also it is not recommended to possess non-associates because only associates will show
//the unpossess icon in radial menu.
//Creature possessed with this function can be unpossessed with UnpossessFamiliar function.
void NWNXPatch_PossessCreature(object oPlayer, object oCreature);

//This function returns total damage dealt by oCreature to current target by specific damage type
//Works only in events and scripts firing before damage is applied (OnPreDamage, special attacks)
//nDamageType - DAMAGE_TYPE_*
int NWNXPatch_GetTotalDamageDealtByType(object oCreature, int nDamageType);

//This function allows to set total damage dealt oCreature to current by specific damage type
//Works only in events and scripts firing before damage is applied (OnPreDamage, special attacks)
//Note: adding elemental damage when there was 0 previously will not trigger the usual
//visual effect and sound when hit!
//nDamageType - DAMAGE_TYPE_*
void NWNXPatch_SetTotalDamageDealtByType(object oCreature, int nDamageType, int nDamageAmount);

//This function performs a special attack
//nFeat - FEAT_*
void NWNXPatch_ActionUseSpecialAttack(object oCreature, object oTarget, int nFeat);

//This functions allows to overwrite current attack roll (result of d20()).
//Works only in events and scripts firing before the attack roll is printed into combat log (special attacks)
//nRoll can be 1-255
void NWNXPatch_SetAttackRoll(object oCreature, int nRoll);

//This functions allows to overwrite whether was current attack sneak attack or not
//Works only in events and scripts firing before the attack roll is printed into combat log (special attacks)
//nSneak - 0: disable attack to be sneak attack
//nSneak - 1: set attack to be sneak attack
//nSneak - 2: set attack to be death attack
//nSneak - 3: set attack to be sneak+death attack
void NWNXPatch_SetAttackSneak(object oCreature, int nSneak);

//This functions allows to overwrite current attack critical threat roll (result of d20()).
//Works only in events and scripts firing before the attack roll is printed into combat log (special attacks)
//nRoll can be 1-255
void NWNXPatch_SetAttackCriticalThreatRoll(object oCreature, int nRoll);

//This functions allows to set current attack to behave as killing blow. This is important
//to use for special attacks that kills target to trigger cleave etc.
//Works only in events and scripts firing before damage is applied (OnPreDamage, special attacks)
//bIsKillingBlow can be only TRUE of FALSE
void NWNXPatch_SetAttackKillingBlow(object oCreature, int bIsKillingBlow=TRUE);

//This functions allows to set current attack to behave as coupe de grace.
//Works only in events and scripts firing before damage is applied (OnPreDamage, special attacks)
//bCoupeDeGrace can be only TRUE of FALSE
void NWNXPatch_SetAttackCoupeDeGrace(object oCreature, int bCoupeDeGrace=TRUE);

//returns all extra attack informations stored in engine
//function should be only used in OnPhysicallyAttacked event
struct CombatAttackData NWNXPatch_GetLastAttackCombatData();

//Performs a nNumAttacks number of attacks with currently heald melee weapon against specific target
//Notes:
//- this function will not make any animations, but it will apply the damage and damage visuals
//- attacker doesn't have to be in actual melee range
//- this function should not start combat round; meaning that after using this attacker should be
//able to start normal attack action without need to wait for new round
int NWNXPatch_PerformMeleeAttacks(object oCreature, object oTarget, int nNumAttacks);

//Modifies base arcane spell failure from armor or shield.
//Note: this function should be used after equipping an armor or shield as the spell
//failure is updated when equipping new item.
//nIgnoreType - 1: ignore spell failure from armor
//              2: ignore spell failure from shield
//              other value: ignore spell failure from both
void NWNXPatch_SetSpellFailure(object oCreature, int nFailure, int nType=1);

//Modifies skill check penalty from armor or shield.
//Note: this function should be used after equipping an armor or shield as the skill check
//penalty is updated when equipping new item.
//nIgnoreType - 1: ignore spell failure from armor
//              2: ignore spell failure from shield
//              other value: ignore spell failure from both
void NWNXPatch_SetSkillCheckPenalty(object oCreature, int nPenalty, int nType=1);

//Sets remaining (saved) skill points to a new value.
void NWNXPatch_SetSkillPointsRemaining(object oCreature, int nSkillPoints);

//Returns total bonus to the specific effect type from all bonuses (and penalties) character might have (effects and itemproperties)
//nEffectBonusType - 1: attack increase, 2: damage increase/decrease, 3: saving throw increase/decrease, 4: ability increase/decrease, 5: skill increase/decrease, 6: attack decrease
//oidEffectVersus - object to check Versus bonuses against
//bElementalDamage - unknown
//bForceMax - unknown
//nSaveType - SAVING_THROW_* (for when nEffectBonusType is 3)
//nSpecificType - SAVING_THROW_TYPE_* (for when nEffectBonusType is 3)
//nSkill - SKILL_* (for when nEffectBonusType is 5)
//nAbilityScore - unknown
//bOffHand - unknown
int NWNXPatch_GetTotalEffectBonus(object oCreature, int nEffectBonusType, object oidEffectVersus, int bElementalDamage, int bForceMax, int nSaveType, int nSpecificType, int nSkill, int nAbilityScore, int bOffHand);

//This function allows character to use monk UBAB provided he also uses monk weapon or no weapon in his hand(s).
void NWNXPatch_SetIsUsingMonkAttackTable(object oCreature, int bValue);

////////////////////////////////////////////////////////////////////////////////
//                            Spell Functions                                 //
////////////////////////////////////////////////////////////////////////////////

//This function can change any spell information value, be it spell level, icon, cast visuals or spellscript.
//nSpell - SPELL_*
//sValue - new value, if it should be integer convert it into string
//oPlayer - O
//nConst - specific value that controlls which spell information will be changed, possible values:
//1 - tlk reference to name - matches column Name in spells.2da
//2 - tlk reference to description - matches column SpellDesc
//3 - icon resref - matches column IconResRef
//4 - school - use SPELL_SCHOOL_* constants
//5 - range - matches column Range
//6 - component - matches column VS
//7 - target type - matches column TargetType but value might need to be in decimal format (untested)
//8 - spellscript name - matches column ImpactScript
//9 - bard level - matches column Bard
//10 - cleric level - matches column Cleric
//11 - druid level - matches column Druid
//12 - paladin level - matches column Paladin
//13 - ranger level - matches column Ranger
//14 - sorcerer level
//15 - wizard level
//16 - innate level - matches column Innate
//17 - conjure time - matches column ConjTime
//18 - conjure animation - value is integer unlike spell.2da, exact numeric values are unknown
//19 - ConjHeadVisual
//20 - ConjHandVisual
//21 - ConjGrndVisual
//22 - ConjSoundMale
//23 - ConjSoundFemale
//24 - ConjSoundVFX
//25 - cast animation - value is integer unlike spell.2da, exact numeric values are unknown
//26 - cast time - matches column CastTime
//27 - CastHeadVisual
//28 - CastHandVisual
//29 - CastGrndVisual
//30 - CastSoundVFX
//31 - spawn projectile - matches column Proj
//32 - ProjModel
//33 - projectile type - value is integer unlike spell.2da, exact numeric values are unknown
//34 - projectile spawn point - value is integer unlike spell.2da, exact numeric values are unknown
//35 - ProjSound
//36 - projectile orientation - value is integer unlike spell.2da, exact numeric values are unknown
//37 - immunity type - value is integer but AFAIK this is not used by engine
//38 - ItemImmunity - AFAIK not used by engine
//39 - talent category - matches column Category
//40 - talent max CR - used by NWScript functions, I think it matches InnateLevel by default
//41,42 - not supported yet (subradial spells)
//43 - UseConcentration
//44 - Master
//45 - Counter1
//46 - Counter2
//47 - UserType
//48 - SpontaneouslyCast
//49 - allowed metamagic - matches column MetaMagic but value might need to be in decimal format (untested)
//50 - AltMessage
//51 - HostileSetting
//52 - FeatID
//53 - HasProjectile
//60 - Hidden
void NWNXPatch_SetSpellValue(int nSpell, int nConst, string sValue, object oPlayer=OBJECT_INVALID);

//Returns 1 if oCreature knows specified spell
//nClass - CLASS_TYPE_*
//nSpell - SPELL_*
int NWNXPatch_GetKnowsSpell(object oCreature, int nClass, int nSpell);

//Adds known spell to oCreature
//nClass - CLASS_TYPE_*
//nSpell - SPELL_*
//bIgnoreLimit - unless TRUE, adding a spell will not exceed the maximum number of known spells for given level
void NWNXPatch_AddKnownSpell(object oCreature, int nClass, int nSpell, int bIgnoreLimit=FALSE);

//Removes known spell from oCreature
//nClass - CLASS_TYPE_*
//nSpell - SPELL_*
void NWNXPatch_RemoveKnownSpell(object oCreature, int nClass, int nSpell);

//Returns nTh known spell id of given class and spell level, -1 on error
//nClass - CLASS_TYPE_*
//nSpellLevel - 0-9
int NWNXPatch_GetKnownSpell(object oCreature, int nClass, int nSpellLevel, int nTh);

//Returns spell school the class is specialized into, not neccessarily wizard only
//nClass - CLASS_TYPE_*
int NWNXPatch_GetSpellSchoolSpecialization(object oCreature, int nClass=CLASS_TYPE_WIZARD);

//Sets spell school the class is specialized into, not neccessarily wizard only
//nSchool - SPELL_SCHOOL_*
//nClass - CLASS_TYPE_*
void NWNXPatch_SetSpellSchoolSpecialization(object oCreature, int nSchool, int nClass=CLASS_TYPE_WIZARD);

//Returns class domains, not neccessarily cleric only
//nTh - 1 or 2
//nClass - CLASS_TYPE_*
int NWNXPatch_GetDomain(object oCreature, int nTh, int nClass=CLASS_TYPE_CLERIC);

//Sets class domains, not neccessarily cleric only
//nTh - 1 or 2
//nDomain - refers to domains.2da
//nClass - CLASS_TYPE_*
void NWNXPatch_SetDomain(object oCreature, int nTh, int nDomain, int nClass=CLASS_TYPE_CLERIC);

//Returns nTh memorized spell slot of given class and spell level
//nClass - CLASS_TYPE_*
//nSpellLevel - 0-9
struct MemorizedSpellSlot NWNXPatch_GetMemorisedSpellSlot(object oCreature, int nClass, int nSpellLevel, int nTh);

//Sets memorized spell slot of given class and spell level at nTh position
//nClass - CLASS_TYPE_*
//nSpellLevel - 0-9
void NWNXPatch_SetMemorisedSpellSlot(object oCreature, int nClass, int nSpellLevel, int nTh, struct MemorizedSpellSlot slot);

//Returns total ammount of memorized spell slots for given class and spell level
int NWNXPatch_GetMaxSpellSlots(object oCreature, int nClass, int nSpellLevel);

//Adds or removes bonus spell slot, just as ItemPropertyBonusLevelSpell does
//nClass - CLASS_TYPE_*
//nSpelllevel - 0-9
void NWNXPatch_ModifyNumberBonusSpells(object oCreature, int nClass, int nSpellLevel, int nMod);

////////////////////////////////////////////////////////////////////////////////
//                           Effect Functions                                 //
////////////////////////////////////////////////////////////////////////////////

//This version differs from vanilla function in that it will be able to apply effect on dead target as well
void NWNXPatch_ForceApplyEffectToObject(int nDurationType, effect eEffect, object oTarget, float fDuration=0.0f);

//Changes the effect type.
//Note this cannot be used for effects already present on creature (ie. return from GetFirst/NextEffect).
//It only changes effect inside the NWScript declaration.
//nTrueType - EFFECT_TRUETYPE_*
effect NWNXPatch_SetEffectTrueType(effect eEffect, int nTrueType);

//Changes the effect spell id
//Note this cannot be used for effects already present on creature (ie. return from GetFirst/NextEffect).
//It only changes effect inside the NWScript declaration.
effect NWNXPatch_SetEffectSpellId(effect eEffect, int nSpellId);

//Changes the effect creator
//Note this cannot be used for effects already present on creature (ie. return from GetFirst/NextEffect).
//It only changes effect inside the NWScript declaration.
effect NWNXPatch_SetEffectCreator(effect eEffect, object oCreator);

//Changes the effect caster level. This only affects dispelling.
//Note this cannot be used for effects already present on creature (ie. return from GetFirst/NextEffect).
//It only changes effect inside the NWScript declaration.
effect NWNXPatch_SetEffectCasterLevel(effect eEffect, int nCasterLevel);

//Changes the effect values. There is no list of which effect has how many values and what their means.
//However, integers 0 and 1 are the main integers, ie if the effect function has one or two parameters they
//will get pushed to integer 0 and 1. Integers 2,3,4 are reserved for Versus* functions. Rest is unknown.
//Note this cannot be used for effects already present on creature (ie. return from GetFirst/NextEffect).
//It only changes effect inside the NWScript declaration.
//nTh - 0 to 9 (if the integer can be higher value is unknown)
//nValue - from technical issues only positive number and max 999
effect NWNXPatch_SetEffectInteger(effect eEffect, int nTh, int nValue);

//Sets the effect string. I am not aware of any effect that uses this in vanilla and it has very limited uses.
//Could be probably used to tag effect like in NWN:EE, another usage is to pass some tags/resrefs within effect
//(which is something I needed for dynamic polymorph and why I add this).
effect NWNXPatch_SetEffectString(effect eEffect, int nTh, string sValue);

//NWNX variant of the vanilla function, grants access to all effects, even the system ones.
//Note, GetIsEffectValid will return FALSE for system effects, use NWNXPatch_GetEffectTrueType
//instead to check an effect validity, invalid effect will return EFFECT_TRUETYPE_INVALIDEFFECT
effect NWNXPatch_GetFirstEffect(object oObject);

//NWNX variant of the vanilla function, grants access to all effects, even the system ones.
//Note, GetIsEffectValid will return FALSE for system effects, use NWNXPatch_GetEffectTrueType
//instead to check an effect validity, invalid effect will return EFFECT_TRUETYPE_INVALIDEFFECT
effect NWNXPatch_GetNextEffect(object oObject);

//Returns effect EFFECT_TRUETYPE_* constant. Usefull for dealing with effects returning
//EFFECT_TYPE_INVALIDEFFECT such as knockdown or taunt or custom effects like NWNXPatch_EffectModifyBAB
int NWNXPatch_GetEffectTrueType(effect eEffect);

//Returns caster level of the effect
int NWNXPatch_GetEffectCasterLevel(effect eEffect);

//Returns effect integer.
//nTh - 0 to 9 (if the integer can be higher value is unknown)
//Example, if used on effect temp = EffectAbilityIncrease(ABILITY_DEXTERITY,5);
//NWNXPatch_GetEffectInteger(temp,0) = 1 (ABILITY_DEXTERITY)
//NWNXPatch_GetEffectInteger(temp,1) = 5
int NWNXPatch_GetEffectInteger(effect eEffect, int nTh);

//Returns effect remaining duration.
float NWNXPatch_GetEffectRemainingDuration(effect eEffect);

//Makes effect ignore the usual cap limit.
//currently supported effects:
// - EffectAttackIncrease
// - EffectAbilityIncrease
// - EffectSavingThrowIncrease
// - EffectSkillIncrease
effect NWNXPatch_UncappedEffect(effect eEffect);

//Create an effect which will modify/replace pre-epic BAB
//nBaseAttackBonus - 1-20 althought values above 20 are allowed its untested
effect NWNXPatch_EffectModifyBAB(int nBaseAttackBonus);

//Create an effect that will allow ignore base spell failure from armor or shield
//nIgnoreType - 1: ignore spell failure from armor
//              2: ignore spell failure from shield
//              other value: ignore spell failure from both
//nClassOnly - CLASS_TYPE_* - effect will work only for specified class
//           - CLASS_TYPE_INVALID - effect will work for all classes
effect NWNXPatch_EffectIgnoreArcaneSpellFailure(int nIgnoreType=1, int nClassOnly=CLASS_TYPE_INVALID);

//Create a Spell Level Immunity effect.
// - nSpellLevel: maximum spell level that will be absorbed by the effect
// - nSpellSchool: SPELL_SCHOOL_*
effect NWNXPatch_EffectSpellLevelImmunity(int nSpellLevel, int nSpellSchool=SPELL_SCHOOL_GENERAL);

//Create a Bonus Feat effect. Note this function can grant any feat, not just those that
//can be granted by itemproperty.
// - nFeat - FEAT_*
effect NWNXPatch_EffectBonusFeat(int nFeat);

//Create an Icon effect.
//nIcon - row value from effecticons.2da
effect NWNXPatch_EffectIcon(int nIcon);

//Alternative version of vanilla EffectPolymorph - this allows to create custom polymorph on the fly without changing 2DA
effect NWNXPatch_EffectPolymorph(int nAppearanceType, int bLocked, int nRacialType, int nPortraitId, int nSTR, int nCON, int nDEX, int nACBonus, int nBonusHP, string sEquippedWeapon, string sCreatureWeapon1, string sCreatureWeapon2, string sCreatureWeapon3, string sCreatureSkin, int nSpell1 = -1, int nSpell2 = -1, int nSpell3 = -1);

//Special custom options for EffectPolymorph, works with both vanilla EffectPolymorph and NWNXPatch_EffectPolymorph
//nACType - AC_*_BONUS
//bReplaceAbilityOnlyWhenHigher - if TRUE then the ability values will be replaced only when the value from polymorph is higher
//bKeepItems - if TRUE, polymorphing will not affect equipped items; however, if this option is set then the standard polymorph items like creature weapons and creature skin won't be equipped as well
effect NWNXPatch_EffectPolymorphOptions(effect ePolymorph, int nACType = AC_DODGE_BONUS, int bReplaceAbilityOnlyWhenHigher=FALSE, int bKeepItems=FALSE);


//returns effect getting applied or removed
//function should be only used in 70_mod_effects script
effect NWNXPatch_GetEffectEventEffect();

//Copies values from eEffect into the original effect in engine.
//This is usefull if you want to modify effect before its application/removal.
//Works only inside 70_mod_effects script/event
void NWNXPatch_TransferEffectValues(effect eEffect);

//Copies values from eEffect into the nTh effect on oTarget, this is the only way how to
//modify a value inside actual effect on object.
//Usage note: you need to know the position of the effect on the target. To do that, you
//need to calculate it manually inside getfirst/getnext loop. Note - first effect is 1 not 0.
//Functionality note: it is not certain this will really do what you want to do. Some effects
//grants their benefit when applied directly and thus changing their values won't produce anz
//effect. It should work with at least these effects: ability increase/decrease, ac increase/
//decrease, concealment, miss chance, saving throw increase/decrease, skill increase/decrease,
//spell level absorption. It might work on more effects but you need to test this yourself.
void NWNXPatch_TransferEffectValuesIntoNthEffect(effect eEffect, object oTarget, int nTh);

////////////////////////////////////////////////////////////////////////////////
//                        Variable based functions                            //
////////////////////////////////////////////////////////////////////////////////

//Sets number of attacks of opportunity that creature can perform each round.
void NWNXPatch_SetNumberOfAOOs(object oCreature, int nMaxAOO);
//Returns value set by SetNumberOfAOOs, 0 by default
int NWNXPatch_GetNumberOfAOOs(object oCreature);
//Sets number of epic dodges that creature can perform each round.
void NWNXPatch_SetNumberOfEpicDodges(object oCreature, int nMaxED);
//Returns value set by SetNumberOfEpicDodges, 0 by default
int NWNXPatch_GetNumberOfEpicDodges(object oCreature);
//Sets number of deflect arrows that creature can perform each round.
void NWNXPatch_SetNumberOfDeflectArrows(object oCreature, int nMaxDeflect);
//Returns value set by SetNumberOfDeflectArrows, 0 by default
int NWNXPatch_GetNumberOfDeflectArrows(object oCreature);
//Sets value that will get added into favored enemy strength calculation.
void NWNXPatch_SetFavoredEnemyModifier(object oCreature, int nMod);
//Returns value set by SetNumberOfAOOs, 0 by default
int NWNXPatch_GetFavoredEnemyModifier(object oCreature);
//Modify AC bonus granted from tumble
void NWNXPatch_SetTumbleACBonus(object oCreature, int nAC);
//Overrides unarmed damage dice, set 0 to remove override and get vanilla damage
void NWNXPatch_SetUnarmedDamageDiceOverride(object oCreature, int nDamageDice);
//Overrides unarmed damage die, set 0 to remove override and get vanilla damage
void NWNXPatch_SetUnarmedDamageDieOverride(object oCreature, int nDamageDie);
//Overrides unarmed damage type, set 0 to remove override and get vanilla damage
//nDamageType - DAMAGE_TYPE_*
void NWNXPatch_SetUnarmedDamageTypeOverride(object oCreature, int nDamageType);
//Overrides the length of the round after casting spell from an item.
//Default values are 3000 (half the round) for potions and 6000 (full round) for
//any other item. Recommended value for no pause is 1000.
//Set 0 to force vanilla casting speed.
void NWNXPatch_SetItemCastSpeed(object oItem, int nCastingSpeedValue);
//Adds nBonusDice(d6) to the sneak damage calculation
void NWNXPatch_SetSneakDamageBonus(object oCreature, int nBonusDice);
//This function forces engine to return your value whenever engine check whether is creature immune to something
//Use RemoveImmunityOverride to restore vanilla behavior
//nImmunityType - IMMUNITY_TYPE_*
//bResult - 0: false, 1: true
void NWNXPatch_SetImmunityOverride(object oCreature, int nImmunityType, int bResult);

//This function deletes immunity override applied with SetImmunityOverride
void NWNXPatch_RemoveImmunityOverride(object oCreature, int nImmunityType);

//This function overrides total (max) uses of feat. This can be used on any feat even feat that normally has unlimited uses such as Divine Might
//nFeat - FEAT_*
//nUses - 0-99, value 100 makes feat unlimited
//Note that feats will most likely be restored to incorrect value after restart. You need to workaround this issue with your own code to restore
//feat uses after relog.
void NWNXPatch_SetFeatTotalUses(object oCreature, int nFeat, int nUses);

//This function overrides base will saving throw, that is saving throw value calculated from class levels without modifiers from feat/effects
//nSavingThrow - SAVING_THROW_REFLEX, SAVING_THROW_FORT or SAVING_THROW_WILL
//nNewBase - -127 to +127
void NWNXPatch_SetSavingThrowBase(object oCreature, int nSavingThrow, int nNewBase);

//Sets value that will get added into saving throw value calculation.
//nSavingThrow - SAVING_THROW_REFLEX, SAVING_THROW_FORT or SAVING_THROW_WILL
//nModifyBy - any value however, saving throws are capped to -127 / +127
void NWNXPatch_SetSavingThrowModifier(object oCreature, int nSavingThrow, int nModifyBy);
//Sets value that will get added into initiative roll calculation.
void NWNXPatch_SetInitiativeModifier(object oCreature, int nModifyBy);
//Sets value that will get added into creature total speed calculation.
void NWNXPatch_SetMovementRateFactorModifier(object oCreature, float fModifyBy);
//Returns -2 if the damage comes from combat, -1 if the damage doesn't come from spell or combat or spell id if the damage comes from spell
//Function will work properly only in OnDamaged event
int NWNXPatch_GetDamageDealtSpellId();

int NWNXPatch_GetDamageDealtSpellId()
{
return GetLocalInt(OBJECT_SELF,"GetDamageDealtSpellId");
}

void NWNXPatch_SetWeaponIsFinessable(object oWeapon)
{
SetLocalInt(oWeapon,"finesse",1);
}

int NWNXPatch_GetWeaponIsFinessable(object oWeapon)
{
int mod = GetLocalInt(oWeapon,"finesse");
 if(!mod)
 {
  switch(GetBaseItemType(oWeapon))
  {
  case BASE_ITEM_DAGGER:
  case BASE_ITEM_HANDAXE:
  case BASE_ITEM_KAMA:
  case BASE_ITEM_KUKRI:
  case BASE_ITEM_LIGHTHAMMER:
  case BASE_ITEM_LIGHTMACE:
  case BASE_ITEM_RAPIER:
  case BASE_ITEM_SICKLE:
  case BASE_ITEM_WHIP:
  case BASE_ITEM_INVALID:
  return TRUE;
  }
 }
return mod;
}

void NWNXPatch_SetWeaponIsMonkWeapon(object oWeapon)
{
SetLocalInt(oWeapon,"ubab",1);
}

int NWNXPatch_GetWeaponIsMonkWeapon(object oWeapon)
{
int mod = GetLocalInt(oWeapon,"ubab");
 if(!mod)
 {
  switch(GetBaseItemType(oWeapon))
  {
  case BASE_ITEM_KAMA:
  case BASE_ITEM_INVALID:
  return TRUE;
  }
 }
return mod;
}

void NWNXPatch_SetIsUsingMonkAttackTable(object oCreature, int bValue)
{
 if(bValue) SetLocalInt(oCreature,"ubab",TRUE);
 else DeleteLocalInt(oCreature,"ubab");
 if(GetIsPC(oCreature)) NWNXPatch_UpdateCombatInformation(oCreature);
}

void NWNXPatch_SetNumberOfAOOs(object oCreature, int nMaxAOO)
{
SetLocalInt(oCreature,"NUM_AOO",nMaxAOO);
}

int NWNXPatch_GetNumberOfAOOs(object oCreature)
{
return GetLocalInt(oCreature,"NUM_AOO");
}

void NWNXPatch_SetNumberOfEpicDodges(object oCreature, int nMaxED)
{
SetLocalInt(oCreature,"NUM_ED",nMaxED);
}

int NWNXPatch_GetNumberOfEpicDodges(object oCreature)
{
return GetLocalInt(oCreature,"NUM_ED");
}

void NWNXPatch_SetNumberOfDeflectArrows(object oCreature, int nMaxDeflect)
{
SetLocalInt(oCreature,"NUM_DEFLECT",nMaxDeflect);
}

int NWNXPatch_GetNumberOfDeflectArrows(object oCreature)
{
return GetLocalInt(oCreature,"NUM_DEFLECT");
}

void NWNXPatch_SetFavoredEnemyModifier(object oCreature, int nMod)
{
SetLocalInt(oCreature,"FE_MODIFIER",nMod);
}

int NWNXPatch_GetFavoredEnemyModifier(object oCreature)
{
return GetLocalInt(oCreature,"FE_MODIFIER");
}

void NWNXPatch_SetTumbleACBonus(object oCreature, int nAC)
{
SetLocalInt(oCreature,"TumbleAC",nAC);
}

void NWNXPatch_SetItemLevelRestriction(object oItem, int nLevel)
{
SetLocalInt(oItem,"CILR",nLevel);
}

void NWNXPatch_SetSavingThrowBase(object oCreature, int nSavingThrow, int nNewBase)
{
 if(nSavingThrow == SAVING_THROW_REFLEX)
 {
 SetLocalInt(oCreature,"ReflexSaveOverride",nNewBase);
 }
 else if(nSavingThrow == SAVING_THROW_FORT)
 {
 SetLocalInt(oCreature,"FortitudeSaveOverride",nNewBase);
 }
 else if(nSavingThrow == SAVING_THROW_WILL)
 {
 SetLocalInt(oCreature,"WillSaveOverride",nNewBase);
 }
}

void NWNXPatch_SetSavingThrowModifier(object oCreature, int nSavingThrow, int nModifyBy)
{
 if(nSavingThrow == SAVING_THROW_REFLEX)
 {
 SetLocalInt(oCreature,"ReflexSaveModifier",nModifyBy);
 }
 else if(nSavingThrow == SAVING_THROW_FORT)
 {
 SetLocalInt(oCreature,"FortitudeSaveModifier",nModifyBy);
 }
 else if(nSavingThrow == SAVING_THROW_WILL)
 {
 SetLocalInt(oCreature,"WillSaveModifier",nModifyBy);
 }
}

void NWNXPatch_SetInitiativeModifier(object oCreature, int nModifyBy)
{
SetLocalInt(oCreature,"InitiativeModifier",nModifyBy);
}

void NWNXPatch_SetMovementRateFactorModifier(object oCreature, float fModifyBy)
{
 if(fModifyBy != 0.0)
 {
 SetLocalFloat(oCreature,"MovementRateFactorModifier",fModifyBy);
 }
 else
 {
 DeleteLocalFloat(oCreature,"MovementRateFactorModifier");
 }
}

void NWNXPatch_SetImmunityOverride(object oCreature, int nImmunityType, int bResult)
{
SetLocalInt(oCreature,"IMMUNITY_OVERRIDE_"+IntToString(nImmunityType),!bResult ? 0 : 1);
}

void NWNXPatch_RemoveImmunityOverride(object oCreature, int nImmunityType)
{
DeleteLocalInt(oCreature,"IMMUNITY_OVERRIDE_"+IntToString(nImmunityType));
}

void NWNXPatch_SetUnarmedDamageDiceOverride(object oCreature, int nDamageDice)
{
SetLocalInt(oCreature,"UnarmedDiceOverride",nDamageDice);
}

void NWNXPatch_SetUnarmedDamageDieOverride(object oCreature, int nDamageDie)
{
SetLocalInt(oCreature,"UnarmedDieOverride",nDamageDie);
}

void NWNXPatch_SetUnarmedDamageTypeOverride(object oCreature, int nDamageType)
{
SetLocalInt(oCreature,"UnarmedTypeOverride",nDamageType);
}

void NWNXPatch_SetFeatTotalUses(object oCreature, int nFeat, int nUses)
{
SetLocalInt(oCreature,"GetFeatTotalUses_"+IntToString(nFeat),nUses);
}

void NWNXPatch_SetItemCastSpeed(object oItem, int nCastingSpeedValue)
{
    if(nCastingSpeedValue < 1)
    {
        DeleteLocalInt(oItem,"ItemCastSpeedOverride");
    }
    else
    {
        SetLocalInt(oItem,"ItemCastSpeedOverride",nCastingSpeedValue);
    }
}

void NWNXPatch_SetSneakDamageBonus(object oCreature, int nBonusDice)
{
    if(nBonusDice < 1)
    {
        DeleteLocalInt(oCreature,"SneakAttackBonus");
    }
    else
    {
        SetLocalInt(oCreature,"SneakAttackBonus",nBonusDice);
    }
}

void NWNXPatch_RegisterEffectEvent(object oObject, int nEffectTrueType)
{
    SetLocalInt(oObject,IntToString(nEffectTrueType)+"_EffectRegistered",2);
}

void NWNXPatch_UnregisterEffectEvent(object oObject, int nEffectTrueType)
{
    SetLocalInt(oObject,IntToString(nEffectTrueType)+"_EffectRegistered",FALSE);
}

int NWNXPatch_GetIsEffectEventRegistered(object oObject, int nEffectTrueType)
{
    return GetLocalInt(oObject,IntToString(nEffectTrueType)+"_EffectRegistered");
}

////////////////////////////////////////////////////////////////////////////////
int NWNXPatch_IsInUse()
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!12",".");
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!12");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

int NWNXPatch_GetPlayerLanguage(object oPlayer, int bReadFromNWNX=FALSE)
{
    if(!bReadFromNWNX)
    {
        int nValue = GetLocalInt(oPlayer,"GetPlayerLanguage")-1;
        if(nValue > -1)
        {
            return nValue;
        }
    }
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!1",ObjectToString(oPlayer));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!1");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    if(retVal > -1)
    {
        SetLocalInt(oPlayer,"GetPlayerLanguage",retVal+1);
    }
    return retVal;
}

object NWNXPatch_GetObjectById(string sId)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!2",sId);
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!2");
    object oObject = GetLocalObject(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalObject(GetModule(),"NWNXPATCH_RESULT");
    return oObject;
}

/*
void NWNXPatch_PlayMovie(object oPlayer, string sMovieName)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!3",ObjectToString(oPlayer)+"|"+sMovieName);
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!3");
}
*/

void NWNXPatch_BootPCWithMessage(object oPC, int nTlkEntry)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!4",ObjectToString(oPC)+"|"+IntToString(nTlkEntry));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!4");
}

string NWNXPatch_GetPCFileName(object oPC)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!5",ObjectToString(oPC));
    string sBic = GetLocalString(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalString(GetModule(),"NWNXPATCH_RESULT");
    return sBic;
}

/*
void NWNXPatch_SetCanCastInPolymorph(object oPlayer, int nCastingAllowed)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!6",ObjectToString(oPlayer)+"|"+IntToString(nCastingAllowed != FALSE));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!6");
}
*/

int NWNXPatch_GetIsFeatGranted(int nClass, int nFeat)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!7",IntToString(nClass)+"|"+IntToString(nFeat));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!7");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

/*
void NWNXPatch_HighlightObject(object oPlayer, object oObject, int nColor)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!8",ObjectToString(oPlayer)+"|"+ObjectToString(oObject)+"|"+IntToString(nColor));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!8");
}

int NWNXPatch_VerifyClientRunningNWNCX(object oPlayer)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!9",ObjectToString(oPlayer));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!9");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

void NWNXPatch_UnhighlightObject(object oPlayer, object oObject)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!10",ObjectToString(oPlayer)+"|"+ObjectToString(oObject));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!10");
}

void NWNXPatch_SetDisableObjectHighlight(object oPlayer, int bDisable)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!11",ObjectToString(oPlayer)+"|"+IntToString(bDisable));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!11");
}
*/

void NWNXPatch_UpdateCombatInformation(object oPlayer)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!16",ObjectToString(oPlayer));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!16");
}

string NWNXPatch_GetINIString(string sIniFile, string sIniSection, string sKey)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!17",sIniFile+"|"+sIniSection+"|"+sKey);
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!17");
    string retVal = GetLocalString(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalString(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

void NWNXPatch_SetSpellValue(int nSpell, int nConst, string sValue, object oPlayer=OBJECT_INVALID)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!13",ObjectToString(oPlayer)+"|"+IntToString(nSpell)+"|"+IntToString(nConst)+"|"+sValue);
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!13");
}

int NWNXPatch_GetNumAreas()
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!101",".");
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!101");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

object NWNXPatch_GetNthArea(int nTh)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!102",IntToString(nTh));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!102");
    object oArea = GetLocalObject(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalObject(GetModule(),"NWNXPATCH_RESULT");
    return oArea;
}

int NWNXPatch_GetNoRestFlag(object oArea)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!103",ObjectToString(oArea));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!103");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

void NWNXPatch_SetNoRestFlag(object oArea, int bNoRest)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!104",ObjectToString(oArea)+"|"+IntToString(bNoRest));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!104");
}

int NWNXPatch_GetSurfaceMaterial(location lLocation)
{
    return GetSurfaceMaterial(lLocation);
}

int NWNXPatch_GetPvPSettings(object oArea)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!106",ObjectToString(oArea));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!106");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

void NWNXPatch_SetPvPSettings(object oArea, int nPvP)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!107",ObjectToString(oArea)+"|"+IntToString(nPvP));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!107");
}

int NWNXPatch_GetTileAnimLoop(location lLocation, int nTh)
{
    object oArea = GetAreaFromLocation(lLocation);
    if(GetIsObjectValid(oArea))
    {
        vector v = GetPositionFromLocation(lLocation);
        SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!108",ObjectToString(oArea)+"|"+FloatToString(v.x)+"|"+FloatToString(v.y)+"|"+FloatToString(v.z)+"|"+IntToString(nTh));
        DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!108");
        int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
        DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
        return retVal;
    }
    return -1;
}

void NWNXPatch_SetTileAnimLoop(location lLocation, int nTh, int nValue)
{
    object oArea = GetAreaFromLocation(lLocation);
    if(GetIsObjectValid(oArea))
    {
        vector v = GetPositionFromLocation(lLocation);
        SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!109",ObjectToString(oArea)+"|"+FloatToString(v.x)+"|"+FloatToString(v.y)+"|"+FloatToString(v.z)+"|"+IntToString(nTh)+"|"+IntToString(nValue));
        DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!109");
    }
}

int NWNXPatch_GetAreaWind(object oArea)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!110",ObjectToString(oArea));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!110");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

void NWNXPatch_SetAreaWind(object oArea, int nWind)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!111",ObjectToString(oArea)+"|"+IntToString(nWind));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!111");
}

void NWNXPatch_SetAreaDayTime(object oArea, int nDayTime)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!112",ObjectToString(oArea)+"|"+IntToString(nDayTime));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!112");
}

int NWNXPatch_GetAreaAmbientColor(object oArea, int nType)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!113",ObjectToString(oArea)+"|"+IntToString(nType));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!113");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

void NWNXPatch_SetAreaAmbientColor(object oArea, int nType, int nColor)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!114",ObjectToString(oArea)+"|"+IntToString(nType)+"|"+IntToString(nColor));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!114");
}

int NWNXPatch_GetAreaDiffuseColor(object oArea, int nType)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!115",ObjectToString(oArea)+"|"+IntToString(nType));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!115");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

void NWNXPatch_SetAreaDiffuseColor(object oArea, int nType, int nColor)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!116",ObjectToString(oArea)+"|"+IntToString(nType)+"|"+IntToString(nColor));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!116");
}

int NWNXPatch_GetAreaShadowsEnabled(object oArea, int nType)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!117",ObjectToString(oArea)+"|"+IntToString(nType));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!117");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

void NWNXPatch_SetAreaShadowsEnabled(object oArea, int nType, int bShadowsEnabled)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!118",ObjectToString(oArea)+"|"+IntToString(nType)+"|"+IntToString(bShadowsEnabled));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!118");
}

int NWNXPatch_GetAreaChanceOfLightning(object oArea)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!119",ObjectToString(oArea));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!119");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

void NWNXPatch_SetAreaChanceOfLightning(object oArea, int nChance)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!120",ObjectToString(oArea)+"|"+IntToString(nChance));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!120");
}

int NWNXPatch_GetAreaSpotModifier(object oArea)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!121",ObjectToString(oArea));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!121");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

void NWNXPatch_SetAreaSpotModifier(object oArea, int nModifier)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!122",ObjectToString(oArea)+"|"+IntToString(nModifier));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!122");
}

int NWNXPatch_GetAreaListenModifier(object oArea)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!123",ObjectToString(oArea));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!123");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

void NWNXPatch_SetAreaListenModifier(object oArea, int nModifier)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!124",ObjectToString(oArea)+"|"+IntToString(nModifier));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!124");
}

void NWNXPatch_DumpEffects(object oObject)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!201",ObjectToString(oObject));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!201");
}

void NWNXPatch_SetCurrentHitPoints(object oObject, int nHP)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!202",ObjectToString(oObject)+"|"+IntToString(nHP));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!202");
}

void NWNXPatch_SetTag(object oObject, string sTag)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!203",ObjectToString(oObject)+"|"+sTag);
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!203");
}

void NWNXPatch_SetTrapFlagged(object oObject, int bFlagged)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!204",ObjectToString(oObject)+"|"+IntToString(bFlagged));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!204");
}

void NWNXPatch_SetTrapCreator(object oObject, object oCreator)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!205",ObjectToString(oObject)+"|"+ObjectToString(oCreator));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!205");
}

string NWNXPatch_GetConversation(object oObject)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!206",ObjectToString(oObject));
    string sBic = GetLocalString(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalString(GetModule(),"NWNXPATCH_RESULT");
    return sBic;
}

void NWNXPatch_SetConversation(object oObject, string sConversation)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!207",ObjectToString(oObject)+"|"+sConversation);
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!207");
}


void NWNXPatch_SetBaseItemType(object oItem, int nBaseItemType)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!301",ObjectToString(oItem)+"|"+IntToString(nBaseItemType));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!301");
}

int NWNXPatch_GetWeaponCriticalThreat(object oCreature, object oWeapon)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!302",ObjectToString(oCreature)+"|"+ObjectToString(oWeapon));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!302");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

void NWNXPatch_SetWeaponCriticalThreat(object oCreature, object oWeapon, int nThreat)
{
    if(!nThreat)
    {
        DeleteLocalInt(GetIsObjectValid(oWeapon) ? oWeapon : oCreature,"CriticalThreatOverride");
    }
    else if(nThreat > 0 && nThreat < 21)
    {
        SetLocalInt(GetIsObjectValid(oWeapon) ? oWeapon : oCreature,"CriticalThreatOverride",nThreat);
    }
}

int NWNXPatch_GetWeaponCriticalMultiplier(object oCreature, object oWeapon)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!303",ObjectToString(oCreature)+"|"+ObjectToString(oWeapon));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!303");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

int NWNXPatch_CheckItemFitsInventory(object oCreature, object oItem)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!304",ObjectToString(oCreature)+"|"+ObjectToString(oItem));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!304");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

void NWNXPatch_SetWeaponCriticalMultiplier(object oCreature, object oWeapon, int nMultiplier)
{
    if(!nMultiplier)
    {
        DeleteLocalInt(GetIsObjectValid(oWeapon) ? oWeapon : oCreature,"CriticalMultiplierOverride");
    }
    else if(nMultiplier > 0)
    {
        SetLocalInt(GetIsObjectValid(oWeapon) ? oWeapon : oCreature,"CriticalMultiplierOverride",nMultiplier);
    }
}

void NWNXPatch_SetCreatureSize(object oCreature, int nSize)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!401",ObjectToString(oCreature)+"|"+IntToString(nSize));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!401");
}

int NWNXPatch_GetEquippmentWeight(object oCreature)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!402",ObjectToString(oCreature));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!402");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

void NWNXPatch_SetGold(object oCreature, int nGold)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!403",ObjectToString(oCreature)+"|"+IntToString(nGold));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!403");
}

int NWNXPatch_GetSoundsetId(object oCreature)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!404",ObjectToString(oCreature));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!404");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

void NWNXPatch_SetSoundsetId(object oCreature, int nSoundset)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!405",ObjectToString(oCreature)+"|"+IntToString(nSoundset));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!405");
}

void NWNXPatch_JumpToLimbo(object oCreature)
{
    if(!GetIsPC(oCreature))
    {
        SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!406",ObjectToString(oCreature));
        DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!406");
    }
}

float NWNXPatch_GetMovementRateFactor(object oCreature, int bBase=FALSE)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!407",ObjectToString(oCreature)+"|"+IntToString(bBase));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!407");
    float retVal = GetLocalFloat(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalFloat(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

int NWNXPatch_GetFlanked(object oCreature, object oFlankedBy)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!408",ObjectToString(oCreature)+"|"+ObjectToString(oFlankedBy));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!408");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

int NWNXPatch_GetIsFlatfooted(object oCreature)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!409",ObjectToString(oCreature));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!409");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

int NWNXPatch_GetEncumbranceState(object oCreature)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!410",ObjectToString(oCreature));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!410");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

void NWNXPatch_SetMovementRate(object oCreature, int nMovRate)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!411",ObjectToString(oCreature)+"|"+IntToString(nMovRate));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!411");
}

void NWNXPatch_BroadcastAttackOfOpportunity(object oCreature, object oAttacker, int bAllowRanged=FALSE)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!412",ObjectToString(oCreature)+"|"+ObjectToString(oAttacker)+"|"+IntToString(bAllowRanged));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!412");
}

void NWNXPatch_SetRacialType(object oCreature, int nRace)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!415",ObjectToString(oCreature)+"|"+IntToString(nRace));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!415");
}

void NWNXPatch_SetXP(object oCreature, int nXP)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!416",ObjectToString(oCreature)+"|"+IntToString(nXP));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!416");
}

void NWNXPatch_SetAge(object oCreature, int nAge)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!417",ObjectToString(oCreature)+"|"+IntToString(nAge));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!417");
}

void NWNXPatch_SetGender(object oCreature, int nGender)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!418",ObjectToString(oCreature)+"|"+IntToString(nGender));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!418");
}

void NWNXPatch_SetAbilityScore(object oCreature, int nAbility, int newScore)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!419",ObjectToString(oCreature)+"|"+IntToString(nAbility)+"|"+IntToString(newScore));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!419");
}

object NWNXPatch_GetEncounterFrom(object oCreature)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!422",ObjectToString(oCreature));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!422");
    object retVal = GetLocalObject(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalObject(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

int NWNXPatch_GetBodyBag(object oCreature)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!423",ObjectToString(oCreature));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!423");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

void NWNXPatch_SetBodyBag(object oCreature, int nBodyBag)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!424",ObjectToString(oCreature)+"|"+IntToString(nBodyBag));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!424");
}

int NWNXPatch_GetFactionId(object oCreature)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!425",ObjectToString(oCreature));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!425");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

void NWNXPatch_SetFactionId(object oCreature, int nFactionId)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!426",ObjectToString(oCreature)+"|"+IntToString(nFactionId));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!426");
}

int NWNXPatch_GetStartingPackage(object oCreature)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!438",ObjectToString(oCreature));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!438");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

void NWNXPatch_SetStartingPackage(object oCreature, int nPackage)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!439",ObjectToString(oCreature)+"|"+IntToString(nPackage));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!439");
}

void NWNXPatch_TakeItemFromCreature(object oCreature, object oItem)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!440",ObjectToString(oCreature)+"|"+ObjectToString(oItem));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!440");
}

int NWNXPatch_GetBaseAC(object oCreature, int nType)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!441",ObjectToString(oCreature)+"|"+IntToString(nType));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!441");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

void NWNXPatch_SetBaseAC(object oCreature, int nType, int nAC)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!442",ObjectToString(oCreature)+"|"+IntToString(nType)+"|"+IntToString(nAC));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!442");
}

void NWNXPatch_PossessCreature(object oPlayer, object oCreature)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!427",ObjectToString(oPlayer)+"|"+ObjectToString(oCreature));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!427");
}

int NWNXPatch_GetTotalDamageDealtByType(object oCreature, int nDamageType)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!429",ObjectToString(oCreature)+"|"+IntToString(nDamageType));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!429");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

void NWNXPatch_SetTotalDamageDealtByType(object oCreature, int nDamageType, int nDamageAmount)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!430",ObjectToString(oCreature)+"|"+IntToString(nDamageType)+"|"+IntToString(nDamageAmount));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!430");
}

void NWNXPatch_ActionUseSpecialAttack(object oCreature, object oTarget, int nFeat)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!431",ObjectToString(oCreature)+"|"+ObjectToString(oTarget)+"|"+IntToString(nFeat));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!431");
}

void NWNXPatch_SetAttackRoll(object oCreature, int nRoll)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!432",ObjectToString(oCreature)+"|"+IntToString(nRoll));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!432");
}

void NWNXPatch_SetAttackSneak(object oCreature, int nSneak)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!433",ObjectToString(oCreature)+"|"+IntToString(nSneak));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!433");
}

void NWNXPatch_SetAttackCriticalThreatRoll(object oCreature, int nRoll)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!434",ObjectToString(oCreature)+"|"+IntToString(nRoll));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!434");
}

void NWNXPatch_SetAttackKillingBlow(object oCreature, int bIsKillingBlow=TRUE)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!435",ObjectToString(oCreature)+"|"+IntToString(bIsKillingBlow));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!435");
}

void NWNXPatch_SetAttackCoupeDeGrace(object oCreature, int bCoupeDeGrace=TRUE)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!436",ObjectToString(oCreature)+"|"+IntToString(bCoupeDeGrace));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!436");
}

int NWNXPatch_GetKnowsSpell(object oCreature, int nClass, int nSpell)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!501",ObjectToString(oCreature)+"|"+IntToString(nClass)+"|"+IntToString(nSpell));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!501");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

void NWNXPatch_AddKnownSpell(object oCreature, int nClass, int nSpell, int bIgnoreLimit=FALSE)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!502",ObjectToString(oCreature)+"|"+IntToString(nClass)+"|"+IntToString(nSpell)+"|"+IntToString(bIgnoreLimit));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!502");
}

void NWNXPatch_RemoveKnownSpell(object oCreature, int nClass, int nSpell)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!503",ObjectToString(oCreature)+"|"+IntToString(nClass)+"|"+IntToString(nSpell));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!503");
}

int NWNXPatch_GetKnownSpell(object oCreature, int nClass, int nSpellLevel, int nTh)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!504",ObjectToString(oCreature)+"|"+IntToString(nClass)+"|"+IntToString(nSpellLevel)+"|"+IntToString(nTh));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!504");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

int NWNXPatch_GetSpellSchoolSpecialization(object oCreature, int nClass=CLASS_TYPE_WIZARD)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!505",ObjectToString(oCreature)+"|"+IntToString(nClass));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!505");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

void NWNXPatch_SetSpellSchoolSpecialization(object oCreature, int nSchool, int nClass=CLASS_TYPE_WIZARD)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!506",ObjectToString(oCreature)+"|"+IntToString(nClass)+"|"+IntToString(nSchool));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!506");
}

int NWNXPatch_GetDomain(object oCreature, int nTh, int nClass=CLASS_TYPE_CLERIC)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!507",ObjectToString(oCreature)+"|"+IntToString(nClass)+"|"+IntToString(nTh));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!507");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

void NWNXPatch_SetDomain(object oCreature, int nTh, int nDomain, int nClass=CLASS_TYPE_CLERIC)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!508",ObjectToString(oCreature)+"|"+IntToString(nClass)+"|"+IntToString(nTh)+"|"+IntToString(nDomain));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!508");
}

struct MemorizedSpellSlot NWNXPatch_GetMemorisedSpellSlot(object oCreature, int nClass, int nSpellLevel, int nTh)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!509",ObjectToString(oCreature)+"|"+IntToString(nClass)+"|"+IntToString(nSpellLevel)+"|"+IntToString(nTh));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!509");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");

    struct MemorizedSpellSlot mss;

    if(retVal >= 0)
    {
        mss.id    = retVal & 0xFFFF;
        mss.meta  = (retVal >> 16) & 0x7F;
        mss.ready = (retVal >> 24) & 1;
    }
    else
        mss.id = -1;

    return mss;
}

void NWNXPatch_SetMemorisedSpellSlot(object oCreature, int nClass, int nSpellLevel, int nTh, struct MemorizedSpellSlot slot)
{
    int nData = (slot.id & 0xFFFF) | ((slot.meta&0xFF) << 16) | (slot.ready << 24);
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!510",ObjectToString(oCreature)+"|"+IntToString(nClass)+"|"+IntToString(nSpellLevel)+"|"+IntToString(nTh)+"|"+IntToString(nData));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!510");
}

int NWNXPatch_GetMaxSpellSlots(object oCreature, int nClass, int nSpellLevel)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!511",ObjectToString(oCreature)+"|"+IntToString(nClass)+"|"+IntToString(nSpellLevel));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!511");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

void NWNXPatch_ModifyNumberBonusSpells(object oCreature, int nClass, int nSpellLevel, int nMod)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!512",ObjectToString(oCreature)+"|"+IntToString(nClass)+"|"+IntToString(nSpellLevel)+"|"+IntToString(nMod));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!512");
}

effect NWNXPatch_SetEffectTrueType(effect eEffect, int nTrueType)
{
    SetLocalInt(GetModule(),"SetEffectTrueType",nTrueType);
    eEffect = VersusTrapEffect(eEffect);
    DeleteLocalInt(GetModule(),"SetEffectTrueType");
    return eEffect;
}

effect NWNXPatch_SetEffectSpellId(effect eEffect, int nSpellId)
{
    SetLocalInt(GetModule(),"SetEffectSpellId",nSpellId);
    eEffect = VersusTrapEffect(eEffect);
    DeleteLocalInt(GetModule(),"SetEffectSpellId");
    return eEffect;
}

effect NWNXPatch_SetEffectCreator(effect eEffect, object oCreator)
{
    SetLocalObject(GetModule(),"SetEffectCreator",oCreator);
    eEffect = VersusTrapEffect(eEffect);
    DeleteLocalObject(GetModule(),"SetEffectCreator");
    return eEffect;
}


effect NWNXPatch_SetEffectCasterLevel(effect eEffect, int nCasterLevel)
{
    SetLocalInt(GetModule(),"SetEffectCasterLevel",nCasterLevel);
    eEffect = VersusTrapEffect(eEffect);
    DeleteLocalInt(GetModule(),"SetEffectCasterLevel");
    return eEffect;
}

effect NWNXPatch_SetEffectInteger(effect eEffect, int nTh, int nValue)
{
    SetLocalInt(GetModule(),"SetEffectIntegerNth",nTh);
    SetLocalInt(GetModule(),"SetEffectIntegerVal",nValue);
    eEffect = VersusTrapEffect(eEffect);
    DeleteLocalInt(GetModule(),"SetEffectIntegerNth");
    return eEffect;
}

effect NWNXPatch_SetEffectString(effect eEffect, int nTh, string sValue)
{
    SetLocalInt(GetModule(),"SetEffectStringNth",nTh);
    SetLocalString(GetModule(),"SetEffectStringVal",sValue);
    eEffect = VersusTrapEffect(eEffect);
    DeleteLocalInt(GetModule(),"SetEffectStringNth");
    return eEffect;
}

int NWNXPatch_GetEffectInteger(effect eEffect, int nTh)
{
    SetLocalInt(GetModule(),"GetEffectInteger",nTh);
    int retVal = GetEffectSubType(eEffect);
    DeleteLocalInt(GetModule(),"GetEffectInteger");
    return retVal;
}

float NWNXPatch_GetEffectRemainingDuration(effect eEffect)
{
    SetLocalFloat(GetModule(),"GetEffectRemainingDuration",0.0);
    GetEffectSubType(eEffect);
    float retVal = GetLocalFloat(GetModule(),"GetEffectRemainingDuration");
    DeleteLocalFloat(GetModule(),"GetEffectRemainingDuration");
    return retVal;
}

effect NWNXPatch_UncappedEffect(effect eEffect)
{
    return GetEffectType(eEffect) == EFFECT_TYPE_SAVING_THROW_INCREASE ? NWNXPatch_SetEffectInteger(eEffect,6,1) : NWNXPatch_SetEffectInteger(eEffect,5,1);
}

effect NWNXPatch_EffectModifyBAB(int nBaseAttackBonus)
{
    effect eEffect = EffectVisualEffect(nBaseAttackBonus);
    eEffect = NWNXPatch_SetEffectTrueType(eEffect,EFFECT_TRUETYPE_NWNXPATCH_MODIFYBAB);
    return eEffect;
}

effect NWNXPatch_EffectIgnoreArcaneSpellFailure(int nIgnoreType=1, int nClassOnly=CLASS_TYPE_INVALID)
{
    effect eEffect = EffectSpellFailure(nIgnoreType,nClassOnly);
    eEffect = NWNXPatch_SetEffectTrueType(eEffect,97);
    return eEffect;
}

effect NWNXPatch_EffectSpellLevelImmunity(int nSpellLevel, int nSpellSchool=SPELL_SCHOOL_GENERAL)
{
    effect eEffect = EffectSpellLevelAbsorption(nSpellLevel,0,nSpellSchool);
    eEffect = NWNXPatch_SetEffectInteger(eEffect,3,1);
    return eEffect;
}

effect NWNXPatch_EffectBonusFeat(int nFeat)
{
    effect eEffect = EffectVisualEffect(nFeat);
    eEffect = NWNXPatch_SetEffectTrueType(eEffect,EFFECT_TRUETYPE_BONUS_FEAT);
    return eEffect;
}

effect NWNXPatch_EffectIcon(int nIcon)
{
    effect eEffect = EffectVisualEffect(nIcon);
    eEffect = NWNXPatch_SetEffectTrueType(eEffect,EFFECT_TRUETYPE_ICON);
    return eEffect;
}

effect NWNXPatch_EffectPolymorph(int nAppearanceType, int bLocked, int nRacialType, int nPortraitId, int nSTR, int nCON, int nDEX, int nACBonus, int nBonusHP, string sEquippedWeapon, string sCreatureWeapon1, string sCreatureWeapon2, string sCreatureWeapon3, string sCreatureSkin, int nSpell1 = -1, int nSpell2 = -1, int nSpell3 = -1)
{
    effect eEffect = EffectDamage(1);
    eEffect = NWNXPatch_SetEffectTrueType(eEffect,EFFECT_TRUETYPE_POLYMORPH);
    eEffect = NWNXPatch_SetEffectInteger(eEffect,0,-1);
    eEffect = NWNXPatch_SetEffectInteger(eEffect,1,0);
    eEffect = NWNXPatch_SetEffectInteger(eEffect,2,bLocked);
    eEffect = NWNXPatch_SetEffectInteger(eEffect,6,nAppearanceType);
    eEffect = NWNXPatch_SetEffectInteger(eEffect,7,nRacialType);
    eEffect = NWNXPatch_SetEffectInteger(eEffect,8,nPortraitId);
    eEffect = NWNXPatch_SetEffectInteger(eEffect,9,nSTR);
    eEffect = NWNXPatch_SetEffectInteger(eEffect,10,nCON);
    eEffect = NWNXPatch_SetEffectInteger(eEffect,11,nDEX);
    eEffect = NWNXPatch_SetEffectInteger(eEffect,12,nACBonus);
    eEffect = NWNXPatch_SetEffectInteger(eEffect,13,nBonusHP);
    eEffect = NWNXPatch_SetEffectString(eEffect,0,sEquippedWeapon);
    eEffect = NWNXPatch_SetEffectString(eEffect,1,sCreatureWeapon1);
    eEffect = NWNXPatch_SetEffectString(eEffect,2,sCreatureWeapon2);
    eEffect = NWNXPatch_SetEffectString(eEffect,3,sCreatureWeapon3);
    eEffect = NWNXPatch_SetEffectString(eEffect,4,sCreatureSkin);
    eEffect = NWNXPatch_SetEffectInteger(eEffect,14,nSpell1);
    eEffect = NWNXPatch_SetEffectInteger(eEffect,15,nSpell2);
    eEffect = NWNXPatch_SetEffectInteger(eEffect,16,nSpell3);
    return eEffect;
}

effect NWNXPatch_EffectPolymorphOptions(effect ePolymorph, int nACType = AC_DODGE_BONUS, int bReplaceAbilityOnlyWhenHigher=FALSE, int bKeepItems=FALSE)
{
    if(nACType) ePolymorph = NWNXPatch_SetEffectInteger(ePolymorph,3,nACType);
    if(bReplaceAbilityOnlyWhenHigher) ePolymorph = NWNXPatch_SetEffectInteger(ePolymorph,4,TRUE);
    if(bKeepItems) ePolymorph = NWNXPatch_SetEffectInteger(ePolymorph,5,TRUE);
    return ePolymorph;
}

effect NWNXPatch_GetNthEffect(object oObject, int nTh)
{
    SetLocalInt(GetModule(),"GetEffect",nTh);
    SetLocalObject(GetModule(),"GetEffect",oObject);
    effect eEffect;
    eEffect = VersusTrapEffect(eEffect);
    DeleteLocalInt(GetModule(),"GetEffect");
    DeleteLocalObject(GetModule(),"GetEffect");
    return eEffect;
}

int getfirstnexteffect;

effect NWNXPatch_GetFirstEffect(object oObject)
{
    getfirstnexteffect = 0;
    return NWNXPatch_GetNthEffect(oObject,getfirstnexteffect);
}

effect NWNXPatch_GetNextEffect(object oObject)
{
    return NWNXPatch_GetNthEffect(oObject,++getfirstnexteffect);
}

int NWNXPatch_GetEffectTrueType(effect eEffect)
{
    SetLocalInt(GetModule(),"GetEffectTrueType",0);
    int retVal = GetEffectSubType(eEffect);
    DeleteLocalInt(GetModule(),"GetEffectTrueType");
    return retVal;
}

int NWNXPatch_GetEffectCasterLevel(effect eEffect)
{
    SetLocalInt(GetModule(),"GetEffectCasterLevel",0);
    int retVal = GetEffectSubType(eEffect);
    DeleteLocalInt(GetModule(),"GetEffectCasterLevel");
    return retVal;
}

void NWNXPatch_TransferEffectValues(effect eEffect)
{
    SetLocalInt(GetModule(),"TransferEffectValues",0);
    GetEffectSubType(eEffect);
    DeleteLocalInt(GetModule(),"TransferEffectValues");
}

void NWNXPatch_TransferEffectValuesIntoNthEffect(effect eEffect, object oTarget, int nTh)
{
    SetLocalObject(GetModule(),"TransferEffectValuesNth",oTarget);
    SetLocalInt(GetModule(),"TransferEffectValuesNth",nTh);
    GetEffectSubType(eEffect);
    DeleteLocalObject(GetModule(),"TransferEffectValuesNth");
    DeleteLocalInt(GetModule(),"TransferEffectValuesNth");
}

void NWNXPatch_ForceApplyEffectToObject(int nDurationType, effect eEffect, object oTarget, float fDuration=0.0f)
{
    ApplyEffectToObject(nDurationType+10,eEffect,oTarget,fDuration);
}

effect NWNXPatch_GetEffectEventEffect()
{
    effect eEffect;
    SetLocalInt(GetModule(),"GetEffectEventEffect",1);
    eEffect = VersusTrapEffect(eEffect);
    DeleteLocalInt(GetModule(),"GetEffectEventEffect");
    return eEffect;
}

struct CombatAttackData NWNXPatch_GetLastAttackCombatData()
{
   struct CombatAttackData data;
   data.AttackDeflected = GetLocalInt(OBJECT_SELF,"AttackDeflected");
   data.AttackResult = GetLocalInt(OBJECT_SELF,"AttackResult");
   data.AttackType = GetLocalInt(OBJECT_SELF,"AttackType");
   data.Concealment = GetLocalInt(OBJECT_SELF,"Concealment");
   data.CoupDeGrace = GetLocalInt(OBJECT_SELF,"CoupDeGrace");
   data.CriticalThreat = GetLocalInt(OBJECT_SELF,"CriticalThreat");
   data.DeathAttack = GetLocalInt(OBJECT_SELF,"DeathAttack");
   data.KillingBlow = GetLocalInt(OBJECT_SELF,"KillingBlow");
   data.MissedBy = GetLocalInt(OBJECT_SELF,"MissedBy");
   data.SneakAttack = GetLocalInt(OBJECT_SELF,"SneakAttack");
   data.ThreatRoll = GetLocalInt(OBJECT_SELF,"ThreatRoll");
   data.ToHitMod = GetLocalInt(OBJECT_SELF,"ToHitMod");
   data.ToHitRoll = GetLocalInt(OBJECT_SELF,"ToHitRoll");
   data.WeaponType = GetLocalInt(OBJECT_SELF,"WeaponType");
   return data;
}

void NWNXPatch_AddFeat(object oCreature, int nFeat, int nLevel=0)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!443",ObjectToString(oCreature)+"|"+IntToString(nFeat)+"|"+IntToString(nLevel));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!443");
}

void NWNXPatch_RemoveFeat(object oCreature, int nFeat, int bRemoveFromLevel=TRUE)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!444",ObjectToString(oCreature)+"|"+IntToString(nFeat)+"|"+IntToString(bRemoveFromLevel));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!444");
}

int NWNXPatch_PerformMeleeAttacks(object oCreature, object oTarget, int nNumAttacks)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!446",ObjectToString(oCreature)+"|"+ObjectToString(oTarget)+"|"+IntToString(nNumAttacks));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!446");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

void NWNXPatch_SetSpellFailure(object oCreature, int nFailure, int nType=1)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!447",ObjectToString(oCreature)+"|"+IntToString(nFailure)+"|"+IntToString(nType));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!447");
}

void NWNXPatch_SetSkillCheckPenalty(object oCreature, int nPenalty, int nType=1)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!448",ObjectToString(oCreature)+"|"+IntToString(nPenalty)+"|"+IntToString(nType));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!448");
}

void NWNXPatch_SetSkillPointsRemaining(object oCreature, int nSkillPoints)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!449",ObjectToString(oCreature)+"|"+IntToString(nSkillPoints));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!449");
}

int NWNXPatch_GetTotalEffectBonus(object oCreature, int nEffectBonusType, object oidEffectVersus, int bElementalDamage, int bForceMax, int nSaveType, int nSpecificType, int nSkill, int nAbilityScore, int bOffHand)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!450",ObjectToString(oCreature)+"|"+IntToString(nEffectBonusType)+"|"+ObjectToString(oidEffectVersus)+"|"+IntToString(bElementalDamage)+"|"+IntToString(bForceMax)+"|"+IntToString(nSaveType)+"|"+IntToString(nSpecificType)+"|"+IntToString(nSkill)+"|"+IntToString(nAbilityScore)+"|"+IntToString(bOffHand));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!450");
    int retVal = GetLocalInt(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalInt(GetModule(),"NWNXPATCH_RESULT");
    return retVal;
}

//experimental
void NWNXPatch_OpenInventory(object oPC, object oTarget)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!18",ObjectToString(oPC)+"|"+ObjectToString(oTarget));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!18");
}

void NWNXPatch_ShutdownServer()
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!19",".");
}

string NWNXPatch_GetCurrentScriptName(int nDepth=0)
{
    SetLocalString(GetModule(),"NWNX!PATCH!FUNCS!20",IntToString(nDepth));
    DeleteLocalString(GetModule(),"NWNX!PATCH!FUNCS!20");
    string sScript = GetLocalString(GetModule(),"NWNXPATCH_RESULT");
    DeleteLocalString(GetModule(),"NWNXPATCH_RESULT");
    return sScript;
}

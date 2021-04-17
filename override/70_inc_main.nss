//::///////////////////////////////////////////////
//:: Community Patch 1.72 library with various custom functions for builders
//:: 70_inc_main
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*

*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow
//:: Created On: 01-01-2016
//:://////////////////////////////////////////////

#include "x3_inc_skin"

const int ATTACK_BONUS_CWEAPON1            = 3;
const int ATTACK_BONUS_CWEAPON2            = 4;
const int ATTACK_BONUS_CWEAPON3            = 5;
const int ATTACK_BONUS_UNARMED             = 7;
const int SAVING_THROW_TYPE_PARALYSE       = 20;
const int VFX_COM_GIB                      = 119 ;
const int VFX_DUR_QUESTION_MARK            = 127 ;
const int VFX_DUR_EXCLAMATION_MARK         = 128 ;
const int PACKAGE_PURPLE_DRAGON_KNIGH      = 131;
const int PACKAGE_EYE_OF_THE_GRUUMSH       = 132;
const int PACKAGE_SHOU_DISCIPLE            = 133;
const int IP_CONST_SAVEVS_TRAPS            = 16;
const int IP_CONST_SAVEVS_SPELLS           = 17;
const int IP_CONST_SAVEVS_LAW              = 18;
const int IP_CONST_SAVEVS_CHAOS            = 19;
const int IP_CONST_SAVEVS_GOOD             = 20;
const int IP_CONST_SAVEVS_EVIL             = 21;
const int ITEM_VISUAL_NONE                 = 7;

//Adds feat to player. Uses PC Skin system from 1.69 + expanded iprp_feats.2da from patch 1.72.
void AddFeat(int nFeat, object oPC);

// Determine whether oCreature knows nFeat
// This function is similar to GetHasFeat, however GetHasFeat returns FALSE if the feat uses are depleted
// - nFeat: FEAT_*
// - oCreature
int GetKnowsFeat(int nFeat, object oCreature);

//returns 170, 171 or 172 depending on the community patch version installed on the running machine
//returns -1 if community patch is not installed
int GetCommunityPatchVersion();

//Returns current skill timer value.
int SkillTimerCurrent(object oCreature, int nSkill);

//Reset/Initialize skill timer to 6 seconds.
void SkillTimerInitialize(object oCreature, int nSkill);

//Reduces skill timer by 1 each second.
void SkillTimerReduce(object oCreature, int nSkill);

void AddFeat(int nFeat, object oPC)
{
 switch(nFeat)
 {
 case FEAT_ALERTNESS:
 nFeat = IP_CONST_FEAT_ALERTNESS;
 break;
 case FEAT_AMBIDEXTERITY:
 nFeat = IP_CONST_FEAT_AMBIDEXTROUS;
 break;
 case FEAT_ARMOR_PROFICIENCY_HEAVY:
 nFeat = IP_CONST_FEAT_ARMOR_PROF_HEAVY;
 break;
 case FEAT_ARMOR_PROFICIENCY_LIGHT:
 nFeat = IP_CONST_FEAT_ARMOR_PROF_LIGHT;
 break;
 case FEAT_ARMOR_PROFICIENCY_MEDIUM:
 nFeat = IP_CONST_FEAT_ARMOR_PROF_MEDIUM;
 break;
 case FEAT_CLEAVE:
 nFeat = IP_CONST_FEAT_CLEAVE;
 break;
 case FEAT_COMBAT_CASTING:
 nFeat = IP_CONST_FEAT_COMBAT_CASTING;
 break;
 case FEAT_DISARM:
 nFeat = IP_CONST_FEAT_DISARM;
 break;
 case FEAT_DODGE:
 nFeat = IP_CONST_FEAT_DODGE;
 break;
 case FEAT_EXTRA_TURNING:
 nFeat = IP_CONST_FEAT_EXTRA_TURNING;
 break;
 case FEAT_HIDE_IN_PLAIN_SIGHT:
 nFeat = IP_CONST_FEAT_HIDE_IN_PLAIN_SIGHT;
 break;
 case FEAT_IMPROVED_CRITICAL_UNARMED_STRIKE:
 nFeat = IP_CONST_FEAT_IMPCRITUNARM;
 break;
 case FEAT_KNOCKDOWN:
 nFeat = IP_CONST_FEAT_KNOCKDOWN;
 break;
 case FEAT_MOBILITY:
 nFeat = IP_CONST_FEAT_MOBILITY;
 break;
 case FEAT_PLAYER_TOOL_01:
 nFeat = IP_CONST_FEAT_PLAYER_TOOL_01;
 break;
 case FEAT_PLAYER_TOOL_02:
 nFeat = IP_CONST_FEAT_PLAYER_TOOL_02;
 break;
 case FEAT_PLAYER_TOOL_03:
 nFeat = IP_CONST_FEAT_PLAYER_TOOL_03;
 break;
 case FEAT_PLAYER_TOOL_04:
 nFeat = IP_CONST_FEAT_PLAYER_TOOL_04;
 break;
 case FEAT_PLAYER_TOOL_05:
 nFeat = IP_CONST_FEAT_PLAYER_TOOL_05;
 break;
 case FEAT_PLAYER_TOOL_06:
 nFeat = IP_CONST_FEAT_PLAYER_TOOL_06;
 break;
 case FEAT_PLAYER_TOOL_07:
 nFeat = IP_CONST_FEAT_PLAYER_TOOL_07;
 break;
 case FEAT_PLAYER_TOOL_08:
 nFeat = IP_CONST_FEAT_PLAYER_TOOL_08;
 break;
 case FEAT_PLAYER_TOOL_09:
 nFeat = IP_CONST_FEAT_PLAYER_TOOL_09;
 break;
 case FEAT_PLAYER_TOOL_10:
 nFeat = IP_CONST_FEAT_PLAYER_TOOL_10;
 break;
 case FEAT_POINT_BLANK_SHOT:
 nFeat = IP_CONST_FEAT_POINTBLANK;
 break;
 case FEAT_POWER_ATTACK:
 nFeat = IP_CONST_FEAT_POWERATTACK;
 break;
 case FEAT_RAPID_SHOT:
 nFeat = IP_CONST_FEAT_RAPID_SHOT;
 break;
 case FEAT_SHIELD_PROFICIENCY:
 nFeat = IP_CONST_FEAT_SHIELD_PROFICIENCY;
 break;
 case FEAT_SNEAK_ATTACK:
 nFeat = IP_CONST_FEAT_SNEAK_ATTACK_1D6;
 break;
 case 345:
 nFeat = IP_CONST_FEAT_SNEAK_ATTACK_2D6;
 break;
 case 346:
 nFeat = IP_CONST_FEAT_SNEAK_ATTACK_3D6;
 break;
 case 348:
 nFeat = IP_CONST_FEAT_SNEAK_ATTACK_5D6;
 break;
 case FEAT_SPELL_FOCUS_ABJURATION:
 nFeat = IP_CONST_FEAT_SPELLFOCUSABJ;
 break;
 case FEAT_SPELL_FOCUS_CONJURATION:
 nFeat = IP_CONST_FEAT_SPELLFOCUSCON;
 break;
 case FEAT_SPELL_FOCUS_DIVINATION:
 nFeat = IP_CONST_FEAT_SPELLFOCUSDIV;
 break;
 case FEAT_SPELL_FOCUS_ENCHANTMENT:
 nFeat = IP_CONST_FEAT_SPELLFOCUSENC;
 break;
 case FEAT_SPELL_FOCUS_EVOCATION:
 nFeat = IP_CONST_FEAT_SPELLFOCUSEVO;
 break;
 case FEAT_SPELL_FOCUS_ILLUSION:
 nFeat = IP_CONST_FEAT_SPELLFOCUSILL;
 break;
 case FEAT_SPELL_FOCUS_NECROMANCY:
 nFeat = IP_CONST_FEAT_SPELLFOCUSNEC;
 break;
 case FEAT_SPELL_FOCUS_TRANSMUTATION:
 nFeat = IP_CONST_FEAT_SPELLPENETRATION;
 break;
 case FEAT_TWO_WEAPON_FIGHTING:
 nFeat = IP_CONST_FEAT_TWO_WEAPON_FIGHTING;
 break;
 case FEAT_USE_POISON:
 nFeat = IP_CONST_FEAT_USE_POISON;
 break;
 case FEAT_WEAPON_FINESSE:
 nFeat = IP_CONST_FEAT_WEAPFINESSE;
 break;
 case FEAT_WEAPON_PROFICIENCY_CREATURE:
 nFeat = IP_CONST_FEAT_WEAPON_PROF_CREATURE;
 break;
 case FEAT_WEAPON_PROFICIENCY_EXOTIC:
 nFeat = IP_CONST_FEAT_WEAPON_PROF_EXOTIC;
 break;
 case FEAT_WEAPON_PROFICIENCY_MARTIAL:
 nFeat = IP_CONST_FEAT_WEAPON_PROF_MARTIAL;
 break;
 case FEAT_WEAPON_PROFICIENCY_SIMPLE:
 nFeat = IP_CONST_FEAT_WEAPON_PROF_SIMPLE;
 break;
 case FEAT_WEAPON_SPECIALIZATION_UNARMED_STRIKE:
 nFeat = IP_CONST_FEAT_WEAPSPEUNARM;
 break;
 case FEAT_WHIRLWIND_ATTACK:
 nFeat = IP_CONST_FEAT_WHIRLWIND;
 break;
 default:
 nFeat+= 100;
 break;
 }
itemproperty bonusFeat = ItemPropertyBonusFeat(nFeat);
 if(GetIsItemPropertyValid(bonusFeat))
 {
 object oSkin = SKIN_SupportGetSkin(oPC);
 AddItemProperty(DURATION_TYPE_PERMANENT,bonusFeat,oSkin);
 AssignCommand(oPC,SKIN_SupportEquipSkin(oSkin));
 }
 else
 {
 WriteTimestampedLogEntry("70_inc_main: AddFunction used with nonsupported feat.");
 }
}

int GetKnowsFeat(int nFeat, object oCreature)
{
    if(GetHasFeat(nFeat,oCreature)) return TRUE;
    IncrementRemainingFeatUses(oCreature,nFeat);
    int bHasFeat = GetHasFeat(nFeat,oCreature);
    if(bHasFeat)
    {
        DecrementRemainingFeatUses(oCreature,nFeat);
    }
    return bHasFeat;
}

int GetCommunityPatchVersion()
{
int nVersion = GetLocalInt(GetModule(),"GetCommunityPatchVersion()");
 if(nVersion) return nVersion;
object oTest = CreateObject(OBJECT_TYPE_ITEM,"70_it_scrwarcry",GetStartingLocation());
 if(oTest == OBJECT_INVALID) nVersion = -1;//all versions of CPP has 70_it_scrwarcry if its missing, CPP is not installed
 else
 {
 DestroyObject(oTest);
 oTest = CreateObject(OBJECT_TYPE_PLACEABLE,"70_ec_poison",GetStartingLocation());
  if(oTest != OBJECT_INVALID)
  {
  DestroyObject(oTest);
  nVersion = 171;//only 1.71 has 70_ec_poison, this file was removed from 1.72
  }
  else
  {
  oTest = CreateObject(OBJECT_TYPE_ITEM,"70_ip_14",GetStartingLocation());
   if(oTest != OBJECT_INVALID)
   {
   DestroyObject(oTest);
   nVersion = 172;//70_ip_14 exists only in 1.72
   }
   else nVersion = 170;//if all other checks failed it must be 1.70
  }
 }
SetLocalInt(GetModule(),"GetCommunityPatchVersion()",nVersion);
return nVersion;
}

int SkillTimerCurrent(object oCreature, int nSkill)
{
string sVarName = ObjectToString(oCreature)+"_SKILL"+IntToString(nSkill)+"_TIMER";
return GetLocalInt(GetModule(),sVarName);
}

void SkillTimerInitialize(object oCreature, int nSkill)
{
string sVarName = ObjectToString(oCreature)+"_SKILL"+IntToString(nSkill)+"_TIMER";
SetLocalInt(GetModule(),sVarName,6);
}

void SkillTimerReduce_internal(object oCreature, int nSkill)
{
string sVarName = ObjectToString(oCreature)+"_SKILL"+IntToString(nSkill)+"_TIMER";
int nTimer = GetLocalInt(OBJECT_SELF,sVarName);
 if(nTimer < 1) return;
SetLocalInt(OBJECT_SELF,sVarName,--nTimer);
 if(nTimer > 0)
 {
 DelayCommand(1.0,SkillTimerReduce(oCreature,nSkill));
 }
}

void SkillTimerReduce(object oCreature, int nSkill)
{
object oModule = GetModule();
AssignCommand(oModule,DelayCommand(1.0,SkillTimerReduce_internal(oCreature,nSkill)));
}

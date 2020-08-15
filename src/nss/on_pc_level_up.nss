//::///////////////////////////////////////////////
//:: Default community patch OnPlayerLevelUp module event script
//:: 70_mod_def_lvup
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
The 70_mod_def_* scripts are a new feature of nwn(c)x_patch plugin and will fire
just before normal module events. Note, that this script will run only if game
is loaded via NWNX or NWNCX and Community Patch plugin!

The purpose of this is to automatically enforce fixes/features that requires changes
in module events in any module player will play. Also, PW builders no longer needs
to merge scripts to get these functionalities.

If you are a builder you can reuse these events for your own purposes too. With
this feature, you can make a system like 3.5 ruleset which will work in any module
as long player is using patch 1.72 + NWNCX + nwncx_patch plugin.

Note: community patch doesn't include scripts for all these events, but only for
a few. You can create a script with specified name for other events. There was
just no point of including a script which will do nothing. So here is a list:
OnAcquireItem       - 70_mod_def_aqu
OnActivateItem      - 70_mod_def_act
OnClientEnter       - 70_mod_def_enter
OnClientLeave       - 70_mod_def_leave
OnCutsceneAbort     - 70_mod_def_abort
OnHeartbeat         - not running extra script
OnModuleLoad        - 70_mod_def_load
OnPlayerChat        - 70_mod_def_chat
OnPlayerDeath       - 70_mod_def_death
OnPlayerDying       - 70_mod_def_dying
OnPlayerEquipItem   - 70_mod_def_equ
OnPlayerLevelUp     - 70_mod_def_lvup
OnPlayerRespawn     - 70_mod_def_resp
OnPlayerRest        - 70_mod_def_rest
OnPlayerUnEquipItem - 70_mod_def_unequ
OnUnAcquireItem     - 70_mod_def_unaqu
OnUserDefined       - 70_mod_def_user

It is also possible to bypass the original script, use this command:
SetLocalInt(OBJECT_SELF,"BYPASS_EVENT",1);
This should be used wisely as you don't know what is original module event script
doing so, do this only if running original event has no longer sense.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.70
//:: Created On: 03-07-2011
//:://////////////////////////////////////////////
////////////////////////////////////////////////////////////////////////////////
const int MIN_CLASS_LEVEL_FOR_EPIC_SPELLS_SORCERER = 18;
const int MIN_CLASS_LEVEL_FOR_EPIC_SPELLS_WIZARD = 17;
const int MIN_CLASS_LEVEL_FOR_EPIC_SPELLS_DRUID = 17;
const int MIN_CLASS_LEVEL_FOR_EPIC_SPELLS_CLERIC = 17;
const int MIN_CLASS_LEVEL_FOR_EPIC_SPELLS_PALE_MASTER = 15;
const int MIN_CLASS_LEVEL_FOR_BANE_OF_ENEMIES = 21;
const int MIN_CLASS_LEVEL_FOR_EPIC_FIEND = 15;
////////////////////////////////////////////////////////////////////////////////

#include "inc_debug"
#include "inc_nwnx"

/*
Patch 1.72
- fixed bug which deleveled palemasters taking EMA and Warding
*/
int GetXPToLevel(int nLevel)
{
    return nLevel < 2 ? 0 : (nLevel-1)*nLevel*500;
}

void CancelLevelUp(object oPC)
{
    //Character has too many feats.
    SendMessageToPCByStrRef(oPC,66222);
    int nLevel = GetHitDice(oPC);
    int nXP = GetXP(oPC);
    //relevel
    SetXP(oPC,GetXPToLevel(nLevel)-1);
    DelayCommand(0.3,SetXP(oPC,nXP));
}

void main()
{
    object oPC = GetPCLevellingUp();
    effect eEffect = GetFirstEffect(oPC);
     while(GetIsEffectValid(eEffect))
     {
      if(GetEffectType(eEffect) == EFFECT_TYPE_POLYMORPH)//no levelling in polymorph to avoid exploits
      {
      CancelLevelUp(oPC);
      return;//ensures, the default OnLevelUp event will not fire
      }
     eEffect = GetNextEffect(oPC);
     }
     if(GetHasFeat(FEAT_EPIC_SPELL_MAGE_ARMOUR,oPC) || GetHasFeat(FEAT_EPIC_SPELL_EPIC_WARDING,oPC))
     {
      if(GetLevelByClass(CLASS_TYPE_WIZARD,oPC) < MIN_CLASS_LEVEL_FOR_EPIC_SPELLS_WIZARD &&
         GetLevelByClass(CLASS_TYPE_SORCERER,oPC) < MIN_CLASS_LEVEL_FOR_EPIC_SPELLS_SORCERER &&
         GetLevelByClass(CLASS_TYPE_PALEMASTER,oPC) < MIN_CLASS_LEVEL_FOR_EPIC_SPELLS_PALE_MASTER)
      {
      CancelLevelUp(oPC);
      return;//ensures, the default OnLevelUp event will not fire
      }
     }
     if(GetHasFeat(FEAT_EPIC_SPELL_MUMMY_DUST,oPC) || GetHasFeat(FEAT_EPIC_SPELL_HELLBALL,oPC) ||
             GetHasFeat(FEAT_EPIC_SPELL_RUIN,oPC) || GetHasFeat(FEAT_EPIC_SPELL_DRAGON_KNIGHT,oPC))
     {
      if(GetLevelByClass(CLASS_TYPE_CLERIC,oPC) < MIN_CLASS_LEVEL_FOR_EPIC_SPELLS_CLERIC &&
         GetLevelByClass(CLASS_TYPE_DRUID,oPC) < MIN_CLASS_LEVEL_FOR_EPIC_SPELLS_DRUID &&
         GetLevelByClass(CLASS_TYPE_PALE_MASTER,oPC) < MIN_CLASS_LEVEL_FOR_EPIC_SPELLS_PALE_MASTER &&
         GetLevelByClass(CLASS_TYPE_WIZARD,oPC) < MIN_CLASS_LEVEL_FOR_EPIC_SPELLS_WIZARD &&
         GetLevelByClass(CLASS_TYPE_SORCERER,oPC) < MIN_CLASS_LEVEL_FOR_EPIC_SPELLS_SORCERER)
      {
      CancelLevelUp(oPC);
      return;//ensures, the default OnLevelUp event will not fire
      }
     }
     if(GetHasFeat(FEAT_EPIC_BANE_OF_ENEMIES,oPC))
     {
      if(GetLevelByClass(CLASS_TYPE_RANGER,oPC) < MIN_CLASS_LEVEL_FOR_BANE_OF_ENEMIES)
      {
      CancelLevelUp(oPC);
      return;//ensures, the default OnLevelUp event will not fire
      }
     }
     if(GetHasFeat(FEAT_EPIC_EPIC_FIEND,oPC))
     {
      if(GetLevelByClass(CLASS_TYPE_BLACKGUARD,oPC) < MIN_CLASS_LEVEL_FOR_EPIC_FIEND)
      {
      CancelLevelUp(oPC);
      return;//ensures, the default OnLevelUp event will not fire
      }
     }
    ExecuteScript("70_featfix",oPC);

   WriteTimestampedLogEntry(PlayerDetailedName(oPC)+" leveled up.");

   SendDiscordLogMessage(GetName(oPC)+" has leveled up to level "+IntToString(GetHitDice(oPC))+"!");

// Don't do any of this if leveling from level 2

    if (GetXP(oPC) < 3000) return;

    PlayVoiceChat(VOICE_CHAT_CHEER, oPC);
    switch (d3())
    {
       case 1: AssignCommand(oPC, ActionPlayAnimation(ANIMATION_FIREFORGET_VICTORY1)); break;
       case 2: AssignCommand(oPC, ActionPlayAnimation(ANIMATION_FIREFORGET_VICTORY2)); break;
       case 3: AssignCommand(oPC, ActionPlayAnimation(ANIMATION_FIREFORGET_VICTORY3)); break;
    }
    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_FNF_LOS_HOLY_30), oPC);
}

//::///////////////////////////////////////////////
//:: Epic Rage abilities script
//:: 70_s2_epicrage
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
This script implements CheckAndApplyEpicRageFeats function from x2_i0_spells include.
The reason why is this function now externalized here is that if you were going to
modify the epic rage feats in any way (for example add support for new epic feat), you
would have to recompile all rage feat and abilities scripts. Instead, you can make any
modification into this script and it dynamically update in all rage feat and abilities.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch
//:: Created On: 22-01-2015
//:://////////////////////////////////////////////

#include "x2_i0_spells"

void main()
{
object oBarbarian = OBJECT_SELF;
int nRounds = GetLocalInt(oBarbarian,"EPIC_RAGE_ROUNDS");
DeleteLocalInt(oBarbarian,"EPIC_RAGE_ROUNDS");
float fDuration = RoundsToSeconds(nRounds);

 if(GetHasFeat(FEAT_EPIC_TERRIFYING_RAGE,oBarbarian))//if barbarian has terrifying rage
 {
 effect eAOE = EffectAreaOfEffect(AOE_MOB_FEAR,"x2_s2_terrage_A","","");
 ApplyEffectToObject(DURATION_TYPE_TEMPORARY,ExtraordinaryEffect(eAOE),oBarbarian,fDuration);//apply fear aura
 }//end of terrifying rage

 if(!GetHasFeat(FEAT_EPIC_THUNDERING_RAGE,oBarbarian))//if player don't have thundering rage,
 {                                                    //this function ends
 return;
 }
//declare variables, because they will be used multiple times
itemproperty critical = ItemPropertyMassiveCritical(IP_CONST_DAMAGEBONUS_2d6);
itemproperty vfx = ItemPropertyVisualEffect(ITEM_VISUAL_SONIC);
itemproperty onhit = ItemPropertyOnHitProps(IP_CONST_ONHIT_DEAFNESS,IP_CONST_ONHIT_SAVEDC_20,IP_CONST_ONHIT_DURATION_25_PERCENT_3_ROUNDS);

object oWeapon = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,oBarbarian);
 if(GetIsObjectValid(oWeapon))//barbarian has weapon
 {
 IPSafeAddItemProperty(oWeapon,critical,fDuration,X2_IP_ADDPROP_POLICY_KEEP_EXISTING,TRUE,TRUE);
 IPSafeAddItemProperty(oWeapon,vfx,fDuration,X2_IP_ADDPROP_POLICY_REPLACE_EXISTING,FALSE,TRUE);
 IPSafeAddItemProperty(oWeapon,onhit,fDuration,X2_IP_ADDPROP_POLICY_REPLACE_EXISTING,FALSE,TRUE);
  switch(GetBaseItemType(oWeapon))//onhit neither vfx property works on ranged weapons but on their ammunition
  {
  case BASE_ITEM_SHORTBOW:
  case BASE_ITEM_LONGBOW:
  oWeapon = GetItemInSlot(INVENTORY_SLOT_ARROWS,oBarbarian);
   if(GetIsObjectValid(oWeapon))
   {
   IPSafeAddItemProperty(oWeapon,onhit,fDuration,X2_IP_ADDPROP_POLICY_REPLACE_EXISTING,FALSE,TRUE);
   }
  break;
  case BASE_ITEM_LIGHTCROSSBOW:
  case BASE_ITEM_HEAVYCROSSBOW:
  oWeapon = GetItemInSlot(INVENTORY_SLOT_BOLTS,oBarbarian);
   if(GetIsObjectValid(oWeapon))
   {
   IPSafeAddItemProperty(oWeapon,onhit,fDuration,X2_IP_ADDPROP_POLICY_REPLACE_EXISTING,FALSE,TRUE);
   }
  break;
  case BASE_ITEM_SLING:
  oWeapon = GetItemInSlot(INVENTORY_SLOT_BULLETS,oBarbarian);
   if(GetIsObjectValid(oWeapon))
   {
   IPSafeAddItemProperty(oWeapon,onhit,fDuration,X2_IP_ADDPROP_POLICY_REPLACE_EXISTING,FALSE,TRUE);
   }
  break;
  }
 oWeapon = GetItemInSlot(INVENTORY_SLOT_LEFTHAND,oBarbarian);
  if(GetIsObjectValid(oWeapon))//barbarian has two weapons
  {
  IPSafeAddItemProperty(oWeapon,critical,fDuration,X2_IP_ADDPROP_POLICY_KEEP_EXISTING,TRUE,TRUE);
  IPSafeAddItemProperty(oWeapon,vfx,fDuration,X2_IP_ADDPROP_POLICY_REPLACE_EXISTING,FALSE,TRUE);
  //no onhit for left weapon - bioware decision, perhaps balanced issue?
  }
 }
 else //no weapon!
 {
 int bCreature;
 int nSlot=14;
  for(nSlot;nSlot<17;nSlot++)
  {
  oWeapon = GetItemInSlot(nSlot,oBarbarian);//creature weapon
   if(GetIsObjectValid(oWeapon))
   {
   bCreature = TRUE;
   IPSafeAddItemProperty(oWeapon,critical,fDuration,X2_IP_ADDPROP_POLICY_KEEP_EXISTING,TRUE,TRUE);
   IPSafeAddItemProperty(oWeapon,onhit,fDuration,X2_IP_ADDPROP_POLICY_REPLACE_EXISTING,FALSE,TRUE);
   //no visual as it work only for non-creature weapons
   }
  }
  if(!bCreature)//no creature's weapons! monk or brawler
  {
  oWeapon = GetItemInSlot(INVENTORY_SLOT_ARMS,oBarbarian);//gloves
   if(GetIsObjectValid(oWeapon))
   {
   IPSafeAddItemProperty(oWeapon,onhit,fDuration,X2_IP_ADDPROP_POLICY_REPLACE_EXISTING,FALSE,TRUE);
   }
  }
 }
}

//::///////////////////////////////////////////////
//:: Community Patch 1.70 Custom functions related to item properties and shifter
//:: 70_inc_itemprop
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
This include file contains new functions used for merging items and other item-based
stuff.

Most of these functions are private, meaning they don't appear in function list because
they are specific for one purpose and not expected to be used outside of that scope.
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow
//:: Created On: ?-11-2010
//:://////////////////////////////////////////////
#include "x2_inc_switches"

int ITEM_PROPERTY_BOOMERANG             = 14;
int ITEM_PROPERTY_ITEM_COST_PARAMETER   = 42;
int ITEM_PROPERTY_WOUNDING              = 69;


// Returns Item property Boomerang. Keep in mind this property works only with NWN(C)X
itemproperty ItemPropertyBoomerang();

// Returns Item property wounding.  You must specify the wounding amount.
// The amount must be an integer between 1 and 20.
itemproperty ItemPropertyWounding(int nWoundingAmount);

// Returns Item Cost Parameter itemproperty.
// nLetter: A = 0, B = 1, C = 2, D = 3, E = 4, F = 5
// nValue: 1-10 = -1 to -10, 11-20 = +1 to +10
itemproperty ItemPropertyItemCostParameter(int nLetter, int nValue);

// returns INVENTORY_SLOT_* constant or -1 if creature haven't item equipped
int GetSlotByItem(object oItem, object oCreature=OBJECT_SELF);

//1.71 version of the IPWildShapeCopyItemProperties
void IPWildShapeMergeItemProperties(object oOld, object oNew, int bWeapon = FALSE);

//Updates item charges and fixes and issue where setting a zero charges break the cast spell
//itemproperties which won't be functional again even when charges on ths item are increased again
void UpdateItemCharges(object oItem, int nCharges);

//This is a copy of the function IPGetItemPropertyByID that includes new itemproperties added
//by CPP: boomerang, wounding and item cost parameter.
itemproperty GetItemPropertyByID( int nPropID, int nParam1 = 0, int nParam2 = 0, int nParam3 = 0, int nParam4 = 0 );

// ----------------------------------------------------------------------------
// Provide mapping between numbers and bonus constants for ITEM_PROPERTY_DAMAGE_BONUS
// Note that nNumber should be > 0!
// ----------------------------------------------------------------------------
int IPGetIPConstDamageBonusConstantFromNumber(int nNumber);

int GetSlotByItem(object oItem, object oCreature=OBJECT_SELF)
{
int nTh;
 for(;nTh < NUM_INVENTORY_SLOTS;nTh++)
 {
  if(GetItemInSlot(nTh,oCreature) == oItem)
  {
  return nTh;
  }
 }
return -1;
}

void IPWildShapeHandleAbilityBonuses_continue(object oArmorNew, object oWeaponNew, int bImmunityArmor, int bImmunityWeapon)
{
    int bStack = GetLocalInt(GetItemPossessor(oArmorNew),"71_POLYMORPH_STACK_ABILITY_BONUSES") || GetModuleSwitchValue("71_POLYMORPH_STACK_ABILITY_BONUSES");
    int STRmalus,CHAmalus,INTmalus,DEXmalus,CONmalus,WISmalus,Fort,Will,Reflex;
    int nSkill, nSave, nValue, HighestSkill = -1, HighestSave = -1;

    itemproperty ip = GetFirstItemProperty(oArmorNew);
    while(GetIsItemPropertyValid(ip))
    {
        switch(GetItemPropertyType(ip))
        {
        case ITEM_PROPERTY_DECREASED_ABILITY_SCORE:
            nValue = GetItemPropertyCostTableValue(ip);
            switch(GetItemPropertySubType(ip))
            {
            case IP_CONST_ABILITY_CON:
                if(bStack)
                CONmalus+= nValue;
                else if(nValue > CONmalus)
                CONmalus = nValue;
            break;
            case IP_CONST_ABILITY_DEX:
                if(bStack)
                DEXmalus+= nValue;
                else if(nValue > DEXmalus)
                DEXmalus = nValue;
            break;
            case IP_CONST_ABILITY_CHA:
                if(bStack)
                CHAmalus+= nValue;
                else if(nValue > CHAmalus)
                CHAmalus = nValue;
            break;
            case IP_CONST_ABILITY_INT:
                if(bStack)
                INTmalus+= nValue;
                else if(nValue > INTmalus)
                INTmalus = nValue;
            break;
            case IP_CONST_ABILITY_STR:
                if(bStack)
                STRmalus+= nValue;
                else if(nValue > STRmalus)
                STRmalus = nValue;
            break;
            case IP_CONST_ABILITY_WIS:
                if(bStack)
                WISmalus+= nValue;
                else if(nValue > WISmalus)
                WISmalus = nValue;
            break;
            }
            RemoveItemProperty(oArmorNew,ip);
        break;
        case ITEM_PROPERTY_SKILL_BONUS:
            if(bStack)
            {
                nSkill = GetItemPropertySubType(ip);
                if(nSkill > HighestSkill) HighestSkill = nSkill;
                nValue = GetItemPropertyCostTableValue(ip);
                SetLocalInt(oArmorNew,"SKILL_"+IntToString(nSkill),GetLocalInt(oArmorNew,"SKILL_"+IntToString(nSkill))+nValue);
                RemoveItemProperty(oArmorNew,ip);
            }
        break;
        case ITEM_PROPERTY_DECREASED_SKILL_MODIFIER:
            if(bStack)
            {
                nSkill = GetItemPropertySubType(ip);
                if(nSkill > HighestSkill) HighestSkill = nSkill;
                nValue = GetItemPropertyCostTableValue(ip);
                SetLocalInt(oArmorNew,"SKILL_"+IntToString(nSkill),GetLocalInt(oArmorNew,"SKILL_"+IntToString(nSkill))-nValue);
                RemoveItemProperty(oArmorNew,ip);
            }
        break;
        case ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC:
            if(bStack)
            {
                nValue = GetItemPropertyCostTableValue(ip);
                int test = GetItemPropertySubType(ip);
                switch(GetItemPropertySubType(ip))
                {
                case IP_CONST_SAVEBASETYPE_FORTITUDE:
                    Fort+= nValue;
                break;
                case IP_CONST_SAVEBASETYPE_REFLEX:
                    Reflex+= nValue;
                break;
                case IP_CONST_SAVEBASETYPE_WILL:
                    Will+= nValue;
                break;
                }
                RemoveItemProperty(oArmorNew,ip);
            }
        break;
        case ITEM_PROPERTY_DECREASED_SAVING_THROWS_SPECIFIC:
            if(bStack)
            {
                nValue = GetItemPropertyCostTableValue(ip);
                switch(GetItemPropertySubType(ip))
                {
                case IP_CONST_SAVEBASETYPE_FORTITUDE:
                    Fort-= nValue;
                break;
                case IP_CONST_SAVEBASETYPE_REFLEX:
                    Reflex-= nValue;
                break;
                case IP_CONST_SAVEBASETYPE_WILL:
                    Will-= nValue;
                break;
                }
                RemoveItemProperty(oArmorNew,ip);
            }
        break;
        case ITEM_PROPERTY_SAVING_THROW_BONUS:
            if(bStack)
            {
                nSave = GetItemPropertySubType(ip);
                if(nSave > HighestSave) HighestSave = nSave;
                nValue = GetItemPropertyCostTableValue(ip);
                SetLocalInt(oArmorNew,"SAVE_"+IntToString(nSave),GetLocalInt(oArmorNew,"SAVE_"+IntToString(nSave))+nValue);
                RemoveItemProperty(oArmorNew,ip);
            }
        break;
        case ITEM_PROPERTY_DECREASED_SAVING_THROWS:
            if(bStack)
            {
                nSave = GetItemPropertySubType(ip);
                if(nSave > HighestSave) HighestSave = nSave;
                nValue = GetItemPropertyCostTableValue(ip);
                SetLocalInt(oArmorNew,"SAVE_"+IntToString(nSave),GetLocalInt(oArmorNew,"SAVE_"+IntToString(nSave))-nValue);
                RemoveItemProperty(oArmorNew,ip);
            }
        break;
        }
        ip = GetNextItemProperty(oArmorNew);
    }
    //reapply the ability decrease itemproperties
    if(STRmalus > 0)
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyDecreaseAbility(IP_CONST_ABILITY_STR,STRmalus),oArmorNew);
    if(DEXmalus > 0)
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyDecreaseAbility(IP_CONST_ABILITY_DEX,DEXmalus),oArmorNew);
    if(CONmalus > 0)
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyDecreaseAbility(IP_CONST_ABILITY_CON,CONmalus),oArmorNew);
    if(WISmalus > 0)
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyDecreaseAbility(IP_CONST_ABILITY_WIS,WISmalus),oArmorNew);
    if(INTmalus > 0)
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyDecreaseAbility(IP_CONST_ABILITY_INT,INTmalus),oArmorNew);
    if(CHAmalus > 0)
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyDecreaseAbility(IP_CONST_ABILITY_CHA,CHAmalus),oArmorNew);
    //reapply saves
    if(Fort > 0)
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyBonusSavingThrow(IP_CONST_SAVEBASETYPE_FORTITUDE,Fort > 12 ? 12 : Fort),oArmorNew);
    else if(Fort < 0)
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyReducedSavingThrow(IP_CONST_SAVEBASETYPE_FORTITUDE,Fort < -12 ? 12 : abs(Fort)),oArmorNew);
    if(Will > 0)
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyBonusSavingThrow(IP_CONST_SAVEBASETYPE_WILL,Will > 12 ? 12 : Will),oArmorNew);
    else if(Will < 0)
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyReducedSavingThrow(IP_CONST_SAVEBASETYPE_WILL,Will < -12 ? 12 : abs(Will)),oArmorNew);
    if(Reflex > 0)
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyBonusSavingThrow(IP_CONST_SAVEBASETYPE_REFLEX,Reflex > 12 ? 12 : Reflex),oArmorNew);
    else if(Reflex < 0)
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyReducedSavingThrow(IP_CONST_SAVEBASETYPE_REFLEX,Reflex < -12 ? 12 : abs(Reflex)),oArmorNew);
    //specific saves needs to be handled differenly (to support custom content)
    for(;HighestSave > -1;HighestSave--)
    {
        nValue = GetLocalInt(oArmorNew,"SAVE_"+IntToString(HighestSave));
        if(nValue > 0)
        {
            AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyBonusSavingThrowVsX(HighestSave,nValue > 12 ? 12 : nValue),oArmorNew);
        }
        else if(nValue < 0)
        {
            AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyReducedSavingThrowVsX(HighestSave,nValue < -12 ? 12 : abs(nValue)),oArmorNew);
        }
    }
    //reapply the skills
    for(;HighestSkill > -1;HighestSkill--)
    {
        nValue = GetLocalInt(oArmorNew,"SKILL_"+IntToString(HighestSkill));
        if(nValue > 0)
        {
            AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertySkillBonus(HighestSkill,nValue > 50 ? 50 : nValue),oArmorNew);
        }
        else if(nValue < 0)
        {
            AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyDecreaseSkill(HighestSkill,nValue < -50 ? 50 : abs(nValue)),oArmorNew);
        }
    }

    if(!GetIsObjectValid(oWeaponNew))//weapon is not valid, stop here
    {
        //re-apply the immunity
        if(bImmunityArmor)
        AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_LEVEL_ABIL_DRAIN),oArmorNew);
        return;
    }

    //now do the same for weapon
    STRmalus = 0;CHAmalus = 0;INTmalus = 0;DEXmalus = 0;CONmalus = 0;WISmalus = 0;Fort = 0;Will = 0;Reflex = 0;
    ip = GetFirstItemProperty(oWeaponNew);
    while(GetIsItemPropertyValid(ip))
    {
        switch(GetItemPropertyType(ip))
        {
        case ITEM_PROPERTY_DECREASED_ABILITY_SCORE:
            nValue = GetItemPropertyCostTableValue(ip);
            switch(GetItemPropertySubType(ip))
            {
            case IP_CONST_ABILITY_CON:
               if(bStack)
                CONmalus+= nValue;
                else if(nValue > CONmalus)
                CONmalus = nValue;
            break;
            case IP_CONST_ABILITY_DEX:
                if(bStack)
                DEXmalus+= nValue;
                else if(nValue > DEXmalus)
                DEXmalus = nValue;
            break;
            case IP_CONST_ABILITY_CHA:
                if(bStack)
                CHAmalus+= nValue;
                else if(nValue > CHAmalus)
                CHAmalus = nValue;
            break;
            case IP_CONST_ABILITY_INT:
                if(bStack)
                INTmalus+= nValue;
                else if(nValue > INTmalus)
                INTmalus = nValue;
            break;
            case IP_CONST_ABILITY_STR:
                if(bStack)
                STRmalus+= nValue;
                else if(nValue > STRmalus)
                STRmalus = nValue;
            break;
            case IP_CONST_ABILITY_WIS:
                if(bStack)
                WISmalus+= nValue;
                else if(nValue > WISmalus)
                WISmalus = nValue;
            break;
            }
            RemoveItemProperty(oWeaponNew,ip);
        break;
        case ITEM_PROPERTY_SKILL_BONUS:
            if(bStack)
            {
                nSkill = GetItemPropertySubType(ip);
                if(nSkill > HighestSkill) HighestSkill = nSkill;
                nValue = GetItemPropertyCostTableValue(ip);
                SetLocalInt(oWeaponNew,"SKILL_"+IntToString(nSkill),GetLocalInt(oWeaponNew,"SKILL_"+IntToString(nSkill))+nValue);
                RemoveItemProperty(oWeaponNew,ip);
            }
        break;
        case ITEM_PROPERTY_DECREASED_SKILL_MODIFIER:
            if(bStack)
            {
                nSkill = GetItemPropertySubType(ip);
                if(nSkill > HighestSkill) HighestSkill = nSkill;
                nValue = GetItemPropertyCostTableValue(ip);
                SetLocalInt(oWeaponNew,"SKILL_"+IntToString(nSkill),GetLocalInt(oWeaponNew,"SKILL_"+IntToString(nSkill))-nValue);
                RemoveItemProperty(oWeaponNew,ip);
            }
        break;
        case ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC:
            if(bStack)
            {
                nValue = GetItemPropertyCostTableValue(ip);
                switch(GetItemPropertySubType(ip))
                {
                case IP_CONST_SAVEBASETYPE_FORTITUDE:
                    Fort+= nValue;
                break;
                case IP_CONST_SAVEBASETYPE_REFLEX:
                    Reflex+= nValue;
                break;
                case IP_CONST_SAVEBASETYPE_WILL:
                    Will+= nValue;
                break;
                }
                RemoveItemProperty(oWeaponNew,ip);
            }
        break;
        case ITEM_PROPERTY_DECREASED_SAVING_THROWS_SPECIFIC:
            if(bStack)
            {
                nValue = GetItemPropertyCostTableValue(ip);
                switch(GetItemPropertySubType(ip))
                {
                case IP_CONST_SAVEBASETYPE_FORTITUDE:
                    Fort-= nValue;
                break;
                case IP_CONST_SAVEBASETYPE_REFLEX:
                    Reflex-= nValue;
                break;
                case IP_CONST_SAVEBASETYPE_WILL:
                    Will-= nValue;
                break;
                }
                RemoveItemProperty(oWeaponNew,ip);
            }
        break;
        case ITEM_PROPERTY_SAVING_THROW_BONUS:
            if(bStack)
            {
                nSave = GetItemPropertySubType(ip);
                if(nSave > HighestSave) HighestSave = nSave;
                nValue = GetItemPropertyCostTableValue(ip);
                SetLocalInt(oWeaponNew,"SAVE_"+IntToString(nSave),GetLocalInt(oWeaponNew,"SAVE_"+IntToString(nSave))+nValue);
                RemoveItemProperty(oWeaponNew,ip);
            }
        break;
        case ITEM_PROPERTY_DECREASED_SAVING_THROWS:
            if(bStack)
            {
                nSave = GetItemPropertySubType(ip);
                if(nSave > HighestSave) HighestSave = nSave;
                nValue = GetItemPropertyCostTableValue(ip);
                SetLocalInt(oWeaponNew,"SAVE_"+IntToString(nSave),GetLocalInt(oWeaponNew,"SAVE_"+IntToString(nSave))-nValue);
                RemoveItemProperty(oWeaponNew,ip);
            }
        break;
        }
        ip = GetNextItemProperty(oWeaponNew);
    }
    //reapply the ability decrease itemproperties
    if(STRmalus > 0)
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyDecreaseAbility(IP_CONST_ABILITY_STR,STRmalus),oWeaponNew);
    if(DEXmalus > 0)
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyDecreaseAbility(IP_CONST_ABILITY_DEX,DEXmalus),oWeaponNew);
    if(CONmalus > 0)
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyDecreaseAbility(IP_CONST_ABILITY_CON,CONmalus),oWeaponNew);
    if(WISmalus > 0)
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyDecreaseAbility(IP_CONST_ABILITY_WIS,WISmalus),oWeaponNew);
    if(INTmalus > 0)
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyDecreaseAbility(IP_CONST_ABILITY_INT,INTmalus),oWeaponNew);
    if(CHAmalus > 0)
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyDecreaseAbility(IP_CONST_ABILITY_CHA,CHAmalus),oWeaponNew);
    //reapply saves
    if(Fort > 0)
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyBonusSavingThrow(IP_CONST_SAVEBASETYPE_FORTITUDE,Fort > 12 ? 12 : Fort),oWeaponNew);
    else if(Fort < 0)
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyReducedSavingThrow(IP_CONST_SAVEBASETYPE_FORTITUDE,Fort > 12 ? 12 : Fort),oWeaponNew);
    if(Will > 0)
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyBonusSavingThrow(IP_CONST_SAVEBASETYPE_WILL,Will > 12 ? 12 : Will),oWeaponNew);
    else if(Will < 0)
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyReducedSavingThrow(IP_CONST_SAVEBASETYPE_WILL,Will > 12 ? 12 : Will),oWeaponNew);
    if(Reflex > 0)
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyBonusSavingThrow(IP_CONST_SAVEBASETYPE_REFLEX,Reflex > 12 ? 12 : Reflex),oWeaponNew);
    else if(Reflex < 0)
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyReducedSavingThrow(IP_CONST_SAVEBASETYPE_REFLEX,Reflex > 12 ? 12 : Reflex),oWeaponNew);
    //specific saves needs to be handled differenly (to support custom content)
    for(;HighestSave > -1;HighestSave--)
    {
        nValue = GetLocalInt(oWeaponNew,"SAVE_"+IntToString(HighestSave));
        if(nValue > 0)
        {
            AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyBonusSavingThrowVsX(HighestSave,nValue > 12 ? 12 : nValue),oWeaponNew);
        }
        else if(nValue < 0)
        {
            AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyReducedSavingThrowVsX(HighestSave,nValue > 12 ? 12 : nValue),oWeaponNew);
        }
    }
    //reapply the skills
    for(;HighestSkill > -1;HighestSkill--)
    {
        nValue = GetLocalInt(oWeaponNew,"SKILL_"+IntToString(HighestSkill));
        if(nValue > 0)
        {
            AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertySkillBonus(HighestSkill,nValue > 50 ? 50 : nValue),oWeaponNew);
        }
        else if(nValue < 0)
        {
            AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyDecreaseSkill(HighestSkill,nValue < -50 ? 50 : abs(nValue)),oWeaponNew);
        }
    }

    //now re-apply the immunities
    if(bImmunityArmor)
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_LEVEL_ABIL_DRAIN),oArmorNew);
    if(bImmunityWeapon)
    AddItemProperty(DURATION_TYPE_PERMANENT,ItemPropertyImmunityMisc(IP_CONST_IMMUNITYMISC_LEVEL_ABIL_DRAIN),oWeaponNew);
}

//1.71 by Shadooow, private function for new way to handle ability bonuses when polymorphing
void IPWildShapeHandleAbilityBonuses(object oArmorNew, object oWeaponNew)
{
    int bImmunityArmor, bImmunityWeapon;
    //this is a workaround for an issue where shapes with natural immunity to ability/level decrease will be immune to the decreases from merged items
    itemproperty ip = GetFirstItemProperty(oWeaponNew);
    while(GetIsItemPropertyValid(ip))
    {
        //found ability decrease itemproperty on weapon
        if(GetItemPropertyType(ip) == ITEM_PROPERTY_IMMUNITY_MISCELLANEOUS && GetItemPropertySubType(ip) == IP_CONST_IMMUNITYMISC_LEVEL_ABIL_DRAIN)
        {
            bImmunityWeapon = TRUE;
            RemoveItemProperty(oWeaponNew,ip);//temporarily remove it
        }
        ip = GetNextItemProperty(oWeaponNew);
    }
    ip = GetFirstItemProperty(oArmorNew);
    while(GetIsItemPropertyValid(ip))
    {
        //found ability decrease itemproperty on skin
        if(GetItemPropertyType(ip) == ITEM_PROPERTY_IMMUNITY_MISCELLANEOUS && GetItemPropertySubType(ip) == IP_CONST_IMMUNITYMISC_LEVEL_ABIL_DRAIN)
        {
            bImmunityArmor = TRUE;
            RemoveItemProperty(oArmorNew,ip);//temporarily remove it
        }
        ip = GetNextItemProperty(oArmorNew);
    }
    //needs a delay to complete the immunity removal
    DelayCommand(0.0,IPWildShapeHandleAbilityBonuses_continue(oArmorNew,oWeaponNew,bImmunityArmor,bImmunityWeapon));
}

void ApplyWounding_continue(object oItem, int nNum, int nSlot)
{
object oPC = GetItemPossessor(oItem);
 if(GetItemInSlot(nSlot,oPC) == oItem)
 {
  if(!GetIsResting(oPC) && GetCurrentHitPoints(oPC) > -10)
  {
  AssignCommand(oItem,ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectDamage(nNum,DAMAGE_TYPE_MAGICAL),oPC));
  }
 DelayCommand(6.0,ApplyWounding_continue(oItem,nNum,nSlot));
 }
 else
 {
 SetLocalInt(GetModule(),ObjectToString(oItem)+ObjectToString(OBJECT_SELF),FALSE);
 }
}

//1.71: private function to handle wounding itemproperty
void ApplyWounding(object oItem, object oPC, int nNum)
{
int nSlot = GetSlotByItem(oItem,oPC);
 if(nSlot > -1 && !GetLocalInt(GetModule(),ObjectToString(oItem)+ObjectToString(oPC)))
 {
 SetLocalInt(GetModule(),ObjectToString(oItem)+ObjectToString(oPC),TRUE);
 AssignCommand(oPC,DelayCommand(6.0,ApplyWounding_continue(oItem,nNum,nSlot)));
 }
}

void IPWildShapeMergeItemProperties(object oOld, object oNew, int bWeapon = FALSE)
{
    if(GetIsObjectValid(oOld) && GetIsObjectValid(oNew))
    {
        itemproperty ip = GetFirstItemProperty(oOld);
        while (GetIsItemPropertyValid(ip))
        {
            if(GetItemPropertyType(ip) != ITEM_PROPERTY_ABILITY_BONUS && (!bWeapon || GetWeaponRanged(oOld) == GetWeaponRanged(oNew)))
            {
                AddItemProperty(DURATION_TYPE_PERMANENT,ip,oNew);
            }
            ip = GetNextItemProperty(oOld);
        }
    }
}

itemproperty ItemPropertyBoomerang()
{
object oItem = CreateObject(OBJECT_TYPE_ITEM,"70_ip_14",GetStartingLocation());
itemproperty ip = GetFirstItemProperty(oItem);
DestroyObject(oItem);
return ip;
}

itemproperty ItemPropertyWounding(int nWoundingAmount)
{
object oItem = CreateObject(OBJECT_TYPE_ITEM,"70_ip_69_"+IntToString(nWoundingAmount),GetStartingLocation());
itemproperty ip = GetFirstItemProperty(oItem);
DestroyObject(oItem);
return ip;
}

itemproperty ItemPropertyItemCostParameter(int nLetter, int nValue)
{
object oItem = CreateObject(OBJECT_TYPE_ITEM,"70_ip_42_"+IntToString(nLetter)+"_"+IntToString(nValue),GetStartingLocation());
itemproperty ip = GetFirstItemProperty(oItem);
DestroyObject(oItem);
return ip;
}

//Private version of the SKIN_SupportEquipSkin function to handle special case after relog
void CPP_SupportEquipSkin(object oSkin,int nCount=0)
{ // PURPOSE: Force equip skin
    object skinOld = GetLocalObject(OBJECT_SELF,"oX3_Skin");
    if(oSkin != skinOld)
    {
        DestroyObject(skinOld);
        SetLocalObject(OBJECT_SELF,"oX3_Skin",oSkin);
    }
    effect e = GetFirstEffect(OBJECT_SELF);
    while(GetIsEffectValid(e))
    {
        if(GetEffectType(e) == EFFECT_TYPE_POLYMORPH)
        {
            DelayCommand(3.0,CPP_SupportEquipSkin(oSkin,nCount));
            return;
        }
        e = GetNextEffect(OBJECT_SELF);
    }
    skinOld = GetItemInSlot(INVENTORY_SLOT_CARMOUR,OBJECT_SELF);
    if(GetIsObjectValid(skinOld) && oSkin != skinOld)
    { // skin already present
        DestroyObject(oSkin);
    } // skin already present
    else if(nCount > 0 && GetCurrentAction() == ACTION_REST)
    { // wait till resting finished
        DelayCommand(0.2,CPP_SupportEquipSkin(oSkin,nCount));
    } // wait till resting finished
    else if(oSkin != skinOld)
    { // equip
        AssignCommand(OBJECT_SELF,ActionEquipItem(oSkin,INVENTORY_SLOT_CARMOUR));
        if (nCount<29) DelayCommand(0.2,CPP_SupportEquipSkin(oSkin,nCount+1));
    } // equip
} // SKIN_SupportEquipSkin()


void UpdateItemCharges(object oItem, int nCharges)
{
int charges = GetItemCharges(oItem);
SetItemCharges(oItem,nCharges);
 if(charges > 0)
 return;
itemproperty ip = GetFirstItemProperty(oItem);
float fDelay = 0.0;
 while(GetIsItemPropertyValid(ip))
 {
  if(GetItemPropertyType(ip) == ITEM_PROPERTY_CAST_SPELL)
  {
  RemoveItemProperty(oItem,ip);
  DelayCommand(fDelay,AddItemProperty(DURATION_TYPE_PERMANENT,ip,oItem));
  fDelay+=0.01;
  }
 ip = GetNextItemProperty(oItem);
 }
}

itemproperty GetItemPropertyByID( int nPropID, int nParam1 = 0, int nParam2 = 0, int nParam3 = 0, int nParam4 = 0 )
{
   itemproperty ipRet;

   if (nPropID == ITEM_PROPERTY_ABILITY_BONUS)
   {
        ipRet = ItemPropertyAbilityBonus(nParam1, nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_AC_BONUS)
   {
        ipRet = ItemPropertyACBonus(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_AC_BONUS_VS_ALIGNMENT_GROUP)
   {
        ipRet = ItemPropertyACBonusVsAlign(nParam1, nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_AC_BONUS_VS_DAMAGE_TYPE)
   {
        ipRet = ItemPropertyACBonusVsDmgType(nParam1, nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_AC_BONUS_VS_RACIAL_GROUP)
   {
        ipRet = ItemPropertyACBonusVsRace(nParam1, nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_AC_BONUS_VS_SPECIFIC_ALIGNMENT)
   {
        ipRet = ItemPropertyACBonusVsSAlign(nParam1, nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_ATTACK_BONUS)
   {
        ipRet = ItemPropertyAttackBonus(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_ATTACK_BONUS_VS_ALIGNMENT_GROUP)
   {
        ipRet = ItemPropertyAttackBonusVsAlign(nParam1, nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_ATTACK_BONUS_VS_RACIAL_GROUP)
   {
        ipRet = ItemPropertyAttackBonusVsRace(nParam1, nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_ATTACK_BONUS_VS_SPECIFIC_ALIGNMENT)
   {
        ipRet = ItemPropertyAttackBonusVsSAlign(nParam1, nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_BASE_ITEM_WEIGHT_REDUCTION)
   {
        ipRet = ItemPropertyWeightReduction(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_BONUS_FEAT)
   {
        ipRet = ItemPropertyBonusFeat(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_BONUS_SPELL_SLOT_OF_LEVEL_N)
   {
        ipRet = ItemPropertyBonusLevelSpell(nParam1, nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_CAST_SPELL)
   {
        ipRet = ItemPropertyCastSpell(nParam1, nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_DAMAGE_BONUS)
   {
        ipRet = ItemPropertyDamageBonus(nParam1, nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_DAMAGE_BONUS_VS_ALIGNMENT_GROUP)
   {
        ipRet = ItemPropertyDamageBonusVsAlign(nParam1, nParam2, nParam3);
   }
   else if (nPropID == ITEM_PROPERTY_DAMAGE_BONUS_VS_RACIAL_GROUP)
   {
        ipRet = ItemPropertyDamageBonusVsRace(nParam1, nParam2, nParam3);
   }
   else if (nPropID == ITEM_PROPERTY_DAMAGE_BONUS_VS_SPECIFIC_ALIGNMENT)
   {
        ipRet = ItemPropertyDamageBonusVsSAlign(nParam1, nParam2, nParam3);
   }
   else if (nPropID == ITEM_PROPERTY_DAMAGE_REDUCTION)
   {
        ipRet = ItemPropertyDamageReduction(nParam1, nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_DAMAGE_RESISTANCE)
   {
        ipRet = ItemPropertyDamageResistance(nParam1, nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_DAMAGE_VULNERABILITY)
   {
        ipRet = ItemPropertyDamageResistance(nParam1, nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_DARKVISION)
   {
        ipRet = ItemPropertyDarkvision();
   }
   else if (nPropID == ITEM_PROPERTY_DECREASED_ABILITY_SCORE)
   {
        ipRet = ItemPropertyDecreaseAbility(nParam1,nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_DECREASED_AC)
   {
        ipRet = ItemPropertyDecreaseAC(nParam1,nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_DECREASED_ATTACK_MODIFIER)
   {
        ipRet = ItemPropertyAttackPenalty(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_DECREASED_ENHANCEMENT_MODIFIER)
   {
        ipRet = ItemPropertyEnhancementPenalty(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_DECREASED_DAMAGE)
   {
        ipRet = ItemPropertyDamagePenalty(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_DECREASED_SAVING_THROWS)
   {
        ipRet = ItemPropertyReducedSavingThrow(nParam1, nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_DECREASED_SAVING_THROWS_SPECIFIC)
   {
        ipRet = ItemPropertyBonusSavingThrowVsX(nParam1, nParam2);
   }
    else if (nPropID == ITEM_PROPERTY_DECREASED_SKILL_MODIFIER)
   {
        ipRet = ItemPropertyDecreaseSkill(nParam1, nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_ENHANCED_CONTAINER_REDUCED_WEIGHT)
   {
        ipRet = ItemPropertyContainerReducedWeight(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_ENHANCEMENT_BONUS)
   {
        ipRet = ItemPropertyEnhancementBonus(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_ALIGNMENT_GROUP)
   {
        ipRet = ItemPropertyEnhancementBonusVsAlign(nParam1,nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_SPECIFIC_ALIGNEMENT)
   {
        ipRet = ItemPropertyEnhancementBonusVsSAlign(nParam1,nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_ENHANCEMENT_BONUS_VS_RACIAL_GROUP)
   {
        ipRet = ItemPropertyEnhancementBonusVsRace(nParam1,nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_EXTRA_MELEE_DAMAGE_TYPE)
   {
        ipRet = ItemPropertyExtraMeleeDamageType(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_EXTRA_RANGED_DAMAGE_TYPE)
   {
        ipRet = ItemPropertyExtraRangeDamageType(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_HASTE)
   {
        ipRet = ItemPropertyHaste();
   }
   else if (nPropID == ITEM_PROPERTY_KEEN)
   {
        ipRet = ItemPropertyKeen();
   }
   else if (nPropID == ITEM_PROPERTY_LIGHT)
   {
        ipRet = ItemPropertyLight(nParam1,nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_MASSIVE_CRITICALS)
   {
        ipRet = ItemPropertyMassiveCritical(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_NO_DAMAGE)
   {
        ipRet = ItemPropertyNoDamage();
   }
   else if (nPropID == ITEM_PROPERTY_ON_HIT_PROPERTIES)
   {
        ipRet = ItemPropertyOnHitProps(nParam1, nParam2, nParam3);
   }
   else if (nPropID == ITEM_PROPERTY_TRAP)
   {
        ipRet = ItemPropertyTrap(nParam1, nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_TRUE_SEEING)
   {
        ipRet = ItemPropertyTrueSeeing();
   }
   else if (nPropID == ITEM_PROPERTY_UNLIMITED_AMMUNITION)
   {
        ipRet = ItemPropertyUnlimitedAmmo(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_ONHITCASTSPELL)
   {
        ipRet = ItemPropertyOnHitCastSpell(nParam1, nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_ARCANE_SPELL_FAILURE)
   {
        ipRet = ItemPropertyArcaneSpellFailure(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_ADDITIONAL)
   {
        ipRet = ItemPropertyAdditional(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_MATERIAL)
   {
        ipRet = ItemPropertyMaterial(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_QUALITY)
   {
        ipRet = ItemPropertyQuality(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_SAVING_THROW_BONUS)
   {
        ipRet = ItemPropertyBonusSavingThrow(nParam1, nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_SAVING_THROW_BONUS_SPECIFIC)
   {
        ipRet = ItemPropertyBonusSavingThrowVsX(nParam1, nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_SPELL_RESISTANCE)
   {
        ipRet = ItemPropertyBonusSpellResistance(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_IMMUNITY_DAMAGE_TYPE)
   {
        ipRet = ItemPropertyDamageImmunity(nParam1,nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_IMMUNITY_MISCELLANEOUS)
   {
        ipRet = ItemPropertyImmunityMisc(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_IMMUNITY_SPECIFIC_SPELL)
   {
        ipRet = ItemPropertySpellImmunitySpecific(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_IMMUNITY_SPELL_SCHOOL)
   {
        ipRet = ItemPropertySpellImmunitySchool(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_IMMUNITY_SPELLS_BY_LEVEL)
   {
        ipRet = ItemPropertyImmunityToSpellLevel(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_FREEDOM_OF_MOVEMENT)
   {
        ipRet = ItemPropertyFreeAction();
   }
   else if (nPropID == ITEM_PROPERTY_HEALERS_KIT)
   {
        ipRet = ItemPropertyHealersKit(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_HOLY_AVENGER)
   {
        ipRet = ItemPropertyHolyAvenger();
   }
   else if (nPropID == ITEM_PROPERTY_IMPROVED_EVASION)
   {
        ipRet = ItemPropertyImprovedEvasion();
   }
   else if (nPropID == ITEM_PROPERTY_USE_LIMITATION_ALIGNMENT_GROUP)
   {
        ipRet = ItemPropertyLimitUseByAlign(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_USE_LIMITATION_CLASS)
   {
        ipRet = ItemPropertyLimitUseByClass(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_USE_LIMITATION_RACIAL_TYPE)
   {
        ipRet = ItemPropertyLimitUseByRace(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_USE_LIMITATION_SPECIFIC_ALIGNMENT)
   {
        ipRet = ItemPropertyLimitUseBySAlign(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_MIGHTY)
   {
        ipRet = ItemPropertyMaxRangeStrengthMod(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_MONSTER_DAMAGE)
   {
        ipRet = ItemPropertyMonsterDamage(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_ON_MONSTER_HIT)
   {
        ipRet = ItemPropertyOnMonsterHitProperties(nParam1,nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_REGENERATION)
   {
        ipRet = ItemPropertyRegeneration(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_SKILL_BONUS)
   {
        ipRet = ItemPropertySkillBonus(nParam1,nParam2);
   }
   else if (nPropID == ITEM_PROPERTY_SPECIAL_WALK)
   {
        ipRet = ItemPropertySpecialWalk(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_THIEVES_TOOLS)
   {
        ipRet = ItemPropertyThievesTools(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_TURN_RESISTANCE)
   {
        ipRet = ItemPropertyTurnResistance(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_REGENERATION_VAMPIRIC)
   {
        ipRet = ItemPropertyVampiricRegeneration(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_VISUALEFFECT)
   {
        ipRet = ItemPropertyVisualEffect(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_WEIGHT_INCREASE)
   {
        ipRet = ItemPropertyWeightIncrease(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_BOOMERANG)
   {
        ipRet = ItemPropertyBoomerang();
   }
   else if (nPropID == ITEM_PROPERTY_WOUNDING)
   {
        ipRet = ItemPropertyWounding(nParam1);
   }
   else if (nPropID == ITEM_PROPERTY_ITEM_COST_PARAMETER)
   {
        ipRet = ItemPropertyItemCostParameter(nParam1,nParam2);
   }
   return ipRet;
}

int IPGetIPConstDamageBonusConstantFromNumber(int nNumber)
{
    switch(nNumber)
    {
        case 1:  return IP_CONST_DAMAGEBONUS_1;
        case 2:  return IP_CONST_DAMAGEBONUS_2;
        case 3:  return IP_CONST_DAMAGEBONUS_3;
        case 4:  return IP_CONST_DAMAGEBONUS_4;
        case 5:  return IP_CONST_DAMAGEBONUS_5;
        case 6:  return IP_CONST_DAMAGEBONUS_6;
        case 7:  return IP_CONST_DAMAGEBONUS_7;
        case 8:  return IP_CONST_DAMAGEBONUS_8;
        case 9:  return IP_CONST_DAMAGEBONUS_9;
    }
    return nNumber >= 10 ? IP_CONST_DAMAGEBONUS_10 : -1;
}

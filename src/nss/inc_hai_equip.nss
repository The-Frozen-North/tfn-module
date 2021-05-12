/*

    Henchman Inventory And Battle AI

    This file contains routines used in equipping monsters
    and henchman. Contains modified EquipAppropriateWeapons
    function (renamed HenchEquipAppropriateWeapons)

*/

#include "inc_hai_generic"

// void main() {    }

// internal weapon state settings
const int HENCH_AI_WEAPON_INIT =          0x00000001;
const int HENCH_AI_HAS_MELEE =            0x00000002;
const int HENCH_AI_HAS_MELEE_WEAPON =     0x00000004;
const int HENCH_AI_HAS_RANGED_WEAPON =    0x00000008;


const string HENCH_AI_WEAPON = "HENCH_AI_WEAPON";
const string HENCH_AI_STORED_MELEE = "HenchStoredMeleeWeapon";
const string HENCH_AI_STORED_RANGED = "HenchStoredRangedWeapon";
const string HENCH_AI_STORED_SHIELD = "StoredShield";
const string HENCH_AI_SHIELD_STATUS = "HaveShieldStatus";
const string HENCH_AI_STORED_OFF_HAND = "StoredOffHand";
const string HENCH_AI_OFF_HAND_STATUS = "HaveOffhandStatus";
const string HENCH_AI_SWITCHED_TO_MELEE = "SwitchedToMelee";
const string HENCH_AI_COMBAT_EQUIP = "HenchCombatEquip";


// void main() {    }


// cache weapon state information on self
void SetWeaponState(int nCondition, int bValid = TRUE);

// un-equip weapons from left and right hands
void UnequipWeapons();

// equip best shield available
void EquipShield(int bIndicateStatus);

// get cached weapon state information
int GetInitWeaponStatus();

// equip best melee weapon(s) against target AND check for shield
int EquipMeleeWeapons(object oTarget, int bIndicateStatus, int iCallNumber);

// equip best ranged weapon(s) against target
int EquipRangedWeapon(object oTarget, int bIndicateStatus, int iCallNumber);

// equip best weapons based on target and threshold distance
int HenchEquipAppropriateWeapons(object oTarget, float fThresholdDistance, int bIndicateSwitch, int bPolymorphed);

// continue weapon equipping that is in progress
void ActionContinueEquip(object oTarget, int bIndicateStatus, int iCallNumber);

// wrapper to equip default weapons
void HenchEquipDefaultWeapons(object oCreature = OBJECT_SELF, int bShowStatus = FALSE);

// clear all cached weapon state information
void ClearWeaponStates(object oCreature = OBJECT_SELF);

// equip weapons on self
void ActionChangeEquippedWeapons();

// equip weapons on target creature
void ChangeEquippedWeapons(object oCreature);


void SetWeaponState(int nCondition, int bValid = TRUE)
{
    int nStatus = GetLocalInt(OBJECT_SELF, HENCH_AI_WEAPON);
    if (bValid)
    {
        nStatus = nStatus | nCondition;
        SetLocalInt(OBJECT_SELF, HENCH_AI_WEAPON, nStatus);
    }
    else
    {
        nStatus = nStatus & ~nCondition;
        SetLocalInt(OBJECT_SELF, HENCH_AI_WEAPON, nStatus);
    }
}


void UnequipWeapons()
{
    object oRight = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);
    if (GetIsObjectValid(oRight))
    {
        ActionUnequipItem(oRight);
    }
    object oLeft = GetItemInSlot(INVENTORY_SLOT_LEFTHAND);
    if (GetIsObjectValid(oLeft))
    {
        ActionUnequipItem(oLeft);
    }
}


void EquipShield(int bIndicateStatus)
{
    int iHaveShieldStatus = GetLocalInt(OBJECT_SELF, HENCH_AI_SHIELD_STATUS);
    object oShield = GetItemInSlot(INVENTORY_SLOT_LEFTHAND);
    if (iHaveShieldStatus == 2)
    {
        // not really a shield, get rid of
        if (GetIsObjectValid(oShield))
        {
            ActionUnequipItem(oShield);
        }
        return;
    }
    if (iHaveShieldStatus == 1)
    {
        object oStoredShield = GetLocalObject(OBJECT_SELF, HENCH_AI_STORED_SHIELD);
        if (oStoredShield == oShield)
        {
            return;
        }

        if (GetIsObjectValid(oStoredShield) && (GetItemPossessor(oStoredShield) == OBJECT_SELF))
        {
            ActionEquipItem(oStoredShield, INVENTORY_SLOT_LEFTHAND);
            return;
        }
    }

    int nMaxValue = 0;
    int iCreatureSize = GetCreatureSize(OBJECT_SELF);
    object oRealMaster = GetRealMaster();
    int bNoPCMaster = !(GetIsObjectValid(oRealMaster) && GetIsPC(oRealMaster));
    if (GetIsObjectValid(oShield))
    {
        int nSize = 1;      // note start at one less so easy compare with creature size
        switch (GetBaseItemType(oShield))
        {
            case BASE_ITEM_TOWERSHIELD:
                nSize ++;
            case BASE_ITEM_LARGESHIELD:
                nSize ++;
            case BASE_ITEM_SMALLSHIELD:
                if (bNoPCMaster || GetIdentified(oShield))
                {
                    int bPlotFlag = GetPlotFlag(oShield);
                    if (bPlotFlag)
                    {
                        SetPlotFlag(oShield, FALSE);
                    }
                    nMaxValue = GetGoldPieceValue(oShield);
                    if (bPlotFlag)
                    {
                        SetPlotFlag(oShield, TRUE);
                    }
                }
                else
                {
                    nMaxValue = 2;
                }
                break;
/*            case BASE_ITEM_TORCH:
                nMaxValue = 1;
                break; */
            default:
                // not a shield - remove
                ActionUnequipItem(oShield);
                oShield = OBJECT_INVALID;
                break;
        }
    }

    int iNewShield = FALSE;
    int tempValue;
    int bHasShieldProf = GetHasFeat(FEAT_SHIELD_PROFICIENCY);
    int bCantUseShield = FALSE;
//    int bCanUseTorch = (iCreatureSize > 1) && GetCreatureUseItems(OBJECT_SELF);

    object oItem = GetFirstItemInInventory();
    while (GetIsObjectValid(oItem))
    {
        // skip past any items in a container
        if (GetHasInventory(oItem))
        {
            object oContainer = oItem;
            object oSubItem = GetFirstItemInInventory(oContainer);
            oItem = GetNextItemInInventory();
            while (GetIsObjectValid(oSubItem))
            {
                oItem = GetNextItemInInventory();
                oSubItem = GetNextItemInInventory(oContainer);
            }
            continue;
        }
        int nSize = 1;      // note start at one less so easy compare with creature size
        switch (GetBaseItemType(oItem))
        {
            case BASE_ITEM_TOWERSHIELD:
                nSize ++;
            case BASE_ITEM_LARGESHIELD:
                nSize ++;
            case BASE_ITEM_SMALLSHIELD:
                if (bHasShieldProf && (iCreatureSize >= nSize))
                {
                    if (bNoPCMaster || GetIdentified(oItem))
                    {
                        int bPlotFlag = GetPlotFlag(oItem);
                        if (bPlotFlag)
                        {
                            SetPlotFlag(oItem, FALSE);
                        }
                        tempValue = GetGoldPieceValue(oItem);
                        if (bPlotFlag)
                        {
                            SetPlotFlag(oItem, TRUE);
                        }
                    }
                    else
                    {
                        tempValue = 2;
                    }
                    if (tempValue > nMaxValue)
                    {
                        nMaxValue = tempValue;
                        oShield = oItem;
                        iNewShield = TRUE;
                    }
                }
                else
                {
                    bCantUseShield = TRUE;
                }
                break;
/*            case BASE_ITEM_TORCH:
                if (bCanUseTorch && (1 > nMaxValue))
                {
                    nMaxValue = 1;
                    oShield = oItem;
                    iNewShield = TRUE;
                } */
                break;
            default:
                break;

        }
        oItem = GetNextItemInInventory();
    }
    if (nMaxValue > 0)
    {
        SetLocalInt(OBJECT_SELF, HENCH_AI_SHIELD_STATUS, 1);
        SetLocalObject(OBJECT_SELF, HENCH_AI_STORED_SHIELD, oShield);
    }
    else
    {
        SetLocalInt(OBJECT_SELF, HENCH_AI_SHIELD_STATUS, 2);
        DeleteLocalObject(OBJECT_SELF, HENCH_AI_STORED_SHIELD);
    }
    if (iNewShield)
    {
        ActionEquipItem(oShield, INVENTORY_SLOT_LEFTHAND);
    }
    else if (bCantUseShield && bIndicateStatus)
    {
        SpeakString(sHenchCantUseShield);
    }
}


int GetMeleeWeaponSize(object oItem)
{
    if (GetWeaponRanged(oItem))
    {
        return 0;
    }
    int nBase = GetBaseItemType(oItem);
    if (nBase == BASE_ITEM_TORCH)
    {
        return 0;
    }
    string sWeaponSizeStr = "HENCH_AI_WEAPON_SIZE_" + IntToString(nBase);
    object oModule = GetModule();
    int iWeaponSize = GetLocalInt(oModule, sWeaponSizeStr);
    if (iWeaponSize == 0)
    {
        iWeaponSize = StringToInt(Get2DAString("baseitems", "WeaponSize", nBase));
        if (iWeaponSize == 0)
        {
            iWeaponSize = -1;
        }
        SetLocalInt(oModule, sWeaponSizeStr, iWeaponSize);
    }
    if (iWeaponSize > 0)
    {
        return iWeaponSize;
    }
    return 0;
}


int GetInitWeaponStatus()
{
    int nResult = GetLocalInt(OBJECT_SELF, HENCH_AI_WEAPON);
    if (nResult)
    {
        return nResult;
    }

    int bHasMeleeWeapon;
    int bHasMeleeAttack;
    int bHasRangedWeapon;

    object oItem = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);
    if (GetIsObjectValid(oItem))
    {
        if (GetWeaponRanged(oItem))
        {
            bHasRangedWeapon = TRUE;
        }
        else if (GetMeleeWeaponSize(oItem) > 0)
        {
            bHasMeleeWeapon = TRUE;
        }
    }

    oItem = GetFirstItemInInventory();
    while (GetIsObjectValid(oItem) && !(bHasMeleeWeapon && bHasRangedWeapon))
    {
        // skip past any items in a container
        if (GetHasInventory(oItem))
        {
            object oContainer = oItem;
            object oSubItem = GetFirstItemInInventory(oContainer);
            oItem = GetNextItemInInventory();
            while (GetIsObjectValid(oSubItem))
            {
                oItem = GetNextItemInInventory();
                oSubItem = GetNextItemInInventory(oContainer);
            }
            continue;
        }
        if (!bHasRangedWeapon && GetWeaponRanged(oItem))
        {
            bHasRangedWeapon = TRUE;
        }
        else if (!bHasMeleeWeapon && GetMeleeWeaponSize(oItem) > 0)
        {
            bHasMeleeWeapon = TRUE;
        }
        oItem = GetNextItemInInventory();
    }
    if (!bHasMeleeWeapon)
    {
        if (GetHasFeat(FEAT_IMPROVED_UNARMED_STRIKE))
        {
            bHasMeleeAttack = TRUE;
        }
        else if (GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_CWEAPON_R)))
        {
            bHasMeleeAttack = TRUE;
        }
        else if (GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_CWEAPON_B)))
        {
            bHasMeleeAttack = TRUE;
        }
        else if (GetIsObjectValid(GetItemInSlot(INVENTORY_SLOT_CWEAPON_L)))
        {
            bHasMeleeAttack = TRUE;
        }
    }
    else
    {
        bHasMeleeAttack = TRUE;
    }
    if (bHasMeleeAttack)
    {
        nResult = HENCH_AI_WEAPON_INIT | HENCH_AI_HAS_MELEE;
    }
    else
    {
        nResult = HENCH_AI_WEAPON_INIT;
    }
    if (bHasMeleeWeapon)
    {
        nResult = nResult | HENCH_AI_HAS_MELEE_WEAPON;
    }
    if (bHasRangedWeapon)
    {
        nResult = nResult | HENCH_AI_HAS_RANGED_WEAPON;
    }

    SetLocalInt(OBJECT_SELF, HENCH_AI_WEAPON, nResult);
    return nResult;
}


int EquipMeleeWeapons(object oTarget, int bIndicateStatus, int iCallNumber)
{
//  float time = IntToFloat(GetTimeSecond()) + IntToFloat(GetTimeMillisecond()) /1000.0;
//  Jug_Debug(GetName(OBJECT_SELF) + " equip melee vs. " + GetName(oTarget) + " call number " + IntToString(iCallNumber) + " time " + FloatToString(time));

    int nWeaponStatus = GetInitWeaponStatus();
    if (iCallNumber == 1)
    {
        if (!(nWeaponStatus & HENCH_AI_HAS_MELEE_WEAPON))
        {
            if ((nWeaponStatus & HENCH_AI_HAS_MELEE))
            {
                // no weapons, has creature attacks, make sure ranged weapons removed
                UnequipWeapons();
            }
            return TRUE;
        }
        ActionEquipMostDamagingMelee(oTarget);
        return FALSE;
    }

    object oRight = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);
    int iCreatureSize = GetCreatureSize(OBJECT_SELF);
    int iRWeaponSize = GetMeleeWeaponSize(oRight);

    if (iRWeaponSize > iCreatureSize)
    {
        // two handed weapon - done
        return TRUE;
    }
    // for dual weapon selection, must wait until right weapon is equipped
    if (!GetIsObjectValid(oRight))
    {
        if (nWeaponStatus & HENCH_AI_HAS_MELEE)
        {
            return TRUE;
        }
        else
        {
            SetWeaponState(HENCH_AI_HAS_MELEE_WEAPON, FALSE);
            return TRUE;
        }
    }

    int dualWieldState = GetLocalInt(OBJECT_SELF, sHenchDualWieldState);
    if (dualWieldState == 0)
    {
        dualWieldState = GetHasFeat(FEAT_TWO_WEAPON_FIGHTING) ? 1 : 2;
    }

    if (dualWieldState == 2)
    {
        EquipShield(bIndicateStatus);
        return TRUE;
    }
    // already have something in left
    object oOrigLeft = GetItemInSlot(INVENTORY_SLOT_LEFTHAND);
    int iHaveOffHandStatus = GetLocalInt(OBJECT_SELF, HENCH_AI_OFF_HAND_STATUS);
    if (iHaveOffHandStatus == 2)
    {
        EquipShield(bIndicateStatus);
        return TRUE;
    }
    if (iHaveOffHandStatus == 1)
    {
        object oStoredOffHand = GetLocalObject(OBJECT_SELF, HENCH_AI_STORED_OFF_HAND);
        if (oStoredOffHand == oOrigLeft)
        {
            return TRUE;
        }

        if (GetIsObjectValid(oStoredOffHand) && (GetItemPossessor(oStoredOffHand) == OBJECT_SELF) &&
            oRight != oStoredOffHand)
        {
            ActionEquipItem(oStoredOffHand, INVENTORY_SLOT_LEFTHAND);
            return TRUE;
        }
    }

    object oLeft = OBJECT_INVALID;
    int nLeftPrevEquip = GetIsObjectValid(oOrigLeft);
    int nMaxValue = 0;
    int iMaxWeaponSize = iCreatureSize;
    if (GetLocalInt(OBJECT_SELF, sHenchLightOffHand) && (iRWeaponSize >= iCreatureSize))
    {
        iMaxWeaponSize--;
    }
    int iCurWeaponSize;
    if (nLeftPrevEquip)
    {
        iCurWeaponSize = GetMeleeWeaponSize(oOrigLeft);
        if (iCurWeaponSize != 0 && iCurWeaponSize <= iMaxWeaponSize)
        {
            if (GetIdentified(oOrigLeft))
            {
                int bPlotFlag = GetPlotFlag(oOrigLeft);
                if (bPlotFlag)
                {
                    SetPlotFlag(oOrigLeft, FALSE);
                }
                nMaxValue = GetGoldPieceValue(oOrigLeft);
                if (bPlotFlag)
                {
                    SetPlotFlag(oOrigLeft, TRUE);
                }
            }
            else
            {
                nMaxValue = 1;
            }
            oLeft = oOrigLeft;
        }
    }
    // Then look for more than 1 single handed melee weapon
    int iNewOffHand = FALSE;

    object oItem = GetFirstItemInInventory();
    while (GetIsObjectValid(oItem))
    {
        // skip past any items in a container
        if (GetHasInventory(oItem))
        {
            object oContainer = oItem;
            object oSubItem = GetFirstItemInInventory(oContainer);
            oItem = GetNextItemInInventory();
            while (GetIsObjectValid(oSubItem))
            {
                oItem = GetNextItemInInventory();
                oSubItem = GetNextItemInInventory(oContainer);
            }
            continue;
        }
        int nItemType = GetBaseItemType(oItem);
        if (nItemType != BASE_ITEM_LIGHTFLAIL && nItemType != BASE_ITEM_MORNINGSTAR &&
            nItemType != BASE_ITEM_WHIP)
        {
            iCurWeaponSize = GetMeleeWeaponSize(oItem);
            if (iCurWeaponSize != 0 && iCurWeaponSize <= iMaxWeaponSize)
            {
                int tempValue;
                if (GetIdentified(oItem))
                {
                    int bPlotFlag = GetPlotFlag(oItem);
                    if (bPlotFlag)
                    {
                        SetPlotFlag(oItem, FALSE);
                    }
                    tempValue = GetGoldPieceValue(oItem);
                    if (bPlotFlag)
                    {
                        SetPlotFlag(oItem, TRUE);
                    }
                }
                else
                {
                    tempValue = 1;
                }
                if (tempValue > nMaxValue)
                {
                    nMaxValue = tempValue;
                    oLeft = oItem;
                    iNewOffHand = TRUE;
               }
            }
        }
        oItem = GetNextItemInInventory();
    }
    if (nMaxValue > 0)
    {
        SetLocalInt(OBJECT_SELF, HENCH_AI_OFF_HAND_STATUS, 1);
        SetLocalObject(OBJECT_SELF, HENCH_AI_STORED_OFF_HAND, oLeft);
    }
    else
    {
        SetLocalInt(OBJECT_SELF, HENCH_AI_OFF_HAND_STATUS, 2);
        DeleteLocalObject(OBJECT_SELF, HENCH_AI_STORED_OFF_HAND);
    }
    if (iNewOffHand)
    {
        ActionEquipItem(oLeft, INVENTORY_SLOT_LEFTHAND);
    }
    else if (GetIsObjectValid(oOrigLeft) && oOrigLeft == oLeft)
    {
        // nothing to do
    }
    else
    {
        EquipShield(bIndicateStatus);
    }
    return TRUE;
}


int EquipRangedWeapon(object oTarget, int bIndicateStatus, int iCallNumber)
{
//  float time = IntToFloat(GetTimeSecond()) + IntToFloat(GetTimeMillisecond()) /1000.0;
//Jug_Debug(GetName(OBJECT_SELF) + " equip ranged vs. " + GetName(oTarget) + " call number " + IntToString(iCallNumber) + " time " + FloatToString(time));
    if (iCallNumber == 1)
    {
        ActionEquipMostDamagingRanged(oTarget);
        return FALSE;
    }

    object oRight = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);
    if (!GetWeaponRanged(oRight))
    {
        if (iCallNumber == 2)
        {
            ActionWait(0.3);
            return FALSE;
        }
//        object oRealMaster = GetRealMaster();
//        if (GetIsObjectValid(oRealMaster) && GetIsPC(oRealMaster))
//        {
//            SpeakString(sHenchCantUseRanged);
//        }
//      Jug_Debug(GetName(OBJECT_SELF) + " turning off ranged weapons");
        SetWeaponState(HENCH_AI_HAS_RANGED_WEAPON, FALSE);
        SetLocalInt(OBJECT_SELF, "UseRangedWeapons", FALSE);
        return EquipMeleeWeapons(oTarget, bIndicateStatus, 1);
    }

    switch (GetBaseItemType(oRight))
    {
    case BASE_ITEM_DART:
    case BASE_ITEM_SHURIKEN:
    case BASE_ITEM_SLING:
    case BASE_ITEM_THROWINGAXE:
        EquipShield(bIndicateStatus);
        break;
    }
    return TRUE;
}


//::///////////////////////////////////////////////
//:: Equip Appropriate Weapons
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Makes the user get his best weapons.  If the
    user is a Henchmen then he checks the player
    preference.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: April 2, 2002
//:://////////////////////////////////////////////

int HenchEquipAppropriateWeapons(object oTarget, float fThresholdDistance, int bIndicateSwitch, int bPolymorphed)
{
//  Jug_Debug(GetName(OBJECT_SELF) + " trying out equip");

    if (bPolymorphed)
    {
        return TRUE;
    }
    int nWeaponStatus = GetInitWeaponStatus();
    int bUseRanged;

    if (nWeaponStatus & HENCH_AI_HAS_RANGED_WEAPON)
    {
        // has ranged weapons
        object oRealMaster = GetRealMaster();
        if(GetIsObjectValid(oRealMaster) && GetIsPC(oRealMaster) && !GetAssociateState(NW_ASC_USE_RANGED_WEAPON))
        {
            bUseRanged = FALSE;
        }
        else
        {
            if (nWeaponStatus & HENCH_AI_HAS_MELEE)
            {
                // if has melee weapons (includes creature weapons & monk class)
                // if z distance is greater than two then assume cliff
                // TODO add size of creatures for distance?
                bUseRanged = (GetDistanceToObject(oTarget) > fThresholdDistance) ||
                     (fabs(GetPosition(OBJECT_SELF).z - GetPosition(oTarget).z) > 2.0);
            }
            else
            {
                bUseRanged = TRUE;
            }
        }
    }
    else
    {
        bUseRanged = FALSE;
    }
    if (bIndicateSwitch && GetAssociateState(NW_ASC_USE_RANGED_WEAPON))
    {
        if (!(nWeaponStatus & HENCH_AI_HAS_RANGED_WEAPON))
        {
            DeleteLocalInt(OBJECT_SELF, HENCH_AI_SWITCHED_TO_MELEE);
        }
        else
        {
            int bSwitchedToMelee = GetLocalInt(OBJECT_SELF, HENCH_AI_SWITCHED_TO_MELEE);
            if (bUseRanged && bSwitchedToMelee)
            {
                SpeakString(sHenchSwitchToMissle);
                DeleteLocalInt(OBJECT_SELF, HENCH_AI_SWITCHED_TO_MELEE);
            }
            else if (!bUseRanged && !bSwitchedToMelee)
            {
                SpeakString(sHenchSwitchToRanged);
                SetLocalInt(OBJECT_SELF, HENCH_AI_SWITCHED_TO_MELEE, TRUE);
            }
        }
    }
    SetLocalInt(OBJECT_SELF, "UseRangedWeapons", bUseRanged);
    if (bUseRanged)
    {
        object oRight = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND);
        if (!GetWeaponRanged(oRight))
        {
            object oLeft = GetItemInSlot(INVENTORY_SLOT_LEFTHAND);
            if (GetIsObjectValid(oLeft))
            {
                // get rid of weapon or shield
                // shield or weapon in left hand prevents switch to ranged
                ActionUnequipItem(oLeft);
                ActionWait(0.3);
            }
        }
        return EquipRangedWeapon(oTarget, bIndicateSwitch, 1);
    }
    else
    {
        return EquipMeleeWeapons(oTarget, bIndicateSwitch, 1);
    }
}


void ActionContinueEquip(object oTarget, int bIndicateStatus, int iCallNumber)
{
    if (GetLocalInt(OBJECT_SELF, "UseRangedWeapons"))
    {
        if (!EquipRangedWeapon(oTarget, bIndicateStatus, iCallNumber))
        {
            ActionDoCommand(ActionContinueEquip(oTarget, bIndicateStatus, iCallNumber + 1));
        }
    }
    else
    {
        if (!EquipMeleeWeapons(oTarget, bIndicateStatus, iCallNumber))
        {
            ActionDoCommand(ActionContinueEquip(oTarget, bIndicateStatus, iCallNumber + 1));
        }
    }
}


const string sHenchShowWeaponStatus = "HenchShowWeaponStatus";

void HenchEquipDefaultWeapons(object oCreature = OBJECT_SELF, int bShowStatus = FALSE)
{
    if (bShowStatus)
    {
        SetLocalInt(oCreature, sHenchShowWeaponStatus, TRUE);
    }
    ExecuteScript("hench_o0_equip", oCreature);
}


void ClearWeaponStates(object oCreature = OBJECT_SELF)
{
    DeleteLocalInt(oCreature, HENCH_AI_SWITCHED_TO_MELEE);
    DeleteLocalInt(oCreature, HENCH_AI_SHIELD_STATUS);
    DeleteLocalObject(oCreature, HENCH_AI_STORED_SHIELD);
    DeleteLocalInt(oCreature, HENCH_AI_OFF_HAND_STATUS);
    DeleteLocalObject(oCreature, HENCH_AI_STORED_OFF_HAND);
    DeleteLocalInt(oCreature, HENCH_AI_WEAPON);
}


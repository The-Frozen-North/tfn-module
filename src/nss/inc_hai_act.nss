/*

    Henchman Inventory And Battle AI

    This file contains functions used in the default On* scripts
    for henchman actions during noncombat. This includes dealing
    with traps, locks, items, and containers

*/

#include "inc_hai_generic"

// void main() {  }

// Removes master force trap and locks
void ClearForceOptions();

// force associate to open given lock
void OpenLock(object oLock);

// force associate to disarm given trap
void ForceTrap(object oTrap);

// true if free to work with trap, locks, items
int GetIAmNotDoingAnything();

// checks if associate should do any actions with
// traps, locks, or items
int HenchCheckArea(int nClearActions = FALSE);

// finds nears trap or locked item
object HenchGetLockedOrTrappedObject(object oMaster);


// strings for actions
const string sLockMasterFailed = "tk_master_lock_failed";
const string sForceTrap = "tk_force_trap";


void ClearForceOptions()
{
    DeleteLocalObject(OBJECT_SELF, sLockMasterFailed);
    DeleteLocalInt(OBJECT_SELF, sForceTrap);
}


void OpenLock(object oLock)
{
    if (GetIsObjectValid(oLock))
    {
        SetLocalObject(OBJECT_SELF, sLockMasterFailed, oLock);
        ExecuteScript("hench_o0_act", OBJECT_SELF);
    }
}


void ForceTrap(object oTrap)
{
    if (GetIsObjectValid(oTrap))
    {
        SetLocalObject(OBJECT_SELF, sLockMasterFailed, oTrap);
        SetLocalInt(OBJECT_SELF, sForceTrap, TRUE);
        ExecuteScript("hench_o0_act", OBJECT_SELF);
    }
}


int GetIAmNotDoingAnything()
{
    int currentAction = GetCurrentAction(OBJECT_SELF);

    return !IsInConversation(OBJECT_SELF)
        && !GetIsObjectValid(GetAttemptedAttackTarget())
        && !GetIsObjectValid(GetAttemptedSpellTarget())
        && currentAction != ACTION_REST
        && currentAction != ACTION_DISABLETRAP
        && currentAction != ACTION_OPENLOCK
        && currentAction != ACTION_USEOBJECT
        && currentAction != ACTION_RECOVERTRAP
        && currentAction != ACTION_EXAMINETRAP
        && currentAction != ACTION_PICKUPITEM
        && currentAction != ACTION_HEAL
        && currentAction != ACTION_TAUNT;
}


int HenchCheckArea(int nClearActions = FALSE)
{
    //    only execute if we have something to do
    if (!GetAssociateState(NW_ASC_MODE_STAND_GROUND) && !GetLocalInt(OBJECT_SELF, sHenchDontAttackFlag) &&
        GetIAmNotDoingAnything() &&
        ((GetHasSkill(SKILL_DISABLE_TRAP) && !GetLocalInt(OBJECT_SELF, sHenchNoDisarmTraps)) ||
        GetLocalInt(OBJECT_SELF, sHenchAutoOpenLocks) ||
        GetLocalInt(OBJECT_SELF, sHenchAutoPickup) || GetLocalInt(OBJECT_SELF, sHenchAutoOpenChest) ||
        GetIsObjectValid(GetLocalObject(OBJECT_SELF, sLockMasterFailed))))
    {
        if (!GetLocalInt(OBJECT_SELF, "tk_doing_action"))
        {
            ExecuteScript("hench_o0_act", OBJECT_SELF);
            return GetLocalInt(OBJECT_SELF, "tk_action_result");
        }
        else
        {
            ActionDoCommand(ExecuteScript("hench_o0_act", OBJECT_SELF));
            return TRUE;
        }
    }
    else
    {
        ClearForceOptions();
    }
    return FALSE;
}


//::///////////////////////////////////////////////
//:: Get Locked or Trapped Object
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Finds the closest locked or trapped object to the object
    passed in up to a maximum of 10 objects.
*/
//:://////////////////////////////////////////////
//:: Created By: Pausanias
//:: Created On: ??????
//:://////////////////////////////////////////////

object HenchGetLockedOrTrappedObject(object oMaster)
{
    int nCnt = 1;
    int bValid = TRUE;
    object oRealMaster = GetRealMaster();
    object oLastObject = GetNearestObjectToLocation(OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE  | OBJECT_TYPE_TRIGGER, GetLocation(oMaster), nCnt);
    while (GetIsObjectValid(oLastObject) && bValid)
    {
        //COMMENT THIS BACK IN WHEN DOOR ACTION WORKS ON PLACABLE.

        //object oItem = GetFirstItemInInventory(oLastObject);
        if(GetLocked(oLastObject) ||
           (GetIsTrapped(oLastObject) &&
            (GetTrapDetectedBy(oLastObject,OBJECT_SELF) ||
             GetTrapDetectedBy(oLastObject,oRealMaster))))
        {
            return oLastObject;
        }
        nCnt++;
        if(nCnt == 10)
        {
            bValid = FALSE;
        }
        oLastObject = GetNearestObjectToLocation(OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE | OBJECT_TYPE_TRIGGER, GetLocation(oMaster), nCnt);
    }
    return OBJECT_INVALID;
}




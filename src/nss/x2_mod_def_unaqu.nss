//::///////////////////////////////////////////////
//:: Example XP2 OnItemUnAcquireScript
//:: x2_mod_def_unaqu
//:: (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Put into: OnItemUnAcquire Event

*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: 2003-07-16
//:://////////////////////////////////////////////

#include "x2_inc_switches"

void main()
{
     object oPC = GetModuleItemLostBy();
     object oItem = GetModuleItemLost();
     object oOwner = GetItemPossessor(oItem);

     //1.71: fix for automatic unarmed attack when stack of throwing weapons gets destroyed
     if(!GetIsObjectValid(oItem) && oItem != OBJECT_INVALID && GetAttackTarget(oPC) != OBJECT_INVALID && GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,oPC) == OBJECT_INVALID)
     {
         AssignCommand(oPC,ClearAllActions());
     }
     //1.72: support for OC henchman inventory across levelling
     if(GetAssociateType(oPC) == ASSOCIATE_TYPE_HENCHMAN && !GetLocalInt(oItem,"70_ACQUIRED_FROM_MASTER") && oOwner == GetMaster(oPC))
     {
         SetLocalInt(oItem,"70_MY_ORIGINAL_POSSESSION",TRUE);
     }

     //1.70 Patch by Mavrixio, solution for overfilled stores causing huge lags
     if (GetLocalInt(OBJECT_SELF,"70_OVERFILLED_STORES_ISSUE_FIX") && GetIsPC(oPC) && GetObjectType(oOwner) == OBJECT_TYPE_STORE)
     {
         object oStore = oOwner;
         int nLastItemIndex = GetLocalInt(oStore, "MOD_CLEAN_STORE_LAST");
         SetLocalObject(oStore, "MOD_CLEAN_STORE_ITEM"+IntToString(nLastItemIndex), oItem);
         nLastItemIndex++;
         SetLocalInt(oStore, "MOD_CLEAN_STORE_LAST", nLastItemIndex);
         if (nLastItemIndex > GetLocalInt(OBJECT_SELF,"70_OVERFILLED_STORES_ISSUE_FIX"))
         {
             int nFirstItemIndex = GetLocalInt(oStore, "MOD_CLEAN_STORE_FIRST");
             object oItem = GetLocalObject(oStore, "MOD_CLEAN_STORE_ITEM"+IntToString(nFirstItemIndex));
             if (GetItemPossessor(oItem) == oStore)
             {
                 DestroyObject(oItem);
             }
             DeleteLocalObject(oStore, "MOD_CLEAN_STORE_ITEM"+IntToString(nFirstItemIndex));
             nFirstItemIndex++;
             SetLocalInt(oStore, "MOD_CLEAN_STORE_FIRST", nFirstItemIndex);
         }
     }

     // * Generic Item Script Execution Code
     // * If MODULE_SWITCH_EXECUTE_TAGBASED_SCRIPTS is set to TRUE on the module,
     // * it will execute a script that has the same name as the item's tag
     // * inside this script you can manage scripts for all events by checking against
     // * GetUserDefinedItemEventNumber(). See x2_it_example.nss
     if (GetModuleSwitchValue(MODULE_SWITCH_ENABLE_TAGBASED_SCRIPTS) == TRUE)
     {
        SetUserDefinedItemEventNumber(X2_ITEM_EVENT_UNACQUIRE);
        int nRet = ExecuteScriptAndReturnInt(GetUserDefinedItemEventScriptName(oItem),OBJECT_SELF);
        if (nRet == X2_EXECUTE_SCRIPT_END)
        {
           return;
        }
     }
}

//::///////////////////////////////////////////////
//:: Default community patch OnUnAcquire module event script
//:: 70_mod_def_unaqu
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
//:: Created By: Shadooow for Community Patch 1.72
//:: Created On: 31-05-2017
//:://////////////////////////////////////////////
#include "inc_debug"
#include "nwnx_feedback"

void main()
{
    object oPC = GetModuleItemLostBy();
    object oItem = GetModuleItemLost();
    object oOwner = GetItemPossessor(oItem);
    int nStackSize = GetItemStackSize(oItem);

    if (GetIsDM(oPC) && !GetIsDeveloper(oPC))
    {
        SendMessageToPC(oPC, "You cannot drop or transfer items as a DM unless you are a developer.");
        DestroyObject(oItem);
        return;
    }

    NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_LOST, FALSE, oPC);


    //1.71: fix for automatic unarmed attack when stack of throwing weapons gets destroyed
    if(!GetIsObjectValid(oItem) && oItem != OBJECT_INVALID && GetAttackTarget(oPC) != OBJECT_INVALID && GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,oPC) == OBJECT_INVALID)
    {
        AssignCommand(oPC,ClearAllActions());
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
}


//::///////////////////////////////////////////////
//:: Default community patch OnAcquire module event script
//:: 70_mod_def_aqu
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

#include "x0_i0_spells"
#include "70_inc_itemprop"
#include "inc_key"
#include "inc_treasure"
#include "inc_quest"
#include "nwnx_feedback"
#include "inc_party"

void GiveCreatureSkillXP(object oTarget, object oPC, string sSkill)
{
    if (GetIsDead(oTarget)) return;
    if (GetIsPC(oTarget)) return;

    string sIdentifier = "skill_xp_"+GetName(oPC) + GetPCPublicCDKey(oPC);

    // this cannot be awarded again until reset
    if (GetLocalInt(oTarget, sIdentifier) == 1) return;


    SetLocalInt(oTarget, sIdentifier, 1);
    DelayCommand(1800.0, DeleteLocalInt(oTarget, sIdentifier)); // reset in 30 minutes

    // we use party data to award XP. That means to maximize XP value, you must be solo or far away enough from people.
    // Does that seem odd? Yes. But this is the way to make sure that the correct XP is accounted for if they kill the creature with a party
    // (players can get more potential XP if they use a skill in a party versus killing them without any successful skill uses)
    // another way to think about it, pickpocketing NPCs or using animal empathy with a party is less risky because you have a party to back you up in case shit hits the fan and they aggro

    int bAmbush = FALSE;
    if (GetLocalInt(oTarget, "ambush") == 1)
    {
        bAmbush = TRUE;
    }

    int bBoss = GetLocalInt(oTarget, "boss");
    int bSemiBoss = GetLocalInt(oTarget, "semiboss");
    int bRare = GetLocalInt(oTarget, "rare");
    float fMultiplier = 1.0;
    if (bBoss == 1)
    {
        fMultiplier = 3.0;
    }
    else if (bSemiBoss == 1 || bRare == 1)
    {
        fMultiplier = 2.0;
    }

    float fXP = GetPartyXPValue(oTarget, bAmbush, Party.AverageLevel, Party.TotalSize, fMultiplier) * SKILL_XP_PERCENTAGE;

    GiveXPToPC(oPC, fXP, FALSE, sSkill);
}

void main()
{
    object oPC = GetModuleItemAcquiredBy();
    object oItem = GetModuleItemAcquired();
    object oOwner = GetModuleItemAcquiredFrom();
    int nStackSize =GetModuleItemAcquiredStackSize();

    // this shouldnt run for non-PCs
    if (!GetIsPC(oPC))
    {
        return;
    }

    // do not do anything on creature items
    int nBaseItemType = GetBaseItemType(oItem);
    if (nBaseItemType == BASE_ITEM_CPIERCWEAPON || nBaseItemType == BASE_ITEM_CREATUREITEM || nBaseItemType == BASE_ITEM_CSLASHWEAPON || nBaseItemType == BASE_ITEM_CSLSHPRCWEAP || nBaseItemType == BASE_ITEM_CBLUDGWEAPON)
    {
        return;
    }

    int bIsKey = 0;
    if (GetBaseItemType(oItem) == BASE_ITEM_KEY)
    {
        if (!GetLocalInt(oItem, "nokeybag"))
        {
            bIsKey = 1;
        }
    }
    else if (GetLocalInt(oItem, "is_key"))
    {
        bIsKey = 1;
    }
    if (bIsKey)
    {
        AddKeyToPlayer(oPC, oItem);
    }

    // TODO: Count gold for XP
    if (!GetIsPC(oOwner) && GetIsObjectValid(oOwner) && GetObjectType(oOwner) == OBJECT_TYPE_CREATURE && !GetIsDead(oOwner) && GetLocalInt(oItem, "pickpocket_xp") == 1)
    {
        IncrementPlayerStatistic(oPC, "pickpockets_succeeded");

        if (GetLocalInt(oOwner, "pickpocket_xp") == 1)
        {
            GiveCreatureSkillXP(oOwner, oPC, "Pickpocketing");
        }

        // we no longer track pickpockets that fail, not sure if that is possible
    }

    DeleteLocalInt(oItem, "pickpocket_xp");

    // cleaner solution is to do it on nwnx before action events, unfortunately it doesnt fire when taking items from containers, only NWNX_ON_INVENTORY_REMOVE_ITEM_BEFORE does
    // which doesn't have an object for the item remover
    if (GetTag(oItem) == "quest")
    {
        AdvanceQuest(oItem, oPC, 1);
        DestroyObject(oItem);
        NWNX_Feedback_SetFeedbackMessageHidden(NWNX_FEEDBACK_ITEM_LOST, TRUE, oPC);
        return;
    }

    // Item containers should retroactively be given unique power self only for renaming
    if (nBaseItemType == BASE_ITEM_LARGEBOX)
    {
        itemproperty ipTest = GetFirstItemProperty(oItem);
        int nFound = 0;
        while (GetIsItemPropertyValid(ipTest))
        {
            if (GetItemPropertyType(ipTest) == ITEM_PROPERTY_CAST_SPELL)
            {
                nFound = 1;
                break;
            }
            ipTest = GetNextItemProperty(oItem);
        }
        if (!nFound)
        {
            IPSafeAddItemProperty(oItem, ItemPropertyCastSpell(IP_CONST_CASTSPELL_UNIQUE_POWER_SELF_ONLY, IP_CONST_CASTSPELL_NUMUSES_UNLIMITED_USE));
        }
    }
    // if it has an item property, these ammo / throwing weapons are infinite
    else if (IsAmmoInfinite(oItem))
    { // https://github.com/nwnxee/unified/pull/178
        // Clippy: Logic is simple: If items have different local variables, they will not stack. If you want to prevent stacking on a certain item, you can use:
        if (GetLocalString(oItem, "prevent_stack") == "")
            SetLocalString(oItem, "prevent_stack", GetRandomUUID());
        // That will guarantee it has a unique variable and it won't be merged because other item objects will have different object IDs.
    }

    ExecuteScript("remove_invis", oPC);

    DeleteLocalInt(oItem, "destroy_count");
    DeleteLocalInt(oItem, "non_unique"); // not needed at this point
    InitializeItem(oItem);

    //1.71: craft dupe fix
    if(GetLocalInt(oItem,"DUPLICATED_ITEM") == TRUE)
    {
       DestroyObject(oItem);
       return;
    }
     //1.72: support for OC henchman inventory across levelling
    if(GetAssociateType(oPC) == ASSOCIATE_TYPE_HENCHMAN && !GetLocalInt(oItem,"70_MY_ORIGINAL_POSSESSION") && oOwner == GetMaster(oPC))
    {
        SetLocalInt(oItem,"70_ACQUIRED_FROM_MASTER",TRUE);
    }

    //Now execute original script
    string sScript = GetLocalString(OBJECT_SELF,"EVENT_SCRIPT_MODULE_ON_ACQUIRE_ITEM");
    if(sScript != "")
    {
        ExecuteScript(sScript,OBJECT_SELF);
    }
}

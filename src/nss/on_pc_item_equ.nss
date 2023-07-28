//::///////////////////////////////////////////////
//:: Default community patch OnPlayerEquip module event script
//:: 70_mod_def_equ
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

//#include "nwnx_feedback"
#include "x0_i0_spells"
#include "70_inc_itemprop"
#include "inc_horse"
#include "inc_treasure"

void main()
{
    object oItem = GetPCItemLastEquipped();
    object oPC   = GetPCItemLastEquippedBy();

    // Boomerang weapons should suppress "you are running out of ammo" messages
    /* we will suppress this feedback permanently
    object oRightHand = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oPC);
    if (GetItemHasItemProperty(oRightHand, ITEM_PROPERTY_BOOMERANG))
    {
        // NWNX_FEEDBACK_COMBAT_RUNNING_OUT_OF_AMMO = 24
        NWNX_Feedback_SetFeedbackMessageHidden(24, 1, oPC);
    }
    else
    {
        NWNX_Feedback_SetFeedbackMessageHidden(24, 0, oPC);
    }
    */

    DetermineHorseEffects(oPC);

    //1.72: OnPolymorph scripted event handler
    if(!GetLocalInt(oPC,"Polymorphed") && GetHasEffect(EFFECT_TYPE_POLYMORPH,oPC))
    {
        SetLocalInt(oPC,"Polymorphed",1);
        SetLocalInt(oPC,"UnPolymorph",0);
        ExecuteScript("70_mod_polymorph",oPC);
    }
    //1.71: wounding item property handling
    if(GetItemHasItemProperty(oItem,ITEM_PROPERTY_WOUNDING))
    {
        itemproperty ip = GetFirstItemProperty(oItem);
        while(GetIsItemPropertyValid(ip))
        {
            if(GetItemPropertyType(ip) == ITEM_PROPERTY_WOUNDING)
            {
                ApplyWounding(oItem,oPC,GetItemPropertyCostTableValue(ip));
            }
            ip = GetNextItemProperty(oItem);
        }
    }

    /*
    string sItemTag = GetTag(oItem);
    // * When wearing Nasher's set of items, get special (Brent)
    // * benefits
    if (sItemTag == "x2_nash_boot" || sItemTag == "x2_nash_cloak" || sItemTag == "x2_nash_glove" || sItemTag == "x2_nash_ring")
    {
        // * Do I have them all on?
        object oBoot =  GetItemInSlot(INVENTORY_SLOT_BOOTS, oPC);
        object oCloak = GetItemInSlot(INVENTORY_SLOT_CLOAK, oPC);
        object oGlove = GetItemInSlot(INVENTORY_SLOT_ARMS, oPC);
        object oRing1 = GetItemInSlot(INVENTORY_SLOT_RIGHTRING, oPC);
        object oRing2 = GetItemInSlot(INVENTORY_SLOT_LEFTRING, oPC);

        string sRing1 = GetTag(oRing1);
        string sRing2 = GetTag(oRing2);
        if (GetTag(oBoot) == "x2_nash_boot" && GetTag(oCloak) == "x2_nash_cloak" && GetTag(oGlove) == "x2_nash_glove"
            && (sRing1 == "x2_nash_ring" || sRing2 == "x2_nash_ring"))
        {
            SetLocalInt(oPC,"NASHER_SET_FULL",TRUE);
            itemproperty itProp = ItemPropertyAbilityBonus(IP_CONST_ABILITY_DEX, 7);
            IPSafeAddItemProperty(oBoot, itProp , 0.0f, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);

            itProp = ItemPropertyACBonus(7);
            IPSafeAddItemProperty(oCloak, itProp , 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);

            itProp = ItemPropertySkillBonus(SKILL_DISCIPLINE, 10);
            IPSafeAddItemProperty(oGlove, itProp , 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);


            itProp = ItemPropertyAbilityBonus(IP_CONST_ABILITY_STR, 7);
            if (sRing1 == "x2_nash_ring")
            {
                IPSafeAddItemProperty(oRing1, itProp , 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
            }
            if (sRing2 == "x2_nash_ring")
            {
                IPSafeAddItemProperty(oRing2, itProp , 0.0, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
            }
            ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_GOOD_HELP), oPC);
        }
    }
    */
}


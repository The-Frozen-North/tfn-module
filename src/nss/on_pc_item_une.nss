//::///////////////////////////////////////////////
//:: Default community patch OnPlayerUnEquip module event script
//:: 70_mod_def_unequ
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
#include "inc_horse"
#include "nwnx_events"
#include "nwnx_effect"
#include "inc_debug"

void RemoveMagicVestmentEffect(object oPC, string sTag)
{
    effect eEffect = GetFirstEffect(oPC);

    while (GetIsEffectValid(eEffect))
    {
        if (GetEffectTag(eEffect) == sTag)
        {
            RemoveEffect(oPC, eEffect);
            FloatingTextStringOnCreature("*Magic Vestment was removed*", oPC);
            break;
        }

        eEffect = GetNextEffect(oPC);
    }
}

void main()
{
    object oItem = GetPCItemLastUnequipped();
    object oPC   = GetPCItemLastUnequippedBy();

    DetermineHorseEffects(oPC);

    //1.71: fix for losing skin in ELC/ILR module settings
    if(GetIsPC(oPC) && GetTag(oItem) == "x3_it_pchide" && GetLocalObject(oPC,"oX3_Skin") == OBJECT_INVALID)
    {
        object oSkin = CopyItem(oItem,oPC,TRUE);
        SetLocalObject(oPC,"oX3_Skin",oSkin);
        DelayCommand(1.0,AssignCommand(GetItemPossessor(oSkin),CPP_SupportEquipSkin(oSkin)));
        SetDroppableFlag(oSkin,FALSE);
    }
    //1.72: OnPolymorph scripted event handler
    else if(!GetLocalInt(oPC,"UnPolymorph") && GetHasEffect(EFFECT_TYPE_POLYMORPH,oPC))
    {
        SetLocalInt(oPC,"UnPolymorph",1);
        SetLocalInt(oPC,"UnPolymorph_HP_Setup",TRUE);
        SetLocalInt(oPC,"UnPolymorph_HP",GetCurrentHitPoints(oPC));
        DelayCommand(0.0,ExecuteScript("70_mod_polymorph",oPC));
    }

    int nItemType = GetBaseItemType(oItem);

    if (nItemType == BASE_ITEM_LARGESHIELD || nItemType == BASE_ITEM_SMALLSHIELD || nItemType == BASE_ITEM_TOWERSHIELD)
    {
        RemoveMagicVestmentEffect(oPC, "magic_vestment_shield");
    }
    else if (nItemType == BASE_ITEM_ARMOR)
    {
        RemoveMagicVestmentEffect(oPC, "magic_vestment_armor");
    }

    // If the item created some self buffs on the user, remove them.
    int nIndex = 1;
    int bRemovedNotify = 0;
    while (1)
    {
        string sVar = "SelfCastEffectID" + IntToString(nIndex);
        int nEffectID = GetLocalInt(oItem, sVar);
        if (!nEffectID)
        {
            break;
        }
        string sEffectID = IntToString(nEffectID);
        effect eTest = GetFirstEffect(oPC);
        SendDebugMessage("Target effect ID: " + sEffectID);
        while (GetIsEffectValid(eTest))
        {
            struct NWNX_EffectUnpacked eUnpacked = NWNX_Effect_UnpackEffect(eTest);
            SendDebugMessage("This effect ID: " + eUnpacked.sID);
            if (sEffectID == eUnpacked.sID)
            {
                SendDebugMessage("IDs matched, removed");
                RemoveEffect(oPC, eTest);
                if (!bRemovedNotify)
                {
                    bRemovedNotify = 1;
                    ApplyEffectToObject(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_IMP_DISPEL), oPC);
                    FloatingTextStringOnCreature("As you unequip the " + GetName(oItem) + ", some effects it created were dispelled.", oPC, FALSE);
                }
                break;
            }
            eTest = GetNextEffect(oPC);
        }
        DeleteLocalInt(oItem, sVar);
        nIndex++;

    }

}


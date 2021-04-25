//::///////////////////////////////////////////////
//:: Community Patch OnPolymorph module event script
//:: 70_mod_polymorph
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
This script uses unique concept to determine OnPolymorph and OnUnPolymorph events.
Its used for re-merging items after repolymorph (which happens whenever polymorphed
character gets saved).
*/
//:://////////////////////////////////////////////
//:: Created By: Shadooow for Community Patch 1.71
//:: Created On: 14-10-2013
//:://////////////////////////////////////////////

#include "70_inc_shifter"
#include "x3_inc_skin"

void main()
{
    object oPC = OBJECT_SELF;
    object oCreator = GetLocalObject(oPC,"Polymorph_Creator");
    int nEvent = GetLastPolymorphEventType();
    if(POLYMORPH_DEBUG) SendMessageToPC(oPC,"OnPolymorph event: "+IntToString(nEvent));

    if(nEvent == POLYMORPH_EVENTTYPE_POLYMORPH_PREPOLYMORPH)//in this event type OBJECT_SELF is the creator!
    {
        oCreator = OBJECT_SELF;
        oPC = GetLocalObject(oCreator,"Polymorph_Target");
        if(POLYMORPH_DEBUG) SendMessageToPC(oPC,"OnPolymorph event: "+IntToString(nEvent));//debug again as the last one was sent to oCreator instead
        int nPolymorph = GetLocalInt(oPC,"Polymorph_ID")-1;
        int nHP = GetLocalInt(oPC,"Polymorph_HP");
        int bLocked = GetLocalInt(oPC,"Polymorph_Locked");
        int spell1 = GetLocalInt(oPC,"Polymorph_SPELL1");
        int spell2 = GetLocalInt(oPC,"Polymorph_SPELL2");
        int spell3 = GetLocalInt(oPC,"Polymorph_SPELL3");
        int bAll = GetModuleSwitchValue("72_POLYMORPH_MERGE_EVERYTHING");

// We will merge all items.
        int bItems = bAll; // || GetLocalInt(oPC,"Polymorph_MergeI");l
        int bArmor = bAll; //|| GetLocalInt(oPC,"Polymorph_MergeA");
        int bWeapon = bAll; //|| GetLocalInt(oPC,"Polymorph_MergeW");
        int bArms = bAll; //|| (bItems && (GetLocalInt(oPC,"71_POLYMORPH_MERGE_ARMS") || GetModuleSwitchValue("71_POLYMORPH_MERGE_ARMS")));

        //this allows to dynamically override polymorph ID, temp HP and whether player can cancel it or now
        SetLocalInt(oPC,"Polymorph_ID",nPolymorph+1);
        SetLocalInt(oPC,"Polymorph_Locked",bLocked);
        SetLocalInt(oPC,"Polymorph_HP",nHP);

        object oWeaponOld = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,oPC);
        object oArmorOld = GetItemInSlot(INVENTORY_SLOT_CHEST,oPC);
        object oRing1Old = GetItemInSlot(INVENTORY_SLOT_LEFTRING,oPC);
        object oRing2Old = GetItemInSlot(INVENTORY_SLOT_RIGHTRING,oPC);
        object oAmuletOld = GetItemInSlot(INVENTORY_SLOT_NECK,oPC);
        object oCloakOld  = GetItemInSlot(INVENTORY_SLOT_CLOAK,oPC);
        object oBootsOld  = GetItemInSlot(INVENTORY_SLOT_BOOTS,oPC);
        object oBeltOld = GetItemInSlot(INVENTORY_SLOT_BELT,oPC);
        object oArmsOld = GetItemInSlot(INVENTORY_SLOT_ARMS,oPC);
        object oHelmetOld = GetItemInSlot(INVENTORY_SLOT_HEAD,oPC);
        object oShield = GetItemInSlot(INVENTORY_SLOT_LEFTHAND,oPC);
        if(GetIsObjectValid(oShield))
        {   //1.71: this is now custom content compatible, polymorph will merge custom left-hand only items such as flags
            if (GetWeaponRanged(oShield) || IPGetIsMeleeWeapon(oShield))
            {
                oShield = OBJECT_INVALID;
            }
        }
        //stores current items into variable to access later when polymorphed
        SetLocalObject(oPC,"Polymorph_WeaponOld",oWeaponOld);
        SetLocalObject(oPC,"Polymorph_ArmorOld",oArmorOld);
        SetLocalObject(oPC,"Polymorph_Ring1Old",oRing1Old);
        SetLocalObject(oPC,"Polymorph_Ring2Old",oRing2Old);
        SetLocalObject(oPC,"Polymorph_AmuletOld",oAmuletOld);
        SetLocalObject(oPC,"Polymorph_CloakOld",oCloakOld);
        SetLocalObject(oPC,"Polymorph_BoootsOld",oBootsOld);
        SetLocalObject(oPC,"Polymorph_BeltOld",oBeltOld);
        SetLocalObject(oPC,"Polymorph_ArmsOld",oArmsOld);
        SetLocalObject(oPC,"Polymorph_HelmetOld",oHelmetOld);
        SetLocalObject(oPC,"Polymorph_ShieldOld",oShield);
        //1.72: engine markers for correct handling spell slots from items in NWNX_Patch
        SetLocalInt(oWeaponOld,"MERGED",bWeapon);
        SetLocalInt(oHelmetOld,"MERGED",bArmor);
        SetLocalInt(oArmorOld,"MERGED",bArmor);
        SetLocalInt(oShield,"MERGED",bArmor);
        SetLocalInt(oRing1Old,"MERGED",bItems);
        SetLocalInt(oRing2Old,"MERGED",bItems);
        SetLocalInt(oAmuletOld,"MERGED",bItems);
        SetLocalInt(oCloakOld,"MERGED",bItems);
        SetLocalInt(oBootsOld,"MERGED",bItems);
        SetLocalInt(oBeltOld,"MERGED",bItems);
        SetLocalInt(oArmsOld,"MERGED",bArms);

        //calculate appropriate ability bonuses from items
        struct abilities abil;
        if(bArmor)
        {
            abil = IPGetAbilityBonuses(abil,oArmorOld);
            abil = IPGetAbilityBonuses(abil,oHelmetOld);
            abil = IPGetAbilityBonuses(abil,oShield);
        }
        if(bItems)
        {
            abil = IPGetAbilityBonuses(abil,oRing1Old);
            abil = IPGetAbilityBonuses(abil,oRing2Old);
            abil = IPGetAbilityBonuses(abil,oAmuletOld);
            abil = IPGetAbilityBonuses(abil,oCloakOld);
            abil = IPGetAbilityBonuses(abil,oBeltOld);
            abil = IPGetAbilityBonuses(abil,oBootsOld);
        }
        if(bArms)
        {
            abil = IPGetAbilityBonuses(abil,oArmsOld);
        }
        if(bWeapon)
        {
            abil = IPGetAbilityBonuses(abil,oWeaponOld);
        }
        effect eNull, eAbil, eAdditional;
        if(nPolymorph == 76)
        {
            //added benefits of being incorporeal into polymorph effect for spectre shape
            eAdditional = EffectLinkEffects(EffectCutsceneGhost(),EffectConcealment(50));
        }

        //extra ability bonus in order to ensure players won't lose spellslots in polymorph
        if(GetModuleSwitchValue("72_POLYMORPH_MERGE_CASTING_ABILITY"))
        {
            struct abilities abil2;
            if(!bArmor)
            {
                abil2 = IPGetAbilityBonuses(abil,oArmorOld);
                abil2 = IPGetAbilityBonuses(abil,oHelmetOld);
                abil2 = IPGetAbilityBonuses(abil,oShield);
            }
            if(!bItems)
            {
                abil2 = IPGetAbilityBonuses(abil,oRing1Old);
                abil2 = IPGetAbilityBonuses(abil,oRing2Old);
                abil2 = IPGetAbilityBonuses(abil,oAmuletOld);
                abil2 = IPGetAbilityBonuses(abil,oCloakOld);
                abil2 = IPGetAbilityBonuses(abil,oBeltOld);
                abil2 = IPGetAbilityBonuses(abil,oBootsOld);
            }
            if(!bArms)
            {
                abil2 = IPGetAbilityBonuses(abil,oArmsOld);
            }
            if(!bWeapon)
            {
                abil2 = IPGetAbilityBonuses(abil,oWeaponOld);
            }
            if(GetLevelByClass(CLASS_TYPE_WIZARD,oPC))
            {
                abil.Int+= abil2.Int;
            }
            if(GetLevelByClass(CLASS_TYPE_SORCERER,oPC) || GetLevelByClass(CLASS_TYPE_BARD,oPC))
            {
                abil.Cha+= abil2.Cha;
            }
            if(GetLevelByClass(CLASS_TYPE_CLERIC,oPC) || GetLevelByClass(CLASS_TYPE_DRUID,oPC) || GetLevelByClass(CLASS_TYPE_PALADIN,oPC) > 3 || GetLevelByClass(CLASS_TYPE_RANGER,oPC) > 3)
            {
                if(abil2.Wis > 0)
                {
                    int nMod = abil.Wis/2;
                    nMod = (abil.Wis+abil2.Wis)/2 - nMod;
                    if(nMod > 0 && GetHasFeat(FEAT_MONK_AC_BONUS,oPC))//make sure the extra given wis wont raise AC
                    {
                        eAdditional = EffectLinkEffects(eAdditional, EffectACDecrease(nMod,AC_NATURAL_BONUS));
                    }
                }
                abil.Wis+= abil2.Wis;
            }
        }

        if(abil.Str > 0)
            eAbil = EffectAbilityIncrease(ABILITY_STRENGTH,abil.Str > 12 ? 12 : abil.Str);
        if(abil.Dex > 0)
            eAbil = EffectLinkEffects(eAbil,EffectAbilityIncrease(ABILITY_DEXTERITY,abil.Dex > 12 ? 12 : abil.Dex));
        if(abil.Con > 0)
            eAbil = EffectLinkEffects(eAbil,EffectAbilityIncrease(ABILITY_CONSTITUTION,abil.Con > 12 ? 12 : abil.Con));
        if(abil.Wis > 0)
            eAbil = EffectLinkEffects(eAbil,EffectAbilityIncrease(ABILITY_WISDOM,abil.Wis > 12 ? 12 : abil.Wis));
        if(abil.Int > 0)
            eAbil = EffectLinkEffects(eAbil,EffectAbilityIncrease(ABILITY_INTELLIGENCE,abil.Int > 12 ? 12 : abil.Int));
        if(abil.Cha > 0)
            eAbil = EffectLinkEffects(eAbil,EffectAbilityIncrease(ABILITY_CHARISMA,abil.Cha > 12 ? 12 : abil.Cha));

        if(eAdditional != eNull)
        {
            //Apply any additional effects coming along with given shape - keep this visible in effect list
            eAdditional = ExtraordinaryEffect(eAdditional);
            //note all additional effects are permanent since new "engine" will handle them automatically after polymorph ends
            ApplyEffectToObject(DURATION_TYPE_PERMANENT,eAdditional,oPC);
        }
        if(eAbil != eNull)
        {
            //Apply (stacked) ability bonuses from all merged items before polymorph to ensure no spell slots are lost
            eAbil = SupernaturalEffect(eAbil);
            effect eNew = EffectLinkEffects(eNew,eAbil);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT,eNew,oPC);
            ApplyEffectToObject(DURATION_TYPE_PERMANENT,eAbil,oPC);
            RemoveEffect(oPC,eNew);//hack to hide effect icons
        }
    }
    else if(nEvent == POLYMORPH_EVENTTYPE_POLYMORPH_UNPOLYMORPH)
    {
        SetLocalInt(oPC,"Polymorphed",0);//system variable do not remove
        //clean all additional effects, if any
        int nSpellId = GetLocalInt(oPC,"Polymorph_SpellID");
        DeleteLocalInt(oPC,"Polymorph_SpellID");
        effect eSearch = GetFirstEffect(oPC);
        while(GetIsEffectValid(eSearch))
        {
            if((oCreator != OBJECT_INVALID && GetEffectCreator(eSearch) == oCreator) || (nSpellId > 0 && GetEffectSpellId(eSearch) == nSpellId))
            {
                RemoveEffect(oPC,eSearch);
            }
            eSearch = GetNextEffect(oPC);
        }
        DestroyObject(oCreator);
        //1.72: workaround for skin issue with polymorph and relog
        object oSkin = GetLocalObject(oPC,"oX3_Skin");
        if(GetIsObjectValid(oSkin) && GetItemInSlot(INVENTORY_SLOT_CARMOUR,oPC) == OBJECT_INVALID)
        {
            AssignCommand(oPC,SKIN_SupportEquipSkin(oSkin));
        }
    }
    else if(nEvent == POLYMORPH_EVENTTYPE_POLYMORPH_ONPOLYMORPH || nEvent == POLYMORPH_EVENTTYPE_POLYMORPH_REPOLYMORPH)
    {
        SetLocalInt(oPC,"UnPolymorph",0);//system variable do not remove
        object oWeaponNew, oArmorNew = GetItemInSlot(INVENTORY_SLOT_CARMOUR,oPC);
        if(nEvent == POLYMORPH_EVENTTYPE_POLYMORPH_REPOLYMORPH && GetItemCharges(oArmorNew) > 0)//case of repolymorph from ExportSingleCharacter on servervault character
        {
            if(GetLocalInt(oPC,"UnPolymorph_HP_Setup"))//in this situation however, engine refills hitpoints if shape has higher constitution than character
            {
                int preHP = GetLocalInt(oPC,"UnPolymorph_HP");
                int currHP = GetCurrentHitPoints(oPC);
                if(preHP < currHP)
                {
                    if(POLYMORPH_DEBUG) SendMessageToPC(oPC,"OnPolymorph: hitpoints correction.");
                    ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectDamage(currHP-preHP),oPC);
                }
                SetLocalInt(oPC,"UnPolymorph_HP_Setup",FALSE);
            }
            if(POLYMORPH_DEBUG) SendMessageToPC(oPC,"OnPolymorph: correct repolymorph, no change to skin/weapon, ending now.");
            return;
        }
        //retrieve polymorph spell id
        int nSpellId = GetLocalInt(oPC,"Polymorph_SpellID");
        if(!nSpellId)
        {
            effect eSearch = GetFirstEffect(oPC);
            while(GetIsEffectValid(eSearch))
            {
                if(GetEffectType(eSearch) == EFFECT_TYPE_POLYMORPH)
                {
                    //reset if not valid spell id to provide "addition effect cleaning" functionality for spells without 1.72 polymorph engine
                    SetLocalInt(oPC,"Polymorph_SpellID",GetEffectSpellId(eSearch));
                    break;
                }
                eSearch = GetNextEffect(oPC);
            }
        }
        //determine all current polymorph informations
        int nPolymorph = GetLocalInt(oPC,"Polymorph_ID")-1;
        int nHP = GetLocalInt(oPC,"Polymorph_HP");
        int spell1 = GetLocalInt(oPC,"Polymorph_SPELL1");
        int spell2 = GetLocalInt(oPC,"Polymorph_SPELL2");
        int spell3 = GetLocalInt(oPC,"Polymorph_SPELL3");
        int bAll = GetModuleSwitchValue("72_POLYMORPH_MERGE_EVERYTHING");
        int bItems = bAll; //|| GetLocalInt(oPC,"Polymorph_MergeI");
        int bArmor = bAll; //|| GetLocalInt(oPC,"Polymorph_MergeA");
        int bWeapon = bAll; //|| GetLocalInt(oPC,"Polymorph_MergeW");
        int bArms = bAll; //|| (bItems && (GetLocalInt(oPC,"71_POLYMORPH_MERGE_ARMS") || GetModuleSwitchValue("71_POLYMORPH_MERGE_ARMS")));

        object oWeaponOld = GetLocalObject(oPC,"Polymorph_WeaponOld");
        object oArmorOld = GetLocalObject(oPC,"Polymorph_ArmorOld");
        object oRing1Old = GetLocalObject(oPC,"Polymorph_Ring1Old");
        object oRing2Old = GetLocalObject(oPC,"Polymorph_Ring2Old");
        object oAmuletOld = GetLocalObject(oPC,"Polymorph_AmuletOld");
        object oCloakOld = GetLocalObject(oPC,"Polymorph_CloakOld");
        object oBootsOld = GetLocalObject(oPC,"Polymorph_BoootsOld");
        object oBeltOld = GetLocalObject(oPC,"Polymorph_BeltOld");
        object oArmsOld = GetLocalObject(oPC,"Polymorph_ArmsOld");
        object oHelmetOld = GetLocalObject(oPC,"Polymorph_HelmetOld");
        object oShield = GetLocalObject(oPC,"Polymorph_ShieldOld");
        //now re-merge itemproperties into new shape
        if(bWeapon)
        {
            oWeaponNew = GetItemInSlot(INVENTORY_SLOT_RIGHTHAND,oPC);
            if(!GetIsObjectValid(oWeaponNew))
            {
                //oWeaponNew = oArmorNew;//if weapon is allowed to merge but shape has no weapon, then merge itemproperties to skin instead
                object oCWeaponB = GetItemInSlot(INVENTORY_SLOT_CWEAPON_B,oPC);
                object oCWeaponL = GetItemInSlot(INVENTORY_SLOT_CWEAPON_L,oPC);
                object oCWeaponR = GetItemInSlot(INVENTORY_SLOT_CWEAPON_R,oPC);

                if (GetIsObjectValid(oCWeaponB))
                    IPWildShapeMergeItemProperties(oWeaponOld,oCWeaponB, TRUE);

                if (GetIsObjectValid(oCWeaponL))
                    IPWildShapeMergeItemProperties(oWeaponOld,oCWeaponL, TRUE);

                if (GetIsObjectValid(oCWeaponR))
                    IPWildShapeMergeItemProperties(oWeaponOld,oCWeaponR, TRUE);
            }
            else
            {
                SetIdentified(oWeaponNew, TRUE);//identify weapon
                IPWildShapeMergeItemProperties(oWeaponOld,oWeaponNew, TRUE);
            }
            //IPWildShapeMergeItemProperties(oWeaponOld,oWeaponNew, TRUE);
        }
        if(bArmor)
        {
            IPWildShapeMergeItemProperties(oHelmetOld,oArmorNew);
            IPWildShapeMergeItemProperties(oArmorOld,oArmorNew);
            IPWildShapeMergeItemProperties(oShield,oArmorNew);
        }
        if(bItems)
        {
            IPWildShapeMergeItemProperties(oRing1Old,oArmorNew);
            IPWildShapeMergeItemProperties(oRing2Old,oArmorNew);
            IPWildShapeMergeItemProperties(oAmuletOld,oArmorNew);
            IPWildShapeMergeItemProperties(oCloakOld,oArmorNew);
            IPWildShapeMergeItemProperties(oBootsOld,oArmorNew);
            IPWildShapeMergeItemProperties(oBeltOld,oArmorNew);
        }
        if(bArms)
        {
            IPWildShapeMergeItemProperties(oArmsOld,oArmorNew);
        }
        //recalculate ability increase/decrease itemproperties
        IPWildShapeHandleAbilityBonuses(oArmorNew,oWeaponNew);
        //system workaround to determine whether repolymorph copied itemproperties from old items or not
        SetItemCharges(oArmorNew,1);
    }
}

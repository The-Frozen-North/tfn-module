//::///////////////////////////////////////////////
//:: Deafening Clang
//:: X2_S0_DeafClng
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
  Grants a +1 to attack and +3 bonus sonic damage to
  a weapon. Also the weapon will deafen on hit.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 28, 2002
//:://////////////////////////////////////////////
//:: Updated by Andrew Nobbs May 08, 2003
//:: 2003-07-07: Stacking Spell Pass, Georg Zoeller
//:: 2003-07-17: Complete Rewrite to make use of Item Property System
/*
Patch 1.72
- the duration visual effect is no longer dispellable
Patch 1.71
- VFX added if cast on weapon on ground
- allowed to stack sonic damage on weapon with custom content based damage bonuses of different type
- onhit deafness itemproperty will be correctly extended when recast before expiration
*/

#include "70_inc_spells"
#include "x2_i0_spells"
#include "x2_inc_spellhook"

void  AddDeafeningClangEffectToWeapon(object oMyWeapon, float fDuration)
{
    if(GetModuleSwitchValue("72_DISABLE_WEAPON_BOOST_STACKING"))
    {
        IPRemoveAllItemProperties(oMyWeapon,DURATION_TYPE_TEMPORARY);
    }
    if(!IPGetIsProjectile(oMyWeapon))
    {
        //1.72: don't apply the weapon vfx and attack bonus itemproperty only on amunition
        IPSafeAddItemProperty(oMyWeapon, ItemPropertyAttackBonus(1), fDuration, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, TRUE ,TRUE);
        IPSafeAddItemProperty(oMyWeapon, ItemPropertyVisualEffect(ITEM_VISUAL_SONIC), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);
    }
    // If the spell is cast again, any previous itemproperties matching are removed.
    IPSafeAddItemProperty(oMyWeapon, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_SONIC, IP_CONST_DAMAGEBONUS_3), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, FALSE);
    IPSafeAddItemProperty(oMyWeapon, ItemPropertyOnHitCastSpell(137, 5), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, FALSE);
}

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_ROUNDS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(VFX_IMP_SUPER_HEROISM);
    effect eDur = ExtraordinaryEffect(EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE));
    int nDuration = spell.Level;

    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration * 2; //Duration is +100%
    }

    object oMyWeapon = IPGetTargetedOrEquippedMeleeWeapon();
    object oPossessor = GetItemPossessor(oMyWeapon);

    //1.72: special workaround for a case spell selected ranged weapon as the spell benefits must be applied on ammunition
    if(GetWeaponRanged(oMyWeapon) && !IPGetIsThrownWeapon(oMyWeapon))
    {
        if(oMyWeapon == spell.Target)//direct cast on ranged weapon, in this case let it fail
        {
            FloatingTextStrRefOnCreature(83615, spell.Caster);
            return;
        }
        int nAmmoType = StringToInt(Get2DAString("baseitems","RangedWeapon",GetBaseItemType(oMyWeapon)));
        string sSlots = Get2DAString("baseitems","EquipableSlots",nAmmoType);
        int nSlot = -1;
        if(sSlots == "0x00800")
        {
            nSlot = INVENTORY_SLOT_ARROWS;
        }
        else if(sSlots == "0x01000")
        {
            nSlot = INVENTORY_SLOT_BULLETS;
        }
        else if(sSlots == "0x02000")
        {
            nSlot = INVENTORY_SLOT_BOLTS;
        }
        oMyWeapon = GetItemInSlot(nSlot,oPossessor);
        if(!GetIsObjectValid(oMyWeapon) || GetLocalInt(oMyWeapon,"72_DISABLE_ENCHANTMENT_SPELLS"))
        {
            FloatingTextStrRefOnCreature(83615, spell.Caster);
            return;
        }
    }
    if(GetIsObjectValid(oMyWeapon))
    {
        SignalEvent(oPossessor, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
        AddDeafeningClangEffectToWeapon(oMyWeapon, DurationToSeconds(nDuration));
        if(GetIsObjectValid(oPossessor))
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oPossessor);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, oPossessor, DurationToSeconds(nDuration));
        }
        else
        {
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, spell.Loc);
        }
    }
    else
    {
        FloatingTextStrRefOnCreature(83615, spell.Caster);
    }
}

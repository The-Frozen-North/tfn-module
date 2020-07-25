//::///////////////////////////////////////////////
//:: Magic Weapon
//:: X2_S0_MagcWeap
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
  Grants a +1 enhancement bonus.
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
- VFX added if cast on weapon on ground
- spell will apply attack bonus instead of enhancement if ever targets ranged weapon or gloves
*/

#include "70_inc_spells"
#include "x2_i0_spells"
#include "x2_inc_spellhook"

void AddEnhancementEffectToWeapon(object oMyWeapon, float fDuration)
{
    if(GetModuleSwitchValue("72_DISABLE_WEAPON_BOOST_STACKING"))
    {
        IPRemoveAllItemProperties(oMyWeapon,DURATION_TYPE_TEMPORARY);
    }
    if(IPGetIsProjectile(oMyWeapon))
    {
        //1.72: in the case this spell targets projectiles, raw damage bonus is added instead
        if(GetBaseItemType(oMyWeapon) == BASE_ITEM_BULLET)
        {
            IPSafeAddItemProperty(oMyWeapon, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_BLUDGEONING,IP_CONST_DAMAGEBONUS_1), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
        }
        else
        {
            IPSafeAddItemProperty(oMyWeapon, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_PIERCING,IP_CONST_DAMAGEBONUS_1), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
        }
    }
    else if(GetBaseItemType(oMyWeapon) == BASE_ITEM_GLOVES || (GetWeaponRanged(oMyWeapon) && !IPGetIsThrownWeapon(oMyWeapon)))
    {
        //1.72: in the case this spell targets ranged weapon or gloves, an attack bonus is added instead
        IPSafeAddItemProperty(oMyWeapon, ItemPropertyAttackBonus(1), fDuration, X2_IP_ADDPROP_POLICY_KEEP_EXISTING, TRUE, TRUE);
    }
    else
    {
        //melee or throwing weapon
        IPSafeAddItemProperty(oMyWeapon, ItemPropertyEnhancementBonus(1), fDuration, X2_IP_ADDPROP_POLICY_KEEP_EXISTING ,TRUE, TRUE);
    }
}

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_HOURS;

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

    object oMyWeapon = IPGetTargetedOrEquippedMeleeWeapon();
    object oPossessor = GetItemPossessor(oMyWeapon);

    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration * 2; //Duration is +100%
    }

    if(GetIsObjectValid(oMyWeapon))
    {
        SignalEvent(oPossessor, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
        if(GetIsObjectValid(oPossessor))
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oPossessor);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, oPossessor, DurationToSeconds(nDuration));
        }
        else
        {
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, spell.Loc);
        }
        AddEnhancementEffectToWeapon(oMyWeapon, DurationToSeconds(nDuration));
    }
    else
    {
        FloatingTextStrRefOnCreature(83615, spell.Caster);
    }
}

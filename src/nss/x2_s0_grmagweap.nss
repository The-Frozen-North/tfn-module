//::///////////////////////////////////////////////
//:: Greater Magic Weapon
//:: X2_S0_GrMagWeap
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
  Grants a +1 enhancement bonus per 3 caster levels
  (maximum of +5).
  lasts 1 hour per level
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
#include "70_inc_itemprop"
#include "x2_i0_spells"
#include "x2_inc_spellhook"

void AddGreaterEnhancementEffectToWeapon(object oMyWeapon, float fDuration, int nBonus)
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
            IPSafeAddItemProperty(oMyWeapon, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_BLUDGEONING,IPGetIPConstDamageBonusConstantFromNumber(nBonus)), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
        }
        else
        {
            IPSafeAddItemProperty(oMyWeapon, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_PIERCING,IPGetIPConstDamageBonusConstantFromNumber(nBonus)), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
        }
    }
    else if(GetBaseItemType(oMyWeapon) == BASE_ITEM_GLOVES || (GetWeaponRanged(oMyWeapon) && !IPGetIsThrownWeapon(oMyWeapon)))
    {
        //1.72: in the case this spell targets ranged weapon or gloves, an attack bonus is added instead
        IPSafeAddItemProperty(oMyWeapon, ItemPropertyAttackBonus(nBonus), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);
    }
    else
    {
        //melee or throwing weapon
        IPSafeAddItemProperty(oMyWeapon, ItemPropertyEnhancementBonus(nBonus), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING ,FALSE, TRUE);
    }
}

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_HOURS;
    spell.Limit = 5;

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
    int nCasterLvl = spell.Level / 4;

    //Limit nCasterLvl to 5, so it max out at +5 enhancement to the weapon.
    if(nCasterLvl > spell.Limit)
    {
        nCasterLvl = spell.Limit;
    }

    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration * 2; //Duration is +100%
    }

    object oMyWeapon = IPGetTargetedOrEquippedMeleeWeapon();
    object oPossessor = GetItemPossessor(oMyWeapon);

    if(GetIsObjectValid(oMyWeapon))
    {
        //if the possessor isn't valid, nothing should happen
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
        AddGreaterEnhancementEffectToWeapon(oMyWeapon, DurationToSeconds(nDuration), nCasterLvl);
    }
        else
    {
        FloatingTextStrRefOnCreature(83615, spell.Caster);
    }
}

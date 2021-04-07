//::///////////////////////////////////////////////
//:: Bless Weapon
//:: X2_S0_BlssWeap
//:: Copyright (c) 2003 Bioware Corp.
//:://////////////////////////////////////////////
/*

  If cast on a crossbow bolt, it adds the ability to
  slay rakshasa's on hit

  If cast on a melee weapon, it will add the
      grants a +1 enhancement bonus.
      grants a +2d6 damage divine to undead

  will add a holy vfx when command becomes available

  If cast on a creature it will pick the first
  melee weapon without these effects

*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 28, 2002
//:://////////////////////////////////////////////
//:: Updated by Andrew Nobbs May 09, 2003
//:: 2003-07-07: Stacking Spell Pass, Georg Zoeller
//:: 2003-07-15: Complete Rewrite to make use of Item Property System
/*
Patch 1.72
- if ranged/ammo boosting is allowed, spell will apply also default benefits not just rakshasa onhit when cast on bolts
- the duration visual effect is no longer dispellable
Patch 1.70
- duration was round/level if cast on bolt
- VFX added if cast on weapon on ground
*/

#include "70_inc_spells"
#include "x2_i0_spells"
#include "x2_inc_spellhook"

void AddBlessEffectToWeapon(object oMyWeapon, float fDuration)
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
        IPSafeAddItemProperty(oMyWeapon, ItemPropertyVisualEffect(ITEM_VISUAL_HOLY), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);
    }
    // Replace existing temporary anti undead boni
    IPSafeAddItemProperty(oMyWeapon, ItemPropertyDamageBonusVsRace(IP_CONST_RACIALTYPE_UNDEAD, IP_CONST_DAMAGETYPE_DIVINE, IP_CONST_DAMAGEBONUS_2d6), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
}

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_TURNS;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(VFX_IMP_SUPER_HEROISM);
    effect eDur = ExtraordinaryEffect(EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE));
    object oPossessor;
    int nDuration = 2 * spell.Level;

    if (spell.Meta & METAMAGIC_EXTEND)
    {
       nDuration = nDuration * 2; //Duration is +100%
    }

    // ---------------- TARGETED ON BOLT  -------------------
    if(GetIsObjectValid(spell.Target) && GetBaseItemType(spell.Target) == BASE_ITEM_BOLT)
    {
        oPossessor = GetItemPossessor(spell.Target);
        // special handling for blessing crossbow bolts that can slay rakshasa's
        SignalEvent(oPossessor, EventSpellCastAt(spell.Caster, spell.Id, FALSE));
        IPSafeAddItemProperty(spell.Target, ItemPropertyOnHitCastSpell(123,1), DurationToSeconds(nDuration), X2_IP_ADDPROP_POLICY_KEEP_EXISTING);
        //1.72: if ranged/ammo boosting is allowed, make the spell to apply also default benefits not just rakshasa onhit
        if(GetModuleSwitchValue("72_ALLOW_BOOST_AMMO"))
        {
            AddBlessEffectToWeapon(spell.Target, TurnsToSeconds(nDuration));
        }
        if(GetIsObjectValid(oPossessor))
        {
            ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oPossessor);
            ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, oPossessor, DurationToSeconds(nDuration));
        }
        else
        {
            ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, spell.Loc);
        }
        return;
    }

   object oMyWeapon = IPGetTargetedOrEquippedMeleeWeapon();
   oPossessor = GetItemPossessor(oMyWeapon);
   if(GetIsObjectValid(oMyWeapon))
   {
        SignalEvent(oPossessor, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

        AddBlessEffectToWeapon(oMyWeapon, TurnsToSeconds(nDuration));
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

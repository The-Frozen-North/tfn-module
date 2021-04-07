//::///////////////////////////////////////////////
//:: Darkfire
//:: X2_S0_Darkfire
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
  Gives a melee weapon 1d6 fire damage +1 per two caster
  levels to a maximum of +10.
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Dec 04, 2002
//:://////////////////////////////////////////////
//:: Updated by Andrew Nobbs May 08, 2003
//:: 2003-07-29: Rewritten, Georg Zoeller
/*
Patch 1.72
- the duration visual effect is no longer dispellable
Patch 1.70
- VFX added if cast on weapon on ground
*/

#include "70_inc_spells"
#include "x2_i0_spells"
#include "x2_inc_spellhook"

void AddFlamingEffectToWeapon(object oMyWeapon, float fDuration, int nCasterLevel)
{
    if(GetModuleSwitchValue("72_DISABLE_WEAPON_BOOST_STACKING"))
    {
        IPRemoveAllItemProperties(oMyWeapon,DURATION_TYPE_TEMPORARY);
    }
    //1.72: support for damage type override
    SetLocalInt(oMyWeapon, IntToString(spell.Id)+"_DAMAGE_TYPE", spell.DamageType);
    int nWeaponVFX = ITEM_VISUAL_FIRE;
    switch(spell.DamageType)
    {
    case DAMAGE_TYPE_ACID: nWeaponVFX = ITEM_VISUAL_ACID; break;
    case DAMAGE_TYPE_COLD: nWeaponVFX = ITEM_VISUAL_COLD; break;
    case DAMAGE_TYPE_ELECTRICAL: nWeaponVFX = ITEM_VISUAL_ELECTRICAL; break;
    case DAMAGE_TYPE_NEGATIVE: nWeaponVFX = ITEM_VISUAL_EVIL; break;
    case DAMAGE_TYPE_POSITIVE: case DAMAGE_TYPE_DIVINE: nWeaponVFX = ITEM_VISUAL_HOLY; break;
    case DAMAGE_TYPE_SONIC: case DAMAGE_TYPE_MAGICAL: nWeaponVFX = ITEM_VISUAL_SONIC; break;
    }
    if(IPGetIsMeleeWeapon(oMyWeapon))
    {
        //1.72: apply the weapon vfx itemproperty only on melee weapons
        IPSafeAddItemProperty(oMyWeapon, ItemPropertyVisualEffect(nWeaponVFX), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);
    }
    // If the spell is cast again, any previous itemproperties matching are removed.
    IPSafeAddItemProperty(oMyWeapon, ItemPropertyOnHitCastSpell(127,nCasterLevel), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
}

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DamageType = DAMAGE_TYPE_FIRE;
    spell.DurationType = SPELL_DURATION_TYPE_TURNS;
    spell.Limit = 20;

    if (!X2PreSpellCastCode())
    {
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run this spell
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();
    effect eVis = EffectVisualEffect(VFX_IMP_PULSE_FIRE);
    eVis = EffectLinkEffects(EffectVisualEffect(spell.DmgVfxL),eVis);
    effect eDur = ExtraordinaryEffect(EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE));
    int nDuration = 2 * spell.Level;
    int nCasterLvl = spell.Level;

    //Limit nCasterLvl to 10, so it max out at +10 to the damage.
    //Bugfix: Limiting nCasterLvl to *20* - the damage calculation
    //        divides it by 2.
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
        AddFlamingEffectToWeapon(oMyWeapon, DurationToSeconds(nDuration), nCasterLvl);
    }
    else
    {
        FloatingTextStrRefOnCreature(83615, spell.Caster);
    }
}

//::///////////////////////////////////////////////
//:: Magic Vestment
//:: X2_S0_MagcVest
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
  Grants a +1 AC bonus to armor touched per 3 caster
  levels (maximum of +5).
*/
//:://////////////////////////////////////////////
//:: Created By: Andrew Nobbs
//:: Created On: Nov 28, 2002
//:://////////////////////////////////////////////
//:: Updated by Andrew Nobbs May 09, 2003
//:: 2003-07-29: Rewritten, Georg Zoeller
/*
Patch 1.72
- the duration visual effect is no longer dispellable
Patch 1.70
- never auto-targetted any shield if cast at character (without armor)
- VFX added if cast on weapon on ground
*/

// this spell was revamped to apply an AC bonus effect instead of it being a temporary item property
// shield and armor does NOT stack

#include "70_inc_spells"
#include "x2_i0_spells"
#include "x2_inc_spellhook"
#include "inc_spells"

/*
int HasEffectTag(object oPC, string sTag)
{
    effect eEffect = GetFirstEffect(oPC);

    while (GetIsEffectValid(eEffect))
    {
        if (GetEffectTag(eEffect) == sTag)
        {
            return TRUE;
            break;
        }

        eEffect = GetNextEffect(oPC);
    }

    return FALSE;
}
*/

void ApplyMagicVestmentEffect(object oPossessor, object oCaster, int nSpellId, effect eDur, effect eVis, int nDuration, int nAmount, int nItemType = 0)
{
    SignalEvent(oPossessor, EventSpellCastAt(oCaster, nSpellId, FALSE));
    DelayCommand(1.3, ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oPossessor));

    effect eEffect, eLink;

    if (nItemType == BASE_ITEM_ARMOR)
    {
        eEffect = EffectACIncrease(nAmount, AC_ARMOUR_ENCHANTMENT_BONUS);
        eLink = EffectLinkEffects(eDur, eEffect);
        eLink = TagEffect(eLink, "magic_vestment_armor");
        /*
        if (HasEffectTag(oPossessor, "magic_vestment_shield"))
        {
            FloatingTextStringOnCreature("*Magic Vestment Shield AC Bonus removed, Magic Vestment Armor AC bonus applied*", oCaster, FALSE);
        }
        else
        {
            FloatingTextStringOnCreature("*Magic Vestment Armor AC bonus applied*", oCaster, FALSE);
        }
        */
        FloatingTextStringOnCreature("*Magic Vestment Armor AC bonus applied*", oCaster, FALSE);
    }
    else
    {
        eEffect = EffectACIncrease(nAmount, AC_SHIELD_ENCHANTMENT_BONUS);
        eLink = EffectLinkEffects(eDur, eEffect);
        eLink = TagEffect(eLink, "magic_vestment_shield");
         /*
        if (HasEffectTag(oPossessor, "magic_vestment_armor"))
        {
            FloatingTextStringOnCreature("*Magic Vestment Armor AC Bonus removed, Magic Vestment Shield AC bonus applied*", oCaster, FALSE);
        }
        else
        {
            FloatingTextStringOnCreature("*Magic Vestment Shield AC bonus applied*", oCaster, FALSE);
        }
        */
        FloatingTextStringOnCreature("*Magic Vestment Shield AC bonus applied*", oCaster, FALSE);
    }

    RemoveClericArmorClassSpellEffects(oPossessor);
    ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, oPossessor, DurationToSeconds(nDuration));
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
    effect eVis = EffectVisualEffect(VFX_IMP_GLOBE_USE);
    effect eDur = ExtraordinaryEffect(EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE));

    int nDuration  = spell.Level;
    int nAmount = spell.Level/4;
    if (nAmount < 0)
    {
        nAmount = 1;
    }
    else if (nAmount > spell.Limit)
    {
        nAmount = spell.Limit;
    }

    object oArmor = GetItemInSlot(INVENTORY_SLOT_CHEST, spell.Target);
    object oShield = GetItemInSlot(INVENTORY_SLOT_LEFTHAND, spell.Target);

// if the left hand is not actually a shield, nullify it for further checks/logic
    int nItemType = GetBaseItemType(oShield);
    if (nItemType != BASE_ITEM_LARGESHIELD && nItemType != BASE_ITEM_SMALLSHIELD && nItemType != BASE_ITEM_TOWERSHIELD) oShield = OBJECT_INVALID;

    object oTargetedArmor = spell.Target;
    object oPossessor = GetItemPossessor(oTargetedArmor);

    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration * 2; //Duration is +100%
    }

    if(GetIsObjectValid(oTargetedArmor) && GetObjectType(oTargetedArmor) == OBJECT_TYPE_ITEM)
    {
        int nTargetedItemType = GetBaseItemType(oTargetedArmor);

        if(nTargetedItemType == BASE_ITEM_ARMOR)
        {
            ApplyMagicVestmentEffect(oPossessor, spell.Caster, spell.Id, eDur, eVis, nDuration, nAmount, BASE_ITEM_ARMOR);
        }
        else if (nTargetedItemType == BASE_ITEM_LARGESHIELD || nTargetedItemType == BASE_ITEM_SMALLSHIELD || nTargetedItemType == BASE_ITEM_TOWERSHIELD)
        {
            ApplyMagicVestmentEffect(oPossessor, spell.Caster, spell.Id, eDur, eVis, nDuration, nAmount);
        }
        else
        {
            FloatingTextStringOnCreature("*Magic Vestment can only be cast on an equipped armor or shield*", spell.Caster, FALSE);
        }
    }
    else if (GetIsObjectValid(oArmor))
    {
        oPossessor = GetItemPossessor(oArmor);
        ApplyMagicVestmentEffect(oPossessor, spell.Caster, spell.Id, eDur, eVis, nDuration, nAmount, BASE_ITEM_ARMOR);
    }
    else if (GetIsObjectValid(oShield))
    {
        oPossessor = GetItemPossessor(oShield);
        ApplyMagicVestmentEffect(oPossessor, spell.Caster, spell.Id, eDur, eVis, nDuration, nAmount);
    }
    else
    {
        FloatingTextStringOnCreature("*Magic Vestment can only be cast on an equipped armor or shield*", spell.Caster, FALSE);
    }
}

//::///////////////////////////////////////////////
//:: Light
//:: NW_S0_Light.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Applies a light source to the target for
    1 hour per level

    XP2
    If cast on an item, item will get temporary
    property "light" for the duration of the spell
    Brightness on an item is lower than on the
    continual light version.

*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Aug 15, 2001
//:://////////////////////////////////////////////
//:: VFX Pass By: Preston W, On: June 22, 2001
//:: Added XP2 cast on item code: Georg Z, 2003-06-05
//:://////////////////////////////////////////////

#include "70_inc_spells"
#include "x2_inc_spellhook"

void main()
{
    //1.72: pre-declare some of the spell informations to be able to process them
    spell.DurationType = SPELL_DURATION_TYPE_HOURS;

    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run
    // this spell.
    if (!X2PreSpellCastCode())
    {
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

    int nVFX = VFX_DUR_LIGHT_YELLOW_20;
    int nIpColor = IP_CONST_LIGHTCOLOR_YELLOW;

    switch (spell.Class)
    {
        case CLASS_TYPE_SORCERER:
            nVFX = VFX_DUR_LIGHT_RED_20;
            nIpColor = IP_CONST_LIGHTCOLOR_RED;
        break;
        case CLASS_TYPE_WIZARD:
            nVFX = VFX_DUR_LIGHT_BLUE_20;
            nIpColor = IP_CONST_LIGHTCOLOR_BLUE;
        break;
        case CLASS_TYPE_DRUID:
            nVFX = VFX_DUR_LIGHT_ORANGE_20;
            nIpColor = IP_CONST_LIGHTCOLOR_ORANGE;
        break;
        case CLASS_TYPE_BARD:
            nVFX = VFX_DUR_LIGHT_PURPLE_20;
            nIpColor = IP_CONST_LIGHTCOLOR_PURPLE;
        break;
        case CLASS_TYPE_CLERIC:
            nVFX = VFX_DUR_LIGHT_WHITE_20;
            nIpColor = IP_CONST_LIGHTCOLOR_WHITE;
        break;
    }

    int nDuration = spell.Level;
    //Enter Metamagic conditions
    if (spell.Meta & METAMAGIC_EXTEND)
    {
        nDuration = nDuration *2; //Duration is +100%
    }

    // Handle spell cast on item....
    if (GetObjectType(spell.Target) == OBJECT_TYPE_ITEM && !CIGetIsCraftFeatBaseItem(spell.Target))
    {
        // Do not allow casting on not equippable items
        if (!IPGetIsItemEquipable(spell.Target))
        {
            // Item must be equipable...
            FloatingTextStrRefOnCreature(83326,spell.Caster);
            return;
        }

        itemproperty ip = ItemPropertyLight(IP_CONST_LIGHTBRIGHTNESS_NORMAL, nIpColor);

        if (GetItemHasItemProperty(spell.Target, ITEM_PROPERTY_LIGHT))
        {
            IPRemoveMatchingItemProperties(spell.Target,ITEM_PROPERTY_LIGHT,DURATION_TYPE_TEMPORARY);
        }

        AddItemProperty(DURATION_TYPE_TEMPORARY,ip,spell.Target,DurationToSeconds(nDuration));
    }
    else
    {
        effect eVis = EffectVisualEffect(nVFX);
        effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
        effect eLink = EffectLinkEffects(eVis, eDur);

        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

        //Apply the VFX impact and effects
        ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eLink, spell.Target, DurationToSeconds(nDuration));
    }
}

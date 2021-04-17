//::///////////////////////////////////////////////
//:: Continual Flame
//:: x0_s0_clight.nss
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
 Permanent Light spell

    XP2
    If cast on an item, item will get permanently
    get the property "light".
    Previously existing permanent light properties
    will be removed!

*/
//:://////////////////////////////////////////////
//:: Created By: Brent Knowles
//:: Created On: July 18, 2002
//:://////////////////////////////////////////////
//:: VFX Pass By:
//:: Added XP2 cast on item code: Georg Z, 2003-06-05
//:://////////////////////////////////////////////
/*
Patch 1.72
- stolen modification will not be executed in single player
Patch 1.71
- any item that this spell is cast at is now marked as stolen to disable the cast/sell exploit
- spell can dispell the shadowblend effect
*/

#include "70_inc_spells"
#include "x0_i0_spells"
#include "x2_inc_spellhook"

void main()
{
    // If code within the PreSpellCastHook (i.e. UMD) reports FALSE, do not run
    // this spell.
    if (!X2PreSpellCastCode())
    {
        return;
    }

    //Declare major variables
    spellsDeclareMajorVariables();

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
        itemproperty ip = ItemPropertyLight (IP_CONST_LIGHTBRIGHTNESS_BRIGHT, IP_CONST_LIGHTCOLOR_WHITE);
        IPSafeAddItemProperty(spell.Target, ip, HoursToSeconds(24),X2_IP_ADDPROP_POLICY_REPLACE_EXISTING,TRUE,TRUE);
    }
    else
    {
        if(GetHasSpellEffect(757, spell.Target))
        {
            //Continual light effectively dispells shadowblend effect
            RemoveEffectsFromSpell(spell.Target, 757);
        }
        //Declare major variables
        effect eVis = EffectVisualEffect(VFX_DUR_LIGHT_WHITE_20);
        effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
        effect eLink = SupernaturalEffect(EffectLinkEffects(eVis, eDur));

        //Fire cast spell at event for the specified target
        SignalEvent(spell.Target, EventSpellCastAt(spell.Caster, spell.Id, FALSE));

        //Apply the VFX impact and effects
        ApplyEffectToObject(DURATION_TYPE_PERMANENT, eLink, spell.Target);
   }
}

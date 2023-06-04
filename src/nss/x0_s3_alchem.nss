//::///////////////////////////////////////////////
//:: Alchemists fire
//:: x0_s3_alchem
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Grenade.
    Fires at a target. If hit, the target takes
    direct damage. If missed, all enemies within
    an area of effect take splash damage.

    HOWTO:
    - If target is valid attempt a hit
       - If miss then MISS
       - If hit then direct damage
    - If target is invalid or MISS
       - have area of effect near target
       - everyone in area takes splash damage
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: September 10, 2002
//:://////////////////////////////////////////////
//:: GZ: Can now be used to coat a weapon with fire.
/*
Patch 1.70

- critical hit damage corrected
- VFX added if cast on weapon on ground
*/

#include "70_inc_spells"
#include "x2_i0_spells"
#include "x2_inc_itemprop"

void AddFlamingEffectToWeapon(object oTarget, float fDuration, int nCasterLvl)
{
   // If the spell is cast again, any previous itemproperties matching are removed.
   IPSafeAddItemProperty(oTarget, ItemPropertyDamageBonus(IP_CONST_DAMAGETYPE_FIRE,IP_CONST_DAMAGEBONUS_1d4), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING);
   IPSafeAddItemProperty(oTarget, ItemPropertyVisualEffect(ITEM_VISUAL_FIRE), fDuration, X2_IP_ADDPROP_POLICY_REPLACE_EXISTING, FALSE, TRUE);
}

void main()
{
    effect eVis = EffectVisualEffect(VFX_IMP_PULSE_FIRE);
    effect eDur = EffectVisualEffect(VFX_DUR_CESSATE_POSITIVE);
    object oTarget = GetSpellTargetObject();
    object oPossessor;
    int nTarget = GetObjectType(oTarget);
    int nDuration = 4;
    int nCasterLvl = 1;

    if(nTarget == OBJECT_TYPE_ITEM)
    {
        oPossessor = GetItemPossessor(oTarget);
        int nItem = IPGetIsMeleeWeapon(oTarget);
        if(nItem == TRUE)
        {
            //if the possessor isn't valid, nothing should happen
            SignalEvent(oPossessor, EventSpellCastAt(OBJECT_SELF, GetSpellId(), FALSE));

            if(GetIsObjectValid(oPossessor))
            {
                ApplyEffectToObject(DURATION_TYPE_INSTANT, eVis, oPossessor);
                ApplyEffectToObject(DURATION_TYPE_TEMPORARY, eDur, oPossessor, TurnsToSeconds(nDuration));
            }
            else
            {
                ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, GetLocation(oTarget));
            }
            AddFlamingEffectToWeapon(oTarget, TurnsToSeconds(nDuration), nCasterLvl);
        }
        else
        {
            FloatingTextStrRefOnCreature(100944,OBJECT_SELF);
        }
    }
    else //if(nTarget & (OBJECT_TYPE_CREATURE|OBJECT_TYPE_DOOR|OBJECT_TYPE_PLACEABLE))
    {
        spell.Level = 1;
        DoGrenade(6,1, VFX_IMP_FLAME_M, VFX_FNF_FIREBALL,DAMAGE_TYPE_FIRE,RADIUS_SIZE_HUGE, OBJECT_TYPE_CREATURE | OBJECT_TYPE_DOOR | OBJECT_TYPE_PLACEABLE,RACIAL_TYPE_ALL);
    }
}

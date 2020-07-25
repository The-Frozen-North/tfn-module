//::///////////////////////////////////////////////
//:: Caltrops: heartbeat
//:: x0_s3_calen
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*

    Caltrops on enter

*/
//:://////////////////////////////////////////////
//:: Created By: Bioware
//:://////////////////////////////////////////////
/*
Patch 1.70

- caltrops didn't done any damage last round when the damage counter reached 25
- previous solution could left invisible placeable in area
> serious rewrite, now the default AOE heartbeat is replaced by scripted heartbeat
on placeable which executes a script on AOE (so it will work always reliably)
*/

#include "x0_i0_spells"

void main()
{
    object oCreator = GetAreaOfEffectCreator();
    object oTarget = GetEnteringObject();
    int nDamageDone = GetLocalInt(OBJECT_SELF, "NW_L_TOTAL_DAMAGE");
    if(nDamageDone > 24)
    {
        return;
    }
    if(spellsIsTarget(oTarget, SPELL_TARGET_STANDARDHOSTILE, oCreator) && !spellsIsFlying(oTarget))
    {
        //Fire cast spell at event for the target
        SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_GRENADE_CALTROPS));
        effect eDam = EffectDamage(1, DAMAGE_TYPE_PIERCING);
        float fDelay = GetRandomDelay(1.0, 2.2);
        //Apply damage and visuals
        //DelayCommand(fDelay, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, GetLocation(oTarget)));
        DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));

        //  * storing variable on area of effect object
        SetLocalInt(OBJECT_SELF, "NW_L_TOTAL_DAMAGE", nDamageDone+1);
    }
}

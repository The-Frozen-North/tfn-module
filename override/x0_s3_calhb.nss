//::///////////////////////////////////////////////
//:: Caltrops: heartbeat
//:: x0_s3_calhb
//:: Copyright (c) 2002 Bioware Corp.
//:://////////////////////////////////////////////
/*

    do caltrop effect each round targets are in it

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
    if(GetObjectType(OBJECT_SELF) == OBJECT_TYPE_PLACEABLE)
    {
        object oAOE = GetLocalObject(OBJECT_SELF,"AOE");
        if(GetIsObjectValid(oAOE))
        {
            if(GetLocalInt(oAOE, "NW_L_TOTAL_DAMAGE") > 24)
            {
                DestroyObject(oAOE);
                DestroyObject(OBJECT_SELF);
            }
            else
            {
                ExecuteScript("x0_s3_calhb", oAOE);
                DelayCommand(6.0, ExecuteScript("x0_s3_calhb", OBJECT_SELF));
            }
        }
        else
        {
            DestroyObject(OBJECT_SELF);//aoe vanished, lets destroy placeable
        }
        return;
    }
    //AOE code now
    object oCreator = GetAreaOfEffectCreator();
    effect eDam = EffectDamage(1, DAMAGE_TYPE_PIERCING);
    int nDamageDone = GetLocalInt(OBJECT_SELF, "NW_L_TOTAL_DAMAGE");
    float fDelay;
    //Start cycling through the AOE Object for viable targets including doors and placable objects.
    object oTarget = GetFirstInPersistentObject(OBJECT_SELF);
    while(GetIsObjectValid(oTarget))
    {
        if(nDamageDone > 24)
        {
            return;
        }
        if(spellsIsTarget(oTarget,SPELL_TARGET_STANDARDHOSTILE, oCreator) && !spellsIsFlying(oTarget))
        {
            //Fire cast spell at event for the target
            SignalEvent(oTarget, EventSpellCastAt(OBJECT_SELF, SPELL_GRENADE_CALTROPS));
            fDelay = GetRandomDelay(1.0, 2.2);
            //Apply damage and visuals
            //DelayCommand(fDelay, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, eVis, GetLocation(oTarget)));
            DelayCommand(fDelay, ApplyEffectToObject(DURATION_TYPE_INSTANT, eDam, oTarget));
            nDamageDone++;

            //  * storing variable on area of effect object
            SetLocalInt(OBJECT_SELF, "NW_L_TOTAL_DAMAGE", nDamageDone);
        }
        //Get next target.
        oTarget = GetNextInPersistentObject(OBJECT_SELF);
    }
}

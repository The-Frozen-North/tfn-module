//::///////////////////////////////////////////////
//:: Name x2_def_heartbeat
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    Gelatinous Cube Heartbeat
*/
//:://////////////////////////////////////////////
//:: Created By: Georg Zoeller
//:: Created On: Sept 16/03
//:://////////////////////////////////////////////

#include "x0_i0_spells"
#include "x2_i0_spells"

void main()
{
   ExecuteScript("hb_ghost", OBJECT_SELF);

   object oVictim = FIX_GetFirstObjectInShape(SHAPE_CUBE,4.0,GetLocation(OBJECT_SELF), TRUE, OBJECT_TYPE_CREATURE);

   while (GetIsObjectValid(oVictim))
   {
        if (oVictim != OBJECT_SELF && spellsIsTarget(oVictim,SPELL_TARGET_STANDARDHOSTILE,OBJECT_SELF))
        {
            EngulfAndDamage(oVictim,OBJECT_SELF);
        }
        oVictim = FIX_GetNextObjectInShape(SHAPE_CUBE,4.0,GetLocation(OBJECT_SELF), TRUE, OBJECT_TYPE_CREATURE);
   }
}

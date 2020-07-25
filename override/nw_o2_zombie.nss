//::///////////////////////////////////////////////
//:: NW_O2_ZOMBIE.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
   Turns the placeable into a zombie
   if a player comes near enough.
*/
//:://////////////////////////////////////////////
//:: Created By:   Brent
//:: Created On:   January 17, 2002
//:://////////////////////////////////////////////
/*
Patch 1.71

- total rewrite from efficiency reasons - will use AOE instead of heartbeat
- spawn animation improved
*/

void main()
{
   if(GetObjectType(OBJECT_SELF) == OBJECT_TYPE_PLACEABLE)
   {
       location lLoc = GetLocation(OBJECT_SELF);
       object oNew = CreateObject(OBJECT_TYPE_PLACEABLE,"70_pl_zombie",lLoc,FALSE,GetTag(OBJECT_SELF));
       ApplyEffectAtLocation(DURATION_TYPE_PERMANENT,SupernaturalEffect(EffectAreaOfEffect(AOE_PER_INVIS_SPHERE,"nw_o2_zombie","****","****")),lLoc);
       object oAOE = GetNearestObjectByTag("VFX_PER_INVIS_SPHERE",oNew);
       SetLocalInt(oAOE,"X1_L_IMMUNE_TO_DISPEL",10);
       AssignCommand(oAOE,SetIsDestroyable(FALSE));
       SetLocalObject(oAOE,"PLACEABLE",oNew);
       DestroyObject(OBJECT_SELF);
   }
   else if(!GetLocalInt(OBJECT_SELF,"DO_ONCE"))
   {
       object oCreature = GetEnteringObject();
       if(GetIsPC(oCreature) || GetIsPossessedFamiliar(oCreature))
       {
           effect eMind = EffectVisualEffect(VFX_FNF_SUMMON_UNDEAD);
           string sCreature = "NW_ZOMBWARR01";
           // * 10% chance of a zombie lord instead
           if (Random(100) > 90)
           {
               sCreature = "NW_ZOMBIEBOSS";
           }
           object oMonster = CreateObject(OBJECT_TYPE_CREATURE, sCreature, GetLocation(OBJECT_SELF));
           AssignCommand(oMonster, PlayAnimation(ANIMATION_LOOPING_DEAD_FRONT, 1.0, 2.0));
           ApplyEffectToObject(DURATION_TYPE_INSTANT, eMind, oMonster);
           SetPlotFlag(OBJECT_SELF, FALSE);
           DestroyObject(OBJECT_SELF);
           object oSource = GetLocalObject(OBJECT_SELF,"PLACEABLE");
           DestroyObject(oSource);
           SetLocalInt(OBJECT_SELF,"DO_ONCE",TRUE);
           SetIsDestroyable(TRUE);
           DestroyObject(OBJECT_SELF);
       }
   }
}

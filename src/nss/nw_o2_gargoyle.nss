//::///////////////////////////////////////////////
//:: NW_O2_GARGOYLE.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
   Turns the placeable into a gargoyle
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
- spawned gargoyle orientation corrected
*/

void delay(location lNew)
{

}

void main()
{
   if(GetObjectType(OBJECT_SELF) == OBJECT_TYPE_PLACEABLE)
   {
       location lLoc = GetLocation(OBJECT_SELF);
       object oNew = CreateObject(OBJECT_TYPE_PLACEABLE,"70_stat_garg",lLoc,FALSE,GetTag(OBJECT_SELF));
       ApplyEffectAtLocation(DURATION_TYPE_PERMANENT,SupernaturalEffect(EffectAreaOfEffect(AOE_MOB_HORRIFICAPPEARANCE,"nw_o2_gargoyle")),lLoc);
       object oAOE = GetNearestObjectByTag("VFX_MOB_HORRIFICAPPEARANCE",oNew);
       SetLocalInt(oAOE,"X1_L_IMMUNE_TO_DISPEL",10);
       SetLocalObject(oAOE,"PLACEABLE",oNew);
       DestroyObject(OBJECT_SELF);
   }
   else if(!GetLocalInt(OBJECT_SELF,"DO_ONCE"))
   {
       object oCreature = GetEnteringObject();
       object oSource = GetLocalObject(OBJECT_SELF,"PLACEABLE");
       if(GetIsPC(oCreature) || GetIsPossessedFamiliar(oCreature))
       {
           effect eMind = EffectVisualEffect(VFX_IMP_HOLY_AID);
           location l = GetLocation(OBJECT_SELF);
           location lNew = Location(GetAreaFromLocation(l), GetPositionFromLocation(l), GetFacingFromLocation(l) + 180);
           object oGargoyle = CreateObject(OBJECT_TYPE_CREATURE, "NW_GARGOYLE", lNew);
           ApplyEffectToObject(DURATION_TYPE_INSTANT, eMind, oGargoyle);

           SetPlotFlag(OBJECT_SELF, FALSE);
           DestroyObject(OBJECT_SELF);
           object oSource = GetLocalObject(OBJECT_SELF,"PLACEABLE");
           SetPlotFlag(oSource, FALSE);
           //DestroyObject(oSource, 0.5);
           ApplyEffectToObject(DURATION_TYPE_INSTANT,EffectDamage(GetCurrentHitPoints(oSource)),oSource);
           SetLocalInt(OBJECT_SELF,"DO_ONCE",TRUE);
       }
   }
}

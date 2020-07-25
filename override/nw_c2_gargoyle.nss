//::///////////////////////////////////////////////
//:: NW_C2_GARGOYLE.nss
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
   on gargoyle's heartbeat, if no PC nearby then become a statue
*/
//:://////////////////////////////////////////////
//:: Created By: Brent
//:: Created On: January 17, 2001
//:://////////////////////////////////////////////
//:: Noel made the orientation correct, May 2002
/*
Patch 1.71

- original source code restored (the one added in expansions was wrong entirely)
*/

void main()
{
    object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC,OBJECT_SELF,1,CREATURE_TYPE_IS_ALIVE,TRUE);
    if(!GetIsObjectValid(oPC) || GetDistanceToObject(oPC) > 10.0)
    {
        location l = GetLocation(OBJECT_SELF);
        location lNew = Location(GetAreaFromLocation(l), GetPositionFromLocation(l), GetFacingFromLocation(l) + 180);

        object oStatue = CreateObject(OBJECT_TYPE_PLACEABLE, "70_stat_garg", lNew);
        ApplyEffectAtLocation(DURATION_TYPE_PERMANENT,SupernaturalEffect(EffectAreaOfEffect(AOE_MOB_HORRIFICAPPEARANCE,"nw_o2_gargoyle")),lNew);
        object oAOE = GetNearestObjectByTag("VFX_MOB_HORRIFICAPPEARANCE",oStatue);
        SetLocalInt(oAOE,"X1_L_IMMUNE_TO_DISPEL",10);
        AssignCommand(oAOE,SetIsDestroyable(FALSE));
        SetLocalObject(oAOE,"PLACEABLE",oStatue);
        DestroyObject(OBJECT_SELF, 0.5);
    }
}

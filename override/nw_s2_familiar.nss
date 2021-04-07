//::///////////////////////////////////////////////
//:: Summon Familiar
//:: NW_S2_Familiar
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This spell summons an Arcane casters familiar
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Sept 27, 2001
//:://////////////////////////////////////////////
/*
Patch 1.72

- softcoded,builder is now able to override the summoned creature resref within NWScript
- wizard and sorcerer levels stacks together for determining the animal companion level now
*/

void main()
{
    string sResRef = Get2DAString("hen_familiar","BASERESREF",GetFamiliarCreatureType(OBJECT_SELF));
    int nLevel = GetLevelByClass(CLASS_TYPE_SORCERER)+GetLevelByClass(CLASS_TYPE_WIZARD);
    if(nLevel <= 0) nLevel = 1;
    if(nLevel < 10) sResRef+= "0";
    else if(nLevel > 40) nLevel = 40;
    sResRef+= IntToString(nLevel);
    //NWNX hook to override summoned creature resref
    SetLocalString(OBJECT_SELF, "NWNX!PATCH!SETSUMMONEDRESREF",sResRef);
    //Yep thats it
    SummonFamiliar();
}

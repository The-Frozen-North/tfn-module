//::///////////////////////////////////////////////
//:: Summon Animal Companion
//:: NW_S2_AnimalComp
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This spell summons a Druid's animal companion
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Sept 27, 2001
//:://////////////////////////////////////////////
/*
Patch 1.72

- softcoded,builder is now able to override the summoned creature resref within NWScript
- druid and ranger levels stacks together for determining the animal companion level now
*/

void main()
{
    string sResRef = Get2DAString("hen_companion","BASERESREF",GetAnimalCompanionCreatureType(OBJECT_SELF));
    int nLevel = GetLevelByClass(CLASS_TYPE_DRUID)+GetLevelByClass(CLASS_TYPE_RANGER);
    if(nLevel <= 0) nLevel = 1;
    if(nLevel < 10) sResRef+= "0";
    else if(nLevel > 40) nLevel = 40;
    sResRef+= IntToString(nLevel);
    //NWNX hook to override summoned creature resref
    SetLocalString(OBJECT_SELF, "NWNX!PATCH!SETSUMMONEDRESREF",sResRef);
    //Yep thats it
    SummonAnimalCompanion();
}

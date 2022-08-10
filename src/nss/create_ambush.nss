#include "util_i_csvlists"
#include "inc_ai_combat"

string ChooseSpawnRef(object oArea, int nTarget)
{
    string sTarget = "random"+IntToString(nTarget);

    string sList = GetLocalString(oArea, sTarget+"_list");
    string sListUnique = GetLocalString(oArea, sTarget+"_list_unique");

    int nUniqueChance = GetLocalInt(oArea, sTarget+"_unique_chance");

    if (d100() <= nUniqueChance)
    {
        return GetListItem(sListUnique, Random(CountList(sListUnique)));
    }
    else
    {
        return GetListItem(sList, Random(CountList(sList)));
    }
}

void CreateAmbush(int nTarget, object oArea, object oPC, location lLocation, location lFallbackLocation)
{
    string sSpawnScript = GetLocalString(oArea, "random"+IntToString(nTarget)+"_spawn_script");

    int nCount = GetLocalInt(oArea, "random"+IntToString(nTarget)+"_ambush_size");
    if (nCount < 1) nCount = 2;

    object oModule = GetModule();

    int i;
    for (i = 0; i < nCount; i++)
    {
        object oEnemy = CreateObject(OBJECT_TYPE_CREATURE, ChooseSpawnRef(oArea, nTarget), lLocation);

        SetLocalInt(oEnemy, "ambush", 1);
        SetLocalLocation(oEnemy, "ambush_location", lFallbackLocation);
        SetLocalObject(oEnemy, "ambush_target", oPC);

        if (sSpawnScript != "") ExecuteScript(sSpawnScript, oEnemy);

// PC is alive and not dead? start fighting
        if (GetIsObjectValid(oPC) && !GetIsDead(oPC))
        {
            //DelayCommand(1.0, AssignCommand(oEnemy, ActionAttack(oPC)));
            AssignCommand(oModule, DelayCommand(1.0, AssignCommand(oEnemy, gsCBDetermineCombatRound(oPC))));
        } // otherwise, move to their location
        else
        {
            AssignCommand(oModule, DelayCommand(1.0, AssignCommand(oEnemy, ActionMoveToLocation(lFallbackLocation, TRUE))));
        }

        DestroyObject(oEnemy, 300.0);
    }
}


void main()
{
// stored variables
    object oPC = GetLocalObject(OBJECT_SELF, "pc");
    location lLocation = GetLocalLocation(OBJECT_SELF, "pc_location");
    int nTarget = GetLocalInt(OBJECT_SELF, "target");

    object oArea = GetAreaFromLocation(lLocation);

    CreateAmbush(nTarget, oArea, oPC, GetLocation(OBJECT_SELF), lLocation);

    DestroyObject(OBJECT_SELF);
}

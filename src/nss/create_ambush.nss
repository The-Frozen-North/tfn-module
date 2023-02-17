#include "util_i_csvlists"
#include "inc_ai_combat"
#include "inc_adv_assassin"

int ShouldUseUniqueEncounter(object oArea, int nTarget)
{
    int nUniqueChance = GetLocalInt(oArea, "random"+IntToString(nTarget)+"_unique_chance");

    if (d100() <= nUniqueChance)
    {
        return 1;
    }
    else
    {
        return 0;
    }
}

string ChooseSpawnRef(object oArea, int nTarget, int nUnique)
{
    string sTarget = "random"+IntToString(nTarget);

    string sList = GetLocalString(oArea, sTarget+"_list");
    string sListUnique = GetLocalString(oArea, sTarget+"_list_unique");

    int nUniqueChance = GetLocalInt(oArea, sTarget+"_unique_chance");

    if (nUnique)
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
    int bHasUsedUnique = 0;
    for (i = 0; i < nCount; i++)
    {
        int nUnique = bHasUsedUnique ? 0 : ShouldUseUniqueEncounter(oArea, nTarget);
        if (nUnique) { bHasUsedUnique = 1; }
        string sSpawnRef = ChooseSpawnRef(oArea, nTarget, nUnique);
        object oEnemy = CreateObject(OBJECT_TYPE_CREATURE, sSpawnRef, lLocation);

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

int CreateAdventurerAmbush(location lLocation, object oPC)
{
    int nSenderType = GetAdventurerAssassinSender(oPC);
    if (nSenderType > ADVENTURER_ASSASSIN_SENDER_NONE && GetHitDice(oPC) >= 3)
    {
        object oModule = GetModule();
        int bTwoAssassins = 0;
        int nLeaderHD = GetHitDice(oPC) - 2;
        if (Random(100) < 50 && nLeaderHD > 2)
        {
            nLeaderHD -= 2;
            bTwoAssassins = 1;
        }
        object oLeader = SpawnAdventurer(lLocation, SelectAdventurerPathAssassin(), nLeaderHD);
        DesignateAdventurerAsPartyLeader(oLeader);
        SetAdventurerPartyType(oLeader, ADVENTURER_PARTY_REST_ASSASSIN);
        if (bTwoAssassins)
        {
            object oSideKick = SpawnAdventurer(lLocation, SelectAdventurerPathAssassin(), nLeaderHD);
            AddAdventurerToParty(oSideKick, oLeader);
            ChangeToStandardFaction(oSideKick, STANDARD_FACTION_HOSTILE);
            SetIsTemporaryEnemy(oPC, oSideKick);
            AssignCommand(oSideKick, gsCBDetermineCombatRound(oPC));
            DestroyObject(oSideKick, 300.0);
            SetName(oSideKick, "Unknown Assailant");
            SetAdventurerPartyType(oSideKick, ADVENTURER_PARTY_REST_ASSASSIN);
            AssignCommand(oModule, DelayCommand(1.0, AssignCommand(oSideKick, FastBuff())));
            AssignCommand(oModule, DelayCommand(1.5, AssignCommand(oSideKick, gsCBDetermineCombatRound(oPC))));
        }
        ChangeToStandardFaction(oLeader, STANDARD_FACTION_HOSTILE);
        SetIsTemporaryEnemy(oPC, oLeader);
        AssignCommand(oLeader, gsCBDetermineCombatRound(oPC));
        SetName(oLeader, "Unknown Assailant");
        DestroyObject(oLeader, 300.0);
        SetLocalObject(oLeader, "adventurer_party_target", oPC);
        SetLocalInt(oLeader, "adventurer_party_sender", nSenderType);
        AssignCommand(oModule, DelayCommand(1.0, AssignCommand(oLeader, FastBuff())));
        AssignCommand(oModule, DelayCommand(1.5, AssignCommand(oLeader, gsCBDetermineCombatRound(oPC))));
        return 1;
    }
    return 0;
}


void main()
{
// stored variables
    object oPC = GetLocalObject(OBJECT_SELF, "pc");
    location lLocation = GetLocalLocation(OBJECT_SELF, "pc_location");
    int nTarget = GetLocalInt(OBJECT_SELF, "target");

    object oArea = GetAreaFromLocation(lLocation);
    int bMakeRegularAmbush = 1;
    
    // Tiny chance for adventurer assassins instead
    if (Random(100) < 2)
    // Testing 1%s at full odds is an exercise in insanity
    //if (1)
    {
        bMakeRegularAmbush = !CreateAdventurerAmbush(GetLocation(OBJECT_SELF), oPC);
    }

    if (bMakeRegularAmbush)
    {
        CreateAmbush(nTarget, oArea, oPC, GetLocation(OBJECT_SELF), lLocation);
    }

    DestroyObject(OBJECT_SELF);
}

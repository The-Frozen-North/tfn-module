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

void SpawnSidekick(location lLocation, object oLeader, int nLeaderHD, object oPC)
{
    object oModule = GetModule();
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

int CreateAdventurerAmbush(location lLocation, object oPC)
{
    int nSenderType = GetAdventurerAssassinSender(oPC);
    if (nSenderType > ADVENTURER_ASSASSIN_SENDER_NONE && GetHitDice(oPC) >= 3)
    {
        object oPartyMember = GetFirstFactionMember(oPC);
        int nPCLevels = 0;
        int nNPCLevels = 0;
        
        // For the sake of player enjoyment and being a reasonable difficulty this benefits from scaling
        // to party level a bit
        
        // This makes some sweeping assumptions about how much HD of stuff they have with them, though.
        
        while (GetIsObjectValid(oPartyMember))
        {
            int nHD = GetHitDice(oPartyMember) - 2;
            if (nHD > 0)
            {
                nPCLevels += nHD;
                int nNumFollows = GetFollowerCount(oPartyMember);
                nNPCLevels += (nNumFollows * (nHD/2));
                nNumFollows =  GetHenchmanCount(oPartyMember);
                nNPCLevels += (nNumFollows * nHD);
            }
            oPartyMember = GetNextFactionMember(oPC);
        }
        int nTotalLevels = nPCLevels + nNPCLevels;
        SendDebugMessage("Adventure party ambush: total levels = " + IntToString(nTotalLevels));
        
        // Find what level to spawn our assassins.
        // Consider dropping up to 4 more levels from (PC's HD)
        // We try to match nTotalLevels as closely as possible and go for the one with the least remainder
        
        int i;
        int nBestLevel = GetHitDice(oPC);
        int nBestLevelRemainder = 99999;
        for (i=0; i<5; i++)
        {
            int nThisLevel = GetHitDice(oPC) - i;
            if (nThisLevel < 2) { break; }
            int nThisRemainder = nTotalLevels % nThisLevel;
            // Greatly discourage going over four
            // by adding the excess back to the remainder for this level
            int nNumToSpawn = nTotalLevels / nThisLevel;
            if (nNumToSpawn <= 0)
            {
                continue;
            }
            if (nNumToSpawn > 4)
            {
                nThisRemainder += (nNumToSpawn-4)*nThisLevel;
            }
            // Slightly discourage dropping down levels by adding i
            if ((nThisRemainder + i) < nBestLevelRemainder)
            {
                nBestLevel = nThisLevel;
                nBestLevelRemainder = nThisRemainder;
            }
        }
        
        int nNumToSpawn = nTotalLevels / nBestLevel;
        if (nNumToSpawn > 6) { nNumToSpawn = 6; }
        
        SendDebugMessage("Adventure party ambush: spawn " + IntToString(nNumToSpawn) + " attackers at level " + IntToString(nBestLevel));
        
        object oModule = GetModule();
        int nLeaderHD = nBestLevel;
        
        object oLeader = SpawnAdventurer(lLocation, SelectAdventurerPathAssassin(), nLeaderHD);
        DesignateAdventurerAsPartyLeader(oLeader);
        SetAdventurerPartyType(oLeader, ADVENTURER_PARTY_REST_ASSASSIN);
        if (nNumToSpawn > 1)
        {
            for (i=1; i<nNumToSpawn; i++)
            {
                AssignCommand(oModule, DelayCommand(0.5, SpawnSidekick(lLocation, oLeader, nLeaderHD, oPC)));
            }
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

    // Small chance for adventurer assassins instead
    // Testing this at full odds is an exercise in insanity
    if (Random(100) < 3)
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

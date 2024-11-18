#include "inc_debug"
#include "inc_event"
#include "inc_adventurer"

// Adventurer party event

// Parties come in two flavours: the friendly, and the hostile.
// The friendly ones will just have a little chat, and offer safe resting because they'll fight enemies.
// The hostile ones will try to attack their target instead.
// If there are no valid targets (only PCs that have completed the cure can have assassination notes written for them)
// they'll just be arrogant and annoying, and it might end in a fight that way.


// Adventurer parties have a leader and some number of followers
// Some parties wish to seek out a "specific player" - the "target"
// (really, this is one player picked at random in the first party seen by the adventurer leader)
// They'll ask for this player and try to kill them


void SpawnFollower(object oLeader, int nHD, int nPartyType, int nTargetHD)
{
    if (nHD > 12) { nHD = 12; }
    object oFollower = CreateEventCreature("adventurer");
    AdvanceCreatureAlongAdventurerPath(oFollower, SelectAdventurerPathForPartyType(nPartyType), nHD);
    EquipAdventurer(oFollower);
    AddAdventurerToParty(oFollower, oLeader);
    SetAdventurerPartyType(oFollower, nPartyType);
    SetLocalInt(oFollower, "advparty_target_hd", nTargetHD);
}

// Making this many adventurers is slightly TMI prone
void SpawnFollowerDelayed(object oLeader, int nHD, int nPartyType, int nTargetHD)
{
    // Last I checked, DelayCommands on waypoints didn't work
    // AssignCommand doesn't either.
    object oMe = OBJECT_SELF;
    AssignCommand(GetModule(), DelayCommand(IntToFloat(Random(3)), AssignCommand(oLeader, SpawnFollower(oLeader, nHD, nPartyType, nTargetHD))));
}

void main()
{
    object oArea = GetArea(OBJECT_SELF);
    int nBountyHunterHD = SelectBountyHunterGroupHD(oArea);
    int nAreaSetHD = SelectAdventurerHD(oArea);
    
    int nAdventurerHD;
    
    // Adventurer party type
    int nPartyType = ADVENTURER_PARTY_FRIENDLY_GENERIC;
    if (Random(100) < 30)
    {
        nPartyType = ADVENTURER_PARTY_HOSTILE_ASSASSIN;
        nAdventurerHD = nBountyHunterHD;
    }
    else
    {
        int nDiff = nBountyHunterHD - nAreaSetHD;
        if (nDiff < 0) nDiff = 0;
        nAdventurerHD = nAreaSetHD + Random(nDiff+1);
    }
    
    // Reference: The Ranger random event spits out a 7HD Ranger and 3x 3HD Krenshars
    // This thing spawns in ACR 4 areas where it is surprisingly manageable
    // (at the time of writing it has killed 5 PCs over the history of the server)
    
    // One of:
    // 1 guy at HD + 3
    // 2 guys: one HD+2, one HD+1
    // 3 guys at HD
    // 4 guys at HD-1
    // 5 guys, 2x HD-1, 3x HD-2
    
    // It is way easier to work out the possibilities like this than most other ways
    json jPossibilities = JsonArray();
    if (nAdventurerHD+3 <= 12)
    {
        jPossibilities = JsonArrayInsert(jPossibilities, JsonInt(1));
    }
    if (nAdventurerHD+2 <= 12)
    {
        jPossibilities = JsonArrayInsert(jPossibilities, JsonInt(2));
    }
    if (nAdventurerHD <= 12)
    {
        jPossibilities = JsonArrayInsert(jPossibilities, JsonInt(3));
    }
    if (nAdventurerHD-1 <= 12 && nAdventurerHD-1 >= 3)
    {
        jPossibilities = JsonArrayInsert(jPossibilities, JsonInt(4));
    }
    // If there is every a really really high level area with these, they will all end up capped to level 12
    // so no reason to check the high end of the level range for this one (as we'll need lots to put up a fight anyway)
    if (nAdventurerHD-2 >= 3)
    {
        jPossibilities = JsonArrayInsert(jPossibilities, JsonInt(5));
    }
    jPossibilities = JsonArrayTransform(jPossibilities, JSON_ARRAY_SHUFFLE);
    
    int nRoll = JsonGetInt(JsonArrayGet(jPossibilities, 0));
    int i;
    WriteTimestampedLogEntry("eve_advparty: roll = " + IntToString(nRoll));
    object oLeader;  
    
    if (nRoll == 5)
    {
        oLeader = CreateEventCreature("adventurer");
        AdvanceCreatureAlongAdventurerPath(oLeader, SelectAdventurerPathForPartyType(nPartyType), nAdventurerHD-1);
        EquipAdventurer(oLeader);
        DesignateAdventurerAsPartyLeader(oLeader);
        SpawnFollowerDelayed(oLeader, nAdventurerHD-1, nPartyType, nAdventurerHD);
        for (i=0; i<3; i++)
        {
            SpawnFollowerDelayed(oLeader, nAdventurerHD-2, nPartyType, nAdventurerHD);
        }
    }
    // Below types require increasing HD over 12, which can't be done
    // Do this if that is desired
    else if (nRoll == 4)
    {
        oLeader = CreateEventCreature("adventurer");
        AdvanceCreatureAlongAdventurerPath(oLeader, SelectAdventurerPathForPartyType(nPartyType), nAdventurerHD-1);
        EquipAdventurer(oLeader);
        DesignateAdventurerAsPartyLeader(oLeader);
        for (i=0; i<3; i++)
        {
            SpawnFollowerDelayed(oLeader, nAdventurerHD-1, nPartyType, nAdventurerHD);
        }
    }
    else if (nRoll == 3)
    {
        oLeader = CreateEventCreature("adventurer");
        AdvanceCreatureAlongAdventurerPath(oLeader, SelectAdventurerPathForPartyType(nPartyType), nAdventurerHD);
        EquipAdventurer(oLeader);
        DesignateAdventurerAsPartyLeader(oLeader);
        for (i=0; i<2; i++)
        {
            SpawnFollowerDelayed(oLeader, nAdventurerHD, nPartyType, nAdventurerHD);
        }
    }
    // can't make HD+1 if HD already 12
    else if (nRoll == 2)
    {
        oLeader = CreateEventCreature("adventurer");
        AdvanceCreatureAlongAdventurerPath(oLeader, SelectAdventurerPathForPartyType(nPartyType), nAdventurerHD+2);
        EquipAdventurer(oLeader);
        DesignateAdventurerAsPartyLeader(oLeader);
        SpawnFollowerDelayed(oLeader, nAdventurerHD+1, nPartyType, nAdventurerHD);
    }
    else
    {
        oLeader = CreateEventCreature("adventurer");
        AdvanceCreatureAlongAdventurerPath(oLeader, SelectAdventurerPathForPartyType(nPartyType), nAdventurerHD+3);
        EquipAdventurer(oLeader);
        DesignateAdventurerAsPartyLeader(oLeader);
    }
    SetLocalInt(oLeader, "advparty_target_hd", nAdventurerHD);
    
    // Set party type
    int nPartySize = GetAdventurerPartySize(oLeader);
    if (nPartySize >= 1)
    {
        for (i=1; i<=nPartySize; i++)
        {
            object oAdventurer = GetAdventurerPartyMemberByIndex(oLeader, i);
            SetAdventurerPartyType(oAdventurer, nPartyType);
        }
    }
    
    SendDebugMessage("Spawned event adventurer party type " + IntToString(nPartyType));
}

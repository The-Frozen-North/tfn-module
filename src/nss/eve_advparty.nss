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


void SpawnFollower(object oLeader, int nHD, int nPartyType, object oWP)
{
    if (oWP != OBJECT_SELF)
    {
        AssignCommand(oWP, SpawnFollower(oLeader, nHD, nPartyType, oWP));
        return;
    }
    object oFollower = CreateEventCreature("adventurer");
    AdvanceCreatureAlongAdventurerPath(oFollower, SelectAdventurerPathForPartyType(nPartyType), nHD);
    EquipAdventurer(oFollower);
    AddAdventurerToParty(oFollower, oLeader);
    SetAdventurerPartyType(oFollower, nPartyType);
}

// Making this many adventurers is slightly TMI prone
void SpawnFollowerDelayed(object oLeader, int nHD, int nPartyType)
{
    // Last I checked, DelayCommands on waypoints didn't work
    object oMe = OBJECT_SELF;
    AssignCommand(GetModule(), DelayCommand(IntToFloat(Random(3)), SpawnFollower(oLeader, nHD, nPartyType, oMe)));
}

void main()
{
    object oArea = GetArea(OBJECT_SELF);
    int nAdventurerHD = GetLocalInt(oArea, "adventurer_hd");
    if (nAdventurerHD <= 0)
    {
        nAdventurerHD = GetLocalInt(oArea, "cr");
    }
    if (nAdventurerHD <= 0)
    {
        WriteTimestampedLogEntry("eve_advparty has no HD setting for adventurer in area " + GetResRef(oArea));
        //return;
    }
    if (nAdventurerHD < 3)
    {
        nAdventurerHD = 3;
    }
    
    // Adventurer party type
    int nPartyType = ADVENTURER_PARTY_FRIENDLY_GENERIC;
    if (Random(100) < 30)
    {
        nPartyType = ADVENTURER_PARTY_HOSTILE_ASSASSIN;
    }
    
    // One of:
    // 1 guy at HD + 1
    // 2 guys: one HD, one HD-1
    // 3 guys at HD-2
    // 4 guys at HD-3
    // 5 guys, 2x HD-3, 3x HD-4
    int nRoll = d4();
    int i;
    WriteTimestampedLogEntry("eve_advparty: roll = " + IntToString(nRoll));
    object oLeader;
    // Don't go below 3 hd
    if (nRoll == 1 && nAdventurerHD >= 5)
    {
        oLeader = CreateEventCreature("adventurer");
        AdvanceCreatureAlongAdventurerPath(oLeader, SelectAdventurerPathForPartyType(nPartyType), nAdventurerHD-3);
        EquipAdventurer(oLeader);
        DesignateAdventurerAsPartyLeader(oLeader);
        SpawnFollowerDelayed(oLeader, nAdventurerHD-3, nPartyType);
        for (i=0; i<3; i++)
        {
            SpawnFollowerDelayed(oLeader, nAdventurerHD-4, nPartyType);
        }
    }
    // Below types require increasing HD over 12, which can't be done
    // Do this if that is desired
    else if (nRoll <= 2 && nAdventurerHD >= 4)
    {
        oLeader = CreateEventCreature("adventurer");
        AdvanceCreatureAlongAdventurerPath(oLeader, SelectAdventurerPathForPartyType(nPartyType), nAdventurerHD-3);
        EquipAdventurer(oLeader);
        DesignateAdventurerAsPartyLeader(oLeader);
        for (i=0; i<3; i++)
        {
            SpawnFollowerDelayed(oLeader, nAdventurerHD-3, nPartyType);
        }
    }
    else if (nRoll <= 3 && nAdventurerHD >= 3)
    {
        oLeader = CreateEventCreature("adventurer");
        AdvanceCreatureAlongAdventurerPath(oLeader, SelectAdventurerPathForPartyType(nPartyType), nAdventurerHD-2);
        EquipAdventurer(oLeader);
        DesignateAdventurerAsPartyLeader(oLeader);
        for (i=0; i<2; i++)
        {
            SpawnFollowerDelayed(oLeader, nAdventurerHD-2, nPartyType);
        }
    }
    // can't make HD+1 if HD already 12
    else if (nRoll <= 4 || nAdventurerHD == 12)
    {
        oLeader = CreateEventCreature("adventurer");
        AdvanceCreatureAlongAdventurerPath(oLeader, SelectAdventurerPathForPartyType(nPartyType), nAdventurerHD);
        EquipAdventurer(oLeader);
        DesignateAdventurerAsPartyLeader(oLeader);
        object oFollower = CreateEventCreature("adventurer");
        AdvanceCreatureAlongAdventurerPath(oFollower, SelectAdventurerPathForPartyType(nPartyType), nAdventurerHD-1);
        EquipAdventurer(oFollower);
        AddAdventurerToParty(oFollower, oLeader);
    }
    else
    {
        oLeader = CreateEventCreature("adventurer");
        AdvanceCreatureAlongAdventurerPath(oLeader, SelectAdventurerPathForPartyType(nPartyType), nAdventurerHD+1);
        EquipAdventurer(oLeader);
        DesignateAdventurerAsPartyLeader(oLeader);
    }
    
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

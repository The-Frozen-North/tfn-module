#include "inc_adventurer"
#include "inc_adv_assassin"
#include "inc_ai_combat"
#include "inc_ctoken"

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    SetLocalObject(OBJECT_SELF, "last_speaker", oPC);
    int bOutside = !GetIsAreaInterior(OBJECT_SELF);
    object oLeader = GetAdventurerPartyLeader(OBJECT_SELF);
    string sLeaderName = GetAdventurerTrueName(oLeader);
    string sMessage;
    int nPCPartySize = 0;
    int nAdventurerPartySize = GetAdventurerPartySize(OBJECT_SELF);
    int bTavern = 0;
    object oArea = GetArea(OBJECT_SELF);
    if (!bOutside && GetLocalInt(oArea, "restxp"))
    {
        bTavern = 1;
    }
    object oTest = GetFirstFactionMember(oPC, FALSE);
    while (GetIsObjectValid(oTest))
    {
        if (GetArea(oTest) == GetArea(OBJECT_SELF) && !GetIsDead(oTest) && GetObjectSeen(oTest, OBJECT_SELF))
        {
            nPCPartySize++;
        }
        oTest = GetNextFactionMember(oPC, FALSE);
    }
    int nRoll;
    if (!GetLocalInt(OBJECT_SELF, "talkedto" + ObjectToString(oPC)))
    {
        RevealTrueNameToPlayer(OBJECT_SELF, oPC);
        SetLocalInt(OBJECT_SELF, "talkedto" + ObjectToString(oPC), 1);
        if (bTavern)
        {
            SetCustomToken(CTOKEN_ADVENTURER_DIALOGUE, "Greetings, friend! I'm " + GetAdventurerTrueName(OBJECT_SELF) + ", just stopping to enjoy a few drinks. Care to join " + (nAdventurerPartySize > 1 ? "us" : "me") + "?");
        }
        else
        {
            if (GetLocalInt(oArea, "ambush"))
            {
                SetCustomToken(CTOKEN_ADVENTURER_DIALOGUE, "Greetings, friend! I'm " + GetAdventurerTrueName(OBJECT_SELF) + ", another adventurer. In these troubled times, we need to look out for each other - " + (nAdventurerPartySize > 1 ? "we" : "I") + " can help make sure you can rest safely.");
            }
            else
            {
                SetCustomToken(CTOKEN_ADVENTURER_DIALOGUE, "Greetings, friend! I'm " + GetAdventurerTrueName(OBJECT_SELF) + ", another adventurer. In these troubled times, we need to look out for each other.");
            }
        }            
    }
    else
    {
        nRoll = Random(4);
        if (nRoll == 0)
        {
            SetCustomToken(CTOKEN_ADVENTURER_DIALOGUE, "Doing all right, I hope?");
        }
        else if (nRoll == 1)
        {
            SetCustomToken(CTOKEN_ADVENTURER_DIALOGUE, "I trust all is well?");
        }
        else if (nRoll == 2)
        {
            SetCustomToken(CTOKEN_ADVENTURER_DIALOGUE, "Stay safe, traveller.");
        }
        else if (nRoll == 3)
        {
            SetCustomToken(CTOKEN_ADVENTURER_DIALOGUE, "Look after yourself out there.");
        }
    }
    
    return 1;
}
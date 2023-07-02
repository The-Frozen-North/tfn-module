// Include for some common adventurer assassin functions
#include "inc_quest"
#include "inc_adventurer"

int GetAdventurerAssassinSender(object oPC);

object GetAdventurerPartyTarget(object oAdventurer, object oInteractingPC);

string GetAssassinNoteMessage(int nSender, object oPC, object oAssassin);

object MakeAssassinNote(object oAssassin, object oPC);


const int ADVENTURER_ASSASSIN_SENDER_NONE = 0;
const int ADVENTURER_ASSASSIN_SENDER_HODGE = 1;
const int ADVENTURER_ASSASSIN_SENDER_RUMBOTTOM = 2;
const int ADVENTURER_ASSASSIN_SENDER_ANDROD = 3;
const int ADVENTURER_ASSASSIN_SENDER_DESTHER = 4;
const int ADVENTURER_ASSASSIN_SENDER_MAUGRIM = 5;
const int ADVENTURER_ASSASSIN_SENDER_UNDERDARK = 6;

string GetAssassinNoteMessage(int nSender, object oPC, object oAssassin)
{
    int nPartySize = GetAdventurerPartySize(oAssassin);
    string sTrueName = GetAdventurerTrueName(oAssassin);
    string sPCName = GetName(oPC);
    int nPCRace = GetRacialType(oPC);
    string sPCRace = GetStringByStrRef(StringToInt(Get2DAString("racialtypes", "Name", nPCRace)));
    int nPCGender = GetGender(oPC);
    string sHeShe = nPCGender == GENDER_MALE ? "he" : "she";
    string sHimHer = nPCGender == GENDER_MALE ? "him" : "her";
    string sHisHer = nPCGender == GENDER_MALE ? "his" : "her";
    string sHeSheCap = nPCGender == GENDER_MALE ? "He" : "She";
    string sMes;
    
    if (nSender == ADVENTURER_ASSASSIN_SENDER_NONE)
    {
        return "";
    }
    else if (nSender == ADVENTURER_ASSASSIN_SENDER_HODGE)
    {
        sMes = sTrueName + ",\n\nI've got an opportunity you might find interesting. A pesky " + sPCRace + " named " + sPCName + " broke in and stole something precious to me. I've no doubt that it's now in the hands of a wench who rewarded our thief handsomely. " + sHeSheCap + " didn't look all that experienced, and should be pretty easy to take care of. Rough " + sHimHer + " up or kill " + sHimHer + ", it's up to you, but I might have a little something extra for you once you're done. You know where to find me.\n\n~H";
    }
    else if (nSender == ADVENTURER_ASSASSIN_SENDER_RUMBOTTOM)
    {
        sMes = sTrueName + ",\n\nI've got a lead for you" + (nPartySize > 1 ? " and your friends": "") + ". I gather that a " + sPCRace + " named " + sPCName + " broke in and stole something precious while I was away. I've heard that it's now likely in the hands of Ophala, who no doubt paid " + sHimHer + " well for the job. Go carefully, " + sHeShe + " killed most of my guards in the process. Rough " + sHimHer + " up or kill " + sHimHer + ", it's up to you, but I have a little something extra for you once you're done. Once this plague business is over, you'll know where to find me.\n\n~R";
    }
    else if (nSender == ADVENTURER_ASSASSIN_SENDER_ANDROD)
    {
        sMes = sTrueName + ",\n\nI've got a job for you" + (nPartySize > 1 ? " and your friends": "") + ". Some newly \"famous\" " + sPCRace + " named " + sPCName + " broke in, threatened me, and made off with something important. " + sHeSheCap + " came looking for that specifically, and was probably paid well for it. Go carefully, " + sHeShe + " killed most of my burly guards in the process. Give " + sHimHer + "a good beating, but I don't really care if " +sHeShe + " lives or dies. You know where to go for your bonus.\n\n~A";
    }
    else if (nSender == ADVENTURER_ASSASSIN_SENDER_DESTHER)
    {
        int nCuresFound = 0;
        if (GetQuestEntry(oPC, "q_dryad") >= 6) { nCuresFound++; }
        if (GetQuestEntry(oPC, "q_cockatrice") >= 5) { nCuresFound++; }
        if (GetQuestEntry(oPC, "q_pureblood") >= 3) { nCuresFound++; }
        if (GetQuestEntry(oPC, "q_intellect") >= 3) { nCuresFound++; }
        int nBounty;
        string sThreatText;
        if (nCuresFound == 0)
        {
            nBounty = 5000;
            sThreatText = sHeSheCap + " is something of a nuisance to my plans, and I would appreciate your services in preventing that escalating further. " + sHeSheCap + " may look unprepared, but should not be underestimated.";
        }
        if (nCuresFound == 1)
        {
            nBounty = 7500;
            sThreatText = sHeSheCap + " is becoming a greater threat to my plans, and I would like " + sHimHer + " removed. " + sHeSheCap + " is a formidable foe, and should not be underestimated.";         
        }
        if (nCuresFound == 2)
        {
            nBounty = 8500;
            sThreatText = sHeSheCap + " is a considerable threat to my plans, and I need " + sHimHer + " removed. " + sHeSheCap + " is an adventurer of some experience, and should not be underestimated.";         
        }
        if (nCuresFound == 3)
        {
            nBounty = 10000;
            sThreatText = sHeSheCap + " is a significant threat to my plans, and I need " + sHimHer + " removed urgently. " + sHeSheCap + " is an adventurer of considerable experience, and should not be underestimated.";         
        }
        if (nCuresFound == 4)
        {
            nBounty = 13500;
            sThreatText = sHeSheCap + " is now a threat to my very life, and " + sHeShe + " must be terminated with the utmost urgency. " + sHeSheCap + " likely rivals my own power, and I hope that you " + (nPartySize > 1 ? "and your friends ": "") + " are up to the task.";         
        }
        
        if (nCuresFound < 4)
        {
            sThreatText += " I would also ask that you return any parts of strange creatures in " + sHisHer + " possession to me, and I shall pay handsomely for any you find. Anything else " + sHeShe + " is carrying is yours to keep, however.";
        }
        
        sMes = sTrueName + ",\n\nI have need of your services once more. This time, your assignment is " + sPCName + ", a " + sPCRace + " adventurer. " + sThreatText + " Return to me with proof of the deed and you shall be rewarded with the generous sum of " + IntToString(nBounty) + " gold.\n\n~D";
    }
    else if (nSender == ADVENTURER_ASSASSIN_SENDER_MAUGRIM)
    {
        sMes = sTrueName + ",\n\nI have another task for you: a " + sPCRace + " named " + sPCName + " has proven a great nuisance to me, and I would like " + sHimHer + " dealt with. Your reward for this simple deed will be 20000 gold. " + sPCName + " is an adventurer of great ability, and I happen to know that " + sHeShe + " has faced the depths of the Underdark and returned. Underestimate " + sHimHer + " at your peril.\nDo not fail me.\n\n~M";
    }
    else if (nSender == ADVENTURER_ASSASSIN_SENDER_UNDERDARK)
    {
        int nPlansThwarted = 0;
        if (GetQuestEntry(oPC, "q_golems") >= 50) { nPlansThwarted++; }
        int nBounty = 60000;
        string sThreatText;
        if (nPlansThwarted == 0)
        {
            sThreatText = "While " + sHisHer + " capabilities are not fully known, " + sHeShe + " appears to be a credible threat to my plans. Additionally, " + sHeShe + " has been seen consorting with the rebels of the east, who may be trying to recruit " + sHimHer + " to their cause.";
            nBounty = 20000;
        }
        else if (nPlansThwarted >= 1)
        {
            sThreatText = sHeSheCap + " has proven troublesome to my plans, and appears to be of considerable strength for a surfacer. They are working with the rebels of Lith My'athar and should not be underestimated.";
            nBounty = 40000;
        }
        sMes = "BOUNTY NOTICE\n\nThis is an open offer of " + IntToString(nBounty) + " gold for the head of" + sPCName + ", a " + sPCRace + " surfacer. " + sThreatText;
    }
    return sMes;
}

object MakeAssassinNote(object oAssassin, object oPC)
{
    int nSender = GetLocalInt(oAssassin, "adventurer_party_sender");
    string sText = GetAssassinNoteMessage(nSender, oPC, oAssassin);
    vector vPos = GetPosition(oAssassin);
    vector vRandom;
    vector vFinal;
    location lFinal;
    int bValid = 0;
    int i;
    for (i=0; i<10; i++)
    {
        vRandom = Vector(IntToFloat(Random(1000) - 500)/1000.0, IntToFloat(Random(1000) - 500)/1000.0, 0.0);
        vFinal = vPos + vRandom;
        lFinal = Location(GetArea(oAssassin), vFinal, 0.0);
        int nSurfaceType = GetSurfaceMaterial(lFinal);
        int bWalkable = StringToInt(Get2DAString("surfacemat", "Walk", nSurfaceType));
        if(bWalkable)
        {
            bValid = 1;
            break;
        }
    }
    if (!bValid)
    {
        lFinal = GetLocation(oAssassin);
    }
    object oNote = CreateObject(OBJECT_TYPE_ITEM, "assassinnote", lFinal);
    if (sText != "")
    {
        SetDescription(oNote, "This note was carried by an assassin in " +GetName(GetArea(oAssassin)) + ".\n\n\"" + sText + "\"");
    }
    else
    {
        // In an ideal world this message should never appear
        SetDescription(oNote, "This note was carried by an assassin in " +GetName(GetArea(oAssassin)) + ". It is too bloodstained to make out what it might have once said.");
    }
    return oNote;
}

int GetAdventurerAssassinSender(object oPC)
{
    int nLevel = GetHitDice(oPC);
    
    int nRumbottomChance = 0;
    int nHodgeChance = 0;
    int nAndrodChance = 0;
    int nDestherChance = 0;
    int nMaugrimChance = 0;
    int nUnderdarkChance = 0;
    
    if (GetQuestEntry(oPC, "q_art_theft2") >= 2)
    {
        nRumbottomChance = 100 - ((nLevel - 3) * 33);
    }
    if (GetQuestEntry(oPC, "q_art_theft1") >= 2)
    {
        nAndrodChance = 100 - ((nLevel - 2) * 33);
    }
    if (GetQuestEntry(oPC, "q_art_theft3") >= 2)
    {
        nHodgeChance = 100 - ((nLevel - 3) * 33);
    }
    int nWailingStage = GetQuestEntry(oPC, "q_wailing");
    // Between storming the Temple of Helm and killing Desther
    if (nWailingStage >= 9 && nWailingStage <= 12)
    {
        nDestherChance = 100;
    }
    // After killing Desther
    if (nWailingStage >= 13)
    {
        nMaugrimChance = 100;
    }
    
    if (GetQuestEntry(oPC, "q_underdark") > 0 && FindSubString(GetName(GetArea(oPC)), "Underdark") > 0)
    {
        nUnderdarkChance = 100;
    }
    
    if (nUnderdarkChance > 0)
    {
        return ADVENTURER_ASSASSIN_SENDER_UNDERDARK;
    }
    if (Random(100) < nMaugrimChance)
    {
        return ADVENTURER_ASSASSIN_SENDER_MAUGRIM;
    }
    else if (Random(100) < nDestherChance)
    {
        return ADVENTURER_ASSASSIN_SENDER_DESTHER;
    }
    else if (Random(100) < nRumbottomChance)
    {
        return ADVENTURER_ASSASSIN_SENDER_RUMBOTTOM;
    }
    else if (Random(100) < nHodgeChance)
    {
        return ADVENTURER_ASSASSIN_SENDER_HODGE;
    }
    else if (Random(100) < nAndrodChance)
    {
        return ADVENTURER_ASSASSIN_SENDER_ANDROD;
    }
    
    return ADVENTURER_ASSASSIN_SENDER_NONE;
}

object GetAdventurerPartyTarget(object oAdventurer, object oInteractingPC)
{
    // Do this from the leader's perspective
    object oLeader = GetAdventurerPartyLeader(oAdventurer);
    if (oLeader != oAdventurer)
    {
        return GetAdventurerPartyTarget(oLeader, oInteractingPC);
    }
    object oLast = GetLocalObject(oAdventurer, "adventurer_party_target");
    if (GetIsObjectValid(oLast) && GetArea(oLast) == GetArea(oAdventurer))
    {
        return oLast;
    }
    if (!GetIsObjectValid(oInteractingPC))
    {
        return OBJECT_INVALID;
    }
    int nCount = 0;
    int nSender = ADVENTURER_ASSASSIN_SENDER_NONE;
    object oTest = GetFirstFactionMember(oInteractingPC);
    while (GetIsObjectValid(oTest))
    {
        if (GetArea(oTest) == GetArea(oAdventurer) && !GetIsDead(oTest) && GetAdventurerAssassinSender(oTest) > 0)
        {
            nCount++;
        }
        oTest = GetNextFactionMember(oInteractingPC);
    }
    int nSelection = Random(nCount);
    oTest = GetFirstFactionMember(oInteractingPC);
    while (GetIsObjectValid(oTest))
    {
        if (GetArea(oTest) == GetArea(oAdventurer) && !GetIsDead(oTest))
        {
            nSender = GetAdventurerAssassinSender(oTest);
            if (nSelection == 0 && nSender > 0)
            {
                oLast = oTest;
                break;
            }
            nSelection--;
        }
        oTest = GetNextFactionMember(oInteractingPC);
    }
    // If that didn't land on a PC (possible because of randomness in GetAdventurerAssassinSender)
    // Just take the first PC that it's valid for
    if (!GetIsObjectValid(oLast))
    {
        oTest = GetFirstFactionMember(oInteractingPC);
        while (GetIsObjectValid(oTest))
        {
            if (GetArea(oTest) == GetArea(oAdventurer) && !GetIsDead(oTest))
            {
                nSender = GetAdventurerAssassinSender(oTest);
                if (nSender > 0)
                {
                    oLast = oTest;
                    break;
                }
            }
            oTest = GetNextFactionMember(oInteractingPC);
        }
    }
    
    // If the leader dies, the other party members should inherit this too
    int nPartySize = GetAdventurerPartySize(oAdventurer);
    int i;
    for (i=1; i<=nPartySize; i++)
    {
        object oMember = GetAdventurerPartyMemberByIndex(oAdventurer, i);
        SetLocalObject(oMember, "adventurer_party_target", oLast);
        SetLocalInt(oMember, "adventurer_party_sender", nSender);
    }
    return oLast;    
}
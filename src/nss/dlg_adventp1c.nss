// Adventurer party conditional dialogue script

// Parties come in two flavours: the friendly, and the hostile.
// The friendly ones will just have a little chat, and offer safe resting because they'll fight enemies.
// The hostile ones will try to attack their target instead.
// If there are no valid targets (only PCs with certain quests complete can be targeted)
// they'll just be looking out for a target, and attack anyway if pushed

// Script params:
// isleader    If set, line is only valid if this adventurer is the party leader
// istavern - if 1, line is valid only in a Neverwinter tavern. If 0, line is valid only outside Neverwinter taverns

//////// HAS-TARGET LINES

// pcintimidate - Does the intimidate check
// attack - does what it says, no tokens

/////// TARGETLESS LINES

// hasnotargetgreeting:
// pcoffershelp
// pcsuspicious
// attacknontarget - needs to write a token



// Adventurer parties have a leader and some number of followers
// Some parties wish to seek out a "specific player" - the "target"
// (really, this is one player picked at random in the first party seen by the adventurer leader)
// Most of the time they'll want to kill this player, but maybe not always...


#include "inc_adventurer"
#include "inc_adv_assassin"
#include "inc_ai_combat"
#include "inc_ctoken"
#include "inc_xp"

string GenerateInsult(object oPC)
{
    int nRoll;
    if (GetAbilityScore(oPC, ABILITY_STRENGTH, TRUE) <= 10 && d3() == 3)
    {
        nRoll = Random(2);
        if (nRoll == 0) { return "a scrawny whelp"; }
        else if (nRoll == 1) { return "a puny weakling"; }
    }
    if (GetAbilityScore(oPC, ABILITY_DEXTERITY, TRUE) <= 10 && d3() == 3)
    {
        nRoll = Random(2);
        if (nRoll == 0) { return "a clumsy oaf"; }
        else if (nRoll == 1) { return "an ungraceful swine"; }
    }
    if (GetAbilityScore(oPC, ABILITY_CONSTITUTION, TRUE) <= 10 && d3() == 3)
    {
        nRoll = Random(1);
        if (nRoll == 0) { return "a flimsy sack of bones"; }
    }
    if (GetAbilityScore(oPC, ABILITY_WISDOM, TRUE) <= 10 && d3() == 3)
    {
        nRoll = Random(2);
        if (nRoll == 0) { return "a half-wit"; }
        else if (nRoll == 1) { return "an imbecile"; }
    }
    if (GetAbilityScore(oPC, ABILITY_INTELLIGENCE, TRUE) <= 10 && d3() == 3)
    {
        nRoll = Random(1);
        if (nRoll == 0) { return "a braindead idiot"; }
    }
    if (GetAbilityScore(oPC, ABILITY_CHARISMA, TRUE) <= 10 && d3() == 3)
    {
        nRoll = Random(1);
        if (nRoll == 0) { return "a boring buffoon"; }
    }
    nRoll = Random(2);
    if (nRoll == 0) { return "a nobody"; }
    else if (nRoll == 1) { return "an inept idiot"; }
    return "a nobody";
}

void AttackParty(object oPC)
{
    int i;
    int nPartySize = GetAdventurerPartySize(OBJECT_SELF);
    for (i=1; i<=nPartySize; i++)
    {
        object oAdventurer = GetAdventurerPartyMemberByIndex(OBJECT_SELF, i);
        ChangeToStandardFaction(oAdventurer, STANDARD_FACTION_HOSTILE);
        SetIsTemporaryEnemy(oPC, oAdventurer);
        AssignCommand(oAdventurer, gsCBDetermineCombatRound(oPC));
    }
}

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
    int bNeverwinterTavern = 0;
    object oArea = GetArea(OBJECT_SELF);
    if (FindSubString(GetName(oArea), "Neverwinter - ") >= 0 && GetLocalInt(oArea, "restxp"))
    {
        bNeverwinterTavern = 1;
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
    if (GetScriptParam("isnotleader") != "")
    {
        if (oLeader != OBJECT_SELF)
        {
            return 0;
        }
    }
    if (GetScriptParam("istavern") != "")
    {
        int nScriptParam = StringToInt(GetScriptParam("istavern"));
        if (nScriptParam && !bNeverwinterTavern)
        {
            return 0;
        }
        if (!nScriptParam && bNeverwinterTavern)
        {
            return 0;
        }
    }
    object oPCTarget = GetAdventurerPartyTarget(OBJECT_SELF, oPC);
    if (GetScriptParam("hasnotargetgreeting") != "")
    {
        if (GetIsObjectValid(oPCTarget))
        {
            return 0;
        }
        sMessage = "Excuse me, but " + (nAdventurerPartySize > 1 ? "we're" : "I'm") + " looking for someone in particular. Please, don't distract me.";
        SetCustomToken(CTOKEN_ADVENTURER_DIALOGUE, sMessage);
        return 1;
    }
    if (GetScriptParam("pcoffershelp") != "")
    {
        sMessage = "Sorry, as much as " + (nAdventurerPartySize > 1 ? "we'd" : "I'd") + " love the help, I can't risk word getting out that I'm waiting here.";
        SetCustomToken(CTOKEN_ADVENTURER_DIALOGUE, sMessage);
        return 1;
    }
    if (GetScriptParam("pcsuspicious") != "")
    {
        sMessage = "I've already asked you to leave " + (nAdventurerPartySize > 1 ? "us" : "me") + " alone once. " + (nAdventurerPartySize > 1 ? "We" : "I") + " won't take too kindly to needing to ask again.";
        SetCustomToken(CTOKEN_ADVENTURER_DIALOGUE, sMessage);
        return 1;
    }
    if (GetScriptParam("attacknontarget") != "")
    {
        sMessage = "If you're not going to leave " + (nAdventurerPartySize > 1 ? "us" : "me") + " alone, I'm afraid I have to insist.";
        SetCustomToken(CTOKEN_ADVENTURER_DIALOGUE, sMessage);
        AttackParty(oPC);
        return 1;
    }
    
    
    if (GetScriptParam("pcintimidate") != "")
    {
        int nDC = 18 + GetHitDice(OBJECT_SELF);
        if (GetIsSkillSuccessful(oPC, SKILL_INTIMIDATE, nDC))
        {
            GiveDialogueSkillXP(oPC, nDC, SKILL_INTIMIDATE);
            sMessage = "You know, I think " + (nAdventurerPartySize > 1 ? "we" : "I") + " might have bitten off a bit more than " + (nAdventurerPartySize > 1 ? "we" : "I") + " can chew this time. Farewell... for now.";
            SetCustomToken(CTOKEN_ADVENTURER_DIALOGUE, sMessage);
            int i;
            int nPartySize = GetAdventurerPartySize(OBJECT_SELF);
            for (i=1; i<=nPartySize; i++)
            {
                object oAdventurer = GetAdventurerPartyMemberByIndex(OBJECT_SELF, i);
                AssignCommand(oAdventurer, ActionMoveToObject(GetNearestObject(OBJECT_TYPE_DOOR)));
                DestroyObject(oAdventurer, 10.0);
                SetLocalInt(oAdventurer, "no_attack", 1);
            }
            return 1;
        }
        return 0;
        
    }
    if (GetScriptParam("attack") != "")
    {
        AttackParty(oPC);
        return 1;
    }
    
    return 1;
}
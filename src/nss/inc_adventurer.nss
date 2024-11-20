#include "nwnx_creature"
#include "nwnx_player"
#include "inc_rand_feat"
#include "inc_rand_appear"
#include "inc_rand_equip"
#include "inc_rand_spell"
#include "inc_areadist"
#include "inc_debug"

const int ADVENTURER_PATH_BARBARIAN12 = 1;
const int ADVENTURER_PATH_BARD12 = 2;
const int ADVENTURER_PATH_CLERIC12 = 3;
const int ADVENTURER_PATH_DRUID12 = 4;
const int ADVENTURER_PATH_FIGHTER12 = 5;
const int ADVENTURER_PATH_MONK12 = 6;
const int ADVENTURER_PATH_PALADIN12 = 7;
const int ADVENTURER_PATH_RANGER12 = 8;
const int ADVENTURER_PATH_ROGUE12 = 9;
const int ADVENTURER_PATH_SORCERER12 = 10;
const int ADVENTURER_PATH_WIZARD12 = 11;
const int ADVENTURER_PATH_FIGHTER9ROGUE3 = 12;
const int ADVENTURER_PATH_BARBARIAN9ROGUE3 = 13;
const int ADVENTURER_PATH_PALADIN9ROGUE3 = 14;
const int ADVENTURER_PATH_RANGER9ROGUE3 = 15;
const int ADVENTURER_PATH_MONK8ROGUE3PDK1 = 16;
const int ADVENTURER_PATH_CLERIC11MONK1 = 17;
const int ADVENTURER_PATH_DRUID11MONK1 = 18;
const int ADVENTURER_PATH_RANGER6BLACKGUARD6 = 19;
const int ADVENTURER_PATH_MONK8BLACKGUARD4 = 20;
const int ADVENTURER_PATH_SORCERER2PALADIN5AA5 = 21;
const int ADVENTURER_PATH_WIZARD2FIGHTER5AA5 = 22;
const int ADVENTURER_PATH_BARD4FIGHTER3AA5 = 23;
const int ADVENTURER_PATH_ROGUE5ASSASSIN7 = 24;
const int ADVENTURER_PATH_MONK5ASSASSIN7 = 25;
const int ADVENTURER_PATH_RANGER5ASSASSIN7 = 26;
const int ADVENTURER_PATH_RANGER9ASSASSIN3 = 27;
const int ADVENTURER_PATH_FIGHTER7TORM5 = 28;
const int ADVENTURER_PATH_PALADIN7TORM5 = 29;
const int ADVENTURER_PATH_BARBARIAN7TORM5 = 30;
const int ADVENTURER_PATH_ROGUE4FIGHTER4TORM4 = 31;
const int ADVENTURER_PATH_ROGUE4PALADIN4TORM4 = 32;
const int ADVENTURER_PATH_FIGHTER7DD5 = 33;
const int ADVENTURER_PATH_PALADIN7DD5 = 34;
const int ADVENTURER_PATH_ROGUE4FIGHTER4DD4 = 35;
const int ADVENTURER_PATH_PALADIN8HARPER4 = 36;
const int ADVENTURER_PATH_WIZARD3PM9 = 37;
const int ADVENTURER_PATH_RANGER7PDK5 = 38;
const int ADVENTURER_PATH_FIGHTER4PDK5PALADIN3 = 39;
const int ADVENTURER_PATH_MONK8PDK4 = 40;
const int ADVENTURER_PATH_PALADIN4PDK5TORM3 = 41;
const int ADVENTURER_PATH_BARBARIAN7PDK5 = 42;
const int ADVENTURER_PATH_FIGHTER4PDK5ROGUE3 = 43;
const int ADVENTURER_PATH_BARD7PDK5 = 44;
const int ADVENTURER_PATH_FIGHTER6ROGUE3SHADOWDANCER3 = 45;
const int ADVENTURER_PATH_RANGER8ROGUE3SHADOWDANCER1 = 46;
const int ADVENTURER_PATH_ROGUE5ASSASSIN5SHADOWDANCER2 = 47;
const int ADVENTURER_PATH_MONK5ASSASSIN5SHADOWDANCER2 = 48;
const int ADVENTURER_PATH_FIGHTER7WM5 = 49;
const int ADVENTURER_PATH_FIGHTER6RANGER1WM5 = 50;
const int ADVENTURER_PATH_RANGER11MONK1 = 51;

const int ADVENTURER_PATH_HIGHEST = 51;

// Return a weighted random ADVENTURER_PATH constant
// Ignore this and roll your own if a specific adventurer type is needed for some reason
int SelectAdventurerPath();

// As SelectAdventurerPath except it picks only paths that might become assassins.
int SelectAdventurerPathAssassin();

// Feed a ADVENTURER_PARTY constant to pick a suitable SelectAdventurerPath function for that party.
int SelectAdventurerPathForPartyType(int nPartyType);

// Set oCreature to be a nHD randomised adventurer along the given progression path.
// oCreature should be the standard adventurer UTC for several reasons:
// 1) It has no feats
// 2) It has a special dummy package that does nothing, which means that levelling it doesn't add anything from a functioning default package
// Use SpawnAdventurer with bAdvance=0 and bEquip=0 to create the adventurer
// then use this to specify a path if the normal random weighting isn't desired
void AdvanceCreatureAlongAdventurerPath(object oCreature, int nPath, int nHD);

// Adventurers don't start with any equipment.
// This throws some suggested defaults for inc_rand_equip stuff based on their HD
// Call this AFTER AdvanceCreatureAlongAdventurerPath if at all.
void EquipAdventurer(object oAdventurer);

// Spawn a random adventurer of hit dice nHD and progression path nPath at lSpawn.
// If bAdvance, AdvanceCreatureAlongAdventurerPath will be called for the given path and HD
// If bEquip AND bAdvance, EquipAdventurer will be called.
object SpawnAdventurer(location lSpawn, int nPath, int nHD, int bAdvance=1, int bEquip=1);

// Generate a real name for oAdventurer.
// This is not revealed to a PC, but is tracked for consistency.
void GenerateTrueName(object oAdventurer);

// Reveal oAdventurer's true name to oPC and their party.
void RevealTrueNameToPlayer(object oAdventurer, object oPC);

string GetAdventurerTrueName(object oAdventurer);

// Mark oAdventurer as the leader of their little group.
void DesignateAdventurerAsPartyLeader(object oAdventurer);

// Add oAdventurer to oLeader's little adventuring group.
// DOES NOT ADD THEM TO A PLAYER PARTY. Use the inc_follower stuff for that.
void AddAdventurerToParty(object oAdventurer, object oLeader);

// Adventurer party type constants
const int ADVENTURER_PARTY_HOSTILE_ASSASSIN = 1;
const int ADVENTURER_PARTY_FRIENDLY_GENERIC = 2;
const int ADVENTURER_PARTY_REST_ASSASSIN = 3;

// Return the leader of oAdventurer's adventurer party.
// If they are dead or destroyed, oAdventurer will become the new leader.
object GetAdventurerPartyLeader(object oAdventurer);

// Return the original/highest size that oAdventurer's party has ever been.
// If people have died or been destroyed since then, this is not updated
int GetAdventurerPartySize(object oAdventurer);

// Return oAdventurer's party members by index (starting from 1, not 0)
// oAdventurer itself will occupy one of these positions
object GetAdventurerPartyMemberByIndex(object oAdventurer, int nIndex);

// Sets variables/dialog etc for oAdventurer to be of a given ADVENTURER_PARTY_* constant type.
void SetAdventurerPartyType(object oAdventurer, int nPartyType);

// Work out what HD an adventurer party should generate in oArea.
// This looks at the PCs that are on the server, where they are in relation to oArea, and will copy one of their hit dice.
int SelectAdventurerGroupHD(object oArea);


////////////////////////////////////////

void SetAdventurerMaxArmorAC(object oAdventurer, int nValue)
{
    SetLocalInt(oAdventurer, "armormaxac", nValue+1);
}

int GetAdventurerPathWeight(int nPath)
{
    int nRet = 0;
    switch (nPath)
    {
        // Pure melee classes
        case ADVENTURER_PATH_BARBARIAN12:
        case ADVENTURER_PATH_FIGHTER12:
        case ADVENTURER_PATH_MONK12:
        case ADVENTURER_PATH_PALADIN12:
        case ADVENTURER_PATH_RANGER12:
        case ADVENTURER_PATH_ROGUE12:
        {
            nRet = 60; // = 360 total attacker
            break;
        }
        // Pure casters - due to NWN's lack of CL progressing prestige options these would get quite rare
        case ADVENTURER_PATH_CLERIC12:
        case ADVENTURER_PATH_DRUID12:
        {
            nRet = 110; // = 220 total caster
            break;
        }
        case ADVENTURER_PATH_WIZARD12:
        case ADVENTURER_PATH_SORCERER12:
        {
            nRet = 150; // +300 = 520 total caster
            break;
        }
        // The weird mix base class
        case ADVENTURER_PATH_BARD12:
        {
            nRet = 50; // = 410 total attacker, if you count bard as that
            break;
        }
        case ADVENTURER_PATH_FIGHTER7WM5:
        case ADVENTURER_PATH_FIGHTER6RANGER1WM5:
        {
            nRet = 60; // +120 = 480 total attacker
            break;
        }
        case ADVENTURER_PATH_CLERIC11MONK1:
        case ADVENTURER_PATH_DRUID11MONK1:
        {
            nRet = 40; // +80 = 600 total caster
            break;
        }
        // All the other many multiclass combinations
        default:
        {
            // ADVENTURER_PATH_HIGHEST = 51
            // 4 multiclasses marked above
            // -> 40 possibilities
            // -> +800 to attacker = 1400
            nRet = 20; 
            
            break;
        }
        // 1400 attacker
        // 600 caster
    }
    return nRet;
}

int SelectAdventurerPath()
{
    int nTotalWeight = 0;
    int i;
    for (i=1; i<= ADVENTURER_PATH_HIGHEST; i++)
    {
        nTotalWeight += GetAdventurerPathWeight(i);
    }
    int nRandom = Random(nTotalWeight);
    i = 1;
    while (nRandom > 0 && i <= ADVENTURER_PATH_HIGHEST)
    {
        nRandom -= GetAdventurerPathWeight(i);
        i++;
    }
    return i;
}

int _IsAdventurerPathSuitableForAssassin(int nPath)
{
    if (nPath == ADVENTURER_PATH_PALADIN12 ||
        nPath == ADVENTURER_PATH_MONK8ROGUE3PDK1 ||
        nPath == ADVENTURER_PATH_SORCERER2PALADIN5AA5 ||
        nPath == ADVENTURER_PATH_PALADIN7TORM5 ||
        nPath == ADVENTURER_PATH_BARBARIAN7TORM5 ||
        nPath == ADVENTURER_PATH_ROGUE4FIGHTER4TORM4 ||
        nPath == ADVENTURER_PATH_ROGUE4PALADIN4TORM4 ||
        nPath == ADVENTURER_PATH_PALADIN7DD5 ||
        nPath == ADVENTURER_PATH_PALADIN8HARPER4 ||
        nPath == ADVENTURER_PATH_FIGHTER4PDK5PALADIN3 ||
        nPath == ADVENTURER_PATH_RANGER7PDK5 ||
        nPath == ADVENTURER_PATH_MONK8PDK4 ||
        nPath == ADVENTURER_PATH_PALADIN4PDK5TORM3 ||
        nPath == ADVENTURER_PATH_BARBARIAN7PDK5 ||
        nPath == ADVENTURER_PATH_FIGHTER4PDK5ROGUE3 ||
        nPath == ADVENTURER_PATH_BARD7PDK5)
        {
            return 0;
        }
    return 1;
}

int SelectAdventurerPathAssassin()
{
    int nTotalWeight = 0;
    int i;
    for (i=1; i<= ADVENTURER_PATH_HIGHEST; i++)
    {
        if (_IsAdventurerPathSuitableForAssassin(i))
        {   
            nTotalWeight += GetAdventurerPathWeight(i);
        }
    }
    int nRandom = Random(nTotalWeight);
    i = 1;
    while (nRandom > 0 && i <= ADVENTURER_PATH_HIGHEST)
    {
        if (_IsAdventurerPathSuitableForAssassin(i))
        {   
            nRandom -= GetAdventurerPathWeight(i);
            if (nRandom < 0)
            {
                break;
            }
        }
        i++;
    }
    //WriteTimestampedLogEntry("Selected assassin path: " + IntToString(i));
    return i;
}

int SelectAdventurerPathForPartyType(int nPartyType)
{
    if (nPartyType == ADVENTURER_PARTY_HOSTILE_ASSASSIN || nPartyType == ADVENTURER_PARTY_REST_ASSASSIN)
    {
        return SelectAdventurerPathAssassin();
    }
    return SelectAdventurerPath();
}

int GetRacialTypeForAdventurerPath(int nPath)
{
    switch (nPath)
    {
        // AA must be elf or halfelf
        case ADVENTURER_PATH_SORCERER2PALADIN5AA5:
        case ADVENTURER_PATH_WIZARD2FIGHTER5AA5:
        case ADVENTURER_PATH_BARD4FIGHTER3AA5:
        {
            if (d2() == 1)
            {
                return RACIAL_TYPE_HALFELF;
            }
            return RACIAL_TYPE_ELF;
            break;
        }
        // DD must be dwarf
        case ADVENTURER_PATH_FIGHTER7DD5:
        case ADVENTURER_PATH_PALADIN7DD5:
        case ADVENTURER_PATH_ROGUE4FIGHTER4DD4:
        {
            return RACIAL_TYPE_DWARF;
            break;
        }
        break;
    }
    int nHumanWeight = 100;
    int nDwarfWeight = 100;
    int nHalfelfWeight = 100;
    int nElfWeight = 100;
    int nGnomeWeight = 100;
    int nHalforcWeight = 100;
    int nHalflingWeight = 100;
    switch (nPath)
    {
        // Barbarians and the strength bonus from rage just seems like a poor idea on small stature races
        // considering they'll probably be wanting finesse anyway
        case ADVENTURER_PATH_BARBARIAN12:
        case ADVENTURER_PATH_BARBARIAN9ROGUE3:
        case ADVENTURER_PATH_BARBARIAN7TORM5:
        case ADVENTURER_PATH_BARBARIAN7PDK5:
        {
            nHalflingWeight /= 20;
            nGnomeWeight /= 20;
            break;
        }
        // Int penalty is bad for wizards
        case ADVENTURER_PATH_WIZARD12:
        case ADVENTURER_PATH_WIZARD3PM9:
        {
            nHalforcWeight /= 20;
            break;
        }
        // Cha penalty is bad for paladins/bards/blackguards
        case ADVENTURER_PATH_PALADIN12:
        case ADVENTURER_PATH_PALADIN9ROGUE3:
        case ADVENTURER_PATH_PALADIN7TORM5:
        case ADVENTURER_PATH_ROGUE4PALADIN4TORM4:
        case ADVENTURER_PATH_PALADIN7DD5:
        case ADVENTURER_PATH_PALADIN8HARPER4:
        case ADVENTURER_PATH_FIGHTER4PDK5PALADIN3:
        case ADVENTURER_PATH_PALADIN4PDK5TORM3:
        case ADVENTURER_PATH_BARD12:
        case ADVENTURER_PATH_BARD7PDK5:
        case ADVENTURER_PATH_RANGER6BLACKGUARD6:
        case ADVENTURER_PATH_MONK8BLACKGUARD4:
        {
            nDwarfWeight /= 20;
            nHalforcWeight /= 20;
            break;
        }
    }
    int nWeightSum = nHumanWeight + nDwarfWeight + nElfWeight + nHalfelfWeight + nHalforcWeight + nHalflingWeight + nGnomeWeight;
    int nRoll = Random(nWeightSum+1);
    if (nRoll < nHumanWeight) { return RACIAL_TYPE_HUMAN; }
    nRoll -= nHumanWeight;
    if (nRoll < nDwarfWeight) { return RACIAL_TYPE_DWARF; }
    nRoll -= nDwarfWeight;
    if (nRoll < nElfWeight) { return RACIAL_TYPE_ELF; }
    nRoll -= nElfWeight;
    if (nRoll < nHalfelfWeight) { return RACIAL_TYPE_HALFELF; }
    nRoll -= nHalfelfWeight;
    if (nRoll < nHalforcWeight) { return RACIAL_TYPE_HALFORC; }
    nRoll -= nHalforcWeight;
    if (nRoll < nHalflingWeight) { return RACIAL_TYPE_HALFLING; }
    nRoll -= nHalflingWeight;
    if (nRoll < nGnomeWeight) { return RACIAL_TYPE_GNOME; }
    nRoll -= nGnomeWeight;
    return RACIAL_TYPE_HUMAN;
}

void AddAdventurerRacialTypeFeats(object oCreature, int nRacialType)
{
    // Turns out you can remove this from the UTC as well, I wasn't sure you could
    //NWNX_Creature_RemoveFeat(oCreature, FEAT_QUICK_TO_MASTER);
    if (nRacialType == RACIAL_TYPE_HALFLING || nRacialType == RACIAL_TYPE_GNOME)
    {
        NWNX_Creature_SetSize(oCreature, CREATURE_SIZE_SMALL);
    }
    string sFeat2da = Get2DAString("racialtypes", "FeatsTable", nRacialType);
    int i;
    int nRowCount = Get2DARowCount(sFeat2da);
    for(i=0; i<=nRowCount; i++)
    {
        int nFeat = StringToInt(Get2DAString(sFeat2da, "FeatIndex", i));
        if (nFeat > 0)
        {
            NWNX_Creature_AddFeat(oCreature, nFeat);
        }
    }
    SetCreatureAppearanceType(oCreature, StringToInt(Get2DAString("racialtypes", "Appearance", nRacialType)));
    NWNX_Creature_SetRacialType(oCreature, nRacialType);
}

void AdjustAdventurerAlignment(object oCreature, int nPath)
{
    int nLawChaos = -1;
    int nGoodEvil = -1;
    switch (nPath)
    {
        case ADVENTURER_PATH_BARBARIAN12:
        case ADVENTURER_PATH_BARD12:
        case ADVENTURER_PATH_BARBARIAN9ROGUE3:
        case ADVENTURER_PATH_BARD4FIGHTER3AA5:
        {
            // Any non lawful
            nLawChaos = d2() == 1 ? ALIGNMENT_NEUTRAL : ALIGNMENT_CHAOTIC;
            break;
        }
        case ADVENTURER_PATH_DRUID12:
        {
            // Not LG, LE, CE, CG
            int nRoll = Random(5);
            if (nRoll == 0)
            {
                nLawChaos = ALIGNMENT_NEUTRAL;
                nGoodEvil = ALIGNMENT_NEUTRAL;
            }
            else if (nRoll == 1)
            {
                nLawChaos = ALIGNMENT_CHAOTIC;
                nGoodEvil = ALIGNMENT_NEUTRAL;
            }
            else if (nRoll == 2)
            {
                nLawChaos = ALIGNMENT_LAWFUL;
                nGoodEvil = ALIGNMENT_NEUTRAL;
            }
            else if (nRoll == 3)
            {
                nLawChaos = ALIGNMENT_NEUTRAL;
                nGoodEvil = ALIGNMENT_GOOD;
            }
            else if (nRoll == 4)
            {
                nLawChaos = ALIGNMENT_NEUTRAL;
                nGoodEvil = ALIGNMENT_EVIL;
            }
            break;
        }
        case ADVENTURER_PATH_MONK12:
        case ADVENTURER_PATH_CLERIC11MONK1:
        case ADVENTURER_PATH_FIGHTER7DD5:
        case ADVENTURER_PATH_ROGUE4FIGHTER4DD4:
        case ADVENTURER_PATH_RANGER11MONK1:
        {
            // Any lawful
            nLawChaos = ALIGNMENT_LAWFUL;
            break;
        }
        case ADVENTURER_PATH_PALADIN12:
        case ADVENTURER_PATH_PALADIN9ROGUE3:
        case ADVENTURER_PATH_SORCERER2PALADIN5AA5:
        case ADVENTURER_PATH_PALADIN7TORM5:
        case ADVENTURER_PATH_ROGUE4PALADIN4TORM4:
        case ADVENTURER_PATH_PALADIN7DD5:
        case ADVENTURER_PATH_PALADIN8HARPER4:
        case ADVENTURER_PATH_FIGHTER4PDK5PALADIN3:
        case ADVENTURER_PATH_PALADIN4PDK5TORM3:
        {
            // LG only
            nLawChaos = ALIGNMENT_LAWFUL;
            nGoodEvil = ALIGNMENT_GOOD;
            break;
        }
        case ADVENTURER_PATH_DRUID11MONK1:
        {
            // LN only
            nLawChaos = ALIGNMENT_LAWFUL;
            nGoodEvil = ALIGNMENT_NEUTRAL;
            break;
        }
        case ADVENTURER_PATH_RANGER6BLACKGUARD6:
        case ADVENTURER_PATH_ROGUE5ASSASSIN7:
        case ADVENTURER_PATH_RANGER5ASSASSIN7:
        case ADVENTURER_PATH_RANGER9ASSASSIN3:
        case ADVENTURER_PATH_ROGUE5ASSASSIN5SHADOWDANCER2:
        {
            // Any evil
            nGoodEvil = ALIGNMENT_EVIL;
            break;
        }
        case ADVENTURER_PATH_MONK8BLACKGUARD4:
        case ADVENTURER_PATH_MONK5ASSASSIN7:
        case ADVENTURER_PATH_MONK5ASSASSIN5SHADOWDANCER2:
        {
            // LE only
            nGoodEvil = ALIGNMENT_EVIL;
            nLawChaos = ALIGNMENT_LAWFUL;
            break;
        }
        case ADVENTURER_PATH_FIGHTER7TORM5:
        case ADVENTURER_PATH_ROGUE4FIGHTER4TORM4:
        {
            // Any non evil
            nGoodEvil = d2() == 1 ? ALIGNMENT_NEUTRAL : ALIGNMENT_GOOD;
            break;
        }
        case ADVENTURER_PATH_BARBARIAN7TORM5:
        {
            // non-evil and non-lawful
            nGoodEvil = d2() == 1 ? ALIGNMENT_NEUTRAL : ALIGNMENT_GOOD;
            nLawChaos = d2() == 1 ? ALIGNMENT_NEUTRAL : ALIGNMENT_CHAOTIC;
            break;
        }
        case ADVENTURER_PATH_RANGER7PDK5:
        case ADVENTURER_PATH_FIGHTER4PDK5ROGUE3:
        {
            // Non evil, non chaotic
            nGoodEvil = d2() == 1 ? ALIGNMENT_NEUTRAL : ALIGNMENT_GOOD;
            nLawChaos = d2() == 1 ? ALIGNMENT_NEUTRAL : ALIGNMENT_LAWFUL;
            break;
        }
        case ADVENTURER_PATH_WIZARD3PM9:
        {
            // Non good
            nGoodEvil = d2() == 1 ? ALIGNMENT_NEUTRAL : ALIGNMENT_EVIL;
            break;
        }
        case ADVENTURER_PATH_MONK8PDK4:
        case ADVENTURER_PATH_MONK8ROGUE3PDK1:
        {
            // Non evil and lawful
            nGoodEvil = d2() == 1 ? ALIGNMENT_NEUTRAL : ALIGNMENT_GOOD;
            nLawChaos = ALIGNMENT_LAWFUL;
            break;
        }
        case ADVENTURER_PATH_BARBARIAN7PDK5:
        case ADVENTURER_PATH_BARD7PDK5:
        {
            // Neutral law-chaos, nonevil
            nLawChaos = ALIGNMENT_NEUTRAL;
            nGoodEvil = d2() == 1 ? ALIGNMENT_NEUTRAL : ALIGNMENT_GOOD;
            break;
        }
        break;
    }
    if (nLawChaos == -1)
    {
        int nRoll = d3();
        if (nRoll == 1) { nLawChaos = ALIGNMENT_CHAOTIC; }
        else if (nRoll == 2) { nLawChaos = ALIGNMENT_NEUTRAL; }
        else if (nRoll == 3) { nLawChaos = ALIGNMENT_LAWFUL; }
    }
    if (nGoodEvil == -1)
    {
        int nRoll = d3();
        if (nRoll == 1) { nGoodEvil = ALIGNMENT_EVIL; }
        else if (nRoll == 2) { nGoodEvil = ALIGNMENT_NEUTRAL; }
        else if (nRoll == 3) { nGoodEvil = ALIGNMENT_GOOD; }
    }
    if (nLawChaos == ALIGNMENT_LAWFUL)
    {
        NWNX_Creature_SetAlignmentLawChaos(oCreature, 85);
    }
    else if (nLawChaos == ALIGNMENT_CHAOTIC)
    {
        NWNX_Creature_SetAlignmentLawChaos(oCreature, 15);
    }
    else
    {
        NWNX_Creature_SetAlignmentLawChaos(oCreature, 50);
    }
    
    if (nGoodEvil == ALIGNMENT_GOOD)
    {
        NWNX_Creature_SetAlignmentGoodEvil(oCreature, 85);
    }
    else if (nGoodEvil == ALIGNMENT_EVIL)
    {
        NWNX_Creature_SetAlignmentGoodEvil(oCreature, 15);
    }
    else
    {
        NWNX_Creature_SetAlignmentGoodEvil(oCreature, 50);
    }
}

int _GetSkillpointsPerLevelInClass(int nClass)
{
    return StringToInt(Get2DAString("classes", "SkillPointBase", nClass));
}

int _GetHitDieForClass(int nClass)
{
    return StringToInt(Get2DAString("classes", "HitDie", nClass));
}


int _GetCostToIncreaseAbility(int nAbilityScore)
{
    if (nAbilityScore >= 16)
    {
        return 3;
    }
    if (nAbilityScore >= 14)
    {
        return 2;
    }
    return 1;
}

int _GetRefundFromDecreasingAbility(int nAbilityScore)
{
    if (nAbilityScore > 16)
    {
        return 3;
    }
    if (nAbilityScore > 14)
    {
        return 2;
    }
    return 1;
}

void AdventurerFinesseAdjustAbilities(object oCreature, int nMinStrength=10)
{
    int nStr = NWNX_Creature_GetRawAbilityScore(oCreature, ABILITY_STRENGTH);
    int nDex = NWNX_Creature_GetRawAbilityScore(oCreature, ABILITY_DEXTERITY);
    int nRealStr = GetAbilityScore(oCreature, ABILITY_STRENGTH);
    //if (nDex >= 14 && nStr < 14)
    //{
    //    return;
    //}
    if (nRealStr <= nMinStrength)
    {
        return;
    }
    int nNeededPoints = _GetCostToIncreaseAbility(nDex);
    int nPoints = _GetRefundFromDecreasingAbility(nStr);
    int nDecrease = 1;
    if (nPoints < nNeededPoints)
    {
        nDecrease = 2;
        nPoints += _GetRefundFromDecreasingAbility(nStr-1);
    }
    if (nPoints > nNeededPoints)
    {
        // If the extra point(s) translate directly to another dex rank, just add it
        if (nPoints - nNeededPoints == _GetCostToIncreaseAbility(nDex + 1))
        {
            NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, nDex + 1);
            nDex++;
        }
        else
        {
            // Can't easily handle this case
            return;
        }
    }
    NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, nStr - nDecrease);
    NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, nDex + 1);
    // Go again until something says stop
    AdventurerFinesseAdjustAbilities(oCreature, nMinStrength);
}

void AdventurerResetFeats(object oCreature)
{
    // Remove all feats
    int nFeats = NWNX_Creature_GetFeatCount(oCreature);
    while (nFeats > 0)
    {
        int nFeat = NWNX_Creature_GetFeatByIndex(oCreature, nFeats - 1);
        int nLevel = NWNX_Creature_GetFeatGrantLevel(oCreature, nFeat);
        if (nLevel > 0)
        {
            NWNX_Creature_RemoveFeatByLevel(oCreature, nFeat, nLevel);
        }
        NWNX_Creature_RemoveFeat(oCreature, nFeat);
        nFeats--;
    }
    // re-add racials
    AddAdventurerRacialTypeFeats(oCreature, GetRacialType(oCreature));
    // Add auto granted feats from classes
    int nClassIndex;
    int nHD = GetHitDice(oCreature);
    for (nClassIndex=0; nClassIndex<=3; nClassIndex++)
    {
        int nClass = GetClassByPosition(nClassIndex, oCreature);
        int nClassLevel = GetLevelByClass(nClass, oCreature);
        string sFeat2DA = Get2DAString("classes", "FeatsTable", nClass);
        int nRows = Get2DARowCount(sFeat2DA);
        int nRow;
        for (nRow=0; nRow<nRows; nRow++)
        {
            int nList = StringToInt(Get2DAString(sFeat2DA, "List", nRow));
            if (nList != 3) { continue; }
            int nGrantedLevel = StringToInt(Get2DAString(sFeat2DA, "GrantedOnLevel", nRow));
            if (nGrantedLevel > 0 && nClassLevel >= nGrantedLevel)
            {
                int nFeat = StringToInt(Get2DAString(sFeat2DA, "FeatIndex", nRow));
                // Find the real level at which the creature reached this class level
                int nTestClassLevel = 0;
                int nCurrentHD;
                for (nCurrentHD=1; nCurrentHD<=nHD; nCurrentHD++)
                {
                    if (NWNX_Creature_GetClassByLevel(oCreature, nCurrentHD) == nClass)
                    {
                        nTestClassLevel++;
                        if (nTestClassLevel == nGrantedLevel)
                        {
                            NWNX_Creature_AddFeatByLevel(oCreature, nFeat, nCurrentHD);
                            break;
                        }
                    }
                }
            }
        }
    }
}

void AdventurerResetSkills(object oCreature)
{
    int nHD = GetHitDice(oCreature);
    int nCurrentHD;
    int nCurrentSkill;
    for (nCurrentHD=1; nCurrentHD<=nHD; nCurrentHD++)
    {
        for (nCurrentSkill=0; nCurrentSkill<=27; nCurrentSkill++)
        {
            NWNX_Creature_SetSkillRankByLevel(oCreature, nCurrentSkill, 0, nCurrentHD);
        }
    }
    for (nCurrentSkill=0; nCurrentSkill<=27; nCurrentSkill++)
    {
        NWNX_Creature_SetSkillRank(oCreature, nCurrentSkill, 0);
    }
}

void AddAdventurerDesiredSkill(object oCreature, int nSkill)
{
    int nIndex = GetLocalInt(oCreature, "adventurer_num_desired_skills");
    SetLocalInt(oCreature, "adventurer_desired_skill" + IntToString(nIndex), nSkill);
    SetLocalInt(oCreature, "adventurer_num_desired_skills", nIndex+1);
}

void AddAdventurerSpellbookType(object oCreature, int nClass, int nSpellbookType)
{
    string sClass = IntToString(nClass);
    int nIndex = GetLocalInt(oCreature, "adventurer_num_spellbooks_" + sClass);
    SetLocalInt(oCreature, "adventurer_spellbook_" + sClass + "_" + IntToString(nIndex), nSpellbookType);
    SetLocalInt(oCreature, "adventurer_num_spellbooks_" + sClass, nIndex+1);
}

void AddRandomAdventurerSkills(object oCreature, int nSkillpoints)
{
    int nHD = GetHitDice(oCreature);
    int nMaxRank = nHD + 3;
    int nNumDesired = GetLocalInt(oCreature, "adventurer_num_desired_skills");
    // No zero division please
    if (nNumDesired == 0)
    {
        return;
    }
    int nAmountPerSkill = nSkillpoints/nNumDesired;
    int nRemainder = 0;
    if (nAmountPerSkill > nMaxRank)
    {
        nAmountPerSkill = nMaxRank;
    }
    nRemainder = nSkillpoints - (nAmountPerSkill * nNumDesired);
    int i;
    for (i=0; i<nNumDesired; i++)
    {
        int nSkill = GetLocalInt(oCreature, "adventurer_desired_skill" + IntToString(i));
        int nAmt = nAmountPerSkill;
        if (nRemainder > 0 && nAmt < nMaxRank)
        {
            nAmt++;
            nRemainder--;
        }
        NWNX_Creature_SetSkillRank(oCreature, nSkill, nAmt);
    }
    // For now, excess points are discarded :(
}

void AdvanceCreatureAlongAdventurerPath(object oCreature, int nPath, int nHD)
{
    if (!GetIsObjectValid(oCreature))
    {
        return;
    }
    if (nHD < 1) { return; }
    else if (nPath <= 0 || nPath > ADVENTURER_PATH_HIGHEST)
    {
        WriteTimestampedLogEntry("Warning: Tried to advance adventurer along invalid path " + IntToString(nPath));
        nPath = Random(12) + 1;
    }
    int nRacialType = GetRacialTypeForAdventurerPath(nPath);
    NWNX_Creature_SetRacialType(oCreature, nRacialType);
    AdjustAdventurerAlignment(oCreature, nPath);
 
    GenerateTrueName(oCreature);
    NWNX_Creature_SetChallengeRating(oCreature, IntToFloat(nHD));
 
    // There are Problems here.
    // Namely there is seemingly no way to add a class to a creature
    // without getting involved in one level of its default package
    // NWNX_Creature_SetLevelByPosition doesn't let you add the first level which is unfortunate
    // The solution here is probably to do things in a set order
    
    // 1) Set race (can forget about racial feats for now)
    // 2) Set final levels
    // 3) Ability scores, because packages will change that too
    // 4) Remove every single feat on the creature
    // 5) Readd racial feats
    // 6) Readd automatic class-based feats
    // 7) Add random feats
    // 8) Remove all skills on the creature
    // 9) Set skills again
    // 10) Equipment, appearance etc
    
    // When adding prestige classes this way, all the requirements have to be met or NWNX says...
    // [NWNX_Creature] [Creature.cpp:1515] Failed to add level of class 41, aborting
    // This means adding some things (required skills, feats) twice
    
    // This is the really longwinded part
    int nCurrentHD;
    int i;
    int bIsHuman = nRacialType == RACIAL_TYPE_HUMAN;
    int nRemainingFeats = 1 + (nHD/3) + bIsHuman;
    int nRemainingSkillpoints = 0;
    int nUsedFighterBonusFeats = 0;
    int nUsedRogueBonusFeats = 0;
    int bFinesseAdjust = 0; 
    if (nRacialType == RACIAL_TYPE_GNOME || nRacialType == RACIAL_TYPE_HALFLING)
    {
        bFinesseAdjust = 1;
    }
    else if (d10() == 10)
    {
        bFinesseAdjust = 1;
    }
    
    // Whether or not the path overrides the spellbooks (if unset this instead churns out something randomly)
    int bOverrideSpellbooks = 0;
    if (nPath <= ADVENTURER_PATH_WIZARD12)
    {
        // Pure classes are a much, much simpler problem
        int nClass = CLASS_TYPE_WIZARD;
        if (nPath == ADVENTURER_PATH_BARBARIAN12) { nClass = CLASS_TYPE_BARBARIAN; }
        else if (nPath == ADVENTURER_PATH_BARD12) { nClass = CLASS_TYPE_BARD; }
        else if (nPath == ADVENTURER_PATH_CLERIC12) { nClass = CLASS_TYPE_CLERIC; }
        else if (nPath == ADVENTURER_PATH_DRUID12) { nClass = CLASS_TYPE_DRUID; }
        else if (nPath == ADVENTURER_PATH_FIGHTER12) { nClass = CLASS_TYPE_FIGHTER; }
        else if (nPath == ADVENTURER_PATH_MONK12) { nClass = CLASS_TYPE_MONK; }
        else if (nPath == ADVENTURER_PATH_PALADIN12) { nClass = CLASS_TYPE_PALADIN; }
        else if (nPath == ADVENTURER_PATH_RANGER12) { nClass = CLASS_TYPE_RANGER; }
        else if (nPath == ADVENTURER_PATH_ROGUE12) { nClass = CLASS_TYPE_ROGUE; }
        else if (nPath == ADVENTURER_PATH_SORCERER12) { nClass = CLASS_TYPE_SORCERER; }
        NWNX_Creature_SetClassByPosition(oCreature, 0, nClass, TRUE);
        NWNX_Creature_LevelUp(oCreature, nClass, (nHD - 1));
        for (nCurrentHD=1; nCurrentHD<=nHD; nCurrentHD++)
        {
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
        }
        
        // Recommended button!
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, StringToInt(Get2DAString("classes", "Str", nClass)));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, StringToInt(Get2DAString("classes", "Dex", nClass)));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, StringToInt(Get2DAString("classes", "Con", nClass)));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, StringToInt(Get2DAString("classes", "Int", nClass)));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, StringToInt(Get2DAString("classes", "Wis", nClass)));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, StringToInt(Get2DAString("classes", "Cha", nClass)));
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman) * (nHD + 3);
        if (bFinesseAdjust)
        {
            AdventurerFinesseAdjustAbilities(oCreature, 10);
        }
        int nAbilityToIncrease = ABILITY_STRENGTH;
        if (nClass == CLASS_TYPE_CLERIC || nClass == CLASS_TYPE_DRUID || nClass == CLASS_TYPE_MONK)
        {
            nAbilityToIncrease = ABILITY_WISDOM;
        }
        else if (nClass == CLASS_TYPE_BARD || nClass == CLASS_TYPE_PALADIN)
        {
            nAbilityToIncrease = ABILITY_CHARISMA;
        }
        else if (nClass == CLASS_TYPE_RANGER || nClass == CLASS_TYPE_ROGUE)
        {
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        else if (nClass == CLASS_TYPE_WIZARD)
        {
            nAbilityToIncrease = ABILITY_INTELLIGENCE;
        }
        if (bFinesseAdjust && nAbilityToIncrease == ABILITY_STRENGTH)
        {
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        if (nClass == CLASS_TYPE_CLERIC || nClass == CLASS_TYPE_DRUID || nClass == CLASS_TYPE_WIZARD || nClass == CLASS_TYPE_SORCERER || nClass == CLASS_TYPE_BARD)
        {
            AddAdventurerDesiredSkill(oCreature, SKILL_CONCENTRATION);
            AddAdventurerDesiredSkill(oCreature, SKILL_SPELLCRAFT);
        }
        if (nClass == CLASS_TYPE_BARD)
        {
            SetAdventurerMaxArmorAC(oCreature, 2);
            AddAdventurerDesiredSkill(oCreature, SKILL_PERFORM);
            AddAdventurerDesiredSkill(oCreature, SKILL_USE_MAGIC_DEVICE);
        }
        if (nClass == CLASS_TYPE_ROGUE)
        {
            AddAdventurerDesiredSkill(oCreature, SKILL_OPEN_LOCK);
            AddAdventurerDesiredSkill(oCreature, SKILL_DISABLE_TRAP);
            AddAdventurerDesiredSkill(oCreature, SKILL_SEARCH);
            AddAdventurerDesiredSkill(oCreature, SKILL_USE_MAGIC_DEVICE);
        }
        if (nClass == CLASS_TYPE_ROGUE || nClass == CLASS_TYPE_MONK || nClass == CLASS_TYPE_BARD)
        {
            AddAdventurerDesiredSkill(oCreature, SKILL_TUMBLE);
        }
        if (nClass == CLASS_TYPE_ROGUE || nClass == CLASS_TYPE_MONK || nClass == CLASS_TYPE_BARD)
        {
            AddAdventurerDesiredSkill(oCreature, SKILL_TUMBLE);
        }
        if (nClass == CLASS_TYPE_ROGUE || nClass == CLASS_TYPE_MONK || nClass == CLASS_TYPE_RANGER)
        {
            AddAdventurerDesiredSkill(oCreature, SKILL_HIDE);
            AddAdventurerDesiredSkill(oCreature, SKILL_MOVE_SILENTLY);
        }
        if (nClass == CLASS_TYPE_BARBARIAN || nClass == CLASS_TYPE_MONK || nClass == CLASS_TYPE_BARD || nClass == CLASS_TYPE_RANGER || nClass == CLASS_TYPE_FIGHTER || nClass == CLASS_TYPE_PALADIN)
        {
            AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        }
        if (nClass == CLASS_TYPE_BARBARIAN || nClass == CLASS_TYPE_PALADIN)
        {
            AddAdventurerDesiredSkill(oCreature, SKILL_TAUNT);
        }
        if (nClass == CLASS_TYPE_BARBARIAN)
        {
            AddAdventurerDesiredSkill(oCreature, SKILL_LISTEN);
        }

    }
    // This hurts.
    // With NWScript restrictions and lack of callbacks I see no easy way to do this without a ton of code reuse
    // because some of these adventurers are going to want some pretty gnarly stuff handled in their level up process
    
    else if (nPath == ADVENTURER_PATH_FIGHTER9ROGUE3)
    {
        // 1st level rogue for skill points
        // 6th level rogue because weapon specialisation should be picked up as fighter 4 bonus feat
        // 7th level rogue because no BAB loss and +1d6 sneak attack, a human would rebuild to take this at 12 though
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_ROGUE, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_ROGUE));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 12);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_ROGUE) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_FIGHTER;
            if (nCurrentHD == 6 || nCurrentHD == 7)
            {
                nClass = CLASS_TYPE_ROGUE;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 12);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 12);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 8);
        
        int nAbilityToIncrease = ABILITY_STRENGTH;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        if (nHD >= 2)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_WEAPON_FOCUS_DAGGER, 2);
            nUsedFighterBonusFeats++;
        }
        if (nCurrentHD >= 5)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_WEAPON_SPECIALIZATION_DAGGER, 5);
            nUsedFighterBonusFeats++;
        }
        AddAdventurerDesiredSkill(oCreature, SKILL_TUMBLE);
        AddAdventurerDesiredSkill(oCreature, SKILL_OPEN_LOCK);
        AddAdventurerDesiredSkill(oCreature, SKILL_DISABLE_TRAP);
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        AddAdventurerDesiredSkill(oCreature, SKILL_SEARCH);
        AddAdventurerDesiredSkill(oCreature, SKILL_USE_MAGIC_DEVICE);
    }
    else if (nPath == ADVENTURER_PATH_BARBARIAN9ROGUE3)
    {
        // 1st level rogue for skill points
        // 6th level rogue because weapon specialisation should be picked up as fighter 4 bonus feat
        // 7th level rogue because no BAB loss and +1d6 sneak attack, a human would rebuild to take this at 12 though
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_ROGUE, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_ROGUE));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 12);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_ROGUE) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_BARBARIAN;
            if (nCurrentHD == 6 || nCurrentHD == 7)
            {
                nClass = CLASS_TYPE_ROGUE;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 12);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 12);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 8);
        
        int nAbilityToIncrease = ABILITY_STRENGTH;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_TUMBLE);
        AddAdventurerDesiredSkill(oCreature, SKILL_OPEN_LOCK);
        AddAdventurerDesiredSkill(oCreature, SKILL_DISABLE_TRAP);
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        AddAdventurerDesiredSkill(oCreature, SKILL_TAUNT);
        AddAdventurerDesiredSkill(oCreature, SKILL_USE_MAGIC_DEVICE);
    }
    else if (nPath == ADVENTURER_PATH_PALADIN9ROGUE3)
    {
        // 1st level rogue for skill points
        // 6th level rogue because weapon specialisation should be picked up as fighter 4 bonus feat
        // 7th level rogue because no BAB loss and +1d6 sneak attack, a human would rebuild to take this at 12 though
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_ROGUE, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_ROGUE));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_ROGUE) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_PALADIN;
            if (nCurrentHD == 6 || nCurrentHD == 7)
            {
                nClass = CLASS_TYPE_ROGUE;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 15);
        
        int nAbilityToIncrease = ABILITY_CHARISMA;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_TUMBLE);
        AddAdventurerDesiredSkill(oCreature, SKILL_OPEN_LOCK);
        AddAdventurerDesiredSkill(oCreature, SKILL_DISABLE_TRAP);
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        AddAdventurerDesiredSkill(oCreature, SKILL_TAUNT);
        AddAdventurerDesiredSkill(oCreature, SKILL_USE_MAGIC_DEVICE);
    }
    else if (nPath == ADVENTURER_PATH_RANGER9ROGUE3)
    {
        // 1st level rogue for skill points
        // 6th level rogue because weapon specialisation should be picked up as fighter 4 bonus feat
        // 7th level rogue because no BAB loss and +1d6 sneak attack, a human would rebuild to take this at 12 though
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_ROGUE, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_ROGUE));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_ROGUE) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_RANGER;
            if (nCurrentHD == 6 || nCurrentHD == 7)
            {
                nClass = CLASS_TYPE_ROGUE;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 8);
        
        int nAbilityToIncrease = ABILITY_DEXTERITY;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_TUMBLE);
        AddAdventurerDesiredSkill(oCreature, SKILL_OPEN_LOCK);
        AddAdventurerDesiredSkill(oCreature, SKILL_DISABLE_TRAP);
        AddAdventurerDesiredSkill(oCreature, SKILL_HIDE);
        AddAdventurerDesiredSkill(oCreature, SKILL_MOVE_SILENTLY);
        AddAdventurerDesiredSkill(oCreature, SKILL_USE_MAGIC_DEVICE);
    }
    else if (nPath == ADVENTURER_PATH_MONK8ROGUE3PDK1)
    {
        // 1st level rogue for skill points
        // 6th/8th level rogue, postpone BAB loss from monk 5
        // 7th level pdk (min BAB)
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_ROGUE, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_ROGUE));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_ROGUE) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_MONK;
            if (nCurrentHD == 6 || nCurrentHD == 8)
            {
                nClass = CLASS_TYPE_ROGUE;
            }
            if (nCurrentHD == 7)
            {
                NWNX_Creature_SetSkillRank(oCreature, SKILL_INTIMIDATE, 1);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_LISTEN, 2);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_PERSUADE, 1);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_RIDE, 2);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_SPOT, 2);
                nClass = CLASS_TYPE_PURPLE_DRAGON_KNIGHT;
                //return;
            }
            if (nCurrentHD == 4)
            {
                NWNX_Creature_AddFeat(oCreature, FEAT_MOUNTED_COMBAT);
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 8);
        
        int nAbilityToIncrease = ABILITY_DEXTERITY;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_TUMBLE);
        AddAdventurerDesiredSkill(oCreature, SKILL_OPEN_LOCK);
        AddAdventurerDesiredSkill(oCreature, SKILL_DISABLE_TRAP);
        AddAdventurerDesiredSkill(oCreature, SKILL_HIDE);
        AddAdventurerDesiredSkill(oCreature, SKILL_MOVE_SILENTLY);
        AddAdventurerDesiredSkill(oCreature, SKILL_USE_MAGIC_DEVICE);
        if (nHD >= 7)
        {
            // PDK entry reqs
            nRemainingSkillpoints -= 10;
            NWNX_Creature_SetSkillRank(oCreature, SKILL_INTIMIDATE, 1);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_LISTEN, 2);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_PERSUADE, 1);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_RIDE, 2);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_SPOT, 2);
        }
        if (nHD >= 4)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_MOUNTED_COMBAT, 4);
            nRemainingFeats--;
        }
        
    }
    else if (nPath == ADVENTURER_PATH_CLERIC11MONK1)
    {
        // 6th level monk, it's when UBAB progression gains a second attack
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_CLERIC, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_CLERIC));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 8);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_CLERIC) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_CLERIC;
            if (nCurrentHD == 6)
            {
                nClass = CLASS_TYPE_MONK;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 8);
        
        int nAbilityToIncrease = ABILITY_STRENGTH;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_TUMBLE);
        AddAdventurerDesiredSkill(oCreature, SKILL_CONCENTRATION);
        
        // AI does not use divine X
        //if (nRemainingFeats)
        //{
        //    NWNX_Creature_AddFeatByLevel(oCreature, FEAT_POWER_ATTACK, 1);
        //    nRemainingFeats--;
        //}
        //if (nRemainingFeats)
        //{
        //    NWNX_Creature_AddFeatByLevel(oCreature, FEAT_DIVINE_SHIELD, 1);
        //    nRemainingFeats--;
        //}
        //if (nRemainingFeats)
        //{
        //    NWNX_Creature_AddFeatByLevel(oCreature, FEAT_DIVINE_MIGHT, 1);
        //    nRemainingFeats--;
        //}
        AddAdventurerSpellbookType(oCreature, CLASS_TYPE_CLERIC, RAND_SPELL_DIVINE_BUFF_ATTACKS);
        bOverrideSpellbooks = 1;
    }
    else if (nPath == ADVENTURER_PATH_DRUID11MONK1)
    {
        // 6th level monk, it's when UBAB progression gains a second attack
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_DRUID, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_DRUID));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_DRUID) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_DRUID;
            if (nCurrentHD == 6)
            {
                nClass = CLASS_TYPE_MONK;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 8);
        
        int nAbilityToIncrease = ABILITY_CHARISMA;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_CHARISMA;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_TUMBLE);
        AddAdventurerDesiredSkill(oCreature, SKILL_CONCENTRATION);
        
    }
    else if (nPath == ADVENTURER_PATH_RANGER6BLACKGUARD6)
    {
        // 6 ranger than 6 bg
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_RANGER, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_RANGER));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 8);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_RANGER) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_RANGER;
            if (nCurrentHD >= 7)
            {
                NWNX_Creature_AddFeat(oCreature, FEAT_CLEAVE);
                nClass = CLASS_TYPE_BLACKGUARD;
                NWNX_Creature_SetSkillRank(oCreature, SKILL_HIDE, 5);
                //return;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 8);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 12);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 8);
        bFinesseAdjust = 1;
        int nAbilityToIncrease = ABILITY_STRENGTH;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        AddAdventurerDesiredSkill(oCreature, SKILL_TAUNT);
        
        if (nRemainingFeats)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_POWER_ATTACK, 1);
            nRemainingFeats--;
        }
        if (nRemainingFeats)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_CLEAVE, 1);
            nRemainingFeats--;
        }
        if (nHD >= 7)
        {
            // BG entry
            nRemainingSkillpoints -= 5;
            NWNX_Creature_SetSkillRank(oCreature, SKILL_HIDE, 5);
        }
    }
    else if (nPath == ADVENTURER_PATH_MONK8BLACKGUARD4)
    {
        // bg levels last
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_MONK, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_MONK));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 8);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_MONK) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_MONK;
            if (nCurrentHD >= 9)
            {
                nClass = CLASS_TYPE_BLACKGUARD;
                NWNX_Creature_SetSkillRank(oCreature, SKILL_HIDE, 5);
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 8);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 10);
        
        int nAbilityToIncrease = ABILITY_STRENGTH;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        AddAdventurerDesiredSkill(oCreature, SKILL_TUMBLE);
        
        if (nHD >= 9)
        {
            // BG entry
            nRemainingSkillpoints -= 5;
            NWNX_Creature_SetSkillRank(oCreature, SKILL_HIDE, 5);
        }
    }
    else if (nPath == ADVENTURER_PATH_SORCERER2PALADIN5AA5)
    {
        // Paladin first, then sorc, then AA
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_PALADIN, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_PALADIN));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_PALADIN) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_PALADIN;
            if (nCurrentHD == 6 || nCurrentHD == 7)
            {
                nClass = CLASS_TYPE_SORCERER;
            }
            if (nCurrentHD >= 8)
            {
                if (nCurrentHD == 8)
                {
                    NWNX_Creature_AddFeat(oCreature, FEAT_WEAPON_FOCUS_SHORTBOW);
                    NWNX_Creature_AddFeat(oCreature, FEAT_POINT_BLANK_SHOT);
                }
                nClass = CLASS_TYPE_ARCANE_ARCHER;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 8);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 14);
        
        int nAbilityToIncrease = ABILITY_DEXTERITY;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        AddAdventurerDesiredSkill(oCreature, SKILL_SPOT);
        AddAdventurerDesiredSkill(oCreature, SKILL_LISTEN);
        
        // Divine might isn't legal on this build - 4th feat has to be at level 9
        // While it would probably be stronger to drop AA levels, shuffle abilities, and slot it in
        // I don't yet know how well the AI does with it
        if (nRemainingFeats)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_POINT_BLANK_SHOT, 1);
            nRemainingFeats--;
        }
        if (nRemainingFeats)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_WEAPON_FOCUS_DAGGER, 1);
            nRemainingFeats--;
        }
        if (nRemainingFeats)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_RAPID_SHOT, 1);
            nRemainingFeats--;
        }
        if (nRemainingFeats)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_IMPROVED_CRITICAL_DAGGER, 1);
            nRemainingFeats--;
        }
        AddAdventurerSpellbookType(oCreature, CLASS_TYPE_SORCERER, RAND_SPELL_ARCANE_BUFF_ATTACKS);
        bOverrideSpellbooks = 1;
    }
    else if (nPath == ADVENTURER_PATH_WIZARD2FIGHTER5AA5)
    {
        // Fighter first, then wiz, then AA
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_FIGHTER, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_FIGHTER));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 14);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_FIGHTER) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_FIGHTER;
            if (nCurrentHD == 6 || nCurrentHD == 7)
            {
                nClass = CLASS_TYPE_WIZARD;
            }
            if (nCurrentHD >= 8)
            {
                if (nCurrentHD == 8)
                {
                    NWNX_Creature_AddFeat(oCreature, FEAT_WEAPON_FOCUS_SHORTBOW);
                    NWNX_Creature_AddFeat(oCreature, FEAT_POINT_BLANK_SHOT);
                }
                nClass = CLASS_TYPE_ARCANE_ARCHER;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 8);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 10);
        
        int nAbilityToIncrease = ABILITY_DEXTERITY;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        AddAdventurerDesiredSkill(oCreature, SKILL_SPOT);
        AddAdventurerDesiredSkill(oCreature, SKILL_LISTEN);
        
        // Divine might isn't legal on this build - 4th feat has to be at level 9
        // While it would probably be stronger to drop AA levels, shuffle abilities, and slot it in
        // I don't yet know how well the AI does with it
        if (nRemainingFeats)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_POINT_BLANK_SHOT, 1);
            nRemainingFeats--;
        }
        if (nRemainingFeats)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_WEAPON_FOCUS_DAGGER, 1);
            nRemainingFeats--;
        }
        if (nRemainingFeats)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_RAPID_SHOT, 1);
            nRemainingFeats--;
        }
        if (nRemainingFeats)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_IMPROVED_CRITICAL_DAGGER, 1);
            nRemainingFeats--;
        }
        AddAdventurerSpellbookType(oCreature, CLASS_TYPE_WIZARD, RAND_SPELL_ARCANE_BUFF_ATTACKS);
        bOverrideSpellbooks = 1;
    }
    else if (nPath == ADVENTURER_PATH_BARD4FIGHTER3AA5)
    {
        // bard first, then fighter, then AA
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_BARD, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_BARD));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_BARD) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_BARD;
            if (nCurrentHD == 6 || nCurrentHD == 7 || nCurrentHD == 5)
            {
                nClass = CLASS_TYPE_FIGHTER;
            }
            if (nCurrentHD >= 8)
            {
                if (nCurrentHD == 8)
                {
                    NWNX_Creature_AddFeat(oCreature, FEAT_WEAPON_FOCUS_SHORTBOW);
                    NWNX_Creature_AddFeat(oCreature, FEAT_POINT_BLANK_SHOT);
                }
                nClass = CLASS_TYPE_ARCANE_ARCHER;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 8);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 14);
        
        int nAbilityToIncrease = ABILITY_DEXTERITY;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_PERFORM);
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        AddAdventurerDesiredSkill(oCreature, SKILL_SPOT);
        AddAdventurerDesiredSkill(oCreature, SKILL_USE_MAGIC_DEVICE);
        
        // Divine might isn't legal on this build - 4th feat has to be at level 9
        // While it would probably be stronger to drop AA levels, shuffle abilities, and slot it in
        // I don't yet know how well the AI does with it
        if (nRemainingFeats)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_POINT_BLANK_SHOT, 1);
            nRemainingFeats--;
        }
        if (nRemainingFeats)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_WEAPON_FOCUS_DAGGER, 1);
            nRemainingFeats--;
        }
        if (nRemainingFeats)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_RAPID_SHOT, 1);
            nRemainingFeats--;
        }
        if (nRemainingFeats)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_IMPROVED_CRITICAL_DAGGER, 1);
            nRemainingFeats--;
        }
        
    }
    else if (nPath == ADVENTURER_PATH_ROGUE5ASSASSIN7)
    {
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_ROGUE, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_ROGUE));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 14);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_ROGUE) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_ROGUE;
            if (nCurrentHD >= 6)
            {
                if (nCurrentHD == 6)
                {
                    NWNX_Creature_SetSkillRank(oCreature, SKILL_HIDE, 8);
                    NWNX_Creature_SetSkillRank(oCreature, SKILL_MOVE_SILENTLY, 8);
                }
                nClass = CLASS_TYPE_ASSASSIN;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 8);
        
        int nAbilityToIncrease = ABILITY_DEXTERITY;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_HIDE);
        AddAdventurerDesiredSkill(oCreature, SKILL_MOVE_SILENTLY);
        AddAdventurerDesiredSkill(oCreature, SKILL_TUMBLE);
        AddAdventurerDesiredSkill(oCreature, SKILL_OPEN_LOCK);
        AddAdventurerDesiredSkill(oCreature, SKILL_DISABLE_TRAP);
        AddAdventurerDesiredSkill(oCreature, SKILL_USE_MAGIC_DEVICE);
        
        if (nHD >= 6)
        {
            // Assassin entry
            nRemainingSkillpoints -= 16;
            NWNX_Creature_SetSkillRank(oCreature, SKILL_HIDE, 8);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_MOVE_SILENTLY, 8);
        }
        
    }
    else if (nPath == ADVENTURER_PATH_MONK5ASSASSIN7)
    {
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_MONK, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_MONK));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_MONK) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_MONK;
            if (nCurrentHD >= 6)
            {
                if (nCurrentHD == 6)
                {
                    NWNX_Creature_SetSkillRank(oCreature, SKILL_HIDE, 8);
                    NWNX_Creature_SetSkillRank(oCreature, SKILL_MOVE_SILENTLY, 8);
                }
                nClass = CLASS_TYPE_ASSASSIN;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 8);
        
        int nAbilityToIncrease = ABILITY_DEXTERITY;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_HIDE);
        AddAdventurerDesiredSkill(oCreature, SKILL_MOVE_SILENTLY);
        AddAdventurerDesiredSkill(oCreature, SKILL_TUMBLE);
        
        if (nHD >= 6)
        {
            // Assassin entry
            nRemainingSkillpoints -= 16;
            NWNX_Creature_SetSkillRank(oCreature, SKILL_HIDE, 8);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_MOVE_SILENTLY, 8);
        }
    }
    else if (nPath == ADVENTURER_PATH_RANGER5ASSASSIN7)
    {
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_RANGER, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_RANGER));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_RANGER) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_RANGER;
            if (nCurrentHD >= 6)
            {
                if (nCurrentHD == 6)
                {
                    NWNX_Creature_SetSkillRank(oCreature, SKILL_HIDE, 8);
                    NWNX_Creature_SetSkillRank(oCreature, SKILL_MOVE_SILENTLY, 8);
                }
                nClass = CLASS_TYPE_ASSASSIN;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 8);
        
        int nAbilityToIncrease = ABILITY_DEXTERITY;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_HIDE);
        AddAdventurerDesiredSkill(oCreature, SKILL_MOVE_SILENTLY);
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        
        
        if (nHD >= 6)
        {
            // Assassin entry
            nRemainingSkillpoints -= 16;
            NWNX_Creature_SetSkillRank(oCreature, SKILL_HIDE, 8);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_MOVE_SILENTLY, 8);
            AddAdventurerDesiredSkill(oCreature, SKILL_DISABLE_TRAP);
            AddAdventurerDesiredSkill(oCreature, SKILL_OPEN_LOCK);
            AddAdventurerDesiredSkill(oCreature, SKILL_USE_MAGIC_DEVICE);
        }
    }
    else if (nPath == ADVENTURER_PATH_RANGER9ASSASSIN3)
    {
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_RANGER, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_RANGER));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_RANGER) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_RANGER;
            if (nCurrentHD >= 10)
            {
                if (nCurrentHD == 10)
                {
                    NWNX_Creature_SetSkillRank(oCreature, SKILL_HIDE, 8);
                    NWNX_Creature_SetSkillRank(oCreature, SKILL_MOVE_SILENTLY, 8);
                }
                nClass = CLASS_TYPE_ASSASSIN;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 8);
        
        int nAbilityToIncrease = ABILITY_DEXTERITY;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_HIDE);
        AddAdventurerDesiredSkill(oCreature, SKILL_MOVE_SILENTLY);
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        
        if (nHD >= 10)
        {
            // Assassin entry
            nRemainingSkillpoints -= 16;
            NWNX_Creature_SetSkillRank(oCreature, SKILL_HIDE, 8);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_MOVE_SILENTLY, 8);
            AddAdventurerDesiredSkill(oCreature, SKILL_DISABLE_TRAP);
            AddAdventurerDesiredSkill(oCreature, SKILL_OPEN_LOCK);
            AddAdventurerDesiredSkill(oCreature, SKILL_USE_MAGIC_DEVICE);
        }
    }
    else if (nPath == ADVENTURER_PATH_FIGHTER7TORM5)
    {
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_FIGHTER, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_FIGHTER));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_FIGHTER) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_FIGHTER;
            if (nCurrentHD >= 8)
            {
                if (nCurrentHD == 8)
                {
                    NWNX_Creature_AddFeat(oCreature, FEAT_WEAPON_FOCUS_DAGGER);
                }
                nClass = CLASS_TYPE_DIVINECHAMPION;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 12);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 8);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 12);
        
        int nAbilityToIncrease = ABILITY_STRENGTH;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_TAUNT);
        AddAdventurerDesiredSkill(oCreature, SKILL_LISTEN);
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        if (nRemainingFeats)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_WEAPON_FOCUS_DAGGER, 1);
            nRemainingFeats--;
        }
    }
    else if (nPath == ADVENTURER_PATH_PALADIN7TORM5)
    {
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_PALADIN, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_PALADIN));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_PALADIN) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_PALADIN;
            if (nCurrentHD >= 8)
            {
                if (nCurrentHD == 8)
                {
                    NWNX_Creature_AddFeat(oCreature, FEAT_WEAPON_FOCUS_DAGGER);
                }
                nClass = CLASS_TYPE_DIVINECHAMPION;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 12);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 8);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 15);
        
        int nAbilityToIncrease = ABILITY_CHARISMA;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_CHARISMA;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_TAUNT);
        AddAdventurerDesiredSkill(oCreature, SKILL_LISTEN);
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        if (nRemainingFeats)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_WEAPON_FOCUS_DAGGER, 1);
            nRemainingFeats--;
        }
    }
    else if (nPath == ADVENTURER_PATH_BARBARIAN7TORM5)
    {
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_BARBARIAN, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_BARBARIAN));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 12);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_BARBARIAN) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_BARBARIAN;
            if (nCurrentHD >= 8)
            {
                if (nCurrentHD == 8)
                {
                    NWNX_Creature_AddFeat(oCreature, FEAT_WEAPON_FOCUS_DAGGER);
                }
                nClass = CLASS_TYPE_DIVINECHAMPION;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 12);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 8);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 8);
        
        int nAbilityToIncrease = ABILITY_STRENGTH;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_TAUNT);
        AddAdventurerDesiredSkill(oCreature, SKILL_LISTEN);
        AddAdventurerDesiredSkill(oCreature, SKILL_SPOT);
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        if (nRemainingFeats)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_WEAPON_FOCUS_DAGGER, 1);
            nRemainingFeats--;
        }
    }
    else if (nPath == ADVENTURER_PATH_ROGUE4FIGHTER4TORM4)
    {
        // 1st level rogue, then 4 fighter, then 3 rogue, then torm
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_ROGUE, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_ROGUE));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 12);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_ROGUE) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_ROGUE;
            if (nCurrentHD >= 2 && nCurrentHD <= 5)
            {
                nClass = CLASS_TYPE_FIGHTER;
            }
            if (nCurrentHD >= 9)
            {
                if (nCurrentHD == 9)
                {
                    NWNX_Creature_AddFeat(oCreature, FEAT_WEAPON_FOCUS_DAGGER);
                }
                nClass = CLASS_TYPE_DIVINECHAMPION;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 12);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 8);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 12);
        
        int nAbilityToIncrease = ABILITY_STRENGTH;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_TUMBLE);
        AddAdventurerDesiredSkill(oCreature, SKILL_OPEN_LOCK);
        AddAdventurerDesiredSkill(oCreature, SKILL_DISABLE_TRAP);
        AddAdventurerDesiredSkill(oCreature, SKILL_SPOT);
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        AddAdventurerDesiredSkill(oCreature, SKILL_USE_MAGIC_DEVICE);
        if (nRemainingFeats)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_WEAPON_FOCUS_DAGGER, 1);
            nRemainingFeats--;
        }
    }
    else if (nPath == ADVENTURER_PATH_ROGUE4PALADIN4TORM4)
    {
        // 1st level rogue, then 4 paladin, then 3 rogue, then torm
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_ROGUE, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_ROGUE));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 12);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_ROGUE) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_ROGUE;
            if (nCurrentHD >= 2 && nCurrentHD <= 5)
            {
                nClass = CLASS_TYPE_PALADIN;
            }
            if (nCurrentHD >= 9)
            {
                if (nCurrentHD == 9)
                {
                    NWNX_Creature_AddFeat(oCreature, FEAT_WEAPON_FOCUS_DAGGER);
                }
                nClass = CLASS_TYPE_DIVINECHAMPION;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 12);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 12);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 8);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 14);
        
        int nAbilityToIncrease = ABILITY_CHARISMA;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_CHARISMA;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_TUMBLE);
        AddAdventurerDesiredSkill(oCreature, SKILL_OPEN_LOCK);
        AddAdventurerDesiredSkill(oCreature, SKILL_DISABLE_TRAP);
        AddAdventurerDesiredSkill(oCreature, SKILL_SPOT);
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        AddAdventurerDesiredSkill(oCreature, SKILL_USE_MAGIC_DEVICE);
        if (nRemainingFeats)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_WEAPON_FOCUS_DAGGER, 1);
            nRemainingFeats--;
        }
    }
    else if (nPath == ADVENTURER_PATH_FIGHTER7DD5)
    {
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_FIGHTER, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_FIGHTER));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_FIGHTER) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_FIGHTER;
            if (nCurrentHD >= 8)
            {
                if (nCurrentHD == 8)
                {
                    NWNX_Creature_AddFeat(oCreature, FEAT_DODGE);
                    NWNX_Creature_AddFeat(oCreature, FEAT_TOUGHNESS);
                }
                nClass = CLASS_TYPE_DWARVEN_DEFENDER;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 8);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 10);
        
        int nAbilityToIncrease = ABILITY_STRENGTH;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        AddAdventurerDesiredSkill(oCreature, SKILL_LISTEN);
        AddAdventurerDesiredSkill(oCreature, SKILL_SPOT);
        if (nRemainingFeats)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_TOUGHNESS, 1);
            nRemainingFeats--;
        }
        if (nRemainingFeats)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_DODGE, 1);
            nRemainingFeats--;
        }
    }
    else if (nPath == ADVENTURER_PATH_PALADIN7DD5)
    {
        // 1st level rogue, then 4 paladin, then 3 rogue, then torm
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_PALADIN, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_PALADIN));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_PALADIN) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_PALADIN;
            if (nCurrentHD >= 8)
            {
                if (nCurrentHD == 8)
                {
                    NWNX_Creature_AddFeat(oCreature, FEAT_DODGE);
                    NWNX_Creature_AddFeat(oCreature, FEAT_TOUGHNESS);
                }
                nClass = CLASS_TYPE_DWARVEN_DEFENDER;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 8);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 14);
        
        int nAbilityToIncrease = ABILITY_STRENGTH;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        AddAdventurerDesiredSkill(oCreature, SKILL_TAUNT);
        if (nRemainingFeats)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_TOUGHNESS, 1);
            nRemainingFeats--;
        }
        if (nRemainingFeats)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_DODGE, 1);
            nRemainingFeats--;
        }
    }
    else if (nPath == ADVENTURER_PATH_ROGUE4FIGHTER4DD4)
    {
        // 1st level rogue, then 4 fighter, then 3 rogue, then DD
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_ROGUE, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_ROGUE));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_ROGUE) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_ROGUE;
            if (nCurrentHD >= 2 && nCurrentHD <= 5)
            {
                nClass = CLASS_TYPE_FIGHTER;
            }
            if (nCurrentHD >= 9)
            {
                if (nCurrentHD == 9)
                {
                    NWNX_Creature_AddFeat(oCreature, FEAT_DODGE);
                    NWNX_Creature_AddFeat(oCreature, FEAT_TOUGHNESS);
                }
                nClass = CLASS_TYPE_DWARVEN_DEFENDER;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 8);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 10);
        
        int nAbilityToIncrease = ABILITY_STRENGTH;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        AddAdventurerDesiredSkill(oCreature, SKILL_TUMBLE);
        AddAdventurerDesiredSkill(oCreature, SKILL_OPEN_LOCK);
        AddAdventurerDesiredSkill(oCreature, SKILL_DISABLE_TRAP);
        AddAdventurerDesiredSkill(oCreature, SKILL_SEARCH);
        AddAdventurerDesiredSkill(oCreature, SKILL_USE_MAGIC_DEVICE);
        if (nRemainingFeats)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_TOUGHNESS, 1);
            nRemainingFeats--;
        }
        if (nRemainingFeats)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_DODGE, 1);
            nRemainingFeats--;
        }
    }
    else if (nPath == ADVENTURER_PATH_PALADIN8HARPER4)
    {
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_PALADIN, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_PALADIN));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_PALADIN) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_PALADIN;
            if (nCurrentHD >= 9)
            {
                if (nCurrentHD == 9)
                {
                    NWNX_Creature_AddFeat(oCreature, FEAT_ALERTNESS);
                    NWNX_Creature_AddFeat(oCreature, FEAT_IRON_WILL);
                    NWNX_Creature_SetSkillRank(oCreature, SKILL_DISCIPLINE, 4); 
                    NWNX_Creature_SetSkillRank(oCreature, SKILL_LORE, 6);
                    NWNX_Creature_SetSkillRank(oCreature, SKILL_PERSUADE, 8); 
                    NWNX_Creature_SetSkillRank(oCreature, SKILL_SEARCH, 4); 
                }
                nClass = CLASS_TYPE_HARPER;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 8);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 14);
        
        int nAbilityToIncrease = ABILITY_STRENGTH;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        AddAdventurerDesiredSkill(oCreature, SKILL_TUMBLE);
        AddAdventurerDesiredSkill(oCreature, SKILL_LISTEN);
        if (nRemainingFeats)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_IRON_WILL, 1);
            nRemainingFeats--;
        }
        if (nRemainingFeats)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_ALERTNESS, 1);
            nRemainingFeats--;
        }
        if (nHD >= 9)
        {
            // Harper entry reqs
            nRemainingSkillpoints -= 26;
            NWNX_Creature_SetSkillRank(oCreature, SKILL_DISCIPLINE, 4); // 4
            NWNX_Creature_SetSkillRank(oCreature, SKILL_LORE, 6); // 6
            NWNX_Creature_SetSkillRank(oCreature, SKILL_PERSUADE, 8); // 8
            NWNX_Creature_SetSkillRank(oCreature, SKILL_SEARCH, 4); // 8
        }
    }
    else if (nPath == ADVENTURER_PATH_WIZARD3PM9)
    {
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_WIZARD, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_WIZARD));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 16);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_WIZARD) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_WIZARD;
            if (nCurrentHD >= 4)
            {
                nClass = CLASS_TYPE_PALE_MASTER;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 12);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 10);
        
        int nAbilityToIncrease = ABILITY_INTELLIGENCE;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_INTELLIGENCE;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_SPELLCRAFT);
        AddAdventurerDesiredSkill(oCreature, SKILL_CONCENTRATION);
        
        AddAdventurerSpellbookType(oCreature, CLASS_TYPE_WIZARD, RAND_SPELL_ARCANE_CONTROLLER);
        AddAdventurerSpellbookType(oCreature, CLASS_TYPE_WIZARD, RAND_SPELL_ARCANE_SINGLE_TARGET_BALANCED);
        bOverrideSpellbooks = 1;
    }
    else if (nPath == ADVENTURER_PATH_RANGER7PDK5)
    {
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_RANGER, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_RANGER));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_RANGER) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_RANGER;
            if (nCurrentHD >= 8)
            {
                NWNX_Creature_AddFeat(oCreature, FEAT_MOUNTED_COMBAT);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_INTIMIDATE, 1);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_LISTEN, 2);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_PERSUADE, 1);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_RIDE, 2);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_SPOT, 2);
                nClass = CLASS_TYPE_PURPLE_DRAGON_KNIGHT;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 12);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 12);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 12);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 10);
        
        int nAbilityToIncrease = ABILITY_DEXTERITY;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        AddAdventurerDesiredSkill(oCreature, SKILL_HIDE);
        AddAdventurerDesiredSkill(oCreature, SKILL_MOVE_SILENTLY);
        
        if (nHD >= 8)
        {
            // PDK entry reqs
            nRemainingSkillpoints -= 11;
            NWNX_Creature_SetSkillRank(oCreature, SKILL_INTIMIDATE, 1);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_LISTEN, 2);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_PERSUADE, 1);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_RIDE, 2);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_SPOT, 2);
        }
        if (nHD >= 6)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_MOUNTED_COMBAT, 4);
            nRemainingFeats--;
        }
    }
    else if (nPath == ADVENTURER_PATH_FIGHTER4PDK5PALADIN3)
    {
        // Fighter 1 - bonus feat!
        // Paladin 1 - CHA to saves!
        // Fighter 2-4 - bonus feats!
        // Paladin 2-3 - umm paladin stuff
        // PDK
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_FIGHTER, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_FIGHTER));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_FIGHTER) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_FIGHTER;
            if (nCurrentHD == 2 || nCurrentHD == 7 || nCurrentHD == 6)
            {
                nClass = CLASS_TYPE_PALADIN;
            }
            if (nCurrentHD >= 8)
            {
                NWNX_Creature_AddFeat(oCreature, FEAT_MOUNTED_COMBAT);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_INTIMIDATE, 1);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_LISTEN, 2);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_PERSUADE, 1);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_RIDE, 2);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_SPOT, 2);
                nClass = CLASS_TYPE_PURPLE_DRAGON_KNIGHT;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 12);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 12);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 14);
        
        int nAbilityToIncrease = ABILITY_STRENGTH;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        AddAdventurerDesiredSkill(oCreature, SKILL_TAUNT);
        
        if (nHD >= 8)
        {
            // PDK entry reqs
            nRemainingSkillpoints -= 11;
            NWNX_Creature_SetSkillRank(oCreature, SKILL_INTIMIDATE, 1);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_LISTEN, 2);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_PERSUADE, 1);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_RIDE, 2);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_SPOT, 2);
        }
        if (nHD >= 6)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_MOUNTED_COMBAT, 4);
            nRemainingFeats--;
        }
    }
    else if (nPath == ADVENTURER_PATH_MONK8PDK4)
    {
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_MONK, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_MONK));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_MONK) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_MONK;
            
            if (nCurrentHD >= 9)
            {
                NWNX_Creature_AddFeat(oCreature, FEAT_MOUNTED_COMBAT);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_INTIMIDATE, 1);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_LISTEN, 2);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_PERSUADE, 1);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_RIDE, 2);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_SPOT, 2);
                nClass = CLASS_TYPE_PURPLE_DRAGON_KNIGHT;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 10);
        
        int nAbilityToIncrease = ABILITY_STRENGTH;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_TUMBLE);
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        
        if (nHD >= 8)
        {
            // PDK entry reqs
            nRemainingSkillpoints -= 11;
            NWNX_Creature_SetSkillRank(oCreature, SKILL_INTIMIDATE, 1);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_LISTEN, 2);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_PERSUADE, 1);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_RIDE, 2);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_SPOT, 2);
        }
        if (nHD >= 6)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_MOUNTED_COMBAT, 4);
            nRemainingFeats--;
        }
    }
    else if (nPath == ADVENTURER_PATH_PALADIN4PDK5TORM3)
    {
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_PALADIN, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_PALADIN));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_PALADIN) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_PALADIN;
            if ((nCurrentHD >= 5 && nCurrentHD <= 7) || nCurrentHD >= 11)
            {
                NWNX_Creature_AddFeat(oCreature, FEAT_MOUNTED_COMBAT);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_INTIMIDATE, 1);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_LISTEN, 2);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_PERSUADE, 1);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_RIDE, 2);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_SPOT, 2);
                nClass = CLASS_TYPE_PURPLE_DRAGON_KNIGHT;
            }
            if (nCurrentHD >= 8 && nCurrentHD <= 10)
            {
                NWNX_Creature_AddFeat(oCreature, FEAT_WEAPON_FOCUS_DAGGER);
                nClass = CLASS_TYPE_DIVINECHAMPION;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 12);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 12);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 14);
        
        int nAbilityToIncrease = ABILITY_STRENGTH;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        AddAdventurerDesiredSkill(oCreature, SKILL_TAUNT);
        
        if (nHD >= 8)
        {
            // PDK entry reqs
            nRemainingSkillpoints -= 11;
            NWNX_Creature_SetSkillRank(oCreature, SKILL_INTIMIDATE, 1);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_LISTEN, 2);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_PERSUADE, 1);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_RIDE, 2);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_SPOT, 2);
        }
        if (nHD >= 3)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_MOUNTED_COMBAT, 3);
            nRemainingFeats--;
        }
        if (nHD >= 6)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_WEAPON_FOCUS_DAGGER, 6);
            nRemainingFeats--;
        }
    }
    else if (nPath == ADVENTURER_PATH_BARBARIAN7PDK5)
    {
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_BARBARIAN, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_BARBARIAN));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_BARBARIAN) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_BARBARIAN;
            
            if (nCurrentHD >= 8)
            {
                NWNX_Creature_AddFeat(oCreature, FEAT_MOUNTED_COMBAT);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_INTIMIDATE, 1);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_LISTEN, 2);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_PERSUADE, 1);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_RIDE, 2);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_SPOT, 2);
                nClass = CLASS_TYPE_PURPLE_DRAGON_KNIGHT;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 10);
        
        int nAbilityToIncrease = ABILITY_STRENGTH;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_TAUNT);
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        
        if (nHD >= 8)
        {
            // PDK entry reqs
            nRemainingSkillpoints -= 11;
            NWNX_Creature_SetSkillRank(oCreature, SKILL_INTIMIDATE, 1);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_LISTEN, 2);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_PERSUADE, 1);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_RIDE, 2);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_SPOT, 2);
        }
        if (nHD >= 6)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_MOUNTED_COMBAT, 4);
            nRemainingFeats--;
        }
    }
    else if (nPath == ADVENTURER_PATH_FIGHTER4PDK5ROGUE3)
    {
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_ROGUE, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_ROGUE));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_ROGUE) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_ROGUE;
            if (nCurrentHD >= 2 && nCurrentHD <= 5)
            {
                nClass = CLASS_TYPE_FIGHTER;
            }
            
            if (nCurrentHD >= 8)
            {
                NWNX_Creature_AddFeat(oCreature, FEAT_MOUNTED_COMBAT);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_INTIMIDATE, 1);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_LISTEN, 2);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_PERSUADE, 1);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_RIDE, 2);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_SPOT, 2);
                nClass = CLASS_TYPE_PURPLE_DRAGON_KNIGHT;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 10);
        
        int nAbilityToIncrease = ABILITY_STRENGTH;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_TUMBLE);
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        AddAdventurerDesiredSkill(oCreature, SKILL_OPEN_LOCK);
        AddAdventurerDesiredSkill(oCreature, SKILL_DISABLE_TRAP);
        AddAdventurerDesiredSkill(oCreature, SKILL_USE_MAGIC_DEVICE);
        
        if (nHD >= 8)
        {
            // PDK entry reqs
            nRemainingSkillpoints -= 11;
            NWNX_Creature_SetSkillRank(oCreature, SKILL_INTIMIDATE, 1);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_LISTEN, 2);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_PERSUADE, 1);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_RIDE, 2);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_SPOT, 2);
        }
        if (nHD >= 6)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_MOUNTED_COMBAT, 4);
            nRemainingFeats--;
        }
    }
    else if (nPath == ADVENTURER_PATH_BARD7PDK5)
    {
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_BARD, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_BARD));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_BARD) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_BARD;
            
            if (nCurrentHD >= 8)
            {
                NWNX_Creature_AddFeat(oCreature, FEAT_MOUNTED_COMBAT);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_INTIMIDATE, 1);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_LISTEN, 2);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_PERSUADE, 1);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_RIDE, 2);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_SPOT, 2);
                nClass = CLASS_TYPE_PURPLE_DRAGON_KNIGHT;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 14);
        
        int nAbilityToIncrease = ABILITY_STRENGTH;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_TUMBLE);
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        AddAdventurerDesiredSkill(oCreature, SKILL_PERFORM);
        AddAdventurerDesiredSkill(oCreature, SKILL_USE_MAGIC_DEVICE);
        
        if (nHD >= 8)
        {
            // PDK entry reqs
            nRemainingSkillpoints -= 11;
            NWNX_Creature_SetSkillRank(oCreature, SKILL_INTIMIDATE, 1);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_LISTEN, 2);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_PERSUADE, 1);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_RIDE, 2);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_SPOT, 2);
        }
        if (nHD >= 6)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_MOUNTED_COMBAT, 6);
            nRemainingFeats--;
        }
    }
    else if (nPath == ADVENTURER_PATH_FIGHTER6ROGUE3SHADOWDANCER3)
    {
        // 1 rogue
        // 1 rogue, 4 fighter
        // 3 rogue, 4 fighter
        // 3 rogue, 4 fighter, 3 shadowdancer
        // 3 rogue, 6 fighter, 3 shadowdancer
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_ROGUE, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_ROGUE));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_ROGUE) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_ROGUE;
            if ((nCurrentHD >= 2 && nCurrentHD <= 5) || nCurrentHD >= 11)
            {
                nClass = CLASS_TYPE_FIGHTER;
            }
            if (nCurrentHD == 8 || nCurrentHD == 9 || nCurrentHD == 10)
            {
                NWNX_Creature_AddFeat(oCreature, FEAT_DODGE);
                NWNX_Creature_AddFeat(oCreature, FEAT_MOBILITY);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_HIDE, 10);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_MOVE_SILENTLY, 8);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_TUMBLE, 5);
                nClass = CLASS_TYPE_SHADOWDANCER;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 10);
        
        int nAbilityToIncrease = ABILITY_STRENGTH;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_TUMBLE);
        AddAdventurerDesiredSkill(oCreature, SKILL_HIDE);
        AddAdventurerDesiredSkill(oCreature, SKILL_MOVE_SILENTLY);
        AddAdventurerDesiredSkill(oCreature, SKILL_OPEN_LOCK);
        AddAdventurerDesiredSkill(oCreature, SKILL_USE_MAGIC_DEVICE);
        
        if (nHD >= 8)
        {
            // Shadowdancer entry reqs
            nRemainingSkillpoints -= 23;
            NWNX_Creature_SetSkillRank(oCreature, SKILL_HIDE, 10);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_MOVE_SILENTLY, 8);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_TUMBLE, 5);
        }
        if (nHD >= 3)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_DODGE, 3);
            nRemainingFeats--;
        }
        if (nHD >= 6)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_MOBILITY, 6);
            nRemainingFeats--;
        }
    }
    else if (nPath == ADVENTURER_PATH_RANGER8ROGUE3SHADOWDANCER1)
    {
        // 1 rogue
        // 1 rogue, 4 ranger
        // 3 rogue, 4 ranger
        // 3 rogue, 4 ranger, 1 shadowdancer
        // 3 rogue, 8 ranger, 1 shadowdancer
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_ROGUE, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_ROGUE));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_ROGUE) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_ROGUE;
            if ((nCurrentHD >= 2 && nCurrentHD <= 5) || nCurrentHD >= 9)
            {
                nClass = CLASS_TYPE_RANGER;
            }
            if (nCurrentHD == 8)
            {
                NWNX_Creature_AddFeat(oCreature, FEAT_DODGE);
                NWNX_Creature_AddFeat(oCreature, FEAT_MOBILITY);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_HIDE, 10);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_MOVE_SILENTLY, 8);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_TUMBLE, 5);
                nClass = CLASS_TYPE_SHADOWDANCER;
            }
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 10);
        
        int nAbilityToIncrease = ABILITY_DEXTERITY;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_TUMBLE);
        AddAdventurerDesiredSkill(oCreature, SKILL_HIDE);
        AddAdventurerDesiredSkill(oCreature, SKILL_MOVE_SILENTLY);
        AddAdventurerDesiredSkill(oCreature, SKILL_OPEN_LOCK);
        AddAdventurerDesiredSkill(oCreature, SKILL_USE_MAGIC_DEVICE);
        
        if (nHD >= 8)
        {
            // Shadowdancer entry reqs
            nRemainingSkillpoints -= 23;
            NWNX_Creature_SetSkillRank(oCreature, SKILL_HIDE, 10);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_MOVE_SILENTLY, 8);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_TUMBLE, 5);
        }
        if (nHD >= 3)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_DODGE, 3);
            nRemainingFeats--;
        }
        if (nHD >= 6)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_MOBILITY, 6);
            nRemainingFeats--;
        }
    }
    else if (nPath == ADVENTURER_PATH_ROGUE5ASSASSIN5SHADOWDANCER2)
    {
        // 5 rogue
        // 5 rogue 3 assassin
        // 5 rogue 3 assassin 2 shadowdancer
        // 5 rogue 5 assassin 2 shadowdancer
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_ROGUE, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_ROGUE));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_ROGUE) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_ROGUE;
            if ((nCurrentHD >= 6 && nCurrentHD <= 8) || nCurrentHD >= 11)
            {
                NWNX_Creature_SetSkillRank(oCreature, SKILL_HIDE, 8);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_MOVE_SILENTLY, 8);
                nClass = CLASS_TYPE_ASSASSIN;
            }
            if (nCurrentHD == 9 || nCurrentHD == 10)
            {
                NWNX_Creature_AddFeat(oCreature, FEAT_DODGE);
                NWNX_Creature_AddFeat(oCreature, FEAT_MOBILITY);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_HIDE, 10);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_MOVE_SILENTLY, 8);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_TUMBLE, 5);
                nClass = CLASS_TYPE_SHADOWDANCER;
            }            

            
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 10);
        
        int nAbilityToIncrease = ABILITY_STRENGTH;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_TUMBLE);
        AddAdventurerDesiredSkill(oCreature, SKILL_HIDE);
        AddAdventurerDesiredSkill(oCreature, SKILL_MOVE_SILENTLY);
        AddAdventurerDesiredSkill(oCreature, SKILL_OPEN_LOCK);
        AddAdventurerDesiredSkill(oCreature, SKILL_DISABLE_TRAP);
        AddAdventurerDesiredSkill(oCreature, SKILL_USE_MAGIC_DEVICE);
        
        if (nHD >= 6)
        {
            // Assassin entry
            nRemainingSkillpoints -= 16;
            NWNX_Creature_SetSkillRank(oCreature, SKILL_HIDE, 8);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_MOVE_SILENTLY, 8);
        }
        
        if (nHD >= 9)
        {
            // Shadowdancer entry reqs
            nRemainingSkillpoints -= 23;
            NWNX_Creature_SetSkillRank(oCreature, SKILL_HIDE, 10);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_MOVE_SILENTLY, 8);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_TUMBLE, 5);
        }
        if (nHD >= 3)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_DODGE, 3);
            nRemainingFeats--;
        }
        if (nHD >= 6)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_MOBILITY, 6);
            nRemainingFeats--;
        }
    }
    else if (nPath == ADVENTURER_PATH_MONK5ASSASSIN5SHADOWDANCER2)
    {
        // 5 monk
        // 5 monk 3 assassin
        // 5 monk 3 assassin 2 shadowdancer
        // 5 monk 5 assassin 2 shadowdancer
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_MONK, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_MONK));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_MONK) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_MONK;
            if ((nCurrentHD >= 6 && nCurrentHD <= 8) || nCurrentHD >= 11)
            {
                NWNX_Creature_SetSkillRank(oCreature, SKILL_HIDE, 8);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_MOVE_SILENTLY, 8);
                nClass = CLASS_TYPE_ASSASSIN;
            }
            if (nCurrentHD == 9 || nCurrentHD == 10)
            {
                NWNX_Creature_AddFeat(oCreature, FEAT_DODGE);
                NWNX_Creature_AddFeat(oCreature, FEAT_MOBILITY);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_HIDE, 10);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_MOVE_SILENTLY, 8);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_TUMBLE, 5);
                nClass = CLASS_TYPE_SHADOWDANCER;
            }            

            
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 10);
        
        int nAbilityToIncrease = ABILITY_DEXTERITY;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_TUMBLE);
        AddAdventurerDesiredSkill(oCreature, SKILL_HIDE);
        AddAdventurerDesiredSkill(oCreature, SKILL_MOVE_SILENTLY);
        
        if (nHD >= 6)
        {
            // Assassin entry
            nRemainingSkillpoints -= 16;
            NWNX_Creature_SetSkillRank(oCreature, SKILL_HIDE, 8);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_MOVE_SILENTLY, 8);
            AddAdventurerDesiredSkill(oCreature, SKILL_DISABLE_TRAP);
            AddAdventurerDesiredSkill(oCreature, SKILL_OPEN_LOCK);
            AddAdventurerDesiredSkill(oCreature, SKILL_USE_MAGIC_DEVICE);
        }
        
        if (nHD >= 9)
        {
            // Shadowdancer entry reqs
            nRemainingSkillpoints -= 23;
            NWNX_Creature_SetSkillRank(oCreature, SKILL_HIDE, 10);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_MOVE_SILENTLY, 8);
            NWNX_Creature_SetSkillRank(oCreature, SKILL_TUMBLE, 5);
        }
        if (nHD >= 3)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_DODGE, 3);
            nRemainingFeats--;
        }
        if (nHD >= 6)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_MOBILITY, 6);
            nRemainingFeats--;
        }
    }
    else if (nPath == ADVENTURER_PATH_FIGHTER7WM5)
    {
        // 1: weapon focus, dodge
        // 2: mobility
        // 3: expertise
        // 4: spring attack
        // 6: whirlwind attack
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_FIGHTER, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_FIGHTER));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 13);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_FIGHTER) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_FIGHTER;
            if (nCurrentHD >= 7 && nCurrentHD <= 11)
            {
                NWNX_Creature_AddFeat(oCreature, FEAT_DODGE);
                NWNX_Creature_AddFeat(oCreature, FEAT_MOBILITY);
                NWNX_Creature_AddFeat(oCreature, FEAT_SPRING_ATTACK);
                NWNX_Creature_AddFeat(oCreature, FEAT_EXPERTISE);
                NWNX_Creature_AddFeat(oCreature, FEAT_WHIRLWIND_ATTACK);
                NWNX_Creature_AddFeat(oCreature, FEAT_WEAPON_FOCUS_DAGGER);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_INTIMIDATE, 4);
                nClass = CLASS_TYPE_WEAPON_MASTER;
            }            

            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 13);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 11);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 10);
        
        int nAbilityToIncrease = ABILITY_STRENGTH;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        AddAdventurerDesiredSkill(oCreature, SKILL_LISTEN);
        
        
        if (nHD >= 6)
        {
            // WM entry reqs
            nRemainingSkillpoints -= 4;
            NWNX_Creature_SetSkillRank(oCreature, SKILL_INTIMIDATE, 4);
        }
        if (nHD >= 1)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_WEAPON_FOCUS_DAGGER, 1);
            nUsedFighterBonusFeats++;
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_DODGE, 1);
            nRemainingFeats--;
        }
        if (nHD >= 2)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_MOBILITY, 2);
            nUsedFighterBonusFeats++;
        }
        if (nHD >= 3)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_EXPERTISE, 3);
            nRemainingFeats--;
        }
        if (nHD >= 4)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_SPRING_ATTACK, 4);
            nUsedFighterBonusFeats++;
        }
        if (nHD >= 6)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_WHIRLWIND_ATTACK, 6);
            nUsedFighterBonusFeats++;
        }
        // inc_rand_feat handles weapon of choice feat
    }
    else if (nPath == ADVENTURER_PATH_FIGHTER6RANGER1WM5)
    {
        // 1: weapon focus, dodge
        // 2: mobility
        // 3: expertise
        // 4: spring attack
        // 6: whirlwind attack
        // Take ranger at level 5
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_FIGHTER, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_FIGHTER));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 13);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_FIGHTER) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_FIGHTER;
            if (nCurrentHD == 5)
            {
                nClass = CLASS_TYPE_RANGER;
            }
            if (nCurrentHD >= 7 && nCurrentHD <= 11)
            {
                NWNX_Creature_AddFeat(oCreature, FEAT_DODGE);
                NWNX_Creature_AddFeat(oCreature, FEAT_MOBILITY);
                NWNX_Creature_AddFeat(oCreature, FEAT_SPRING_ATTACK);
                NWNX_Creature_AddFeat(oCreature, FEAT_EXPERTISE);
                NWNX_Creature_AddFeat(oCreature, FEAT_WHIRLWIND_ATTACK);
                NWNX_Creature_AddFeat(oCreature, FEAT_WEAPON_FOCUS_DAGGER);
                NWNX_Creature_SetSkillRank(oCreature, SKILL_INTIMIDATE, 4);
                nClass = CLASS_TYPE_WEAPON_MASTER;
            }            

            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 13);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 11);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 10);
        
        int nAbilityToIncrease = ABILITY_DEXTERITY;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
        AddAdventurerDesiredSkill(oCreature, SKILL_LISTEN);
        
        if (nHD >= 6)
        {
            // WM entry reqs
            nRemainingSkillpoints -= 4;
            NWNX_Creature_SetSkillRank(oCreature, SKILL_INTIMIDATE, 4);
        }
        if (nHD >= 1)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_WEAPON_FOCUS_DAGGER, 1);
            nUsedFighterBonusFeats++;
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_DODGE, 1);
            nRemainingFeats--;
        }
        if (nHD >= 2)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_MOBILITY, 2);
            nUsedFighterBonusFeats++;
        }
        if (nHD >= 3)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_EXPERTISE, 3);
            nRemainingFeats--;
        }
        if (nHD >= 4)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_SPRING_ATTACK, 4);
            nUsedFighterBonusFeats++;
        }
        if (nHD >= 6)
        {
            NWNX_Creature_AddFeatByLevel(oCreature, FEAT_WHIRLWIND_ATTACK, 6);
            nRemainingFeats++;
        }
        // inc_rand_feat handles weapon of choice feat
    }
    else if (nPath == ADVENTURER_PATH_RANGER11MONK1)
    {
        // The gimmick here is that this invariably turns into a kama dual wielder with monk UBAB progression
        NWNX_Creature_SetClassByPosition(oCreature, 0, CLASS_TYPE_MONK, TRUE);
        NWNX_Creature_SetMaxHitPointsByLevel(oCreature, 1, _GetHitDieForClass(CLASS_TYPE_MONK));
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        nRemainingSkillpoints = (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(CLASS_TYPE_MONK) + bIsHuman) * 4;
        for (nCurrentHD=2; nCurrentHD<=nHD; nCurrentHD++)
        {
            int nClass = CLASS_TYPE_RANGER;
            
            NWNX_Creature_LevelUp(oCreature, nClass, 1);
            NWNX_Creature_SetMaxHitPointsByLevel(oCreature, nCurrentHD, nCurrentHD * _GetHitDieForClass(nClass));
            nRemainingSkillpoints += (GetAbilityModifier(ABILITY_INTELLIGENCE, oCreature) + _GetSkillpointsPerLevelInClass(nClass) + bIsHuman);
        }
        
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_STRENGTH, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_DEXTERITY, 16);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CONSTITUTION, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_INTELLIGENCE, 10);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_WISDOM, 14);
        NWNX_Creature_SetRawAbilityScore(oCreature, ABILITY_CHARISMA, 10);
        bFinesseAdjust = 1;
        
        int nAbilityToIncrease = ABILITY_STRENGTH;
        if (bFinesseAdjust)
        {
            SetAdventurerMaxArmorAC(oCreature, 4);
            AdventurerFinesseAdjustAbilities(oCreature, 10);
            nAbilityToIncrease = ABILITY_DEXTERITY;
        }
        int nAbilityIncreases = (nHD / 4);
        NWNX_Creature_SetRawAbilityScore(oCreature, nAbilityToIncrease, NWNX_Creature_GetRawAbilityScore(oCreature, nAbilityToIncrease) + nAbilityIncreases);
        
        AdventurerResetFeats(oCreature);
        AdventurerResetSkills(oCreature);
        
        AddAdventurerDesiredSkill(oCreature, SKILL_TUMBLE);
        AddAdventurerDesiredSkill(oCreature, SKILL_DISCIPLINE);
    }
    // End of all the path handling...
    
    // Decide on range vs melee
    
    // If you've built strength, why are you getting a ranged weapon?
    int nDexMod = GetAbilityModifier(ABILITY_DEXTERITY, oCreature);
    int nWisMod = GetAbilityModifier(ABILITY_WISDOM, oCreature);
    int nStrMod = GetAbilityModifier(ABILITY_STRENGTH, oCreature);
    
    int bNoRange = 0;
    
    if (nStrMod > nDexMod && nStrMod > nWisMod)
    {
        bNoRange = 1;
    }
    
    if (GetLevelByClass(CLASS_TYPE_ARCANE_ARCHER, oCreature) > 0)
    {
        bNoRange = 0;
    }
    
    //SendDebugMessage("Dex: " + IntToString(nDexMod) + ", Wis: " + IntToString(nWisMod) + ", Str: " + IntToString(nStrMod) + ", melee only: " + IntToString(bNoRange));
  
    if (!bNoRange)
    {
        if (Random(100) < 25 || GetLevelByClass(CLASS_TYPE_ARCANE_ARCHER, oCreature) > 0)
        {
            if (GetLevelByClass(CLASS_TYPE_WEAPON_MASTER, oCreature) <= 0)
            {
                SetLocalInt(oCreature, RAND_EQUIP_GIVE_RANGED, 1);
            }
        }
    }
    
            
    int nNumFighterBonusFeats = 0;
    int nFighter = GetLevelByClass(CLASS_TYPE_FIGHTER, oCreature);
    if (nFighter > 0)
    {
        nNumFighterBonusFeats = 1 + (nFighter/2);
    }
    int nNumRogueBonusFeats = 0;
    if (GetLevelByClass(CLASS_TYPE_ROGUE, oCreature) >= 10)
    {
        nNumRogueBonusFeats++;
    }
    if (nNumFighterBonusFeats - nUsedFighterBonusFeats > 0)
    {
        AddRandomFeats(oCreature, RAND_FEAT_LIST_FIGHTER_BONUS, nNumFighterBonusFeats - nUsedFighterBonusFeats);
    }
    if (nNumRogueBonusFeats - nUsedRogueBonusFeats > 0)
    {
        AddRandomFeats(oCreature, RAND_FEAT_LIST_ROGUE_BONUS, nNumFighterBonusFeats - nUsedFighterBonusFeats);
    }
    // Why is there TMI :(
    //WriteTimestampedLogEntry("feat");
    AddRandomFeats(oCreature, RAND_FEAT_LIST_RANDOM, nRemainingFeats);
    //WriteTimestampedLogEntry("skills");
    AddRandomAdventurerSkills(oCreature, nRemainingSkillpoints);
    //WriteTimestampedLogEntry("gender/appearance/soundset");
    RandomiseGenderAndAppearance(oCreature);
    RandomiseCreatureSoundset_Average(oCreature);
    
    if (GetLevelByClass(CLASS_TYPE_DRUID, oCreature) || (GetLevelByClass(CLASS_TYPE_RANGER, oCreature) > 6))
    {
        NWNX_Creature_SetAnimalCompanionCreatureType(oCreature, Random(9));
    }
    if (GetLevelByClass(CLASS_TYPE_WIZARD, oCreature) || GetLevelByClass(CLASS_TYPE_SORCERER, oCreature))
    {
        NWNX_Creature_SetFamiliarCreatureType(oCreature, Random(11));
    }
    if (GetLevelByClass(CLASS_TYPE_RANGER, oCreature) > 0)
    {
        int nNumFavoredEnemies = 1 + (GetLevelByClass(CLASS_TYPE_RANGER, oCreature))/5;
        AssignCommand(GetModule(), DelayCommand(6.0, AddRandomFeats(oCreature, RAND_FEAT_LIST_FAVORED_ENEMY, nNumFavoredEnemies)));
    }
    if (!bOverrideSpellbooks)
    {
        for (i=1; i<=3; i++)
        {
            int nClass = GetClassByPosition(i, oCreature);
            int nClassLevel = GetLevelByClass(nClass, oCreature);
        
            if (nClass == CLASS_TYPE_CLERIC || nClass == CLASS_TYPE_DRUID)
            {
                AddAdventurerSpellbookType(oCreature, nClass, RAND_SPELL_DIVINE_EVOKER);
                AddAdventurerSpellbookType(oCreature, nClass, RAND_SPELL_DIVINE_BUFF_ATTACKS);
                AddAdventurerSpellbookType(oCreature, nClass, RAND_SPELL_DIVINE_CONTROLLER);
                if (nClass == CLASS_TYPE_CLERIC)
                {
                    AddAdventurerSpellbookType(oCreature, nClass, RAND_SPELL_DIVINE_HEALER);
                }
            }
            else if (nClass == CLASS_TYPE_WIZARD || nClass == CLASS_TYPE_SORCERER)
            {
                AddAdventurerSpellbookType(oCreature, nClass, RAND_SPELL_ARCANE_EVOKER_SINGLE_TARGET);
                AddAdventurerSpellbookType(oCreature, nClass, RAND_SPELL_ARCANE_EVOKER_AOE);
                AddAdventurerSpellbookType(oCreature, nClass, RAND_SPELL_ARCANE_SINGLE_TARGET_BALANCED);
                AddAdventurerSpellbookType(oCreature, nClass, RAND_SPELL_ARCANE_CONTROLLER);
            }
            else if (nClass == CLASS_TYPE_PALADIN && nClassLevel >= 4)
            {
                AddAdventurerSpellbookType(oCreature, nClass, RAND_SPELL_DIVINE_PALADIN);
            }
            else if (nClass == CLASS_TYPE_RANGER && nClassLevel >= 4)
            {
                AddAdventurerSpellbookType(oCreature, nClass, RAND_SPELL_DIVINE_RANGER);
            }
            else if (nClass == CLASS_TYPE_BARD)
            {
                AddAdventurerSpellbookType(oCreature, nClass, RAND_SPELL_ARCANE_BARD);
            }
        }
    }
    //WriteTimestampedLogEntry("spellbook prep");
    // Load or seed a spellbook
    int bStartedSeeding = 0;
    for (i=1; i<=3; i++)
    {
        int bSpellbook = 0;
        int nClass = GetClassByPosition(i, oCreature);
        int nClassLevel = GetLevelByClass(nClass, oCreature);
    
        if (nClass == CLASS_TYPE_CLERIC || nClass == CLASS_TYPE_DRUID)
        {
            bSpellbook = 1;
        }
        else if (nClass == CLASS_TYPE_WIZARD || nClass == CLASS_TYPE_SORCERER)
        {
             bSpellbook = 1;
        }
        else if (nClass == CLASS_TYPE_PALADIN && nClassLevel >= 4)
        {
             bSpellbook = 1;
        }
        else if (nClass == CLASS_TYPE_RANGER && nClassLevel >= 4)
        {
            bSpellbook = 1;
        }
        else if (nClass == CLASS_TYPE_BARD)
        {
            bSpellbook = 1;
        }
        
        
        // Saved as:
        // "adventurer_num_spellbooks_" + sClass - number of categories
        // "adventurer_spellbook_" + sClass + "_" + IntToString(nIndex) - RAND_SPELL_* constant for this spellbook type        
        // nIndex starts from zero
        if (bSpellbook)
        {
            string sResRefOverride = "adventurer" + IntToString(nPath) + "_" + IntToString(nHD);
            string sClass = IntToString(nClass);
            int nNumCategories = GetLocalInt(oCreature, "adventurer_num_spellbooks_" + sClass);
            if (SeedingSpellbooks(nClass, oCreature, sResRefOverride))
            {
                bStartedSeeding = 1;
                int nIndex;
                for (nIndex=0; nIndex<nNumCategories; nIndex++)
                {
                    int nCategory = GetLocalInt(oCreature, "adventurer_spellbook_" + sClass + "_" + IntToString(nIndex));
                    // Seeding the full number of spellbooks takes over an hour and a half for the adventurers alone
                    // 4 per path/level combo seems like enough
                    for (i=0; i<RAND_SPELL_NUM_SPELLBOOKS/5; i++)
                    {
                         RandomSpellbookPopulate(nCategory, oCreature, nClass, sResRefOverride);
                    }
                }
                
            }
            else
            {
                // For some reason doing this without a delay fails to load spells above level 2
                // ... but inc_rand_spell should be able to deal with this and keep trying until it works
                AssignCommand(GetModule(), LoadSpellbook(nClass, oCreature, -1, sResRefOverride));
            }
        }
        
    }
     
    if (bStartedSeeding)
    {
        SeedingSpellbooksComplete(oCreature);
    }
    else
    {
        // The spellbook seeder needs to know this.
        SetLocalInt(oCreature, "noncaster", 1);
    }
    
    //WriteTimestampedLogEntry("Advanced adventurer " + GetAdventurerTrueName(oCreature) + " along path " + IntToString(nPath) + ", hd=" + (IntToString(nHD)));
}

int GetRandomItemTierFromAdventurerHD(int nHD)
{
    if (nHD == 1) { return 1; }
    else if (nHD == 2)
    {
        if (d10() == 1) { return 2; }
        return 1;
    }
    else if (nHD == 3)
    {
        if (d6() == 1) { return 2; }
        return 1;
    }
    else if (nHD == 4)
    {
        int nRoll = d10();
        if (nRoll <= 3) { return 1; }
        else if (nRoll <= 10) { return 2; }
    }
    else if (nHD == 5)
    {
        int nRoll = d10();
        if (nRoll <= 2) { return 1; }
        else if (nRoll <= 9) { return 2; }
        return 3;
    }
    else if (nHD == 6)
    {
        int nRoll = d10();
        if (nRoll <= 1) { return 1; }
        else if (nRoll <= 8) { return 2; }
        return 3;
    }
    else if (nHD == 7)
    {
        int nRoll = d10();
        if (nRoll <= 1) { return 1; }
        else if (nRoll <= 6) { return 2; }
        return 3;
    }
    else if (nHD == 8)
    {
        int nRoll = d10();
        if (nRoll <= 1) { return 1; }
        else if (nRoll <= 4) { return 2; }
        else if (nRoll <= 9) { return 3; }
        return 4;
    }
    else if (nHD == 9)
    {
        int nRoll = d10();
        if (nRoll <= 3) { return 2; }
        else if (nRoll <= 8) { return 3; }
        return 4;
    }
    else if (nHD == 10)
    {
        int nRoll = d10();
        if (nRoll <= 2) { return 2; }
        else if (nRoll <= 6) { return 3; }
        else if (nRoll <= 9) { return 4; }
        return 5;
    }
    else if (nHD == 11)
    {
        int nRoll = d10();
        if (nRoll <= 1) { return 2; }
        else if (nRoll <= 5) { return 3; }
        else if (nRoll <= 8) { return 4; }
        return 5;
    }
    else if (nHD >= 12)
    {
        int nRoll = d10();
        if (nRoll <= 4) { return 3; }
        else if (nRoll <= 7) { return 4; }
        return 5;
    }
    // should never be reached
    return 1;
}

void EquipAdventurer(object oAdventurer)
{
    int nHD = GetHitDice(oAdventurer);
    int nMaxAC = 8;
    int nChanceToFillApparel = 100;
    int nUniqueChance = 15;
    
    // Don't give full plate to low levels, it's not realistic at TFN prices
    // Low levels are also unlikely to have all their slots filled
    if (nHD <= 2)
    { 
        nUniqueChance = 2;
        nChanceToFillApparel = 5;
        nMaxAC = 5;
    }
    else if (nHD == 3)
    {
        nUniqueChance = 5;
        nChanceToFillApparel = 15;
        nMaxAC = 6;
    }
    else if (nHD == 4)
    {
        nUniqueChance = 8;
        nChanceToFillApparel = 50;
        nMaxAC = 7;
    }
    else if (nHD == 5)
    {
        nUniqueChance = 11;
        nChanceToFillApparel = 75;
    }
    // Values are saved at +1 to allow differentiation of "real" 0s and not-set 0s
    int nSavedMaxAC = GetLocalInt(oAdventurer, "armormaxac") - 1;
    if (nSavedMaxAC > -1 && nSavedMaxAC < nMaxAC)
    {
        nMaxAC = nSavedMaxAC;
    }
    
    
    // Primary weapon tier, based on henchman scaling and pok's old adventurers
    // Also used for armour
    int nWeaponTier = 1;
    if (nHD >= 12) { nWeaponTier = 5; }
    else if (nHD >= 9) { nWeaponTier = 4; }
    else if (nHD >= 5) { nWeaponTier = 3; }
    else if (nHD >= 4) { nWeaponTier = 2; }
        
    
    struct RandomWeaponResults rwr = RollRandomWeaponTypesForCreature(oAdventurer);
    object oMain = TryEquippingRandomItemOfTier(rwr.nMainHand, nWeaponTier, nUniqueChance, oAdventurer, INVENTORY_SLOT_RIGHTHAND);
    object oOffhand = TryEquippingRandomItemOfTier(rwr.nOffHand, GetRandomItemTierFromAdventurerHD(nHD), nUniqueChance, oAdventurer, INVENTORY_SLOT_LEFTHAND);
    object oBackup;
    if (rwr.nBackupMeleeWeapon > 0)
    {
        oBackup = AddRandomItemOfTierToInventory(rwr.nBackupMeleeWeapon, GetRandomItemTierFromAdventurerHD(nHD), nUniqueChance, oAdventurer);
    }
    if (Random(100) < nChanceToFillApparel)
    {
        TryEquippingRandomItemOfTier(BASE_ITEM_HELMET, GetRandomItemTierFromAdventurerHD(nHD), 100, oAdventurer, INVENTORY_SLOT_HEAD);
    }
    if (Random(100) < nChanceToFillApparel)
    {
        TryEquippingRandomItemOfTier(BASE_ITEM_GLOVES, GetRandomItemTierFromAdventurerHD(nHD), 100, oAdventurer, INVENTORY_SLOT_ARMS);
    }
    if (Random(100) < nChanceToFillApparel)
    {
        TryEquippingRandomItemOfTier(BASE_ITEM_RING, GetRandomItemTierFromAdventurerHD(nHD), 100, oAdventurer, INVENTORY_SLOT_LEFTRING);
    }
    if (Random(100) < nChanceToFillApparel)
    {
        TryEquippingRandomItemOfTier(BASE_ITEM_RING, GetRandomItemTierFromAdventurerHD(nHD), 100, oAdventurer, INVENTORY_SLOT_RIGHTRING);
    }
    if (Random(100) < nChanceToFillApparel)
    {
        TryEquippingRandomItemOfTier(BASE_ITEM_AMULET, GetRandomItemTierFromAdventurerHD(nHD), 100, oAdventurer, INVENTORY_SLOT_NECK);
    }
    if (Random(100) < nChanceToFillApparel)
    {
        TryEquippingRandomItemOfTier(BASE_ITEM_BELT, GetRandomItemTierFromAdventurerHD(nHD), 100, oAdventurer, INVENTORY_SLOT_BELT);
    }
    if (Random(100) < nChanceToFillApparel)
    {
        TryEquippingRandomItemOfTier(BASE_ITEM_BOOTS, GetRandomItemTierFromAdventurerHD(nHD), 100, oAdventurer, INVENTORY_SLOT_BOOTS);
    }
    if (Random(100) < nChanceToFillApparel)
    {
        TryEquippingRandomItemOfTier(BASE_ITEM_CLOAK, GetRandomItemTierFromAdventurerHD(nHD), 100, oAdventurer, INVENTORY_SLOT_CLOAK);
    }
    
    nMaxAC = GetACOfArmorToEquip(oAdventurer, nMaxAC);
    TryEquippingRandomArmorOfTier(nMaxAC, nWeaponTier, nUniqueChance, oAdventurer);
    if (GetWeaponRanged(oMain))
    {
        SetLocalInt(oAdventurer, "range", 1);
        SetLocalObject(oAdventurer, "range_weapon", oMain);
        SetLocalObject(oAdventurer, "melee_weapon", oBackup);
        SetLocalObject(oAdventurer, "offhand", oOffhand);
    }
    else
    {
        SetLocalObject(oAdventurer, "melee_weapon", oMain);
        SetLocalObject(oAdventurer, "offhand", oOffhand);
    }
    SetLocalInt(oAdventurer, "no_stealth", 1);
}

object SpawnAdventurer(location lSpawn, int nPath, int nHD, int bAdvance=1, int bEquip=1)
{
    object oAdventurer = CreateObject(OBJECT_TYPE_CREATURE, "adventurer", lSpawn);
    if (bAdvance)
    {
        AdvanceCreatureAlongAdventurerPath(oAdventurer, nPath, nHD);
        if (bEquip)
        {
            EquipAdventurer(oAdventurer);
        }
    }
    return oAdventurer;
}

void GenerateTrueName(object oAdventurer)
{
    int nRacialType = GetRacialType(oAdventurer);
    int nGender = GetGender(oAdventurer);
    int nFirstNametype = NAME_FIRST_GENERIC_MALE;
    int nLastNametype = NAME_LAST_HUMAN;
    if (nRacialType == RACIAL_TYPE_HUMAN)
    {
        if (nGender == GENDER_MALE)
        {
            nFirstNametype = NAME_FIRST_HUMAN_MALE;
        }
        else
        {
            nFirstNametype = NAME_FIRST_HUMAN_FEMALE;
        }
        nLastNametype = NAME_LAST_HUMAN;
    }
    else if (nRacialType == RACIAL_TYPE_DWARF)
    {
        if (nGender == GENDER_MALE)
        {
            nFirstNametype = NAME_FIRST_DWARF_MALE;
        }
        else
        {
            nFirstNametype = NAME_FIRST_DWARF_FEMALE;
        }
        nLastNametype = NAME_LAST_DWARF;
    }
    else if (nRacialType == RACIAL_TYPE_ELF)
    {
        if (nGender == GENDER_MALE)
        {
            nFirstNametype = NAME_FIRST_ELF_MALE;
        }
        else
        {
            nFirstNametype = NAME_FIRST_ELF_FEMALE;
        }
        nLastNametype = NAME_LAST_ELF;
    }
    else if (nRacialType == RACIAL_TYPE_GNOME)
    {
        if (nGender == GENDER_MALE)
        {
            nFirstNametype = NAME_FIRST_GNOME_MALE;
        }
        else
        {
            nFirstNametype = NAME_FIRST_GNOME_FEMALE;
        }
        nLastNametype = NAME_LAST_GNOME;
    }
    else if (nRacialType == RACIAL_TYPE_HALFELF)
    {
        if (nGender == GENDER_MALE)
        {
            nFirstNametype = NAME_FIRST_HALFELF_MALE;
        }
        else
        {
            nFirstNametype = NAME_FIRST_HALFELF_FEMALE;
        }
        nLastNametype = NAME_LAST_HALFELF;
    }
    else if (nRacialType == RACIAL_TYPE_HALFLING)
    {
        if (nGender == GENDER_MALE)
        {
            nFirstNametype = NAME_FIRST_HALFLING_MALE;
        }
        else
        {
            nFirstNametype = NAME_FIRST_HALFLING_FEMALE;
        }
        nLastNametype = NAME_LAST_HALFLING;
    }
    else if (nRacialType == RACIAL_TYPE_HALFORC)
    {
        if (nGender == GENDER_MALE)
        {
            nFirstNametype = NAME_FIRST_HALFORC_MALE;
        }
        else
        {
            nFirstNametype = NAME_FIRST_HALFORC_FEMALE;
        }
        nLastNametype = NAME_LAST_HALFORC;
    }
    SetLocalString(oAdventurer, "adventurer_firstname", RandomName(nFirstNametype));
    SetLocalString(oAdventurer, "adventurer_lastname", RandomName(nLastNametype));
}

string GetAdventurerTrueName(object oAdventurer)
{
    string sTrueName = GetLocalString(oAdventurer, "adventurer_firstname") + " " + GetLocalString(oAdventurer, "adventurer_lastname");
    return sTrueName;
}

// Reveal oAdventurer's true name to oPC and their party.
void RevealTrueNameToPlayer(object oAdventurer, object oPC)
{
    string sTrueName = GetLocalString(oAdventurer, "adventurer_firstname") + " " + GetLocalString(oAdventurer, "adventurer_lastname");
    NWNX_Player_SetCreatureNameOverride(oPC, oAdventurer, sTrueName);
    object oTest = GetFirstFactionMember(oPC);
    while (GetIsObjectValid(oTest))
    {
        if (GetIsPC(oTest))
        {
            NWNX_Player_SetCreatureNameOverride(oTest, oAdventurer, sTrueName);
        }
        oTest = GetNextFactionMember(oPC);
    }
    location lPC = GetLocation(oPC);
    oTest = GetFirstObjectInShape(SHAPE_SPHERE, 20.0, lPC, TRUE);
    while (GetIsObjectValid(oTest))
    {
        if (GetIsPC(oTest))
        {
            NWNX_Player_SetCreatureNameOverride(oTest, oAdventurer, sTrueName);
        }
        oTest = GetNextObjectInShape(SHAPE_SPHERE, 20.0, lPC, TRUE);
    }
}

// Mark oAdventurer as the leader of their little group.
void DesignateAdventurerAsPartyLeader(object oAdventurer)
{
    SetLocalObject(oAdventurer, "adventurer_leader", oAdventurer);
    if (GetLocalInt(oAdventurer, "adventurer_party_size") < 1)
    {
        SetLocalInt(oAdventurer, "adventurer_party_size", 1);
        SetLocalObject(oAdventurer, "adventurer_party1", oAdventurer);
    }
}

// Add oAdventurer to oLeader's little adventuring group.
// DOES NOT ADD THEM TO A PLAYER PARTY. Use the inc_follower stuff for that.
void AddAdventurerToParty(object oAdventurer, object oLeader)
{
    SetLocalObject(oAdventurer, "adventurer_leader", oLeader);
    int nOldPartySize = GetLocalInt(oLeader, "adventurer_party_size");
    SetLocalObject(oLeader, "adventurer_party" + IntToString(nOldPartySize+1), oAdventurer);
    int i;
    for (i=1; i<=nOldPartySize+1; i++)
    {
        object oPartyMember = GetLocalObject(oLeader, "adventurer_party" + IntToString(i));
        SetLocalObject(oAdventurer, "adventurer_party" + IntToString(i), oPartyMember);
        SetLocalObject(oPartyMember, "adventurer_party" + IntToString(nOldPartySize + 1), oAdventurer);
        SetLocalInt(oPartyMember, "adventurer_party_size", nOldPartySize + 1);
    }
}

object GetAdventurerPartyLeader(object oAdventurer)
{
    object oLeader = GetLocalObject(oAdventurer, "adventurer_leader");
    if (GetIsObjectValid(oLeader) && !GetIsDead(oLeader))
    {
        return oLeader;
    }
    // Look for a new alive group leader, then update all members accordingly
    int nPartySize = GetAdventurerPartySize(oAdventurer);
    int i;
    oLeader = OBJECT_INVALID;
    for (i=1; i<=nPartySize; i++)
    {
        object oMember = GetAdventurerPartyMemberByIndex(oAdventurer, i);
        if (!GetIsDead(oMember) && GetIsObjectValid(oMember))
        {
            oLeader = oMember;
            break;
        }
    }
    if (GetIsObjectValid(oLeader))
    {
        // Update all party members leader markers, deliberately including those that are dead
        for (i=1; i<=nPartySize; i++)
        {
            object oMember = GetAdventurerPartyMemberByIndex(oAdventurer, i);
            SetLocalObject(oMember, "adventurer_leader", oLeader);
        }
        DesignateAdventurerAsPartyLeader(oLeader);
        // Setting the party type will potentially set a bunch of variables on the new leader
        // This is important in some cases, eg if the assassin leader gets killed by random spawns
        // then another member will take up their job of talking to the PC and drop the note on death
        int nPartyType = GetLocalInt(oLeader, "adventurer_party_type");
        if (nPartyType > 0)
        {
            SetAdventurerPartyType(oLeader, nPartyType);
        }
        return oLeader;
    }
    // If we didn't find a new leader, assume the last adventurer standing was it
    // (might be a case for returning the old leader here instead, though)
    return oAdventurer;
}

int GetAdventurerPartySize(object oAdventurer)
{
    return GetLocalInt(oAdventurer, "adventurer_party_size");
}

object GetAdventurerPartyMemberByIndex(object oAdventurer, int nIndex)
{
    return GetLocalObject(oAdventurer, "adventurer_party" + IntToString(nIndex));
}

void SetAdventurerPartyType(object oAdventurer, int nPartyType)
{
    SetLocalInt(oAdventurer, "adventurer_party_type", nPartyType);
    if (nPartyType != ADVENTURER_PARTY_FRIENDLY_GENERIC)
    {
        DeleteLocalInt(oAdventurer, "no_stealth");
    }
    SetLocalString(oAdventurer, "conversation_override", "adventureparty" + IntToString(nPartyType));
    if (nPartyType == ADVENTURER_PARTY_HOSTILE_ASSASSIN)
    {
        SetLocalInt(oAdventurer, "cr", GetHitDice(oAdventurer));
        SetLocalInt(oAdventurer, "area_cr", GetHitDice(oAdventurer));
        DeleteLocalInt(oAdventurer, "no_credit");
        object oLeader = GetAdventurerPartyLeader(oAdventurer);
        SetLocalString(oLeader, "perception_script", "percep_advp1");
        SetLocalString(oLeader, "heartbeat_script", "hb_advp1");
        SetLocalString(oLeader, "death_script", "ondeath_assnote");
        SetLocalInt(oLeader, "semiboss", 1);
        
    }
    else if (nPartyType == ADVENTURER_PARTY_REST_ASSASSIN)
    {
        SetLocalInt(oAdventurer, "semiboss", 1);
        SetLocalInt(oAdventurer, "cr", GetHitDice(oAdventurer));
        SetLocalInt(oAdventurer, "area_cr", GetHitDice(oAdventurer));
        DeleteLocalInt(oAdventurer, "no_credit");
        object oLeader = GetAdventurerPartyLeader(oAdventurer);
        SetLocalString(oLeader, "death_script", "ondeath_assnote");
    }
}

int SelectAdventurerHD(object oArea)
{
    int nACR = GetLocalInt(oArea, "cr");
    if (nACR < 3)
        nACR = GetLocalInt(oArea, "adventurer_hd");
    if (nACR < 3)
    {
        WriteTimestampedLogEntry("Adventurer HD: HD setting for adventurers in area " + GetResRef(oArea));
        nACR = 3;
    }
    return nACR;    
}

int SelectBountyHunterGroupHD(object oArea)
{
    int nACR = GetLocalInt(oArea, "cr");
    if (nACR < 3)
        nACR = 3;
    
    int nWeightSum = 0;
    json jWeights = JsonArray();
    int i;
    object oTest = GetFirstPC();
    while (GetIsObjectValid(oTest))
    {
        object oPCArea = GetArea(oTest);
        int nWeight = 1;
        if (GetIsObjectValid(oPCArea))
        {
            int nDist = 1;
            if (oPCArea != oArea)
            {
                nDist = GetDistanceBetweenAreas(oArea, oPCArea);
            }
            // max(nDist, 150) should hopefully give a hefty weighting to the PC entering the area
            if (nDist < 150)
                nDist = 150;
            nWeight = (10000/nDist);
        }
        nWeightSum += nWeight;
        int nHD = GetHitDice(oTest);
        while (nHD >= JsonGetLength(jWeights))
        {
            JsonArrayInsertInplace(jWeights, JsonInt(0));
        }
        int nNewWeight = JsonGetInt(JsonArrayGet(jWeights, nHD)) + nWeight;
        JsonArraySetInplace(jWeights, nHD, JsonInt(nNewWeight));
        
        oTest = GetNextPC();
    }
    int nRolledWeight = Random(nWeightSum);
    WriteTimestampedLogEntry("SelectAdventurerGroupHD: weight sum = " + IntToString(nWeightSum) + ", rolled " + IntToString(nRolledWeight) + "; " + JsonDump(jWeights));
    i = 0;
    while (nRolledWeight > 0 && i < JsonGetLength(jWeights))
    {
        int nThisWeight = JsonGetInt(JsonArrayGet(jWeights, i));
        nRolledWeight -= nThisWeight;
        if (nRolledWeight > 0)
            i++;
    }
    // Safety: reduce by 20%
    // This hopefully keeps things a little bit more manageable.
    int nReduction = i / 5;
    WriteTimestampedLogEntry("Picked HD (unless lower than ACR " + IntToString(nACR) + "): " + IntToString(i) + ", reduction = " + IntToString(nReduction));
    i -= nReduction;
    if (i < nACR)
    {
        return nACR;
    }
    
    return i;
}

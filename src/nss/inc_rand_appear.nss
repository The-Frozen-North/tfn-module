#include "nwnx_creature"
#include "util_i_math"
#include "inc_array"
#include "inc_general"

// This is an include for changing creatures' appearance and gender.

// Randomises a creature's racial type, according to the weight parameters.
void RandomiseCreatureRacialType(object oCreature=OBJECT_SELF, int nDwarfWeight=1, int nElfWeight=1, int nGnomeWeight=1,  int nHalfElfWeight=1, int nHalfOrcWeight=1, int nHalflingWeight=1, int nHumanWeight=1);

// Randomises a creature's racial type, based on its class(es).
void RandomiseCreatureRacialTypeBasedOnClass(object oCreature=OBJECT_SELF);

// 50/50 to become male or female. Returns the new GENDER_* constant.
// This DOESN'T CHANGE PORTRAITS.
int RandomiseCreatureGender(object oCreature=OBJECT_SELF);

void RandomiseCreaturePortrait(object oCreature=OBJECT_SELF);

// Randomise a creature's soundset. These voices are middle of the road, and probably appropriate for fairly average-to-well-off characters.
// Rough or brutish characters probably want to go somewhere else, though
void RandomiseCreatureSoundset_Average(object oCreature=OBJECT_SELF);

// Soundsets for casters and the like.
void RandomiseCreatureSoundset_Intellectual(object oCreature=OBJECT_SELF);

// Soundsets for rowdy bandits and the like.
void RandomiseCreatureSoundset_Rough(object oCreature=OBJECT_SELF);

// Soundsets for old people.
void RandomiseCreatureSoundset_Old(object oCreature=OBJECT_SELF);

void RandomiseSkinColour(object oCreature=OBJECT_SELF);

void RandomiseHairColour(object oCreature=OBJECT_SELF);

void RandomiseGenderAndAppearance(object oCreature=OBJECT_SELF);



//////////

const string RAND_APPEAR_TEMP_ARRAY = "rand_appear_temp";


// Untested - switching out racial feats and updating appearances manually might be needed too
// which means wrapping around NWNX_Creature_SetRacialType for this function

void RandomiseCreatureRacialType(object oCreature=OBJECT_SELF, int nDwarfWeight=1, int nElfWeight=1, int nGnomeWeight=1,  int nHalfElfWeight=1, int nHalfOrcWeight=1, int nHalflingWeight=1, int nHumanWeight=1)
{
    int nWeightSum = nDwarfWeight + nElfWeight + nGnomeWeight + nHalfElfWeight + nHalfOrcWeight + nHalflingWeight + nHumanWeight;
    int nRoll = Random(nWeightSum) + 1;
    if (nRoll <= nDwarfWeight) { NWNX_Creature_SetRacialType(oCreature, RACIAL_TYPE_DWARF); return; }
    nRoll -= nDwarfWeight;
    if (nRoll <= nElfWeight) { NWNX_Creature_SetRacialType(oCreature, RACIAL_TYPE_ELF); return; }
    nRoll -= nElfWeight;
    if (nRoll <= nHalfElfWeight) { NWNX_Creature_SetRacialType(oCreature, RACIAL_TYPE_HALFELF); return; }
    nRoll -= nHalfElfWeight;
    if (nRoll <= nGnomeWeight) { NWNX_Creature_SetRacialType(oCreature, RACIAL_TYPE_GNOME); return; }
    nRoll -= nGnomeWeight;
    if (nRoll <= nHalfOrcWeight) { NWNX_Creature_SetRacialType(oCreature, RACIAL_TYPE_HALFORC); return; }
    nRoll -= nHalfOrcWeight;
    if (nRoll <= nHalflingWeight) { NWNX_Creature_SetRacialType(oCreature, RACIAL_TYPE_HALFLING); return; }
    NWNX_Creature_SetRacialType(oCreature, RACIAL_TYPE_HUMAN);
}

void RandomiseCreatureRacialTypeBasedOnClass(object oCreature=OBJECT_SELF)
{
    int nFight = GetLevelByClass(CLASS_TYPE_FIGHTER, oCreature);
    int nBarb = GetLevelByClass(CLASS_TYPE_BARBARIAN, oCreature);
    int nRogue = GetLevelByClass(CLASS_TYPE_ROGUE, oCreature);
    int nWizard = GetLevelByClass(CLASS_TYPE_WIZARD, oCreature) + GetLevelByClass(CLASS_TYPE_SORCERER, oCreature);
    int nHighest = max(max(max(nFight, nBarb), nRogue), nWizard);
    if (nHighest == nFight)
    {
        RandomiseCreatureRacialType(oCreature, 3, 2, 1, 2, 3, 1, 2);
        return;
    }
    if (nHighest == nBarb)
    {
        RandomiseCreatureRacialType(oCreature, 2, 1, 1, 2, 4, 1, 2);
        return;
    }
    if (nHighest == nRogue)
    {
        RandomiseCreatureRacialType(oCreature, 1, 2, 2, 2, 1, 4, 2);
        return;
    }
    if (nHighest == nWizard)
    {
        RandomiseCreatureRacialType(oCreature, 1, 3, 3, 2, 1, 2, 2);
        return;
    }
    RandomiseCreatureRacialType(oCreature);
}


int RandomiseCreatureGender(object oCreature=OBJECT_SELF)
{
    if (Random(2) == 1)
    {
        SetGender(oCreature, GENDER_FEMALE);
        return GENDER_FEMALE;
    }
    else
    {
        SetGender(oCreature, GENDER_MALE);
        return GENDER_MALE;
    }
}

void RandomiseCreatureHead(object oCreature=OBJECT_SELF)
{
    int nRacialType = GetRacialType(oCreature);
    int nGender = GetGender(oCreature);
    int nHead = -1;
    if (nRacialType == RACIAL_TYPE_HUMAN || nRacialType == RACIAL_TYPE_HALFELF)
    {
        if (nGender == GENDER_MALE)
        {
            // Not: 19 (black features), 20 (tiefling), 21 (somewhat glowy eyes)
            // up to 32
            nHead = 1 + Random(29);
            if (nHead >= 19) { nHead += 3; }
        }
        else if (nGender == GENDER_FEMALE)
        {
            // Up to 25
            // Not 14 (tiefling)
            nHead = 1 + Random(25);
            if (nHead >= 14) { nHead += 1; }
        }
    }
    else if (nRacialType == RACIAL_TYPE_DWARF)
    {
        if (nGender == GENDER_FEMALE)
        {
            nHead = 1 + Random(12);
        }
        else if (nGender == GENDER_MALE)
        {
            nHead = 1 + Random(13);
        }
    }
    else if (nRacialType == RACIAL_TYPE_ELF)
    {
        if (nGender == GENDER_FEMALE)
        {
            nHead = 1 + Random(16);
        }
        else if (nGender == GENDER_MALE)
        {
            nHead = 1 + Random(18);
        }
    }
    else if (nRacialType == RACIAL_TYPE_GNOME)
    {
        if (nGender == GENDER_FEMALE)
        {
            nHead = 1 + Random(9);
        }
        else if (nGender == GENDER_MALE)
        {
            nHead = 1 + Random(13);
        }
    }
    else if (nRacialType == RACIAL_TYPE_HALFLING)
    {
        if (nGender == GENDER_FEMALE)
        {
            nHead = 1 + Random(11);
        }
        else if (nGender == GENDER_MALE)
        {
            nHead = 1 + Random(10);
        }
    }
    else if (nRacialType == RACIAL_TYPE_HALFORC)
    {
        if (nGender == GENDER_FEMALE)
        {
            nHead = 1 + Random(12);
        }
        else if (nGender == GENDER_MALE)
        {
            nHead = 1 + Random(13);
        }
    }
    if (nHead != -1)
    {
        SetCreatureBodyPart(CREATURE_PART_HEAD, nHead, oCreature);
    }
}

void RandomiseCreatureSoundset_Average(object oCreature=OBJECT_SELF)
{
    Array_Clear(RAND_APPEAR_TEMP_ARRAY, GetModule());
    int nRace = GetRacialType(oCreature);
    int nGender = GetGender(oCreature);
    int nGoodEvil = GetAlignmentGoodEvil(oCreature);
    //int nLawChaos = GetAlignmentLawChaos(oCreature);
    float fAB = IntToFloat(GetBaseAttackBonus(oCreature))/IntToFloat(GetHitDice(oCreature));
    int nInt = GetAbilityScore(oCreature, ABILITY_INTELLIGENCE);
    int nWiz = GetLevelByClass(CLASS_TYPE_WIZARD, oCreature) + GetLevelByClass(CLASS_TYPE_SORCERER, oCreature);
    int i;
    if (nRace == RACIAL_TYPE_DWARF)
    {
        if (nGender == GENDER_MALE)
        {
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 163, GetModule());   //dwarf male typical
        }
    }
    else if (nRace == RACIAL_TYPE_ELF)
    {
        if (nGender == GENDER_FEMALE)
        {
            if (nGoodEvil == ALIGNMENT_GOOD) { for (i=0; i<4; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 154, GetModule());  } } //elf female guard
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 135, GetModule());   //elf female sensible
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 128, GetModule());   //elf female typical
        }
        else if (nGender == GENDER_MALE)
        {
           if (GetLevelByClass(CLASS_TYPE_CLERIC, oCreature)) { for (i=0; i<8; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 125, GetModule()); } }  //elf male cleric
           if (nGoodEvil == ALIGNMENT_GOOD) { for (i=0; i<5; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 155, GetModule());  } } //elf male guard mature officer
           if (fAB <= 0.7) { for (i=0; i<4; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 165, GetModule());  } } //elf male lilting
           Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 132, GetModule()); //elf male typical
        }
    }
    else if (nRace == RACIAL_TYPE_GNOME)
    {
        if (nGender == GENDER_MALE)
        {
           Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 142, GetModule());   //gnome male annoying
           Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 178, GetModule());   //gnome male older
           Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 143, GetModule());   //gnome male pleasant
           Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 164, GetModule());   //gnome male typical
        }
    }
    else if (nRace == RACIAL_TYPE_HALFLING)
    {
        if (nGender == GENDER_MALE)
        {
           Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 145, GetModule());   //halfling male typical
        }
        else if (nGender == GENDER_FEMALE)
        {
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 144, GetModule());   //halfling female sensible
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 162, GetModule());   //halfling female typical
        }
    }
    else if (nRace == RACIAL_TYPE_HALFORC)
    {
        if (nGender == GENDER_MALE)
        {
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 192, GetModule());   //halforc male gruff lout
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 114, GetModule());   //halforc male chieftain
        }
        else if (nGender == GENDER_FEMALE)
        {
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 176, GetModule());   //halforc female lout
        }
    }
    else if (nRace == RACIAL_TYPE_HUMAN || nRace == RACIAL_TYPE_HALFELF)
    {
        if (nGender == GENDER_FEMALE)
        {
            if (fAB > 0.9) { for (i=0; i<8; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 112, GetModule()); } }   //human female barbarian
            if (nGoodEvil == ALIGNMENT_EVIL) { for (i=0; i<3; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 133, GetModule()); } }   //human female evil fanatic
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 188, GetModule());    //human female guard sedos
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 151, GetModule());    //human female young pleasant
        }
        else if (nGender == GENDER_MALE)
        {
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 193, GetModule());    //human male average joe
            if (fAB > 0.9 && nGoodEvil == ALIGNMENT_GOOD) { for (i=0; i<8; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 187, GetModule()); } } // human male barbarian good
            if (fAB > 0.9 && nInt < 10) { for (i=0; i<9; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 113, GetModule()); } } // human male barbarian stupid
            if (fAB > 0.9) { for (i=0; i<4; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 115, GetModule()); } } // human male barbarian warrior
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 352, GetModule()); // human male blackguard
            if (fAB > 0.9) { for (i=0; i<4; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 177, GetModule()); } } // human male bully
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 134, GetModule()); // human male evil fanatic
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 147, GetModule()); // human male evil methodical villain
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 146, GetModule()); // human male evil sly assassin
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 148, GetModule()); // human male evil typical fighter
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 169, GetModule());  // 169 human male gigolo seductive
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 170, GetModule());  // 170 human male gigolo smarmy
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 190, GetModule()); // 190 human male guard arrogant
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 156, GetModule());  // 156 human male guard good rough
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 186, GetModule()); // 186 human male guard gruff
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 183, GetModule()); // 183 human male older slave
            if (GetLevelByClass(CLASS_TYPE_DRUID, oCreature)) { for (i=0; i<10; i++) {   Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 129, GetModule()); } } // human male older confident leader
            if (fAB >= 0.75) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 171, GetModule()); } // human male stoic ranger
            if (fAB >= 0.75) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 118, GetModule()); } // human male typical brash scumbag
            if (fAB >= 0.75) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 172, GetModule()); } // human male veteran rogue
            if (GetLevelByClass(CLASS_TYPE_CLERIC, oCreature)) { for (i=0; i<3; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 123, GetModule()); } } // human male typical cleric
            if (GetLevelByClass(CLASS_TYPE_DRUID, oCreature)) { for (i=0; i<3; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 140, GetModule()); } } // human male typical druid
        }
    }

    if (nGender == GENDER_FEMALE)
    {
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 433, GetModule());   //female adventurer
        if (GetLevelByClass(CLASS_TYPE_BARBARIAN, oCreature)) { for (i=0; i<6; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 357, GetModule()); } }  //female berserker
        if (fAB >= 0.8 && nInt < 9) { for (i=0; i<6; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 245, GetModule()); } }  //female brutish thug
        if (fAB >= 0.75) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 243, GetModule()); } // female cold killer
        if (fAB >= 0.8) { for (i=0; i<3; i++) {  Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 358, GetModule()); } } // female feisty
        if (fAB >= 0.8) { for (i=0; i<3; i++) {  Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 242, GetModule()); } } // female fighter
        if (GetLevelByClass(CLASS_TYPE_DRUID, oCreature)) { for (i=0; i<6; i++) {   Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 226, GetModule()); } } // female guardian reserved
        if (GetLevelByClass(CLASS_TYPE_CLERIC, oCreature)) { for (i=0; i<6; i++) {   Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 422, GetModule()); } } // female healer
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 423, GetModule()); // female maiden
        if (fAB >= 0.8) { for (i=0; i<3; i++) {  Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 359, GetModule()); } } // female mature commander
        if (nWiz) { for (i=0; i<6; i++) {   Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 220, GetModule()); } } // female noble scholar
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 360, GetModule()); // female playful
        if (nGoodEvil == ALIGNMENT_GOOD) Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 361, GetModule()); // female quiet leader
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 421, GetModule()); // female rogue
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 244, GetModule()); // female seductress
    }
    else if (nGender == GENDER_MALE)
    {
        if (GetLevelByClass(CLASS_TYPE_PALADIN, oCreature)) { for (i=0; i<15; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 161, GetModule()); } } // human male veteran paladin
        if (nWiz) { for (i=0; i<8; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 191, GetModule()); } } // human male wizard
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 420, GetModule()); // male archer
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 217, GetModule()); // male boisterous goodnatured
        if (nGoodEvil != ALIGNMENT_GOOD) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 218, GetModule()); } // male brooding dark hero
        if (nInt <= 8) { for (i=0; i<10; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 363, GetModule()); } } // male dumb hero
        if (nWiz) { for (i=0; i<6; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 418, GetModule()); } } // male good wizard
        if (nWiz) { for (i=0; i<6; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 222, GetModule()); } } // male high strung evangelist
        if (fAB >= 0.8) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 221, GetModule()); } // male large rowdy
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 229, GetModule()); // male mature swashbuckler
        if (fAB >= 0.8) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 368, GetModule()); } // male neutral warrior
        if (nGoodEvil == ALIGNMENT_GOOD) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 224, GetModule()); } // male pious scholar
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 364, GetModule());  // male power hungry
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 365, GetModule());  // male prankster
        if (GetLevelByClass(CLASS_TYPE_DRUID, oCreature)) { for (i=0; i<6; i++) {   Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 223, GetModule()); } } // male reserved guardian
        if (nGoodEvil == ALIGNMENT_EVIL) { for (i=0; i<6; i++) {   Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 366, GetModule()); } } // male sociopath
        if (fAB > 0.75) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 367, GetModule()); } // male stealth specialist
        if (fAB > 0.75) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 419, GetModule()); } // male typical fighter
    }

    Array_Shuffle(RAND_APPEAR_TEMP_ARRAY, GetModule());
    int nSoundset = Array_At_Int(RAND_APPEAR_TEMP_ARRAY, 0, GetModule());
    SetSoundset(oCreature, nSoundset);

}


void RandomiseCreatureSoundset_Rough(object oCreature=OBJECT_SELF)
{
    Array_Clear(RAND_APPEAR_TEMP_ARRAY, GetModule());
    int nRace = GetRacialType(oCreature);
    int nGender = GetGender(oCreature);
    int nGoodEvil = GetAlignmentGoodEvil(oCreature);
    //int nLawChaos = GetAlignmentLawChaos(oCreature);
    float fAB = IntToFloat(GetBaseAttackBonus(oCreature))/IntToFloat(GetHitDice(oCreature));
    int nInt = GetAbilityScore(oCreature, ABILITY_INTELLIGENCE);
    int nWiz = GetLevelByClass(CLASS_TYPE_WIZARD, oCreature) + GetLevelByClass(CLASS_TYPE_SORCERER, oCreature);
    int i;
    if (nRace == RACIAL_TYPE_DWARF)
    {
        if (nGender == GENDER_MALE)
        {
            for (i=0; i<2; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 179, GetModule()); } // dwarf male evil thug
            for (i=0; i<2; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 130, GetModule()); } // dwarf male veteran
        }
    }
    else if (nRace == RACIAL_TYPE_ELF)
    {
        if (nGender == GENDER_MALE)
        {
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 131, GetModule());   //elf male brooding
        }
    }
    else if (nRace == RACIAL_TYPE_HALFORC)
    {
        if (nGender == GENDER_MALE)
        {
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 192, GetModule());   //halforc male gruff lout
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 114, GetModule());   //halforc male chieftain
        }
        else if (nGender == GENDER_FEMALE)
        {
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 176, GetModule());   //halforc female lout
        }
    }

    if (nGender == GENDER_FEMALE)
    {
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 357, GetModule());  // female berserker
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 245, GetModule()); // female brutish thug
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 243, GetModule()); // female cold killer
    }
    else if (nGender == GENDER_MALE)
    {
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 138, GetModule()); // human male older world weary
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 363, GetModule()); // male dumb hero
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 119, GetModule());  // human male typical low class villain
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 118, GetModule());  // human male typical brash scumbag
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 177, GetModule()); // human male bully
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 177, GetModule());
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 177, GetModule());
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 177, GetModule());
    }


    Array_Shuffle(RAND_APPEAR_TEMP_ARRAY, GetModule());
    if (Array_Size(RAND_APPEAR_TEMP_ARRAY, GetModule()) == 0)
    {
        RandomiseCreatureSoundset_Average(oCreature);
    }
    else
    {
        int nSoundset = Array_At_Int(RAND_APPEAR_TEMP_ARRAY, 0, GetModule());
        SetSoundset(oCreature, nSoundset);
    }
}

void RandomiseCreatureSoundset_Intellectual(object oCreature=OBJECT_SELF)
{
    Array_Clear(RAND_APPEAR_TEMP_ARRAY, GetModule());
    int nRace = GetRacialType(oCreature);
    int nGender = GetGender(oCreature);
    int nGoodEvil = GetAlignmentGoodEvil(oCreature);
    //int nLawChaos = GetAlignmentLawChaos(oCreature);
    float fAB = IntToFloat(GetBaseAttackBonus(oCreature))/IntToFloat(GetHitDice(oCreature));
    int nInt = GetAbilityScore(oCreature, ABILITY_INTELLIGENCE);
    int nWiz = GetLevelByClass(CLASS_TYPE_WIZARD, oCreature) + GetLevelByClass(CLASS_TYPE_SORCERER, oCreature);
    int i;
    if (nRace == RACIAL_TYPE_ELF)
    {
        if (nGender == GENDER_FEMALE)
        {
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 353, GetModule()); //elf female noble
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 180, GetModule()); //elf female wizard
        }
        else if (nGender == GENDER_MALE)
        {
            if (GetLevelByClass(CLASS_TYPE_CLERIC, oCreature)) { for (i=0; i<3; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 125, GetModule()); }} //elf male cleric
            if (fAB <= 0.7) { for (i=0; i<4; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 165, GetModule());  } } //elf male lilting
            if (nWiz) { for (i=0; i<8; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 344, GetModule()); } }  //elf male wizard
        }
    }
    else if (nRace == RACIAL_TYPE_HALFLING)
    {
        if (nGender == GENDER_FEMALE)
        {
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 144, GetModule());   //halfling female sensible
        }
        else if (nGender == GENDER_MALE)
        {
            Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 145, GetModule());   //halfling male typical
        }
    }
    if (nGender == GENDER_FEMALE)
    {
        if (GetLevelByClass(CLASS_TYPE_DRUID, oCreature)) { for (i=0; i<3; i++) {   Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 226, GetModule()); } } // female guardian reserved
        if (GetLevelByClass(CLASS_TYPE_CLERIC, oCreature)) { for (i=0; i<6; i++) {   Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 422, GetModule()); } } // female healer
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 220, GetModule()); // female noble scholar
    }
    else if (nGender == GENDER_MALE)
    {
        if (nGoodEvil == ALIGNMENT_GOOD) { for (i=0; i<3; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 187, GetModule()); } } // human male barbarian good
        if (nInt < 10) { for (i=0; i<3; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 113, GetModule()); } } // human male barbarian stupid
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 115, GetModule());  // human male barbarian warrior
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 195, GetModule());  // human male farmer ("Don't make me have to adjust your attitude. I will.")
        if (GetLevelByClass(CLASS_TYPE_DRUID, oCreature)) { for (i=0; i<5; i++) {   Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 129, GetModule()); } } // human male older confident leader
        if (nWiz) { for (i=0; i<8; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 191, GetModule()); } } // human male wizard
        if (nWiz) { for (i=0; i<4; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 181, GetModule()); } } // human male wizard old
        if (nWiz) { for (i=0; i<6; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 418, GetModule()); } } // male good wizard
        if (nGoodEvil == ALIGNMENT_GOOD) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 224, GetModule()); } // male pious scholar
        if (GetLevelByClass(CLASS_TYPE_DRUID, oCreature)) { for (i=0; i<6; i++) {   Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 223, GetModule()); } } // male reserved guardian
        if (fAB > 0.75) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 219, GetModule()); } // male violent fighter
    }

    Array_Shuffle(RAND_APPEAR_TEMP_ARRAY, GetModule());
    if (Array_Size(RAND_APPEAR_TEMP_ARRAY, GetModule()) == 0)
    {
        RandomiseCreatureSoundset_Average(oCreature);
    }
    else
    {
        int nSoundset = Array_At_Int(RAND_APPEAR_TEMP_ARRAY, 0, GetModule());
        SetSoundset(oCreature, nSoundset);
    }

}

void RandomiseCreatureSoundset_Old(object oCreature=OBJECT_SELF)
{
    Array_Clear(RAND_APPEAR_TEMP_ARRAY, GetModule());
    int nRace = GetRacialType(oCreature);
    int nGender = GetGender(oCreature);
    int nGoodEvil = GetAlignmentGoodEvil(oCreature);
    //int nLawChaos = GetAlignmentLawChaos(oCreature);
    float fAB = IntToFloat(GetBaseAttackBonus(oCreature))/IntToFloat(GetHitDice(oCreature));
    int nInt = GetAbilityScore(oCreature, ABILITY_INTELLIGENCE);
    int nWiz = GetLevelByClass(CLASS_TYPE_WIZARD, oCreature) + GetLevelByClass(CLASS_TYPE_SORCERER, oCreature);
    int i;
    if (nRace == RACIAL_TYPE_DWARF)
    {
        if (nGender == GENDER_MALE)
        {
            for (i=0; i<2; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 141, GetModule()); } // dwarf male older grouch
        }
    }
    else if (nRace == RACIAL_TYPE_GNOME && nGender == GENDER_MALE)
    {
        for (i=0; i<2; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 178, GetModule()); } // gnome male older
    }
    if (nGender == GENDER_MALE)
    {
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 352, GetModule()); // human male blackguard
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 177, GetModule()); // human male bully
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 148, GetModule()); // human male evil typical fighter
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 174, GetModule()); // human male older shopkeep
        Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 124, GetModule()); // human male older melancholy
        if (nWiz) { for (i=0; i<4; i++) { Array_PushBack_Int(RAND_APPEAR_TEMP_ARRAY, 181, GetModule()); } } // human male wizard old
    }

    Array_Shuffle(RAND_APPEAR_TEMP_ARRAY, GetModule());
    if (Array_Size(RAND_APPEAR_TEMP_ARRAY, GetModule()) == 0)
    {
        RandomiseCreatureSoundset_Average(oCreature);
    }
    else
    {
        int nSoundset = Array_At_Int(RAND_APPEAR_TEMP_ARRAY, 0, GetModule());
        SetSoundset(oCreature, nSoundset);
    }

}

void RandomiseSkinColour(object oCreature=OBJECT_SELF)
{
    int nSkin = Random(14);
    SetColor(oCreature, COLOR_CHANNEL_SKIN, nSkin);
}

void RandomiseHairColour(object oCreature=OBJECT_SELF)
{
    int nSkin = GetColor(oCreature, COLOR_CHANNEL_SKIN);
    int nHair;
    int nDarkerSkin = 1;
    // Lighter skin colours
    if (nSkin <= 3 || nSkin == 8 || nSkin == 9 || nSkin == 12 || nSkin == 13)
    {
        nDarkerSkin = 0;
    }

    if (!nDarkerSkin)
    {
        // Apparently, 1/4 of the first row colours are some kind of red
        // which seems a bit too common
        if (d10() == 10)
        {
            nHair = Random(4) + 4;
        }
        else
        {
            nHair = Random(12);
            if (nHair >= 4 && nHair <= 7)
            {
                nHair += 8;
            }
        }
    }
    else
    {
        // Red
        if (d10() == 10)
        {
            nHair = Random(4) + 4;
        }
        else
        {
            nHair = Random(10);
            // Don't end up in the red range
            if (nHair >= 4 && nHair <= 7)
            {
                nHair += 4;
            }
            // Omit 12/13 for darker skin
            if (nHair == 12 || nHair == 13)
            {
                nHair += 2;
            }
        }
    }
    SetColor(oCreature, COLOR_CHANNEL_HAIR, nHair);
}




void RandomisePortrait(object oCreature=OBJECT_SELF)
{

    Array_Clear(RAND_APPEAR_TEMP_ARRAY, GetModule());
    int nRace = GetRacialType(oCreature);
    int nGender = GetGender(oCreature);
    int nGoodEvil = GetAlignmentGoodEvil(oCreature);
    //int nLawChaos = GetAlignmentLawChaos(oCreature);
    float fAB = IntToFloat(GetBaseAttackBonus(oCreature))/IntToFloat(GetHitDice(oCreature));
    int nInt = GetAbilityScore(oCreature, ABILITY_INTELLIGENCE);
    int nWiz = GetLevelByClass(CLASS_TYPE_WIZARD, oCreature) + GetLevelByClass(CLASS_TYPE_SORCERER, oCreature);
    int nAC = GetBaseArmorAC(GetItemInSlot(INVENTORY_SLOT_CHEST, oCreature));
    int nWeaponType = GetBaseItemType(GetItemInSlot(INVENTORY_SLOT_RIGHTHAND, oCreature));
    int i;
    if (nRace == RACIAL_TYPE_HUMAN || nRace == RACIAL_TYPE_HALFELF)
    {
        if (nGender == GENDER_FEMALE)
        {
            if (nAC >= 6) { for (i=0; i<5; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_f_01_", GetModule()); } }
            if (nAC < 2) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_f_02_", GetModule()); } }
            if (nAC > 0 && nAC <= 4) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_f_05_", GetModule()); } }
            if (nAC >= 4 && nAC <= 6) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_f_06_", GetModule()); } }
            if (nAC <= 3) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_f_07_", GetModule()); } }
            if (nAC <= 3) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_f_08_", GetModule()); } }
            if (nAC <= 3) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_f_09_", GetModule());  }
            if (nAC >= 5) { for (i=0; i<5; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_f_11_", GetModule()); } }
            if (GetLevelByClass(CLASS_TYPE_ROGUE, oCreature)) {  for (i=0; i<3; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_f_12_", GetModule()); } }
            if (GetLevelByClass(CLASS_TYPE_ROGUE, oCreature)) {  for (i=0; i<3; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_f_14_", GetModule()); } }
            if (nAC <= 3 && fAB >= 0.75) { for (i=0; i<3; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_f_13_", GetModule()); } }
            if (nAC >= 3 && fAB >= 0.75) { for (i=0; i<3; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_f_15_", GetModule()); } }
            if (nAC >= 4 && fAB >= 0.75) { for (i=0; i<3; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_f_16_", GetModule()); } }
            if (nAC == 0 && fAB <= 0.75) { for (i=0; i<3; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_f_17_", GetModule()); } }
            if (nAC <= 3) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_f_21_", GetModule()); } }
            if (GetLevelByClass(CLASS_TYPE_ROGUE, oCreature)) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_f_22_", GetModule()); }
            if (nAC >= 4 && fAB >= 0.75) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_f_23_", GetModule()); } }
            if (nAC >= 6 && nGoodEvil != ALIGNMENT_EVIL) { for (i=0; i<5; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_f_26_", GetModule()); } }
            if (GetLevelByClass(CLASS_TYPE_ARCANE_ARCHER, oCreature)) { for (i=0; i<10; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_f_27_", GetModule()); } }
            if (GetLevelByClass(CLASS_TYPE_ROGUE, oCreature)) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_f_28_", GetModule()); }
            Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_f_34_", GetModule());
            Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_f_35_", GetModule());
            Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_f_29_", GetModule());
            if (nWeaponType == BASE_ITEM_LIGHTCROSSBOW || nWeaponType == BASE_ITEM_HEAVYCROSSBOW) { for (i=0; i<5; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_f_30_", GetModule()); } }
            if (GetLevelByClass(CLASS_TYPE_RANGER, oCreature)) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_f_31_", GetModule()); }
            if (nAC >= 4 && fAB >= 0.75) { for (i=0; i<3; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_f_33_", GetModule()); } }
        }
        else if (nGender == GENDER_MALE)
        {
            if (nAC >= 6) { for (i=0; i<5; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_01_", GetModule()); } }
            if (nAC <= 1) { for (i=0; i<5; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_02_", GetModule()); } }
            // This one is a bit old
            //Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_03_", GetModule());
            if (nAC >= 3 && nAC <= 4) { for (i=0; i<3; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_04_", GetModule()); } }
            if (nAC <= 1 && fAB <= 0.75) { for (i=0; i<5; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_05_", GetModule()); } }
            if (nAC <= 2 && fAB >= 0.75) { for (i=0; i<5; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_27_", GetModule()); } }
            if (nAC <= 1 && fAB <= 0.75) { for (i=0; i<5; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_17_", GetModule()); } }
            if (nAC <= 1 && fAB <= 0.75) { for (i=0; i<5; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_19_", GetModule()); } }
            if (nAC >= 4 && nAC < 7) { for (i=0; i<3; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_06_", GetModule()); } }
            if (nAC >= 6 && nGoodEvil == ALIGNMENT_EVIL) { for (i=0; i<5; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_07_", GetModule()); } }
            if (nAC < 3) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_08_", GetModule()); } }
            if (nAC < 1) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_22_", GetModule()); }
            if (nAC < 1 && fAB < 0.75) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_23_", GetModule()); }
            if (nAC >= 6) { for (i=0; i<5; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_09_", GetModule()); } }
            if (nAC >= 3 && nAC < 5) { for (i=0; i<5; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_10_", GetModule()); } }
            if (fAB > 0.75 && nAC < 2) { for (i=0; i<3; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_11_", GetModule()); } }
            if (nAC >= 4 && nAC <= 5) { for (i=0; i<5; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_12_", GetModule()); } }
            if (nAC >= 6) { for (i=0; i<5; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_13_", GetModule()); } }
            if (nAC >= 6) { for (i=0; i<5; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_15_", GetModule()); } }
            if (nAC >= 6) { for (i=0; i<5; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_16_", GetModule()); } }
            if (nAC >= 6) { for (i=0; i<5; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_21_", GetModule()); } }
            if (nAC >= 5 && nAC < 7) { for (i=0; i<5; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_18_", GetModule()); } }
            if (nAC >= 2 && nAC < 5) { for (i=0; i<5; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_25_", GetModule()); } }
            if (nWeaponType == BASE_ITEM_LIGHTCROSSBOW || nWeaponType == BASE_ITEM_HEAVYCROSSBOW) { for (i=0; i<5; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_14_", GetModule()); } }
            if (GetLevelByClass(CLASS_TYPE_DRUID, oCreature)) { for (i=0; i<7; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_20_", GetModule()); } }
            if (GetLevelByClass(CLASS_TYPE_DRUID, oCreature)) { for (i=0; i<5; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_42_", GetModule()); } }
            if (GetLevelByClass(CLASS_TYPE_ROGUE, oCreature)) { for (i=0; i<7; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_26_", GetModule()); } }
            if (GetLevelByClass(CLASS_TYPE_BLACKGUARD, oCreature)) { for (i=0; i<15; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_38_", GetModule()); } }
            if (nWiz) { for (i=0; i<3; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_36_", GetModule()); } }
            if (nAC >= 1 && nAC <=4 && fAB >= 0.75) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_39_", GetModule()); }
            Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_53_", GetModule());
            if (nAC >= 4 && nAC <=6 && fAB >= 0.75) { for (i=0; i<4; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_40_", GetModule()); } }
            if (nAC >= 6) { for (i=0; i<3; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_41_", GetModule()); } }
            if (nAC >= 7) { for (i=0; i<5; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_43_", GetModule()); } }
            if (nAC >= 6) { for (i=0; i<3; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_45_", GetModule()); } }
            if (nAC >= 6) { for (i=0; i<3; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_46_", GetModule()); } }
            if (nAC <= 1) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_44_", GetModule()); } }
            if (nAC <= 1) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_47_", GetModule()); } }
            if (nAC == 5) { for (i=0; i<3; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "hu_m_48_", GetModule()); } }
        }
    }
    // NOT else if - half elves need to go here too
    if (nRace == RACIAL_TYPE_ELF || nRace == RACIAL_TYPE_HALFELF)
    {
        if (nGender == GENDER_FEMALE)
        {
            if (nAC <= 1) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_f_01_", GetModule()); } }
            if (nAC <= 2) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_f_03_", GetModule()); } }
            if (nAC <= 5) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_f_02_", GetModule()); } }
            if (nAC <= 6) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_f_04_", GetModule()); } }
            if (nAC <= 3) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_f_05_", GetModule()); } }
            if (nAC <= 1) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_f_06_", GetModule()); } }
            if (nAC <= 1) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_f_09_", GetModule()); } }
            if (nAC <= 1) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_f_10_", GetModule()); } }
            if (nAC <= 3) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_f_15_", GetModule()); } }
            if (nAC < 1 && nWiz) { for (i=0; i<5; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_f_14_", GetModule()); } }
            if (nAC < 1 && nWiz) { for (i=0; i<5; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_f_16_", GetModule()); } }
            if (nAC >= 4) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_f_07_", GetModule()); } }
            if (nAC <= 4) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_f_08_", GetModule()); } }
            Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_f_18_", GetModule());
            Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_f_19_", GetModule());
        }
        else if (nGender == GENDER_MALE)
        {
            if (nAC >= 6) { for (i=0; i<5; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_m_01_", GetModule()); } }
            if (nAC >= 6) { for (i=0; i<5; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_m_13_", GetModule()); } }
            if (nAC >= 4) { for (i=0; i<5; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_m_07_", GetModule()); } }
            if (nAC >= 2 && nAC <= 4) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_m_02_", GetModule()); } }
            if (nAC >= 2 && nAC <= 4) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_m_05_", GetModule()); } }
            if (nAC <= 2) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_m_09_", GetModule()); } }
            if (nAC >= 2 && nAC <= 4) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_m_10_", GetModule()); } }
            if (nWiz) { for (i=0; i<4; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_m_03_", GetModule()); } }
            if (nWiz) { for (i=0; i<4; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_m_06_", GetModule()); } }
            if (nWiz) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_m_11_", GetModule()); } }
            if (fAB >= 0.75) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_m_04_", GetModule()); } }
            if (fAB >= 0.75) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_m_12_", GetModule()); } }
            Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_m_08_", GetModule());
            Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "el_m_14_", GetModule());
        }
    }
    else if (nRace == RACIAL_TYPE_DWARF)
    {
        if (nGender == GENDER_MALE)
        {
            if (nAC >= 5) { for (i=0; i<4; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "dw_m_01_", GetModule()); } }
            if (nAC >= 5) { for (i=0; i<4; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "dw_m_03_", GetModule()); } }
            if (nAC >= 5) { for (i=0; i<4; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "dw_m_05_", GetModule()); } }
            if (nAC >= 6) { for (i=0; i<4; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "dw_m_06_", GetModule()); } }
            if (nAC >= 6) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "dw_m_11_", GetModule()); } }
            if (nAC >= 4) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "dw_m_07_", GetModule()); } }
            if (nAC >= 4) { for (i=0; i<3; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "dw_m_02_", GetModule()); } }
            if (nAC < 4) { for (i=0; i<3; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "dw_m_08_", GetModule()); } }
            if (nWiz) { for (i=0; i<3; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "dw_m_04_", GetModule()); } }
            if (nWiz) { for (i=0; i<3; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "dw_m_10_", GetModule()); } }
        }
        else if (nGender == GENDER_FEMALE)
        {
            if (nAC <= 4) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "dw_f_01_", GetModule()); } }
            if (nAC <= 4) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "dw_f_02_", GetModule()); } }
            if (nAC <= 4) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "dw_f_03_", GetModule()); } }
            if (nAC <= 4) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "dw_f_04_", GetModule()); } }
            if (nAC <= 4) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "dw_f_05_", GetModule()); } }
            if (nAC <= 4) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "dw_f_06_", GetModule()); } }
            if (nAC <= 4) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "dw_f_07_", GetModule()); } }
            if (nAC <= 4) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "dw_f_09_", GetModule()); } }
            if (nAC > 4) { for (i=0; i<2; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "dw_f_10_", GetModule()); } }
            if (nWiz) { for (i=0; i<6; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "dw_f_08_", GetModule()); } }
        }
    }
    else if (nRace == RACIAL_TYPE_GNOME)
    {
        if (nGender == GENDER_MALE)
        {
            Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "gn_m_08_", GetModule());
            if (!nWiz) {
                Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "gn_m_01_", GetModule());
                Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "gn_m_02_", GetModule());
                Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "gn_m_03_", GetModule());
                Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "gn_m_04_", GetModule());
                Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "gn_m_05_", GetModule());
            }
            else
            {
               Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "gn_m_06_", GetModule());
               Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "gn_m_06_", GetModule());
               Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "gn_m_07_", GetModule());
               Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "gn_m_07_", GetModule());
            }
        }
        else if (nGender == GENDER_FEMALE)
        {
            Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "gn_f_04_", GetModule());
            if (!nWiz)
            {
               Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "gn_f_02_", GetModule());
               Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "gn_f_03_", GetModule());
               Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "gn_f_05_", GetModule());
               if (nAC >= 6) { for (i=0; i<3; i++) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "gn_f_07_", GetModule()); } }
            }
            else
            {
               Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "gn_f_06_", GetModule());
               Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "gn_f_06_", GetModule());
            }
        }
    }
    else if (nRace == RACIAL_TYPE_HALFLING)
    {
        if (nGender == GENDER_FEMALE)
        {
            if (fAB >= 0.75 && nAC <= 4)
            {
                Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "ha_f_01_", GetModule());
                Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "ha_f_03_", GetModule());
                Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "ha_f_04_", GetModule());
                Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "ha_f_06_", GetModule());
                Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "ha_f_08_", GetModule());
            }
            if (nAC <= 4)
            {
                Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "ha_f_07_", GetModule());
                Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "ha_f_02_", GetModule());
            }
            if (nAC > 4)
            {
                Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "ha_f_05_", GetModule());
            }
        }
        else if (nGender == GENDER_MALE)
        {
            if (nAC >= 2 && nAC <= 4) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "ha_m_01_", GetModule()); }
            if (nAC <= 1) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "ha_m_02_", GetModule()); }
            if (nAC <= 1) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "ha_m_04_", GetModule()); }
            if (nAC <= 1) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "ha_m_06_", GetModule()); }
            if (nAC >= 1 && nAC <= 4) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "ha_m_07_", GetModule()); }
            if (nAC >= 5) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "ha_m_03_", GetModule()); }
            if (nAC >= 5) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "ha_m_05_", GetModule()); }
        }
    }
    else if (nRace == RACIAL_TYPE_HALFORC)
    {
        if (nGender == GENDER_MALE)
        {
            if (nWiz || GetLevelByClass(CLASS_TYPE_CLERIC, oCreature)) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "or_m_01_", GetModule()); }
            if (nAC >= 5) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "or_m_02_", GetModule()); }
            if (nAC >= 4) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "or_m_04_", GetModule()); }
            if (nAC >= 1 && nAC <= 4) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "or_m_05_", GetModule()); }
            if (nAC <= 3) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "or_m_07_", GetModule()); }
            if (nAC >= 4 && nAC < 6) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "or_m_08_", GetModule()); }
            if (fAB > 0.75) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "or_m_03_", GetModule()); }
        }
        else if (nGender == GENDER_FEMALE)
        {
            if (nWiz) { Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "or_f_05_", GetModule()); }
            else
            {
                Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "or_f_01_", GetModule());
                Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "or_f_02_", GetModule());
                Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "or_f_03_", GetModule());
                Array_PushBack_Str(RAND_APPEAR_TEMP_ARRAY, "or_f_04_", GetModule());
            }
        }
    }


    Array_Shuffle(RAND_APPEAR_TEMP_ARRAY, GetModule());

    string sPortrait = Array_At_Str(RAND_APPEAR_TEMP_ARRAY, 0, GetModule());
    //if (Array_Size(RAND_APPEAR_TEMP_ARRAY, GetModule()) == 0)
    if (GetStringLength(sPortrait) == 0)
    {
        if (GetGender(oCreature) == GENDER_MALE)
        {
            sPortrait = "hu_m_99_";
        }
        else
        {
            sPortrait = "hu_f_99_";
        }
    }
    SetPortraitResRef(oCreature, "po_" + sPortrait);
}

void RandomiseGenderAndAppearance(object oCreature=OBJECT_SELF)
{
    RandomiseCreatureGender(oCreature);
    RandomiseCreatureHead(oCreature);
    RandomiseSkinColour(oCreature);
    RandomiseHairColour(oCreature);
    RandomisePortrait(oCreature);
}


//void main(){}

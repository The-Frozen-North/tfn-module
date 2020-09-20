#include "nwnx_creature"
#include "nwnx_object"

void main()
{
    if (GetIsPC(OBJECT_SELF)) return;

    object oMaster = GetMaster(OBJECT_SELF);

// stop if no master
    if (GetMaster(OBJECT_SELF) == OBJECT_INVALID) return;

// stop if not familiar or animal companion
    if (GetAssociateType(OBJECT_SELF) != ASSOCIATE_TYPE_ANIMALCOMPANION && GetAssociateType(OBJECT_SELF) != ASSOCIATE_TYPE_FAMILIAR) return;

    int nHitDice = GetHitDice(oMaster)-1;
    float fHitDice = IntToFloat(nHitDice);

    float fScaleLevel, fStrengthLevel, fDexterityLevel, fConstitutionLevel, fIntelligenceLevel, fWisdomLevel, fCharismaLevel;

    float fTranslationLevel = 0.0;
    float fTranslation = 0.0;

    float fScale = 1.0;

    float fACLevel = 1.0;

    int nStrength, nDexterity, nConstitution, nIntelligence, nWisdom, nCharisma;
    int nBaseAC = 0;

    switch (GetAppearanceType(OBJECT_SELF))
    {
        case APPEARANCE_TYPE_BADGER:
            nBaseAC = 5;

            nStrength = 8;
            nDexterity = 17;
            nConstitution = 11;
            nIntelligence = 3;
            nWisdom = 12;
            nCharisma = 6;

            fConstitutionLevel = 0.5;
            fDexterityLevel = 1.0;
            fStrengthLevel = 0.5;

            fACLevel = 1.5;

            fScale = 1.2;
            fScaleLevel = 0.5;
        break;
        case APPEARANCE_TYPE_BAT:
            nBaseAC = 6;

            nStrength = 9;
            nDexterity = 15;
            nConstitution = 8;
            nIntelligence = 3;
            nWisdom = 14;
            nCharisma = 4;

            fConstitutionLevel = 0.25;
            fDexterityLevel = 0.75;
            fStrengthLevel = 0.25;

            fACLevel = 2.0;

            fScale = 1.2;
            fScaleLevel = 0.05;

            fTranslation = -1.5;
            fTranslationLevel = -0.15;
        break;
        case APPEARANCE_TYPE_BOAR_DIRE:
            nBaseAC = 3;

            nStrength = 13;
            nDexterity = 10;
            nConstitution = 13;
            nIntelligence = 3;
            nWisdom = 13;
            nCharisma = 4;

            fACLevel = 1.5;

            fConstitutionLevel = 0.75;
            fStrengthLevel = 0.75;

            fScale = 0.9;
            fScaleLevel = 0.04;
        break;
        case APPEARANCE_TYPE_BEAR_BROWN:

            nStrength = 15;
            nDexterity = 10;
            nConstitution = 14;
            nIntelligence = 3;
            nWisdom = 12;
            nCharisma = 6;

            fConstitutionLevel = 0.75;
            fDexterityLevel = 0.25;
            fStrengthLevel = 1.0;

            fScale = 0.7;
            fScaleLevel = 0.06;
        break;
        case APPEARANCE_TYPE_BEHOLDER_EYEBALL:
            nBaseAC = 4;

            nStrength = 6;
            nDexterity = 14;
            nConstitution = 10;
            nIntelligence = 8;
            nWisdom = 10;
            nCharisma = 12;


            fDexterityLevel = 0.5;
            fConstitutionLevel = 0.25;
            fStrengthLevel = 0.25;
            fCharismaLevel = 0.25;

            fScale = 1.0;
            fScaleLevel = 0.05;

            fTranslation = 0.0;
            fTranslationLevel = -0.075;
        break;
        case APPEARANCE_TYPE_FAERIE_DRAGON:
            nBaseAC = 3;

            nStrength = 10;
            nDexterity = 16;
            nConstitution = 11;
            nIntelligence = 13;
            nWisdom = 12;
            nCharisma = 12;

            fACLevel = 1.5;

            fDexterityLevel = 0.5;
            fConstitutionLevel = 0.25;
            fStrengthLevel = 0.25;

            fScale = 1.0;
            fScaleLevel = 0.04;

            fTranslation = 0.0;
            fTranslationLevel = -0.04;
        break;
        case APPEARANCE_TYPE_MEPHIT_FIRE:
            nBaseAC = 3;

            nStrength = 14;
            nDexterity = 12;
            nConstitution = 8;
            nIntelligence = 12;
            nWisdom = 12;
            nCharisma = 10;

            fStrengthLevel = 0.75;
            fDexterityLevel = 0.5;
            fConstitutionLevel = 0.5;

            fScale = 1.0;
            fScaleLevel = 0.03;

            fTranslation = 0.0;
            fTranslationLevel = -0.03;
        break;
        case APPEARANCE_TYPE_MEPHIT_ICE:
            nBaseAC = 4;

            nStrength = 12;
            nDexterity = 14;
            nConstitution = 8;
            nIntelligence = 12;
            nWisdom = 12;
            nCharisma = 10;


            fStrengthLevel = 0.5;
            fDexterityLevel = 0.75;
            fConstitutionLevel = 0.5;

            fScale = 1.0;
            fScaleLevel = 0.03;

            fTranslation = 0.0;
            fTranslationLevel = -0.03;
        break;
        case APPEARANCE_TYPE_DOG_HELL_HOUND:
            nBaseAC = 2;

            nStrength = 14;
            nDexterity = 12;
            nConstitution = 11;
            nIntelligence = 6;
            nWisdom = 10;
            nCharisma = 6;


            fDexterityLevel = 0.75;
            fConstitutionLevel = 0.5;
            fStrengthLevel = 1.0;

            fScale = 0.9;
            fScaleLevel = 0.04;
        break;
        case APPEARANCE_TYPE_SPIDER_GIANT:
            nBaseAC = 1;

            nStrength = 12;
            nDexterity = 14;
            nConstitution = 12;
            nIntelligence = 3;
            nWisdom = 10;
            nCharisma = 3;

            fDexterityLevel = 0.5;
            fConstitutionLevel = 0.25;
            fStrengthLevel = 0.25;

            fScale = 0.7;
            fScaleLevel = 0.06;
        break;
        case APPEARANCE_TYPE_DOG_WOLF:
            nBaseAC = 2;

            nStrength = 12;
            nDexterity = 14;
            nConstitution = 12;
            nIntelligence = 3;
            nWisdom = 12;
            nCharisma = 6;


            fDexterityLevel = 1.0;
            fConstitutionLevel = 0.75;
            fStrengthLevel = 0.75;

            fScale = 0.9;
            fScaleLevel = 0.04;
        break;
        case APPEARANCE_TYPE_DOG_DIRE_WOLF:
            nBaseAC = 3;

            nStrength = 14;
            nDexterity = 12;
            nConstitution = 12;
            nIntelligence = 3;
            nWisdom = 12;
            nCharisma = 10;


            fDexterityLevel = 0.5;
            fConstitutionLevel = 0.75;
            fStrengthLevel = 1.0;

            fScale = 0.7;
            fScaleLevel = 0.05;
        break;
        case APPEARANCE_TYPE_RAT_DIRE:
            nBaseAC = 5;

            nStrength = 8;
            nDexterity = 17;
            nConstitution = 11;
            nIntelligence = 3;
            nWisdom = 12;
            nCharisma = 6;

            fConstitutionLevel = 0.5;
            fDexterityLevel = 1.0;
            fStrengthLevel = 0.5;

            fACLevel = 1.5;

            fScale = 1.0;
            fScaleLevel = 0.5;
        break;
        case APPEARANCE_TYPE_FALCON:
            nBaseAC = 3;

            nStrength = 10;
            nDexterity = 17;
            nConstitution = 8;
            nIntelligence = 3;
            nWisdom = 14;
            nCharisma = 6;


            fDexterityLevel = 1.0;
            fConstitutionLevel = 0.25;
            fStrengthLevel = 0.5;

            fScale = 1.0;
            fScaleLevel = 0.04;

            fTranslation = 0.0;
            fTranslationLevel = -0.04;
        break;
        case APPEARANCE_TYPE_CAT_PANTHER:
            nBaseAC = 2;

            nStrength = 12;
            nDexterity = 16;
            nConstitution = 9;
            nIntelligence = 3;
            nWisdom = 12;
            nCharisma = 10;


            fDexterityLevel = 1.0;
            fConstitutionLevel = 0.25;
            fStrengthLevel = 0.25;

            fScale = 0.9;
            fScaleLevel = 0.04;
        break;
        case APPEARANCE_TYPE_IMP:
            nBaseAC = 4;

            nStrength = 10;
            nDexterity = 14;
            nConstitution = 10;
            nIntelligence = 17;
            nWisdom = 12;
            nCharisma = 10;

            fIntelligenceLevel = 0.75;
            fDexterityLevel = 0.5;

            fScale = 1.0;
            fScaleLevel = 0.03;

            fTranslation = 0.0;
            fTranslationLevel = -0.03;
        break;
        case APPEARANCE_TYPE_FAIRY:
            nBaseAC = 3;

            nStrength = 5;
            nDexterity = 14;
            nConstitution = 6;
            nIntelligence = 16;
            nWisdom = 16;
            nCharisma = 16;


            fDexterityLevel = 1.0;

            fScale = 2.0;
            fScaleLevel = 0.03;

            fTranslation = -1.25;
            fTranslationLevel = -0.125;
        break;
        case APPEARANCE_TYPE_PSEUDODRAGON:
            nBaseAC = 3;

            nStrength = 11;
            nDexterity = 15;
            nConstitution = 13;
            nIntelligence = 16;
            nWisdom = 16;
            nCharisma = 16;


            fDexterityLevel = 0.75;
            fConstitutionLevel = 0.5;
            fStrengthLevel = 0.5;

            fScale = 1.0;
            fScaleLevel = 0.04;

            fTranslation = 0.0;
            fTranslationLevel = -0.04;
        break;
        case APPEARANCE_TYPE_RAVEN:
            nBaseAC = 3;

            nStrength = 8;
            nDexterity = 19;
            nConstitution = 11;
            nIntelligence = 3;
            nWisdom = 12;
            nCharisma = 6;


            fDexterityLevel = 1.0;
            fConstitutionLevel = 0.25;
            fStrengthLevel = 0.25;

            fScale = 1.0;
            fScaleLevel = 0.04;

            fTranslation = 0.0;
            fTranslationLevel = -0.04;
        break;
    }

    if (nDexterity > nStrength) NWNX_Creature_AddFeat(OBJECT_SELF, FEAT_WEAPON_FINESSE);

    NWNX_Object_SetMaxHitPoints(OBJECT_SELF, (nHitDice+1)*8);
    NWNX_Object_SetCurrentHitPoints(OBJECT_SELF, GetMaxHitPoints(OBJECT_SELF));

    SetObjectVisualTransform(OBJECT_SELF, OBJECT_VISUAL_TRANSFORM_SCALE, fScale+(fScaleLevel*fHitDice));

    SetObjectVisualTransform(OBJECT_SELF, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, fTranslation+(fTranslationLevel*fHitDice));

    NWNX_Creature_SetLevelByPosition(OBJECT_SELF, 0, nHitDice+1);

    NWNX_Creature_SetRawAbilityScore(OBJECT_SELF, ABILITY_STRENGTH, nStrength+FloatToInt(fStrengthLevel*fHitDice));
    NWNX_Creature_SetRawAbilityScore(OBJECT_SELF, ABILITY_DEXTERITY, nDexterity+FloatToInt(fDexterityLevel*fHitDice));
    NWNX_Creature_SetRawAbilityScore(OBJECT_SELF, ABILITY_CONSTITUTION, nConstitution+FloatToInt(fConstitutionLevel*fHitDice));
    NWNX_Creature_SetRawAbilityScore(OBJECT_SELF, ABILITY_INTELLIGENCE, nIntelligence+FloatToInt(fIntelligenceLevel*fHitDice));
    NWNX_Creature_SetRawAbilityScore(OBJECT_SELF, ABILITY_WISDOM, nWisdom+FloatToInt(fWisdomLevel*fHitDice));
    NWNX_Creature_SetRawAbilityScore(OBJECT_SELF, ABILITY_CHARISMA, nCharisma+FloatToInt(fCharismaLevel*fHitDice));

    NWNX_Creature_SetBaseAC(OBJECT_SELF, nBaseAC+FloatToInt(fACLevel*fHitDice));
}

#include "inc_ctoken"

const float PERSUADE_DISCOUNT_MODIFIER = 0.66;
const float PERSUADE_BONUS_MODIFIER = 1.5;

const int GOLD_MODIFIER_CAP = 30;

const int CHARISMA_MODIFIER = 2;

// Returns the gold, increased by high charisma (eg quest reward).
int CharismaModifiedGold(object oPC, int nGold);

// Returns the gold cost of some service reduced by high charisma
// then discounted by successful persuade.
int CharismaModifiedPersuadeGold(object oPC, int nGold);

// Returns the gold, reduced by high charisma. (eg services)
int CharismaDiscountedGold(object oPC, int nGold);

// Round a gold value to a "reasonable" number. Asking someone for 276 gold seems a bit oddly specific?
int RoundedGoldValue(int nGold);

int RoundedGoldValue(int nGold)
{
    int nRet = nGold;
    if (nRet < 10) { return nRet; }
    if (nRet < 100) { return 5 * (nRet / 5); }
    if (nRet < 1000) { return 10 * (nRet / 10); }
    return 50 * (nRet / 50);
}

int CharismaModifiedGold(object oPC, int nGold)
{
    int nPCCharisma = (GetAbilityScore(oPC, ABILITY_CHARISMA) - 10);

    int nModifier = nPCCharisma*CHARISMA_MODIFIER;

    int nCap = GOLD_MODIFIER_CAP;

    if (nModifier > nCap) nModifier = nCap;
    if (nModifier < -nCap) nModifier = -nCap;

    float fModifier = 1.0 + (IntToFloat(nModifier)/100);

    int nRet = FloatToInt(IntToFloat(nGold) * fModifier);
    return RoundedGoldValue(nRet);
}

int CharismaModifiedPersuadeGold(object oPC, int nGold)
{
    int nRet = FloatToInt(CharismaDiscountedGold(oPC, nGold) * PERSUADE_DISCOUNT_MODIFIER);
    return RoundedGoldValue(nRet);
}

int CharismaDiscountedGold(object oPC, int nGold)
{
    int nPCCharisma = (GetAbilityScore(oPC, ABILITY_CHARISMA) - 10);

    int nModifier = nPCCharisma*CHARISMA_MODIFIER;

    int nCap = GOLD_MODIFIER_CAP;

    if (nModifier > nCap) nModifier = nCap;
    if (nModifier < -nCap) nModifier = -nCap;

    float fModifier = 1.0 - (IntToFloat(nModifier)/100);

    int nRet = FloatToInt(IntToFloat(nGold) * fModifier);
    return RoundedGoldValue(nRet);
}

//void main() {}

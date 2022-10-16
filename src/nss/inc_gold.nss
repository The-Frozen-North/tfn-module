const float PERSUADE_DISCOUNT_MODIFIER = 0.66;
const float PERSUADE_BONUS_MODIFIER = 1.5;

const int GOLD_MODIFIER_CAP = 30;
const int MERCHANT_MODIFIER_CAP = 20;

const int CHARISMA_MODIFIER = 2;

// Returns the gold, modifed by charisma.
int CharismaModifiedGold(object oPC, int nGold);

// Returns the gold, modifed by charisma and discounted by persuade.
int CharismaModifiedPersuadeGold(object oPC, int nGold);

// Returns the gold, discounted by charisma.
int CharismaDiscountedGold(object oPC, int nGold);

int CharismaModifiedGold(object oPC, int nGold)
{
    int nPCCharisma = (GetAbilityScore(oPC, ABILITY_CHARISMA) - 10);

    int nModifier = nPCCharisma*CHARISMA_MODIFIER;

    int nCap = GOLD_MODIFIER_CAP;

    if (nModifier > nCap) nModifier = nCap;
    if (nModifier < -nCap) nModifier = -nCap;

    float fModifier = 1.0 + (IntToFloat(nModifier)/100);

    return FloatToInt(IntToFloat(nGold) * fModifier);
}

int CharismaModifiedPersuadeGold(object oPC, int nGold)
{
    int nRet = FloatToInt(CharismaModifiedGold(oPC, nGold) * PERSUADE_DISCOUNT_MODIFIER);
    if (nRet < 10) { return nRet; }
    if (nRet < 100) { return 5 * (nRet / 5); }
    return 10 * (nRet / 10);
}

int CharismaDiscountedGold(object oPC, int nGold)
{
    int nPCCharisma = (GetAbilityScore(oPC, ABILITY_CHARISMA) - 10);

    int nModifier = nPCCharisma*CHARISMA_MODIFIER;

    int nCap = GOLD_MODIFIER_CAP;

    if (nModifier > nCap) nModifier = nCap;
    if (nModifier < -nCap) nModifier = -nCap;

    float fModifier = 1.0 - (IntToFloat(nModifier)/100);

    return FloatToInt(IntToFloat(nGold) * fModifier);
}

//void main() {}

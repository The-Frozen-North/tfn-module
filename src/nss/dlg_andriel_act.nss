#include "inc_gold"
#include "inc_treasuremap"
#include "inc_loot"
#include "inc_persist"
#include "inc_sqlite_time"

// See also: dlg_andriel_cond
// If changing gold costs, both files need updating

void main()
{
    object oPC = GetPCSpeaker();

    string sPersuaded = GetScriptParam("persuaded");

    int nHD = GetHitDice(oPC);
    int nGold = (140*GetTreasureMapGoldValue(nHD))/100;
    int nChaModified = CharismaDiscountedGold(oPC, nGold);
    // Persuade modified here is -15% cost, IE 85% of normal
    // This is because maps have actual gold return value
    // unlike paying for most other services
    int nPersuadeModified = RoundedGoldValue((nChaModified * 85)/100);

    int nRealCost = nChaModified;
    if (sPersuaded != "")
    {
        nRealCost = nPersuadeModified;
    }

    TakeGoldFromCreature(nRealCost, oPC, TRUE);

    IncrementPlayerStatistic(oPC, "gold_spent_from_buying", nRealCost);
    IncrementPlayerStatistic(oPC, "items_bought");

    int nACR = GetHitDice(oPC);
    // ACR of map = HD +/- 1
    nACR = nACR + Random(3) - 1;

    object oMap = SetupProgenitorTreasureMap(nACR, GetArea(OBJECT_SELF), 0, "It was purchased from " + GetName(OBJECT_SELF) +": there is no telling where it was originally from, nor where the treasure might be.");
    // Andriel's altered map difficulty
    int nRoll = d100();
    if (nRoll <= 80) { SetTreasureMapDifficulty(oMap, TREASUREMAP_DIFFICULTY_HARD); }
    else if (nRoll <= 85) { SetTreasureMapDifficulty(oMap, TREASUREMAP_DIFFICULTY_MEDIUM); }
    else if (nRoll <= 90) { SetTreasureMapDifficulty(oMap, TREASUREMAP_DIFFICULTY_EASY); }
    else { SetTreasureMapDifficulty(oMap, TREASUREMAP_DIFFICULTY_MASTER); }
    CopyTierItemFromStaging(oMap, oPC);
    SQLocalsPlayer_SetInt(oPC, "andriel_lastbuy", SQLite_GetTimeStamp());
}

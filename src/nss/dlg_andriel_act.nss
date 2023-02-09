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
    int nGold = GetTreasureMapGoldValue(nHD);
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

    int nACR = GetHitDice(oPC);
    int nVariability = GetHitDice(oPC) / 4;
    // ACR of map = HD ± HD/4 rounded down
    nACR = nACR + 1 + Random(nVariability*2) - nVariability;

    object oMap = SetupProgenitorTreasureMap(nACR, "Highcliff. It was purchased from " + GetName(OBJECT_SELF));
    CopyTierItemToContainer(oMap, oPC);
    SQLocalsPlayer_SetInt(oPC, "andriel_lastbuy", SQLite_GetTimeStamp());
}

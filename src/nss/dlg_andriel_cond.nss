#include "inc_gold"
#include "inc_treasuremap"
#include "inc_persist"
#include "inc_general"
#include "inc_sqlite_time"

// See also: dlg_andriel_act
// If changing gold costs, both files need updating

// 23h. If you felt so inclined you can do this at the same time every day
const int ANDRIEL_RESTOCK_DELAY = 82800;

int StartingConditional()
{
    object oPC = GetPCSpeaker();
    int nHD = GetHitDice(oPC);
    int nGold = (140*GetTreasureMapGoldValue(nHD))/100;
    int nChaModified = CharismaDiscountedGold(oPC, nGold);
    // Persuade modified here is -15% cost, IE 85% of normal
    // This is because maps have actual gold return value
    // unlike paying for most other services
    int nPersuadeModified = RoundedGoldValue((nChaModified * 85)/100);

    string sCanPersuade = GetScriptParam("canpersuade");
    if (sCanPersuade != "" && GetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+"_"+GetTag(OBJECT_SELF)+"_pers") == 1)
    {
        return 0;
    }
    // Can't persuade if you don't have the gold
    if (sCanPersuade != "" && GetGold(oPC) < nPersuadeModified)
    {
        return 0;
    }

    string sCanBuy = GetScriptParam("canbuy");
    if (sCanBuy != "" && GetGold(oPC) < nChaModified)
    {
        return 0;
    }

    string sPersuade = GetScriptParam("persuade");
    if (sPersuade != "")
    {
        int nSkill = SKILL_PERSUADE;
        int nDC = 14 + GetHitDice(oPC);

        if(!(GetIsSkillSuccessful(oPC, nSkill, nDC)))
        {
            IncrementPlayerStatistic(oPC, "persuade_failed");
            SetTemporaryInt(GetPCPublicCDKey(oPC, TRUE)+GetName(oPC)+"_"+GetTag(OBJECT_SELF)+"_pers", 1, 900.0);
            return FALSE;
        }
        IncrementPlayerStatistic(oPC, "persuade_succeeded");
    }

    string sHasMap = GetScriptParam("hasmap");
    string sFirst = GetScriptParam("first");
    int nLast = SQLocalsPlayer_GetInt(oPC, "andriel_lastbuy");
    if (nLast > 0 && sFirst != "")
    {
        return 0;
    }

    int nNow = SQLite_GetTimeStamp();
    if (sHasMap != "" && (nNow - nLast) < ANDRIEL_RESTOCK_DELAY)
    {
        return 0;
    }


    SetCustomToken(CTOKEN_TREASUREMAP_MERCHANT_COST, IntToString(nChaModified));
    SetCustomToken(CTOKEN_TREASUREMAP_MERCHANT_PERSUADE_COST, IntToString(nPersuadeModified));
    return 1;
}

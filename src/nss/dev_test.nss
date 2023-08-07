#include "inc_treasuremap"
#include "inc_loot"

void main()
{
    
    int nStart = GetMicrosecondCounter();
    object oMap = SetupProgenitorTreasureMap(12, GetArea(OBJECT_SELF), 1);
    CopyTierItemToObjectOrLocation(oMap, OBJECT_SELF);
    SendDebugMessage("time = " + IntToString(GetMicrosecondCounter() - nStart));
    
    /*
    sqlquery sql = SqlPrepareQueryCampaign("areadistances", "EXPLAIN QUERY PLAN SELECT areadest from areadists " +
    "WHERE areasource = @areasource AND distance <= @distance;");
    SqlBindString(sql, "@areasource", GetTag(GetArea(GetFirstPC())));
    SqlBindInt(sql, "@distance", 1000);
    SqlStep(sql);
    SpeakString(SqlGetString(sql, 0));
    SpeakString(SqlGetString(sql, 1));
    SpeakString(SqlGetString(sql, 2));
    SpeakString(SqlGetString(sql, 3));
    */
    
}
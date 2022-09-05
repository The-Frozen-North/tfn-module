int StartingConditional()
{
    // Trolls and ogres have the Giant class
    int bOkay = 1;
    int i;
    for (i=1; i<=2; i++)
    {
        string sArea = "pl_troll" + IntToString(i);
        object oArea = GetObjectByTag(sArea);
        object oTest = GetFirstObjectInArea(oArea);
        int nEnemyCount = 0;
        while (GetIsObjectValid(oTest))
        {
            if (GetObjectType(oTest) != OBJECT_TYPE_CREATURE || GetIsDead(oTest))
            {

            }
            else
            {
                if (GetLevelByClass(CLASS_TYPE_GIANT, oTest))
                {
                    nEnemyCount++;
                    if (nEnemyCount >= 15)
                    {
                        bOkay = 0;
                        break;
                    }
                }
            }
            oTest = GetNextObjectInArea(oArea);
        }
        if (!bOkay)
        {
            break;
        }
    }
    return bOkay;
}

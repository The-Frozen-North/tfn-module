void main()
{
    int nMaxHP = GetMaxHitPoints();

    int nHPThreshold = nMaxHP/10;

    if (nHPThreshold < 20)
        nHPThreshold = 20;

    int nCurrentHP = GetCurrentHitPoints();

     // * generic surrender should only fire once

    if((GetIsDead(OBJECT_SELF) == FALSE) && (nCurrentHP <= nHPThreshold) && GetLocalInt(OBJECT_SELF,"Generic_Surrender") == 0)
    {
        SetLocalInt(OBJECT_SELF, "Generic_Surrender",1);
        SetLocalInt(OBJECT_SELF, "no_rest",1);
        ChangeToStandardFaction(OBJECT_SELF, STANDARD_FACTION_COMMONER);
        SurrenderToEnemies();
        ClearAllActions();
        SpeakOneLinerConversation();
    }
}

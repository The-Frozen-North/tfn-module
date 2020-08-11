void main()
{
    if (GetIsNight()) return;

    int nTownCry = GetLocalInt(OBJECT_SELF, "town_cry");

    SetLocalInt(OBJECT_SELF, "town_cry", nTownCry+1);

    if (nTownCry >= 3)
    {
        DeleteLocalInt(OBJECT_SELF, "town_cry");

        string sPrepend = "Hear ye! Hear ye! ";
        string sMessage;

        switch (d8())
        {
            case 1: sMessage = "Zombie outbreak in the Beggar's Nest! All able-bodied men and women to report to Drake at the barricade to the Great Graveyard!"; break;
            case 2: sMessage = "Prison riot in the Peninsula! All soldiers and academy recruits to report to head gaoler Alaefin in the prison for orders!"; break;
            case 3: sMessage = "Sword Coast Boys roaming in the sewers and aqueducts! Speak to Harben Ashensmith in front on the aqueducts in the Docks for details on a bounty and reward!"; break;
            case 4: sMessage = "City ordinance for selling merchandise in effect! All sales must be conducted with Olgerd in the Docks district!"; break;
            case 5: sMessage = "Help wanted to find a missing brother! Speak to Jemanie in the Shining Serpent Inn in the Beggar's Nest for details!"; break;
            case 6: sMessage = "Sister lost in the prison! Reward offered for her safe return! Speak with Bethany near the prison for more information!"; break;
            case 7: sMessage = "Adventurers wanted to save Neverwinter! All able-bodied men and women to apply in the Adventurer's Academy in the Beggar's Nest!"; break;
            case 8: sMessage = "City gate closed until further notice! No one comes in or out of Neverwinter!"; break;
        }

        SpeakString(sPrepend+sMessage);
        ClearAllActions();
        PlayAnimation(ANIMATION_LOOPING_TALK_FORCEFUL, 1.0, 6.0);
    }
}

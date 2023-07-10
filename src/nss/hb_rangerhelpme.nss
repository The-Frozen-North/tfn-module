void main()
{

// stop if talking to another player
    if (IsInConversation(OBJECT_SELF)) return;

    if (GetIsDead(OBJECT_SELF)) return;

// check if the ranger is healed enough... and not the evil ranger!
    if (GetLocalInt(OBJECT_SELF, "no_credit") == 1 && GetCurrentHitPoints() >= 50)
    {
        DeleteLocalInt(OBJECT_SELF, "no_pet");
        DeleteLocalInt(OBJECT_SELF, "no_rest");

        SetLocalInt(OBJECT_SELF, "follower", 1);

        ChangeToStandardFaction(OBJECT_SELF, STANDARD_FACTION_DEFENDER);

        DeleteLocalString(OBJECT_SELF, "heartbeat_script");
        DeleteLocalString(OBJECT_SELF, "attack_script");
        DeleteLocalString(OBJECT_SELF, "damage_script");

        return;
    }
    else if (GetLocalInt(OBJECT_SELF, "semiboss") == 1)
    {
        object oPC = GetNearestCreature(CREATURE_TYPE_PLAYER_CHAR, PLAYER_CHAR_IS_PC, OBJECT_SELF, 1, CREATURE_TYPE_IS_ALIVE, TRUE, CREATURE_TYPE_PERCEPTION, PERCEPTION_SEEN);

        float fDistance = GetDistanceToObject(oPC);

        if (GetIsObjectValid(oPC) && fDistance > 0.0 && fDistance < 10.0)
        {
            SpeakOneLinerConversation("ranger_aggro");
             
            ExecuteScript("ranger_aggro");

            return;
        }

    }

    int nCount = GetLocalInt(OBJECT_SELF, "count");
    SetLocalInt(OBJECT_SELF, "count", nCount+1);

    if (nCount < 2) return;

    SpeakOneLinerConversation("ranger_helpme");

    ActionPlayAnimation(ANIMATION_LOOPING_SIT_CROSS, 1.0, 10.0);

}

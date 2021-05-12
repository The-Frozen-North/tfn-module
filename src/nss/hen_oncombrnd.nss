//::///////////////////////////////////////////////
//:: On Blocked
//:: NW_CH_ACE
//:: Copyright (c) 2001 Bioware Corp.
//:://////////////////////////////////////////////
/*
    This will cause blocked creatures to open
    or smash down doors depending on int and
    str.
*/
//:://////////////////////////////////////////////
//:: Created By: Preston Watamaniuk
//:: Created On: Nov 23, 2001
//:://////////////////////////////////////////////

#include "inc_hai_generic"
#include "inc_hai_assoc"
#include "inc_hai"


void main()
{
    object oDoor = GetBlockingDoor();

//    Jug_Debug(GetName(OBJECT_SELF) + " is blocked by " + GetName(oDoor));

    object oRealMaster = GetRealMaster();

    if (GetObjectType(oDoor) == OBJECT_TYPE_DOOR && GetIsObjectValid(oRealMaster)
        && !GetLocalInt(OBJECT_SELF, sHenchScoutingFlag) && !IsOnOppositeSideOfDoor(oDoor, oRealMaster, OBJECT_SELF))
    {
        ClearAllActions();
        ClearForceOptions();
        if (GetAssociateType(OBJECT_SELF) == ASSOCIATE_TYPE_HENCHMAN && (GetIsObjectValid(GetLocalObject(OBJECT_SELF, sHenchLastTarget)) || GetLocalInt(OBJECT_SELF, sHenchLastHeardOrSeen)))
        {
            DeleteLocalObject(OBJECT_SELF, sHenchLastTarget);
            ClearEnemyLocation();
            if (!GetLocalInt(oDoor, "tkDoorWarning"))
            {
                SpeakString(sHenchMonsterOnOtherSide);
                SetLocalInt(oDoor, "tkDoorWarning", TRUE);
            }
        }
        ActionForceFollowObject(oRealMaster, GetFollowDistance());
        return;
    }

    if(GetIsDoorActionPossible(oDoor, DOOR_ACTION_OPEN) && GetAbilityScore(OBJECT_SELF, ABILITY_INTELLIGENCE) >= 3)
    {
        DoDoorAction(oDoor, DOOR_ACTION_OPEN);
    }
    else if (GetIsDoorActionPossible(oDoor, DOOR_ACTION_UNLOCK))
    {
        DoDoorAction(oDoor, DOOR_ACTION_UNLOCK);
    }
    else if(GetIsDoorActionPossible(oDoor, DOOR_ACTION_BASH) && GetAbilityScore(OBJECT_SELF, ABILITY_STRENGTH) >= 16)
    {
        DoDoorAction(oDoor, DOOR_ACTION_BASH);
    }
}


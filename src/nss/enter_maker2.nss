#include "inc_loot"

void MakeGroundItem(object oTest)
{
    object oChestItem = SelectLootItemFromACR(OBJECT_INVALID, 12, LOOT_TYPE_WEAPON_MELEE, 5);
    location lLoc = GetLocation(oTest);
    lLoc = Location(GetAreaFromLocation(lLoc), GetPositionFromLocation(lLoc), IntToFloat(Random(360)));
    object oFloorItem = CopyTierItemFromStaging(oChestItem, OBJECT_INVALID, lLoc);
    SetLocalObject(oTest, "ground_weapon", oFloorItem);
}

void main()
{
    // Patrolling golems!
    int i;
    for (i=1; i<=5; i++)
    {
        object oGolem = GetLocalObject(OBJECT_SELF, "patrolling_" + IntToString(i));
        SetLocalString(oGolem, "heartbeat_script", "hb_maker2patrol");
    }
    object oLever = GetLocalObject(OBJECT_SELF, "hidden_lever");
    SetEventScript(oLever, EVENT_SCRIPT_PLACEABLE_ON_HEARTBEAT, "hb_maker2lever");
    // Spawn floor weapons
    // this can't be done in refresh or they will be cleaned up before a PC gets in to see them
    if (!GetLocalInt(OBJECT_SELF, "spawned_ground_weapons") && GetIsPC(GetEnteringObject()))
    {
        object oTest = GetFirstObjectInArea(OBJECT_SELF);
        while (GetIsObjectValid(oTest))
        {
            if (GetObjectType(oTest) == OBJECT_TYPE_WAYPOINT)
            {
                string sTag = GetTag(oTest);
                if (sTag == "maker_spawn_rand_weapon")
                {
                    if (Random(100) < 15)
                    {
                        //DelayCommand(6.0, MakeGroundItem(oTest));
                    }
                }
            }
            oTest = GetNextObjectInArea(OBJECT_SELF);
        }
        SetLocalInt(OBJECT_SELF, "spawned_ground_weapons", 1);
    }

}

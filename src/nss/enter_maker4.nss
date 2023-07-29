#include "inc_loot"
#include "inc_rand_equip"

void main()
{
    // Respawn sling/bullets if gone
    // if trap already done, no need to make them!
    if (GetLocalInt(OBJECT_SELF, "trap_fired")) { return; }
    object oSling = GetLocalObject(OBJECT_SELF, "puzzle_sling");
    if (!GetIsObjectValid(oSling) || (GetAreaFromLocation(GetLocation(oSling)) == OBJECT_SELF && !GetIsObjectValid(GetItemPossessor(oSling))))
    {
        object oWP = GetWaypointByTag("maker4_trap");
        vector vPos = GetPosition(oWP);
        vector vBullets = vPos + Vector(IntToFloat(Random(1000))/100 - 5.0, IntToFloat(Random(1000))/100 - 5.0, 0.0);
        vector vSling = vPos + Vector(IntToFloat(Random(1000))/100 - 5.0, IntToFloat(Random(1000))/100 - 5.0, 0.0);
        object oChestItem = GetTieredItemOfType(BASE_ITEM_BULLET, 1, 0);
        location lLoc = Location(OBJECT_SELF, vBullets, IntToFloat(Random(360)));
        object oFloorItem = CopyTierItemToObjectOrLocation(oChestItem, OBJECT_INVALID, lLoc);
        SetItemStackSize(oFloorItem, 10 + d4(3));
        SetLocalObject(OBJECT_SELF, "puzzle_bullets", oFloorItem);
        
        oChestItem = GetTieredItemOfType(BASE_ITEM_SLING, 1, 0);
        lLoc = Location(OBJECT_SELF, vSling, IntToFloat(Random(360)));
        oFloorItem = CopyTierItemToObjectOrLocation(oChestItem, OBJECT_INVALID, lLoc);
        SetLocalObject(OBJECT_SELF, "puzzle_sling", oFloorItem);
    }
}
#include "inc_treasuremap"

void main()
{
    if (GetIsInCombat(OBJECT_SELF))
    {
        FloatingTextStringOnCreature("You cannot examine the map in combat.", OBJECT_SELF);
        return;
    }
    object oMap = GetSpellCastItem();
    
    UseTreasureMap(oMap);
}

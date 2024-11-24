#include "inc_treasuremap"
#include "inc_horse"
#include "inc_itemevent"


void main()
{
    if (GetCurrentItemEventType() == ITEM_EVENT_ACTIVATED)
    {
        if (GetIsInCombat(OBJECT_SELF))
        {
            FloatingTextStringOnCreature("The shovel cannot be used in combat.", OBJECT_SELF);
            return;
        }
        if (GetIsMounted(OBJECT_SELF))
        {
            FloatingTextStringOnCreature("The shovel is not long enough to dig while mounted.", OBJECT_SELF);
            return;
        }
        location lSelf = GetLocation(OBJECT_SELF);
        int nSurfacemat = GetSurfaceMaterial(lSelf);
        // Things that are too hard to dig with a shovel
        if (!GetIsSurfacematDiggable(nSurfacemat))
        {
            if (nSurfacemat == 5)
            {
                FloatingTextStringOnCreature("Digging on a wooden surface would destroy it!", OBJECT_SELF, FALSE);
                return;
            }
            if (nSurfacemat == 9)
            {
                FloatingTextStringOnCreature("Digging up this carpet would destroy it!", OBJECT_SELF, FALSE);
                return;
            }
            else
            {
                FloatingTextStringOnCreature("This surface is too hard to dig.", OBJECT_SELF, FALSE);
                return;
            }
        }
        DigForTreasure(OBJECT_SELF);
    }
}

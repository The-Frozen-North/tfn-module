#include "inc_treasuremap"

void main()
{
    if (GetIsInCombat(OBJECT_SELF))
    {
        FloatingTextStringOnCreature("You cannot examine the map in combat.", OBJECT_SELF);
        return;
    }
    object oMap = GetSpellCastItem();
    location lSelf = GetLocation(OBJECT_SELF);
    int nSurfacemat = GetSurfaceMaterial(lSelf);
    if (!GetIsSurfacematDiggable(nSurfacemat) && DoesLocationCompleteMap(oMap, lSelf))
    {
        FadeToBlack(OBJECT_SELF, FADE_SPEED_MEDIUM);
        DelayCommand(2.0, FadeFromBlack(OBJECT_SELF, FADE_SPEED_MEDIUM));
        string sMessage = "You look carefully beneath your feet and find the hidden treasure!";
        if (nSurfacemat == 4 || nSurfacemat == 22)
        {
            sMessage = "After a careful search, you find the hidden treasure beneath a loose stone!";
        }
        else if (nSurfacemat == 5)
        {
            sMessage = "After a careful search, you find the hidden treasure beneath a loose plank!";
        }
        else if (nSurfacemat == 9)
        {
            sMessage = "After a careful search, you find the hidden treasure stashed beneath the carpet!";
        }
        DelayCommand(4.0, FloatingTextStringOnCreature(sMessage, OBJECT_SELF));
        DelayCommand(2.0, CompleteTreasureMap(oMap));
    }
    else
    {
        UseTreasureMap(oMap);
    }
}

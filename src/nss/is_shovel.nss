#include "inc_treasuremap"

void main()
{
    if (GetIsInCombat(OBJECT_SELF))
    {
        FloatingTextStringOnCreature("The shovel cannot be used in combat.", OBJECT_SELF);
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
    ClearAllActions();
    
    FadeToBlack(OBJECT_SELF, FADE_SPEED_MEDIUM);
    DelayCommand(4.0, FadeFromBlack(OBJECT_SELF, FADE_SPEED_MEDIUM));
    ActionPlayAnimation(ANIMATION_LOOPING_GET_LOW);
    DelayCommand(2.0, ApplyEffectAtLocation(DURATION_TYPE_INSTANT, EffectVisualEffect(VFX_COM_CHUNK_STONE_SMALL, FALSE, 0.25), lSelf));
    
	// Treasure maps.
    int nMaps = 0;
    object oTest = GetFirstItemInInventory(OBJECT_SELF);
    while (GetIsObjectValid(oTest))
    {
        if (GetTag(oTest) == "treasuremap")
        {
            if (DoesLocationCompleteMap(oTest, lSelf))
            {
                DelayCommand(2.0, CompleteTreasureMap(oTest));
                nMaps++;
            }
        }
        oTest = GetNextItemInInventory(OBJECT_SELF);
    }
    
    if (nMaps == 0)
    {
        DelayCommand(4.0, FloatingTextStringOnCreature("You dig a hole, but find nothing.", OBJECT_SELF, FALSE));
    }
    else
    {
        DelayCommand(4.0, FloatingTextStringOnCreature("You have found some buried treasure!", OBJECT_SELF));
    }
}

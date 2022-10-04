#include "inc_penalty"

void main()
{
    object oPlayer = OBJECT_SELF;
    int nXP = GetXP(oPlayer);
    // No penalty below level 3
    if (nXP >= 3000)
    {
        SetXP(oPlayer, GetXPOnRespawn(oPlayer));
        TakeGoldFromCreature(GetGoldLossOnRespawn(oPlayer), oPlayer, TRUE);
    }
}

#include "inc_penalty"

void main()
{
        object oPlayer = OBJECT_SELF;

        SetXP(oPlayer, GetXPOnRespawn(oPlayer));
        TakeGoldFromCreature(GetGoldLossOnRespawn(oPlayer), oPlayer, TRUE);
}

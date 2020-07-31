#include "inc_xp"

void main()
{
        object oPlayer = OBJECT_SELF;
        int nXP = GetXP(oPlayer);
        int nHD = GetLevelFromXP(nXP);
        int nPenalty = 25 * nHD;
// * You cannot lose a level by dying
        int nMin = ((nHD * (nHD - 1)) / 2) * 1000;

// you cannot be reduced below 1 xp
        if (nMin < 1) nMin = 1;

        int nNewXP = nXP - nPenalty;

        if (nNewXP < nMin) nNewXP = nMin;

        string sXPLoss = IntToString(nXP - nNewXP);

        int nGold = GetGold(oPlayer);
        int nGoldLoss = 0;

        if (nGold > 1) nGoldLoss = nGold/10;

        SetXP(oPlayer, nNewXP);
        TakeGoldFromCreature(nGoldLoss, oPlayer, TRUE);
}

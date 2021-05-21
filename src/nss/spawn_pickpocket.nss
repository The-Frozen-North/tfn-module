#include "inc_loot"

void InitializeForPickpocket(object oItem)
{
    SetDroppableFlag(oItem, FALSE);
    SetPickpocketableFlag(oItem, TRUE);
}

void main()
{
        SetLocalInt(OBJECT_SELF, "cr", FloatToInt(GetChallengeRating(OBJECT_SELF)));
        SetLocalInt(OBJECT_SELF, "area_cr", GetLocalInt(GetArea(OBJECT_SELF), "cr"));


        int nRandom = d6();

        if (nRandom == 6)
        {
           InitializeForPickpocket(GenerateLoot(OBJECT_SELF));
           InitializeForPickpocket(GenerateLoot(OBJECT_SELF));
           InitializeForPickpocket(GenerateLoot(OBJECT_SELF));
        }
        else if (nRandom > 3)
        {
            InitializeForPickpocket(GenerateLoot(OBJECT_SELF));
            InitializeForPickpocket(GenerateLoot(OBJECT_SELF));
        }
        else
        {
            InitializeForPickpocket(GenerateLoot(OBJECT_SELF));
        }
}

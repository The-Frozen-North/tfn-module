#include "inc_loot"

void main()
{
    int i;
    int bNonUnique;
    int nMax = d4(5);
    for (i = 0; i < nMax; i++)
    {
        SelectLootItemFixedTierEqualLootTypeOdds(OBJECT_SELF, 3, LOOT_TYPE_ANY, PAWNSHOP_CHANCE_TO_ALLOW_UNIQUE);
    }

    nMax = d3(2);
    for (i = 0; i < nMax; i++)
    {
        SelectLootItemFixedTierEqualLootTypeOdds(OBJECT_SELF, 4, LOOT_TYPE_ANY, PAWNSHOP_CHANCE_TO_ALLOW_UNIQUE);
    }
    
    for (i = 0; i < 2; i++)
    {
        if (Random(100) < STORE_RANDOM_T5_CHANCE)
        {
            SelectLootItemFixedTierEqualLootTypeOdds(OBJECT_SELF, 5, LOOT_TYPE_ANY, PAWNSHOP_CHANCE_TO_ALLOW_UNIQUE);
        }
    }
}

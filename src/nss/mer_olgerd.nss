#include "inc_loot"

void main()
{
    int nItems = d20(20);
    int i;
    
    for (i = 0; i < nItems; i++)
    {
        SelectLootItemFromACREqualLootTypeOdds(OBJECT_SELF, 4, LOOT_TYPE_ANY);
    }

    int bNonUnique;

    int nMax = d4(7);
    for (i = 0; i < nMax; i++)
    {
        SelectLootItemFixedTierEqualLootTypeOdds(OBJECT_SELF, 3, LOOT_TYPE_ANY, PAWNSHOP_CHANCE_TO_ALLOW_UNIQUE);
    }

    nMax = d2(3);
    for (i = 0; i < nMax; i++)
    {
        SelectLootItemFixedTierEqualLootTypeOdds(OBJECT_SELF, 4, LOOT_TYPE_ANY, PAWNSHOP_CHANCE_TO_ALLOW_UNIQUE);
    }

    for (i = 0; i < 3; i++)
    {
        if (Random(100) < STORE_RANDOM_T5_CHANCE)
        {
            SelectLootItemFixedTierEqualLootTypeOdds(OBJECT_SELF, 5, LOOT_TYPE_ANY, PAWNSHOP_CHANCE_TO_ALLOW_UNIQUE);
        }
    }
}

#include "inc_loot"

void InitializeForPickpocket(object oItem)
{
    SetDroppableFlag(oItem, FALSE);
    SetPickpocketableFlag(oItem, TRUE);
}

void main()
{
        SetLocalInt(OBJECT_SELF, "cr", 6);
        SetLocalInt(OBJECT_SELF, "area_cr", GetLocalInt(GetArea(OBJECT_SELF), "cr"));

        int i;
        for (i=0; i<5; i++)
            InitializeForPickpocket(SelectLootItemForLootSource(OBJECT_SELF, OBJECT_SELF));
}

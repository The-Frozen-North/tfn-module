#include "inc_loot"

void main()
{
	object oUser = GetLastUsedBy();
	string sOwnerKey = GetLocalString(OBJECT_SELF, "owner");
	if (GetPCPublicCDKey(oUser) != sOwnerKey)
	{
		FloatingTextStringOnCreature("This isn't your treasure!", oUser, FALSE);
		return;
	}
    ActionPlayAnimation(ANIMATION_PLACEABLE_OPEN);
	
	int nGenerated = GetLocalInt(OBJECT_SELF, "doneloot");
	if (!nGenerated)
	{
		SetLocalInt(OBJECT_SELF, "boss", 1);
		int i;
		int nTries = d2(2);
		for (i=0; i<nTries; i++)
		{
			SetScriptParam("exclusivelooter", ObjectToString(oUser));
			ExecuteScript("party_credit");
			DeleteLocalInt(OBJECT_SELF, "no_credit");
		}
        object oPersonalLoot = GetObjectByUUID(GetLocalString(OBJECT_SELF, "personal_loot_"+GetPCPublicCDKey(oUser, TRUE)));        
        int nGoldToAdd = 0;
        object oTest = GetFirstItemInInventory(oPersonalLoot);
        while (GetIsObjectValid(oTest))
        {
            int nIdentified = GetIdentified(oTest);
            SetIdentified(oTest, TRUE);
            int nGold = GetGoldPieceValue(oTest);
            int nTurnToGold = 0;
            if (nGold < 200)
            {
                nTurnToGold = 1;
            }
            else if (!GetIsItemPropertyValid(GetFirstItemProperty(oTest)))
            {
                nTurnToGold = 1;
            }
            if (nTurnToGold && GetTag(oTest) != "treasuremap")
            {
                nGoldToAdd += nGold;
                DestroyObject(oTest);
            }
            SetIdentified(oTest, nIdentified);
            oTest = GetNextItemInInventory(oPersonalLoot);
        }
        SetLocalInt(oPersonalLoot, PERSONAL_LOOT_GOLD_AMOUNT, GetLocalInt(oPersonalLoot, PERSONAL_LOOT_GOLD_AMOUNT) + nGoldToAdd);
		SetLocalInt(OBJECT_SELF, "doneloot", 1);
	}

	ExecuteScript("loot_open");
}
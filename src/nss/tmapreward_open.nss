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
        string sPersonalLootVar = "personal_loot_"+GetPCPublicCDKey(oUser, TRUE);
        object oPersonalLoot = GetObjectByUUID(GetLocalString(OBJECT_SELF, sPersonalLootVar));        
        
        // Unfortunately making and destroying items like this messes up the inventory grid
        // and you frequently end up with items on page 2 that would fit on page 1
        // The easiest fix I can see for this is to remake personal loot and copy everything over
        // ... which we may as well do while we're looping through the inventory and gold-ifying items anyway!
        object oPersonalLootNew = CreateObject(OBJECT_TYPE_PLACEABLE, "_loot_personal", GetLocation(oPersonalLoot), FALSE);
        DestroyObject(oPersonalLootNew, LOOT_DESTRUCTION_TIME); // Personal loot will no longer be accessible after awhile
        ForceRefreshObjectUUID(oPersonalLootNew);
        SetLocalString(OBJECT_SELF, sPersonalLootVar, GetObjectUUID(oPersonalLootNew));
        SetLocalString(oPersonalLootNew, "loot_parent_uuid", GetObjectUUID(OBJECT_SELF));
        
        int nGoldToAdd = 0;
        object oTest = GetFirstItemInInventory(oPersonalLoot);
        while (GetIsObjectValid(oTest))
        {
            int nIdentified = GetIdentified(oTest);
            SetIdentified(oTest, TRUE);
            int nGold = GetGoldPieceValue(oTest);
            SetIdentified(oTest, nIdentified);
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
            }
            else
            {
                // If this item isn't being gold-ified, copy it to the new personal loot
                // For nice inventory grid placement!
                CopyItem(oTest, oPersonalLootNew, TRUE);
            }
            DestroyObject(oTest);
            oTest = GetNextItemInInventory(oPersonalLoot);
        }
        SetLocalInt(oPersonalLootNew, PERSONAL_LOOT_GOLD_AMOUNT, GetLocalInt(oPersonalLoot, PERSONAL_LOOT_GOLD_AMOUNT) + nGoldToAdd);
		SetLocalInt(OBJECT_SELF, "doneloot", 1);
        
        // Done with the old personal loot now too.
        DestroyObject(oPersonalLoot);
	}

	ExecuteScript("loot_open");
}
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
        int nACR = GetLocalInt(OBJECT_SELF, "area_cr");
        int nNewMapACR = 1 + nACR + (nACR / 6);
        if (nNewMapACR > TREASUREMAP_ACR_MAX) { nNewMapACR = TREASUREMAP_ACR_MAX; }
        int nParentDifficulty = GetLocalInt(OBJECT_SELF, "parent_map_difficulty");
        int nNewDifficulty = nParentDifficulty + 1;
        if (nNewDifficulty > TREASUREMAP_HIGHEST_DIFFICULTY)
        {
            nNewDifficulty = TREASUREMAP_HIGHEST_DIFFICULTY;
        }
        WriteTimestampedLogEntry(GetName(oUser) + " completed a treasure map difficulty " + IntToString(nParentDifficulty) + " and acr " + IntToString(nACR));
        int nDowngradeChance = TREASUREMAP_REWARD_DOWNGRADE_EASY;
        if (nParentDifficulty == TREASUREMAP_DIFFICULTY_MEDIUM) { nDowngradeChance = TREASUREMAP_REWARD_DOWNGRADE_MEDIUM; }
        else if (nParentDifficulty == TREASUREMAP_DIFFICULTY_HARD) { nDowngradeChance = TREASUREMAP_REWARD_DOWNGRADE_HARD; }
        else if (nParentDifficulty == TREASUREMAP_DIFFICULTY_MASTER) { nDowngradeChance = TREASUREMAP_REWARD_DOWNGRADE_MASTER; }
		int i;
		int nTries = d2(2);
		for (i=0; i<nTries; i++)
		{
            if (i == 0)
            {
                SetLocalInt(OBJECT_SELF, "boss", 1);
            }
            else if (Random(100) < nDowngradeChance)
            {
                DeleteLocalInt(OBJECT_SELF, "boss");
                SetLocalInt(OBJECT_SELF, "semiboss", 1);
            }
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
            nGold = (nGold * TREASUREMAP_MUNDANE_ITEM_GOLD_CONVERSION_RATE)/100;
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
                
                // It's kinda nice if map "chains" go up in difficulty a bit
                if (GetTag(oTest) == "treasuremap")
                {
                    SetLocalInt(oTest, "acr", nNewMapACR);
                    // 50% to be local, 50% to full random
                    if (Random(100) < 50)
                    {
                        AssignNewPuzzleToMap(oTest, OBJECT_INVALID, 0);
                    }
                    else
                    {
                        AssignNewPuzzleToMap(oTest, GetArea(OBJECT_SELF), 1);
                    }
                    SetTreasureMapDifficulty(oTest, nNewDifficulty);
                }
                CopyItem(oTest, oPersonalLootNew, TRUE);
            }
            DestroyObject(oTest);
            oTest = GetNextItemInInventory(oPersonalLoot);
        }
        if (Random(100) < 15)
        {
            object oProgenitor = SetupProgenitorTreasureMap(nNewMapACR, GetArea(OBJECT_SELF), (d2() == 2));
            SetTreasureMapDifficulty(oProgenitor, nNewDifficulty);
            CopyTierItemFromStaging(oProgenitor, oPersonalLootNew);
        }
        SetLocalInt(oPersonalLootNew, PERSONAL_LOOT_GOLD_AMOUNT, GetLocalInt(oPersonalLoot, PERSONAL_LOOT_GOLD_AMOUNT) + nGoldToAdd);
		SetLocalInt(OBJECT_SELF, "doneloot", 1);
        
        // Done with the old personal loot now too.
        DestroyObject(oPersonalLoot);
	}

	ExecuteScript("loot_open");
}
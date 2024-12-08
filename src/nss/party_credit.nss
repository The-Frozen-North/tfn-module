#include "inc_quest"
#include "inc_treasure"
#include "inc_henchman"
#include "inc_key"
#include "inc_party"
#include "inc_sql"

// The max distance in meters a player can be from
// a target killed by a trap, and still get xp.
const float TRAP_DST_MAX = 100.0;

void SendLootMessage(object oHench, object oItem, int bUnidentified)
{

    object oOwner = oHench;

    if (GetIsDead(oOwner))
        return;

    string sName = GetName(oItem);

    if (sName == "")
    {
        if (!GetIsObjectValid(oItem))
            return;
        int nBaseItem = GetBaseItemType(oItem);

        switch (nBaseItem)
        {
            case BASE_ITEM_CSLASHWEAPON:          return; break;
            case BASE_ITEM_CPIERCWEAPON:          return; break;
            case BASE_ITEM_CBLUDGWEAPON:          return; break;
            case BASE_ITEM_CSLSHPRCWEAP:          return; break;
            case BASE_ITEM_CREATUREITEM:          return; break;
            case BASE_ITEM_GOLD:                  return; break;
            case BASE_ITEM_CRAFTMATERIALMED:      return; break;
            case BASE_ITEM_CRAFTMATERIALSML:      return; break;
        }
    }

    if (bUnidentified)
    {
        switch (d4())
        {
            case 1: PlayVoiceChat(VOICE_CHAT_LOOKHERE, oOwner); break;
            case 2: PlayVoiceChat(VOICE_CHAT_CHEER, oOwner); break;
        }
    }

    object oPC = GetFirstFactionMember(oOwner);
    while (GetIsObjectValid(oPC))
    {
        if (GetArea(oPC) == GetArea(oOwner))
        {
            //NWNX_Player_FloatingTextStringOnCreature(oPC, oOwner, "*"+GetName(oOwner)+" receives "+sName+"*");
            // this is probably better because it mirrors how players pick up items
            SendMessageToPC(oPC, GetName(oOwner)+" Acquired Item: "+sName);
        }

        oPC = GetNextFactionMember(oPC);
    }
}

void GiveItemToHenchman(object oItem, object oHenchmanStore, object oHench, int nNth)
{
    object oNewItem;
    if (GetBaseItemType(oItem) == BASE_ITEM_POTIONS)
    {
        oNewItem = CopyTierItemFromStaging(oItem, oHench);
        SetDroppableFlag(oNewItem, FALSE);
        SetPickpocketableFlag(oNewItem, FALSE);
    }
    else
    {
        oNewItem = CopyTierItemFromStaging(oItem, oHenchmanStore);
    }
    AssignCommand(GetModule(), DelayCommand(IntToFloat(nNth)+1.0+(IntToFloat(d8())*0.1), SendLootMessage(oHench, oNewItem, GetIdentified(oItem))));
}

// Convenience function. Add oItem to the list of items assigned to the party member at nIndex.
// Takes the jAssignments array object and returns the new version
json _AddItemToPartyMemberAssignments(json jAssignments, object oItem, int nIndex)
{
    if (nIndex < 1)
    {
        return jAssignments;
    }
    //WriteTimestampedLogEntry("Index = " + IntToString(nIndex) + ", Before: " + JsonDump(jAssignments));
    json jArray = JsonArrayGet(jAssignments, nIndex);
    jArray = JsonArrayInsert(jArray, JsonString(ObjectToString(oItem)));
    jAssignments = JsonArraySet(jAssignments, nIndex, jArray);
    //WriteTimestampedLogEntry("After: " + JsonDump(jAssignments));
    return jAssignments;
}


void main()
{
// this should never trigger on a PC, nunless it's DM-possessed
   if (GetIsPC(OBJECT_SELF) == TRUE && GetIsDMPossessed(OBJECT_SELF) == FALSE) return;

// if it is tagged for no credit, also stop
   if (GetLocalInt(OBJECT_SELF, "no_credit") == 1) return;

// no credit after it's been triggered
   SetLocalInt(OBJECT_SELF, "no_credit", 1);

// Store  party data
   SetPartyData();

// stop if there are 0 players around
   if (Party.TotalSize == 0) return;

// determine if the creature killed was an ambush
   int bAmbush = FALSE;
   if (GetLocalInt(OBJECT_SELF, "ambush") == 1)
   {
     SendDebugMessage("Creature killed was from an ambush.");
     bAmbush = TRUE;
   }

// =========================
// START LOOT CONTAINER CODE
// =========================

   int bNoTreasure = FALSE;
   int bAnimalLoot = FALSE;
   object oContainer, oPersonalLoot;
   int nUnlooted;
   string sQuestItemResRef;

// if the hit points of the object is 0 or less than 0,
// assume it is a dead creature or destroyed treasure
// we shall roll to see if treasure even drops at that point.
    int bDestroyed = GetCurrentHitPoints(OBJECT_SELF) <= 0;

    int bBoss = GetLocalInt(OBJECT_SELF, "boss");
    int bSemiBoss = GetLocalInt(OBJECT_SELF, "semiboss");
    int bRare = GetLocalInt(OBJECT_SELF, "rare");

    int iCR = GetLocalInt(OBJECT_SELF, "cr");
    int iAreaCR = GetLocalInt(OBJECT_SELF, "area_cr");

    int nChanceThree = CHANCE_THREE;
    int nChanceTwo = CHANCE_TWO;
    int nChanceOne = CHANCE_ONE;
    int nTreasureChance = 100;

    int bIsPlaceable = GetObjectType(OBJECT_SELF) == OBJECT_TYPE_PLACEABLE;

    if (bDestroyed)
    {
        nTreasureChance = FloatToInt(fmin(100.0, TREASURE_CHANCE * pow(2.0, (iCR - iAreaCR)/TREASURE_CHANCE_EXPONENT_DENOMINATOR)));
        //if (ShouldDebugLoot())
        if (1)
        {
            SendDebugMessage("Treasure chance at MCR " + IntToString(iCR) + " and ACR " + IntToString(iAreaCR) + " = " + IntToString(nTreasureChance));
        }

        if (GetLocalInt(OBJECT_SELF, "half_loot") == 1) nTreasureChance = nTreasureChance/2;

        if ((bBoss == 1) || (bSemiBoss == 1) || (bRare == 1))
        {
            nTreasureChance = 100;
        }

        if (d100() > nTreasureChance)
        {
            bNoTreasure = TRUE;
        }

        int nRace = GetRacialType(OBJECT_SELF);
        switch (nRace)
        {
            case RACIAL_TYPE_MAGICAL_BEAST:
            case RACIAL_TYPE_ANIMAL:
            case RACIAL_TYPE_VERMIN:
            case RACIAL_TYPE_BEAST:
            {
               // no treasure or loot at all from small animals, including hides skins pelts etc
               if (GetCreatureSize(OBJECT_SELF) < CREATURE_SIZE_MEDIUM)
               {
                   bNoTreasure = TRUE;
               }
               else
               {
                   bAnimalLoot = TRUE;
               }
            }
            break;
        }

        if (GetLocalInt(OBJECT_SELF, "animal_loot") == 1)
        {
            bAnimalLoot = TRUE;
        }
        if (GetLocalInt(OBJECT_SELF, "no_animal_loot"))
        {
            bAnimalLoot = FALSE;
        }
    }

    // Placeables always yield treasure, even if you bash them to pieces
    // (how hard do you have to bonk a coin before it's not gold any more?)
    // Destroying them lowers the chances of getting items though
    // And some have higher chances to contain more items
    if (bIsPlaceable)
    {
        bNoTreasure = FALSE;
        nTreasureChance = 100;
        float fTreasureMultiplier = 1.0;
        float fQuantityMult = GetLocalFloat(OBJECT_SELF, "quantity_mult");
        if (fQuantityMult > 0.0)
        {
            fTreasureMultiplier = fQuantityMult;
        }
        if (bDestroyed)
        {
            fTreasureMultiplier *= PLACEABLE_DESTROY_LOOT_PENALTY;
        }
        nChanceOne = FloatToInt(IntToFloat(nChanceOne) * fTreasureMultiplier);
        nChanceTwo = FloatToInt(IntToFloat(nChanceTwo) * fTreasureMultiplier);
        nChanceThree = FloatToInt(IntToFloat(nChanceThree) * fTreasureMultiplier);
    }

// ambushes never yield treasure
    if (bAmbush)
    {
        bNoTreasure = TRUE;
        nTreasureChance = 0;
    }

// determine if there is a key
    object oItem = GetFirstItemInInventory(OBJECT_SELF);
    object oKey;
    while (GetIsObjectValid(oItem))
    {
        if (GetBaseItemType(oItem) == BASE_ITEM_KEY || GetLocalInt(oItem, "is_key"))
        {
            oKey = oItem;
            break;
        }

        oItem = GetNextItemInInventory(OBJECT_SELF);
    }
    if (GetIsObjectValid(oKey))
    {
        nTreasureChance = 100;
    }

    if (GetLocalString(OBJECT_SELF, "quest1") != "")
    {
        bNoTreasure = FALSE;
        nTreasureChance = 100;
    }

    if (GetLocalString(OBJECT_SELF, "quest_item") != "")
    {
        bNoTreasure = FALSE;
        nTreasureChance = 100;
    }

    if (ShouldDebugLoot() && nTreasureChance > 0)
    {
        // Always make a container if debugging and there's a chance this enemy type drops something
        bNoTreasure = FALSE;
    }

// only proceed if there is treasure or a key
    if (!bNoTreasure || GetIsObjectValid(oKey))
    {
// if destroyed, the container is a loot bag
        if (bDestroyed)
        {
            oContainer = CreateObject(OBJECT_TYPE_PLACEABLE, "_loot_container", GetLocation(OBJECT_SELF));
            SetLocalInt(oContainer, "cr", iCR);
            SetLocalInt(oContainer, "area_cr", iAreaCR);

// Pass on any quest variables, if any
            SetLocalString(oContainer, "quest1", GetLocalString(OBJECT_SELF, "quest1"));
            SetLocalString(oContainer, "quest_item", GetLocalString(OBJECT_SELF, "quest_item"));

            DestroyObject(oContainer, LOOT_DESTRUCTION_TIME); // destroy loot bag after awhile
        }
// otherwise, the container is itself
        else
        {
            oContainer = OBJECT_SELF;
        }
        ForceRefreshObjectUUID(oContainer); // assign a UUID to this container

        sQuestItemResRef = GetLocalString(oContainer, "quest_item");

        nUnlooted = Party.PlayerSize;

        SetLocalInt(oContainer, "unlooted", nUnlooted);
    }

    int nTotalSize = Party.PlayerSize+Party.HenchmanSize;

// only distribute gold if there is treasure
    int nGold = 0;
    int nGoldToDistribute = 0;
    // also avoid dropping empty lootbags for people who have the key already
    if (!bAnimalLoot && (!bNoTreasure || GetIsObjectValid(oKey)))
    {
        if (ShouldDebugLoot())
        {
            // This is the gold drop rate, set it on the module so it gets counted correctly
            float fTreasureChance = IntToFloat(nTreasureChance)/100.0;
            SetLocalFloat(GetModule(), LOOT_DEBUG_DROP_CHANCE_MULT, fTreasureChance);
        }
        if (bBoss == 1) nGold = DetermineGoldFromCR(iAreaCR, BOSS_GOLD_MULTIPLIER);
        else if (bSemiBoss == 1 || bRare == 1) nGold = DetermineGoldFromCR(iAreaCR, SEMIBOSS_RARE_GOLD_MULTIPLIER);
        else
        {
            nGold = DetermineGoldFromCR(iAreaCR);
        }
        nGoldToDistribute = nGold/max(1, nTotalSize);

// remove henchman gold now, if they exist
        if (Party.HenchmanSize > 0) nGold = nGold - Party.HenchmanSize*nGoldToDistribute;
    }

// Calculate how many items to make, and to which player it goes to
   int nNumItems = 0;

   int nItemsRoll = d100();

// boss always give a guaranteed 3 items
   if (bBoss)
   {
       nChanceThree = 100;
       nChanceTwo = 0;
       nChanceOne = 0;
   }

// no items
   float fLootBagScale = 0.9;

   if (nItemsRoll <= nChanceThree)
   {
       nNumItems = 3;
       fLootBagScale = 1.4;
   }
   // rares always guarantees at least 2 items
   else if (nItemsRoll <= nChanceTwo || (bRare == 1))
   {
       nNumItems = 2;
       fLootBagScale = 1.25;
   }
   else if ((nItemsRoll <= nChanceOne) || (bSemiBoss == 1))
   {
       nNumItems = 1;
       fLootBagScale = 1.1;
   }

    if (ShouldDebugLoot())
    {
        float fTreasureChance = IntToFloat(nTreasureChance)/100.0;
        float fChanceThree = IntToFloat(nChanceThree)/100.0;
        float fChanceTwo = IntToFloat(nChanceTwo - nChanceThree)/100.0;
        float fChanceOne = IntToFloat(nChanceOne - (nChanceTwo + nChanceThree))/100.0;
        fChanceThree = fmin(1.0, fmax(0.0, fChanceThree));
        fChanceTwo = fmin(1.0, fmax(0.0, fChanceTwo));
        fChanceOne = fmin(1.0, fmax(0.0, fChanceOne));

        float fExpected = fTreasureChance * (fChanceOne + (2.0 * fChanceTwo) + (3.0 * fChanceThree));
        SendDebugMessage("Expected number of items from " + GetName(OBJECT_SELF) +": " + FloatToString(fExpected));
        //SendDebugMessage("fTreasureChance = " + FloatToString(fTreasureChance));
        SetLocalFloat(GetModule(), LOOT_DEBUG_DROP_CHANCE_MULT, fExpected);

        // Force it to always roll only one item when debugging
        // This is so that one call is always done to the item selector which updates the logging variables correctly
        // Because we just calculated the correct expected amount of items
        // It will mean that the actual items created will not be correct though, but that's a small price to pay for science
        // plus if you can run this you can just warp to the treasure area and loot whatever you want anyway
        nNumItems = 1;
        bNoTreasure = FALSE;
    }

// =========================
// END LOOT CONTAINER CODE
// =========================

   float fXP = GetPartyXPValue(OBJECT_SELF, bAmbush, Party.AverageLevel, Party.TotalSize);


// =============================
// ASSIGN ITEMS TO PARTY MEMBERS
// =============================

   // Each item in this array is another array that contains the items assigned to this position
   json jAssignments = JsonArray();

   // Eg three items: me (party index 1) gets a longsword, Daelan (party index 2) gets a shortbow and a gem
   // This array looks like:
   // 0: <nothing> (we index party members starting at 1 here)
   // 1: Array(longsword) -> goes to me
   // 2: Array(shortbow, gem) -> goes to daelan
   // The objects themselves are saved as ObjectToStrings of the real objects.

   // This approach should prove a lot more flexible when it comes to adding and assigning special bonus drops
   // that count towards the gold debt system which exist outside the tier system
   // (vs. trying to force a way to put them into the tier stuff)
   // It should also be pretty easy to assign new stuff to everyone

   // Make empty arrays for everyone
   int nNth;
   for(nNth = 0; nNth <= Party.PlayerSize + Party.HenchmanSize; nNth++)
   {
       jAssignments = JsonArrayInsert(jAssignments, JsonArray());
   }

   if (!bNoTreasure)
   {
       for (nNth=1; nNth <= nNumItems; nNth++)
       {
           object oItem = SelectLootItemForLootSource(OBJECT_INVALID, OBJECT_SELF);
           int nAssignIndex = DeterminePartyMemberThatGetsItem(oItem);
           jAssignments = _AddItemToPartyMemberAssignments(jAssignments, oItem, nAssignIndex);
       }

       // Independent treasure map chance
       object oMap = MaybeGenerateTreasureMap(iAreaCR);
       if (GetIsObjectValid(oMap))
       {
           int nAssignIndex = DeterminePartyMemberThatGetsItem(oMap);
           jAssignments = _AddItemToPartyMemberAssignments(jAssignments, oMap, nAssignIndex);
       }

       if (bAnimalLoot)
       {
           int nAnimalGoldMultiplier = 1;

           if (bBoss == 1) nAnimalGoldMultiplier = BOSS_GOLD_MULTIPLIER;
           else if (bSemiBoss == 1 || bRare == 1) nAnimalGoldMultiplier = SEMIBOSS_RARE_GOLD_MULTIPLIER;

           object oAnimalLootContainer = GetObjectByTag("_animal_loot_container");

           object oAnimalLoot = GenerateAnimalLoot(OBJECT_SELF, nAnimalGoldMultiplier, oAnimalLootContainer);

           if (GetIsObjectValid(oAnimalLoot))
           {
               int nAssignIndex = DeterminePartyMemberThatGetsItem(oAnimalLoot);
               jAssignments = _AddItemToPartyMemberAssignments(jAssignments, oAnimalLoot, nAssignIndex);

               // 50% chance of another animal loot to distribute
               if (d2() == 1)
               {
                    nAssignIndex = DeterminePartyMemberThatGetsItem(oAnimalLoot);
                    jAssignments = _AddItemToPartyMemberAssignments(jAssignments, oAnimalLoot, nAssignIndex);
               }

               // the loot will get copied to personal loot or henchman stores, the original isn't needed any more
               DestroyObject(oAnimalLoot);
           }
       }
   }

   int bContainsQuestItem = 0;

// =========================
// START LOOP
// =========================
   // For stat tracking, work out who really killed this
   // (and if it was a summon or dominated associate, direct it back to the owner)
   object oKiller = GetLastKiller();
   if (GetIsPC(GetMaster(oKiller)))
   {
       int nAssociateType = GetAssociateType(oKiller);
       if (nAssociateType == ASSOCIATE_TYPE_ANIMALCOMPANION || nAssociateType == ASSOCIATE_TYPE_DOMINATED || nAssociateType == ASSOCIATE_TYPE_FAMILIAR || nAssociateType == ASSOCIATE_TYPE_SUMMONED)
       {
           oKiller = GetMaster(oKiller);
       }
   }

   int nPCLevel;

   for(nNth = 1; nNth <= Party.PlayerSize; nNth++)
   {
// Credit players in previously set array "Players"
      object oPC = GetLocalArrayObject(OBJECT_SELF, "Players", nNth);
      // This script runs to calc loot values without players present
      // Don't try to do any of this if there isn't anyone.
      if (!GetIsObjectValid(oPC)) { continue; }

      if (GetObjectType(OBJECT_SELF) == OBJECT_TYPE_CREATURE)
      {
          // includes neutrals or people outside of party
          IncrementPlayerStatistic(oPC, "enemies_killed_with_credit");

          nPCLevel = GetLevelFromXP(GetXP(oPC));

          float fTotalXPPercent = 1.0;

          string sStealthIdentifier = "stealth_xp_"+GetName(oPC) + GetPCPublicCDKey(oPC);
          if (GetLocalInt(OBJECT_SELF, sStealthIdentifier) == 1)
          {
                fTotalXPPercent -= STEALTH_XP_PERCENTAGE;
          }

          string sSkillIdentifier = "skill_xp_"+GetName(oPC) + GetPCPublicCDKey(oPC);
          if (GetLocalInt(OBJECT_SELF, sSkillIdentifier) == 1)
          {
                fTotalXPPercent -= SKILL_XP_PERCENTAGE;
          }

          float fXPAfterReductions = fXP * fTotalXPPercent;

          GiveXPToPC(oPC, fXPAfterReductions);
          AdvanceQuest(OBJECT_SELF, oPC, GetLocalInt(OBJECT_SELF, "quest_kill"));

          if (oKiller == oPC)
          {
              // Number of personal kills is in ai_ondeath already
              IncrementPlayerStatistic(oPC, "kill_xp_value", FloatToInt(fXPAfterReductions*100.0));
          }
          IncrementPlayerStatistic(oPC, "total_xp_from_partys_kills", FloatToInt(fXPAfterReductions*100.0));
      }

// only proceed with loot code if container exists
      if (GetIsObjectValid(oContainer))
      {
        oPersonalLoot = GetPersonalLootForPC(oContainer, oPC, TRUE);

// If there's a quest on the object, add a quest item to their personal if this player is eligible
        if (sQuestItemResRef != "" && GetLocalString(oContainer, "quest1") != "" && GetIsQuestStageEligible(oContainer, oPC, 1))
        {
            object oQuest = CreateItemOnObject(sQuestItemResRef, oPersonalLoot, 1, "quest");
            SetName(oQuest, QUEST_ITEM_NAME_COLOR + GetName(oQuest) + "</c>");
            bContainsQuestItem = 1;
        }


        if (bNoTreasure == FALSE)
        {
           // If this is the very first time the player has looted this boss/semiboss,
           // a single piece of loot will be guaranteed from their equipped item (if present)
           if ((bBoss || bSemiBoss) && GetObjectType(OBJECT_SELF) == OBJECT_TYPE_CREATURE)
           {
              
               string sLootKey = "looted_"+GetResRef(OBJECT_SELF);

               if (SQLocalsPlayer_GetInt(oPC, sLootKey) != 1)
               {
                   int nForcedTier = GetFirstBossKillGuaranteedLootTier(iAreaCR, bSemiBoss);
                   object oFirstDrop = SelectLootItemFixedTier(oPersonalLoot, nForcedTier, LOOT_TYPE_EQUIPPABLE);
                   SendDebugMessage("First loot forced tier: " + IntToString(nForcedTier) + " -> " + GetName(oFirstDrop));
                   if (GetIsObjectValid(oFirstDrop))
                   {
                        SQLocalsPlayer_SetInt(oPC, sLootKey, 1);
                   }
               }
           }

           SetLocalInt(oPersonalLoot, "cr", GetLocalInt(oContainer, "cr"));
           SetLocalInt(oPersonalLoot, "area_cr", GetLocalInt(oContainer, "area_cr"));
           json jItemArray = JsonArrayGet(jAssignments, nNth);
           int nAssignedItemIndex;
           int nAssignedCount = JsonGetLength(jItemArray);
           //WriteTimestampedLogEntry(GetName(oPC) + " is assigned " + IntToString(nAssignedCount) + " items");
           for (nAssignedItemIndex=0; nAssignedItemIndex<nAssignedCount; nAssignedItemIndex++)
           {
               object oSourceItem = StringToObject(JsonGetString(JsonArrayGet(jItemArray, nAssignedItemIndex)));
               CopyTierItemFromStaging(oSourceItem, oPersonalLoot);
           }
        }


// distribute gold evenly to all
        if (nGold > 0)
        {
            if (nNth == Party.PlayerSize) nGoldToDistribute = nGold; // if this is the last player, give them the remaining gold
            SetLocalInt(oPersonalLoot, PERSONAL_LOOT_GOLD_AMOUNT, GetLocalInt(oPersonalLoot, PERSONAL_LOOT_GOLD_AMOUNT) + nGoldToDistribute);
            nGold = nGold - nGoldToDistribute;
        }

        if (GetIsObjectValid(oKey))
        {
            if (!GetHasKey(oPC, GetTag(oKey)))
            {
                object oNewKey = CopyItem(oKey, oPersonalLoot);
                SetName(oNewKey, KEY_ITEM_NAME_COLOR + GetName(oNewKey) + "</c>");
            }
        }
        // This is for putting keys inside placeables
        string sKeyResRef = GetLocalString(OBJECT_SELF, "key_item");
        if (sKeyResRef != "")
        {
            object oKeyItem = CreateItemOnObject(sKeyResRef, oPersonalLoot, 1);
            SetName(oKeyItem, KEY_ITEM_NAME_COLOR + GetName(oKeyItem) + "</c>");
            if (GetHasKey(oPC, GetTag(oKeyItem)))
            {
                DestroyObject(oKeyItem);
            }
            else
            {
                SetLocalInt(oKeyItem, "is_key", 1);
            }
        }

        DestroyObject(oPersonalLoot, LOOT_DESTRUCTION_TIME); // Personal loot will no longer be accessible after awhile

      }
   }

   if (bNoTreasure == FALSE && Party.HenchmanSize > 0)
   {
       nNth = 1;
       for(nNth = 1; nNth <= Party.HenchmanSize; nNth++)
       {
          object oHenchman = GetLocalArrayObject(OBJECT_SELF, "Henchmans", nNth);

          if (GetObjectType(oHenchman) == OBJECT_TYPE_CREATURE && GetStringLeft(GetResRef(oHenchman), 3) == "hen")
          {

               object oMerchant = GetLocalObject(oHenchman, "merchant");
               // assumed to be out of bounds (henchman)
               int nExternalIndex = nNth + Party.PlayerSize;
               json jItemArray = JsonArrayGet(jAssignments, nExternalIndex);
               int nAssignedItemIndex;
               int nAssignedCount = JsonGetLength(jItemArray);
               for (nAssignedItemIndex=0; nAssignedItemIndex<nAssignedCount; nAssignedItemIndex++)
               {
                   object oSourceItem = StringToObject(JsonGetString(JsonArrayGet(jItemArray, nAssignedItemIndex)));

                   GiveItemToHenchman(oSourceItem, oMerchant, oHenchman, nNth);
               }
          }
       }
   }

   // Scale the loot bag, but only if it's really a loot bag
   if (GetResRef(oContainer) == "_loot_container")
   {
       // If it contains a quest item, override it
       if (bContainsQuestItem)
       {
           fLootBagScale = 1.0;
       }
       SetObjectVisualTransform(oContainer, OBJECT_VISUAL_TRANSFORM_SCALE, fLootBagScale);
   }

   //DestroyObject(oKey);

// =========================
// END LOOP
// =========================
}

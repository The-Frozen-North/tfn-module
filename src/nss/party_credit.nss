#include "inc_quest"
#include "inc_treasure"
#include "inc_henchman"
#include "inc_key"
#include "inc_party"
#include "inc_sql"

// The max distance in meters a player can be from
// a target killed by a trap, and still get xp.
const float TRAP_DST_MAX = 100.0;

void SendLootMessage(object oHench, object oItem)
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

        // this code doesn't actually work, because the item is automatically identified when put into their merchant inventory
        // there's not a really good way to solve this, even though we can set their item to be unidentified
        /*
        if (!GetIdentified(oItem))
        {
            switch (nBaseItem)
            {
                case BASE_ITEM_SHORTSWORD:            sName = "shortsword"; break;
                case BASE_ITEM_LONGSWORD:             sName = "longsword"; break;
                case BASE_ITEM_BATTLEAXE:             sName = "battleaxe"; break;
                case BASE_ITEM_BASTARDSWORD:          sName = "bastard sword"; break;
                case BASE_ITEM_LIGHTFLAIL:            sName = "light flail"; break;
                case BASE_ITEM_WARHAMMER:             sName = "warhammer"; break;
                case BASE_ITEM_HEAVYCROSSBOW:         sName = "heavy crossbow"; break;
                case BASE_ITEM_LIGHTCROSSBOW:         sName = "light crossbow"; break;
                case BASE_ITEM_LONGBOW:               sName = "longbow"; break;
                case BASE_ITEM_LIGHTMACE:             sName = "mace"; break;
                case BASE_ITEM_HALBERD:               sName = "halberd"; break;
                case BASE_ITEM_SHORTBOW:              sName = "shortbow"; break;
                case BASE_ITEM_TWOBLADEDSWORD:        sName = "two-bladed sword"; break;
                case BASE_ITEM_GREATSWORD:            sName = "greatsword"; break;
                case BASE_ITEM_SMALLSHIELD:           sName = "small shield"; break;
                case BASE_ITEM_TORCH:                 sName = "torch"; break;
                case BASE_ITEM_ARMOR:                 sName = "armor"; break;
                case BASE_ITEM_HELMET:                sName = "helmet"; break;
                case BASE_ITEM_GREATAXE:              sName = "greataxe"; break;
                case BASE_ITEM_AMULET:                sName = "amulet"; break;
                case BASE_ITEM_ARROW:                 sName = "arrow"; break;
                case BASE_ITEM_BELT:                  sName = "belt"; break;
                case BASE_ITEM_DAGGER:                sName = "dagger"; break;
                case BASE_ITEM_MISCSMALL:             sName = "misc item"; break;
                case BASE_ITEM_BOLT:                  sName = "bolt"; break;
                case BASE_ITEM_BOOTS:                 sName = "boots"; break;
                case BASE_ITEM_BULLET:                sName = "bullet"; break;
                case BASE_ITEM_CLUB:                  sName = "club"; break;
                case BASE_ITEM_MISCMEDIUM:            sName = "misc item"; break;
                case BASE_ITEM_DART:                  sName = "dart"; break;
                case BASE_ITEM_DIREMACE:              sName = "dire mace"; break;
                case BASE_ITEM_DOUBLEAXE:             sName = "doubleaxe"; break;
                case BASE_ITEM_MISCLARGE:             sName = "misc item"; break;
                case BASE_ITEM_HEAVYFLAIL:            sName = "heavy flail"; break;
                case BASE_ITEM_GLOVES:                sName = "gloves"; break;
                case BASE_ITEM_LIGHTHAMMER:           sName = "light hammer"; break;
                case BASE_ITEM_HANDAXE:               sName = "handaxe"; break;
                case BASE_ITEM_HEALERSKIT:            sName = "healer's kit"; break;
                case BASE_ITEM_KAMA:                  sName = "kama"; break;
                case BASE_ITEM_KATANA:                sName = "katana"; break;
                case BASE_ITEM_KUKRI:                 sName = "kukri"; break;
                case BASE_ITEM_MISCTALL:              sName = "misc item"; break;
                case BASE_ITEM_MAGICROD:              sName = "rod"; break;
                case BASE_ITEM_MAGICSTAFF:            sName = "staff"; break;
                case BASE_ITEM_MAGICWAND:             sName = "wand"; break;
                case BASE_ITEM_MORNINGSTAR:           sName = "morningstar"; break;
                case BASE_ITEM_POTIONS:               sName = "potion"; break;
                case BASE_ITEM_QUARTERSTAFF:          sName = "quarterstaff"; break;
                case BASE_ITEM_RAPIER:                sName = "rapier"; break;
                case BASE_ITEM_RING:                  sName = "ring"; break;
                case BASE_ITEM_SCIMITAR:              sName = "scimitar"; break;
                case BASE_ITEM_SCROLL:                sName = "scroll"; break;
                case BASE_ITEM_SCYTHE:                sName = "scythe"; break;
                case BASE_ITEM_LARGESHIELD:           sName = "large shield"; break;
                case BASE_ITEM_TOWERSHIELD:           sName = "tower shield"; break;
                case BASE_ITEM_SHORTSPEAR:            sName = "spear"; break;
                case BASE_ITEM_SHURIKEN:              sName = "shuriken"; break;
                case BASE_ITEM_SICKLE:                sName = "sickle"; break;
                case BASE_ITEM_SLING:                 sName = "sling"; break;
                case BASE_ITEM_THIEVESTOOLS:          sName = "thieve's tool"; break;
                case BASE_ITEM_THROWINGAXE:           sName = "throwing axe"; break;
                case BASE_ITEM_TRAPKIT:               sName = "trap kit"; break;
                case BASE_ITEM_KEY:                   sName = "key"; break;
                case BASE_ITEM_LARGEBOX:              sName = "large box"; break;
                case BASE_ITEM_MISCWIDE:              sName = "misc item"; break;
                case BASE_ITEM_CSLASHWEAPON:          return; break;
                case BASE_ITEM_CPIERCWEAPON:          return; break;
                case BASE_ITEM_CBLUDGWEAPON:          return; break;
                case BASE_ITEM_CSLSHPRCWEAP:          return; break;
                case BASE_ITEM_CREATUREITEM:          return; break;
                case BASE_ITEM_BOOK:                  sName = "book"; break;
                case BASE_ITEM_SPELLSCROLL:           sName = "scroll"; break;
                case BASE_ITEM_GOLD:                  return; break;
                case BASE_ITEM_GEM:                   sName = "gem"; break;
                case BASE_ITEM_BRACER:                sName = "bracer"; break;
                case BASE_ITEM_MISCTHIN:              sName = "misc item"; break;
                case BASE_ITEM_CLOAK:                 sName = "cloak"; break;
                case BASE_ITEM_GRENADE:               sName = "grenade"; break;
                case BASE_ITEM_TRIDENT:               sName = "trident"; break;
                case BASE_ITEM_BLANK_POTION:          sName = "potion"; break;
                case BASE_ITEM_BLANK_SCROLL:          sName = "scroll"; break;
                case BASE_ITEM_BLANK_WAND:           sName = "wand"; break;
                case BASE_ITEM_ENCHANTED_POTION:      sName = "potion"; break;
                case BASE_ITEM_ENCHANTED_SCROLL:      sName = "scroll"; break;
                case BASE_ITEM_ENCHANTED_WAND:        sName = "wand"; break;
                case BASE_ITEM_DWARVENWARAXE:         sName = "dwarvern waraxe"; break;
                case BASE_ITEM_CRAFTMATERIALMED:      return; break;
                case BASE_ITEM_CRAFTMATERIALSML:      return; break;
                case BASE_ITEM_WHIP:                  sName = "whip"; break;
            }

            switch (d4())
            {
                case 1: PlayVoiceChat(VOICE_CHAT_LOOKHERE, oOwner); break;
                case 2: PlayVoiceChat(VOICE_CHAT_CHEER, oOwner); break;
            }

            sName = sName+" (unidentified)";
        }
        */
    }

    if (GetLocalInt(oItem, "unidentified") == 1)
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

void DetermineItem(object oItem, object oMerchant, object oHench, int nNth)
{
   if (GetBaseItemType(oItem) == BASE_ITEM_POTIONS)
   {
       object oNewItem = CopyItem(oItem, oHench, TRUE);
       SetDroppableFlag(oNewItem, FALSE);
       SetPickpocketableFlag(oNewItem, FALSE);
       DestroyObject(oItem);
       AssignCommand(GetModule(), DelayCommand(IntToFloat(nNth)+1.0+(IntToFloat(d8())*0.1), SendLootMessage(oHench, oNewItem)));
   }
   else
   {
       AssignCommand(GetModule(), DelayCommand(IntToFloat(nNth)+1.0+(IntToFloat(d8())*0.1), SendLootMessage(oHench, oItem)));
   }
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

// Take the loot item (in the treasure area chest) and return the index of the party member that should recieve it.
int DeterminePartyMemberThatGetsItem(object oItem, int nStartWeights=1000)
{
    int nWasIdentified = GetIdentified(oItem);
    SetIdentified(oItem, 1);
    int nItemValue = GetGoldPieceValue(oItem);
    if (LOOT_OWING_DEBUG)
    {
        WriteTimestampedLogEntry("Try to assign: " + GetName(oItem) + ", value = " +IntToString(nItemValue));
    }
    SetIdentified(oItem, nWasIdentified);
    if (!GetIsObjectValid(oItem))
    {
        return -1;
    }
    // Recommended reading: inc_loot -> "owings" section
    // First, simply go through everyone and work out weightings
    // combinations need to be done EXACTLY once, PC1 vs Daelan then Daelan vs PC1 will undo itself
    int nNumLootRecievers = Party.PlayerSize + Party.HenchmanSize;
    int i, j;
    // Everyone starts on 1000
    for (i=1; i<=nNumLootRecievers; i++)
    {
        SetLocalArrayInt(OBJECT_SELF, "LootWeights", i, nStartWeights);
    }
    object oRecipient;
    for (i=1; i<=nNumLootRecievers; i++)
    {
        if (i <= Party.PlayerSize)
        {
            oRecipient = GetLocalArrayObject(OBJECT_SELF, "Players", i);
        }
        else
        {
            oRecipient = GetLocalArrayObject(OBJECT_SELF, "Henchmans", i - Party.PlayerSize);
        }
        // Check all other party members after this index
        // this should avoid the above mentioned "reverse" cases
        int nWeight = GetLocalArrayInt(OBJECT_SELF, "LootWeights", i);
        for (j=i+1; j<=nNumLootRecievers; j++)
        {
            object oDebtor;
            if (j <= Party.PlayerSize)
            {
                oDebtor = GetLocalArrayObject(OBJECT_SELF, "Players", j);
            }
            else
            {
                oDebtor = GetLocalArrayObject(OBJECT_SELF, "Henchmans", j - Party.PlayerSize);
            }
            int nTransfer = GetLootWeightingTransferBasedOnOwings(oRecipient, oDebtor, nItemValue);
            int nDebtorWeight = GetLocalArrayInt(OBJECT_SELF, "LootWeights", j);
            nDebtorWeight -= nTransfer;
            nWeight += nTransfer;
            if (LOOT_OWING_DEBUG)
            {
                WriteTimestampedLogEntry(GetName(oDebtor) + " owes " + IntToString(GetOwedGoldValue(oRecipient, oDebtor)) + " to " + GetName(oRecipient) + ": transfer " + IntToString(nTransfer) + " weighting -> " + GetName(oRecipient) + "=" + IntToString(nWeight) + ", " + GetName(oDebtor) + "=" + IntToString(nDebtorWeight));
            }
            SetLocalArrayInt(OBJECT_SELF, "LootWeights", j, nDebtorWeight);
        }
        SetLocalArrayInt(OBJECT_SELF, "LootWeights", i, nWeight);
    }
    // Make sure no weight ended up negative, if it did, repeat with a higher nStartWeights
    int nLowestWeight = 999999;
    int nTotalWeight = nStartWeights * nNumLootRecievers;
    for (i=1; i<=nNumLootRecievers; i++)
    {
        int nWeight = GetLocalArrayInt(OBJECT_SELF, "LootWeights", i);
        if (LOOT_OWING_DEBUG)
        {
            object oPerson;
            if (i <= Party.PlayerSize)
            {
                oPerson = GetLocalArrayObject(OBJECT_SELF, "Players", i);
            }
            else
            {
                oPerson = GetLocalArrayObject(OBJECT_SELF, "Henchmans", i - Party.PlayerSize);
            }
            WriteTimestampedLogEntry(GetName(oPerson) + " = " + IntToString(nWeight) + " or " + IntToString(100*nWeight/nTotalWeight) + " percent");
        }
        if (nWeight < nLowestWeight)
        {
            nLowestWeight = nWeight;
        }
    }
    if (LOOT_OWING_DEBUG)
    {
        WriteTimestampedLogEntry("Lowest weight = " + IntToString(nLowestWeight));
    }
    if (nLowestWeight < 0)
    {
        // I don't think this is perfect, but it is by far the easiest way to get out of this particular hole
        // and solve the negative weight problem
        if (LOOT_OWING_DEBUG)
        {
            WriteTimestampedLogEntry("Lowest weight is negative, try again with start points +" + IntToString(nLowestWeight*-1));
        }
        return DeterminePartyMemberThatGetsItem(oItem, nStartWeights + (nLowestWeight*-1));
    }

    int nRolledWeight = Random(nTotalWeight)+1;
    if (LOOT_OWING_DEBUG)
    {
        WriteTimestampedLogEntry("Total weight = " + IntToString(nTotalWeight));
        WriteTimestampedLogEntry("Rolled = " + IntToString(nRolledWeight));
    }
    int nAssignedIndex = -1;
    for (i=1; i<=nNumLootRecievers; i++)
    {
        int nWeight = GetLocalArrayInt(OBJECT_SELF, "LootWeights", i);
        nRolledWeight -= nWeight;
        if (LOOT_OWING_DEBUG)
        {
            WriteTimestampedLogEntry("Index = " + IntToString(i) + " subtracted " + IntToString(nWeight) + "; now rolled = " + IntToString(nRolledWeight));
        }
        if (nRolledWeight < 0)
        {
            nAssignedIndex = i;
            break;
        }
    }
    if (LOOT_OWING_DEBUG)
    {
        WriteTimestampedLogEntry("Assigned index = " + IntToString(nAssignedIndex));
    }
    // Convert back to an object to return
    if (nAssignedIndex <= Party.PlayerSize)
    {
        oRecipient = GetLocalArrayObject(OBJECT_SELF, "Players", nAssignedIndex);
        IncrementPlayerStatistic(oRecipient, "item_gold_value_assigned", nItemValue);
    }
    else
    {
        oRecipient = GetLocalArrayObject(OBJECT_SELF, "Henchmans", nAssignedIndex - Party.PlayerSize);
        for (i=1; i<= Party.PlayerSize; i++)
        {
            object oPlayer = GetLocalArrayObject(OBJECT_SELF, "Players", i);
            IncrementPlayerStatistic(oPlayer, "henchman_item_gold_value_assigned", nItemValue);
        }
    }
    // Update gold owings
    // I guess the best way to do this is to just subtract (item gold value/(party size-1)) from everyone else's owing
    // to the person who got it

    // This logic will turn into a divide by zero if solo
    if (nNumLootRecievers > 1)
    {
        int nSubtraction = -1*(nItemValue/(nNumLootRecievers-1));
        for (i=1; i<=nNumLootRecievers; i++)
        {
            object oNonRecipient;
            if (i <= Party.PlayerSize)
            {
                oNonRecipient = GetLocalArrayObject(OBJECT_SELF, "Players", i);
            }
            else
            {
                oNonRecipient = GetLocalArrayObject(OBJECT_SELF, "Henchmans", i - Party.PlayerSize);
            }
            if (i == nAssignedIndex)
            {
                continue;
            }
            AdjustOwedGoldValue(oRecipient, oNonRecipient, nSubtraction);
        }
    }
    if (LOOT_OWING_DEBUG)
    {
        WriteTimestampedLogEntry("Assigned " + GetName(oItem) + " to " + GetName(oRecipient));
    }
    return nAssignedIndex;
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
   vector vPosition;
   location lLocation;
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
        if (ShouldDebugLoot())
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

        vPosition = GetPosition(oContainer);
        vPosition.z = -100.0; // Make the personal loot go under the map
        lLocation  = Location(GetArea(oContainer), vPosition, 0.0);
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
        // This is so that one call is always done to GenerateLoot which updates the logging variables correctly
        // Because we just calculated the correct expected amount of items
        // It will mean that the actual items created will not be correct though, but that's a small price to pay for science
        // plus if you can run this you can just warp to the treasure area and loot whatever you want anyway
        nNumItems = 1;
        bNoTreasure = FALSE;
    }

// =========================
// END LOOT CONTAINER CODE
// =========================
   float fMultiplier = 1.0;

   if (bBoss == 1)
   {
        fMultiplier = 3.0;
   }
   else if (bSemiBoss == 1 || bRare == 1)
   {
        fMultiplier = 2.0;
   }

   float fXP = GetPartyXPValue(OBJECT_SELF, bAmbush, Party.AverageLevel, Party.TotalSize, fMultiplier);


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
           object oItem = SelectLoot(OBJECT_SELF);
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

               // the loot is serialized into JSON, we don't need it anymore
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
         // If there is already personal loot, just add to it
        oPersonalLoot = GetObjectByUUID(GetLocalString(oContainer, "personal_loot_"+GetPCPublicCDKey(oPC, TRUE)));
        if (!GetIsObjectValid(oPersonalLoot))
        {
            oPersonalLoot = CreateObject(OBJECT_TYPE_PLACEABLE, "_loot_personal", lLocation, FALSE);

            string sPlayerCDKey = GetPCPublicCDKey(oPC, TRUE);
            ForceRefreshObjectUUID(oPersonalLoot);

            SetLocalString(oContainer, "personal_loot_"+sPlayerCDKey, GetObjectUUID(oPersonalLoot));
            SetLocalString(oPersonalLoot, "loot_parent_uuid", GetObjectUUID(oContainer));
        }

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
               object oEquippedItem = SelectEquippedItemToDropAsLoot(OBJECT_SELF);
               string sLootKey = "looted_"+GetResRef(OBJECT_SELF);

               if (GetIsObjectValid(oEquippedItem) && SQLocalsPlayer_GetInt(oPC, sLootKey) != 1)
               {
                   CopyItem(oEquippedItem, oPersonalLoot, TRUE);
                   SQLocalsPlayer_SetInt(oPC, sLootKey, 1);
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
               CopyTierItemToObjectOrLocation(oSourceItem, oPersonalLoot);
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
// have to be set for treasure to function properly
               SetLocalInt(oHenchman, "cr", GetLocalInt(oContainer, "cr"));
               SetLocalInt(oHenchman, "area_cr", GetLocalInt(oContainer, "area_cr"));

               object oMerchant = GetLocalObject(oHenchman, "merchant");
// assumed to be out of bounds (henchman)
               int nExternalIndex = nNth + Party.PlayerSize;
               json jItemArray = JsonArrayGet(jAssignments, nExternalIndex);
               int nAssignedItemIndex;
               int nAssignedCount = JsonGetLength(jItemArray);
               for (nAssignedItemIndex=0; nAssignedItemIndex<nAssignedCount; nAssignedItemIndex++)
               {
                   object oSourceItem = StringToObject(JsonGetString(JsonArrayGet(jItemArray, nAssignedItemIndex)));
                   object oRealItem = CopyTierItemToObjectOrLocation(oSourceItem, oMerchant);

// items that are copied to a merchant are automatically identified, this is a hack to store that status somehow
// so that when henchmans pick it up, they can do an appropriate voice emote
                   if (!GetIdentified(oSourceItem))
                      SetLocalInt(oRealItem, "unidentified", 1);

                   DetermineItem(oRealItem, oMerchant, oHenchman, nNth);
               }

// clear these out afterwards
               DeleteLocalInt(oHenchman, "cr");
               DeleteLocalInt(oHenchman, "area_cr");
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

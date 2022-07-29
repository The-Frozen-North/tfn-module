#include "inc_xp"
#include "inc_quest"
#include "inc_loot"
#include "inc_henchman"
#include "inc_nwnx"

// The max distance in meters a party member can be from
// a target killed by oKiller and still get xp. (no lower than 5!)
const float PARTY_DST_MAX = 40.0;

// The max distance in meters a player can be from
// a target killed by a trap, and still get xp.
const float TRAP_DST_MAX = 100.0;


struct Party
{
   int PlayerSize;
   int HenchmanSize;
   int TotalSize;
   int LevelGap;
   int HighestLevel;
   float AverageLevel;
};

// * Simulates retrieving an object from an array on an object.
object GetLocalArrayObject(object oObject, string sArrayName, int nIndex)
{
   string sVarName = sArrayName + IntToString(nIndex);
   return GetLocalObject(oObject, sVarName);
}


// * Simulates storing a local object in an array on an object.
void SetLocalArrayObject(object oObject, string sArrayName, int nIndex, object oValue)
{
   SetLocalObject(oObject, sArrayName + IntToString(nIndex), oValue);
}

void SendLootMessage(object oHench, object oItem)
{
    if (!GetIsObjectValid(oItem))
        return;

    object oOwner = oHench;

    if (GetIsDead(oOwner))
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

    string sName = GetName(oItem);

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

    object oPC = GetFirstPC();
    while (GetIsObjectValid(oPC))
    {
        if (GetArea(oPC) == GetArea(oOwner))
            NWNX_Player_FloatingTextStringOnCreature(oPC, oOwner, "*"+GetName(oOwner)+" receives "+sName+"*");

        oPC = GetNextPC();
    }
}

void DetermineItem(object oItem, object oMerchant, object oHench, int nNth)
{
   if (GetBaseItemType(oItem) == BASE_ITEM_POTIONS)
   {
       SetDroppableFlag(oItem, FALSE);
       SetPickpocketableFlag(oItem, FALSE);
       object oNewItem = CopyItem(oItem, oHench, TRUE);
       DestroyObject(oItem);
       AssignCommand(GetModule(), DelayCommand(IntToFloat(nNth)+1.0+(IntToFloat(d8())*0.1), SendLootMessage(oHench, oNewItem)));
   }
   else
   {
       AssignCommand(GetModule(), DelayCommand(IntToFloat(nNth)+1.0+(IntToFloat(d8())*0.1), SendLootMessage(oHench, oItem)));
   }
}


// This global variable is used to store party data during the first loop
struct Party Party;

void SetPartyData()
{
   int nLow = 80;
   int nHigh, nLevel = 0;
   int nPlayerSize = 0;
   int nHenchmanSize = 0;
   int nTotalSize = 0;
   int nTotalLevels = 0;
   int nHighestLevel = 0;
   float fAverageLevel = 0.0;

   float fDst = PARTY_DST_MAX;
   location lLocation = GetLocation(OBJECT_SELF);

   object oMbr = GetFirstObjectInShape(SHAPE_SPHERE, fDst, lLocation, FALSE, OBJECT_TYPE_CREATURE);

   while(oMbr != OBJECT_INVALID)
   {

      if(GetIsPC(oMbr))
      {
          nPlayerSize++;
          nTotalSize++;
          nLevel = GetLevelFromXP(GetXP(oMbr));
          nTotalLevels = nTotalLevels + nLevel;
          if (nLevel > nHighestLevel) nHighestLevel = nLevel;


          if(nLow > nLevel) nLow = nLevel;
          if(nHigh < nLevel) nHigh = nLevel;
          SetLocalArrayObject(OBJECT_SELF, "Players", nPlayerSize, oMbr);
      }
// checking if it isn't dead and that the heartbeat event is henchman heartbeat is enough
// for us to tell
      else if (!GetIsDead(oMbr) && !GetIsPC(oMbr) && GetEventScript(oMbr, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT) == "hen_onheartb")
      {
          nTotalSize++;
          if (GetStringLeft(GetResRef(oMbr), 3) == "hen")
          {
            nHenchmanSize++;
            SetLocalArrayObject(OBJECT_SELF, "Henchmans", nHenchmanSize, oMbr);
          }
          nLevel = GetHitDice(oMbr);
          if (nLevel > nHighestLevel) nHighestLevel = nLevel;
          nTotalLevels = nTotalLevels + nLevel;
      }

      oMbr = GetNextObjectInShape(SHAPE_SPHERE, fDst, lLocation, FALSE, OBJECT_TYPE_CREATURE);
   }
   // Used for loot debugging: if there were no "real" party members in range, add
   // the module developer as a party member
   // This forces the loot code to always be run
   if (nTotalSize == 0 && GetIsDevServer())
   {
      object oDev = GetLocalObject(GetModule(), "dev_lootvortex");
      if (GetIsObjectValid(oDev) && GetIsDeveloper(oDev))
      {
          nPlayerSize++;
          nTotalSize++;
          nLevel = GetLevelFromXP(GetXP(oMbr));
          nTotalLevels = nTotalLevels + nLevel;
          nHighestLevel = nLevel;
          nLow = nLevel;
          nHigh = nLevel;
          SetLocalArrayObject(OBJECT_SELF, "Players", nPlayerSize, oDev);
      }
   }


   if (nPlayerSize > 0) fAverageLevel = IntToFloat(nTotalLevels) / IntToFloat(nTotalSize);

   float fHighestLevel = IntToFloat(nHighestLevel);
   if (fHighestLevel > fAverageLevel) fAverageLevel = fHighestLevel;

   SendDebugMessage("Player size: "+IntToString(nPlayerSize));
   SendDebugMessage("Henchman size: "+IntToString(nHenchmanSize));
   SendDebugMessage("Total size: "+IntToString(nTotalSize));
   SendDebugMessage("Party gap: "+IntToString(nHigh - nLow));
   SendDebugMessage("Party highest level: "+IntToString(nLevel));
   SendDebugMessage("Party average: "+FloatToString(fAverageLevel));

   Party.PlayerSize = nPlayerSize;
   Party.HenchmanSize = nHenchmanSize;
   Party.TotalSize = nTotalSize;
   Party.AverageLevel = fAverageLevel;
   Party.LevelGap = nHigh - nLow;
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

        if ((bBoss == 1) || (bSemiBoss == 1))
        {
            nTreasureChance = 100;
        }

        if (d100() > nTreasureChance)
        {
            bNoTreasure = TRUE;
        }

// any of these races will never drop treasure
        int nRace = GetRacialType(OBJECT_SELF);
        switch (nRace)
        {
            case RACIAL_TYPE_MAGICAL_BEAST:
            case RACIAL_TYPE_ANIMAL:
            case RACIAL_TYPE_VERMIN:
            case RACIAL_TYPE_BEAST:
            {
               bNoTreasure = TRUE;
               nTreasureChance = 0;
            }
            break;
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
        if (GetBaseItemType(oItem) == BASE_ITEM_KEY)
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
    if (!bNoTreasure)
    {
        if (ShouldDebugLoot())
        {
            // This is the gold drop rate, set it on the module so it gets counted correctly
            float fTreasureChance = IntToFloat(nTreasureChance)/100.0;
            SetLocalFloat(GetModule(), LOOT_DEBUG_DROP_CHANCE_MULT, fTreasureChance);
        }
        if (bBoss == 1) nGold = DetermineGoldFromCR(iCR, 3);
        else if (bSemiBoss == 1) nGold = DetermineGoldFromCR(iCR, 2);
        else
        {
            nGold = DetermineGoldFromCR(iCR);
        }

        nGoldToDistribute = nGold/nTotalSize;
// remove henchman gold now, if they exist
        if (Party.HenchmanSize > 0) nGold = nGold - Party.HenchmanSize*nGoldToDistribute;
    }

// Calculate how many items to make, and to which player it goes to
   int nItem1, nItem2, nItem3;

   int nItemsRoll = d100();

   if (bBoss)
   {
       nChanceThree = 100;
       nChanceTwo = 0;
       nChanceOne = 0;
   }
   

   if (nItemsRoll <= nChanceThree)
   {
       nItem3 = Random(nTotalSize)+1;
       nItem2 = Random(nTotalSize)+1;
       nItem1 = Random(nTotalSize)+1;
   }
   else if (nItemsRoll <= nChanceTwo)
   {
       nItem2 = Random(nTotalSize)+1;
       nItem1 = Random(nTotalSize)+1;
   }
   else if ((nItemsRoll <= nChanceOne) || (bSemiBoss == 1))
   {
       nItem1 = Random(nTotalSize)+1;
   }

   if (nItem1 > 0)
    SendDebugMessage("Item 1: "+IntToString(nItem1));

   if (nItem2 > 0)
    SendDebugMessage("Item 2: "+IntToString(nItem2));

   if (nItem3 > 0)
    SendDebugMessage("Item 3: "+IntToString(nItem3));

    if (ShouldDebugLoot())
    {
        float fTreasureChance = IntToFloat(nTreasureChance)/100.0;
        float fChanceThree = IntToFloat(nChanceThree)/100.0;
        float fChanceTwo = IntToFloat(nChanceTwo - nChanceThree)/100.0;
        float fChanceOne = IntToFloat(nChanceOne - (nChanceTwo + nChanceThree))/100.0;

        float fExpected = fTreasureChance * (fChanceOne + (2.0 * fChanceTwo) + (3.0 * fChanceThree));
        SendDebugMessage("Expected number of items from " + GetName(OBJECT_SELF) +": " + FloatToString(fExpected));
        //SendDebugMessage("fTreasureChance = " + FloatToString(fTreasureChance));
        SetLocalFloat(GetModule(), LOOT_DEBUG_DROP_CHANCE_MULT, fExpected);

        // Force it to always roll only one item when debugging
        // This is so that one call is always done to GenerateLoot which updates the logging variables correctly
        // Because we just calculated the correct expected amount of items
        // It will mean that the actual items created will not be correct though, but that's a small price to pay for science
        // plus if you can run this you can just warp to the treasure area and loot whatever you want anyway
        nItem1 = 1;
        nItem2 = 0;
        nItem3 = 0;
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
   else if (bSemiBoss == 1)
   {
        fMultiplier = 2.0;
   }

   float fXP = GetPartyXPValue(OBJECT_SELF, bAmbush, Party.AverageLevel, Party.TotalSize, fMultiplier);

// =========================
// START LOOP
// =========================
   int nNth = 1;
   for(nNth = 1; nNth <= Party.PlayerSize; nNth++)
   {
// Credit players in previously set array "Players"
      object oPC = GetLocalArrayObject(OBJECT_SELF, "Players", nNth);

      if (GetObjectType(OBJECT_SELF) == OBJECT_TYPE_CREATURE)
      {
          GiveXPToPC(oPC, fXP);
          AdvanceQuest(OBJECT_SELF, oPC, GetLocalInt(OBJECT_SELF, "quest_kill"));
      }

// only proceed with loot code if container exists
      if (GetIsObjectValid(oContainer))
      {
        oPersonalLoot = CreateObject(OBJECT_TYPE_PLACEABLE, "_loot_personal", lLocation, FALSE);

        string sPlayerCDKey = GetPCPublicCDKey(oPC, TRUE);
        ForceRefreshObjectUUID(oPersonalLoot);

        SetLocalString(oContainer, "personal_loot_"+sPlayerCDKey, GetObjectUUID(oPersonalLoot));
        SetLocalString(oPersonalLoot, "loot_parent_uuid", GetObjectUUID(oContainer));

// If there's a quest on the object, add a quest item to their personal if this player is eligible
        if (sQuestItemResRef != "" && GetLocalString(oContainer, "quest1") != "" && GetIsQuestStageEligible(oContainer, oPC, 1))
            CreateItemOnObject(sQuestItemResRef, oPersonalLoot, 1, "quest");

        if (bNoTreasure == FALSE)
        {
           SetLocalInt(oPersonalLoot, "cr", GetLocalInt(oContainer, "cr"));
           SetLocalInt(oPersonalLoot, "area_cr", GetLocalInt(oContainer, "area_cr"));

           if (nNth == nItem1) GenerateLoot(oPersonalLoot);
           if (nNth == nItem2) GenerateLoot(oPersonalLoot);
           if (nNth == nItem3) GenerateLoot(oPersonalLoot);
        }


// distribute gold evenly to all
        if (nGold > 0)
        {
            if (nNth == Party.PlayerSize) nGoldToDistribute = nGold; // if this is the last player, give them the remaining gold
            CreateItemOnObject("nw_it_gold001", oPersonalLoot, nGoldToDistribute);
            nGold = nGold - nGoldToDistribute;
        }

        if (GetIsObjectValid(oKey)) CopyItem(oKey, oPersonalLoot);

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
               object oItem1, oItem2, oItem3;
// assumed to be out of bounds (henchman)
               if (Party.PlayerSize+nNth == nItem1)
               {
                   oItem1 = GenerateLoot(oMerchant);
                   DetermineItem(oItem1, oMerchant, oHenchman, nNth);
               }
               if (Party.PlayerSize+nNth == nItem2)
               {
                   oItem2 = GenerateLoot(oMerchant);
                   DetermineItem(oItem2, oMerchant, oHenchman, nNth);
               }
               if (Party.PlayerSize+nNth == nItem3)
               {
                   oItem3 = GenerateLoot(oMerchant);
                   DetermineItem(oItem3, oMerchant, oHenchman, nNth);
               }

// clear these out afterwards
               DeleteLocalInt(oHenchman, "cr");
               DeleteLocalInt(oHenchman, "area_cr");
          }
       }
   }

   //DestroyObject(oKey);

// =========================
// END LOOP
// =========================
}

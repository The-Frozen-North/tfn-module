#include "inc_xp"
#include "inc_quest"
#include "inc_loot"
#include "inc_henchman"

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


          if(nLow > nLevel) nLow = nLevel;
          if(nHigh < nLevel) nHigh = nLevel;
          SetLocalArrayObject(OBJECT_SELF, "Players", nPlayerSize, oMbr);
      }
// checking if it isn't dead and that the heartbeat event is henchman heartbeat is enough
// for us to tell
      else if (!GetIsDead(oMbr) && GetEventScript(oMbr, EVENT_SCRIPT_CREATURE_ON_HEARTBEAT) == "hen_onheartb")
      {
          nTotalSize++;
          if (GetStringLeft(GetResRef(oMbr), 3) == "hen") nHenchmanSize++;
          nLevel = GetHitDice(oMbr);
          nTotalLevels = nTotalLevels + nLevel;
      }

      oMbr = GetNextObjectInShape(SHAPE_SPHERE, fDst, lLocation, FALSE, OBJECT_TYPE_CREATURE);
   }

   if (nPlayerSize > 0) fAverageLevel = IntToFloat(nTotalLevels) / IntToFloat(nTotalSize);

   SendDebugMessage("Player size: "+IntToString(nPlayerSize));
   SendDebugMessage("Henchman size: "+IntToString(nHenchmanSize));
   SendDebugMessage("Total size: "+IntToString(nTotalSize));
   SendDebugMessage("Party gap: "+IntToString(nHigh - nLow));
   SendDebugMessage("Party average: "+FloatToString(fAverageLevel));

   Party.PlayerSize = nPlayerSize;
   Party.HenchmanSize = nHenchmanSize;
   Party.TotalSize = nTotalSize;
   Party.AverageLevel = fAverageLevel;
   Party.LevelGap = nHigh - nLow;
}

void main()
{
// this should never trigger on a PC
   if (GetIsPC(OBJECT_SELF)) return;

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

// if the hit points of the object is 0 or less than 0,
// assume it is a dead creature or destroyed treasure
// we shall roll to see if treasure even drops at that point.
    int bDestroyed = GetCurrentHitPoints(OBJECT_SELF) <= 0;

    int bBoss = GetLocalInt(OBJECT_SELF, "boss");
    int bSemiBoss = GetLocalInt(OBJECT_SELF, "semiboss");

    int iCR = GetLocalInt(OBJECT_SELF, "cr");
    int iAreaCR = GetLocalInt(OBJECT_SELF, "area_cr");

    if (bDestroyed)
    {
        int nTreasureChance = TREASURE_CHANCE;

// destroyed treasures have double the chance of still dropping treasure
        if (GetStringLeft(GetResRef(OBJECT_SELF), 6) == "treas_") nTreasureChance = TREASURE_CHANCE*2;

        if (GetLocalInt(OBJECT_SELF, "half_loot") == 1) nTreasureChance = nTreasureChance/2;

        if ((bBoss != 1) && (bSemiBoss != 1) && (d100() > nTreasureChance)) bNoTreasure = TRUE;

// any of these races will never drop treasure
        int nRace = GetRacialType(OBJECT_SELF);
        switch (nRace)
        {
            case RACIAL_TYPE_MAGICAL_BEAST:
            case RACIAL_TYPE_ANIMAL:
            case RACIAL_TYPE_VERMIN:
            case RACIAL_TYPE_BEAST:
               bNoTreasure = TRUE;
            break;
        }
    }

// ambushes never yield treasure
    if (bAmbush) bNoTreasure = TRUE;

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

// only proceed if there is treasure or a key
    if (!bNoTreasure || GetIsObjectValid(oKey))
    {
// if destroyed, the container is a loot bag
        if (bDestroyed)
        {
            oContainer = CreateObject(OBJECT_TYPE_PLACEABLE, "_loot_container", GetLocation(OBJECT_SELF));
            SetLocalInt(oContainer, "cr", iCR);
            SetLocalInt(oContainer, "area_cr", iAreaCR);
            DestroyObject(oContainer, LOOT_DESTRUCTION_TIME); // destroy loot bag after awhile
        }
// otherwise, the container is itself
        else
        {
            oContainer = OBJECT_SELF;
        }
        ForceRefreshObjectUUID(oContainer); // assign a UUID to this container

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
        nGold = DetermineGoldFromCR(iCR);

        if (bBoss == 1) nGold = nGold*3;
        else if (bSemiBoss == 1) nGold = nGold*2;

        nGoldToDistribute = nGold/nTotalSize;
// remove henchman gold now, if they exist
        if (Party.HenchmanSize > 0) nGold = nGold - Party.HenchmanSize*nGoldToDistribute;
    }

// Calculate how many items to make, and to which player it goes to
   int nItem1, nItem2, nItem3;

   int nItemsRoll = d100();

   if ((nItemsRoll <= CHANCE_THREE) || (bBoss == 1))
   {
       nItem3 = Random(nTotalSize)+1;
       nItem2 = Random(nTotalSize)+1;
       nItem1 = Random(nTotalSize)+1;
   }
   else if (nItemsRoll <= CHANCE_TWO)
   {
       nItem2 = Random(nTotalSize)+1;
       nItem1 = Random(nTotalSize)+1;
   }
   else if ((nItemsRoll <= CHANCE_ONE) || (bSemiBoss == 1))
   {
       nItem1 = Random(nTotalSize)+1;
   }

// =========================
// END LOOT CONTAINER CODE
// =========================

   float fXP = GetPartyXPValue(OBJECT_SELF, bAmbush, Party.AverageLevel, Party.TotalSize);

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
   DestroyObject(oKey);

// =========================
// END LOOP
// =========================
}

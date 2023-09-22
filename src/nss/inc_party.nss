#include "inc_general"
#include "inc_xp"
#include "inc_loot"

// SetScriptParam: "exclusivelooter" to ObjectToString(oPC) to make oPC get everything.

// The max distance in meters a party member can be from
// a target killed by oKiller and still get xp. (no lower than 5!)
const float PARTY_DST_MAX = 40.0;

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

int GetLocalArrayInt(object oObject, string sArrayName, int nIndex)
{
   string sVarName = sArrayName + IntToString(nIndex);
   return GetLocalInt(oObject, sVarName);
}

void SetLocalArrayInt(object oObject, string sArrayName, int nIndex, int nValue)
{
   SetLocalInt(oObject, sArrayName + IntToString(nIndex), nValue);
}

// This global variable is used to store party data during the first loop
struct Party Party;

void SetPartyData(object oTarget = OBJECT_SELF)
{
   int nLow = 80;
   int nHigh, nLevel = 0;
   int nPlayerSize = 0;
   int nHenchmanSize = 0;
   int nTotalSize = 0;
   int nTotalLevels = 0;
   int nHighestLevel = 0;
   int nAssociateType;
   float fAverageLevel = 0.0;

   float fDst = PARTY_DST_MAX;
   location lLocation = GetLocation(oTarget);

   object oMbr = GetFirstObjectInShape(SHAPE_SPHERE, fDst, lLocation, FALSE, OBJECT_TYPE_CREATURE);

   object oExclusiveLooter = StringToObject(GetScriptParam("exclusivelooter"));
   if (GetIsObjectValid(oExclusiveLooter))
   {
        nPlayerSize = 1;
        nTotalSize = 1;
        nTotalLevels = GetLevelFromXP(GetXP(oExclusiveLooter));
        nHighestLevel = nTotalLevels;
        nHigh = nTotalLevels;
        nLow = nTotalLevels;
        fAverageLevel = IntToFloat(nTotalLevels);
        SetLocalArrayObject(oTarget, "Players", 1, oExclusiveLooter);
   }
   else
   {
       while(oMbr != OBJECT_INVALID)
       {
          nAssociateType = GetAssociateType(oMbr);
          if(GetIsPC(oMbr))
          {
              nPlayerSize++;
              nTotalSize++;
              nLevel = GetLevelFromXP(GetXP(oMbr));
              nTotalLevels = nTotalLevels + nLevel;

              if (nLevel > nHighestLevel) nHighestLevel = nLevel;


              if(nLow > nLevel) nLow = nLevel;
              if(nHigh < nLevel) nHigh = nLevel;
              SetLocalArrayObject(oTarget, "Players", nPlayerSize, oMbr);
          }

    // all associates except dominated and pets should count for xp purposes
          else if (!GetIsDead(oMbr) && !GetIsPC(oMbr) && nAssociateType > 0
                   && nAssociateType != ASSOCIATE_TYPE_DOMINATED
                   && nAssociateType != ASSOCIATE_TYPE_FAMILIAR
                   && nAssociateType != ASSOCIATE_TYPE_ANIMALCOMPANION
                   && GetLocalInt(oMbr, "no_xp_penalty") != 1)
          {
              nTotalSize++;
              if (GetStringLeft(GetResRef(oMbr), 3) == "hen") // only named henchman count for loot distro
              {
                nHenchmanSize++;
                SetLocalArrayObject(oTarget, "Henchmans", nHenchmanSize, oMbr);
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
       if (nTotalSize == 0 && ShouldDebugLoot())
       {
          object oDev = GetLocalObject(GetModule(), "dev_lootvortex");
          nPlayerSize++;
          nTotalSize++;
          nLevel = GetLevelFromXP(GetXP(oMbr));
          nTotalLevels = nTotalLevels + nLevel;
          nHighestLevel = nLevel;
          nLow = nLevel;
          nHigh = nLevel;
          if (GetIsObjectValid(oDev) && GetIsDeveloper(oDev))
          {
              SetLocalArrayObject(oTarget, "Players", nPlayerSize, oDev);
          }
          else
          {
              SetLocalArrayObject(oTarget, "Players", nPlayerSize, OBJECT_INVALID);
          }
       }
   }


   if (nPlayerSize > 0) fAverageLevel = IntToFloat(nTotalLevels) / IntToFloat(max(1, nTotalSize));

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

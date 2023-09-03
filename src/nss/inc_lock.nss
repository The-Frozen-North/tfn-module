// some considerations when crunching numbers:
// lvl 6 with 20 str, equivalent to 5 open lock
// lvl 1 with 18 str, equivalent to 4 open lock

// lvl 1 with open lock, equivalent to 4 open lock
// lvl 1 with open lock and 18 dex, equivalent to 8 open lock
// lvl 6 with open lock, equivalent to 9 open lock
// lvl 6 with open lock and 20 dex, equivalent to 14 open lock

const int BASE_LOCK_DC = 22;
const int BASE_LOCK_CHANCE = 30;

const int INCREASED_DOOR_DC = 3;

const int INCREASED_LOCK_CHANCE_FACTOR_PER_CR = 0;

// in a CR area, this would mean that 50% of the locks may have a lower DC than the full CR being added to it
// for example, in a 6 CR area say there is a chest being locked. the formula is as follows
// IF not a lower lock DC, it would be 22 base + 6 so a 28 DC locked chest
// IF selected to be lower, it would be 21 + 6 - 1-3 DC, or a DC 24-27 lock
const int CHANCE_FOR_LOWER_LOCK_DC = 50;

void GenerateLockOnObject(object oObject = OBJECT_SELF)
{
   if (GetLocalInt(oObject, "locked") != 1) return;
   if (GetLocalInt(GetArea(oObject), "unlocked") == 1) return;

   int nCR = GetLocalInt(oObject, "cr");

   int nLockChance = BASE_LOCK_CHANCE + (nCR * INCREASED_LOCK_CHANCE_FACTOR_PER_CR);

   // Door DCs should be automatically and always be set, disregard toolset value.
   if (GetObjectType(oObject) == OBJECT_TYPE_DOOR)
   {
       int nLockDC = BASE_LOCK_DC + nCR;

       // add increased door DC if it doesn't have a transition target
       if (GetTransitionTarget(oObject) == OBJECT_INVALID)
       {            
            int nIncreasedDoorDC = INCREASED_DOOR_DC;
            
            // if set on an area, use that area's increased door DC
            int nAreaIncreasedDoorDC = GetLocalInt(GetArea(oObject), "increased_door_dc");
            if (nAreaIncreasedDoorDC > 0)
            {
                nIncreasedDoorDC = nAreaIncreasedDoorDC;
            }
            
            nLockDC += nIncreasedDoorDC;
       } 

       SetLockUnlockDC(oObject, nLockDC);
       SetLocked(oObject, TRUE);
   }
   else if (d100() <= nLockChance)
   {
       int nLockDC = BASE_LOCK_DC + nCR;

       // if selected to be a lower level lock, then calculate it ranging from the base lock DC to the highest in the CR -1
       if (d100() <= CHANCE_FOR_LOWER_LOCK_DC)
       {
            nLockDC = BASE_LOCK_DC + Random(nCR);
            // a harsher alternative, stops strength builds from bashing around lvl 9 or 10
            // nLockDC = BASE_LOCK_DC + (nCR / 2) + Random(nCR / 2);
       }

       // for chests and strongboxes, add 1 to the DC
       if (GetLocalString(oObject, "treasure") == "high") nLockDC += 1;

       SetLockUnlockDC(oObject, nLockDC);
       SetLocked(oObject, TRUE);
   }
}

//void main(){}

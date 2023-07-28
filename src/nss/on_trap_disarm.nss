#include "inc_xp"
#include "inc_general"

void main()
{
     object oPC = GetLastDisarmed();

     int nXP = GetTrapDisarmDC(OBJECT_SELF);

     if (nXP == 0) nXP = GetLocalInt(OBJECT_SELF, "trap_dc");

// cap
     if (nXP > 50) nXP = 50;

     if (nXP > 0)
     {
        nXP = nXP/9;
     }
     else
     {
        return;
     }

     if (GetIsPC(oPC))
     {
         GiveXPToPC(oPC, IntToFloat(nXP));
         IncrementPlayerStatistic(oPC, "traps_disarmed");
     }
}

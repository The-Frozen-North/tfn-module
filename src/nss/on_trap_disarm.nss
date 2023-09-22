#include "inc_xp"
#include "inc_general"

void main()
{
     object oPC = GetLastDisarmed();

     int nXP = GetTrapDisarmDC(OBJECT_SELF);

     if (nXP == 0) nXP = GetLocalInt(OBJECT_SELF, "trap_dc");

     float fXP = IntToFloat(nXP);

// cap
     if (fXP > 50.0) fXP = 50.0;

     if (fXP > 0.0)
     {
        fXP = fXP/9.0;
     }
     else
     {
        return;
     }

     if (GetIsPC(oPC))
     {
         GiveXPToPC(oPC, fXP, FALSE, "Trap Disarming");
         IncrementPlayerStatistic(oPC, "traps_disarmed");
     }
}

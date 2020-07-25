#include "1_inc_loot"
#include "1_inc_respawn"

void main()
{
     object oPC = GetLastUsedBy();

// don't do anything if not a PC
     if (!GetIsPC(oPC)) return;

     OpenPersonalLoot(OBJECT_SELF, oPC);
}

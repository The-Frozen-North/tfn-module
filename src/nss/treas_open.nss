#include "inc_loot"
#include "inc_respawn"

void main()
{
     object oPC = GetLastUsedBy();

// don't do anything if not a PC
     if (!GetIsPC(oPC)) return;

     OpenPersonalLoot(OBJECT_SELF, oPC);
}

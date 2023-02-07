#include "inc_loot"
#include "inc_respawn"

void main()
{
     object oPC = GetLastUsedBy();

     ExecuteScript("remove_invis", oPC);

// don't do anything if not a PC
     if (!GetIsPC(oPC)) return;
     OpenPersonalLoot(OBJECT_SELF, oPC);
}

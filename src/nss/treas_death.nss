#include "inc_respawn"

void main()
{
// Generate loot if it isn't already opened
     if (GetLocalInt(OBJECT_SELF, "no_credit") != 1) ExecuteScript("party_credit");
     StartRespawn();
}

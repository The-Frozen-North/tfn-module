#include "inc_loot"

void main()
{
    SpeakString("Boing");
    OpenPersonalLoot(OBJECT_SELF, GetLastUsedBy());
}

#include "x3_inc_string"

void main()
{
    SetName(OBJECT_SELF, "Broken Fang "+StringReplace(GetName(OBJECT_SELF), "Orc ", ""));
    SetCreatureAppearanceType(OBJECT_SELF, GetAppearanceType(OBJECT_SELF)+1);
    SetPortraitId(OBJECT_SELF, GetPortraitId(OBJECT_SELF)+1);
    ChangeFaction(OBJECT_SELF, GetObjectByTag("FACTION_BROKENFANG"));
}

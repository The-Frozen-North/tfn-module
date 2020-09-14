#include "x3_inc_string"

void main()
{
    SetName(OBJECT_SELF, "Heart Ripper "+StringReplace(GetName(OBJECT_SELF), "Orc ", ""));
    ChangeFaction(OBJECT_SELF, GetObjectByTag("FACTION_HEARTRIPPER"));
}

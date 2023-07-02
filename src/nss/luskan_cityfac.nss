void main()
{
// ignore civilians
    if (GetLevelByClass(CLASS_TYPE_COMMONER)) return;

// ignore animals
    if (GetRacialType(OBJECT_SELF) == RACIAL_TYPE_ANIMAL) return;

// ignore associates
    if (GetIsObjectValid(GetMaster())) return;

    ChangeFaction(OBJECT_SELF, GetObjectByTag("FACTION_LUSKANCITY"));
}

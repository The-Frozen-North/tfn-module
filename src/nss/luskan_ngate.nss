void main()
{
// ignore civilians
    if (GetLevelByClass(CLASS_TYPE_COMMONER)) return;

// ignore animals
    if (GetRacialType(OBJECT_SELF) == RACIAL_TYPE_ANIMAL) return;

// ignore associates
    if (GetIsObjectValid(GetMaster())) return;

// archers on the walls tend to bunch up, don't allow that
    if (GetResRef(OBJECT_SELF) == "luskan_archer")
        SetLocalInt(OBJECT_SELF, "no_wander", 1);

    float fDistance = GetDistanceToObject(GetObjectByTag("luskan_north_gate"));

// invalid distance, do nothing
    if (fDistance <= -1.0) return;

// too far, do nothing
    if (fDistance >= 30.0) return;

    ChangeFaction(OBJECT_SELF, GetObjectByTag("FACTION_LUSKANCITY"));
}

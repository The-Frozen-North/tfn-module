// "open" - open the door
// open not set: make mithril golems hostile

#include "inc_ai_combat"
#include "nwnx_visibility"

void main()
{
    string sOpen = GetScriptParam("open");
    object oDoor = GetObjectByTag("maker4_golemdoor");
    if (sOpen != "")
    {
        SetLocked(oDoor, 0);
        AssignCommand(oDoor, ActionOpenDoor(oDoor));
    }
    if (GetLocked(oDoor))
    {
        location lSelf = GetLocation(OBJECT_SELF);
        object oTest = GetFirstObjectInShape(SHAPE_SPHERE, 40.0, lSelf);
        while (GetIsObjectValid(oTest))
        {
            if (GetResRef(oTest) == "mithralgolem")
            {
                ChangeToStandardFaction(oTest, STANDARD_FACTION_HOSTILE);
                AssignCommand(oTest, gsCBDetermineCombatRound(GetPCSpeaker()));
            }
            oTest = GetNextObjectInShape(SHAPE_SPHERE, 40.0, lSelf);
        }
    }
    NWNX_Visibility_SetVisibilityOverride(OBJECT_INVALID, OBJECT_SELF, NWNX_VISIBILITY_HIDDEN);
}

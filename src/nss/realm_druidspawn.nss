#include "x0_i0_position"

void main()
{
    SetTag(OBJECT_SELF, "realm_druid");
    SetLocalInt(OBJECT_SELF, "no_wander", 1);
    SetLocalString(OBJECT_SELF, "death_script", "realm_druiddeath");

    TurnToFaceObject(GetObjectByTag("WP_REALM_CENTER"), OBJECT_SELF);
    PlayAnimation(ANIMATION_LOOPING_WORSHIP, 1.0, 9000000000000.0);
}

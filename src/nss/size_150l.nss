#include "nwnx_creature"

void main()
{
    SetObjectVisualTransform(OBJECT_SELF, OBJECT_VISUAL_TRANSFORM_SCALE, 1.5);
    NWNX_Creature_SetSize(OBJECT_SELF, CREATURE_SIZE_LARGE);
}

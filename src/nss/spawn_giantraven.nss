#include "nwnx_creature"

void main()
{
    float fSize = 3.0;

    SetObjectVisualTransform(OBJECT_SELF, OBJECT_VISUAL_TRANSFORM_SCALE, fSize);
    SetObjectVisualTransform(OBJECT_SELF, OBJECT_VISUAL_TRANSFORM_TRANSLATE_Z, -fSize);

    NWNX_Creature_SetSize(OBJECT_SELF, CREATURE_SIZE_LARGE);
}

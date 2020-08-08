#include "nwnx_creature"

void main()
{
    switch (d3())
    {
        case 1:
        case 2:
            SetCreatureAppearanceType(OBJECT_SELF, APPEARANCE_TYPE_SEAGULL_WALKING);
        break;
    }

    SetObjectVisualTransform(OBJECT_SELF, OBJECT_VISUAL_TRANSFORM_SCALE, 1.6);
}

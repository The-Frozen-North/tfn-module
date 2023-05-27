#include "nwnx_creature"

void main()
{
    switch (d2())
    {
        case 2:
            SetPortraitResRef(OBJECT_SELF, "po_hu_f_13_");
            SetCreatureAppearanceType(OBJECT_SELF, 237);
            SetSoundset(OBJECT_SELF, 168);
        break;
    }
}

#include "nwnx_creature"

void main()
{
    switch (d2())
    {
        case 2:
            SetGender(OBJECT_SELF, GENDER_FEMALE);
            SetPortraitResRef(OBJECT_SELF, "po_girl_");
            SetCreatureAppearanceType(OBJECT_SELF, 242);
            SetSoundset(OBJECT_SELF, 120);
        break;
    }
}

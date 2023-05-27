#include "nwnx_creature"

void main()
{
    switch (d2())
    {
        case 2:
            SetGender(OBJECT_SELF, GENDER_FEMALE);
            SetCreatureAppearanceType(OBJECT_SELF, 222);
            SetPortraitResRef(OBJECT_SELF, "po_hu_f_18_");
            SetSoundset(OBJECT_SELF, 151);
        break;
    }
}

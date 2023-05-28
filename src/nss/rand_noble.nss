#include "nwnx_creature"

void main()
{
    switch (d6())
    {
        case 1:
        break;
        case 2:
            SetPortraitResRef(OBJECT_SELF, "po_hu_m_30_");
            SetCreatureAppearanceType(OBJECT_SELF, 283);
            SetSoundset(OBJECT_SELF, 159);
        break;
        case 3:
            SetPortraitResRef(OBJECT_SELF, "po_hu_m_22_");
            SetCreatureAppearanceType(OBJECT_SELF, 229);
            SetSoundset(OBJECT_SELF, 126);
        break;
        case 4:
            SetGender(OBJECT_SELF, GENDER_FEMALE);
            SetPortraitResRef(OBJECT_SELF, "po_hu_f_09_");
            SetCreatureAppearanceType(OBJECT_SELF, 264);
            SetSoundset(OBJECT_SELF, 157);
        break;
        case 5:
            SetGender(OBJECT_SELF, GENDER_FEMALE);
            SetPortraitResRef(OBJECT_SELF, "po_hu_f_06_");
            SetCreatureAppearanceType(OBJECT_SELF, 225);
            SetSoundset(OBJECT_SELF, 158);
        break;
        case 6:
            SetGender(OBJECT_SELF, GENDER_FEMALE);
            SetPortraitResRef(OBJECT_SELF, "po_hu_f_17_");
            SetCreatureAppearanceType(OBJECT_SELF, 224);
            SetSoundset(OBJECT_SELF, 154);
        break;
    }
}

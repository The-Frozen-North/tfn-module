#include "nwnx_creature"

void main()
{
    switch (d2())
    {
        case 2:
            SetGender(OBJECT_SELF, GENDER_FEMALE);
            SetPortraitResRef(OBJECT_SELF, "po_vampire_f_");
            SetCreatureAppearanceType(OBJECT_SELF, APPEARANCE_TYPE_VAMPIRE_FEMALE);
            SetSoundset(OBJECT_SELF, 90); // use succubus voice
        break;
    }
}

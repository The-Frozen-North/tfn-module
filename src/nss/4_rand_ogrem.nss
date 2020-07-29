#include "nwnx_creature"

void main()
{
    switch (d2())
    {
        case 2:
            SetPortraitResRef(OBJECT_SELF, "po_OgreMageB_");
            SetCreatureAppearanceType(OBJECT_SELF, APPEARANCE_TYPE_OGRE_MAGEB);
        break;
    }
}

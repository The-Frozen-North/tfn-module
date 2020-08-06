#include "nwnx_creature"

void main()
{
    switch (d3())
    {
        case 1:
            SetPortraitResRef(OBJECT_SELF, "po_cat_crag_");
            SetCreatureTailType(366, OBJECT_SELF);
        break;
        case 2:
            SetPortraitResRef(OBJECT_SELF, "po_Cat_");
            SetCreatureTailType(372, OBJECT_SELF);
        break;
    }
}

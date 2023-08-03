void main()
{
    int nSizeModifier = 0;
    
    // third case is a default panther
    switch (d3())
    {
        case 1:
            SetPortraitResRef(OBJECT_SELF, "po_cat_crag_");
            SetCreatureTailType(366, OBJECT_SELF);
        break;
        case 2:
            SetPortraitResRef(OBJECT_SELF, "po_Cat_");
            SetCreatureTailType(372, OBJECT_SELF);
            nSizeModifier = 1; // these cats are big, need to downsize them by one
        break;
    }

    // Invisible_CreatureS_050, random chance for a smaller cat
    SetCreatureAppearanceType(OBJECT_SELF, 833 - Random(1) - nSizeModifier);
}

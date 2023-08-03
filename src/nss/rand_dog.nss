void main()
{
    // third case is a default dog
    switch (d3())
    {
        case 1: // winter wolf
            SetPortraitResRef(OBJECT_SELF, "po_wolfwint_");
            SetCreatureAppearanceType(OBJECT_SELF, APPEARANCE_TYPE_DOG_WINTER_WOLF);
        break;
        case 2: // wolf
            SetPortraitResRef(OBJECT_SELF, "po_wolf_");
            SetCreatureAppearanceType(OBJECT_SELF, APPEARANCE_TYPE_DOG_WOLF);
        break;
    }
}


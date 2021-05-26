int lcs_GetWeaponModelLowerBound(object oItem, int nPart)
{
    int nWeaponType = GetBaseItemType(oItem);
    if(nPart == ITEM_APPR_WEAPON_MODEL_TOP)
    {
        switch(nWeaponType)
        {
            case BASE_ITEM_BASTARDSWORD     : return 6;
            case BASE_ITEM_BATTLEAXE        : return 8;
            case BASE_ITEM_CLUB             : return 4;
            case BASE_ITEM_DAGGER           : return 6;
            case BASE_ITEM_DIREMACE         : return 4;
            case BASE_ITEM_DOUBLEAXE        : return 3;
            case BASE_ITEM_DWARVENWARAXE    : return 8;
            case BASE_ITEM_GREATAXE         : return 4;
            case BASE_ITEM_GREATSWORD       : return 4;
            case BASE_ITEM_HALBERD          : return 4;
            case BASE_ITEM_HANDAXE          : return 4;
            case BASE_ITEM_HEAVYCROSSBOW    : return 4;
            case BASE_ITEM_HEAVYFLAIL       : return 4;
            //case BASE_ITEM_KAMA             : return ;
            case BASE_ITEM_KATANA           : return 4;
            //case BASE_ITEM_KUKRI            : return ;
            case BASE_ITEM_LIGHTCROSSBOW    : return 4;
            case BASE_ITEM_LIGHTFLAIL       : return 4;
            case BASE_ITEM_LIGHTHAMMER      : return 4;
            case BASE_ITEM_LIGHTMACE        : return 4;
            case BASE_ITEM_LONGBOW          : return 8;
            case BASE_ITEM_LONGSWORD        : return 8;
            case BASE_ITEM_MAGICSTAFF       : return 6;
            case BASE_ITEM_MORNINGSTAR      : return 4;
            case BASE_ITEM_QUARTERSTAFF     : return 4;
            case BASE_ITEM_RAPIER           : return 4;
            case BASE_ITEM_SCIMITAR         : return 5;
            case BASE_ITEM_SCYTHE           : return 4;
            case BASE_ITEM_SHORTBOW         : return 6;
            case BASE_ITEM_SHORTSPEAR       : return 4;
            case BASE_ITEM_SHORTSWORD       : return 6;
            //case BASE_ITEM_SICKLE           : return ;
            //case BASE_ITEM_SLING            : return ;
            case BASE_ITEM_THROWINGAXE      : return 4;
            case BASE_ITEM_TWOBLADEDSWORD   : return 3;
            case BASE_ITEM_WARHAMMER        : return 6;
        }
    }
    else if(nPart == ITEM_APPR_WEAPON_MODEL_MIDDLE)
    {
        switch(nWeaponType)
        {
            case BASE_ITEM_BASTARDSWORD     : return 6;
            case BASE_ITEM_BATTLEAXE        : return 6;
            case BASE_ITEM_CLUB             : return 4;
            case BASE_ITEM_DAGGER           : return 6;
            case BASE_ITEM_DIREMACE         : return 4;
            case BASE_ITEM_DOUBLEAXE        : return 3;
            case BASE_ITEM_DWARVENWARAXE    : return 6;
            case BASE_ITEM_GREATAXE         : return 4;
            case BASE_ITEM_GREATSWORD       : return 4;
            case BASE_ITEM_HALBERD          : return 4;
            case BASE_ITEM_HANDAXE          : return 4;
            case BASE_ITEM_HEAVYCROSSBOW    : return 4;
            case BASE_ITEM_HEAVYFLAIL       : return 4;
            //case BASE_ITEM_KAMA             : return ;
            case BASE_ITEM_KATANA           : return 4;
            //case BASE_ITEM_KUKRI            : return ;
            case BASE_ITEM_LIGHTCROSSBOW    : return 4;
            case BASE_ITEM_LIGHTFLAIL       : return 4;
            case BASE_ITEM_LIGHTHAMMER      : return 4;
            case BASE_ITEM_LIGHTMACE        : return 4;
            case BASE_ITEM_LONGBOW          : return 8;
            case BASE_ITEM_LONGSWORD        : return 8;
            case BASE_ITEM_MAGICSTAFF       : return 8;
            case BASE_ITEM_MORNINGSTAR      : return 4;
            case BASE_ITEM_QUARTERSTAFF     : return 4;
            case BASE_ITEM_RAPIER           : return 4;
            case BASE_ITEM_SCIMITAR         : return 5;
            case BASE_ITEM_SCYTHE           : return 4;
            case BASE_ITEM_SHORTBOW         : return 6;
            case BASE_ITEM_SHORTSPEAR       : return 4;
            case BASE_ITEM_SHORTSWORD       : return 6;
            //case BASE_ITEM_SICKLE           : return ;
            //case BASE_ITEM_SLING            : return ;
            case BASE_ITEM_THROWINGAXE      : return 4;
            case BASE_ITEM_TWOBLADEDSWORD   : return 3;
            case BASE_ITEM_WARHAMMER        : return 6;
        }
    }
    else if(nPart == ITEM_APPR_WEAPON_MODEL_BOTTOM)
    {
        switch(nWeaponType)
        {
            case BASE_ITEM_BASTARDSWORD     : return 6;
            case BASE_ITEM_BATTLEAXE        : return 6;
            case BASE_ITEM_CLUB             : return 4;
            case BASE_ITEM_DAGGER           : return 6;
            case BASE_ITEM_DIREMACE         : return 4;
            case BASE_ITEM_DOUBLEAXE        : return 3;
            case BASE_ITEM_DWARVENWARAXE    : return 6;
            case BASE_ITEM_GREATAXE         : return 4;
            case BASE_ITEM_GREATSWORD       : return 4;
            case BASE_ITEM_HALBERD          : return 4;
            case BASE_ITEM_HANDAXE          : return 4;
            case BASE_ITEM_HEAVYCROSSBOW    : return 4;
            case BASE_ITEM_HEAVYFLAIL       : return 4;
            //case BASE_ITEM_KAMA             : return ;
            case BASE_ITEM_KATANA           : return 4;
            //case BASE_ITEM_KUKRI            : return ;
            case BASE_ITEM_LIGHTCROSSBOW    : return 4;
            case BASE_ITEM_LIGHTFLAIL       : return 4;
            case BASE_ITEM_LIGHTHAMMER      : return 4;
            case BASE_ITEM_LIGHTMACE        : return 4;
            case BASE_ITEM_LONGBOW          : return 8;
            case BASE_ITEM_LONGSWORD        : return 8;
            case BASE_ITEM_MAGICSTAFF       : return 6;
            case BASE_ITEM_MORNINGSTAR      : return 4;
            case BASE_ITEM_QUARTERSTAFF     : return 4;
            case BASE_ITEM_RAPIER           : return 4;
            case BASE_ITEM_SCIMITAR         : return 5;
            case BASE_ITEM_SCYTHE           : return 4;
            case BASE_ITEM_SHORTBOW         : return 6;
            case BASE_ITEM_SHORTSPEAR       : return 4;
            case BASE_ITEM_SHORTSWORD       : return 6;
            //case BASE_ITEM_SICKLE           : return ;
            //case BASE_ITEM_SLING            : return ;
            case BASE_ITEM_THROWINGAXE      : return 4;
            case BASE_ITEM_TWOBLADEDSWORD   : return 3;
            case BASE_ITEM_WARHAMMER        : return 6;
        }
    }
    return 1;
}

//For Shadowhawk Weapons Hak use ONLY
int lcs_GetWeaponModelUpperBound(object oItem, int nPart)
{
    int nWeaponType = GetBaseItemType(oItem);
    if(nPart == ITEM_APPR_WEAPON_MODEL_TOP)
    {
        switch(nWeaponType)
        {
            case BASE_ITEM_BASTARDSWORD     : return 22;
            case BASE_ITEM_BATTLEAXE        : return 25;
            case BASE_ITEM_DOUBLEAXE        : return 14;
            case BASE_ITEM_GREATAXE         : return 22;
            case BASE_ITEM_GREATSWORD       : return 15;
            case BASE_ITEM_KATANA           : return 12;
            case BASE_ITEM_LIGHTMACE        : return 22;
            case BASE_ITEM_LONGBOW          : return 11;
            case BASE_ITEM_LONGSWORD        : return 21;
            case BASE_ITEM_RAPIER           : return 13;
            case BASE_ITEM_SCIMITAR         : return 18;
            case BASE_ITEM_SHORTSWORD       : return 19;
            case BASE_ITEM_TWOBLADEDSWORD   : return 16;
            case BASE_ITEM_WARHAMMER        : return 20;
        }
    }
    else if(nPart == ITEM_APPR_WEAPON_MODEL_MIDDLE)
    {
        switch(nWeaponType)
        {
            case BASE_ITEM_BASTARDSWORD     : return 24;
            case BASE_ITEM_BATTLEAXE        : return 25;
            case BASE_ITEM_DOUBLEAXE        : return 12;
            case BASE_ITEM_GREATAXE         : return 13;
            case BASE_ITEM_GREATSWORD       : return 18;
            case BASE_ITEM_KATANA           : return 13;
            case BASE_ITEM_LIGHTMACE        : return 18;
            case BASE_ITEM_LONGBOW          : return 20;
            case BASE_ITEM_LONGSWORD        : return 22;
            case BASE_ITEM_RAPIER           : return 24;
            case BASE_ITEM_SCIMITAR         : return 15;
            case BASE_ITEM_SHORTSWORD       : return 20;
            case BASE_ITEM_TWOBLADEDSWORD   : return 16;
            case BASE_ITEM_WARHAMMER        : return 16;
        }
    }
    else if(nPart == ITEM_APPR_WEAPON_MODEL_BOTTOM)
    {
        switch(nWeaponType)
        {
            case BASE_ITEM_BASTARDSWORD     : return 20;
            case BASE_ITEM_BATTLEAXE        : return 16;
            case BASE_ITEM_DOUBLEAXE        : return 18;
            case BASE_ITEM_GREATAXE         : return 18;
            case BASE_ITEM_GREATSWORD       : return 15;
            case BASE_ITEM_KATANA           : return 13;
            case BASE_ITEM_LIGHTMACE        : return 11;
            case BASE_ITEM_LONGSWORD        : return 22;
            case BASE_ITEM_RAPIER           : return 16;
            case BASE_ITEM_SCIMITAR         : return 15;
            case BASE_ITEM_SHORTSWORD       : return 13;
            case BASE_ITEM_TWOBLADEDSWORD   : return 18;
            case BASE_ITEM_WARHAMMER        : return 21;
        }
    }
    return 1;
}

int lcs_GetNextValidWeaponModel(object oItem, int nPart)
{
    int nLowerBound = lcs_GetWeaponModelLowerBound(oItem, nPart);
    //int nUpperBound = lcs_GetWeaponModelUpperBound(oItem, nPart);
    int nUpperBound = 1;

    int nCurrentAppearance = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, nPart);

    if(nCurrentAppearance == nLowerBound)
    {
        if(nUpperBound >= 11)
        {
            return 11;
        }
        else
        {
            return 1;
        }
    }
    else if((nCurrentAppearance == nUpperBound) && (nUpperBound >= 11))
    {
        return 1;
    }
    else if(((GetBaseItemType(oItem) == BASE_ITEM_DOUBLEAXE) && (nPart == ITEM_APPR_WEAPON_MODEL_TOP)) && (nCurrentAppearance == 11))
    {
        return 13;
    }
    else if(((GetBaseItemType(oItem) == BASE_ITEM_BASTARDSWORD) && (nPart == ITEM_APPR_WEAPON_MODEL_TOP)) && (nCurrentAppearance == 19))
    {
        return 21;
    }
    else if(((GetBaseItemType(oItem) == BASE_ITEM_LONGSWORD) && (nPart == ITEM_APPR_WEAPON_MODEL_BOTTOM)) && (nCurrentAppearance == 17))
    {
        return 20;
    }
    else
    {
        return nCurrentAppearance + 1;
    }
}

int lcs_GetPreviousValidWeaponModel(object oItem, int nPart)
{
    int nLowerBound = lcs_GetWeaponModelLowerBound(oItem, nPart);
    //int nUpperBound = lcs_GetWeaponModelUpperBound(oItem, nPart);
    int nUpperBound = 1;

    int nCurrentAppearance = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, nPart);

    if(nCurrentAppearance == 11)
    {
        return nLowerBound;
    }
    else if(nCurrentAppearance == 1)
    {
        if(nUpperBound >= 11)
        {
            return nUpperBound;
        }
        else
        {
            return nLowerBound;
        }
    }
    else if(((GetBaseItemType(oItem) == BASE_ITEM_DOUBLEAXE) && (nPart == ITEM_APPR_WEAPON_MODEL_TOP)) && (nCurrentAppearance == 13))
    {
        return 11;
    }
    else if(((GetBaseItemType(oItem) == BASE_ITEM_BASTARDSWORD) && (nPart == ITEM_APPR_WEAPON_MODEL_TOP)) && (nCurrentAppearance == 21))
    {
        return 19;
    }
    else if(((GetBaseItemType(oItem) == BASE_ITEM_LONGSWORD) && (nPart == ITEM_APPR_WEAPON_MODEL_BOTTOM)) && (nCurrentAppearance == 20))
    {
        return 17;
    }
    else
    {
        return nCurrentAppearance - 1;
    }
}

int lcs_GetNextValidWeaponColor(object oItem, int nPart)
{
    int nAppearance = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, nPart);
    if(nAppearance == 3)
    {
        nAppearance = 1;
    }
    else
    {
        nAppearance = nAppearance + 1;
    }
    return nAppearance;
}

int lcs_GetPreviousValidWeaponColor(object oItem, int nPart)
{
    int nAppearance = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, nPart);
    if(nAppearance == 1)
    {
            nAppearance = 3;
    }
    else
    {
        nAppearance = nAppearance - 1;
    }
    return nAppearance;
}

void lcs_ModifyColorandEquipNewWeapon(object oItem, int nPart, int nAppearance)
{
    object oPC = GetItemPossessor(oItem);
    object oNewItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, nPart, nAppearance, TRUE);
    DestroyObject(oItem);
    SetCommandable(TRUE, oPC);
    AssignCommand(oPC, ActionEquipItem(oNewItem, INVENTORY_SLOT_RIGHTHAND));
}

void lcs_ModifyandEquipNewWeapon(object oItem, int nPart, int nAppearance)
{
    object oPC = GetItemPossessor(oItem);

    //int nColorAppearance = GetItemAppearance(oItem, ITEM_APPR_TYPE_WEAPON_COLOR, nPart);
    //if(nColorAppearance > 3)
    //{
        //SendMessageToPC(oPC, ("Your current weapon color is " + IntToString(nAppearance) + ". Please change the color to be set to 3 or lower before changing the weapon model."));
        //return;
    //}
    object oNewItem = CopyItemAndModify(oItem, ITEM_APPR_TYPE_WEAPON_MODEL, nPart, nAppearance, TRUE);
    DestroyObject(oItem);
    SetCommandable(TRUE, oPC);
    AssignCommand(oPC, ActionEquipItem(oNewItem, INVENTORY_SLOT_RIGHTHAND));
}

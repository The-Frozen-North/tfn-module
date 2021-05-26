//lcs_inc_chmodel

#include "lcs_inc_general"

//==========================================/
object set_chest_model_next(object item, object user)
//==========================================/
    {
    string s2da = "parts_chest";
    int index = ITEM_APPR_ARMOR_MODEL_TORSO;

    int apart_row = GetItemAppearance(item, ITEM_APPR_TYPE_ARMOR_MODEL, index);
    int ac_current = StringToInt(Get2DAString(s2da, "ACBONUS", apart_row));

    int apart_index = get_apart_2da_index(s2da, apart_row);
    int apart_index_max = get_apart_max_index(s2da);

    if(apart_index < apart_index_max)
        {
        apart_index++;
        }
    else
        {
        apart_index = 1;
        }

    apart_row = get_apart_2da_row(s2da, apart_index);
    int ac_new = StringToInt(Get2DAString(s2da, "ACBONUS", apart_row));

    //SendMessageToPC(user, IntToString(ac_new));

    while(ac_new != ac_current)
        {
        if(apart_index < apart_index_max)
            {
            apart_index++;
            }
        else
            {
            apart_index = 1;
            }

        apart_row = get_apart_2da_row(s2da, apart_index);
        ac_new = StringToInt(Get2DAString(s2da, "ACBONUS", apart_row));

        //SendMessageToPC(user, IntToString(ac_new));
        }

    SendMessageToPC(user, "part number: " + IntToString(apart_row));

    DestroyObject(item);
    return CopyItemAndModify(item, ITEM_APPR_TYPE_ARMOR_MODEL, index,
apart_row, TRUE);
    }

//==========================================/
object set_chest_model_prev(object item, object user)
//==========================================/
    {
    string s2da = "parts_chest";
    int index = ITEM_APPR_ARMOR_MODEL_TORSO;

    int apart_row = GetItemAppearance(item, ITEM_APPR_TYPE_ARMOR_MODEL, index);
    int ac_current = StringToInt(Get2DAString(s2da, "ACBONUS", apart_row));

    int apart_index = get_apart_2da_index(s2da, apart_row);
    int apart_index_max = get_apart_max_index(s2da);

    if(apart_index > 1)
        {
        apart_index--;
        }
    else
        {
        apart_index = apart_index_max;
        }

    apart_row = get_apart_2da_row(s2da, apart_index);
    int ac_new = StringToInt(Get2DAString(s2da, "ACBONUS", apart_row));

    while(ac_new != ac_current)
        {
        if(apart_index > 1)
            {
            apart_index--;
            }
        else
            {
            apart_index = apart_index_max;
            }

        apart_row = get_apart_2da_row(s2da, apart_index);
        ac_new = StringToInt(Get2DAString(s2da, "ACBONUS", apart_row));
        }

    SendMessageToPC(user, "part number: " + IntToString(apart_row));

    DestroyObject(item);
    return CopyItemAndModify(item, ITEM_APPR_TYPE_ARMOR_MODEL, index,
apart_row, TRUE);
    }


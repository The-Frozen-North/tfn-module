#include "lcs_inc_general"

//==========================================/
object set_armor_model_next(object item, int index, string s2da, object user)
//==========================================/
    {
    int apart_row = GetItemAppearance(item, ITEM_APPR_TYPE_ARMOR_MODEL, index);
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
    SendMessageToPC(user, "part number: " + IntToString(apart_row));

    DestroyObject(item);
    return CopyItemAndModify(item, ITEM_APPR_TYPE_ARMOR_MODEL, index, apart_row, TRUE);
    }

//==========================================/
object set_armor_model_prev(object item, int index, string s2da, object user)
//==========================================/
    {
    int apart_row = GetItemAppearance(item, ITEM_APPR_TYPE_ARMOR_MODEL, index);
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
    SendMessageToPC(user, "part number: " + IntToString(apart_row));

    DestroyObject(item);
    return CopyItemAndModify(item, ITEM_APPR_TYPE_ARMOR_MODEL, index, apart_row, TRUE);
    }

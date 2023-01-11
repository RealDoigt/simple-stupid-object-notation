bool try_set_objects(out HashTable<string, HashTable<string, string>> objects, string[] raw_object_data)
{
    objects = new HashTable<string, HashTable<string, string>>(str_hash, str_equal);
    var default_values = new HashTable<string, HashTable<string, string>>(str_hash, str_equal);

    var reading_object = false, reading_default = false;
    var line_count = 0;
    var current_object = "";

    foreach (var str in raw_object_data)
    {
        ++line_count;

        if (str.has_prefix("#") || str.length == 0) continue;

        if (str.has_prefix("."))
        {
            if (!reading_object)
            {
                print(@"$str at line $line_count is supposed to be a property, however it is cut off from its parent object. You probably misplaced a ; just before that line.\n");
                return false;
            }

            var key_value_pair = str.split("=");

            if (key_value_pair.length < 2)
            {
                print(@"expected a value after $str at line $line_count; property cannot be empty.\n");
                return false;
            }

            if (key_value_pair.length > 2)
                key_value_pair[1] = string.join("=", key_value_pair[1:key_value_pair.length]);

            // remove the dot at the beginning of the attribute
            key_value_pair[0] = key_value_pair[0][1:key_value_pair[0].length];

            // removes the ; from the value if it's at the end of it
            if (key_value_pair[1].has_suffix(";"))
                key_value_pair[1] = key_value_pair[1][0:key_value_pair[1].length - 1];

            key_value_pair[0] = key_value_pair[0].strip();
            key_value_pair[1] = key_value_pair[1].strip();

            // put the value in the appropriate hashtable.
            if (reading_default)
            {
                if (!default_values.contains(current_object))
                    default_values.insert(current_object, new HashTable<string, string>(str_hash, str_equal));

                default_values[current_object].insert(key_value_pair[0], key_value_pair[1]);
            }

            else
            {
                if (!objects.contains(current_object))
                    objects.insert(current_object, new HashTable<string, string>(str_hash, str_equal));

                objects[current_object].insert(key_value_pair[0], key_value_pair[1]);
            }
        }

        else if (str != ";")
        {
            if (reading_object)
            {
                print(@"expected a ; before line $line_count\n");
                return false;
            }

            if (str.has_prefix("default"))
            {
                reading_object = true;
                reading_default = true;

                // removes the default out of the string.
                current_object = str[7:str.length].strip();
            }

            else
            {
                var clean_str = str.strip();

                current_object = @"$(clean_str)_$line_count";
                reading_object = true;

                if (default_values.contains(clean_str))
                {
                    var attributes = default_values[clean_str].get_keys_as_array();
                    objects.insert(current_object, new HashTable<string, string>(str_hash, str_equal));

                    foreach (var attribute in attributes)
                        objects[current_object].insert(attribute, default_values[clean_str][attribute]);
                }
            }
        }

        if (str.has_suffix(";"))
        {
            if (!reading_object) print(@"redundant ; at line $line_count\n");
            reading_default = false;
            reading_object = false;
        }
    }

    return true;
}

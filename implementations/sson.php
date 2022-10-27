<?php 

    function try_get_objects($raw_object_data)
    {
        if (!is_array($raw_object_data))
            return 'This function expects the parameter to be an array';

        $reading_object = false;
        $reading_default = false;

        $line_count = 0;
        $current_object = "";

        $objects = [];
        $default_values = [];

        foreach ($raw_object_data as $str)
        {
            ++$line_count;

            if (str_starts_with($str, '#') || $str === '') continue;

            if (str_starts_with($str, '.'))
            {
                if (!$reading_object)
                    return "$str at line $line_count is supposed to be a property, however it is cut off from its parent object. You probably misplaced a ; just before that line.";

                $key_value_pair = explode('=', $str, 2);

                if (count($key_value_pair) < 2)
                    return "expected a value after $str at line $line_count; property cannot be empty.";

                // remove the dot at the beginning of the attribute
                $key_value_pair[0] = substr($key_value_pair[0], 1);

                if (str_ends_with($key_value_pair[1], ';'))
                    $key_value_pair[1] = substr($key_value_pair[1], 0, strlen($key_value_pair[1]) - 1);

                $key_value_pair[0] = trim($key_value_pair[0]);
                $key_value_pair[1] = trim($key_value_pair[1]);

                if ($reading_default)
                {
                    if (!array_key_exists($current_object, $default_values))
                        $default_values[$current_object] = [];

                    $default_values[$current_object][$key_value_pair[0]] = $key_value_pair[1];
                }

                else
                {
                    if (!array_key_exists($current_object, $objects))
                        $objects[$current_object] = [];

                    $objects[$current_object][$key_value_pair[0]] = $key_value_pair[1];
                }
            }

            else
            {
                if ($reading_object) return "expected a ; before line $line_count";

                if (str_starts_with($str, 'default'))
                {
                    $reading_object = true;
                    $reading_default = true;

                    // removes the default part of the string
                    $current_object = trim(substr($str, 7));
                }

                else
                {
                    $clean_str = trim($str);
                    $reading_object = true;

                    if (array_key_exists($clean_str, $default_values))
                    {
                        $objects[$current_object] = [];

                        foreach ($default_values[$clean_str] as $property => $value)
                            $objects[$current_object][$property] = $value;
                    }
                }
            }

            if (str_ends_with($str, ';'))
            {
                $reading_object = false;
                $reading_default = false;
            }
        }

        return $objects;
    }
?>

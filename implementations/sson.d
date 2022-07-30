module sson;
import std.stdio;
import std.string;
//import std.variant;
import std.algorithm;

enum ReadingMode
{
    objects,
    defaults,
    connections,
    generators,
    templates,
    none
}

bool trySetObjects(out string[string][string] objects, string[] rawObjectData)
{
    auto reading = ReadingMode.none;

    auto lineCount = 0;
    auto currentObject = "";

    string[string][string] defaultValues;
    string[string][string] connections;
    string[string][string] generators;
    string[string][string] templates;

    // put the value in the appropriate hashmap.
    void insert(string key, string value)
    {
        switch (reading)
        {
            case ReadingMode.objects:
                objects[currentObject][key] = value;
                break;

            case ReadingMode.templates:
                templates[currentObject][key] = value;
                break;

            case ReadingMode.connections:
                connections[currentObject][key] = value;
                break;

            case ReadingMode.generators:
                generators[currentObject][key] = value;
                break;

            default:
                defaultValues[currentObject][key] = value;
        }
    }

    // this puts all the attributes and values of an object in a hashmap
    // each object has a unique identifier that goes by its name and the
    // line # it was declared on, separated by an _ except for other types
    foreach (str; rawObjectData)
    {
        ++lineCount;

        if (str.startsWith("#") || !str.length) continue;

        if (str.startsWith("."))
        {
            if (reading == ReadingMode.none)
            {
                "%s at line %d is supposed to be a property, however it is cut off from its parent object. You probably misplaced a ; just before that line.".format(str, lineCount).writeln;
                return false;
            }

            auto keyValuePair = str.split("=");

            if (keyValuePair.length < 2)
            {
                "expected a value after %s at line %d; property cannot be empty.".format(str, lineCount).writeln;
                return false;
            }

            // this is a fix for when someone uses another = after the assign
            for (int i = 2; i < keyValuePair.length; ++i)
                keyValuePair[1] ~= "=" ~ keyValuePair[i];

            // remove the dot at the beginning of the attribute
            keyValuePair[0] = keyValuePair[0][1..keyValuePair[0].length];

            // removes the ; from the value if it's at the end of it
            if (keyValuePair[1].endsWith(";")) keyValuePair[1] = keyValuePair[1][0..keyValuePair[1].length - 1];

            keyValuePair[0] = keyValuePair[0].strip;
            keyValuePair[1] = keyValuePair[1].strip;

            insert(keyValuePair[0], keyValuePair[1]);
        }

        else
        {
            if (reading != ReadingMode.none)
            {
                "expected a ; before line %d".format(lineCount).writeln;
                return false;
            }

            string cleanStr = "";

            if (str.startsWith("default "))
            {
                reading = ReadingMode.defaults;

                // removes the default part of the string.
                currentObject = str[8..str.length].strip;
                goto default_exit;
            }

            else if (str.startsWith("template "))
            {
                reading = ReadingMode.templates;

                // removes the template part of the string.
                currentObject = str[9..str.length].strip;
                cleanStr = currentObject;
            }

            else if (str.startsWith("connect "))
            {
                reading = ReadingMode.connections;

                // removes the connect part of the string.
                currentObject = str[8..str.length].strip;
                cleanStr = currentObject;
            }

            else if (str.startsWith("generator "))
            {
                reading = ReadingMode.generators;

                // removes the generator part of the string.
                currentObject = str[10..str.length].strip;
                cleanStr = currentObject;

                insert("line", "%d".format(lineCount));
            }

            else
            {
                cleanStr = str.strip;

                reading = ReadingMode.objects;
                currentObject = format("%s_%d", cleanStr, lineCount);
            }

            if (defaultValues.keys.canFind(cleanStr))
            {
                auto attributes = defaultValues[cleanStr].keys;

                foreach (attribute; attributes)
                    insert(attribute, defaultValues[cleanStr][attribute]);
            }
        }
        default_exit:

        if (str.endsWith(";"))
        {
            if (reading == ReadingMode.none)
                "redundant ; at line %d".format(lineCount).writeln;

            reading = ReadingMode.none;
        }
    }

    return true;
}

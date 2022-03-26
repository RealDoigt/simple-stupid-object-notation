def trySetObjects(rawObjectData):

    if not isinstance(rawObjectData, list):
        return "expected an array of strings"

    readingObject = False
    readingDefault = False

    objects = {}
    defaultValues = {}

    lineCount = 0
    currentObject = ""

    for str in rawObjectData:

        lineCount += 1

        if str.startswith("#") or len(str) == 0:
            continue

        if str.startswith("."):

            if not readingObject:
                return f"{str} at line {lineCount} is supposed to be a property, however it is cut off from its parent object. You probably misplaced a ; just before that line."

            keyValuePair = str.split("=")

            if len(keyValuePair) < 2:
                return f"expected a value after {str} at line {lineCount}; property cannot be empty."

            for i = 2 in range(len(keyValuePair)):
                keyValuePair[1] = f"{keyValuePair[1]}={keyValuePair[i]}"

            # remove the dot at the beginning of the attribute
            keyValuePair[0] = keyValuePair[0][1:len(keyValuePair[0])]

            # removes the ; from the value if it's at the end of it
            if keyValuePair[1].endswith(";"):
                keyValuePair[1] = keyValuePair[1][:len(keyValuePair[1]) - 1]

            keyValuePair[0] = keyValuePair[0].strip()
            keyValuePair[1] = keyValuePair[1].strip()

            # put the value in the appropriate dictionary.
            if readingDefault:

                if defaultValues.get(currentObject) == None:
                    defaultValues[currentObject] = {}

                defaultValues[currentObject][keyValuePair[0]] = keyValuePair[1]

            else:

                if objects.get(currentObject) == None:
                    objects[currentObject] = {}

                objects[currentObject][keyValuePair[0]] = keyValuePair[1]

        else:

            if readingObject:
                return f"expected a ; before line {lineCount}"

            if str.startswith("default"):

                readingObject = True
                readingDefault = True

                # remove the default part of the string.
                currentObject = str[8:len(str)]

            else:

                cleanStr = str.strip()

                currentObject = f"{cleanStr}_{lineCount}"
                readingObject = True

                if cleanStr in defaultValues.keys():

                    attributes = defaultValues[cleanStr].keys()
                    objects[currentObject] = {}

                    for attribute in attributes:
                        objects[currentObject][attribute] = defaultValues[cleanStr][attribute]

        if str.endswith(";"):

            readingObject = False
            readingDefault = False

    return objects

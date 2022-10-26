const trySetObjects = (rawObjectData) => {

  if(!Array.isArray(rawObjectData)) return "expected an array of strings";

  let readingObject = false, readingDefault = false;

  let lineCount = 0;
  let currentObject;

  let objects = {}, defaultValues = {};

  for (const str of rawObjectData) {

    ++lineCount;

    if (str.startsWith("#") || str.length === 0) continue;

    if (str.startsWith(".")) {

      if (!readingObject)
        return `${str} at line ${lineCount} is supposed to be a property,
        however it is cut off from its parent object. You probably misplaced a
        ; just before that line.`;

      let keyValuePair = str.split("=");

      if (keyValuePair.length < 2)
        return `expected a value after ${str} at line ${lineCount}; property
        cannot be empty.`;

      if (keyValuePair.length > 2)
          keyValuePair[1] = keyValuePair.slice(1).join("=");

      // remove the dot at the beginning of the attribute
      keyValuePair[0] = keyValuePair[0].slice(1);

      // removes the ; from the value if it's at the end of it
      if (keyValuePair[1].endsWith(";"))
        keyValuePair[1] = keyValuePair[1].slice(0, keyValuePair[1].length - 1);

      keyValuePair[0] = keyValuePair[0].trim();
      keyValuePair[1] = keyValuePair[1].trim();

      if (readingDefault) {

        if (!defaultValues.hasOwnProperty(currentObject)) defaultValues[currentObject] = {};
        defaultValues[currentObject][keyValuePair[0]] = keyValuePair[1];
      }

      else {

        if (!objects.hasOwnProperty(currentObject)) objects[currentObject] = {};
        objects[currentObject][keyValuePair[0]] = keyValuePair[1];
      }
    }

    else {

        if (readingObject) return `expected a ; before line ${lineCount}`;

        if (str.startsWith("default")) {

          readingObject = true;
          readingDefault = true;

          // removes the default part of the string
          currentObject = str.slice(7).trim();
        }

        else {

          const cleanStr = str.trim();

          currentObject = `${cleanStr}_${lineCount}`;
          readingObject = true;

          if (defaultValues.hasOwnProperty(cleanStr)) {

            objects[currentObject] = {};

            for (const property in defaultValues[cleanStr])
              objects[currentObject][property] = defaultValues[cleanStr][property];
            }
        }
      }

    if (str.endsWith(";")) {
        
      readingObject = false;
      readingDefault = false;
    }
  }

  return objects;
};

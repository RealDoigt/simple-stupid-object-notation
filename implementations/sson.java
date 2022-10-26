import java.util.HashMap;

public class sson
{
  public class parsingErrorException extends Exception { public ParsingErrorException(String errMsg) { super(errMsg); }}

  public HashMap<String, HashMap<String, String>> trySetObjects(String[] rawObjectData) throws ParsingErrorException
  {
    boolean readingObject = false, readingDefault = false;

    int lineCount = 0;
    var currentObject = "";

    var defaultValues = new HashMap<String, HashMap<String, String>>();
    var objects = new HashMap<String, HashMap<String, String>>();

    for (String str : rawObjectData) {

      ++lineCount;

      if (str.startsWith("#") || str.length() == 0) continue;

      if (str.startsWith(".")) {

        if (!readingObject)
          throw new parsingErrorException(String.format("%s at line %d is supposed to be a property, however it is cut off from its parent object. You probably misplaced a ; just before that line.\n", str, lineCount));

        
        var keyValuePair = str.split("=", 2);

        if (keyValuePair.length < 2)
          throw new parsingErrorException(String.format("Expected a value after %s at line %d; property cannot be empty.\n", str, lineCount));


        keyValuePair[0] = keyValuePair[0].substring(1);

        if (keyValuePair[1].endsWith(";")) 
          keyValuePair[1] = keyValuePair[1].substring(0, keyValuePair[1].length() - 1);

        keyValuePair[0] = keyValuePair[0].trim();
        keyValuePair[1] = keyValuePair[1].trim();

        if (readingDefault) {

          if (!defaultValues.containsKey(currentObject))
            defaultValues.put(currentObject, new HashMap<String, String>());

          if (!defaultValues.get(currentObject).containsKey(keyValuePair[0]))
            defaultValues.get(currentObject).put(keyValuePair[0], keyValuePair[1]);

          else defaultValues.get(currentObject).replace(keyValuePair[0], keyValuePair[1]);
        }

        else {

          if (!objects.containsKey(currentObject))
            objects.put(currentObject, new HashMap<String, String>());

          if (!objects.get(currentObject).containsKey(keyValuePair[0]))
            objects.get(currentObject).put(keyValuePair[0], keyValuePair[1]);

          else objects.get(currentObject).replace(keyValuePair[0], keyValuePair[1]);
        }
      }

      else {

        if (readingObject)
          throw new ParsingErrorException(String.format("Expected a ; before line " + lineCount));

        if (str.startsWith("default")) {

          readingObject = true;
          readingDefault = true;

          // removes the default part of the string.
          currentObject = str.substring(7).trim();
        }

        else {

          var cleanStr = str.trim();

          currentObject = String.format("%s_%s", cleanStr, lineCount);
          readingObject = true;

          if (defaultValues.containsKey(cleanStr)) {

            objects.put(currentObject, new HashMap<String, String>());

            for (var property : defaultValues.get(cleanStr).entrySet())
              objects.get(currentObject).put(property.getKey(), property.getValue());
          }
        }
      }

      if (str.endsWith(";")) {

        if (!readingObject)
          System.err.println("Redundant ; at line " + lineCount);

        readingObject = false;
        readingDefault = false;
      }
    }

    return objects;
  }
}

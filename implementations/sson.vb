Imports System.Collections.Generic

Public Module SSON
	
	Function TrySetObjects(ByRef objects As Dictionary(Of String, Dictionary(Of String, String)), rawObjectData As String()) As Boolean
		
		objects = New Dictionary(Of String, Dictionary(Of String, String))()
		Dim defaultValues = New Dictionary(Of String, Dictionary(Of String, String))()
		
		Dim readingObject = False
		Dim readingDefault = False
		
		Dim lineCount = 0
		Dim currentObject = ""
		
		For Each str As String In rawObjectData
			
			lineCount += 1
			
			If str.StartsWith("#") Or str.Length = 0 Then
				
				Continue For
			End If
			
			If str.StartsWith(".") Then
				
				If Not readingObject Then
					
					Console.Error.WriteLine("{0} at line {1} is supposed to be a property, however it is cut off from its parent object, you probably misplaced a ; just before that line.", str, lineCount)
					Return False
				End If
				
				Dim keyValuePair = str.Split("=".ToCharArray(), 2)
				
				If keyValuePair.Length < 2 Then
					
					Console.Error.WriteLine("expected a value after {0} at line {1}; property cannot be empty", str, lineCount)
					Return False
				End If
				
				' remove the dot at the beginning of the attribute
				keyValuePair(0) = keyValuePair(0).Substring(1)
				
				' removes the ; from the value if it's at the end of it
				If keyValuePair(1).EndsWith(";") Then
					
					keyValuePair(1) = keyValuePair(1).Remove(keyValuePair(1).Length - 1)
				End If
				
				keyValuePair(0) = keyValuePair(0).Trim()
				keyValuePair(1) = keyValuePair(1).Trim()
				
				If readingDefault Then
					
					If Not defaultValues.ContainsKey(currentObject) Then
						
						defaultValues.Add(currentObject, New Dictionary(Of String, String)())
					End If
					
					If Not defaultValues(currentObject).ContainsKey(keyValuePair(0)) Then
						
						defaultValues(currentObject).Add(keyValuePair(0), keyValuePair(1))
						
					Else
						
						defaultValues(currentObject)(keyValuePair(0)) = keyValuePair(1)
					End If
					
				Else
					
					If Not objects.ContainsKey(currentObject) Then
						
						objects.Add(currentObject, New Dictionary(Of String, String)())
					End If
					
					If Not objects(currentObject).ContainsKey(keyValuePair(0)) Then
						
						objects(currentObject).Add(keyValuePair(0), keyValuePair(1))
						
					Else
						
						objects(currentObject)(keyValuePair(0)) = keyValuePair(1)
					End If
				End If
				
			Else If str <> ";" Then
				
				If readingObject Then
					
					Console.Error.WriteLine("expect a ; before line {0}", lineCount)
					Return False
				End If
				
				If str.StartsWith("default") Then
					
					readingObject = True
					readingDefault = True
					
					' removes the default part of the string.
					currentObject = str.Substring(7).Trim()
					
				Else
					
					Dim cleanStr = str.Trim()
					
					currentObject = String.Format("{0}_{1}", cleanStr, lineCount)
					readingObject = True
					
					If defaultValues.ContainsKey(cleanStr) Then
						
						objects.Add(currentObject, New Dictionary(Of String, String)())
						
						For Each attribute As KeyValuePair(Of String, String) In defaultValues(cleanStr)
							
							objects(currentObject).Add(attribute.Key, attribute.Value)
						Next
					End If
				End If
			End If
			
			If str.EndsWith(";") Then
				
				If Not readingObject Then
					
					Console.Error.WriteLine("redundant ; at line {0}", lineCount)
				End If
				
				readingObject = False
				readingDefault = False
			End If
		Next
		
		Return True
	End Function
End Module

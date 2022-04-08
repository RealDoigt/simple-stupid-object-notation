Function TrySetObjects(ByRef objects, rawObjectData)
	
	Set objects = CreateObject("Scripting.Dictionary")
	Dim defaultValues : Set defaultValues = CreateObject("Scripting.Dictionary")
	
	Dim readingObject : readingObject = CBool(0)
	Dim readingDefault : readingDefault = CBool(0)
	
	Dim lineCount : lineCount = 0
	Dim currentObject : currentObject = ""
	
	TrySetObjects = CBool(0)
	
	For Each str In rawObjectData
	
		lineCount = lineCount + 1
		
		If Len(str) = 0 Or Left(str, 1) = "#" Then
			
			' Do nothing
			
			Else
				
				If Left(str, 1) = "." Then
				
					If Not readingObject Then
					
						MsgBox str & " at line " & lineCount & " is supposed to be a property, however it is cut off from its parent object, you probably misplaced a ; just before that line."
						
						Exit Function
					End If
					
					Dim keyValuePair : keyValuePair = Split(str, "=")
					
					If UBound(keyValuePair) < 1 Then
						
						MsgBox "expected a value after " & str & " at line " & lineCount & "; property cannot be empty"
						Exit Function
					End If
					
					' This loop makes it possible to use the = glyph in the property value
					For i = 2 To UBound(keyValuePair)
						
						keyValuePair(1) = keyValuePair(1) & "=" & keyValuePair(i)
					Next
					
					' removes the dot at the beginning of the attribute
					keyValuePair(0) = Right(keyValuePair(0), Len(keyValuePair(0)) - 1)
					
					' removes the ; from the value if it's at the end of it
					If Right(keyValuePair(1), 1) = ";" Then
					
						keyValuePair(1) = Left(keyValuePair(1), Len(keyValuePair(1)) - 1)
					End If
					
					keyValuePair(0) = Trim(keyValuePair(0))
					keyValuePair(1) = Trim(keyValuePair(1))
					
					If readingDefault Then
					
						If Not defaultValues.Exists(currentObject) Then
							
							defaultValues.Add currentObject, CreateObject("Scripting.Dictionary")
						End If
						
						If Not defaultValues(currentObject).Exists(keyValuePair(0)) Then
							
							defaultValues(currentObject).Add keyValuePair(0), keyValuePair(1)
							
						Else
							
							defaultValues(currentObject)(keyValuePair(0)) = keyValuePair(1)
						End If
						
					Else
						
						If Not objects.Exists(currentObject) Then
						
							objects.Add currentObject, CreateObject("Scripting.Dictionary")
						End If
						
						If Not objects(currentObject).Exists(keyValuePair(0)) Then
							
							objects(currentObject).Add keyValuePair(0), keyValuePair(1)
							
						Else
						
							objects(currentObject)(keyValuePair(0)) = keyValuePair(1)
						End If
					End If
					
				Else
					
					If readingObject Then
					
						MsgBox "Expected a ; before line " & lineCount
						Exit Function
					End If
					
					' Check if str starts with default
					If CBool(InStr(1, str, "default", 1)) Then
					
						readingObject = CBool(1)
						readingDefault = CBool(1)
						
						' Removes the default part of the string.
						currentObject = Trim(Right(str, Len(str) - 7))
						
					Else
					
						Dim cleanStr : cleanStr = Trim(str)
						currentObject = cleanStr & "_" & lineCount
						
						readingObject = CBool(1)
						
						If defaultValues.Exists(cleanStr) Then
						
							objects.Add currentObject, CreateObject("Scripting.Dictionary")
							
							Dim properties : properties = defaultValues(cleanStr).Keys
							
							For Each prop In properties
								
								objects(currentObject).Add prop, defaultValues(cleanStr)(prop)
							Next
						End If
					End If
				End If
				
				If Right(str, 1) = ";" Then
				
					readingDefault = CBool(0)
					readingObject = CBool(0)
				End if
		End If
	Next
	
	TrySetObjects = CBool(1)
End Function
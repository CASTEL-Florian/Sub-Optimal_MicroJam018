base64Chars = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
padding = "="

encode = function(rawData)
	if rawData isa string then
		s = rawData
		rawData = new RawData
		rawData.resize s.len * 3
		rawData.resize rawData.setUtf8(0, s)
	end if
	
	encoded = []
	
	byteCount = rawData.len
	for i in range(0, byteCount - 1, 3)
		b1 = rawData.byte(i)
		b2 = 0; if i + 1 < byteCount then b2 = rawData.byte(i + 1)
		b3 = 0; if i + 2 < byteCount then b3 = rawData.byte(i + 2)
		
		encoded.push base64Chars[floor(b1 / 4)]
		encoded.push base64Chars[bitAnd((b1 % 4) * 16, 63) + floor(b2 / 16)]
		
		if i + 1 < byteCount then
			encoded.push base64Chars[bitAnd((b2 % 16) * 4, 63) + floor(b3 / 64)]
		else
			encoded.push padding
		end if
		
		if i + 2 < byteCount then
			encoded.push base64Chars[bitAnd(b3, 63)]
		else
			encoded.push padding
		end if
	end for
	
	return encoded.join("")
end function

decodeToList = function(encodedStr)
	decodedBytes = []
	
	// Function to get the index of a character in base64Chars
	getIndex = function(char)
		return base64Chars.indexOf(char)
	end function

	i = 0
	while i < encodedStr.len
		b1 = base64Chars.indexOf(encodedStr[i])
		b2 = base64Chars.indexOf(encodedStr[i + 1])
		b3 = -1
		if encodedStr[i + 2] != padding then b3 = base64Chars.indexOf(encodedStr[i + 2])
		b4 = -1
		if encodedStr[i + 3] != padding then b4 = base64Chars.indexOf(encodedStr[i + 3])

		decodedBytes.push b1 * 4 + floor(b2 / 16)
		if b3 >= 0 then
			decodedBytes.push (bitAnd(b2, 15) * 16) + floor(b3 / 4)
		end if
		if b4 >= 0 then
			decodedBytes.push (bitAnd(b3, 3) * 64) + b4
		end if

		i += 4
	end while
	
	return decodedBytes
end function

decodeToRawData = function(encodedStr)
	asList = decodeToList(encodedStr)
	result = new RawData
	result.resize asList.len
	for i in asList.indexes
		result.setByte i, asList[i]
	end for
	return result
end function

decodeToString = function(encodedStr)
	rd = decodeToRawData(encodedStr)
	return rd.utf8
end function

runUnitTests = function
	print "Unit testing: base64"
	
	errorCount = 0
	assertEqual = function(actual, expected, note)
		if actual != expected then
			print "Unit test failure (" + note + "): expected " + expected + ", got " + actual + " at " + stackTrace[1]
			outer.errorCount = errorCount + 1
		end if
	end function
	
	assert = function(shouldBeTrue, note)
		if shouldBeTrue then return
		print "Unit test failure (" + note + ")"
	end function
	
	assertEqual encode("Hello world!"), "SGVsbG8gd29ybGQh"
	assertEqual encode("This is a test..."), "VGhpcyBpcyBhIHRlc3QuLi4="
	
	assertEqual decodeToString("SGVsbG8gd29ybGQh"), "Hello world!"
	assertEqual decodeToString("VGhpcyBpcyBhIHRlc3QuLi4="), "This is a test..."
	
	if errorCount == 0 then
		print "All tests passed."
	else
		print errorCount + " error" + "s" * (errorCount!=1) + " found."
	end if
end function

if locals == globals then runUnitTests

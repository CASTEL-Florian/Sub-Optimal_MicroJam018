// This module defines a BitWriter class, which lets you
// write data one bit at a time (or in slightly larger
// chunks), and then get it back out as a RawData.
// You can also go the other way: given a RawData, create
// a BitReader instance, and read data out one bit at
// a time (or in slightly larger chunks).

BitWriter = {}
BitWriter.pendingBits = 0
BitWriter.pendingSize = 0
BitWriter.bytes = null

BitWriter.writeBit = function(b)
	self.pendingBits = self.pendingBits * 2 + b
	self.pendingSize += 1
	if self.pendingSize == 8 then
		if self.bytes == null then self.bytes = []
		self.bytes.push self.pendingBits
		self.pendingBits = 0
		self.pendingSize = 0
	end if
end function

BitWriter.writeByte = function(byte)
	mask = 128
	while mask >= 1
		self.writeBit bitAnd(byte, mask) > 0
		mask /= 2
	end while
end function

BitWriter.getData = function
	if self.pendingSize > 0 then
		// pad out to 8 bits
		while self.pendingSize != 0
			self.writeBit 0
		end while
	end if
	r = new RawData
	r.resize self.bytes.len
	for i in self.bytes.indexes
		r.setByte i, self.bytes[i]
	end for
	return r
end function


BitReader = {}
BitReader.rawData = null
BitReader.index = 0			// byte index of next bit to read
BitReader.bitMask = 128		// mask used to select bit of next byte

BitReader.readBit = function
	b = self.rawData.byte(self.index)
	result = bitAnd(b, self.bitMask) > 0
	if self.bitMask == 1 then
		self.bitMask = 128
		self.index += 1
	else
		self.bitMask /= 2
		if self.bitMask < 1 then self.bitMask = 0
	end if
	return result
end function

BitReader.readByte = function
	result = 0
	for i in range(0, 7)
		result = result * 2 + self.readBit
	end for
	return result
end function

BitReader.atEnd = function
	return self.rawData == null or self.index >= self.rawData.len
end function

runUnitTests = function
	print "Unit testing: bitstream"
	
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
	
	bw = new BitWriter
	for b in [1,0,0,1,1,0,0,1,0,1]
		bw.writeBit b
	end for
	r = bw.getData
	assertEqual r.len, 2
	assertEqual r.byte(0), 153
	assertEqual r.byte(1), 64

	globals.br = new BitReader
	br.rawData = r
	bits = []
	for i in range(0,9)
		bits.push br.readBit
	end for
	assertEqual bits, [1,0,0,1,1,0,0,1,0,1]
	bits = []
	while not br.atEnd
		bits.push br.readBit
	end while
	assertEqual bits, [0, 0, 0, 0, 0, 0]		
	
	if errorCount == 0 then
		print "All tests passed."
	else
		print errorCount + " error" + "s" * (errorCount!=1) + " found."
	end if
end function

if locals == globals then runUnitTests

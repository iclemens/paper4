function out = hexcol(hx)
	out = [hex2dec(hx(1:2)), hex2dec(hx(3:4)), hex2dec(hx(5:6))] / 256;
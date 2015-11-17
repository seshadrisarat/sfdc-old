function htmlEncode(str) {
	return str.replace(/\x26/g,'&amp;').replace(/\x22/g,'&quot;').replace(/\x27/g,'&#39;').replace(/\x3c/g,'&lt;').replace(/\x3e/g,'&gt;');
}
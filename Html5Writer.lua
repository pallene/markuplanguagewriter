--[[
This file is part of markuplanguagewriter. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/markuplanguagewriter/master/COPYRIGHT. No part of markuplanguagewriter, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of markuplanguagewriter. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/markuplanguagewriter/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local Writer = require.sibling.Writer
local XmlWriter = require.sibling.XmlWriter


local Html5Writer = moduleclass('Html5Writer', XmlWriter)

function module:initialize()
	XmlWriter.initialize(self)
end

assert.globalTableHasChieldFieldOfTypeFunctionOrCall('string', 'find')
function module:_constructAttribute(alwaysEscapedCharacters, attributesArray, attributeName, attributeValue)
	if attributeValue == '' then
		return
	end
	
	-- Omit quotemarks if value is 'safe'
	if attributeValue:find('[ >="\']') == nil then
		attributesArray:insert(' ' .. attributeName .. '=' ..attributeValue)
		return
	end
	
	return XmlWriter._constructAttribute(self, alwaysEscapedCharacters, attributesArray, attributeName, attributeValue)
end

module.static.singleton = module:new()

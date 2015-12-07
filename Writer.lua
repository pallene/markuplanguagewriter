--[[
This file is part of markuplanguagewriter. It is subject to the licence terms in the COPYRIGHT file found in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/markuplanguagewriter/master/COPYRIGHT. No part of markuplanguagewriter, including this file, may be copied, modified, propagated, or distributed except according to the terms contained in the COPYRIGHT file.
Copyright © 2015 The developers of markuplanguagewriter. See the COPYRIGHT file in the top-level directory of this distribution and at https://raw.githubusercontent.com/pallene/markuplanguagewriter/master/COPYRIGHT.
]]--


local halimede = require('halimede')
local tabelize = halimede.table.tabelize
local exception = halimede.exception


moduleclass('Writer')

assert.globalTypeIsFunction('setmetatable')
local alwaysEscapedCharacters = {}
alwaysEscapedCharacters['<'] = '&lt;'
alwaysEscapedCharacters['>'] = '&gt;'
alwaysEscapedCharacters['&'] = '&amp;'
alwaysEscapedCharacters = setmetatable(alwaysEscapedCharacters, {
		__index = function(_, matchedCharacter)
			return matchedCharacter
		end
	}
)

function module:initialize()
end

function module:_constructAttribute()
	exception.throw('Abstract Method')
end

assert.globalTypeIsFunction('pairs')
function module:_writeAttributes(attributesTable)
	local attributesArray = tabelize()

	for attributeName, attributeValue in pairs(attributesTable) do
		assert.parameterTypeIsString('attributeName', attributeName)
		assert.parameterTypeIsString('attributeValue', attributeValue)

		self:_constructAttribute(alwaysEscapedCharacters, attributesArray, attributeName, attributeValue)
	end

	-- Sorted to ensure stable, diff-able output
	attributesArray:sort()
	return attributesArray:concat()
end

assert.globalTableHasChieldFieldOfTypeFunction('string', 'gsub')
function module:writeText(rawText)
	assert.parameterTypeIsString('rawText', rawText)

	return rawText:gsub('[<>&]', function(matchedCharacter)
		return alwaysEscapedCharacters[matchedCharacter]
	end)
end

function module:writeElementNameWithAttributes(elementName, attributesTable)
	assert.parameterTypeIsString('elementName', elementName)
	assert.parameterTypeIsTable('attributesTable', attributesTable)

	return elementName .. self:_writeAttributes(attributesTable)
end

function module:writeElementOpenTag(elementNameOrElementNameWithAttributes)
	assert.parameterTypeIsString('elementNameOrElementNameWithAttributes', elementNameOrElementNameWithAttributes)

	return '<' .. elementNameOrElementNameWithAttributes .. '>'
end

function module:writeElementEmptyTag(elementNameOrElementNameWithAttributes)
	assert.parameterTypeIsString('elementNameOrElementNameWithAttributes', elementNameOrElementNameWithAttributes)

	return '<' .. elementNameOrElementNameWithAttributes .. '/>'
end

function module:writeElementCloseTag(elementName)
	assert.parameterTypeIsString('elementName', elementName)

	return '</' .. elementName .. '>'
end

function module:writeElement(elementName, phrasingContent, optionalAttributesTable)
	assert.parameterTypeIsString('elementName', elementName)
	assert.parameterTypeIsString('phrasingContent', phrasingContent)
	assert.parameterTypeIsTableOrNil('optionalAttributesTable', optionalAttributesTable)

	local attributesTable
	if optionalAttributesTable == nil then
		attributesTable = {}
	else
		attributesTable = optionalAttributesTable
	end

	local elementNameWithAttributes = self:writeElementNameWithAttributes(elementName, attributesTable)
	if phrasingContent == '' then
		return self:writeElementEmptyTag(elementNameWithAttributes)
	end
	return self:writeElementOpenTag(elementNameWithAttributes) .. phrasingContent .. self:writeElementCloseTag(elementName)
end

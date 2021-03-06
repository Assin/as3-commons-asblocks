/*
 * ASDoc.g
 * 
 * Copyright (c) 2007 David Holroyd
 * Copyright (c) 2010-2011 Michael Schmalle
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License.
 */

grammar ASDoc;


options {
	k = 4;
	output=AST;
	ASTLabelType=LinkedListTree;
	language=ActionScript;
}

tokens {
	ASDOC;
	INLINE_TAG;
	DESCRIPTION;
	PARA_TAG;
	TEXT_LINE;
	VIRTUAL_WS;
}

@parser::package {org.as3commons.asblocks.parser.antlr.asdoc}

@parser::header {
import org.as3commons.asblocks.parser.antlr.LinkedListToken;
import org.as3commons.asblocks.parser.antlr.LinkedListTree;
import org.antlr.runtime.MismatchedTokenException;
import org.as3commons.asblocks.impl.TokenBuilder;
}

@lexer::package {org.as3commons.asblocks.parser.antlr.asdoc}

@lexer::header {
}

// disable standard error handling; be strict
@rulecatch { }

@parser::members {
	//protected void mismatch(IntStream input, int ttype, BitSet follow)
	//	throws RecognitionException
	//{
	//	throw new MismatchedTokenException(ttype, input);
	//}

	private function placeholder(imaginary:LinkedListTree):void {
		
		if (imaginary.childCount > 0)
			return;

		var tok:LinkedListToken = LinkedListToken(input.LT(1));
		var placeholder:LinkedListToken = TokenBuilder.newPlaceholder(imaginary);
		tok.prependToken(placeholder);
	}

}
@lexer::members {
	//protected void mismatch(IntStream input, int ttype, BitSet follow)
	//	throws RecognitionException
	//{
	//	throw new MismatchedTokenException(ttype, input);
	//}
}

commentBody
	:	d=description {placeholder($d.tree);}
		paragraphTag*
		EOF
		-> ^(ASDOC description paragraphTag*)
	;


description
	:	textLine*
		-> ^(DESCRIPTION textLine*)
	;

textLine
	:	textLineStart textLineContent* (NL | EOF!)
	|	NL
	;

textLineStart
	:	(LBRACE ATWORD)=> inlineTag
	|	WORD | STARS | WS | LBRACE | RBRACE | AT
	;

textLineContent
	:	(LBRACE ATWORD)=> inlineTag
	|	WORD | STARS | WS | LBRACE | RBRACE | AT | ATWORD
	;

inlineTag
	:	LBRACE ATWORD inlineTagContent* RBRACE
		-> ^(INLINE_TAG ATWORD inlineTagContent*)
	;

inlineTagContent
	:	WORD | STARS | WS | AT | NL
	;

paragraphTag
	:	ATWORD paragraphTagTail
		-> ^(PARA_TAG ATWORD paragraphTagTail)
	;

paragraphTagTail
	:	textLineContent*
		(	NL textLine*
		|	EOF
		)
		-> textLineContent* NL? textLine*
	;

STARS:		'*'+ (' ' | '\t')?;

LBRACE:		'{';
RBRACE:		'}';
AT:		'@';

WS:		(' ' | '\t')+;

NL
options {
	k=*;
}
	:		('\r\n' | '\r' | '\n') WS? (STARS)?;

// added this hack for non STAR 1 space tags. In order to keep pre text correct
// this needs to be here or the pre text prefix indentation WS will be 
// consumed in the NL which will flatten it to the left
ATWORD:		WS? '@' WORD WORD_TAIL;

WORD:		~('\n' | ' ' | '\r' | '\t' | '{' | '}' | '@')
		WORD_TAIL;

fragment
WORD_TAIL:	(~('\n' | ' ' | '\r' | '\t' | '{' | '}'))*;

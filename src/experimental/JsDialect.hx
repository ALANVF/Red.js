package experimental;

import Tokenizer;
import tokenizer.Token;
import experimental.jsDialect.Statement.*;
import experimental.jsDialect.Expr;

class JsDialect {
	public static function compile(input: String) {
		final parsedAst = Tokenizer.tokenize(input);
		final headerData = getHeader(parsedAst);
		final header = headerData.header;
		final ast = headerData.rest;
	}

	static function getHeader(ast: Array<Token>) {
		return switch ast.slice(0, 2) {
			case [TPath([TWord("Red"), TWord("JS" | "Js")]), TBlock(header)]:
				{
					header: header,
					rest: ast.slice(2)
				};
			
			case [_] | []:
				throw "Incomplete input!";
			
			default:
				getHeader(ast.slice(2));
		};
	}

	static function nextStatement(ast: Array<Token>) {
		return switch ast[0] {
			case TTag("js") if(ast.length >= 2):
				switch ast[1] {
					case TString(code):
						{made: SJs(code), rest: ast.slice(2)};
					
					case tok:
						throw 'Unexpected token `$tok`!';
				}
			
			case TTag("label") if(ast.length >= 2):
				switch ast[1] {
					case TWord(label) | TGetWord(label) | TSetWord(label) | TLitWord(label):
						var res = nextStatement(ast.slice(2));
						{made: SLabel(label, res.made), rest: res.rest};
					
					case _:
						throw "error!";
				}
			
			// ...
			
			case _:
				throw "error!";
		}
	}

	static function nextExpr(ast: Array<Token>) {

	}
}
package runtime;

import types.base.Options;
import types.base._ActionOptions;
import types.base.ComparisonOp;
import types.base.CompareResult;
import types.base._Number;
import types.Value;
import types.Logic;
import types.Integer;
import types.Word;
import types.Action;
import types.TypeKind;
import types.None;
import types.Unset;
import runtime.actions.datatypes.*;

@:publicFields
class Actions {
	private static final ACTIONS = Dict.of(([
		DDatatype => new DatatypeActions(),
		DUnset => new UnsetActions(),
		DNone => new NoneActions(),
		DLogic => new LogicActions(),
		DBlock => new BlockActions(),
		DParen => new ParenActions(),
		DString => new StringActions(),
		DFile => new FileActions(),
		DUrl => new UrlActions(),
		DChar => new CharActions(),
		DInteger => new IntegerActions(),
		DFloat => new FloatActions(),
		DWord => new WordActions(),
		DSetWord => new SetWordActions(),
		DLitWord => new LitWordActions(),
		DGetWord => new GetWordActions(),
		DRefinement => new RefinementActions(),
		DIssue => new IssueActions(),
		DNative => new NativeActions(),
		DAction => new ActionActions(),
		DOp => new OpActions(),
		DFunction => new FunctionActions(),
		DPath => new PathActions(),
		DLitPath => new LitPathActions(),
		DSetPath => new SetPathActions(),
		DGetPath => new GetPathActions(),
		DBitset => new BitsetActions(),
		DPoint2D => new Point2DActions(),
		DPoint3D => new Point3DActions(),
		DObject => new ObjectActions(),
		DError => new ErrorActions(),
		DTypeset => new TypesetActions(),
		DHash => new HashActions(),
		DPair => new PairActions(),
		DPercent => new PercentActions(),
		DTuple => new TupleActions(),
		DMap => new MapActions(),
		DBinary => new BinaryActions(),
		DTime => new TimeActions(),
		DTag => new TagActions(),
		DEmail => new EmailActions(),
		DDate => new DateActions(),
		DMoney => new MoneyActions(),
		DRef => new RefActions(),
		DJsRoutine => new JsRoutineActions()
	] : Dict<TypeKind, ValueActions<Value>>));

	static inline function get(kind: TypeKind) {
		return ACTIONS[kind].nonNull();
	}

	static inline function getFor(value: Value) return ACTIONS[value.TYPE_KIND].nonNull();

	static function callAction(action: Action, args: Array<Value>, refines: Dict<String, Array<Value>>) {
		return switch [action.fn, args] {
			case [AForm(f), [v]]: f(v, Options.fromRefines(AFormOptions, refines));
			case [AMold(f), [v]]: f(v, Options.fromRefines(AMoldOptions, refines));
			
			case [AEvalPath(_) | ACompare(_), _]: throw "this can't be called directly!";
			
			case [AAbsolute(f) | ANegate(f)
				| AComplement(f)
				| ABack(f) | AClear(f) | AHead(f) | ALength_q(f) | ANext(f) | ATail(f)
				| ACreate(f) | ADelete(f) | AQuery(f), [v]]: f(v);
			case [AEven_q(f) | AOdd_q(f)
				| AHead_q(f) | ATail_q(f), [v]]: f(v);
			case [AIndex_q(f), [v]]: f(v);
			case [ARandom(f), [v]]: f(v, Options.fromRefines(ARandomOptions, refines));
			case [ARound(f), [v]]: f(v, Options.fromRefines(ARoundOptions, refines));
			case [ACopy(f), [v]]: f(v, Options.fromRefines(ACopyOptions, refines));
			case [ARemove(f), [v]]: f(v, Options.fromRefines(ARemoveOptions, refines));
			case [AReverse(f), [v]]: f(v, Options.fromRefines(AReverseOptions, refines));
			case [ASort(f), [v]]: f(v, Options.fromRefines(ASortOptions, refines));
			case [ATake(f), [v]]: f(v, Options.fromRefines(ATakeOptions, refines));
			case [ATrim(f), [v]]: f(v, Options.fromRefines(ATrimOptions, refines));
			case [AOpen(f), [v]]: f(v, Options.fromRefines(AOpenOptions, refines));
			case [ARead(f), [v]]: f(v, Options.fromRefines(AReadOptions, refines));
			
			case [AMake(f) | ATo(f)
				| AAdd(f) | ASubtract(f) | AMultiply(f) | ADivide(f) | ARemainder(f)
				| AAnd(f) | AOr(f) | AXor(f)
				| AAt(f) | APick(f) | ASkip(f) | ASwap(f)
				| ARename(f), [v1, v2]]: f(v1, v2);
			case [APower(f), [v1, v2]]: f(Std.downcast(v1, _Number).nonNull(), Std.downcast(v2, _Number).nonNull());
			case [AReflect(f), [v1, v2]]: f(v1, Std.downcast(v2, Word).nonNull());
			case [AAppend(f), [v1, v2]]: f(v1, v2, Options.fromRefines(AAppendOptions, refines));
			case [AChange(f), [v1, v2]]: f(v1, v2, Options.fromRefines(AChangeOptions, refines));
			case [AFind(f), [v1, v2]]: f(v1, v2, Options.fromRefines(AFindOptions, refines));
			case [AInsert(f), [v1, v2]]: f(v1, v2, Options.fromRefines(AInsertOptions, refines));
			case [AMove(f), [v1, v2]]: f(v1, v2, Options.fromRefines(AMoveOptions, refines));
			case [ASelect(f), [v1, v2]]: f(v1, v2, Options.fromRefines(ASelectOptions, refines));
			case [AWrite(f), [v1, v2]]: f(v1, v2, Options.fromRefines(AWriteOptions, refines));
			
			case [APoke(f), [v1, v2, v3]]: f(v1, v2, v3);
			case [AModify(f), [v1, v2, v3]]: f(v1, Std.downcast(v2, Word).nonNull(), v3, Options.fromRefines(AModifyOptions, refines));
			case [APut(f), [v1, v2, v3]]: f(v1, v2, v3, Options.fromRefines(APutOptions, refines));
			// ...
			default: throw "Invalid number of args";
		}
	}
	
	static function compare(value1: Value, value2: Value, op: ComparisonOp) {
		final cmp = getFor(value1).compare(value1, value2, op);
		
		if(cmp == IsInvalid &&
			!( op == CEqual
			|| op == CSame
			|| op == CStrictEqual
			|| op == CStrictEqualWord
			|| op == CNotEqual
			|| op == CFind)
		) {
			throw 'Invalid comparison: $value1, $op, $value2';
		}
		
		return Logic.fromCond(switch op {
			case CEqual | CFind | CSame | CStrictEqual | CStrictEqualWord: cmp == IsSame;
			case CNotEqual: cmp != IsSame;
			case CLesser: cmp == IsLess;
			case CLesserEqual: cmp != IsMore;
			case CGreater: cmp == IsMore;
			case CGreaterEqual: cmp != IsLess;
			default: throw "error!";
		});
	}

	static function compareValue(value1: Value, value2: Value, op: ComparisonOp, flags: Int = 0): CompareResult {
		final res = value1._match(
			at(l1 is Logic) => (untyped l1.cond - (untyped value2 : Logic).cond),
			at(f is types.base._Function) => (value1 == value2 ? 0 : -1),
			at(_ is None | _ is Unset) => 0,
			_ => cast getFor(value1).compare(value1, value2, op)
		);
		return cast if(flags & Sort.REVERSE_MASK != 0) -res else res;
	}

	static function evalPath(parent: Value, element: Value, ?value: Value) {
		return getFor(parent).evalPath(
			parent,
			element,
			value,
			null,
			null,
			null,
			-1,
			false,
			false,
			true
		);
	}
}
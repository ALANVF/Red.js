import {system$words} from "./system";
import * as Red from "../red-types";
import * as RedEval from "./eval";

import * as ACT_datatype   from "./datatypes/datatype";
import * as ACT_unset      from "./datatypes/unset";
import * as ACT_none       from "./datatypes/none";
import * as ACT_logic      from "./datatypes/logic";
import * as ACT_block      from "./datatypes/block";
import * as ACT_paren      from "./datatypes/paren";
import * as ACT_string     from "./datatypes/string";
import * as ACT_file       from "./datatypes/file";
import * as ACT_url        from "./datatypes/url";
import * as ACT_char       from "./datatypes/char";
import * as ACT_integer    from "./datatypes/integer";
import * as ACT_float      from "./datatypes/float";
import * as ACT_context    from "./datatypes/context";
import * as ACT_word       from "./datatypes/word";
import * as ACT_setWord    from "./datatypes/set-word";
import * as ACT_litWord    from "./datatypes/lit-word";
import * as ACT_getWord    from "./datatypes/get-word";
import * as ACT_refinement from "./datatypes/refinement";
import * as ACT_issue      from "./datatypes/issue";
import * as ACT_native     from "./datatypes/native";
import * as ACT_action     from "./datatypes/action";
import * as ACT_op         from "./datatypes/op";
import * as ACT_function   from "./datatypes/function";
import * as ACT_path       from "./datatypes/path";
import * as ACT_litPath    from "./datatypes/lit-path";
import * as ACT_setPath    from "./datatypes/set-path";
import * as ACT_getPath    from "./datatypes/get-path";
import * as ACT_bitset     from "./datatypes/bitset";
import * as ACT_object     from "./datatypes/object";
import * as ACT_typeset    from "./datatypes/typeset";
import * as ACT_vector     from "./datatypes/vector";
import * as ACT_hash       from "./datatypes/hash";
import * as ACT_pair       from "./datatypes/pair";
import * as ACT_percent    from "./datatypes/percent";
import * as ACT_tuple      from "./datatypes/tuple";
import * as ACT_map        from "./datatypes/map";
import * as ACT_binary     from "./datatypes/binary";
import * as ACT_series     from "./datatypes/series";
import * as ACT_time       from "./datatypes/time";
import * as ACT_tag        from "./datatypes/tag";
import * as ACT_email      from "./datatypes/email";
import * as ACT_date       from "./datatypes/date";

module RedActions {
	export interface RandomOptions {
		seed?:   true;
		secure?: true;
		only?:   true;
	}

	export interface MoldOptions {
		only?:   true;
		all?:    true;
		flat?:   true;
		part?:   number;
	}

	export interface RoundOptions {
		to?:          Red.RawNumber|Red.RawTime;
		even?:        true;
		down?:        true;
		halfDown?:    true;
		floor?:       true;
		ceiling?:     true;
		halfCeiling?: true;
	}

	export interface AppendOptions {
		part?: number;
		only?: true;
		dup?:  number;
	}

	export interface ChangeOptions {
		part?: number;
		only?: true;
		dup?:  number;
	}

	export interface CopyOptions {
		part?:  number;
		deep?:  true;
		types?: Red.RawDatatype|Red.RawTypeset;
	}

	export interface FindOptions {
		part?:    number;
		only?:    true;
		case?:    true;
		same?:    true;
		any?:     true;
		with?:    string;
		skip?:    number;
		last?:    true;
		reverse?: true;
		tail?:    true;
		match?:   true;
	}

	export interface InsertOptions {
		part?: number;
		only?: true;
		dup?:  number;
	}

	export interface RemoveOptions {
		part?: Red.RawNumber|Red.RawChar|Red.RawSeries;
		key?:  Red.RawScalar|Red.RawAnyString|Red.RawAnyWord|Red.RawBinary|Red.RawBlock;
	}

	export interface SelectOptions {
		part?:    number;
		only?:    true;
		case?:    true;
		same?:    true;
		any?:     true;
		with?:    string;
		skip?:    number;
		last?:    true;
		reverse?: true;
	}
	
	export interface SortOptions {
		case?:    true;
		skip?:    number;
		compare?: Red.RawInteger|Red.RawBlock|Red.RawAnyFunc;
		part?:    number;
		all?:     true;
		reverse?: true;
		stable?:  true;
	}

	export interface TakeOptions {
		part?: number;
		deep?: true;
		last?: true;
	}

	export interface TrimOptions {
		head?:  true;
		tail?:  true;
		auto?:  true;
		lines?: true;
		all?:   true;
		with?:  Red.RawChar|Red.RawString|Red.RawInteger;
	}

	/*
	export interface TypeActions<Sender extends Red.AnyType> {
		$evalPath?:    (ctx: Red.Context, sender: Sender, a: Red.AnyType, b: boolean) => Red.AnyType;
		$setPath?:     (ctx: Red.Context, sender: Sender, a: Red.AnyType, b: Red.AnyType, c: boolean) => Red.AnyType;
		$add?:         (ctx: Red.Context, sender: Sender, a: Red.AnyType, b: boolean) => void;
		$compare?:     (ctx: Red.Context, sender: Sender, a: Red.AnyType, b: Red.ComparisonOp) => Red.CompareResult;
		
		$$make?:       (ctx: Red.Context, sender: Red.AnyType, a: Red.AnyType) => Red.AnyType;
		$$random?:     (ctx: Red.Context, sender: Sender, a?: RandomOptions) => Red.AnyType;
		$$reflect?:    (ctx: Red.Context, sender: Sender, a: string) => Red.AnyType;
		$$to?:         (ctx: Red.Context, sender: Sender, a: Red.AnyType) => Red.AnyType;
		$$form?:       (ctx: Red.Context, sender: Sender, a: string[], b?: number) => boolean;
		$$mold?:       (ctx: Red.Context, sender: Sender, a: string[], b: number, c?: MoldOptions) => boolean;
		$$modify?:     (ctx: Red.Context, sender: Red.RawSeries|Red.RawObject, a: string, b: Red.AnyType, c: boolean) => Red.AnyType;
		$$absolute?:   (ctx: Red.Context, sender: Sender) => Red.AnyType;
		$$add?:        (ctx: Red.Context, sender: Sender, a: Red.AnyType) => Red.AnyType;
		$$divide?:     (ctx: Red.Context, sender: Sender, a: Red.AnyType) => Red.AnyType;
		$$multiply?:   (ctx: Red.Context, sender: Sender, a: Red.AnyType) => Red.AnyType;
		$$negate?:     (ctx: Red.Context, sender: Sender) => Red.AnyType;
		$$power?:      (ctx: Red.Context, sender: Red.RawNumber, a: Red.RawNumber) => Red.RawNumber;
		$$remainder?:  (ctx: Red.Context, sender: Sender, a: Red.AnyType) => Red.AnyType;
		$$round?:      (ctx: Red.Context, sender: Red.RawNumber|Red.RawTime|Red.RawPair, a?: RoundOptions) => Sender;
		$$subtract?:   (ctx: Red.Context, sender: Sender, a: Red.AnyType) => Red.AnyType;
		$$even_q?:     (ctx: Red.Context, sender: Red.RawNumber|Red.RawChar|Red.RawTime) => Red.RawLogic;
		$$odd_q?:      (ctx: Red.Context, sender: Red.RawNumber|Red.RawChar|Red.RawTime) => Red.RawLogic;
		$$and_t?:      (ctx: Red.Context, sender: Sender, a: Red.AnyType) => Red.AnyType;
		$$complement?: (ctx: Red.Context, sender: Sender) => Red.AnyType;
		$$or_t?:       (ctx: Red.Context, sender: Sender, a: Red.AnyType) => Red.AnyType;
		$$xor_t?:      (ctx: Red.Context, sender: Sender, a: Red.AnyType) => Red.AnyType;
		$$append?:     (ctx: Red.Context, sender: Red.RawSeries, a: Red.AnyType, b?: AppendOptions) => Red.RawSeries;
		$$at?:         (ctx: Red.Context, sender: Red.RawSeries, a: number) => Red.RawSeries;
		$$back?:       (ctx: Red.Context, sender: Red.RawSeries) => Red.RawSeries;
		$$change?:     (ctx: Red.Context, sender: Red.RawSeries, a: Red.AnyType, b?: ChangeOptions) => Red.RawSeries;
		$$clear?:      (ctx: Red.Context, sender: Red.RawSeries|Red.RawBitset|Red.RawMap|Red.RawNone) => Sender;
		$$copy?:       (ctx: Red.Context, sender: Red.RawSeries|Red.RawMap|Red.Context|Red.RawObject|Red.RawBitset|Red.RawAnyFunc, a?: CopyOptions) => Sender;
		$$find?:       (ctx: Red.Context, sender: Red.RawSeries|Red.RawBitset|Red.RawTypeset|Red.RawMap|Red.RawNone, a: Red.AnyType, b?: FindOptions) => Red.AnyType;
		$$head?:       (ctx: Red.Context, sender: Red.RawSeries) => Red.RawSeries;
		$$head_q?:     (ctx: Red.Context, sender: Red.RawSeries) => Red.RawLogic;
		$$index_q?:    (ctx: Red.Context, sender: Red.RawSeries) => Red.RawInteger;
		$$insert?:     (ctx: Red.Context, sender: Red.RawSeries|Red.RawBitset, a: Red.AnyType, b?: InsertOptions) => Sender;
		$$length_q?:   (ctx: Red.Context, sender: Red.RawSeries) => Red.RawInteger;
		$$move?:       (ctx: Red.Context, sender: Red.RawSeries, a: Red.RawSeries, b?: number) => Red.RawSeries;
		$$next?:       (ctx: Red.Context, sender: Red.RawSeries) => Red.RawSeries;
		$$pick?:       (ctx: Red.Context, sender: Red.RawSeries|Red.RawBitset, a: Red.AnyType) => Red.AnyType;
		$$poke?:       (ctx: Red.Context, sender: Red.RawSeries|Red.RawBitset, a: Red.AnyType, b: Red.AnyType) => Red.AnyType;
		$$put?:        (ctx: Red.Context, sender: Red.RawSeries|Red.RawMap|Red.RawObject, a: Red.RawScalar|Red.RawAnyString|Red.RawAnyWord, b: Red.AnyType, c: boolean) => Sender;
		$$remove?:     (ctx: Red.Context, sender: Red.RawSeries|Red.RawBitset|Red.RawMap|Red.RawNone, a?: RemoveOptions) => Sender;
		$$reverse?:    (ctx: Red.Context, sender: Red.RawSeries|Red.RawPair|Red.RawTuple, a?: number) => Sender;
		$$select?:     (ctx: Red.Context, sender: Red.RawSeries|Red.RawObject|Red.RawMap|Red.RawNone, a: Red.AnyType, b?: SelectOptions) => Red.AnyType;
		$$sort?:       (ctx: Red.Context, sender: Red.RawSeries, a?: SortOptions) => Red.RawSeries;
		$$skip?:       (ctx: Red.Context, sender: Red.RawSeries, a: number) => Red.RawSeries;
		$$swap?:       (ctx: Red.Context, sender: Red.RawSeries, a: Red.RawSeries) => Red.RawSeries;
		$$tail?:       (ctx: Red.Context, sender: Red.RawSeries) => Red.RawSeries;
		$$tail_q?:     (ctx: Red.Context, sender: Red.RawSeries) => Red.RawLogic;
		$$take?:       (ctx: Red.Context, sender: Red.RawSeries, a?: TakeOptions) => Red.AnyType;
		$$trim?:       (ctx: Red.Context, sender: Red.RawSeries, a?: TrimOptions) => Red.RawSeries;
		// create
		// close
		// delete
		// open
		// open?
		// query
		// read
		// rename
		// update
		// write
	}
	*/
	
	export interface BasicTypeActions<Sender = any> {
		$evalPath?:    (ctx: Red.Context, sender: Sender, a: Red.AnyType, b: boolean)                 => Red.AnyType;
		$setPath?:     (ctx: Red.Context, sender: Sender, a: Red.AnyType, b: Red.AnyType, c: boolean) => Red.AnyType;
		$addPath?:     (ctx: Red.Context, sender: Sender, a: Red.AnyType, b: boolean)                 => void;
		$compare?:     (ctx: Red.Context, sender: Sender, a: any, b: Red.ComparisonOp)                => Red.CompareResult;
		
		$$make?:       (ctx: Red.Context, sender: Red.AnyType, a: any)                                => Red.AnyType;
		$$random?:     (ctx: Red.Context, sender: Sender, a?: RandomOptions)                          => Red.AnyType;
		$$reflect?:    (ctx: Red.Context, sender: Sender, a: string)                                  => Red.AnyType;
		$$to?:         (ctx: Red.Context, sender: Sender, a: any)                                     => Red.AnyType;
		$$form?:       (ctx: Red.Context, sender: Sender, a: string[], b?: number)                    => boolean;
		$$mold?:       (ctx: Red.Context, sender: Sender, a: string[], b: number, c?: MoldOptions)    => boolean;
		$$modify?:     (ctx: Red.Context, sender: Sender, a: string, b: any, c: boolean)              => Red.AnyType;
		$$absolute?:   (ctx: Red.Context, sender: Sender)                                             => Red.AnyType;
		$$add?:        (ctx: Red.Context, sender: Sender, a: any)                                     => Red.AnyType;
		$$divide?:     (ctx: Red.Context, sender: Sender, a: any)                                     => Red.AnyType;
		$$multiply?:   (ctx: Red.Context, sender: Sender, a: any)                                     => Red.AnyType;
		$$negate?:     (ctx: Red.Context, sender: Sender)                                             => Red.AnyType;
		$$power?:      (ctx: Red.Context, sender: Sender, a: any)                                     => Red.RawNumber;
		$$remainder?:  (ctx: Red.Context, sender: Sender, a: any)                                     => Red.AnyType;
		$$round?:      (ctx: Red.Context, sender: Sender, a?: RoundOptions)                           => Sender;
		$$subtract?:   (ctx: Red.Context, sender: Sender, a: any)                                     => Red.AnyType;
		$$even_q?:     (ctx: Red.Context, sender: Sender)                                             => Red.RawLogic;
		$$odd_q?:      (ctx: Red.Context, sender: Sender)                                             => Red.RawLogic;
		$$and_t?:      (ctx: Red.Context, sender: Sender, a: any)                                     => Red.AnyType;
		$$complement?: (ctx: Red.Context, sender: Sender)                                             => Red.AnyType;
		$$or_t?:       (ctx: Red.Context, sender: Sender, a: any)                                     => Red.AnyType;
		$$xor_t?:      (ctx: Red.Context, sender: Sender, a: any)                                     => Red.AnyType;
		$$append?:     (ctx: Red.Context, sender: Sender, a: any, b?: AppendOptions)                  => Red.RawSeries;
		$$at?:         (ctx: Red.Context, sender: Sender, a: number)                                  => Red.RawSeries;
		$$back?:       (ctx: Red.Context, sender: Sender)                                             => Red.RawSeries;
		$$change?:     (ctx: Red.Context, sender: Sender, a: any, b?: ChangeOptions)                  => Red.RawSeries;
		$$clear?:      (ctx: Red.Context, sender: Sender)                                             => Sender;
		$$copy?:       (ctx: Red.Context, sender: Sender, a?: CopyOptions)                            => Sender;
		$$find?:       (ctx: Red.Context, sender: Sender, a: Red.AnyType, b?: FindOptions)            => Red.AnyType;
		$$head?:       (ctx: Red.Context, sender: Sender)                                             => Red.RawSeries;
		$$head_q?:     (ctx: Red.Context, sender: Sender)                                             => Red.RawLogic;
		$$index_q?:    (ctx: Red.Context, sender: Sender)                                             => Red.RawInteger;
		$$insert?:     (ctx: Red.Context, sender: Sender, a: Red.AnyType, b?: InsertOptions)          => Sender;
		$$length_q?:   (ctx: Red.Context, sender: Sender)                                             => Red.RawInteger;
		$$move?:       (ctx: Red.Context, sender: Sender, a: Red.RawSeries, b?: number)               => Red.RawSeries;
		$$next?:       (ctx: Red.Context, sender: Sender)                                             => Red.RawSeries;
		$$pick?:       (ctx: Red.Context, sender: Sender, a: Red.AnyType)                             => Red.AnyType;
		$$poke?:       (ctx: Red.Context, sender: Sender, a: Red.AnyType, b: Red.AnyType)             => Red.AnyType;
		$$put?:        (ctx: Red.Context, sender: Sender, a: any, b: Red.AnyType, c: boolean)         => Sender;
		$$remove?:     (ctx: Red.Context, sender: Sender, a?: RemoveOptions)                          => Sender;
		$$reverse?:    (ctx: Red.Context, sender: Sender, a?: number)                                 => Sender;
		$$select?:     (ctx: Red.Context, sender: Sender, a: Red.AnyType, b?: SelectOptions)          => Red.AnyType;
		$$sort?:       (ctx: Red.Context, sender: Sender, a?: SortOptions)                            => Red.RawSeries;
		$$skip?:       (ctx: Red.Context, sender: Sender, a: number)                                  => Red.RawSeries;
		$$swap?:       (ctx: Red.Context, sender: Sender, a: Red.RawSeries)                           => Red.RawSeries;
		$$tail?:       (ctx: Red.Context, sender: Sender)                                             => Red.RawSeries;
		$$tail_q?:     (ctx: Red.Context, sender: Sender)                                             => Red.RawLogic;
		$$take?:       (ctx: Red.Context, sender: Sender, a?: TakeOptions)                            => Red.AnyType;
		$$trim?:       (ctx: Red.Context, sender: Sender, a?: TrimOptions)                            => Red.RawSeries;
		// create
		// close
		// delete
		// open
		// open?
		// query
		// read
		// rename
		// update
		// write
		// ... finish later
		// ... https://github.com/red/red/blob/master/runtime/actions.reds
		// ... https://github.com/red/red/blob/master/environment/actions.red
	}

	type TypeActionsFunc = (ctx: Red.Context, sender: any, ...rest: any[]) => any;

	export type TypeActionsSet = BasicTypeActions[];


	export const ACT: Record<string, TypeActionsSet> = {
		"ACT_VALUE":      [],
		"ACT_DATATYPE":   [ACT_datatype],
		"ACT_UNSET":      [ACT_unset],
		"ACT_NONE":       [ACT_none],
		"ACT_LOGIC":      [ACT_logic],
		"ACT_BLOCK":      [ACT_block, ACT_series],
		"ACT_PAREN":      [ACT_paren, ACT_block, ACT_series],
		"ACT_STRING":     [ACT_string, ACT_series],
		"ACT_FILE":       [ACT_file, ACT_string, ACT_series],
		"ACT_URL":        [ACT_url, ACT_string, ACT_series],
		"ACT_CHAR":       [ACT_char],
		"ACT_INTEGER":    [ACT_integer],
		"ACT_FLOAT":      [ACT_float],
		"ACT_SYMBOL":     [],
		"ACT_CONTEXT":    [ACT_context],
		"ACT_WORD":       [ACT_word],
		"ACT_SET_WORD":   [ACT_setWord, ACT_word],
		"ACT_LIT_WORD":   [ACT_litWord, ACT_word],
		"ACT_GET_WORD":   [ACT_getWord, ACT_word],
		"ACT_REFINEMENT": [ACT_refinement, ACT_word],
		"ACT_ISSUE":      [ACT_issue, ACT_word],
		"ACT_NATIVE":     [ACT_native],
		"ACT_ACTION":     [ACT_action],
		"ACT_OP":         [ACT_op],
		"ACT_FUNCTION":   [ACT_function],
		"ACT_PATH":       [ACT_path, ACT_block, ACT_series],
		"ACT_LIT_PATH":   [ACT_litPath, ACT_path, ACT_block, ACT_series],
		"ACT_SET_PATH":   [ACT_setPath, ACT_path, ACT_block, ACT_series],
		"ACT_GET_PATH":   [ACT_getPath, ACT_path, ACT_block, ACT_series],
		"ACT_ROUTINE":    [],
		"ACT_BITSET":     [ACT_bitset],
		"ACT_POINT":      [],
		"ACT_OBJECT":     [ACT_object, ACT_context],
		"ACT_TYPESET":    [ACT_typeset],
		"ACT_ERROR":      [],
		"ACT_VECTOR":     [ACT_vector, ACT_series],
		"ACT_HASH":       [ACT_hash, ACT_block, ACT_series],
		"ACT_PAIR":       [ACT_pair],
		"ACT_PERCENT":    [ACT_percent, ACT_float],
		"ACT_TUPLE":      [ACT_tuple],
		"ACT_MAP":        [ACT_map],
		"ACT_BINARY":     [ACT_binary, ACT_string, ACT_series],
		"ACT_SERIES":     [ACT_series],
		"ACT_TIME":       [ACT_time],
		"ACT_TAG":        [ACT_tag, ACT_string, ACT_series],
		"ACT_EMAIL":      [ACT_email, ACT_string, ACT_series],
		"ACT_HANDLE":     [],
		"ACT_DATE":       [ACT_date],
		"ACT_PORT":       [],
		"ACT_IMAGE":      [ACT_series],
		"ACT_EVENT":      [],
		"ACT_CLOSURE":    [],
		"ACT_MONEY":      [], // https://github.com/9214/red/blob/money/runtime/datatypes/money.reds
		"ACT_REF":        [ACT_string, ACT_series]
	};

	type ActionName = keyof BasicTypeActions;

	
	/* Native functions */
	function getActionsForValue(value: Red.AnyType): TypeActionsSet {
		return Object.values(ACT)[Red.typeOf(value)];
	}

	function hasAction(
		actObj: TypeActionsSet,
		action: ActionName
	): boolean {
		if(actObj.length != 0) {
			for(const obj of actObj) {
				if(action in obj) {
					return true;
				}
			}
		}
		
		return false;
	}

	function sendAction(
		actObj:  TypeActionsSet,
		action:  ActionName,
		ctx:     Red.Context,
		value:   Red.AnyType,
		...args: any[]
	): any {
		if(actObj.length == 0) {
			throw new Error(`This type has no actions! (${Red.typeName(value)})`);
		} else {
			for(const obj of actObj) {
				if(action in obj) {
					return (obj[action] as TypeActionsFunc)(ctx, value, ...args);
				}
			}

			throw new Error(`Action ${action} doesn't exist for type of ${Red.typeName(value)}`);
		}
	}

	export function valueSendAction(
		action:  ActionName,
		ctx:     Red.Context,
		value:   Red.AnyType,
		...args: any[]
	): any {
		return sendAction(getActionsForValue(value), action, ctx, value, ...args);
	}


	export function $evalPath(
		ctx:      Red.Context,
		value:    Red.AnyType,
		accessor: Red.AnyType,
		isCase:   Red.RawLogic
	): Red.AnyType {
		if(accessor instanceof Red.RawGetWord || accessor instanceof Red.RawGetPath || accessor instanceof Red.RawParen) {
			accessor = RedEval.evalSingle(ctx, accessor, false);
		}
		
		return valueSendAction("$evalPath", ctx, value, accessor, isCase.cond);
	}

	export const EVAL_PATH = new Red.Action(
		"eval-path*",
		null,
		[
			new Red.RawArgument(new Red.RawWord("value")),
			new Red.RawArgument(new Red.RawLitWord("accessor")),
			new Red.RawArgument(new Red.RawWord("case?"))
		],
		[],
		null,
		$evalPath
	);
	
	system$words.addWord("eval-path*", EVAL_PATH);

	export function $setPath(
		ctx:      Red.Context,
		value:    Red.AnyType,
		accessor: Red.AnyType,
		newValue: Red.AnyType,
		isCase:   Red.RawLogic
	): Red.AnyType {
		if(accessor instanceof Red.RawGetWord || accessor instanceof Red.RawGetPath || accessor instanceof Red.RawParen) {
			accessor = RedEval.evalSingle(ctx, accessor, false);
		}
		
		return valueSendAction("$setPath", ctx, value, accessor, newValue, isCase.cond);
	}

	export const SET_PATH = new Red.Action(
		"set-path*",
		null,
		[
			new Red.RawArgument(new Red.RawWord("value")),
			new Red.RawArgument(new Red.RawLitWord("accessor")),
			new Red.RawArgument(new Red.RawWord("new-value")),
			new Red.RawArgument(new Red.RawWord("case?"))
		],
		[],
		null,
		$setPath
	);
	
	system$words.addWord("eval-path*", EVAL_PATH);
	
	export function $addPath(
		ctx:      Red.Context,
		value:    Red.AnyType,
		accessor: Red.AnyType,
		isCase:   Red.RawLogic
	) {
		valueSendAction("$addPath", ctx, value, accessor, isCase.cond);
	}
	

	export function $compare(
		ctx:    Red.Context,
		value1: Red.AnyType,
		value2: Red.AnyType,
		op:     Red.ComparisonOp
	): Red.RawLogic {
		const actions = getActionsForValue(value1);
		let value: Red.CompareResult;

		if(hasAction(actions, "$compare")) {
			value = sendAction(actions, "$compare", ctx, value1, value2, op);
		} else {
			if(value1.constructor === value2.constructor) {
				switch(value1.constructor) {
					case Red.RawLogic:
						value = +(value1 as Red.RawLogic).cond - +(value2 as Red.RawLogic).cond as Red.CompareResult;
						break;
					case Red.RawFunction:
					case Red.Action:
					case Red.Native:
					case Red.Op:
						value = (value1 == value2) ? 0 : -2;
						break;
					case Red.RawNone:
					case Red.RawUnset:
						value = 0;
						break;
					default:
						throw new Error(`Action $compare doesn't exist for type of ${Red.typeName(value1)}`);
				}
			} else {
				throw new Error(`Action $compare doesn't exist for type of ${Red.typeName(value1)}`);
			}
		}
		
		if(
			value == -2
				&&
			![
				Red.ComparisonOp.EQUAL,
				Red.ComparisonOp.SAME,
				Red.ComparisonOp.STRICT_EQUAL,
				Red.ComparisonOp.STRICT_EQUAL_WORD,
				Red.ComparisonOp.NOT_EQUAL,
				Red.ComparisonOp.FIND
			].includes(op)
		) {
			throw new Error(`Invalid comparison: ${$$mold(ctx, value1).toJsString()}, ${op}, ${$$mold(ctx, value2).toJsString()}`);
		}

		switch(op) {
			case Red.ComparisonOp.EQUAL:
			case Red.ComparisonOp.FIND:
			case Red.ComparisonOp.SAME:
			case Red.ComparisonOp.STRICT_EQUAL:
			case Red.ComparisonOp.STRICT_EQUAL_WORD:
				return Red.RawLogic.from(value == 0);
			case Red.ComparisonOp.NOT_EQUAL:
				return Red.RawLogic.from(value != 0);
			case Red.ComparisonOp.LESSER:
				return Red.RawLogic.from(value < 0);
			case Red.ComparisonOp.LESSER_EQUAL:
				return Red.RawLogic.from(value <= 0);
			case Red.ComparisonOp.GREATER:
				return Red.RawLogic.from(value > 0);
			case Red.ComparisonOp.GREATER_EQUAL:
				return Red.RawLogic.from(value >= 0);
			default:
				throw new Error("error!");
		}
	}

	/* Actions */
	export function $$make(
		ctx:   Red.Context,
		proto: Red.AnyType,
		spec:  Red.AnyType
	): Red.AnyType {
		if(proto instanceof Red.RawDatatype) {
			return sendAction(Object.values(ACT)[Red.Types.indexOf(proto.repr)], "$$make", ctx, proto, spec);
		} else {
			return valueSendAction("$$make", ctx, proto, spec);
		}
	}

	// TODO: add docstrings and type annotations
	export const _MAKE = new Red.Action(
		"make",
		null,
		[
			new Red.RawArgument(new Red.RawWord("proto")),
			new Red.RawArgument(new Red.RawWord("spec")),
		],
		[],
		null,
		$$make
	);
	
	system$words.addWord("make", _MAKE);
	
	/*
	random: make action! [[
			"Returns a random value of the same datatype; or shuffles series"
			value	"Maximum value of result (modified when series)"
			/seed   "Restart or randomize"
			/secure "TBD: Returns a cryptographically secure random number"
			/only	"Pick a random value from a series"
			return:	[any-type!]
		]
		#get-definition ACT_RANDOM
	]

	reflect: make action! [[
			"Returns internal details about a value via reflection"
			value	[any-type!]
			field 	[word!] "spec, body, words, etc. Each datatype defines its own reflectors"
		]
		#get-definition ACT_REFLECT
	]
	*/

	export function $$to(
		ctx:   Red.Context,
		proto: Red.AnyType,
		spec:  Red.AnyType
	) {
		if(proto instanceof Red.RawDatatype) {
			return sendAction(Object.values(ACT)[Red.Types.indexOf(proto.repr)], "$$to", ctx, proto, spec);
		} else {
			return valueSendAction("$$to", ctx, proto, spec);
		}
	}

	export function $$form(
		ctx:   Red.Context,
		value: Red.AnyType,
		_: {
			part?: [Red.RawInteger]
		} = {}
	): Red.RawString {
		const str: string[] = [];
		const ml = valueSendAction("$$form", ctx, value, str, _.part && _.part[0].value);
		
		return Red.RawString.fromRedString(str.join(""), ml); // maybe change
	}

	export function $$mold(
		ctx:   Red.Context,
		value: Red.AnyType,
		_: {
			only?: [],
			all?:  [],
			flat?: [],
			part?: [Red.RawInteger]
		} = {}
	): Red.RawString {
		const str: string[] = [];
		const __: MoldOptions = {};

		if(_.only !== undefined) __.only = true;
		if(_.all !== undefined)  __.all = true;
		if(_.flat !== undefined) __.flat = true;
		if(_.part !== undefined) __.part = _.part[0].value;

		const ml = valueSendAction("$$mold", ctx, value, str, 1, __);
		
		return Red.RawString.fromJsString(str.join(""), ml); // maybe change
	}

	/*
	modify: make action! [[
			"Change mode for target aggregate value"
			target	 [object! series!]
			field 	 [word!]
			value 	 [any-type!]
			/case "Perform a case-sensitive lookup"
		]
		#get-definition ACT_MODIFY
	]

	;-- Scalar actions --
	*/
	
	export function $$absolute(
		ctx:   Red.Context,
		value: Red.RawNumber|Red.RawChar|Red.RawPair|Red.RawTime
	): typeof value {
		return valueSendAction("$$absolute", ctx, value);
	}

	export function $$add(
		ctx:    Red.Context,
		value1: Red.RawNumber|Red.RawChar|Red.RawPair|Red.RawVector|Red.RawTime|Red.RawTuple|Red.RawDate,
		value2: typeof value1
	): typeof value1 {
		return valueSendAction("$$add", ctx, value1, value2);
	}

	export function $$divide(
		ctx:    Red.Context,
		value1: Red.RawNumber|Red.RawChar|Red.RawPair|Red.RawVector|Red.RawTime|Red.RawTuple|Red.RawDate,
		value2: typeof value1
	): typeof value1 {
		return valueSendAction("$$divide", ctx, value1, value2);
	}

	export function $$multiply(
		ctx:    Red.Context,
		value1: Red.RawNumber|Red.RawChar|Red.RawPair|Red.RawVector|Red.RawTime|Red.RawTuple|Red.RawDate,
		value2: typeof value1
	): typeof value1 {
		return valueSendAction("$$multiply", ctx, value1, value2);
	}
	
	export function $$negate(
		ctx:    Red.Context,
		number: Red.RawNumber|Red.RawBitset|Red.RawPair|Red.RawTime
	): typeof number {
		return valueSendAction("$$negate", ctx, number);
	}
	
	export function $$power(
		ctx:      Red.Context,
		number:   Red.RawNumber,
		exponent: Red.RawInteger|Red.RawFloat
	): typeof number {
		return valueSendAction("$$power", ctx, number, exponent);
	}

	export function $$remainder(
		ctx:    Red.Context,
		value1: Red.RawNumber|Red.RawChar|Red.RawPair|Red.RawVector|Red.RawTime|Red.RawTuple,
		value2: typeof value1
	): typeof value1 {
		return valueSendAction("$$remainder", ctx, value1, value2);
	}

	/*round: make action! [[
			"Returns the nearest integer. Halves round up (away from zero) by default"
			n		[number! time! pair!]
			/to		"Return the nearest multiple of the scale parameter"
			scale	[number! time!] "Must be a non-zero value"
			/even		"Halves round toward even results"
			/down		"Round toward zero, ignoring discarded digits. (truncate)"
			/half-down	"Halves round toward zero"
			/floor		"Round in negative direction"
			/ceiling	"Round in positive direction"
			/half-ceiling "Halves round in positive direction"
		]
		#get-definition ACT_ROUND
	]
	*/
	
	export function $$subtract(
		ctx:    Red.Context,
		value1: Red.RawNumber|Red.RawChar|Red.RawPair|Red.RawVector|Red.RawTime|Red.RawTuple|Red.RawDate,
		value2: typeof value1
	): typeof value1 {
		return valueSendAction("$$subtract", ctx, value1, value2);
	}

	/*
	even?: make action! [[
			"Returns true if the number is evenly divisible by 2"
			number 	 [number! char! time!]
			return:  [number! char! time!]
		]
		#get-definition ACT_EVEN?
	]

	odd?: make action! [[
			"Returns true if the number has a remainder of 1 when divided by 2"
			number 	 [number! char! time!]
			return:  [number! char! time!]
		]
		#get-definition ACT_ODD?
	]
	*/

	/*
	;-- Bitwise actions --
	*/

	export function $$and_t(
		ctx:    Red.Context,
		value1: Red.RawLogic|Red.RawInteger|Red.RawChar|Red.RawBitset|Red.RawTypeset|Red.RawPair|Red.RawTuple|Red.RawVector,
		value2: typeof value1
	): typeof value1 {
		return valueSendAction("$$and_t", ctx, value1, value2);
	}

	export function $$complement(
		ctx:   Red.Context,
		value: Red.RawLogic|Red.RawInteger|Red.RawBitset|Red.RawTypeset|Red.RawBinary
	): typeof value {
		return valueSendAction("$$complement", ctx, value)
	}

	export function $$or_t(
		ctx:    Red.Context,
		value1: Red.RawLogic|Red.RawInteger|Red.RawChar|Red.RawBitset|Red.RawTypeset|Red.RawPair|Red.RawTuple|Red.RawVector,
		value2: typeof value1
	): typeof value1 {
		return valueSendAction("$$or_t", ctx, value1, value2);
	}

	export function $$xor_t(
		ctx:    Red.Context,
		value1: Red.RawLogic|Red.RawInteger|Red.RawChar|Red.RawBitset|Red.RawTypeset|Red.RawPair|Red.RawTuple|Red.RawVector,
		value2: typeof value1
	): typeof value1 {
		return valueSendAction("$$xor_t", ctx, value1, value2);
	}

	/*
	;-- Series actions --
	*/

	export function $$append(
		ctx:    Red.Context,
		series: Red.RawSeries|Red.RawBitset,
		value:  Red.AnyType,
		_: {
			part?: [Red.RawNumber|Red.RawSeries],
			only?: [],
			dup?:  [Red.RawInteger]
		} = {}
	): Red.RawSeries|Red.RawBitset {
		const __: AppendOptions = {};

		if(_.part !== undefined) {
			const [length] = _.part;
			
			if(Red.isNumber(length)) {
				__.part = Math.floor(length.value);
			} else if(!(series instanceof Red.RawBitset) && Red.sameSeries(series, length)) {
				__.part = length.index - series.index;
			} else {
				throw new Error("Error!");
			}
		}
		if(_.only !== undefined) __.only = true;
		if(_.dup !== undefined)  __.dup = _.dup[0].value;
		
		return valueSendAction("$$append", ctx, series, value, __);
	}

	export function $$at(
		ctx:    Red.Context,
		series: Red.RawSeries,
		index:  Red.RawInteger|Red.RawPair
	): Red.RawSeries {
		return valueSendAction("$$at", ctx, series, index instanceof Red.RawInteger ? index.value : index.x);
	}

	export function $$back(
		ctx:    Red.Context,
		series: Red.RawSeries
	): Red.RawSeries {
		return valueSendAction("$$back", ctx, series);
	}
	
	export function $$change(
		ctx:    Red.Context,
		series: Red.RawSeries,
		value:  Red.AnyType,
		_: {
			part?: [Red.RawNumber|Red.RawSeries],
			only?: [],
			dup?:  [Red.RawNumber]
		} = {}
	): typeof series {
		const __: ChangeOptions = {};
		
		if(_.part !== undefined) {
			const [length] = _.part;
			
			if(Red.isNumber(length)) {
				__.part = Math.floor(length.value);
			} else if(Red.sameSeries(series, length)) {
				__.part = length.index - series.index;
			} else {
				throw new Error("Error!");
			}
		}
		if(_.only !== undefined) __.only = true;
		if(_.dup !== undefined) __.dup = _.dup[0].value;
		
		return valueSendAction("$$change", ctx, series, value, __);
	}
	
	export function $$clear(
		ctx:    Red.Context,
		series: Red.RawSeries|Red.RawBitset|Red.RawMap|Red.RawNone
	): typeof series {
		return valueSendAction("$$clear", ctx, series);
	}

	/*
	copy: make action! [[
			"Returns a copy of a non-scalar value"
			value	 [series! any-object! bitset! map!]
			/part	 "Limit the length of the result"
				length [number! series! pair!]
			/deep	 "Copy nested values"
			/types	 "Copy only specific types of non-scalar values"
				kind [datatype!]
			return:  [series! any-object! bitset! map!]
		]
		#get-definition ACT_COPY
	]
	*/
	export function $$copy(
		ctx:   Red.Context,
		value: Red.RawSeries|Red.Context|Red.RawObject|Red.RawBitset|Red.RawMap,
		_: {
			part?:  [Red.RawNumber|Red.RawSeries|Red.RawPair],
			deep?:  [],
			types?: [Red.RawDatatype|Red.RawTypeset]
		} = {}
	): Red.RawSeries|Red.Context|Red.RawObject|Red.RawBitset|Red.RawMap {
		const __: CopyOptions = {};

		if(_.part !== undefined) {
			const [length] = _.part;
			
			if(Red.isNumber(length)) {
				__.part = Math.floor(length.value);
			} else if(length instanceof Red.RawPair) {
				Red.todo();
			} else if(Red.isSeries(value) && Red.sameSeries(value, length)) {
				__.part = length.index - value.index;
			} else {
				throw new Error("Error!");
			}
		}
		if(_.deep !== undefined)  __.deep = true;
		if(_.types !== undefined) __.types = _.types[0];
		
		return valueSendAction("$$copy", ctx, value, __);
	}

	/*
	find: make action! [[
			"Returns the series where a value is found, or NONE"
			series	 [series! bitset! typeset! any-object! map! none!]
			value 	 [any-type!]
			/part "Limit the length of the search"
				length [number! series!]
			/only "Treat a series search value as a single value"
			/case "Perform a case-sensitive search"
			/same {Use "same?" as comparator}
			/any  "TBD: Use * and ? wildcards in string searches"
			/with "TBD: Use custom wildcards in place of * and ?"
				wild [string!]
			/skip "Treat the series as fixed size records"
				size [integer!]
			/last "Find the last occurrence of value, from the tail"
			/reverse "Find the last occurrence of value, from the current index"
			/tail "Return the tail of the match found, rather than the head"
			/match "Match at current index only and return tail of match"
		]
		#get-definition ACT_FIND
	]
	*/

	export function $$head(
		ctx:    Red.Context,
		series: Red.RawSeries,
	): Red.RawSeries {
		return valueSendAction("$$head", ctx, series);
	}

	export function $$head_q(
		ctx:    Red.Context,
		series: Red.RawSeries,
	): Red.RawLogic {
		return valueSendAction("$$head_q", ctx, series);
	}

	export function $$index_q(
		ctx:    Red.Context,
		series: Red.RawSeries|Red.RawAnyWord,
	): Red.RawInteger {
		return valueSendAction("$$index_q", ctx, series);
	}

	/*
	insert: make action! [[
			"Inserts value(s) at series index; returns series past the insertion"
			series	   [series! port! bitset!]
			value	   [any-type!]
			/part "Limit the number of values inserted"
				length [number! series!]
			/only "Insert block types as single values (overrides /part)"
			/dup  "Duplicate the inserted values"
				count  [integer!]
			return:    [series! port! bitset!]
		]
		#get-definition ACT_INSERT
	]
	*/
	export function $$insert(
		ctx:    Red.Context,
		series: Red.RawSeries|Red.RawBitset,
		value:  Red.AnyType,
		_: {
			part?: [Red.RawNumber|Red.RawSeries],
			only?: [],
			dup?:  [Red.RawInteger]
		} = {}
	): typeof series {
		const __: InsertOptions = {};
		
		if(_.part !== undefined) {
			const [length] = _.part;
			
			if(Red.isNumber(length)) {
				__.part = Math.floor(length.value);
			} else if(!(series instanceof Red.RawBitset) && Red.sameSeries(series, length)) {
				__.part = length.index - series.index;
			} else {
				throw new Error("Error!");
			}
		}
		if(_.only !== undefined) __.only = true;
		if(_.dup !== undefined) __.dup = _.dup[0].value;
		
		return valueSendAction("$$insert", ctx, series, value, __);
	}

	export function $$length_q(
		ctx:    Red.Context,
		series: Red.RawSeries|Red.RawBitset|Red.RawTuple|Red.RawNone|Red.RawMap
	): Red.RawInteger|Red.RawNone {
		return valueSendAction("$$length_q", ctx, series);
	}

	/*
	move: make action! [[
			"Moves one or more elements from one series to another position or series"
			origin	   [series! port!]
			target	   [series! port!]
			/part "Limit the number of values inserted"
				length [integer!]
			return:    [series! port!]
		]
		#get-definition ACT_MOVE
	]
	*/

	export function $$next(
		ctx:    Red.Context,
		series: Red.RawSeries
	): Red.RawSeries {
		return valueSendAction("$$next", ctx, series);
	}

	// redo? idk what this is doing
	export function $$pick(
		ctx:    Red.Context,
		series: Red.RawSeries|Red.RawTuple|Red.RawPair|Red.RawTime|Red.RawBitset|Red.RawTuple|Red.RawDate,
		index:  Red.RawScalar|Red.RawAnyString|Red.RawAnyWord|Red.RawBlock|Red.RawLogic|Red.RawTime
	): Red.AnyType {
		if(index instanceof Red.RawInteger && !(series instanceof Red.RawTuple || series instanceof Red.RawPair || series instanceof Red.RawTime)) {
			return valueSendAction("$$pick", ctx, series, index);
		} else {
			Red.todo();
		}
	}

	/*
	poke: make action! [[
			"Replaces the series value at a given index, and returns the new value"
			series	 [series! port! bitset!]
			index 	 [scalar! any-string! any-word! block! logic!]
			value 	 [any-type!]
			return:  [series! port! bitset!]
		]
		#get-definition ACT_POKE
	]
	*/
	// probably redo this too
	export function $$poke(
		ctx:    Red.Context,
		series: Red.RawSeries|Red.RawBitset,
		index:  Red.RawScalar|Red.RawAnyString|Red.RawAnyWord|Red.RawBlock|Red.RawLogic,
		value:  Red.AnyType
	): typeof series {
		if(index instanceof Red.RawInteger && !(series instanceof Red.RawTuple || series instanceof Red.RawPair || series instanceof Red.RawTime)) {
			return valueSendAction("$$poke", ctx, series, index, value);
		} else {
			Red.todo();
		}
	}

	/*
	put: make action! [[
			"Replaces the value following a key, and returns the new value"
			series	 [series! port! map! object!]
			key 	 [scalar! any-string! any-word! binary!]
			value 	 [any-type!]
			/case "Perform a case-sensitive search"
			return:  [series! port! map! object!]
		]
		#get-definition ACT_PUT
	]*/
	
	export function $$remove(
		ctx:    Red.Context,
		series: Red.RawSeries|Red.RawBitset|Red.RawMap|Red.RawNone,
		_: {
			part?: [Red.RawNumber|Red.RawChar|Red.RawSeries],
			key?:  [Red.RawScalar|Red.RawAnyString|Red.RawAnyWord|Red.RawBinary|Red.RawBlock]
		} = {}
	): typeof series {
		return valueSendAction("$$remove", ctx, series, {
			part: _.part === undefined ? undefined : _.part[0],
			key:  _.key === undefined ? undefined : _.key[0]
		});
	}

	/*
	reverse: make action! [[
			"Reverses the order of elements; returns at same position"
			series	 [series! port! pair! tuple!]
			/part "Limits to a given length or position"
				length [number! series!]
			return:  [series! port! pair! tuple!]
		]
		#get-definition ACT_REVERSE
	]

	select: make action! [[
			"Find a value in a series and return the next value, or NONE"
			series	 [series! any-object! map! none!]
			value 	 [any-type!]
			/part "Limit the length of the search"
				length [number! series!]
			/only "Treat a series search value as a single value"
			/case "Perform a case-sensitive search"
			/same {Use "same?" as comparator}
			/any  "TBD: Use * and ? wildcards in string searches"
			/with "TBD: Use custom wildcards in place of * and ?"
				wild [string!]
			/skip "Treat the series as fixed size records"
				size [integer!]
			/last "Find the last occurrence of value, from the tail"
			/reverse "Find the last occurrence of value, from the current index"
			return:  [any-type!]
		]
		#get-definition ACT_SELECT
	]

	sort: make action! [[
			"Sorts a series (modified); default sort order is ascending"
			series	 [series! port!]
			/case "Perform a case-sensitive sort"
			/skip "Treat the series as fixed size records"
				size [integer!]
			/compare "Comparator offset, block (TBD) or function"
				comparator [integer! block! any-function!]
			/part "Sort only part of a series"
				length [number! series!]
			/all "Compare all fields"
			/reverse "Reverse sort order"
			/stable "Stable sorting"
			return:  [series!]
		]
		#get-definition ACT_SORT
	]
	*/
	
	export function $$skip(
		ctx:    Red.Context,
		series: Red.RawSeries,
		offset: Red.RawInteger|Red.RawPair
	): Red.RawSeries {
		return valueSendAction("$$skip", ctx, series, offset instanceof Red.RawInteger ? offset.value : offset.x);
	}

	/*
	swap: make action! [[
			"Swaps elements between two series or the same series"
			series1  [series! port!]
			series2  [series! port!]
			return:  [series! port!]
		]
		#get-definition ACT_SWAP
	]
	*/

	export function $$tail(
		ctx:    Red.Context,
		series: Red.RawSeries,
	): Red.RawSeries {
		return valueSendAction("$$tail", ctx, series);
	}

	export function $$tail_q(
		ctx:    Red.Context,
		series: Red.RawSeries,
	): Red.RawLogic {
		return valueSendAction("$$tail_q", ctx, series);
	}

	/*
	take: make action! [[
			"Removes and returns one or more elements"
			series	 [series! port! none!]
			/part	 "Specifies a length or end position"
				length [number! series!]
			/deep	 "Copy nested values"
			/last	 "Take it from the tail end"
		]
		#get-definition ACT_TAKE
	]

	trim: make action! [[
			"Removes space from a string or NONE from a block"
			series	[series! port!]
			/head	"Removes only from the head"
			/tail	"Removes only from the tail"
			/auto	"Auto indents lines relative to first line"
			/lines	"Removes all line breaks and extra spaces"
			/all	"Removes all whitespace"
			/with	"Same as /all, but removes characters in 'str'"
				str [char! string! binary! integer!]
		]
		#get-definition ACT_TRIM
	]

	;-- I/O actions --

	create: make action! [[
			"Send port a create request"
			port [port! file! url! block!]
		]
		#get-definition ACT_CREATE
	]

	close: make action! [[
			"Closes a port"
			port [port!]
		]
		#get-definition ACT_CLOSE
	]

	delete: make action! [[
			"Deletes the specified file or empty folder"
			file [file! port!]
		]
		#get-definition ACT_DELETE
	]

	open: make action! [[
			"Opens a port; makes a new port from a specification if necessary"
			port [port! file! url! block!]
			/new "Create new file - if it exists, deletes it"
			/read "Open for read access"
			/write "Open for write access"
			/seek "Optimize for random access"
			/allow "Specificies right access attributes"
				access [block!]
		]
		#get-definition ACT_OPEN
	]

	open?: make action! [[
			"Returns TRUE if port is open"
			port [port!]
		]
		#get-definition ACT_OPEN?
	]

	query: make action! [[
			"Returns information about a file"
			target [file! port!]
		]
		#get-definition ACT_QUERY
	]

	read: make action! [[
			"Reads from a file, URL, or other port"
			source	[file! url! port!]
			/part	"Partial read a given number of units (source relative)"
				length [number!]
			/seek	"Read from a specific position (source relative)"
				index [number!]
			/binary	"Preserves contents exactly"
			/lines	"Convert to block of strings"
			/info
			/as		"Read with the specified encoding, default is 'UTF-8"
				encoding [word!]
		]
		#get-definition ACT_READ
	]

	rename: make action! [[
			"Rename a file"
			from [port! file! url!]
			to   [port! file! url!]
		]
		#get-definition ACT_RENAME
	]

	update: make action! [[
			"Updates external and internal states (normally after read/write)"
			port [port!]
		]
		#get-definition ACT_UPDATE
	]

	write: make action! [[
			"Writes to a file, URL, or other port"
			destination	[file! url! port!]
			data		[any-type!]
			/binary	"Preserves contents exactly"
			/lines	"Write each value in a block as a separate line"
			/info
			/append "Write data at end of file"
			/part	"Partial write a given number of units"
				length	[number!]
			/seek	"Write at a specific position"
				index	[number!]
			/allow	"Specifies protection attributes"
				access	[block!]
			/as		"Write with the specified encoding, default is 'UTF-8"
				encoding [word!]
		]
		#get-definition ACT_WRITE
	]
	*/
}

export default RedActions
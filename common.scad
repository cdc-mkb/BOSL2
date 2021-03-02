//////////////////////////////////////////////////////////////////////
// LibFile: common.scad
//   Common functions used in argument processing.
// Includes:
//   include <BOSL2/std.scad>
//////////////////////////////////////////////////////////////////////


// Section: Type handling helpers.


// Function: typeof()
// Usage:
//   typ = typeof(x);
// Topics: Type Checking
// See Also: is_type()
// Description:
//   Returns a string representing the type of the value.  One of "undef", "boolean", "number", "nan", "string", "list", "range", "function" or "invalid".
//   Some malformed "ranges", like '[0:NAN:INF]' and '[0:"a":INF]', may be classified as "undef" or "invalid".
// Examples:
//   typ = typeof(undef);  // Returns: "undef"
//   typ = typeof(true);  // Returns: "boolean"
//   typ = typeof(42);  // Returns: "number"
//   typ = typeof(NAN);  // Returns: "nan"
//   typ = typeof("foo");  // Returns: "string"
//   typ = typeof([3,4,5]);  // Returns: "list"
//   typ = typeof([3:1:8]);  // Returns: "range"
//   typ = typeof(function (x,y) x+y);  // Returns: "function"
function typeof(x) =
    is_undef(x)? "undef" :
    is_bool(x)? "boolean" :
    is_num(x)? "number" :
    is_nan(x)? "nan" :
    is_string(x)? "string" :
    is_list(x)? "list" :
    is_range(x) ? "range" :
    version_num()>20210000 && is_function(x) ? "function" :
    "invalid";



// Function: is_type()
// Usage:
//   bool = is_type(x, types);
// Topics: Type Checking
// See Also: typeof()
// Description:
//   Returns true if the type of the value `x` is one of those given as strings in the list `types`. 
//   Valid types are "undef", "boolean", "number", "nan", "string", "list", "range", or "function".
// Arguments:
//   x = The value to check the type of.
//   types = A list of types to check 
// Example:
//   is_str_or_list = is_type("foo", ["string","list"]);   // Returns: true
//   is_str_or_list2 = is_type([1,2,3], ["string","list"]);  // Returns: true
//   is_str_or_list3 = is_type(2, ["string","list"]);  // Returns: false
//   is_str = is_type("foo", "string");  // Returns: true
//   is_str2 = is_type([3,4], "string");  // Returns: false
//   is_str3 = is_type(["foo"], "string");  // Returns: false
//   is_str4 = is_type(3, "string");  // Returns: false
function is_type(x,types) =
    is_list(types)? in_list(typeof(x),types) :
    is_string(types)? typeof(x) == types :
    assert(is_list(types)||is_string(types));


// Function: is_def()
// Usage:
//   bool = is_def(x);
// Topics: Type Checking
// See Also: typeof(), is_type(), is_str()
// Description:
//   Returns true if `x` is not `undef`.  False if `x==undef`.
// Example:
//   bool = is_def(undef);  // Returns: false
//   bool = is_def(false);  // Returns: true
//   bool = is_def(42);     // Returns: true
//   bool = is_def("foo");  // Returns: true
function is_def(x) = !is_undef(x);


// Function: is_str()
// Usage:
//   bool = is_str(x);
// Topics: Type Checking
// See Also: typeof(), is_type(), is_int(), is_def()
// Description:
//   Returns true if `x` is a string.  A shortcut for `is_string()`.
// Example:
//   bool = is_str(undef);  // Returns: false
//   bool = is_str(false);  // Returns: false
//   bool = is_str(42);     // Returns: false
//   bool = is_str("foo");  // Returns: true
function is_str(x) = is_string(x);


// Function: is_int()
// Alias: is_integer()
// Usage:
//   bool = is_int(n);
//   bool = is_integer(n);
// Topics: Type Checking
// See Also: typeof(), is_type(), is_str(), is_def()
// Description:
//   Returns true if the given value is an integer (it is a number and it rounds to itself).  
// Example:
//   bool = is_int(undef);  // Returns: false
//   bool = is_int(false);  // Returns: false
//   bool = is_int(42);     // Returns: true
//   bool = is_int("foo");  // Returns: false
function is_int(n) = is_finite(n) && n == round(n);
function is_integer(n) = is_finite(n) && n == round(n);


// Function: is_nan()
// Usage:
//   bool = is_nan(x);
// Topics: Type Checking
// See Also: typeof(), is_type(), is_str(), is_def(), is_int()
// Description:
//   Returns true if a given value `x` is nan, a floating point value representing "not a number".
// Example:
//   bool = is_nan(undef);  // Returns: false
//   bool = is_nan(false);  // Returns: false
//   bool = is_nan(42);     // Returns: false
//   bool = is_nan("foo");  // Returns: false
//   bool = is_nan(NAN);    // Returns: true
function is_nan(x) = (x!=x);


// Function: is_finite()
// Usage:
//   bool = is_finite(x);
// Topics: Type Checking
// See Also: typeof(), is_type(), is_str(), is_def(), is_int(), is_nan()
// Description:
//   Returns true if a given value `x` is a finite number.
// Example:
//   bool = is_finite(undef);  // Returns: false
//   bool = is_finite(false);  // Returns: false
//   bool = is_finite(42);     // Returns: true
//   bool = is_finite("foo");  // Returns: false
//   bool = is_finite(NAN);    // Returns: false
//   bool = is_finite(INF);    // Returns: false
//   bool = is_finite(-INF);   // Returns: false
function is_finite(x) = is_num(x) && !is_nan(0*x);


// Function: is_range()
// Usage:
//   bool = is_range(x);
// Topics: Type Checking
// See Also: typeof(), is_type(), is_str(), is_def(), is_int()
// Description:
//   Returns true if its argument is a range
// Example:
//   bool = is_range(undef);   // Returns: false
//   bool = is_range(false);   // Returns: false
//   bool = is_range(42);      // Returns: false
//   bool = is_range([3,4,5]); // Returns: false
//   bool = is_range("foo");   // Returns: false
//   bool = is_range([3:5]);   // Returns: true
function is_range(x) = !is_list(x) && is_finite(x[0]) && is_finite(x[1]) && is_finite(x[2]) ;


// Function: valid_range()
// Usage:
//   bool = valid_range(x);
// Topics: Type Checking
// See Also: typeof(), is_type(), is_str(), is_def(), is_int(), is_range()
// Description:
//   Returns true if its argument is a valid range (deprecated ranges excluded).
// Example:
//   bool = is_range(undef);   // Returns: false
//   bool = is_range(false);   // Returns: false
//   bool = is_range(42);      // Returns: false
//   bool = is_range([3,4,5]); // Returns: false
//   bool = is_range("foo");   // Returns: false
//   bool = is_range([3:5]);   // Returns: true
//   bool = is_range([3:1]);   // Returns: false
function valid_range(x) = 
    is_range(x) 
    && ( x[1]>0 
         ? x[0]<=x[2]
         : ( x[1]<0 && x[0]>=x[2] ) );


// Function: is_list_of()
// Usage:
//   bool = is_list_of(list, pattern);
// Topics: Type Checking
// See Also: typeof(), is_type(), is_str(), is_def(), is_int(), is_range()
// Description:
//   Tests whether the input is a list whose entries are all numeric lists that have the same
//   list shape as the pattern.
// Example:
//   is_list_of([3,4,5], 0);            // Returns true
//   is_list_of([3,4,undef], 0);        // Returns false
//   is_list_of([[3,4],[4,5]], [1,1]);  // Returns true
//   is_list_of([[3,"a"],[4,true]], [1,undef]);  // Returns true
//   is_list_of([[3,4], 6, [4,5]], [1,1]);  // Returns false
//   is_list_of([[1,[3,4]], [4,[5,6]]], [1,[2,3]]);    // Returns true
//   is_list_of([[1,[3,INF]], [4,[5,6]]], [1,[2,3]]);  // Returns false
//   is_list_of([], [1,[2,3]]);                        // Returns true
function is_list_of(list,pattern) =
    let(pattern = 0*pattern)
    is_list(list) &&
    []==[for(entry=0*list) if (entry != pattern) entry];


// Function: is_consistent()
// Usage:
//   bool = is_consistent(list);
// Topics: Type Checking
// See Also: typeof(), is_type(), is_str(), is_def(), is_int(), is_range(), is_homogeneous()
// Description:
//   Tests whether input is a list of entries which all have the same list structure
//   and are filled with finite numerical data. It returns `true`for the empty list. 
// Example:
//   is_consistent([3,4,5]);              // Returns true
//   is_consistent([[3,4],[4,5],[6,7]]);  // Returns true
//   is_consistent([[3,4,5],[3,4]]);      // Returns false
//   is_consistent([[3,[3,4,[5]]], [5,[2,9,[9]]]]); // Returns true
//   is_consistent([[3,[3,4,[5]]], [5,[2,9,9]]]);   // Returns false
function is_consistent(list) =
  /*is_list(list) &&*/ is_list_of(list, _list_pattern(list[0]));


//Internal function
//Creates a list with the same structure of `list` with each of its elements substituted by 0.
function _list_pattern(list) =
  is_list(list) 
  ? [for(entry=list) is_list(entry) ? _list_pattern(entry) : 0]
  : 0;


// Function: same_shape()
// Usage:
//   bool = same_shape(a,b);
// Topics: Type Checking
// See Also: is_homogeneous(), is_consistent()
// Description:
//   Tests whether the inputs `a` and `b` are both numeric and are the same shaped list.
// Example:
//   same_shape([3,[4,5]],[7,[3,4]]);   // Returns true
//   same_shape([3,4,5], [7,[3,4]]);    // Returns false
function same_shape(a,b) = _list_pattern(a) == b*0;


// Function: is_bool_list()
// Usage:
//   check = is_bool_list(list,<length>)
// Topics: Type Checking
// See Also: is_homogeneous(), is_consistent()
// Description:
//   Tests whether input is a list containing only booleans, and optionally checks its length.
// Arguments:
//   list = list to test
//   length = if given, list must be this length
function is_bool_list(list, length) =
     is_list(list) && (is_undef(length) || len(list)==length) && []==[for(entry=list) if (!is_bool(entry)) 1];


// Section: Handling `undef`s.


// Function: default()
// Usage:
//   val = default(val, dflt);
// Topics: Undef Handling
// See Also: first_defined(), one_defined(), num_defined()
// Description:
//   Returns the value given as `v` if it is not `undef`.  Otherwise, returns the value of `dflt`.
// Arguments:
//   v = Value to pass through if not `undef`.
//   dflt = Value to return if `v` *is* `undef`.
function default(v,dflt=undef) = is_undef(v)? dflt : v;


// Function: first_defined()
// Usage:
//   val = first_defined(v, <recursive>);
// Topics: Undef Handling
// See Also: default(), one_defined(), num_defined(), any_defined(), all_defined()
// Description:
//   Returns the first item in the list that is not `undef`.
//   If all items are `undef`, or list is empty, returns `undef`.
// Arguments:
//   v = The list whose items are being checked.
//   recursive = If true, sublists are checked recursively for defined values.  The first sublist that has a defined item is returned.
function first_defined(v,recursive=false,_i=0) =
    _i<len(v) && (
        is_undef(v[_i]) || (
            recursive &&
            is_list(v[_i]) &&
            is_undef(first_defined(v[_i],recursive=recursive))
        )
    )? first_defined(v,recursive=recursive,_i=_i+1) : v[_i];
    

// Function: one_defined()
// Usage:
//   val = one_defined(vals, names, <dflt>)
// Topics: Undef Handling
// See Also: default(), first_defined(), num_defined(), any_defined(), all_defined()
// Description:
//   Examines the input list `vals` and returns the entry which is not `undef`.
//   If more than one entry is not `undef` then an error is asserted, specifying
//   "Must define exactly one of" followed by the names in the `names` parameter.
//   If `dflt` is given, and all `vals` are `undef`, then the value in `dflt` is returned.
//   If `dflt` is *not* given, and all `vals` are `undef`, then an error is asserted.
// Arguments:
//   vals = The values to return the first one which is not `undef`.
//   names = A string with comma-separated names for the arguments whose values are passed in `vals`.
//   dflt = If given, the value returned if all `vals` are `undef`.
// Examples:
//   length = one_defined([length,L,l], ["length","L","l"]);
//   length = one_defined([length,L,l], "length,L,l", dflt=1);
function one_defined(vals, names, dflt=_UNDEF) =
    let(
        checkargs = is_list(names)? assert(len(vals) == len(names)) :
            is_string(names)? let(
                name_cnt = len([for (c=names) if (c==",") 1]) + 1
            ) assert(len(vals) == name_cnt) :
            assert(is_list(names) || is_string(names)) 0,
        ok = num_defined(vals)==1 || (dflt!=_UNDEF && num_defined(vals)==0)
    ) ok? default(first_defined(vals), dflt) :
    let(
        names = is_string(names) ? str_split(names,",") : names,
        defd = [for (i=idx(vals)) if (is_def(vals[i])) names[i]],
        msg = str(
            "Must define ",
            dflt==_UNDEF? "exactly" : "at most",
            " one of ",
            num_defined(vals) == 0 ? names : defd
        )
    ) assert(ok,msg);


// Function: num_defined()
// Usage:
//   cnt = num_defined(v);
// Topics: Undef Handling
// See Also: default(), first_defined(), one_defined(), any_defined(), all_defined()
// Description:
//   Counts how many items in list `v` are not `undef`.
// Example:
//   cnt = num_defined([3,7,undef,2,undef,undef,1]);  // Returns: 4
function num_defined(v) =
    len([for(vi=v) if(!is_undef(vi)) 1]);


// Function: any_defined()
// Usage:
//   bool = any_defined(v, <recursive>);
// Topics: Undef Handling
// See Also: default(), first_defined(), one_defined(), num_defined(), all_defined()
// Description:
//   Returns true if any item in the given array is not `undef`.
// Arguments:
//   v = The list whose items are being checked.
//   recursive = If true, any sublists are evaluated recursively.
// Example:
//   bool = any_defined([undef,undef,undef]);    // Returns: false
//   bool = any_defined([undef,42,undef]);       // Returns: true
//   bool = any_defined([34,42,87]);             // Returns: true
//   bool = any_defined([undef,undef,[undef]]);  // Returns: true
//   bool = any_defined([undef,undef,[undef]],recursive=true);  // Returns: false
//   bool = any_defined([undef,undef,[42]],recursive=true);     // Returns: true
function any_defined(v,recursive=false) =
    first_defined(v,recursive=recursive) != undef;


// Function: all_defined()
// Usage:
//   bool = all_defined(v, <recursive>);
// Description:
//   Returns true if all items in the given array are not `undef`.
// Arguments:
//   v = The list whose items are being checked.
//   recursive = If true, any sublists are evaluated recursively.
// Example:
//   bool = all_defined([undef,undef,undef]);    // Returns: false
//   bool = all_defined([undef,42,undef]);       // Returns: false
//   bool = all_defined([34,42,87]);             // Returns: true
//   bool = all_defined([23,34,[undef]]);        // Returns: true
//   bool = all_defined([23,34,[undef]],recursive=true);  // Returns: false
//   bool = all_defined([23,34,[42]],recursive=true);     // Returns: true
function all_defined(v,recursive=false) = 
    []==[for (x=v) if(is_undef(x)||(recursive && is_list(x) && !all_defined(x,recursive))) 0 ];



// Section: Argument Helpers


// Function: get_anchor()
// Usage:
//   anchr = get_anchor(anchor,center,<uncentered>,<dflt>);
// Topics: Argument Handling
// See Also: get_radius(), get_named_args()
// Description:
//   Calculated the correct anchor from `anchor` and `center`.  In order:
//   - If `center` is not `undef` and `center` evaluates as true, then `CENTER` (`[0,0,0]`) is returned.
//   - Otherwise, if `center` is not `undef` and `center` evaluates as false, then the value of `uncentered` is returned.
//   - Otherwise, if `anchor` is not `undef`, then the value of `anchor` is returned.
//   - Otherwise, the value of `dflt` is returned.
//   This ordering ensures that `center` will override `anchor`.
// Arguments:
//   anchor = The anchor name or vector.
//   center = If not `undef`, this overrides the value of `anchor`.
//   uncentered = The value to return if `center` is not `undef` and evaluates as false.  Default: ALLNEG
//   dflt = The default value to return if both `anchor` and `center` are `undef`.  Default: `CENTER`
// Examples:
//   anchr = get_anchor(undef, undef, BOTTOM, TOP);  // Returns: [0, 0, 1] (TOP)
//   anchr = get_anchor(RIGHT, undef, BOTTOM, TOP);  // Returns: [1, 0, 0] (RIGHT)
//   anchr = get_anchor(undef, false, BOTTOM, TOP);  // Returns: [0, 0,-1] (BOTTOM)
//   anchr = get_anchor(RIGHT, false, BOTTOM, TOP);  // Returns: [0, 0,-1] (BOTTOM)
//   anchr = get_anchor(undef, true,  BOTTOM, TOP);  // Returns: [0, 0, 0] (CENTER)
//   anchr = get_anchor(RIGHT, true,  BOTTOM, TOP);  // Returns: [0, 0, 0] (CENTER)
function get_anchor(anchor,center,uncentered=BOT,dflt=CENTER) =
    !is_undef(center)? (center? CENTER : uncentered) :
    !is_undef(anchor)? anchor :
    dflt;


// Function: get_radius()
// Usage:
//   r = get_radius(<r1=>, <r2=>, <r=>, <d1=>, <d2=>, <d=>, <dflt=>);
// Topics: Argument Handling
// See Also: get_anchor(), get_named_args()
// Description:
//   Given various radii and diameters, returns the most specific radius.  If a diameter is most
//   specific, returns half its value, giving the radius.  If no radii or diameters are defined,
//   returns the value of `dflt`.  Value specificity order is `r1`, `r2`, `d1`, `d2`, `r`, `d`,
//   then `dflt`.  Only one of `r1`, `r2`, `d1`, or `d2` can be defined at once, or else it errors
//   out, complaining about conflicting radius/diameter values.  Only one of `r` or `d` can be
//   defined at once, or else it errors out, complaining about conflicting radius/diameter values.
// Arguments:
//   ---
//   r1 = Most specific radius.
//   r2 = Second most specific radius.
//   r = Most general radius.
//   d1 = Most specific diameter.
//   d2 = Second most specific diameter.
//   d = Most general diameter.
//   dflt = Value to return if all other values given are `undef`.
// Examples:
//   r = get_radius(r1=undef, r=undef, dflt=undef);  // Returns: undef
//   r = get_radius(r1=undef, r=undef, dflt=1);      // Returns: 1
//   r = get_radius(r1=undef, r=6, dflt=1);          // Returns: 6
//   r = get_radius(r1=7, r=6, dflt=1);              // Returns: 7
//   r = get_radius(r1=undef, r2=8, r=6, dflt=1);    // Returns: 8
//   r = get_radius(r1=undef, r2=8, d=6, dflt=1);    // Returns: 8
//   r = get_radius(r1=undef, d=6, dflt=1);          // Returns: 3
//   r = get_radius(d1=7, d=6, dflt=1);              // Returns: 3.5
//   r = get_radius(d1=7, d2=8, d=6, dflt=1);        // Returns: 3.5
//   r = get_radius(d1=undef, d2=8, d=6, dflt=1);    // Returns: 4
//   r = get_radius(r1=8, d=6, dflt=1);              // Returns: 8
function get_radius(r1, r2, r, d1, d2, d, dflt) = 
    assert(num_defined([r1,d1,r2,d2])<2, "Conflicting or redundant radius/diameter arguments given.")
    !is_undef(r1) ?   assert(is_finite(r1), "Invalid radius r1." ) r1 
    : !is_undef(r2) ? assert(is_finite(r2), "Invalid radius r2." ) r2
    : !is_undef(d1) ? assert(is_finite(d1), "Invalid diameter d1." ) d1/2
    : !is_undef(d2) ? assert(is_finite(d2), "Invalid diameter d2." ) d2/2
    : !is_undef(r)
      ? assert(is_undef(d), "Conflicting or redundant radius/diameter arguments given.")
        assert(is_finite(r) || is_vector(r,1) || is_vector(r,2), "Invalid radius r." )
        r 
    : !is_undef(d) ? assert(is_finite(d) || is_vector(d,1) || is_vector(d,2), "Invalid diameter d." ) d/2
    : dflt;


// Function: get_named_args()
// Usage:
//   function f(pos1=_UNDEF, pos2=_UNDEF,...,named1=_UNDEF, named2=_UNDEF, ...) = let(args = get_named_args([pos1, pos2, ...], [[named1, default1], [named2, default2], ...]), named1=args[0], named2=args[1], ...)
// Topics: Argument Handling
// See Also: get_anchor(), get_radius()
// Description:
//   Given the values of some positional and named arguments, returns a list of the values assigned to
//   named parameters.  in the following steps:
//   - First, all named parameters which were explicitly assigned in the function call take their
//     provided value.
//   - Then, any positional arguments are assigned to remaining unassigned
//     parameters; this is governed both by the `priority` entries (if there are `N` positional
//     arguments, then the `N` parameters with lowest `priority` value will be assigned) and by the
//     order of the positional arguments (matching that of the assigned named parameters).  If no
//     priority is given, then these two ordering coincide: parameters are assigned in order, starting
//     from the first one.
//   - Finally, any remaining named parameters can take default values.  If no default values are
//     given, then `undef` is used.
//   .
//   This allows an author to declare a function prototype with named or optional parameters, so that
//   the user may then call this function using either positional or named parameters. In practice the
//   author will declare the function as using *both* positional and named parameters, and let
//   `get_named_args()` do the parsing from the whole set of arguments.  See the example below.
//   .
//   This supports the user explicitly passing `undef` as a function argument.  To distinguish between
//   an intentional `undef` and the absence of an argument, we use a custom `_UNDEF` value as a guard
//   marking the absence of any arguments (in practice, `_UNDEF` is a random-generated string, which
//   will never coincide with any useful user value).  This forces the author to declare all the
//   function parameters as having `_UNDEF` as their default value.
// Arguments:
//   positional = The list of values of positional arguments.
//   named = The list of named arguments; each entry of the list has the form `[passed-value, <default-value>, <priority>]`, where `passed-value` is the value that was passed at function call; `default-value` is the value that will be used if nothing is read from either named or positional arguments; `priority` is the priority assigned to this argument (lower means more priority, default value is `+inf`). Since stable sorting is used, if no priority at all is given, all arguments will be read in order.
//   _undef = The default value used by the calling function for all arguments. The default value, `_UNDEF`, is a random string. This value **must** be the default value of all parameters in the outer function call (see example below).
//
// Example: a function with prototype `f(named1,< <named2>, named3 >)`
//   function f(_p1=_UNDEF, _p2=_UNDEF, _p3=_UNDEF,
//              arg1=_UNDEF, arg2=_UNDEF, arg3=_UNDEF) =
//      let(named = get_named_args([_p1, _p2, _p3],
//          [[arg1, "default1",0], [arg2, "default2",2], [arg3, "default3",1]]))
//      named;
//   // all default values or all parameters provided:
//   echo(f());
//   // ["default1", "default2", "default3"]
//   echo(f("given2", "given3", arg1="given1"));
//   // ["given1", "given2", "given3"]
//   
//   // arg1 has highest priority, and arg3 is higher than arg2:
//   echo(f("given1"));
//   // ["given1", "default2", "default3"]
//   echo(f("given3", arg1="given1"));
//   // ["given1", "default2", "given3"]
//   
//   // explicitly passing undef is allowed:
//   echo(f(undef, arg1="given1", undef));
//   // ["given1", undef, undef]

// a value that the user should never enter randomly;
// result of `dd if=/dev/random bs=32 count=1 |base64` :
_UNDEF="LRG+HX7dy89RyHvDlAKvb9Y04OTuaikpx205CTh8BSI";

/* Note: however tempting it might be, it is *not* possible to accept
 * named argument as a list [named1, named2, ...] (without default
 * values), because the values [named1, named2...] themselves might be
 * lists, and we will not be able to distinguish the two cases. */
function get_named_args(positional, named, _undef=_UNDEF) =
    let(deft = [for(p=named) p[1]], // default is undef
        // indices of the values to fetch from positional args:
        unknown = [for(x=enumerate(named)) if(x[1][0]==_undef) x[0]],
        // number of values given to positional arguments:
        n_positional = count_true([for(p=positional) p!=_undef]))
    assert(n_positional <= len(unknown),
      str("too many positional arguments (", n_positional, " given, ",
          len(unknown), " required)"))
    let(
        // those elements which have no priority assigned go last (prio=+∞):
        prio = sortidx([for(u=unknown) default(named[u][2], 1/0)]),
        // list of indices of values assigned from positional arguments:
        assigned = [for(a=sort([for(i=[0:1:n_positional-1]) prio[i]]))
          unknown[a]])
    [ for(e = enumerate(named))
      let(idx=e[0], val=e[1][0], ass=search(idx, assigned))
        val != _undef ? val :
        ass != [] ? positional[ass[0]] :
        deft[idx] ];


// Function: scalar_vec3()
// Usage:
//   vec = scalar_vec3(v, <dflt>);
// Topics: Argument Handling
// See Also: get_anchor(), get_radius(), force_list()
// Description:
//   If `v` is a scalar, and `dflt==undef`, returns `[v, v, v]`.
//   If `v` is a scalar, and `dflt!=undef`, returns `[v, dflt, dflt]`.
//   If `v` is a vector, returns the first 3 items, with any missing values replaced by `dflt`.
//   If `v` is `undef`, returns `undef`.
// Arguments:
//   v = Value to return vector from.
//   dflt = Default value to set empty vector parts from.
// Examples:
//   vec = scalar_vec3(undef);      // Returns: undef
//   vec = scalar_vec3(10);         // Returns: [10,10,10]
//   vec = scalar_vec3(10,1);       // Returns: [10,1,1]
//   vec = scalar_vec3([10,10],1);  // Returns: [10,10,1]
function scalar_vec3(v, dflt) =
    is_undef(v)? undef :
    is_list(v)? [for (i=[0:2]) default(v[i], default(dflt, 0))] :
    !is_undef(dflt)? [v,dflt,dflt] : [v,v,v];


// Function: segs()
// Usage:
//   sides = segs(r);
// Topics: Geometry
// Description:
//   Calculate the standard number of sides OpenSCAD would give a circle based on `$fn`, `$fa`, and `$fs`.
// Arguments:
//   r = Radius of circle to get the number of segments for.
// Examples:
//   $fn=12; sides=segs(10);  // Returns: 12
//   $fa=2; $fs=3, sides=segs(10);  // Returns: 21
function segs(r) = 
    $fn>0? ($fn>3? $fn : 3) :
    let( r = is_finite(r)? r : 0 )
    ceil(max(5, min(360/$fa, abs(r)*2*PI/$fs)));


// Module: no_children()
// Topics: Error Checking
// See Also: no_function(), no_module()
// Usage:
//   no_children($children);
// Description:
//   Assert that the calling module does not support children.  Prints an error message to this effect and fails if children are present,
//   as indicated by its argument.
// Arguments:
//   $children = number of children the module has.  
// Example:
//   module foo() {
//       no_children($children);
//   }
module no_children(count) {
  assert($children==0, "Module no_children() does not support child modules");
  if ($parent_modules>0) {
      assert(count==0, str("Module ",parent_module(1),"() does not support child modules"));
  }
}


// Function: no_function()
// Usage:
//   dummy = no_function(name)
// Topics: Error Checking
// See Also: no_children(), no_module()
// Description:
//   Asserts that the function, "name", only exists as a module.
// Example:
//   x = no_function("foo");
function no_function(name) =
   assert(false,str("You called ",name,"() as a function, but it is available only as a module"));


// Module: no_module()
// Usage:
//   no_module();
// Topics: Error Checking
// See Also: no_children(), no_function()
// Description:
//   Asserts that the called module exists only as a function.
// Example:
//   function foo() = no_module();
module no_module() {
    assert(false, str("You called ",parent_module(1),"() as a module but it is available only as a function"));
}    
  

// Section: Testing Helpers


function _valstr(x) =
    is_list(x)? str("[",str_join([for (xx=x) _valstr(xx)],","),"]") :
    is_finite(x)? fmt_float(x,12) : x;


// Module: assert_approx()
// Usage:
//   assert_approx(got, expected, <info>);
// Topics: Error Checking, Debugging
// See Also: no_children(), no_function(), no_module(), assert_equal()
// Description:
//   Tests if the value gotten is what was expected.  If not, then
//   the expected and received values are printed to the console and
//   an assertion is thrown to stop execution.
// Arguments:
//   got = The value actually received.
//   expected = The value that was expected.
//   info = Extra info to print out to make the error clearer.
// Example:
//   assert_approx(1/3, 0.333333333333333, str("numer=",1,", demon=",3));
module assert_approx(got, expected, info) {
    no_children($children);
    if (!approx(got, expected)) {
        echo();
        echo(str("EXPECT: ", _valstr(expected)));
        echo(str("GOT   : ", _valstr(got)));
        if (same_shape(got, expected)) {
            echo(str("DELTA : ", _valstr(got - expected)));
        }
        if (is_def(info)) {
            echo(str("INFO  : ", _valstr(info)));
        }
        assert(approx(got, expected));
    }
}


// Module: assert_equal()
// Usage:
//   assert_equal(got, expected, <info>);
// Topics: Error Checking, Debugging
// See Also: no_children(), no_function(), no_module(), assert_approx()
// Description:
//   Tests if the value gotten is what was expected.  If not, then the expected and received values
//   are printed to the console and an assertion is thrown to stop execution.
// Arguments:
//   got = The value actually received.
//   expected = The value that was expected.
//   info = Extra info to print out to make the error clearer.
// Example:
//   assert_approx(3*9, 27, str("a=",3,", b=",9));
module assert_equal(got, expected, info) {
    no_children($children);
    if (got != expected || (is_nan(got) && is_nan(expected))) {
        echo();
        echo(str("EXPECT: ", _valstr(expected)));
        echo(str("GOT   : ", _valstr(got)));
        if (same_shape(got, expected)) {
            echo(str("DELTA : ", _valstr(got - expected)));
        }
        if (is_def(info)) {
            echo(str("INFO  : ", _valstr(info)));
        }
        assert(got == expected);
    }
}


// Module: shape_compare()
// Usage:
//   shape_compare(<eps>) {test_shape(); expected_shape();}
// Topics: Error Checking, Debugging, Testing
// See Also: assert_approx(), assert_equal()
// Description:
//   Compares two child shapes, returning empty geometry if they are very nearly the same shape and size.
//   Returns the differential geometry if they are not quite the same shape and size.
// Arguments:
//   eps = The surface of the two shapes must be within this size of each other.  Default: 1/1024
// Example:
//   $fn=36;
//   shape_compare() {
//       sphere(d=100);
//       rotate_extrude() right_half(planar=true) circle(d=100);
//   }
module shape_compare(eps=1/1024) {
    union() {
        difference() {
            children(0);
            if (eps==0) {
                children(1);
            } else {
                minkowski() {
                    children(1);
                    spheroid(r=eps, style="octa");
                }
            }
        }
        difference() {
            children(1);
            if (eps==0) {
                children(0);
            } else {
                minkowski() {
                    children(0);
                    spheroid(r=eps, style="octa");
                }
            }
        }
    }
}


// Section: Looping Helpers
//   You can use a list comprehension with a C-style for loop to iteratively make a calculation.
//   .
//   The syntax is: `[for (INIT; CONDITION; NEXT) RETVAL]` where:
//   - INIT is zero or more `let()` style assignments that are evaluated exactly one time, before the first loop.
//   - CONDITION is an expression evaluated at the start of each loop.  If true, continues with the loop.
//   - RETVAL is an expression that returns a list item for each loop.
//   - NEXT is one or more `let()` style assignments that is evaluated at the end of each loop.
//   .
//   Since the INIT phase is only run once, and the CONDITION and RETVAL expressions cannot update
//   variables, that means that only the NEXT phase can be used for iterative calculations.
//   Unfortunately, the NEXT phase runs *after* the RETVAL expression, which means that you need
//   to run the loop one extra time to return the final value.  This tends to make the loop code
//   look rather ugly.  The `looping()`, `loop_while()` and `loop_done()` functions
//   can make this somewhat more legible.
//   .
//   ```openscad
//   function flat_sum(l) = [
//       for (
//           i = 0,
//           total = 0,
//           state = 0;
//           
//           looping(state);
//           
//           state = loop_while(state, i < len(l)),
//           total = total +
//               loop_done(state) ? 0 :
//               let( x = l[i] )
//               is_list(x) ? flat_sum(x) : x,
//           i = i + 1
//       ) if (loop_done(state)) total;
//   ].x;
//   ```


// Function: looping()
// Usage:
//   bool = looping(state);
// Topics: Iteration
// See Also: loop_while(), loop_done()
// Description:
//   Returns true if the `state` value indicates the current loop should continue.  This is useful
//   when using C-style for loops to iteratively calculate a value.  Used with `loop_while()` and
//   `loop_done()`.  See [Looping Helpers](section-looping-helpers) for an example.
// Arguments:
//   state = The loop state value.
function looping(state) = state < 2;


// Function: loop_while()
// Usage:
//   state = loop_while(state, continue);
// Topics: Iteration
// See Also: looping(), loop_done()
// Description:
//   Given the current `state`, and a boolean `continue` that indicates if the loop should still be
//   continuing, returns the updated state value for the the next loop.  This is useful when using
//   C-style for loops to iteratively calculate a value.  Used with `looping()` and `loop_done()`.
//   See [Looping Helpers](section-looping-helpers) for an example.
// Arguments:
//   state = The loop state value.
//   continue = A boolean value indicating whether the current loop should progress.
function loop_while(state, continue) =
    state > 0 ? 2 :
    continue ? 0 : 1;


// Function: loop_done()
// Usage:
//   bool = loop_done(state);
// Topics: Iteration
// See Also: looping(), loop_while()
// Description:
//   Returns true if the `state` value indicates the loop is finishing.  This is useful when using
//   C-style for loops to iteratively calculate a value.  Used with `looping()` and `loop_while()`.
//   See [Looping Helpers](#5-looping-helpers) for an example.
// Arguments:
//   state = The loop state value.
function loop_done(state) = state > 0;


// vim: expandtab tabstop=4 shiftwidth=4 softtabstop=4 nowrap

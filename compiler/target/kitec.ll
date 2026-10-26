%Span = type { i64, i64, i64, i64 }
%Diag = type { i8*, i8*, %Span, i8*, i8*, i8*, i8*, i1 }
%Diags = type { { i64, i64, %Diag* } }
%Token = type { i8*, i8*, i64, %Span }
%RawLine = type { i64, i64, { i64, i64, %Token* } }
%Lexer = type { i8*, { i64, i64, i64* }, { i64, i64, i64* }, i64, i64, i64, %Diags, { i64, i64, %RawLine* }, i64 }
%Node = type { i8*, i8*, %Span, { i64, i64, i64* } }
%Ast = type { { i64, i64, %Node* } }
%Parser = type { { i64, i64, %Token* }, i64, i8*, %Diags, %Ast, { i64, i64, i64* } }

declare i32 @printf(i8*, ...)
declare i8* @malloc(i64)
declare void @free(i8*)
declare i8* @memcpy(i8*, i8*, i64)
declare i64 @strlen(i8*)
declare i8* @memmove(i8*, i8*, i64)
declare i32 @snprintf(i8*, i64, i8*, ...)
declare i32 @strcmp(i8*, i8*)
declare void @exit(i32)
declare i8* @fopen(i8*, i8*)
declare i64 @fread(i8*, i64, i64, i8*)
declare i64 @fwrite(i8*, i64, i64, i8*)
declare i32 @fclose(i8*)
declare i32 @fseek(i8*, i64, i32)
declare i64 @ftell(i8*)
declare void @llvm.memset.p0i8.i64(i8*, i8, i64, i1)

@.kite.argc = global i32 0
@.kite.argv = global i8** null

; extern declarations (implemented outside Kite, e.g. in C)
declare i64 @write(i64, i8*, i64)
declare i64 @system(i8*)

@.fmt.int = private unnamed_addr constant [6 x i8] c"%lld\0A\00"
@.fmt.float = private unnamed_addr constant [4 x i8] c"%f\0A\00"
@.fmt.str = private unnamed_addr constant [4 x i8] c"%s\0A\00"
@.fmt.int.raw = private unnamed_addr constant [5 x i8] c"%lld\00"
@.fmt.float.raw = private unnamed_addr constant [3 x i8] c"%g\00"
@.str.true = private unnamed_addr constant [5 x i8] c"true\00"
@.str.false = private unnamed_addr constant [6 x i8] c"false\00"
@.err.bounds = private unnamed_addr constant [79 x i8] c"kite: index %lld out of range for a list of length %lld (lists are 0-indexed)\0A\00"
@.err.arg = private unnamed_addr constant [86 x i8] c"kite: index %lld out of range for %lld command-line argument(s) (arg() is 0-indexed)\0A\00"
@.str.mode.rb = private unnamed_addr constant [3 x i8] c"rb\00"
@.str.mode.wb = private unnamed_addr constant [3 x i8] c"wb\00"
@.str.empty = private unnamed_addr constant [1 x i8] c"\00"

@.str.235 = private unnamed_addr constant [6 x i8] c"E0002\00"
@.str.89 = private unnamed_addr constant [5 x i8] c"null\00"
@.str.324 = private unnamed_addr constant [29 x i8] c"unterminated `{` in f-string\00"
@.str.239 = private unnamed_addr constant [2 x i8] c"\5C\00"
@.str.27 = private unnamed_addr constant [6 x i8] c"while\00"
@.str.336 = private unnamed_addr constant [6 x i8] c"Named\00"
@.str.49 = private unnamed_addr constant [5 x i8] c"from\00"
@.str.136 = private unnamed_addr constant [6 x i8] c"`int`\00"
@.str.298 = private unnamed_addr constant [7 x i8] c"LField\00"
@.str.52 = private unnamed_addr constant [7 x i8] c"Import\00"
@.str.213 = private unnamed_addr constant [5 x i8] c"`^=`\00"
@.str.42 = private unnamed_addr constant [4 x i8] c"Try\00"
@.str.146 = private unnamed_addr constant [9 x i8] c"LBracket\00"
@.str.35 = private unnamed_addr constant [3 x i8] c"in\00"
@.str.233 = private unnamed_addr constant [15 x i8] c"` is too large\00"
@.str.121 = private unnamed_addr constant [9 x i8] c"`failed`\00"
@.str.108 = private unnamed_addr constant [9 x i8] c"`return`\00"
@.str.289 = private unnamed_addr constant [9 x i8] c"variadic\00"
@.str.119 = private unnamed_addr constant [11 x i8] c"`continue`\00"
@.str.287 = private unnamed_addr constant [6 x i8] c"E0011\00"
@.str.259 = private unnamed_addr constant [6 x i8] c"Entry\00"
@.str.226 = private unnamed_addr constant [6 x i8] c"E0004\00"
@.str.288 = private unnamed_addr constant [5 x i8] c"self\00"
@.str.223 = private unnamed_addr constant [22 x i8] c"end of indented block\00"
@.str.189 = private unnamed_addr constant [4 x i8] c"`|`\00"
@.str.333 = private unnamed_addr constant [4 x i8] c"Neg\00"
@.str.1 = private unnamed_addr constant [1 x i8] c"\00"
@.str.148 = private unnamed_addr constant [9 x i8] c"RBracket\00"
@.str.162 = private unnamed_addr constant [5 x i8] c"Plus\00"
@.str.93 = private unnamed_addr constant [2 x i8] c"`\00"
@.str.144 = private unnamed_addr constant [7 x i8] c"RParen\00"
@.str.169 = private unnamed_addr constant [4 x i8] c"`/`\00"
@.str.264 = private unnamed_addr constant [18 x i8] c"string literal \22\22\00"
@.str.329 = private unnamed_addr constant [5 x i8] c"Call\00"
@.str.193 = private unnamed_addr constant [4 x i8] c"`~`\00"
@.str.219 = private unnamed_addr constant [12 x i8] c"end of line\00"
@.str.295 = private unnamed_addr constant [7 x i8] c"Unpack\00"
@.str.255 = private unnamed_addr constant [5 x i8] c"List\00"
@.str.334 = private unnamed_addr constant [7 x i8] c"AddrOf\00"
@.str.344 = private unnamed_addr constant [31 x i8] c"expected an expression, found \00"
@.str.307 = private unnamed_addr constant [4 x i8] c"Add\00"
@.str.8 = private unnamed_addr constant [2 x i8] c":\00"
@.str.347 = private unnamed_addr constant [8 x i8] c"ListLit\00"
@.str.174 = private unnamed_addr constant [6 x i8] c"NotEq\00"
@.str.237 = private unnamed_addr constant [33 x i8] c"string was never closed with `\22`\00"
@.str.310 = private unnamed_addr constant [4 x i8] c"Div\00"
@.str.155 = private unnamed_addr constant [4 x i8] c"`,`\00"
@.str.45 = private unnamed_addr constant [8 x i8] c"finally\00"
@.str.25 = private unnamed_addr constant [6 x i8] c"until\00"
@.str.225 = private unnamed_addr constant [12 x i8] c"end of file\00"
@.str.265 = private unnamed_addr constant [10 x i8] c"expected \00"
@.str.168 = private unnamed_addr constant [6 x i8] c"Slash\00"
@.str.10 = private unnamed_addr constant [4 x i8] c" | \00"
@.str.17 = private unnamed_addr constant [7 x i8] c"return\00"
@.str.36 = private unnamed_addr constant [3 x i8] c"In\00"
@.str.9 = private unnamed_addr constant [4 x i8] c" |\0A\00"
@.str.76 = private unnamed_addr constant [5 x i8] c"True\00"
@.str.94 = private unnamed_addr constant [13 x i8] c"FloatLiteral\00"
@.str.110 = private unnamed_addr constant [7 x i8] c"`orif`\00"
@.str.153 = private unnamed_addr constant [4 x i8] c"`}`\00"
@.str.43 = private unnamed_addr constant [7 x i8] c"failed\00"
@.str.137 = private unnamed_addr constant [8 x i8] c"`float`\00"
@.str.159 = private unnamed_addr constant [4 x i8] c"`.`\00"
@.str.322 = private unnamed_addr constant [2 x i8] c"}\00"
@.str.123 = private unnamed_addr constant [6 x i8] c"`use`\00"
@.str.62 = private unnamed_addr constant [5 x i8] c"Enum\00"
@.str.138 = private unnamed_addr constant [7 x i8] c"`bool`\00"
@.str.11 = private unnamed_addr constant [2 x i8] c"^\00"
@.str.320 = private unnamed_addr constant [8 x i8] c"ForEach\00"
@.str.353 = private unnamed_addr constant [4 x i8] c"ast\00"
@.str.351 = private unnamed_addr constant [29 x i8] c"usage: kitec tokens|ast FILE\00"
@.str.19 = private unnamed_addr constant [3 x i8] c"if\00"
@.str.80 = private unnamed_addr constant [6 x i8] c"KwInt\00"
@.str.127 = private unnamed_addr constant [7 x i8] c"`enum`\00"
@.str.280 = private unnamed_addr constant [18 x i8] c"` has no variants\00"
@.str.245 = private unnamed_addr constant [3 x i8] c"\5C\5C\00"
@.str.286 = private unnamed_addr constant [24 x i8] c"expected a type, found \00"
@.str.292 = private unnamed_addr constant [9 x i8] c"Function\00"
@.str.337 = private unnamed_addr constant [11 x i8] c"MethodCall\00"
@.str.195 = private unnamed_addr constant [5 x i8] c"`<<`\00"
@.str.303 = private unnamed_addr constant [7 x i8] c"LDeref\00"
@.str.107 = private unnamed_addr constant [7 x i8] c"`case`\00"
@.str.274 = private unnamed_addr constant [3 x i8] c"__\00"
@.str.160 = private unnamed_addr constant [6 x i8] c"Arrow\00"
@.str.151 = private unnamed_addr constant [4 x i8] c"`{`\00"
@.str.72 = private unnamed_addr constant [3 x i8] c"Or\00"
@.str.78 = private unnamed_addr constant [6 x i8] c"False\00"
@.str.206 = private unnamed_addr constant [10 x i8] c"PercentEq\00"
@.str.113 = private unnamed_addr constant [8 x i8] c"`while`\00"
@.str.301 = private unnamed_addr constant [6 x i8] c"Unary\00"
@.str.332 = private unnamed_addr constant [56 x i8] c"single `}` in f-string (write `}}` for a literal brace)\00"
@.str.279 = private unnamed_addr constant [7 x i8] c"enum `\00"
@.str.187 = private unnamed_addr constant [4 x i8] c"`&`\00"
@.str.147 = private unnamed_addr constant [4 x i8] c"`[`\00"
@.str.53 = private unnamed_addr constant [5 x i8] c"type\00"
@.str.163 = private unnamed_addr constant [4 x i8] c"`+`\00"
@.str.325 = private unnamed_addr constant [4 x i8] c"Str\00"
@.str.294 = private unnamed_addr constant [9 x i8] c"ExprStmt\00"
@.str.248 = private unnamed_addr constant [3 x i8] c"\5Cr\00"
@.str.271 = private unnamed_addr constant [77 x i8] c"expected `use`, `from`, `type`, `class`, `enum`, `extern`, or `make`, found \00"
@.str.317 = private unnamed_addr constant [7 x i8] c"Binary\00"
@.str.61 = private unnamed_addr constant [5 x i8] c"enum\00"
@.str.246 = private unnamed_addr constant [3 x i8] c"\5Cn\00"
@.str.275 = private unnamed_addr constant [6 x i8] c"Field\00"
@.str.188 = private unnamed_addr constant [5 x i8] c"Pipe\00"
@.str.308 = private unnamed_addr constant [4 x i8] c"Sub\00"
@.str.98 = private unnamed_addr constant [2 x i8] c"\22\00"
@.str.266 = private unnamed_addr constant [9 x i8] c", found \00"
@.str.143 = private unnamed_addr constant [4 x i8] c"`(`\00"
@.str.145 = private unnamed_addr constant [4 x i8] c"`)`\00"
@.str.40 = private unnamed_addr constant [9 x i8] c"Continue\00"
@.str.172 = private unnamed_addr constant [5 x i8] c"EqEq\00"
@.str.103 = private unnamed_addr constant [7 x i8] c"`make`\00"
@.str.95 = private unnamed_addr constant [16 x i8] c"float literal `\00"
@.str.13 = private unnamed_addr constant [5 x i8] c"make\00"
@.str.200 = private unnamed_addr constant [8 x i8] c"MinusEq\00"
@.str.97 = private unnamed_addr constant [17 x i8] c"string literal \22\00"
@.str.316 = private unnamed_addr constant [75 x i8] c"a compound assignment (`+=` and friends) can't also have a type annotation\00"
@.str.318 = private unnamed_addr constant [4 x i8] c"Arm\00"
@.str.114 = private unnamed_addr constant [10 x i8] c"`infinit`\00"
@.str.131 = private unnamed_addr constant [6 x i8] c"`and`\00"
@.str.37 = private unnamed_addr constant [6 x i8] c"break\00"
@.str.38 = private unnamed_addr constant [6 x i8] c"Break\00"
@.str.86 = private unnamed_addr constant [9 x i8] c"KwString\00"
@.str.91 = private unnamed_addr constant [11 x i8] c"IntLiteral\00"
@.str.214 = private unnamed_addr constant [6 x i8] c"ShlEq\00"
@.str.313 = private unnamed_addr constant [6 x i8] c"BitOr\00"
@.str.331 = private unnamed_addr constant [6 x i8] c"E0094\00"
@.str.350 = private unnamed_addr constant [3 x i8] c" @\00"
@.str.71 = private unnamed_addr constant [3 x i8] c"or\00"
@.str.73 = private unnamed_addr constant [4 x i8] c"not\00"
@.str.244 = private unnamed_addr constant [3 x i8] c"\5C\22\00"
@.str.197 = private unnamed_addr constant [5 x i8] c"`>>`\00"
@.str.241 = private unnamed_addr constant [58 x i8] c"unexpected character `!` (use `not` for boolean negation)\00"
@.str.260 = private unnamed_addr constant [7 x i8] c"VField\00"
@.str.230 = private unnamed_addr constant [25 x i8] c"inconsistent indentation\00"
@.str.12 = private unnamed_addr constant [9 x i8] c"= help: \00"
@.str.39 = private unnamed_addr constant [9 x i8] c"continue\00"
@.str.349 = private unnamed_addr constant [9 x i8] c"TupleLit\00"
@.str.100 = private unnamed_addr constant [19 x i8] c"f-string literal \22\00"
@.str.167 = private unnamed_addr constant [4 x i8] c"`*`\00"
@.str.41 = private unnamed_addr constant [4 x i8] c"try\00"
@.str.315 = private unnamed_addr constant [6 x i8] c"E0100\00"
@.str.69 = private unnamed_addr constant [4 x i8] c"and\00"
@.str.149 = private unnamed_addr constant [4 x i8] c"`]`\00"
@.str.170 = private unnamed_addr constant [8 x i8] c"Percent\00"
@.str.83 = private unnamed_addr constant [5 x i8] c"bool\00"
@.str.191 = private unnamed_addr constant [4 x i8] c"`^`\00"
@.str.218 = private unnamed_addr constant [8 x i8] c"Newline\00"
@.str.262 = private unnamed_addr constant [2 x i8] c"(\00"
@.str.306 = private unnamed_addr constant [7 x i8] c"Assign\00"
@.str.346 = private unnamed_addr constant [28 x i8] c"expected an expression here\00"
@.str.105 = private unnamed_addr constant [8 x i8] c"`class`\00"
@.str.67 = private unnamed_addr constant [6 x i8] c"await\00"
@.str.291 = private unnamed_addr constant [13 x i8] c"extern async\00"
@.str.352 = private unnamed_addr constant [7 x i8] c"tokens\00"
@.str.135 = private unnamed_addr constant [8 x i8] c"`false`\00"
@.str.312 = private unnamed_addr constant [7 x i8] c"BitAnd\00"
@.str.70 = private unnamed_addr constant [4 x i8] c"And\00"
@.str.211 = private unnamed_addr constant [5 x i8] c"`|=`\00"
@.str.99 = private unnamed_addr constant [15 x i8] c"FStringLiteral\00"
@.str.28 = private unnamed_addr constant [6 x i8] c"While\00"
@.str.192 = private unnamed_addr constant [6 x i8] c"Tilde\00"
@.str.203 = private unnamed_addr constant [5 x i8] c"`*=`\00"
@.str.293 = private unnamed_addr constant [6 x i8] c"Block\00"
@.str.23 = private unnamed_addr constant [5 x i8] c"else\00"
@.str.46 = private unnamed_addr constant [8 x i8] c"Finally\00"
@.str.284 = private unnamed_addr constant [2 x i8] c">\00"
@.str.112 = private unnamed_addr constant [8 x i8] c"`until`\00"
@.str.171 = private unnamed_addr constant [4 x i8] c"`%`\00"
@.str.186 = private unnamed_addr constant [4 x i8] c"Amp\00"
@.str.252 = private unnamed_addr constant [6 x i8] c"Float\00"
@.str.88 = private unnamed_addr constant [6 x i8] c"KwPtr\00"
@.str.305 = private unnamed_addr constant [37 x i8] c"this expression can't be assigned to\00"
@.str.231 = private unnamed_addr constant [50 x i8] c"indentation must match an enclosing block's level\00"
@.str.335 = private unnamed_addr constant [7 x i8] c"BitNot\00"
@.str.87 = private unnamed_addr constant [4 x i8] c"ptr\00"
@.str.339 = private unnamed_addr constant [5 x i8] c"Null\00"
@.str.154 = private unnamed_addr constant [6 x i8] c"Comma\00"
@.str.240 = private unnamed_addr constant [6 x i8] c"E0003\00"
@.str.125 = private unnamed_addr constant [9 x i8] c"`import`\00"
@.str.281 = private unnamed_addr constant [6 x i8] c"E0068\00"
@.str.354 = private unnamed_addr constant [25 x i8] c"kitec: unknown command `\00"
@.str.57 = private unnamed_addr constant [6 x i8] c"match\00"
@.str.179 = private unnamed_addr constant [4 x i8] c"`>`\00"
@.str.199 = private unnamed_addr constant [5 x i8] c"`+=`\00"
@.str.273 = private unnamed_addr constant [12 x i8] c"ImportItems\00"
@.str.299 = private unnamed_addr constant [6 x i8] c"Index\00"
@.str.176 = private unnamed_addr constant [3 x i8] c"Lt\00"
@.str.247 = private unnamed_addr constant [3 x i8] c"\5Ct\00"
@.str.29 = private unnamed_addr constant [8 x i8] c"infinit\00"
@.str.208 = private unnamed_addr constant [6 x i8] c"AmpEq\00"
@.str.126 = private unnamed_addr constant [7 x i8] c"`type`\00"
@.str.117 = private unnamed_addr constant [5 x i8] c"`in`\00"
@.str.158 = private unnamed_addr constant [4 x i8] c"Dot\00"
@.str.0 = private unnamed_addr constant [2 x i8] c"\0A\00"
@.str.348 = private unnamed_addr constant [8 x i8] c"DictLit\00"
@.str.75 = private unnamed_addr constant [5 x i8] c"true\00"
@.str.84 = private unnamed_addr constant [7 x i8] c"KwBool\00"
@.str.181 = private unnamed_addr constant [5 x i8] c"`<=`\00"
@.str.342 = private unnamed_addr constant [8 x i8] c"alloc_n\00"
@.str.47 = private unnamed_addr constant [4 x i8] c"use\00"
@.str.24 = private unnamed_addr constant [5 x i8] c"Else\00"
@.str.85 = private unnamed_addr constant [7 x i8] c"string\00"
@.str.196 = private unnamed_addr constant [4 x i8] c"Shr\00"
@.str.341 = private unnamed_addr constant [6 x i8] c"Alloc\00"
@.str.16 = private unnamed_addr constant [7 x i8] c"Extern\00"
@.str.66 = private unnamed_addr constant [6 x i8] c"Async\00"
@.str.296 = private unnamed_addr constant [6 x i8] c"Ident\00"
@.str.142 = private unnamed_addr constant [7 x i8] c"LParen\00"
@.str.328 = private unnamed_addr constant [6 x i8] c"E0093\00"
@.str.183 = private unnamed_addr constant [5 x i8] c"`>=`\00"
@.str.118 = private unnamed_addr constant [8 x i8] c"`break`\00"
@.str.178 = private unnamed_addr constant [3 x i8] c"Gt\00"
@.str.4 = private unnamed_addr constant [2 x i8] c"]\00"
@.str.101 = private unnamed_addr constant [11 x i8] c"Identifier\00"
@.str.122 = private unnamed_addr constant [10 x i8] c"`finally`\00"
@.str.133 = private unnamed_addr constant [6 x i8] c"`not`\00"
@.str.177 = private unnamed_addr constant [4 x i8] c"`<`\00"
@.str.201 = private unnamed_addr constant [5 x i8] c"`-=`\00"
@.str.251 = private unnamed_addr constant [4 x i8] c"Int\00"
@.str.276 = private unnamed_addr constant [7 x i8] c"Struct\00"
@.str.15 = private unnamed_addr constant [7 x i8] c"extern\00"
@.str.32 = private unnamed_addr constant [4 x i8] c"For\00"
@.str.157 = private unnamed_addr constant [4 x i8] c"`:`\00"
@.str.132 = private unnamed_addr constant [5 x i8] c"`or`\00"
@.str.31 = private unnamed_addr constant [4 x i8] c"for\00"
@.str.59 = private unnamed_addr constant [5 x i8] c"case\00"
@.str.180 = private unnamed_addr constant [5 x i8] c"LtEq\00"
@.str.207 = private unnamed_addr constant [5 x i8] c"`%=`\00"
@.str.18 = private unnamed_addr constant [7 x i8] c"Return\00"
@.str.65 = private unnamed_addr constant [6 x i8] c"async\00"
@.str.2 = private unnamed_addr constant [6 x i8] c"error\00"
@.str.216 = private unnamed_addr constant [6 x i8] c"ShrEq\00"
@.str.51 = private unnamed_addr constant [7 x i8] c"import\00"
@.str.128 = private unnamed_addr constant [9 x i8] c"`thread`\00"
@.str.250 = private unnamed_addr constant [4 x i8] c"nil\00"
@.str.263 = private unnamed_addr constant [2 x i8] c")\00"
@.str.327 = private unnamed_addr constant [14 x i8] c"` in f-string\00"
@.str.82 = private unnamed_addr constant [8 x i8] c"KwFloat\00"
@.str.190 = private unnamed_addr constant [6 x i8] c"Caret\00"
@.str.222 = private unnamed_addr constant [7 x i8] c"Dedent\00"
@.str.92 = private unnamed_addr constant [18 x i8] c"integer literal `\00"
@.str.129 = private unnamed_addr constant [8 x i8] c"`async`\00"
@.str.340 = private unnamed_addr constant [6 x i8] c"alloc\00"
@.str.102 = private unnamed_addr constant [13 x i8] c"identifier `\00"
@.str.277 = private unnamed_addr constant [2 x i8] c"f\00"
@.str.166 = private unnamed_addr constant [5 x i8] c"Star\00"
@.str.77 = private unnamed_addr constant [6 x i8] c"false\00"
@.str.140 = private unnamed_addr constant [6 x i8] c"`ptr`\00"
@.str.173 = private unnamed_addr constant [5 x i8] c"`==`\00"
@.str.184 = private unnamed_addr constant [3 x i8] c"Eq\00"
@.str.270 = private unnamed_addr constant [6 x i8] c"E0013\00"
@.str.54 = private unnamed_addr constant [5 x i8] c"Type\00"
@.str.205 = private unnamed_addr constant [5 x i8] c"`/=`\00"
@.str.134 = private unnamed_addr constant [7 x i8] c"`true`\00"
@.str.165 = private unnamed_addr constant [4 x i8] c"`-`\00"
@.str.7 = private unnamed_addr constant [5 x i8] c"--> \00"
@.str.30 = private unnamed_addr constant [8 x i8] c"Infinit\00"
@.str.150 = private unnamed_addr constant [7 x i8] c"LBrace\00"
@.str.26 = private unnamed_addr constant [6 x i8] c"Until\00"
@.str.182 = private unnamed_addr constant [5 x i8] c"GtEq\00"
@.str.232 = private unnamed_addr constant [20 x i8] c"9223372036854775807\00"
@.str.50 = private unnamed_addr constant [5 x i8] c"From\00"
@.str.234 = private unnamed_addr constant [6 x i8] c"E0001\00"
@.str.269 = private unnamed_addr constant [31 x i8] c"expected an identifier, found \00"
@.str.124 = private unnamed_addr constant [7 x i8] c"`from`\00"
@.str.300 = private unnamed_addr constant [7 x i8] c"LIndex\00"
@.str.309 = private unnamed_addr constant [4 x i8] c"Mul\00"
@.str.321 = private unnamed_addr constant [2 x i8] c"{\00"
@.str.20 = private unnamed_addr constant [3 x i8] c"If\00"
@.str.185 = private unnamed_addr constant [4 x i8] c"`=`\00"
@.str.267 = private unnamed_addr constant [6 x i8] c" here\00"
@.str.326 = private unnamed_addr constant [21 x i8] c"invalid expression `\00"
@.str.227 = private unnamed_addr constant [51 x i8] c"inconsistent use of tabs and spaces in indentation\00"
@.str.120 = private unnamed_addr constant [6 x i8] c"`try`\00"
@.str.253 = private unnamed_addr constant [2 x i8] c"@\00"
@.str.323 = private unnamed_addr constant [6 x i8] c"E0092\00"
@.str.249 = private unnamed_addr constant [2 x i8] c".\00"
@.str.330 = private unnamed_addr constant [4 x i8] c"str\00"
@.str.55 = private unnamed_addr constant [6 x i8] c"class\00"
@.str.345 = private unnamed_addr constant [6 x i8] c"E0012\00"
@.str.63 = private unnamed_addr constant [7 x i8] c"thread\00"
@.str.130 = private unnamed_addr constant [8 x i8] c"`await`\00"
@.str.204 = private unnamed_addr constant [8 x i8] c"SlashEq\00"
@.str.210 = private unnamed_addr constant [7 x i8] c"PipeEq\00"
@.str.217 = private unnamed_addr constant [6 x i8] c"`>>=`\00"
@.str.224 = private unnamed_addr constant [4 x i8] c"Eof\00"
@.str.14 = private unnamed_addr constant [5 x i8] c"Make\00"
@.str.64 = private unnamed_addr constant [7 x i8] c"Thread\00"
@.str.106 = private unnamed_addr constant [8 x i8] c"`match`\00"
@.str.33 = private unnamed_addr constant [3 x i8] c"to\00"
@.str.21 = private unnamed_addr constant [5 x i8] c"orif\00"
@.str.115 = private unnamed_addr constant [6 x i8] c"`for`\00"
@.str.5 = private unnamed_addr constant [3 x i8] c": \00"
@.str.175 = private unnamed_addr constant [5 x i8] c"`!=`\00"
@.str.228 = private unnamed_addr constant [192 x i8] c"this line's indentation is ambiguous relative to the line above it once tabs and spaces are compared directly -- indent this block with only tabs or only spaces, matching the rest of the file\00"
@.str.261 = private unnamed_addr constant [3 x i8] c"@-\00"
@.str.141 = private unnamed_addr constant [7 x i8] c"`null`\00"
@.str.104 = private unnamed_addr constant [9 x i8] c"`extern`\00"
@.str.156 = private unnamed_addr constant [6 x i8] c"Colon\00"
@.str.202 = private unnamed_addr constant [7 x i8] c"StarEq\00"
@.str.74 = private unnamed_addr constant [4 x i8] c"Not\00"
@.str.58 = private unnamed_addr constant [6 x i8] c"Match\00"
@.str.44 = private unnamed_addr constant [7 x i8] c"Failed\00"
@.str.297 = private unnamed_addr constant [7 x i8] c"LIdent\00"
@.str.96 = private unnamed_addr constant [14 x i8] c"StringLiteral\00"
@.str.161 = private unnamed_addr constant [5 x i8] c"`->`\00"
@.str.238 = private unnamed_addr constant [2 x i8] c"\09\00"
@.str.282 = private unnamed_addr constant [85 x i8] c"an enum needs at least one variant, e.g. `enum Color:\5Cn    Red\5Cn    Green\5Cn    Blue`\00"
@.str.338 = private unnamed_addr constant [5 x i8] c"Bool\00"
@.str.79 = private unnamed_addr constant [4 x i8] c"int\00"
@.str.22 = private unnamed_addr constant [5 x i8] c"Orif\00"
@.str.56 = private unnamed_addr constant [6 x i8] c"Class\00"
@.str.343 = private unnamed_addr constant [7 x i8] c"AllocN\00"
@.str.215 = private unnamed_addr constant [6 x i8] c"`<<=`\00"
@.str.198 = private unnamed_addr constant [7 x i8] c"PlusEq\00"
@.str.257 = private unnamed_addr constant [5 x i8] c"Name\00"
@.str.3 = private unnamed_addr constant [2 x i8] c"[\00"
@.str.242 = private unnamed_addr constant [61 x i8] c"Kite doesn't use semicolons -- statements end at the newline\00"
@.str.311 = private unnamed_addr constant [4 x i8] c"Mod\00"
@.str.152 = private unnamed_addr constant [7 x i8] c"RBrace\00"
@.str.319 = private unnamed_addr constant [9 x i8] c"ForRange\00"
@.str.164 = private unnamed_addr constant [6 x i8] c"Minus\00"
@.str.60 = private unnamed_addr constant [5 x i8] c"Case\00"
@.str.304 = private unnamed_addr constant [6 x i8] c"E0098\00"
@.str.139 = private unnamed_addr constant [9 x i8] c"`string`\00"
@.str.283 = private unnamed_addr constant [5 x i8] c"ptr<\00"
@.str.194 = private unnamed_addr constant [4 x i8] c"Shl\00"
@.str.268 = private unnamed_addr constant [6 x i8] c"E0010\00"
@.str.209 = private unnamed_addr constant [5 x i8] c"`&=`\00"
@.str.221 = private unnamed_addr constant [12 x i8] c"indentation\00"
@.str.111 = private unnamed_addr constant [7 x i8] c"`else`\00"
@.str.90 = private unnamed_addr constant [7 x i8] c"KwNull\00"
@.str.48 = private unnamed_addr constant [4 x i8] c"Use\00"
@.str.302 = private unnamed_addr constant [6 x i8] c"Deref\00"
@.str.256 = private unnamed_addr constant [6 x i8] c"Flags\00"
@.str.278 = private unnamed_addr constant [8 x i8] c"Variant\00"
@.str.34 = private unnamed_addr constant [3 x i8] c"To\00"
@.str.258 = private unnamed_addr constant [8 x i8] c"Program\00"
@.str.81 = private unnamed_addr constant [6 x i8] c"float\00"
@.str.212 = private unnamed_addr constant [8 x i8] c"CaretEq\00"
@.str.229 = private unnamed_addr constant [6 x i8] c"E0005\00"
@.str.290 = private unnamed_addr constant [6 x i8] c"Param\00"
@.str.220 = private unnamed_addr constant [7 x i8] c"Indent\00"
@.str.285 = private unnamed_addr constant [3 x i8] c", \00"
@.str.116 = private unnamed_addr constant [5 x i8] c"`to`\00"
@.str.243 = private unnamed_addr constant [23 x i8] c"unexpected character `\00"
@.str.254 = private unnamed_addr constant [2 x i8] c"-\00"
@.str.272 = private unnamed_addr constant [13 x i8] c"ImportModule\00"
@.str.236 = private unnamed_addr constant [28 x i8] c"unterminated string literal\00"
@.str.68 = private unnamed_addr constant [6 x i8] c"Await\00"
@.str.6 = private unnamed_addr constant [2 x i8] c" \00"
@.str.109 = private unnamed_addr constant [5 x i8] c"`if`\00"
@.str.314 = private unnamed_addr constant [7 x i8] c"BitXor\00"

define void @eprint(i8* %s.arg) {
entry:
  %s = alloca i8*
  store i8* %s.arg, i8** %s
  %.r0 = load i8*, i8** %s
  %.t0 = call i64 @strlen(i8* %.r0)
  %.r1 = load i8*, i8** %s
  %.t1 = call i64 @write(i64 2, i8* %.r1, i64 %.t0)
  ret void
}

define void @eprint_line(i8* %s.arg) {
entry:
  %s = alloca i8*
  store i8* %s.arg, i8** %s
  %.r2 = load i8*, i8** %s
  %.t0 = call i64 @strlen(i8* %.r2)
  %.r3 = load i8*, i8** %s
  %.t1 = call i64 @write(i64 2, i8* %.r3, i64 %.t0)
  %.p4 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.0, i64 0, i64 0
  %.t2 = call i64 @write(i64 2, i8* %.p4, i64 1)
  ret void
}

define void @span_new(%Span* %__ret, i64 %start.arg, i64 %end.arg, i64 %line.arg, i64 %col.arg) {
entry:
  %start = alloca i64
  %end = alloca i64
  %line = alloca i64
  %col = alloca i64
  %s = alloca %Span
  store i64 %start.arg, i64* %start
  store i64 %end.arg, i64* %end
  store i64 %line.arg, i64* %line
  store i64 %col.arg, i64* %col
  %.p5 = getelementptr inbounds %Span, %Span* %s, i32 0, i32 0
  store i64 0, i64* %.p5
  %.p6 = getelementptr inbounds %Span, %Span* %s, i32 0, i32 1
  store i64 0, i64* %.p6
  %.p7 = getelementptr inbounds %Span, %Span* %s, i32 0, i32 2
  store i64 0, i64* %.p7
  %.p8 = getelementptr inbounds %Span, %Span* %s, i32 0, i32 3
  store i64 0, i64* %.p8
  %.r9 = load i64, i64* %start
  %.p10 = getelementptr inbounds %Span, %Span* %s, i32 0, i32 0
  store i64 %.r9, i64* %.p10
  %.r11 = load i64, i64* %end
  %.p12 = getelementptr inbounds %Span, %Span* %s, i32 0, i32 1
  store i64 %.r11, i64* %.p12
  %.r13 = load i64, i64* %line
  %.p14 = getelementptr inbounds %Span, %Span* %s, i32 0, i32 2
  store i64 %.r13, i64* %.p14
  %.r15 = load i64, i64* %col
  %.p16 = getelementptr inbounds %Span, %Span* %s, i32 0, i32 3
  store i64 %.r15, i64* %.p16
  %.r17 = load %Span, %Span* %s
  store %Span %.r17, %Span* %__ret
  ret void
}

define void @span_dummy(%Span* %__ret) {
entry:
  %__agg.0 = alloca %Span
  call void @span_new(%Span* %__agg.0, i64 0, i64 0, i64 0, i64 0)
  %.r18 = load %Span, %Span* %__agg.0
  store %Span %.r18, %Span* %__ret
  ret void
}

define void @span_to(%Span* %__ret, %Span* %a, %Span* %b) {
entry:
  %s = alloca %Span
  %.p19 = getelementptr inbounds %Span, %Span* %s, i32 0, i32 0
  store i64 0, i64* %.p19
  %.p20 = getelementptr inbounds %Span, %Span* %s, i32 0, i32 1
  store i64 0, i64* %.p20
  %.p21 = getelementptr inbounds %Span, %Span* %s, i32 0, i32 2
  store i64 0, i64* %.p21
  %.p22 = getelementptr inbounds %Span, %Span* %s, i32 0, i32 3
  store i64 0, i64* %.p22
  %.p23 = getelementptr inbounds %Span, %Span* %a, i32 0, i32 0
  %.t0 = load i64, i64* %.p23
  %.p24 = getelementptr inbounds %Span, %Span* %b, i32 0, i32 0
  %.t1 = load i64, i64* %.p24
  %.t2 = call i64 @min(i64 %.t0, i64 %.t1)
  %.p25 = getelementptr inbounds %Span, %Span* %s, i32 0, i32 0
  store i64 %.t2, i64* %.p25
  %.p26 = getelementptr inbounds %Span, %Span* %a, i32 0, i32 1
  %.t3 = load i64, i64* %.p26
  %.p27 = getelementptr inbounds %Span, %Span* %b, i32 0, i32 1
  %.t4 = load i64, i64* %.p27
  %.t5 = call i64 @max(i64 %.t3, i64 %.t4)
  %.p28 = getelementptr inbounds %Span, %Span* %s, i32 0, i32 1
  store i64 %.t5, i64* %.p28
  %.p29 = getelementptr inbounds %Span, %Span* %a, i32 0, i32 2
  %.t6 = load i64, i64* %.p29
  %.p30 = getelementptr inbounds %Span, %Span* %s, i32 0, i32 2
  store i64 %.t6, i64* %.p30
  %.p31 = getelementptr inbounds %Span, %Span* %a, i32 0, i32 3
  %.t7 = load i64, i64* %.p31
  %.p32 = getelementptr inbounds %Span, %Span* %s, i32 0, i32 3
  store i64 %.t7, i64* %.p32
  %.r33 = load %Span, %Span* %s
  store %Span %.r33, %Span* %__ret
  ret void
}

define void @Diags__add(%Diags* %self, i8* %code.arg, i8* %title.arg, %Span* %span, i8* %label.arg, i8* %help.arg) {
entry:
  %code = alloca i8*
  %title = alloca i8*
  %label = alloca i8*
  %help = alloca i8*
  %d = alloca %Diag
  store i8* %code.arg, i8** %code
  store i8* %title.arg, i8** %title
  store i8* %label.arg, i8** %label
  store i8* %help.arg, i8** %help
  %.p34 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p35 = getelementptr inbounds %Diag, %Diag* %d, i32 0, i32 0
  store i8* %.p34, i8** %.p35
  %.p36 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p37 = getelementptr inbounds %Diag, %Diag* %d, i32 0, i32 1
  store i8* %.p36, i8** %.p37
  %.p38 = getelementptr inbounds %Diag, %Diag* %d, i32 0, i32 2
  store %Span zeroinitializer, %Span* %.p38
  %.p39 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p40 = getelementptr inbounds %Diag, %Diag* %d, i32 0, i32 3
  store i8* %.p39, i8** %.p40
  %.p41 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p42 = getelementptr inbounds %Diag, %Diag* %d, i32 0, i32 4
  store i8* %.p41, i8** %.p42
  %.p43 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p44 = getelementptr inbounds %Diag, %Diag* %d, i32 0, i32 5
  store i8* %.p43, i8** %.p44
  %.p45 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p46 = getelementptr inbounds %Diag, %Diag* %d, i32 0, i32 6
  store i8* %.p45, i8** %.p46
  %.p47 = getelementptr inbounds %Diag, %Diag* %d, i32 0, i32 7
  store i1 false, i1* %.p47
  %.r48 = load i8*, i8** %code
  %.p49 = getelementptr inbounds %Diag, %Diag* %d, i32 0, i32 0
  store i8* %.r48, i8** %.p49
  %.r50 = load i8*, i8** %title
  %.p51 = getelementptr inbounds %Diag, %Diag* %d, i32 0, i32 1
  store i8* %.r50, i8** %.p51
  %.r52 = load %Span, %Span* %span
  %.p53 = getelementptr inbounds %Diag, %Diag* %d, i32 0, i32 2
  store %Span %.r52, %Span* %.p53
  %.r54 = load i8*, i8** %label
  %.p55 = getelementptr inbounds %Diag, %Diag* %d, i32 0, i32 3
  store i8* %.r54, i8** %.p55
  %.r56 = load i8*, i8** %help
  %.p57 = getelementptr inbounds %Diag, %Diag* %d, i32 0, i32 4
  store i8* %.r56, i8** %.p57
  %__fld.0 = getelementptr inbounds %Diags, %Diags* %self, i32 0, i32 0
  %.p58 = getelementptr %Diag, %Diag* null, i32 1
  %.r59 = ptrtoint %Diag* %.p58 to i64
  %.p60 = getelementptr inbounds { i64, i64, %Diag* }, { i64, i64, %Diag* }* %__fld.0, i32 0, i32 0
  %.p61 = getelementptr inbounds { i64, i64, %Diag* }, { i64, i64, %Diag* }* %__fld.0, i32 0, i32 1
  %.p62 = getelementptr inbounds { i64, i64, %Diag* }, { i64, i64, %Diag* }* %__fld.0, i32 0, i32 2
  %.r63 = load i64, i64* %.p60
  %.r64 = load i64, i64* %.p61
  %.r65 = icmp sge i64 %.r63, %.r64
  br i1 %.r65, label %append.grow.66, label %append.after.67
append.grow.66:
  %.r68 = load %Diag*, %Diag** %.p62
  %.r69 = icmp eq i64 %.r64, 0
  %.r70 = mul i64 %.r64, 2
  %.r71 = select i1 %.r69, i64 1, i64 %.r70
  %.r72 = mul i64 %.r71, %.r59
  %.p73 = call i8* @malloc(i64 %.r72)
  %.p74 = bitcast i8* %.p73 to %Diag*
  %.r75 = mul i64 %.r63, %.r59
  %.p76 = bitcast %Diag* %.r68 to i8*
  call i8* @memcpy(i8* %.p73, i8* %.p76, i64 %.r75)
  call void @free(i8* %.p76)
  store %Diag* %.p74, %Diag** %.p62
  store i64 %.r71, i64* %.p61
  br label %append.after.67
append.after.67:
  %.r77 = load %Diag*, %Diag** %.p62
  %.r78 = load %Diag, %Diag* %d
  %.p79 = getelementptr inbounds %Diag, %Diag* %.r77, i64 %.r63
  store %Diag %.r78, %Diag* %.p79
  %.r80 = add i64 %.r63, 1
  store i64 %.r80, i64* %.p60
  ret void
}

define i1 @Diags__had_errors(%Diags* %self) {
entry:
  %__fld.0 = getelementptr inbounds %Diags, %Diags* %self, i32 0, i32 0
  %.p81 = getelementptr inbounds { i64, i64, %Diag* }, { i64, i64, %Diag* }* %__fld.0, i32 0, i32 0
  %.t1 = load i64, i64* %.p81
  %.t2 = icmp sgt i64 %.t1, 0
  ret i1 %.t2
}

define i1 @Diags__is_empty(%Diags* %self) {
entry:
  %__fld.0 = getelementptr inbounds %Diags, %Diags* %self, i32 0, i32 0
  %.p82 = getelementptr inbounds { i64, i64, %Diag* }, { i64, i64, %Diag* }* %__fld.0, i32 0, i32 0
  %.t1 = load i64, i64* %.p82
  %.t2 = icmp eq i64 %.t1, 0
  ret i1 %.t2
}

define void @Diags__extend(%Diags* %self, %Diags* %other) {
entry:
  %__for.idx.1 = alloca i64
  %__for.len.2 = alloca i64
  %d = alloca %Diag
  %__fld.0 = getelementptr inbounds %Diags, %Diags* %other, i32 0, i32 0
  store i64 0, i64* %__for.idx.1
  %.p83 = getelementptr inbounds { i64, i64, %Diag* }, { i64, i64, %Diag* }* %__fld.0, i32 0, i32 0
  %.t3 = load i64, i64* %.p83
  store i64 %.t3, i64* %__for.len.2
  br label %foreach_cond_0
foreach_cond_0:
  %.r84 = load i64, i64* %__for.idx.1
  %.r85 = load i64, i64* %__for.len.2
  %.t4 = icmp slt i64 %.r84, %.r85
  br i1 %.t4, label %foreach_body_1, label %foreach_end_3
foreach_body_1:
  %.r86 = load i64, i64* %__for.idx.1
  %.p87 = getelementptr inbounds { i64, i64, %Diag* }, { i64, i64, %Diag* }* %__fld.0, i32 0, i32 0
  %.r88 = load i64, i64* %.p87
  %.r89 = icmp slt i64 %.r86, 0
  %.r90 = icmp sge i64 %.r86, %.r88
  %.r91 = or i1 %.r89, %.r90
  br i1 %.r91, label %idx.fail.93, label %idx.ok.92
idx.fail.93:
  %.p94 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p94, i64 %.r86, i64 %.r88)
  call void @exit(i32 1)
  unreachable
idx.ok.92:
  %.p96 = getelementptr inbounds { i64, i64, %Diag* }, { i64, i64, %Diag* }* %__fld.0, i32 0, i32 2
  %.p95 = load %Diag*, %Diag** %.p96
  %.p97 = getelementptr inbounds %Diag, %Diag* %.p95, i64 %.r86
  %.t5 = load %Diag, %Diag* %.p97
  store %Diag %.t5, %Diag* %d
  %__fld.6 = getelementptr inbounds %Diags, %Diags* %self, i32 0, i32 0
  %.p98 = getelementptr %Diag, %Diag* null, i32 1
  %.r99 = ptrtoint %Diag* %.p98 to i64
  %.p100 = getelementptr inbounds { i64, i64, %Diag* }, { i64, i64, %Diag* }* %__fld.6, i32 0, i32 0
  %.p101 = getelementptr inbounds { i64, i64, %Diag* }, { i64, i64, %Diag* }* %__fld.6, i32 0, i32 1
  %.p102 = getelementptr inbounds { i64, i64, %Diag* }, { i64, i64, %Diag* }* %__fld.6, i32 0, i32 2
  %.r103 = load i64, i64* %.p100
  %.r104 = load i64, i64* %.p101
  %.r105 = icmp sge i64 %.r103, %.r104
  br i1 %.r105, label %append.grow.106, label %append.after.107
append.grow.106:
  %.r108 = load %Diag*, %Diag** %.p102
  %.r109 = icmp eq i64 %.r104, 0
  %.r110 = mul i64 %.r104, 2
  %.r111 = select i1 %.r109, i64 1, i64 %.r110
  %.r112 = mul i64 %.r111, %.r99
  %.p113 = call i8* @malloc(i64 %.r112)
  %.p114 = bitcast i8* %.p113 to %Diag*
  %.r115 = mul i64 %.r103, %.r99
  %.p116 = bitcast %Diag* %.r108 to i8*
  call i8* @memcpy(i8* %.p113, i8* %.p116, i64 %.r115)
  call void @free(i8* %.p116)
  store %Diag* %.p114, %Diag** %.p102
  store i64 %.r111, i64* %.p101
  br label %append.after.107
append.after.107:
  %.r117 = load %Diag*, %Diag** %.p102
  %.r118 = load %Diag, %Diag* %d
  %.p119 = getelementptr inbounds %Diag, %Diag* %.r117, i64 %.r103
  store %Diag %.r118, %Diag* %.p119
  %.r120 = add i64 %.r103, 1
  store i64 %.r120, i64* %.p100
  br label %foreach_step_2
foreach_step_2:
  %.r121 = load i64, i64* %__for.idx.1
  %.t7 = add i64 %.r121, 1
  store i64 %.t7, i64* %__for.idx.1
  br label %foreach_cond_0
foreach_end_3:
  ret void
}

define void @Diags__retag_file(%Diags* %self, i8* %filename.arg, i8* %source.arg) {
entry:
  %filename = alloca i8*
  %source = alloca i8*
  %i = alloca i64
  store i8* %filename.arg, i8** %filename
  store i8* %source.arg, i8** %source
  store i64 0, i64* %i
  br label %while_cond_0
while_cond_0:
  %__fld.0 = getelementptr inbounds %Diags, %Diags* %self, i32 0, i32 0
  %.p122 = getelementptr inbounds { i64, i64, %Diag* }, { i64, i64, %Diag* }* %__fld.0, i32 0, i32 0
  %.t1 = load i64, i64* %.p122
  %.r123 = load i64, i64* %i
  %.t2 = icmp slt i64 %.r123, %.t1
  br i1 %.t2, label %while_body_1, label %while_end_2
while_body_1:
  %__fld.3 = getelementptr inbounds %Diags, %Diags* %self, i32 0, i32 0
  %.r124 = load i64, i64* %i
  %.p125 = getelementptr inbounds { i64, i64, %Diag* }, { i64, i64, %Diag* }* %__fld.3, i32 0, i32 0
  %.r126 = load i64, i64* %.p125
  %.r127 = icmp slt i64 %.r124, 0
  %.r128 = icmp sge i64 %.r124, %.r126
  %.r129 = or i1 %.r127, %.r128
  br i1 %.r129, label %idx.fail.131, label %idx.ok.130
idx.fail.131:
  %.p132 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p132, i64 %.r124, i64 %.r126)
  call void @exit(i32 1)
  unreachable
idx.ok.130:
  %.p134 = getelementptr inbounds { i64, i64, %Diag* }, { i64, i64, %Diag* }* %__fld.3, i32 0, i32 2
  %.p133 = load %Diag*, %Diag** %.p134
  %.p135 = getelementptr inbounds %Diag, %Diag* %.p133, i64 %.r124
  %__elem.4 = bitcast %Diag* %.p135 to %Diag*
  %.p136 = getelementptr inbounds %Diag, %Diag* %__elem.4, i32 0, i32 7
  %.t5 = load i1, i1* %.p136
  %.t6 = xor i1 %.t5, true
  br i1 %.t6, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %__fld.7 = getelementptr inbounds %Diags, %Diags* %self, i32 0, i32 0
  %.r137 = load i64, i64* %i
  %.p138 = getelementptr inbounds { i64, i64, %Diag* }, { i64, i64, %Diag* }* %__fld.7, i32 0, i32 0
  %.r139 = load i64, i64* %.p138
  %.r140 = icmp slt i64 %.r137, 0
  %.r141 = icmp sge i64 %.r137, %.r139
  %.r142 = or i1 %.r140, %.r141
  br i1 %.r142, label %idx.fail.144, label %idx.ok.143
idx.fail.144:
  %.p145 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p145, i64 %.r137, i64 %.r139)
  call void @exit(i32 1)
  unreachable
idx.ok.143:
  %.p147 = getelementptr inbounds { i64, i64, %Diag* }, { i64, i64, %Diag* }* %__fld.7, i32 0, i32 2
  %.p146 = load %Diag*, %Diag** %.p147
  %.p148 = getelementptr inbounds %Diag, %Diag* %.p146, i64 %.r137
  %__elem.8 = bitcast %Diag* %.p148 to %Diag*
  %.r149 = load i8*, i8** %filename
  %.p150 = getelementptr inbounds %Diag, %Diag* %__elem.8, i32 0, i32 5
  store i8* %.r149, i8** %.p150
  %__fld.9 = getelementptr inbounds %Diags, %Diags* %self, i32 0, i32 0
  %.r151 = load i64, i64* %i
  %.p152 = getelementptr inbounds { i64, i64, %Diag* }, { i64, i64, %Diag* }* %__fld.9, i32 0, i32 0
  %.r153 = load i64, i64* %.p152
  %.r154 = icmp slt i64 %.r151, 0
  %.r155 = icmp sge i64 %.r151, %.r153
  %.r156 = or i1 %.r154, %.r155
  br i1 %.r156, label %idx.fail.158, label %idx.ok.157
idx.fail.158:
  %.p159 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p159, i64 %.r151, i64 %.r153)
  call void @exit(i32 1)
  unreachable
idx.ok.157:
  %.p161 = getelementptr inbounds { i64, i64, %Diag* }, { i64, i64, %Diag* }* %__fld.9, i32 0, i32 2
  %.p160 = load %Diag*, %Diag** %.p161
  %.p162 = getelementptr inbounds %Diag, %Diag* %.p160, i64 %.r151
  %__elem.10 = bitcast %Diag* %.p162 to %Diag*
  %.r163 = load i8*, i8** %source
  %.p164 = getelementptr inbounds %Diag, %Diag* %__elem.10, i32 0, i32 6
  store i8* %.r163, i8** %.p164
  %__fld.11 = getelementptr inbounds %Diags, %Diags* %self, i32 0, i32 0
  %.r165 = load i64, i64* %i
  %.p166 = getelementptr inbounds { i64, i64, %Diag* }, { i64, i64, %Diag* }* %__fld.11, i32 0, i32 0
  %.r167 = load i64, i64* %.p166
  %.r168 = icmp slt i64 %.r165, 0
  %.r169 = icmp sge i64 %.r165, %.r167
  %.r170 = or i1 %.r168, %.r169
  br i1 %.r170, label %idx.fail.172, label %idx.ok.171
idx.fail.172:
  %.p173 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p173, i64 %.r165, i64 %.r167)
  call void @exit(i32 1)
  unreachable
idx.ok.171:
  %.p175 = getelementptr inbounds { i64, i64, %Diag* }, { i64, i64, %Diag* }* %__fld.11, i32 0, i32 2
  %.p174 = load %Diag*, %Diag** %.p175
  %.p176 = getelementptr inbounds %Diag, %Diag* %.p174, i64 %.r165
  %__elem.12 = bitcast %Diag* %.p176 to %Diag*
  %.p177 = getelementptr inbounds %Diag, %Diag* %__elem.12, i32 0, i32 7
  store i1 true, i1* %.p177
  br label %if_end_3
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.r178 = load i64, i64* %i
  %.t13 = add i64 %.r178, 1
  store i64 %.t13, i64* %i
  br label %while_cond_0
while_end_2:
  ret void
}

define i64 @gutter_width(i64 %line_no.arg) {
entry:
  %line_no = alloca i64
  store i64 %line_no.arg, i64* %line_no
  %.r180 = load i64, i64* %line_no
  %.p179 = call i8* @malloc(i64 32)
  %.p181 = getelementptr inbounds [5 x i8], [5 x i8]* @.fmt.int.raw, i64 0, i64 0
  call i32 (i8*, i64, i8*, ...) @snprintf(i8* %.p179, i64 32, i8* %.p181, i64 %.r180)
  %.t0 = bitcast i8* %.p179 to i8*
  %.t1 = call i64 @strlen(i8* %.t0)
  ret i64 %.t1
}

define i8* @nth_line(i8* %source.arg, i64 %n.arg) {
entry:
  %source = alloca i8*
  %n = alloca i64
  %start = alloca i64
  %cur = alloca i64
  %i = alloca i64
  %total = alloca i64
  %__sc.2 = alloca i1
  %end = alloca i64
  %__sc.7 = alloca i1
  store i8* %source.arg, i8** %source
  store i64 %n.arg, i64* %n
  store i64 0, i64* %start
  store i64 0, i64* %cur
  store i64 0, i64* %i
  %.r182 = load i8*, i8** %source
  %.t0 = call i64 @strlen(i8* %.r182)
  store i64 %.t0, i64* %total
  br label %while_cond_0
while_cond_0:
  %.r183 = load i64, i64* %i
  %.r184 = load i64, i64* %total
  %.t1 = icmp sle i64 %.r183, %.r184
  br i1 %.t1, label %while_body_1, label %while_end_2
while_body_1:
  %.r185 = load i64, i64* %i
  %.r186 = load i64, i64* %total
  %.t3 = icmp eq i64 %.r185, %.r186
  br i1 %.t3, label %sc_short_7, label %sc_rhs_6
sc_rhs_6:
  %.r187 = load i8*, i8** %source
  %.r188 = load i64, i64* %i
  %.p189 = getelementptr inbounds i8, i8* %.r187, i64 %.r188
  %.r190 = load i8, i8* %.p189
  %.t4 = zext i8 %.r190 to i64
  %.t5 = icmp eq i64 %.t4, 10
  store i1 %.t5, i1* %__sc.2
  br label %sc_end_8
sc_short_7:
  store i1 true, i1* %__sc.2
  br label %sc_end_8
sc_end_8:
  %.r191 = load i1, i1* %__sc.2
  br i1 %.r191, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.r192 = load i64, i64* %cur
  %.r193 = load i64, i64* %n
  %.t6 = icmp eq i64 %.r192, %.r193
  br i1 %.t6, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.r194 = load i64, i64* %i
  store i64 %.r194, i64* %end
  %.r195 = load i64, i64* %end
  %.r196 = load i64, i64* %start
  %.t8 = icmp sgt i64 %.r195, %.r196
  br i1 %.t8, label %sc_rhs_15, label %sc_short_16
sc_rhs_15:
  %.r197 = load i64, i64* %end
  %.t9 = sub i64 %.r197, 1
  %.r198 = load i8*, i8** %source
  %.p199 = getelementptr inbounds i8, i8* %.r198, i64 %.t9
  %.r200 = load i8, i8* %.p199
  %.t10 = zext i8 %.r200 to i64
  %.t11 = icmp eq i64 %.t10, 13
  store i1 %.t11, i1* %__sc.7
  br label %sc_end_17
sc_short_16:
  store i1 false, i1* %__sc.7
  br label %sc_end_17
sc_end_17:
  %.r201 = load i1, i1* %__sc.7
  br i1 %.r201, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  %.r202 = load i64, i64* %end
  %.t12 = sub i64 %.r202, 1
  store i64 %.t12, i64* %end
  br label %if_end_12
if_next_0_14:
  br label %if_end_12
if_end_12:
  %.r203 = load i8*, i8** %source
  %.r204 = load i64, i64* %start
  %.r205 = load i64, i64* %end
  %.r206 = sub i64 %.r205, %.r204
  %.r207 = add i64 %.r206, 1
  %.p208 = call i8* @malloc(i64 %.r207)
  %.p209 = getelementptr inbounds i8, i8* %.r203, i64 %.r204
  call i8* @memcpy(i8* %.p208, i8* %.p209, i64 %.r206)
  %.p210 = getelementptr inbounds i8, i8* %.p208, i64 %.r206
  store i8 0, i8* %.p210
  %.t13 = bitcast i8* %.p208 to i8*
  ret i8* %.t13
if_next_0_11:
  br label %if_end_9
if_end_9:
  %.r211 = load i64, i64* %cur
  %.t14 = add i64 %.r211, 1
  store i64 %.t14, i64* %cur
  %.r212 = load i64, i64* %i
  %.t15 = add i64 %.r212, 1
  store i64 %.t15, i64* %start
  br label %if_end_3
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.r213 = load i64, i64* %i
  %.t16 = add i64 %.r213, 1
  store i64 %.t16, i64* %i
  br label %while_cond_0
while_end_2:
  %.p214 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  ret i8* %.p214
}

define i8* @render_diag(%Diag* %d, i8* %default_file.arg, i8* %default_source.arg) {
entry:
  %default_file = alloca i8*
  %default_source = alloca i8*
  %filename = alloca i8*
  %source = alloca i8*
  %out = alloca i8*
  %line_no = alloca i64
  %gutter = alloca i64
  %pad = alloca i8*
  %src_line = alloca i8*
  %col = alloca i64
  %width = alloca i64
  %room = alloca i64
  %carets = alloca i8*
  %pointer = alloca i8*
  store i8* %default_file.arg, i8** %default_file
  store i8* %default_source.arg, i8** %default_source
  %.r215 = load i8*, i8** %default_file
  store i8* %.r215, i8** %filename
  %.r216 = load i8*, i8** %default_source
  store i8* %.r216, i8** %source
  %.p217 = getelementptr inbounds %Diag, %Diag* %d, i32 0, i32 7
  %.t0 = load i1, i1* %.p217
  br i1 %.t0, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.p218 = getelementptr inbounds %Diag, %Diag* %d, i32 0, i32 5
  %.t1 = load i8*, i8** %.p218
  store i8* %.t1, i8** %filename
  %.p219 = getelementptr inbounds %Diag, %Diag* %d, i32 0, i32 6
  %.t2 = load i8*, i8** %.p219
  store i8* %.t2, i8** %source
  br label %if_end_0
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.p220 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.2, i64 0, i64 0
  store i8* %.p220, i8** %out
  %.p221 = getelementptr inbounds %Diag, %Diag* %d, i32 0, i32 0
  %.t3 = load i8*, i8** %.p221
  %.t4 = call i64 @strlen(i8* %.t3)
  %.t5 = icmp sgt i64 %.t4, 0
  br i1 %.t5, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.r222 = load i8*, i8** %out
  %.p223 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.3, i64 0, i64 0
  %.r224 = call i64 @strlen(i8* %.r222)
  %.r225 = call i64 @strlen(i8* %.p223)
  %.r226 = add i64 %.r224, %.r225
  %.r227 = add i64 %.r226, 1
  %.t6 = call i8* @malloc(i64 %.r227)
  call i8* @memcpy(i8* %.t6, i8* %.r222, i64 %.r224)
  %.p228 = getelementptr inbounds i8, i8* %.t6, i64 %.r224
  call i8* @memcpy(i8* %.p228, i8* %.p223, i64 %.r225)
  %.p229 = getelementptr inbounds i8, i8* %.t6, i64 %.r226
  store i8 0, i8* %.p229
  %.p230 = getelementptr inbounds %Diag, %Diag* %d, i32 0, i32 0
  %.t7 = load i8*, i8** %.p230
  %.r231 = call i64 @strlen(i8* %.t6)
  %.r232 = call i64 @strlen(i8* %.t7)
  %.r233 = add i64 %.r231, %.r232
  %.r234 = add i64 %.r233, 1
  %.t8 = call i8* @malloc(i64 %.r234)
  call i8* @memcpy(i8* %.t8, i8* %.t6, i64 %.r231)
  %.p235 = getelementptr inbounds i8, i8* %.t8, i64 %.r231
  call i8* @memcpy(i8* %.p235, i8* %.t7, i64 %.r232)
  %.p236 = getelementptr inbounds i8, i8* %.t8, i64 %.r233
  store i8 0, i8* %.p236
  %.p237 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.4, i64 0, i64 0
  %.r238 = call i64 @strlen(i8* %.t8)
  %.r239 = call i64 @strlen(i8* %.p237)
  %.r240 = add i64 %.r238, %.r239
  %.r241 = add i64 %.r240, 1
  %.t9 = call i8* @malloc(i64 %.r241)
  call i8* @memcpy(i8* %.t9, i8* %.t8, i64 %.r238)
  %.p242 = getelementptr inbounds i8, i8* %.t9, i64 %.r238
  call i8* @memcpy(i8* %.p242, i8* %.p237, i64 %.r239)
  %.p243 = getelementptr inbounds i8, i8* %.t9, i64 %.r240
  store i8 0, i8* %.p243
  store i8* %.t9, i8** %out
  br label %if_end_3
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.r244 = load i8*, i8** %out
  %.p245 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.5, i64 0, i64 0
  %.r246 = call i64 @strlen(i8* %.r244)
  %.r247 = call i64 @strlen(i8* %.p245)
  %.r248 = add i64 %.r246, %.r247
  %.r249 = add i64 %.r248, 1
  %.t10 = call i8* @malloc(i64 %.r249)
  call i8* @memcpy(i8* %.t10, i8* %.r244, i64 %.r246)
  %.p250 = getelementptr inbounds i8, i8* %.t10, i64 %.r246
  call i8* @memcpy(i8* %.p250, i8* %.p245, i64 %.r247)
  %.p251 = getelementptr inbounds i8, i8* %.t10, i64 %.r248
  store i8 0, i8* %.p251
  %.p252 = getelementptr inbounds %Diag, %Diag* %d, i32 0, i32 1
  %.t11 = load i8*, i8** %.p252
  %.r253 = call i64 @strlen(i8* %.t10)
  %.r254 = call i64 @strlen(i8* %.t11)
  %.r255 = add i64 %.r253, %.r254
  %.r256 = add i64 %.r255, 1
  %.t12 = call i8* @malloc(i64 %.r256)
  call i8* @memcpy(i8* %.t12, i8* %.t10, i64 %.r253)
  %.p257 = getelementptr inbounds i8, i8* %.t12, i64 %.r253
  call i8* @memcpy(i8* %.p257, i8* %.t11, i64 %.r254)
  %.p258 = getelementptr inbounds i8, i8* %.t12, i64 %.r255
  store i8 0, i8* %.p258
  %.p259 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.0, i64 0, i64 0
  %.r260 = call i64 @strlen(i8* %.t12)
  %.r261 = call i64 @strlen(i8* %.p259)
  %.r262 = add i64 %.r260, %.r261
  %.r263 = add i64 %.r262, 1
  %.t13 = call i8* @malloc(i64 %.r263)
  call i8* @memcpy(i8* %.t13, i8* %.t12, i64 %.r260)
  %.p264 = getelementptr inbounds i8, i8* %.t13, i64 %.r260
  call i8* @memcpy(i8* %.p264, i8* %.p259, i64 %.r261)
  %.p265 = getelementptr inbounds i8, i8* %.t13, i64 %.r262
  store i8 0, i8* %.p265
  store i8* %.t13, i8** %out
  %__fld.14 = getelementptr inbounds %Diag, %Diag* %d, i32 0, i32 2
  %.p266 = getelementptr inbounds %Span, %Span* %__fld.14, i32 0, i32 2
  %.t15 = load i64, i64* %.p266
  %.t16 = call i64 @max(i64 %.t15, i64 1)
  store i64 %.t16, i64* %line_no
  %.r267 = load i64, i64* %line_no
  %.t17 = call i64 @gutter_width(i64 %.r267)
  store i64 %.t17, i64* %gutter
  %.p268 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.6, i64 0, i64 0
  %.r269 = load i64, i64* %gutter
  %.t18 = call i8* @repeat(i8* %.p268, i64 %.r269)
  store i8* %.t18, i8** %pad
  %.r270 = load i8*, i8** %out
  %.r271 = load i8*, i8** %pad
  %.r272 = call i64 @strlen(i8* %.r270)
  %.r273 = call i64 @strlen(i8* %.r271)
  %.r274 = add i64 %.r272, %.r273
  %.r275 = add i64 %.r274, 1
  %.t19 = call i8* @malloc(i64 %.r275)
  call i8* @memcpy(i8* %.t19, i8* %.r270, i64 %.r272)
  %.p276 = getelementptr inbounds i8, i8* %.t19, i64 %.r272
  call i8* @memcpy(i8* %.p276, i8* %.r271, i64 %.r273)
  %.p277 = getelementptr inbounds i8, i8* %.t19, i64 %.r274
  store i8 0, i8* %.p277
  %.p278 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.7, i64 0, i64 0
  %.r279 = call i64 @strlen(i8* %.t19)
  %.r280 = call i64 @strlen(i8* %.p278)
  %.r281 = add i64 %.r279, %.r280
  %.r282 = add i64 %.r281, 1
  %.t20 = call i8* @malloc(i64 %.r282)
  call i8* @memcpy(i8* %.t20, i8* %.t19, i64 %.r279)
  %.p283 = getelementptr inbounds i8, i8* %.t20, i64 %.r279
  call i8* @memcpy(i8* %.p283, i8* %.p278, i64 %.r280)
  %.p284 = getelementptr inbounds i8, i8* %.t20, i64 %.r281
  store i8 0, i8* %.p284
  %.r285 = load i8*, i8** %filename
  %.r286 = call i64 @strlen(i8* %.t20)
  %.r287 = call i64 @strlen(i8* %.r285)
  %.r288 = add i64 %.r286, %.r287
  %.r289 = add i64 %.r288, 1
  %.t21 = call i8* @malloc(i64 %.r289)
  call i8* @memcpy(i8* %.t21, i8* %.t20, i64 %.r286)
  %.p290 = getelementptr inbounds i8, i8* %.t21, i64 %.r286
  call i8* @memcpy(i8* %.p290, i8* %.r285, i64 %.r287)
  %.p291 = getelementptr inbounds i8, i8* %.t21, i64 %.r288
  store i8 0, i8* %.p291
  %.p292 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.8, i64 0, i64 0
  %.r293 = call i64 @strlen(i8* %.t21)
  %.r294 = call i64 @strlen(i8* %.p292)
  %.r295 = add i64 %.r293, %.r294
  %.r296 = add i64 %.r295, 1
  %.t22 = call i8* @malloc(i64 %.r296)
  call i8* @memcpy(i8* %.t22, i8* %.t21, i64 %.r293)
  %.p297 = getelementptr inbounds i8, i8* %.t22, i64 %.r293
  call i8* @memcpy(i8* %.p297, i8* %.p292, i64 %.r294)
  %.p298 = getelementptr inbounds i8, i8* %.t22, i64 %.r295
  store i8 0, i8* %.p298
  %.r300 = load i64, i64* %line_no
  %.p299 = call i8* @malloc(i64 32)
  %.p301 = getelementptr inbounds [5 x i8], [5 x i8]* @.fmt.int.raw, i64 0, i64 0
  call i32 (i8*, i64, i8*, ...) @snprintf(i8* %.p299, i64 32, i8* %.p301, i64 %.r300)
  %.t23 = bitcast i8* %.p299 to i8*
  %.r302 = call i64 @strlen(i8* %.t22)
  %.r303 = call i64 @strlen(i8* %.t23)
  %.r304 = add i64 %.r302, %.r303
  %.r305 = add i64 %.r304, 1
  %.t24 = call i8* @malloc(i64 %.r305)
  call i8* @memcpy(i8* %.t24, i8* %.t22, i64 %.r302)
  %.p306 = getelementptr inbounds i8, i8* %.t24, i64 %.r302
  call i8* @memcpy(i8* %.p306, i8* %.t23, i64 %.r303)
  %.p307 = getelementptr inbounds i8, i8* %.t24, i64 %.r304
  store i8 0, i8* %.p307
  %.p308 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.8, i64 0, i64 0
  %.r309 = call i64 @strlen(i8* %.t24)
  %.r310 = call i64 @strlen(i8* %.p308)
  %.r311 = add i64 %.r309, %.r310
  %.r312 = add i64 %.r311, 1
  %.t25 = call i8* @malloc(i64 %.r312)
  call i8* @memcpy(i8* %.t25, i8* %.t24, i64 %.r309)
  %.p313 = getelementptr inbounds i8, i8* %.t25, i64 %.r309
  call i8* @memcpy(i8* %.p313, i8* %.p308, i64 %.r310)
  %.p314 = getelementptr inbounds i8, i8* %.t25, i64 %.r311
  store i8 0, i8* %.p314
  %__fld.26 = getelementptr inbounds %Diag, %Diag* %d, i32 0, i32 2
  %.p315 = getelementptr inbounds %Span, %Span* %__fld.26, i32 0, i32 3
  %.t27 = load i64, i64* %.p315
  %.p316 = call i8* @malloc(i64 32)
  %.p317 = getelementptr inbounds [5 x i8], [5 x i8]* @.fmt.int.raw, i64 0, i64 0
  call i32 (i8*, i64, i8*, ...) @snprintf(i8* %.p316, i64 32, i8* %.p317, i64 %.t27)
  %.t28 = bitcast i8* %.p316 to i8*
  %.r318 = call i64 @strlen(i8* %.t25)
  %.r319 = call i64 @strlen(i8* %.t28)
  %.r320 = add i64 %.r318, %.r319
  %.r321 = add i64 %.r320, 1
  %.t29 = call i8* @malloc(i64 %.r321)
  call i8* @memcpy(i8* %.t29, i8* %.t25, i64 %.r318)
  %.p322 = getelementptr inbounds i8, i8* %.t29, i64 %.r318
  call i8* @memcpy(i8* %.p322, i8* %.t28, i64 %.r319)
  %.p323 = getelementptr inbounds i8, i8* %.t29, i64 %.r320
  store i8 0, i8* %.p323
  %.p324 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.0, i64 0, i64 0
  %.r325 = call i64 @strlen(i8* %.t29)
  %.r326 = call i64 @strlen(i8* %.p324)
  %.r327 = add i64 %.r325, %.r326
  %.r328 = add i64 %.r327, 1
  %.t30 = call i8* @malloc(i64 %.r328)
  call i8* @memcpy(i8* %.t30, i8* %.t29, i64 %.r325)
  %.p329 = getelementptr inbounds i8, i8* %.t30, i64 %.r325
  call i8* @memcpy(i8* %.p329, i8* %.p324, i64 %.r326)
  %.p330 = getelementptr inbounds i8, i8* %.t30, i64 %.r327
  store i8 0, i8* %.p330
  store i8* %.t30, i8** %out
  %.r331 = load i8*, i8** %out
  %.r332 = load i8*, i8** %pad
  %.r333 = call i64 @strlen(i8* %.r331)
  %.r334 = call i64 @strlen(i8* %.r332)
  %.r335 = add i64 %.r333, %.r334
  %.r336 = add i64 %.r335, 1
  %.t31 = call i8* @malloc(i64 %.r336)
  call i8* @memcpy(i8* %.t31, i8* %.r331, i64 %.r333)
  %.p337 = getelementptr inbounds i8, i8* %.t31, i64 %.r333
  call i8* @memcpy(i8* %.p337, i8* %.r332, i64 %.r334)
  %.p338 = getelementptr inbounds i8, i8* %.t31, i64 %.r335
  store i8 0, i8* %.p338
  %.p339 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.9, i64 0, i64 0
  %.r340 = call i64 @strlen(i8* %.t31)
  %.r341 = call i64 @strlen(i8* %.p339)
  %.r342 = add i64 %.r340, %.r341
  %.r343 = add i64 %.r342, 1
  %.t32 = call i8* @malloc(i64 %.r343)
  call i8* @memcpy(i8* %.t32, i8* %.t31, i64 %.r340)
  %.p344 = getelementptr inbounds i8, i8* %.t32, i64 %.r340
  call i8* @memcpy(i8* %.p344, i8* %.p339, i64 %.r341)
  %.p345 = getelementptr inbounds i8, i8* %.t32, i64 %.r342
  store i8 0, i8* %.p345
  store i8* %.t32, i8** %out
  %.r346 = load i64, i64* %line_no
  %.t33 = sub i64 %.r346, 1
  %.r347 = load i8*, i8** %source
  %.t34 = call i8* @nth_line(i8* %.r347, i64 %.t33)
  store i8* %.t34, i8** %src_line
  %.r348 = load i64, i64* %line_no
  %.t35 = sub i64 %.r348, 1
  %.r349 = load i8*, i8** %source
  %.t36 = call i64 @count_lines(i8* %.r349)
  %.t37 = icmp slt i64 %.t35, %.t36
  br i1 %.t37, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.r351 = load i64, i64* %line_no
  %.p350 = call i8* @malloc(i64 32)
  %.p352 = getelementptr inbounds [5 x i8], [5 x i8]* @.fmt.int.raw, i64 0, i64 0
  call i32 (i8*, i64, i8*, ...) @snprintf(i8* %.p350, i64 32, i8* %.p352, i64 %.r351)
  %.t38 = bitcast i8* %.p350 to i8*
  %.r353 = load i8*, i8** %out
  %.r354 = call i64 @strlen(i8* %.r353)
  %.r355 = call i64 @strlen(i8* %.t38)
  %.r356 = add i64 %.r354, %.r355
  %.r357 = add i64 %.r356, 1
  %.t39 = call i8* @malloc(i64 %.r357)
  call i8* @memcpy(i8* %.t39, i8* %.r353, i64 %.r354)
  %.p358 = getelementptr inbounds i8, i8* %.t39, i64 %.r354
  call i8* @memcpy(i8* %.p358, i8* %.t38, i64 %.r355)
  %.p359 = getelementptr inbounds i8, i8* %.t39, i64 %.r356
  store i8 0, i8* %.p359
  %.p360 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.10, i64 0, i64 0
  %.r361 = call i64 @strlen(i8* %.t39)
  %.r362 = call i64 @strlen(i8* %.p360)
  %.r363 = add i64 %.r361, %.r362
  %.r364 = add i64 %.r363, 1
  %.t40 = call i8* @malloc(i64 %.r364)
  call i8* @memcpy(i8* %.t40, i8* %.t39, i64 %.r361)
  %.p365 = getelementptr inbounds i8, i8* %.t40, i64 %.r361
  call i8* @memcpy(i8* %.p365, i8* %.p360, i64 %.r362)
  %.p366 = getelementptr inbounds i8, i8* %.t40, i64 %.r363
  store i8 0, i8* %.p366
  %.r367 = load i8*, i8** %src_line
  %.r368 = call i64 @strlen(i8* %.t40)
  %.r369 = call i64 @strlen(i8* %.r367)
  %.r370 = add i64 %.r368, %.r369
  %.r371 = add i64 %.r370, 1
  %.t41 = call i8* @malloc(i64 %.r371)
  call i8* @memcpy(i8* %.t41, i8* %.t40, i64 %.r368)
  %.p372 = getelementptr inbounds i8, i8* %.t41, i64 %.r368
  call i8* @memcpy(i8* %.p372, i8* %.r367, i64 %.r369)
  %.p373 = getelementptr inbounds i8, i8* %.t41, i64 %.r370
  store i8 0, i8* %.p373
  %.p374 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.0, i64 0, i64 0
  %.r375 = call i64 @strlen(i8* %.t41)
  %.r376 = call i64 @strlen(i8* %.p374)
  %.r377 = add i64 %.r375, %.r376
  %.r378 = add i64 %.r377, 1
  %.t42 = call i8* @malloc(i64 %.r378)
  call i8* @memcpy(i8* %.t42, i8* %.t41, i64 %.r375)
  %.p379 = getelementptr inbounds i8, i8* %.t42, i64 %.r375
  call i8* @memcpy(i8* %.p379, i8* %.p374, i64 %.r376)
  %.p380 = getelementptr inbounds i8, i8* %.t42, i64 %.r377
  store i8 0, i8* %.p380
  store i8* %.t42, i8** %out
  %__fld.43 = getelementptr inbounds %Diag, %Diag* %d, i32 0, i32 2
  %.p381 = getelementptr inbounds %Span, %Span* %__fld.43, i32 0, i32 3
  %.t44 = load i64, i64* %.p381
  %.t45 = sub i64 %.t44, 1
  %.t46 = call i64 @max(i64 %.t45, i64 0)
  store i64 %.t46, i64* %col
  %__fld.47 = getelementptr inbounds %Diag, %Diag* %d, i32 0, i32 2
  %.p382 = getelementptr inbounds %Span, %Span* %__fld.47, i32 0, i32 1
  %.t48 = load i64, i64* %.p382
  %__fld.49 = getelementptr inbounds %Diag, %Diag* %d, i32 0, i32 2
  %.p383 = getelementptr inbounds %Span, %Span* %__fld.49, i32 0, i32 0
  %.t50 = load i64, i64* %.p383
  %.t51 = sub i64 %.t48, %.t50
  %.t52 = call i64 @max(i64 %.t51, i64 1)
  store i64 %.t52, i64* %width
  %.r384 = load i8*, i8** %src_line
  %.t53 = call i64 @strlen(i8* %.r384)
  %.r385 = load i64, i64* %col
  %.t54 = sub i64 %.t53, %.r385
  %.t55 = call i64 @max(i64 %.t54, i64 1)
  store i64 %.t55, i64* %room
  %.r386 = load i64, i64* %width
  %.r387 = load i64, i64* %room
  %.t56 = call i64 @min(i64 %.r386, i64 %.r387)
  %.p388 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.11, i64 0, i64 0
  %.t57 = call i8* @repeat(i8* %.p388, i64 %.t56)
  store i8* %.t57, i8** %carets
  %.r389 = load i8*, i8** %pad
  %.p390 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.10, i64 0, i64 0
  %.r391 = call i64 @strlen(i8* %.r389)
  %.r392 = call i64 @strlen(i8* %.p390)
  %.r393 = add i64 %.r391, %.r392
  %.r394 = add i64 %.r393, 1
  %.t58 = call i8* @malloc(i64 %.r394)
  call i8* @memcpy(i8* %.t58, i8* %.r389, i64 %.r391)
  %.p395 = getelementptr inbounds i8, i8* %.t58, i64 %.r391
  call i8* @memcpy(i8* %.p395, i8* %.p390, i64 %.r392)
  %.p396 = getelementptr inbounds i8, i8* %.t58, i64 %.r393
  store i8 0, i8* %.p396
  %.p397 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.6, i64 0, i64 0
  %.r398 = load i64, i64* %col
  %.t59 = call i8* @repeat(i8* %.p397, i64 %.r398)
  %.r399 = call i64 @strlen(i8* %.t58)
  %.r400 = call i64 @strlen(i8* %.t59)
  %.r401 = add i64 %.r399, %.r400
  %.r402 = add i64 %.r401, 1
  %.t60 = call i8* @malloc(i64 %.r402)
  call i8* @memcpy(i8* %.t60, i8* %.t58, i64 %.r399)
  %.p403 = getelementptr inbounds i8, i8* %.t60, i64 %.r399
  call i8* @memcpy(i8* %.p403, i8* %.t59, i64 %.r400)
  %.p404 = getelementptr inbounds i8, i8* %.t60, i64 %.r401
  store i8 0, i8* %.p404
  %.r405 = load i8*, i8** %carets
  %.r406 = call i64 @strlen(i8* %.t60)
  %.r407 = call i64 @strlen(i8* %.r405)
  %.r408 = add i64 %.r406, %.r407
  %.r409 = add i64 %.r408, 1
  %.t61 = call i8* @malloc(i64 %.r409)
  call i8* @memcpy(i8* %.t61, i8* %.t60, i64 %.r406)
  %.p410 = getelementptr inbounds i8, i8* %.t61, i64 %.r406
  call i8* @memcpy(i8* %.p410, i8* %.r405, i64 %.r407)
  %.p411 = getelementptr inbounds i8, i8* %.t61, i64 %.r408
  store i8 0, i8* %.p411
  store i8* %.t61, i8** %pointer
  %.p412 = getelementptr inbounds %Diag, %Diag* %d, i32 0, i32 3
  %.t62 = load i8*, i8** %.p412
  %.t63 = call i64 @strlen(i8* %.t62)
  %.t64 = icmp sgt i64 %.t63, 0
  br i1 %.t64, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.r413 = load i8*, i8** %pointer
  %.p414 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.6, i64 0, i64 0
  %.r415 = call i64 @strlen(i8* %.r413)
  %.r416 = call i64 @strlen(i8* %.p414)
  %.r417 = add i64 %.r415, %.r416
  %.r418 = add i64 %.r417, 1
  %.t65 = call i8* @malloc(i64 %.r418)
  call i8* @memcpy(i8* %.t65, i8* %.r413, i64 %.r415)
  %.p419 = getelementptr inbounds i8, i8* %.t65, i64 %.r415
  call i8* @memcpy(i8* %.p419, i8* %.p414, i64 %.r416)
  %.p420 = getelementptr inbounds i8, i8* %.t65, i64 %.r417
  store i8 0, i8* %.p420
  %.p421 = getelementptr inbounds %Diag, %Diag* %d, i32 0, i32 3
  %.t66 = load i8*, i8** %.p421
  %.r422 = call i64 @strlen(i8* %.t65)
  %.r423 = call i64 @strlen(i8* %.t66)
  %.r424 = add i64 %.r422, %.r423
  %.r425 = add i64 %.r424, 1
  %.t67 = call i8* @malloc(i64 %.r425)
  call i8* @memcpy(i8* %.t67, i8* %.t65, i64 %.r422)
  %.p426 = getelementptr inbounds i8, i8* %.t67, i64 %.r422
  call i8* @memcpy(i8* %.p426, i8* %.t66, i64 %.r423)
  %.p427 = getelementptr inbounds i8, i8* %.t67, i64 %.r424
  store i8 0, i8* %.p427
  store i8* %.t67, i8** %pointer
  br label %if_end_9
if_next_0_11:
  br label %if_end_9
if_end_9:
  %.r428 = load i8*, i8** %out
  %.r429 = load i8*, i8** %pointer
  %.r430 = call i64 @strlen(i8* %.r428)
  %.r431 = call i64 @strlen(i8* %.r429)
  %.r432 = add i64 %.r430, %.r431
  %.r433 = add i64 %.r432, 1
  %.t68 = call i8* @malloc(i64 %.r433)
  call i8* @memcpy(i8* %.t68, i8* %.r428, i64 %.r430)
  %.p434 = getelementptr inbounds i8, i8* %.t68, i64 %.r430
  call i8* @memcpy(i8* %.p434, i8* %.r429, i64 %.r431)
  %.p435 = getelementptr inbounds i8, i8* %.t68, i64 %.r432
  store i8 0, i8* %.p435
  %.p436 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.0, i64 0, i64 0
  %.r437 = call i64 @strlen(i8* %.t68)
  %.r438 = call i64 @strlen(i8* %.p436)
  %.r439 = add i64 %.r437, %.r438
  %.r440 = add i64 %.r439, 1
  %.t69 = call i8* @malloc(i64 %.r440)
  call i8* @memcpy(i8* %.t69, i8* %.t68, i64 %.r437)
  %.p441 = getelementptr inbounds i8, i8* %.t69, i64 %.r437
  call i8* @memcpy(i8* %.p441, i8* %.p436, i64 %.r438)
  %.p442 = getelementptr inbounds i8, i8* %.t69, i64 %.r439
  store i8 0, i8* %.p442
  store i8* %.t69, i8** %out
  br label %if_end_6
if_next_0_8:
  br label %if_end_6
if_end_6:
  %.r443 = load i8*, i8** %out
  %.r444 = load i8*, i8** %pad
  %.r445 = call i64 @strlen(i8* %.r443)
  %.r446 = call i64 @strlen(i8* %.r444)
  %.r447 = add i64 %.r445, %.r446
  %.r448 = add i64 %.r447, 1
  %.t70 = call i8* @malloc(i64 %.r448)
  call i8* @memcpy(i8* %.t70, i8* %.r443, i64 %.r445)
  %.p449 = getelementptr inbounds i8, i8* %.t70, i64 %.r445
  call i8* @memcpy(i8* %.p449, i8* %.r444, i64 %.r446)
  %.p450 = getelementptr inbounds i8, i8* %.t70, i64 %.r447
  store i8 0, i8* %.p450
  %.p451 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.9, i64 0, i64 0
  %.r452 = call i64 @strlen(i8* %.t70)
  %.r453 = call i64 @strlen(i8* %.p451)
  %.r454 = add i64 %.r452, %.r453
  %.r455 = add i64 %.r454, 1
  %.t71 = call i8* @malloc(i64 %.r455)
  call i8* @memcpy(i8* %.t71, i8* %.t70, i64 %.r452)
  %.p456 = getelementptr inbounds i8, i8* %.t71, i64 %.r452
  call i8* @memcpy(i8* %.p456, i8* %.p451, i64 %.r453)
  %.p457 = getelementptr inbounds i8, i8* %.t71, i64 %.r454
  store i8 0, i8* %.p457
  store i8* %.t71, i8** %out
  %.p458 = getelementptr inbounds %Diag, %Diag* %d, i32 0, i32 4
  %.t72 = load i8*, i8** %.p458
  %.t73 = call i64 @strlen(i8* %.t72)
  %.t74 = icmp sgt i64 %.t73, 0
  br i1 %.t74, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  %.r459 = load i8*, i8** %out
  %.r460 = load i8*, i8** %pad
  %.r461 = call i64 @strlen(i8* %.r459)
  %.r462 = call i64 @strlen(i8* %.r460)
  %.r463 = add i64 %.r461, %.r462
  %.r464 = add i64 %.r463, 1
  %.t75 = call i8* @malloc(i64 %.r464)
  call i8* @memcpy(i8* %.t75, i8* %.r459, i64 %.r461)
  %.p465 = getelementptr inbounds i8, i8* %.t75, i64 %.r461
  call i8* @memcpy(i8* %.p465, i8* %.r460, i64 %.r462)
  %.p466 = getelementptr inbounds i8, i8* %.t75, i64 %.r463
  store i8 0, i8* %.p466
  %.p467 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.12, i64 0, i64 0
  %.r468 = call i64 @strlen(i8* %.t75)
  %.r469 = call i64 @strlen(i8* %.p467)
  %.r470 = add i64 %.r468, %.r469
  %.r471 = add i64 %.r470, 1
  %.t76 = call i8* @malloc(i64 %.r471)
  call i8* @memcpy(i8* %.t76, i8* %.t75, i64 %.r468)
  %.p472 = getelementptr inbounds i8, i8* %.t76, i64 %.r468
  call i8* @memcpy(i8* %.p472, i8* %.p467, i64 %.r469)
  %.p473 = getelementptr inbounds i8, i8* %.t76, i64 %.r470
  store i8 0, i8* %.p473
  %.p474 = getelementptr inbounds %Diag, %Diag* %d, i32 0, i32 4
  %.t77 = load i8*, i8** %.p474
  %.r475 = call i64 @strlen(i8* %.t76)
  %.r476 = call i64 @strlen(i8* %.t77)
  %.r477 = add i64 %.r475, %.r476
  %.r478 = add i64 %.r477, 1
  %.t78 = call i8* @malloc(i64 %.r478)
  call i8* @memcpy(i8* %.t78, i8* %.t76, i64 %.r475)
  %.p479 = getelementptr inbounds i8, i8* %.t78, i64 %.r475
  call i8* @memcpy(i8* %.p479, i8* %.t77, i64 %.r476)
  %.p480 = getelementptr inbounds i8, i8* %.t78, i64 %.r477
  store i8 0, i8* %.p480
  %.p481 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.0, i64 0, i64 0
  %.r482 = call i64 @strlen(i8* %.t78)
  %.r483 = call i64 @strlen(i8* %.p481)
  %.r484 = add i64 %.r482, %.r483
  %.r485 = add i64 %.r484, 1
  %.t79 = call i8* @malloc(i64 %.r485)
  call i8* @memcpy(i8* %.t79, i8* %.t78, i64 %.r482)
  %.p486 = getelementptr inbounds i8, i8* %.t79, i64 %.r482
  call i8* @memcpy(i8* %.p486, i8* %.p481, i64 %.r483)
  %.p487 = getelementptr inbounds i8, i8* %.t79, i64 %.r484
  store i8 0, i8* %.p487
  store i8* %.t79, i8** %out
  br label %if_end_12
if_next_0_14:
  br label %if_end_12
if_end_12:
  %.t80 = load i8*, i8** %out
  ret i8* %.t80
}

define i64 @count_lines(i8* %source.arg) {
entry:
  %source = alloca i8*
  %n = alloca i64
  %i = alloca i64
  %__sc.4 = alloca i1
  store i8* %source.arg, i8** %source
  %.r488 = load i8*, i8** %source
  %.t0 = call i64 @strlen(i8* %.r488)
  %.t1 = icmp eq i64 %.t0, 0
  br i1 %.t1, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  ret i64 0
if_next_0_2:
  br label %if_end_0
if_end_0:
  store i64 1, i64* %n
  store i64 0, i64* %i
  br label %while_cond_3
while_cond_3:
  %.r489 = load i8*, i8** %source
  %.t2 = call i64 @strlen(i8* %.r489)
  %.r490 = load i64, i64* %i
  %.t3 = icmp slt i64 %.r490, %.t2
  br i1 %.t3, label %while_body_4, label %while_end_5
while_body_4:
  %.r491 = load i8*, i8** %source
  %.r492 = load i64, i64* %i
  %.p493 = getelementptr inbounds i8, i8* %.r491, i64 %.r492
  %.r494 = load i8, i8* %.p493
  %.t5 = zext i8 %.r494 to i64
  %.t6 = icmp eq i64 %.t5, 10
  br i1 %.t6, label %sc_rhs_9, label %sc_short_10
sc_rhs_9:
  %.r495 = load i64, i64* %i
  %.t7 = add i64 %.r495, 1
  %.r496 = load i8*, i8** %source
  %.t8 = call i64 @strlen(i8* %.r496)
  %.t9 = icmp slt i64 %.t7, %.t8
  store i1 %.t9, i1* %__sc.4
  br label %sc_end_11
sc_short_10:
  store i1 false, i1* %__sc.4
  br label %sc_end_11
sc_end_11:
  %.r497 = load i1, i1* %__sc.4
  br i1 %.r497, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.r498 = load i64, i64* %n
  %.t10 = add i64 %.r498, 1
  store i64 %.t10, i64* %n
  br label %if_end_6
if_next_0_8:
  br label %if_end_6
if_end_6:
  %.r499 = load i64, i64* %i
  %.t11 = add i64 %.r499, 1
  store i64 %.t11, i64* %i
  br label %while_cond_3
while_end_5:
  %.t12 = load i64, i64* %n
  ret i64 %.t12
}

define void @emit_diags(%Diags* %ds, i8* %default_file.arg, i8* %default_source.arg) {
entry:
  %default_file = alloca i8*
  %default_source = alloca i8*
  %__for.idx.1 = alloca i64
  %__for.len.2 = alloca i64
  %d = alloca %Diag
  store i8* %default_file.arg, i8** %default_file
  store i8* %default_source.arg, i8** %default_source
  %__fld.0 = getelementptr inbounds %Diags, %Diags* %ds, i32 0, i32 0
  store i64 0, i64* %__for.idx.1
  %.p500 = getelementptr inbounds { i64, i64, %Diag* }, { i64, i64, %Diag* }* %__fld.0, i32 0, i32 0
  %.t3 = load i64, i64* %.p500
  store i64 %.t3, i64* %__for.len.2
  br label %foreach_cond_0
foreach_cond_0:
  %.r501 = load i64, i64* %__for.idx.1
  %.r502 = load i64, i64* %__for.len.2
  %.t4 = icmp slt i64 %.r501, %.r502
  br i1 %.t4, label %foreach_body_1, label %foreach_end_3
foreach_body_1:
  %.r503 = load i64, i64* %__for.idx.1
  %.p504 = getelementptr inbounds { i64, i64, %Diag* }, { i64, i64, %Diag* }* %__fld.0, i32 0, i32 0
  %.r505 = load i64, i64* %.p504
  %.r506 = icmp slt i64 %.r503, 0
  %.r507 = icmp sge i64 %.r503, %.r505
  %.r508 = or i1 %.r506, %.r507
  br i1 %.r508, label %idx.fail.510, label %idx.ok.509
idx.fail.510:
  %.p511 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p511, i64 %.r503, i64 %.r505)
  call void @exit(i32 1)
  unreachable
idx.ok.509:
  %.p513 = getelementptr inbounds { i64, i64, %Diag* }, { i64, i64, %Diag* }* %__fld.0, i32 0, i32 2
  %.p512 = load %Diag*, %Diag** %.p513
  %.p514 = getelementptr inbounds %Diag, %Diag* %.p512, i64 %.r503
  %.t5 = load %Diag, %Diag* %.p514
  store %Diag %.t5, %Diag* %d
  %.t6 = bitcast %Diag* %d to %Diag*
  %.r515 = load i8*, i8** %default_file
  %.r516 = load i8*, i8** %default_source
  %.t7 = call i8* @render_diag(%Diag* %.t6, i8* %.r515, i8* %.r516)
  %.p517 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.0, i64 0, i64 0
  %.r518 = call i64 @strlen(i8* %.t7)
  %.r519 = call i64 @strlen(i8* %.p517)
  %.r520 = add i64 %.r518, %.r519
  %.r521 = add i64 %.r520, 1
  %.t8 = call i8* @malloc(i64 %.r521)
  call i8* @memcpy(i8* %.t8, i8* %.t7, i64 %.r518)
  %.p522 = getelementptr inbounds i8, i8* %.t8, i64 %.r518
  call i8* @memcpy(i8* %.p522, i8* %.p517, i64 %.r519)
  %.p523 = getelementptr inbounds i8, i8* %.t8, i64 %.r520
  store i8 0, i8* %.p523
  call void @eprint(i8* %.t8)
  br label %foreach_step_2
foreach_step_2:
  %.r524 = load i64, i64* %__for.idx.1
  %.t9 = add i64 %.r524, 1
  store i64 %.t9, i64* %__for.idx.1
  br label %foreach_cond_0
foreach_end_3:
  ret void
}

define void @tok_new(%Token* %__ret, i8* %kind.arg, i8* %text.arg, i64 %ival.arg, %Span* %span) {
entry:
  %kind = alloca i8*
  %text = alloca i8*
  %ival = alloca i64
  %t = alloca %Token
  store i8* %kind.arg, i8** %kind
  store i8* %text.arg, i8** %text
  store i64 %ival.arg, i64* %ival
  %.p525 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p526 = getelementptr inbounds %Token, %Token* %t, i32 0, i32 0
  store i8* %.p525, i8** %.p526
  %.p527 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p528 = getelementptr inbounds %Token, %Token* %t, i32 0, i32 1
  store i8* %.p527, i8** %.p528
  %.p529 = getelementptr inbounds %Token, %Token* %t, i32 0, i32 2
  store i64 0, i64* %.p529
  %.p530 = getelementptr inbounds %Token, %Token* %t, i32 0, i32 3
  store %Span zeroinitializer, %Span* %.p530
  %.r531 = load i8*, i8** %kind
  %.p532 = getelementptr inbounds %Token, %Token* %t, i32 0, i32 0
  store i8* %.r531, i8** %.p532
  %.r533 = load i8*, i8** %text
  %.p534 = getelementptr inbounds %Token, %Token* %t, i32 0, i32 1
  store i8* %.r533, i8** %.p534
  %.r535 = load i64, i64* %ival
  %.p536 = getelementptr inbounds %Token, %Token* %t, i32 0, i32 2
  store i64 %.r535, i64* %.p536
  %.r537 = load %Span, %Span* %span
  %.p538 = getelementptr inbounds %Token, %Token* %t, i32 0, i32 3
  store %Span %.r537, %Span* %.p538
  %.r539 = load %Token, %Token* %t
  store %Token %.r539, %Token* %__ret
  ret void
}

define i8* @lookup_keyword(i8* %s.arg) {
entry:
  %s = alloca i8*
  store i8* %s.arg, i8** %s
  %.r540 = load i8*, i8** %s
  %.p541 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.13, i64 0, i64 0
  %.r542 = call i32 @strcmp(i8* %.r540, i8* %.p541)
  %.t0 = icmp eq i32 %.r542, 0
  br i1 %.t0, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.p543 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.14, i64 0, i64 0
  ret i8* %.p543
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.r544 = load i8*, i8** %s
  %.p545 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.15, i64 0, i64 0
  %.r546 = call i32 @strcmp(i8* %.r544, i8* %.p545)
  %.t1 = icmp eq i32 %.r546, 0
  br i1 %.t1, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.p547 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.16, i64 0, i64 0
  ret i8* %.p547
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.r548 = load i8*, i8** %s
  %.p549 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.17, i64 0, i64 0
  %.r550 = call i32 @strcmp(i8* %.r548, i8* %.p549)
  %.t2 = icmp eq i32 %.r550, 0
  br i1 %.t2, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.p551 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.18, i64 0, i64 0
  ret i8* %.p551
if_next_0_8:
  br label %if_end_6
if_end_6:
  %.r552 = load i8*, i8** %s
  %.p553 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.19, i64 0, i64 0
  %.r554 = call i32 @strcmp(i8* %.r552, i8* %.p553)
  %.t3 = icmp eq i32 %.r554, 0
  br i1 %.t3, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.p555 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.20, i64 0, i64 0
  ret i8* %.p555
if_next_0_11:
  br label %if_end_9
if_end_9:
  %.r556 = load i8*, i8** %s
  %.p557 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.21, i64 0, i64 0
  %.r558 = call i32 @strcmp(i8* %.r556, i8* %.p557)
  %.t4 = icmp eq i32 %.r558, 0
  br i1 %.t4, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  %.p559 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.22, i64 0, i64 0
  ret i8* %.p559
if_next_0_14:
  br label %if_end_12
if_end_12:
  %.r560 = load i8*, i8** %s
  %.p561 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.23, i64 0, i64 0
  %.r562 = call i32 @strcmp(i8* %.r560, i8* %.p561)
  %.t5 = icmp eq i32 %.r562, 0
  br i1 %.t5, label %if_then_0_16, label %if_next_0_17
if_then_0_16:
  %.p563 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.24, i64 0, i64 0
  ret i8* %.p563
if_next_0_17:
  br label %if_end_15
if_end_15:
  %.r564 = load i8*, i8** %s
  %.p565 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.25, i64 0, i64 0
  %.r566 = call i32 @strcmp(i8* %.r564, i8* %.p565)
  %.t6 = icmp eq i32 %.r566, 0
  br i1 %.t6, label %if_then_0_19, label %if_next_0_20
if_then_0_19:
  %.p567 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.26, i64 0, i64 0
  ret i8* %.p567
if_next_0_20:
  br label %if_end_18
if_end_18:
  %.r568 = load i8*, i8** %s
  %.p569 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.27, i64 0, i64 0
  %.r570 = call i32 @strcmp(i8* %.r568, i8* %.p569)
  %.t7 = icmp eq i32 %.r570, 0
  br i1 %.t7, label %if_then_0_22, label %if_next_0_23
if_then_0_22:
  %.p571 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.28, i64 0, i64 0
  ret i8* %.p571
if_next_0_23:
  br label %if_end_21
if_end_21:
  %.r572 = load i8*, i8** %s
  %.p573 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.29, i64 0, i64 0
  %.r574 = call i32 @strcmp(i8* %.r572, i8* %.p573)
  %.t8 = icmp eq i32 %.r574, 0
  br i1 %.t8, label %if_then_0_25, label %if_next_0_26
if_then_0_25:
  %.p575 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.30, i64 0, i64 0
  ret i8* %.p575
if_next_0_26:
  br label %if_end_24
if_end_24:
  %.r576 = load i8*, i8** %s
  %.p577 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.31, i64 0, i64 0
  %.r578 = call i32 @strcmp(i8* %.r576, i8* %.p577)
  %.t9 = icmp eq i32 %.r578, 0
  br i1 %.t9, label %if_then_0_28, label %if_next_0_29
if_then_0_28:
  %.p579 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.32, i64 0, i64 0
  ret i8* %.p579
if_next_0_29:
  br label %if_end_27
if_end_27:
  %.r580 = load i8*, i8** %s
  %.p581 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.33, i64 0, i64 0
  %.r582 = call i32 @strcmp(i8* %.r580, i8* %.p581)
  %.t10 = icmp eq i32 %.r582, 0
  br i1 %.t10, label %if_then_0_31, label %if_next_0_32
if_then_0_31:
  %.p583 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.34, i64 0, i64 0
  ret i8* %.p583
if_next_0_32:
  br label %if_end_30
if_end_30:
  %.r584 = load i8*, i8** %s
  %.p585 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.35, i64 0, i64 0
  %.r586 = call i32 @strcmp(i8* %.r584, i8* %.p585)
  %.t11 = icmp eq i32 %.r586, 0
  br i1 %.t11, label %if_then_0_34, label %if_next_0_35
if_then_0_34:
  %.p587 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.36, i64 0, i64 0
  ret i8* %.p587
if_next_0_35:
  br label %if_end_33
if_end_33:
  %.r588 = load i8*, i8** %s
  %.p589 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.37, i64 0, i64 0
  %.r590 = call i32 @strcmp(i8* %.r588, i8* %.p589)
  %.t12 = icmp eq i32 %.r590, 0
  br i1 %.t12, label %if_then_0_37, label %if_next_0_38
if_then_0_37:
  %.p591 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.38, i64 0, i64 0
  ret i8* %.p591
if_next_0_38:
  br label %if_end_36
if_end_36:
  %.r592 = load i8*, i8** %s
  %.p593 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.39, i64 0, i64 0
  %.r594 = call i32 @strcmp(i8* %.r592, i8* %.p593)
  %.t13 = icmp eq i32 %.r594, 0
  br i1 %.t13, label %if_then_0_40, label %if_next_0_41
if_then_0_40:
  %.p595 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.40, i64 0, i64 0
  ret i8* %.p595
if_next_0_41:
  br label %if_end_39
if_end_39:
  %.r596 = load i8*, i8** %s
  %.p597 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.41, i64 0, i64 0
  %.r598 = call i32 @strcmp(i8* %.r596, i8* %.p597)
  %.t14 = icmp eq i32 %.r598, 0
  br i1 %.t14, label %if_then_0_43, label %if_next_0_44
if_then_0_43:
  %.p599 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.42, i64 0, i64 0
  ret i8* %.p599
if_next_0_44:
  br label %if_end_42
if_end_42:
  %.r600 = load i8*, i8** %s
  %.p601 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.43, i64 0, i64 0
  %.r602 = call i32 @strcmp(i8* %.r600, i8* %.p601)
  %.t15 = icmp eq i32 %.r602, 0
  br i1 %.t15, label %if_then_0_46, label %if_next_0_47
if_then_0_46:
  %.p603 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.44, i64 0, i64 0
  ret i8* %.p603
if_next_0_47:
  br label %if_end_45
if_end_45:
  %.r604 = load i8*, i8** %s
  %.p605 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.45, i64 0, i64 0
  %.r606 = call i32 @strcmp(i8* %.r604, i8* %.p605)
  %.t16 = icmp eq i32 %.r606, 0
  br i1 %.t16, label %if_then_0_49, label %if_next_0_50
if_then_0_49:
  %.p607 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.46, i64 0, i64 0
  ret i8* %.p607
if_next_0_50:
  br label %if_end_48
if_end_48:
  %.r608 = load i8*, i8** %s
  %.p609 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.47, i64 0, i64 0
  %.r610 = call i32 @strcmp(i8* %.r608, i8* %.p609)
  %.t17 = icmp eq i32 %.r610, 0
  br i1 %.t17, label %if_then_0_52, label %if_next_0_53
if_then_0_52:
  %.p611 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.48, i64 0, i64 0
  ret i8* %.p611
if_next_0_53:
  br label %if_end_51
if_end_51:
  %.r612 = load i8*, i8** %s
  %.p613 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.49, i64 0, i64 0
  %.r614 = call i32 @strcmp(i8* %.r612, i8* %.p613)
  %.t18 = icmp eq i32 %.r614, 0
  br i1 %.t18, label %if_then_0_55, label %if_next_0_56
if_then_0_55:
  %.p615 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.50, i64 0, i64 0
  ret i8* %.p615
if_next_0_56:
  br label %if_end_54
if_end_54:
  %.r616 = load i8*, i8** %s
  %.p617 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.51, i64 0, i64 0
  %.r618 = call i32 @strcmp(i8* %.r616, i8* %.p617)
  %.t19 = icmp eq i32 %.r618, 0
  br i1 %.t19, label %if_then_0_58, label %if_next_0_59
if_then_0_58:
  %.p619 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.52, i64 0, i64 0
  ret i8* %.p619
if_next_0_59:
  br label %if_end_57
if_end_57:
  %.r620 = load i8*, i8** %s
  %.p621 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.53, i64 0, i64 0
  %.r622 = call i32 @strcmp(i8* %.r620, i8* %.p621)
  %.t20 = icmp eq i32 %.r622, 0
  br i1 %.t20, label %if_then_0_61, label %if_next_0_62
if_then_0_61:
  %.p623 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.54, i64 0, i64 0
  ret i8* %.p623
if_next_0_62:
  br label %if_end_60
if_end_60:
  %.r624 = load i8*, i8** %s
  %.p625 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.55, i64 0, i64 0
  %.r626 = call i32 @strcmp(i8* %.r624, i8* %.p625)
  %.t21 = icmp eq i32 %.r626, 0
  br i1 %.t21, label %if_then_0_64, label %if_next_0_65
if_then_0_64:
  %.p627 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.56, i64 0, i64 0
  ret i8* %.p627
if_next_0_65:
  br label %if_end_63
if_end_63:
  %.r628 = load i8*, i8** %s
  %.p629 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.57, i64 0, i64 0
  %.r630 = call i32 @strcmp(i8* %.r628, i8* %.p629)
  %.t22 = icmp eq i32 %.r630, 0
  br i1 %.t22, label %if_then_0_67, label %if_next_0_68
if_then_0_67:
  %.p631 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.58, i64 0, i64 0
  ret i8* %.p631
if_next_0_68:
  br label %if_end_66
if_end_66:
  %.r632 = load i8*, i8** %s
  %.p633 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.59, i64 0, i64 0
  %.r634 = call i32 @strcmp(i8* %.r632, i8* %.p633)
  %.t23 = icmp eq i32 %.r634, 0
  br i1 %.t23, label %if_then_0_70, label %if_next_0_71
if_then_0_70:
  %.p635 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.60, i64 0, i64 0
  ret i8* %.p635
if_next_0_71:
  br label %if_end_69
if_end_69:
  %.r636 = load i8*, i8** %s
  %.p637 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.61, i64 0, i64 0
  %.r638 = call i32 @strcmp(i8* %.r636, i8* %.p637)
  %.t24 = icmp eq i32 %.r638, 0
  br i1 %.t24, label %if_then_0_73, label %if_next_0_74
if_then_0_73:
  %.p639 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.62, i64 0, i64 0
  ret i8* %.p639
if_next_0_74:
  br label %if_end_72
if_end_72:
  %.r640 = load i8*, i8** %s
  %.p641 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.63, i64 0, i64 0
  %.r642 = call i32 @strcmp(i8* %.r640, i8* %.p641)
  %.t25 = icmp eq i32 %.r642, 0
  br i1 %.t25, label %if_then_0_76, label %if_next_0_77
if_then_0_76:
  %.p643 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.64, i64 0, i64 0
  ret i8* %.p643
if_next_0_77:
  br label %if_end_75
if_end_75:
  %.r644 = load i8*, i8** %s
  %.p645 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.65, i64 0, i64 0
  %.r646 = call i32 @strcmp(i8* %.r644, i8* %.p645)
  %.t26 = icmp eq i32 %.r646, 0
  br i1 %.t26, label %if_then_0_79, label %if_next_0_80
if_then_0_79:
  %.p647 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.66, i64 0, i64 0
  ret i8* %.p647
if_next_0_80:
  br label %if_end_78
if_end_78:
  %.r648 = load i8*, i8** %s
  %.p649 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.67, i64 0, i64 0
  %.r650 = call i32 @strcmp(i8* %.r648, i8* %.p649)
  %.t27 = icmp eq i32 %.r650, 0
  br i1 %.t27, label %if_then_0_82, label %if_next_0_83
if_then_0_82:
  %.p651 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.68, i64 0, i64 0
  ret i8* %.p651
if_next_0_83:
  br label %if_end_81
if_end_81:
  %.r652 = load i8*, i8** %s
  %.p653 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.69, i64 0, i64 0
  %.r654 = call i32 @strcmp(i8* %.r652, i8* %.p653)
  %.t28 = icmp eq i32 %.r654, 0
  br i1 %.t28, label %if_then_0_85, label %if_next_0_86
if_then_0_85:
  %.p655 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.70, i64 0, i64 0
  ret i8* %.p655
if_next_0_86:
  br label %if_end_84
if_end_84:
  %.r656 = load i8*, i8** %s
  %.p657 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.71, i64 0, i64 0
  %.r658 = call i32 @strcmp(i8* %.r656, i8* %.p657)
  %.t29 = icmp eq i32 %.r658, 0
  br i1 %.t29, label %if_then_0_88, label %if_next_0_89
if_then_0_88:
  %.p659 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.72, i64 0, i64 0
  ret i8* %.p659
if_next_0_89:
  br label %if_end_87
if_end_87:
  %.r660 = load i8*, i8** %s
  %.p661 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.73, i64 0, i64 0
  %.r662 = call i32 @strcmp(i8* %.r660, i8* %.p661)
  %.t30 = icmp eq i32 %.r662, 0
  br i1 %.t30, label %if_then_0_91, label %if_next_0_92
if_then_0_91:
  %.p663 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.74, i64 0, i64 0
  ret i8* %.p663
if_next_0_92:
  br label %if_end_90
if_end_90:
  %.r664 = load i8*, i8** %s
  %.p665 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.75, i64 0, i64 0
  %.r666 = call i32 @strcmp(i8* %.r664, i8* %.p665)
  %.t31 = icmp eq i32 %.r666, 0
  br i1 %.t31, label %if_then_0_94, label %if_next_0_95
if_then_0_94:
  %.p667 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.76, i64 0, i64 0
  ret i8* %.p667
if_next_0_95:
  br label %if_end_93
if_end_93:
  %.r668 = load i8*, i8** %s
  %.p669 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.77, i64 0, i64 0
  %.r670 = call i32 @strcmp(i8* %.r668, i8* %.p669)
  %.t32 = icmp eq i32 %.r670, 0
  br i1 %.t32, label %if_then_0_97, label %if_next_0_98
if_then_0_97:
  %.p671 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.78, i64 0, i64 0
  ret i8* %.p671
if_next_0_98:
  br label %if_end_96
if_end_96:
  %.r672 = load i8*, i8** %s
  %.p673 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.79, i64 0, i64 0
  %.r674 = call i32 @strcmp(i8* %.r672, i8* %.p673)
  %.t33 = icmp eq i32 %.r674, 0
  br i1 %.t33, label %if_then_0_100, label %if_next_0_101
if_then_0_100:
  %.p675 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.80, i64 0, i64 0
  ret i8* %.p675
if_next_0_101:
  br label %if_end_99
if_end_99:
  %.r676 = load i8*, i8** %s
  %.p677 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.81, i64 0, i64 0
  %.r678 = call i32 @strcmp(i8* %.r676, i8* %.p677)
  %.t34 = icmp eq i32 %.r678, 0
  br i1 %.t34, label %if_then_0_103, label %if_next_0_104
if_then_0_103:
  %.p679 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.82, i64 0, i64 0
  ret i8* %.p679
if_next_0_104:
  br label %if_end_102
if_end_102:
  %.r680 = load i8*, i8** %s
  %.p681 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.83, i64 0, i64 0
  %.r682 = call i32 @strcmp(i8* %.r680, i8* %.p681)
  %.t35 = icmp eq i32 %.r682, 0
  br i1 %.t35, label %if_then_0_106, label %if_next_0_107
if_then_0_106:
  %.p683 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.84, i64 0, i64 0
  ret i8* %.p683
if_next_0_107:
  br label %if_end_105
if_end_105:
  %.r684 = load i8*, i8** %s
  %.p685 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.85, i64 0, i64 0
  %.r686 = call i32 @strcmp(i8* %.r684, i8* %.p685)
  %.t36 = icmp eq i32 %.r686, 0
  br i1 %.t36, label %if_then_0_109, label %if_next_0_110
if_then_0_109:
  %.p687 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.86, i64 0, i64 0
  ret i8* %.p687
if_next_0_110:
  br label %if_end_108
if_end_108:
  %.r688 = load i8*, i8** %s
  %.p689 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.87, i64 0, i64 0
  %.r690 = call i32 @strcmp(i8* %.r688, i8* %.p689)
  %.t37 = icmp eq i32 %.r690, 0
  br i1 %.t37, label %if_then_0_112, label %if_next_0_113
if_then_0_112:
  %.p691 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.88, i64 0, i64 0
  ret i8* %.p691
if_next_0_113:
  br label %if_end_111
if_end_111:
  %.r692 = load i8*, i8** %s
  %.p693 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.89, i64 0, i64 0
  %.r694 = call i32 @strcmp(i8* %.r692, i8* %.p693)
  %.t38 = icmp eq i32 %.r694, 0
  br i1 %.t38, label %if_then_0_115, label %if_next_0_116
if_then_0_115:
  %.p695 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.90, i64 0, i64 0
  ret i8* %.p695
if_next_0_116:
  br label %if_end_114
if_end_114:
  %.p696 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  ret i8* %.p696
}

define i8* @token_display(%Token* %t) {
entry:
  %k = alloca i8*
  %.p697 = getelementptr inbounds %Token, %Token* %t, i32 0, i32 0
  %.t0 = load i8*, i8** %.p697
  store i8* %.t0, i8** %k
  %.r698 = load i8*, i8** %k
  %.p699 = getelementptr inbounds [11 x i8], [11 x i8]* @.str.91, i64 0, i64 0
  %.r700 = call i32 @strcmp(i8* %.r698, i8* %.p699)
  %.t1 = icmp eq i32 %.r700, 0
  br i1 %.t1, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.p701 = getelementptr inbounds %Token, %Token* %t, i32 0, i32 1
  %.t2 = load i8*, i8** %.p701
  %.p702 = getelementptr inbounds [18 x i8], [18 x i8]* @.str.92, i64 0, i64 0
  %.r703 = call i64 @strlen(i8* %.p702)
  %.r704 = call i64 @strlen(i8* %.t2)
  %.r705 = add i64 %.r703, %.r704
  %.r706 = add i64 %.r705, 1
  %.t3 = call i8* @malloc(i64 %.r706)
  call i8* @memcpy(i8* %.t3, i8* %.p702, i64 %.r703)
  %.p707 = getelementptr inbounds i8, i8* %.t3, i64 %.r703
  call i8* @memcpy(i8* %.p707, i8* %.t2, i64 %.r704)
  %.p708 = getelementptr inbounds i8, i8* %.t3, i64 %.r705
  store i8 0, i8* %.p708
  %.p709 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.93, i64 0, i64 0
  %.r710 = call i64 @strlen(i8* %.t3)
  %.r711 = call i64 @strlen(i8* %.p709)
  %.r712 = add i64 %.r710, %.r711
  %.r713 = add i64 %.r712, 1
  %.t4 = call i8* @malloc(i64 %.r713)
  call i8* @memcpy(i8* %.t4, i8* %.t3, i64 %.r710)
  %.p714 = getelementptr inbounds i8, i8* %.t4, i64 %.r710
  call i8* @memcpy(i8* %.p714, i8* %.p709, i64 %.r711)
  %.p715 = getelementptr inbounds i8, i8* %.t4, i64 %.r712
  store i8 0, i8* %.p715
  ret i8* %.t4
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.r716 = load i8*, i8** %k
  %.p717 = getelementptr inbounds [13 x i8], [13 x i8]* @.str.94, i64 0, i64 0
  %.r718 = call i32 @strcmp(i8* %.r716, i8* %.p717)
  %.t5 = icmp eq i32 %.r718, 0
  br i1 %.t5, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.p719 = getelementptr inbounds %Token, %Token* %t, i32 0, i32 1
  %.t6 = load i8*, i8** %.p719
  %.p720 = getelementptr inbounds [16 x i8], [16 x i8]* @.str.95, i64 0, i64 0
  %.r721 = call i64 @strlen(i8* %.p720)
  %.r722 = call i64 @strlen(i8* %.t6)
  %.r723 = add i64 %.r721, %.r722
  %.r724 = add i64 %.r723, 1
  %.t7 = call i8* @malloc(i64 %.r724)
  call i8* @memcpy(i8* %.t7, i8* %.p720, i64 %.r721)
  %.p725 = getelementptr inbounds i8, i8* %.t7, i64 %.r721
  call i8* @memcpy(i8* %.p725, i8* %.t6, i64 %.r722)
  %.p726 = getelementptr inbounds i8, i8* %.t7, i64 %.r723
  store i8 0, i8* %.p726
  %.p727 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.93, i64 0, i64 0
  %.r728 = call i64 @strlen(i8* %.t7)
  %.r729 = call i64 @strlen(i8* %.p727)
  %.r730 = add i64 %.r728, %.r729
  %.r731 = add i64 %.r730, 1
  %.t8 = call i8* @malloc(i64 %.r731)
  call i8* @memcpy(i8* %.t8, i8* %.t7, i64 %.r728)
  %.p732 = getelementptr inbounds i8, i8* %.t8, i64 %.r728
  call i8* @memcpy(i8* %.p732, i8* %.p727, i64 %.r729)
  %.p733 = getelementptr inbounds i8, i8* %.t8, i64 %.r730
  store i8 0, i8* %.p733
  ret i8* %.t8
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.r734 = load i8*, i8** %k
  %.p735 = getelementptr inbounds [14 x i8], [14 x i8]* @.str.96, i64 0, i64 0
  %.r736 = call i32 @strcmp(i8* %.r734, i8* %.p735)
  %.t9 = icmp eq i32 %.r736, 0
  br i1 %.t9, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.p737 = getelementptr inbounds %Token, %Token* %t, i32 0, i32 1
  %.t10 = load i8*, i8** %.p737
  %.p738 = getelementptr inbounds [17 x i8], [17 x i8]* @.str.97, i64 0, i64 0
  %.r739 = call i64 @strlen(i8* %.p738)
  %.r740 = call i64 @strlen(i8* %.t10)
  %.r741 = add i64 %.r739, %.r740
  %.r742 = add i64 %.r741, 1
  %.t11 = call i8* @malloc(i64 %.r742)
  call i8* @memcpy(i8* %.t11, i8* %.p738, i64 %.r739)
  %.p743 = getelementptr inbounds i8, i8* %.t11, i64 %.r739
  call i8* @memcpy(i8* %.p743, i8* %.t10, i64 %.r740)
  %.p744 = getelementptr inbounds i8, i8* %.t11, i64 %.r741
  store i8 0, i8* %.p744
  %.p745 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.98, i64 0, i64 0
  %.r746 = call i64 @strlen(i8* %.t11)
  %.r747 = call i64 @strlen(i8* %.p745)
  %.r748 = add i64 %.r746, %.r747
  %.r749 = add i64 %.r748, 1
  %.t12 = call i8* @malloc(i64 %.r749)
  call i8* @memcpy(i8* %.t12, i8* %.t11, i64 %.r746)
  %.p750 = getelementptr inbounds i8, i8* %.t12, i64 %.r746
  call i8* @memcpy(i8* %.p750, i8* %.p745, i64 %.r747)
  %.p751 = getelementptr inbounds i8, i8* %.t12, i64 %.r748
  store i8 0, i8* %.p751
  ret i8* %.t12
if_next_0_8:
  br label %if_end_6
if_end_6:
  %.r752 = load i8*, i8** %k
  %.p753 = getelementptr inbounds [15 x i8], [15 x i8]* @.str.99, i64 0, i64 0
  %.r754 = call i32 @strcmp(i8* %.r752, i8* %.p753)
  %.t13 = icmp eq i32 %.r754, 0
  br i1 %.t13, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.p755 = getelementptr inbounds %Token, %Token* %t, i32 0, i32 1
  %.t14 = load i8*, i8** %.p755
  %.p756 = getelementptr inbounds [19 x i8], [19 x i8]* @.str.100, i64 0, i64 0
  %.r757 = call i64 @strlen(i8* %.p756)
  %.r758 = call i64 @strlen(i8* %.t14)
  %.r759 = add i64 %.r757, %.r758
  %.r760 = add i64 %.r759, 1
  %.t15 = call i8* @malloc(i64 %.r760)
  call i8* @memcpy(i8* %.t15, i8* %.p756, i64 %.r757)
  %.p761 = getelementptr inbounds i8, i8* %.t15, i64 %.r757
  call i8* @memcpy(i8* %.p761, i8* %.t14, i64 %.r758)
  %.p762 = getelementptr inbounds i8, i8* %.t15, i64 %.r759
  store i8 0, i8* %.p762
  %.p763 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.98, i64 0, i64 0
  %.r764 = call i64 @strlen(i8* %.t15)
  %.r765 = call i64 @strlen(i8* %.p763)
  %.r766 = add i64 %.r764, %.r765
  %.r767 = add i64 %.r766, 1
  %.t16 = call i8* @malloc(i64 %.r767)
  call i8* @memcpy(i8* %.t16, i8* %.t15, i64 %.r764)
  %.p768 = getelementptr inbounds i8, i8* %.t16, i64 %.r764
  call i8* @memcpy(i8* %.p768, i8* %.p763, i64 %.r765)
  %.p769 = getelementptr inbounds i8, i8* %.t16, i64 %.r766
  store i8 0, i8* %.p769
  ret i8* %.t16
if_next_0_11:
  br label %if_end_9
if_end_9:
  %.r770 = load i8*, i8** %k
  %.p771 = getelementptr inbounds [11 x i8], [11 x i8]* @.str.101, i64 0, i64 0
  %.r772 = call i32 @strcmp(i8* %.r770, i8* %.p771)
  %.t17 = icmp eq i32 %.r772, 0
  br i1 %.t17, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  %.p773 = getelementptr inbounds %Token, %Token* %t, i32 0, i32 1
  %.t18 = load i8*, i8** %.p773
  %.p774 = getelementptr inbounds [13 x i8], [13 x i8]* @.str.102, i64 0, i64 0
  %.r775 = call i64 @strlen(i8* %.p774)
  %.r776 = call i64 @strlen(i8* %.t18)
  %.r777 = add i64 %.r775, %.r776
  %.r778 = add i64 %.r777, 1
  %.t19 = call i8* @malloc(i64 %.r778)
  call i8* @memcpy(i8* %.t19, i8* %.p774, i64 %.r775)
  %.p779 = getelementptr inbounds i8, i8* %.t19, i64 %.r775
  call i8* @memcpy(i8* %.p779, i8* %.t18, i64 %.r776)
  %.p780 = getelementptr inbounds i8, i8* %.t19, i64 %.r777
  store i8 0, i8* %.p780
  %.p781 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.93, i64 0, i64 0
  %.r782 = call i64 @strlen(i8* %.t19)
  %.r783 = call i64 @strlen(i8* %.p781)
  %.r784 = add i64 %.r782, %.r783
  %.r785 = add i64 %.r784, 1
  %.t20 = call i8* @malloc(i64 %.r785)
  call i8* @memcpy(i8* %.t20, i8* %.t19, i64 %.r782)
  %.p786 = getelementptr inbounds i8, i8* %.t20, i64 %.r782
  call i8* @memcpy(i8* %.p786, i8* %.p781, i64 %.r783)
  %.p787 = getelementptr inbounds i8, i8* %.t20, i64 %.r784
  store i8 0, i8* %.p787
  ret i8* %.t20
if_next_0_14:
  br label %if_end_12
if_end_12:
  %.r788 = load i8*, i8** %k
  %.t21 = call i8* @kind_display(i8* %.r788)
  ret i8* %.t21
}

define i8* @kind_display(i8* %k.arg) {
entry:
  %k = alloca i8*
  store i8* %k.arg, i8** %k
  %.r789 = load i8*, i8** %k
  %.p790 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.14, i64 0, i64 0
  %.r791 = call i32 @strcmp(i8* %.r789, i8* %.p790)
  %.t0 = icmp eq i32 %.r791, 0
  br i1 %.t0, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.p792 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.103, i64 0, i64 0
  ret i8* %.p792
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.r793 = load i8*, i8** %k
  %.p794 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.16, i64 0, i64 0
  %.r795 = call i32 @strcmp(i8* %.r793, i8* %.p794)
  %.t1 = icmp eq i32 %.r795, 0
  br i1 %.t1, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.p796 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.104, i64 0, i64 0
  ret i8* %.p796
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.r797 = load i8*, i8** %k
  %.p798 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.56, i64 0, i64 0
  %.r799 = call i32 @strcmp(i8* %.r797, i8* %.p798)
  %.t2 = icmp eq i32 %.r799, 0
  br i1 %.t2, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.p800 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.105, i64 0, i64 0
  ret i8* %.p800
if_next_0_8:
  br label %if_end_6
if_end_6:
  %.r801 = load i8*, i8** %k
  %.p802 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.58, i64 0, i64 0
  %.r803 = call i32 @strcmp(i8* %.r801, i8* %.p802)
  %.t3 = icmp eq i32 %.r803, 0
  br i1 %.t3, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.p804 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.106, i64 0, i64 0
  ret i8* %.p804
if_next_0_11:
  br label %if_end_9
if_end_9:
  %.r805 = load i8*, i8** %k
  %.p806 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.60, i64 0, i64 0
  %.r807 = call i32 @strcmp(i8* %.r805, i8* %.p806)
  %.t4 = icmp eq i32 %.r807, 0
  br i1 %.t4, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  %.p808 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.107, i64 0, i64 0
  ret i8* %.p808
if_next_0_14:
  br label %if_end_12
if_end_12:
  %.r809 = load i8*, i8** %k
  %.p810 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.18, i64 0, i64 0
  %.r811 = call i32 @strcmp(i8* %.r809, i8* %.p810)
  %.t5 = icmp eq i32 %.r811, 0
  br i1 %.t5, label %if_then_0_16, label %if_next_0_17
if_then_0_16:
  %.p812 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.108, i64 0, i64 0
  ret i8* %.p812
if_next_0_17:
  br label %if_end_15
if_end_15:
  %.r813 = load i8*, i8** %k
  %.p814 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.20, i64 0, i64 0
  %.r815 = call i32 @strcmp(i8* %.r813, i8* %.p814)
  %.t6 = icmp eq i32 %.r815, 0
  br i1 %.t6, label %if_then_0_19, label %if_next_0_20
if_then_0_19:
  %.p816 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.109, i64 0, i64 0
  ret i8* %.p816
if_next_0_20:
  br label %if_end_18
if_end_18:
  %.r817 = load i8*, i8** %k
  %.p818 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.22, i64 0, i64 0
  %.r819 = call i32 @strcmp(i8* %.r817, i8* %.p818)
  %.t7 = icmp eq i32 %.r819, 0
  br i1 %.t7, label %if_then_0_22, label %if_next_0_23
if_then_0_22:
  %.p820 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.110, i64 0, i64 0
  ret i8* %.p820
if_next_0_23:
  br label %if_end_21
if_end_21:
  %.r821 = load i8*, i8** %k
  %.p822 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.24, i64 0, i64 0
  %.r823 = call i32 @strcmp(i8* %.r821, i8* %.p822)
  %.t8 = icmp eq i32 %.r823, 0
  br i1 %.t8, label %if_then_0_25, label %if_next_0_26
if_then_0_25:
  %.p824 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.111, i64 0, i64 0
  ret i8* %.p824
if_next_0_26:
  br label %if_end_24
if_end_24:
  %.r825 = load i8*, i8** %k
  %.p826 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.26, i64 0, i64 0
  %.r827 = call i32 @strcmp(i8* %.r825, i8* %.p826)
  %.t9 = icmp eq i32 %.r827, 0
  br i1 %.t9, label %if_then_0_28, label %if_next_0_29
if_then_0_28:
  %.p828 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.112, i64 0, i64 0
  ret i8* %.p828
if_next_0_29:
  br label %if_end_27
if_end_27:
  %.r829 = load i8*, i8** %k
  %.p830 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.28, i64 0, i64 0
  %.r831 = call i32 @strcmp(i8* %.r829, i8* %.p830)
  %.t10 = icmp eq i32 %.r831, 0
  br i1 %.t10, label %if_then_0_31, label %if_next_0_32
if_then_0_31:
  %.p832 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.113, i64 0, i64 0
  ret i8* %.p832
if_next_0_32:
  br label %if_end_30
if_end_30:
  %.r833 = load i8*, i8** %k
  %.p834 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.30, i64 0, i64 0
  %.r835 = call i32 @strcmp(i8* %.r833, i8* %.p834)
  %.t11 = icmp eq i32 %.r835, 0
  br i1 %.t11, label %if_then_0_34, label %if_next_0_35
if_then_0_34:
  %.p836 = getelementptr inbounds [10 x i8], [10 x i8]* @.str.114, i64 0, i64 0
  ret i8* %.p836
if_next_0_35:
  br label %if_end_33
if_end_33:
  %.r837 = load i8*, i8** %k
  %.p838 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.32, i64 0, i64 0
  %.r839 = call i32 @strcmp(i8* %.r837, i8* %.p838)
  %.t12 = icmp eq i32 %.r839, 0
  br i1 %.t12, label %if_then_0_37, label %if_next_0_38
if_then_0_37:
  %.p840 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.115, i64 0, i64 0
  ret i8* %.p840
if_next_0_38:
  br label %if_end_36
if_end_36:
  %.r841 = load i8*, i8** %k
  %.p842 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.34, i64 0, i64 0
  %.r843 = call i32 @strcmp(i8* %.r841, i8* %.p842)
  %.t13 = icmp eq i32 %.r843, 0
  br i1 %.t13, label %if_then_0_40, label %if_next_0_41
if_then_0_40:
  %.p844 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.116, i64 0, i64 0
  ret i8* %.p844
if_next_0_41:
  br label %if_end_39
if_end_39:
  %.r845 = load i8*, i8** %k
  %.p846 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.36, i64 0, i64 0
  %.r847 = call i32 @strcmp(i8* %.r845, i8* %.p846)
  %.t14 = icmp eq i32 %.r847, 0
  br i1 %.t14, label %if_then_0_43, label %if_next_0_44
if_then_0_43:
  %.p848 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.117, i64 0, i64 0
  ret i8* %.p848
if_next_0_44:
  br label %if_end_42
if_end_42:
  %.r849 = load i8*, i8** %k
  %.p850 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.38, i64 0, i64 0
  %.r851 = call i32 @strcmp(i8* %.r849, i8* %.p850)
  %.t15 = icmp eq i32 %.r851, 0
  br i1 %.t15, label %if_then_0_46, label %if_next_0_47
if_then_0_46:
  %.p852 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.118, i64 0, i64 0
  ret i8* %.p852
if_next_0_47:
  br label %if_end_45
if_end_45:
  %.r853 = load i8*, i8** %k
  %.p854 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.40, i64 0, i64 0
  %.r855 = call i32 @strcmp(i8* %.r853, i8* %.p854)
  %.t16 = icmp eq i32 %.r855, 0
  br i1 %.t16, label %if_then_0_49, label %if_next_0_50
if_then_0_49:
  %.p856 = getelementptr inbounds [11 x i8], [11 x i8]* @.str.119, i64 0, i64 0
  ret i8* %.p856
if_next_0_50:
  br label %if_end_48
if_end_48:
  %.r857 = load i8*, i8** %k
  %.p858 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.42, i64 0, i64 0
  %.r859 = call i32 @strcmp(i8* %.r857, i8* %.p858)
  %.t17 = icmp eq i32 %.r859, 0
  br i1 %.t17, label %if_then_0_52, label %if_next_0_53
if_then_0_52:
  %.p860 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.120, i64 0, i64 0
  ret i8* %.p860
if_next_0_53:
  br label %if_end_51
if_end_51:
  %.r861 = load i8*, i8** %k
  %.p862 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.44, i64 0, i64 0
  %.r863 = call i32 @strcmp(i8* %.r861, i8* %.p862)
  %.t18 = icmp eq i32 %.r863, 0
  br i1 %.t18, label %if_then_0_55, label %if_next_0_56
if_then_0_55:
  %.p864 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.121, i64 0, i64 0
  ret i8* %.p864
if_next_0_56:
  br label %if_end_54
if_end_54:
  %.r865 = load i8*, i8** %k
  %.p866 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.46, i64 0, i64 0
  %.r867 = call i32 @strcmp(i8* %.r865, i8* %.p866)
  %.t19 = icmp eq i32 %.r867, 0
  br i1 %.t19, label %if_then_0_58, label %if_next_0_59
if_then_0_58:
  %.p868 = getelementptr inbounds [10 x i8], [10 x i8]* @.str.122, i64 0, i64 0
  ret i8* %.p868
if_next_0_59:
  br label %if_end_57
if_end_57:
  %.r869 = load i8*, i8** %k
  %.p870 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.48, i64 0, i64 0
  %.r871 = call i32 @strcmp(i8* %.r869, i8* %.p870)
  %.t20 = icmp eq i32 %.r871, 0
  br i1 %.t20, label %if_then_0_61, label %if_next_0_62
if_then_0_61:
  %.p872 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.123, i64 0, i64 0
  ret i8* %.p872
if_next_0_62:
  br label %if_end_60
if_end_60:
  %.r873 = load i8*, i8** %k
  %.p874 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.50, i64 0, i64 0
  %.r875 = call i32 @strcmp(i8* %.r873, i8* %.p874)
  %.t21 = icmp eq i32 %.r875, 0
  br i1 %.t21, label %if_then_0_64, label %if_next_0_65
if_then_0_64:
  %.p876 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.124, i64 0, i64 0
  ret i8* %.p876
if_next_0_65:
  br label %if_end_63
if_end_63:
  %.r877 = load i8*, i8** %k
  %.p878 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.52, i64 0, i64 0
  %.r879 = call i32 @strcmp(i8* %.r877, i8* %.p878)
  %.t22 = icmp eq i32 %.r879, 0
  br i1 %.t22, label %if_then_0_67, label %if_next_0_68
if_then_0_67:
  %.p880 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.125, i64 0, i64 0
  ret i8* %.p880
if_next_0_68:
  br label %if_end_66
if_end_66:
  %.r881 = load i8*, i8** %k
  %.p882 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.54, i64 0, i64 0
  %.r883 = call i32 @strcmp(i8* %.r881, i8* %.p882)
  %.t23 = icmp eq i32 %.r883, 0
  br i1 %.t23, label %if_then_0_70, label %if_next_0_71
if_then_0_70:
  %.p884 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.126, i64 0, i64 0
  ret i8* %.p884
if_next_0_71:
  br label %if_end_69
if_end_69:
  %.r885 = load i8*, i8** %k
  %.p886 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.62, i64 0, i64 0
  %.r887 = call i32 @strcmp(i8* %.r885, i8* %.p886)
  %.t24 = icmp eq i32 %.r887, 0
  br i1 %.t24, label %if_then_0_73, label %if_next_0_74
if_then_0_73:
  %.p888 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.127, i64 0, i64 0
  ret i8* %.p888
if_next_0_74:
  br label %if_end_72
if_end_72:
  %.r889 = load i8*, i8** %k
  %.p890 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.64, i64 0, i64 0
  %.r891 = call i32 @strcmp(i8* %.r889, i8* %.p890)
  %.t25 = icmp eq i32 %.r891, 0
  br i1 %.t25, label %if_then_0_76, label %if_next_0_77
if_then_0_76:
  %.p892 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.128, i64 0, i64 0
  ret i8* %.p892
if_next_0_77:
  br label %if_end_75
if_end_75:
  %.r893 = load i8*, i8** %k
  %.p894 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.66, i64 0, i64 0
  %.r895 = call i32 @strcmp(i8* %.r893, i8* %.p894)
  %.t26 = icmp eq i32 %.r895, 0
  br i1 %.t26, label %if_then_0_79, label %if_next_0_80
if_then_0_79:
  %.p896 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.129, i64 0, i64 0
  ret i8* %.p896
if_next_0_80:
  br label %if_end_78
if_end_78:
  %.r897 = load i8*, i8** %k
  %.p898 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.68, i64 0, i64 0
  %.r899 = call i32 @strcmp(i8* %.r897, i8* %.p898)
  %.t27 = icmp eq i32 %.r899, 0
  br i1 %.t27, label %if_then_0_82, label %if_next_0_83
if_then_0_82:
  %.p900 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.130, i64 0, i64 0
  ret i8* %.p900
if_next_0_83:
  br label %if_end_81
if_end_81:
  %.r901 = load i8*, i8** %k
  %.p902 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.70, i64 0, i64 0
  %.r903 = call i32 @strcmp(i8* %.r901, i8* %.p902)
  %.t28 = icmp eq i32 %.r903, 0
  br i1 %.t28, label %if_then_0_85, label %if_next_0_86
if_then_0_85:
  %.p904 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.131, i64 0, i64 0
  ret i8* %.p904
if_next_0_86:
  br label %if_end_84
if_end_84:
  %.r905 = load i8*, i8** %k
  %.p906 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.72, i64 0, i64 0
  %.r907 = call i32 @strcmp(i8* %.r905, i8* %.p906)
  %.t29 = icmp eq i32 %.r907, 0
  br i1 %.t29, label %if_then_0_88, label %if_next_0_89
if_then_0_88:
  %.p908 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.132, i64 0, i64 0
  ret i8* %.p908
if_next_0_89:
  br label %if_end_87
if_end_87:
  %.r909 = load i8*, i8** %k
  %.p910 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.74, i64 0, i64 0
  %.r911 = call i32 @strcmp(i8* %.r909, i8* %.p910)
  %.t30 = icmp eq i32 %.r911, 0
  br i1 %.t30, label %if_then_0_91, label %if_next_0_92
if_then_0_91:
  %.p912 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.133, i64 0, i64 0
  ret i8* %.p912
if_next_0_92:
  br label %if_end_90
if_end_90:
  %.r913 = load i8*, i8** %k
  %.p914 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.76, i64 0, i64 0
  %.r915 = call i32 @strcmp(i8* %.r913, i8* %.p914)
  %.t31 = icmp eq i32 %.r915, 0
  br i1 %.t31, label %if_then_0_94, label %if_next_0_95
if_then_0_94:
  %.p916 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.134, i64 0, i64 0
  ret i8* %.p916
if_next_0_95:
  br label %if_end_93
if_end_93:
  %.r917 = load i8*, i8** %k
  %.p918 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.78, i64 0, i64 0
  %.r919 = call i32 @strcmp(i8* %.r917, i8* %.p918)
  %.t32 = icmp eq i32 %.r919, 0
  br i1 %.t32, label %if_then_0_97, label %if_next_0_98
if_then_0_97:
  %.p920 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.135, i64 0, i64 0
  ret i8* %.p920
if_next_0_98:
  br label %if_end_96
if_end_96:
  %.r921 = load i8*, i8** %k
  %.p922 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.80, i64 0, i64 0
  %.r923 = call i32 @strcmp(i8* %.r921, i8* %.p922)
  %.t33 = icmp eq i32 %.r923, 0
  br i1 %.t33, label %if_then_0_100, label %if_next_0_101
if_then_0_100:
  %.p924 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.136, i64 0, i64 0
  ret i8* %.p924
if_next_0_101:
  br label %if_end_99
if_end_99:
  %.r925 = load i8*, i8** %k
  %.p926 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.82, i64 0, i64 0
  %.r927 = call i32 @strcmp(i8* %.r925, i8* %.p926)
  %.t34 = icmp eq i32 %.r927, 0
  br i1 %.t34, label %if_then_0_103, label %if_next_0_104
if_then_0_103:
  %.p928 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.137, i64 0, i64 0
  ret i8* %.p928
if_next_0_104:
  br label %if_end_102
if_end_102:
  %.r929 = load i8*, i8** %k
  %.p930 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.84, i64 0, i64 0
  %.r931 = call i32 @strcmp(i8* %.r929, i8* %.p930)
  %.t35 = icmp eq i32 %.r931, 0
  br i1 %.t35, label %if_then_0_106, label %if_next_0_107
if_then_0_106:
  %.p932 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.138, i64 0, i64 0
  ret i8* %.p932
if_next_0_107:
  br label %if_end_105
if_end_105:
  %.r933 = load i8*, i8** %k
  %.p934 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.86, i64 0, i64 0
  %.r935 = call i32 @strcmp(i8* %.r933, i8* %.p934)
  %.t36 = icmp eq i32 %.r935, 0
  br i1 %.t36, label %if_then_0_109, label %if_next_0_110
if_then_0_109:
  %.p936 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.139, i64 0, i64 0
  ret i8* %.p936
if_next_0_110:
  br label %if_end_108
if_end_108:
  %.r937 = load i8*, i8** %k
  %.p938 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.88, i64 0, i64 0
  %.r939 = call i32 @strcmp(i8* %.r937, i8* %.p938)
  %.t37 = icmp eq i32 %.r939, 0
  br i1 %.t37, label %if_then_0_112, label %if_next_0_113
if_then_0_112:
  %.p940 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.140, i64 0, i64 0
  ret i8* %.p940
if_next_0_113:
  br label %if_end_111
if_end_111:
  %.r941 = load i8*, i8** %k
  %.p942 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.90, i64 0, i64 0
  %.r943 = call i32 @strcmp(i8* %.r941, i8* %.p942)
  %.t38 = icmp eq i32 %.r943, 0
  br i1 %.t38, label %if_then_0_115, label %if_next_0_116
if_then_0_115:
  %.p944 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.141, i64 0, i64 0
  ret i8* %.p944
if_next_0_116:
  br label %if_end_114
if_end_114:
  %.r945 = load i8*, i8** %k
  %.p946 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.142, i64 0, i64 0
  %.r947 = call i32 @strcmp(i8* %.r945, i8* %.p946)
  %.t39 = icmp eq i32 %.r947, 0
  br i1 %.t39, label %if_then_0_118, label %if_next_0_119
if_then_0_118:
  %.p948 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.143, i64 0, i64 0
  ret i8* %.p948
if_next_0_119:
  br label %if_end_117
if_end_117:
  %.r949 = load i8*, i8** %k
  %.p950 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.144, i64 0, i64 0
  %.r951 = call i32 @strcmp(i8* %.r949, i8* %.p950)
  %.t40 = icmp eq i32 %.r951, 0
  br i1 %.t40, label %if_then_0_121, label %if_next_0_122
if_then_0_121:
  %.p952 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.145, i64 0, i64 0
  ret i8* %.p952
if_next_0_122:
  br label %if_end_120
if_end_120:
  %.r953 = load i8*, i8** %k
  %.p954 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.146, i64 0, i64 0
  %.r955 = call i32 @strcmp(i8* %.r953, i8* %.p954)
  %.t41 = icmp eq i32 %.r955, 0
  br i1 %.t41, label %if_then_0_124, label %if_next_0_125
if_then_0_124:
  %.p956 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.147, i64 0, i64 0
  ret i8* %.p956
if_next_0_125:
  br label %if_end_123
if_end_123:
  %.r957 = load i8*, i8** %k
  %.p958 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.148, i64 0, i64 0
  %.r959 = call i32 @strcmp(i8* %.r957, i8* %.p958)
  %.t42 = icmp eq i32 %.r959, 0
  br i1 %.t42, label %if_then_0_127, label %if_next_0_128
if_then_0_127:
  %.p960 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.149, i64 0, i64 0
  ret i8* %.p960
if_next_0_128:
  br label %if_end_126
if_end_126:
  %.r961 = load i8*, i8** %k
  %.p962 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.150, i64 0, i64 0
  %.r963 = call i32 @strcmp(i8* %.r961, i8* %.p962)
  %.t43 = icmp eq i32 %.r963, 0
  br i1 %.t43, label %if_then_0_130, label %if_next_0_131
if_then_0_130:
  %.p964 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.151, i64 0, i64 0
  ret i8* %.p964
if_next_0_131:
  br label %if_end_129
if_end_129:
  %.r965 = load i8*, i8** %k
  %.p966 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.152, i64 0, i64 0
  %.r967 = call i32 @strcmp(i8* %.r965, i8* %.p966)
  %.t44 = icmp eq i32 %.r967, 0
  br i1 %.t44, label %if_then_0_133, label %if_next_0_134
if_then_0_133:
  %.p968 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.153, i64 0, i64 0
  ret i8* %.p968
if_next_0_134:
  br label %if_end_132
if_end_132:
  %.r969 = load i8*, i8** %k
  %.p970 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.154, i64 0, i64 0
  %.r971 = call i32 @strcmp(i8* %.r969, i8* %.p970)
  %.t45 = icmp eq i32 %.r971, 0
  br i1 %.t45, label %if_then_0_136, label %if_next_0_137
if_then_0_136:
  %.p972 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.155, i64 0, i64 0
  ret i8* %.p972
if_next_0_137:
  br label %if_end_135
if_end_135:
  %.r973 = load i8*, i8** %k
  %.p974 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.156, i64 0, i64 0
  %.r975 = call i32 @strcmp(i8* %.r973, i8* %.p974)
  %.t46 = icmp eq i32 %.r975, 0
  br i1 %.t46, label %if_then_0_139, label %if_next_0_140
if_then_0_139:
  %.p976 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.157, i64 0, i64 0
  ret i8* %.p976
if_next_0_140:
  br label %if_end_138
if_end_138:
  %.r977 = load i8*, i8** %k
  %.p978 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.158, i64 0, i64 0
  %.r979 = call i32 @strcmp(i8* %.r977, i8* %.p978)
  %.t47 = icmp eq i32 %.r979, 0
  br i1 %.t47, label %if_then_0_142, label %if_next_0_143
if_then_0_142:
  %.p980 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.159, i64 0, i64 0
  ret i8* %.p980
if_next_0_143:
  br label %if_end_141
if_end_141:
  %.r981 = load i8*, i8** %k
  %.p982 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.160, i64 0, i64 0
  %.r983 = call i32 @strcmp(i8* %.r981, i8* %.p982)
  %.t48 = icmp eq i32 %.r983, 0
  br i1 %.t48, label %if_then_0_145, label %if_next_0_146
if_then_0_145:
  %.p984 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.161, i64 0, i64 0
  ret i8* %.p984
if_next_0_146:
  br label %if_end_144
if_end_144:
  %.r985 = load i8*, i8** %k
  %.p986 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.162, i64 0, i64 0
  %.r987 = call i32 @strcmp(i8* %.r985, i8* %.p986)
  %.t49 = icmp eq i32 %.r987, 0
  br i1 %.t49, label %if_then_0_148, label %if_next_0_149
if_then_0_148:
  %.p988 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.163, i64 0, i64 0
  ret i8* %.p988
if_next_0_149:
  br label %if_end_147
if_end_147:
  %.r989 = load i8*, i8** %k
  %.p990 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.164, i64 0, i64 0
  %.r991 = call i32 @strcmp(i8* %.r989, i8* %.p990)
  %.t50 = icmp eq i32 %.r991, 0
  br i1 %.t50, label %if_then_0_151, label %if_next_0_152
if_then_0_151:
  %.p992 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.165, i64 0, i64 0
  ret i8* %.p992
if_next_0_152:
  br label %if_end_150
if_end_150:
  %.r993 = load i8*, i8** %k
  %.p994 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.166, i64 0, i64 0
  %.r995 = call i32 @strcmp(i8* %.r993, i8* %.p994)
  %.t51 = icmp eq i32 %.r995, 0
  br i1 %.t51, label %if_then_0_154, label %if_next_0_155
if_then_0_154:
  %.p996 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.167, i64 0, i64 0
  ret i8* %.p996
if_next_0_155:
  br label %if_end_153
if_end_153:
  %.r997 = load i8*, i8** %k
  %.p998 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.168, i64 0, i64 0
  %.r999 = call i32 @strcmp(i8* %.r997, i8* %.p998)
  %.t52 = icmp eq i32 %.r999, 0
  br i1 %.t52, label %if_then_0_157, label %if_next_0_158
if_then_0_157:
  %.p1000 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.169, i64 0, i64 0
  ret i8* %.p1000
if_next_0_158:
  br label %if_end_156
if_end_156:
  %.r1001 = load i8*, i8** %k
  %.p1002 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.170, i64 0, i64 0
  %.r1003 = call i32 @strcmp(i8* %.r1001, i8* %.p1002)
  %.t53 = icmp eq i32 %.r1003, 0
  br i1 %.t53, label %if_then_0_160, label %if_next_0_161
if_then_0_160:
  %.p1004 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.171, i64 0, i64 0
  ret i8* %.p1004
if_next_0_161:
  br label %if_end_159
if_end_159:
  %.r1005 = load i8*, i8** %k
  %.p1006 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.172, i64 0, i64 0
  %.r1007 = call i32 @strcmp(i8* %.r1005, i8* %.p1006)
  %.t54 = icmp eq i32 %.r1007, 0
  br i1 %.t54, label %if_then_0_163, label %if_next_0_164
if_then_0_163:
  %.p1008 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.173, i64 0, i64 0
  ret i8* %.p1008
if_next_0_164:
  br label %if_end_162
if_end_162:
  %.r1009 = load i8*, i8** %k
  %.p1010 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.174, i64 0, i64 0
  %.r1011 = call i32 @strcmp(i8* %.r1009, i8* %.p1010)
  %.t55 = icmp eq i32 %.r1011, 0
  br i1 %.t55, label %if_then_0_166, label %if_next_0_167
if_then_0_166:
  %.p1012 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.175, i64 0, i64 0
  ret i8* %.p1012
if_next_0_167:
  br label %if_end_165
if_end_165:
  %.r1013 = load i8*, i8** %k
  %.p1014 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.176, i64 0, i64 0
  %.r1015 = call i32 @strcmp(i8* %.r1013, i8* %.p1014)
  %.t56 = icmp eq i32 %.r1015, 0
  br i1 %.t56, label %if_then_0_169, label %if_next_0_170
if_then_0_169:
  %.p1016 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.177, i64 0, i64 0
  ret i8* %.p1016
if_next_0_170:
  br label %if_end_168
if_end_168:
  %.r1017 = load i8*, i8** %k
  %.p1018 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.178, i64 0, i64 0
  %.r1019 = call i32 @strcmp(i8* %.r1017, i8* %.p1018)
  %.t57 = icmp eq i32 %.r1019, 0
  br i1 %.t57, label %if_then_0_172, label %if_next_0_173
if_then_0_172:
  %.p1020 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.179, i64 0, i64 0
  ret i8* %.p1020
if_next_0_173:
  br label %if_end_171
if_end_171:
  %.r1021 = load i8*, i8** %k
  %.p1022 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.180, i64 0, i64 0
  %.r1023 = call i32 @strcmp(i8* %.r1021, i8* %.p1022)
  %.t58 = icmp eq i32 %.r1023, 0
  br i1 %.t58, label %if_then_0_175, label %if_next_0_176
if_then_0_175:
  %.p1024 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.181, i64 0, i64 0
  ret i8* %.p1024
if_next_0_176:
  br label %if_end_174
if_end_174:
  %.r1025 = load i8*, i8** %k
  %.p1026 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.182, i64 0, i64 0
  %.r1027 = call i32 @strcmp(i8* %.r1025, i8* %.p1026)
  %.t59 = icmp eq i32 %.r1027, 0
  br i1 %.t59, label %if_then_0_178, label %if_next_0_179
if_then_0_178:
  %.p1028 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.183, i64 0, i64 0
  ret i8* %.p1028
if_next_0_179:
  br label %if_end_177
if_end_177:
  %.r1029 = load i8*, i8** %k
  %.p1030 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.184, i64 0, i64 0
  %.r1031 = call i32 @strcmp(i8* %.r1029, i8* %.p1030)
  %.t60 = icmp eq i32 %.r1031, 0
  br i1 %.t60, label %if_then_0_181, label %if_next_0_182
if_then_0_181:
  %.p1032 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.185, i64 0, i64 0
  ret i8* %.p1032
if_next_0_182:
  br label %if_end_180
if_end_180:
  %.r1033 = load i8*, i8** %k
  %.p1034 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.186, i64 0, i64 0
  %.r1035 = call i32 @strcmp(i8* %.r1033, i8* %.p1034)
  %.t61 = icmp eq i32 %.r1035, 0
  br i1 %.t61, label %if_then_0_184, label %if_next_0_185
if_then_0_184:
  %.p1036 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.187, i64 0, i64 0
  ret i8* %.p1036
if_next_0_185:
  br label %if_end_183
if_end_183:
  %.r1037 = load i8*, i8** %k
  %.p1038 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.188, i64 0, i64 0
  %.r1039 = call i32 @strcmp(i8* %.r1037, i8* %.p1038)
  %.t62 = icmp eq i32 %.r1039, 0
  br i1 %.t62, label %if_then_0_187, label %if_next_0_188
if_then_0_187:
  %.p1040 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.189, i64 0, i64 0
  ret i8* %.p1040
if_next_0_188:
  br label %if_end_186
if_end_186:
  %.r1041 = load i8*, i8** %k
  %.p1042 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.190, i64 0, i64 0
  %.r1043 = call i32 @strcmp(i8* %.r1041, i8* %.p1042)
  %.t63 = icmp eq i32 %.r1043, 0
  br i1 %.t63, label %if_then_0_190, label %if_next_0_191
if_then_0_190:
  %.p1044 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.191, i64 0, i64 0
  ret i8* %.p1044
if_next_0_191:
  br label %if_end_189
if_end_189:
  %.r1045 = load i8*, i8** %k
  %.p1046 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.192, i64 0, i64 0
  %.r1047 = call i32 @strcmp(i8* %.r1045, i8* %.p1046)
  %.t64 = icmp eq i32 %.r1047, 0
  br i1 %.t64, label %if_then_0_193, label %if_next_0_194
if_then_0_193:
  %.p1048 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.193, i64 0, i64 0
  ret i8* %.p1048
if_next_0_194:
  br label %if_end_192
if_end_192:
  %.r1049 = load i8*, i8** %k
  %.p1050 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.194, i64 0, i64 0
  %.r1051 = call i32 @strcmp(i8* %.r1049, i8* %.p1050)
  %.t65 = icmp eq i32 %.r1051, 0
  br i1 %.t65, label %if_then_0_196, label %if_next_0_197
if_then_0_196:
  %.p1052 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.195, i64 0, i64 0
  ret i8* %.p1052
if_next_0_197:
  br label %if_end_195
if_end_195:
  %.r1053 = load i8*, i8** %k
  %.p1054 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.196, i64 0, i64 0
  %.r1055 = call i32 @strcmp(i8* %.r1053, i8* %.p1054)
  %.t66 = icmp eq i32 %.r1055, 0
  br i1 %.t66, label %if_then_0_199, label %if_next_0_200
if_then_0_199:
  %.p1056 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.197, i64 0, i64 0
  ret i8* %.p1056
if_next_0_200:
  br label %if_end_198
if_end_198:
  %.r1057 = load i8*, i8** %k
  %.p1058 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.198, i64 0, i64 0
  %.r1059 = call i32 @strcmp(i8* %.r1057, i8* %.p1058)
  %.t67 = icmp eq i32 %.r1059, 0
  br i1 %.t67, label %if_then_0_202, label %if_next_0_203
if_then_0_202:
  %.p1060 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.199, i64 0, i64 0
  ret i8* %.p1060
if_next_0_203:
  br label %if_end_201
if_end_201:
  %.r1061 = load i8*, i8** %k
  %.p1062 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.200, i64 0, i64 0
  %.r1063 = call i32 @strcmp(i8* %.r1061, i8* %.p1062)
  %.t68 = icmp eq i32 %.r1063, 0
  br i1 %.t68, label %if_then_0_205, label %if_next_0_206
if_then_0_205:
  %.p1064 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.201, i64 0, i64 0
  ret i8* %.p1064
if_next_0_206:
  br label %if_end_204
if_end_204:
  %.r1065 = load i8*, i8** %k
  %.p1066 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.202, i64 0, i64 0
  %.r1067 = call i32 @strcmp(i8* %.r1065, i8* %.p1066)
  %.t69 = icmp eq i32 %.r1067, 0
  br i1 %.t69, label %if_then_0_208, label %if_next_0_209
if_then_0_208:
  %.p1068 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.203, i64 0, i64 0
  ret i8* %.p1068
if_next_0_209:
  br label %if_end_207
if_end_207:
  %.r1069 = load i8*, i8** %k
  %.p1070 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.204, i64 0, i64 0
  %.r1071 = call i32 @strcmp(i8* %.r1069, i8* %.p1070)
  %.t70 = icmp eq i32 %.r1071, 0
  br i1 %.t70, label %if_then_0_211, label %if_next_0_212
if_then_0_211:
  %.p1072 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.205, i64 0, i64 0
  ret i8* %.p1072
if_next_0_212:
  br label %if_end_210
if_end_210:
  %.r1073 = load i8*, i8** %k
  %.p1074 = getelementptr inbounds [10 x i8], [10 x i8]* @.str.206, i64 0, i64 0
  %.r1075 = call i32 @strcmp(i8* %.r1073, i8* %.p1074)
  %.t71 = icmp eq i32 %.r1075, 0
  br i1 %.t71, label %if_then_0_214, label %if_next_0_215
if_then_0_214:
  %.p1076 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.207, i64 0, i64 0
  ret i8* %.p1076
if_next_0_215:
  br label %if_end_213
if_end_213:
  %.r1077 = load i8*, i8** %k
  %.p1078 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.208, i64 0, i64 0
  %.r1079 = call i32 @strcmp(i8* %.r1077, i8* %.p1078)
  %.t72 = icmp eq i32 %.r1079, 0
  br i1 %.t72, label %if_then_0_217, label %if_next_0_218
if_then_0_217:
  %.p1080 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.209, i64 0, i64 0
  ret i8* %.p1080
if_next_0_218:
  br label %if_end_216
if_end_216:
  %.r1081 = load i8*, i8** %k
  %.p1082 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.210, i64 0, i64 0
  %.r1083 = call i32 @strcmp(i8* %.r1081, i8* %.p1082)
  %.t73 = icmp eq i32 %.r1083, 0
  br i1 %.t73, label %if_then_0_220, label %if_next_0_221
if_then_0_220:
  %.p1084 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.211, i64 0, i64 0
  ret i8* %.p1084
if_next_0_221:
  br label %if_end_219
if_end_219:
  %.r1085 = load i8*, i8** %k
  %.p1086 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.212, i64 0, i64 0
  %.r1087 = call i32 @strcmp(i8* %.r1085, i8* %.p1086)
  %.t74 = icmp eq i32 %.r1087, 0
  br i1 %.t74, label %if_then_0_223, label %if_next_0_224
if_then_0_223:
  %.p1088 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.213, i64 0, i64 0
  ret i8* %.p1088
if_next_0_224:
  br label %if_end_222
if_end_222:
  %.r1089 = load i8*, i8** %k
  %.p1090 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.214, i64 0, i64 0
  %.r1091 = call i32 @strcmp(i8* %.r1089, i8* %.p1090)
  %.t75 = icmp eq i32 %.r1091, 0
  br i1 %.t75, label %if_then_0_226, label %if_next_0_227
if_then_0_226:
  %.p1092 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.215, i64 0, i64 0
  ret i8* %.p1092
if_next_0_227:
  br label %if_end_225
if_end_225:
  %.r1093 = load i8*, i8** %k
  %.p1094 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.216, i64 0, i64 0
  %.r1095 = call i32 @strcmp(i8* %.r1093, i8* %.p1094)
  %.t76 = icmp eq i32 %.r1095, 0
  br i1 %.t76, label %if_then_0_229, label %if_next_0_230
if_then_0_229:
  %.p1096 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.217, i64 0, i64 0
  ret i8* %.p1096
if_next_0_230:
  br label %if_end_228
if_end_228:
  %.r1097 = load i8*, i8** %k
  %.p1098 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.r1099 = call i32 @strcmp(i8* %.r1097, i8* %.p1098)
  %.t77 = icmp eq i32 %.r1099, 0
  br i1 %.t77, label %if_then_0_232, label %if_next_0_233
if_then_0_232:
  %.p1100 = getelementptr inbounds [12 x i8], [12 x i8]* @.str.219, i64 0, i64 0
  ret i8* %.p1100
if_next_0_233:
  br label %if_end_231
if_end_231:
  %.r1101 = load i8*, i8** %k
  %.p1102 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.220, i64 0, i64 0
  %.r1103 = call i32 @strcmp(i8* %.r1101, i8* %.p1102)
  %.t78 = icmp eq i32 %.r1103, 0
  br i1 %.t78, label %if_then_0_235, label %if_next_0_236
if_then_0_235:
  %.p1104 = getelementptr inbounds [12 x i8], [12 x i8]* @.str.221, i64 0, i64 0
  ret i8* %.p1104
if_next_0_236:
  br label %if_end_234
if_end_234:
  %.r1105 = load i8*, i8** %k
  %.p1106 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.222, i64 0, i64 0
  %.r1107 = call i32 @strcmp(i8* %.r1105, i8* %.p1106)
  %.t79 = icmp eq i32 %.r1107, 0
  br i1 %.t79, label %if_then_0_238, label %if_next_0_239
if_then_0_238:
  %.p1108 = getelementptr inbounds [22 x i8], [22 x i8]* @.str.223, i64 0, i64 0
  ret i8* %.p1108
if_next_0_239:
  br label %if_end_237
if_end_237:
  %.r1109 = load i8*, i8** %k
  %.p1110 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.224, i64 0, i64 0
  %.r1111 = call i32 @strcmp(i8* %.r1109, i8* %.p1110)
  %.t80 = icmp eq i32 %.r1111, 0
  br i1 %.t80, label %if_then_0_241, label %if_next_0_242
if_then_0_241:
  %.p1112 = getelementptr inbounds [12 x i8], [12 x i8]* @.str.225, i64 0, i64 0
  ret i8* %.p1112
if_next_0_242:
  br label %if_end_240
if_end_240:
  %.t81 = load i8*, i8** %k
  ret i8* %.t81
}

define i1 @is_alphabetic_cp(i64 %c.arg) {
entry:
  %c = alloca i64
  %__sc.1 = alloca i1
  %__sc.2 = alloca i1
  %__sc.5 = alloca i1
  %__sc.9 = alloca i1
  %__sc.10 = alloca i1
  %__sc.15 = alloca i1
  %__sc.18 = alloca i1
  %__sc.21 = alloca i1
  store i64 %c.arg, i64* %c
  %.r1113 = load i64, i64* %c
  %.t0 = icmp slt i64 %.r1113, 128
  br i1 %.t0, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.r1114 = load i64, i64* %c
  %.t3 = icmp sge i64 %.r1114, 97
  br i1 %.t3, label %sc_rhs_3, label %sc_short_4
sc_rhs_3:
  %.r1115 = load i64, i64* %c
  %.t4 = icmp sle i64 %.r1115, 122
  store i1 %.t4, i1* %__sc.2
  br label %sc_end_5
sc_short_4:
  store i1 false, i1* %__sc.2
  br label %sc_end_5
sc_end_5:
  %.r1116 = load i1, i1* %__sc.2
  br i1 %.r1116, label %sc_short_7, label %sc_rhs_6
sc_rhs_6:
  %.r1117 = load i64, i64* %c
  %.t6 = icmp sge i64 %.r1117, 65
  br i1 %.t6, label %sc_rhs_9, label %sc_short_10
sc_rhs_9:
  %.r1118 = load i64, i64* %c
  %.t7 = icmp sle i64 %.r1118, 90
  store i1 %.t7, i1* %__sc.5
  br label %sc_end_11
sc_short_10:
  store i1 false, i1* %__sc.5
  br label %sc_end_11
sc_end_11:
  %.r1119 = load i1, i1* %__sc.5
  store i1 %.r1119, i1* %__sc.1
  br label %sc_end_8
sc_short_7:
  store i1 true, i1* %__sc.1
  br label %sc_end_8
sc_end_8:
  %.t8 = load i1, i1* %__sc.1
  ret i1 %.t8
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.r1120 = load i64, i64* %c
  %.t11 = icmp eq i64 %.r1120, 170
  br i1 %.t11, label %sc_short_16, label %sc_rhs_15
sc_rhs_15:
  %.r1121 = load i64, i64* %c
  %.t12 = icmp eq i64 %.r1121, 181
  store i1 %.t12, i1* %__sc.10
  br label %sc_end_17
sc_short_16:
  store i1 true, i1* %__sc.10
  br label %sc_end_17
sc_end_17:
  %.r1122 = load i1, i1* %__sc.10
  br i1 %.r1122, label %sc_short_19, label %sc_rhs_18
sc_rhs_18:
  %.r1123 = load i64, i64* %c
  %.t13 = icmp eq i64 %.r1123, 186
  store i1 %.t13, i1* %__sc.9
  br label %sc_end_20
sc_short_19:
  store i1 true, i1* %__sc.9
  br label %sc_end_20
sc_end_20:
  %.r1124 = load i1, i1* %__sc.9
  br i1 %.r1124, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  ret i1 true
if_next_0_14:
  br label %if_end_12
if_end_12:
  %.r1125 = load i64, i64* %c
  %.t14 = icmp slt i64 %.r1125, 192
  br i1 %.t14, label %if_then_0_22, label %if_next_0_23
if_then_0_22:
  ret i1 false
if_next_0_23:
  br label %if_end_21
if_end_21:
  %.r1126 = load i64, i64* %c
  %.t16 = icmp eq i64 %.r1126, 215
  br i1 %.t16, label %sc_short_28, label %sc_rhs_27
sc_rhs_27:
  %.r1127 = load i64, i64* %c
  %.t17 = icmp eq i64 %.r1127, 247
  store i1 %.t17, i1* %__sc.15
  br label %sc_end_29
sc_short_28:
  store i1 true, i1* %__sc.15
  br label %sc_end_29
sc_end_29:
  %.r1128 = load i1, i1* %__sc.15
  br i1 %.r1128, label %if_then_0_25, label %if_next_0_26
if_then_0_25:
  ret i1 false
if_next_0_26:
  br label %if_end_24
if_end_24:
  %.r1129 = load i64, i64* %c
  %.t19 = icmp sge i64 %.r1129, 8192
  br i1 %.t19, label %sc_rhs_33, label %sc_short_34
sc_rhs_33:
  %.r1130 = load i64, i64* %c
  %.t20 = icmp sle i64 %.r1130, 11263
  store i1 %.t20, i1* %__sc.18
  br label %sc_end_35
sc_short_34:
  store i1 false, i1* %__sc.18
  br label %sc_end_35
sc_end_35:
  %.r1131 = load i1, i1* %__sc.18
  br i1 %.r1131, label %if_then_0_31, label %if_next_0_32
if_then_0_31:
  ret i1 false
if_next_0_32:
  br label %if_end_30
if_end_30:
  %.r1132 = load i64, i64* %c
  %.t22 = icmp sge i64 %.r1132, 12288
  br i1 %.t22, label %sc_rhs_39, label %sc_short_40
sc_rhs_39:
  %.r1133 = load i64, i64* %c
  %.t23 = icmp sle i64 %.r1133, 12351
  store i1 %.t23, i1* %__sc.21
  br label %sc_end_41
sc_short_40:
  store i1 false, i1* %__sc.21
  br label %sc_end_41
sc_end_41:
  %.r1134 = load i1, i1* %__sc.21
  br i1 %.r1134, label %if_then_0_37, label %if_next_0_38
if_then_0_37:
  ret i1 false
if_next_0_38:
  br label %if_end_36
if_end_36:
  %.r1135 = load i64, i64* %c
  %.t24 = icmp sge i64 %.r1135, 126976
  br i1 %.t24, label %if_then_0_43, label %if_next_0_44
if_then_0_43:
  %.r1136 = load i64, i64* %c
  %.t25 = icmp sge i64 %.r1136, 131072
  ret i1 %.t25
if_next_0_44:
  br label %if_end_42
if_end_42:
  ret i1 true
}

define i1 @is_digit_cp(i64 %c.arg) {
entry:
  %c = alloca i64
  %__sc.0 = alloca i1
  store i64 %c.arg, i64* %c
  %.r1137 = load i64, i64* %c
  %.t1 = icmp sge i64 %.r1137, 48
  br i1 %.t1, label %sc_rhs_0, label %sc_short_1
sc_rhs_0:
  %.r1138 = load i64, i64* %c
  %.t2 = icmp sle i64 %.r1138, 57
  store i1 %.t2, i1* %__sc.0
  br label %sc_end_2
sc_short_1:
  store i1 false, i1* %__sc.0
  br label %sc_end_2
sc_end_2:
  %.t3 = load i1, i1* %__sc.0
  ret i1 %.t3
}

define i1 @is_ident_start_cp(i64 %c.arg) {
entry:
  %c = alloca i64
  %__sc.0 = alloca i1
  store i64 %c.arg, i64* %c
  %.r1139 = load i64, i64* %c
  %.t1 = call i1 @is_alphabetic_cp(i64 %.r1139)
  br i1 %.t1, label %sc_short_1, label %sc_rhs_0
sc_rhs_0:
  %.r1140 = load i64, i64* %c
  %.t2 = icmp eq i64 %.r1140, 95
  store i1 %.t2, i1* %__sc.0
  br label %sc_end_2
sc_short_1:
  store i1 true, i1* %__sc.0
  br label %sc_end_2
sc_end_2:
  %.t3 = load i1, i1* %__sc.0
  ret i1 %.t3
}

define i1 @is_ident_continue_cp(i64 %c.arg) {
entry:
  %c = alloca i64
  %__sc.0 = alloca i1
  %__sc.1 = alloca i1
  store i64 %c.arg, i64* %c
  %.r1141 = load i64, i64* %c
  %.t2 = call i1 @is_alphabetic_cp(i64 %.r1141)
  br i1 %.t2, label %sc_short_1, label %sc_rhs_0
sc_rhs_0:
  %.r1142 = load i64, i64* %c
  %.t3 = call i1 @is_digit_cp(i64 %.r1142)
  store i1 %.t3, i1* %__sc.1
  br label %sc_end_2
sc_short_1:
  store i1 true, i1* %__sc.1
  br label %sc_end_2
sc_end_2:
  %.r1143 = load i1, i1* %__sc.1
  br i1 %.r1143, label %sc_short_4, label %sc_rhs_3
sc_rhs_3:
  %.r1144 = load i64, i64* %c
  %.t4 = icmp eq i64 %.r1144, 95
  store i1 %.t4, i1* %__sc.0
  br label %sc_end_5
sc_short_4:
  store i1 true, i1* %__sc.0
  br label %sc_end_5
sc_end_5:
  %.t5 = load i1, i1* %__sc.0
  ret i1 %.t5
}

define void @Lexer__init(%Lexer* %self, i8* %source.arg) {
entry:
  %source = alloca i8*
  %i = alloca i64
  %n = alloca i64
  %b = alloca i64
  %size = alloca i64
  %cp = alloca i64
  store i8* %source.arg, i8** %source
  %.r1145 = load i8*, i8** %source
  %.p1146 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 0
  store i8* %.r1145, i8** %.p1146
  %.p1147 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 3
  store i64 0, i64* %.p1147
  %.p1148 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 4
  store i64 1, i64* %.p1148
  %.p1149 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 5
  store i64 1, i64* %.p1149
  %.p1150 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 8
  store i64 0, i64* %.p1150
  store i64 0, i64* %i
  %.r1151 = load i8*, i8** %source
  %.t0 = call i64 @strlen(i8* %.r1151)
  store i64 %.t0, i64* %n
  br label %while_cond_0
while_cond_0:
  %.r1152 = load i64, i64* %i
  %.r1153 = load i64, i64* %n
  %.t1 = icmp slt i64 %.r1152, %.r1153
  br i1 %.t1, label %while_body_1, label %while_end_2
while_body_1:
  %.r1154 = load i8*, i8** %source
  %.r1155 = load i64, i64* %i
  %.p1156 = getelementptr inbounds i8, i8* %.r1154, i64 %.r1155
  %.r1157 = load i8, i8* %.p1156
  %.t2 = zext i8 %.r1157 to i64
  store i64 %.t2, i64* %b
  store i64 1, i64* %size
  %.r1158 = load i64, i64* %b
  store i64 %.r1158, i64* %cp
  %.r1159 = load i64, i64* %b
  %.t3 = icmp sge i64 %.r1159, 240
  br i1 %.t3, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  store i64 4, i64* %size
  %.r1160 = load i64, i64* %b
  %.t4 = and i64 %.r1160, 7
  %.t5 = shl i64 %.t4, 18
  %.r1161 = load i64, i64* %i
  %.t6 = add i64 %.r1161, 1
  %.r1162 = load i8*, i8** %source
  %.p1163 = getelementptr inbounds i8, i8* %.r1162, i64 %.t6
  %.r1164 = load i8, i8* %.p1163
  %.t7 = zext i8 %.r1164 to i64
  %.t8 = and i64 %.t7, 63
  %.t9 = shl i64 %.t8, 12
  %.t10 = or i64 %.t5, %.t9
  %.r1165 = load i64, i64* %i
  %.t11 = add i64 %.r1165, 2
  %.r1166 = load i8*, i8** %source
  %.p1167 = getelementptr inbounds i8, i8* %.r1166, i64 %.t11
  %.r1168 = load i8, i8* %.p1167
  %.t12 = zext i8 %.r1168 to i64
  %.t13 = and i64 %.t12, 63
  %.t14 = shl i64 %.t13, 6
  %.t15 = or i64 %.t10, %.t14
  %.r1169 = load i64, i64* %i
  %.t16 = add i64 %.r1169, 3
  %.r1170 = load i8*, i8** %source
  %.p1171 = getelementptr inbounds i8, i8* %.r1170, i64 %.t16
  %.r1172 = load i8, i8* %.p1171
  %.t17 = zext i8 %.r1172 to i64
  %.t18 = and i64 %.t17, 63
  %.t19 = or i64 %.t15, %.t18
  store i64 %.t19, i64* %cp
  br label %if_end_3
if_next_0_5:
  %.r1173 = load i64, i64* %b
  %.t20 = icmp sge i64 %.r1173, 224
  br i1 %.t20, label %if_then_1_6, label %if_next_1_7
if_then_1_6:
  store i64 3, i64* %size
  %.r1174 = load i64, i64* %b
  %.t21 = and i64 %.r1174, 15
  %.t22 = shl i64 %.t21, 12
  %.r1175 = load i64, i64* %i
  %.t23 = add i64 %.r1175, 1
  %.r1176 = load i8*, i8** %source
  %.p1177 = getelementptr inbounds i8, i8* %.r1176, i64 %.t23
  %.r1178 = load i8, i8* %.p1177
  %.t24 = zext i8 %.r1178 to i64
  %.t25 = and i64 %.t24, 63
  %.t26 = shl i64 %.t25, 6
  %.t27 = or i64 %.t22, %.t26
  %.r1179 = load i64, i64* %i
  %.t28 = add i64 %.r1179, 2
  %.r1180 = load i8*, i8** %source
  %.p1181 = getelementptr inbounds i8, i8* %.r1180, i64 %.t28
  %.r1182 = load i8, i8* %.p1181
  %.t29 = zext i8 %.r1182 to i64
  %.t30 = and i64 %.t29, 63
  %.t31 = or i64 %.t27, %.t30
  store i64 %.t31, i64* %cp
  br label %if_end_3
if_next_1_7:
  %.r1183 = load i64, i64* %b
  %.t32 = icmp sge i64 %.r1183, 192
  br i1 %.t32, label %if_then_2_8, label %if_next_2_9
if_then_2_8:
  store i64 2, i64* %size
  %.r1184 = load i64, i64* %b
  %.t33 = and i64 %.r1184, 31
  %.t34 = shl i64 %.t33, 6
  %.r1185 = load i64, i64* %i
  %.t35 = add i64 %.r1185, 1
  %.r1186 = load i8*, i8** %source
  %.p1187 = getelementptr inbounds i8, i8* %.r1186, i64 %.t35
  %.r1188 = load i8, i8* %.p1187
  %.t36 = zext i8 %.r1188 to i64
  %.t37 = and i64 %.t36, 63
  %.t38 = or i64 %.t34, %.t37
  store i64 %.t38, i64* %cp
  br label %if_end_3
if_next_2_9:
  br label %if_end_3
if_end_3:
  %__fld.39 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 1
  %.p1189 = getelementptr i64, i64* null, i32 1
  %.r1190 = ptrtoint i64* %.p1189 to i64
  %.p1191 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.39, i32 0, i32 0
  %.p1192 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.39, i32 0, i32 1
  %.p1193 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.39, i32 0, i32 2
  %.r1194 = load i64, i64* %.p1191
  %.r1195 = load i64, i64* %.p1192
  %.r1196 = icmp sge i64 %.r1194, %.r1195
  br i1 %.r1196, label %append.grow.1197, label %append.after.1198
append.grow.1197:
  %.r1199 = load i64*, i64** %.p1193
  %.r1200 = icmp eq i64 %.r1195, 0
  %.r1201 = mul i64 %.r1195, 2
  %.r1202 = select i1 %.r1200, i64 1, i64 %.r1201
  %.r1203 = mul i64 %.r1202, %.r1190
  %.p1204 = call i8* @malloc(i64 %.r1203)
  %.p1205 = bitcast i8* %.p1204 to i64*
  %.r1206 = mul i64 %.r1194, %.r1190
  %.p1207 = bitcast i64* %.r1199 to i8*
  call i8* @memcpy(i8* %.p1204, i8* %.p1207, i64 %.r1206)
  call void @free(i8* %.p1207)
  store i64* %.p1205, i64** %.p1193
  store i64 %.r1202, i64* %.p1192
  br label %append.after.1198
append.after.1198:
  %.r1208 = load i64*, i64** %.p1193
  %.r1209 = load i64, i64* %cp
  %.p1210 = getelementptr inbounds i64, i64* %.r1208, i64 %.r1194
  store i64 %.r1209, i64* %.p1210
  %.r1211 = add i64 %.r1194, 1
  store i64 %.r1211, i64* %.p1191
  %__fld.40 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 2
  %.p1212 = getelementptr i64, i64* null, i32 1
  %.r1213 = ptrtoint i64* %.p1212 to i64
  %.p1214 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.40, i32 0, i32 0
  %.p1215 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.40, i32 0, i32 1
  %.p1216 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.40, i32 0, i32 2
  %.r1217 = load i64, i64* %.p1214
  %.r1218 = load i64, i64* %.p1215
  %.r1219 = icmp sge i64 %.r1217, %.r1218
  br i1 %.r1219, label %append.grow.1220, label %append.after.1221
append.grow.1220:
  %.r1222 = load i64*, i64** %.p1216
  %.r1223 = icmp eq i64 %.r1218, 0
  %.r1224 = mul i64 %.r1218, 2
  %.r1225 = select i1 %.r1223, i64 1, i64 %.r1224
  %.r1226 = mul i64 %.r1225, %.r1213
  %.p1227 = call i8* @malloc(i64 %.r1226)
  %.p1228 = bitcast i8* %.p1227 to i64*
  %.r1229 = mul i64 %.r1217, %.r1213
  %.p1230 = bitcast i64* %.r1222 to i8*
  call i8* @memcpy(i8* %.p1227, i8* %.p1230, i64 %.r1229)
  call void @free(i8* %.p1230)
  store i64* %.p1228, i64** %.p1216
  store i64 %.r1225, i64* %.p1215
  br label %append.after.1221
append.after.1221:
  %.r1231 = load i64*, i64** %.p1216
  %.r1232 = load i64, i64* %i
  %.p1233 = getelementptr inbounds i64, i64* %.r1231, i64 %.r1217
  store i64 %.r1232, i64* %.p1233
  %.r1234 = add i64 %.r1217, 1
  store i64 %.r1234, i64* %.p1214
  %.r1235 = load i64, i64* %i
  %.r1236 = load i64, i64* %size
  %.t41 = add i64 %.r1235, %.r1236
  store i64 %.t41, i64* %i
  br label %while_cond_0
while_end_2:
  %__fld.42 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 2
  %.p1237 = getelementptr i64, i64* null, i32 1
  %.r1238 = ptrtoint i64* %.p1237 to i64
  %.p1239 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.42, i32 0, i32 0
  %.p1240 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.42, i32 0, i32 1
  %.p1241 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.42, i32 0, i32 2
  %.r1242 = load i64, i64* %.p1239
  %.r1243 = load i64, i64* %.p1240
  %.r1244 = icmp sge i64 %.r1242, %.r1243
  br i1 %.r1244, label %append.grow.1245, label %append.after.1246
append.grow.1245:
  %.r1247 = load i64*, i64** %.p1241
  %.r1248 = icmp eq i64 %.r1243, 0
  %.r1249 = mul i64 %.r1243, 2
  %.r1250 = select i1 %.r1248, i64 1, i64 %.r1249
  %.r1251 = mul i64 %.r1250, %.r1238
  %.p1252 = call i8* @malloc(i64 %.r1251)
  %.p1253 = bitcast i8* %.p1252 to i64*
  %.r1254 = mul i64 %.r1242, %.r1238
  %.p1255 = bitcast i64* %.r1247 to i8*
  call i8* @memcpy(i8* %.p1252, i8* %.p1255, i64 %.r1254)
  call void @free(i8* %.p1255)
  store i64* %.p1253, i64** %.p1241
  store i64 %.r1250, i64* %.p1240
  br label %append.after.1246
append.after.1246:
  %.r1256 = load i64*, i64** %.p1241
  %.r1257 = load i64, i64* %n
  %.p1258 = getelementptr inbounds i64, i64* %.r1256, i64 %.r1242
  store i64 %.r1257, i64* %.p1258
  %.r1259 = add i64 %.r1242, 1
  store i64 %.r1259, i64* %.p1239
  ret void
}

define i64 @Lexer__peek(%Lexer* %self) {
entry:
  %.p1260 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 3
  %.t0 = load i64, i64* %.p1260
  %__fld.1 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 1
  %.p1261 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.1, i32 0, i32 0
  %.t2 = load i64, i64* %.p1261
  %.t3 = icmp slt i64 %.t0, %.t2
  br i1 %.t3, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %__fld.4 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 1
  %.p1262 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 3
  %.t5 = load i64, i64* %.p1262
  %.p1263 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.4, i32 0, i32 0
  %.r1264 = load i64, i64* %.p1263
  %.r1265 = icmp slt i64 %.t5, 0
  %.r1266 = icmp sge i64 %.t5, %.r1264
  %.r1267 = or i1 %.r1265, %.r1266
  br i1 %.r1267, label %idx.fail.1269, label %idx.ok.1268
idx.fail.1269:
  %.p1270 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p1270, i64 %.t5, i64 %.r1264)
  call void @exit(i32 1)
  unreachable
idx.ok.1268:
  %.p1272 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.4, i32 0, i32 2
  %.p1271 = load i64*, i64** %.p1272
  %.p1273 = getelementptr inbounds i64, i64* %.p1271, i64 %.t5
  %.t6 = load i64, i64* %.p1273
  ret i64 %.t6
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.t7 = sub i64 0, 1
  ret i64 %.t7
}

define i64 @Lexer__peek_at(%Lexer* %self, i64 %offset.arg) {
entry:
  %offset = alloca i64
  store i64 %offset.arg, i64* %offset
  %.p1274 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 3
  %.t0 = load i64, i64* %.p1274
  %.r1275 = load i64, i64* %offset
  %.t1 = add i64 %.t0, %.r1275
  %__fld.2 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 1
  %.p1276 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.2, i32 0, i32 0
  %.t3 = load i64, i64* %.p1276
  %.t4 = icmp slt i64 %.t1, %.t3
  br i1 %.t4, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %__fld.5 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 1
  %.p1277 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 3
  %.t6 = load i64, i64* %.p1277
  %.r1278 = load i64, i64* %offset
  %.t7 = add i64 %.t6, %.r1278
  %.p1279 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.5, i32 0, i32 0
  %.r1280 = load i64, i64* %.p1279
  %.r1281 = icmp slt i64 %.t7, 0
  %.r1282 = icmp sge i64 %.t7, %.r1280
  %.r1283 = or i1 %.r1281, %.r1282
  br i1 %.r1283, label %idx.fail.1285, label %idx.ok.1284
idx.fail.1285:
  %.p1286 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p1286, i64 %.t7, i64 %.r1280)
  call void @exit(i32 1)
  unreachable
idx.ok.1284:
  %.p1288 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.5, i32 0, i32 2
  %.p1287 = load i64*, i64** %.p1288
  %.p1289 = getelementptr inbounds i64, i64* %.p1287, i64 %.t7
  %.t8 = load i64, i64* %.p1289
  ret i64 %.t8
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.t9 = sub i64 0, 1
  ret i64 %.t9
}

define i64 @Lexer__advance(%Lexer* %self) {
entry:
  %c = alloca i64
  %.t0 = bitcast %Lexer* %self to %Lexer*
  %.t1 = call i64 @Lexer__peek(%Lexer* %.t0)
  store i64 %.t1, i64* %c
  %.r1290 = load i64, i64* %c
  %.t2 = icmp slt i64 %.r1290, 0
  br i1 %.t2, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t3 = sub i64 0, 1
  ret i64 %.t3
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.p1291 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 3
  %.t4 = load i64, i64* %.p1291
  %.t5 = add i64 %.t4, 1
  %.p1292 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 3
  store i64 %.t5, i64* %.p1292
  %.r1293 = load i64, i64* %c
  %.t6 = icmp eq i64 %.r1293, 10
  br i1 %.t6, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.p1294 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 4
  %.t7 = load i64, i64* %.p1294
  %.t8 = add i64 %.t7, 1
  %.p1295 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 4
  store i64 %.t8, i64* %.p1295
  %.p1296 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 5
  store i64 1, i64* %.p1296
  br label %if_end_3
if_next_0_5:
  %.p1297 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 5
  %.t9 = load i64, i64* %.p1297
  %.t10 = add i64 %.t9, 1
  %.p1298 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 5
  store i64 %.t10, i64* %.p1298
  br label %if_end_3
if_end_3:
  %.t11 = load i64, i64* %c
  ret i64 %.t11
}

define i8* @Lexer__slice(%Lexer* %self, i64 %a.arg, i64 %b.arg) {
entry:
  %a = alloca i64
  %b = alloca i64
  store i64 %a.arg, i64* %a
  store i64 %b.arg, i64* %b
  %.p1299 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 0
  %.t0 = load i8*, i8** %.p1299
  %__fld.1 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 2
  %.r1300 = load i64, i64* %a
  %.p1301 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.1, i32 0, i32 0
  %.r1302 = load i64, i64* %.p1301
  %.r1303 = icmp slt i64 %.r1300, 0
  %.r1304 = icmp sge i64 %.r1300, %.r1302
  %.r1305 = or i1 %.r1303, %.r1304
  br i1 %.r1305, label %idx.fail.1307, label %idx.ok.1306
idx.fail.1307:
  %.p1308 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p1308, i64 %.r1300, i64 %.r1302)
  call void @exit(i32 1)
  unreachable
idx.ok.1306:
  %.p1310 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.1, i32 0, i32 2
  %.p1309 = load i64*, i64** %.p1310
  %.p1311 = getelementptr inbounds i64, i64* %.p1309, i64 %.r1300
  %.t2 = load i64, i64* %.p1311
  %__fld.3 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 2
  %.r1312 = load i64, i64* %b
  %.p1313 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.3, i32 0, i32 0
  %.r1314 = load i64, i64* %.p1313
  %.r1315 = icmp slt i64 %.r1312, 0
  %.r1316 = icmp sge i64 %.r1312, %.r1314
  %.r1317 = or i1 %.r1315, %.r1316
  br i1 %.r1317, label %idx.fail.1319, label %idx.ok.1318
idx.fail.1319:
  %.p1320 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p1320, i64 %.r1312, i64 %.r1314)
  call void @exit(i32 1)
  unreachable
idx.ok.1318:
  %.p1322 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.3, i32 0, i32 2
  %.p1321 = load i64*, i64** %.p1322
  %.p1323 = getelementptr inbounds i64, i64* %.p1321, i64 %.r1312
  %.t4 = load i64, i64* %.p1323
  %.r1324 = sub i64 %.t4, %.t2
  %.r1325 = add i64 %.r1324, 1
  %.p1326 = call i8* @malloc(i64 %.r1325)
  %.p1327 = getelementptr inbounds i8, i8* %.t0, i64 %.t2
  call i8* @memcpy(i8* %.p1326, i8* %.p1327, i64 %.r1324)
  %.p1328 = getelementptr inbounds i8, i8* %.p1326, i64 %.r1324
  store i8 0, i8* %.p1328
  %.t5 = bitcast i8* %.p1326 to i8*
  ret i8* %.t5
}

define void @Lexer__tokenize({ i64, i64, %Token* }* %__ret, %Lexer* %self) {
entry:
  %__agg.1 = alloca { i64, i64, %Token* }
  %.t0 = bitcast %Lexer* %self to %Lexer*
  call void @Lexer__scan_logical_lines(%Lexer* %.t0)
  %.t2 = bitcast %Lexer* %self to %Lexer*
  call void @Lexer__apply_layout({ i64, i64, %Token* }* %__agg.1, %Lexer* %.t2)
  %.r1329 = load { i64, i64, %Token* }, { i64, i64, %Token* }* %__agg.1
  store { i64, i64, %Token* } %.r1329, { i64, i64, %Token* }* %__ret
  ret void
}

define void @Lexer__skip_intraline(%Lexer* %self) {
entry:
  %c = alloca i64
  %__sc.2 = alloca i1
  %__sc.3 = alloca i1
  %__sc.9 = alloca i1
  %__sc.14 = alloca i1
  br label %while_cond_0
while_cond_0:
  br i1 true, label %while_body_1, label %while_end_2
while_body_1:
  %.t0 = bitcast %Lexer* %self to %Lexer*
  %.t1 = call i64 @Lexer__peek(%Lexer* %.t0)
  store i64 %.t1, i64* %c
  %.r1330 = load i64, i64* %c
  %.t4 = icmp eq i64 %.r1330, 32
  br i1 %.t4, label %sc_short_7, label %sc_rhs_6
sc_rhs_6:
  %.r1331 = load i64, i64* %c
  %.t5 = icmp eq i64 %.r1331, 9
  store i1 %.t5, i1* %__sc.3
  br label %sc_end_8
sc_short_7:
  store i1 true, i1* %__sc.3
  br label %sc_end_8
sc_end_8:
  %.r1332 = load i1, i1* %__sc.3
  br i1 %.r1332, label %sc_short_10, label %sc_rhs_9
sc_rhs_9:
  %.r1333 = load i64, i64* %c
  %.t6 = icmp eq i64 %.r1333, 13
  store i1 %.t6, i1* %__sc.2
  br label %sc_end_11
sc_short_10:
  store i1 true, i1* %__sc.2
  br label %sc_end_11
sc_end_11:
  %.r1334 = load i1, i1* %__sc.2
  br i1 %.r1334, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.t7 = bitcast %Lexer* %self to %Lexer*
  %.t8 = call i64 @Lexer__advance(%Lexer* %.t7)
  br label %if_end_3
if_next_0_5:
  %.r1335 = load i64, i64* %c
  %.t10 = icmp eq i64 %.r1335, 47
  br i1 %.t10, label %sc_rhs_14, label %sc_short_15
sc_rhs_14:
  %.t11 = bitcast %Lexer* %self to %Lexer*
  %.t12 = call i64 @Lexer__peek_at(%Lexer* %.t11, i64 1)
  %.t13 = icmp eq i64 %.t12, 47
  store i1 %.t13, i1* %__sc.9
  br label %sc_end_16
sc_short_15:
  store i1 false, i1* %__sc.9
  br label %sc_end_16
sc_end_16:
  %.r1336 = load i1, i1* %__sc.9
  br i1 %.r1336, label %if_then_1_12, label %if_next_1_13
if_then_1_12:
  br label %while_cond_17
while_cond_17:
  %.t15 = bitcast %Lexer* %self to %Lexer*
  %.t16 = call i64 @Lexer__peek(%Lexer* %.t15)
  %.t17 = icmp sge i64 %.t16, 0
  br i1 %.t17, label %sc_rhs_20, label %sc_short_21
sc_rhs_20:
  %.t18 = bitcast %Lexer* %self to %Lexer*
  %.t19 = call i64 @Lexer__peek(%Lexer* %.t18)
  %.t20 = icmp ne i64 %.t19, 10
  store i1 %.t20, i1* %__sc.14
  br label %sc_end_22
sc_short_21:
  store i1 false, i1* %__sc.14
  br label %sc_end_22
sc_end_22:
  %.r1337 = load i1, i1* %__sc.14
  br i1 %.r1337, label %while_body_18, label %while_end_19
while_body_18:
  %.t21 = bitcast %Lexer* %self to %Lexer*
  %.t22 = call i64 @Lexer__advance(%Lexer* %.t21)
  br label %while_cond_17
while_end_19:
  br label %if_end_3
if_next_1_13:
  ret void
if_end_3:
  br label %while_cond_0
while_end_2:
  ret void
}

define void @Lexer__scan_logical_lines(%Lexer* %self) {
entry:
  %indent = alloca i64
  %indent_chars = alloca i64
  %c = alloca i64
  %__sc.22 = alloca i1
  %__sc.29 = alloca i1
  %tokens = alloca { i64, i64, %Token* }
  %start_pos = alloca i64
  %start_line = alloca i64
  %start_col = alloca i64
  %tk = alloca %Token
  %got = alloca i1
  %__sc.62 = alloca i1
  %__agg.79 = alloca %Span
  %rl = alloca %RawLine
  br label %while_cond_0
while_cond_0:
  br i1 true, label %while_body_1, label %while_end_2
while_body_1:
  store i64 0, i64* %indent
  store i64 0, i64* %indent_chars
  br label %while_cond_3
while_cond_3:
  br i1 true, label %while_body_4, label %while_end_5
while_body_4:
  %.t0 = bitcast %Lexer* %self to %Lexer*
  %.t1 = call i64 @Lexer__peek(%Lexer* %.t0)
  store i64 %.t1, i64* %c
  %.r1338 = load i64, i64* %c
  %.t2 = icmp eq i64 %.r1338, 32
  br i1 %.t2, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.r1339 = load i64, i64* %indent
  %.t3 = add i64 %.r1339, 1
  store i64 %.t3, i64* %indent
  %.r1340 = load i64, i64* %indent_chars
  %.t4 = add i64 %.r1340, 1
  store i64 %.t4, i64* %indent_chars
  %.t5 = bitcast %Lexer* %self to %Lexer*
  %.t6 = call i64 @Lexer__advance(%Lexer* %.t5)
  br label %if_end_6
if_next_0_8:
  %.r1341 = load i64, i64* %c
  %.t7 = icmp eq i64 %.r1341, 9
  br i1 %.t7, label %if_then_1_9, label %if_next_1_10
if_then_1_9:
  %.r1342 = load i64, i64* %indent
  %.t8 = sdiv i64 %.r1342, 8
  %.t9 = add i64 %.t8, 1
  %.t10 = mul i64 %.t9, 8
  store i64 %.t10, i64* %indent
  %.r1343 = load i64, i64* %indent_chars
  %.t11 = add i64 %.r1343, 1
  store i64 %.t11, i64* %indent_chars
  %.t12 = bitcast %Lexer* %self to %Lexer*
  %.t13 = call i64 @Lexer__advance(%Lexer* %.t12)
  br label %if_end_6
if_next_1_10:
  br label %while_end_5
if_end_6:
  br label %while_cond_3
while_end_5:
  %.t14 = bitcast %Lexer* %self to %Lexer*
  %.t15 = call i64 @Lexer__peek(%Lexer* %.t14)
  %.t16 = icmp slt i64 %.t15, 0
  br i1 %.t16, label %if_then_0_12, label %if_next_0_13
if_then_0_12:
  br label %while_end_2
if_next_0_13:
  br label %if_end_11
if_end_11:
  %.t17 = bitcast %Lexer* %self to %Lexer*
  %.t18 = call i64 @Lexer__peek(%Lexer* %.t17)
  %.t19 = icmp eq i64 %.t18, 10
  br i1 %.t19, label %if_then_0_15, label %if_next_0_16
if_then_0_15:
  %.t20 = bitcast %Lexer* %self to %Lexer*
  %.t21 = call i64 @Lexer__advance(%Lexer* %.t20)
  br label %while_cond_0
if_next_0_16:
  br label %if_end_14
if_end_14:
  %.t23 = bitcast %Lexer* %self to %Lexer*
  %.t24 = call i64 @Lexer__peek(%Lexer* %.t23)
  %.t25 = icmp eq i64 %.t24, 47
  br i1 %.t25, label %sc_rhs_20, label %sc_short_21
sc_rhs_20:
  %.t26 = bitcast %Lexer* %self to %Lexer*
  %.t27 = call i64 @Lexer__peek_at(%Lexer* %.t26, i64 1)
  %.t28 = icmp eq i64 %.t27, 47
  store i1 %.t28, i1* %__sc.22
  br label %sc_end_22
sc_short_21:
  store i1 false, i1* %__sc.22
  br label %sc_end_22
sc_end_22:
  %.r1344 = load i1, i1* %__sc.22
  br i1 %.r1344, label %if_then_0_18, label %if_next_0_19
if_then_0_18:
  br label %while_cond_23
while_cond_23:
  %.t30 = bitcast %Lexer* %self to %Lexer*
  %.t31 = call i64 @Lexer__peek(%Lexer* %.t30)
  %.t32 = icmp sge i64 %.t31, 0
  br i1 %.t32, label %sc_rhs_26, label %sc_short_27
sc_rhs_26:
  %.t33 = bitcast %Lexer* %self to %Lexer*
  %.t34 = call i64 @Lexer__peek(%Lexer* %.t33)
  %.t35 = icmp ne i64 %.t34, 10
  store i1 %.t35, i1* %__sc.29
  br label %sc_end_28
sc_short_27:
  store i1 false, i1* %__sc.29
  br label %sc_end_28
sc_end_28:
  %.r1345 = load i1, i1* %__sc.29
  br i1 %.r1345, label %while_body_24, label %while_end_25
while_body_24:
  %.t36 = bitcast %Lexer* %self to %Lexer*
  %.t37 = call i64 @Lexer__advance(%Lexer* %.t36)
  br label %while_cond_23
while_end_25:
  br label %while_cond_0
if_next_0_19:
  br label %if_end_17
if_end_17:
  %.p1347 = getelementptr %Token, %Token* null, i32 1
  %.r1348 = ptrtoint %Token* %.p1347 to i64
  %.r1349 = mul i64 %.r1348, 1
  %.p1346 = call i8* @malloc(i64 %.r1349)
  %.p1350 = bitcast i8* %.p1346 to %Token*
  %.p1351 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %tokens, i32 0, i32 0
  store i64 0, i64* %.p1351
  %.p1352 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %tokens, i32 0, i32 1
  store i64 0, i64* %.p1352
  %.p1353 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %tokens, i32 0, i32 2
  store %Token* %.p1350, %Token** %.p1353
  br label %while_cond_29
while_cond_29:
  br i1 true, label %while_body_30, label %while_end_31
while_body_30:
  %.t38 = bitcast %Lexer* %self to %Lexer*
  call void @Lexer__skip_intraline(%Lexer* %.t38)
  %.t39 = bitcast %Lexer* %self to %Lexer*
  %.t40 = call i64 @Lexer__peek(%Lexer* %.t39)
  store i64 %.t40, i64* %c
  %.r1354 = load i64, i64* %c
  %.t41 = icmp slt i64 %.r1354, 0
  br i1 %.t41, label %if_then_0_33, label %if_next_0_34
if_then_0_33:
  br label %while_end_31
if_next_0_34:
  br label %if_end_32
if_end_32:
  %.r1355 = load i64, i64* %c
  %.t42 = icmp eq i64 %.r1355, 10
  br i1 %.t42, label %if_then_0_36, label %if_next_0_37
if_then_0_36:
  %.p1356 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 8
  %.t43 = load i64, i64* %.p1356
  %.t44 = icmp sgt i64 %.t43, 0
  br i1 %.t44, label %if_then_0_39, label %if_next_0_40
if_then_0_39:
  %.t45 = bitcast %Lexer* %self to %Lexer*
  %.t46 = call i64 @Lexer__advance(%Lexer* %.t45)
  br label %while_cond_29
if_next_0_40:
  %.t47 = bitcast %Lexer* %self to %Lexer*
  %.t48 = call i64 @Lexer__advance(%Lexer* %.t47)
  br label %while_end_31
if_end_38:
  br label %if_end_35
if_next_0_37:
  br label %if_end_35
if_end_35:
  %.p1357 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 3
  %.t49 = load i64, i64* %.p1357
  store i64 %.t49, i64* %start_pos
  %.p1358 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 4
  %.t50 = load i64, i64* %.p1358
  store i64 %.t50, i64* %start_line
  %.p1359 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 5
  %.t51 = load i64, i64* %.p1359
  store i64 %.t51, i64* %start_col
  %.p1360 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p1361 = getelementptr inbounds %Token, %Token* %tk, i32 0, i32 0
  store i8* %.p1360, i8** %.p1361
  %.p1362 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p1363 = getelementptr inbounds %Token, %Token* %tk, i32 0, i32 1
  store i8* %.p1362, i8** %.p1363
  %.p1364 = getelementptr inbounds %Token, %Token* %tk, i32 0, i32 2
  store i64 0, i64* %.p1364
  %.p1365 = getelementptr inbounds %Token, %Token* %tk, i32 0, i32 3
  store %Span zeroinitializer, %Span* %.p1365
  store i1 false, i1* %got
  %.r1366 = load i64, i64* %c
  %.t52 = call i1 @is_digit_cp(i64 %.r1366)
  br i1 %.t52, label %if_then_0_42, label %if_next_0_43
if_then_0_42:
  %.t53 = bitcast %Lexer* %self to %Lexer*
  call void @Lexer__lex_number(%Token* %tk, %Lexer* %.t53)
  %.p1367 = getelementptr inbounds %Token, %Token* %tk, i32 0, i32 0
  %.t54 = load i8*, i8** %.p1367
  %.t55 = call i64 @strlen(i8* %.t54)
  %.t56 = icmp sgt i64 %.t55, 0
  store i1 %.t56, i1* %got
  br label %if_end_41
if_next_0_43:
  %.r1368 = load i64, i64* %c
  %.t57 = icmp eq i64 %.r1368, 34
  br i1 %.t57, label %if_then_1_44, label %if_next_1_45
if_then_1_44:
  %.t58 = bitcast %Lexer* %self to %Lexer*
  %.r1369 = load i64, i64* %start_line
  %.r1370 = load i64, i64* %start_col
  call void @Lexer__lex_string(%Token* %tk, %Lexer* %.t58, i64 %.r1369, i64 %.r1370)
  %.p1371 = getelementptr inbounds %Token, %Token* %tk, i32 0, i32 0
  %.t59 = load i8*, i8** %.p1371
  %.t60 = call i64 @strlen(i8* %.t59)
  %.t61 = icmp sgt i64 %.t60, 0
  store i1 %.t61, i1* %got
  br label %if_end_41
if_next_1_45:
  %.r1372 = load i64, i64* %c
  %.t63 = icmp eq i64 %.r1372, 102
  br i1 %.t63, label %sc_rhs_48, label %sc_short_49
sc_rhs_48:
  %.t64 = bitcast %Lexer* %self to %Lexer*
  %.t65 = call i64 @Lexer__peek_at(%Lexer* %.t64, i64 1)
  %.t66 = icmp eq i64 %.t65, 34
  store i1 %.t66, i1* %__sc.62
  br label %sc_end_50
sc_short_49:
  store i1 false, i1* %__sc.62
  br label %sc_end_50
sc_end_50:
  %.r1373 = load i1, i1* %__sc.62
  br i1 %.r1373, label %if_then_2_46, label %if_next_2_47
if_then_2_46:
  %.t67 = bitcast %Lexer* %self to %Lexer*
  %.t68 = call i64 @Lexer__advance(%Lexer* %.t67)
  %.t69 = bitcast %Lexer* %self to %Lexer*
  %.r1374 = load i64, i64* %start_line
  %.r1375 = load i64, i64* %start_col
  call void @Lexer__lex_string(%Token* %tk, %Lexer* %.t69, i64 %.r1374, i64 %.r1375)
  %.p1376 = getelementptr inbounds %Token, %Token* %tk, i32 0, i32 0
  %.t70 = load i8*, i8** %.p1376
  %.t71 = call i64 @strlen(i8* %.t70)
  %.t72 = icmp sgt i64 %.t71, 0
  store i1 %.t72, i1* %got
  %.r1377 = load i1, i1* %got
  br i1 %.r1377, label %if_then_0_52, label %if_next_0_53
if_then_0_52:
  %.p1378 = getelementptr inbounds [15 x i8], [15 x i8]* @.str.99, i64 0, i64 0
  %.p1379 = getelementptr inbounds %Token, %Token* %tk, i32 0, i32 0
  store i8* %.p1378, i8** %.p1379
  br label %if_end_51
if_next_0_53:
  br label %if_end_51
if_end_51:
  br label %if_end_41
if_next_2_47:
  %.r1380 = load i64, i64* %c
  %.t73 = call i1 @is_ident_start_cp(i64 %.r1380)
  br i1 %.t73, label %if_then_3_54, label %if_next_3_55
if_then_3_54:
  %.t74 = bitcast %Lexer* %self to %Lexer*
  call void @Lexer__lex_identifier(%Token* %tk, %Lexer* %.t74)
  store i1 true, i1* %got
  br label %if_end_41
if_next_3_55:
  %.t75 = bitcast %Lexer* %self to %Lexer*
  %.r1381 = load i64, i64* %start_line
  %.r1382 = load i64, i64* %start_col
  call void @Lexer__lex_operator(%Token* %tk, %Lexer* %.t75, i64 %.r1381, i64 %.r1382)
  %.p1383 = getelementptr inbounds %Token, %Token* %tk, i32 0, i32 0
  %.t76 = load i8*, i8** %.p1383
  %.t77 = call i64 @strlen(i8* %.t76)
  %.t78 = icmp sgt i64 %.t77, 0
  store i1 %.t78, i1* %got
  br label %if_end_41
if_end_41:
  %.r1384 = load i1, i1* %got
  br i1 %.r1384, label %if_then_0_57, label %if_next_0_58
if_then_0_57:
  %.p1385 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 3
  %.t80 = load i64, i64* %.p1385
  %.r1386 = load i64, i64* %start_pos
  %.r1387 = load i64, i64* %start_line
  %.r1388 = load i64, i64* %start_col
  call void @span_new(%Span* %__agg.79, i64 %.r1386, i64 %.t80, i64 %.r1387, i64 %.r1388)
  %.r1389 = load %Span, %Span* %__agg.79
  %.p1390 = getelementptr inbounds %Token, %Token* %tk, i32 0, i32 3
  store %Span %.r1389, %Span* %.p1390
  %.p1391 = getelementptr %Token, %Token* null, i32 1
  %.r1392 = ptrtoint %Token* %.p1391 to i64
  %.p1393 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %tokens, i32 0, i32 0
  %.p1394 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %tokens, i32 0, i32 1
  %.p1395 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %tokens, i32 0, i32 2
  %.r1396 = load i64, i64* %.p1393
  %.r1397 = load i64, i64* %.p1394
  %.r1398 = icmp sge i64 %.r1396, %.r1397
  br i1 %.r1398, label %append.grow.1399, label %append.after.1400
append.grow.1399:
  %.r1401 = load %Token*, %Token** %.p1395
  %.r1402 = icmp eq i64 %.r1397, 0
  %.r1403 = mul i64 %.r1397, 2
  %.r1404 = select i1 %.r1402, i64 1, i64 %.r1403
  %.r1405 = mul i64 %.r1404, %.r1392
  %.p1406 = call i8* @malloc(i64 %.r1405)
  %.p1407 = bitcast i8* %.p1406 to %Token*
  %.r1408 = mul i64 %.r1396, %.r1392
  %.p1409 = bitcast %Token* %.r1401 to i8*
  call i8* @memcpy(i8* %.p1406, i8* %.p1409, i64 %.r1408)
  call void @free(i8* %.p1409)
  store %Token* %.p1407, %Token** %.p1395
  store i64 %.r1404, i64* %.p1394
  br label %append.after.1400
append.after.1400:
  %.r1410 = load %Token*, %Token** %.p1395
  %.r1411 = load %Token, %Token* %tk
  %.p1412 = getelementptr inbounds %Token, %Token* %.r1410, i64 %.r1396
  store %Token %.r1411, %Token* %.p1412
  %.r1413 = add i64 %.r1396, 1
  store i64 %.r1413, i64* %.p1393
  br label %if_end_56
if_next_0_58:
  br label %if_end_56
if_end_56:
  br label %while_cond_29
while_end_31:
  %.p1414 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %tokens, i32 0, i32 0
  %.t81 = load i64, i64* %.p1414
  %.t82 = icmp sgt i64 %.t81, 0
  br i1 %.t82, label %if_then_0_60, label %if_next_0_61
if_then_0_60:
  %.p1415 = getelementptr inbounds %RawLine, %RawLine* %rl, i32 0, i32 0
  store i64 0, i64* %.p1415
  %.p1416 = getelementptr inbounds %RawLine, %RawLine* %rl, i32 0, i32 1
  store i64 0, i64* %.p1416
  %.p1417 = getelementptr inbounds %RawLine, %RawLine* %rl, i32 0, i32 2
  store { i64, i64, %Token* } zeroinitializer, { i64, i64, %Token* }* %.p1417
  %.r1418 = load i64, i64* %indent
  %.p1419 = getelementptr inbounds %RawLine, %RawLine* %rl, i32 0, i32 0
  store i64 %.r1418, i64* %.p1419
  %.r1420 = load i64, i64* %indent_chars
  %.p1421 = getelementptr inbounds %RawLine, %RawLine* %rl, i32 0, i32 1
  store i64 %.r1420, i64* %.p1421
  %.r1422 = load { i64, i64, %Token* }, { i64, i64, %Token* }* %tokens
  %.p1423 = getelementptr inbounds %RawLine, %RawLine* %rl, i32 0, i32 2
  store { i64, i64, %Token* } %.r1422, { i64, i64, %Token* }* %.p1423
  %__fld.83 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 7
  %.p1424 = getelementptr %RawLine, %RawLine* null, i32 1
  %.r1425 = ptrtoint %RawLine* %.p1424 to i64
  %.p1426 = getelementptr inbounds { i64, i64, %RawLine* }, { i64, i64, %RawLine* }* %__fld.83, i32 0, i32 0
  %.p1427 = getelementptr inbounds { i64, i64, %RawLine* }, { i64, i64, %RawLine* }* %__fld.83, i32 0, i32 1
  %.p1428 = getelementptr inbounds { i64, i64, %RawLine* }, { i64, i64, %RawLine* }* %__fld.83, i32 0, i32 2
  %.r1429 = load i64, i64* %.p1426
  %.r1430 = load i64, i64* %.p1427
  %.r1431 = icmp sge i64 %.r1429, %.r1430
  br i1 %.r1431, label %append.grow.1432, label %append.after.1433
append.grow.1432:
  %.r1434 = load %RawLine*, %RawLine** %.p1428
  %.r1435 = icmp eq i64 %.r1430, 0
  %.r1436 = mul i64 %.r1430, 2
  %.r1437 = select i1 %.r1435, i64 1, i64 %.r1436
  %.r1438 = mul i64 %.r1437, %.r1425
  %.p1439 = call i8* @malloc(i64 %.r1438)
  %.p1440 = bitcast i8* %.p1439 to %RawLine*
  %.r1441 = mul i64 %.r1429, %.r1425
  %.p1442 = bitcast %RawLine* %.r1434 to i8*
  call i8* @memcpy(i8* %.p1439, i8* %.p1442, i64 %.r1441)
  call void @free(i8* %.p1442)
  store %RawLine* %.p1440, %RawLine** %.p1428
  store i64 %.r1437, i64* %.p1427
  br label %append.after.1433
append.after.1433:
  %.r1443 = load %RawLine*, %RawLine** %.p1428
  %.r1444 = load %RawLine, %RawLine* %rl
  %.p1445 = getelementptr inbounds %RawLine, %RawLine* %.r1443, i64 %.r1429
  store %RawLine %.r1444, %RawLine* %.p1445
  %.r1446 = add i64 %.r1429, 1
  store i64 %.r1446, i64* %.p1426
  br label %if_end_59
if_next_0_61:
  br label %if_end_59
if_end_59:
  br label %while_cond_0
while_end_2:
  ret void
}

define void @Lexer__apply_layout({ i64, i64, %Token* }* %__ret, %Lexer* %self) {
entry:
  %out = alloca { i64, i64, %Token* }
  %stack_ind = alloca { i64, i64, i64* }
  %stack_chars = alloca { i64, i64, i64* }
  %__for.idx.1 = alloca i64
  %__for.len.2 = alloca i64
  %raw = alloca %RawLine
  %indent = alloca i64
  %top = alloca i64
  %current = alloca i64
  %current_chars = alloca i64
  %first_span = alloca %Span
  %ord1 = alloca i64
  %ord2 = alloca i64
  %__agg.28 = alloca %Token
  %__agg.37 = alloca %Token
  %__for.idx.47 = alloca i64
  %__for.len.48 = alloca i64
  %t = alloca %Token
  %last_span = alloca %Span
  %__agg.59 = alloca %Token
  %eof_span = alloca %Span
  %__agg.70 = alloca %Token
  %__agg.72 = alloca %Token
  %.p1448 = getelementptr %Token, %Token* null, i32 1
  %.r1449 = ptrtoint %Token* %.p1448 to i64
  %.r1450 = mul i64 %.r1449, 1
  %.p1447 = call i8* @malloc(i64 %.r1450)
  %.p1451 = bitcast i8* %.p1447 to %Token*
  %.p1452 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %out, i32 0, i32 0
  store i64 0, i64* %.p1452
  %.p1453 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %out, i32 0, i32 1
  store i64 0, i64* %.p1453
  %.p1454 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %out, i32 0, i32 2
  store %Token* %.p1451, %Token** %.p1454
  %.p1456 = getelementptr i64, i64* null, i32 1
  %.r1457 = ptrtoint i64* %.p1456 to i64
  %.r1458 = mul i64 %.r1457, 1
  %.p1455 = call i8* @malloc(i64 %.r1458)
  %.p1459 = bitcast i8* %.p1455 to i64*
  %.p1460 = getelementptr inbounds i64, i64* %.p1459, i64 0
  store i64 0, i64* %.p1460
  %.p1461 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_ind, i32 0, i32 0
  store i64 1, i64* %.p1461
  %.p1462 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_ind, i32 0, i32 1
  store i64 1, i64* %.p1462
  %.p1463 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_ind, i32 0, i32 2
  store i64* %.p1459, i64** %.p1463
  %.p1465 = getelementptr i64, i64* null, i32 1
  %.r1466 = ptrtoint i64* %.p1465 to i64
  %.r1467 = mul i64 %.r1466, 1
  %.p1464 = call i8* @malloc(i64 %.r1467)
  %.p1468 = bitcast i8* %.p1464 to i64*
  %.p1469 = getelementptr inbounds i64, i64* %.p1468, i64 0
  store i64 0, i64* %.p1469
  %.p1470 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_chars, i32 0, i32 0
  store i64 1, i64* %.p1470
  %.p1471 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_chars, i32 0, i32 1
  store i64 1, i64* %.p1471
  %.p1472 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_chars, i32 0, i32 2
  store i64* %.p1468, i64** %.p1472
  %__fld.0 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 7
  store i64 0, i64* %__for.idx.1
  %.p1473 = getelementptr inbounds { i64, i64, %RawLine* }, { i64, i64, %RawLine* }* %__fld.0, i32 0, i32 0
  %.t3 = load i64, i64* %.p1473
  store i64 %.t3, i64* %__for.len.2
  br label %foreach_cond_0
foreach_cond_0:
  %.r1474 = load i64, i64* %__for.idx.1
  %.r1475 = load i64, i64* %__for.len.2
  %.t4 = icmp slt i64 %.r1474, %.r1475
  br i1 %.t4, label %foreach_body_1, label %foreach_end_3
foreach_body_1:
  %.r1476 = load i64, i64* %__for.idx.1
  %.p1477 = getelementptr inbounds { i64, i64, %RawLine* }, { i64, i64, %RawLine* }* %__fld.0, i32 0, i32 0
  %.r1478 = load i64, i64* %.p1477
  %.r1479 = icmp slt i64 %.r1476, 0
  %.r1480 = icmp sge i64 %.r1476, %.r1478
  %.r1481 = or i1 %.r1479, %.r1480
  br i1 %.r1481, label %idx.fail.1483, label %idx.ok.1482
idx.fail.1483:
  %.p1484 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p1484, i64 %.r1476, i64 %.r1478)
  call void @exit(i32 1)
  unreachable
idx.ok.1482:
  %.p1486 = getelementptr inbounds { i64, i64, %RawLine* }, { i64, i64, %RawLine* }* %__fld.0, i32 0, i32 2
  %.p1485 = load %RawLine*, %RawLine** %.p1486
  %.p1487 = getelementptr inbounds %RawLine, %RawLine* %.p1485, i64 %.r1476
  %.t5 = load %RawLine, %RawLine* %.p1487
  store %RawLine %.t5, %RawLine* %raw
  %.p1488 = getelementptr inbounds %RawLine, %RawLine* %raw, i32 0, i32 0
  %.t6 = load i64, i64* %.p1488
  store i64 %.t6, i64* %indent
  %.p1489 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_ind, i32 0, i32 0
  %.t7 = load i64, i64* %.p1489
  %.t8 = sub i64 %.t7, 1
  store i64 %.t8, i64* %top
  %.r1490 = load i64, i64* %top
  %.p1491 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_ind, i32 0, i32 0
  %.r1492 = load i64, i64* %.p1491
  %.r1493 = icmp slt i64 %.r1490, 0
  %.r1494 = icmp sge i64 %.r1490, %.r1492
  %.r1495 = or i1 %.r1493, %.r1494
  br i1 %.r1495, label %idx.fail.1497, label %idx.ok.1496
idx.fail.1497:
  %.p1498 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p1498, i64 %.r1490, i64 %.r1492)
  call void @exit(i32 1)
  unreachable
idx.ok.1496:
  %.p1500 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_ind, i32 0, i32 2
  %.p1499 = load i64*, i64** %.p1500
  %.p1501 = getelementptr inbounds i64, i64* %.p1499, i64 %.r1490
  %.t9 = load i64, i64* %.p1501
  store i64 %.t9, i64* %current
  %.r1502 = load i64, i64* %top
  %.p1503 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_chars, i32 0, i32 0
  %.r1504 = load i64, i64* %.p1503
  %.r1505 = icmp slt i64 %.r1502, 0
  %.r1506 = icmp sge i64 %.r1502, %.r1504
  %.r1507 = or i1 %.r1505, %.r1506
  br i1 %.r1507, label %idx.fail.1509, label %idx.ok.1508
idx.fail.1509:
  %.p1510 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p1510, i64 %.r1502, i64 %.r1504)
  call void @exit(i32 1)
  unreachable
idx.ok.1508:
  %.p1512 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_chars, i32 0, i32 2
  %.p1511 = load i64*, i64** %.p1512
  %.p1513 = getelementptr inbounds i64, i64* %.p1511, i64 %.r1502
  %.t10 = load i64, i64* %.p1513
  store i64 %.t10, i64* %current_chars
  %__fld.11 = getelementptr inbounds %RawLine, %RawLine* %raw, i32 0, i32 2
  %.p1514 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %__fld.11, i32 0, i32 0
  %.r1515 = load i64, i64* %.p1514
  %.r1516 = icmp slt i64 0, 0
  %.r1517 = icmp sge i64 0, %.r1515
  %.r1518 = or i1 %.r1516, %.r1517
  br i1 %.r1518, label %idx.fail.1520, label %idx.ok.1519
idx.fail.1520:
  %.p1521 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p1521, i64 0, i64 %.r1515)
  call void @exit(i32 1)
  unreachable
idx.ok.1519:
  %.p1523 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %__fld.11, i32 0, i32 2
  %.p1522 = load %Token*, %Token** %.p1523
  %.p1524 = getelementptr inbounds %Token, %Token* %.p1522, i64 0
  %__elem.12 = bitcast %Token* %.p1524 to %Token*
  %__fld.13 = getelementptr inbounds %Token, %Token* %__elem.12, i32 0, i32 3
  %.r1525 = load %Span, %Span* %__fld.13
  store %Span %.r1525, %Span* %first_span
  store i64 0, i64* %ord1
  %.r1526 = load i64, i64* %indent
  %.r1527 = load i64, i64* %current
  %.t14 = icmp sgt i64 %.r1526, %.r1527
  br i1 %.t14, label %if_then_0_5, label %if_next_0_6
if_then_0_5:
  store i64 1, i64* %ord1
  br label %if_end_4
if_next_0_6:
  %.r1528 = load i64, i64* %indent
  %.r1529 = load i64, i64* %current
  %.t15 = icmp slt i64 %.r1528, %.r1529
  br i1 %.t15, label %if_then_1_7, label %if_next_1_8
if_then_1_7:
  %.t16 = sub i64 0, 1
  store i64 %.t16, i64* %ord1
  br label %if_end_4
if_next_1_8:
  br label %if_end_4
if_end_4:
  store i64 0, i64* %ord2
  %.p1530 = getelementptr inbounds %RawLine, %RawLine* %raw, i32 0, i32 1
  %.t17 = load i64, i64* %.p1530
  %.r1531 = load i64, i64* %current_chars
  %.t18 = icmp sgt i64 %.t17, %.r1531
  br i1 %.t18, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  store i64 1, i64* %ord2
  br label %if_end_9
if_next_0_11:
  %.p1532 = getelementptr inbounds %RawLine, %RawLine* %raw, i32 0, i32 1
  %.t19 = load i64, i64* %.p1532
  %.r1533 = load i64, i64* %current_chars
  %.t20 = icmp slt i64 %.t19, %.r1533
  br i1 %.t20, label %if_then_1_12, label %if_next_1_13
if_then_1_12:
  %.t21 = sub i64 0, 1
  store i64 %.t21, i64* %ord2
  br label %if_end_9
if_next_1_13:
  br label %if_end_9
if_end_9:
  %.r1534 = load i64, i64* %ord1
  %.r1535 = load i64, i64* %ord2
  %.t22 = icmp ne i64 %.r1534, %.r1535
  br i1 %.t22, label %if_then_0_15, label %if_next_0_16
if_then_0_15:
  %__fld.23 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 6
  %.t24 = bitcast %Diags* %__fld.23 to %Diags*
  %.t25 = bitcast %Span* %first_span to %Span*
  %.p1536 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.226, i64 0, i64 0
  %.p1537 = getelementptr inbounds [51 x i8], [51 x i8]* @.str.227, i64 0, i64 0
  %.p1538 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p1539 = getelementptr inbounds [192 x i8], [192 x i8]* @.str.228, i64 0, i64 0
  call void @Diags__add(%Diags* %.t24, i8* %.p1536, i8* %.p1537, %Span* %.t25, i8* %.p1538, i8* %.p1539)
  br label %if_end_14
if_next_0_16:
  br label %if_end_14
if_end_14:
  %.r1540 = load i64, i64* %indent
  %.r1541 = load i64, i64* %current
  %.t26 = icmp sgt i64 %.r1540, %.r1541
  br i1 %.t26, label %if_then_0_18, label %if_next_0_19
if_then_0_18:
  %.p1542 = getelementptr i64, i64* null, i32 1
  %.r1543 = ptrtoint i64* %.p1542 to i64
  %.p1544 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_ind, i32 0, i32 0
  %.p1545 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_ind, i32 0, i32 1
  %.p1546 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_ind, i32 0, i32 2
  %.r1547 = load i64, i64* %.p1544
  %.r1548 = load i64, i64* %.p1545
  %.r1549 = icmp sge i64 %.r1547, %.r1548
  br i1 %.r1549, label %append.grow.1550, label %append.after.1551
append.grow.1550:
  %.r1552 = load i64*, i64** %.p1546
  %.r1553 = icmp eq i64 %.r1548, 0
  %.r1554 = mul i64 %.r1548, 2
  %.r1555 = select i1 %.r1553, i64 1, i64 %.r1554
  %.r1556 = mul i64 %.r1555, %.r1543
  %.p1557 = call i8* @malloc(i64 %.r1556)
  %.p1558 = bitcast i8* %.p1557 to i64*
  %.r1559 = mul i64 %.r1547, %.r1543
  %.p1560 = bitcast i64* %.r1552 to i8*
  call i8* @memcpy(i8* %.p1557, i8* %.p1560, i64 %.r1559)
  call void @free(i8* %.p1560)
  store i64* %.p1558, i64** %.p1546
  store i64 %.r1555, i64* %.p1545
  br label %append.after.1551
append.after.1551:
  %.r1561 = load i64*, i64** %.p1546
  %.r1562 = load i64, i64* %indent
  %.p1563 = getelementptr inbounds i64, i64* %.r1561, i64 %.r1547
  store i64 %.r1562, i64* %.p1563
  %.r1564 = add i64 %.r1547, 1
  store i64 %.r1564, i64* %.p1544
  %.p1565 = getelementptr inbounds %RawLine, %RawLine* %raw, i32 0, i32 1
  %.t27 = load i64, i64* %.p1565
  %.p1566 = getelementptr i64, i64* null, i32 1
  %.r1567 = ptrtoint i64* %.p1566 to i64
  %.p1568 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_chars, i32 0, i32 0
  %.p1569 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_chars, i32 0, i32 1
  %.p1570 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_chars, i32 0, i32 2
  %.r1571 = load i64, i64* %.p1568
  %.r1572 = load i64, i64* %.p1569
  %.r1573 = icmp sge i64 %.r1571, %.r1572
  br i1 %.r1573, label %append.grow.1574, label %append.after.1575
append.grow.1574:
  %.r1576 = load i64*, i64** %.p1570
  %.r1577 = icmp eq i64 %.r1572, 0
  %.r1578 = mul i64 %.r1572, 2
  %.r1579 = select i1 %.r1577, i64 1, i64 %.r1578
  %.r1580 = mul i64 %.r1579, %.r1567
  %.p1581 = call i8* @malloc(i64 %.r1580)
  %.p1582 = bitcast i8* %.p1581 to i64*
  %.r1583 = mul i64 %.r1571, %.r1567
  %.p1584 = bitcast i64* %.r1576 to i8*
  call i8* @memcpy(i8* %.p1581, i8* %.p1584, i64 %.r1583)
  call void @free(i8* %.p1584)
  store i64* %.p1582, i64** %.p1570
  store i64 %.r1579, i64* %.p1569
  br label %append.after.1575
append.after.1575:
  %.r1585 = load i64*, i64** %.p1570
  %.p1586 = getelementptr inbounds i64, i64* %.r1585, i64 %.r1571
  store i64 %.t27, i64* %.p1586
  %.r1587 = add i64 %.r1571, 1
  store i64 %.r1587, i64* %.p1568
  %.t29 = bitcast %Span* %first_span to %Span*
  %.p1588 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.220, i64 0, i64 0
  %.p1589 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @tok_new(%Token* %__agg.28, i8* %.p1588, i8* %.p1589, i64 0, %Span* %.t29)
  %.p1590 = getelementptr %Token, %Token* null, i32 1
  %.r1591 = ptrtoint %Token* %.p1590 to i64
  %.p1592 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %out, i32 0, i32 0
  %.p1593 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %out, i32 0, i32 1
  %.p1594 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %out, i32 0, i32 2
  %.r1595 = load i64, i64* %.p1592
  %.r1596 = load i64, i64* %.p1593
  %.r1597 = icmp sge i64 %.r1595, %.r1596
  br i1 %.r1597, label %append.grow.1598, label %append.after.1599
append.grow.1598:
  %.r1600 = load %Token*, %Token** %.p1594
  %.r1601 = icmp eq i64 %.r1596, 0
  %.r1602 = mul i64 %.r1596, 2
  %.r1603 = select i1 %.r1601, i64 1, i64 %.r1602
  %.r1604 = mul i64 %.r1603, %.r1591
  %.p1605 = call i8* @malloc(i64 %.r1604)
  %.p1606 = bitcast i8* %.p1605 to %Token*
  %.r1607 = mul i64 %.r1595, %.r1591
  %.p1608 = bitcast %Token* %.r1600 to i8*
  call i8* @memcpy(i8* %.p1605, i8* %.p1608, i64 %.r1607)
  call void @free(i8* %.p1608)
  store %Token* %.p1606, %Token** %.p1594
  store i64 %.r1603, i64* %.p1593
  br label %append.after.1599
append.after.1599:
  %.r1609 = load %Token*, %Token** %.p1594
  %.r1610 = load %Token, %Token* %__agg.28
  %.p1611 = getelementptr inbounds %Token, %Token* %.r1609, i64 %.r1595
  store %Token %.r1610, %Token* %.p1611
  %.r1612 = add i64 %.r1595, 1
  store i64 %.r1612, i64* %.p1592
  br label %if_end_17
if_next_0_19:
  %.r1613 = load i64, i64* %indent
  %.r1614 = load i64, i64* %current
  %.t30 = icmp slt i64 %.r1613, %.r1614
  br i1 %.t30, label %if_then_1_20, label %if_next_1_21
if_then_1_20:
  br label %while_cond_22
while_cond_22:
  %.p1615 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_ind, i32 0, i32 0
  %.t31 = load i64, i64* %.p1615
  %.t32 = sub i64 %.t31, 1
  %.p1616 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_ind, i32 0, i32 0
  %.r1617 = load i64, i64* %.p1616
  %.r1618 = icmp slt i64 %.t32, 0
  %.r1619 = icmp sge i64 %.t32, %.r1617
  %.r1620 = or i1 %.r1618, %.r1619
  br i1 %.r1620, label %idx.fail.1622, label %idx.ok.1621
idx.fail.1622:
  %.p1623 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p1623, i64 %.t32, i64 %.r1617)
  call void @exit(i32 1)
  unreachable
idx.ok.1621:
  %.p1625 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_ind, i32 0, i32 2
  %.p1624 = load i64*, i64** %.p1625
  %.p1626 = getelementptr inbounds i64, i64* %.p1624, i64 %.t32
  %.t33 = load i64, i64* %.p1626
  %.r1627 = load i64, i64* %indent
  %.t34 = icmp sgt i64 %.t33, %.r1627
  br i1 %.t34, label %while_body_23, label %while_end_24
while_body_23:
  %.p1628 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_ind, i32 0, i32 0
  %.r1629 = load i64, i64* %.p1628
  %.r1630 = sub i64 %.r1629, 1
  %.p1631 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_ind, i32 0, i32 0
  %.r1632 = load i64, i64* %.p1631
  %.r1633 = icmp slt i64 %.r1630, 0
  %.r1634 = icmp sge i64 %.r1630, %.r1632
  %.r1635 = or i1 %.r1633, %.r1634
  br i1 %.r1635, label %idx.fail.1637, label %idx.ok.1636
idx.fail.1637:
  %.p1638 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p1638, i64 %.r1630, i64 %.r1632)
  call void @exit(i32 1)
  unreachable
idx.ok.1636:
  %.p1640 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_ind, i32 0, i32 2
  %.p1639 = load i64*, i64** %.p1640
  %.p1641 = getelementptr inbounds i64, i64* %.p1639, i64 %.r1630
  %.t35 = load i64, i64* %.p1641
  %.p1642 = getelementptr i64, i64* null, i32 1
  %.r1643 = ptrtoint i64* %.p1642 to i64
  %.p1644 = getelementptr inbounds i64, i64* %.p1641, i64 1
  %.r1645 = sub i64 %.r1629, %.r1630
  %.r1646 = sub i64 %.r1645, 1
  %.r1647 = mul i64 %.r1646, %.r1643
  %.p1648 = bitcast i64* %.p1641 to i8*
  %.p1649 = bitcast i64* %.p1644 to i8*
  call i8* @memmove(i8* %.p1648, i8* %.p1649, i64 %.r1647)
  %.r1650 = sub i64 %.r1629, 1
  store i64 %.r1650, i64* %.p1628
  %.p1651 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_chars, i32 0, i32 0
  %.r1652 = load i64, i64* %.p1651
  %.r1653 = sub i64 %.r1652, 1
  %.p1654 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_chars, i32 0, i32 0
  %.r1655 = load i64, i64* %.p1654
  %.r1656 = icmp slt i64 %.r1653, 0
  %.r1657 = icmp sge i64 %.r1653, %.r1655
  %.r1658 = or i1 %.r1656, %.r1657
  br i1 %.r1658, label %idx.fail.1660, label %idx.ok.1659
idx.fail.1660:
  %.p1661 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p1661, i64 %.r1653, i64 %.r1655)
  call void @exit(i32 1)
  unreachable
idx.ok.1659:
  %.p1663 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_chars, i32 0, i32 2
  %.p1662 = load i64*, i64** %.p1663
  %.p1664 = getelementptr inbounds i64, i64* %.p1662, i64 %.r1653
  %.t36 = load i64, i64* %.p1664
  %.p1665 = getelementptr i64, i64* null, i32 1
  %.r1666 = ptrtoint i64* %.p1665 to i64
  %.p1667 = getelementptr inbounds i64, i64* %.p1664, i64 1
  %.r1668 = sub i64 %.r1652, %.r1653
  %.r1669 = sub i64 %.r1668, 1
  %.r1670 = mul i64 %.r1669, %.r1666
  %.p1671 = bitcast i64* %.p1664 to i8*
  %.p1672 = bitcast i64* %.p1667 to i8*
  call i8* @memmove(i8* %.p1671, i8* %.p1672, i64 %.r1670)
  %.r1673 = sub i64 %.r1652, 1
  store i64 %.r1673, i64* %.p1651
  %.t38 = bitcast %Span* %first_span to %Span*
  %.p1674 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.222, i64 0, i64 0
  %.p1675 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @tok_new(%Token* %__agg.37, i8* %.p1674, i8* %.p1675, i64 0, %Span* %.t38)
  %.p1676 = getelementptr %Token, %Token* null, i32 1
  %.r1677 = ptrtoint %Token* %.p1676 to i64
  %.p1678 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %out, i32 0, i32 0
  %.p1679 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %out, i32 0, i32 1
  %.p1680 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %out, i32 0, i32 2
  %.r1681 = load i64, i64* %.p1678
  %.r1682 = load i64, i64* %.p1679
  %.r1683 = icmp sge i64 %.r1681, %.r1682
  br i1 %.r1683, label %append.grow.1684, label %append.after.1685
append.grow.1684:
  %.r1686 = load %Token*, %Token** %.p1680
  %.r1687 = icmp eq i64 %.r1682, 0
  %.r1688 = mul i64 %.r1682, 2
  %.r1689 = select i1 %.r1687, i64 1, i64 %.r1688
  %.r1690 = mul i64 %.r1689, %.r1677
  %.p1691 = call i8* @malloc(i64 %.r1690)
  %.p1692 = bitcast i8* %.p1691 to %Token*
  %.r1693 = mul i64 %.r1681, %.r1677
  %.p1694 = bitcast %Token* %.r1686 to i8*
  call i8* @memcpy(i8* %.p1691, i8* %.p1694, i64 %.r1693)
  call void @free(i8* %.p1694)
  store %Token* %.p1692, %Token** %.p1680
  store i64 %.r1689, i64* %.p1679
  br label %append.after.1685
append.after.1685:
  %.r1695 = load %Token*, %Token** %.p1680
  %.r1696 = load %Token, %Token* %__agg.37
  %.p1697 = getelementptr inbounds %Token, %Token* %.r1695, i64 %.r1681
  store %Token %.r1696, %Token* %.p1697
  %.r1698 = add i64 %.r1681, 1
  store i64 %.r1698, i64* %.p1678
  br label %while_cond_22
while_end_24:
  %.p1699 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_ind, i32 0, i32 0
  %.t39 = load i64, i64* %.p1699
  %.t40 = sub i64 %.t39, 1
  %.p1700 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_ind, i32 0, i32 0
  %.r1701 = load i64, i64* %.p1700
  %.r1702 = icmp slt i64 %.t40, 0
  %.r1703 = icmp sge i64 %.t40, %.r1701
  %.r1704 = or i1 %.r1702, %.r1703
  br i1 %.r1704, label %idx.fail.1706, label %idx.ok.1705
idx.fail.1706:
  %.p1707 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p1707, i64 %.t40, i64 %.r1701)
  call void @exit(i32 1)
  unreachable
idx.ok.1705:
  %.p1709 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_ind, i32 0, i32 2
  %.p1708 = load i64*, i64** %.p1709
  %.p1710 = getelementptr inbounds i64, i64* %.p1708, i64 %.t40
  %.t41 = load i64, i64* %.p1710
  %.r1711 = load i64, i64* %indent
  %.t42 = icmp ne i64 %.t41, %.r1711
  br i1 %.t42, label %if_then_0_26, label %if_next_0_27
if_then_0_26:
  %__fld.43 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 6
  %.t44 = bitcast %Diags* %__fld.43 to %Diags*
  %.t45 = bitcast %Span* %first_span to %Span*
  %.p1712 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.229, i64 0, i64 0
  %.p1713 = getelementptr inbounds [25 x i8], [25 x i8]* @.str.230, i64 0, i64 0
  %.p1714 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p1715 = getelementptr inbounds [50 x i8], [50 x i8]* @.str.231, i64 0, i64 0
  call void @Diags__add(%Diags* %.t44, i8* %.p1712, i8* %.p1713, %Span* %.t45, i8* %.p1714, i8* %.p1715)
  br label %if_end_25
if_next_0_27:
  br label %if_end_25
if_end_25:
  br label %if_end_17
if_next_1_21:
  br label %if_end_17
if_end_17:
  %__fld.46 = getelementptr inbounds %RawLine, %RawLine* %raw, i32 0, i32 2
  store i64 0, i64* %__for.idx.47
  %.p1716 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %__fld.46, i32 0, i32 0
  %.t49 = load i64, i64* %.p1716
  store i64 %.t49, i64* %__for.len.48
  br label %foreach_cond_28
foreach_cond_28:
  %.r1717 = load i64, i64* %__for.idx.47
  %.r1718 = load i64, i64* %__for.len.48
  %.t50 = icmp slt i64 %.r1717, %.r1718
  br i1 %.t50, label %foreach_body_29, label %foreach_end_31
foreach_body_29:
  %.r1719 = load i64, i64* %__for.idx.47
  %.p1720 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %__fld.46, i32 0, i32 0
  %.r1721 = load i64, i64* %.p1720
  %.r1722 = icmp slt i64 %.r1719, 0
  %.r1723 = icmp sge i64 %.r1719, %.r1721
  %.r1724 = or i1 %.r1722, %.r1723
  br i1 %.r1724, label %idx.fail.1726, label %idx.ok.1725
idx.fail.1726:
  %.p1727 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p1727, i64 %.r1719, i64 %.r1721)
  call void @exit(i32 1)
  unreachable
idx.ok.1725:
  %.p1729 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %__fld.46, i32 0, i32 2
  %.p1728 = load %Token*, %Token** %.p1729
  %.p1730 = getelementptr inbounds %Token, %Token* %.p1728, i64 %.r1719
  %.t51 = load %Token, %Token* %.p1730
  store %Token %.t51, %Token* %t
  %.p1731 = getelementptr %Token, %Token* null, i32 1
  %.r1732 = ptrtoint %Token* %.p1731 to i64
  %.p1733 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %out, i32 0, i32 0
  %.p1734 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %out, i32 0, i32 1
  %.p1735 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %out, i32 0, i32 2
  %.r1736 = load i64, i64* %.p1733
  %.r1737 = load i64, i64* %.p1734
  %.r1738 = icmp sge i64 %.r1736, %.r1737
  br i1 %.r1738, label %append.grow.1739, label %append.after.1740
append.grow.1739:
  %.r1741 = load %Token*, %Token** %.p1735
  %.r1742 = icmp eq i64 %.r1737, 0
  %.r1743 = mul i64 %.r1737, 2
  %.r1744 = select i1 %.r1742, i64 1, i64 %.r1743
  %.r1745 = mul i64 %.r1744, %.r1732
  %.p1746 = call i8* @malloc(i64 %.r1745)
  %.p1747 = bitcast i8* %.p1746 to %Token*
  %.r1748 = mul i64 %.r1736, %.r1732
  %.p1749 = bitcast %Token* %.r1741 to i8*
  call i8* @memcpy(i8* %.p1746, i8* %.p1749, i64 %.r1748)
  call void @free(i8* %.p1749)
  store %Token* %.p1747, %Token** %.p1735
  store i64 %.r1744, i64* %.p1734
  br label %append.after.1740
append.after.1740:
  %.r1750 = load %Token*, %Token** %.p1735
  %.r1751 = load %Token, %Token* %t
  %.p1752 = getelementptr inbounds %Token, %Token* %.r1750, i64 %.r1736
  store %Token %.r1751, %Token* %.p1752
  %.r1753 = add i64 %.r1736, 1
  store i64 %.r1753, i64* %.p1733
  br label %foreach_step_30
foreach_step_30:
  %.r1754 = load i64, i64* %__for.idx.47
  %.t52 = add i64 %.r1754, 1
  store i64 %.t52, i64* %__for.idx.47
  br label %foreach_cond_28
foreach_end_31:
  %__fld.53 = getelementptr inbounds %RawLine, %RawLine* %raw, i32 0, i32 2
  %__fld.54 = getelementptr inbounds %RawLine, %RawLine* %raw, i32 0, i32 2
  %.p1755 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %__fld.54, i32 0, i32 0
  %.t55 = load i64, i64* %.p1755
  %.t56 = sub i64 %.t55, 1
  %.p1756 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %__fld.53, i32 0, i32 0
  %.r1757 = load i64, i64* %.p1756
  %.r1758 = icmp slt i64 %.t56, 0
  %.r1759 = icmp sge i64 %.t56, %.r1757
  %.r1760 = or i1 %.r1758, %.r1759
  br i1 %.r1760, label %idx.fail.1762, label %idx.ok.1761
idx.fail.1762:
  %.p1763 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p1763, i64 %.t56, i64 %.r1757)
  call void @exit(i32 1)
  unreachable
idx.ok.1761:
  %.p1765 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %__fld.53, i32 0, i32 2
  %.p1764 = load %Token*, %Token** %.p1765
  %.p1766 = getelementptr inbounds %Token, %Token* %.p1764, i64 %.t56
  %__elem.57 = bitcast %Token* %.p1766 to %Token*
  %__fld.58 = getelementptr inbounds %Token, %Token* %__elem.57, i32 0, i32 3
  %.r1767 = load %Span, %Span* %__fld.58
  store %Span %.r1767, %Span* %last_span
  %.t60 = bitcast %Span* %last_span to %Span*
  %.p1768 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.p1769 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @tok_new(%Token* %__agg.59, i8* %.p1768, i8* %.p1769, i64 0, %Span* %.t60)
  %.p1770 = getelementptr %Token, %Token* null, i32 1
  %.r1771 = ptrtoint %Token* %.p1770 to i64
  %.p1772 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %out, i32 0, i32 0
  %.p1773 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %out, i32 0, i32 1
  %.p1774 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %out, i32 0, i32 2
  %.r1775 = load i64, i64* %.p1772
  %.r1776 = load i64, i64* %.p1773
  %.r1777 = icmp sge i64 %.r1775, %.r1776
  br i1 %.r1777, label %append.grow.1778, label %append.after.1779
append.grow.1778:
  %.r1780 = load %Token*, %Token** %.p1774
  %.r1781 = icmp eq i64 %.r1776, 0
  %.r1782 = mul i64 %.r1776, 2
  %.r1783 = select i1 %.r1781, i64 1, i64 %.r1782
  %.r1784 = mul i64 %.r1783, %.r1771
  %.p1785 = call i8* @malloc(i64 %.r1784)
  %.p1786 = bitcast i8* %.p1785 to %Token*
  %.r1787 = mul i64 %.r1775, %.r1771
  %.p1788 = bitcast %Token* %.r1780 to i8*
  call i8* @memcpy(i8* %.p1785, i8* %.p1788, i64 %.r1787)
  call void @free(i8* %.p1788)
  store %Token* %.p1786, %Token** %.p1774
  store i64 %.r1783, i64* %.p1773
  br label %append.after.1779
append.after.1779:
  %.r1789 = load %Token*, %Token** %.p1774
  %.r1790 = load %Token, %Token* %__agg.59
  %.p1791 = getelementptr inbounds %Token, %Token* %.r1789, i64 %.r1775
  store %Token %.r1790, %Token* %.p1791
  %.r1792 = add i64 %.r1775, 1
  store i64 %.r1792, i64* %.p1772
  br label %foreach_step_2
foreach_step_2:
  %.r1793 = load i64, i64* %__for.idx.1
  %.t61 = add i64 %.r1793, 1
  store i64 %.t61, i64* %__for.idx.1
  br label %foreach_cond_0
foreach_end_3:
  %.p1794 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 3
  %.t62 = load i64, i64* %.p1794
  %.p1795 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 3
  %.t63 = load i64, i64* %.p1795
  %.p1796 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 4
  %.t64 = load i64, i64* %.p1796
  %.p1797 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 5
  %.t65 = load i64, i64* %.p1797
  call void @span_new(%Span* %eof_span, i64 %.t62, i64 %.t63, i64 %.t64, i64 %.t65)
  br label %while_cond_32
while_cond_32:
  %.p1798 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_ind, i32 0, i32 0
  %.t66 = load i64, i64* %.p1798
  %.t67 = icmp sgt i64 %.t66, 1
  br i1 %.t67, label %while_body_33, label %while_end_34
while_body_33:
  %.p1799 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_ind, i32 0, i32 0
  %.r1800 = load i64, i64* %.p1799
  %.r1801 = sub i64 %.r1800, 1
  %.p1802 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_ind, i32 0, i32 0
  %.r1803 = load i64, i64* %.p1802
  %.r1804 = icmp slt i64 %.r1801, 0
  %.r1805 = icmp sge i64 %.r1801, %.r1803
  %.r1806 = or i1 %.r1804, %.r1805
  br i1 %.r1806, label %idx.fail.1808, label %idx.ok.1807
idx.fail.1808:
  %.p1809 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p1809, i64 %.r1801, i64 %.r1803)
  call void @exit(i32 1)
  unreachable
idx.ok.1807:
  %.p1811 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_ind, i32 0, i32 2
  %.p1810 = load i64*, i64** %.p1811
  %.p1812 = getelementptr inbounds i64, i64* %.p1810, i64 %.r1801
  %.t68 = load i64, i64* %.p1812
  %.p1813 = getelementptr i64, i64* null, i32 1
  %.r1814 = ptrtoint i64* %.p1813 to i64
  %.p1815 = getelementptr inbounds i64, i64* %.p1812, i64 1
  %.r1816 = sub i64 %.r1800, %.r1801
  %.r1817 = sub i64 %.r1816, 1
  %.r1818 = mul i64 %.r1817, %.r1814
  %.p1819 = bitcast i64* %.p1812 to i8*
  %.p1820 = bitcast i64* %.p1815 to i8*
  call i8* @memmove(i8* %.p1819, i8* %.p1820, i64 %.r1818)
  %.r1821 = sub i64 %.r1800, 1
  store i64 %.r1821, i64* %.p1799
  %.p1822 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_chars, i32 0, i32 0
  %.r1823 = load i64, i64* %.p1822
  %.r1824 = sub i64 %.r1823, 1
  %.p1825 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_chars, i32 0, i32 0
  %.r1826 = load i64, i64* %.p1825
  %.r1827 = icmp slt i64 %.r1824, 0
  %.r1828 = icmp sge i64 %.r1824, %.r1826
  %.r1829 = or i1 %.r1827, %.r1828
  br i1 %.r1829, label %idx.fail.1831, label %idx.ok.1830
idx.fail.1831:
  %.p1832 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p1832, i64 %.r1824, i64 %.r1826)
  call void @exit(i32 1)
  unreachable
idx.ok.1830:
  %.p1834 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stack_chars, i32 0, i32 2
  %.p1833 = load i64*, i64** %.p1834
  %.p1835 = getelementptr inbounds i64, i64* %.p1833, i64 %.r1824
  %.t69 = load i64, i64* %.p1835
  %.p1836 = getelementptr i64, i64* null, i32 1
  %.r1837 = ptrtoint i64* %.p1836 to i64
  %.p1838 = getelementptr inbounds i64, i64* %.p1835, i64 1
  %.r1839 = sub i64 %.r1823, %.r1824
  %.r1840 = sub i64 %.r1839, 1
  %.r1841 = mul i64 %.r1840, %.r1837
  %.p1842 = bitcast i64* %.p1835 to i8*
  %.p1843 = bitcast i64* %.p1838 to i8*
  call i8* @memmove(i8* %.p1842, i8* %.p1843, i64 %.r1841)
  %.r1844 = sub i64 %.r1823, 1
  store i64 %.r1844, i64* %.p1822
  %.t71 = bitcast %Span* %eof_span to %Span*
  %.p1845 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.222, i64 0, i64 0
  %.p1846 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @tok_new(%Token* %__agg.70, i8* %.p1845, i8* %.p1846, i64 0, %Span* %.t71)
  %.p1847 = getelementptr %Token, %Token* null, i32 1
  %.r1848 = ptrtoint %Token* %.p1847 to i64
  %.p1849 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %out, i32 0, i32 0
  %.p1850 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %out, i32 0, i32 1
  %.p1851 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %out, i32 0, i32 2
  %.r1852 = load i64, i64* %.p1849
  %.r1853 = load i64, i64* %.p1850
  %.r1854 = icmp sge i64 %.r1852, %.r1853
  br i1 %.r1854, label %append.grow.1855, label %append.after.1856
append.grow.1855:
  %.r1857 = load %Token*, %Token** %.p1851
  %.r1858 = icmp eq i64 %.r1853, 0
  %.r1859 = mul i64 %.r1853, 2
  %.r1860 = select i1 %.r1858, i64 1, i64 %.r1859
  %.r1861 = mul i64 %.r1860, %.r1848
  %.p1862 = call i8* @malloc(i64 %.r1861)
  %.p1863 = bitcast i8* %.p1862 to %Token*
  %.r1864 = mul i64 %.r1852, %.r1848
  %.p1865 = bitcast %Token* %.r1857 to i8*
  call i8* @memcpy(i8* %.p1862, i8* %.p1865, i64 %.r1864)
  call void @free(i8* %.p1865)
  store %Token* %.p1863, %Token** %.p1851
  store i64 %.r1860, i64* %.p1850
  br label %append.after.1856
append.after.1856:
  %.r1866 = load %Token*, %Token** %.p1851
  %.r1867 = load %Token, %Token* %__agg.70
  %.p1868 = getelementptr inbounds %Token, %Token* %.r1866, i64 %.r1852
  store %Token %.r1867, %Token* %.p1868
  %.r1869 = add i64 %.r1852, 1
  store i64 %.r1869, i64* %.p1849
  br label %while_cond_32
while_end_34:
  %.t73 = bitcast %Span* %eof_span to %Span*
  %.p1870 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.224, i64 0, i64 0
  %.p1871 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @tok_new(%Token* %__agg.72, i8* %.p1870, i8* %.p1871, i64 0, %Span* %.t73)
  %.p1872 = getelementptr %Token, %Token* null, i32 1
  %.r1873 = ptrtoint %Token* %.p1872 to i64
  %.p1874 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %out, i32 0, i32 0
  %.p1875 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %out, i32 0, i32 1
  %.p1876 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %out, i32 0, i32 2
  %.r1877 = load i64, i64* %.p1874
  %.r1878 = load i64, i64* %.p1875
  %.r1879 = icmp sge i64 %.r1877, %.r1878
  br i1 %.r1879, label %append.grow.1880, label %append.after.1881
append.grow.1880:
  %.r1882 = load %Token*, %Token** %.p1876
  %.r1883 = icmp eq i64 %.r1878, 0
  %.r1884 = mul i64 %.r1878, 2
  %.r1885 = select i1 %.r1883, i64 1, i64 %.r1884
  %.r1886 = mul i64 %.r1885, %.r1873
  %.p1887 = call i8* @malloc(i64 %.r1886)
  %.p1888 = bitcast i8* %.p1887 to %Token*
  %.r1889 = mul i64 %.r1877, %.r1873
  %.p1890 = bitcast %Token* %.r1882 to i8*
  call i8* @memcpy(i8* %.p1887, i8* %.p1890, i64 %.r1889)
  call void @free(i8* %.p1890)
  store %Token* %.p1888, %Token** %.p1876
  store i64 %.r1885, i64* %.p1875
  br label %append.after.1881
append.after.1881:
  %.r1891 = load %Token*, %Token** %.p1876
  %.r1892 = load %Token, %Token* %__agg.72
  %.p1893 = getelementptr inbounds %Token, %Token* %.r1891, i64 %.r1877
  store %Token %.r1892, %Token* %.p1893
  %.r1894 = add i64 %.r1877, 1
  store i64 %.r1894, i64* %.p1874
  %.r1895 = load { i64, i64, %Token* }, { i64, i64, %Token* }* %out
  store { i64, i64, %Token* } %.r1895, { i64, i64, %Token* }* %__ret
  ret void
}

define void @Lexer__lex_number(%Token* %__ret, %Lexer* %self) {
entry:
  %start = alloca i64
  %is_float = alloca i1
  %__sc.6 = alloca i1
  %text = alloca i8*
  %__agg.24 = alloca %Span
  %__agg.23 = alloca %Token
  %too_big = alloca i1
  %__sc.28 = alloca i1
  %__agg.36 = alloca %Span
  %__agg.41 = alloca %Token
  %v = alloca i64
  %i = alloca i64
  %__agg.50 = alloca %Span
  %__agg.49 = alloca %Token
  %.p1896 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 3
  %.t0 = load i64, i64* %.p1896
  store i64 %.t0, i64* %start
  br label %while_cond_0
while_cond_0:
  %.t1 = bitcast %Lexer* %self to %Lexer*
  %.t2 = call i64 @Lexer__peek(%Lexer* %.t1)
  %.t3 = call i1 @is_digit_cp(i64 %.t2)
  br i1 %.t3, label %while_body_1, label %while_end_2
while_body_1:
  %.t4 = bitcast %Lexer* %self to %Lexer*
  %.t5 = call i64 @Lexer__advance(%Lexer* %.t4)
  br label %while_cond_0
while_end_2:
  store i1 false, i1* %is_float
  %.t7 = bitcast %Lexer* %self to %Lexer*
  %.t8 = call i64 @Lexer__peek(%Lexer* %.t7)
  %.t9 = icmp eq i64 %.t8, 46
  br i1 %.t9, label %sc_rhs_6, label %sc_short_7
sc_rhs_6:
  %.t10 = bitcast %Lexer* %self to %Lexer*
  %.t11 = call i64 @Lexer__peek_at(%Lexer* %.t10, i64 1)
  %.t12 = call i1 @is_digit_cp(i64 %.t11)
  store i1 %.t12, i1* %__sc.6
  br label %sc_end_8
sc_short_7:
  store i1 false, i1* %__sc.6
  br label %sc_end_8
sc_end_8:
  %.r1897 = load i1, i1* %__sc.6
  br i1 %.r1897, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  store i1 true, i1* %is_float
  %.t13 = bitcast %Lexer* %self to %Lexer*
  %.t14 = call i64 @Lexer__advance(%Lexer* %.t13)
  br label %while_cond_9
while_cond_9:
  %.t15 = bitcast %Lexer* %self to %Lexer*
  %.t16 = call i64 @Lexer__peek(%Lexer* %.t15)
  %.t17 = call i1 @is_digit_cp(i64 %.t16)
  br i1 %.t17, label %while_body_10, label %while_end_11
while_body_10:
  %.t18 = bitcast %Lexer* %self to %Lexer*
  %.t19 = call i64 @Lexer__advance(%Lexer* %.t18)
  br label %while_cond_9
while_end_11:
  br label %if_end_3
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.t20 = bitcast %Lexer* %self to %Lexer*
  %.p1898 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 3
  %.t21 = load i64, i64* %.p1898
  %.r1899 = load i64, i64* %start
  %.t22 = call i8* @Lexer__slice(%Lexer* %.t20, i64 %.r1899, i64 %.t21)
  store i8* %.t22, i8** %text
  %.r1900 = load i1, i1* %is_float
  br i1 %.r1900, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  call void @span_dummy(%Span* %__agg.24)
  %.t25 = bitcast %Span* %__agg.24 to %Span*
  %.p1901 = getelementptr inbounds [13 x i8], [13 x i8]* @.str.94, i64 0, i64 0
  %.r1902 = load i8*, i8** %text
  call void @tok_new(%Token* %__agg.23, i8* %.p1901, i8* %.r1902, i64 0, %Span* %.t25)
  %.r1903 = load %Token, %Token* %__agg.23
  store %Token %.r1903, %Token* %__ret
  ret void
if_next_0_14:
  br label %if_end_12
if_end_12:
  store i1 false, i1* %too_big
  %.r1904 = load i8*, i8** %text
  %.t26 = call i64 @strlen(i8* %.r1904)
  %.t27 = icmp sgt i64 %.t26, 19
  br i1 %.t27, label %if_then_0_16, label %if_next_0_17
if_then_0_16:
  store i1 true, i1* %too_big
  br label %if_end_15
if_next_0_17:
  %.r1905 = load i8*, i8** %text
  %.t29 = call i64 @strlen(i8* %.r1905)
  %.t30 = icmp eq i64 %.t29, 19
  br i1 %.t30, label %sc_rhs_20, label %sc_short_21
sc_rhs_20:
  %.r1906 = load i8*, i8** %text
  %.p1907 = getelementptr inbounds [20 x i8], [20 x i8]* @.str.232, i64 0, i64 0
  %.r1908 = call i32 @strcmp(i8* %.r1906, i8* %.p1907)
  %.t31 = icmp sgt i32 %.r1908, 0
  store i1 %.t31, i1* %__sc.28
  br label %sc_end_22
sc_short_21:
  store i1 false, i1* %__sc.28
  br label %sc_end_22
sc_end_22:
  %.r1909 = load i1, i1* %__sc.28
  br i1 %.r1909, label %if_then_1_18, label %if_next_1_19
if_then_1_18:
  store i1 true, i1* %too_big
  br label %if_end_15
if_next_1_19:
  br label %if_end_15
if_end_15:
  %.r1910 = load i1, i1* %too_big
  br i1 %.r1910, label %if_then_0_24, label %if_next_0_25
if_then_0_24:
  %__fld.32 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 6
  %.t33 = bitcast %Diags* %__fld.32 to %Diags*
  %.p1911 = getelementptr inbounds [18 x i8], [18 x i8]* @.str.92, i64 0, i64 0
  %.r1912 = load i8*, i8** %text
  %.r1913 = call i64 @strlen(i8* %.p1911)
  %.r1914 = call i64 @strlen(i8* %.r1912)
  %.r1915 = add i64 %.r1913, %.r1914
  %.r1916 = add i64 %.r1915, 1
  %.t34 = call i8* @malloc(i64 %.r1916)
  call i8* @memcpy(i8* %.t34, i8* %.p1911, i64 %.r1913)
  %.p1917 = getelementptr inbounds i8, i8* %.t34, i64 %.r1913
  call i8* @memcpy(i8* %.p1917, i8* %.r1912, i64 %.r1914)
  %.p1918 = getelementptr inbounds i8, i8* %.t34, i64 %.r1915
  store i8 0, i8* %.p1918
  %.p1919 = getelementptr inbounds [15 x i8], [15 x i8]* @.str.233, i64 0, i64 0
  %.r1920 = call i64 @strlen(i8* %.t34)
  %.r1921 = call i64 @strlen(i8* %.p1919)
  %.r1922 = add i64 %.r1920, %.r1921
  %.r1923 = add i64 %.r1922, 1
  %.t35 = call i8* @malloc(i64 %.r1923)
  call i8* @memcpy(i8* %.t35, i8* %.t34, i64 %.r1920)
  %.p1924 = getelementptr inbounds i8, i8* %.t35, i64 %.r1920
  call i8* @memcpy(i8* %.p1924, i8* %.p1919, i64 %.r1921)
  %.p1925 = getelementptr inbounds i8, i8* %.t35, i64 %.r1922
  store i8 0, i8* %.p1925
  %.p1926 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 3
  %.t37 = load i64, i64* %.p1926
  %.p1927 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 4
  %.t38 = load i64, i64* %.p1927
  %.p1928 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 5
  %.t39 = load i64, i64* %.p1928
  %.r1929 = load i64, i64* %start
  call void @span_new(%Span* %__agg.36, i64 %.r1929, i64 %.t37, i64 %.t38, i64 %.t39)
  %.t40 = bitcast %Span* %__agg.36 to %Span*
  %.p1930 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.234, i64 0, i64 0
  %.p1931 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p1932 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @Diags__add(%Diags* %.t33, i8* %.p1930, i8* %.t35, %Span* %.t40, i8* %.p1931, i8* %.p1932)
  %.p1933 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p1934 = getelementptr inbounds %Token, %Token* %__agg.41, i32 0, i32 0
  store i8* %.p1933, i8** %.p1934
  %.p1935 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p1936 = getelementptr inbounds %Token, %Token* %__agg.41, i32 0, i32 1
  store i8* %.p1935, i8** %.p1936
  %.p1937 = getelementptr inbounds %Token, %Token* %__agg.41, i32 0, i32 2
  store i64 0, i64* %.p1937
  %.p1938 = getelementptr inbounds %Token, %Token* %__agg.41, i32 0, i32 3
  store %Span zeroinitializer, %Span* %.p1938
  %.r1939 = load %Token, %Token* %__agg.41
  store %Token %.r1939, %Token* %__ret
  ret void
if_next_0_25:
  br label %if_end_23
if_end_23:
  store i64 0, i64* %v
  store i64 0, i64* %i
  br label %while_cond_26
while_cond_26:
  %.r1940 = load i8*, i8** %text
  %.t42 = call i64 @strlen(i8* %.r1940)
  %.r1941 = load i64, i64* %i
  %.t43 = icmp slt i64 %.r1941, %.t42
  br i1 %.t43, label %while_body_27, label %while_end_28
while_body_27:
  %.r1942 = load i64, i64* %v
  %.t44 = mul i64 %.r1942, 10
  %.r1943 = load i8*, i8** %text
  %.r1944 = load i64, i64* %i
  %.p1945 = getelementptr inbounds i8, i8* %.r1943, i64 %.r1944
  %.r1946 = load i8, i8* %.p1945
  %.t45 = zext i8 %.r1946 to i64
  %.t46 = sub i64 %.t45, 48
  %.t47 = add i64 %.t44, %.t46
  store i64 %.t47, i64* %v
  %.r1947 = load i64, i64* %i
  %.t48 = add i64 %.r1947, 1
  store i64 %.t48, i64* %i
  br label %while_cond_26
while_end_28:
  call void @span_dummy(%Span* %__agg.50)
  %.t51 = bitcast %Span* %__agg.50 to %Span*
  %.p1948 = getelementptr inbounds [11 x i8], [11 x i8]* @.str.91, i64 0, i64 0
  %.r1949 = load i8*, i8** %text
  %.r1950 = load i64, i64* %v
  call void @tok_new(%Token* %__agg.49, i8* %.p1948, i8* %.r1949, i64 %.r1950, %Span* %.t51)
  %.r1951 = load %Token, %Token* %__agg.49
  store %Token %.r1951, %Token* %__ret
  ret void
}

define void @Lexer__lex_string(%Token* %__ret, %Lexer* %self, i64 %start_line.arg, i64 %start_col.arg) {
entry:
  %start_line = alloca i64
  %start_col = alloca i64
  %value = alloca i8*
  %c = alloca i64
  %__sc.4 = alloca i1
  %__agg.9 = alloca %Span
  %__agg.13 = alloca %Token
  %e = alloca i64
  %at = alloca i64
  %__agg.46 = alloca %Span
  %__agg.45 = alloca %Token
  store i64 %start_line.arg, i64* %start_line
  store i64 %start_col.arg, i64* %start_col
  %.t0 = bitcast %Lexer* %self to %Lexer*
  %.t1 = call i64 @Lexer__advance(%Lexer* %.t0)
  %.p1952 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  store i8* %.p1952, i8** %value
  br label %while_cond_0
while_cond_0:
  br i1 true, label %while_body_1, label %while_end_2
while_body_1:
  %.t2 = bitcast %Lexer* %self to %Lexer*
  %.t3 = call i64 @Lexer__peek(%Lexer* %.t2)
  store i64 %.t3, i64* %c
  %.r1953 = load i64, i64* %c
  %.t5 = icmp slt i64 %.r1953, 0
  br i1 %.t5, label %sc_short_7, label %sc_rhs_6
sc_rhs_6:
  %.r1954 = load i64, i64* %c
  %.t6 = icmp eq i64 %.r1954, 10
  store i1 %.t6, i1* %__sc.4
  br label %sc_end_8
sc_short_7:
  store i1 true, i1* %__sc.4
  br label %sc_end_8
sc_end_8:
  %.r1955 = load i1, i1* %__sc.4
  br i1 %.r1955, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %__fld.7 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 6
  %.t8 = bitcast %Diags* %__fld.7 to %Diags*
  %.p1956 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 3
  %.t10 = load i64, i64* %.p1956
  %.p1957 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 3
  %.t11 = load i64, i64* %.p1957
  %.r1958 = load i64, i64* %start_line
  %.r1959 = load i64, i64* %start_col
  call void @span_new(%Span* %__agg.9, i64 %.t10, i64 %.t11, i64 %.r1958, i64 %.r1959)
  %.t12 = bitcast %Span* %__agg.9 to %Span*
  %.p1960 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.235, i64 0, i64 0
  %.p1961 = getelementptr inbounds [28 x i8], [28 x i8]* @.str.236, i64 0, i64 0
  %.p1962 = getelementptr inbounds [33 x i8], [33 x i8]* @.str.237, i64 0, i64 0
  %.p1963 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @Diags__add(%Diags* %.t8, i8* %.p1960, i8* %.p1961, %Span* %.t12, i8* %.p1962, i8* %.p1963)
  %.p1964 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p1965 = getelementptr inbounds %Token, %Token* %__agg.13, i32 0, i32 0
  store i8* %.p1964, i8** %.p1965
  %.p1966 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p1967 = getelementptr inbounds %Token, %Token* %__agg.13, i32 0, i32 1
  store i8* %.p1966, i8** %.p1967
  %.p1968 = getelementptr inbounds %Token, %Token* %__agg.13, i32 0, i32 2
  store i64 0, i64* %.p1968
  %.p1969 = getelementptr inbounds %Token, %Token* %__agg.13, i32 0, i32 3
  store %Span zeroinitializer, %Span* %.p1969
  %.r1970 = load %Token, %Token* %__agg.13
  store %Token %.r1970, %Token* %__ret
  ret void
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.r1971 = load i64, i64* %c
  %.t14 = icmp eq i64 %.r1971, 34
  br i1 %.t14, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.t15 = bitcast %Lexer* %self to %Lexer*
  %.t16 = call i64 @Lexer__advance(%Lexer* %.t15)
  br label %while_end_2
if_next_0_11:
  br label %if_end_9
if_end_9:
  %.r1972 = load i64, i64* %c
  %.t17 = icmp eq i64 %.r1972, 92
  br i1 %.t17, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  %.t18 = bitcast %Lexer* %self to %Lexer*
  %.t19 = call i64 @Lexer__advance(%Lexer* %.t18)
  %.t20 = bitcast %Lexer* %self to %Lexer*
  %.t21 = call i64 @Lexer__peek(%Lexer* %.t20)
  store i64 %.t21, i64* %e
  %.r1973 = load i64, i64* %e
  %.t22 = icmp slt i64 %.r1973, 0
  br i1 %.t22, label %if_then_0_16, label %if_next_0_17
if_then_0_16:
  br label %while_end_2
if_next_0_17:
  br label %if_end_15
if_end_15:
  %.p1974 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 3
  %.t23 = load i64, i64* %.p1974
  store i64 %.t23, i64* %at
  %.t24 = bitcast %Lexer* %self to %Lexer*
  %.t25 = call i64 @Lexer__advance(%Lexer* %.t24)
  %.r1975 = load i64, i64* %e
  %.t26 = icmp eq i64 %.r1975, 110
  br i1 %.t26, label %if_then_0_19, label %if_next_0_20
if_then_0_19:
  %.r1976 = load i8*, i8** %value
  %.p1977 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.0, i64 0, i64 0
  %.r1978 = call i64 @strlen(i8* %.r1976)
  %.r1979 = call i64 @strlen(i8* %.p1977)
  %.r1980 = add i64 %.r1978, %.r1979
  %.r1981 = add i64 %.r1980, 1
  %.t27 = call i8* @malloc(i64 %.r1981)
  call i8* @memcpy(i8* %.t27, i8* %.r1976, i64 %.r1978)
  %.p1982 = getelementptr inbounds i8, i8* %.t27, i64 %.r1978
  call i8* @memcpy(i8* %.p1982, i8* %.p1977, i64 %.r1979)
  %.p1983 = getelementptr inbounds i8, i8* %.t27, i64 %.r1980
  store i8 0, i8* %.p1983
  store i8* %.t27, i8** %value
  br label %if_end_18
if_next_0_20:
  %.r1984 = load i64, i64* %e
  %.t28 = icmp eq i64 %.r1984, 116
  br i1 %.t28, label %if_then_1_21, label %if_next_1_22
if_then_1_21:
  %.r1985 = load i8*, i8** %value
  %.p1986 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.238, i64 0, i64 0
  %.r1987 = call i64 @strlen(i8* %.r1985)
  %.r1988 = call i64 @strlen(i8* %.p1986)
  %.r1989 = add i64 %.r1987, %.r1988
  %.r1990 = add i64 %.r1989, 1
  %.t29 = call i8* @malloc(i64 %.r1990)
  call i8* @memcpy(i8* %.t29, i8* %.r1985, i64 %.r1987)
  %.p1991 = getelementptr inbounds i8, i8* %.t29, i64 %.r1987
  call i8* @memcpy(i8* %.p1991, i8* %.p1986, i64 %.r1988)
  %.p1992 = getelementptr inbounds i8, i8* %.t29, i64 %.r1989
  store i8 0, i8* %.p1992
  store i8* %.t29, i8** %value
  br label %if_end_18
if_next_1_22:
  %.r1993 = load i64, i64* %e
  %.t30 = icmp eq i64 %.r1993, 34
  br i1 %.t30, label %if_then_2_23, label %if_next_2_24
if_then_2_23:
  %.r1994 = load i8*, i8** %value
  %.p1995 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.98, i64 0, i64 0
  %.r1996 = call i64 @strlen(i8* %.r1994)
  %.r1997 = call i64 @strlen(i8* %.p1995)
  %.r1998 = add i64 %.r1996, %.r1997
  %.r1999 = add i64 %.r1998, 1
  %.t31 = call i8* @malloc(i64 %.r1999)
  call i8* @memcpy(i8* %.t31, i8* %.r1994, i64 %.r1996)
  %.p2000 = getelementptr inbounds i8, i8* %.t31, i64 %.r1996
  call i8* @memcpy(i8* %.p2000, i8* %.p1995, i64 %.r1997)
  %.p2001 = getelementptr inbounds i8, i8* %.t31, i64 %.r1998
  store i8 0, i8* %.p2001
  store i8* %.t31, i8** %value
  br label %if_end_18
if_next_2_24:
  %.r2002 = load i64, i64* %e
  %.t32 = icmp eq i64 %.r2002, 92
  br i1 %.t32, label %if_then_3_25, label %if_next_3_26
if_then_3_25:
  %.r2003 = load i8*, i8** %value
  %.p2004 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.239, i64 0, i64 0
  %.r2005 = call i64 @strlen(i8* %.r2003)
  %.r2006 = call i64 @strlen(i8* %.p2004)
  %.r2007 = add i64 %.r2005, %.r2006
  %.r2008 = add i64 %.r2007, 1
  %.t33 = call i8* @malloc(i64 %.r2008)
  call i8* @memcpy(i8* %.t33, i8* %.r2003, i64 %.r2005)
  %.p2009 = getelementptr inbounds i8, i8* %.t33, i64 %.r2005
  call i8* @memcpy(i8* %.p2009, i8* %.p2004, i64 %.r2006)
  %.p2010 = getelementptr inbounds i8, i8* %.t33, i64 %.r2007
  store i8 0, i8* %.p2010
  store i8* %.t33, i8** %value
  br label %if_end_18
if_next_3_26:
  %.t34 = bitcast %Lexer* %self to %Lexer*
  %.r2011 = load i64, i64* %at
  %.t35 = add i64 %.r2011, 1
  %.r2012 = load i64, i64* %at
  %.t36 = call i8* @Lexer__slice(%Lexer* %.t34, i64 %.r2012, i64 %.t35)
  %.r2013 = load i8*, i8** %value
  %.r2014 = call i64 @strlen(i8* %.r2013)
  %.r2015 = call i64 @strlen(i8* %.t36)
  %.r2016 = add i64 %.r2014, %.r2015
  %.r2017 = add i64 %.r2016, 1
  %.t37 = call i8* @malloc(i64 %.r2017)
  call i8* @memcpy(i8* %.t37, i8* %.r2013, i64 %.r2014)
  %.p2018 = getelementptr inbounds i8, i8* %.t37, i64 %.r2014
  call i8* @memcpy(i8* %.p2018, i8* %.t36, i64 %.r2015)
  %.p2019 = getelementptr inbounds i8, i8* %.t37, i64 %.r2016
  store i8 0, i8* %.p2019
  store i8* %.t37, i8** %value
  br label %if_end_18
if_end_18:
  br label %if_end_12
if_next_0_14:
  %.p2020 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 3
  %.t38 = load i64, i64* %.p2020
  store i64 %.t38, i64* %at
  %.t39 = bitcast %Lexer* %self to %Lexer*
  %.t40 = call i64 @Lexer__advance(%Lexer* %.t39)
  %.t41 = bitcast %Lexer* %self to %Lexer*
  %.r2021 = load i64, i64* %at
  %.t42 = add i64 %.r2021, 1
  %.r2022 = load i64, i64* %at
  %.t43 = call i8* @Lexer__slice(%Lexer* %.t41, i64 %.r2022, i64 %.t42)
  %.r2023 = load i8*, i8** %value
  %.r2024 = call i64 @strlen(i8* %.r2023)
  %.r2025 = call i64 @strlen(i8* %.t43)
  %.r2026 = add i64 %.r2024, %.r2025
  %.r2027 = add i64 %.r2026, 1
  %.t44 = call i8* @malloc(i64 %.r2027)
  call i8* @memcpy(i8* %.t44, i8* %.r2023, i64 %.r2024)
  %.p2028 = getelementptr inbounds i8, i8* %.t44, i64 %.r2024
  call i8* @memcpy(i8* %.p2028, i8* %.t43, i64 %.r2025)
  %.p2029 = getelementptr inbounds i8, i8* %.t44, i64 %.r2026
  store i8 0, i8* %.p2029
  store i8* %.t44, i8** %value
  br label %if_end_12
if_end_12:
  br label %while_cond_0
while_end_2:
  call void @span_dummy(%Span* %__agg.46)
  %.t47 = bitcast %Span* %__agg.46 to %Span*
  %.p2030 = getelementptr inbounds [14 x i8], [14 x i8]* @.str.96, i64 0, i64 0
  %.r2031 = load i8*, i8** %value
  call void @tok_new(%Token* %__agg.45, i8* %.p2030, i8* %.r2031, i64 0, %Span* %.t47)
  %.r2032 = load %Token, %Token* %__agg.45
  store %Token %.r2032, %Token* %__ret
  ret void
}

define void @Lexer__lex_identifier(%Token* %__ret, %Lexer* %self) {
entry:
  %start = alloca i64
  %__sc.1 = alloca i1
  %text = alloca i8*
  %kw = alloca i8*
  %__agg.17 = alloca %Span
  %__agg.16 = alloca %Token
  %__agg.20 = alloca %Span
  %__agg.19 = alloca %Token
  %.p2033 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 3
  %.t0 = load i64, i64* %.p2033
  store i64 %.t0, i64* %start
  br label %while_cond_0
while_cond_0:
  %.t2 = bitcast %Lexer* %self to %Lexer*
  %.t3 = call i64 @Lexer__peek(%Lexer* %.t2)
  %.t4 = icmp sge i64 %.t3, 0
  br i1 %.t4, label %sc_rhs_3, label %sc_short_4
sc_rhs_3:
  %.t5 = bitcast %Lexer* %self to %Lexer*
  %.t6 = call i64 @Lexer__peek(%Lexer* %.t5)
  %.t7 = call i1 @is_ident_continue_cp(i64 %.t6)
  store i1 %.t7, i1* %__sc.1
  br label %sc_end_5
sc_short_4:
  store i1 false, i1* %__sc.1
  br label %sc_end_5
sc_end_5:
  %.r2034 = load i1, i1* %__sc.1
  br i1 %.r2034, label %while_body_1, label %while_end_2
while_body_1:
  %.t8 = bitcast %Lexer* %self to %Lexer*
  %.t9 = call i64 @Lexer__advance(%Lexer* %.t8)
  br label %while_cond_0
while_end_2:
  %.t10 = bitcast %Lexer* %self to %Lexer*
  %.p2035 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 3
  %.t11 = load i64, i64* %.p2035
  %.r2036 = load i64, i64* %start
  %.t12 = call i8* @Lexer__slice(%Lexer* %.t10, i64 %.r2036, i64 %.t11)
  store i8* %.t12, i8** %text
  %.r2037 = load i8*, i8** %text
  %.t13 = call i8* @lookup_keyword(i8* %.r2037)
  store i8* %.t13, i8** %kw
  %.r2038 = load i8*, i8** %kw
  %.t14 = call i64 @strlen(i8* %.r2038)
  %.t15 = icmp sgt i64 %.t14, 0
  br i1 %.t15, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  call void @span_dummy(%Span* %__agg.17)
  %.t18 = bitcast %Span* %__agg.17 to %Span*
  %.r2039 = load i8*, i8** %kw
  %.p2040 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @tok_new(%Token* %__agg.16, i8* %.r2039, i8* %.p2040, i64 0, %Span* %.t18)
  %.r2041 = load %Token, %Token* %__agg.16
  store %Token %.r2041, %Token* %__ret
  ret void
if_next_0_8:
  br label %if_end_6
if_end_6:
  call void @span_dummy(%Span* %__agg.20)
  %.t21 = bitcast %Span* %__agg.20 to %Span*
  %.p2042 = getelementptr inbounds [11 x i8], [11 x i8]* @.str.101, i64 0, i64 0
  %.r2043 = load i8*, i8** %text
  call void @tok_new(%Token* %__agg.19, i8* %.p2042, i8* %.r2043, i64 0, %Span* %.t21)
  %.r2044 = load %Token, %Token* %__agg.19
  store %Token %.r2044, %Token* %__ret
  ret void
}

define void @Lexer__op2(%Token* %__ret, %Lexer* %self, i8* %single.arg, i8* %with_eq.arg) {
entry:
  %single = alloca i8*
  %with_eq = alloca i8*
  %__agg.6 = alloca %Span
  %__agg.5 = alloca %Token
  %__agg.9 = alloca %Span
  %__agg.8 = alloca %Token
  store i8* %single.arg, i8** %single
  store i8* %with_eq.arg, i8** %with_eq
  %.t0 = bitcast %Lexer* %self to %Lexer*
  %.t1 = call i64 @Lexer__peek(%Lexer* %.t0)
  %.t2 = icmp eq i64 %.t1, 61
  br i1 %.t2, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t3 = bitcast %Lexer* %self to %Lexer*
  %.t4 = call i64 @Lexer__advance(%Lexer* %.t3)
  call void @span_dummy(%Span* %__agg.6)
  %.t7 = bitcast %Span* %__agg.6 to %Span*
  %.r2045 = load i8*, i8** %with_eq
  %.p2046 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @tok_new(%Token* %__agg.5, i8* %.r2045, i8* %.p2046, i64 0, %Span* %.t7)
  %.r2047 = load %Token, %Token* %__agg.5
  store %Token %.r2047, %Token* %__ret
  ret void
if_next_0_2:
  br label %if_end_0
if_end_0:
  call void @span_dummy(%Span* %__agg.9)
  %.t10 = bitcast %Span* %__agg.9 to %Span*
  %.r2048 = load i8*, i8** %single
  %.p2049 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @tok_new(%Token* %__agg.8, i8* %.r2048, i8* %.p2049, i64 0, %Span* %.t10)
  %.r2050 = load %Token, %Token* %__agg.8
  store %Token %.r2050, %Token* %__ret
  ret void
}

define void @Lexer__lex_operator(%Token* %__ret, %Lexer* %self, i64 %line.arg, i64 %col.arg) {
entry:
  %line = alloca i64
  %col = alloca i64
  %c = alloca i64
  %__agg.6 = alloca %Span
  %__agg.5 = alloca %Token
  %__agg.12 = alloca %Span
  %__agg.11 = alloca %Token
  %__agg.18 = alloca %Span
  %__agg.17 = alloca %Token
  %__agg.24 = alloca %Span
  %__agg.23 = alloca %Token
  %__agg.30 = alloca %Span
  %__agg.29 = alloca %Token
  %__agg.36 = alloca %Span
  %__agg.35 = alloca %Token
  %__agg.40 = alloca %Span
  %__agg.39 = alloca %Token
  %__agg.44 = alloca %Span
  %__agg.43 = alloca %Token
  %__agg.48 = alloca %Span
  %__agg.47 = alloca %Token
  %__agg.51 = alloca %Token
  %__agg.54 = alloca %Token
  %__agg.57 = alloca %Token
  %__agg.60 = alloca %Token
  %__agg.63 = alloca %Token
  %__agg.66 = alloca %Token
  %__agg.69 = alloca %Token
  %__agg.73 = alloca %Span
  %__agg.72 = alloca %Token
  %__agg.82 = alloca %Span
  %__agg.81 = alloca %Token
  %__agg.84 = alloca %Token
  %__agg.87 = alloca %Token
  %__agg.96 = alloca %Span
  %__agg.95 = alloca %Token
  %__agg.100 = alloca %Span
  %__agg.105 = alloca %Token
  %__agg.113 = alloca %Span
  %__agg.112 = alloca %Token
  %__agg.120 = alloca %Token
  %__agg.123 = alloca %Span
  %__agg.122 = alloca %Token
  %__agg.132 = alloca %Span
  %__agg.131 = alloca %Token
  %__agg.139 = alloca %Token
  %__agg.142 = alloca %Span
  %__agg.141 = alloca %Token
  %help = alloca i8*
  %__agg.154 = alloca %Span
  %__agg.159 = alloca %Token
  store i64 %line.arg, i64* %line
  store i64 %col.arg, i64* %col
  %.t0 = bitcast %Lexer* %self to %Lexer*
  %.t1 = call i64 @Lexer__advance(%Lexer* %.t0)
  store i64 %.t1, i64* %c
  %.r2051 = load i64, i64* %c
  %.t2 = icmp eq i64 %.r2051, 40
  br i1 %.t2, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.p2052 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 8
  %.t3 = load i64, i64* %.p2052
  %.t4 = add i64 %.t3, 1
  %.p2053 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 8
  store i64 %.t4, i64* %.p2053
  call void @span_dummy(%Span* %__agg.6)
  %.t7 = bitcast %Span* %__agg.6 to %Span*
  %.p2054 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.142, i64 0, i64 0
  %.p2055 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @tok_new(%Token* %__agg.5, i8* %.p2054, i8* %.p2055, i64 0, %Span* %.t7)
  %.r2056 = load %Token, %Token* %__agg.5
  store %Token %.r2056, %Token* %__ret
  ret void
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.r2057 = load i64, i64* %c
  %.t8 = icmp eq i64 %.r2057, 41
  br i1 %.t8, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.p2058 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 8
  %.t9 = load i64, i64* %.p2058
  %.t10 = sub i64 %.t9, 1
  %.p2059 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 8
  store i64 %.t10, i64* %.p2059
  call void @span_dummy(%Span* %__agg.12)
  %.t13 = bitcast %Span* %__agg.12 to %Span*
  %.p2060 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.144, i64 0, i64 0
  %.p2061 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @tok_new(%Token* %__agg.11, i8* %.p2060, i8* %.p2061, i64 0, %Span* %.t13)
  %.r2062 = load %Token, %Token* %__agg.11
  store %Token %.r2062, %Token* %__ret
  ret void
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.r2063 = load i64, i64* %c
  %.t14 = icmp eq i64 %.r2063, 91
  br i1 %.t14, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.p2064 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 8
  %.t15 = load i64, i64* %.p2064
  %.t16 = add i64 %.t15, 1
  %.p2065 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 8
  store i64 %.t16, i64* %.p2065
  call void @span_dummy(%Span* %__agg.18)
  %.t19 = bitcast %Span* %__agg.18 to %Span*
  %.p2066 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.146, i64 0, i64 0
  %.p2067 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @tok_new(%Token* %__agg.17, i8* %.p2066, i8* %.p2067, i64 0, %Span* %.t19)
  %.r2068 = load %Token, %Token* %__agg.17
  store %Token %.r2068, %Token* %__ret
  ret void
if_next_0_8:
  br label %if_end_6
if_end_6:
  %.r2069 = load i64, i64* %c
  %.t20 = icmp eq i64 %.r2069, 93
  br i1 %.t20, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.p2070 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 8
  %.t21 = load i64, i64* %.p2070
  %.t22 = sub i64 %.t21, 1
  %.p2071 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 8
  store i64 %.t22, i64* %.p2071
  call void @span_dummy(%Span* %__agg.24)
  %.t25 = bitcast %Span* %__agg.24 to %Span*
  %.p2072 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.148, i64 0, i64 0
  %.p2073 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @tok_new(%Token* %__agg.23, i8* %.p2072, i8* %.p2073, i64 0, %Span* %.t25)
  %.r2074 = load %Token, %Token* %__agg.23
  store %Token %.r2074, %Token* %__ret
  ret void
if_next_0_11:
  br label %if_end_9
if_end_9:
  %.r2075 = load i64, i64* %c
  %.t26 = icmp eq i64 %.r2075, 123
  br i1 %.t26, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  %.p2076 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 8
  %.t27 = load i64, i64* %.p2076
  %.t28 = add i64 %.t27, 1
  %.p2077 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 8
  store i64 %.t28, i64* %.p2077
  call void @span_dummy(%Span* %__agg.30)
  %.t31 = bitcast %Span* %__agg.30 to %Span*
  %.p2078 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.150, i64 0, i64 0
  %.p2079 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @tok_new(%Token* %__agg.29, i8* %.p2078, i8* %.p2079, i64 0, %Span* %.t31)
  %.r2080 = load %Token, %Token* %__agg.29
  store %Token %.r2080, %Token* %__ret
  ret void
if_next_0_14:
  br label %if_end_12
if_end_12:
  %.r2081 = load i64, i64* %c
  %.t32 = icmp eq i64 %.r2081, 125
  br i1 %.t32, label %if_then_0_16, label %if_next_0_17
if_then_0_16:
  %.p2082 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 8
  %.t33 = load i64, i64* %.p2082
  %.t34 = sub i64 %.t33, 1
  %.p2083 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 8
  store i64 %.t34, i64* %.p2083
  call void @span_dummy(%Span* %__agg.36)
  %.t37 = bitcast %Span* %__agg.36 to %Span*
  %.p2084 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.152, i64 0, i64 0
  %.p2085 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @tok_new(%Token* %__agg.35, i8* %.p2084, i8* %.p2085, i64 0, %Span* %.t37)
  %.r2086 = load %Token, %Token* %__agg.35
  store %Token %.r2086, %Token* %__ret
  ret void
if_next_0_17:
  br label %if_end_15
if_end_15:
  %.r2087 = load i64, i64* %c
  %.t38 = icmp eq i64 %.r2087, 44
  br i1 %.t38, label %if_then_0_19, label %if_next_0_20
if_then_0_19:
  call void @span_dummy(%Span* %__agg.40)
  %.t41 = bitcast %Span* %__agg.40 to %Span*
  %.p2088 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.154, i64 0, i64 0
  %.p2089 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @tok_new(%Token* %__agg.39, i8* %.p2088, i8* %.p2089, i64 0, %Span* %.t41)
  %.r2090 = load %Token, %Token* %__agg.39
  store %Token %.r2090, %Token* %__ret
  ret void
if_next_0_20:
  br label %if_end_18
if_end_18:
  %.r2091 = load i64, i64* %c
  %.t42 = icmp eq i64 %.r2091, 58
  br i1 %.t42, label %if_then_0_22, label %if_next_0_23
if_then_0_22:
  call void @span_dummy(%Span* %__agg.44)
  %.t45 = bitcast %Span* %__agg.44 to %Span*
  %.p2092 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.156, i64 0, i64 0
  %.p2093 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @tok_new(%Token* %__agg.43, i8* %.p2092, i8* %.p2093, i64 0, %Span* %.t45)
  %.r2094 = load %Token, %Token* %__agg.43
  store %Token %.r2094, %Token* %__ret
  ret void
if_next_0_23:
  br label %if_end_21
if_end_21:
  %.r2095 = load i64, i64* %c
  %.t46 = icmp eq i64 %.r2095, 46
  br i1 %.t46, label %if_then_0_25, label %if_next_0_26
if_then_0_25:
  call void @span_dummy(%Span* %__agg.48)
  %.t49 = bitcast %Span* %__agg.48 to %Span*
  %.p2096 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.158, i64 0, i64 0
  %.p2097 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @tok_new(%Token* %__agg.47, i8* %.p2096, i8* %.p2097, i64 0, %Span* %.t49)
  %.r2098 = load %Token, %Token* %__agg.47
  store %Token %.r2098, %Token* %__ret
  ret void
if_next_0_26:
  br label %if_end_24
if_end_24:
  %.r2099 = load i64, i64* %c
  %.t50 = icmp eq i64 %.r2099, 43
  br i1 %.t50, label %if_then_0_28, label %if_next_0_29
if_then_0_28:
  %.t52 = bitcast %Lexer* %self to %Lexer*
  %.p2100 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.162, i64 0, i64 0
  %.p2101 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.198, i64 0, i64 0
  call void @Lexer__op2(%Token* %__agg.51, %Lexer* %.t52, i8* %.p2100, i8* %.p2101)
  %.r2102 = load %Token, %Token* %__agg.51
  store %Token %.r2102, %Token* %__ret
  ret void
if_next_0_29:
  br label %if_end_27
if_end_27:
  %.r2103 = load i64, i64* %c
  %.t53 = icmp eq i64 %.r2103, 42
  br i1 %.t53, label %if_then_0_31, label %if_next_0_32
if_then_0_31:
  %.t55 = bitcast %Lexer* %self to %Lexer*
  %.p2104 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.166, i64 0, i64 0
  %.p2105 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.202, i64 0, i64 0
  call void @Lexer__op2(%Token* %__agg.54, %Lexer* %.t55, i8* %.p2104, i8* %.p2105)
  %.r2106 = load %Token, %Token* %__agg.54
  store %Token %.r2106, %Token* %__ret
  ret void
if_next_0_32:
  br label %if_end_30
if_end_30:
  %.r2107 = load i64, i64* %c
  %.t56 = icmp eq i64 %.r2107, 47
  br i1 %.t56, label %if_then_0_34, label %if_next_0_35
if_then_0_34:
  %.t58 = bitcast %Lexer* %self to %Lexer*
  %.p2108 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.168, i64 0, i64 0
  %.p2109 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.204, i64 0, i64 0
  call void @Lexer__op2(%Token* %__agg.57, %Lexer* %.t58, i8* %.p2108, i8* %.p2109)
  %.r2110 = load %Token, %Token* %__agg.57
  store %Token %.r2110, %Token* %__ret
  ret void
if_next_0_35:
  br label %if_end_33
if_end_33:
  %.r2111 = load i64, i64* %c
  %.t59 = icmp eq i64 %.r2111, 37
  br i1 %.t59, label %if_then_0_37, label %if_next_0_38
if_then_0_37:
  %.t61 = bitcast %Lexer* %self to %Lexer*
  %.p2112 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.170, i64 0, i64 0
  %.p2113 = getelementptr inbounds [10 x i8], [10 x i8]* @.str.206, i64 0, i64 0
  call void @Lexer__op2(%Token* %__agg.60, %Lexer* %.t61, i8* %.p2112, i8* %.p2113)
  %.r2114 = load %Token, %Token* %__agg.60
  store %Token %.r2114, %Token* %__ret
  ret void
if_next_0_38:
  br label %if_end_36
if_end_36:
  %.r2115 = load i64, i64* %c
  %.t62 = icmp eq i64 %.r2115, 38
  br i1 %.t62, label %if_then_0_40, label %if_next_0_41
if_then_0_40:
  %.t64 = bitcast %Lexer* %self to %Lexer*
  %.p2116 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.186, i64 0, i64 0
  %.p2117 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.208, i64 0, i64 0
  call void @Lexer__op2(%Token* %__agg.63, %Lexer* %.t64, i8* %.p2116, i8* %.p2117)
  %.r2118 = load %Token, %Token* %__agg.63
  store %Token %.r2118, %Token* %__ret
  ret void
if_next_0_41:
  br label %if_end_39
if_end_39:
  %.r2119 = load i64, i64* %c
  %.t65 = icmp eq i64 %.r2119, 124
  br i1 %.t65, label %if_then_0_43, label %if_next_0_44
if_then_0_43:
  %.t67 = bitcast %Lexer* %self to %Lexer*
  %.p2120 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.188, i64 0, i64 0
  %.p2121 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.210, i64 0, i64 0
  call void @Lexer__op2(%Token* %__agg.66, %Lexer* %.t67, i8* %.p2120, i8* %.p2121)
  %.r2122 = load %Token, %Token* %__agg.66
  store %Token %.r2122, %Token* %__ret
  ret void
if_next_0_44:
  br label %if_end_42
if_end_42:
  %.r2123 = load i64, i64* %c
  %.t68 = icmp eq i64 %.r2123, 94
  br i1 %.t68, label %if_then_0_46, label %if_next_0_47
if_then_0_46:
  %.t70 = bitcast %Lexer* %self to %Lexer*
  %.p2124 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.190, i64 0, i64 0
  %.p2125 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.212, i64 0, i64 0
  call void @Lexer__op2(%Token* %__agg.69, %Lexer* %.t70, i8* %.p2124, i8* %.p2125)
  %.r2126 = load %Token, %Token* %__agg.69
  store %Token %.r2126, %Token* %__ret
  ret void
if_next_0_47:
  br label %if_end_45
if_end_45:
  %.r2127 = load i64, i64* %c
  %.t71 = icmp eq i64 %.r2127, 126
  br i1 %.t71, label %if_then_0_49, label %if_next_0_50
if_then_0_49:
  call void @span_dummy(%Span* %__agg.73)
  %.t74 = bitcast %Span* %__agg.73 to %Span*
  %.p2128 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.192, i64 0, i64 0
  %.p2129 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @tok_new(%Token* %__agg.72, i8* %.p2128, i8* %.p2129, i64 0, %Span* %.t74)
  %.r2130 = load %Token, %Token* %__agg.72
  store %Token %.r2130, %Token* %__ret
  ret void
if_next_0_50:
  br label %if_end_48
if_end_48:
  %.r2131 = load i64, i64* %c
  %.t75 = icmp eq i64 %.r2131, 45
  br i1 %.t75, label %if_then_0_52, label %if_next_0_53
if_then_0_52:
  %.t76 = bitcast %Lexer* %self to %Lexer*
  %.t77 = call i64 @Lexer__peek(%Lexer* %.t76)
  %.t78 = icmp eq i64 %.t77, 62
  br i1 %.t78, label %if_then_0_55, label %if_next_0_56
if_then_0_55:
  %.t79 = bitcast %Lexer* %self to %Lexer*
  %.t80 = call i64 @Lexer__advance(%Lexer* %.t79)
  call void @span_dummy(%Span* %__agg.82)
  %.t83 = bitcast %Span* %__agg.82 to %Span*
  %.p2132 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.160, i64 0, i64 0
  %.p2133 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @tok_new(%Token* %__agg.81, i8* %.p2132, i8* %.p2133, i64 0, %Span* %.t83)
  %.r2134 = load %Token, %Token* %__agg.81
  store %Token %.r2134, %Token* %__ret
  ret void
if_next_0_56:
  br label %if_end_54
if_end_54:
  %.t85 = bitcast %Lexer* %self to %Lexer*
  %.p2135 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.164, i64 0, i64 0
  %.p2136 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.200, i64 0, i64 0
  call void @Lexer__op2(%Token* %__agg.84, %Lexer* %.t85, i8* %.p2135, i8* %.p2136)
  %.r2137 = load %Token, %Token* %__agg.84
  store %Token %.r2137, %Token* %__ret
  ret void
if_next_0_53:
  br label %if_end_51
if_end_51:
  %.r2138 = load i64, i64* %c
  %.t86 = icmp eq i64 %.r2138, 61
  br i1 %.t86, label %if_then_0_58, label %if_next_0_59
if_then_0_58:
  %.t88 = bitcast %Lexer* %self to %Lexer*
  %.p2139 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.184, i64 0, i64 0
  %.p2140 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.172, i64 0, i64 0
  call void @Lexer__op2(%Token* %__agg.87, %Lexer* %.t88, i8* %.p2139, i8* %.p2140)
  %.r2141 = load %Token, %Token* %__agg.87
  store %Token %.r2141, %Token* %__ret
  ret void
if_next_0_59:
  br label %if_end_57
if_end_57:
  %.r2142 = load i64, i64* %c
  %.t89 = icmp eq i64 %.r2142, 33
  br i1 %.t89, label %if_then_0_61, label %if_next_0_62
if_then_0_61:
  %.t90 = bitcast %Lexer* %self to %Lexer*
  %.t91 = call i64 @Lexer__peek(%Lexer* %.t90)
  %.t92 = icmp eq i64 %.t91, 61
  br i1 %.t92, label %if_then_0_64, label %if_next_0_65
if_then_0_64:
  %.t93 = bitcast %Lexer* %self to %Lexer*
  %.t94 = call i64 @Lexer__advance(%Lexer* %.t93)
  call void @span_dummy(%Span* %__agg.96)
  %.t97 = bitcast %Span* %__agg.96 to %Span*
  %.p2143 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.174, i64 0, i64 0
  %.p2144 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @tok_new(%Token* %__agg.95, i8* %.p2143, i8* %.p2144, i64 0, %Span* %.t97)
  %.r2145 = load %Token, %Token* %__agg.95
  store %Token %.r2145, %Token* %__ret
  ret void
if_next_0_65:
  br label %if_end_63
if_end_63:
  %__fld.98 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 6
  %.t99 = bitcast %Diags* %__fld.98 to %Diags*
  %.p2146 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 3
  %.t101 = load i64, i64* %.p2146
  %.t102 = sub i64 %.t101, 1
  %.p2147 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 3
  %.t103 = load i64, i64* %.p2147
  %.r2148 = load i64, i64* %line
  %.r2149 = load i64, i64* %col
  call void @span_new(%Span* %__agg.100, i64 %.t102, i64 %.t103, i64 %.r2148, i64 %.r2149)
  %.t104 = bitcast %Span* %__agg.100 to %Span*
  %.p2150 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.240, i64 0, i64 0
  %.p2151 = getelementptr inbounds [58 x i8], [58 x i8]* @.str.241, i64 0, i64 0
  %.p2152 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p2153 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @Diags__add(%Diags* %.t99, i8* %.p2150, i8* %.p2151, %Span* %.t104, i8* %.p2152, i8* %.p2153)
  %.p2154 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p2155 = getelementptr inbounds %Token, %Token* %__agg.105, i32 0, i32 0
  store i8* %.p2154, i8** %.p2155
  %.p2156 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p2157 = getelementptr inbounds %Token, %Token* %__agg.105, i32 0, i32 1
  store i8* %.p2156, i8** %.p2157
  %.p2158 = getelementptr inbounds %Token, %Token* %__agg.105, i32 0, i32 2
  store i64 0, i64* %.p2158
  %.p2159 = getelementptr inbounds %Token, %Token* %__agg.105, i32 0, i32 3
  store %Span zeroinitializer, %Span* %.p2159
  %.r2160 = load %Token, %Token* %__agg.105
  store %Token %.r2160, %Token* %__ret
  ret void
if_next_0_62:
  br label %if_end_60
if_end_60:
  %.r2161 = load i64, i64* %c
  %.t106 = icmp eq i64 %.r2161, 60
  br i1 %.t106, label %if_then_0_67, label %if_next_0_68
if_then_0_67:
  %.t107 = bitcast %Lexer* %self to %Lexer*
  %.t108 = call i64 @Lexer__peek(%Lexer* %.t107)
  %.t109 = icmp eq i64 %.t108, 61
  br i1 %.t109, label %if_then_0_70, label %if_next_0_71
if_then_0_70:
  %.t110 = bitcast %Lexer* %self to %Lexer*
  %.t111 = call i64 @Lexer__advance(%Lexer* %.t110)
  call void @span_dummy(%Span* %__agg.113)
  %.t114 = bitcast %Span* %__agg.113 to %Span*
  %.p2162 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.180, i64 0, i64 0
  %.p2163 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @tok_new(%Token* %__agg.112, i8* %.p2162, i8* %.p2163, i64 0, %Span* %.t114)
  %.r2164 = load %Token, %Token* %__agg.112
  store %Token %.r2164, %Token* %__ret
  ret void
if_next_0_71:
  br label %if_end_69
if_end_69:
  %.t115 = bitcast %Lexer* %self to %Lexer*
  %.t116 = call i64 @Lexer__peek(%Lexer* %.t115)
  %.t117 = icmp eq i64 %.t116, 60
  br i1 %.t117, label %if_then_0_73, label %if_next_0_74
if_then_0_73:
  %.t118 = bitcast %Lexer* %self to %Lexer*
  %.t119 = call i64 @Lexer__advance(%Lexer* %.t118)
  %.t121 = bitcast %Lexer* %self to %Lexer*
  %.p2165 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.194, i64 0, i64 0
  %.p2166 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.214, i64 0, i64 0
  call void @Lexer__op2(%Token* %__agg.120, %Lexer* %.t121, i8* %.p2165, i8* %.p2166)
  %.r2167 = load %Token, %Token* %__agg.120
  store %Token %.r2167, %Token* %__ret
  ret void
if_next_0_74:
  br label %if_end_72
if_end_72:
  call void @span_dummy(%Span* %__agg.123)
  %.t124 = bitcast %Span* %__agg.123 to %Span*
  %.p2168 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.176, i64 0, i64 0
  %.p2169 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @tok_new(%Token* %__agg.122, i8* %.p2168, i8* %.p2169, i64 0, %Span* %.t124)
  %.r2170 = load %Token, %Token* %__agg.122
  store %Token %.r2170, %Token* %__ret
  ret void
if_next_0_68:
  br label %if_end_66
if_end_66:
  %.r2171 = load i64, i64* %c
  %.t125 = icmp eq i64 %.r2171, 62
  br i1 %.t125, label %if_then_0_76, label %if_next_0_77
if_then_0_76:
  %.t126 = bitcast %Lexer* %self to %Lexer*
  %.t127 = call i64 @Lexer__peek(%Lexer* %.t126)
  %.t128 = icmp eq i64 %.t127, 61
  br i1 %.t128, label %if_then_0_79, label %if_next_0_80
if_then_0_79:
  %.t129 = bitcast %Lexer* %self to %Lexer*
  %.t130 = call i64 @Lexer__advance(%Lexer* %.t129)
  call void @span_dummy(%Span* %__agg.132)
  %.t133 = bitcast %Span* %__agg.132 to %Span*
  %.p2172 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.182, i64 0, i64 0
  %.p2173 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @tok_new(%Token* %__agg.131, i8* %.p2172, i8* %.p2173, i64 0, %Span* %.t133)
  %.r2174 = load %Token, %Token* %__agg.131
  store %Token %.r2174, %Token* %__ret
  ret void
if_next_0_80:
  br label %if_end_78
if_end_78:
  %.t134 = bitcast %Lexer* %self to %Lexer*
  %.t135 = call i64 @Lexer__peek(%Lexer* %.t134)
  %.t136 = icmp eq i64 %.t135, 62
  br i1 %.t136, label %if_then_0_82, label %if_next_0_83
if_then_0_82:
  %.t137 = bitcast %Lexer* %self to %Lexer*
  %.t138 = call i64 @Lexer__advance(%Lexer* %.t137)
  %.t140 = bitcast %Lexer* %self to %Lexer*
  %.p2175 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.196, i64 0, i64 0
  %.p2176 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.216, i64 0, i64 0
  call void @Lexer__op2(%Token* %__agg.139, %Lexer* %.t140, i8* %.p2175, i8* %.p2176)
  %.r2177 = load %Token, %Token* %__agg.139
  store %Token %.r2177, %Token* %__ret
  ret void
if_next_0_83:
  br label %if_end_81
if_end_81:
  call void @span_dummy(%Span* %__agg.142)
  %.t143 = bitcast %Span* %__agg.142 to %Span*
  %.p2178 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.178, i64 0, i64 0
  %.p2179 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @tok_new(%Token* %__agg.141, i8* %.p2178, i8* %.p2179, i64 0, %Span* %.t143)
  %.r2180 = load %Token, %Token* %__agg.141
  store %Token %.r2180, %Token* %__ret
  ret void
if_next_0_77:
  br label %if_end_75
if_end_75:
  %.p2181 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  store i8* %.p2181, i8** %help
  %.r2182 = load i64, i64* %c
  %.t144 = icmp eq i64 %.r2182, 59
  br i1 %.t144, label %if_then_0_85, label %if_next_0_86
if_then_0_85:
  %.p2183 = getelementptr inbounds [61 x i8], [61 x i8]* @.str.242, i64 0, i64 0
  store i8* %.p2183, i8** %help
  br label %if_end_84
if_next_0_86:
  br label %if_end_84
if_end_84:
  %__fld.145 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 6
  %.t146 = bitcast %Diags* %__fld.145 to %Diags*
  %.t147 = bitcast %Lexer* %self to %Lexer*
  %.p2184 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 3
  %.t148 = load i64, i64* %.p2184
  %.t149 = sub i64 %.t148, 1
  %.p2185 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 3
  %.t150 = load i64, i64* %.p2185
  %.t151 = call i8* @Lexer__slice(%Lexer* %.t147, i64 %.t149, i64 %.t150)
  %.p2186 = getelementptr inbounds [23 x i8], [23 x i8]* @.str.243, i64 0, i64 0
  %.r2187 = call i64 @strlen(i8* %.p2186)
  %.r2188 = call i64 @strlen(i8* %.t151)
  %.r2189 = add i64 %.r2187, %.r2188
  %.r2190 = add i64 %.r2189, 1
  %.t152 = call i8* @malloc(i64 %.r2190)
  call i8* @memcpy(i8* %.t152, i8* %.p2186, i64 %.r2187)
  %.p2191 = getelementptr inbounds i8, i8* %.t152, i64 %.r2187
  call i8* @memcpy(i8* %.p2191, i8* %.t151, i64 %.r2188)
  %.p2192 = getelementptr inbounds i8, i8* %.t152, i64 %.r2189
  store i8 0, i8* %.p2192
  %.p2193 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.93, i64 0, i64 0
  %.r2194 = call i64 @strlen(i8* %.t152)
  %.r2195 = call i64 @strlen(i8* %.p2193)
  %.r2196 = add i64 %.r2194, %.r2195
  %.r2197 = add i64 %.r2196, 1
  %.t153 = call i8* @malloc(i64 %.r2197)
  call i8* @memcpy(i8* %.t153, i8* %.t152, i64 %.r2194)
  %.p2198 = getelementptr inbounds i8, i8* %.t153, i64 %.r2194
  call i8* @memcpy(i8* %.p2198, i8* %.p2193, i64 %.r2195)
  %.p2199 = getelementptr inbounds i8, i8* %.t153, i64 %.r2196
  store i8 0, i8* %.p2199
  %.p2200 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 3
  %.t155 = load i64, i64* %.p2200
  %.t156 = sub i64 %.t155, 1
  %.p2201 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 3
  %.t157 = load i64, i64* %.p2201
  %.r2202 = load i64, i64* %line
  %.r2203 = load i64, i64* %col
  call void @span_new(%Span* %__agg.154, i64 %.t156, i64 %.t157, i64 %.r2202, i64 %.r2203)
  %.t158 = bitcast %Span* %__agg.154 to %Span*
  %.p2204 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.240, i64 0, i64 0
  %.p2205 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.r2206 = load i8*, i8** %help
  call void @Diags__add(%Diags* %.t146, i8* %.p2204, i8* %.t153, %Span* %.t158, i8* %.p2205, i8* %.r2206)
  %.p2207 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p2208 = getelementptr inbounds %Token, %Token* %__agg.159, i32 0, i32 0
  store i8* %.p2207, i8** %.p2208
  %.p2209 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p2210 = getelementptr inbounds %Token, %Token* %__agg.159, i32 0, i32 1
  store i8* %.p2209, i8** %.p2210
  %.p2211 = getelementptr inbounds %Token, %Token* %__agg.159, i32 0, i32 2
  store i64 0, i64* %.p2211
  %.p2212 = getelementptr inbounds %Token, %Token* %__agg.159, i32 0, i32 3
  store %Span zeroinitializer, %Span* %.p2212
  %.r2213 = load %Token, %Token* %__agg.159
  store %Token %.r2213, %Token* %__ret
  ret void
}

define void @lex({ i64, i64, %Token* }* %__ret, i8* %source.arg, %Diags* %diags) {
entry:
  %source = alloca i8*
  %lx = alloca %Lexer
  %toks = alloca { i64, i64, %Token* }
  store i8* %source.arg, i8** %source
  %.r2214 = load i8*, i8** %source
  call void @Lexer__new(%Lexer* %lx, i8* %.r2214)
  %.t0 = bitcast %Lexer* %lx to %Lexer*
  call void @Lexer__tokenize({ i64, i64, %Token* }* %toks, %Lexer* %.t0)
  %.t1 = bitcast %Diags* %diags to %Diags*
  %__fld.2 = getelementptr inbounds %Lexer, %Lexer* %lx, i32 0, i32 6
  %.t3 = bitcast %Diags* %__fld.2 to %Diags*
  call void @Diags__extend(%Diags* %.t1, %Diags* %.t3)
  %.r2215 = load { i64, i64, %Token* }, { i64, i64, %Token* }* %toks
  store { i64, i64, %Token* } %.r2215, { i64, i64, %Token* }* %__ret
  ret void
}

define i64 @Ast__addl(%Ast* %self, i8* %kind.arg, i8* %text.arg, %Span* %span, { i64, i64, i64* }* %kids) {
entry:
  %kind = alloca i8*
  %text = alloca i8*
  %n = alloca %Node
  store i8* %kind.arg, i8** %kind
  store i8* %text.arg, i8** %text
  %.p2216 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p2217 = getelementptr inbounds %Node, %Node* %n, i32 0, i32 0
  store i8* %.p2216, i8** %.p2217
  %.p2218 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p2219 = getelementptr inbounds %Node, %Node* %n, i32 0, i32 1
  store i8* %.p2218, i8** %.p2219
  %.p2220 = getelementptr inbounds %Node, %Node* %n, i32 0, i32 2
  store %Span zeroinitializer, %Span* %.p2220
  %.p2221 = getelementptr inbounds %Node, %Node* %n, i32 0, i32 3
  store { i64, i64, i64* } zeroinitializer, { i64, i64, i64* }* %.p2221
  %.r2222 = load i8*, i8** %kind
  %.p2223 = getelementptr inbounds %Node, %Node* %n, i32 0, i32 0
  store i8* %.r2222, i8** %.p2223
  %.r2224 = load i8*, i8** %text
  %.p2225 = getelementptr inbounds %Node, %Node* %n, i32 0, i32 1
  store i8* %.r2224, i8** %.p2225
  %.r2226 = load %Span, %Span* %span
  %.p2227 = getelementptr inbounds %Node, %Node* %n, i32 0, i32 2
  store %Span %.r2226, %Span* %.p2227
  %.r2228 = load { i64, i64, i64* }, { i64, i64, i64* }* %kids
  %.p2229 = getelementptr inbounds %Node, %Node* %n, i32 0, i32 3
  store { i64, i64, i64* } %.r2228, { i64, i64, i64* }* %.p2229
  %__fld.0 = getelementptr inbounds %Ast, %Ast* %self, i32 0, i32 0
  %.p2230 = getelementptr %Node, %Node* null, i32 1
  %.r2231 = ptrtoint %Node* %.p2230 to i64
  %.p2232 = getelementptr inbounds { i64, i64, %Node* }, { i64, i64, %Node* }* %__fld.0, i32 0, i32 0
  %.p2233 = getelementptr inbounds { i64, i64, %Node* }, { i64, i64, %Node* }* %__fld.0, i32 0, i32 1
  %.p2234 = getelementptr inbounds { i64, i64, %Node* }, { i64, i64, %Node* }* %__fld.0, i32 0, i32 2
  %.r2235 = load i64, i64* %.p2232
  %.r2236 = load i64, i64* %.p2233
  %.r2237 = icmp sge i64 %.r2235, %.r2236
  br i1 %.r2237, label %append.grow.2238, label %append.after.2239
append.grow.2238:
  %.r2240 = load %Node*, %Node** %.p2234
  %.r2241 = icmp eq i64 %.r2236, 0
  %.r2242 = mul i64 %.r2236, 2
  %.r2243 = select i1 %.r2241, i64 1, i64 %.r2242
  %.r2244 = mul i64 %.r2243, %.r2231
  %.p2245 = call i8* @malloc(i64 %.r2244)
  %.p2246 = bitcast i8* %.p2245 to %Node*
  %.r2247 = mul i64 %.r2235, %.r2231
  %.p2248 = bitcast %Node* %.r2240 to i8*
  call i8* @memcpy(i8* %.p2245, i8* %.p2248, i64 %.r2247)
  call void @free(i8* %.p2248)
  store %Node* %.p2246, %Node** %.p2234
  store i64 %.r2243, i64* %.p2233
  br label %append.after.2239
append.after.2239:
  %.r2249 = load %Node*, %Node** %.p2234
  %.r2250 = load %Node, %Node* %n
  %.p2251 = getelementptr inbounds %Node, %Node* %.r2249, i64 %.r2235
  store %Node %.r2250, %Node* %.p2251
  %.r2252 = add i64 %.r2235, 1
  store i64 %.r2252, i64* %.p2232
  %__fld.1 = getelementptr inbounds %Ast, %Ast* %self, i32 0, i32 0
  %.p2253 = getelementptr inbounds { i64, i64, %Node* }, { i64, i64, %Node* }* %__fld.1, i32 0, i32 0
  %.t2 = load i64, i64* %.p2253
  %.t3 = sub i64 %.t2, 1
  ret i64 %.t3
}

define i64 @Ast__add0(%Ast* %self, i8* %kind.arg, i8* %text.arg, %Span* %span) {
entry:
  %kind = alloca i8*
  %text = alloca i8*
  %k = alloca { i64, i64, i64* }
  store i8* %kind.arg, i8** %kind
  store i8* %text.arg, i8** %text
  %.p2255 = getelementptr i64, i64* null, i32 1
  %.r2256 = ptrtoint i64* %.p2255 to i64
  %.r2257 = mul i64 %.r2256, 1
  %.p2254 = call i8* @malloc(i64 %.r2257)
  %.p2258 = bitcast i8* %.p2254 to i64*
  %.p2259 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %k, i32 0, i32 0
  store i64 0, i64* %.p2259
  %.p2260 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %k, i32 0, i32 1
  store i64 0, i64* %.p2260
  %.p2261 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %k, i32 0, i32 2
  store i64* %.p2258, i64** %.p2261
  %.t0 = bitcast %Ast* %self to %Ast*
  %.t1 = bitcast %Span* %span to %Span*
  %.t2 = bitcast { i64, i64, i64* }* %k to { i64, i64, i64* }*
  %.r2262 = load i8*, i8** %kind
  %.r2263 = load i8*, i8** %text
  %.t3 = call i64 @Ast__addl(%Ast* %.t0, i8* %.r2262, i8* %.r2263, %Span* %.t1, { i64, i64, i64* }* %.t2)
  ret i64 %.t3
}

define i64 @Ast__add1(%Ast* %self, i8* %kind.arg, i8* %text.arg, %Span* %span, i64 %a.arg) {
entry:
  %kind = alloca i8*
  %text = alloca i8*
  %a = alloca i64
  %__agg.2 = alloca { i64, i64, i64* }
  store i8* %kind.arg, i8** %kind
  store i8* %text.arg, i8** %text
  store i64 %a.arg, i64* %a
  %.t0 = bitcast %Ast* %self to %Ast*
  %.t1 = bitcast %Span* %span to %Span*
  %.p2265 = getelementptr i64, i64* null, i32 1
  %.r2266 = ptrtoint i64* %.p2265 to i64
  %.r2267 = mul i64 %.r2266, 1
  %.p2264 = call i8* @malloc(i64 %.r2267)
  %.p2268 = bitcast i8* %.p2264 to i64*
  %.r2269 = load i64, i64* %a
  %.p2270 = getelementptr inbounds i64, i64* %.p2268, i64 0
  store i64 %.r2269, i64* %.p2270
  %.p2271 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__agg.2, i32 0, i32 0
  store i64 1, i64* %.p2271
  %.p2272 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__agg.2, i32 0, i32 1
  store i64 1, i64* %.p2272
  %.p2273 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__agg.2, i32 0, i32 2
  store i64* %.p2268, i64** %.p2273
  %.t3 = bitcast { i64, i64, i64* }* %__agg.2 to { i64, i64, i64* }*
  %.r2274 = load i8*, i8** %kind
  %.r2275 = load i8*, i8** %text
  %.t4 = call i64 @Ast__addl(%Ast* %.t0, i8* %.r2274, i8* %.r2275, %Span* %.t1, { i64, i64, i64* }* %.t3)
  ret i64 %.t4
}

define i64 @Ast__add2(%Ast* %self, i8* %kind.arg, i8* %text.arg, %Span* %span, i64 %a.arg, i64 %b.arg) {
entry:
  %kind = alloca i8*
  %text = alloca i8*
  %a = alloca i64
  %b = alloca i64
  %__agg.2 = alloca { i64, i64, i64* }
  store i8* %kind.arg, i8** %kind
  store i8* %text.arg, i8** %text
  store i64 %a.arg, i64* %a
  store i64 %b.arg, i64* %b
  %.t0 = bitcast %Ast* %self to %Ast*
  %.t1 = bitcast %Span* %span to %Span*
  %.p2277 = getelementptr i64, i64* null, i32 1
  %.r2278 = ptrtoint i64* %.p2277 to i64
  %.r2279 = mul i64 %.r2278, 2
  %.p2276 = call i8* @malloc(i64 %.r2279)
  %.p2280 = bitcast i8* %.p2276 to i64*
  %.r2281 = load i64, i64* %a
  %.p2282 = getelementptr inbounds i64, i64* %.p2280, i64 0
  store i64 %.r2281, i64* %.p2282
  %.r2283 = load i64, i64* %b
  %.p2284 = getelementptr inbounds i64, i64* %.p2280, i64 1
  store i64 %.r2283, i64* %.p2284
  %.p2285 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__agg.2, i32 0, i32 0
  store i64 2, i64* %.p2285
  %.p2286 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__agg.2, i32 0, i32 1
  store i64 2, i64* %.p2286
  %.p2287 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__agg.2, i32 0, i32 2
  store i64* %.p2280, i64** %.p2287
  %.t3 = bitcast { i64, i64, i64* }* %__agg.2 to { i64, i64, i64* }*
  %.r2288 = load i8*, i8** %kind
  %.r2289 = load i8*, i8** %text
  %.t4 = call i64 @Ast__addl(%Ast* %.t0, i8* %.r2288, i8* %.r2289, %Span* %.t1, { i64, i64, i64* }* %.t3)
  ret i64 %.t4
}

define i64 @Ast__add3(%Ast* %self, i8* %kind.arg, i8* %text.arg, %Span* %span, i64 %a.arg, i64 %b.arg, i64 %c.arg) {
entry:
  %kind = alloca i8*
  %text = alloca i8*
  %a = alloca i64
  %b = alloca i64
  %c = alloca i64
  %__agg.2 = alloca { i64, i64, i64* }
  store i8* %kind.arg, i8** %kind
  store i8* %text.arg, i8** %text
  store i64 %a.arg, i64* %a
  store i64 %b.arg, i64* %b
  store i64 %c.arg, i64* %c
  %.t0 = bitcast %Ast* %self to %Ast*
  %.t1 = bitcast %Span* %span to %Span*
  %.p2291 = getelementptr i64, i64* null, i32 1
  %.r2292 = ptrtoint i64* %.p2291 to i64
  %.r2293 = mul i64 %.r2292, 3
  %.p2290 = call i8* @malloc(i64 %.r2293)
  %.p2294 = bitcast i8* %.p2290 to i64*
  %.r2295 = load i64, i64* %a
  %.p2296 = getelementptr inbounds i64, i64* %.p2294, i64 0
  store i64 %.r2295, i64* %.p2296
  %.r2297 = load i64, i64* %b
  %.p2298 = getelementptr inbounds i64, i64* %.p2294, i64 1
  store i64 %.r2297, i64* %.p2298
  %.r2299 = load i64, i64* %c
  %.p2300 = getelementptr inbounds i64, i64* %.p2294, i64 2
  store i64 %.r2299, i64* %.p2300
  %.p2301 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__agg.2, i32 0, i32 0
  store i64 3, i64* %.p2301
  %.p2302 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__agg.2, i32 0, i32 1
  store i64 3, i64* %.p2302
  %.p2303 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__agg.2, i32 0, i32 2
  store i64* %.p2294, i64** %.p2303
  %.t3 = bitcast { i64, i64, i64* }* %__agg.2 to { i64, i64, i64* }*
  %.r2304 = load i8*, i8** %kind
  %.r2305 = load i8*, i8** %text
  %.t4 = call i64 @Ast__addl(%Ast* %.t0, i8* %.r2304, i8* %.r2305, %Span* %.t1, { i64, i64, i64* }* %.t3)
  ret i64 %.t4
}

define i64 @Ast__add4(%Ast* %self, i8* %kind.arg, i8* %text.arg, %Span* %span, i64 %a.arg, i64 %b.arg, i64 %c.arg, i64 %d.arg) {
entry:
  %kind = alloca i8*
  %text = alloca i8*
  %a = alloca i64
  %b = alloca i64
  %c = alloca i64
  %d = alloca i64
  %__agg.2 = alloca { i64, i64, i64* }
  store i8* %kind.arg, i8** %kind
  store i8* %text.arg, i8** %text
  store i64 %a.arg, i64* %a
  store i64 %b.arg, i64* %b
  store i64 %c.arg, i64* %c
  store i64 %d.arg, i64* %d
  %.t0 = bitcast %Ast* %self to %Ast*
  %.t1 = bitcast %Span* %span to %Span*
  %.p2307 = getelementptr i64, i64* null, i32 1
  %.r2308 = ptrtoint i64* %.p2307 to i64
  %.r2309 = mul i64 %.r2308, 4
  %.p2306 = call i8* @malloc(i64 %.r2309)
  %.p2310 = bitcast i8* %.p2306 to i64*
  %.r2311 = load i64, i64* %a
  %.p2312 = getelementptr inbounds i64, i64* %.p2310, i64 0
  store i64 %.r2311, i64* %.p2312
  %.r2313 = load i64, i64* %b
  %.p2314 = getelementptr inbounds i64, i64* %.p2310, i64 1
  store i64 %.r2313, i64* %.p2314
  %.r2315 = load i64, i64* %c
  %.p2316 = getelementptr inbounds i64, i64* %.p2310, i64 2
  store i64 %.r2315, i64* %.p2316
  %.r2317 = load i64, i64* %d
  %.p2318 = getelementptr inbounds i64, i64* %.p2310, i64 3
  store i64 %.r2317, i64* %.p2318
  %.p2319 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__agg.2, i32 0, i32 0
  store i64 4, i64* %.p2319
  %.p2320 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__agg.2, i32 0, i32 1
  store i64 4, i64* %.p2320
  %.p2321 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__agg.2, i32 0, i32 2
  store i64* %.p2310, i64** %.p2321
  %.t3 = bitcast { i64, i64, i64* }* %__agg.2 to { i64, i64, i64* }*
  %.r2322 = load i8*, i8** %kind
  %.r2323 = load i8*, i8** %text
  %.t4 = call i64 @Ast__addl(%Ast* %.t0, i8* %.r2322, i8* %.r2323, %Span* %.t1, { i64, i64, i64* }* %.t3)
  ret i64 %.t4
}

define void @Ast__span_of(%Span* %__ret, %Ast* %self, i64 %id.arg) {
entry:
  %id = alloca i64
  store i64 %id.arg, i64* %id
  %__fld.0 = getelementptr inbounds %Ast, %Ast* %self, i32 0, i32 0
  %.r2324 = load i64, i64* %id
  %.p2325 = getelementptr inbounds { i64, i64, %Node* }, { i64, i64, %Node* }* %__fld.0, i32 0, i32 0
  %.r2326 = load i64, i64* %.p2325
  %.r2327 = icmp slt i64 %.r2324, 0
  %.r2328 = icmp sge i64 %.r2324, %.r2326
  %.r2329 = or i1 %.r2327, %.r2328
  br i1 %.r2329, label %idx.fail.2331, label %idx.ok.2330
idx.fail.2331:
  %.p2332 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p2332, i64 %.r2324, i64 %.r2326)
  call void @exit(i32 1)
  unreachable
idx.ok.2330:
  %.p2334 = getelementptr inbounds { i64, i64, %Node* }, { i64, i64, %Node* }* %__fld.0, i32 0, i32 2
  %.p2333 = load %Node*, %Node** %.p2334
  %.p2335 = getelementptr inbounds %Node, %Node* %.p2333, i64 %.r2324
  %__elem.1 = bitcast %Node* %.p2335 to %Node*
  %__fld.2 = getelementptr inbounds %Node, %Node* %__elem.1, i32 0, i32 2
  %.r2336 = load %Span, %Span* %__fld.2
  store %Span %.r2336, %Span* %__ret
  ret void
}

define i8* @Ast__kind_of(%Ast* %self, i64 %id.arg) {
entry:
  %id = alloca i64
  store i64 %id.arg, i64* %id
  %__fld.0 = getelementptr inbounds %Ast, %Ast* %self, i32 0, i32 0
  %.r2337 = load i64, i64* %id
  %.p2338 = getelementptr inbounds { i64, i64, %Node* }, { i64, i64, %Node* }* %__fld.0, i32 0, i32 0
  %.r2339 = load i64, i64* %.p2338
  %.r2340 = icmp slt i64 %.r2337, 0
  %.r2341 = icmp sge i64 %.r2337, %.r2339
  %.r2342 = or i1 %.r2340, %.r2341
  br i1 %.r2342, label %idx.fail.2344, label %idx.ok.2343
idx.fail.2344:
  %.p2345 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p2345, i64 %.r2337, i64 %.r2339)
  call void @exit(i32 1)
  unreachable
idx.ok.2343:
  %.p2347 = getelementptr inbounds { i64, i64, %Node* }, { i64, i64, %Node* }* %__fld.0, i32 0, i32 2
  %.p2346 = load %Node*, %Node** %.p2347
  %.p2348 = getelementptr inbounds %Node, %Node* %.p2346, i64 %.r2337
  %__elem.1 = bitcast %Node* %.p2348 to %Node*
  %.p2349 = getelementptr inbounds %Node, %Node* %__elem.1, i32 0, i32 0
  %.t2 = load i8*, i8** %.p2349
  ret i8* %.t2
}

define i8* @Ast__text_of(%Ast* %self, i64 %id.arg) {
entry:
  %id = alloca i64
  store i64 %id.arg, i64* %id
  %__fld.0 = getelementptr inbounds %Ast, %Ast* %self, i32 0, i32 0
  %.r2350 = load i64, i64* %id
  %.p2351 = getelementptr inbounds { i64, i64, %Node* }, { i64, i64, %Node* }* %__fld.0, i32 0, i32 0
  %.r2352 = load i64, i64* %.p2351
  %.r2353 = icmp slt i64 %.r2350, 0
  %.r2354 = icmp sge i64 %.r2350, %.r2352
  %.r2355 = or i1 %.r2353, %.r2354
  br i1 %.r2355, label %idx.fail.2357, label %idx.ok.2356
idx.fail.2357:
  %.p2358 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p2358, i64 %.r2350, i64 %.r2352)
  call void @exit(i32 1)
  unreachable
idx.ok.2356:
  %.p2360 = getelementptr inbounds { i64, i64, %Node* }, { i64, i64, %Node* }* %__fld.0, i32 0, i32 2
  %.p2359 = load %Node*, %Node** %.p2360
  %.p2361 = getelementptr inbounds %Node, %Node* %.p2359, i64 %.r2350
  %__elem.1 = bitcast %Node* %.p2361 to %Node*
  %.p2362 = getelementptr inbounds %Node, %Node* %__elem.1, i32 0, i32 1
  %.t2 = load i8*, i8** %.p2362
  ret i8* %.t2
}

define i64 @Ast__kid(%Ast* %self, i64 %id.arg, i64 %i.arg) {
entry:
  %id = alloca i64
  %i = alloca i64
  store i64 %id.arg, i64* %id
  store i64 %i.arg, i64* %i
  %__fld.0 = getelementptr inbounds %Ast, %Ast* %self, i32 0, i32 0
  %.r2363 = load i64, i64* %id
  %.p2364 = getelementptr inbounds { i64, i64, %Node* }, { i64, i64, %Node* }* %__fld.0, i32 0, i32 0
  %.r2365 = load i64, i64* %.p2364
  %.r2366 = icmp slt i64 %.r2363, 0
  %.r2367 = icmp sge i64 %.r2363, %.r2365
  %.r2368 = or i1 %.r2366, %.r2367
  br i1 %.r2368, label %idx.fail.2370, label %idx.ok.2369
idx.fail.2370:
  %.p2371 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p2371, i64 %.r2363, i64 %.r2365)
  call void @exit(i32 1)
  unreachable
idx.ok.2369:
  %.p2373 = getelementptr inbounds { i64, i64, %Node* }, { i64, i64, %Node* }* %__fld.0, i32 0, i32 2
  %.p2372 = load %Node*, %Node** %.p2373
  %.p2374 = getelementptr inbounds %Node, %Node* %.p2372, i64 %.r2363
  %__elem.1 = bitcast %Node* %.p2374 to %Node*
  %__fld.2 = getelementptr inbounds %Node, %Node* %__elem.1, i32 0, i32 3
  %.r2375 = load i64, i64* %i
  %.p2376 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.2, i32 0, i32 0
  %.r2377 = load i64, i64* %.p2376
  %.r2378 = icmp slt i64 %.r2375, 0
  %.r2379 = icmp sge i64 %.r2375, %.r2377
  %.r2380 = or i1 %.r2378, %.r2379
  br i1 %.r2380, label %idx.fail.2382, label %idx.ok.2381
idx.fail.2382:
  %.p2383 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p2383, i64 %.r2375, i64 %.r2377)
  call void @exit(i32 1)
  unreachable
idx.ok.2381:
  %.p2385 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.2, i32 0, i32 2
  %.p2384 = load i64*, i64** %.p2385
  %.p2386 = getelementptr inbounds i64, i64* %.p2384, i64 %.r2375
  %.t3 = load i64, i64* %.p2386
  ret i64 %.t3
}

define i64 @Ast__nkids(%Ast* %self, i64 %id.arg) {
entry:
  %id = alloca i64
  store i64 %id.arg, i64* %id
  %__fld.0 = getelementptr inbounds %Ast, %Ast* %self, i32 0, i32 0
  %.r2387 = load i64, i64* %id
  %.p2388 = getelementptr inbounds { i64, i64, %Node* }, { i64, i64, %Node* }* %__fld.0, i32 0, i32 0
  %.r2389 = load i64, i64* %.p2388
  %.r2390 = icmp slt i64 %.r2387, 0
  %.r2391 = icmp sge i64 %.r2387, %.r2389
  %.r2392 = or i1 %.r2390, %.r2391
  br i1 %.r2392, label %idx.fail.2394, label %idx.ok.2393
idx.fail.2394:
  %.p2395 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p2395, i64 %.r2387, i64 %.r2389)
  call void @exit(i32 1)
  unreachable
idx.ok.2393:
  %.p2397 = getelementptr inbounds { i64, i64, %Node* }, { i64, i64, %Node* }* %__fld.0, i32 0, i32 2
  %.p2396 = load %Node*, %Node** %.p2397
  %.p2398 = getelementptr inbounds %Node, %Node* %.p2396, i64 %.r2387
  %__elem.1 = bitcast %Node* %.p2398 to %Node*
  %__fld.2 = getelementptr inbounds %Node, %Node* %__elem.1, i32 0, i32 3
  %.p2399 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.2, i32 0, i32 0
  %.t3 = load i64, i64* %.p2399
  ret i64 %.t3
}

define i8* @dump_quote(i8* %s.arg) {
entry:
  %s = alloca i8*
  %out = alloca i8*
  %i = alloca i64
  %c = alloca i64
  store i8* %s.arg, i8** %s
  %.p2400 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.98, i64 0, i64 0
  store i8* %.p2400, i8** %out
  store i64 0, i64* %i
  br label %while_cond_0
while_cond_0:
  %.r2401 = load i8*, i8** %s
  %.t0 = call i64 @strlen(i8* %.r2401)
  %.r2402 = load i64, i64* %i
  %.t1 = icmp slt i64 %.r2402, %.t0
  br i1 %.t1, label %while_body_1, label %while_end_2
while_body_1:
  %.r2403 = load i8*, i8** %s
  %.r2404 = load i64, i64* %i
  %.p2405 = getelementptr inbounds i8, i8* %.r2403, i64 %.r2404
  %.r2406 = load i8, i8* %.p2405
  %.t2 = zext i8 %.r2406 to i64
  store i64 %.t2, i64* %c
  %.r2407 = load i64, i64* %c
  %.t3 = icmp eq i64 %.r2407, 34
  br i1 %.t3, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.r2408 = load i8*, i8** %out
  %.p2409 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.244, i64 0, i64 0
  %.r2410 = call i64 @strlen(i8* %.r2408)
  %.r2411 = call i64 @strlen(i8* %.p2409)
  %.r2412 = add i64 %.r2410, %.r2411
  %.r2413 = add i64 %.r2412, 1
  %.t4 = call i8* @malloc(i64 %.r2413)
  call i8* @memcpy(i8* %.t4, i8* %.r2408, i64 %.r2410)
  %.p2414 = getelementptr inbounds i8, i8* %.t4, i64 %.r2410
  call i8* @memcpy(i8* %.p2414, i8* %.p2409, i64 %.r2411)
  %.p2415 = getelementptr inbounds i8, i8* %.t4, i64 %.r2412
  store i8 0, i8* %.p2415
  store i8* %.t4, i8** %out
  br label %if_end_3
if_next_0_5:
  %.r2416 = load i64, i64* %c
  %.t5 = icmp eq i64 %.r2416, 92
  br i1 %.t5, label %if_then_1_6, label %if_next_1_7
if_then_1_6:
  %.r2417 = load i8*, i8** %out
  %.p2418 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.245, i64 0, i64 0
  %.r2419 = call i64 @strlen(i8* %.r2417)
  %.r2420 = call i64 @strlen(i8* %.p2418)
  %.r2421 = add i64 %.r2419, %.r2420
  %.r2422 = add i64 %.r2421, 1
  %.t6 = call i8* @malloc(i64 %.r2422)
  call i8* @memcpy(i8* %.t6, i8* %.r2417, i64 %.r2419)
  %.p2423 = getelementptr inbounds i8, i8* %.t6, i64 %.r2419
  call i8* @memcpy(i8* %.p2423, i8* %.p2418, i64 %.r2420)
  %.p2424 = getelementptr inbounds i8, i8* %.t6, i64 %.r2421
  store i8 0, i8* %.p2424
  store i8* %.t6, i8** %out
  br label %if_end_3
if_next_1_7:
  %.r2425 = load i64, i64* %c
  %.t7 = icmp eq i64 %.r2425, 10
  br i1 %.t7, label %if_then_2_8, label %if_next_2_9
if_then_2_8:
  %.r2426 = load i8*, i8** %out
  %.p2427 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.246, i64 0, i64 0
  %.r2428 = call i64 @strlen(i8* %.r2426)
  %.r2429 = call i64 @strlen(i8* %.p2427)
  %.r2430 = add i64 %.r2428, %.r2429
  %.r2431 = add i64 %.r2430, 1
  %.t8 = call i8* @malloc(i64 %.r2431)
  call i8* @memcpy(i8* %.t8, i8* %.r2426, i64 %.r2428)
  %.p2432 = getelementptr inbounds i8, i8* %.t8, i64 %.r2428
  call i8* @memcpy(i8* %.p2432, i8* %.p2427, i64 %.r2429)
  %.p2433 = getelementptr inbounds i8, i8* %.t8, i64 %.r2430
  store i8 0, i8* %.p2433
  store i8* %.t8, i8** %out
  br label %if_end_3
if_next_2_9:
  %.r2434 = load i64, i64* %c
  %.t9 = icmp eq i64 %.r2434, 9
  br i1 %.t9, label %if_then_3_10, label %if_next_3_11
if_then_3_10:
  %.r2435 = load i8*, i8** %out
  %.p2436 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.247, i64 0, i64 0
  %.r2437 = call i64 @strlen(i8* %.r2435)
  %.r2438 = call i64 @strlen(i8* %.p2436)
  %.r2439 = add i64 %.r2437, %.r2438
  %.r2440 = add i64 %.r2439, 1
  %.t10 = call i8* @malloc(i64 %.r2440)
  call i8* @memcpy(i8* %.t10, i8* %.r2435, i64 %.r2437)
  %.p2441 = getelementptr inbounds i8, i8* %.t10, i64 %.r2437
  call i8* @memcpy(i8* %.p2441, i8* %.p2436, i64 %.r2438)
  %.p2442 = getelementptr inbounds i8, i8* %.t10, i64 %.r2439
  store i8 0, i8* %.p2442
  store i8* %.t10, i8** %out
  br label %if_end_3
if_next_3_11:
  %.r2443 = load i64, i64* %c
  %.t11 = icmp eq i64 %.r2443, 13
  br i1 %.t11, label %if_then_4_12, label %if_next_4_13
if_then_4_12:
  %.r2444 = load i8*, i8** %out
  %.p2445 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.248, i64 0, i64 0
  %.r2446 = call i64 @strlen(i8* %.r2444)
  %.r2447 = call i64 @strlen(i8* %.p2445)
  %.r2448 = add i64 %.r2446, %.r2447
  %.r2449 = add i64 %.r2448, 1
  %.t12 = call i8* @malloc(i64 %.r2449)
  call i8* @memcpy(i8* %.t12, i8* %.r2444, i64 %.r2446)
  %.p2450 = getelementptr inbounds i8, i8* %.t12, i64 %.r2446
  call i8* @memcpy(i8* %.p2450, i8* %.p2445, i64 %.r2447)
  %.p2451 = getelementptr inbounds i8, i8* %.t12, i64 %.r2448
  store i8 0, i8* %.p2451
  store i8* %.t12, i8** %out
  br label %if_end_3
if_next_4_13:
  %.r2452 = load i64, i64* %i
  %.t13 = add i64 %.r2452, 1
  %.r2453 = load i8*, i8** %s
  %.r2454 = load i64, i64* %i
  %.r2455 = sub i64 %.t13, %.r2454
  %.r2456 = add i64 %.r2455, 1
  %.p2457 = call i8* @malloc(i64 %.r2456)
  %.p2458 = getelementptr inbounds i8, i8* %.r2453, i64 %.r2454
  call i8* @memcpy(i8* %.p2457, i8* %.p2458, i64 %.r2455)
  %.p2459 = getelementptr inbounds i8, i8* %.p2457, i64 %.r2455
  store i8 0, i8* %.p2459
  %.t14 = bitcast i8* %.p2457 to i8*
  %.r2460 = load i8*, i8** %out
  %.r2461 = call i64 @strlen(i8* %.r2460)
  %.r2462 = call i64 @strlen(i8* %.t14)
  %.r2463 = add i64 %.r2461, %.r2462
  %.r2464 = add i64 %.r2463, 1
  %.t15 = call i8* @malloc(i64 %.r2464)
  call i8* @memcpy(i8* %.t15, i8* %.r2460, i64 %.r2461)
  %.p2465 = getelementptr inbounds i8, i8* %.t15, i64 %.r2461
  call i8* @memcpy(i8* %.p2465, i8* %.t14, i64 %.r2462)
  %.p2466 = getelementptr inbounds i8, i8* %.t15, i64 %.r2463
  store i8 0, i8* %.p2466
  store i8* %.t15, i8** %out
  br label %if_end_3
if_end_3:
  %.r2467 = load i64, i64* %i
  %.t16 = add i64 %.r2467, 1
  store i64 %.t16, i64* %i
  br label %while_cond_0
while_end_2:
  %.r2468 = load i8*, i8** %out
  %.p2469 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.98, i64 0, i64 0
  %.r2470 = call i64 @strlen(i8* %.r2468)
  %.r2471 = call i64 @strlen(i8* %.p2469)
  %.r2472 = add i64 %.r2470, %.r2471
  %.r2473 = add i64 %.r2472, 1
  %.t17 = call i8* @malloc(i64 %.r2473)
  call i8* @memcpy(i8* %.t17, i8* %.r2468, i64 %.r2470)
  %.p2474 = getelementptr inbounds i8, i8* %.t17, i64 %.r2470
  call i8* @memcpy(i8* %.p2474, i8* %.p2469, i64 %.r2471)
  %.p2475 = getelementptr inbounds i8, i8* %.t17, i64 %.r2472
  store i8 0, i8* %.p2475
  ret i8* %.t17
}

define i8* @norm_int(i8* %s.arg) {
entry:
  %s = alloca i8*
  %i = alloca i64
  %__sc.0 = alloca i1
  store i8* %s.arg, i8** %s
  store i64 0, i64* %i
  br label %while_cond_0
while_cond_0:
  %.r2476 = load i8*, i8** %s
  %.t1 = call i64 @strlen(i8* %.r2476)
  %.t2 = sub i64 %.t1, 1
  %.r2477 = load i64, i64* %i
  %.t3 = icmp slt i64 %.r2477, %.t2
  br i1 %.t3, label %sc_rhs_3, label %sc_short_4
sc_rhs_3:
  %.r2478 = load i8*, i8** %s
  %.r2479 = load i64, i64* %i
  %.p2480 = getelementptr inbounds i8, i8* %.r2478, i64 %.r2479
  %.r2481 = load i8, i8* %.p2480
  %.t4 = zext i8 %.r2481 to i64
  %.t5 = icmp eq i64 %.t4, 48
  store i1 %.t5, i1* %__sc.0
  br label %sc_end_5
sc_short_4:
  store i1 false, i1* %__sc.0
  br label %sc_end_5
sc_end_5:
  %.r2482 = load i1, i1* %__sc.0
  br i1 %.r2482, label %while_body_1, label %while_end_2
while_body_1:
  %.r2483 = load i64, i64* %i
  %.t6 = add i64 %.r2483, 1
  store i64 %.t6, i64* %i
  br label %while_cond_0
while_end_2:
  %.r2484 = load i8*, i8** %s
  %.t7 = call i64 @strlen(i8* %.r2484)
  %.r2485 = load i8*, i8** %s
  %.r2486 = load i64, i64* %i
  %.r2487 = sub i64 %.t7, %.r2486
  %.r2488 = add i64 %.r2487, 1
  %.p2489 = call i8* @malloc(i64 %.r2488)
  %.p2490 = getelementptr inbounds i8, i8* %.r2485, i64 %.r2486
  call i8* @memcpy(i8* %.p2489, i8* %.p2490, i64 %.r2487)
  %.p2491 = getelementptr inbounds i8, i8* %.p2489, i64 %.r2487
  store i8 0, i8* %.p2491
  %.t8 = bitcast i8* %.p2489 to i8*
  ret i8* %.t8
}

define i8* @norm_float(i8* %s.arg) {
entry:
  %s = alloca i8*
  %dot = alloca i64
  %ip = alloca i8*
  %frac = alloca i8*
  %end = alloca i64
  %__sc.9 = alloca i1
  store i8* %s.arg, i8** %s
  %.r2492 = load i8*, i8** %s
  %.p2493 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.249, i64 0, i64 0
  %.t0 = call i64 @find(i8* %.r2492, i8* %.p2493)
  store i64 %.t0, i64* %dot
  %.r2494 = load i64, i64* %dot
  %.t1 = icmp slt i64 %.r2494, 0
  br i1 %.t1, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t2 = load i8*, i8** %s
  ret i8* %.t2
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.r2495 = load i8*, i8** %s
  %.r2496 = load i64, i64* %dot
  %.r2497 = sub i64 %.r2496, 0
  %.r2498 = add i64 %.r2497, 1
  %.p2499 = call i8* @malloc(i64 %.r2498)
  %.p2500 = getelementptr inbounds i8, i8* %.r2495, i64 0
  call i8* @memcpy(i8* %.p2499, i8* %.p2500, i64 %.r2497)
  %.p2501 = getelementptr inbounds i8, i8* %.p2499, i64 %.r2497
  store i8 0, i8* %.p2501
  %.t3 = bitcast i8* %.p2499 to i8*
  %.t4 = call i8* @norm_int(i8* %.t3)
  store i8* %.t4, i8** %ip
  %.r2502 = load i64, i64* %dot
  %.t5 = add i64 %.r2502, 1
  %.r2503 = load i8*, i8** %s
  %.t6 = call i64 @strlen(i8* %.r2503)
  %.r2504 = load i8*, i8** %s
  %.r2505 = sub i64 %.t6, %.t5
  %.r2506 = add i64 %.r2505, 1
  %.p2507 = call i8* @malloc(i64 %.r2506)
  %.p2508 = getelementptr inbounds i8, i8* %.r2504, i64 %.t5
  call i8* @memcpy(i8* %.p2507, i8* %.p2508, i64 %.r2505)
  %.p2509 = getelementptr inbounds i8, i8* %.p2507, i64 %.r2505
  store i8 0, i8* %.p2509
  %.t7 = bitcast i8* %.p2507 to i8*
  store i8* %.t7, i8** %frac
  %.r2510 = load i8*, i8** %frac
  %.t8 = call i64 @strlen(i8* %.r2510)
  store i64 %.t8, i64* %end
  br label %while_cond_3
while_cond_3:
  %.r2511 = load i64, i64* %end
  %.t10 = icmp sgt i64 %.r2511, 1
  br i1 %.t10, label %sc_rhs_6, label %sc_short_7
sc_rhs_6:
  %.r2512 = load i64, i64* %end
  %.t11 = sub i64 %.r2512, 1
  %.r2513 = load i8*, i8** %frac
  %.p2514 = getelementptr inbounds i8, i8* %.r2513, i64 %.t11
  %.r2515 = load i8, i8* %.p2514
  %.t12 = zext i8 %.r2515 to i64
  %.t13 = icmp eq i64 %.t12, 48
  store i1 %.t13, i1* %__sc.9
  br label %sc_end_8
sc_short_7:
  store i1 false, i1* %__sc.9
  br label %sc_end_8
sc_end_8:
  %.r2516 = load i1, i1* %__sc.9
  br i1 %.r2516, label %while_body_4, label %while_end_5
while_body_4:
  %.r2517 = load i64, i64* %end
  %.t14 = sub i64 %.r2517, 1
  store i64 %.t14, i64* %end
  br label %while_cond_3
while_end_5:
  %.r2518 = load i8*, i8** %ip
  %.p2519 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.249, i64 0, i64 0
  %.r2520 = call i64 @strlen(i8* %.r2518)
  %.r2521 = call i64 @strlen(i8* %.p2519)
  %.r2522 = add i64 %.r2520, %.r2521
  %.r2523 = add i64 %.r2522, 1
  %.t15 = call i8* @malloc(i64 %.r2523)
  call i8* @memcpy(i8* %.t15, i8* %.r2518, i64 %.r2520)
  %.p2524 = getelementptr inbounds i8, i8* %.t15, i64 %.r2520
  call i8* @memcpy(i8* %.p2524, i8* %.p2519, i64 %.r2521)
  %.p2525 = getelementptr inbounds i8, i8* %.t15, i64 %.r2522
  store i8 0, i8* %.p2525
  %.r2526 = load i8*, i8** %frac
  %.r2527 = load i64, i64* %end
  %.r2528 = sub i64 %.r2527, 0
  %.r2529 = add i64 %.r2528, 1
  %.p2530 = call i8* @malloc(i64 %.r2529)
  %.p2531 = getelementptr inbounds i8, i8* %.r2526, i64 0
  call i8* @memcpy(i8* %.p2530, i8* %.p2531, i64 %.r2528)
  %.p2532 = getelementptr inbounds i8, i8* %.p2530, i64 %.r2528
  store i8 0, i8* %.p2532
  %.t16 = bitcast i8* %.p2530 to i8*
  %.r2533 = call i64 @strlen(i8* %.t15)
  %.r2534 = call i64 @strlen(i8* %.t16)
  %.r2535 = add i64 %.r2533, %.r2534
  %.r2536 = add i64 %.r2535, 1
  %.t17 = call i8* @malloc(i64 %.r2536)
  call i8* @memcpy(i8* %.t17, i8* %.t15, i64 %.r2533)
  %.p2537 = getelementptr inbounds i8, i8* %.t17, i64 %.r2533
  call i8* @memcpy(i8* %.p2537, i8* %.t16, i64 %.r2534)
  %.p2538 = getelementptr inbounds i8, i8* %.t17, i64 %.r2535
  store i8 0, i8* %.p2538
  ret i8* %.t17
}

define i8* @dump_node(%Ast* %ast, i64 %id.arg, i64 %depth.arg) {
entry:
  %id = alloca i64
  %depth = alloca i64
  %n = alloca %Node
  %sp = alloca %Span
  %text = alloca i8*
  %shown = alloca i8*
  %k0 = alloca i8*
  %__sc.27 = alloca i1
  %__sc.28 = alloca i1
  %__sc.29 = alloca i1
  %__sc.30 = alloca i1
  %__sc.31 = alloca i1
  %__sc.32 = alloca i1
  %out = alloca i8*
  %__for.idx.48 = alloca i64
  %__for.len.49 = alloca i64
  %k = alloca i64
  store i64 %id.arg, i64* %id
  store i64 %depth.arg, i64* %depth
  %.r2539 = load i64, i64* %id
  %.t0 = icmp slt i64 %.r2539, 0
  br i1 %.t0, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.p2540 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.250, i64 0, i64 0
  ret i8* %.p2540
if_next_0_2:
  br label %if_end_0
if_end_0:
  %__fld.1 = getelementptr inbounds %Ast, %Ast* %ast, i32 0, i32 0
  %.r2541 = load i64, i64* %id
  %.p2542 = getelementptr inbounds { i64, i64, %Node* }, { i64, i64, %Node* }* %__fld.1, i32 0, i32 0
  %.r2543 = load i64, i64* %.p2542
  %.r2544 = icmp slt i64 %.r2541, 0
  %.r2545 = icmp sge i64 %.r2541, %.r2543
  %.r2546 = or i1 %.r2544, %.r2545
  br i1 %.r2546, label %idx.fail.2548, label %idx.ok.2547
idx.fail.2548:
  %.p2549 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p2549, i64 %.r2541, i64 %.r2543)
  call void @exit(i32 1)
  unreachable
idx.ok.2547:
  %.p2551 = getelementptr inbounds { i64, i64, %Node* }, { i64, i64, %Node* }* %__fld.1, i32 0, i32 2
  %.p2550 = load %Node*, %Node** %.p2551
  %.p2552 = getelementptr inbounds %Node, %Node* %.p2550, i64 %.r2541
  %.t2 = load %Node, %Node* %.p2552
  store %Node %.t2, %Node* %n
  %__fld.3 = getelementptr inbounds %Node, %Node* %n, i32 0, i32 2
  %.r2553 = load %Span, %Span* %__fld.3
  store %Span %.r2553, %Span* %sp
  %.p2554 = getelementptr inbounds %Node, %Node* %n, i32 0, i32 1
  %.t4 = load i8*, i8** %.p2554
  store i8* %.t4, i8** %text
  %.p2555 = getelementptr inbounds %Node, %Node* %n, i32 0, i32 0
  %.t5 = load i8*, i8** %.p2555
  %.p2556 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.251, i64 0, i64 0
  %.r2557 = call i32 @strcmp(i8* %.t5, i8* %.p2556)
  %.t6 = icmp eq i32 %.r2557, 0
  br i1 %.t6, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.r2558 = load i8*, i8** %text
  %.t7 = call i8* @norm_int(i8* %.r2558)
  store i8* %.t7, i8** %text
  br label %if_end_3
if_next_0_5:
  %.p2559 = getelementptr inbounds %Node, %Node* %n, i32 0, i32 0
  %.t8 = load i8*, i8** %.p2559
  %.p2560 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.252, i64 0, i64 0
  %.r2561 = call i32 @strcmp(i8* %.t8, i8* %.p2560)
  %.t9 = icmp eq i32 %.r2561, 0
  br i1 %.t9, label %if_then_1_6, label %if_next_1_7
if_then_1_6:
  %.r2562 = load i8*, i8** %text
  %.t10 = call i8* @norm_float(i8* %.r2562)
  store i8* %.t10, i8** %text
  br label %if_end_3
if_next_1_7:
  br label %if_end_3
if_end_3:
  %.p2563 = getelementptr inbounds %Span, %Span* %sp, i32 0, i32 2
  %.t11 = load i64, i64* %.p2563
  %.p2564 = call i8* @malloc(i64 32)
  %.p2565 = getelementptr inbounds [5 x i8], [5 x i8]* @.fmt.int.raw, i64 0, i64 0
  call i32 (i8*, i64, i8*, ...) @snprintf(i8* %.p2564, i64 32, i8* %.p2565, i64 %.t11)
  %.t12 = bitcast i8* %.p2564 to i8*
  %.p2566 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.253, i64 0, i64 0
  %.r2567 = call i64 @strlen(i8* %.p2566)
  %.r2568 = call i64 @strlen(i8* %.t12)
  %.r2569 = add i64 %.r2567, %.r2568
  %.r2570 = add i64 %.r2569, 1
  %.t13 = call i8* @malloc(i64 %.r2570)
  call i8* @memcpy(i8* %.t13, i8* %.p2566, i64 %.r2567)
  %.p2571 = getelementptr inbounds i8, i8* %.t13, i64 %.r2567
  call i8* @memcpy(i8* %.p2571, i8* %.t12, i64 %.r2568)
  %.p2572 = getelementptr inbounds i8, i8* %.t13, i64 %.r2569
  store i8 0, i8* %.p2572
  %.p2573 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.8, i64 0, i64 0
  %.r2574 = call i64 @strlen(i8* %.t13)
  %.r2575 = call i64 @strlen(i8* %.p2573)
  %.r2576 = add i64 %.r2574, %.r2575
  %.r2577 = add i64 %.r2576, 1
  %.t14 = call i8* @malloc(i64 %.r2577)
  call i8* @memcpy(i8* %.t14, i8* %.t13, i64 %.r2574)
  %.p2578 = getelementptr inbounds i8, i8* %.t14, i64 %.r2574
  call i8* @memcpy(i8* %.p2578, i8* %.p2573, i64 %.r2575)
  %.p2579 = getelementptr inbounds i8, i8* %.t14, i64 %.r2576
  store i8 0, i8* %.p2579
  %.p2580 = getelementptr inbounds %Span, %Span* %sp, i32 0, i32 3
  %.t15 = load i64, i64* %.p2580
  %.p2581 = call i8* @malloc(i64 32)
  %.p2582 = getelementptr inbounds [5 x i8], [5 x i8]* @.fmt.int.raw, i64 0, i64 0
  call i32 (i8*, i64, i8*, ...) @snprintf(i8* %.p2581, i64 32, i8* %.p2582, i64 %.t15)
  %.t16 = bitcast i8* %.p2581 to i8*
  %.r2583 = call i64 @strlen(i8* %.t14)
  %.r2584 = call i64 @strlen(i8* %.t16)
  %.r2585 = add i64 %.r2583, %.r2584
  %.r2586 = add i64 %.r2585, 1
  %.t17 = call i8* @malloc(i64 %.r2586)
  call i8* @memcpy(i8* %.t17, i8* %.t14, i64 %.r2583)
  %.p2587 = getelementptr inbounds i8, i8* %.t17, i64 %.r2583
  call i8* @memcpy(i8* %.p2587, i8* %.t16, i64 %.r2584)
  %.p2588 = getelementptr inbounds i8, i8* %.t17, i64 %.r2585
  store i8 0, i8* %.p2588
  %.p2589 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.8, i64 0, i64 0
  %.r2590 = call i64 @strlen(i8* %.t17)
  %.r2591 = call i64 @strlen(i8* %.p2589)
  %.r2592 = add i64 %.r2590, %.r2591
  %.r2593 = add i64 %.r2592, 1
  %.t18 = call i8* @malloc(i64 %.r2593)
  call i8* @memcpy(i8* %.t18, i8* %.t17, i64 %.r2590)
  %.p2594 = getelementptr inbounds i8, i8* %.t18, i64 %.r2590
  call i8* @memcpy(i8* %.p2594, i8* %.p2589, i64 %.r2591)
  %.p2595 = getelementptr inbounds i8, i8* %.t18, i64 %.r2592
  store i8 0, i8* %.p2595
  %.p2596 = getelementptr inbounds %Span, %Span* %sp, i32 0, i32 0
  %.t19 = load i64, i64* %.p2596
  %.p2597 = call i8* @malloc(i64 32)
  %.p2598 = getelementptr inbounds [5 x i8], [5 x i8]* @.fmt.int.raw, i64 0, i64 0
  call i32 (i8*, i64, i8*, ...) @snprintf(i8* %.p2597, i64 32, i8* %.p2598, i64 %.t19)
  %.t20 = bitcast i8* %.p2597 to i8*
  %.r2599 = call i64 @strlen(i8* %.t18)
  %.r2600 = call i64 @strlen(i8* %.t20)
  %.r2601 = add i64 %.r2599, %.r2600
  %.r2602 = add i64 %.r2601, 1
  %.t21 = call i8* @malloc(i64 %.r2602)
  call i8* @memcpy(i8* %.t21, i8* %.t18, i64 %.r2599)
  %.p2603 = getelementptr inbounds i8, i8* %.t21, i64 %.r2599
  call i8* @memcpy(i8* %.p2603, i8* %.t20, i64 %.r2600)
  %.p2604 = getelementptr inbounds i8, i8* %.t21, i64 %.r2601
  store i8 0, i8* %.p2604
  %.p2605 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.254, i64 0, i64 0
  %.r2606 = call i64 @strlen(i8* %.t21)
  %.r2607 = call i64 @strlen(i8* %.p2605)
  %.r2608 = add i64 %.r2606, %.r2607
  %.r2609 = add i64 %.r2608, 1
  %.t22 = call i8* @malloc(i64 %.r2609)
  call i8* @memcpy(i8* %.t22, i8* %.t21, i64 %.r2606)
  %.p2610 = getelementptr inbounds i8, i8* %.t22, i64 %.r2606
  call i8* @memcpy(i8* %.p2610, i8* %.p2605, i64 %.r2607)
  %.p2611 = getelementptr inbounds i8, i8* %.t22, i64 %.r2608
  store i8 0, i8* %.p2611
  %.p2612 = getelementptr inbounds %Span, %Span* %sp, i32 0, i32 1
  %.t23 = load i64, i64* %.p2612
  %.p2613 = call i8* @malloc(i64 32)
  %.p2614 = getelementptr inbounds [5 x i8], [5 x i8]* @.fmt.int.raw, i64 0, i64 0
  call i32 (i8*, i64, i8*, ...) @snprintf(i8* %.p2613, i64 32, i8* %.p2614, i64 %.t23)
  %.t24 = bitcast i8* %.p2613 to i8*
  %.r2615 = call i64 @strlen(i8* %.t22)
  %.r2616 = call i64 @strlen(i8* %.t24)
  %.r2617 = add i64 %.r2615, %.r2616
  %.r2618 = add i64 %.r2617, 1
  %.t25 = call i8* @malloc(i64 %.r2618)
  call i8* @memcpy(i8* %.t25, i8* %.t22, i64 %.r2615)
  %.p2619 = getelementptr inbounds i8, i8* %.t25, i64 %.r2615
  call i8* @memcpy(i8* %.p2619, i8* %.t24, i64 %.r2616)
  %.p2620 = getelementptr inbounds i8, i8* %.t25, i64 %.r2617
  store i8 0, i8* %.p2620
  store i8* %.t25, i8** %shown
  %.p2621 = getelementptr inbounds %Node, %Node* %n, i32 0, i32 0
  %.t26 = load i8*, i8** %.p2621
  store i8* %.t26, i8** %k0
  %.r2622 = load i8*, i8** %k0
  %.p2623 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.255, i64 0, i64 0
  %.r2624 = call i32 @strcmp(i8* %.r2622, i8* %.p2623)
  %.t33 = icmp eq i32 %.r2624, 0
  br i1 %.t33, label %sc_short_12, label %sc_rhs_11
sc_rhs_11:
  %.r2625 = load i8*, i8** %k0
  %.p2626 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.256, i64 0, i64 0
  %.r2627 = call i32 @strcmp(i8* %.r2625, i8* %.p2626)
  %.t34 = icmp eq i32 %.r2627, 0
  store i1 %.t34, i1* %__sc.32
  br label %sc_end_13
sc_short_12:
  store i1 true, i1* %__sc.32
  br label %sc_end_13
sc_end_13:
  %.r2628 = load i1, i1* %__sc.32
  br i1 %.r2628, label %sc_short_15, label %sc_rhs_14
sc_rhs_14:
  %.r2629 = load i8*, i8** %k0
  %.p2630 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.257, i64 0, i64 0
  %.r2631 = call i32 @strcmp(i8* %.r2629, i8* %.p2630)
  %.t35 = icmp eq i32 %.r2631, 0
  store i1 %.t35, i1* %__sc.31
  br label %sc_end_16
sc_short_15:
  store i1 true, i1* %__sc.31
  br label %sc_end_16
sc_end_16:
  %.r2632 = load i1, i1* %__sc.31
  br i1 %.r2632, label %sc_short_18, label %sc_rhs_17
sc_rhs_17:
  %.r2633 = load i8*, i8** %k0
  %.p2634 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.258, i64 0, i64 0
  %.r2635 = call i32 @strcmp(i8* %.r2633, i8* %.p2634)
  %.t36 = icmp eq i32 %.r2635, 0
  store i1 %.t36, i1* %__sc.30
  br label %sc_end_19
sc_short_18:
  store i1 true, i1* %__sc.30
  br label %sc_end_19
sc_end_19:
  %.r2636 = load i1, i1* %__sc.30
  br i1 %.r2636, label %sc_short_21, label %sc_rhs_20
sc_rhs_20:
  %.r2637 = load i8*, i8** %k0
  %.p2638 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.259, i64 0, i64 0
  %.r2639 = call i32 @strcmp(i8* %.r2637, i8* %.p2638)
  %.t37 = icmp eq i32 %.r2639, 0
  store i1 %.t37, i1* %__sc.29
  br label %sc_end_22
sc_short_21:
  store i1 true, i1* %__sc.29
  br label %sc_end_22
sc_end_22:
  %.r2640 = load i1, i1* %__sc.29
  br i1 %.r2640, label %sc_short_24, label %sc_rhs_23
sc_rhs_23:
  %.r2641 = load i8*, i8** %k0
  %.p2642 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.54, i64 0, i64 0
  %.r2643 = call i32 @strcmp(i8* %.r2641, i8* %.p2642)
  %.t38 = icmp eq i32 %.r2643, 0
  store i1 %.t38, i1* %__sc.28
  br label %sc_end_25
sc_short_24:
  store i1 true, i1* %__sc.28
  br label %sc_end_25
sc_end_25:
  %.r2644 = load i1, i1* %__sc.28
  br i1 %.r2644, label %sc_short_27, label %sc_rhs_26
sc_rhs_26:
  %.r2645 = load i8*, i8** %k0
  %.p2646 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.260, i64 0, i64 0
  %.r2647 = call i32 @strcmp(i8* %.r2645, i8* %.p2646)
  %.t39 = icmp eq i32 %.r2647, 0
  store i1 %.t39, i1* %__sc.27
  br label %sc_end_28
sc_short_27:
  store i1 true, i1* %__sc.27
  br label %sc_end_28
sc_end_28:
  %.r2648 = load i1, i1* %__sc.27
  br i1 %.r2648, label %if_then_0_9, label %if_next_0_10
if_then_0_9:
  %.p2649 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.261, i64 0, i64 0
  store i8* %.p2649, i8** %shown
  br label %if_end_8
if_next_0_10:
  br label %if_end_8
if_end_8:
  %.p2650 = getelementptr inbounds %Node, %Node* %n, i32 0, i32 0
  %.t40 = load i8*, i8** %.p2650
  %.p2651 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.262, i64 0, i64 0
  %.r2652 = call i64 @strlen(i8* %.p2651)
  %.r2653 = call i64 @strlen(i8* %.t40)
  %.r2654 = add i64 %.r2652, %.r2653
  %.r2655 = add i64 %.r2654, 1
  %.t41 = call i8* @malloc(i64 %.r2655)
  call i8* @memcpy(i8* %.t41, i8* %.p2651, i64 %.r2652)
  %.p2656 = getelementptr inbounds i8, i8* %.t41, i64 %.r2652
  call i8* @memcpy(i8* %.p2656, i8* %.t40, i64 %.r2653)
  %.p2657 = getelementptr inbounds i8, i8* %.t41, i64 %.r2654
  store i8 0, i8* %.p2657
  %.p2658 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.6, i64 0, i64 0
  %.r2659 = call i64 @strlen(i8* %.t41)
  %.r2660 = call i64 @strlen(i8* %.p2658)
  %.r2661 = add i64 %.r2659, %.r2660
  %.r2662 = add i64 %.r2661, 1
  %.t42 = call i8* @malloc(i64 %.r2662)
  call i8* @memcpy(i8* %.t42, i8* %.t41, i64 %.r2659)
  %.p2663 = getelementptr inbounds i8, i8* %.t42, i64 %.r2659
  call i8* @memcpy(i8* %.p2663, i8* %.p2658, i64 %.r2660)
  %.p2664 = getelementptr inbounds i8, i8* %.t42, i64 %.r2661
  store i8 0, i8* %.p2664
  %.r2665 = load i8*, i8** %text
  %.t43 = call i8* @dump_quote(i8* %.r2665)
  %.r2666 = call i64 @strlen(i8* %.t42)
  %.r2667 = call i64 @strlen(i8* %.t43)
  %.r2668 = add i64 %.r2666, %.r2667
  %.r2669 = add i64 %.r2668, 1
  %.t44 = call i8* @malloc(i64 %.r2669)
  call i8* @memcpy(i8* %.t44, i8* %.t42, i64 %.r2666)
  %.p2670 = getelementptr inbounds i8, i8* %.t44, i64 %.r2666
  call i8* @memcpy(i8* %.p2670, i8* %.t43, i64 %.r2667)
  %.p2671 = getelementptr inbounds i8, i8* %.t44, i64 %.r2668
  store i8 0, i8* %.p2671
  %.p2672 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.6, i64 0, i64 0
  %.r2673 = call i64 @strlen(i8* %.t44)
  %.r2674 = call i64 @strlen(i8* %.p2672)
  %.r2675 = add i64 %.r2673, %.r2674
  %.r2676 = add i64 %.r2675, 1
  %.t45 = call i8* @malloc(i64 %.r2676)
  call i8* @memcpy(i8* %.t45, i8* %.t44, i64 %.r2673)
  %.p2677 = getelementptr inbounds i8, i8* %.t45, i64 %.r2673
  call i8* @memcpy(i8* %.p2677, i8* %.p2672, i64 %.r2674)
  %.p2678 = getelementptr inbounds i8, i8* %.t45, i64 %.r2675
  store i8 0, i8* %.p2678
  %.r2679 = load i8*, i8** %shown
  %.r2680 = call i64 @strlen(i8* %.t45)
  %.r2681 = call i64 @strlen(i8* %.r2679)
  %.r2682 = add i64 %.r2680, %.r2681
  %.r2683 = add i64 %.r2682, 1
  %.t46 = call i8* @malloc(i64 %.r2683)
  call i8* @memcpy(i8* %.t46, i8* %.t45, i64 %.r2680)
  %.p2684 = getelementptr inbounds i8, i8* %.t46, i64 %.r2680
  call i8* @memcpy(i8* %.p2684, i8* %.r2679, i64 %.r2681)
  %.p2685 = getelementptr inbounds i8, i8* %.t46, i64 %.r2682
  store i8 0, i8* %.p2685
  store i8* %.t46, i8** %out
  %__fld.47 = getelementptr inbounds %Node, %Node* %n, i32 0, i32 3
  store i64 0, i64* %__for.idx.48
  %.p2686 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.47, i32 0, i32 0
  %.t50 = load i64, i64* %.p2686
  store i64 %.t50, i64* %__for.len.49
  br label %foreach_cond_29
foreach_cond_29:
  %.r2687 = load i64, i64* %__for.idx.48
  %.r2688 = load i64, i64* %__for.len.49
  %.t51 = icmp slt i64 %.r2687, %.r2688
  br i1 %.t51, label %foreach_body_30, label %foreach_end_32
foreach_body_30:
  %.r2689 = load i64, i64* %__for.idx.48
  %.p2690 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.47, i32 0, i32 0
  %.r2691 = load i64, i64* %.p2690
  %.r2692 = icmp slt i64 %.r2689, 0
  %.r2693 = icmp sge i64 %.r2689, %.r2691
  %.r2694 = or i1 %.r2692, %.r2693
  br i1 %.r2694, label %idx.fail.2696, label %idx.ok.2695
idx.fail.2696:
  %.p2697 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p2697, i64 %.r2689, i64 %.r2691)
  call void @exit(i32 1)
  unreachable
idx.ok.2695:
  %.p2699 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.47, i32 0, i32 2
  %.p2698 = load i64*, i64** %.p2699
  %.p2700 = getelementptr inbounds i64, i64* %.p2698, i64 %.r2689
  %.t52 = load i64, i64* %.p2700
  store i64 %.t52, i64* %k
  %.r2701 = load i8*, i8** %out
  %.p2702 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.6, i64 0, i64 0
  %.r2703 = call i64 @strlen(i8* %.r2701)
  %.r2704 = call i64 @strlen(i8* %.p2702)
  %.r2705 = add i64 %.r2703, %.r2704
  %.r2706 = add i64 %.r2705, 1
  %.t53 = call i8* @malloc(i64 %.r2706)
  call i8* @memcpy(i8* %.t53, i8* %.r2701, i64 %.r2703)
  %.p2707 = getelementptr inbounds i8, i8* %.t53, i64 %.r2703
  call i8* @memcpy(i8* %.p2707, i8* %.p2702, i64 %.r2704)
  %.p2708 = getelementptr inbounds i8, i8* %.t53, i64 %.r2705
  store i8 0, i8* %.p2708
  %.t54 = bitcast %Ast* %ast to %Ast*
  %.r2709 = load i64, i64* %depth
  %.t55 = add i64 %.r2709, 1
  %.r2710 = load i64, i64* %k
  %.t56 = call i8* @dump_node(%Ast* %.t54, i64 %.r2710, i64 %.t55)
  %.r2711 = call i64 @strlen(i8* %.t53)
  %.r2712 = call i64 @strlen(i8* %.t56)
  %.r2713 = add i64 %.r2711, %.r2712
  %.r2714 = add i64 %.r2713, 1
  %.t57 = call i8* @malloc(i64 %.r2714)
  call i8* @memcpy(i8* %.t57, i8* %.t53, i64 %.r2711)
  %.p2715 = getelementptr inbounds i8, i8* %.t57, i64 %.r2711
  call i8* @memcpy(i8* %.p2715, i8* %.t56, i64 %.r2712)
  %.p2716 = getelementptr inbounds i8, i8* %.t57, i64 %.r2713
  store i8 0, i8* %.p2716
  store i8* %.t57, i8** %out
  br label %foreach_step_31
foreach_step_31:
  %.r2717 = load i64, i64* %__for.idx.48
  %.t58 = add i64 %.r2717, 1
  store i64 %.t58, i64* %__for.idx.48
  br label %foreach_cond_29
foreach_end_32:
  %.r2718 = load i8*, i8** %out
  %.p2719 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.263, i64 0, i64 0
  %.r2720 = call i64 @strlen(i8* %.r2718)
  %.r2721 = call i64 @strlen(i8* %.p2719)
  %.r2722 = add i64 %.r2720, %.r2721
  %.r2723 = add i64 %.r2722, 1
  %.t59 = call i8* @malloc(i64 %.r2723)
  call i8* @memcpy(i8* %.t59, i8* %.r2718, i64 %.r2720)
  %.p2724 = getelementptr inbounds i8, i8* %.t59, i64 %.r2720
  call i8* @memcpy(i8* %.p2724, i8* %.p2719, i64 %.r2721)
  %.p2725 = getelementptr inbounds i8, i8* %.t59, i64 %.r2722
  store i8 0, i8* %.p2725
  ret i8* %.t59
}

define void @Parser__init(%Parser* %self, { i64, i64, %Token* }* %toks) {
entry:
  %.r2726 = load { i64, i64, %Token* }, { i64, i64, %Token* }* %toks
  %.p2727 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 0
  store { i64, i64, %Token* } %.r2726, { i64, i64, %Token* }* %.p2727
  %.p2728 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 1
  store i64 0, i64* %.p2728
  %.p2729 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p2730 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 2
  store i8* %.p2729, i8** %.p2730
  ret void
}

define i64 @Parser__cur(%Parser* %self) {
entry:
  %.p2731 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 1
  %.t0 = load i64, i64* %.p2731
  %__fld.1 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 0
  %.p2732 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %__fld.1, i32 0, i32 0
  %.t2 = load i64, i64* %.p2732
  %.t3 = sub i64 %.t2, 1
  %.t4 = call i64 @min(i64 %.t0, i64 %.t3)
  ret i64 %.t4
}

define i64 @Parser__idx(%Parser* %self, i64 %off.arg) {
entry:
  %off = alloca i64
  store i64 %off.arg, i64* %off
  %.p2733 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 1
  %.t0 = load i64, i64* %.p2733
  %.r2734 = load i64, i64* %off
  %.t1 = add i64 %.t0, %.r2734
  %__fld.2 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 0
  %.p2735 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %__fld.2, i32 0, i32 0
  %.t3 = load i64, i64* %.p2735
  %.t4 = sub i64 %.t3, 1
  %.t5 = call i64 @min(i64 %.t1, i64 %.t4)
  ret i64 %.t5
}

define i8* @Parser__peek(%Parser* %self) {
entry:
  %__fld.0 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 0
  %.t1 = bitcast %Parser* %self to %Parser*
  %.t2 = call i64 @Parser__cur(%Parser* %.t1)
  %.p2736 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %__fld.0, i32 0, i32 0
  %.r2737 = load i64, i64* %.p2736
  %.r2738 = icmp slt i64 %.t2, 0
  %.r2739 = icmp sge i64 %.t2, %.r2737
  %.r2740 = or i1 %.r2738, %.r2739
  br i1 %.r2740, label %idx.fail.2742, label %idx.ok.2741
idx.fail.2742:
  %.p2743 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p2743, i64 %.t2, i64 %.r2737)
  call void @exit(i32 1)
  unreachable
idx.ok.2741:
  %.p2745 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %__fld.0, i32 0, i32 2
  %.p2744 = load %Token*, %Token** %.p2745
  %.p2746 = getelementptr inbounds %Token, %Token* %.p2744, i64 %.t2
  %__elem.3 = bitcast %Token* %.p2746 to %Token*
  %.p2747 = getelementptr inbounds %Token, %Token* %__elem.3, i32 0, i32 0
  %.t4 = load i8*, i8** %.p2747
  ret i8* %.t4
}

define i8* @Parser__peek_at(%Parser* %self, i64 %off.arg) {
entry:
  %off = alloca i64
  store i64 %off.arg, i64* %off
  %__fld.0 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 0
  %.t1 = bitcast %Parser* %self to %Parser*
  %.r2748 = load i64, i64* %off
  %.t2 = call i64 @Parser__idx(%Parser* %.t1, i64 %.r2748)
  %.p2749 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %__fld.0, i32 0, i32 0
  %.r2750 = load i64, i64* %.p2749
  %.r2751 = icmp slt i64 %.t2, 0
  %.r2752 = icmp sge i64 %.t2, %.r2750
  %.r2753 = or i1 %.r2751, %.r2752
  br i1 %.r2753, label %idx.fail.2755, label %idx.ok.2754
idx.fail.2755:
  %.p2756 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p2756, i64 %.t2, i64 %.r2750)
  call void @exit(i32 1)
  unreachable
idx.ok.2754:
  %.p2758 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %__fld.0, i32 0, i32 2
  %.p2757 = load %Token*, %Token** %.p2758
  %.p2759 = getelementptr inbounds %Token, %Token* %.p2757, i64 %.t2
  %__elem.3 = bitcast %Token* %.p2759 to %Token*
  %.p2760 = getelementptr inbounds %Token, %Token* %__elem.3, i32 0, i32 0
  %.t4 = load i8*, i8** %.p2760
  ret i8* %.t4
}

define i8* @Parser__token_at(%Parser* %self, i64 %i.arg) {
entry:
  %i = alloca i64
  store i64 %i.arg, i64* %i
  %__fld.0 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 0
  %__fld.1 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 0
  %.p2761 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %__fld.1, i32 0, i32 0
  %.t2 = load i64, i64* %.p2761
  %.t3 = sub i64 %.t2, 1
  %.r2762 = load i64, i64* %i
  %.t4 = call i64 @min(i64 %.r2762, i64 %.t3)
  %.p2763 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %__fld.0, i32 0, i32 0
  %.r2764 = load i64, i64* %.p2763
  %.r2765 = icmp slt i64 %.t4, 0
  %.r2766 = icmp sge i64 %.t4, %.r2764
  %.r2767 = or i1 %.r2765, %.r2766
  br i1 %.r2767, label %idx.fail.2769, label %idx.ok.2768
idx.fail.2769:
  %.p2770 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p2770, i64 %.t4, i64 %.r2764)
  call void @exit(i32 1)
  unreachable
idx.ok.2768:
  %.p2772 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %__fld.0, i32 0, i32 2
  %.p2771 = load %Token*, %Token** %.p2772
  %.p2773 = getelementptr inbounds %Token, %Token* %.p2771, i64 %.t4
  %__elem.5 = bitcast %Token* %.p2773 to %Token*
  %.p2774 = getelementptr inbounds %Token, %Token* %__elem.5, i32 0, i32 0
  %.t6 = load i8*, i8** %.p2774
  ret i8* %.t6
}

define void @Parser__peek_span(%Span* %__ret, %Parser* %self) {
entry:
  %__fld.0 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 0
  %.t1 = bitcast %Parser* %self to %Parser*
  %.t2 = call i64 @Parser__cur(%Parser* %.t1)
  %.p2775 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %__fld.0, i32 0, i32 0
  %.r2776 = load i64, i64* %.p2775
  %.r2777 = icmp slt i64 %.t2, 0
  %.r2778 = icmp sge i64 %.t2, %.r2776
  %.r2779 = or i1 %.r2777, %.r2778
  br i1 %.r2779, label %idx.fail.2781, label %idx.ok.2780
idx.fail.2781:
  %.p2782 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p2782, i64 %.t2, i64 %.r2776)
  call void @exit(i32 1)
  unreachable
idx.ok.2780:
  %.p2784 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %__fld.0, i32 0, i32 2
  %.p2783 = load %Token*, %Token** %.p2784
  %.p2785 = getelementptr inbounds %Token, %Token* %.p2783, i64 %.t2
  %__elem.3 = bitcast %Token* %.p2785 to %Token*
  %__fld.4 = getelementptr inbounds %Token, %Token* %__elem.3, i32 0, i32 3
  %.r2786 = load %Span, %Span* %__fld.4
  store %Span %.r2786, %Span* %__ret
  ret void
}

define void @Parser__tspan(%Span* %__ret, %Parser* %self, i64 %t.arg) {
entry:
  %t = alloca i64
  store i64 %t.arg, i64* %t
  %__fld.0 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 0
  %.r2787 = load i64, i64* %t
  %.p2788 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %__fld.0, i32 0, i32 0
  %.r2789 = load i64, i64* %.p2788
  %.r2790 = icmp slt i64 %.r2787, 0
  %.r2791 = icmp sge i64 %.r2787, %.r2789
  %.r2792 = or i1 %.r2790, %.r2791
  br i1 %.r2792, label %idx.fail.2794, label %idx.ok.2793
idx.fail.2794:
  %.p2795 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p2795, i64 %.r2787, i64 %.r2789)
  call void @exit(i32 1)
  unreachable
idx.ok.2793:
  %.p2797 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %__fld.0, i32 0, i32 2
  %.p2796 = load %Token*, %Token** %.p2797
  %.p2798 = getelementptr inbounds %Token, %Token* %.p2796, i64 %.r2787
  %__elem.1 = bitcast %Token* %.p2798 to %Token*
  %__fld.2 = getelementptr inbounds %Token, %Token* %__elem.1, i32 0, i32 3
  %.r2799 = load %Span, %Span* %__fld.2
  store %Span %.r2799, %Span* %__ret
  ret void
}

define i8* @Parser__ttext(%Parser* %self, i64 %t.arg) {
entry:
  %t = alloca i64
  store i64 %t.arg, i64* %t
  %__fld.0 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 0
  %.r2800 = load i64, i64* %t
  %.p2801 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %__fld.0, i32 0, i32 0
  %.r2802 = load i64, i64* %.p2801
  %.r2803 = icmp slt i64 %.r2800, 0
  %.r2804 = icmp sge i64 %.r2800, %.r2802
  %.r2805 = or i1 %.r2803, %.r2804
  br i1 %.r2805, label %idx.fail.2807, label %idx.ok.2806
idx.fail.2807:
  %.p2808 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p2808, i64 %.r2800, i64 %.r2802)
  call void @exit(i32 1)
  unreachable
idx.ok.2806:
  %.p2810 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %__fld.0, i32 0, i32 2
  %.p2809 = load %Token*, %Token** %.p2810
  %.p2811 = getelementptr inbounds %Token, %Token* %.p2809, i64 %.r2800
  %__elem.1 = bitcast %Token* %.p2811 to %Token*
  %.p2812 = getelementptr inbounds %Token, %Token* %__elem.1, i32 0, i32 1
  %.t2 = load i8*, i8** %.p2812
  ret i8* %.t2
}

define i1 @Parser__at(%Parser* %self, i8* %kind.arg) {
entry:
  %kind = alloca i8*
  store i8* %kind.arg, i8** %kind
  %.t0 = bitcast %Parser* %self to %Parser*
  %.t1 = call i8* @Parser__peek(%Parser* %.t0)
  %.r2813 = load i8*, i8** %kind
  %.r2814 = call i32 @strcmp(i8* %.t1, i8* %.r2813)
  %.t2 = icmp eq i32 %.r2814, 0
  ret i1 %.t2
}

define i64 @Parser__advance(%Parser* %self) {
entry:
  %t = alloca i64
  %.t0 = bitcast %Parser* %self to %Parser*
  %.t1 = call i64 @Parser__cur(%Parser* %.t0)
  store i64 %.t1, i64* %t
  %.p2815 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 1
  %.t2 = load i64, i64* %.p2815
  %__fld.3 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 0
  %.p2816 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %__fld.3, i32 0, i32 0
  %.t4 = load i64, i64* %.p2816
  %.t5 = sub i64 %.t4, 1
  %.t6 = icmp slt i64 %.t2, %.t5
  br i1 %.t6, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.p2817 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 1
  %.t7 = load i64, i64* %.p2817
  %.t8 = add i64 %.t7, 1
  %.p2818 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 1
  store i64 %.t8, i64* %.p2818
  br label %if_end_0
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.t9 = load i64, i64* %t
  ret i64 %.t9
}

define i8* @Parser__found(%Parser* %self) {
entry:
  %__fld.0 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 0
  %.t1 = bitcast %Parser* %self to %Parser*
  %.t2 = call i64 @Parser__cur(%Parser* %.t1)
  %.p2819 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %__fld.0, i32 0, i32 0
  %.r2820 = load i64, i64* %.p2819
  %.r2821 = icmp slt i64 %.t2, 0
  %.r2822 = icmp sge i64 %.t2, %.r2820
  %.r2823 = or i1 %.r2821, %.r2822
  br i1 %.r2823, label %idx.fail.2825, label %idx.ok.2824
idx.fail.2825:
  %.p2826 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p2826, i64 %.t2, i64 %.r2820)
  call void @exit(i32 1)
  unreachable
idx.ok.2824:
  %.p2828 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %__fld.0, i32 0, i32 2
  %.p2827 = load %Token*, %Token** %.p2828
  %.p2829 = getelementptr inbounds %Token, %Token* %.p2827, i64 %.t2
  %__elem.3 = bitcast %Token* %.p2829 to %Token*
  %.t4 = bitcast %Token* %__elem.3 to %Token*
  %.t5 = call i8* @token_display(%Token* %.t4)
  ret i8* %.t5
}

define i64 @Parser__expect(%Parser* %self, i8* %kind.arg) {
entry:
  %kind = alloca i8*
  %shown = alloca i8*
  %__agg.13 = alloca %Span
  store i8* %kind.arg, i8** %kind
  %.t0 = bitcast %Parser* %self to %Parser*
  %.r2830 = load i8*, i8** %kind
  %.t1 = call i1 @Parser__at(%Parser* %.t0, i8* %.r2830)
  br i1 %.t1, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t2 = bitcast %Parser* %self to %Parser*
  %.t3 = call i64 @Parser__advance(%Parser* %.t2)
  ret i64 %.t3
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.r2831 = load i8*, i8** %kind
  %.t4 = call i8* @kind_display(i8* %.r2831)
  store i8* %.t4, i8** %shown
  %.r2832 = load i8*, i8** %kind
  %.p2833 = getelementptr inbounds [14 x i8], [14 x i8]* @.str.96, i64 0, i64 0
  %.r2834 = call i32 @strcmp(i8* %.r2832, i8* %.p2833)
  %.t5 = icmp eq i32 %.r2834, 0
  br i1 %.t5, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.p2835 = getelementptr inbounds [18 x i8], [18 x i8]* @.str.264, i64 0, i64 0
  store i8* %.p2835, i8** %shown
  br label %if_end_3
if_next_0_5:
  br label %if_end_3
if_end_3:
  %__fld.6 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 3
  %.t7 = bitcast %Diags* %__fld.6 to %Diags*
  %.p2836 = getelementptr inbounds [10 x i8], [10 x i8]* @.str.265, i64 0, i64 0
  %.r2837 = load i8*, i8** %shown
  %.r2838 = call i64 @strlen(i8* %.p2836)
  %.r2839 = call i64 @strlen(i8* %.r2837)
  %.r2840 = add i64 %.r2838, %.r2839
  %.r2841 = add i64 %.r2840, 1
  %.t8 = call i8* @malloc(i64 %.r2841)
  call i8* @memcpy(i8* %.t8, i8* %.p2836, i64 %.r2838)
  %.p2842 = getelementptr inbounds i8, i8* %.t8, i64 %.r2838
  call i8* @memcpy(i8* %.p2842, i8* %.r2837, i64 %.r2839)
  %.p2843 = getelementptr inbounds i8, i8* %.t8, i64 %.r2840
  store i8 0, i8* %.p2843
  %.p2844 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.266, i64 0, i64 0
  %.r2845 = call i64 @strlen(i8* %.t8)
  %.r2846 = call i64 @strlen(i8* %.p2844)
  %.r2847 = add i64 %.r2845, %.r2846
  %.r2848 = add i64 %.r2847, 1
  %.t9 = call i8* @malloc(i64 %.r2848)
  call i8* @memcpy(i8* %.t9, i8* %.t8, i64 %.r2845)
  %.p2849 = getelementptr inbounds i8, i8* %.t9, i64 %.r2845
  call i8* @memcpy(i8* %.p2849, i8* %.p2844, i64 %.r2846)
  %.p2850 = getelementptr inbounds i8, i8* %.t9, i64 %.r2847
  store i8 0, i8* %.p2850
  %.t10 = bitcast %Parser* %self to %Parser*
  %.t11 = call i8* @Parser__found(%Parser* %.t10)
  %.r2851 = call i64 @strlen(i8* %.t9)
  %.r2852 = call i64 @strlen(i8* %.t11)
  %.r2853 = add i64 %.r2851, %.r2852
  %.r2854 = add i64 %.r2853, 1
  %.t12 = call i8* @malloc(i64 %.r2854)
  call i8* @memcpy(i8* %.t12, i8* %.t9, i64 %.r2851)
  %.p2855 = getelementptr inbounds i8, i8* %.t12, i64 %.r2851
  call i8* @memcpy(i8* %.p2855, i8* %.t11, i64 %.r2852)
  %.p2856 = getelementptr inbounds i8, i8* %.t12, i64 %.r2853
  store i8 0, i8* %.p2856
  %.t14 = bitcast %Parser* %self to %Parser*
  call void @Parser__peek_span(%Span* %__agg.13, %Parser* %.t14)
  %.t15 = bitcast %Span* %__agg.13 to %Span*
  %.p2857 = getelementptr inbounds [10 x i8], [10 x i8]* @.str.265, i64 0, i64 0
  %.r2858 = load i8*, i8** %shown
  %.r2859 = call i64 @strlen(i8* %.p2857)
  %.r2860 = call i64 @strlen(i8* %.r2858)
  %.r2861 = add i64 %.r2859, %.r2860
  %.r2862 = add i64 %.r2861, 1
  %.t16 = call i8* @malloc(i64 %.r2862)
  call i8* @memcpy(i8* %.t16, i8* %.p2857, i64 %.r2859)
  %.p2863 = getelementptr inbounds i8, i8* %.t16, i64 %.r2859
  call i8* @memcpy(i8* %.p2863, i8* %.r2858, i64 %.r2860)
  %.p2864 = getelementptr inbounds i8, i8* %.t16, i64 %.r2861
  store i8 0, i8* %.p2864
  %.p2865 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.267, i64 0, i64 0
  %.r2866 = call i64 @strlen(i8* %.t16)
  %.r2867 = call i64 @strlen(i8* %.p2865)
  %.r2868 = add i64 %.r2866, %.r2867
  %.r2869 = add i64 %.r2868, 1
  %.t17 = call i8* @malloc(i64 %.r2869)
  call i8* @memcpy(i8* %.t17, i8* %.t16, i64 %.r2866)
  %.p2870 = getelementptr inbounds i8, i8* %.t17, i64 %.r2866
  call i8* @memcpy(i8* %.p2870, i8* %.p2865, i64 %.r2867)
  %.p2871 = getelementptr inbounds i8, i8* %.t17, i64 %.r2868
  store i8 0, i8* %.p2871
  %.p2872 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.268, i64 0, i64 0
  %.p2873 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @Diags__add(%Diags* %.t7, i8* %.p2872, i8* %.t12, %Span* %.t15, i8* %.t17, i8* %.p2873)
  %.t18 = sub i64 0, 1
  ret i64 %.t18
}

define i64 @Parser__expect_identifier(%Parser* %self) {
entry:
  %__agg.9 = alloca %Span
  %.t0 = bitcast %Parser* %self to %Parser*
  %.p2874 = getelementptr inbounds [11 x i8], [11 x i8]* @.str.101, i64 0, i64 0
  %.t1 = call i1 @Parser__at(%Parser* %.t0, i8* %.p2874)
  br i1 %.t1, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t2 = bitcast %Parser* %self to %Parser*
  %.t3 = call i64 @Parser__advance(%Parser* %.t2)
  ret i64 %.t3
if_next_0_2:
  br label %if_end_0
if_end_0:
  %__fld.4 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 3
  %.t5 = bitcast %Diags* %__fld.4 to %Diags*
  %.t6 = bitcast %Parser* %self to %Parser*
  %.t7 = call i8* @Parser__found(%Parser* %.t6)
  %.p2875 = getelementptr inbounds [31 x i8], [31 x i8]* @.str.269, i64 0, i64 0
  %.r2876 = call i64 @strlen(i8* %.p2875)
  %.r2877 = call i64 @strlen(i8* %.t7)
  %.r2878 = add i64 %.r2876, %.r2877
  %.r2879 = add i64 %.r2878, 1
  %.t8 = call i8* @malloc(i64 %.r2879)
  call i8* @memcpy(i8* %.t8, i8* %.p2875, i64 %.r2876)
  %.p2880 = getelementptr inbounds i8, i8* %.t8, i64 %.r2876
  call i8* @memcpy(i8* %.p2880, i8* %.t7, i64 %.r2877)
  %.p2881 = getelementptr inbounds i8, i8* %.t8, i64 %.r2878
  store i8 0, i8* %.p2881
  %.t10 = bitcast %Parser* %self to %Parser*
  call void @Parser__peek_span(%Span* %__agg.9, %Parser* %.t10)
  %.t11 = bitcast %Span* %__agg.9 to %Span*
  %.p2882 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.270, i64 0, i64 0
  %.p2883 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p2884 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @Diags__add(%Diags* %.t5, i8* %.p2882, i8* %.t8, %Span* %.t11, i8* %.p2883, i8* %.p2884)
  %.t12 = sub i64 0, 1
  ret i64 %.t12
}

define void @Parser__skip_blank_newlines(%Parser* %self) {
entry:
  br label %while_cond_0
while_cond_0:
  %.t0 = bitcast %Parser* %self to %Parser*
  %.p2885 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.t1 = call i1 @Parser__at(%Parser* %.t0, i8* %.p2885)
  br i1 %.t1, label %while_body_1, label %while_end_2
while_body_1:
  %.t2 = bitcast %Parser* %self to %Parser*
  %.t3 = call i64 @Parser__advance(%Parser* %.t2)
  br label %while_cond_0
while_end_2:
  ret void
}

define void @Parser__synchronize_to_top_level(%Parser* %self) {
entry:
  %__sc.0 = alloca i1
  %__sc.1 = alloca i1
  %__sc.2 = alloca i1
  %__sc.3 = alloca i1
  %__sc.4 = alloca i1
  %__sc.5 = alloca i1
  %__sc.6 = alloca i1
  br label %while_cond_0
while_cond_0:
  %.t7 = bitcast %Parser* %self to %Parser*
  %.p2886 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.224, i64 0, i64 0
  %.t8 = call i1 @Parser__at(%Parser* %.t7, i8* %.p2886)
  %.t9 = xor i1 %.t8, true
  br i1 %.t9, label %sc_rhs_3, label %sc_short_4
sc_rhs_3:
  %.t10 = bitcast %Parser* %self to %Parser*
  %.p2887 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.14, i64 0, i64 0
  %.t11 = call i1 @Parser__at(%Parser* %.t10, i8* %.p2887)
  %.t12 = xor i1 %.t11, true
  store i1 %.t12, i1* %__sc.6
  br label %sc_end_5
sc_short_4:
  store i1 false, i1* %__sc.6
  br label %sc_end_5
sc_end_5:
  %.r2888 = load i1, i1* %__sc.6
  br i1 %.r2888, label %sc_rhs_6, label %sc_short_7
sc_rhs_6:
  %.t13 = bitcast %Parser* %self to %Parser*
  %.p2889 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.66, i64 0, i64 0
  %.t14 = call i1 @Parser__at(%Parser* %.t13, i8* %.p2889)
  %.t15 = xor i1 %.t14, true
  store i1 %.t15, i1* %__sc.5
  br label %sc_end_8
sc_short_7:
  store i1 false, i1* %__sc.5
  br label %sc_end_8
sc_end_8:
  %.r2890 = load i1, i1* %__sc.5
  br i1 %.r2890, label %sc_rhs_9, label %sc_short_10
sc_rhs_9:
  %.t16 = bitcast %Parser* %self to %Parser*
  %.p2891 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.16, i64 0, i64 0
  %.t17 = call i1 @Parser__at(%Parser* %.t16, i8* %.p2891)
  %.t18 = xor i1 %.t17, true
  store i1 %.t18, i1* %__sc.4
  br label %sc_end_11
sc_short_10:
  store i1 false, i1* %__sc.4
  br label %sc_end_11
sc_end_11:
  %.r2892 = load i1, i1* %__sc.4
  br i1 %.r2892, label %sc_rhs_12, label %sc_short_13
sc_rhs_12:
  %.t19 = bitcast %Parser* %self to %Parser*
  %.p2893 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.54, i64 0, i64 0
  %.t20 = call i1 @Parser__at(%Parser* %.t19, i8* %.p2893)
  %.t21 = xor i1 %.t20, true
  store i1 %.t21, i1* %__sc.3
  br label %sc_end_14
sc_short_13:
  store i1 false, i1* %__sc.3
  br label %sc_end_14
sc_end_14:
  %.r2894 = load i1, i1* %__sc.3
  br i1 %.r2894, label %sc_rhs_15, label %sc_short_16
sc_rhs_15:
  %.t22 = bitcast %Parser* %self to %Parser*
  %.p2895 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.62, i64 0, i64 0
  %.t23 = call i1 @Parser__at(%Parser* %.t22, i8* %.p2895)
  %.t24 = xor i1 %.t23, true
  store i1 %.t24, i1* %__sc.2
  br label %sc_end_17
sc_short_16:
  store i1 false, i1* %__sc.2
  br label %sc_end_17
sc_end_17:
  %.r2896 = load i1, i1* %__sc.2
  br i1 %.r2896, label %sc_rhs_18, label %sc_short_19
sc_rhs_18:
  %.t25 = bitcast %Parser* %self to %Parser*
  %.p2897 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.48, i64 0, i64 0
  %.t26 = call i1 @Parser__at(%Parser* %.t25, i8* %.p2897)
  %.t27 = xor i1 %.t26, true
  store i1 %.t27, i1* %__sc.1
  br label %sc_end_20
sc_short_19:
  store i1 false, i1* %__sc.1
  br label %sc_end_20
sc_end_20:
  %.r2898 = load i1, i1* %__sc.1
  br i1 %.r2898, label %sc_rhs_21, label %sc_short_22
sc_rhs_21:
  %.t28 = bitcast %Parser* %self to %Parser*
  %.p2899 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.50, i64 0, i64 0
  %.t29 = call i1 @Parser__at(%Parser* %.t28, i8* %.p2899)
  %.t30 = xor i1 %.t29, true
  store i1 %.t30, i1* %__sc.0
  br label %sc_end_23
sc_short_22:
  store i1 false, i1* %__sc.0
  br label %sc_end_23
sc_end_23:
  %.r2900 = load i1, i1* %__sc.0
  br i1 %.r2900, label %while_body_1, label %while_end_2
while_body_1:
  %.t31 = bitcast %Parser* %self to %Parser*
  %.t32 = call i64 @Parser__advance(%Parser* %.t31)
  br label %while_cond_0
while_end_2:
  ret void
}

define void @Parser__synchronize_to_next_stmt(%Parser* %self) {
entry:
  %__sc.0 = alloca i1
  %__sc.1 = alloca i1
  br label %while_cond_0
while_cond_0:
  %.t2 = bitcast %Parser* %self to %Parser*
  %.p2901 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.224, i64 0, i64 0
  %.t3 = call i1 @Parser__at(%Parser* %.t2, i8* %.p2901)
  %.t4 = xor i1 %.t3, true
  br i1 %.t4, label %sc_rhs_3, label %sc_short_4
sc_rhs_3:
  %.t5 = bitcast %Parser* %self to %Parser*
  %.p2902 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.t6 = call i1 @Parser__at(%Parser* %.t5, i8* %.p2902)
  %.t7 = xor i1 %.t6, true
  store i1 %.t7, i1* %__sc.1
  br label %sc_end_5
sc_short_4:
  store i1 false, i1* %__sc.1
  br label %sc_end_5
sc_end_5:
  %.r2903 = load i1, i1* %__sc.1
  br i1 %.r2903, label %sc_rhs_6, label %sc_short_7
sc_rhs_6:
  %.t8 = bitcast %Parser* %self to %Parser*
  %.p2904 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.222, i64 0, i64 0
  %.t9 = call i1 @Parser__at(%Parser* %.t8, i8* %.p2904)
  %.t10 = xor i1 %.t9, true
  store i1 %.t10, i1* %__sc.0
  br label %sc_end_8
sc_short_7:
  store i1 false, i1* %__sc.0
  br label %sc_end_8
sc_end_8:
  %.r2905 = load i1, i1* %__sc.0
  br i1 %.r2905, label %while_body_1, label %while_end_2
while_body_1:
  %.t11 = bitcast %Parser* %self to %Parser*
  %.t12 = call i64 @Parser__advance(%Parser* %.t11)
  br label %while_cond_0
while_end_2:
  %.t13 = bitcast %Parser* %self to %Parser*
  %.p2906 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.t14 = call i1 @Parser__at(%Parser* %.t13, i8* %.p2906)
  br i1 %.t14, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.t15 = bitcast %Parser* %self to %Parser*
  %.t16 = call i64 @Parser__advance(%Parser* %.t15)
  br label %if_end_9
if_next_0_11:
  br label %if_end_9
if_end_9:
  ret void
}

define i64 @Parser__parse_program(%Parser* %self) {
entry:
  %imports = alloca { i64, i64, i64* }
  %structs = alloca { i64, i64, i64* }
  %enums = alloca { i64, i64, i64* }
  %functions = alloca { i64, i64, i64* }
  %start = alloca %Span
  %k = alloca i8*
  %ok = alloca i1
  %__sc.7 = alloca i1
  %r = alloca i64
  %__for.idx.23 = alloca i64
  %__for.len.24 = alloca i64
  %f = alloca i64
  %__sc.33 = alloca i1
  %__sc.34 = alloca i1
  %__agg.46 = alloca %Span
  %a = alloca i64
  %b = alloca i64
  %c = alloca i64
  %d = alloca i64
  %.p2908 = getelementptr i64, i64* null, i32 1
  %.r2909 = ptrtoint i64* %.p2908 to i64
  %.r2910 = mul i64 %.r2909, 1
  %.p2907 = call i8* @malloc(i64 %.r2910)
  %.p2911 = bitcast i8* %.p2907 to i64*
  %.p2912 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %imports, i32 0, i32 0
  store i64 0, i64* %.p2912
  %.p2913 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %imports, i32 0, i32 1
  store i64 0, i64* %.p2913
  %.p2914 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %imports, i32 0, i32 2
  store i64* %.p2911, i64** %.p2914
  %.p2916 = getelementptr i64, i64* null, i32 1
  %.r2917 = ptrtoint i64* %.p2916 to i64
  %.r2918 = mul i64 %.r2917, 1
  %.p2915 = call i8* @malloc(i64 %.r2918)
  %.p2919 = bitcast i8* %.p2915 to i64*
  %.p2920 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %structs, i32 0, i32 0
  store i64 0, i64* %.p2920
  %.p2921 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %structs, i32 0, i32 1
  store i64 0, i64* %.p2921
  %.p2922 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %structs, i32 0, i32 2
  store i64* %.p2919, i64** %.p2922
  %.p2924 = getelementptr i64, i64* null, i32 1
  %.r2925 = ptrtoint i64* %.p2924 to i64
  %.r2926 = mul i64 %.r2925, 1
  %.p2923 = call i8* @malloc(i64 %.r2926)
  %.p2927 = bitcast i8* %.p2923 to i64*
  %.p2928 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %enums, i32 0, i32 0
  store i64 0, i64* %.p2928
  %.p2929 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %enums, i32 0, i32 1
  store i64 0, i64* %.p2929
  %.p2930 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %enums, i32 0, i32 2
  store i64* %.p2927, i64** %.p2930
  %.p2932 = getelementptr i64, i64* null, i32 1
  %.r2933 = ptrtoint i64* %.p2932 to i64
  %.r2934 = mul i64 %.r2933, 1
  %.p2931 = call i8* @malloc(i64 %.r2934)
  %.p2935 = bitcast i8* %.p2931 to i64*
  %.p2936 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %functions, i32 0, i32 0
  store i64 0, i64* %.p2936
  %.p2937 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %functions, i32 0, i32 1
  store i64 0, i64* %.p2937
  %.p2938 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %functions, i32 0, i32 2
  store i64* %.p2935, i64** %.p2938
  %.t0 = bitcast %Parser* %self to %Parser*
  call void @Parser__peek_span(%Span* %start, %Parser* %.t0)
  %.t1 = bitcast %Parser* %self to %Parser*
  call void @Parser__skip_blank_newlines(%Parser* %.t1)
  br label %while_cond_0
while_cond_0:
  %.t2 = bitcast %Parser* %self to %Parser*
  %.p2939 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.224, i64 0, i64 0
  %.t3 = call i1 @Parser__at(%Parser* %.t2, i8* %.p2939)
  %.t4 = xor i1 %.t3, true
  br i1 %.t4, label %while_body_1, label %while_end_2
while_body_1:
  %.t5 = bitcast %Parser* %self to %Parser*
  %.t6 = call i8* @Parser__peek(%Parser* %.t5)
  store i8* %.t6, i8** %k
  store i1 true, i1* %ok
  %.r2940 = load i8*, i8** %k
  %.p2941 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.48, i64 0, i64 0
  %.r2942 = call i32 @strcmp(i8* %.r2940, i8* %.p2941)
  %.t8 = icmp eq i32 %.r2942, 0
  br i1 %.t8, label %sc_short_7, label %sc_rhs_6
sc_rhs_6:
  %.r2943 = load i8*, i8** %k
  %.p2944 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.50, i64 0, i64 0
  %.r2945 = call i32 @strcmp(i8* %.r2943, i8* %.p2944)
  %.t9 = icmp eq i32 %.r2945, 0
  store i1 %.t9, i1* %__sc.7
  br label %sc_end_8
sc_short_7:
  store i1 true, i1* %__sc.7
  br label %sc_end_8
sc_end_8:
  %.r2946 = load i1, i1* %__sc.7
  br i1 %.r2946, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.t10 = bitcast %Parser* %self to %Parser*
  %.t11 = call i64 @Parser__parse_import(%Parser* %.t10)
  store i64 %.t11, i64* %r
  %.r2947 = load i64, i64* %r
  %.t12 = icmp slt i64 %.r2947, 0
  br i1 %.t12, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  store i1 false, i1* %ok
  br label %if_end_9
if_next_0_11:
  %.p2948 = getelementptr i64, i64* null, i32 1
  %.r2949 = ptrtoint i64* %.p2948 to i64
  %.p2950 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %imports, i32 0, i32 0
  %.p2951 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %imports, i32 0, i32 1
  %.p2952 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %imports, i32 0, i32 2
  %.r2953 = load i64, i64* %.p2950
  %.r2954 = load i64, i64* %.p2951
  %.r2955 = icmp sge i64 %.r2953, %.r2954
  br i1 %.r2955, label %append.grow.2956, label %append.after.2957
append.grow.2956:
  %.r2958 = load i64*, i64** %.p2952
  %.r2959 = icmp eq i64 %.r2954, 0
  %.r2960 = mul i64 %.r2954, 2
  %.r2961 = select i1 %.r2959, i64 1, i64 %.r2960
  %.r2962 = mul i64 %.r2961, %.r2949
  %.p2963 = call i8* @malloc(i64 %.r2962)
  %.p2964 = bitcast i8* %.p2963 to i64*
  %.r2965 = mul i64 %.r2953, %.r2949
  %.p2966 = bitcast i64* %.r2958 to i8*
  call i8* @memcpy(i8* %.p2963, i8* %.p2966, i64 %.r2965)
  call void @free(i8* %.p2966)
  store i64* %.p2964, i64** %.p2952
  store i64 %.r2961, i64* %.p2951
  br label %append.after.2957
append.after.2957:
  %.r2967 = load i64*, i64** %.p2952
  %.r2968 = load i64, i64* %r
  %.p2969 = getelementptr inbounds i64, i64* %.r2967, i64 %.r2953
  store i64 %.r2968, i64* %.p2969
  %.r2970 = add i64 %.r2953, 1
  store i64 %.r2970, i64* %.p2950
  br label %if_end_9
if_end_9:
  br label %if_end_3
if_next_0_5:
  %.r2971 = load i8*, i8** %k
  %.p2972 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.54, i64 0, i64 0
  %.r2973 = call i32 @strcmp(i8* %.r2971, i8* %.p2972)
  %.t13 = icmp eq i32 %.r2973, 0
  br i1 %.t13, label %if_then_1_12, label %if_next_1_13
if_then_1_12:
  %.t14 = bitcast %Parser* %self to %Parser*
  %.t15 = call i64 @Parser__parse_struct_def(%Parser* %.t14)
  store i64 %.t15, i64* %r
  %.r2974 = load i64, i64* %r
  %.t16 = icmp slt i64 %.r2974, 0
  br i1 %.t16, label %if_then_0_15, label %if_next_0_16
if_then_0_15:
  store i1 false, i1* %ok
  br label %if_end_14
if_next_0_16:
  %.p2975 = getelementptr i64, i64* null, i32 1
  %.r2976 = ptrtoint i64* %.p2975 to i64
  %.p2977 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %structs, i32 0, i32 0
  %.p2978 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %structs, i32 0, i32 1
  %.p2979 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %structs, i32 0, i32 2
  %.r2980 = load i64, i64* %.p2977
  %.r2981 = load i64, i64* %.p2978
  %.r2982 = icmp sge i64 %.r2980, %.r2981
  br i1 %.r2982, label %append.grow.2983, label %append.after.2984
append.grow.2983:
  %.r2985 = load i64*, i64** %.p2979
  %.r2986 = icmp eq i64 %.r2981, 0
  %.r2987 = mul i64 %.r2981, 2
  %.r2988 = select i1 %.r2986, i64 1, i64 %.r2987
  %.r2989 = mul i64 %.r2988, %.r2976
  %.p2990 = call i8* @malloc(i64 %.r2989)
  %.p2991 = bitcast i8* %.p2990 to i64*
  %.r2992 = mul i64 %.r2980, %.r2976
  %.p2993 = bitcast i64* %.r2985 to i8*
  call i8* @memcpy(i8* %.p2990, i8* %.p2993, i64 %.r2992)
  call void @free(i8* %.p2993)
  store i64* %.p2991, i64** %.p2979
  store i64 %.r2988, i64* %.p2978
  br label %append.after.2984
append.after.2984:
  %.r2994 = load i64*, i64** %.p2979
  %.r2995 = load i64, i64* %r
  %.p2996 = getelementptr inbounds i64, i64* %.r2994, i64 %.r2980
  store i64 %.r2995, i64* %.p2996
  %.r2997 = add i64 %.r2980, 1
  store i64 %.r2997, i64* %.p2977
  br label %if_end_14
if_end_14:
  br label %if_end_3
if_next_1_13:
  %.r2998 = load i8*, i8** %k
  %.p2999 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.56, i64 0, i64 0
  %.r3000 = call i32 @strcmp(i8* %.r2998, i8* %.p2999)
  %.t17 = icmp eq i32 %.r3000, 0
  br i1 %.t17, label %if_then_2_17, label %if_next_2_18
if_then_2_17:
  %__fld.18 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 5
  %.p3001 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.18, i32 0, i32 0
  store i64 0, i64* %.p3001
  %.t19 = bitcast %Parser* %self to %Parser*
  %.t20 = call i64 @Parser__parse_class_def(%Parser* %.t19)
  store i64 %.t20, i64* %r
  %.r3002 = load i64, i64* %r
  %.t21 = icmp slt i64 %.r3002, 0
  br i1 %.t21, label %if_then_0_20, label %if_next_0_21
if_then_0_20:
  store i1 false, i1* %ok
  br label %if_end_19
if_next_0_21:
  %.p3003 = getelementptr i64, i64* null, i32 1
  %.r3004 = ptrtoint i64* %.p3003 to i64
  %.p3005 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %structs, i32 0, i32 0
  %.p3006 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %structs, i32 0, i32 1
  %.p3007 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %structs, i32 0, i32 2
  %.r3008 = load i64, i64* %.p3005
  %.r3009 = load i64, i64* %.p3006
  %.r3010 = icmp sge i64 %.r3008, %.r3009
  br i1 %.r3010, label %append.grow.3011, label %append.after.3012
append.grow.3011:
  %.r3013 = load i64*, i64** %.p3007
  %.r3014 = icmp eq i64 %.r3009, 0
  %.r3015 = mul i64 %.r3009, 2
  %.r3016 = select i1 %.r3014, i64 1, i64 %.r3015
  %.r3017 = mul i64 %.r3016, %.r3004
  %.p3018 = call i8* @malloc(i64 %.r3017)
  %.p3019 = bitcast i8* %.p3018 to i64*
  %.r3020 = mul i64 %.r3008, %.r3004
  %.p3021 = bitcast i64* %.r3013 to i8*
  call i8* @memcpy(i8* %.p3018, i8* %.p3021, i64 %.r3020)
  call void @free(i8* %.p3021)
  store i64* %.p3019, i64** %.p3007
  store i64 %.r3016, i64* %.p3006
  br label %append.after.3012
append.after.3012:
  %.r3022 = load i64*, i64** %.p3007
  %.r3023 = load i64, i64* %r
  %.p3024 = getelementptr inbounds i64, i64* %.r3022, i64 %.r3008
  store i64 %.r3023, i64* %.p3024
  %.r3025 = add i64 %.r3008, 1
  store i64 %.r3025, i64* %.p3005
  %__fld.22 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 5
  store i64 0, i64* %__for.idx.23
  %.p3026 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.22, i32 0, i32 0
  %.t25 = load i64, i64* %.p3026
  store i64 %.t25, i64* %__for.len.24
  br label %foreach_cond_22
foreach_cond_22:
  %.r3027 = load i64, i64* %__for.idx.23
  %.r3028 = load i64, i64* %__for.len.24
  %.t26 = icmp slt i64 %.r3027, %.r3028
  br i1 %.t26, label %foreach_body_23, label %foreach_end_25
foreach_body_23:
  %.r3029 = load i64, i64* %__for.idx.23
  %.p3030 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.22, i32 0, i32 0
  %.r3031 = load i64, i64* %.p3030
  %.r3032 = icmp slt i64 %.r3029, 0
  %.r3033 = icmp sge i64 %.r3029, %.r3031
  %.r3034 = or i1 %.r3032, %.r3033
  br i1 %.r3034, label %idx.fail.3036, label %idx.ok.3035
idx.fail.3036:
  %.p3037 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p3037, i64 %.r3029, i64 %.r3031)
  call void @exit(i32 1)
  unreachable
idx.ok.3035:
  %.p3039 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__fld.22, i32 0, i32 2
  %.p3038 = load i64*, i64** %.p3039
  %.p3040 = getelementptr inbounds i64, i64* %.p3038, i64 %.r3029
  %.t27 = load i64, i64* %.p3040
  store i64 %.t27, i64* %f
  %.p3041 = getelementptr i64, i64* null, i32 1
  %.r3042 = ptrtoint i64* %.p3041 to i64
  %.p3043 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %functions, i32 0, i32 0
  %.p3044 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %functions, i32 0, i32 1
  %.p3045 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %functions, i32 0, i32 2
  %.r3046 = load i64, i64* %.p3043
  %.r3047 = load i64, i64* %.p3044
  %.r3048 = icmp sge i64 %.r3046, %.r3047
  br i1 %.r3048, label %append.grow.3049, label %append.after.3050
append.grow.3049:
  %.r3051 = load i64*, i64** %.p3045
  %.r3052 = icmp eq i64 %.r3047, 0
  %.r3053 = mul i64 %.r3047, 2
  %.r3054 = select i1 %.r3052, i64 1, i64 %.r3053
  %.r3055 = mul i64 %.r3054, %.r3042
  %.p3056 = call i8* @malloc(i64 %.r3055)
  %.p3057 = bitcast i8* %.p3056 to i64*
  %.r3058 = mul i64 %.r3046, %.r3042
  %.p3059 = bitcast i64* %.r3051 to i8*
  call i8* @memcpy(i8* %.p3056, i8* %.p3059, i64 %.r3058)
  call void @free(i8* %.p3059)
  store i64* %.p3057, i64** %.p3045
  store i64 %.r3054, i64* %.p3044
  br label %append.after.3050
append.after.3050:
  %.r3060 = load i64*, i64** %.p3045
  %.r3061 = load i64, i64* %f
  %.p3062 = getelementptr inbounds i64, i64* %.r3060, i64 %.r3046
  store i64 %.r3061, i64* %.p3062
  %.r3063 = add i64 %.r3046, 1
  store i64 %.r3063, i64* %.p3043
  br label %foreach_step_24
foreach_step_24:
  %.r3064 = load i64, i64* %__for.idx.23
  %.t28 = add i64 %.r3064, 1
  store i64 %.t28, i64* %__for.idx.23
  br label %foreach_cond_22
foreach_end_25:
  br label %if_end_19
if_end_19:
  br label %if_end_3
if_next_2_18:
  %.r3065 = load i8*, i8** %k
  %.p3066 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.62, i64 0, i64 0
  %.r3067 = call i32 @strcmp(i8* %.r3065, i8* %.p3066)
  %.t29 = icmp eq i32 %.r3067, 0
  br i1 %.t29, label %if_then_3_26, label %if_next_3_27
if_then_3_26:
  %.t30 = bitcast %Parser* %self to %Parser*
  %.t31 = call i64 @Parser__parse_enum_def(%Parser* %.t30)
  store i64 %.t31, i64* %r
  %.r3068 = load i64, i64* %r
  %.t32 = icmp slt i64 %.r3068, 0
  br i1 %.t32, label %if_then_0_29, label %if_next_0_30
if_then_0_29:
  store i1 false, i1* %ok
  br label %if_end_28
if_next_0_30:
  %.p3069 = getelementptr i64, i64* null, i32 1
  %.r3070 = ptrtoint i64* %.p3069 to i64
  %.p3071 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %enums, i32 0, i32 0
  %.p3072 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %enums, i32 0, i32 1
  %.p3073 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %enums, i32 0, i32 2
  %.r3074 = load i64, i64* %.p3071
  %.r3075 = load i64, i64* %.p3072
  %.r3076 = icmp sge i64 %.r3074, %.r3075
  br i1 %.r3076, label %append.grow.3077, label %append.after.3078
append.grow.3077:
  %.r3079 = load i64*, i64** %.p3073
  %.r3080 = icmp eq i64 %.r3075, 0
  %.r3081 = mul i64 %.r3075, 2
  %.r3082 = select i1 %.r3080, i64 1, i64 %.r3081
  %.r3083 = mul i64 %.r3082, %.r3070
  %.p3084 = call i8* @malloc(i64 %.r3083)
  %.p3085 = bitcast i8* %.p3084 to i64*
  %.r3086 = mul i64 %.r3074, %.r3070
  %.p3087 = bitcast i64* %.r3079 to i8*
  call i8* @memcpy(i8* %.p3084, i8* %.p3087, i64 %.r3086)
  call void @free(i8* %.p3087)
  store i64* %.p3085, i64** %.p3073
  store i64 %.r3082, i64* %.p3072
  br label %append.after.3078
append.after.3078:
  %.r3088 = load i64*, i64** %.p3073
  %.r3089 = load i64, i64* %r
  %.p3090 = getelementptr inbounds i64, i64* %.r3088, i64 %.r3074
  store i64 %.r3089, i64* %.p3090
  %.r3091 = add i64 %.r3074, 1
  store i64 %.r3091, i64* %.p3071
  br label %if_end_28
if_end_28:
  br label %if_end_3
if_next_3_27:
  %.r3092 = load i8*, i8** %k
  %.p3093 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.66, i64 0, i64 0
  %.r3094 = call i32 @strcmp(i8* %.r3092, i8* %.p3093)
  %.t35 = icmp eq i32 %.r3094, 0
  br i1 %.t35, label %sc_short_34, label %sc_rhs_33
sc_rhs_33:
  %.r3095 = load i8*, i8** %k
  %.p3096 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.14, i64 0, i64 0
  %.r3097 = call i32 @strcmp(i8* %.r3095, i8* %.p3096)
  %.t36 = icmp eq i32 %.r3097, 0
  store i1 %.t36, i1* %__sc.34
  br label %sc_end_35
sc_short_34:
  store i1 true, i1* %__sc.34
  br label %sc_end_35
sc_end_35:
  %.r3098 = load i1, i1* %__sc.34
  br i1 %.r3098, label %sc_short_37, label %sc_rhs_36
sc_rhs_36:
  %.r3099 = load i8*, i8** %k
  %.p3100 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.16, i64 0, i64 0
  %.r3101 = call i32 @strcmp(i8* %.r3099, i8* %.p3100)
  %.t37 = icmp eq i32 %.r3101, 0
  store i1 %.t37, i1* %__sc.33
  br label %sc_end_38
sc_short_37:
  store i1 true, i1* %__sc.33
  br label %sc_end_38
sc_end_38:
  %.r3102 = load i1, i1* %__sc.33
  br i1 %.r3102, label %if_then_4_31, label %if_next_4_32
if_then_4_31:
  %.t38 = bitcast %Parser* %self to %Parser*
  %.t39 = call i64 @Parser__parse_function(%Parser* %.t38)
  store i64 %.t39, i64* %r
  %.r3103 = load i64, i64* %r
  %.t40 = icmp slt i64 %.r3103, 0
  br i1 %.t40, label %if_then_0_40, label %if_next_0_41
if_then_0_40:
  store i1 false, i1* %ok
  br label %if_end_39
if_next_0_41:
  %.p3104 = getelementptr i64, i64* null, i32 1
  %.r3105 = ptrtoint i64* %.p3104 to i64
  %.p3106 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %functions, i32 0, i32 0
  %.p3107 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %functions, i32 0, i32 1
  %.p3108 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %functions, i32 0, i32 2
  %.r3109 = load i64, i64* %.p3106
  %.r3110 = load i64, i64* %.p3107
  %.r3111 = icmp sge i64 %.r3109, %.r3110
  br i1 %.r3111, label %append.grow.3112, label %append.after.3113
append.grow.3112:
  %.r3114 = load i64*, i64** %.p3108
  %.r3115 = icmp eq i64 %.r3110, 0
  %.r3116 = mul i64 %.r3110, 2
  %.r3117 = select i1 %.r3115, i64 1, i64 %.r3116
  %.r3118 = mul i64 %.r3117, %.r3105
  %.p3119 = call i8* @malloc(i64 %.r3118)
  %.p3120 = bitcast i8* %.p3119 to i64*
  %.r3121 = mul i64 %.r3109, %.r3105
  %.p3122 = bitcast i64* %.r3114 to i8*
  call i8* @memcpy(i8* %.p3119, i8* %.p3122, i64 %.r3121)
  call void @free(i8* %.p3122)
  store i64* %.p3120, i64** %.p3108
  store i64 %.r3117, i64* %.p3107
  br label %append.after.3113
append.after.3113:
  %.r3123 = load i64*, i64** %.p3108
  %.r3124 = load i64, i64* %r
  %.p3125 = getelementptr inbounds i64, i64* %.r3123, i64 %.r3109
  store i64 %.r3124, i64* %.p3125
  %.r3126 = add i64 %.r3109, 1
  store i64 %.r3126, i64* %.p3106
  br label %if_end_39
if_end_39:
  br label %if_end_3
if_next_4_32:
  %__fld.41 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 3
  %.t42 = bitcast %Diags* %__fld.41 to %Diags*
  %.t43 = bitcast %Parser* %self to %Parser*
  %.t44 = call i8* @Parser__found(%Parser* %.t43)
  %.p3127 = getelementptr inbounds [77 x i8], [77 x i8]* @.str.271, i64 0, i64 0
  %.r3128 = call i64 @strlen(i8* %.p3127)
  %.r3129 = call i64 @strlen(i8* %.t44)
  %.r3130 = add i64 %.r3128, %.r3129
  %.r3131 = add i64 %.r3130, 1
  %.t45 = call i8* @malloc(i64 %.r3131)
  call i8* @memcpy(i8* %.t45, i8* %.p3127, i64 %.r3128)
  %.p3132 = getelementptr inbounds i8, i8* %.t45, i64 %.r3128
  call i8* @memcpy(i8* %.p3132, i8* %.t44, i64 %.r3129)
  %.p3133 = getelementptr inbounds i8, i8* %.t45, i64 %.r3130
  store i8 0, i8* %.p3133
  %.t47 = bitcast %Parser* %self to %Parser*
  call void @Parser__peek_span(%Span* %__agg.46, %Parser* %.t47)
  %.t48 = bitcast %Span* %__agg.46 to %Span*
  %.p3134 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.268, i64 0, i64 0
  %.p3135 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p3136 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @Diags__add(%Diags* %.t42, i8* %.p3134, i8* %.t45, %Span* %.t48, i8* %.p3135, i8* %.p3136)
  store i1 false, i1* %ok
  br label %if_end_3
if_end_3:
  %.r3137 = load i1, i1* %ok
  %.t49 = xor i1 %.r3137, true
  br i1 %.t49, label %if_then_0_43, label %if_next_0_44
if_then_0_43:
  %.t50 = bitcast %Parser* %self to %Parser*
  call void @Parser__synchronize_to_top_level(%Parser* %.t50)
  br label %if_end_42
if_next_0_44:
  br label %if_end_42
if_end_42:
  %.t51 = bitcast %Parser* %self to %Parser*
  call void @Parser__skip_blank_newlines(%Parser* %.t51)
  br label %while_cond_0
while_end_2:
  %__fld.52 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 3
  %.t53 = bitcast %Diags* %__fld.52 to %Diags*
  %.t54 = call i1 @Diags__had_errors(%Diags* %.t53)
  br i1 %.t54, label %if_then_0_46, label %if_next_0_47
if_then_0_46:
  %.t55 = sub i64 0, 1
  ret i64 %.t55
if_next_0_47:
  br label %if_end_45
if_end_45:
  %__fld.56 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t57 = bitcast %Ast* %__fld.56 to %Ast*
  %.t58 = bitcast %Span* %start to %Span*
  %.t59 = bitcast { i64, i64, i64* }* %imports to { i64, i64, i64* }*
  %.p3138 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.255, i64 0, i64 0
  %.p3139 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.t60 = call i64 @Ast__addl(%Ast* %.t57, i8* %.p3138, i8* %.p3139, %Span* %.t58, { i64, i64, i64* }* %.t59)
  store i64 %.t60, i64* %a
  %__fld.61 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t62 = bitcast %Ast* %__fld.61 to %Ast*
  %.t63 = bitcast %Span* %start to %Span*
  %.t64 = bitcast { i64, i64, i64* }* %structs to { i64, i64, i64* }*
  %.p3140 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.255, i64 0, i64 0
  %.p3141 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.t65 = call i64 @Ast__addl(%Ast* %.t62, i8* %.p3140, i8* %.p3141, %Span* %.t63, { i64, i64, i64* }* %.t64)
  store i64 %.t65, i64* %b
  %__fld.66 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t67 = bitcast %Ast* %__fld.66 to %Ast*
  %.t68 = bitcast %Span* %start to %Span*
  %.t69 = bitcast { i64, i64, i64* }* %enums to { i64, i64, i64* }*
  %.p3142 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.255, i64 0, i64 0
  %.p3143 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.t70 = call i64 @Ast__addl(%Ast* %.t67, i8* %.p3142, i8* %.p3143, %Span* %.t68, { i64, i64, i64* }* %.t69)
  store i64 %.t70, i64* %c
  %__fld.71 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t72 = bitcast %Ast* %__fld.71 to %Ast*
  %.t73 = bitcast %Span* %start to %Span*
  %.t74 = bitcast { i64, i64, i64* }* %functions to { i64, i64, i64* }*
  %.p3144 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.255, i64 0, i64 0
  %.p3145 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.t75 = call i64 @Ast__addl(%Ast* %.t72, i8* %.p3144, i8* %.p3145, %Span* %.t73, { i64, i64, i64* }* %.t74)
  store i64 %.t75, i64* %d
  %__fld.76 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t77 = bitcast %Ast* %__fld.76 to %Ast*
  %.t78 = bitcast %Span* %start to %Span*
  %.p3146 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.258, i64 0, i64 0
  %.p3147 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.r3148 = load i64, i64* %a
  %.r3149 = load i64, i64* %b
  %.r3150 = load i64, i64* %c
  %.r3151 = load i64, i64* %d
  %.t79 = call i64 @Ast__add4(%Ast* %.t77, i8* %.p3146, i8* %.p3147, %Span* %.t78, i64 %.r3148, i64 %.r3149, i64 %.r3150, i64 %.r3151)
  ret i64 %.t79
}

define i64 @Parser__parse_import(%Parser* %self) {
entry:
  %start = alloca %Span
  %node = alloca i64
  %path = alloca i8*
  %items = alloca { i64, i64, i64* }
  %t = alloca i64
  %__agg.36 = alloca %Span
  %t2 = alloca i64
  %__agg.52 = alloca %Span
  %.t0 = bitcast %Parser* %self to %Parser*
  call void @Parser__peek_span(%Span* %start, %Parser* %.t0)
  %.t1 = sub i64 0, 1
  store i64 %.t1, i64* %node
  %.t2 = bitcast %Parser* %self to %Parser*
  %.p3152 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.48, i64 0, i64 0
  %.t3 = call i1 @Parser__at(%Parser* %.t2, i8* %.p3152)
  br i1 %.t3, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t4 = bitcast %Parser* %self to %Parser*
  %.t5 = call i64 @Parser__advance(%Parser* %.t4)
  %.t6 = bitcast %Parser* %self to %Parser*
  %.t7 = call i8* @Parser__parse_dotted_path(%Parser* %.t6)
  store i8* %.t7, i8** %path
  %.r3153 = load i8*, i8** %path
  %.t8 = call i64 @strlen(i8* %.r3153)
  %.t9 = icmp eq i64 %.t8, 0
  br i1 %.t9, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.t10 = sub i64 0, 1
  ret i64 %.t10
if_next_0_5:
  br label %if_end_3
if_end_3:
  %__fld.11 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t12 = bitcast %Ast* %__fld.11 to %Ast*
  %.t13 = bitcast %Span* %start to %Span*
  %.p3154 = getelementptr inbounds [13 x i8], [13 x i8]* @.str.272, i64 0, i64 0
  %.r3155 = load i8*, i8** %path
  %.t14 = call i64 @Ast__add0(%Ast* %.t12, i8* %.p3154, i8* %.r3155, %Span* %.t13)
  store i64 %.t14, i64* %node
  br label %if_end_0
if_next_0_2:
  %.t15 = bitcast %Parser* %self to %Parser*
  %.p3156 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.50, i64 0, i64 0
  %.t16 = call i64 @Parser__expect(%Parser* %.t15, i8* %.p3156)
  %.t17 = icmp slt i64 %.t16, 0
  br i1 %.t17, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.t18 = sub i64 0, 1
  ret i64 %.t18
if_next_0_8:
  br label %if_end_6
if_end_6:
  %.t19 = bitcast %Parser* %self to %Parser*
  %.t20 = call i8* @Parser__parse_dotted_path(%Parser* %.t19)
  store i8* %.t20, i8** %path
  %.r3157 = load i8*, i8** %path
  %.t21 = call i64 @strlen(i8* %.r3157)
  %.t22 = icmp eq i64 %.t21, 0
  br i1 %.t22, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.t23 = sub i64 0, 1
  ret i64 %.t23
if_next_0_11:
  br label %if_end_9
if_end_9:
  %.t24 = bitcast %Parser* %self to %Parser*
  %.p3158 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.52, i64 0, i64 0
  %.t25 = call i64 @Parser__expect(%Parser* %.t24, i8* %.p3158)
  %.t26 = icmp slt i64 %.t25, 0
  br i1 %.t26, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  %.t27 = sub i64 0, 1
  ret i64 %.t27
if_next_0_14:
  br label %if_end_12
if_end_12:
  %.p3160 = getelementptr i64, i64* null, i32 1
  %.r3161 = ptrtoint i64* %.p3160 to i64
  %.r3162 = mul i64 %.r3161, 1
  %.p3159 = call i8* @malloc(i64 %.r3162)
  %.p3163 = bitcast i8* %.p3159 to i64*
  %.p3164 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %items, i32 0, i32 0
  store i64 0, i64* %.p3164
  %.p3165 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %items, i32 0, i32 1
  store i64 0, i64* %.p3165
  %.p3166 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %items, i32 0, i32 2
  store i64* %.p3163, i64** %.p3166
  %.t28 = bitcast %Parser* %self to %Parser*
  %.t29 = call i64 @Parser__expect_identifier(%Parser* %.t28)
  store i64 %.t29, i64* %t
  %.r3167 = load i64, i64* %t
  %.t30 = icmp slt i64 %.r3167, 0
  br i1 %.t30, label %if_then_0_16, label %if_next_0_17
if_then_0_16:
  %.t31 = sub i64 0, 1
  ret i64 %.t31
if_next_0_17:
  br label %if_end_15
if_end_15:
  %__fld.32 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t33 = bitcast %Ast* %__fld.32 to %Ast*
  %.t34 = bitcast %Parser* %self to %Parser*
  %.r3168 = load i64, i64* %t
  %.t35 = call i8* @Parser__ttext(%Parser* %.t34, i64 %.r3168)
  %.t37 = bitcast %Parser* %self to %Parser*
  %.r3169 = load i64, i64* %t
  call void @Parser__tspan(%Span* %__agg.36, %Parser* %.t37, i64 %.r3169)
  %.t38 = bitcast %Span* %__agg.36 to %Span*
  %.p3170 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.257, i64 0, i64 0
  %.t39 = call i64 @Ast__add0(%Ast* %.t33, i8* %.p3170, i8* %.t35, %Span* %.t38)
  %.p3171 = getelementptr i64, i64* null, i32 1
  %.r3172 = ptrtoint i64* %.p3171 to i64
  %.p3173 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %items, i32 0, i32 0
  %.p3174 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %items, i32 0, i32 1
  %.p3175 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %items, i32 0, i32 2
  %.r3176 = load i64, i64* %.p3173
  %.r3177 = load i64, i64* %.p3174
  %.r3178 = icmp sge i64 %.r3176, %.r3177
  br i1 %.r3178, label %append.grow.3179, label %append.after.3180
append.grow.3179:
  %.r3181 = load i64*, i64** %.p3175
  %.r3182 = icmp eq i64 %.r3177, 0
  %.r3183 = mul i64 %.r3177, 2
  %.r3184 = select i1 %.r3182, i64 1, i64 %.r3183
  %.r3185 = mul i64 %.r3184, %.r3172
  %.p3186 = call i8* @malloc(i64 %.r3185)
  %.p3187 = bitcast i8* %.p3186 to i64*
  %.r3188 = mul i64 %.r3176, %.r3172
  %.p3189 = bitcast i64* %.r3181 to i8*
  call i8* @memcpy(i8* %.p3186, i8* %.p3189, i64 %.r3188)
  call void @free(i8* %.p3189)
  store i64* %.p3187, i64** %.p3175
  store i64 %.r3184, i64* %.p3174
  br label %append.after.3180
append.after.3180:
  %.r3190 = load i64*, i64** %.p3175
  %.p3191 = getelementptr inbounds i64, i64* %.r3190, i64 %.r3176
  store i64 %.t39, i64* %.p3191
  %.r3192 = add i64 %.r3176, 1
  store i64 %.r3192, i64* %.p3173
  br label %while_cond_18
while_cond_18:
  %.t40 = bitcast %Parser* %self to %Parser*
  %.p3193 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.154, i64 0, i64 0
  %.t41 = call i1 @Parser__at(%Parser* %.t40, i8* %.p3193)
  br i1 %.t41, label %while_body_19, label %while_end_20
while_body_19:
  %.t42 = bitcast %Parser* %self to %Parser*
  %.t43 = call i64 @Parser__advance(%Parser* %.t42)
  %.t44 = bitcast %Parser* %self to %Parser*
  %.t45 = call i64 @Parser__expect_identifier(%Parser* %.t44)
  store i64 %.t45, i64* %t2
  %.r3194 = load i64, i64* %t2
  %.t46 = icmp slt i64 %.r3194, 0
  br i1 %.t46, label %if_then_0_22, label %if_next_0_23
if_then_0_22:
  %.t47 = sub i64 0, 1
  ret i64 %.t47
if_next_0_23:
  br label %if_end_21
if_end_21:
  %__fld.48 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t49 = bitcast %Ast* %__fld.48 to %Ast*
  %.t50 = bitcast %Parser* %self to %Parser*
  %.r3195 = load i64, i64* %t2
  %.t51 = call i8* @Parser__ttext(%Parser* %.t50, i64 %.r3195)
  %.t53 = bitcast %Parser* %self to %Parser*
  %.r3196 = load i64, i64* %t2
  call void @Parser__tspan(%Span* %__agg.52, %Parser* %.t53, i64 %.r3196)
  %.t54 = bitcast %Span* %__agg.52 to %Span*
  %.p3197 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.257, i64 0, i64 0
  %.t55 = call i64 @Ast__add0(%Ast* %.t49, i8* %.p3197, i8* %.t51, %Span* %.t54)
  %.p3198 = getelementptr i64, i64* null, i32 1
  %.r3199 = ptrtoint i64* %.p3198 to i64
  %.p3200 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %items, i32 0, i32 0
  %.p3201 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %items, i32 0, i32 1
  %.p3202 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %items, i32 0, i32 2
  %.r3203 = load i64, i64* %.p3200
  %.r3204 = load i64, i64* %.p3201
  %.r3205 = icmp sge i64 %.r3203, %.r3204
  br i1 %.r3205, label %append.grow.3206, label %append.after.3207
append.grow.3206:
  %.r3208 = load i64*, i64** %.p3202
  %.r3209 = icmp eq i64 %.r3204, 0
  %.r3210 = mul i64 %.r3204, 2
  %.r3211 = select i1 %.r3209, i64 1, i64 %.r3210
  %.r3212 = mul i64 %.r3211, %.r3199
  %.p3213 = call i8* @malloc(i64 %.r3212)
  %.p3214 = bitcast i8* %.p3213 to i64*
  %.r3215 = mul i64 %.r3203, %.r3199
  %.p3216 = bitcast i64* %.r3208 to i8*
  call i8* @memcpy(i8* %.p3213, i8* %.p3216, i64 %.r3215)
  call void @free(i8* %.p3216)
  store i64* %.p3214, i64** %.p3202
  store i64 %.r3211, i64* %.p3201
  br label %append.after.3207
append.after.3207:
  %.r3217 = load i64*, i64** %.p3202
  %.p3218 = getelementptr inbounds i64, i64* %.r3217, i64 %.r3203
  store i64 %.t55, i64* %.p3218
  %.r3219 = add i64 %.r3203, 1
  store i64 %.r3219, i64* %.p3200
  br label %while_cond_18
while_end_20:
  %__fld.56 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t57 = bitcast %Ast* %__fld.56 to %Ast*
  %.t58 = bitcast %Span* %start to %Span*
  %.t59 = bitcast { i64, i64, i64* }* %items to { i64, i64, i64* }*
  %.p3220 = getelementptr inbounds [12 x i8], [12 x i8]* @.str.273, i64 0, i64 0
  %.r3221 = load i8*, i8** %path
  %.t60 = call i64 @Ast__addl(%Ast* %.t57, i8* %.p3220, i8* %.r3221, %Span* %.t58, { i64, i64, i64* }* %.t59)
  store i64 %.t60, i64* %node
  br label %if_end_0
if_end_0:
  %.t61 = bitcast %Parser* %self to %Parser*
  %.p3222 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.t62 = call i64 @Parser__expect(%Parser* %.t61, i8* %.p3222)
  %.t63 = icmp slt i64 %.t62, 0
  br i1 %.t63, label %if_then_0_25, label %if_next_0_26
if_then_0_25:
  %.t64 = sub i64 0, 1
  ret i64 %.t64
if_next_0_26:
  br label %if_end_24
if_end_24:
  %.t65 = load i64, i64* %node
  ret i64 %.t65
}

define i8* @Parser__parse_dotted_path(%Parser* %self) {
entry:
  %t = alloca i64
  %path = alloca i8*
  %t2 = alloca i64
  %.t0 = bitcast %Parser* %self to %Parser*
  %.t1 = call i64 @Parser__expect_identifier(%Parser* %.t0)
  store i64 %.t1, i64* %t
  %.r3223 = load i64, i64* %t
  %.t2 = icmp slt i64 %.r3223, 0
  br i1 %.t2, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.p3224 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  ret i8* %.p3224
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.t3 = bitcast %Parser* %self to %Parser*
  %.r3225 = load i64, i64* %t
  %.t4 = call i8* @Parser__ttext(%Parser* %.t3, i64 %.r3225)
  store i8* %.t4, i8** %path
  br label %while_cond_3
while_cond_3:
  %.t5 = bitcast %Parser* %self to %Parser*
  %.p3226 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.158, i64 0, i64 0
  %.t6 = call i1 @Parser__at(%Parser* %.t5, i8* %.p3226)
  br i1 %.t6, label %while_body_4, label %while_end_5
while_body_4:
  %.t7 = bitcast %Parser* %self to %Parser*
  %.t8 = call i64 @Parser__advance(%Parser* %.t7)
  %.t9 = bitcast %Parser* %self to %Parser*
  %.t10 = call i64 @Parser__expect_identifier(%Parser* %.t9)
  store i64 %.t10, i64* %t2
  %.r3227 = load i64, i64* %t2
  %.t11 = icmp slt i64 %.r3227, 0
  br i1 %.t11, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.p3228 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  ret i8* %.p3228
if_next_0_8:
  br label %if_end_6
if_end_6:
  %.r3229 = load i8*, i8** %path
  %.p3230 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.249, i64 0, i64 0
  %.r3231 = call i64 @strlen(i8* %.r3229)
  %.r3232 = call i64 @strlen(i8* %.p3230)
  %.r3233 = add i64 %.r3231, %.r3232
  %.r3234 = add i64 %.r3233, 1
  %.t12 = call i8* @malloc(i64 %.r3234)
  call i8* @memcpy(i8* %.t12, i8* %.r3229, i64 %.r3231)
  %.p3235 = getelementptr inbounds i8, i8* %.t12, i64 %.r3231
  call i8* @memcpy(i8* %.p3235, i8* %.p3230, i64 %.r3232)
  %.p3236 = getelementptr inbounds i8, i8* %.t12, i64 %.r3233
  store i8 0, i8* %.p3236
  %.t13 = bitcast %Parser* %self to %Parser*
  %.r3237 = load i64, i64* %t2
  %.t14 = call i8* @Parser__ttext(%Parser* %.t13, i64 %.r3237)
  %.r3238 = call i64 @strlen(i8* %.t12)
  %.r3239 = call i64 @strlen(i8* %.t14)
  %.r3240 = add i64 %.r3238, %.r3239
  %.r3241 = add i64 %.r3240, 1
  %.t15 = call i8* @malloc(i64 %.r3241)
  call i8* @memcpy(i8* %.t15, i8* %.t12, i64 %.r3238)
  %.p3242 = getelementptr inbounds i8, i8* %.t15, i64 %.r3238
  call i8* @memcpy(i8* %.p3242, i8* %.t14, i64 %.r3239)
  %.p3243 = getelementptr inbounds i8, i8* %.t15, i64 %.r3240
  store i8 0, i8* %.p3243
  store i8* %.t15, i8** %path
  br label %while_cond_3
while_end_5:
  %.t16 = load i8*, i8** %path
  ret i8* %.t16
}

define i64 @Parser__parse_class_def(%Parser* %self) {
entry:
  %st = alloca i64
  %start = alloca %Span
  %nt = alloca i64
  %name = alloca i8*
  %base = alloca i64
  %bt = alloca i64
  %__agg.24 = alloca %Span
  %fields = alloca { i64, i64, i64* }
  %methods = alloca { i64, i64, i64* }
  %__sc.44 = alloca i1
  %__sc.55 = alloca i1
  %f = alloca i64
  %ft = alloca i64
  %ty = alloca i64
  %__agg.93 = alloca %Span
  %et = alloca i64
  %fl = alloca i64
  %__agg.110 = alloca %Span
  %__agg.108 = alloca %Span
  %.t0 = bitcast %Parser* %self to %Parser*
  %.p3244 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.56, i64 0, i64 0
  %.t1 = call i64 @Parser__expect(%Parser* %.t0, i8* %.p3244)
  store i64 %.t1, i64* %st
  %.r3245 = load i64, i64* %st
  %.t2 = icmp slt i64 %.r3245, 0
  br i1 %.t2, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t3 = sub i64 0, 1
  ret i64 %.t3
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.t4 = bitcast %Parser* %self to %Parser*
  %.r3246 = load i64, i64* %st
  call void @Parser__tspan(%Span* %start, %Parser* %.t4, i64 %.r3246)
  %.t5 = bitcast %Parser* %self to %Parser*
  %.t6 = call i64 @Parser__expect_identifier(%Parser* %.t5)
  store i64 %.t6, i64* %nt
  %.r3247 = load i64, i64* %nt
  %.t7 = icmp slt i64 %.r3247, 0
  br i1 %.t7, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.t8 = sub i64 0, 1
  ret i64 %.t8
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.t9 = bitcast %Parser* %self to %Parser*
  %.r3248 = load i64, i64* %nt
  %.t10 = call i8* @Parser__ttext(%Parser* %.t9, i64 %.r3248)
  store i8* %.t10, i8** %name
  %.t11 = sub i64 0, 1
  store i64 %.t11, i64* %base
  %.t12 = bitcast %Parser* %self to %Parser*
  %.p3249 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.142, i64 0, i64 0
  %.t13 = call i1 @Parser__at(%Parser* %.t12, i8* %.p3249)
  br i1 %.t13, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.t14 = bitcast %Parser* %self to %Parser*
  %.t15 = call i64 @Parser__advance(%Parser* %.t14)
  %.t16 = bitcast %Parser* %self to %Parser*
  %.t17 = call i64 @Parser__expect_identifier(%Parser* %.t16)
  store i64 %.t17, i64* %bt
  %.r3250 = load i64, i64* %bt
  %.t18 = icmp slt i64 %.r3250, 0
  br i1 %.t18, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.t19 = sub i64 0, 1
  ret i64 %.t19
if_next_0_11:
  br label %if_end_9
if_end_9:
  %__fld.20 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t21 = bitcast %Ast* %__fld.20 to %Ast*
  %.t22 = bitcast %Parser* %self to %Parser*
  %.r3251 = load i64, i64* %bt
  %.t23 = call i8* @Parser__ttext(%Parser* %.t22, i64 %.r3251)
  %.t25 = bitcast %Parser* %self to %Parser*
  %.r3252 = load i64, i64* %bt
  call void @Parser__tspan(%Span* %__agg.24, %Parser* %.t25, i64 %.r3252)
  %.t26 = bitcast %Span* %__agg.24 to %Span*
  %.p3253 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.257, i64 0, i64 0
  %.t27 = call i64 @Ast__add0(%Ast* %.t21, i8* %.p3253, i8* %.t23, %Span* %.t26)
  store i64 %.t27, i64* %base
  %.t28 = bitcast %Parser* %self to %Parser*
  %.p3254 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.144, i64 0, i64 0
  %.t29 = call i64 @Parser__expect(%Parser* %.t28, i8* %.p3254)
  %.t30 = icmp slt i64 %.t29, 0
  br i1 %.t30, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  %.t31 = sub i64 0, 1
  ret i64 %.t31
if_next_0_14:
  br label %if_end_12
if_end_12:
  br label %if_end_6
if_next_0_8:
  br label %if_end_6
if_end_6:
  %.t32 = bitcast %Parser* %self to %Parser*
  %.p3255 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.156, i64 0, i64 0
  %.t33 = call i64 @Parser__expect(%Parser* %.t32, i8* %.p3255)
  %.t34 = icmp slt i64 %.t33, 0
  br i1 %.t34, label %if_then_0_16, label %if_next_0_17
if_then_0_16:
  %.t35 = sub i64 0, 1
  ret i64 %.t35
if_next_0_17:
  br label %if_end_15
if_end_15:
  %.t36 = bitcast %Parser* %self to %Parser*
  %.p3256 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.t37 = call i64 @Parser__expect(%Parser* %.t36, i8* %.p3256)
  %.t38 = icmp slt i64 %.t37, 0
  br i1 %.t38, label %if_then_0_19, label %if_next_0_20
if_then_0_19:
  %.t39 = sub i64 0, 1
  ret i64 %.t39
if_next_0_20:
  br label %if_end_18
if_end_18:
  %.t40 = bitcast %Parser* %self to %Parser*
  %.p3257 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.220, i64 0, i64 0
  %.t41 = call i64 @Parser__expect(%Parser* %.t40, i8* %.p3257)
  %.t42 = icmp slt i64 %.t41, 0
  br i1 %.t42, label %if_then_0_22, label %if_next_0_23
if_then_0_22:
  %.t43 = sub i64 0, 1
  ret i64 %.t43
if_next_0_23:
  br label %if_end_21
if_end_21:
  %.r3258 = load i8*, i8** %name
  %.p3259 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 2
  store i8* %.r3258, i8** %.p3259
  %.p3261 = getelementptr i64, i64* null, i32 1
  %.r3262 = ptrtoint i64* %.p3261 to i64
  %.r3263 = mul i64 %.r3262, 1
  %.p3260 = call i8* @malloc(i64 %.r3263)
  %.p3264 = bitcast i8* %.p3260 to i64*
  %.p3265 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %fields, i32 0, i32 0
  store i64 0, i64* %.p3265
  %.p3266 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %fields, i32 0, i32 1
  store i64 0, i64* %.p3266
  %.p3267 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %fields, i32 0, i32 2
  store i64* %.p3264, i64** %.p3267
  %.p3269 = getelementptr i64, i64* null, i32 1
  %.r3270 = ptrtoint i64* %.p3269 to i64
  %.r3271 = mul i64 %.r3270, 1
  %.p3268 = call i8* @malloc(i64 %.r3271)
  %.p3272 = bitcast i8* %.p3268 to i64*
  %.p3273 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %methods, i32 0, i32 0
  store i64 0, i64* %.p3273
  %.p3274 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %methods, i32 0, i32 1
  store i64 0, i64* %.p3274
  %.p3275 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %methods, i32 0, i32 2
  store i64* %.p3272, i64** %.p3275
  br label %while_cond_24
while_cond_24:
  %.t45 = bitcast %Parser* %self to %Parser*
  %.p3276 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.222, i64 0, i64 0
  %.t46 = call i1 @Parser__at(%Parser* %.t45, i8* %.p3276)
  %.t47 = xor i1 %.t46, true
  br i1 %.t47, label %sc_rhs_27, label %sc_short_28
sc_rhs_27:
  %.t48 = bitcast %Parser* %self to %Parser*
  %.p3277 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.224, i64 0, i64 0
  %.t49 = call i1 @Parser__at(%Parser* %.t48, i8* %.p3277)
  %.t50 = xor i1 %.t49, true
  store i1 %.t50, i1* %__sc.44
  br label %sc_end_29
sc_short_28:
  store i1 false, i1* %__sc.44
  br label %sc_end_29
sc_end_29:
  %.r3278 = load i1, i1* %__sc.44
  br i1 %.r3278, label %while_body_25, label %while_end_26
while_body_25:
  %.t51 = bitcast %Parser* %self to %Parser*
  %.p3279 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.t52 = call i1 @Parser__at(%Parser* %.t51, i8* %.p3279)
  br i1 %.t52, label %if_then_0_31, label %if_next_0_32
if_then_0_31:
  %.t53 = bitcast %Parser* %self to %Parser*
  %.t54 = call i64 @Parser__advance(%Parser* %.t53)
  br label %while_cond_24
if_next_0_32:
  br label %if_end_30
if_end_30:
  %.t56 = bitcast %Parser* %self to %Parser*
  %.p3280 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.14, i64 0, i64 0
  %.t57 = call i1 @Parser__at(%Parser* %.t56, i8* %.p3280)
  br i1 %.t57, label %sc_short_37, label %sc_rhs_36
sc_rhs_36:
  %.t58 = bitcast %Parser* %self to %Parser*
  %.p3281 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.66, i64 0, i64 0
  %.t59 = call i1 @Parser__at(%Parser* %.t58, i8* %.p3281)
  store i1 %.t59, i1* %__sc.55
  br label %sc_end_38
sc_short_37:
  store i1 true, i1* %__sc.55
  br label %sc_end_38
sc_end_38:
  %.r3282 = load i1, i1* %__sc.55
  br i1 %.r3282, label %if_then_0_34, label %if_next_0_35
if_then_0_34:
  %.t60 = bitcast %Parser* %self to %Parser*
  %.t61 = call i64 @Parser__parse_function(%Parser* %.t60)
  store i64 %.t61, i64* %f
  %.r3283 = load i64, i64* %f
  %.t62 = icmp slt i64 %.r3283, 0
  br i1 %.t62, label %if_then_0_40, label %if_next_0_41
if_then_0_40:
  %.p3284 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p3285 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 2
  store i8* %.p3284, i8** %.p3285
  %.t63 = sub i64 0, 1
  ret i64 %.t63
if_next_0_41:
  br label %if_end_39
if_end_39:
  %__fld.64 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %__fld.65 = getelementptr inbounds %Ast, %Ast* %__fld.64, i32 0, i32 0
  %.r3286 = load i64, i64* %f
  %.p3287 = getelementptr inbounds { i64, i64, %Node* }, { i64, i64, %Node* }* %__fld.65, i32 0, i32 0
  %.r3288 = load i64, i64* %.p3287
  %.r3289 = icmp slt i64 %.r3286, 0
  %.r3290 = icmp sge i64 %.r3286, %.r3288
  %.r3291 = or i1 %.r3289, %.r3290
  br i1 %.r3291, label %idx.fail.3293, label %idx.ok.3292
idx.fail.3293:
  %.p3294 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p3294, i64 %.r3286, i64 %.r3288)
  call void @exit(i32 1)
  unreachable
idx.ok.3292:
  %.p3296 = getelementptr inbounds { i64, i64, %Node* }, { i64, i64, %Node* }* %__fld.65, i32 0, i32 2
  %.p3295 = load %Node*, %Node** %.p3296
  %.p3297 = getelementptr inbounds %Node, %Node* %.p3295, i64 %.r3286
  %__elem.66 = bitcast %Node* %.p3297 to %Node*
  %.r3298 = load i8*, i8** %name
  %.p3299 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.274, i64 0, i64 0
  %.r3300 = call i64 @strlen(i8* %.r3298)
  %.r3301 = call i64 @strlen(i8* %.p3299)
  %.r3302 = add i64 %.r3300, %.r3301
  %.r3303 = add i64 %.r3302, 1
  %.t67 = call i8* @malloc(i64 %.r3303)
  call i8* @memcpy(i8* %.t67, i8* %.r3298, i64 %.r3300)
  %.p3304 = getelementptr inbounds i8, i8* %.t67, i64 %.r3300
  call i8* @memcpy(i8* %.p3304, i8* %.p3299, i64 %.r3301)
  %.p3305 = getelementptr inbounds i8, i8* %.t67, i64 %.r3302
  store i8 0, i8* %.p3305
  %__fld.68 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %__fld.69 = getelementptr inbounds %Ast, %Ast* %__fld.68, i32 0, i32 0
  %.r3306 = load i64, i64* %f
  %.p3307 = getelementptr inbounds { i64, i64, %Node* }, { i64, i64, %Node* }* %__fld.69, i32 0, i32 0
  %.r3308 = load i64, i64* %.p3307
  %.r3309 = icmp slt i64 %.r3306, 0
  %.r3310 = icmp sge i64 %.r3306, %.r3308
  %.r3311 = or i1 %.r3309, %.r3310
  br i1 %.r3311, label %idx.fail.3313, label %idx.ok.3312
idx.fail.3313:
  %.p3314 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p3314, i64 %.r3306, i64 %.r3308)
  call void @exit(i32 1)
  unreachable
idx.ok.3312:
  %.p3316 = getelementptr inbounds { i64, i64, %Node* }, { i64, i64, %Node* }* %__fld.69, i32 0, i32 2
  %.p3315 = load %Node*, %Node** %.p3316
  %.p3317 = getelementptr inbounds %Node, %Node* %.p3315, i64 %.r3306
  %__elem.70 = bitcast %Node* %.p3317 to %Node*
  %.p3318 = getelementptr inbounds %Node, %Node* %__elem.70, i32 0, i32 1
  %.t71 = load i8*, i8** %.p3318
  %.r3319 = call i64 @strlen(i8* %.t67)
  %.r3320 = call i64 @strlen(i8* %.t71)
  %.r3321 = add i64 %.r3319, %.r3320
  %.r3322 = add i64 %.r3321, 1
  %.t72 = call i8* @malloc(i64 %.r3322)
  call i8* @memcpy(i8* %.t72, i8* %.t67, i64 %.r3319)
  %.p3323 = getelementptr inbounds i8, i8* %.t72, i64 %.r3319
  call i8* @memcpy(i8* %.p3323, i8* %.t71, i64 %.r3320)
  %.p3324 = getelementptr inbounds i8, i8* %.t72, i64 %.r3321
  store i8 0, i8* %.p3324
  %.p3325 = getelementptr inbounds %Node, %Node* %__elem.66, i32 0, i32 1
  store i8* %.t72, i8** %.p3325
  %.p3326 = getelementptr i64, i64* null, i32 1
  %.r3327 = ptrtoint i64* %.p3326 to i64
  %.p3328 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %methods, i32 0, i32 0
  %.p3329 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %methods, i32 0, i32 1
  %.p3330 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %methods, i32 0, i32 2
  %.r3331 = load i64, i64* %.p3328
  %.r3332 = load i64, i64* %.p3329
  %.r3333 = icmp sge i64 %.r3331, %.r3332
  br i1 %.r3333, label %append.grow.3334, label %append.after.3335
append.grow.3334:
  %.r3336 = load i64*, i64** %.p3330
  %.r3337 = icmp eq i64 %.r3332, 0
  %.r3338 = mul i64 %.r3332, 2
  %.r3339 = select i1 %.r3337, i64 1, i64 %.r3338
  %.r3340 = mul i64 %.r3339, %.r3327
  %.p3341 = call i8* @malloc(i64 %.r3340)
  %.p3342 = bitcast i8* %.p3341 to i64*
  %.r3343 = mul i64 %.r3331, %.r3327
  %.p3344 = bitcast i64* %.r3336 to i8*
  call i8* @memcpy(i8* %.p3341, i8* %.p3344, i64 %.r3343)
  call void @free(i8* %.p3344)
  store i64* %.p3342, i64** %.p3330
  store i64 %.r3339, i64* %.p3329
  br label %append.after.3335
append.after.3335:
  %.r3345 = load i64*, i64** %.p3330
  %.r3346 = load i64, i64* %f
  %.p3347 = getelementptr inbounds i64, i64* %.r3345, i64 %.r3331
  store i64 %.r3346, i64* %.p3347
  %.r3348 = add i64 %.r3331, 1
  store i64 %.r3348, i64* %.p3328
  br label %if_end_33
if_next_0_35:
  %.t73 = bitcast %Parser* %self to %Parser*
  %.t74 = call i64 @Parser__expect_identifier(%Parser* %.t73)
  store i64 %.t74, i64* %ft
  %.r3349 = load i64, i64* %ft
  %.t75 = icmp slt i64 %.r3349, 0
  br i1 %.t75, label %if_then_0_43, label %if_next_0_44
if_then_0_43:
  %.t76 = sub i64 0, 1
  ret i64 %.t76
if_next_0_44:
  br label %if_end_42
if_end_42:
  %.t77 = bitcast %Parser* %self to %Parser*
  %.p3350 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.156, i64 0, i64 0
  %.t78 = call i64 @Parser__expect(%Parser* %.t77, i8* %.p3350)
  %.t79 = icmp slt i64 %.t78, 0
  br i1 %.t79, label %if_then_0_46, label %if_next_0_47
if_then_0_46:
  %.t80 = sub i64 0, 1
  ret i64 %.t80
if_next_0_47:
  br label %if_end_45
if_end_45:
  %.t81 = bitcast %Parser* %self to %Parser*
  %.t82 = call i64 @Parser__parse_type(%Parser* %.t81)
  store i64 %.t82, i64* %ty
  %.r3351 = load i64, i64* %ty
  %.t83 = icmp slt i64 %.r3351, 0
  br i1 %.t83, label %if_then_0_49, label %if_next_0_50
if_then_0_49:
  %.t84 = sub i64 0, 1
  ret i64 %.t84
if_next_0_50:
  br label %if_end_48
if_end_48:
  %.t85 = bitcast %Parser* %self to %Parser*
  %.p3352 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.t86 = call i64 @Parser__expect(%Parser* %.t85, i8* %.p3352)
  %.t87 = icmp slt i64 %.t86, 0
  br i1 %.t87, label %if_then_0_52, label %if_next_0_53
if_then_0_52:
  %.t88 = sub i64 0, 1
  ret i64 %.t88
if_next_0_53:
  br label %if_end_51
if_end_51:
  %__fld.89 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t90 = bitcast %Ast* %__fld.89 to %Ast*
  %.t91 = bitcast %Parser* %self to %Parser*
  %.r3353 = load i64, i64* %ft
  %.t92 = call i8* @Parser__ttext(%Parser* %.t91, i64 %.r3353)
  %.t94 = bitcast %Parser* %self to %Parser*
  %.r3354 = load i64, i64* %ft
  call void @Parser__tspan(%Span* %__agg.93, %Parser* %.t94, i64 %.r3354)
  %.t95 = bitcast %Span* %__agg.93 to %Span*
  %.p3355 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.275, i64 0, i64 0
  %.r3356 = load i64, i64* %ty
  %.t96 = call i64 @Ast__add1(%Ast* %.t90, i8* %.p3355, i8* %.t92, %Span* %.t95, i64 %.r3356)
  %.p3357 = getelementptr i64, i64* null, i32 1
  %.r3358 = ptrtoint i64* %.p3357 to i64
  %.p3359 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %fields, i32 0, i32 0
  %.p3360 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %fields, i32 0, i32 1
  %.p3361 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %fields, i32 0, i32 2
  %.r3362 = load i64, i64* %.p3359
  %.r3363 = load i64, i64* %.p3360
  %.r3364 = icmp sge i64 %.r3362, %.r3363
  br i1 %.r3364, label %append.grow.3365, label %append.after.3366
append.grow.3365:
  %.r3367 = load i64*, i64** %.p3361
  %.r3368 = icmp eq i64 %.r3363, 0
  %.r3369 = mul i64 %.r3363, 2
  %.r3370 = select i1 %.r3368, i64 1, i64 %.r3369
  %.r3371 = mul i64 %.r3370, %.r3358
  %.p3372 = call i8* @malloc(i64 %.r3371)
  %.p3373 = bitcast i8* %.p3372 to i64*
  %.r3374 = mul i64 %.r3362, %.r3358
  %.p3375 = bitcast i64* %.r3367 to i8*
  call i8* @memcpy(i8* %.p3372, i8* %.p3375, i64 %.r3374)
  call void @free(i8* %.p3375)
  store i64* %.p3373, i64** %.p3361
  store i64 %.r3370, i64* %.p3360
  br label %append.after.3366
append.after.3366:
  %.r3376 = load i64*, i64** %.p3361
  %.p3377 = getelementptr inbounds i64, i64* %.r3376, i64 %.r3362
  store i64 %.t96, i64* %.p3377
  %.r3378 = add i64 %.r3362, 1
  store i64 %.r3378, i64* %.p3359
  br label %if_end_33
if_end_33:
  br label %while_cond_24
while_end_26:
  %.p3379 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p3380 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 2
  store i8* %.p3379, i8** %.p3380
  %.t97 = bitcast %Parser* %self to %Parser*
  %.p3381 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.222, i64 0, i64 0
  %.t98 = call i64 @Parser__expect(%Parser* %.t97, i8* %.p3381)
  store i64 %.t98, i64* %et
  %.r3382 = load i64, i64* %et
  %.t99 = icmp slt i64 %.r3382, 0
  br i1 %.t99, label %if_then_0_55, label %if_next_0_56
if_then_0_55:
  %.t100 = sub i64 0, 1
  ret i64 %.t100
if_next_0_56:
  br label %if_end_54
if_end_54:
  %__fld.101 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t102 = bitcast %Ast* %__fld.101 to %Ast*
  %.t103 = bitcast %Span* %start to %Span*
  %.t104 = bitcast { i64, i64, i64* }* %fields to { i64, i64, i64* }*
  %.p3383 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.255, i64 0, i64 0
  %.p3384 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.t105 = call i64 @Ast__addl(%Ast* %.t102, i8* %.p3383, i8* %.p3384, %Span* %.t103, { i64, i64, i64* }* %.t104)
  store i64 %.t105, i64* %fl
  %.r3385 = load { i64, i64, i64* }, { i64, i64, i64* }* %methods
  %.p3386 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 5
  store { i64, i64, i64* } %.r3385, { i64, i64, i64* }* %.p3386
  %__fld.106 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t107 = bitcast %Ast* %__fld.106 to %Ast*
  %.t109 = bitcast %Span* %start to %Span*
  %.t111 = bitcast %Parser* %self to %Parser*
  %.r3387 = load i64, i64* %et
  call void @Parser__tspan(%Span* %__agg.110, %Parser* %.t111, i64 %.r3387)
  %.t112 = bitcast %Span* %__agg.110 to %Span*
  call void @span_to(%Span* %__agg.108, %Span* %.t109, %Span* %.t112)
  %.t113 = bitcast %Span* %__agg.108 to %Span*
  %.p3388 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.276, i64 0, i64 0
  %.r3389 = load i8*, i8** %name
  %.r3390 = load i64, i64* %base
  %.r3391 = load i64, i64* %fl
  %.t114 = call i64 @Ast__add2(%Ast* %.t107, i8* %.p3388, i8* %.r3389, %Span* %.t113, i64 %.r3390, i64 %.r3391)
  ret i64 %.t114
}

define i64 @Parser__parse_struct_def(%Parser* %self) {
entry:
  %st = alloca i64
  %start = alloca %Span
  %nt = alloca i64
  %name = alloca i8*
  %fields = alloca { i64, i64, i64* }
  %__sc.23 = alloca i1
  %ft = alloca i64
  %ty = alloca i64
  %__agg.54 = alloca %Span
  %et = alloca i64
  %fl = alloca i64
  %__agg.71 = alloca %Span
  %__agg.69 = alloca %Span
  %.t0 = bitcast %Parser* %self to %Parser*
  %.p3392 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.54, i64 0, i64 0
  %.t1 = call i64 @Parser__expect(%Parser* %.t0, i8* %.p3392)
  store i64 %.t1, i64* %st
  %.r3393 = load i64, i64* %st
  %.t2 = icmp slt i64 %.r3393, 0
  br i1 %.t2, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t3 = sub i64 0, 1
  ret i64 %.t3
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.t4 = bitcast %Parser* %self to %Parser*
  %.r3394 = load i64, i64* %st
  call void @Parser__tspan(%Span* %start, %Parser* %.t4, i64 %.r3394)
  %.t5 = bitcast %Parser* %self to %Parser*
  %.t6 = call i64 @Parser__expect_identifier(%Parser* %.t5)
  store i64 %.t6, i64* %nt
  %.r3395 = load i64, i64* %nt
  %.t7 = icmp slt i64 %.r3395, 0
  br i1 %.t7, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.t8 = sub i64 0, 1
  ret i64 %.t8
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.t9 = bitcast %Parser* %self to %Parser*
  %.r3396 = load i64, i64* %nt
  %.t10 = call i8* @Parser__ttext(%Parser* %.t9, i64 %.r3396)
  store i8* %.t10, i8** %name
  %.t11 = bitcast %Parser* %self to %Parser*
  %.p3397 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.156, i64 0, i64 0
  %.t12 = call i64 @Parser__expect(%Parser* %.t11, i8* %.p3397)
  %.t13 = icmp slt i64 %.t12, 0
  br i1 %.t13, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.t14 = sub i64 0, 1
  ret i64 %.t14
if_next_0_8:
  br label %if_end_6
if_end_6:
  %.t15 = bitcast %Parser* %self to %Parser*
  %.p3398 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.t16 = call i64 @Parser__expect(%Parser* %.t15, i8* %.p3398)
  %.t17 = icmp slt i64 %.t16, 0
  br i1 %.t17, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.t18 = sub i64 0, 1
  ret i64 %.t18
if_next_0_11:
  br label %if_end_9
if_end_9:
  %.t19 = bitcast %Parser* %self to %Parser*
  %.p3399 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.220, i64 0, i64 0
  %.t20 = call i64 @Parser__expect(%Parser* %.t19, i8* %.p3399)
  %.t21 = icmp slt i64 %.t20, 0
  br i1 %.t21, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  %.t22 = sub i64 0, 1
  ret i64 %.t22
if_next_0_14:
  br label %if_end_12
if_end_12:
  %.p3401 = getelementptr i64, i64* null, i32 1
  %.r3402 = ptrtoint i64* %.p3401 to i64
  %.r3403 = mul i64 %.r3402, 1
  %.p3400 = call i8* @malloc(i64 %.r3403)
  %.p3404 = bitcast i8* %.p3400 to i64*
  %.p3405 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %fields, i32 0, i32 0
  store i64 0, i64* %.p3405
  %.p3406 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %fields, i32 0, i32 1
  store i64 0, i64* %.p3406
  %.p3407 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %fields, i32 0, i32 2
  store i64* %.p3404, i64** %.p3407
  br label %while_cond_15
while_cond_15:
  %.t24 = bitcast %Parser* %self to %Parser*
  %.p3408 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.222, i64 0, i64 0
  %.t25 = call i1 @Parser__at(%Parser* %.t24, i8* %.p3408)
  %.t26 = xor i1 %.t25, true
  br i1 %.t26, label %sc_rhs_18, label %sc_short_19
sc_rhs_18:
  %.t27 = bitcast %Parser* %self to %Parser*
  %.p3409 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.224, i64 0, i64 0
  %.t28 = call i1 @Parser__at(%Parser* %.t27, i8* %.p3409)
  %.t29 = xor i1 %.t28, true
  store i1 %.t29, i1* %__sc.23
  br label %sc_end_20
sc_short_19:
  store i1 false, i1* %__sc.23
  br label %sc_end_20
sc_end_20:
  %.r3410 = load i1, i1* %__sc.23
  br i1 %.r3410, label %while_body_16, label %while_end_17
while_body_16:
  %.t30 = bitcast %Parser* %self to %Parser*
  %.p3411 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.t31 = call i1 @Parser__at(%Parser* %.t30, i8* %.p3411)
  br i1 %.t31, label %if_then_0_22, label %if_next_0_23
if_then_0_22:
  %.t32 = bitcast %Parser* %self to %Parser*
  %.t33 = call i64 @Parser__advance(%Parser* %.t32)
  br label %while_cond_15
if_next_0_23:
  br label %if_end_21
if_end_21:
  %.t34 = bitcast %Parser* %self to %Parser*
  %.t35 = call i64 @Parser__expect_identifier(%Parser* %.t34)
  store i64 %.t35, i64* %ft
  %.r3412 = load i64, i64* %ft
  %.t36 = icmp slt i64 %.r3412, 0
  br i1 %.t36, label %if_then_0_25, label %if_next_0_26
if_then_0_25:
  %.t37 = sub i64 0, 1
  ret i64 %.t37
if_next_0_26:
  br label %if_end_24
if_end_24:
  %.t38 = bitcast %Parser* %self to %Parser*
  %.p3413 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.156, i64 0, i64 0
  %.t39 = call i64 @Parser__expect(%Parser* %.t38, i8* %.p3413)
  %.t40 = icmp slt i64 %.t39, 0
  br i1 %.t40, label %if_then_0_28, label %if_next_0_29
if_then_0_28:
  %.t41 = sub i64 0, 1
  ret i64 %.t41
if_next_0_29:
  br label %if_end_27
if_end_27:
  %.t42 = bitcast %Parser* %self to %Parser*
  %.t43 = call i64 @Parser__parse_type(%Parser* %.t42)
  store i64 %.t43, i64* %ty
  %.r3414 = load i64, i64* %ty
  %.t44 = icmp slt i64 %.r3414, 0
  br i1 %.t44, label %if_then_0_31, label %if_next_0_32
if_then_0_31:
  %.t45 = sub i64 0, 1
  ret i64 %.t45
if_next_0_32:
  br label %if_end_30
if_end_30:
  %.t46 = bitcast %Parser* %self to %Parser*
  %.p3415 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.t47 = call i64 @Parser__expect(%Parser* %.t46, i8* %.p3415)
  %.t48 = icmp slt i64 %.t47, 0
  br i1 %.t48, label %if_then_0_34, label %if_next_0_35
if_then_0_34:
  %.t49 = sub i64 0, 1
  ret i64 %.t49
if_next_0_35:
  br label %if_end_33
if_end_33:
  %__fld.50 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t51 = bitcast %Ast* %__fld.50 to %Ast*
  %.t52 = bitcast %Parser* %self to %Parser*
  %.r3416 = load i64, i64* %ft
  %.t53 = call i8* @Parser__ttext(%Parser* %.t52, i64 %.r3416)
  %.t55 = bitcast %Parser* %self to %Parser*
  %.r3417 = load i64, i64* %ft
  call void @Parser__tspan(%Span* %__agg.54, %Parser* %.t55, i64 %.r3417)
  %.t56 = bitcast %Span* %__agg.54 to %Span*
  %.p3418 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.275, i64 0, i64 0
  %.r3419 = load i64, i64* %ty
  %.t57 = call i64 @Ast__add1(%Ast* %.t51, i8* %.p3418, i8* %.t53, %Span* %.t56, i64 %.r3419)
  %.p3420 = getelementptr i64, i64* null, i32 1
  %.r3421 = ptrtoint i64* %.p3420 to i64
  %.p3422 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %fields, i32 0, i32 0
  %.p3423 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %fields, i32 0, i32 1
  %.p3424 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %fields, i32 0, i32 2
  %.r3425 = load i64, i64* %.p3422
  %.r3426 = load i64, i64* %.p3423
  %.r3427 = icmp sge i64 %.r3425, %.r3426
  br i1 %.r3427, label %append.grow.3428, label %append.after.3429
append.grow.3428:
  %.r3430 = load i64*, i64** %.p3424
  %.r3431 = icmp eq i64 %.r3426, 0
  %.r3432 = mul i64 %.r3426, 2
  %.r3433 = select i1 %.r3431, i64 1, i64 %.r3432
  %.r3434 = mul i64 %.r3433, %.r3421
  %.p3435 = call i8* @malloc(i64 %.r3434)
  %.p3436 = bitcast i8* %.p3435 to i64*
  %.r3437 = mul i64 %.r3425, %.r3421
  %.p3438 = bitcast i64* %.r3430 to i8*
  call i8* @memcpy(i8* %.p3435, i8* %.p3438, i64 %.r3437)
  call void @free(i8* %.p3438)
  store i64* %.p3436, i64** %.p3424
  store i64 %.r3433, i64* %.p3423
  br label %append.after.3429
append.after.3429:
  %.r3439 = load i64*, i64** %.p3424
  %.p3440 = getelementptr inbounds i64, i64* %.r3439, i64 %.r3425
  store i64 %.t57, i64* %.p3440
  %.r3441 = add i64 %.r3425, 1
  store i64 %.r3441, i64* %.p3422
  br label %while_cond_15
while_end_17:
  %.t58 = bitcast %Parser* %self to %Parser*
  %.p3442 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.222, i64 0, i64 0
  %.t59 = call i64 @Parser__expect(%Parser* %.t58, i8* %.p3442)
  store i64 %.t59, i64* %et
  %.r3443 = load i64, i64* %et
  %.t60 = icmp slt i64 %.r3443, 0
  br i1 %.t60, label %if_then_0_37, label %if_next_0_38
if_then_0_37:
  %.t61 = sub i64 0, 1
  ret i64 %.t61
if_next_0_38:
  br label %if_end_36
if_end_36:
  %__fld.62 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t63 = bitcast %Ast* %__fld.62 to %Ast*
  %.t64 = bitcast %Span* %start to %Span*
  %.t65 = bitcast { i64, i64, i64* }* %fields to { i64, i64, i64* }*
  %.p3444 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.255, i64 0, i64 0
  %.p3445 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.t66 = call i64 @Ast__addl(%Ast* %.t63, i8* %.p3444, i8* %.p3445, %Span* %.t64, { i64, i64, i64* }* %.t65)
  store i64 %.t66, i64* %fl
  %__fld.67 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t68 = bitcast %Ast* %__fld.67 to %Ast*
  %.t70 = bitcast %Span* %start to %Span*
  %.t72 = bitcast %Parser* %self to %Parser*
  %.r3446 = load i64, i64* %et
  call void @Parser__tspan(%Span* %__agg.71, %Parser* %.t72, i64 %.r3446)
  %.t73 = bitcast %Span* %__agg.71 to %Span*
  call void @span_to(%Span* %__agg.69, %Span* %.t70, %Span* %.t73)
  %.t74 = bitcast %Span* %__agg.69 to %Span*
  %.t75 = sub i64 0, 1
  %.p3447 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.276, i64 0, i64 0
  %.r3448 = load i8*, i8** %name
  %.r3449 = load i64, i64* %fl
  %.t76 = call i64 @Ast__add2(%Ast* %.t68, i8* %.p3447, i8* %.r3448, %Span* %.t74, i64 %.t75, i64 %.r3449)
  ret i64 %.t76
}

define i64 @Parser__parse_enum_def(%Parser* %self) {
entry:
  %st = alloca i64
  %start = alloca %Span
  %nt = alloca i64
  %name = alloca i8*
  %variants = alloca { i64, i64, i64* }
  %__sc.23 = alloca i1
  %vt = alloca i64
  %vfields = alloca { i64, i64, i64* }
  %__sc.42 = alloca i1
  %n = alloca i64
  %ty = alloca i64
  %__agg.60 = alloca %Span
  %__agg.73 = alloca %Span
  %__agg.94 = alloca %Span
  %et = alloca i64
  %__agg.104 = alloca %Span
  %span = alloca %Span
  %vl = alloca i64
  %.t0 = bitcast %Parser* %self to %Parser*
  %.p3450 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.62, i64 0, i64 0
  %.t1 = call i64 @Parser__expect(%Parser* %.t0, i8* %.p3450)
  store i64 %.t1, i64* %st
  %.r3451 = load i64, i64* %st
  %.t2 = icmp slt i64 %.r3451, 0
  br i1 %.t2, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t3 = sub i64 0, 1
  ret i64 %.t3
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.t4 = bitcast %Parser* %self to %Parser*
  %.r3452 = load i64, i64* %st
  call void @Parser__tspan(%Span* %start, %Parser* %.t4, i64 %.r3452)
  %.t5 = bitcast %Parser* %self to %Parser*
  %.t6 = call i64 @Parser__expect_identifier(%Parser* %.t5)
  store i64 %.t6, i64* %nt
  %.r3453 = load i64, i64* %nt
  %.t7 = icmp slt i64 %.r3453, 0
  br i1 %.t7, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.t8 = sub i64 0, 1
  ret i64 %.t8
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.t9 = bitcast %Parser* %self to %Parser*
  %.r3454 = load i64, i64* %nt
  %.t10 = call i8* @Parser__ttext(%Parser* %.t9, i64 %.r3454)
  store i8* %.t10, i8** %name
  %.t11 = bitcast %Parser* %self to %Parser*
  %.p3455 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.156, i64 0, i64 0
  %.t12 = call i64 @Parser__expect(%Parser* %.t11, i8* %.p3455)
  %.t13 = icmp slt i64 %.t12, 0
  br i1 %.t13, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.t14 = sub i64 0, 1
  ret i64 %.t14
if_next_0_8:
  br label %if_end_6
if_end_6:
  %.t15 = bitcast %Parser* %self to %Parser*
  %.p3456 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.t16 = call i64 @Parser__expect(%Parser* %.t15, i8* %.p3456)
  %.t17 = icmp slt i64 %.t16, 0
  br i1 %.t17, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.t18 = sub i64 0, 1
  ret i64 %.t18
if_next_0_11:
  br label %if_end_9
if_end_9:
  %.t19 = bitcast %Parser* %self to %Parser*
  %.p3457 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.220, i64 0, i64 0
  %.t20 = call i64 @Parser__expect(%Parser* %.t19, i8* %.p3457)
  %.t21 = icmp slt i64 %.t20, 0
  br i1 %.t21, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  %.t22 = sub i64 0, 1
  ret i64 %.t22
if_next_0_14:
  br label %if_end_12
if_end_12:
  %.p3459 = getelementptr i64, i64* null, i32 1
  %.r3460 = ptrtoint i64* %.p3459 to i64
  %.r3461 = mul i64 %.r3460, 1
  %.p3458 = call i8* @malloc(i64 %.r3461)
  %.p3462 = bitcast i8* %.p3458 to i64*
  %.p3463 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %variants, i32 0, i32 0
  store i64 0, i64* %.p3463
  %.p3464 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %variants, i32 0, i32 1
  store i64 0, i64* %.p3464
  %.p3465 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %variants, i32 0, i32 2
  store i64* %.p3462, i64** %.p3465
  br label %while_cond_15
while_cond_15:
  %.t24 = bitcast %Parser* %self to %Parser*
  %.p3466 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.222, i64 0, i64 0
  %.t25 = call i1 @Parser__at(%Parser* %.t24, i8* %.p3466)
  %.t26 = xor i1 %.t25, true
  br i1 %.t26, label %sc_rhs_18, label %sc_short_19
sc_rhs_18:
  %.t27 = bitcast %Parser* %self to %Parser*
  %.p3467 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.224, i64 0, i64 0
  %.t28 = call i1 @Parser__at(%Parser* %.t27, i8* %.p3467)
  %.t29 = xor i1 %.t28, true
  store i1 %.t29, i1* %__sc.23
  br label %sc_end_20
sc_short_19:
  store i1 false, i1* %__sc.23
  br label %sc_end_20
sc_end_20:
  %.r3468 = load i1, i1* %__sc.23
  br i1 %.r3468, label %while_body_16, label %while_end_17
while_body_16:
  %.t30 = bitcast %Parser* %self to %Parser*
  %.p3469 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.t31 = call i1 @Parser__at(%Parser* %.t30, i8* %.p3469)
  br i1 %.t31, label %if_then_0_22, label %if_next_0_23
if_then_0_22:
  %.t32 = bitcast %Parser* %self to %Parser*
  %.t33 = call i64 @Parser__advance(%Parser* %.t32)
  br label %while_cond_15
if_next_0_23:
  br label %if_end_21
if_end_21:
  %.t34 = bitcast %Parser* %self to %Parser*
  %.t35 = call i64 @Parser__expect_identifier(%Parser* %.t34)
  store i64 %.t35, i64* %vt
  %.r3470 = load i64, i64* %vt
  %.t36 = icmp slt i64 %.r3470, 0
  br i1 %.t36, label %if_then_0_25, label %if_next_0_26
if_then_0_25:
  %.t37 = sub i64 0, 1
  ret i64 %.t37
if_next_0_26:
  br label %if_end_24
if_end_24:
  %.p3472 = getelementptr i64, i64* null, i32 1
  %.r3473 = ptrtoint i64* %.p3472 to i64
  %.r3474 = mul i64 %.r3473, 1
  %.p3471 = call i8* @malloc(i64 %.r3474)
  %.p3475 = bitcast i8* %.p3471 to i64*
  %.p3476 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %vfields, i32 0, i32 0
  store i64 0, i64* %.p3476
  %.p3477 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %vfields, i32 0, i32 1
  store i64 0, i64* %.p3477
  %.p3478 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %vfields, i32 0, i32 2
  store i64* %.p3475, i64** %.p3478
  %.t38 = bitcast %Parser* %self to %Parser*
  %.p3479 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.142, i64 0, i64 0
  %.t39 = call i1 @Parser__at(%Parser* %.t38, i8* %.p3479)
  br i1 %.t39, label %if_then_0_28, label %if_next_0_29
if_then_0_28:
  %.t40 = bitcast %Parser* %self to %Parser*
  %.t41 = call i64 @Parser__advance(%Parser* %.t40)
  br label %while_cond_30
while_cond_30:
  br i1 true, label %while_body_31, label %while_end_32
while_body_31:
  %.t43 = bitcast %Parser* %self to %Parser*
  %.p3480 = getelementptr inbounds [11 x i8], [11 x i8]* @.str.101, i64 0, i64 0
  %.t44 = call i1 @Parser__at(%Parser* %.t43, i8* %.p3480)
  br i1 %.t44, label %sc_rhs_36, label %sc_short_37
sc_rhs_36:
  %.t45 = bitcast %Parser* %self to %Parser*
  %.t46 = call i8* @Parser__peek_at(%Parser* %.t45, i64 1)
  %.p3481 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.156, i64 0, i64 0
  %.r3482 = call i32 @strcmp(i8* %.t46, i8* %.p3481)
  %.t47 = icmp eq i32 %.r3482, 0
  store i1 %.t47, i1* %__sc.42
  br label %sc_end_38
sc_short_37:
  store i1 false, i1* %__sc.42
  br label %sc_end_38
sc_end_38:
  %.r3483 = load i1, i1* %__sc.42
  br i1 %.r3483, label %if_then_0_34, label %if_next_0_35
if_then_0_34:
  %.t48 = bitcast %Parser* %self to %Parser*
  %.t49 = call i64 @Parser__expect_identifier(%Parser* %.t48)
  store i64 %.t49, i64* %n
  %.t50 = bitcast %Parser* %self to %Parser*
  %.t51 = call i64 @Parser__advance(%Parser* %.t50)
  %.t52 = bitcast %Parser* %self to %Parser*
  %.t53 = call i64 @Parser__parse_type(%Parser* %.t52)
  store i64 %.t53, i64* %ty
  %.r3484 = load i64, i64* %ty
  %.t54 = icmp slt i64 %.r3484, 0
  br i1 %.t54, label %if_then_0_40, label %if_next_0_41
if_then_0_40:
  %.t55 = sub i64 0, 1
  ret i64 %.t55
if_next_0_41:
  br label %if_end_39
if_end_39:
  %__fld.56 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t57 = bitcast %Ast* %__fld.56 to %Ast*
  %.t58 = bitcast %Parser* %self to %Parser*
  %.r3485 = load i64, i64* %n
  %.t59 = call i8* @Parser__ttext(%Parser* %.t58, i64 %.r3485)
  %.t61 = bitcast %Parser* %self to %Parser*
  %.r3486 = load i64, i64* %n
  call void @Parser__tspan(%Span* %__agg.60, %Parser* %.t61, i64 %.r3486)
  %.t62 = bitcast %Span* %__agg.60 to %Span*
  %.p3487 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.260, i64 0, i64 0
  %.r3488 = load i64, i64* %ty
  %.t63 = call i64 @Ast__add1(%Ast* %.t57, i8* %.p3487, i8* %.t59, %Span* %.t62, i64 %.r3488)
  %.p3489 = getelementptr i64, i64* null, i32 1
  %.r3490 = ptrtoint i64* %.p3489 to i64
  %.p3491 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %vfields, i32 0, i32 0
  %.p3492 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %vfields, i32 0, i32 1
  %.p3493 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %vfields, i32 0, i32 2
  %.r3494 = load i64, i64* %.p3491
  %.r3495 = load i64, i64* %.p3492
  %.r3496 = icmp sge i64 %.r3494, %.r3495
  br i1 %.r3496, label %append.grow.3497, label %append.after.3498
append.grow.3497:
  %.r3499 = load i64*, i64** %.p3493
  %.r3500 = icmp eq i64 %.r3495, 0
  %.r3501 = mul i64 %.r3495, 2
  %.r3502 = select i1 %.r3500, i64 1, i64 %.r3501
  %.r3503 = mul i64 %.r3502, %.r3490
  %.p3504 = call i8* @malloc(i64 %.r3503)
  %.p3505 = bitcast i8* %.p3504 to i64*
  %.r3506 = mul i64 %.r3494, %.r3490
  %.p3507 = bitcast i64* %.r3499 to i8*
  call i8* @memcpy(i8* %.p3504, i8* %.p3507, i64 %.r3506)
  call void @free(i8* %.p3507)
  store i64* %.p3505, i64** %.p3493
  store i64 %.r3502, i64* %.p3492
  br label %append.after.3498
append.after.3498:
  %.r3508 = load i64*, i64** %.p3493
  %.p3509 = getelementptr inbounds i64, i64* %.r3508, i64 %.r3494
  store i64 %.t63, i64* %.p3509
  %.r3510 = add i64 %.r3494, 1
  store i64 %.r3510, i64* %.p3491
  br label %if_end_33
if_next_0_35:
  %.t64 = bitcast %Parser* %self to %Parser*
  %.t65 = call i64 @Parser__parse_type(%Parser* %.t64)
  store i64 %.t65, i64* %ty
  %.r3511 = load i64, i64* %ty
  %.t66 = icmp slt i64 %.r3511, 0
  br i1 %.t66, label %if_then_0_43, label %if_next_0_44
if_then_0_43:
  %.t67 = sub i64 0, 1
  ret i64 %.t67
if_next_0_44:
  br label %if_end_42
if_end_42:
  %__fld.68 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t69 = bitcast %Ast* %__fld.68 to %Ast*
  %.p3512 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %vfields, i32 0, i32 0
  %.t70 = load i64, i64* %.p3512
  %.p3513 = call i8* @malloc(i64 32)
  %.p3514 = getelementptr inbounds [5 x i8], [5 x i8]* @.fmt.int.raw, i64 0, i64 0
  call i32 (i8*, i64, i8*, ...) @snprintf(i8* %.p3513, i64 32, i8* %.p3514, i64 %.t70)
  %.t71 = bitcast i8* %.p3513 to i8*
  %.p3515 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.277, i64 0, i64 0
  %.r3516 = call i64 @strlen(i8* %.p3515)
  %.r3517 = call i64 @strlen(i8* %.t71)
  %.r3518 = add i64 %.r3516, %.r3517
  %.r3519 = add i64 %.r3518, 1
  %.t72 = call i8* @malloc(i64 %.r3519)
  call i8* @memcpy(i8* %.t72, i8* %.p3515, i64 %.r3516)
  %.p3520 = getelementptr inbounds i8, i8* %.t72, i64 %.r3516
  call i8* @memcpy(i8* %.p3520, i8* %.t71, i64 %.r3517)
  %.p3521 = getelementptr inbounds i8, i8* %.t72, i64 %.r3518
  store i8 0, i8* %.p3521
  %__fld.74 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t75 = bitcast %Ast* %__fld.74 to %Ast*
  %.r3522 = load i64, i64* %ty
  call void @Ast__span_of(%Span* %__agg.73, %Ast* %.t75, i64 %.r3522)
  %.t76 = bitcast %Span* %__agg.73 to %Span*
  %.p3523 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.260, i64 0, i64 0
  %.r3524 = load i64, i64* %ty
  %.t77 = call i64 @Ast__add1(%Ast* %.t69, i8* %.p3523, i8* %.t72, %Span* %.t76, i64 %.r3524)
  %.p3525 = getelementptr i64, i64* null, i32 1
  %.r3526 = ptrtoint i64* %.p3525 to i64
  %.p3527 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %vfields, i32 0, i32 0
  %.p3528 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %vfields, i32 0, i32 1
  %.p3529 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %vfields, i32 0, i32 2
  %.r3530 = load i64, i64* %.p3527
  %.r3531 = load i64, i64* %.p3528
  %.r3532 = icmp sge i64 %.r3530, %.r3531
  br i1 %.r3532, label %append.grow.3533, label %append.after.3534
append.grow.3533:
  %.r3535 = load i64*, i64** %.p3529
  %.r3536 = icmp eq i64 %.r3531, 0
  %.r3537 = mul i64 %.r3531, 2
  %.r3538 = select i1 %.r3536, i64 1, i64 %.r3537
  %.r3539 = mul i64 %.r3538, %.r3526
  %.p3540 = call i8* @malloc(i64 %.r3539)
  %.p3541 = bitcast i8* %.p3540 to i64*
  %.r3542 = mul i64 %.r3530, %.r3526
  %.p3543 = bitcast i64* %.r3535 to i8*
  call i8* @memcpy(i8* %.p3540, i8* %.p3543, i64 %.r3542)
  call void @free(i8* %.p3543)
  store i64* %.p3541, i64** %.p3529
  store i64 %.r3538, i64* %.p3528
  br label %append.after.3534
append.after.3534:
  %.r3544 = load i64*, i64** %.p3529
  %.p3545 = getelementptr inbounds i64, i64* %.r3544, i64 %.r3530
  store i64 %.t77, i64* %.p3545
  %.r3546 = add i64 %.r3530, 1
  store i64 %.r3546, i64* %.p3527
  br label %if_end_33
if_end_33:
  %.t78 = bitcast %Parser* %self to %Parser*
  %.p3547 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.154, i64 0, i64 0
  %.t79 = call i1 @Parser__at(%Parser* %.t78, i8* %.p3547)
  br i1 %.t79, label %if_then_0_46, label %if_next_0_47
if_then_0_46:
  %.t80 = bitcast %Parser* %self to %Parser*
  %.t81 = call i64 @Parser__advance(%Parser* %.t80)
  br label %if_end_45
if_next_0_47:
  br label %while_end_32
if_end_45:
  br label %while_cond_30
while_end_32:
  %.t82 = bitcast %Parser* %self to %Parser*
  %.p3548 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.144, i64 0, i64 0
  %.t83 = call i64 @Parser__expect(%Parser* %.t82, i8* %.p3548)
  %.t84 = icmp slt i64 %.t83, 0
  br i1 %.t84, label %if_then_0_49, label %if_next_0_50
if_then_0_49:
  %.t85 = sub i64 0, 1
  ret i64 %.t85
if_next_0_50:
  br label %if_end_48
if_end_48:
  br label %if_end_27
if_next_0_29:
  br label %if_end_27
if_end_27:
  %.t86 = bitcast %Parser* %self to %Parser*
  %.p3549 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.t87 = call i64 @Parser__expect(%Parser* %.t86, i8* %.p3549)
  %.t88 = icmp slt i64 %.t87, 0
  br i1 %.t88, label %if_then_0_52, label %if_next_0_53
if_then_0_52:
  %.t89 = sub i64 0, 1
  ret i64 %.t89
if_next_0_53:
  br label %if_end_51
if_end_51:
  %__fld.90 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t91 = bitcast %Ast* %__fld.90 to %Ast*
  %.t92 = bitcast %Parser* %self to %Parser*
  %.r3550 = load i64, i64* %vt
  %.t93 = call i8* @Parser__ttext(%Parser* %.t92, i64 %.r3550)
  %.t95 = bitcast %Parser* %self to %Parser*
  %.r3551 = load i64, i64* %vt
  call void @Parser__tspan(%Span* %__agg.94, %Parser* %.t95, i64 %.r3551)
  %.t96 = bitcast %Span* %__agg.94 to %Span*
  %.t97 = bitcast { i64, i64, i64* }* %vfields to { i64, i64, i64* }*
  %.p3552 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.278, i64 0, i64 0
  %.t98 = call i64 @Ast__addl(%Ast* %.t91, i8* %.p3552, i8* %.t93, %Span* %.t96, { i64, i64, i64* }* %.t97)
  %.p3553 = getelementptr i64, i64* null, i32 1
  %.r3554 = ptrtoint i64* %.p3553 to i64
  %.p3555 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %variants, i32 0, i32 0
  %.p3556 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %variants, i32 0, i32 1
  %.p3557 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %variants, i32 0, i32 2
  %.r3558 = load i64, i64* %.p3555
  %.r3559 = load i64, i64* %.p3556
  %.r3560 = icmp sge i64 %.r3558, %.r3559
  br i1 %.r3560, label %append.grow.3561, label %append.after.3562
append.grow.3561:
  %.r3563 = load i64*, i64** %.p3557
  %.r3564 = icmp eq i64 %.r3559, 0
  %.r3565 = mul i64 %.r3559, 2
  %.r3566 = select i1 %.r3564, i64 1, i64 %.r3565
  %.r3567 = mul i64 %.r3566, %.r3554
  %.p3568 = call i8* @malloc(i64 %.r3567)
  %.p3569 = bitcast i8* %.p3568 to i64*
  %.r3570 = mul i64 %.r3558, %.r3554
  %.p3571 = bitcast i64* %.r3563 to i8*
  call i8* @memcpy(i8* %.p3568, i8* %.p3571, i64 %.r3570)
  call void @free(i8* %.p3571)
  store i64* %.p3569, i64** %.p3557
  store i64 %.r3566, i64* %.p3556
  br label %append.after.3562
append.after.3562:
  %.r3572 = load i64*, i64** %.p3557
  %.p3573 = getelementptr inbounds i64, i64* %.r3572, i64 %.r3558
  store i64 %.t98, i64* %.p3573
  %.r3574 = add i64 %.r3558, 1
  store i64 %.r3574, i64* %.p3555
  br label %while_cond_15
while_end_17:
  %.t99 = bitcast %Parser* %self to %Parser*
  %.p3575 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.222, i64 0, i64 0
  %.t100 = call i64 @Parser__expect(%Parser* %.t99, i8* %.p3575)
  store i64 %.t100, i64* %et
  %.r3576 = load i64, i64* %et
  %.t101 = icmp slt i64 %.r3576, 0
  br i1 %.t101, label %if_then_0_55, label %if_next_0_56
if_then_0_55:
  %.t102 = sub i64 0, 1
  ret i64 %.t102
if_next_0_56:
  br label %if_end_54
if_end_54:
  %.t103 = bitcast %Span* %start to %Span*
  %.t105 = bitcast %Parser* %self to %Parser*
  %.r3577 = load i64, i64* %et
  call void @Parser__tspan(%Span* %__agg.104, %Parser* %.t105, i64 %.r3577)
  %.t106 = bitcast %Span* %__agg.104 to %Span*
  call void @span_to(%Span* %span, %Span* %.t103, %Span* %.t106)
  %.p3578 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %variants, i32 0, i32 0
  %.t107 = load i64, i64* %.p3578
  %.t108 = icmp eq i64 %.t107, 0
  br i1 %.t108, label %if_then_0_58, label %if_next_0_59
if_then_0_58:
  %__fld.109 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 3
  %.t110 = bitcast %Diags* %__fld.109 to %Diags*
  %.p3579 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.279, i64 0, i64 0
  %.r3580 = load i8*, i8** %name
  %.r3581 = call i64 @strlen(i8* %.p3579)
  %.r3582 = call i64 @strlen(i8* %.r3580)
  %.r3583 = add i64 %.r3581, %.r3582
  %.r3584 = add i64 %.r3583, 1
  %.t111 = call i8* @malloc(i64 %.r3584)
  call i8* @memcpy(i8* %.t111, i8* %.p3579, i64 %.r3581)
  %.p3585 = getelementptr inbounds i8, i8* %.t111, i64 %.r3581
  call i8* @memcpy(i8* %.p3585, i8* %.r3580, i64 %.r3582)
  %.p3586 = getelementptr inbounds i8, i8* %.t111, i64 %.r3583
  store i8 0, i8* %.p3586
  %.p3587 = getelementptr inbounds [18 x i8], [18 x i8]* @.str.280, i64 0, i64 0
  %.r3588 = call i64 @strlen(i8* %.t111)
  %.r3589 = call i64 @strlen(i8* %.p3587)
  %.r3590 = add i64 %.r3588, %.r3589
  %.r3591 = add i64 %.r3590, 1
  %.t112 = call i8* @malloc(i64 %.r3591)
  call i8* @memcpy(i8* %.t112, i8* %.t111, i64 %.r3588)
  %.p3592 = getelementptr inbounds i8, i8* %.t112, i64 %.r3588
  call i8* @memcpy(i8* %.p3592, i8* %.p3587, i64 %.r3589)
  %.p3593 = getelementptr inbounds i8, i8* %.t112, i64 %.r3590
  store i8 0, i8* %.p3593
  %.t113 = bitcast %Span* %span to %Span*
  %.p3594 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.281, i64 0, i64 0
  %.p3595 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p3596 = getelementptr inbounds [85 x i8], [85 x i8]* @.str.282, i64 0, i64 0
  call void @Diags__add(%Diags* %.t110, i8* %.p3594, i8* %.t112, %Span* %.t113, i8* %.p3595, i8* %.p3596)
  br label %if_end_57
if_next_0_59:
  br label %if_end_57
if_end_57:
  %__fld.114 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t115 = bitcast %Ast* %__fld.114 to %Ast*
  %.t116 = bitcast %Span* %start to %Span*
  %.t117 = bitcast { i64, i64, i64* }* %variants to { i64, i64, i64* }*
  %.p3597 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.255, i64 0, i64 0
  %.p3598 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.t118 = call i64 @Ast__addl(%Ast* %.t115, i8* %.p3597, i8* %.p3598, %Span* %.t116, { i64, i64, i64* }* %.t117)
  store i64 %.t118, i64* %vl
  %__fld.119 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t120 = bitcast %Ast* %__fld.119 to %Ast*
  %.t121 = bitcast %Span* %span to %Span*
  %.p3599 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.62, i64 0, i64 0
  %.r3600 = load i8*, i8** %name
  %.r3601 = load i64, i64* %vl
  %.t122 = call i64 @Ast__add1(%Ast* %.t120, i8* %.p3599, i8* %.r3600, %Span* %.t121, i64 %.r3601)
  ret i64 %.t122
}

define i64 @Parser__parse_type(%Parser* %self) {
entry:
  %span = alloca %Span
  %k = alloca i8*
  %inner = alloca i64
  %t = alloca i64
  %elem = alloca i64
  %first = alloca i64
  %text = alloca i8*
  %nxt = alloca i64
  %.t0 = bitcast %Parser* %self to %Parser*
  call void @Parser__peek_span(%Span* %span, %Parser* %.t0)
  %.t1 = bitcast %Parser* %self to %Parser*
  %.t2 = call i8* @Parser__peek(%Parser* %.t1)
  store i8* %.t2, i8** %k
  %.r3602 = load i8*, i8** %k
  %.p3603 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.80, i64 0, i64 0
  %.r3604 = call i32 @strcmp(i8* %.r3602, i8* %.p3603)
  %.t3 = icmp eq i32 %.r3604, 0
  br i1 %.t3, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t4 = bitcast %Parser* %self to %Parser*
  %.t5 = call i64 @Parser__advance(%Parser* %.t4)
  %__fld.6 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t7 = bitcast %Ast* %__fld.6 to %Ast*
  %.t8 = bitcast %Span* %span to %Span*
  %.p3605 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.54, i64 0, i64 0
  %.p3606 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.79, i64 0, i64 0
  %.t9 = call i64 @Ast__add0(%Ast* %.t7, i8* %.p3605, i8* %.p3606, %Span* %.t8)
  ret i64 %.t9
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.r3607 = load i8*, i8** %k
  %.p3608 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.82, i64 0, i64 0
  %.r3609 = call i32 @strcmp(i8* %.r3607, i8* %.p3608)
  %.t10 = icmp eq i32 %.r3609, 0
  br i1 %.t10, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.t11 = bitcast %Parser* %self to %Parser*
  %.t12 = call i64 @Parser__advance(%Parser* %.t11)
  %__fld.13 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t14 = bitcast %Ast* %__fld.13 to %Ast*
  %.t15 = bitcast %Span* %span to %Span*
  %.p3610 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.54, i64 0, i64 0
  %.p3611 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.81, i64 0, i64 0
  %.t16 = call i64 @Ast__add0(%Ast* %.t14, i8* %.p3610, i8* %.p3611, %Span* %.t15)
  ret i64 %.t16
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.r3612 = load i8*, i8** %k
  %.p3613 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.84, i64 0, i64 0
  %.r3614 = call i32 @strcmp(i8* %.r3612, i8* %.p3613)
  %.t17 = icmp eq i32 %.r3614, 0
  br i1 %.t17, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.t18 = bitcast %Parser* %self to %Parser*
  %.t19 = call i64 @Parser__advance(%Parser* %.t18)
  %__fld.20 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t21 = bitcast %Ast* %__fld.20 to %Ast*
  %.t22 = bitcast %Span* %span to %Span*
  %.p3615 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.54, i64 0, i64 0
  %.p3616 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.83, i64 0, i64 0
  %.t23 = call i64 @Ast__add0(%Ast* %.t21, i8* %.p3615, i8* %.p3616, %Span* %.t22)
  ret i64 %.t23
if_next_0_8:
  br label %if_end_6
if_end_6:
  %.r3617 = load i8*, i8** %k
  %.p3618 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.86, i64 0, i64 0
  %.r3619 = call i32 @strcmp(i8* %.r3617, i8* %.p3618)
  %.t24 = icmp eq i32 %.r3619, 0
  br i1 %.t24, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.t25 = bitcast %Parser* %self to %Parser*
  %.t26 = call i64 @Parser__advance(%Parser* %.t25)
  %__fld.27 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t28 = bitcast %Ast* %__fld.27 to %Ast*
  %.t29 = bitcast %Span* %span to %Span*
  %.p3620 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.54, i64 0, i64 0
  %.p3621 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.85, i64 0, i64 0
  %.t30 = call i64 @Ast__add0(%Ast* %.t28, i8* %.p3620, i8* %.p3621, %Span* %.t29)
  ret i64 %.t30
if_next_0_11:
  br label %if_end_9
if_end_9:
  %.r3622 = load i8*, i8** %k
  %.p3623 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.88, i64 0, i64 0
  %.r3624 = call i32 @strcmp(i8* %.r3622, i8* %.p3623)
  %.t31 = icmp eq i32 %.r3624, 0
  br i1 %.t31, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  %.t32 = bitcast %Parser* %self to %Parser*
  %.t33 = call i64 @Parser__advance(%Parser* %.t32)
  %.t34 = bitcast %Parser* %self to %Parser*
  %.p3625 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.176, i64 0, i64 0
  %.t35 = call i64 @Parser__expect(%Parser* %.t34, i8* %.p3625)
  %.t36 = icmp slt i64 %.t35, 0
  br i1 %.t36, label %if_then_0_16, label %if_next_0_17
if_then_0_16:
  %.t37 = sub i64 0, 1
  ret i64 %.t37
if_next_0_17:
  br label %if_end_15
if_end_15:
  %.t38 = bitcast %Parser* %self to %Parser*
  %.t39 = call i64 @Parser__parse_type(%Parser* %.t38)
  store i64 %.t39, i64* %inner
  %.r3626 = load i64, i64* %inner
  %.t40 = icmp slt i64 %.r3626, 0
  br i1 %.t40, label %if_then_0_19, label %if_next_0_20
if_then_0_19:
  %.t41 = sub i64 0, 1
  ret i64 %.t41
if_next_0_20:
  br label %if_end_18
if_end_18:
  %.t42 = bitcast %Parser* %self to %Parser*
  %.p3627 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.178, i64 0, i64 0
  %.t43 = call i64 @Parser__expect(%Parser* %.t42, i8* %.p3627)
  %.t44 = icmp slt i64 %.t43, 0
  br i1 %.t44, label %if_then_0_22, label %if_next_0_23
if_then_0_22:
  %.t45 = sub i64 0, 1
  ret i64 %.t45
if_next_0_23:
  br label %if_end_21
if_end_21:
  %__fld.46 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t47 = bitcast %Ast* %__fld.46 to %Ast*
  %__fld.48 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t49 = bitcast %Ast* %__fld.48 to %Ast*
  %.r3628 = load i64, i64* %inner
  %.t50 = call i8* @Ast__text_of(%Ast* %.t49, i64 %.r3628)
  %.p3629 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.283, i64 0, i64 0
  %.r3630 = call i64 @strlen(i8* %.p3629)
  %.r3631 = call i64 @strlen(i8* %.t50)
  %.r3632 = add i64 %.r3630, %.r3631
  %.r3633 = add i64 %.r3632, 1
  %.t51 = call i8* @malloc(i64 %.r3633)
  call i8* @memcpy(i8* %.t51, i8* %.p3629, i64 %.r3630)
  %.p3634 = getelementptr inbounds i8, i8* %.t51, i64 %.r3630
  call i8* @memcpy(i8* %.p3634, i8* %.t50, i64 %.r3631)
  %.p3635 = getelementptr inbounds i8, i8* %.t51, i64 %.r3632
  store i8 0, i8* %.p3635
  %.p3636 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.284, i64 0, i64 0
  %.r3637 = call i64 @strlen(i8* %.t51)
  %.r3638 = call i64 @strlen(i8* %.p3636)
  %.r3639 = add i64 %.r3637, %.r3638
  %.r3640 = add i64 %.r3639, 1
  %.t52 = call i8* @malloc(i64 %.r3640)
  call i8* @memcpy(i8* %.t52, i8* %.t51, i64 %.r3637)
  %.p3641 = getelementptr inbounds i8, i8* %.t52, i64 %.r3637
  call i8* @memcpy(i8* %.p3641, i8* %.p3636, i64 %.r3638)
  %.p3642 = getelementptr inbounds i8, i8* %.t52, i64 %.r3639
  store i8 0, i8* %.p3642
  %.t53 = bitcast %Span* %span to %Span*
  %.p3643 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.54, i64 0, i64 0
  %.t54 = call i64 @Ast__add0(%Ast* %.t47, i8* %.p3643, i8* %.t52, %Span* %.t53)
  ret i64 %.t54
if_next_0_14:
  br label %if_end_12
if_end_12:
  %.r3644 = load i8*, i8** %k
  %.p3645 = getelementptr inbounds [11 x i8], [11 x i8]* @.str.101, i64 0, i64 0
  %.r3646 = call i32 @strcmp(i8* %.r3644, i8* %.p3645)
  %.t55 = icmp eq i32 %.r3646, 0
  br i1 %.t55, label %if_then_0_25, label %if_next_0_26
if_then_0_25:
  %.t56 = bitcast %Parser* %self to %Parser*
  %.t57 = call i64 @Parser__advance(%Parser* %.t56)
  store i64 %.t57, i64* %t
  %__fld.58 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t59 = bitcast %Ast* %__fld.58 to %Ast*
  %.t60 = bitcast %Parser* %self to %Parser*
  %.r3647 = load i64, i64* %t
  %.t61 = call i8* @Parser__ttext(%Parser* %.t60, i64 %.r3647)
  %.t62 = bitcast %Span* %span to %Span*
  %.p3648 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.54, i64 0, i64 0
  %.t63 = call i64 @Ast__add0(%Ast* %.t59, i8* %.p3648, i8* %.t61, %Span* %.t62)
  ret i64 %.t63
if_next_0_26:
  br label %if_end_24
if_end_24:
  %.r3649 = load i8*, i8** %k
  %.p3650 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.146, i64 0, i64 0
  %.r3651 = call i32 @strcmp(i8* %.r3649, i8* %.p3650)
  %.t64 = icmp eq i32 %.r3651, 0
  br i1 %.t64, label %if_then_0_28, label %if_next_0_29
if_then_0_28:
  %.t65 = bitcast %Parser* %self to %Parser*
  %.t66 = call i64 @Parser__advance(%Parser* %.t65)
  %.t67 = bitcast %Parser* %self to %Parser*
  %.t68 = call i64 @Parser__parse_type(%Parser* %.t67)
  store i64 %.t68, i64* %elem
  %.r3652 = load i64, i64* %elem
  %.t69 = icmp slt i64 %.r3652, 0
  br i1 %.t69, label %if_then_0_31, label %if_next_0_32
if_then_0_31:
  %.t70 = sub i64 0, 1
  ret i64 %.t70
if_next_0_32:
  br label %if_end_30
if_end_30:
  %.t71 = bitcast %Parser* %self to %Parser*
  %.p3653 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.148, i64 0, i64 0
  %.t72 = call i64 @Parser__expect(%Parser* %.t71, i8* %.p3653)
  %.t73 = icmp slt i64 %.t72, 0
  br i1 %.t73, label %if_then_0_34, label %if_next_0_35
if_then_0_34:
  %.t74 = sub i64 0, 1
  ret i64 %.t74
if_next_0_35:
  br label %if_end_33
if_end_33:
  %__fld.75 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t76 = bitcast %Ast* %__fld.75 to %Ast*
  %__fld.77 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t78 = bitcast %Ast* %__fld.77 to %Ast*
  %.r3654 = load i64, i64* %elem
  %.t79 = call i8* @Ast__text_of(%Ast* %.t78, i64 %.r3654)
  %.p3655 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.3, i64 0, i64 0
  %.r3656 = call i64 @strlen(i8* %.p3655)
  %.r3657 = call i64 @strlen(i8* %.t79)
  %.r3658 = add i64 %.r3656, %.r3657
  %.r3659 = add i64 %.r3658, 1
  %.t80 = call i8* @malloc(i64 %.r3659)
  call i8* @memcpy(i8* %.t80, i8* %.p3655, i64 %.r3656)
  %.p3660 = getelementptr inbounds i8, i8* %.t80, i64 %.r3656
  call i8* @memcpy(i8* %.p3660, i8* %.t79, i64 %.r3657)
  %.p3661 = getelementptr inbounds i8, i8* %.t80, i64 %.r3658
  store i8 0, i8* %.p3661
  %.p3662 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.4, i64 0, i64 0
  %.r3663 = call i64 @strlen(i8* %.t80)
  %.r3664 = call i64 @strlen(i8* %.p3662)
  %.r3665 = add i64 %.r3663, %.r3664
  %.r3666 = add i64 %.r3665, 1
  %.t81 = call i8* @malloc(i64 %.r3666)
  call i8* @memcpy(i8* %.t81, i8* %.t80, i64 %.r3663)
  %.p3667 = getelementptr inbounds i8, i8* %.t81, i64 %.r3663
  call i8* @memcpy(i8* %.p3667, i8* %.p3662, i64 %.r3664)
  %.p3668 = getelementptr inbounds i8, i8* %.t81, i64 %.r3665
  store i8 0, i8* %.p3668
  %.t82 = bitcast %Span* %span to %Span*
  %.p3669 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.54, i64 0, i64 0
  %.t83 = call i64 @Ast__add0(%Ast* %.t76, i8* %.p3669, i8* %.t81, %Span* %.t82)
  ret i64 %.t83
if_next_0_29:
  br label %if_end_27
if_end_27:
  %.r3670 = load i8*, i8** %k
  %.p3671 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.142, i64 0, i64 0
  %.r3672 = call i32 @strcmp(i8* %.r3670, i8* %.p3671)
  %.t84 = icmp eq i32 %.r3672, 0
  br i1 %.t84, label %if_then_0_37, label %if_next_0_38
if_then_0_37:
  %.t85 = bitcast %Parser* %self to %Parser*
  %.t86 = call i64 @Parser__advance(%Parser* %.t85)
  %.t87 = bitcast %Parser* %self to %Parser*
  %.t88 = call i64 @Parser__parse_type(%Parser* %.t87)
  store i64 %.t88, i64* %first
  %.r3673 = load i64, i64* %first
  %.t89 = icmp slt i64 %.r3673, 0
  br i1 %.t89, label %if_then_0_40, label %if_next_0_41
if_then_0_40:
  %.t90 = sub i64 0, 1
  ret i64 %.t90
if_next_0_41:
  br label %if_end_39
if_end_39:
  %__fld.91 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t92 = bitcast %Ast* %__fld.91 to %Ast*
  %.r3674 = load i64, i64* %first
  %.t93 = call i8* @Ast__text_of(%Ast* %.t92, i64 %.r3674)
  store i8* %.t93, i8** %text
  br label %while_cond_42
while_cond_42:
  %.t94 = bitcast %Parser* %self to %Parser*
  %.p3675 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.154, i64 0, i64 0
  %.t95 = call i1 @Parser__at(%Parser* %.t94, i8* %.p3675)
  br i1 %.t95, label %while_body_43, label %while_end_44
while_body_43:
  %.t96 = bitcast %Parser* %self to %Parser*
  %.t97 = call i64 @Parser__advance(%Parser* %.t96)
  %.t98 = bitcast %Parser* %self to %Parser*
  %.p3676 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.144, i64 0, i64 0
  %.t99 = call i1 @Parser__at(%Parser* %.t98, i8* %.p3676)
  br i1 %.t99, label %if_then_0_46, label %if_next_0_47
if_then_0_46:
  br label %while_end_44
if_next_0_47:
  br label %if_end_45
if_end_45:
  %.t100 = bitcast %Parser* %self to %Parser*
  %.t101 = call i64 @Parser__parse_type(%Parser* %.t100)
  store i64 %.t101, i64* %nxt
  %.r3677 = load i64, i64* %nxt
  %.t102 = icmp slt i64 %.r3677, 0
  br i1 %.t102, label %if_then_0_49, label %if_next_0_50
if_then_0_49:
  %.t103 = sub i64 0, 1
  ret i64 %.t103
if_next_0_50:
  br label %if_end_48
if_end_48:
  %.r3678 = load i8*, i8** %text
  %.p3679 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.285, i64 0, i64 0
  %.r3680 = call i64 @strlen(i8* %.r3678)
  %.r3681 = call i64 @strlen(i8* %.p3679)
  %.r3682 = add i64 %.r3680, %.r3681
  %.r3683 = add i64 %.r3682, 1
  %.t104 = call i8* @malloc(i64 %.r3683)
  call i8* @memcpy(i8* %.t104, i8* %.r3678, i64 %.r3680)
  %.p3684 = getelementptr inbounds i8, i8* %.t104, i64 %.r3680
  call i8* @memcpy(i8* %.p3684, i8* %.p3679, i64 %.r3681)
  %.p3685 = getelementptr inbounds i8, i8* %.t104, i64 %.r3682
  store i8 0, i8* %.p3685
  %__fld.105 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t106 = bitcast %Ast* %__fld.105 to %Ast*
  %.r3686 = load i64, i64* %nxt
  %.t107 = call i8* @Ast__text_of(%Ast* %.t106, i64 %.r3686)
  %.r3687 = call i64 @strlen(i8* %.t104)
  %.r3688 = call i64 @strlen(i8* %.t107)
  %.r3689 = add i64 %.r3687, %.r3688
  %.r3690 = add i64 %.r3689, 1
  %.t108 = call i8* @malloc(i64 %.r3690)
  call i8* @memcpy(i8* %.t108, i8* %.t104, i64 %.r3687)
  %.p3691 = getelementptr inbounds i8, i8* %.t108, i64 %.r3687
  call i8* @memcpy(i8* %.p3691, i8* %.t107, i64 %.r3688)
  %.p3692 = getelementptr inbounds i8, i8* %.t108, i64 %.r3689
  store i8 0, i8* %.p3692
  store i8* %.t108, i8** %text
  br label %while_cond_42
while_end_44:
  %.t109 = bitcast %Parser* %self to %Parser*
  %.p3693 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.144, i64 0, i64 0
  %.t110 = call i64 @Parser__expect(%Parser* %.t109, i8* %.p3693)
  %.t111 = icmp slt i64 %.t110, 0
  br i1 %.t111, label %if_then_0_52, label %if_next_0_53
if_then_0_52:
  %.t112 = sub i64 0, 1
  ret i64 %.t112
if_next_0_53:
  br label %if_end_51
if_end_51:
  %__fld.113 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t114 = bitcast %Ast* %__fld.113 to %Ast*
  %.p3694 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.262, i64 0, i64 0
  %.r3695 = load i8*, i8** %text
  %.r3696 = call i64 @strlen(i8* %.p3694)
  %.r3697 = call i64 @strlen(i8* %.r3695)
  %.r3698 = add i64 %.r3696, %.r3697
  %.r3699 = add i64 %.r3698, 1
  %.t115 = call i8* @malloc(i64 %.r3699)
  call i8* @memcpy(i8* %.t115, i8* %.p3694, i64 %.r3696)
  %.p3700 = getelementptr inbounds i8, i8* %.t115, i64 %.r3696
  call i8* @memcpy(i8* %.p3700, i8* %.r3695, i64 %.r3697)
  %.p3701 = getelementptr inbounds i8, i8* %.t115, i64 %.r3698
  store i8 0, i8* %.p3701
  %.p3702 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.263, i64 0, i64 0
  %.r3703 = call i64 @strlen(i8* %.t115)
  %.r3704 = call i64 @strlen(i8* %.p3702)
  %.r3705 = add i64 %.r3703, %.r3704
  %.r3706 = add i64 %.r3705, 1
  %.t116 = call i8* @malloc(i64 %.r3706)
  call i8* @memcpy(i8* %.t116, i8* %.t115, i64 %.r3703)
  %.p3707 = getelementptr inbounds i8, i8* %.t116, i64 %.r3703
  call i8* @memcpy(i8* %.p3707, i8* %.p3702, i64 %.r3704)
  %.p3708 = getelementptr inbounds i8, i8* %.t116, i64 %.r3705
  store i8 0, i8* %.p3708
  %.t117 = bitcast %Span* %span to %Span*
  %.p3709 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.54, i64 0, i64 0
  %.t118 = call i64 @Ast__add0(%Ast* %.t114, i8* %.p3709, i8* %.t116, %Span* %.t117)
  ret i64 %.t118
if_next_0_38:
  br label %if_end_36
if_end_36:
  %__fld.119 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 3
  %.t120 = bitcast %Diags* %__fld.119 to %Diags*
  %.t121 = bitcast %Parser* %self to %Parser*
  %.t122 = call i8* @Parser__found(%Parser* %.t121)
  %.p3710 = getelementptr inbounds [24 x i8], [24 x i8]* @.str.286, i64 0, i64 0
  %.r3711 = call i64 @strlen(i8* %.p3710)
  %.r3712 = call i64 @strlen(i8* %.t122)
  %.r3713 = add i64 %.r3711, %.r3712
  %.r3714 = add i64 %.r3713, 1
  %.t123 = call i8* @malloc(i64 %.r3714)
  call i8* @memcpy(i8* %.t123, i8* %.p3710, i64 %.r3711)
  %.p3715 = getelementptr inbounds i8, i8* %.t123, i64 %.r3711
  call i8* @memcpy(i8* %.p3715, i8* %.t122, i64 %.r3712)
  %.p3716 = getelementptr inbounds i8, i8* %.t123, i64 %.r3713
  store i8 0, i8* %.p3716
  %.t124 = bitcast %Span* %span to %Span*
  %.p3717 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.287, i64 0, i64 0
  %.p3718 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p3719 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @Diags__add(%Diags* %.t120, i8* %.p3717, i8* %.t123, %Span* %.t124, i8* %.p3718, i8* %.p3719)
  %.t125 = sub i64 0, 1
  ret i64 %.t125
}

define i64 @Parser__parse_function(%Parser* %self) {
entry:
  %is_extern = alloca i1
  %is_async = alloca i1
  %mt = alloca i64
  %start = alloca %Span
  %nt = alloca i64
  %name = alloca i8*
  %params = alloca { i64, i64, i64* }
  %variadic = alloca i1
  %pt = alloca i64
  %__sc.34 = alloca i1
  %__sc.35 = alloca i1
  %__sc.36 = alloca i1
  %is_self = alloca i1
  %ty = alloca i64
  %__agg.52 = alloca %Span
  %default = alloca i64
  %flag = alloca i8*
  %__agg.75 = alloca %Span
  %fl = alloca i64
  %__agg.83 = alloca %Span
  %ret = alloca i64
  %flags = alloca i8*
  %__sc.104 = alloca i1
  %fl2 = alloca i64
  %pl = alloca i64
  %et = alloca i64
  %__agg.122 = alloca %Span
  %__agg.120 = alloca %Span
  %body = alloca i64
  %__agg.140 = alloca %Span
  %__agg.138 = alloca %Span
  store i1 false, i1* %is_extern
  store i1 false, i1* %is_async
  %.t0 = bitcast %Parser* %self to %Parser*
  %.p3720 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.16, i64 0, i64 0
  %.t1 = call i1 @Parser__at(%Parser* %.t0, i8* %.p3720)
  br i1 %.t1, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t2 = bitcast %Parser* %self to %Parser*
  %.t3 = call i64 @Parser__advance(%Parser* %.t2)
  store i1 true, i1* %is_extern
  br label %if_end_0
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.t4 = bitcast %Parser* %self to %Parser*
  %.p3721 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.66, i64 0, i64 0
  %.t5 = call i1 @Parser__at(%Parser* %.t4, i8* %.p3721)
  br i1 %.t5, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.t6 = bitcast %Parser* %self to %Parser*
  %.t7 = call i64 @Parser__advance(%Parser* %.t6)
  store i1 true, i1* %is_async
  br label %if_end_3
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.t8 = bitcast %Parser* %self to %Parser*
  %.p3722 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.14, i64 0, i64 0
  %.t9 = call i64 @Parser__expect(%Parser* %.t8, i8* %.p3722)
  store i64 %.t9, i64* %mt
  %.r3723 = load i64, i64* %mt
  %.t10 = icmp slt i64 %.r3723, 0
  br i1 %.t10, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.t11 = sub i64 0, 1
  ret i64 %.t11
if_next_0_8:
  br label %if_end_6
if_end_6:
  %.t12 = bitcast %Parser* %self to %Parser*
  %.r3724 = load i64, i64* %mt
  call void @Parser__tspan(%Span* %start, %Parser* %.t12, i64 %.r3724)
  %.t13 = bitcast %Parser* %self to %Parser*
  %.t14 = call i64 @Parser__expect_identifier(%Parser* %.t13)
  store i64 %.t14, i64* %nt
  %.r3725 = load i64, i64* %nt
  %.t15 = icmp slt i64 %.r3725, 0
  br i1 %.t15, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.t16 = sub i64 0, 1
  ret i64 %.t16
if_next_0_11:
  br label %if_end_9
if_end_9:
  %.t17 = bitcast %Parser* %self to %Parser*
  %.r3726 = load i64, i64* %nt
  %.t18 = call i8* @Parser__ttext(%Parser* %.t17, i64 %.r3726)
  store i8* %.t18, i8** %name
  %.t19 = bitcast %Parser* %self to %Parser*
  %.p3727 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.142, i64 0, i64 0
  %.t20 = call i64 @Parser__expect(%Parser* %.t19, i8* %.p3727)
  %.t21 = icmp slt i64 %.t20, 0
  br i1 %.t21, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  %.t22 = sub i64 0, 1
  ret i64 %.t22
if_next_0_14:
  br label %if_end_12
if_end_12:
  %.p3729 = getelementptr i64, i64* null, i32 1
  %.r3730 = ptrtoint i64* %.p3729 to i64
  %.r3731 = mul i64 %.r3730, 1
  %.p3728 = call i8* @malloc(i64 %.r3731)
  %.p3732 = bitcast i8* %.p3728 to i64*
  %.p3733 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %params, i32 0, i32 0
  store i64 0, i64* %.p3733
  %.p3734 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %params, i32 0, i32 1
  store i64 0, i64* %.p3734
  %.p3735 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %params, i32 0, i32 2
  store i64* %.p3732, i64** %.p3735
  %.t23 = bitcast %Parser* %self to %Parser*
  %.p3736 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.144, i64 0, i64 0
  %.t24 = call i1 @Parser__at(%Parser* %.t23, i8* %.p3736)
  %.t25 = xor i1 %.t24, true
  br i1 %.t25, label %if_then_0_16, label %if_next_0_17
if_then_0_16:
  br label %while_cond_18
while_cond_18:
  br i1 true, label %while_body_19, label %while_end_20
while_body_19:
  store i1 false, i1* %variadic
  %.t26 = bitcast %Parser* %self to %Parser*
  %.p3737 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.166, i64 0, i64 0
  %.t27 = call i1 @Parser__at(%Parser* %.t26, i8* %.p3737)
  br i1 %.t27, label %if_then_0_22, label %if_next_0_23
if_then_0_22:
  %.t28 = bitcast %Parser* %self to %Parser*
  %.t29 = call i64 @Parser__advance(%Parser* %.t28)
  store i1 true, i1* %variadic
  br label %if_end_21
if_next_0_23:
  br label %if_end_21
if_end_21:
  %.t30 = bitcast %Parser* %self to %Parser*
  %.t31 = call i64 @Parser__expect_identifier(%Parser* %.t30)
  store i64 %.t31, i64* %pt
  %.r3738 = load i64, i64* %pt
  %.t32 = icmp slt i64 %.r3738, 0
  br i1 %.t32, label %if_then_0_25, label %if_next_0_26
if_then_0_25:
  %.t33 = sub i64 0, 1
  ret i64 %.t33
if_next_0_26:
  br label %if_end_24
if_end_24:
  %.p3739 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 2
  %.t37 = load i8*, i8** %.p3739
  %.t38 = call i64 @strlen(i8* %.t37)
  %.t39 = icmp sgt i64 %.t38, 0
  br i1 %.t39, label %sc_rhs_27, label %sc_short_28
sc_rhs_27:
  %.p3740 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %params, i32 0, i32 0
  %.t40 = load i64, i64* %.p3740
  %.t41 = icmp eq i64 %.t40, 0
  store i1 %.t41, i1* %__sc.36
  br label %sc_end_29
sc_short_28:
  store i1 false, i1* %__sc.36
  br label %sc_end_29
sc_end_29:
  %.r3741 = load i1, i1* %__sc.36
  br i1 %.r3741, label %sc_rhs_30, label %sc_short_31
sc_rhs_30:
  %.t42 = bitcast %Parser* %self to %Parser*
  %.r3742 = load i64, i64* %pt
  %.t43 = call i8* @Parser__ttext(%Parser* %.t42, i64 %.r3742)
  %.p3743 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.288, i64 0, i64 0
  %.r3744 = call i32 @strcmp(i8* %.t43, i8* %.p3743)
  %.t44 = icmp eq i32 %.r3744, 0
  store i1 %.t44, i1* %__sc.35
  br label %sc_end_32
sc_short_31:
  store i1 false, i1* %__sc.35
  br label %sc_end_32
sc_end_32:
  %.r3745 = load i1, i1* %__sc.35
  br i1 %.r3745, label %sc_rhs_33, label %sc_short_34
sc_rhs_33:
  %.t45 = bitcast %Parser* %self to %Parser*
  %.p3746 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.156, i64 0, i64 0
  %.t46 = call i1 @Parser__at(%Parser* %.t45, i8* %.p3746)
  %.t47 = xor i1 %.t46, true
  store i1 %.t47, i1* %__sc.34
  br label %sc_end_35
sc_short_34:
  store i1 false, i1* %__sc.34
  br label %sc_end_35
sc_end_35:
  %.r3747 = load i1, i1* %__sc.34
  store i1 %.r3747, i1* %is_self
  %.t48 = sub i64 0, 1
  store i64 %.t48, i64* %ty
  %.r3748 = load i1, i1* %is_self
  br i1 %.r3748, label %if_then_0_37, label %if_next_0_38
if_then_0_37:
  %__fld.49 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t50 = bitcast %Ast* %__fld.49 to %Ast*
  %.p3749 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 2
  %.t51 = load i8*, i8** %.p3749
  %.t53 = bitcast %Parser* %self to %Parser*
  %.r3750 = load i64, i64* %pt
  call void @Parser__tspan(%Span* %__agg.52, %Parser* %.t53, i64 %.r3750)
  %.t54 = bitcast %Span* %__agg.52 to %Span*
  %.p3751 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.54, i64 0, i64 0
  %.t55 = call i64 @Ast__add0(%Ast* %.t50, i8* %.p3751, i8* %.t51, %Span* %.t54)
  store i64 %.t55, i64* %ty
  br label %if_end_36
if_next_0_38:
  %.t56 = bitcast %Parser* %self to %Parser*
  %.p3752 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.156, i64 0, i64 0
  %.t57 = call i64 @Parser__expect(%Parser* %.t56, i8* %.p3752)
  %.t58 = icmp slt i64 %.t57, 0
  br i1 %.t58, label %if_then_0_40, label %if_next_0_41
if_then_0_40:
  %.t59 = sub i64 0, 1
  ret i64 %.t59
if_next_0_41:
  br label %if_end_39
if_end_39:
  %.t60 = bitcast %Parser* %self to %Parser*
  %.t61 = call i64 @Parser__parse_type(%Parser* %.t60)
  store i64 %.t61, i64* %ty
  %.r3753 = load i64, i64* %ty
  %.t62 = icmp slt i64 %.r3753, 0
  br i1 %.t62, label %if_then_0_43, label %if_next_0_44
if_then_0_43:
  %.t63 = sub i64 0, 1
  ret i64 %.t63
if_next_0_44:
  br label %if_end_42
if_end_42:
  br label %if_end_36
if_end_36:
  %.t64 = sub i64 0, 1
  store i64 %.t64, i64* %default
  %.t65 = bitcast %Parser* %self to %Parser*
  %.p3754 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.184, i64 0, i64 0
  %.t66 = call i1 @Parser__at(%Parser* %.t65, i8* %.p3754)
  br i1 %.t66, label %if_then_0_46, label %if_next_0_47
if_then_0_46:
  %.t67 = bitcast %Parser* %self to %Parser*
  %.t68 = call i64 @Parser__advance(%Parser* %.t67)
  %.t69 = bitcast %Parser* %self to %Parser*
  %.t70 = call i64 @Parser__parse_expr(%Parser* %.t69)
  store i64 %.t70, i64* %default
  %.r3755 = load i64, i64* %default
  %.t71 = icmp slt i64 %.r3755, 0
  br i1 %.t71, label %if_then_0_49, label %if_next_0_50
if_then_0_49:
  %.t72 = sub i64 0, 1
  ret i64 %.t72
if_next_0_50:
  br label %if_end_48
if_end_48:
  br label %if_end_45
if_next_0_47:
  br label %if_end_45
if_end_45:
  %.p3756 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  store i8* %.p3756, i8** %flag
  %.r3757 = load i1, i1* %variadic
  br i1 %.r3757, label %if_then_0_52, label %if_next_0_53
if_then_0_52:
  %.p3758 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.289, i64 0, i64 0
  store i8* %.p3758, i8** %flag
  br label %if_end_51
if_next_0_53:
  br label %if_end_51
if_end_51:
  %__fld.73 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t74 = bitcast %Ast* %__fld.73 to %Ast*
  %.t76 = bitcast %Parser* %self to %Parser*
  %.r3759 = load i64, i64* %pt
  call void @Parser__tspan(%Span* %__agg.75, %Parser* %.t76, i64 %.r3759)
  %.t77 = bitcast %Span* %__agg.75 to %Span*
  %.p3760 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.256, i64 0, i64 0
  %.r3761 = load i8*, i8** %flag
  %.t78 = call i64 @Ast__add0(%Ast* %.t74, i8* %.p3760, i8* %.r3761, %Span* %.t77)
  store i64 %.t78, i64* %fl
  %__fld.79 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t80 = bitcast %Ast* %__fld.79 to %Ast*
  %.t81 = bitcast %Parser* %self to %Parser*
  %.r3762 = load i64, i64* %pt
  %.t82 = call i8* @Parser__ttext(%Parser* %.t81, i64 %.r3762)
  %.t84 = bitcast %Parser* %self to %Parser*
  %.r3763 = load i64, i64* %pt
  call void @Parser__tspan(%Span* %__agg.83, %Parser* %.t84, i64 %.r3763)
  %.t85 = bitcast %Span* %__agg.83 to %Span*
  %.p3764 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.290, i64 0, i64 0
  %.r3765 = load i64, i64* %ty
  %.r3766 = load i64, i64* %default
  %.r3767 = load i64, i64* %fl
  %.t86 = call i64 @Ast__add3(%Ast* %.t80, i8* %.p3764, i8* %.t82, %Span* %.t85, i64 %.r3765, i64 %.r3766, i64 %.r3767)
  %.p3768 = getelementptr i64, i64* null, i32 1
  %.r3769 = ptrtoint i64* %.p3768 to i64
  %.p3770 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %params, i32 0, i32 0
  %.p3771 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %params, i32 0, i32 1
  %.p3772 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %params, i32 0, i32 2
  %.r3773 = load i64, i64* %.p3770
  %.r3774 = load i64, i64* %.p3771
  %.r3775 = icmp sge i64 %.r3773, %.r3774
  br i1 %.r3775, label %append.grow.3776, label %append.after.3777
append.grow.3776:
  %.r3778 = load i64*, i64** %.p3772
  %.r3779 = icmp eq i64 %.r3774, 0
  %.r3780 = mul i64 %.r3774, 2
  %.r3781 = select i1 %.r3779, i64 1, i64 %.r3780
  %.r3782 = mul i64 %.r3781, %.r3769
  %.p3783 = call i8* @malloc(i64 %.r3782)
  %.p3784 = bitcast i8* %.p3783 to i64*
  %.r3785 = mul i64 %.r3773, %.r3769
  %.p3786 = bitcast i64* %.r3778 to i8*
  call i8* @memcpy(i8* %.p3783, i8* %.p3786, i64 %.r3785)
  call void @free(i8* %.p3786)
  store i64* %.p3784, i64** %.p3772
  store i64 %.r3781, i64* %.p3771
  br label %append.after.3777
append.after.3777:
  %.r3787 = load i64*, i64** %.p3772
  %.p3788 = getelementptr inbounds i64, i64* %.r3787, i64 %.r3773
  store i64 %.t86, i64* %.p3788
  %.r3789 = add i64 %.r3773, 1
  store i64 %.r3789, i64* %.p3770
  %.t87 = bitcast %Parser* %self to %Parser*
  %.p3790 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.154, i64 0, i64 0
  %.t88 = call i1 @Parser__at(%Parser* %.t87, i8* %.p3790)
  br i1 %.t88, label %if_then_0_55, label %if_next_0_56
if_then_0_55:
  %.t89 = bitcast %Parser* %self to %Parser*
  %.t90 = call i64 @Parser__advance(%Parser* %.t89)
  br label %if_end_54
if_next_0_56:
  br label %while_end_20
if_end_54:
  br label %while_cond_18
while_end_20:
  br label %if_end_15
if_next_0_17:
  br label %if_end_15
if_end_15:
  %.t91 = bitcast %Parser* %self to %Parser*
  %.p3791 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.144, i64 0, i64 0
  %.t92 = call i64 @Parser__expect(%Parser* %.t91, i8* %.p3791)
  %.t93 = icmp slt i64 %.t92, 0
  br i1 %.t93, label %if_then_0_58, label %if_next_0_59
if_then_0_58:
  %.t94 = sub i64 0, 1
  ret i64 %.t94
if_next_0_59:
  br label %if_end_57
if_end_57:
  %.t95 = sub i64 0, 1
  store i64 %.t95, i64* %ret
  %.t96 = bitcast %Parser* %self to %Parser*
  %.p3792 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.160, i64 0, i64 0
  %.t97 = call i1 @Parser__at(%Parser* %.t96, i8* %.p3792)
  br i1 %.t97, label %if_then_0_61, label %if_next_0_62
if_then_0_61:
  %.t98 = bitcast %Parser* %self to %Parser*
  %.t99 = call i64 @Parser__advance(%Parser* %.t98)
  %.t100 = bitcast %Parser* %self to %Parser*
  %.t101 = call i64 @Parser__parse_type(%Parser* %.t100)
  store i64 %.t101, i64* %ret
  %.r3793 = load i64, i64* %ret
  %.t102 = icmp slt i64 %.r3793, 0
  br i1 %.t102, label %if_then_0_64, label %if_next_0_65
if_then_0_64:
  %.t103 = sub i64 0, 1
  ret i64 %.t103
if_next_0_65:
  br label %if_end_63
if_end_63:
  br label %if_end_60
if_next_0_62:
  br label %if_end_60
if_end_60:
  %.p3794 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  store i8* %.p3794, i8** %flags
  %.r3795 = load i1, i1* %is_extern
  br i1 %.r3795, label %sc_rhs_69, label %sc_short_70
sc_rhs_69:
  %.r3796 = load i1, i1* %is_async
  store i1 %.r3796, i1* %__sc.104
  br label %sc_end_71
sc_short_70:
  store i1 false, i1* %__sc.104
  br label %sc_end_71
sc_end_71:
  %.r3797 = load i1, i1* %__sc.104
  br i1 %.r3797, label %if_then_0_67, label %if_next_0_68
if_then_0_67:
  %.p3798 = getelementptr inbounds [13 x i8], [13 x i8]* @.str.291, i64 0, i64 0
  store i8* %.p3798, i8** %flags
  br label %if_end_66
if_next_0_68:
  %.r3799 = load i1, i1* %is_extern
  br i1 %.r3799, label %if_then_1_72, label %if_next_1_73
if_then_1_72:
  %.p3800 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.15, i64 0, i64 0
  store i8* %.p3800, i8** %flags
  br label %if_end_66
if_next_1_73:
  %.r3801 = load i1, i1* %is_async
  br i1 %.r3801, label %if_then_2_74, label %if_next_2_75
if_then_2_74:
  %.p3802 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.65, i64 0, i64 0
  store i8* %.p3802, i8** %flags
  br label %if_end_66
if_next_2_75:
  br label %if_end_66
if_end_66:
  %__fld.105 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t106 = bitcast %Ast* %__fld.105 to %Ast*
  %.t107 = bitcast %Span* %start to %Span*
  %.p3803 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.256, i64 0, i64 0
  %.r3804 = load i8*, i8** %flags
  %.t108 = call i64 @Ast__add0(%Ast* %.t106, i8* %.p3803, i8* %.r3804, %Span* %.t107)
  store i64 %.t108, i64* %fl2
  %__fld.109 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t110 = bitcast %Ast* %__fld.109 to %Ast*
  %.t111 = bitcast %Span* %start to %Span*
  %.t112 = bitcast { i64, i64, i64* }* %params to { i64, i64, i64* }*
  %.p3805 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.255, i64 0, i64 0
  %.p3806 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.t113 = call i64 @Ast__addl(%Ast* %.t110, i8* %.p3805, i8* %.p3806, %Span* %.t111, { i64, i64, i64* }* %.t112)
  store i64 %.t113, i64* %pl
  %.r3807 = load i1, i1* %is_extern
  br i1 %.r3807, label %if_then_0_77, label %if_next_0_78
if_then_0_77:
  %.t114 = bitcast %Parser* %self to %Parser*
  %.p3808 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.t115 = call i64 @Parser__expect(%Parser* %.t114, i8* %.p3808)
  store i64 %.t115, i64* %et
  %.r3809 = load i64, i64* %et
  %.t116 = icmp slt i64 %.r3809, 0
  br i1 %.t116, label %if_then_0_80, label %if_next_0_81
if_then_0_80:
  %.t117 = sub i64 0, 1
  ret i64 %.t117
if_next_0_81:
  br label %if_end_79
if_end_79:
  %__fld.118 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t119 = bitcast %Ast* %__fld.118 to %Ast*
  %.t121 = bitcast %Span* %start to %Span*
  %.t123 = bitcast %Parser* %self to %Parser*
  %.r3810 = load i64, i64* %et
  call void @Parser__tspan(%Span* %__agg.122, %Parser* %.t123, i64 %.r3810)
  %.t124 = bitcast %Span* %__agg.122 to %Span*
  call void @span_to(%Span* %__agg.120, %Span* %.t121, %Span* %.t124)
  %.t125 = bitcast %Span* %__agg.120 to %Span*
  %.t126 = sub i64 0, 1
  %.p3811 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.292, i64 0, i64 0
  %.r3812 = load i8*, i8** %name
  %.r3813 = load i64, i64* %pl
  %.r3814 = load i64, i64* %ret
  %.r3815 = load i64, i64* %fl2
  %.t127 = call i64 @Ast__add4(%Ast* %.t119, i8* %.p3811, i8* %.r3812, %Span* %.t125, i64 %.r3813, i64 %.r3814, i64 %.r3815, i64 %.t126)
  ret i64 %.t127
if_next_0_78:
  br label %if_end_76
if_end_76:
  %.t128 = bitcast %Parser* %self to %Parser*
  %.p3816 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.156, i64 0, i64 0
  %.t129 = call i64 @Parser__expect(%Parser* %.t128, i8* %.p3816)
  %.t130 = icmp slt i64 %.t129, 0
  br i1 %.t130, label %if_then_0_83, label %if_next_0_84
if_then_0_83:
  %.t131 = sub i64 0, 1
  ret i64 %.t131
if_next_0_84:
  br label %if_end_82
if_end_82:
  %.t132 = bitcast %Parser* %self to %Parser*
  %.t133 = call i64 @Parser__parse_block(%Parser* %.t132)
  store i64 %.t133, i64* %body
  %.r3817 = load i64, i64* %body
  %.t134 = icmp slt i64 %.r3817, 0
  br i1 %.t134, label %if_then_0_86, label %if_next_0_87
if_then_0_86:
  %.t135 = sub i64 0, 1
  ret i64 %.t135
if_next_0_87:
  br label %if_end_85
if_end_85:
  %__fld.136 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t137 = bitcast %Ast* %__fld.136 to %Ast*
  %.t139 = bitcast %Span* %start to %Span*
  %__fld.141 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t142 = bitcast %Ast* %__fld.141 to %Ast*
  %.r3818 = load i64, i64* %body
  call void @Ast__span_of(%Span* %__agg.140, %Ast* %.t142, i64 %.r3818)
  %.t143 = bitcast %Span* %__agg.140 to %Span*
  call void @span_to(%Span* %__agg.138, %Span* %.t139, %Span* %.t143)
  %.t144 = bitcast %Span* %__agg.138 to %Span*
  %.p3819 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.292, i64 0, i64 0
  %.r3820 = load i8*, i8** %name
  %.r3821 = load i64, i64* %pl
  %.r3822 = load i64, i64* %ret
  %.r3823 = load i64, i64* %fl2
  %.r3824 = load i64, i64* %body
  %.t145 = call i64 @Ast__add4(%Ast* %.t137, i8* %.p3819, i8* %.r3820, %Span* %.t144, i64 %.r3821, i64 %.r3822, i64 %.r3823, i64 %.r3824)
  ret i64 %.t145
}

define i64 @Parser__parse_block(%Parser* %self) {
entry:
  %it = alloca i64
  %start = alloca %Span
  %stmts = alloca { i64, i64, i64* }
  %__sc.9 = alloca i1
  %s = alloca i64
  %et = alloca i64
  %__agg.32 = alloca %Span
  %__agg.30 = alloca %Span
  %.t0 = bitcast %Parser* %self to %Parser*
  %.p3825 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.t1 = call i64 @Parser__expect(%Parser* %.t0, i8* %.p3825)
  %.t2 = icmp slt i64 %.t1, 0
  br i1 %.t2, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t3 = sub i64 0, 1
  ret i64 %.t3
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.t4 = bitcast %Parser* %self to %Parser*
  %.p3826 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.220, i64 0, i64 0
  %.t5 = call i64 @Parser__expect(%Parser* %.t4, i8* %.p3826)
  store i64 %.t5, i64* %it
  %.r3827 = load i64, i64* %it
  %.t6 = icmp slt i64 %.r3827, 0
  br i1 %.t6, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.t7 = sub i64 0, 1
  ret i64 %.t7
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.t8 = bitcast %Parser* %self to %Parser*
  %.r3828 = load i64, i64* %it
  call void @Parser__tspan(%Span* %start, %Parser* %.t8, i64 %.r3828)
  %.p3830 = getelementptr i64, i64* null, i32 1
  %.r3831 = ptrtoint i64* %.p3830 to i64
  %.r3832 = mul i64 %.r3831, 1
  %.p3829 = call i8* @malloc(i64 %.r3832)
  %.p3833 = bitcast i8* %.p3829 to i64*
  %.p3834 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stmts, i32 0, i32 0
  store i64 0, i64* %.p3834
  %.p3835 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stmts, i32 0, i32 1
  store i64 0, i64* %.p3835
  %.p3836 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stmts, i32 0, i32 2
  store i64* %.p3833, i64** %.p3836
  br label %while_cond_6
while_cond_6:
  %.t10 = bitcast %Parser* %self to %Parser*
  %.p3837 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.222, i64 0, i64 0
  %.t11 = call i1 @Parser__at(%Parser* %.t10, i8* %.p3837)
  %.t12 = xor i1 %.t11, true
  br i1 %.t12, label %sc_rhs_9, label %sc_short_10
sc_rhs_9:
  %.t13 = bitcast %Parser* %self to %Parser*
  %.p3838 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.224, i64 0, i64 0
  %.t14 = call i1 @Parser__at(%Parser* %.t13, i8* %.p3838)
  %.t15 = xor i1 %.t14, true
  store i1 %.t15, i1* %__sc.9
  br label %sc_end_11
sc_short_10:
  store i1 false, i1* %__sc.9
  br label %sc_end_11
sc_end_11:
  %.r3839 = load i1, i1* %__sc.9
  br i1 %.r3839, label %while_body_7, label %while_end_8
while_body_7:
  %.t16 = bitcast %Parser* %self to %Parser*
  %.p3840 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.t17 = call i1 @Parser__at(%Parser* %.t16, i8* %.p3840)
  br i1 %.t17, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  %.t18 = bitcast %Parser* %self to %Parser*
  %.t19 = call i64 @Parser__advance(%Parser* %.t18)
  br label %while_cond_6
if_next_0_14:
  br label %if_end_12
if_end_12:
  %.t20 = bitcast %Parser* %self to %Parser*
  %.t21 = call i64 @Parser__parse_statement(%Parser* %.t20)
  store i64 %.t21, i64* %s
  %.r3841 = load i64, i64* %s
  %.t22 = icmp slt i64 %.r3841, 0
  br i1 %.t22, label %if_then_0_16, label %if_next_0_17
if_then_0_16:
  %.t23 = bitcast %Parser* %self to %Parser*
  call void @Parser__synchronize_to_next_stmt(%Parser* %.t23)
  br label %if_end_15
if_next_0_17:
  %.p3842 = getelementptr i64, i64* null, i32 1
  %.r3843 = ptrtoint i64* %.p3842 to i64
  %.p3844 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stmts, i32 0, i32 0
  %.p3845 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stmts, i32 0, i32 1
  %.p3846 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %stmts, i32 0, i32 2
  %.r3847 = load i64, i64* %.p3844
  %.r3848 = load i64, i64* %.p3845
  %.r3849 = icmp sge i64 %.r3847, %.r3848
  br i1 %.r3849, label %append.grow.3850, label %append.after.3851
append.grow.3850:
  %.r3852 = load i64*, i64** %.p3846
  %.r3853 = icmp eq i64 %.r3848, 0
  %.r3854 = mul i64 %.r3848, 2
  %.r3855 = select i1 %.r3853, i64 1, i64 %.r3854
  %.r3856 = mul i64 %.r3855, %.r3843
  %.p3857 = call i8* @malloc(i64 %.r3856)
  %.p3858 = bitcast i8* %.p3857 to i64*
  %.r3859 = mul i64 %.r3847, %.r3843
  %.p3860 = bitcast i64* %.r3852 to i8*
  call i8* @memcpy(i8* %.p3857, i8* %.p3860, i64 %.r3859)
  call void @free(i8* %.p3860)
  store i64* %.p3858, i64** %.p3846
  store i64 %.r3855, i64* %.p3845
  br label %append.after.3851
append.after.3851:
  %.r3861 = load i64*, i64** %.p3846
  %.r3862 = load i64, i64* %s
  %.p3863 = getelementptr inbounds i64, i64* %.r3861, i64 %.r3847
  store i64 %.r3862, i64* %.p3863
  %.r3864 = add i64 %.r3847, 1
  store i64 %.r3864, i64* %.p3844
  br label %if_end_15
if_end_15:
  br label %while_cond_6
while_end_8:
  %.t24 = bitcast %Parser* %self to %Parser*
  %.p3865 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.222, i64 0, i64 0
  %.t25 = call i64 @Parser__expect(%Parser* %.t24, i8* %.p3865)
  store i64 %.t25, i64* %et
  %.r3866 = load i64, i64* %et
  %.t26 = icmp slt i64 %.r3866, 0
  br i1 %.t26, label %if_then_0_19, label %if_next_0_20
if_then_0_19:
  %.t27 = sub i64 0, 1
  ret i64 %.t27
if_next_0_20:
  br label %if_end_18
if_end_18:
  %__fld.28 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t29 = bitcast %Ast* %__fld.28 to %Ast*
  %.t31 = bitcast %Span* %start to %Span*
  %.t33 = bitcast %Parser* %self to %Parser*
  %.r3867 = load i64, i64* %et
  call void @Parser__tspan(%Span* %__agg.32, %Parser* %.t33, i64 %.r3867)
  %.t34 = bitcast %Span* %__agg.32 to %Span*
  call void @span_to(%Span* %__agg.30, %Span* %.t31, %Span* %.t34)
  %.t35 = bitcast %Span* %__agg.30 to %Span*
  %.t36 = bitcast { i64, i64, i64* }* %stmts to { i64, i64, i64* }*
  %.p3868 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.293, i64 0, i64 0
  %.p3869 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.t37 = call i64 @Ast__addl(%Ast* %.t29, i8* %.p3868, i8* %.p3869, %Span* %.t35, { i64, i64, i64* }* %.t36)
  ret i64 %.t37
}

define i64 @Parser__parse_statement(%Parser* %self) {
entry:
  %k = alloca i8*
  %t = alloca i64
  %__agg.14 = alloca %Span
  %__agg.27 = alloca %Span
  %__sc.55 = alloca i1
  %__sc.61 = alloca i1
  %__sc.67 = alloca i1
  %e = alloca i64
  %__agg.82 = alloca %Span
  %.t0 = bitcast %Parser* %self to %Parser*
  %.t1 = call i8* @Parser__peek(%Parser* %.t0)
  store i8* %.t1, i8** %k
  %.r3870 = load i8*, i8** %k
  %.p3871 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.18, i64 0, i64 0
  %.r3872 = call i32 @strcmp(i8* %.r3870, i8* %.p3871)
  %.t2 = icmp eq i32 %.r3872, 0
  br i1 %.t2, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t3 = bitcast %Parser* %self to %Parser*
  %.t4 = call i64 @Parser__parse_return(%Parser* %.t3)
  ret i64 %.t4
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.r3873 = load i8*, i8** %k
  %.p3874 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.38, i64 0, i64 0
  %.r3875 = call i32 @strcmp(i8* %.r3873, i8* %.p3874)
  %.t5 = icmp eq i32 %.r3875, 0
  br i1 %.t5, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.t6 = bitcast %Parser* %self to %Parser*
  %.t7 = call i64 @Parser__advance(%Parser* %.t6)
  store i64 %.t7, i64* %t
  %.t8 = bitcast %Parser* %self to %Parser*
  %.p3876 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.t9 = call i64 @Parser__expect(%Parser* %.t8, i8* %.p3876)
  %.t10 = icmp slt i64 %.t9, 0
  br i1 %.t10, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.t11 = sub i64 0, 1
  ret i64 %.t11
if_next_0_8:
  br label %if_end_6
if_end_6:
  %__fld.12 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t13 = bitcast %Ast* %__fld.12 to %Ast*
  %.t15 = bitcast %Parser* %self to %Parser*
  %.r3877 = load i64, i64* %t
  call void @Parser__tspan(%Span* %__agg.14, %Parser* %.t15, i64 %.r3877)
  %.t16 = bitcast %Span* %__agg.14 to %Span*
  %.p3878 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.38, i64 0, i64 0
  %.p3879 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.t17 = call i64 @Ast__add0(%Ast* %.t13, i8* %.p3878, i8* %.p3879, %Span* %.t16)
  ret i64 %.t17
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.r3880 = load i8*, i8** %k
  %.p3881 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.40, i64 0, i64 0
  %.r3882 = call i32 @strcmp(i8* %.r3880, i8* %.p3881)
  %.t18 = icmp eq i32 %.r3882, 0
  br i1 %.t18, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.t19 = bitcast %Parser* %self to %Parser*
  %.t20 = call i64 @Parser__advance(%Parser* %.t19)
  store i64 %.t20, i64* %t
  %.t21 = bitcast %Parser* %self to %Parser*
  %.p3883 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.t22 = call i64 @Parser__expect(%Parser* %.t21, i8* %.p3883)
  %.t23 = icmp slt i64 %.t22, 0
  br i1 %.t23, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  %.t24 = sub i64 0, 1
  ret i64 %.t24
if_next_0_14:
  br label %if_end_12
if_end_12:
  %__fld.25 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t26 = bitcast %Ast* %__fld.25 to %Ast*
  %.t28 = bitcast %Parser* %self to %Parser*
  %.r3884 = load i64, i64* %t
  call void @Parser__tspan(%Span* %__agg.27, %Parser* %.t28, i64 %.r3884)
  %.t29 = bitcast %Span* %__agg.27 to %Span*
  %.p3885 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.40, i64 0, i64 0
  %.p3886 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.t30 = call i64 @Ast__add0(%Ast* %.t26, i8* %.p3885, i8* %.p3886, %Span* %.t29)
  ret i64 %.t30
if_next_0_11:
  br label %if_end_9
if_end_9:
  %.r3887 = load i8*, i8** %k
  %.p3888 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.20, i64 0, i64 0
  %.r3889 = call i32 @strcmp(i8* %.r3887, i8* %.p3888)
  %.t31 = icmp eq i32 %.r3889, 0
  br i1 %.t31, label %if_then_0_16, label %if_next_0_17
if_then_0_16:
  %.t32 = bitcast %Parser* %self to %Parser*
  %.t33 = call i64 @Parser__parse_if(%Parser* %.t32)
  ret i64 %.t33
if_next_0_17:
  br label %if_end_15
if_end_15:
  %.r3890 = load i8*, i8** %k
  %.p3891 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.26, i64 0, i64 0
  %.r3892 = call i32 @strcmp(i8* %.r3890, i8* %.p3891)
  %.t34 = icmp eq i32 %.r3892, 0
  br i1 %.t34, label %if_then_0_19, label %if_next_0_20
if_then_0_19:
  %.t35 = bitcast %Parser* %self to %Parser*
  %.p3893 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.26, i64 0, i64 0
  %.t36 = call i64 @Parser__parse_cond_loop(%Parser* %.t35, i8* %.p3893)
  ret i64 %.t36
if_next_0_20:
  br label %if_end_18
if_end_18:
  %.r3894 = load i8*, i8** %k
  %.p3895 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.58, i64 0, i64 0
  %.r3896 = call i32 @strcmp(i8* %.r3894, i8* %.p3895)
  %.t37 = icmp eq i32 %.r3896, 0
  br i1 %.t37, label %if_then_0_22, label %if_next_0_23
if_then_0_22:
  %.t38 = bitcast %Parser* %self to %Parser*
  %.t39 = call i64 @Parser__parse_match(%Parser* %.t38)
  ret i64 %.t39
if_next_0_23:
  br label %if_end_21
if_end_21:
  %.r3897 = load i8*, i8** %k
  %.p3898 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.28, i64 0, i64 0
  %.r3899 = call i32 @strcmp(i8* %.r3897, i8* %.p3898)
  %.t40 = icmp eq i32 %.r3899, 0
  br i1 %.t40, label %if_then_0_25, label %if_next_0_26
if_then_0_25:
  %.t41 = bitcast %Parser* %self to %Parser*
  %.p3900 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.28, i64 0, i64 0
  %.t42 = call i64 @Parser__parse_cond_loop(%Parser* %.t41, i8* %.p3900)
  ret i64 %.t42
if_next_0_26:
  br label %if_end_24
if_end_24:
  %.r3901 = load i8*, i8** %k
  %.p3902 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.30, i64 0, i64 0
  %.r3903 = call i32 @strcmp(i8* %.r3901, i8* %.p3902)
  %.t43 = icmp eq i32 %.r3903, 0
  br i1 %.t43, label %if_then_0_28, label %if_next_0_29
if_then_0_28:
  %.t44 = bitcast %Parser* %self to %Parser*
  %.p3904 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.30, i64 0, i64 0
  %.t45 = call i64 @Parser__parse_body_stmt(%Parser* %.t44, i8* %.p3904)
  ret i64 %.t45
if_next_0_29:
  br label %if_end_27
if_end_27:
  %.r3905 = load i8*, i8** %k
  %.p3906 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.32, i64 0, i64 0
  %.r3907 = call i32 @strcmp(i8* %.r3905, i8* %.p3906)
  %.t46 = icmp eq i32 %.r3907, 0
  br i1 %.t46, label %if_then_0_31, label %if_next_0_32
if_then_0_31:
  %.t47 = bitcast %Parser* %self to %Parser*
  %.t48 = call i64 @Parser__parse_for(%Parser* %.t47)
  ret i64 %.t48
if_next_0_32:
  br label %if_end_30
if_end_30:
  %.r3908 = load i8*, i8** %k
  %.p3909 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.42, i64 0, i64 0
  %.r3910 = call i32 @strcmp(i8* %.r3908, i8* %.p3909)
  %.t49 = icmp eq i32 %.r3910, 0
  br i1 %.t49, label %if_then_0_34, label %if_next_0_35
if_then_0_34:
  %.t50 = bitcast %Parser* %self to %Parser*
  %.t51 = call i64 @Parser__parse_try(%Parser* %.t50)
  ret i64 %.t51
if_next_0_35:
  br label %if_end_33
if_end_33:
  %.r3911 = load i8*, i8** %k
  %.p3912 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.64, i64 0, i64 0
  %.r3913 = call i32 @strcmp(i8* %.r3911, i8* %.p3912)
  %.t52 = icmp eq i32 %.r3913, 0
  br i1 %.t52, label %if_then_0_37, label %if_next_0_38
if_then_0_37:
  %.t53 = bitcast %Parser* %self to %Parser*
  %.p3914 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.64, i64 0, i64 0
  %.t54 = call i64 @Parser__parse_body_stmt(%Parser* %.t53, i8* %.p3914)
  ret i64 %.t54
if_next_0_38:
  br label %if_end_36
if_end_36:
  %.r3915 = load i8*, i8** %k
  %.p3916 = getelementptr inbounds [11 x i8], [11 x i8]* @.str.101, i64 0, i64 0
  %.r3917 = call i32 @strcmp(i8* %.r3915, i8* %.p3916)
  %.t56 = icmp eq i32 %.r3917, 0
  br i1 %.t56, label %sc_rhs_42, label %sc_short_43
sc_rhs_42:
  %.t57 = bitcast %Parser* %self to %Parser*
  %.t58 = call i1 @Parser__looks_like_unpack(%Parser* %.t57)
  store i1 %.t58, i1* %__sc.55
  br label %sc_end_44
sc_short_43:
  store i1 false, i1* %__sc.55
  br label %sc_end_44
sc_end_44:
  %.r3918 = load i1, i1* %__sc.55
  br i1 %.r3918, label %if_then_0_40, label %if_next_0_41
if_then_0_40:
  %.t59 = bitcast %Parser* %self to %Parser*
  %.t60 = call i64 @Parser__parse_unpack(%Parser* %.t59)
  ret i64 %.t60
if_next_0_41:
  br label %if_end_39
if_end_39:
  %.r3919 = load i8*, i8** %k
  %.p3920 = getelementptr inbounds [11 x i8], [11 x i8]* @.str.101, i64 0, i64 0
  %.r3921 = call i32 @strcmp(i8* %.r3919, i8* %.p3920)
  %.t62 = icmp eq i32 %.r3921, 0
  br i1 %.t62, label %sc_rhs_48, label %sc_short_49
sc_rhs_48:
  %.t63 = bitcast %Parser* %self to %Parser*
  %.t64 = call i1 @Parser__looks_like_assignment(%Parser* %.t63)
  store i1 %.t64, i1* %__sc.61
  br label %sc_end_50
sc_short_49:
  store i1 false, i1* %__sc.61
  br label %sc_end_50
sc_end_50:
  %.r3922 = load i1, i1* %__sc.61
  br i1 %.r3922, label %if_then_0_46, label %if_next_0_47
if_then_0_46:
  %.t65 = bitcast %Parser* %self to %Parser*
  %.t66 = call i64 @Parser__parse_assign(%Parser* %.t65)
  ret i64 %.t66
if_next_0_47:
  br label %if_end_45
if_end_45:
  %.r3923 = load i8*, i8** %k
  %.p3924 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.166, i64 0, i64 0
  %.r3925 = call i32 @strcmp(i8* %.r3923, i8* %.p3924)
  %.t68 = icmp eq i32 %.r3925, 0
  br i1 %.t68, label %sc_short_55, label %sc_rhs_54
sc_rhs_54:
  %.r3926 = load i8*, i8** %k
  %.p3927 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.142, i64 0, i64 0
  %.r3928 = call i32 @strcmp(i8* %.r3926, i8* %.p3927)
  %.t69 = icmp eq i32 %.r3928, 0
  store i1 %.t69, i1* %__sc.67
  br label %sc_end_56
sc_short_55:
  store i1 true, i1* %__sc.67
  br label %sc_end_56
sc_end_56:
  %.r3929 = load i1, i1* %__sc.67
  br i1 %.r3929, label %if_then_0_52, label %if_next_0_53
if_then_0_52:
  %.t70 = bitcast %Parser* %self to %Parser*
  %.t71 = call i64 @Parser__parse_expr_led_statement(%Parser* %.t70)
  ret i64 %.t71
if_next_0_53:
  br label %if_end_51
if_end_51:
  %.t72 = bitcast %Parser* %self to %Parser*
  %.t73 = call i64 @Parser__parse_expr(%Parser* %.t72)
  store i64 %.t73, i64* %e
  %.r3930 = load i64, i64* %e
  %.t74 = icmp slt i64 %.r3930, 0
  br i1 %.t74, label %if_then_0_58, label %if_next_0_59
if_then_0_58:
  %.t75 = sub i64 0, 1
  ret i64 %.t75
if_next_0_59:
  br label %if_end_57
if_end_57:
  %.t76 = bitcast %Parser* %self to %Parser*
  %.p3931 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.t77 = call i64 @Parser__expect(%Parser* %.t76, i8* %.p3931)
  %.t78 = icmp slt i64 %.t77, 0
  br i1 %.t78, label %if_then_0_61, label %if_next_0_62
if_then_0_61:
  %.t79 = sub i64 0, 1
  ret i64 %.t79
if_next_0_62:
  br label %if_end_60
if_end_60:
  %__fld.80 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t81 = bitcast %Ast* %__fld.80 to %Ast*
  %__fld.83 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t84 = bitcast %Ast* %__fld.83 to %Ast*
  %.r3932 = load i64, i64* %e
  call void @Ast__span_of(%Span* %__agg.82, %Ast* %.t84, i64 %.r3932)
  %.t85 = bitcast %Span* %__agg.82 to %Span*
  %.p3933 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.294, i64 0, i64 0
  %.p3934 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.r3935 = load i64, i64* %e
  %.t86 = call i64 @Ast__add1(%Ast* %.t81, i8* %.p3933, i8* %.p3934, %Span* %.t85, i64 %.r3935)
  ret i64 %.t86
}

define i1 @Parser__looks_like_unpack(%Parser* %self) {
entry:
  %i = alloca i64
  %count = alloca i64
  %t = alloca i8*
  %.p3936 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 1
  %.t0 = load i64, i64* %.p3936
  store i64 %.t0, i64* %i
  store i64 0, i64* %count
  br label %while_cond_0
while_cond_0:
  br i1 true, label %while_body_1, label %while_end_2
while_body_1:
  %.t1 = bitcast %Parser* %self to %Parser*
  %.r3937 = load i64, i64* %i
  %.t2 = call i8* @Parser__token_at(%Parser* %.t1, i64 %.r3937)
  %.p3938 = getelementptr inbounds [11 x i8], [11 x i8]* @.str.101, i64 0, i64 0
  %.r3939 = call i32 @strcmp(i8* %.t2, i8* %.p3938)
  %.t3 = icmp ne i32 %.r3939, 0
  br i1 %.t3, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  ret i1 false
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.r3940 = load i64, i64* %count
  %.t4 = add i64 %.r3940, 1
  store i64 %.t4, i64* %count
  %.r3941 = load i64, i64* %i
  %.t5 = add i64 %.r3941, 1
  store i64 %.t5, i64* %i
  %.t6 = bitcast %Parser* %self to %Parser*
  %.r3942 = load i64, i64* %i
  %.t7 = call i8* @Parser__token_at(%Parser* %.t6, i64 %.r3942)
  store i8* %.t7, i8** %t
  %.r3943 = load i8*, i8** %t
  %.p3944 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.154, i64 0, i64 0
  %.r3945 = call i32 @strcmp(i8* %.r3943, i8* %.p3944)
  %.t8 = icmp eq i32 %.r3945, 0
  br i1 %.t8, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.r3946 = load i64, i64* %i
  %.t9 = add i64 %.r3946, 1
  store i64 %.t9, i64* %i
  br label %if_end_6
if_next_0_8:
  %.r3947 = load i8*, i8** %t
  %.p3948 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.184, i64 0, i64 0
  %.r3949 = call i32 @strcmp(i8* %.r3947, i8* %.p3948)
  %.t10 = icmp eq i32 %.r3949, 0
  br i1 %.t10, label %if_then_1_9, label %if_next_1_10
if_then_1_9:
  %.r3950 = load i64, i64* %count
  %.t11 = icmp sge i64 %.r3950, 2
  ret i1 %.t11
if_next_1_10:
  ret i1 false
if_end_6:
  br label %while_cond_0
while_end_2:
  ret i1 false
}

define i64 @Parser__parse_unpack(%Parser* %self) {
entry:
  %start = alloca %Span
  %targets = alloca { i64, i64, i64* }
  %t = alloca i64
  %__agg.9 = alloca %Span
  %value = alloca i64
  %tl = alloca i64
  %__agg.38 = alloca %Span
  %__agg.36 = alloca %Span
  %.t0 = bitcast %Parser* %self to %Parser*
  call void @Parser__peek_span(%Span* %start, %Parser* %.t0)
  %.p3952 = getelementptr i64, i64* null, i32 1
  %.r3953 = ptrtoint i64* %.p3952 to i64
  %.r3954 = mul i64 %.r3953, 1
  %.p3951 = call i8* @malloc(i64 %.r3954)
  %.p3955 = bitcast i8* %.p3951 to i64*
  %.p3956 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %targets, i32 0, i32 0
  store i64 0, i64* %.p3956
  %.p3957 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %targets, i32 0, i32 1
  store i64 0, i64* %.p3957
  %.p3958 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %targets, i32 0, i32 2
  store i64* %.p3955, i64** %.p3958
  br label %while_cond_0
while_cond_0:
  br i1 true, label %while_body_1, label %while_end_2
while_body_1:
  %.t1 = bitcast %Parser* %self to %Parser*
  %.t2 = call i64 @Parser__expect_identifier(%Parser* %.t1)
  store i64 %.t2, i64* %t
  %.r3959 = load i64, i64* %t
  %.t3 = icmp slt i64 %.r3959, 0
  br i1 %.t3, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.t4 = sub i64 0, 1
  ret i64 %.t4
if_next_0_5:
  br label %if_end_3
if_end_3:
  %__fld.5 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t6 = bitcast %Ast* %__fld.5 to %Ast*
  %.t7 = bitcast %Parser* %self to %Parser*
  %.r3960 = load i64, i64* %t
  %.t8 = call i8* @Parser__ttext(%Parser* %.t7, i64 %.r3960)
  %.t10 = bitcast %Parser* %self to %Parser*
  %.r3961 = load i64, i64* %t
  call void @Parser__tspan(%Span* %__agg.9, %Parser* %.t10, i64 %.r3961)
  %.t11 = bitcast %Span* %__agg.9 to %Span*
  %.p3962 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.257, i64 0, i64 0
  %.t12 = call i64 @Ast__add0(%Ast* %.t6, i8* %.p3962, i8* %.t8, %Span* %.t11)
  %.p3963 = getelementptr i64, i64* null, i32 1
  %.r3964 = ptrtoint i64* %.p3963 to i64
  %.p3965 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %targets, i32 0, i32 0
  %.p3966 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %targets, i32 0, i32 1
  %.p3967 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %targets, i32 0, i32 2
  %.r3968 = load i64, i64* %.p3965
  %.r3969 = load i64, i64* %.p3966
  %.r3970 = icmp sge i64 %.r3968, %.r3969
  br i1 %.r3970, label %append.grow.3971, label %append.after.3972
append.grow.3971:
  %.r3973 = load i64*, i64** %.p3967
  %.r3974 = icmp eq i64 %.r3969, 0
  %.r3975 = mul i64 %.r3969, 2
  %.r3976 = select i1 %.r3974, i64 1, i64 %.r3975
  %.r3977 = mul i64 %.r3976, %.r3964
  %.p3978 = call i8* @malloc(i64 %.r3977)
  %.p3979 = bitcast i8* %.p3978 to i64*
  %.r3980 = mul i64 %.r3968, %.r3964
  %.p3981 = bitcast i64* %.r3973 to i8*
  call i8* @memcpy(i8* %.p3978, i8* %.p3981, i64 %.r3980)
  call void @free(i8* %.p3981)
  store i64* %.p3979, i64** %.p3967
  store i64 %.r3976, i64* %.p3966
  br label %append.after.3972
append.after.3972:
  %.r3982 = load i64*, i64** %.p3967
  %.p3983 = getelementptr inbounds i64, i64* %.r3982, i64 %.r3968
  store i64 %.t12, i64* %.p3983
  %.r3984 = add i64 %.r3968, 1
  store i64 %.r3984, i64* %.p3965
  %.t13 = bitcast %Parser* %self to %Parser*
  %.p3985 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.154, i64 0, i64 0
  %.t14 = call i1 @Parser__at(%Parser* %.t13, i8* %.p3985)
  br i1 %.t14, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.t15 = bitcast %Parser* %self to %Parser*
  %.t16 = call i64 @Parser__advance(%Parser* %.t15)
  br label %if_end_6
if_next_0_8:
  br label %while_end_2
if_end_6:
  br label %while_cond_0
while_end_2:
  %.t17 = bitcast %Parser* %self to %Parser*
  %.p3986 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.184, i64 0, i64 0
  %.t18 = call i64 @Parser__expect(%Parser* %.t17, i8* %.p3986)
  %.t19 = icmp slt i64 %.t18, 0
  br i1 %.t19, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.t20 = sub i64 0, 1
  ret i64 %.t20
if_next_0_11:
  br label %if_end_9
if_end_9:
  %.t21 = bitcast %Parser* %self to %Parser*
  %.t22 = call i64 @Parser__parse_expr(%Parser* %.t21)
  store i64 %.t22, i64* %value
  %.r3987 = load i64, i64* %value
  %.t23 = icmp slt i64 %.r3987, 0
  br i1 %.t23, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  %.t24 = sub i64 0, 1
  ret i64 %.t24
if_next_0_14:
  br label %if_end_12
if_end_12:
  %.t25 = bitcast %Parser* %self to %Parser*
  %.p3988 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.t26 = call i64 @Parser__expect(%Parser* %.t25, i8* %.p3988)
  %.t27 = icmp slt i64 %.t26, 0
  br i1 %.t27, label %if_then_0_16, label %if_next_0_17
if_then_0_16:
  %.t28 = sub i64 0, 1
  ret i64 %.t28
if_next_0_17:
  br label %if_end_15
if_end_15:
  %__fld.29 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t30 = bitcast %Ast* %__fld.29 to %Ast*
  %.t31 = bitcast %Span* %start to %Span*
  %.t32 = bitcast { i64, i64, i64* }* %targets to { i64, i64, i64* }*
  %.p3989 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.255, i64 0, i64 0
  %.p3990 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.t33 = call i64 @Ast__addl(%Ast* %.t30, i8* %.p3989, i8* %.p3990, %Span* %.t31, { i64, i64, i64* }* %.t32)
  store i64 %.t33, i64* %tl
  %__fld.34 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t35 = bitcast %Ast* %__fld.34 to %Ast*
  %.t37 = bitcast %Span* %start to %Span*
  %__fld.39 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t40 = bitcast %Ast* %__fld.39 to %Ast*
  %.r3991 = load i64, i64* %value
  call void @Ast__span_of(%Span* %__agg.38, %Ast* %.t40, i64 %.r3991)
  %.t41 = bitcast %Span* %__agg.38 to %Span*
  call void @span_to(%Span* %__agg.36, %Span* %.t37, %Span* %.t41)
  %.t42 = bitcast %Span* %__agg.36 to %Span*
  %.p3992 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.295, i64 0, i64 0
  %.p3993 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.r3994 = load i64, i64* %tl
  %.r3995 = load i64, i64* %value
  %.t43 = call i64 @Ast__add2(%Ast* %.t35, i8* %.p3992, i8* %.p3993, %Span* %.t42, i64 %.r3994, i64 %.r3995)
  ret i64 %.t43
}

define i1 @Parser__looks_like_assignment(%Parser* %self) {
entry:
  %i = alloca i64
  %t = alloca i8*
  %depth = alloca i64
  %u = alloca i8*
  %__sc.22 = alloca i1
  %t2 = alloca i8*
  %__sc.28 = alloca i1
  %__sc.29 = alloca i1
  %__sc.30 = alloca i1
  %__sc.31 = alloca i1
  %__sc.32 = alloca i1
  %__sc.33 = alloca i1
  %__sc.34 = alloca i1
  %__sc.35 = alloca i1
  %__sc.36 = alloca i1
  %__sc.37 = alloca i1
  %__sc.38 = alloca i1
  %.p3996 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 1
  %.t0 = load i64, i64* %.p3996
  store i64 %.t0, i64* %i
  %.t1 = bitcast %Parser* %self to %Parser*
  %.t2 = call i8* @Parser__peek_at(%Parser* %.t1, i64 0)
  %.p3997 = getelementptr inbounds [11 x i8], [11 x i8]* @.str.101, i64 0, i64 0
  %.r3998 = call i32 @strcmp(i8* %.t2, i8* %.p3997)
  %.t3 = icmp ne i32 %.r3998, 0
  br i1 %.t3, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  ret i1 false
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.r3999 = load i64, i64* %i
  %.t4 = add i64 %.r3999, 1
  store i64 %.t4, i64* %i
  br label %while_cond_3
while_cond_3:
  br i1 true, label %while_body_4, label %while_end_5
while_body_4:
  %.t5 = bitcast %Parser* %self to %Parser*
  %.r4000 = load i64, i64* %i
  %.t6 = call i8* @Parser__token_at(%Parser* %.t5, i64 %.r4000)
  store i8* %.t6, i8** %t
  %.r4001 = load i8*, i8** %t
  %.p4002 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.158, i64 0, i64 0
  %.r4003 = call i32 @strcmp(i8* %.r4001, i8* %.p4002)
  %.t7 = icmp eq i32 %.r4003, 0
  br i1 %.t7, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.t8 = bitcast %Parser* %self to %Parser*
  %.r4004 = load i64, i64* %i
  %.t9 = add i64 %.r4004, 1
  %.t10 = call i8* @Parser__token_at(%Parser* %.t8, i64 %.t9)
  %.p4005 = getelementptr inbounds [11 x i8], [11 x i8]* @.str.101, i64 0, i64 0
  %.r4006 = call i32 @strcmp(i8* %.t10, i8* %.p4005)
  %.t11 = icmp eq i32 %.r4006, 0
  br i1 %.t11, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.r4007 = load i64, i64* %i
  %.t12 = add i64 %.r4007, 2
  store i64 %.t12, i64* %i
  br label %while_cond_3
if_next_0_11:
  br label %if_end_9
if_end_9:
  br label %while_end_5
if_next_0_8:
  %.r4008 = load i8*, i8** %t
  %.p4009 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.146, i64 0, i64 0
  %.r4010 = call i32 @strcmp(i8* %.r4008, i8* %.p4009)
  %.t13 = icmp eq i32 %.r4010, 0
  br i1 %.t13, label %if_then_1_12, label %if_next_1_13
if_then_1_12:
  store i64 1, i64* %depth
  %.r4011 = load i64, i64* %i
  %.t14 = add i64 %.r4011, 1
  store i64 %.t14, i64* %i
  br label %while_cond_14
while_cond_14:
  %.r4012 = load i64, i64* %depth
  %.t15 = icmp sgt i64 %.r4012, 0
  br i1 %.t15, label %while_body_15, label %while_end_16
while_body_15:
  %.t16 = bitcast %Parser* %self to %Parser*
  %.r4013 = load i64, i64* %i
  %.t17 = call i8* @Parser__token_at(%Parser* %.t16, i64 %.r4013)
  store i8* %.t17, i8** %u
  %.r4014 = load i8*, i8** %u
  %.p4015 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.146, i64 0, i64 0
  %.r4016 = call i32 @strcmp(i8* %.r4014, i8* %.p4015)
  %.t18 = icmp eq i32 %.r4016, 0
  br i1 %.t18, label %if_then_0_18, label %if_next_0_19
if_then_0_18:
  %.r4017 = load i64, i64* %depth
  %.t19 = add i64 %.r4017, 1
  store i64 %.t19, i64* %depth
  br label %if_end_17
if_next_0_19:
  %.r4018 = load i8*, i8** %u
  %.p4019 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.148, i64 0, i64 0
  %.r4020 = call i32 @strcmp(i8* %.r4018, i8* %.p4019)
  %.t20 = icmp eq i32 %.r4020, 0
  br i1 %.t20, label %if_then_1_20, label %if_next_1_21
if_then_1_20:
  %.r4021 = load i64, i64* %depth
  %.t21 = sub i64 %.r4021, 1
  store i64 %.t21, i64* %depth
  br label %if_end_17
if_next_1_21:
  %.r4022 = load i8*, i8** %u
  %.p4023 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.224, i64 0, i64 0
  %.r4024 = call i32 @strcmp(i8* %.r4022, i8* %.p4023)
  %.t23 = icmp eq i32 %.r4024, 0
  br i1 %.t23, label %sc_short_25, label %sc_rhs_24
sc_rhs_24:
  %.r4025 = load i8*, i8** %u
  %.p4026 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.r4027 = call i32 @strcmp(i8* %.r4025, i8* %.p4026)
  %.t24 = icmp eq i32 %.r4027, 0
  store i1 %.t24, i1* %__sc.22
  br label %sc_end_26
sc_short_25:
  store i1 true, i1* %__sc.22
  br label %sc_end_26
sc_end_26:
  %.r4028 = load i1, i1* %__sc.22
  br i1 %.r4028, label %if_then_2_22, label %if_next_2_23
if_then_2_22:
  ret i1 false
if_next_2_23:
  br label %if_end_17
if_end_17:
  %.r4029 = load i64, i64* %i
  %.t25 = add i64 %.r4029, 1
  store i64 %.t25, i64* %i
  br label %while_cond_14
while_end_16:
  br label %while_cond_3
if_next_1_13:
  br label %while_end_5
if_end_6:
  br label %while_cond_3
while_end_5:
  %.t26 = bitcast %Parser* %self to %Parser*
  %.r4030 = load i64, i64* %i
  %.t27 = call i8* @Parser__token_at(%Parser* %.t26, i64 %.r4030)
  store i8* %.t27, i8** %t2
  %.r4031 = load i8*, i8** %t2
  %.p4032 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.184, i64 0, i64 0
  %.r4033 = call i32 @strcmp(i8* %.r4031, i8* %.p4032)
  %.t39 = icmp eq i32 %.r4033, 0
  br i1 %.t39, label %sc_short_28, label %sc_rhs_27
sc_rhs_27:
  %.r4034 = load i8*, i8** %t2
  %.p4035 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.156, i64 0, i64 0
  %.r4036 = call i32 @strcmp(i8* %.r4034, i8* %.p4035)
  %.t40 = icmp eq i32 %.r4036, 0
  store i1 %.t40, i1* %__sc.38
  br label %sc_end_29
sc_short_28:
  store i1 true, i1* %__sc.38
  br label %sc_end_29
sc_end_29:
  %.r4037 = load i1, i1* %__sc.38
  br i1 %.r4037, label %sc_short_31, label %sc_rhs_30
sc_rhs_30:
  %.r4038 = load i8*, i8** %t2
  %.p4039 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.198, i64 0, i64 0
  %.r4040 = call i32 @strcmp(i8* %.r4038, i8* %.p4039)
  %.t41 = icmp eq i32 %.r4040, 0
  store i1 %.t41, i1* %__sc.37
  br label %sc_end_32
sc_short_31:
  store i1 true, i1* %__sc.37
  br label %sc_end_32
sc_end_32:
  %.r4041 = load i1, i1* %__sc.37
  br i1 %.r4041, label %sc_short_34, label %sc_rhs_33
sc_rhs_33:
  %.r4042 = load i8*, i8** %t2
  %.p4043 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.200, i64 0, i64 0
  %.r4044 = call i32 @strcmp(i8* %.r4042, i8* %.p4043)
  %.t42 = icmp eq i32 %.r4044, 0
  store i1 %.t42, i1* %__sc.36
  br label %sc_end_35
sc_short_34:
  store i1 true, i1* %__sc.36
  br label %sc_end_35
sc_end_35:
  %.r4045 = load i1, i1* %__sc.36
  br i1 %.r4045, label %sc_short_37, label %sc_rhs_36
sc_rhs_36:
  %.r4046 = load i8*, i8** %t2
  %.p4047 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.202, i64 0, i64 0
  %.r4048 = call i32 @strcmp(i8* %.r4046, i8* %.p4047)
  %.t43 = icmp eq i32 %.r4048, 0
  store i1 %.t43, i1* %__sc.35
  br label %sc_end_38
sc_short_37:
  store i1 true, i1* %__sc.35
  br label %sc_end_38
sc_end_38:
  %.r4049 = load i1, i1* %__sc.35
  br i1 %.r4049, label %sc_short_40, label %sc_rhs_39
sc_rhs_39:
  %.r4050 = load i8*, i8** %t2
  %.p4051 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.204, i64 0, i64 0
  %.r4052 = call i32 @strcmp(i8* %.r4050, i8* %.p4051)
  %.t44 = icmp eq i32 %.r4052, 0
  store i1 %.t44, i1* %__sc.34
  br label %sc_end_41
sc_short_40:
  store i1 true, i1* %__sc.34
  br label %sc_end_41
sc_end_41:
  %.r4053 = load i1, i1* %__sc.34
  br i1 %.r4053, label %sc_short_43, label %sc_rhs_42
sc_rhs_42:
  %.r4054 = load i8*, i8** %t2
  %.p4055 = getelementptr inbounds [10 x i8], [10 x i8]* @.str.206, i64 0, i64 0
  %.r4056 = call i32 @strcmp(i8* %.r4054, i8* %.p4055)
  %.t45 = icmp eq i32 %.r4056, 0
  store i1 %.t45, i1* %__sc.33
  br label %sc_end_44
sc_short_43:
  store i1 true, i1* %__sc.33
  br label %sc_end_44
sc_end_44:
  %.r4057 = load i1, i1* %__sc.33
  br i1 %.r4057, label %sc_short_46, label %sc_rhs_45
sc_rhs_45:
  %.r4058 = load i8*, i8** %t2
  %.p4059 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.208, i64 0, i64 0
  %.r4060 = call i32 @strcmp(i8* %.r4058, i8* %.p4059)
  %.t46 = icmp eq i32 %.r4060, 0
  store i1 %.t46, i1* %__sc.32
  br label %sc_end_47
sc_short_46:
  store i1 true, i1* %__sc.32
  br label %sc_end_47
sc_end_47:
  %.r4061 = load i1, i1* %__sc.32
  br i1 %.r4061, label %sc_short_49, label %sc_rhs_48
sc_rhs_48:
  %.r4062 = load i8*, i8** %t2
  %.p4063 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.210, i64 0, i64 0
  %.r4064 = call i32 @strcmp(i8* %.r4062, i8* %.p4063)
  %.t47 = icmp eq i32 %.r4064, 0
  store i1 %.t47, i1* %__sc.31
  br label %sc_end_50
sc_short_49:
  store i1 true, i1* %__sc.31
  br label %sc_end_50
sc_end_50:
  %.r4065 = load i1, i1* %__sc.31
  br i1 %.r4065, label %sc_short_52, label %sc_rhs_51
sc_rhs_51:
  %.r4066 = load i8*, i8** %t2
  %.p4067 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.212, i64 0, i64 0
  %.r4068 = call i32 @strcmp(i8* %.r4066, i8* %.p4067)
  %.t48 = icmp eq i32 %.r4068, 0
  store i1 %.t48, i1* %__sc.30
  br label %sc_end_53
sc_short_52:
  store i1 true, i1* %__sc.30
  br label %sc_end_53
sc_end_53:
  %.r4069 = load i1, i1* %__sc.30
  br i1 %.r4069, label %sc_short_55, label %sc_rhs_54
sc_rhs_54:
  %.r4070 = load i8*, i8** %t2
  %.p4071 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.214, i64 0, i64 0
  %.r4072 = call i32 @strcmp(i8* %.r4070, i8* %.p4071)
  %.t49 = icmp eq i32 %.r4072, 0
  store i1 %.t49, i1* %__sc.29
  br label %sc_end_56
sc_short_55:
  store i1 true, i1* %__sc.29
  br label %sc_end_56
sc_end_56:
  %.r4073 = load i1, i1* %__sc.29
  br i1 %.r4073, label %sc_short_58, label %sc_rhs_57
sc_rhs_57:
  %.r4074 = load i8*, i8** %t2
  %.p4075 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.216, i64 0, i64 0
  %.r4076 = call i32 @strcmp(i8* %.r4074, i8* %.p4075)
  %.t50 = icmp eq i32 %.r4076, 0
  store i1 %.t50, i1* %__sc.28
  br label %sc_end_59
sc_short_58:
  store i1 true, i1* %__sc.28
  br label %sc_end_59
sc_end_59:
  %.t51 = load i1, i1* %__sc.28
  ret i1 %.t51
}

define i64 @Parser__expr_to_lvalue(%Parser* %self, i64 %e.arg) {
entry:
  %e = alloca i64
  %k = alloca i8*
  %sp = alloca %Span
  %__agg.11 = alloca %Span
  %__sc.36 = alloca i1
  store i64 %e.arg, i64* %e
  %__fld.0 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t1 = bitcast %Ast* %__fld.0 to %Ast*
  %.r4077 = load i64, i64* %e
  %.t2 = call i8* @Ast__kind_of(%Ast* %.t1, i64 %.r4077)
  store i8* %.t2, i8** %k
  %__fld.3 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t4 = bitcast %Ast* %__fld.3 to %Ast*
  %.r4078 = load i64, i64* %e
  call void @Ast__span_of(%Span* %sp, %Ast* %.t4, i64 %.r4078)
  %.r4079 = load i8*, i8** %k
  %.p4080 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.296, i64 0, i64 0
  %.r4081 = call i32 @strcmp(i8* %.r4079, i8* %.p4080)
  %.t5 = icmp eq i32 %.r4081, 0
  br i1 %.t5, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %__fld.6 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t7 = bitcast %Ast* %__fld.6 to %Ast*
  %__fld.8 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t9 = bitcast %Ast* %__fld.8 to %Ast*
  %.r4082 = load i64, i64* %e
  %.t10 = call i8* @Ast__text_of(%Ast* %.t9, i64 %.r4082)
  call void @span_dummy(%Span* %__agg.11)
  %.t12 = bitcast %Span* %__agg.11 to %Span*
  %.p4083 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.297, i64 0, i64 0
  %.t13 = call i64 @Ast__add0(%Ast* %.t7, i8* %.p4083, i8* %.t10, %Span* %.t12)
  ret i64 %.t13
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.r4084 = load i8*, i8** %k
  %.p4085 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.275, i64 0, i64 0
  %.r4086 = call i32 @strcmp(i8* %.r4084, i8* %.p4085)
  %.t14 = icmp eq i32 %.r4086, 0
  br i1 %.t14, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %__fld.15 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t16 = bitcast %Ast* %__fld.15 to %Ast*
  %__fld.17 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t18 = bitcast %Ast* %__fld.17 to %Ast*
  %.r4087 = load i64, i64* %e
  %.t19 = call i8* @Ast__text_of(%Ast* %.t18, i64 %.r4087)
  %.t20 = bitcast %Span* %sp to %Span*
  %__fld.21 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t22 = bitcast %Ast* %__fld.21 to %Ast*
  %.r4088 = load i64, i64* %e
  %.t23 = call i64 @Ast__kid(%Ast* %.t22, i64 %.r4088, i64 0)
  %.p4089 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.298, i64 0, i64 0
  %.t24 = call i64 @Ast__add1(%Ast* %.t16, i8* %.p4089, i8* %.t19, %Span* %.t20, i64 %.t23)
  ret i64 %.t24
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.r4090 = load i8*, i8** %k
  %.p4091 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.299, i64 0, i64 0
  %.r4092 = call i32 @strcmp(i8* %.r4090, i8* %.p4091)
  %.t25 = icmp eq i32 %.r4092, 0
  br i1 %.t25, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %__fld.26 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t27 = bitcast %Ast* %__fld.26 to %Ast*
  %.t28 = bitcast %Span* %sp to %Span*
  %__fld.29 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t30 = bitcast %Ast* %__fld.29 to %Ast*
  %.r4093 = load i64, i64* %e
  %.t31 = call i64 @Ast__kid(%Ast* %.t30, i64 %.r4093, i64 0)
  %__fld.32 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t33 = bitcast %Ast* %__fld.32 to %Ast*
  %.r4094 = load i64, i64* %e
  %.t34 = call i64 @Ast__kid(%Ast* %.t33, i64 %.r4094, i64 1)
  %.p4095 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.300, i64 0, i64 0
  %.p4096 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.t35 = call i64 @Ast__add2(%Ast* %.t27, i8* %.p4095, i8* %.p4096, %Span* %.t28, i64 %.t31, i64 %.t34)
  ret i64 %.t35
if_next_0_8:
  br label %if_end_6
if_end_6:
  %.r4097 = load i8*, i8** %k
  %.p4098 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.301, i64 0, i64 0
  %.r4099 = call i32 @strcmp(i8* %.r4097, i8* %.p4098)
  %.t37 = icmp eq i32 %.r4099, 0
  br i1 %.t37, label %sc_rhs_12, label %sc_short_13
sc_rhs_12:
  %__fld.38 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t39 = bitcast %Ast* %__fld.38 to %Ast*
  %.r4100 = load i64, i64* %e
  %.t40 = call i8* @Ast__text_of(%Ast* %.t39, i64 %.r4100)
  %.p4101 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.302, i64 0, i64 0
  %.r4102 = call i32 @strcmp(i8* %.t40, i8* %.p4101)
  %.t41 = icmp eq i32 %.r4102, 0
  store i1 %.t41, i1* %__sc.36
  br label %sc_end_14
sc_short_13:
  store i1 false, i1* %__sc.36
  br label %sc_end_14
sc_end_14:
  %.r4103 = load i1, i1* %__sc.36
  br i1 %.r4103, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %__fld.42 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t43 = bitcast %Ast* %__fld.42 to %Ast*
  %.t44 = bitcast %Span* %sp to %Span*
  %__fld.45 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t46 = bitcast %Ast* %__fld.45 to %Ast*
  %.r4104 = load i64, i64* %e
  %.t47 = call i64 @Ast__kid(%Ast* %.t46, i64 %.r4104, i64 0)
  %.p4105 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.303, i64 0, i64 0
  %.p4106 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.t48 = call i64 @Ast__add1(%Ast* %.t43, i8* %.p4105, i8* %.p4106, %Span* %.t44, i64 %.t47)
  ret i64 %.t48
if_next_0_11:
  br label %if_end_9
if_end_9:
  %.t49 = sub i64 0, 1
  ret i64 %.t49
}

define i64 @Parser__lvalue_to_expr(%Parser* %self, i64 %lv.arg, %Span* %fallback) {
entry:
  %lv = alloca i64
  %k = alloca i8*
  %sp = alloca %Span
  store i64 %lv.arg, i64* %lv
  %__fld.0 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t1 = bitcast %Ast* %__fld.0 to %Ast*
  %.r4107 = load i64, i64* %lv
  %.t2 = call i8* @Ast__kind_of(%Ast* %.t1, i64 %.r4107)
  store i8* %.t2, i8** %k
  %__fld.3 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t4 = bitcast %Ast* %__fld.3 to %Ast*
  %.r4108 = load i64, i64* %lv
  call void @Ast__span_of(%Span* %sp, %Ast* %.t4, i64 %.r4108)
  %.r4109 = load i8*, i8** %k
  %.p4110 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.297, i64 0, i64 0
  %.r4111 = call i32 @strcmp(i8* %.r4109, i8* %.p4110)
  %.t5 = icmp eq i32 %.r4111, 0
  br i1 %.t5, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %__fld.6 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t7 = bitcast %Ast* %__fld.6 to %Ast*
  %__fld.8 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t9 = bitcast %Ast* %__fld.8 to %Ast*
  %.r4112 = load i64, i64* %lv
  %.t10 = call i8* @Ast__text_of(%Ast* %.t9, i64 %.r4112)
  %.t11 = bitcast %Span* %fallback to %Span*
  %.p4113 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.296, i64 0, i64 0
  %.t12 = call i64 @Ast__add0(%Ast* %.t7, i8* %.p4113, i8* %.t10, %Span* %.t11)
  ret i64 %.t12
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.r4114 = load i8*, i8** %k
  %.p4115 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.298, i64 0, i64 0
  %.r4116 = call i32 @strcmp(i8* %.r4114, i8* %.p4115)
  %.t13 = icmp eq i32 %.r4116, 0
  br i1 %.t13, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %__fld.14 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t15 = bitcast %Ast* %__fld.14 to %Ast*
  %__fld.16 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t17 = bitcast %Ast* %__fld.16 to %Ast*
  %.r4117 = load i64, i64* %lv
  %.t18 = call i8* @Ast__text_of(%Ast* %.t17, i64 %.r4117)
  %.t19 = bitcast %Span* %sp to %Span*
  %__fld.20 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t21 = bitcast %Ast* %__fld.20 to %Ast*
  %.r4118 = load i64, i64* %lv
  %.t22 = call i64 @Ast__kid(%Ast* %.t21, i64 %.r4118, i64 0)
  %.p4119 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.275, i64 0, i64 0
  %.t23 = call i64 @Ast__add1(%Ast* %.t15, i8* %.p4119, i8* %.t18, %Span* %.t19, i64 %.t22)
  ret i64 %.t23
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.r4120 = load i8*, i8** %k
  %.p4121 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.300, i64 0, i64 0
  %.r4122 = call i32 @strcmp(i8* %.r4120, i8* %.p4121)
  %.t24 = icmp eq i32 %.r4122, 0
  br i1 %.t24, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %__fld.25 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t26 = bitcast %Ast* %__fld.25 to %Ast*
  %.t27 = bitcast %Span* %sp to %Span*
  %__fld.28 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t29 = bitcast %Ast* %__fld.28 to %Ast*
  %.r4123 = load i64, i64* %lv
  %.t30 = call i64 @Ast__kid(%Ast* %.t29, i64 %.r4123, i64 0)
  %__fld.31 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t32 = bitcast %Ast* %__fld.31 to %Ast*
  %.r4124 = load i64, i64* %lv
  %.t33 = call i64 @Ast__kid(%Ast* %.t32, i64 %.r4124, i64 1)
  %.p4125 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.299, i64 0, i64 0
  %.p4126 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.t34 = call i64 @Ast__add2(%Ast* %.t26, i8* %.p4125, i8* %.p4126, %Span* %.t27, i64 %.t30, i64 %.t33)
  ret i64 %.t34
if_next_0_8:
  br label %if_end_6
if_end_6:
  %__fld.35 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t36 = bitcast %Ast* %__fld.35 to %Ast*
  %.t37 = bitcast %Span* %sp to %Span*
  %__fld.38 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t39 = bitcast %Ast* %__fld.38 to %Ast*
  %.r4127 = load i64, i64* %lv
  %.t40 = call i64 @Ast__kid(%Ast* %.t39, i64 %.r4127, i64 0)
  %.p4128 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.301, i64 0, i64 0
  %.p4129 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.302, i64 0, i64 0
  %.t41 = call i64 @Ast__add1(%Ast* %.t36, i8* %.p4128, i8* %.p4129, %Span* %.t37, i64 %.t40)
  ret i64 %.t41
}

define i64 @Parser__parse_expr_led_statement(%Parser* %self) {
entry:
  %start_span = alloca %Span
  %target = alloca i64
  %value = alloca i64
  %__agg.18 = alloca %Span
  %span = alloca %Span
  %tspan = alloca %Span
  %lv = alloca i64
  %__agg.42 = alloca %Span
  %.t0 = bitcast %Parser* %self to %Parser*
  call void @Parser__peek_span(%Span* %start_span, %Parser* %.t0)
  %.t1 = bitcast %Parser* %self to %Parser*
  %.t2 = call i64 @Parser__parse_unary(%Parser* %.t1)
  store i64 %.t2, i64* %target
  %.r4130 = load i64, i64* %target
  %.t3 = icmp slt i64 %.r4130, 0
  br i1 %.t3, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t4 = sub i64 0, 1
  ret i64 %.t4
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.t5 = bitcast %Parser* %self to %Parser*
  %.p4131 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.184, i64 0, i64 0
  %.t6 = call i1 @Parser__at(%Parser* %.t5, i8* %.p4131)
  br i1 %.t6, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.t7 = bitcast %Parser* %self to %Parser*
  %.t8 = call i64 @Parser__advance(%Parser* %.t7)
  %.t9 = bitcast %Parser* %self to %Parser*
  %.t10 = call i64 @Parser__parse_expr(%Parser* %.t9)
  store i64 %.t10, i64* %value
  %.r4132 = load i64, i64* %value
  %.t11 = icmp slt i64 %.r4132, 0
  br i1 %.t11, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.t12 = sub i64 0, 1
  ret i64 %.t12
if_next_0_8:
  br label %if_end_6
if_end_6:
  %.t13 = bitcast %Parser* %self to %Parser*
  %.p4133 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.t14 = call i64 @Parser__expect(%Parser* %.t13, i8* %.p4133)
  %.t15 = icmp slt i64 %.t14, 0
  br i1 %.t15, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.t16 = sub i64 0, 1
  ret i64 %.t16
if_next_0_11:
  br label %if_end_9
if_end_9:
  %.t17 = bitcast %Span* %start_span to %Span*
  %__fld.19 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t20 = bitcast %Ast* %__fld.19 to %Ast*
  %.r4134 = load i64, i64* %value
  call void @Ast__span_of(%Span* %__agg.18, %Ast* %.t20, i64 %.r4134)
  %.t21 = bitcast %Span* %__agg.18 to %Span*
  call void @span_to(%Span* %span, %Span* %.t17, %Span* %.t21)
  %__fld.22 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t23 = bitcast %Ast* %__fld.22 to %Ast*
  %.r4135 = load i64, i64* %target
  call void @Ast__span_of(%Span* %tspan, %Ast* %.t23, i64 %.r4135)
  %.t24 = bitcast %Parser* %self to %Parser*
  %.r4136 = load i64, i64* %target
  %.t25 = call i64 @Parser__expr_to_lvalue(%Parser* %.t24, i64 %.r4136)
  store i64 %.t25, i64* %lv
  %.r4137 = load i64, i64* %lv
  %.t26 = icmp slt i64 %.r4137, 0
  br i1 %.t26, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  %__fld.27 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 3
  %.t28 = bitcast %Diags* %__fld.27 to %Diags*
  %.t29 = bitcast %Span* %tspan to %Span*
  %.p4138 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.304, i64 0, i64 0
  %.p4139 = getelementptr inbounds [37 x i8], [37 x i8]* @.str.305, i64 0, i64 0
  %.p4140 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p4141 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @Diags__add(%Diags* %.t28, i8* %.p4138, i8* %.p4139, %Span* %.t29, i8* %.p4140, i8* %.p4141)
  %.t30 = sub i64 0, 1
  ret i64 %.t30
if_next_0_14:
  br label %if_end_12
if_end_12:
  %__fld.31 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t32 = bitcast %Ast* %__fld.31 to %Ast*
  %.t33 = bitcast %Span* %span to %Span*
  %.t34 = sub i64 0, 1
  %.p4142 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.306, i64 0, i64 0
  %.p4143 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.r4144 = load i64, i64* %lv
  %.r4145 = load i64, i64* %value
  %.t35 = call i64 @Ast__add3(%Ast* %.t32, i8* %.p4142, i8* %.p4143, %Span* %.t33, i64 %.r4144, i64 %.t34, i64 %.r4145)
  ret i64 %.t35
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.t36 = bitcast %Parser* %self to %Parser*
  %.p4146 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.t37 = call i64 @Parser__expect(%Parser* %.t36, i8* %.p4146)
  %.t38 = icmp slt i64 %.t37, 0
  br i1 %.t38, label %if_then_0_16, label %if_next_0_17
if_then_0_16:
  %.t39 = sub i64 0, 1
  ret i64 %.t39
if_next_0_17:
  br label %if_end_15
if_end_15:
  %__fld.40 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t41 = bitcast %Ast* %__fld.40 to %Ast*
  %__fld.43 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t44 = bitcast %Ast* %__fld.43 to %Ast*
  %.r4147 = load i64, i64* %target
  call void @Ast__span_of(%Span* %__agg.42, %Ast* %.t44, i64 %.r4147)
  %.t45 = bitcast %Span* %__agg.42 to %Span*
  %.p4148 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.294, i64 0, i64 0
  %.p4149 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.r4150 = load i64, i64* %target
  %.t46 = call i64 @Ast__add1(%Ast* %.t41, i8* %.p4148, i8* %.p4149, %Span* %.t45, i64 %.r4150)
  ret i64 %.t46
}

define i8* @Parser__compound_op(%Parser* %self) {
entry:
  %k = alloca i8*
  %.t0 = bitcast %Parser* %self to %Parser*
  %.t1 = call i8* @Parser__peek(%Parser* %.t0)
  store i8* %.t1, i8** %k
  %.r4151 = load i8*, i8** %k
  %.p4152 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.198, i64 0, i64 0
  %.r4153 = call i32 @strcmp(i8* %.r4151, i8* %.p4152)
  %.t2 = icmp eq i32 %.r4153, 0
  br i1 %.t2, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.p4154 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.307, i64 0, i64 0
  ret i8* %.p4154
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.r4155 = load i8*, i8** %k
  %.p4156 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.200, i64 0, i64 0
  %.r4157 = call i32 @strcmp(i8* %.r4155, i8* %.p4156)
  %.t3 = icmp eq i32 %.r4157, 0
  br i1 %.t3, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.p4158 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.308, i64 0, i64 0
  ret i8* %.p4158
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.r4159 = load i8*, i8** %k
  %.p4160 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.202, i64 0, i64 0
  %.r4161 = call i32 @strcmp(i8* %.r4159, i8* %.p4160)
  %.t4 = icmp eq i32 %.r4161, 0
  br i1 %.t4, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.p4162 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.309, i64 0, i64 0
  ret i8* %.p4162
if_next_0_8:
  br label %if_end_6
if_end_6:
  %.r4163 = load i8*, i8** %k
  %.p4164 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.204, i64 0, i64 0
  %.r4165 = call i32 @strcmp(i8* %.r4163, i8* %.p4164)
  %.t5 = icmp eq i32 %.r4165, 0
  br i1 %.t5, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.p4166 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.310, i64 0, i64 0
  ret i8* %.p4166
if_next_0_11:
  br label %if_end_9
if_end_9:
  %.r4167 = load i8*, i8** %k
  %.p4168 = getelementptr inbounds [10 x i8], [10 x i8]* @.str.206, i64 0, i64 0
  %.r4169 = call i32 @strcmp(i8* %.r4167, i8* %.p4168)
  %.t6 = icmp eq i32 %.r4169, 0
  br i1 %.t6, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  %.p4170 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.311, i64 0, i64 0
  ret i8* %.p4170
if_next_0_14:
  br label %if_end_12
if_end_12:
  %.r4171 = load i8*, i8** %k
  %.p4172 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.208, i64 0, i64 0
  %.r4173 = call i32 @strcmp(i8* %.r4171, i8* %.p4172)
  %.t7 = icmp eq i32 %.r4173, 0
  br i1 %.t7, label %if_then_0_16, label %if_next_0_17
if_then_0_16:
  %.p4174 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.312, i64 0, i64 0
  ret i8* %.p4174
if_next_0_17:
  br label %if_end_15
if_end_15:
  %.r4175 = load i8*, i8** %k
  %.p4176 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.210, i64 0, i64 0
  %.r4177 = call i32 @strcmp(i8* %.r4175, i8* %.p4176)
  %.t8 = icmp eq i32 %.r4177, 0
  br i1 %.t8, label %if_then_0_19, label %if_next_0_20
if_then_0_19:
  %.p4178 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.313, i64 0, i64 0
  ret i8* %.p4178
if_next_0_20:
  br label %if_end_18
if_end_18:
  %.r4179 = load i8*, i8** %k
  %.p4180 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.212, i64 0, i64 0
  %.r4181 = call i32 @strcmp(i8* %.r4179, i8* %.p4180)
  %.t9 = icmp eq i32 %.r4181, 0
  br i1 %.t9, label %if_then_0_22, label %if_next_0_23
if_then_0_22:
  %.p4182 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.314, i64 0, i64 0
  ret i8* %.p4182
if_next_0_23:
  br label %if_end_21
if_end_21:
  %.r4183 = load i8*, i8** %k
  %.p4184 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.214, i64 0, i64 0
  %.r4185 = call i32 @strcmp(i8* %.r4183, i8* %.p4184)
  %.t10 = icmp eq i32 %.r4185, 0
  br i1 %.t10, label %if_then_0_25, label %if_next_0_26
if_then_0_25:
  %.p4186 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.194, i64 0, i64 0
  ret i8* %.p4186
if_next_0_26:
  br label %if_end_24
if_end_24:
  %.r4187 = load i8*, i8** %k
  %.p4188 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.216, i64 0, i64 0
  %.r4189 = call i32 @strcmp(i8* %.r4187, i8* %.p4188)
  %.t11 = icmp eq i32 %.r4189, 0
  br i1 %.t11, label %if_then_0_28, label %if_next_0_29
if_then_0_28:
  %.p4190 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.196, i64 0, i64 0
  ret i8* %.p4190
if_next_0_29:
  br label %if_end_27
if_end_27:
  %.p4191 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  ret i8* %.p4191
}

define i64 @Parser__parse_assign(%Parser* %self) {
entry:
  %start = alloca %Span
  %target = alloca i64
  %annotated = alloca i64
  %op = alloca i8*
  %value = alloca i64
  %rhs = alloca i64
  %__agg.31 = alloca %Span
  %tspan = alloca %Span
  %texpr = alloca i64
  %__agg.58 = alloca %Span
  %__agg.56 = alloca %Span
  %.t0 = bitcast %Parser* %self to %Parser*
  call void @Parser__peek_span(%Span* %start, %Parser* %.t0)
  %.t1 = bitcast %Parser* %self to %Parser*
  %.t2 = call i64 @Parser__parse_lvalue(%Parser* %.t1)
  store i64 %.t2, i64* %target
  %.r4192 = load i64, i64* %target
  %.t3 = icmp slt i64 %.r4192, 0
  br i1 %.t3, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t4 = sub i64 0, 1
  ret i64 %.t4
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.t5 = sub i64 0, 1
  store i64 %.t5, i64* %annotated
  %.t6 = bitcast %Parser* %self to %Parser*
  %.p4193 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.156, i64 0, i64 0
  %.t7 = call i1 @Parser__at(%Parser* %.t6, i8* %.p4193)
  br i1 %.t7, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.t8 = bitcast %Parser* %self to %Parser*
  %.t9 = call i64 @Parser__advance(%Parser* %.t8)
  %.t10 = bitcast %Parser* %self to %Parser*
  %.t11 = call i64 @Parser__parse_type(%Parser* %.t10)
  store i64 %.t11, i64* %annotated
  %.r4194 = load i64, i64* %annotated
  %.t12 = icmp slt i64 %.r4194, 0
  br i1 %.t12, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.t13 = sub i64 0, 1
  ret i64 %.t13
if_next_0_8:
  br label %if_end_6
if_end_6:
  br label %if_end_3
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.t14 = bitcast %Parser* %self to %Parser*
  %.t15 = call i8* @Parser__compound_op(%Parser* %.t14)
  store i8* %.t15, i8** %op
  %.t16 = sub i64 0, 1
  store i64 %.t16, i64* %value
  %.r4195 = load i8*, i8** %op
  %.t17 = call i64 @strlen(i8* %.r4195)
  %.t18 = icmp sgt i64 %.t17, 0
  br i1 %.t18, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.r4196 = load i64, i64* %annotated
  %.t19 = icmp sge i64 %.r4196, 0
  br i1 %.t19, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  %__fld.20 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 3
  %.t21 = bitcast %Diags* %__fld.20 to %Diags*
  %.t22 = bitcast %Span* %start to %Span*
  %.p4197 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.315, i64 0, i64 0
  %.p4198 = getelementptr inbounds [75 x i8], [75 x i8]* @.str.316, i64 0, i64 0
  %.p4199 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p4200 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @Diags__add(%Diags* %.t21, i8* %.p4197, i8* %.p4198, %Span* %.t22, i8* %.p4199, i8* %.p4200)
  %.t23 = sub i64 0, 1
  ret i64 %.t23
if_next_0_14:
  br label %if_end_12
if_end_12:
  %.t24 = bitcast %Parser* %self to %Parser*
  %.t25 = call i64 @Parser__advance(%Parser* %.t24)
  %.t26 = bitcast %Parser* %self to %Parser*
  %.t27 = call i64 @Parser__parse_expr(%Parser* %.t26)
  store i64 %.t27, i64* %rhs
  %.r4201 = load i64, i64* %rhs
  %.t28 = icmp slt i64 %.r4201, 0
  br i1 %.t28, label %if_then_0_16, label %if_next_0_17
if_then_0_16:
  %.t29 = sub i64 0, 1
  ret i64 %.t29
if_next_0_17:
  br label %if_end_15
if_end_15:
  %.t30 = bitcast %Span* %start to %Span*
  %__fld.32 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t33 = bitcast %Ast* %__fld.32 to %Ast*
  %.r4202 = load i64, i64* %rhs
  call void @Ast__span_of(%Span* %__agg.31, %Ast* %.t33, i64 %.r4202)
  %.t34 = bitcast %Span* %__agg.31 to %Span*
  call void @span_to(%Span* %tspan, %Span* %.t30, %Span* %.t34)
  %.t35 = bitcast %Parser* %self to %Parser*
  %.t36 = bitcast %Span* %tspan to %Span*
  %.r4203 = load i64, i64* %target
  %.t37 = call i64 @Parser__lvalue_to_expr(%Parser* %.t35, i64 %.r4203, %Span* %.t36)
  store i64 %.t37, i64* %texpr
  %__fld.38 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t39 = bitcast %Ast* %__fld.38 to %Ast*
  %.t40 = bitcast %Span* %tspan to %Span*
  %.p4204 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.317, i64 0, i64 0
  %.r4205 = load i8*, i8** %op
  %.r4206 = load i64, i64* %texpr
  %.r4207 = load i64, i64* %rhs
  %.t41 = call i64 @Ast__add2(%Ast* %.t39, i8* %.p4204, i8* %.r4205, %Span* %.t40, i64 %.r4206, i64 %.r4207)
  store i64 %.t41, i64* %value
  br label %if_end_9
if_next_0_11:
  %.t42 = bitcast %Parser* %self to %Parser*
  %.p4208 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.184, i64 0, i64 0
  %.t43 = call i64 @Parser__expect(%Parser* %.t42, i8* %.p4208)
  %.t44 = icmp slt i64 %.t43, 0
  br i1 %.t44, label %if_then_0_19, label %if_next_0_20
if_then_0_19:
  %.t45 = sub i64 0, 1
  ret i64 %.t45
if_next_0_20:
  br label %if_end_18
if_end_18:
  %.t46 = bitcast %Parser* %self to %Parser*
  %.t47 = call i64 @Parser__parse_expr(%Parser* %.t46)
  store i64 %.t47, i64* %value
  %.r4209 = load i64, i64* %value
  %.t48 = icmp slt i64 %.r4209, 0
  br i1 %.t48, label %if_then_0_22, label %if_next_0_23
if_then_0_22:
  %.t49 = sub i64 0, 1
  ret i64 %.t49
if_next_0_23:
  br label %if_end_21
if_end_21:
  br label %if_end_9
if_end_9:
  %.t50 = bitcast %Parser* %self to %Parser*
  %.p4210 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.t51 = call i64 @Parser__expect(%Parser* %.t50, i8* %.p4210)
  %.t52 = icmp slt i64 %.t51, 0
  br i1 %.t52, label %if_then_0_25, label %if_next_0_26
if_then_0_25:
  %.t53 = sub i64 0, 1
  ret i64 %.t53
if_next_0_26:
  br label %if_end_24
if_end_24:
  %__fld.54 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t55 = bitcast %Ast* %__fld.54 to %Ast*
  %.t57 = bitcast %Span* %start to %Span*
  %__fld.59 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t60 = bitcast %Ast* %__fld.59 to %Ast*
  %.r4211 = load i64, i64* %value
  call void @Ast__span_of(%Span* %__agg.58, %Ast* %.t60, i64 %.r4211)
  %.t61 = bitcast %Span* %__agg.58 to %Span*
  call void @span_to(%Span* %__agg.56, %Span* %.t57, %Span* %.t61)
  %.t62 = bitcast %Span* %__agg.56 to %Span*
  %.p4212 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.306, i64 0, i64 0
  %.p4213 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.r4214 = load i64, i64* %target
  %.r4215 = load i64, i64* %annotated
  %.r4216 = load i64, i64* %value
  %.t63 = call i64 @Ast__add3(%Ast* %.t55, i8* %.p4212, i8* %.p4213, %Span* %.t62, i64 %.r4214, i64 %.r4215, i64 %.r4216)
  ret i64 %.t63
}

define i64 @Parser__parse_lvalue(%Parser* %self) {
entry:
  %tok = alloca i64
  %tspan = alloca %Span
  %__agg.9 = alloca %Span
  %lv = alloca i64
  %k = alloca i8*
  %ft = alloca i64
  %base = alloca i64
  %__agg.28 = alloca %Span
  %index = alloca i64
  %et = alloca i64
  %__agg.50 = alloca %Span
  %__agg.48 = alloca %Span
  %.t0 = bitcast %Parser* %self to %Parser*
  %.t1 = call i64 @Parser__expect_identifier(%Parser* %.t0)
  store i64 %.t1, i64* %tok
  %.r4217 = load i64, i64* %tok
  %.t2 = icmp slt i64 %.r4217, 0
  br i1 %.t2, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t3 = sub i64 0, 1
  ret i64 %.t3
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.t4 = bitcast %Parser* %self to %Parser*
  %.r4218 = load i64, i64* %tok
  call void @Parser__tspan(%Span* %tspan, %Parser* %.t4, i64 %.r4218)
  %__fld.5 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t6 = bitcast %Ast* %__fld.5 to %Ast*
  %.t7 = bitcast %Parser* %self to %Parser*
  %.r4219 = load i64, i64* %tok
  %.t8 = call i8* @Parser__ttext(%Parser* %.t7, i64 %.r4219)
  call void @span_dummy(%Span* %__agg.9)
  %.t10 = bitcast %Span* %__agg.9 to %Span*
  %.p4220 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.297, i64 0, i64 0
  %.t11 = call i64 @Ast__add0(%Ast* %.t6, i8* %.p4220, i8* %.t8, %Span* %.t10)
  store i64 %.t11, i64* %lv
  br label %while_cond_3
while_cond_3:
  br i1 true, label %while_body_4, label %while_end_5
while_body_4:
  %.t12 = bitcast %Parser* %self to %Parser*
  %.t13 = call i8* @Parser__peek(%Parser* %.t12)
  store i8* %.t13, i8** %k
  %.r4221 = load i8*, i8** %k
  %.p4222 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.158, i64 0, i64 0
  %.r4223 = call i32 @strcmp(i8* %.r4221, i8* %.p4222)
  %.t14 = icmp eq i32 %.r4223, 0
  br i1 %.t14, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.t15 = bitcast %Parser* %self to %Parser*
  %.t16 = call i64 @Parser__advance(%Parser* %.t15)
  %.t17 = bitcast %Parser* %self to %Parser*
  %.t18 = call i64 @Parser__expect_identifier(%Parser* %.t17)
  store i64 %.t18, i64* %ft
  %.r4224 = load i64, i64* %ft
  %.t19 = icmp slt i64 %.r4224, 0
  br i1 %.t19, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.t20 = sub i64 0, 1
  ret i64 %.t20
if_next_0_11:
  br label %if_end_9
if_end_9:
  %.t21 = bitcast %Parser* %self to %Parser*
  %.t22 = bitcast %Span* %tspan to %Span*
  %.r4225 = load i64, i64* %lv
  %.t23 = call i64 @Parser__lvalue_to_expr(%Parser* %.t21, i64 %.r4225, %Span* %.t22)
  store i64 %.t23, i64* %base
  %__fld.24 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t25 = bitcast %Ast* %__fld.24 to %Ast*
  %.t26 = bitcast %Parser* %self to %Parser*
  %.r4226 = load i64, i64* %ft
  %.t27 = call i8* @Parser__ttext(%Parser* %.t26, i64 %.r4226)
  %.t29 = bitcast %Parser* %self to %Parser*
  %.r4227 = load i64, i64* %ft
  call void @Parser__tspan(%Span* %__agg.28, %Parser* %.t29, i64 %.r4227)
  %.t30 = bitcast %Span* %__agg.28 to %Span*
  %.p4228 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.298, i64 0, i64 0
  %.r4229 = load i64, i64* %base
  %.t31 = call i64 @Ast__add1(%Ast* %.t25, i8* %.p4228, i8* %.t27, %Span* %.t30, i64 %.r4229)
  store i64 %.t31, i64* %lv
  br label %if_end_6
if_next_0_8:
  %.r4230 = load i8*, i8** %k
  %.p4231 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.146, i64 0, i64 0
  %.r4232 = call i32 @strcmp(i8* %.r4230, i8* %.p4231)
  %.t32 = icmp eq i32 %.r4232, 0
  br i1 %.t32, label %if_then_1_12, label %if_next_1_13
if_then_1_12:
  %.t33 = bitcast %Parser* %self to %Parser*
  %.t34 = call i64 @Parser__advance(%Parser* %.t33)
  %.t35 = bitcast %Parser* %self to %Parser*
  %.t36 = call i64 @Parser__parse_expr(%Parser* %.t35)
  store i64 %.t36, i64* %index
  %.r4233 = load i64, i64* %index
  %.t37 = icmp slt i64 %.r4233, 0
  br i1 %.t37, label %if_then_0_15, label %if_next_0_16
if_then_0_15:
  %.t38 = sub i64 0, 1
  ret i64 %.t38
if_next_0_16:
  br label %if_end_14
if_end_14:
  %.t39 = bitcast %Parser* %self to %Parser*
  %.p4234 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.148, i64 0, i64 0
  %.t40 = call i64 @Parser__expect(%Parser* %.t39, i8* %.p4234)
  store i64 %.t40, i64* %et
  %.r4235 = load i64, i64* %et
  %.t41 = icmp slt i64 %.r4235, 0
  br i1 %.t41, label %if_then_0_18, label %if_next_0_19
if_then_0_18:
  %.t42 = sub i64 0, 1
  ret i64 %.t42
if_next_0_19:
  br label %if_end_17
if_end_17:
  %.t43 = bitcast %Parser* %self to %Parser*
  %.t44 = bitcast %Span* %tspan to %Span*
  %.r4236 = load i64, i64* %lv
  %.t45 = call i64 @Parser__lvalue_to_expr(%Parser* %.t43, i64 %.r4236, %Span* %.t44)
  store i64 %.t45, i64* %base
  %__fld.46 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t47 = bitcast %Ast* %__fld.46 to %Ast*
  %.t49 = bitcast %Span* %tspan to %Span*
  %.t51 = bitcast %Parser* %self to %Parser*
  %.r4237 = load i64, i64* %et
  call void @Parser__tspan(%Span* %__agg.50, %Parser* %.t51, i64 %.r4237)
  %.t52 = bitcast %Span* %__agg.50 to %Span*
  call void @span_to(%Span* %__agg.48, %Span* %.t49, %Span* %.t52)
  %.t53 = bitcast %Span* %__agg.48 to %Span*
  %.p4238 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.300, i64 0, i64 0
  %.p4239 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.r4240 = load i64, i64* %base
  %.r4241 = load i64, i64* %index
  %.t54 = call i64 @Ast__add2(%Ast* %.t47, i8* %.p4238, i8* %.p4239, %Span* %.t53, i64 %.r4240, i64 %.r4241)
  store i64 %.t54, i64* %lv
  br label %if_end_6
if_next_1_13:
  br label %while_end_5
if_end_6:
  br label %while_cond_3
while_end_5:
  %.t55 = load i64, i64* %lv
  ret i64 %.t55
}

define i64 @Parser__parse_return(%Parser* %self) {
entry:
  %st = alloca i64
  %value = alloca i64
  %__agg.18 = alloca %Span
  %.t0 = bitcast %Parser* %self to %Parser*
  %.p4242 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.18, i64 0, i64 0
  %.t1 = call i64 @Parser__expect(%Parser* %.t0, i8* %.p4242)
  store i64 %.t1, i64* %st
  %.r4243 = load i64, i64* %st
  %.t2 = icmp slt i64 %.r4243, 0
  br i1 %.t2, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t3 = sub i64 0, 1
  ret i64 %.t3
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.t4 = sub i64 0, 1
  store i64 %.t4, i64* %value
  %.t5 = bitcast %Parser* %self to %Parser*
  %.p4244 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.t6 = call i1 @Parser__at(%Parser* %.t5, i8* %.p4244)
  %.t7 = xor i1 %.t6, true
  br i1 %.t7, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.t8 = bitcast %Parser* %self to %Parser*
  %.t9 = call i64 @Parser__parse_expr(%Parser* %.t8)
  store i64 %.t9, i64* %value
  %.r4245 = load i64, i64* %value
  %.t10 = icmp slt i64 %.r4245, 0
  br i1 %.t10, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.t11 = sub i64 0, 1
  ret i64 %.t11
if_next_0_8:
  br label %if_end_6
if_end_6:
  br label %if_end_3
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.t12 = bitcast %Parser* %self to %Parser*
  %.p4246 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.t13 = call i64 @Parser__expect(%Parser* %.t12, i8* %.p4246)
  %.t14 = icmp slt i64 %.t13, 0
  br i1 %.t14, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.t15 = sub i64 0, 1
  ret i64 %.t15
if_next_0_11:
  br label %if_end_9
if_end_9:
  %__fld.16 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t17 = bitcast %Ast* %__fld.16 to %Ast*
  %.t19 = bitcast %Parser* %self to %Parser*
  %.r4247 = load i64, i64* %st
  call void @Parser__tspan(%Span* %__agg.18, %Parser* %.t19, i64 %.r4247)
  %.t20 = bitcast %Span* %__agg.18 to %Span*
  %.p4248 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.18, i64 0, i64 0
  %.p4249 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.r4250 = load i64, i64* %value
  %.t21 = call i64 @Ast__add1(%Ast* %.t17, i8* %.p4248, i8* %.p4249, %Span* %.t20, i64 %.r4250)
  ret i64 %.t21
}

define i64 @Parser__parse_match(%Parser* %self) {
entry:
  %st = alloca i64
  %start = alloca %Span
  %subject = alloca i64
  %arms = alloca { i64, i64, i64* }
  %else_body = alloca i64
  %__sc.22 = alloca i1
  %ct = alloca i64
  %vt = alloca i64
  %kids = alloca { i64, i64, i64* }
  %b = alloca i64
  %__agg.68 = alloca %Span
  %body = alloca i64
  %__agg.93 = alloca %Span
  %__agg.96 = alloca %Span
  %__agg.92 = alloca %Span
  %et = alloca i64
  %al = alloca i64
  %__agg.116 = alloca %Span
  %__agg.114 = alloca %Span
  %.t0 = bitcast %Parser* %self to %Parser*
  %.p4251 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.58, i64 0, i64 0
  %.t1 = call i64 @Parser__expect(%Parser* %.t0, i8* %.p4251)
  store i64 %.t1, i64* %st
  %.r4252 = load i64, i64* %st
  %.t2 = icmp slt i64 %.r4252, 0
  br i1 %.t2, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t3 = sub i64 0, 1
  ret i64 %.t3
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.t4 = bitcast %Parser* %self to %Parser*
  %.r4253 = load i64, i64* %st
  call void @Parser__tspan(%Span* %start, %Parser* %.t4, i64 %.r4253)
  %.t5 = bitcast %Parser* %self to %Parser*
  %.t6 = call i64 @Parser__parse_expr(%Parser* %.t5)
  store i64 %.t6, i64* %subject
  %.r4254 = load i64, i64* %subject
  %.t7 = icmp slt i64 %.r4254, 0
  br i1 %.t7, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.t8 = sub i64 0, 1
  ret i64 %.t8
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.t9 = bitcast %Parser* %self to %Parser*
  %.p4255 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.156, i64 0, i64 0
  %.t10 = call i64 @Parser__expect(%Parser* %.t9, i8* %.p4255)
  %.t11 = icmp slt i64 %.t10, 0
  br i1 %.t11, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.t12 = sub i64 0, 1
  ret i64 %.t12
if_next_0_8:
  br label %if_end_6
if_end_6:
  %.t13 = bitcast %Parser* %self to %Parser*
  %.p4256 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.t14 = call i64 @Parser__expect(%Parser* %.t13, i8* %.p4256)
  %.t15 = icmp slt i64 %.t14, 0
  br i1 %.t15, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.t16 = sub i64 0, 1
  ret i64 %.t16
if_next_0_11:
  br label %if_end_9
if_end_9:
  %.t17 = bitcast %Parser* %self to %Parser*
  %.p4257 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.220, i64 0, i64 0
  %.t18 = call i64 @Parser__expect(%Parser* %.t17, i8* %.p4257)
  %.t19 = icmp slt i64 %.t18, 0
  br i1 %.t19, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  %.t20 = sub i64 0, 1
  ret i64 %.t20
if_next_0_14:
  br label %if_end_12
if_end_12:
  %.p4259 = getelementptr i64, i64* null, i32 1
  %.r4260 = ptrtoint i64* %.p4259 to i64
  %.r4261 = mul i64 %.r4260, 1
  %.p4258 = call i8* @malloc(i64 %.r4261)
  %.p4262 = bitcast i8* %.p4258 to i64*
  %.p4263 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %arms, i32 0, i32 0
  store i64 0, i64* %.p4263
  %.p4264 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %arms, i32 0, i32 1
  store i64 0, i64* %.p4264
  %.p4265 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %arms, i32 0, i32 2
  store i64* %.p4262, i64** %.p4265
  %.t21 = sub i64 0, 1
  store i64 %.t21, i64* %else_body
  br label %while_cond_15
while_cond_15:
  %.t23 = bitcast %Parser* %self to %Parser*
  %.p4266 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.222, i64 0, i64 0
  %.t24 = call i1 @Parser__at(%Parser* %.t23, i8* %.p4266)
  %.t25 = xor i1 %.t24, true
  br i1 %.t25, label %sc_rhs_18, label %sc_short_19
sc_rhs_18:
  %.t26 = bitcast %Parser* %self to %Parser*
  %.p4267 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.224, i64 0, i64 0
  %.t27 = call i1 @Parser__at(%Parser* %.t26, i8* %.p4267)
  %.t28 = xor i1 %.t27, true
  store i1 %.t28, i1* %__sc.22
  br label %sc_end_20
sc_short_19:
  store i1 false, i1* %__sc.22
  br label %sc_end_20
sc_end_20:
  %.r4268 = load i1, i1* %__sc.22
  br i1 %.r4268, label %while_body_16, label %while_end_17
while_body_16:
  %.t29 = bitcast %Parser* %self to %Parser*
  %.p4269 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.218, i64 0, i64 0
  %.t30 = call i1 @Parser__at(%Parser* %.t29, i8* %.p4269)
  br i1 %.t30, label %if_then_0_22, label %if_next_0_23
if_then_0_22:
  %.t31 = bitcast %Parser* %self to %Parser*
  %.t32 = call i64 @Parser__advance(%Parser* %.t31)
  br label %while_cond_15
if_next_0_23:
  br label %if_end_21
if_end_21:
  %.t33 = bitcast %Parser* %self to %Parser*
  %.p4270 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.24, i64 0, i64 0
  %.t34 = call i1 @Parser__at(%Parser* %.t33, i8* %.p4270)
  br i1 %.t34, label %if_then_0_25, label %if_next_0_26
if_then_0_25:
  %.t35 = bitcast %Parser* %self to %Parser*
  %.t36 = call i64 @Parser__advance(%Parser* %.t35)
  %.t37 = bitcast %Parser* %self to %Parser*
  %.p4271 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.156, i64 0, i64 0
  %.t38 = call i64 @Parser__expect(%Parser* %.t37, i8* %.p4271)
  %.t39 = icmp slt i64 %.t38, 0
  br i1 %.t39, label %if_then_0_28, label %if_next_0_29
if_then_0_28:
  %.t40 = sub i64 0, 1
  ret i64 %.t40
if_next_0_29:
  br label %if_end_27
if_end_27:
  %.t41 = bitcast %Parser* %self to %Parser*
  %.t42 = call i64 @Parser__parse_block(%Parser* %.t41)
  store i64 %.t42, i64* %else_body
  %.r4272 = load i64, i64* %else_body
  %.t43 = icmp slt i64 %.r4272, 0
  br i1 %.t43, label %if_then_0_31, label %if_next_0_32
if_then_0_31:
  %.t44 = sub i64 0, 1
  ret i64 %.t44
if_next_0_32:
  br label %if_end_30
if_end_30:
  br label %while_cond_15
if_next_0_26:
  br label %if_end_24
if_end_24:
  %.t45 = bitcast %Parser* %self to %Parser*
  %.p4273 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.60, i64 0, i64 0
  %.t46 = call i64 @Parser__expect(%Parser* %.t45, i8* %.p4273)
  store i64 %.t46, i64* %ct
  %.r4274 = load i64, i64* %ct
  %.t47 = icmp slt i64 %.r4274, 0
  br i1 %.t47, label %if_then_0_34, label %if_next_0_35
if_then_0_34:
  %.t48 = sub i64 0, 1
  ret i64 %.t48
if_next_0_35:
  br label %if_end_33
if_end_33:
  %.t49 = bitcast %Parser* %self to %Parser*
  %.t50 = call i64 @Parser__expect_identifier(%Parser* %.t49)
  store i64 %.t50, i64* %vt
  %.r4275 = load i64, i64* %vt
  %.t51 = icmp slt i64 %.r4275, 0
  br i1 %.t51, label %if_then_0_37, label %if_next_0_38
if_then_0_37:
  %.t52 = sub i64 0, 1
  ret i64 %.t52
if_next_0_38:
  br label %if_end_36
if_end_36:
  %.p4277 = getelementptr i64, i64* null, i32 1
  %.r4278 = ptrtoint i64* %.p4277 to i64
  %.r4279 = mul i64 %.r4278, 1
  %.p4276 = call i8* @malloc(i64 %.r4279)
  %.p4280 = bitcast i8* %.p4276 to i64*
  %.p4281 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %kids, i32 0, i32 0
  store i64 0, i64* %.p4281
  %.p4282 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %kids, i32 0, i32 1
  store i64 0, i64* %.p4282
  %.p4283 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %kids, i32 0, i32 2
  store i64* %.p4280, i64** %.p4283
  %.t53 = bitcast %Parser* %self to %Parser*
  %.p4284 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.142, i64 0, i64 0
  %.t54 = call i1 @Parser__at(%Parser* %.t53, i8* %.p4284)
  br i1 %.t54, label %if_then_0_40, label %if_next_0_41
if_then_0_40:
  %.t55 = bitcast %Parser* %self to %Parser*
  %.t56 = call i64 @Parser__advance(%Parser* %.t55)
  %.t57 = bitcast %Parser* %self to %Parser*
  %.p4285 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.144, i64 0, i64 0
  %.t58 = call i1 @Parser__at(%Parser* %.t57, i8* %.p4285)
  %.t59 = xor i1 %.t58, true
  br i1 %.t59, label %if_then_0_43, label %if_next_0_44
if_then_0_43:
  br label %while_cond_45
while_cond_45:
  br i1 true, label %while_body_46, label %while_end_47
while_body_46:
  %.t60 = bitcast %Parser* %self to %Parser*
  %.t61 = call i64 @Parser__expect_identifier(%Parser* %.t60)
  store i64 %.t61, i64* %b
  %.r4286 = load i64, i64* %b
  %.t62 = icmp slt i64 %.r4286, 0
  br i1 %.t62, label %if_then_0_49, label %if_next_0_50
if_then_0_49:
  %.t63 = sub i64 0, 1
  ret i64 %.t63
if_next_0_50:
  br label %if_end_48
if_end_48:
  %__fld.64 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t65 = bitcast %Ast* %__fld.64 to %Ast*
  %.t66 = bitcast %Parser* %self to %Parser*
  %.r4287 = load i64, i64* %b
  %.t67 = call i8* @Parser__ttext(%Parser* %.t66, i64 %.r4287)
  %.t69 = bitcast %Parser* %self to %Parser*
  %.r4288 = load i64, i64* %b
  call void @Parser__tspan(%Span* %__agg.68, %Parser* %.t69, i64 %.r4288)
  %.t70 = bitcast %Span* %__agg.68 to %Span*
  %.p4289 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.257, i64 0, i64 0
  %.t71 = call i64 @Ast__add0(%Ast* %.t65, i8* %.p4289, i8* %.t67, %Span* %.t70)
  %.p4290 = getelementptr i64, i64* null, i32 1
  %.r4291 = ptrtoint i64* %.p4290 to i64
  %.p4292 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %kids, i32 0, i32 0
  %.p4293 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %kids, i32 0, i32 1
  %.p4294 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %kids, i32 0, i32 2
  %.r4295 = load i64, i64* %.p4292
  %.r4296 = load i64, i64* %.p4293
  %.r4297 = icmp sge i64 %.r4295, %.r4296
  br i1 %.r4297, label %append.grow.4298, label %append.after.4299
append.grow.4298:
  %.r4300 = load i64*, i64** %.p4294
  %.r4301 = icmp eq i64 %.r4296, 0
  %.r4302 = mul i64 %.r4296, 2
  %.r4303 = select i1 %.r4301, i64 1, i64 %.r4302
  %.r4304 = mul i64 %.r4303, %.r4291
  %.p4305 = call i8* @malloc(i64 %.r4304)
  %.p4306 = bitcast i8* %.p4305 to i64*
  %.r4307 = mul i64 %.r4295, %.r4291
  %.p4308 = bitcast i64* %.r4300 to i8*
  call i8* @memcpy(i8* %.p4305, i8* %.p4308, i64 %.r4307)
  call void @free(i8* %.p4308)
  store i64* %.p4306, i64** %.p4294
  store i64 %.r4303, i64* %.p4293
  br label %append.after.4299
append.after.4299:
  %.r4309 = load i64*, i64** %.p4294
  %.p4310 = getelementptr inbounds i64, i64* %.r4309, i64 %.r4295
  store i64 %.t71, i64* %.p4310
  %.r4311 = add i64 %.r4295, 1
  store i64 %.r4311, i64* %.p4292
  %.t72 = bitcast %Parser* %self to %Parser*
  %.p4312 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.154, i64 0, i64 0
  %.t73 = call i1 @Parser__at(%Parser* %.t72, i8* %.p4312)
  br i1 %.t73, label %if_then_0_52, label %if_next_0_53
if_then_0_52:
  %.t74 = bitcast %Parser* %self to %Parser*
  %.t75 = call i64 @Parser__advance(%Parser* %.t74)
  br label %if_end_51
if_next_0_53:
  br label %while_end_47
if_end_51:
  br label %while_cond_45
while_end_47:
  br label %if_end_42
if_next_0_44:
  br label %if_end_42
if_end_42:
  %.t76 = bitcast %Parser* %self to %Parser*
  %.p4313 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.144, i64 0, i64 0
  %.t77 = call i64 @Parser__expect(%Parser* %.t76, i8* %.p4313)
  %.t78 = icmp slt i64 %.t77, 0
  br i1 %.t78, label %if_then_0_55, label %if_next_0_56
if_then_0_55:
  %.t79 = sub i64 0, 1
  ret i64 %.t79
if_next_0_56:
  br label %if_end_54
if_end_54:
  br label %if_end_39
if_next_0_41:
  br label %if_end_39
if_end_39:
  %.t80 = bitcast %Parser* %self to %Parser*
  %.p4314 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.156, i64 0, i64 0
  %.t81 = call i64 @Parser__expect(%Parser* %.t80, i8* %.p4314)
  %.t82 = icmp slt i64 %.t81, 0
  br i1 %.t82, label %if_then_0_58, label %if_next_0_59
if_then_0_58:
  %.t83 = sub i64 0, 1
  ret i64 %.t83
if_next_0_59:
  br label %if_end_57
if_end_57:
  %.t84 = bitcast %Parser* %self to %Parser*
  %.t85 = call i64 @Parser__parse_block(%Parser* %.t84)
  store i64 %.t85, i64* %body
  %.r4315 = load i64, i64* %body
  %.t86 = icmp slt i64 %.r4315, 0
  br i1 %.t86, label %if_then_0_61, label %if_next_0_62
if_then_0_61:
  %.t87 = sub i64 0, 1
  ret i64 %.t87
if_next_0_62:
  br label %if_end_60
if_end_60:
  %.p4316 = getelementptr i64, i64* null, i32 1
  %.r4317 = ptrtoint i64* %.p4316 to i64
  %.p4318 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %kids, i32 0, i32 0
  %.p4319 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %kids, i32 0, i32 1
  %.p4320 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %kids, i32 0, i32 2
  %.r4321 = load i64, i64* %.p4318
  %.r4322 = load i64, i64* %.p4319
  %.r4323 = icmp sge i64 %.r4321, %.r4322
  br i1 %.r4323, label %append.grow.4324, label %append.after.4325
append.grow.4324:
  %.r4326 = load i64*, i64** %.p4320
  %.r4327 = icmp eq i64 %.r4322, 0
  %.r4328 = mul i64 %.r4322, 2
  %.r4329 = select i1 %.r4327, i64 1, i64 %.r4328
  %.r4330 = mul i64 %.r4329, %.r4317
  %.p4331 = call i8* @malloc(i64 %.r4330)
  %.p4332 = bitcast i8* %.p4331 to i64*
  %.r4333 = mul i64 %.r4321, %.r4317
  %.p4334 = bitcast i64* %.r4326 to i8*
  call i8* @memcpy(i8* %.p4331, i8* %.p4334, i64 %.r4333)
  call void @free(i8* %.p4334)
  store i64* %.p4332, i64** %.p4320
  store i64 %.r4329, i64* %.p4319
  br label %append.after.4325
append.after.4325:
  %.r4335 = load i64*, i64** %.p4320
  %.r4336 = load i64, i64* %body
  %.p4337 = getelementptr inbounds i64, i64* %.r4335, i64 %.r4321
  store i64 %.r4336, i64* %.p4337
  %.r4338 = add i64 %.r4321, 1
  store i64 %.r4338, i64* %.p4318
  %__fld.88 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t89 = bitcast %Ast* %__fld.88 to %Ast*
  %.t90 = bitcast %Parser* %self to %Parser*
  %.r4339 = load i64, i64* %vt
  %.t91 = call i8* @Parser__ttext(%Parser* %.t90, i64 %.r4339)
  %.t94 = bitcast %Parser* %self to %Parser*
  %.r4340 = load i64, i64* %ct
  call void @Parser__tspan(%Span* %__agg.93, %Parser* %.t94, i64 %.r4340)
  %.t95 = bitcast %Span* %__agg.93 to %Span*
  %__fld.97 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t98 = bitcast %Ast* %__fld.97 to %Ast*
  %.r4341 = load i64, i64* %body
  call void @Ast__span_of(%Span* %__agg.96, %Ast* %.t98, i64 %.r4341)
  %.t99 = bitcast %Span* %__agg.96 to %Span*
  call void @span_to(%Span* %__agg.92, %Span* %.t95, %Span* %.t99)
  %.t100 = bitcast %Span* %__agg.92 to %Span*
  %.t101 = bitcast { i64, i64, i64* }* %kids to { i64, i64, i64* }*
  %.p4342 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.318, i64 0, i64 0
  %.t102 = call i64 @Ast__addl(%Ast* %.t89, i8* %.p4342, i8* %.t91, %Span* %.t100, { i64, i64, i64* }* %.t101)
  %.p4343 = getelementptr i64, i64* null, i32 1
  %.r4344 = ptrtoint i64* %.p4343 to i64
  %.p4345 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %arms, i32 0, i32 0
  %.p4346 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %arms, i32 0, i32 1
  %.p4347 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %arms, i32 0, i32 2
  %.r4348 = load i64, i64* %.p4345
  %.r4349 = load i64, i64* %.p4346
  %.r4350 = icmp sge i64 %.r4348, %.r4349
  br i1 %.r4350, label %append.grow.4351, label %append.after.4352
append.grow.4351:
  %.r4353 = load i64*, i64** %.p4347
  %.r4354 = icmp eq i64 %.r4349, 0
  %.r4355 = mul i64 %.r4349, 2
  %.r4356 = select i1 %.r4354, i64 1, i64 %.r4355
  %.r4357 = mul i64 %.r4356, %.r4344
  %.p4358 = call i8* @malloc(i64 %.r4357)
  %.p4359 = bitcast i8* %.p4358 to i64*
  %.r4360 = mul i64 %.r4348, %.r4344
  %.p4361 = bitcast i64* %.r4353 to i8*
  call i8* @memcpy(i8* %.p4358, i8* %.p4361, i64 %.r4360)
  call void @free(i8* %.p4361)
  store i64* %.p4359, i64** %.p4347
  store i64 %.r4356, i64* %.p4346
  br label %append.after.4352
append.after.4352:
  %.r4362 = load i64*, i64** %.p4347
  %.p4363 = getelementptr inbounds i64, i64* %.r4362, i64 %.r4348
  store i64 %.t102, i64* %.p4363
  %.r4364 = add i64 %.r4348, 1
  store i64 %.r4364, i64* %.p4345
  br label %while_cond_15
while_end_17:
  %.t103 = bitcast %Parser* %self to %Parser*
  %.p4365 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.222, i64 0, i64 0
  %.t104 = call i64 @Parser__expect(%Parser* %.t103, i8* %.p4365)
  store i64 %.t104, i64* %et
  %.r4366 = load i64, i64* %et
  %.t105 = icmp slt i64 %.r4366, 0
  br i1 %.t105, label %if_then_0_64, label %if_next_0_65
if_then_0_64:
  %.t106 = sub i64 0, 1
  ret i64 %.t106
if_next_0_65:
  br label %if_end_63
if_end_63:
  %__fld.107 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t108 = bitcast %Ast* %__fld.107 to %Ast*
  %.t109 = bitcast %Span* %start to %Span*
  %.t110 = bitcast { i64, i64, i64* }* %arms to { i64, i64, i64* }*
  %.p4367 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.255, i64 0, i64 0
  %.p4368 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.t111 = call i64 @Ast__addl(%Ast* %.t108, i8* %.p4367, i8* %.p4368, %Span* %.t109, { i64, i64, i64* }* %.t110)
  store i64 %.t111, i64* %al
  %__fld.112 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t113 = bitcast %Ast* %__fld.112 to %Ast*
  %.t115 = bitcast %Span* %start to %Span*
  %.t117 = bitcast %Parser* %self to %Parser*
  %.r4369 = load i64, i64* %et
  call void @Parser__tspan(%Span* %__agg.116, %Parser* %.t117, i64 %.r4369)
  %.t118 = bitcast %Span* %__agg.116 to %Span*
  call void @span_to(%Span* %__agg.114, %Span* %.t115, %Span* %.t118)
  %.t119 = bitcast %Span* %__agg.114 to %Span*
  %.p4370 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.58, i64 0, i64 0
  %.p4371 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.r4372 = load i64, i64* %subject
  %.r4373 = load i64, i64* %al
  %.r4374 = load i64, i64* %else_body
  %.t120 = call i64 @Ast__add3(%Ast* %.t113, i8* %.p4370, i8* %.p4371, %Span* %.t119, i64 %.r4372, i64 %.r4373, i64 %.r4374)
  ret i64 %.t120
}

define i64 @Parser__parse_if(%Parser* %self) {
entry:
  %st = alloca i64
  %start = alloca %Span
  %cond = alloca i64
  %then_b = alloca i64
  %__agg.18 = alloca %Span
  %span = alloca %Span
  %orifs = alloca { i64, i64, i64* }
  %ot = alloca i64
  %c = alloca i64
  %body = alloca i64
  %__agg.39 = alloca %Span
  %__agg.46 = alloca %Span
  %__agg.49 = alloca %Span
  %__agg.45 = alloca %Span
  %else_b = alloca i64
  %__agg.69 = alloca %Span
  %ol = alloca i64
  %.t0 = bitcast %Parser* %self to %Parser*
  %.p4375 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.20, i64 0, i64 0
  %.t1 = call i64 @Parser__expect(%Parser* %.t0, i8* %.p4375)
  store i64 %.t1, i64* %st
  %.r4376 = load i64, i64* %st
  %.t2 = icmp slt i64 %.r4376, 0
  br i1 %.t2, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t3 = sub i64 0, 1
  ret i64 %.t3
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.t4 = bitcast %Parser* %self to %Parser*
  %.r4377 = load i64, i64* %st
  call void @Parser__tspan(%Span* %start, %Parser* %.t4, i64 %.r4377)
  %.t5 = bitcast %Parser* %self to %Parser*
  %.t6 = call i64 @Parser__parse_expr(%Parser* %.t5)
  store i64 %.t6, i64* %cond
  %.r4378 = load i64, i64* %cond
  %.t7 = icmp slt i64 %.r4378, 0
  br i1 %.t7, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.t8 = sub i64 0, 1
  ret i64 %.t8
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.t9 = bitcast %Parser* %self to %Parser*
  %.p4379 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.156, i64 0, i64 0
  %.t10 = call i64 @Parser__expect(%Parser* %.t9, i8* %.p4379)
  %.t11 = icmp slt i64 %.t10, 0
  br i1 %.t11, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.t12 = sub i64 0, 1
  ret i64 %.t12
if_next_0_8:
  br label %if_end_6
if_end_6:
  %.t13 = bitcast %Parser* %self to %Parser*
  %.t14 = call i64 @Parser__parse_block(%Parser* %.t13)
  store i64 %.t14, i64* %then_b
  %.r4380 = load i64, i64* %then_b
  %.t15 = icmp slt i64 %.r4380, 0
  br i1 %.t15, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.t16 = sub i64 0, 1
  ret i64 %.t16
if_next_0_11:
  br label %if_end_9
if_end_9:
  %.t17 = bitcast %Span* %start to %Span*
  %__fld.19 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t20 = bitcast %Ast* %__fld.19 to %Ast*
  %.r4381 = load i64, i64* %then_b
  call void @Ast__span_of(%Span* %__agg.18, %Ast* %.t20, i64 %.r4381)
  %.t21 = bitcast %Span* %__agg.18 to %Span*
  call void @span_to(%Span* %span, %Span* %.t17, %Span* %.t21)
  %.p4383 = getelementptr i64, i64* null, i32 1
  %.r4384 = ptrtoint i64* %.p4383 to i64
  %.r4385 = mul i64 %.r4384, 1
  %.p4382 = call i8* @malloc(i64 %.r4385)
  %.p4386 = bitcast i8* %.p4382 to i64*
  %.p4387 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %orifs, i32 0, i32 0
  store i64 0, i64* %.p4387
  %.p4388 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %orifs, i32 0, i32 1
  store i64 0, i64* %.p4388
  %.p4389 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %orifs, i32 0, i32 2
  store i64* %.p4386, i64** %.p4389
  br label %while_cond_12
while_cond_12:
  %.t22 = bitcast %Parser* %self to %Parser*
  %.p4390 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.22, i64 0, i64 0
  %.t23 = call i1 @Parser__at(%Parser* %.t22, i8* %.p4390)
  br i1 %.t23, label %while_body_13, label %while_end_14
while_body_13:
  %.t24 = bitcast %Parser* %self to %Parser*
  %.t25 = call i64 @Parser__advance(%Parser* %.t24)
  store i64 %.t25, i64* %ot
  %.t26 = bitcast %Parser* %self to %Parser*
  %.t27 = call i64 @Parser__parse_expr(%Parser* %.t26)
  store i64 %.t27, i64* %c
  %.r4391 = load i64, i64* %c
  %.t28 = icmp slt i64 %.r4391, 0
  br i1 %.t28, label %if_then_0_16, label %if_next_0_17
if_then_0_16:
  %.t29 = sub i64 0, 1
  ret i64 %.t29
if_next_0_17:
  br label %if_end_15
if_end_15:
  %.t30 = bitcast %Parser* %self to %Parser*
  %.p4392 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.156, i64 0, i64 0
  %.t31 = call i64 @Parser__expect(%Parser* %.t30, i8* %.p4392)
  %.t32 = icmp slt i64 %.t31, 0
  br i1 %.t32, label %if_then_0_19, label %if_next_0_20
if_then_0_19:
  %.t33 = sub i64 0, 1
  ret i64 %.t33
if_next_0_20:
  br label %if_end_18
if_end_18:
  %.t34 = bitcast %Parser* %self to %Parser*
  %.t35 = call i64 @Parser__parse_block(%Parser* %.t34)
  store i64 %.t35, i64* %body
  %.r4393 = load i64, i64* %body
  %.t36 = icmp slt i64 %.r4393, 0
  br i1 %.t36, label %if_then_0_22, label %if_next_0_23
if_then_0_22:
  %.t37 = sub i64 0, 1
  ret i64 %.t37
if_next_0_23:
  br label %if_end_21
if_end_21:
  %.t38 = bitcast %Span* %span to %Span*
  %__fld.40 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t41 = bitcast %Ast* %__fld.40 to %Ast*
  %.r4394 = load i64, i64* %body
  call void @Ast__span_of(%Span* %__agg.39, %Ast* %.t41, i64 %.r4394)
  %.t42 = bitcast %Span* %__agg.39 to %Span*
  call void @span_to(%Span* %span, %Span* %.t38, %Span* %.t42)
  %__fld.43 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t44 = bitcast %Ast* %__fld.43 to %Ast*
  %.t47 = bitcast %Parser* %self to %Parser*
  %.r4395 = load i64, i64* %ot
  call void @Parser__tspan(%Span* %__agg.46, %Parser* %.t47, i64 %.r4395)
  %.t48 = bitcast %Span* %__agg.46 to %Span*
  %__fld.50 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t51 = bitcast %Ast* %__fld.50 to %Ast*
  %.r4396 = load i64, i64* %body
  call void @Ast__span_of(%Span* %__agg.49, %Ast* %.t51, i64 %.r4396)
  %.t52 = bitcast %Span* %__agg.49 to %Span*
  call void @span_to(%Span* %__agg.45, %Span* %.t48, %Span* %.t52)
  %.t53 = bitcast %Span* %__agg.45 to %Span*
  %.p4397 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.22, i64 0, i64 0
  %.p4398 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.r4399 = load i64, i64* %c
  %.r4400 = load i64, i64* %body
  %.t54 = call i64 @Ast__add2(%Ast* %.t44, i8* %.p4397, i8* %.p4398, %Span* %.t53, i64 %.r4399, i64 %.r4400)
  %.p4401 = getelementptr i64, i64* null, i32 1
  %.r4402 = ptrtoint i64* %.p4401 to i64
  %.p4403 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %orifs, i32 0, i32 0
  %.p4404 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %orifs, i32 0, i32 1
  %.p4405 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %orifs, i32 0, i32 2
  %.r4406 = load i64, i64* %.p4403
  %.r4407 = load i64, i64* %.p4404
  %.r4408 = icmp sge i64 %.r4406, %.r4407
  br i1 %.r4408, label %append.grow.4409, label %append.after.4410
append.grow.4409:
  %.r4411 = load i64*, i64** %.p4405
  %.r4412 = icmp eq i64 %.r4407, 0
  %.r4413 = mul i64 %.r4407, 2
  %.r4414 = select i1 %.r4412, i64 1, i64 %.r4413
  %.r4415 = mul i64 %.r4414, %.r4402
  %.p4416 = call i8* @malloc(i64 %.r4415)
  %.p4417 = bitcast i8* %.p4416 to i64*
  %.r4418 = mul i64 %.r4406, %.r4402
  %.p4419 = bitcast i64* %.r4411 to i8*
  call i8* @memcpy(i8* %.p4416, i8* %.p4419, i64 %.r4418)
  call void @free(i8* %.p4419)
  store i64* %.p4417, i64** %.p4405
  store i64 %.r4414, i64* %.p4404
  br label %append.after.4410
append.after.4410:
  %.r4420 = load i64*, i64** %.p4405
  %.p4421 = getelementptr inbounds i64, i64* %.r4420, i64 %.r4406
  store i64 %.t54, i64* %.p4421
  %.r4422 = add i64 %.r4406, 1
  store i64 %.r4422, i64* %.p4403
  br label %while_cond_12
while_end_14:
  %.t55 = sub i64 0, 1
  store i64 %.t55, i64* %else_b
  %.t56 = bitcast %Parser* %self to %Parser*
  %.p4423 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.24, i64 0, i64 0
  %.t57 = call i1 @Parser__at(%Parser* %.t56, i8* %.p4423)
  br i1 %.t57, label %if_then_0_25, label %if_next_0_26
if_then_0_25:
  %.t58 = bitcast %Parser* %self to %Parser*
  %.t59 = call i64 @Parser__advance(%Parser* %.t58)
  %.t60 = bitcast %Parser* %self to %Parser*
  %.p4424 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.156, i64 0, i64 0
  %.t61 = call i64 @Parser__expect(%Parser* %.t60, i8* %.p4424)
  %.t62 = icmp slt i64 %.t61, 0
  br i1 %.t62, label %if_then_0_28, label %if_next_0_29
if_then_0_28:
  %.t63 = sub i64 0, 1
  ret i64 %.t63
if_next_0_29:
  br label %if_end_27
if_end_27:
  %.t64 = bitcast %Parser* %self to %Parser*
  %.t65 = call i64 @Parser__parse_block(%Parser* %.t64)
  store i64 %.t65, i64* %else_b
  %.r4425 = load i64, i64* %else_b
  %.t66 = icmp slt i64 %.r4425, 0
  br i1 %.t66, label %if_then_0_31, label %if_next_0_32
if_then_0_31:
  %.t67 = sub i64 0, 1
  ret i64 %.t67
if_next_0_32:
  br label %if_end_30
if_end_30:
  %.t68 = bitcast %Span* %span to %Span*
  %__fld.70 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t71 = bitcast %Ast* %__fld.70 to %Ast*
  %.r4426 = load i64, i64* %else_b
  call void @Ast__span_of(%Span* %__agg.69, %Ast* %.t71, i64 %.r4426)
  %.t72 = bitcast %Span* %__agg.69 to %Span*
  call void @span_to(%Span* %span, %Span* %.t68, %Span* %.t72)
  br label %if_end_24
if_next_0_26:
  br label %if_end_24
if_end_24:
  %__fld.73 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t74 = bitcast %Ast* %__fld.73 to %Ast*
  %.t75 = bitcast %Span* %start to %Span*
  %.t76 = bitcast { i64, i64, i64* }* %orifs to { i64, i64, i64* }*
  %.p4427 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.255, i64 0, i64 0
  %.p4428 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.t77 = call i64 @Ast__addl(%Ast* %.t74, i8* %.p4427, i8* %.p4428, %Span* %.t75, { i64, i64, i64* }* %.t76)
  store i64 %.t77, i64* %ol
  %__fld.78 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t79 = bitcast %Ast* %__fld.78 to %Ast*
  %.t80 = bitcast %Span* %span to %Span*
  %.p4429 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.20, i64 0, i64 0
  %.p4430 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.r4431 = load i64, i64* %cond
  %.r4432 = load i64, i64* %then_b
  %.r4433 = load i64, i64* %ol
  %.r4434 = load i64, i64* %else_b
  %.t81 = call i64 @Ast__add4(%Ast* %.t79, i8* %.p4429, i8* %.p4430, %Span* %.t80, i64 %.r4431, i64 %.r4432, i64 %.r4433, i64 %.r4434)
  ret i64 %.t81
}

define i64 @Parser__parse_cond_loop(%Parser* %self, i8* %kind.arg) {
entry:
  %kind = alloca i8*
  %st = alloca i64
  %start = alloca %Span
  %cond = alloca i64
  %body = alloca i64
  %__agg.21 = alloca %Span
  %__agg.19 = alloca %Span
  store i8* %kind.arg, i8** %kind
  %.t0 = bitcast %Parser* %self to %Parser*
  %.r4435 = load i8*, i8** %kind
  %.t1 = call i64 @Parser__expect(%Parser* %.t0, i8* %.r4435)
  store i64 %.t1, i64* %st
  %.r4436 = load i64, i64* %st
  %.t2 = icmp slt i64 %.r4436, 0
  br i1 %.t2, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t3 = sub i64 0, 1
  ret i64 %.t3
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.t4 = bitcast %Parser* %self to %Parser*
  %.r4437 = load i64, i64* %st
  call void @Parser__tspan(%Span* %start, %Parser* %.t4, i64 %.r4437)
  %.t5 = bitcast %Parser* %self to %Parser*
  %.t6 = call i64 @Parser__parse_expr(%Parser* %.t5)
  store i64 %.t6, i64* %cond
  %.r4438 = load i64, i64* %cond
  %.t7 = icmp slt i64 %.r4438, 0
  br i1 %.t7, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.t8 = sub i64 0, 1
  ret i64 %.t8
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.t9 = bitcast %Parser* %self to %Parser*
  %.p4439 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.156, i64 0, i64 0
  %.t10 = call i64 @Parser__expect(%Parser* %.t9, i8* %.p4439)
  %.t11 = icmp slt i64 %.t10, 0
  br i1 %.t11, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.t12 = sub i64 0, 1
  ret i64 %.t12
if_next_0_8:
  br label %if_end_6
if_end_6:
  %.t13 = bitcast %Parser* %self to %Parser*
  %.t14 = call i64 @Parser__parse_block(%Parser* %.t13)
  store i64 %.t14, i64* %body
  %.r4440 = load i64, i64* %body
  %.t15 = icmp slt i64 %.r4440, 0
  br i1 %.t15, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.t16 = sub i64 0, 1
  ret i64 %.t16
if_next_0_11:
  br label %if_end_9
if_end_9:
  %__fld.17 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t18 = bitcast %Ast* %__fld.17 to %Ast*
  %.t20 = bitcast %Span* %start to %Span*
  %__fld.22 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t23 = bitcast %Ast* %__fld.22 to %Ast*
  %.r4441 = load i64, i64* %body
  call void @Ast__span_of(%Span* %__agg.21, %Ast* %.t23, i64 %.r4441)
  %.t24 = bitcast %Span* %__agg.21 to %Span*
  call void @span_to(%Span* %__agg.19, %Span* %.t20, %Span* %.t24)
  %.t25 = bitcast %Span* %__agg.19 to %Span*
  %.r4442 = load i8*, i8** %kind
  %.p4443 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.r4444 = load i64, i64* %cond
  %.r4445 = load i64, i64* %body
  %.t26 = call i64 @Ast__add2(%Ast* %.t18, i8* %.r4442, i8* %.p4443, %Span* %.t25, i64 %.r4444, i64 %.r4445)
  ret i64 %.t26
}

define i64 @Parser__parse_body_stmt(%Parser* %self, i8* %kind.arg) {
entry:
  %kind = alloca i8*
  %st = alloca i64
  %start = alloca %Span
  %body = alloca i64
  %__agg.17 = alloca %Span
  %__agg.15 = alloca %Span
  store i8* %kind.arg, i8** %kind
  %.t0 = bitcast %Parser* %self to %Parser*
  %.r4446 = load i8*, i8** %kind
  %.t1 = call i64 @Parser__expect(%Parser* %.t0, i8* %.r4446)
  store i64 %.t1, i64* %st
  %.r4447 = load i64, i64* %st
  %.t2 = icmp slt i64 %.r4447, 0
  br i1 %.t2, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t3 = sub i64 0, 1
  ret i64 %.t3
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.t4 = bitcast %Parser* %self to %Parser*
  %.r4448 = load i64, i64* %st
  call void @Parser__tspan(%Span* %start, %Parser* %.t4, i64 %.r4448)
  %.t5 = bitcast %Parser* %self to %Parser*
  %.p4449 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.156, i64 0, i64 0
  %.t6 = call i64 @Parser__expect(%Parser* %.t5, i8* %.p4449)
  %.t7 = icmp slt i64 %.t6, 0
  br i1 %.t7, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.t8 = sub i64 0, 1
  ret i64 %.t8
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.t9 = bitcast %Parser* %self to %Parser*
  %.t10 = call i64 @Parser__parse_block(%Parser* %.t9)
  store i64 %.t10, i64* %body
  %.r4450 = load i64, i64* %body
  %.t11 = icmp slt i64 %.r4450, 0
  br i1 %.t11, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.t12 = sub i64 0, 1
  ret i64 %.t12
if_next_0_8:
  br label %if_end_6
if_end_6:
  %__fld.13 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t14 = bitcast %Ast* %__fld.13 to %Ast*
  %.t16 = bitcast %Span* %start to %Span*
  %__fld.18 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t19 = bitcast %Ast* %__fld.18 to %Ast*
  %.r4451 = load i64, i64* %body
  call void @Ast__span_of(%Span* %__agg.17, %Ast* %.t19, i64 %.r4451)
  %.t20 = bitcast %Span* %__agg.17 to %Span*
  call void @span_to(%Span* %__agg.15, %Span* %.t16, %Span* %.t20)
  %.t21 = bitcast %Span* %__agg.15 to %Span*
  %.r4452 = load i8*, i8** %kind
  %.p4453 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.r4454 = load i64, i64* %body
  %.t22 = call i64 @Ast__add1(%Ast* %.t14, i8* %.r4452, i8* %.p4453, %Span* %.t21, i64 %.r4454)
  ret i64 %.t22
}

define i64 @Parser__parse_for(%Parser* %self) {
entry:
  %st = alloca i64
  %start = alloca %Span
  %vt = alloca i64
  %var = alloca i8*
  %from_e = alloca i64
  %to_e = alloca i64
  %body = alloca i64
  %__agg.39 = alloca %Span
  %__agg.37 = alloca %Span
  %iterable = alloca i64
  %__agg.65 = alloca %Span
  %__agg.63 = alloca %Span
  %.t0 = bitcast %Parser* %self to %Parser*
  %.p4455 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.32, i64 0, i64 0
  %.t1 = call i64 @Parser__expect(%Parser* %.t0, i8* %.p4455)
  store i64 %.t1, i64* %st
  %.r4456 = load i64, i64* %st
  %.t2 = icmp slt i64 %.r4456, 0
  br i1 %.t2, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t3 = sub i64 0, 1
  ret i64 %.t3
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.t4 = bitcast %Parser* %self to %Parser*
  %.r4457 = load i64, i64* %st
  call void @Parser__tspan(%Span* %start, %Parser* %.t4, i64 %.r4457)
  %.t5 = bitcast %Parser* %self to %Parser*
  %.t6 = call i64 @Parser__expect_identifier(%Parser* %.t5)
  store i64 %.t6, i64* %vt
  %.r4458 = load i64, i64* %vt
  %.t7 = icmp slt i64 %.r4458, 0
  br i1 %.t7, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.t8 = sub i64 0, 1
  ret i64 %.t8
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.t9 = bitcast %Parser* %self to %Parser*
  %.r4459 = load i64, i64* %vt
  %.t10 = call i8* @Parser__ttext(%Parser* %.t9, i64 %.r4459)
  store i8* %.t10, i8** %var
  %.t11 = bitcast %Parser* %self to %Parser*
  %.p4460 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.184, i64 0, i64 0
  %.t12 = call i1 @Parser__at(%Parser* %.t11, i8* %.p4460)
  br i1 %.t12, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.t13 = bitcast %Parser* %self to %Parser*
  %.t14 = call i64 @Parser__advance(%Parser* %.t13)
  %.t15 = bitcast %Parser* %self to %Parser*
  %.t16 = call i64 @Parser__parse_expr(%Parser* %.t15)
  store i64 %.t16, i64* %from_e
  %.r4461 = load i64, i64* %from_e
  %.t17 = icmp slt i64 %.r4461, 0
  br i1 %.t17, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.t18 = sub i64 0, 1
  ret i64 %.t18
if_next_0_11:
  br label %if_end_9
if_end_9:
  %.t19 = bitcast %Parser* %self to %Parser*
  %.p4462 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.34, i64 0, i64 0
  %.t20 = call i64 @Parser__expect(%Parser* %.t19, i8* %.p4462)
  %.t21 = icmp slt i64 %.t20, 0
  br i1 %.t21, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  %.t22 = sub i64 0, 1
  ret i64 %.t22
if_next_0_14:
  br label %if_end_12
if_end_12:
  %.t23 = bitcast %Parser* %self to %Parser*
  %.t24 = call i64 @Parser__parse_expr(%Parser* %.t23)
  store i64 %.t24, i64* %to_e
  %.r4463 = load i64, i64* %to_e
  %.t25 = icmp slt i64 %.r4463, 0
  br i1 %.t25, label %if_then_0_16, label %if_next_0_17
if_then_0_16:
  %.t26 = sub i64 0, 1
  ret i64 %.t26
if_next_0_17:
  br label %if_end_15
if_end_15:
  %.t27 = bitcast %Parser* %self to %Parser*
  %.p4464 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.156, i64 0, i64 0
  %.t28 = call i64 @Parser__expect(%Parser* %.t27, i8* %.p4464)
  %.t29 = icmp slt i64 %.t28, 0
  br i1 %.t29, label %if_then_0_19, label %if_next_0_20
if_then_0_19:
  %.t30 = sub i64 0, 1
  ret i64 %.t30
if_next_0_20:
  br label %if_end_18
if_end_18:
  %.t31 = bitcast %Parser* %self to %Parser*
  %.t32 = call i64 @Parser__parse_block(%Parser* %.t31)
  store i64 %.t32, i64* %body
  %.r4465 = load i64, i64* %body
  %.t33 = icmp slt i64 %.r4465, 0
  br i1 %.t33, label %if_then_0_22, label %if_next_0_23
if_then_0_22:
  %.t34 = sub i64 0, 1
  ret i64 %.t34
if_next_0_23:
  br label %if_end_21
if_end_21:
  %__fld.35 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t36 = bitcast %Ast* %__fld.35 to %Ast*
  %.t38 = bitcast %Span* %start to %Span*
  %__fld.40 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t41 = bitcast %Ast* %__fld.40 to %Ast*
  %.r4466 = load i64, i64* %body
  call void @Ast__span_of(%Span* %__agg.39, %Ast* %.t41, i64 %.r4466)
  %.t42 = bitcast %Span* %__agg.39 to %Span*
  call void @span_to(%Span* %__agg.37, %Span* %.t38, %Span* %.t42)
  %.t43 = bitcast %Span* %__agg.37 to %Span*
  %.p4467 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.319, i64 0, i64 0
  %.r4468 = load i8*, i8** %var
  %.r4469 = load i64, i64* %from_e
  %.r4470 = load i64, i64* %to_e
  %.r4471 = load i64, i64* %body
  %.t44 = call i64 @Ast__add3(%Ast* %.t36, i8* %.p4467, i8* %.r4468, %Span* %.t43, i64 %.r4469, i64 %.r4470, i64 %.r4471)
  ret i64 %.t44
if_next_0_8:
  br label %if_end_6
if_end_6:
  %.t45 = bitcast %Parser* %self to %Parser*
  %.p4472 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.36, i64 0, i64 0
  %.t46 = call i64 @Parser__expect(%Parser* %.t45, i8* %.p4472)
  %.t47 = icmp slt i64 %.t46, 0
  br i1 %.t47, label %if_then_0_25, label %if_next_0_26
if_then_0_25:
  %.t48 = sub i64 0, 1
  ret i64 %.t48
if_next_0_26:
  br label %if_end_24
if_end_24:
  %.t49 = bitcast %Parser* %self to %Parser*
  %.t50 = call i64 @Parser__parse_expr(%Parser* %.t49)
  store i64 %.t50, i64* %iterable
  %.r4473 = load i64, i64* %iterable
  %.t51 = icmp slt i64 %.r4473, 0
  br i1 %.t51, label %if_then_0_28, label %if_next_0_29
if_then_0_28:
  %.t52 = sub i64 0, 1
  ret i64 %.t52
if_next_0_29:
  br label %if_end_27
if_end_27:
  %.t53 = bitcast %Parser* %self to %Parser*
  %.p4474 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.156, i64 0, i64 0
  %.t54 = call i64 @Parser__expect(%Parser* %.t53, i8* %.p4474)
  %.t55 = icmp slt i64 %.t54, 0
  br i1 %.t55, label %if_then_0_31, label %if_next_0_32
if_then_0_31:
  %.t56 = sub i64 0, 1
  ret i64 %.t56
if_next_0_32:
  br label %if_end_30
if_end_30:
  %.t57 = bitcast %Parser* %self to %Parser*
  %.t58 = call i64 @Parser__parse_block(%Parser* %.t57)
  store i64 %.t58, i64* %body
  %.r4475 = load i64, i64* %body
  %.t59 = icmp slt i64 %.r4475, 0
  br i1 %.t59, label %if_then_0_34, label %if_next_0_35
if_then_0_34:
  %.t60 = sub i64 0, 1
  ret i64 %.t60
if_next_0_35:
  br label %if_end_33
if_end_33:
  %__fld.61 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t62 = bitcast %Ast* %__fld.61 to %Ast*
  %.t64 = bitcast %Span* %start to %Span*
  %__fld.66 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t67 = bitcast %Ast* %__fld.66 to %Ast*
  %.r4476 = load i64, i64* %body
  call void @Ast__span_of(%Span* %__agg.65, %Ast* %.t67, i64 %.r4476)
  %.t68 = bitcast %Span* %__agg.65 to %Span*
  call void @span_to(%Span* %__agg.63, %Span* %.t64, %Span* %.t68)
  %.t69 = bitcast %Span* %__agg.63 to %Span*
  %.p4477 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.320, i64 0, i64 0
  %.r4478 = load i8*, i8** %var
  %.r4479 = load i64, i64* %iterable
  %.r4480 = load i64, i64* %body
  %.t70 = call i64 @Ast__add2(%Ast* %.t62, i8* %.p4477, i8* %.r4478, %Span* %.t69, i64 %.r4479, i64 %.r4480)
  ret i64 %.t70
}

define i64 @Parser__parse_try(%Parser* %self) {
entry:
  %st = alloca i64
  %start = alloca %Span
  %try_b = alloca i64
  %__agg.14 = alloca %Span
  %span = alloca %Span
  %failed_var = alloca i8*
  %failed_b = alloca i64
  %t = alloca i64
  %__agg.38 = alloca %Span
  %finally_b = alloca i64
  %__agg.56 = alloca %Span
  %.t0 = bitcast %Parser* %self to %Parser*
  %.p4481 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.42, i64 0, i64 0
  %.t1 = call i64 @Parser__expect(%Parser* %.t0, i8* %.p4481)
  store i64 %.t1, i64* %st
  %.r4482 = load i64, i64* %st
  %.t2 = icmp slt i64 %.r4482, 0
  br i1 %.t2, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t3 = sub i64 0, 1
  ret i64 %.t3
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.t4 = bitcast %Parser* %self to %Parser*
  %.r4483 = load i64, i64* %st
  call void @Parser__tspan(%Span* %start, %Parser* %.t4, i64 %.r4483)
  %.t5 = bitcast %Parser* %self to %Parser*
  %.p4484 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.156, i64 0, i64 0
  %.t6 = call i64 @Parser__expect(%Parser* %.t5, i8* %.p4484)
  %.t7 = icmp slt i64 %.t6, 0
  br i1 %.t7, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.t8 = sub i64 0, 1
  ret i64 %.t8
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.t9 = bitcast %Parser* %self to %Parser*
  %.t10 = call i64 @Parser__parse_block(%Parser* %.t9)
  store i64 %.t10, i64* %try_b
  %.r4485 = load i64, i64* %try_b
  %.t11 = icmp slt i64 %.r4485, 0
  br i1 %.t11, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.t12 = sub i64 0, 1
  ret i64 %.t12
if_next_0_8:
  br label %if_end_6
if_end_6:
  %.t13 = bitcast %Span* %start to %Span*
  %__fld.15 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t16 = bitcast %Ast* %__fld.15 to %Ast*
  %.r4486 = load i64, i64* %try_b
  call void @Ast__span_of(%Span* %__agg.14, %Ast* %.t16, i64 %.r4486)
  %.t17 = bitcast %Span* %__agg.14 to %Span*
  call void @span_to(%Span* %span, %Span* %.t13, %Span* %.t17)
  %.p4487 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  store i8* %.p4487, i8** %failed_var
  %.t18 = sub i64 0, 1
  store i64 %.t18, i64* %failed_b
  %.t19 = bitcast %Parser* %self to %Parser*
  %.p4488 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.44, i64 0, i64 0
  %.t20 = call i1 @Parser__at(%Parser* %.t19, i8* %.p4488)
  br i1 %.t20, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.t21 = bitcast %Parser* %self to %Parser*
  %.t22 = call i64 @Parser__advance(%Parser* %.t21)
  %.t23 = bitcast %Parser* %self to %Parser*
  %.p4489 = getelementptr inbounds [11 x i8], [11 x i8]* @.str.101, i64 0, i64 0
  %.t24 = call i1 @Parser__at(%Parser* %.t23, i8* %.p4489)
  br i1 %.t24, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  %.t25 = bitcast %Parser* %self to %Parser*
  %.t26 = call i64 @Parser__expect_identifier(%Parser* %.t25)
  store i64 %.t26, i64* %t
  %.t27 = bitcast %Parser* %self to %Parser*
  %.r4490 = load i64, i64* %t
  %.t28 = call i8* @Parser__ttext(%Parser* %.t27, i64 %.r4490)
  store i8* %.t28, i8** %failed_var
  br label %if_end_12
if_next_0_14:
  br label %if_end_12
if_end_12:
  %.t29 = bitcast %Parser* %self to %Parser*
  %.p4491 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.156, i64 0, i64 0
  %.t30 = call i64 @Parser__expect(%Parser* %.t29, i8* %.p4491)
  %.t31 = icmp slt i64 %.t30, 0
  br i1 %.t31, label %if_then_0_16, label %if_next_0_17
if_then_0_16:
  %.t32 = sub i64 0, 1
  ret i64 %.t32
if_next_0_17:
  br label %if_end_15
if_end_15:
  %.t33 = bitcast %Parser* %self to %Parser*
  %.t34 = call i64 @Parser__parse_block(%Parser* %.t33)
  store i64 %.t34, i64* %failed_b
  %.r4492 = load i64, i64* %failed_b
  %.t35 = icmp slt i64 %.r4492, 0
  br i1 %.t35, label %if_then_0_19, label %if_next_0_20
if_then_0_19:
  %.t36 = sub i64 0, 1
  ret i64 %.t36
if_next_0_20:
  br label %if_end_18
if_end_18:
  %.t37 = bitcast %Span* %span to %Span*
  %__fld.39 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t40 = bitcast %Ast* %__fld.39 to %Ast*
  %.r4493 = load i64, i64* %failed_b
  call void @Ast__span_of(%Span* %__agg.38, %Ast* %.t40, i64 %.r4493)
  %.t41 = bitcast %Span* %__agg.38 to %Span*
  call void @span_to(%Span* %span, %Span* %.t37, %Span* %.t41)
  br label %if_end_9
if_next_0_11:
  br label %if_end_9
if_end_9:
  %.t42 = sub i64 0, 1
  store i64 %.t42, i64* %finally_b
  %.t43 = bitcast %Parser* %self to %Parser*
  %.p4494 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.46, i64 0, i64 0
  %.t44 = call i1 @Parser__at(%Parser* %.t43, i8* %.p4494)
  br i1 %.t44, label %if_then_0_22, label %if_next_0_23
if_then_0_22:
  %.t45 = bitcast %Parser* %self to %Parser*
  %.t46 = call i64 @Parser__advance(%Parser* %.t45)
  %.t47 = bitcast %Parser* %self to %Parser*
  %.p4495 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.156, i64 0, i64 0
  %.t48 = call i64 @Parser__expect(%Parser* %.t47, i8* %.p4495)
  %.t49 = icmp slt i64 %.t48, 0
  br i1 %.t49, label %if_then_0_25, label %if_next_0_26
if_then_0_25:
  %.t50 = sub i64 0, 1
  ret i64 %.t50
if_next_0_26:
  br label %if_end_24
if_end_24:
  %.t51 = bitcast %Parser* %self to %Parser*
  %.t52 = call i64 @Parser__parse_block(%Parser* %.t51)
  store i64 %.t52, i64* %finally_b
  %.r4496 = load i64, i64* %finally_b
  %.t53 = icmp slt i64 %.r4496, 0
  br i1 %.t53, label %if_then_0_28, label %if_next_0_29
if_then_0_28:
  %.t54 = sub i64 0, 1
  ret i64 %.t54
if_next_0_29:
  br label %if_end_27
if_end_27:
  %.t55 = bitcast %Span* %span to %Span*
  %__fld.57 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t58 = bitcast %Ast* %__fld.57 to %Ast*
  %.r4497 = load i64, i64* %finally_b
  call void @Ast__span_of(%Span* %__agg.56, %Ast* %.t58, i64 %.r4497)
  %.t59 = bitcast %Span* %__agg.56 to %Span*
  call void @span_to(%Span* %span, %Span* %.t55, %Span* %.t59)
  br label %if_end_21
if_next_0_23:
  br label %if_end_21
if_end_21:
  %__fld.60 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t61 = bitcast %Ast* %__fld.60 to %Ast*
  %.t62 = bitcast %Span* %span to %Span*
  %.p4498 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.42, i64 0, i64 0
  %.r4499 = load i8*, i8** %failed_var
  %.r4500 = load i64, i64* %try_b
  %.r4501 = load i64, i64* %failed_b
  %.r4502 = load i64, i64* %finally_b
  %.t63 = call i64 @Ast__add3(%Ast* %.t61, i8* %.p4498, i8* %.r4499, %Span* %.t62, i64 %.r4500, i64 %.r4501, i64 %.r4502)
  ret i64 %.t63
}

define i64 @Parser__desugar_fstring(%Parser* %self, i8* %raw.arg, %Span* %span) {
entry:
  %raw = alloca i8*
  %parts = alloca { i64, i64, i64* }
  %lit = alloca i8*
  %n = alloca i64
  %i = alloca i64
  %c = alloca i64
  %nxt = alloca i64
  %__sc.8 = alloca i1
  %__sc.13 = alloca i1
  %depth = alloca i64
  %j = alloca i64
  %__sc.20 = alloca i1
  %d = alloca i64
  %body = alloca i8*
  %sub_diags = alloca %Diags
  %sub_toks = alloca { i64, i64, %Token* }
  %saved_toks = alloca { i64, i64, %Token* }
  %saved_pos = alloca i64
  %before = alloca i64
  %inner = alloca i64
  %__agg.76 = alloca { i64, i64, i64* }
  %size = alloca i64
  %__sc.91 = alloca i1
  %acc = alloca i64
  %k = alloca i64
  store i8* %raw.arg, i8** %raw
  %.p4504 = getelementptr i64, i64* null, i32 1
  %.r4505 = ptrtoint i64* %.p4504 to i64
  %.r4506 = mul i64 %.r4505, 1
  %.p4503 = call i8* @malloc(i64 %.r4506)
  %.p4507 = bitcast i8* %.p4503 to i64*
  %.p4508 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %parts, i32 0, i32 0
  store i64 0, i64* %.p4508
  %.p4509 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %parts, i32 0, i32 1
  store i64 0, i64* %.p4509
  %.p4510 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %parts, i32 0, i32 2
  store i64* %.p4507, i64** %.p4510
  %.p4511 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  store i8* %.p4511, i8** %lit
  %.r4512 = load i8*, i8** %raw
  %.t0 = call i64 @strlen(i8* %.r4512)
  store i64 %.t0, i64* %n
  store i64 0, i64* %i
  br label %while_cond_0
while_cond_0:
  %.r4513 = load i64, i64* %i
  %.r4514 = load i64, i64* %n
  %.t1 = icmp slt i64 %.r4513, %.r4514
  br i1 %.t1, label %while_body_1, label %while_end_2
while_body_1:
  %.r4515 = load i8*, i8** %raw
  %.r4516 = load i64, i64* %i
  %.p4517 = getelementptr inbounds i8, i8* %.r4515, i64 %.r4516
  %.r4518 = load i8, i8* %.p4517
  %.t2 = zext i8 %.r4518 to i64
  store i64 %.t2, i64* %c
  %.t3 = sub i64 0, 1
  store i64 %.t3, i64* %nxt
  %.r4519 = load i64, i64* %i
  %.t4 = add i64 %.r4519, 1
  %.r4520 = load i64, i64* %n
  %.t5 = icmp slt i64 %.t4, %.r4520
  br i1 %.t5, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.r4521 = load i64, i64* %i
  %.t6 = add i64 %.r4521, 1
  %.r4522 = load i8*, i8** %raw
  %.p4523 = getelementptr inbounds i8, i8* %.r4522, i64 %.t6
  %.r4524 = load i8, i8* %.p4523
  %.t7 = zext i8 %.r4524 to i64
  store i64 %.t7, i64* %nxt
  br label %if_end_3
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.r4525 = load i64, i64* %c
  %.t9 = icmp eq i64 %.r4525, 123
  br i1 %.t9, label %sc_rhs_9, label %sc_short_10
sc_rhs_9:
  %.r4526 = load i64, i64* %nxt
  %.t10 = icmp eq i64 %.r4526, 123
  store i1 %.t10, i1* %__sc.8
  br label %sc_end_11
sc_short_10:
  store i1 false, i1* %__sc.8
  br label %sc_end_11
sc_end_11:
  %.r4527 = load i1, i1* %__sc.8
  br i1 %.r4527, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.r4528 = load i8*, i8** %lit
  %.p4529 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.321, i64 0, i64 0
  %.r4530 = call i64 @strlen(i8* %.r4528)
  %.r4531 = call i64 @strlen(i8* %.p4529)
  %.r4532 = add i64 %.r4530, %.r4531
  %.r4533 = add i64 %.r4532, 1
  %.t11 = call i8* @malloc(i64 %.r4533)
  call i8* @memcpy(i8* %.t11, i8* %.r4528, i64 %.r4530)
  %.p4534 = getelementptr inbounds i8, i8* %.t11, i64 %.r4530
  call i8* @memcpy(i8* %.p4534, i8* %.p4529, i64 %.r4531)
  %.p4535 = getelementptr inbounds i8, i8* %.t11, i64 %.r4532
  store i8 0, i8* %.p4535
  store i8* %.t11, i8** %lit
  %.r4536 = load i64, i64* %i
  %.t12 = add i64 %.r4536, 2
  store i64 %.t12, i64* %i
  br label %if_end_6
if_next_0_8:
  %.r4537 = load i64, i64* %c
  %.t14 = icmp eq i64 %.r4537, 125
  br i1 %.t14, label %sc_rhs_14, label %sc_short_15
sc_rhs_14:
  %.r4538 = load i64, i64* %nxt
  %.t15 = icmp eq i64 %.r4538, 125
  store i1 %.t15, i1* %__sc.13
  br label %sc_end_16
sc_short_15:
  store i1 false, i1* %__sc.13
  br label %sc_end_16
sc_end_16:
  %.r4539 = load i1, i1* %__sc.13
  br i1 %.r4539, label %if_then_1_12, label %if_next_1_13
if_then_1_12:
  %.r4540 = load i8*, i8** %lit
  %.p4541 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.322, i64 0, i64 0
  %.r4542 = call i64 @strlen(i8* %.r4540)
  %.r4543 = call i64 @strlen(i8* %.p4541)
  %.r4544 = add i64 %.r4542, %.r4543
  %.r4545 = add i64 %.r4544, 1
  %.t16 = call i8* @malloc(i64 %.r4545)
  call i8* @memcpy(i8* %.t16, i8* %.r4540, i64 %.r4542)
  %.p4546 = getelementptr inbounds i8, i8* %.t16, i64 %.r4542
  call i8* @memcpy(i8* %.p4546, i8* %.p4541, i64 %.r4543)
  %.p4547 = getelementptr inbounds i8, i8* %.t16, i64 %.r4544
  store i8 0, i8* %.p4547
  store i8* %.t16, i8** %lit
  %.r4548 = load i64, i64* %i
  %.t17 = add i64 %.r4548, 2
  store i64 %.t17, i64* %i
  br label %if_end_6
if_next_1_13:
  %.r4549 = load i64, i64* %c
  %.t18 = icmp eq i64 %.r4549, 123
  br i1 %.t18, label %if_then_2_17, label %if_next_2_18
if_then_2_17:
  store i64 1, i64* %depth
  %.r4550 = load i64, i64* %i
  %.t19 = add i64 %.r4550, 1
  store i64 %.t19, i64* %j
  br label %while_cond_19
while_cond_19:
  %.r4551 = load i64, i64* %j
  %.r4552 = load i64, i64* %n
  %.t21 = icmp slt i64 %.r4551, %.r4552
  br i1 %.t21, label %sc_rhs_22, label %sc_short_23
sc_rhs_22:
  %.r4553 = load i64, i64* %depth
  %.t22 = icmp sgt i64 %.r4553, 0
  store i1 %.t22, i1* %__sc.20
  br label %sc_end_24
sc_short_23:
  store i1 false, i1* %__sc.20
  br label %sc_end_24
sc_end_24:
  %.r4554 = load i1, i1* %__sc.20
  br i1 %.r4554, label %while_body_20, label %while_end_21
while_body_20:
  %.r4555 = load i8*, i8** %raw
  %.r4556 = load i64, i64* %j
  %.p4557 = getelementptr inbounds i8, i8* %.r4555, i64 %.r4556
  %.r4558 = load i8, i8* %.p4557
  %.t23 = zext i8 %.r4558 to i64
  store i64 %.t23, i64* %d
  %.r4559 = load i64, i64* %d
  %.t24 = icmp eq i64 %.r4559, 123
  br i1 %.t24, label %if_then_0_26, label %if_next_0_27
if_then_0_26:
  %.r4560 = load i64, i64* %depth
  %.t25 = add i64 %.r4560, 1
  store i64 %.t25, i64* %depth
  br label %if_end_25
if_next_0_27:
  %.r4561 = load i64, i64* %d
  %.t26 = icmp eq i64 %.r4561, 125
  br i1 %.t26, label %if_then_1_28, label %if_next_1_29
if_then_1_28:
  %.r4562 = load i64, i64* %depth
  %.t27 = sub i64 %.r4562, 1
  store i64 %.t27, i64* %depth
  br label %if_end_25
if_next_1_29:
  br label %if_end_25
if_end_25:
  %.r4563 = load i64, i64* %j
  %.t28 = add i64 %.r4563, 1
  store i64 %.t28, i64* %j
  br label %while_cond_19
while_end_21:
  %.r4564 = load i64, i64* %depth
  %.t29 = icmp ne i64 %.r4564, 0
  br i1 %.t29, label %if_then_0_31, label %if_next_0_32
if_then_0_31:
  %__fld.30 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 3
  %.t31 = bitcast %Diags* %__fld.30 to %Diags*
  %.t32 = bitcast %Span* %span to %Span*
  %.p4565 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.323, i64 0, i64 0
  %.p4566 = getelementptr inbounds [29 x i8], [29 x i8]* @.str.324, i64 0, i64 0
  %.p4567 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p4568 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @Diags__add(%Diags* %.t31, i8* %.p4565, i8* %.p4566, %Span* %.t32, i8* %.p4567, i8* %.p4568)
  %.t33 = sub i64 0, 1
  ret i64 %.t33
if_next_0_32:
  br label %if_end_30
if_end_30:
  %.r4569 = load i64, i64* %i
  %.t34 = add i64 %.r4569, 1
  %.r4570 = load i64, i64* %j
  %.t35 = sub i64 %.r4570, 1
  %.r4571 = load i8*, i8** %raw
  %.r4572 = sub i64 %.t35, %.t34
  %.r4573 = add i64 %.r4572, 1
  %.p4574 = call i8* @malloc(i64 %.r4573)
  %.p4575 = getelementptr inbounds i8, i8* %.r4571, i64 %.t34
  call i8* @memcpy(i8* %.p4574, i8* %.p4575, i64 %.r4572)
  %.p4576 = getelementptr inbounds i8, i8* %.p4574, i64 %.r4572
  store i8 0, i8* %.p4576
  %.t36 = bitcast i8* %.p4574 to i8*
  store i8* %.t36, i8** %body
  %.r4577 = load i8*, i8** %lit
  %.t37 = call i64 @strlen(i8* %.r4577)
  %.t38 = icmp sgt i64 %.t37, 0
  br i1 %.t38, label %if_then_0_34, label %if_next_0_35
if_then_0_34:
  %__fld.39 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t40 = bitcast %Ast* %__fld.39 to %Ast*
  %.t41 = bitcast %Span* %span to %Span*
  %.p4578 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.325, i64 0, i64 0
  %.r4579 = load i8*, i8** %lit
  %.t42 = call i64 @Ast__add0(%Ast* %.t40, i8* %.p4578, i8* %.r4579, %Span* %.t41)
  %.p4580 = getelementptr i64, i64* null, i32 1
  %.r4581 = ptrtoint i64* %.p4580 to i64
  %.p4582 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %parts, i32 0, i32 0
  %.p4583 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %parts, i32 0, i32 1
  %.p4584 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %parts, i32 0, i32 2
  %.r4585 = load i64, i64* %.p4582
  %.r4586 = load i64, i64* %.p4583
  %.r4587 = icmp sge i64 %.r4585, %.r4586
  br i1 %.r4587, label %append.grow.4588, label %append.after.4589
append.grow.4588:
  %.r4590 = load i64*, i64** %.p4584
  %.r4591 = icmp eq i64 %.r4586, 0
  %.r4592 = mul i64 %.r4586, 2
  %.r4593 = select i1 %.r4591, i64 1, i64 %.r4592
  %.r4594 = mul i64 %.r4593, %.r4581
  %.p4595 = call i8* @malloc(i64 %.r4594)
  %.p4596 = bitcast i8* %.p4595 to i64*
  %.r4597 = mul i64 %.r4585, %.r4581
  %.p4598 = bitcast i64* %.r4590 to i8*
  call i8* @memcpy(i8* %.p4595, i8* %.p4598, i64 %.r4597)
  call void @free(i8* %.p4598)
  store i64* %.p4596, i64** %.p4584
  store i64 %.r4593, i64* %.p4583
  br label %append.after.4589
append.after.4589:
  %.r4599 = load i64*, i64** %.p4584
  %.p4600 = getelementptr inbounds i64, i64* %.r4599, i64 %.r4585
  store i64 %.t42, i64* %.p4600
  %.r4601 = add i64 %.r4585, 1
  store i64 %.r4601, i64* %.p4582
  %.p4602 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  store i8* %.p4602, i8** %lit
  br label %if_end_33
if_next_0_35:
  br label %if_end_33
if_end_33:
  %.p4603 = getelementptr inbounds %Diags, %Diags* %sub_diags, i32 0, i32 0
  store { i64, i64, %Diag* } zeroinitializer, { i64, i64, %Diag* }* %.p4603
  %.t43 = bitcast %Diags* %sub_diags to %Diags*
  %.r4604 = load i8*, i8** %body
  call void @lex({ i64, i64, %Token* }* %sub_toks, i8* %.r4604, %Diags* %.t43)
  %.t44 = bitcast %Diags* %sub_diags to %Diags*
  %.t45 = call i1 @Diags__had_errors(%Diags* %.t44)
  br i1 %.t45, label %if_then_0_37, label %if_next_0_38
if_then_0_37:
  %__fld.46 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 3
  %.t47 = bitcast %Diags* %__fld.46 to %Diags*
  %.p4605 = getelementptr inbounds [21 x i8], [21 x i8]* @.str.326, i64 0, i64 0
  %.r4606 = load i8*, i8** %body
  %.r4607 = call i64 @strlen(i8* %.p4605)
  %.r4608 = call i64 @strlen(i8* %.r4606)
  %.r4609 = add i64 %.r4607, %.r4608
  %.r4610 = add i64 %.r4609, 1
  %.t48 = call i8* @malloc(i64 %.r4610)
  call i8* @memcpy(i8* %.t48, i8* %.p4605, i64 %.r4607)
  %.p4611 = getelementptr inbounds i8, i8* %.t48, i64 %.r4607
  call i8* @memcpy(i8* %.p4611, i8* %.r4606, i64 %.r4608)
  %.p4612 = getelementptr inbounds i8, i8* %.t48, i64 %.r4609
  store i8 0, i8* %.p4612
  %.p4613 = getelementptr inbounds [14 x i8], [14 x i8]* @.str.327, i64 0, i64 0
  %.r4614 = call i64 @strlen(i8* %.t48)
  %.r4615 = call i64 @strlen(i8* %.p4613)
  %.r4616 = add i64 %.r4614, %.r4615
  %.r4617 = add i64 %.r4616, 1
  %.t49 = call i8* @malloc(i64 %.r4617)
  call i8* @memcpy(i8* %.t49, i8* %.t48, i64 %.r4614)
  %.p4618 = getelementptr inbounds i8, i8* %.t49, i64 %.r4614
  call i8* @memcpy(i8* %.p4618, i8* %.p4613, i64 %.r4615)
  %.p4619 = getelementptr inbounds i8, i8* %.t49, i64 %.r4616
  store i8 0, i8* %.p4619
  %.t50 = bitcast %Span* %span to %Span*
  %.p4620 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.328, i64 0, i64 0
  %.p4621 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p4622 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @Diags__add(%Diags* %.t47, i8* %.p4620, i8* %.t49, %Span* %.t50, i8* %.p4621, i8* %.p4622)
  %.t51 = sub i64 0, 1
  ret i64 %.t51
if_next_0_38:
  br label %if_end_36
if_end_36:
  %__fld.52 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 0
  %.r4623 = load { i64, i64, %Token* }, { i64, i64, %Token* }* %__fld.52
  store { i64, i64, %Token* } %.r4623, { i64, i64, %Token* }* %saved_toks
  %.p4624 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 1
  %.t53 = load i64, i64* %.p4624
  store i64 %.t53, i64* %saved_pos
  %__fld.54 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 3
  %__fld.55 = getelementptr inbounds %Diags, %Diags* %__fld.54, i32 0, i32 0
  %.p4625 = getelementptr inbounds { i64, i64, %Diag* }, { i64, i64, %Diag* }* %__fld.55, i32 0, i32 0
  %.t56 = load i64, i64* %.p4625
  store i64 %.t56, i64* %before
  %.r4626 = load { i64, i64, %Token* }, { i64, i64, %Token* }* %sub_toks
  %.p4627 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 0
  store { i64, i64, %Token* } %.r4626, { i64, i64, %Token* }* %.p4627
  %.p4628 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 1
  store i64 0, i64* %.p4628
  %.t57 = bitcast %Parser* %self to %Parser*
  %.t58 = call i64 @Parser__parse_expr(%Parser* %.t57)
  store i64 %.t58, i64* %inner
  %.r4629 = load { i64, i64, %Token* }, { i64, i64, %Token* }* %saved_toks
  %.p4630 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 0
  store { i64, i64, %Token* } %.r4629, { i64, i64, %Token* }* %.p4630
  %.r4631 = load i64, i64* %saved_pos
  %.p4632 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 1
  store i64 %.r4631, i64* %.p4632
  br label %while_cond_39
while_cond_39:
  %__fld.59 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 3
  %__fld.60 = getelementptr inbounds %Diags, %Diags* %__fld.59, i32 0, i32 0
  %.p4633 = getelementptr inbounds { i64, i64, %Diag* }, { i64, i64, %Diag* }* %__fld.60, i32 0, i32 0
  %.t61 = load i64, i64* %.p4633
  %.r4634 = load i64, i64* %before
  %.t62 = icmp sgt i64 %.t61, %.r4634
  br i1 %.t62, label %while_body_40, label %while_end_41
while_body_40:
  %__fld.63 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 3
  %__fld.64 = getelementptr inbounds %Diags, %Diags* %__fld.63, i32 0, i32 0
  %.p4635 = getelementptr inbounds { i64, i64, %Diag* }, { i64, i64, %Diag* }* %__fld.64, i32 0, i32 0
  %.r4636 = load i64, i64* %.p4635
  %.r4637 = sub i64 %.r4636, 1
  %.p4638 = getelementptr inbounds { i64, i64, %Diag* }, { i64, i64, %Diag* }* %__fld.64, i32 0, i32 0
  %.r4639 = load i64, i64* %.p4638
  %.r4640 = icmp slt i64 %.r4637, 0
  %.r4641 = icmp sge i64 %.r4637, %.r4639
  %.r4642 = or i1 %.r4640, %.r4641
  br i1 %.r4642, label %idx.fail.4644, label %idx.ok.4643
idx.fail.4644:
  %.p4645 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p4645, i64 %.r4637, i64 %.r4639)
  call void @exit(i32 1)
  unreachable
idx.ok.4643:
  %.p4647 = getelementptr inbounds { i64, i64, %Diag* }, { i64, i64, %Diag* }* %__fld.64, i32 0, i32 2
  %.p4646 = load %Diag*, %Diag** %.p4647
  %.p4648 = getelementptr inbounds %Diag, %Diag* %.p4646, i64 %.r4637
  %.t65 = load %Diag, %Diag* %.p4648
  %.p4649 = getelementptr %Diag, %Diag* null, i32 1
  %.r4650 = ptrtoint %Diag* %.p4649 to i64
  %.p4651 = getelementptr inbounds %Diag, %Diag* %.p4648, i64 1
  %.r4652 = sub i64 %.r4636, %.r4637
  %.r4653 = sub i64 %.r4652, 1
  %.r4654 = mul i64 %.r4653, %.r4650
  %.p4655 = bitcast %Diag* %.p4648 to i8*
  %.p4656 = bitcast %Diag* %.p4651 to i8*
  call i8* @memmove(i8* %.p4655, i8* %.p4656, i64 %.r4654)
  %.r4657 = sub i64 %.r4636, 1
  store i64 %.r4657, i64* %.p4635
  br label %while_cond_39
while_end_41:
  %.r4658 = load i64, i64* %inner
  %.t66 = icmp slt i64 %.r4658, 0
  br i1 %.t66, label %if_then_0_43, label %if_next_0_44
if_then_0_43:
  %__fld.67 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 3
  %.t68 = bitcast %Diags* %__fld.67 to %Diags*
  %.p4659 = getelementptr inbounds [21 x i8], [21 x i8]* @.str.326, i64 0, i64 0
  %.r4660 = load i8*, i8** %body
  %.r4661 = call i64 @strlen(i8* %.p4659)
  %.r4662 = call i64 @strlen(i8* %.r4660)
  %.r4663 = add i64 %.r4661, %.r4662
  %.r4664 = add i64 %.r4663, 1
  %.t69 = call i8* @malloc(i64 %.r4664)
  call i8* @memcpy(i8* %.t69, i8* %.p4659, i64 %.r4661)
  %.p4665 = getelementptr inbounds i8, i8* %.t69, i64 %.r4661
  call i8* @memcpy(i8* %.p4665, i8* %.r4660, i64 %.r4662)
  %.p4666 = getelementptr inbounds i8, i8* %.t69, i64 %.r4663
  store i8 0, i8* %.p4666
  %.p4667 = getelementptr inbounds [14 x i8], [14 x i8]* @.str.327, i64 0, i64 0
  %.r4668 = call i64 @strlen(i8* %.t69)
  %.r4669 = call i64 @strlen(i8* %.p4667)
  %.r4670 = add i64 %.r4668, %.r4669
  %.r4671 = add i64 %.r4670, 1
  %.t70 = call i8* @malloc(i64 %.r4671)
  call i8* @memcpy(i8* %.t70, i8* %.t69, i64 %.r4668)
  %.p4672 = getelementptr inbounds i8, i8* %.t70, i64 %.r4668
  call i8* @memcpy(i8* %.p4672, i8* %.p4667, i64 %.r4669)
  %.p4673 = getelementptr inbounds i8, i8* %.t70, i64 %.r4670
  store i8 0, i8* %.p4673
  %.t71 = bitcast %Span* %span to %Span*
  %.p4674 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.328, i64 0, i64 0
  %.p4675 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p4676 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @Diags__add(%Diags* %.t68, i8* %.p4674, i8* %.t70, %Span* %.t71, i8* %.p4675, i8* %.p4676)
  %.t72 = sub i64 0, 1
  ret i64 %.t72
if_next_0_44:
  br label %if_end_42
if_end_42:
  %__fld.73 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t74 = bitcast %Ast* %__fld.73 to %Ast*
  %.t75 = bitcast %Span* %span to %Span*
  %.p4678 = getelementptr i64, i64* null, i32 1
  %.r4679 = ptrtoint i64* %.p4678 to i64
  %.r4680 = mul i64 %.r4679, 1
  %.p4677 = call i8* @malloc(i64 %.r4680)
  %.p4681 = bitcast i8* %.p4677 to i64*
  %.r4682 = load i64, i64* %inner
  %.p4683 = getelementptr inbounds i64, i64* %.p4681, i64 0
  store i64 %.r4682, i64* %.p4683
  %.p4684 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__agg.76, i32 0, i32 0
  store i64 1, i64* %.p4684
  %.p4685 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__agg.76, i32 0, i32 1
  store i64 1, i64* %.p4685
  %.p4686 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %__agg.76, i32 0, i32 2
  store i64* %.p4681, i64** %.p4686
  %.t77 = bitcast { i64, i64, i64* }* %__agg.76 to { i64, i64, i64* }*
  %.p4687 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.329, i64 0, i64 0
  %.p4688 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.330, i64 0, i64 0
  %.t78 = call i64 @Ast__addl(%Ast* %.t74, i8* %.p4687, i8* %.p4688, %Span* %.t75, { i64, i64, i64* }* %.t77)
  %.p4689 = getelementptr i64, i64* null, i32 1
  %.r4690 = ptrtoint i64* %.p4689 to i64
  %.p4691 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %parts, i32 0, i32 0
  %.p4692 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %parts, i32 0, i32 1
  %.p4693 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %parts, i32 0, i32 2
  %.r4694 = load i64, i64* %.p4691
  %.r4695 = load i64, i64* %.p4692
  %.r4696 = icmp sge i64 %.r4694, %.r4695
  br i1 %.r4696, label %append.grow.4697, label %append.after.4698
append.grow.4697:
  %.r4699 = load i64*, i64** %.p4693
  %.r4700 = icmp eq i64 %.r4695, 0
  %.r4701 = mul i64 %.r4695, 2
  %.r4702 = select i1 %.r4700, i64 1, i64 %.r4701
  %.r4703 = mul i64 %.r4702, %.r4690
  %.p4704 = call i8* @malloc(i64 %.r4703)
  %.p4705 = bitcast i8* %.p4704 to i64*
  %.r4706 = mul i64 %.r4694, %.r4690
  %.p4707 = bitcast i64* %.r4699 to i8*
  call i8* @memcpy(i8* %.p4704, i8* %.p4707, i64 %.r4706)
  call void @free(i8* %.p4707)
  store i64* %.p4705, i64** %.p4693
  store i64 %.r4702, i64* %.p4692
  br label %append.after.4698
append.after.4698:
  %.r4708 = load i64*, i64** %.p4693
  %.p4709 = getelementptr inbounds i64, i64* %.r4708, i64 %.r4694
  store i64 %.t78, i64* %.p4709
  %.r4710 = add i64 %.r4694, 1
  store i64 %.r4710, i64* %.p4691
  %.r4711 = load i64, i64* %j
  store i64 %.r4711, i64* %i
  br label %if_end_6
if_next_2_18:
  %.r4712 = load i64, i64* %c
  %.t79 = icmp eq i64 %.r4712, 125
  br i1 %.t79, label %if_then_3_45, label %if_next_3_46
if_then_3_45:
  %__fld.80 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 3
  %.t81 = bitcast %Diags* %__fld.80 to %Diags*
  %.t82 = bitcast %Span* %span to %Span*
  %.p4713 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.331, i64 0, i64 0
  %.p4714 = getelementptr inbounds [56 x i8], [56 x i8]* @.str.332, i64 0, i64 0
  %.p4715 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p4716 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @Diags__add(%Diags* %.t81, i8* %.p4713, i8* %.p4714, %Span* %.t82, i8* %.p4715, i8* %.p4716)
  %.t83 = sub i64 0, 1
  ret i64 %.t83
if_next_3_46:
  store i64 1, i64* %size
  %.r4717 = load i64, i64* %c
  %.t84 = icmp sge i64 %.r4717, 240
  br i1 %.t84, label %if_then_0_48, label %if_next_0_49
if_then_0_48:
  store i64 4, i64* %size
  br label %if_end_47
if_next_0_49:
  %.r4718 = load i64, i64* %c
  %.t85 = icmp sge i64 %.r4718, 224
  br i1 %.t85, label %if_then_1_50, label %if_next_1_51
if_then_1_50:
  store i64 3, i64* %size
  br label %if_end_47
if_next_1_51:
  %.r4719 = load i64, i64* %c
  %.t86 = icmp sge i64 %.r4719, 192
  br i1 %.t86, label %if_then_2_52, label %if_next_2_53
if_then_2_52:
  store i64 2, i64* %size
  br label %if_end_47
if_next_2_53:
  br label %if_end_47
if_end_47:
  %.r4720 = load i64, i64* %i
  %.r4721 = load i64, i64* %size
  %.t87 = add i64 %.r4720, %.r4721
  %.r4722 = load i8*, i8** %raw
  %.r4723 = load i64, i64* %i
  %.r4724 = sub i64 %.t87, %.r4723
  %.r4725 = add i64 %.r4724, 1
  %.p4726 = call i8* @malloc(i64 %.r4725)
  %.p4727 = getelementptr inbounds i8, i8* %.r4722, i64 %.r4723
  call i8* @memcpy(i8* %.p4726, i8* %.p4727, i64 %.r4724)
  %.p4728 = getelementptr inbounds i8, i8* %.p4726, i64 %.r4724
  store i8 0, i8* %.p4728
  %.t88 = bitcast i8* %.p4726 to i8*
  %.r4729 = load i8*, i8** %lit
  %.r4730 = call i64 @strlen(i8* %.r4729)
  %.r4731 = call i64 @strlen(i8* %.t88)
  %.r4732 = add i64 %.r4730, %.r4731
  %.r4733 = add i64 %.r4732, 1
  %.t89 = call i8* @malloc(i64 %.r4733)
  call i8* @memcpy(i8* %.t89, i8* %.r4729, i64 %.r4730)
  %.p4734 = getelementptr inbounds i8, i8* %.t89, i64 %.r4730
  call i8* @memcpy(i8* %.p4734, i8* %.t88, i64 %.r4731)
  %.p4735 = getelementptr inbounds i8, i8* %.t89, i64 %.r4732
  store i8 0, i8* %.p4735
  store i8* %.t89, i8** %lit
  %.r4736 = load i64, i64* %i
  %.r4737 = load i64, i64* %size
  %.t90 = add i64 %.r4736, %.r4737
  store i64 %.t90, i64* %i
  br label %if_end_6
if_end_6:
  br label %while_cond_0
while_end_2:
  %.r4738 = load i8*, i8** %lit
  %.t92 = call i64 @strlen(i8* %.r4738)
  %.t93 = icmp sgt i64 %.t92, 0
  br i1 %.t93, label %sc_short_58, label %sc_rhs_57
sc_rhs_57:
  %.p4739 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %parts, i32 0, i32 0
  %.t94 = load i64, i64* %.p4739
  %.t95 = icmp eq i64 %.t94, 0
  store i1 %.t95, i1* %__sc.91
  br label %sc_end_59
sc_short_58:
  store i1 true, i1* %__sc.91
  br label %sc_end_59
sc_end_59:
  %.r4740 = load i1, i1* %__sc.91
  br i1 %.r4740, label %if_then_0_55, label %if_next_0_56
if_then_0_55:
  %__fld.96 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t97 = bitcast %Ast* %__fld.96 to %Ast*
  %.t98 = bitcast %Span* %span to %Span*
  %.p4741 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.325, i64 0, i64 0
  %.r4742 = load i8*, i8** %lit
  %.t99 = call i64 @Ast__add0(%Ast* %.t97, i8* %.p4741, i8* %.r4742, %Span* %.t98)
  %.p4743 = getelementptr i64, i64* null, i32 1
  %.r4744 = ptrtoint i64* %.p4743 to i64
  %.p4745 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %parts, i32 0, i32 0
  %.p4746 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %parts, i32 0, i32 1
  %.p4747 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %parts, i32 0, i32 2
  %.r4748 = load i64, i64* %.p4745
  %.r4749 = load i64, i64* %.p4746
  %.r4750 = icmp sge i64 %.r4748, %.r4749
  br i1 %.r4750, label %append.grow.4751, label %append.after.4752
append.grow.4751:
  %.r4753 = load i64*, i64** %.p4747
  %.r4754 = icmp eq i64 %.r4749, 0
  %.r4755 = mul i64 %.r4749, 2
  %.r4756 = select i1 %.r4754, i64 1, i64 %.r4755
  %.r4757 = mul i64 %.r4756, %.r4744
  %.p4758 = call i8* @malloc(i64 %.r4757)
  %.p4759 = bitcast i8* %.p4758 to i64*
  %.r4760 = mul i64 %.r4748, %.r4744
  %.p4761 = bitcast i64* %.r4753 to i8*
  call i8* @memcpy(i8* %.p4758, i8* %.p4761, i64 %.r4760)
  call void @free(i8* %.p4761)
  store i64* %.p4759, i64** %.p4747
  store i64 %.r4756, i64* %.p4746
  br label %append.after.4752
append.after.4752:
  %.r4762 = load i64*, i64** %.p4747
  %.p4763 = getelementptr inbounds i64, i64* %.r4762, i64 %.r4748
  store i64 %.t99, i64* %.p4763
  %.r4764 = add i64 %.r4748, 1
  store i64 %.r4764, i64* %.p4745
  br label %if_end_54
if_next_0_56:
  br label %if_end_54
if_end_54:
  %.p4765 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %parts, i32 0, i32 0
  %.r4766 = load i64, i64* %.p4765
  %.r4767 = icmp slt i64 0, 0
  %.r4768 = icmp sge i64 0, %.r4766
  %.r4769 = or i1 %.r4767, %.r4768
  br i1 %.r4769, label %idx.fail.4771, label %idx.ok.4770
idx.fail.4771:
  %.p4772 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p4772, i64 0, i64 %.r4766)
  call void @exit(i32 1)
  unreachable
idx.ok.4770:
  %.p4774 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %parts, i32 0, i32 2
  %.p4773 = load i64*, i64** %.p4774
  %.p4775 = getelementptr inbounds i64, i64* %.p4773, i64 0
  %.t100 = load i64, i64* %.p4775
  store i64 %.t100, i64* %acc
  store i64 1, i64* %k
  br label %while_cond_60
while_cond_60:
  %.p4776 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %parts, i32 0, i32 0
  %.t101 = load i64, i64* %.p4776
  %.r4777 = load i64, i64* %k
  %.t102 = icmp slt i64 %.r4777, %.t101
  br i1 %.t102, label %while_body_61, label %while_end_62
while_body_61:
  %__fld.103 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t104 = bitcast %Ast* %__fld.103 to %Ast*
  %.t105 = bitcast %Span* %span to %Span*
  %.r4778 = load i64, i64* %k
  %.p4779 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %parts, i32 0, i32 0
  %.r4780 = load i64, i64* %.p4779
  %.r4781 = icmp slt i64 %.r4778, 0
  %.r4782 = icmp sge i64 %.r4778, %.r4780
  %.r4783 = or i1 %.r4781, %.r4782
  br i1 %.r4783, label %idx.fail.4785, label %idx.ok.4784
idx.fail.4785:
  %.p4786 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p4786, i64 %.r4778, i64 %.r4780)
  call void @exit(i32 1)
  unreachable
idx.ok.4784:
  %.p4788 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %parts, i32 0, i32 2
  %.p4787 = load i64*, i64** %.p4788
  %.p4789 = getelementptr inbounds i64, i64* %.p4787, i64 %.r4778
  %.t106 = load i64, i64* %.p4789
  %.p4790 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.317, i64 0, i64 0
  %.p4791 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.307, i64 0, i64 0
  %.r4792 = load i64, i64* %acc
  %.t107 = call i64 @Ast__add2(%Ast* %.t104, i8* %.p4790, i8* %.p4791, %Span* %.t105, i64 %.r4792, i64 %.t106)
  store i64 %.t107, i64* %acc
  %.r4793 = load i64, i64* %k
  %.t108 = add i64 %.r4793, 1
  store i64 %.t108, i64* %k
  br label %while_cond_60
while_end_62:
  %.t109 = load i64, i64* %acc
  ret i64 %.t109
}

define i64 @Parser__parse_expr(%Parser* %self) {
entry:
  %.t0 = bitcast %Parser* %self to %Parser*
  %.t1 = call i64 @Parser__parse_or(%Parser* %.t0)
  ret i64 %.t1
}

define i64 @Parser__parse_or(%Parser* %self) {
entry:
  %lhs = alloca i64
  %rhs = alloca i64
  %__agg.15 = alloca %Span
  %__agg.19 = alloca %Span
  %__agg.14 = alloca %Span
  %.t0 = bitcast %Parser* %self to %Parser*
  %.t1 = call i64 @Parser__parse_and(%Parser* %.t0)
  store i64 %.t1, i64* %lhs
  %.r4794 = load i64, i64* %lhs
  %.t2 = icmp slt i64 %.r4794, 0
  br i1 %.t2, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t3 = sub i64 0, 1
  ret i64 %.t3
if_next_0_2:
  br label %if_end_0
if_end_0:
  br label %while_cond_3
while_cond_3:
  %.t4 = bitcast %Parser* %self to %Parser*
  %.p4795 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.72, i64 0, i64 0
  %.t5 = call i1 @Parser__at(%Parser* %.t4, i8* %.p4795)
  br i1 %.t5, label %while_body_4, label %while_end_5
while_body_4:
  %.t6 = bitcast %Parser* %self to %Parser*
  %.t7 = call i64 @Parser__advance(%Parser* %.t6)
  %.t8 = bitcast %Parser* %self to %Parser*
  %.t9 = call i64 @Parser__parse_and(%Parser* %.t8)
  store i64 %.t9, i64* %rhs
  %.r4796 = load i64, i64* %rhs
  %.t10 = icmp slt i64 %.r4796, 0
  br i1 %.t10, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.t11 = sub i64 0, 1
  ret i64 %.t11
if_next_0_8:
  br label %if_end_6
if_end_6:
  %__fld.12 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t13 = bitcast %Ast* %__fld.12 to %Ast*
  %__fld.16 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t17 = bitcast %Ast* %__fld.16 to %Ast*
  %.r4797 = load i64, i64* %lhs
  call void @Ast__span_of(%Span* %__agg.15, %Ast* %.t17, i64 %.r4797)
  %.t18 = bitcast %Span* %__agg.15 to %Span*
  %__fld.20 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t21 = bitcast %Ast* %__fld.20 to %Ast*
  %.r4798 = load i64, i64* %rhs
  call void @Ast__span_of(%Span* %__agg.19, %Ast* %.t21, i64 %.r4798)
  %.t22 = bitcast %Span* %__agg.19 to %Span*
  call void @span_to(%Span* %__agg.14, %Span* %.t18, %Span* %.t22)
  %.t23 = bitcast %Span* %__agg.14 to %Span*
  %.p4799 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.317, i64 0, i64 0
  %.p4800 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.72, i64 0, i64 0
  %.r4801 = load i64, i64* %lhs
  %.r4802 = load i64, i64* %rhs
  %.t24 = call i64 @Ast__add2(%Ast* %.t13, i8* %.p4799, i8* %.p4800, %Span* %.t23, i64 %.r4801, i64 %.r4802)
  store i64 %.t24, i64* %lhs
  br label %while_cond_3
while_end_5:
  %.t25 = load i64, i64* %lhs
  ret i64 %.t25
}

define i64 @Parser__parse_and(%Parser* %self) {
entry:
  %lhs = alloca i64
  %rhs = alloca i64
  %__agg.15 = alloca %Span
  %__agg.19 = alloca %Span
  %__agg.14 = alloca %Span
  %.t0 = bitcast %Parser* %self to %Parser*
  %.t1 = call i64 @Parser__parse_not(%Parser* %.t0)
  store i64 %.t1, i64* %lhs
  %.r4803 = load i64, i64* %lhs
  %.t2 = icmp slt i64 %.r4803, 0
  br i1 %.t2, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t3 = sub i64 0, 1
  ret i64 %.t3
if_next_0_2:
  br label %if_end_0
if_end_0:
  br label %while_cond_3
while_cond_3:
  %.t4 = bitcast %Parser* %self to %Parser*
  %.p4804 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.70, i64 0, i64 0
  %.t5 = call i1 @Parser__at(%Parser* %.t4, i8* %.p4804)
  br i1 %.t5, label %while_body_4, label %while_end_5
while_body_4:
  %.t6 = bitcast %Parser* %self to %Parser*
  %.t7 = call i64 @Parser__advance(%Parser* %.t6)
  %.t8 = bitcast %Parser* %self to %Parser*
  %.t9 = call i64 @Parser__parse_not(%Parser* %.t8)
  store i64 %.t9, i64* %rhs
  %.r4805 = load i64, i64* %rhs
  %.t10 = icmp slt i64 %.r4805, 0
  br i1 %.t10, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.t11 = sub i64 0, 1
  ret i64 %.t11
if_next_0_8:
  br label %if_end_6
if_end_6:
  %__fld.12 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t13 = bitcast %Ast* %__fld.12 to %Ast*
  %__fld.16 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t17 = bitcast %Ast* %__fld.16 to %Ast*
  %.r4806 = load i64, i64* %lhs
  call void @Ast__span_of(%Span* %__agg.15, %Ast* %.t17, i64 %.r4806)
  %.t18 = bitcast %Span* %__agg.15 to %Span*
  %__fld.20 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t21 = bitcast %Ast* %__fld.20 to %Ast*
  %.r4807 = load i64, i64* %rhs
  call void @Ast__span_of(%Span* %__agg.19, %Ast* %.t21, i64 %.r4807)
  %.t22 = bitcast %Span* %__agg.19 to %Span*
  call void @span_to(%Span* %__agg.14, %Span* %.t18, %Span* %.t22)
  %.t23 = bitcast %Span* %__agg.14 to %Span*
  %.p4808 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.317, i64 0, i64 0
  %.p4809 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.70, i64 0, i64 0
  %.r4810 = load i64, i64* %lhs
  %.r4811 = load i64, i64* %rhs
  %.t24 = call i64 @Ast__add2(%Ast* %.t13, i8* %.p4808, i8* %.p4809, %Span* %.t23, i64 %.r4810, i64 %.r4811)
  store i64 %.t24, i64* %lhs
  br label %while_cond_3
while_end_5:
  %.t25 = load i64, i64* %lhs
  ret i64 %.t25
}

define i64 @Parser__parse_not(%Parser* %self) {
entry:
  %t = alloca i64
  %e = alloca i64
  %__agg.11 = alloca %Span
  %__agg.14 = alloca %Span
  %__agg.10 = alloca %Span
  %.t0 = bitcast %Parser* %self to %Parser*
  %.p4812 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.74, i64 0, i64 0
  %.t1 = call i1 @Parser__at(%Parser* %.t0, i8* %.p4812)
  br i1 %.t1, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t2 = bitcast %Parser* %self to %Parser*
  %.t3 = call i64 @Parser__advance(%Parser* %.t2)
  store i64 %.t3, i64* %t
  %.t4 = bitcast %Parser* %self to %Parser*
  %.t5 = call i64 @Parser__parse_not(%Parser* %.t4)
  store i64 %.t5, i64* %e
  %.r4813 = load i64, i64* %e
  %.t6 = icmp slt i64 %.r4813, 0
  br i1 %.t6, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.t7 = sub i64 0, 1
  ret i64 %.t7
if_next_0_5:
  br label %if_end_3
if_end_3:
  %__fld.8 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t9 = bitcast %Ast* %__fld.8 to %Ast*
  %.t12 = bitcast %Parser* %self to %Parser*
  %.r4814 = load i64, i64* %t
  call void @Parser__tspan(%Span* %__agg.11, %Parser* %.t12, i64 %.r4814)
  %.t13 = bitcast %Span* %__agg.11 to %Span*
  %__fld.15 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t16 = bitcast %Ast* %__fld.15 to %Ast*
  %.r4815 = load i64, i64* %e
  call void @Ast__span_of(%Span* %__agg.14, %Ast* %.t16, i64 %.r4815)
  %.t17 = bitcast %Span* %__agg.14 to %Span*
  call void @span_to(%Span* %__agg.10, %Span* %.t13, %Span* %.t17)
  %.t18 = bitcast %Span* %__agg.10 to %Span*
  %.p4816 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.301, i64 0, i64 0
  %.p4817 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.74, i64 0, i64 0
  %.r4818 = load i64, i64* %e
  %.t19 = call i64 @Ast__add1(%Ast* %.t9, i8* %.p4816, i8* %.p4817, %Span* %.t18, i64 %.r4818)
  ret i64 %.t19
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.t20 = bitcast %Parser* %self to %Parser*
  %.t21 = call i64 @Parser__parse_equality(%Parser* %.t20)
  ret i64 %.t21
}

define i64 @Parser__parse_equality(%Parser* %self) {
entry:
  %lhs = alloca i64
  %op = alloca i8*
  %k = alloca i8*
  %rhs = alloca i64
  %__agg.17 = alloca %Span
  %__agg.21 = alloca %Span
  %__agg.16 = alloca %Span
  %.t0 = bitcast %Parser* %self to %Parser*
  %.t1 = call i64 @Parser__parse_comparison(%Parser* %.t0)
  store i64 %.t1, i64* %lhs
  %.r4819 = load i64, i64* %lhs
  %.t2 = icmp slt i64 %.r4819, 0
  br i1 %.t2, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t3 = sub i64 0, 1
  ret i64 %.t3
if_next_0_2:
  br label %if_end_0
if_end_0:
  br label %while_cond_3
while_cond_3:
  br i1 true, label %while_body_4, label %while_end_5
while_body_4:
  %.p4820 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  store i8* %.p4820, i8** %op
  %.t4 = bitcast %Parser* %self to %Parser*
  %.t5 = call i8* @Parser__peek(%Parser* %.t4)
  store i8* %.t5, i8** %k
  %.r4821 = load i8*, i8** %k
  %.p4822 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.172, i64 0, i64 0
  %.r4823 = call i32 @strcmp(i8* %.r4821, i8* %.p4822)
  %.t6 = icmp eq i32 %.r4823, 0
  br i1 %.t6, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.p4824 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.184, i64 0, i64 0
  store i8* %.p4824, i8** %op
  br label %if_end_6
if_next_0_8:
  %.r4825 = load i8*, i8** %k
  %.p4826 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.174, i64 0, i64 0
  %.r4827 = call i32 @strcmp(i8* %.r4825, i8* %.p4826)
  %.t7 = icmp eq i32 %.r4827, 0
  br i1 %.t7, label %if_then_1_9, label %if_next_1_10
if_then_1_9:
  %.p4828 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.174, i64 0, i64 0
  store i8* %.p4828, i8** %op
  br label %if_end_6
if_next_1_10:
  br label %while_end_5
if_end_6:
  %.t8 = bitcast %Parser* %self to %Parser*
  %.t9 = call i64 @Parser__advance(%Parser* %.t8)
  %.t10 = bitcast %Parser* %self to %Parser*
  %.t11 = call i64 @Parser__parse_comparison(%Parser* %.t10)
  store i64 %.t11, i64* %rhs
  %.r4829 = load i64, i64* %rhs
  %.t12 = icmp slt i64 %.r4829, 0
  br i1 %.t12, label %if_then_0_12, label %if_next_0_13
if_then_0_12:
  %.t13 = sub i64 0, 1
  ret i64 %.t13
if_next_0_13:
  br label %if_end_11
if_end_11:
  %__fld.14 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t15 = bitcast %Ast* %__fld.14 to %Ast*
  %__fld.18 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t19 = bitcast %Ast* %__fld.18 to %Ast*
  %.r4830 = load i64, i64* %lhs
  call void @Ast__span_of(%Span* %__agg.17, %Ast* %.t19, i64 %.r4830)
  %.t20 = bitcast %Span* %__agg.17 to %Span*
  %__fld.22 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t23 = bitcast %Ast* %__fld.22 to %Ast*
  %.r4831 = load i64, i64* %rhs
  call void @Ast__span_of(%Span* %__agg.21, %Ast* %.t23, i64 %.r4831)
  %.t24 = bitcast %Span* %__agg.21 to %Span*
  call void @span_to(%Span* %__agg.16, %Span* %.t20, %Span* %.t24)
  %.t25 = bitcast %Span* %__agg.16 to %Span*
  %.p4832 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.317, i64 0, i64 0
  %.r4833 = load i8*, i8** %op
  %.r4834 = load i64, i64* %lhs
  %.r4835 = load i64, i64* %rhs
  %.t26 = call i64 @Ast__add2(%Ast* %.t15, i8* %.p4832, i8* %.r4833, %Span* %.t25, i64 %.r4834, i64 %.r4835)
  store i64 %.t26, i64* %lhs
  br label %while_cond_3
while_end_5:
  %.t27 = load i64, i64* %lhs
  ret i64 %.t27
}

define i64 @Parser__parse_comparison(%Parser* %self) {
entry:
  %lhs = alloca i64
  %op = alloca i8*
  %k = alloca i8*
  %rhs = alloca i64
  %__agg.19 = alloca %Span
  %__agg.23 = alloca %Span
  %__agg.18 = alloca %Span
  %.t0 = bitcast %Parser* %self to %Parser*
  %.t1 = call i64 @Parser__parse_bitwise(%Parser* %.t0)
  store i64 %.t1, i64* %lhs
  %.r4836 = load i64, i64* %lhs
  %.t2 = icmp slt i64 %.r4836, 0
  br i1 %.t2, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t3 = sub i64 0, 1
  ret i64 %.t3
if_next_0_2:
  br label %if_end_0
if_end_0:
  br label %while_cond_3
while_cond_3:
  br i1 true, label %while_body_4, label %while_end_5
while_body_4:
  %.p4837 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  store i8* %.p4837, i8** %op
  %.t4 = bitcast %Parser* %self to %Parser*
  %.t5 = call i8* @Parser__peek(%Parser* %.t4)
  store i8* %.t5, i8** %k
  %.r4838 = load i8*, i8** %k
  %.p4839 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.176, i64 0, i64 0
  %.r4840 = call i32 @strcmp(i8* %.r4838, i8* %.p4839)
  %.t6 = icmp eq i32 %.r4840, 0
  br i1 %.t6, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.p4841 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.176, i64 0, i64 0
  store i8* %.p4841, i8** %op
  br label %if_end_6
if_next_0_8:
  %.r4842 = load i8*, i8** %k
  %.p4843 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.178, i64 0, i64 0
  %.r4844 = call i32 @strcmp(i8* %.r4842, i8* %.p4843)
  %.t7 = icmp eq i32 %.r4844, 0
  br i1 %.t7, label %if_then_1_9, label %if_next_1_10
if_then_1_9:
  %.p4845 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.178, i64 0, i64 0
  store i8* %.p4845, i8** %op
  br label %if_end_6
if_next_1_10:
  %.r4846 = load i8*, i8** %k
  %.p4847 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.180, i64 0, i64 0
  %.r4848 = call i32 @strcmp(i8* %.r4846, i8* %.p4847)
  %.t8 = icmp eq i32 %.r4848, 0
  br i1 %.t8, label %if_then_2_11, label %if_next_2_12
if_then_2_11:
  %.p4849 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.180, i64 0, i64 0
  store i8* %.p4849, i8** %op
  br label %if_end_6
if_next_2_12:
  %.r4850 = load i8*, i8** %k
  %.p4851 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.182, i64 0, i64 0
  %.r4852 = call i32 @strcmp(i8* %.r4850, i8* %.p4851)
  %.t9 = icmp eq i32 %.r4852, 0
  br i1 %.t9, label %if_then_3_13, label %if_next_3_14
if_then_3_13:
  %.p4853 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.182, i64 0, i64 0
  store i8* %.p4853, i8** %op
  br label %if_end_6
if_next_3_14:
  br label %while_end_5
if_end_6:
  %.t10 = bitcast %Parser* %self to %Parser*
  %.t11 = call i64 @Parser__advance(%Parser* %.t10)
  %.t12 = bitcast %Parser* %self to %Parser*
  %.t13 = call i64 @Parser__parse_bitwise(%Parser* %.t12)
  store i64 %.t13, i64* %rhs
  %.r4854 = load i64, i64* %rhs
  %.t14 = icmp slt i64 %.r4854, 0
  br i1 %.t14, label %if_then_0_16, label %if_next_0_17
if_then_0_16:
  %.t15 = sub i64 0, 1
  ret i64 %.t15
if_next_0_17:
  br label %if_end_15
if_end_15:
  %__fld.16 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t17 = bitcast %Ast* %__fld.16 to %Ast*
  %__fld.20 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t21 = bitcast %Ast* %__fld.20 to %Ast*
  %.r4855 = load i64, i64* %lhs
  call void @Ast__span_of(%Span* %__agg.19, %Ast* %.t21, i64 %.r4855)
  %.t22 = bitcast %Span* %__agg.19 to %Span*
  %__fld.24 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t25 = bitcast %Ast* %__fld.24 to %Ast*
  %.r4856 = load i64, i64* %rhs
  call void @Ast__span_of(%Span* %__agg.23, %Ast* %.t25, i64 %.r4856)
  %.t26 = bitcast %Span* %__agg.23 to %Span*
  call void @span_to(%Span* %__agg.18, %Span* %.t22, %Span* %.t26)
  %.t27 = bitcast %Span* %__agg.18 to %Span*
  %.p4857 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.317, i64 0, i64 0
  %.r4858 = load i8*, i8** %op
  %.r4859 = load i64, i64* %lhs
  %.r4860 = load i64, i64* %rhs
  %.t28 = call i64 @Ast__add2(%Ast* %.t17, i8* %.p4857, i8* %.r4858, %Span* %.t27, i64 %.r4859, i64 %.r4860)
  store i64 %.t28, i64* %lhs
  br label %while_cond_3
while_end_5:
  %.t29 = load i64, i64* %lhs
  ret i64 %.t29
}

define i64 @Parser__parse_bitwise(%Parser* %self) {
entry:
  %lhs = alloca i64
  %op = alloca i8*
  %k = alloca i8*
  %rhs = alloca i64
  %__agg.20 = alloca %Span
  %__agg.24 = alloca %Span
  %__agg.19 = alloca %Span
  %.t0 = bitcast %Parser* %self to %Parser*
  %.t1 = call i64 @Parser__parse_term(%Parser* %.t0)
  store i64 %.t1, i64* %lhs
  %.r4861 = load i64, i64* %lhs
  %.t2 = icmp slt i64 %.r4861, 0
  br i1 %.t2, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t3 = sub i64 0, 1
  ret i64 %.t3
if_next_0_2:
  br label %if_end_0
if_end_0:
  br label %while_cond_3
while_cond_3:
  br i1 true, label %while_body_4, label %while_end_5
while_body_4:
  %.p4862 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  store i8* %.p4862, i8** %op
  %.t4 = bitcast %Parser* %self to %Parser*
  %.t5 = call i8* @Parser__peek(%Parser* %.t4)
  store i8* %.t5, i8** %k
  %.r4863 = load i8*, i8** %k
  %.p4864 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.186, i64 0, i64 0
  %.r4865 = call i32 @strcmp(i8* %.r4863, i8* %.p4864)
  %.t6 = icmp eq i32 %.r4865, 0
  br i1 %.t6, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.p4866 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.312, i64 0, i64 0
  store i8* %.p4866, i8** %op
  br label %if_end_6
if_next_0_8:
  %.r4867 = load i8*, i8** %k
  %.p4868 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.188, i64 0, i64 0
  %.r4869 = call i32 @strcmp(i8* %.r4867, i8* %.p4868)
  %.t7 = icmp eq i32 %.r4869, 0
  br i1 %.t7, label %if_then_1_9, label %if_next_1_10
if_then_1_9:
  %.p4870 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.313, i64 0, i64 0
  store i8* %.p4870, i8** %op
  br label %if_end_6
if_next_1_10:
  %.r4871 = load i8*, i8** %k
  %.p4872 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.190, i64 0, i64 0
  %.r4873 = call i32 @strcmp(i8* %.r4871, i8* %.p4872)
  %.t8 = icmp eq i32 %.r4873, 0
  br i1 %.t8, label %if_then_2_11, label %if_next_2_12
if_then_2_11:
  %.p4874 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.314, i64 0, i64 0
  store i8* %.p4874, i8** %op
  br label %if_end_6
if_next_2_12:
  %.r4875 = load i8*, i8** %k
  %.p4876 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.194, i64 0, i64 0
  %.r4877 = call i32 @strcmp(i8* %.r4875, i8* %.p4876)
  %.t9 = icmp eq i32 %.r4877, 0
  br i1 %.t9, label %if_then_3_13, label %if_next_3_14
if_then_3_13:
  %.p4878 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.194, i64 0, i64 0
  store i8* %.p4878, i8** %op
  br label %if_end_6
if_next_3_14:
  %.r4879 = load i8*, i8** %k
  %.p4880 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.196, i64 0, i64 0
  %.r4881 = call i32 @strcmp(i8* %.r4879, i8* %.p4880)
  %.t10 = icmp eq i32 %.r4881, 0
  br i1 %.t10, label %if_then_4_15, label %if_next_4_16
if_then_4_15:
  %.p4882 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.196, i64 0, i64 0
  store i8* %.p4882, i8** %op
  br label %if_end_6
if_next_4_16:
  br label %while_end_5
if_end_6:
  %.t11 = bitcast %Parser* %self to %Parser*
  %.t12 = call i64 @Parser__advance(%Parser* %.t11)
  %.t13 = bitcast %Parser* %self to %Parser*
  %.t14 = call i64 @Parser__parse_term(%Parser* %.t13)
  store i64 %.t14, i64* %rhs
  %.r4883 = load i64, i64* %rhs
  %.t15 = icmp slt i64 %.r4883, 0
  br i1 %.t15, label %if_then_0_18, label %if_next_0_19
if_then_0_18:
  %.t16 = sub i64 0, 1
  ret i64 %.t16
if_next_0_19:
  br label %if_end_17
if_end_17:
  %__fld.17 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t18 = bitcast %Ast* %__fld.17 to %Ast*
  %__fld.21 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t22 = bitcast %Ast* %__fld.21 to %Ast*
  %.r4884 = load i64, i64* %lhs
  call void @Ast__span_of(%Span* %__agg.20, %Ast* %.t22, i64 %.r4884)
  %.t23 = bitcast %Span* %__agg.20 to %Span*
  %__fld.25 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t26 = bitcast %Ast* %__fld.25 to %Ast*
  %.r4885 = load i64, i64* %rhs
  call void @Ast__span_of(%Span* %__agg.24, %Ast* %.t26, i64 %.r4885)
  %.t27 = bitcast %Span* %__agg.24 to %Span*
  call void @span_to(%Span* %__agg.19, %Span* %.t23, %Span* %.t27)
  %.t28 = bitcast %Span* %__agg.19 to %Span*
  %.p4886 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.317, i64 0, i64 0
  %.r4887 = load i8*, i8** %op
  %.r4888 = load i64, i64* %lhs
  %.r4889 = load i64, i64* %rhs
  %.t29 = call i64 @Ast__add2(%Ast* %.t18, i8* %.p4886, i8* %.r4887, %Span* %.t28, i64 %.r4888, i64 %.r4889)
  store i64 %.t29, i64* %lhs
  br label %while_cond_3
while_end_5:
  %.t30 = load i64, i64* %lhs
  ret i64 %.t30
}

define i64 @Parser__parse_term(%Parser* %self) {
entry:
  %lhs = alloca i64
  %op = alloca i8*
  %k = alloca i8*
  %rhs = alloca i64
  %__agg.17 = alloca %Span
  %__agg.21 = alloca %Span
  %__agg.16 = alloca %Span
  %.t0 = bitcast %Parser* %self to %Parser*
  %.t1 = call i64 @Parser__parse_factor(%Parser* %.t0)
  store i64 %.t1, i64* %lhs
  %.r4890 = load i64, i64* %lhs
  %.t2 = icmp slt i64 %.r4890, 0
  br i1 %.t2, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t3 = sub i64 0, 1
  ret i64 %.t3
if_next_0_2:
  br label %if_end_0
if_end_0:
  br label %while_cond_3
while_cond_3:
  br i1 true, label %while_body_4, label %while_end_5
while_body_4:
  %.p4891 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  store i8* %.p4891, i8** %op
  %.t4 = bitcast %Parser* %self to %Parser*
  %.t5 = call i8* @Parser__peek(%Parser* %.t4)
  store i8* %.t5, i8** %k
  %.r4892 = load i8*, i8** %k
  %.p4893 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.162, i64 0, i64 0
  %.r4894 = call i32 @strcmp(i8* %.r4892, i8* %.p4893)
  %.t6 = icmp eq i32 %.r4894, 0
  br i1 %.t6, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.p4895 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.307, i64 0, i64 0
  store i8* %.p4895, i8** %op
  br label %if_end_6
if_next_0_8:
  %.r4896 = load i8*, i8** %k
  %.p4897 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.164, i64 0, i64 0
  %.r4898 = call i32 @strcmp(i8* %.r4896, i8* %.p4897)
  %.t7 = icmp eq i32 %.r4898, 0
  br i1 %.t7, label %if_then_1_9, label %if_next_1_10
if_then_1_9:
  %.p4899 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.308, i64 0, i64 0
  store i8* %.p4899, i8** %op
  br label %if_end_6
if_next_1_10:
  br label %while_end_5
if_end_6:
  %.t8 = bitcast %Parser* %self to %Parser*
  %.t9 = call i64 @Parser__advance(%Parser* %.t8)
  %.t10 = bitcast %Parser* %self to %Parser*
  %.t11 = call i64 @Parser__parse_factor(%Parser* %.t10)
  store i64 %.t11, i64* %rhs
  %.r4900 = load i64, i64* %rhs
  %.t12 = icmp slt i64 %.r4900, 0
  br i1 %.t12, label %if_then_0_12, label %if_next_0_13
if_then_0_12:
  %.t13 = sub i64 0, 1
  ret i64 %.t13
if_next_0_13:
  br label %if_end_11
if_end_11:
  %__fld.14 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t15 = bitcast %Ast* %__fld.14 to %Ast*
  %__fld.18 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t19 = bitcast %Ast* %__fld.18 to %Ast*
  %.r4901 = load i64, i64* %lhs
  call void @Ast__span_of(%Span* %__agg.17, %Ast* %.t19, i64 %.r4901)
  %.t20 = bitcast %Span* %__agg.17 to %Span*
  %__fld.22 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t23 = bitcast %Ast* %__fld.22 to %Ast*
  %.r4902 = load i64, i64* %rhs
  call void @Ast__span_of(%Span* %__agg.21, %Ast* %.t23, i64 %.r4902)
  %.t24 = bitcast %Span* %__agg.21 to %Span*
  call void @span_to(%Span* %__agg.16, %Span* %.t20, %Span* %.t24)
  %.t25 = bitcast %Span* %__agg.16 to %Span*
  %.p4903 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.317, i64 0, i64 0
  %.r4904 = load i8*, i8** %op
  %.r4905 = load i64, i64* %lhs
  %.r4906 = load i64, i64* %rhs
  %.t26 = call i64 @Ast__add2(%Ast* %.t15, i8* %.p4903, i8* %.r4904, %Span* %.t25, i64 %.r4905, i64 %.r4906)
  store i64 %.t26, i64* %lhs
  br label %while_cond_3
while_end_5:
  %.t27 = load i64, i64* %lhs
  ret i64 %.t27
}

define i64 @Parser__parse_factor(%Parser* %self) {
entry:
  %lhs = alloca i64
  %op = alloca i8*
  %k = alloca i8*
  %rhs = alloca i64
  %__agg.18 = alloca %Span
  %__agg.22 = alloca %Span
  %__agg.17 = alloca %Span
  %.t0 = bitcast %Parser* %self to %Parser*
  %.t1 = call i64 @Parser__parse_unary(%Parser* %.t0)
  store i64 %.t1, i64* %lhs
  %.r4907 = load i64, i64* %lhs
  %.t2 = icmp slt i64 %.r4907, 0
  br i1 %.t2, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t3 = sub i64 0, 1
  ret i64 %.t3
if_next_0_2:
  br label %if_end_0
if_end_0:
  br label %while_cond_3
while_cond_3:
  br i1 true, label %while_body_4, label %while_end_5
while_body_4:
  %.p4908 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  store i8* %.p4908, i8** %op
  %.t4 = bitcast %Parser* %self to %Parser*
  %.t5 = call i8* @Parser__peek(%Parser* %.t4)
  store i8* %.t5, i8** %k
  %.r4909 = load i8*, i8** %k
  %.p4910 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.166, i64 0, i64 0
  %.r4911 = call i32 @strcmp(i8* %.r4909, i8* %.p4910)
  %.t6 = icmp eq i32 %.r4911, 0
  br i1 %.t6, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.p4912 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.309, i64 0, i64 0
  store i8* %.p4912, i8** %op
  br label %if_end_6
if_next_0_8:
  %.r4913 = load i8*, i8** %k
  %.p4914 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.168, i64 0, i64 0
  %.r4915 = call i32 @strcmp(i8* %.r4913, i8* %.p4914)
  %.t7 = icmp eq i32 %.r4915, 0
  br i1 %.t7, label %if_then_1_9, label %if_next_1_10
if_then_1_9:
  %.p4916 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.310, i64 0, i64 0
  store i8* %.p4916, i8** %op
  br label %if_end_6
if_next_1_10:
  %.r4917 = load i8*, i8** %k
  %.p4918 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.170, i64 0, i64 0
  %.r4919 = call i32 @strcmp(i8* %.r4917, i8* %.p4918)
  %.t8 = icmp eq i32 %.r4919, 0
  br i1 %.t8, label %if_then_2_11, label %if_next_2_12
if_then_2_11:
  %.p4920 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.311, i64 0, i64 0
  store i8* %.p4920, i8** %op
  br label %if_end_6
if_next_2_12:
  br label %while_end_5
if_end_6:
  %.t9 = bitcast %Parser* %self to %Parser*
  %.t10 = call i64 @Parser__advance(%Parser* %.t9)
  %.t11 = bitcast %Parser* %self to %Parser*
  %.t12 = call i64 @Parser__parse_unary(%Parser* %.t11)
  store i64 %.t12, i64* %rhs
  %.r4921 = load i64, i64* %rhs
  %.t13 = icmp slt i64 %.r4921, 0
  br i1 %.t13, label %if_then_0_14, label %if_next_0_15
if_then_0_14:
  %.t14 = sub i64 0, 1
  ret i64 %.t14
if_next_0_15:
  br label %if_end_13
if_end_13:
  %__fld.15 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t16 = bitcast %Ast* %__fld.15 to %Ast*
  %__fld.19 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t20 = bitcast %Ast* %__fld.19 to %Ast*
  %.r4922 = load i64, i64* %lhs
  call void @Ast__span_of(%Span* %__agg.18, %Ast* %.t20, i64 %.r4922)
  %.t21 = bitcast %Span* %__agg.18 to %Span*
  %__fld.23 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t24 = bitcast %Ast* %__fld.23 to %Ast*
  %.r4923 = load i64, i64* %rhs
  call void @Ast__span_of(%Span* %__agg.22, %Ast* %.t24, i64 %.r4923)
  %.t25 = bitcast %Span* %__agg.22 to %Span*
  call void @span_to(%Span* %__agg.17, %Span* %.t21, %Span* %.t25)
  %.t26 = bitcast %Span* %__agg.17 to %Span*
  %.p4924 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.317, i64 0, i64 0
  %.r4925 = load i8*, i8** %op
  %.r4926 = load i64, i64* %lhs
  %.r4927 = load i64, i64* %rhs
  %.t27 = call i64 @Ast__add2(%Ast* %.t16, i8* %.p4924, i8* %.r4925, %Span* %.t26, i64 %.r4926, i64 %.r4927)
  store i64 %.t27, i64* %lhs
  br label %while_cond_3
while_end_5:
  %.t28 = load i64, i64* %lhs
  ret i64 %.t28
}

define i64 @Parser__parse_unary(%Parser* %self) {
entry:
  %k = alloca i8*
  %op = alloca i8*
  %t = alloca i64
  %e = alloca i64
  %__agg.19 = alloca %Span
  %__agg.22 = alloca %Span
  %__agg.18 = alloca %Span
  %.t0 = bitcast %Parser* %self to %Parser*
  %.t1 = call i8* @Parser__peek(%Parser* %.t0)
  store i8* %.t1, i8** %k
  %.p4928 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  store i8* %.p4928, i8** %op
  %.r4929 = load i8*, i8** %k
  %.p4930 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.164, i64 0, i64 0
  %.r4931 = call i32 @strcmp(i8* %.r4929, i8* %.p4930)
  %.t2 = icmp eq i32 %.r4931, 0
  br i1 %.t2, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.p4932 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.333, i64 0, i64 0
  store i8* %.p4932, i8** %op
  br label %if_end_0
if_next_0_2:
  %.r4933 = load i8*, i8** %k
  %.p4934 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.166, i64 0, i64 0
  %.r4935 = call i32 @strcmp(i8* %.r4933, i8* %.p4934)
  %.t3 = icmp eq i32 %.r4935, 0
  br i1 %.t3, label %if_then_1_3, label %if_next_1_4
if_then_1_3:
  %.p4936 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.302, i64 0, i64 0
  store i8* %.p4936, i8** %op
  br label %if_end_0
if_next_1_4:
  %.r4937 = load i8*, i8** %k
  %.p4938 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.186, i64 0, i64 0
  %.r4939 = call i32 @strcmp(i8* %.r4937, i8* %.p4938)
  %.t4 = icmp eq i32 %.r4939, 0
  br i1 %.t4, label %if_then_2_5, label %if_next_2_6
if_then_2_5:
  %.p4940 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.334, i64 0, i64 0
  store i8* %.p4940, i8** %op
  br label %if_end_0
if_next_2_6:
  %.r4941 = load i8*, i8** %k
  %.p4942 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.192, i64 0, i64 0
  %.r4943 = call i32 @strcmp(i8* %.r4941, i8* %.p4942)
  %.t5 = icmp eq i32 %.r4943, 0
  br i1 %.t5, label %if_then_3_7, label %if_next_3_8
if_then_3_7:
  %.p4944 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.335, i64 0, i64 0
  store i8* %.p4944, i8** %op
  br label %if_end_0
if_next_3_8:
  br label %if_end_0
if_end_0:
  %.r4945 = load i8*, i8** %op
  %.t6 = call i64 @strlen(i8* %.r4945)
  %.t7 = icmp eq i64 %.t6, 0
  br i1 %.t7, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.t8 = bitcast %Parser* %self to %Parser*
  %.t9 = call i64 @Parser__parse_postfix(%Parser* %.t8)
  ret i64 %.t9
if_next_0_11:
  br label %if_end_9
if_end_9:
  %.t10 = bitcast %Parser* %self to %Parser*
  %.t11 = call i64 @Parser__advance(%Parser* %.t10)
  store i64 %.t11, i64* %t
  %.t12 = bitcast %Parser* %self to %Parser*
  %.t13 = call i64 @Parser__parse_unary(%Parser* %.t12)
  store i64 %.t13, i64* %e
  %.r4946 = load i64, i64* %e
  %.t14 = icmp slt i64 %.r4946, 0
  br i1 %.t14, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  %.t15 = sub i64 0, 1
  ret i64 %.t15
if_next_0_14:
  br label %if_end_12
if_end_12:
  %__fld.16 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t17 = bitcast %Ast* %__fld.16 to %Ast*
  %.t20 = bitcast %Parser* %self to %Parser*
  %.r4947 = load i64, i64* %t
  call void @Parser__tspan(%Span* %__agg.19, %Parser* %.t20, i64 %.r4947)
  %.t21 = bitcast %Span* %__agg.19 to %Span*
  %__fld.23 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t24 = bitcast %Ast* %__fld.23 to %Ast*
  %.r4948 = load i64, i64* %e
  call void @Ast__span_of(%Span* %__agg.22, %Ast* %.t24, i64 %.r4948)
  %.t25 = bitcast %Span* %__agg.22 to %Span*
  call void @span_to(%Span* %__agg.18, %Span* %.t21, %Span* %.t25)
  %.t26 = bitcast %Span* %__agg.18 to %Span*
  %.p4949 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.301, i64 0, i64 0
  %.r4950 = load i8*, i8** %op
  %.r4951 = load i64, i64* %e
  %.t27 = call i64 @Ast__add1(%Ast* %.t17, i8* %.p4949, i8* %.r4950, %Span* %.t26, i64 %.r4951)
  ret i64 %.t27
}

define i64 @Parser__parse_call_args(%Parser* %self, { i64, i64, i64* }* %args) {
entry:
  %__sc.3 = alloca i1
  %nt = alloca i64
  %nspan = alloca %Span
  %value = alloca i64
  %__agg.24 = alloca %Span
  %__agg.22 = alloca %Span
  %a = alloca i64
  %.t0 = bitcast %Parser* %self to %Parser*
  %.p4952 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.144, i64 0, i64 0
  %.t1 = call i1 @Parser__at(%Parser* %.t0, i8* %.p4952)
  %.t2 = xor i1 %.t1, true
  br i1 %.t2, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  br label %while_cond_3
while_cond_3:
  br i1 true, label %while_body_4, label %while_end_5
while_body_4:
  %.t4 = bitcast %Parser* %self to %Parser*
  %.p4953 = getelementptr inbounds [11 x i8], [11 x i8]* @.str.101, i64 0, i64 0
  %.t5 = call i1 @Parser__at(%Parser* %.t4, i8* %.p4953)
  br i1 %.t5, label %sc_rhs_9, label %sc_short_10
sc_rhs_9:
  %.t6 = bitcast %Parser* %self to %Parser*
  %.t7 = call i8* @Parser__peek_at(%Parser* %.t6, i64 1)
  %.p4954 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.184, i64 0, i64 0
  %.r4955 = call i32 @strcmp(i8* %.t7, i8* %.p4954)
  %.t8 = icmp eq i32 %.r4955, 0
  store i1 %.t8, i1* %__sc.3
  br label %sc_end_11
sc_short_10:
  store i1 false, i1* %__sc.3
  br label %sc_end_11
sc_end_11:
  %.r4956 = load i1, i1* %__sc.3
  br i1 %.r4956, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.t9 = bitcast %Parser* %self to %Parser*
  %.t10 = call i64 @Parser__expect_identifier(%Parser* %.t9)
  store i64 %.t10, i64* %nt
  %.t11 = bitcast %Parser* %self to %Parser*
  %.r4957 = load i64, i64* %nt
  call void @Parser__tspan(%Span* %nspan, %Parser* %.t11, i64 %.r4957)
  %.t12 = bitcast %Parser* %self to %Parser*
  %.t13 = call i64 @Parser__advance(%Parser* %.t12)
  %.t14 = bitcast %Parser* %self to %Parser*
  %.t15 = call i64 @Parser__parse_expr(%Parser* %.t14)
  store i64 %.t15, i64* %value
  %.r4958 = load i64, i64* %value
  %.t16 = icmp slt i64 %.r4958, 0
  br i1 %.t16, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  %.t17 = sub i64 0, 1
  ret i64 %.t17
if_next_0_14:
  br label %if_end_12
if_end_12:
  %__fld.18 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t19 = bitcast %Ast* %__fld.18 to %Ast*
  %.t20 = bitcast %Parser* %self to %Parser*
  %.r4959 = load i64, i64* %nt
  %.t21 = call i8* @Parser__ttext(%Parser* %.t20, i64 %.r4959)
  %.t23 = bitcast %Span* %nspan to %Span*
  %__fld.25 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t26 = bitcast %Ast* %__fld.25 to %Ast*
  %.r4960 = load i64, i64* %value
  call void @Ast__span_of(%Span* %__agg.24, %Ast* %.t26, i64 %.r4960)
  %.t27 = bitcast %Span* %__agg.24 to %Span*
  call void @span_to(%Span* %__agg.22, %Span* %.t23, %Span* %.t27)
  %.t28 = bitcast %Span* %__agg.22 to %Span*
  %.p4961 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.336, i64 0, i64 0
  %.r4962 = load i64, i64* %value
  %.t29 = call i64 @Ast__add1(%Ast* %.t19, i8* %.p4961, i8* %.t21, %Span* %.t28, i64 %.r4962)
  %.p4963 = getelementptr i64, i64* null, i32 1
  %.r4964 = ptrtoint i64* %.p4963 to i64
  %.p4965 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %args, i32 0, i32 0
  %.p4966 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %args, i32 0, i32 1
  %.p4967 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %args, i32 0, i32 2
  %.r4968 = load i64, i64* %.p4965
  %.r4969 = load i64, i64* %.p4966
  %.r4970 = icmp sge i64 %.r4968, %.r4969
  br i1 %.r4970, label %append.grow.4971, label %append.after.4972
append.grow.4971:
  %.r4973 = load i64*, i64** %.p4967
  %.r4974 = icmp eq i64 %.r4969, 0
  %.r4975 = mul i64 %.r4969, 2
  %.r4976 = select i1 %.r4974, i64 1, i64 %.r4975
  %.r4977 = mul i64 %.r4976, %.r4964
  %.p4978 = call i8* @malloc(i64 %.r4977)
  %.p4979 = bitcast i8* %.p4978 to i64*
  %.r4980 = mul i64 %.r4968, %.r4964
  %.p4981 = bitcast i64* %.r4973 to i8*
  call i8* @memcpy(i8* %.p4978, i8* %.p4981, i64 %.r4980)
  call void @free(i8* %.p4981)
  store i64* %.p4979, i64** %.p4967
  store i64 %.r4976, i64* %.p4966
  br label %append.after.4972
append.after.4972:
  %.r4982 = load i64*, i64** %.p4967
  %.p4983 = getelementptr inbounds i64, i64* %.r4982, i64 %.r4968
  store i64 %.t29, i64* %.p4983
  %.r4984 = add i64 %.r4968, 1
  store i64 %.r4984, i64* %.p4965
  br label %if_end_6
if_next_0_8:
  %.t30 = bitcast %Parser* %self to %Parser*
  %.t31 = call i64 @Parser__parse_expr(%Parser* %.t30)
  store i64 %.t31, i64* %a
  %.r4985 = load i64, i64* %a
  %.t32 = icmp slt i64 %.r4985, 0
  br i1 %.t32, label %if_then_0_16, label %if_next_0_17
if_then_0_16:
  %.t33 = sub i64 0, 1
  ret i64 %.t33
if_next_0_17:
  br label %if_end_15
if_end_15:
  %.p4986 = getelementptr i64, i64* null, i32 1
  %.r4987 = ptrtoint i64* %.p4986 to i64
  %.p4988 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %args, i32 0, i32 0
  %.p4989 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %args, i32 0, i32 1
  %.p4990 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %args, i32 0, i32 2
  %.r4991 = load i64, i64* %.p4988
  %.r4992 = load i64, i64* %.p4989
  %.r4993 = icmp sge i64 %.r4991, %.r4992
  br i1 %.r4993, label %append.grow.4994, label %append.after.4995
append.grow.4994:
  %.r4996 = load i64*, i64** %.p4990
  %.r4997 = icmp eq i64 %.r4992, 0
  %.r4998 = mul i64 %.r4992, 2
  %.r4999 = select i1 %.r4997, i64 1, i64 %.r4998
  %.r5000 = mul i64 %.r4999, %.r4987
  %.p5001 = call i8* @malloc(i64 %.r5000)
  %.p5002 = bitcast i8* %.p5001 to i64*
  %.r5003 = mul i64 %.r4991, %.r4987
  %.p5004 = bitcast i64* %.r4996 to i8*
  call i8* @memcpy(i8* %.p5001, i8* %.p5004, i64 %.r5003)
  call void @free(i8* %.p5004)
  store i64* %.p5002, i64** %.p4990
  store i64 %.r4999, i64* %.p4989
  br label %append.after.4995
append.after.4995:
  %.r5005 = load i64*, i64** %.p4990
  %.r5006 = load i64, i64* %a
  %.p5007 = getelementptr inbounds i64, i64* %.r5005, i64 %.r4991
  store i64 %.r5006, i64* %.p5007
  %.r5008 = add i64 %.r4991, 1
  store i64 %.r5008, i64* %.p4988
  br label %if_end_6
if_end_6:
  %.t34 = bitcast %Parser* %self to %Parser*
  %.p5009 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.154, i64 0, i64 0
  %.t35 = call i1 @Parser__at(%Parser* %.t34, i8* %.p5009)
  br i1 %.t35, label %if_then_0_19, label %if_next_0_20
if_then_0_19:
  %.t36 = bitcast %Parser* %self to %Parser*
  %.t37 = call i64 @Parser__advance(%Parser* %.t36)
  br label %if_end_18
if_next_0_20:
  br label %while_end_5
if_end_18:
  br label %while_cond_3
while_end_5:
  br label %if_end_0
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.t38 = bitcast %Parser* %self to %Parser*
  %.p5010 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.144, i64 0, i64 0
  %.t39 = call i64 @Parser__expect(%Parser* %.t38, i8* %.p5010)
  ret i64 %.t39
}

define i64 @Parser__parse_postfix(%Parser* %self) {
entry:
  %e = alloca i64
  %k = alloca i8*
  %ft = alloca i64
  %kids = alloca { i64, i64, i64* }
  %et = alloca i64
  %__agg.27 = alloca %Span
  %__agg.31 = alloca %Span
  %__agg.26 = alloca %Span
  %__agg.42 = alloca %Span
  %__agg.46 = alloca %Span
  %__agg.41 = alloca %Span
  %index = alloca i64
  %__agg.65 = alloca %Span
  %__agg.69 = alloca %Span
  %__agg.64 = alloca %Span
  %__sc.74 = alloca i1
  %name = alloca i8*
  %start = alloca %Span
  %args = alloca { i64, i64, i64* }
  %__agg.96 = alloca %Span
  %__agg.94 = alloca %Span
  %.t0 = bitcast %Parser* %self to %Parser*
  %.t1 = call i64 @Parser__parse_primary(%Parser* %.t0)
  store i64 %.t1, i64* %e
  %.r5011 = load i64, i64* %e
  %.t2 = icmp slt i64 %.r5011, 0
  br i1 %.t2, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t3 = sub i64 0, 1
  ret i64 %.t3
if_next_0_2:
  br label %if_end_0
if_end_0:
  br label %while_cond_3
while_cond_3:
  br i1 true, label %while_body_4, label %while_end_5
while_body_4:
  %.t4 = bitcast %Parser* %self to %Parser*
  %.t5 = call i8* @Parser__peek(%Parser* %.t4)
  store i8* %.t5, i8** %k
  %.r5012 = load i8*, i8** %k
  %.p5013 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.158, i64 0, i64 0
  %.r5014 = call i32 @strcmp(i8* %.r5012, i8* %.p5013)
  %.t6 = icmp eq i32 %.r5014, 0
  br i1 %.t6, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.t7 = bitcast %Parser* %self to %Parser*
  %.t8 = call i64 @Parser__advance(%Parser* %.t7)
  %.t9 = bitcast %Parser* %self to %Parser*
  %.t10 = call i64 @Parser__expect_identifier(%Parser* %.t9)
  store i64 %.t10, i64* %ft
  %.r5015 = load i64, i64* %ft
  %.t11 = icmp slt i64 %.r5015, 0
  br i1 %.t11, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.t12 = sub i64 0, 1
  ret i64 %.t12
if_next_0_11:
  br label %if_end_9
if_end_9:
  %.t13 = bitcast %Parser* %self to %Parser*
  %.p5016 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.142, i64 0, i64 0
  %.t14 = call i1 @Parser__at(%Parser* %.t13, i8* %.p5016)
  br i1 %.t14, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  %.t15 = bitcast %Parser* %self to %Parser*
  %.t16 = call i64 @Parser__advance(%Parser* %.t15)
  %.p5018 = getelementptr i64, i64* null, i32 1
  %.r5019 = ptrtoint i64* %.p5018 to i64
  %.r5020 = mul i64 %.r5019, 1
  %.p5017 = call i8* @malloc(i64 %.r5020)
  %.p5021 = bitcast i8* %.p5017 to i64*
  %.r5022 = load i64, i64* %e
  %.p5023 = getelementptr inbounds i64, i64* %.p5021, i64 0
  store i64 %.r5022, i64* %.p5023
  %.p5024 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %kids, i32 0, i32 0
  store i64 1, i64* %.p5024
  %.p5025 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %kids, i32 0, i32 1
  store i64 1, i64* %.p5025
  %.p5026 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %kids, i32 0, i32 2
  store i64* %.p5021, i64** %.p5026
  %.t17 = bitcast %Parser* %self to %Parser*
  %.t18 = bitcast { i64, i64, i64* }* %kids to { i64, i64, i64* }*
  %.t19 = call i64 @Parser__parse_call_args(%Parser* %.t17, { i64, i64, i64* }* %.t18)
  store i64 %.t19, i64* %et
  %.r5027 = load i64, i64* %et
  %.t20 = icmp slt i64 %.r5027, 0
  br i1 %.t20, label %if_then_0_16, label %if_next_0_17
if_then_0_16:
  %.t21 = sub i64 0, 1
  ret i64 %.t21
if_next_0_17:
  br label %if_end_15
if_end_15:
  %__fld.22 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t23 = bitcast %Ast* %__fld.22 to %Ast*
  %.t24 = bitcast %Parser* %self to %Parser*
  %.r5028 = load i64, i64* %ft
  %.t25 = call i8* @Parser__ttext(%Parser* %.t24, i64 %.r5028)
  %__fld.28 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t29 = bitcast %Ast* %__fld.28 to %Ast*
  %.r5029 = load i64, i64* %e
  call void @Ast__span_of(%Span* %__agg.27, %Ast* %.t29, i64 %.r5029)
  %.t30 = bitcast %Span* %__agg.27 to %Span*
  %.t32 = bitcast %Parser* %self to %Parser*
  %.r5030 = load i64, i64* %et
  call void @Parser__tspan(%Span* %__agg.31, %Parser* %.t32, i64 %.r5030)
  %.t33 = bitcast %Span* %__agg.31 to %Span*
  call void @span_to(%Span* %__agg.26, %Span* %.t30, %Span* %.t33)
  %.t34 = bitcast %Span* %__agg.26 to %Span*
  %.t35 = bitcast { i64, i64, i64* }* %kids to { i64, i64, i64* }*
  %.p5031 = getelementptr inbounds [11 x i8], [11 x i8]* @.str.337, i64 0, i64 0
  %.t36 = call i64 @Ast__addl(%Ast* %.t23, i8* %.p5031, i8* %.t25, %Span* %.t34, { i64, i64, i64* }* %.t35)
  store i64 %.t36, i64* %e
  br label %if_end_12
if_next_0_14:
  %__fld.37 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t38 = bitcast %Ast* %__fld.37 to %Ast*
  %.t39 = bitcast %Parser* %self to %Parser*
  %.r5032 = load i64, i64* %ft
  %.t40 = call i8* @Parser__ttext(%Parser* %.t39, i64 %.r5032)
  %__fld.43 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t44 = bitcast %Ast* %__fld.43 to %Ast*
  %.r5033 = load i64, i64* %e
  call void @Ast__span_of(%Span* %__agg.42, %Ast* %.t44, i64 %.r5033)
  %.t45 = bitcast %Span* %__agg.42 to %Span*
  %.t47 = bitcast %Parser* %self to %Parser*
  %.r5034 = load i64, i64* %ft
  call void @Parser__tspan(%Span* %__agg.46, %Parser* %.t47, i64 %.r5034)
  %.t48 = bitcast %Span* %__agg.46 to %Span*
  call void @span_to(%Span* %__agg.41, %Span* %.t45, %Span* %.t48)
  %.t49 = bitcast %Span* %__agg.41 to %Span*
  %.p5035 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.275, i64 0, i64 0
  %.r5036 = load i64, i64* %e
  %.t50 = call i64 @Ast__add1(%Ast* %.t38, i8* %.p5035, i8* %.t40, %Span* %.t49, i64 %.r5036)
  store i64 %.t50, i64* %e
  br label %if_end_12
if_end_12:
  br label %if_end_6
if_next_0_8:
  %.r5037 = load i8*, i8** %k
  %.p5038 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.146, i64 0, i64 0
  %.r5039 = call i32 @strcmp(i8* %.r5037, i8* %.p5038)
  %.t51 = icmp eq i32 %.r5039, 0
  br i1 %.t51, label %if_then_1_18, label %if_next_1_19
if_then_1_18:
  %.t52 = bitcast %Parser* %self to %Parser*
  %.t53 = call i64 @Parser__advance(%Parser* %.t52)
  %.t54 = bitcast %Parser* %self to %Parser*
  %.t55 = call i64 @Parser__parse_expr(%Parser* %.t54)
  store i64 %.t55, i64* %index
  %.r5040 = load i64, i64* %index
  %.t56 = icmp slt i64 %.r5040, 0
  br i1 %.t56, label %if_then_0_21, label %if_next_0_22
if_then_0_21:
  %.t57 = sub i64 0, 1
  ret i64 %.t57
if_next_0_22:
  br label %if_end_20
if_end_20:
  %.t58 = bitcast %Parser* %self to %Parser*
  %.p5041 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.148, i64 0, i64 0
  %.t59 = call i64 @Parser__expect(%Parser* %.t58, i8* %.p5041)
  store i64 %.t59, i64* %et
  %.r5042 = load i64, i64* %et
  %.t60 = icmp slt i64 %.r5042, 0
  br i1 %.t60, label %if_then_0_24, label %if_next_0_25
if_then_0_24:
  %.t61 = sub i64 0, 1
  ret i64 %.t61
if_next_0_25:
  br label %if_end_23
if_end_23:
  %__fld.62 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t63 = bitcast %Ast* %__fld.62 to %Ast*
  %__fld.66 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t67 = bitcast %Ast* %__fld.66 to %Ast*
  %.r5043 = load i64, i64* %e
  call void @Ast__span_of(%Span* %__agg.65, %Ast* %.t67, i64 %.r5043)
  %.t68 = bitcast %Span* %__agg.65 to %Span*
  %.t70 = bitcast %Parser* %self to %Parser*
  %.r5044 = load i64, i64* %et
  call void @Parser__tspan(%Span* %__agg.69, %Parser* %.t70, i64 %.r5044)
  %.t71 = bitcast %Span* %__agg.69 to %Span*
  call void @span_to(%Span* %__agg.64, %Span* %.t68, %Span* %.t71)
  %.t72 = bitcast %Span* %__agg.64 to %Span*
  %.p5045 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.299, i64 0, i64 0
  %.p5046 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.r5047 = load i64, i64* %e
  %.r5048 = load i64, i64* %index
  %.t73 = call i64 @Ast__add2(%Ast* %.t63, i8* %.p5045, i8* %.p5046, %Span* %.t72, i64 %.r5047, i64 %.r5048)
  store i64 %.t73, i64* %e
  br label %if_end_6
if_next_1_19:
  %.r5049 = load i8*, i8** %k
  %.p5050 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.142, i64 0, i64 0
  %.r5051 = call i32 @strcmp(i8* %.r5049, i8* %.p5050)
  %.t75 = icmp eq i32 %.r5051, 0
  br i1 %.t75, label %sc_rhs_28, label %sc_short_29
sc_rhs_28:
  %__fld.76 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t77 = bitcast %Ast* %__fld.76 to %Ast*
  %.r5052 = load i64, i64* %e
  %.t78 = call i8* @Ast__kind_of(%Ast* %.t77, i64 %.r5052)
  %.p5053 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.296, i64 0, i64 0
  %.r5054 = call i32 @strcmp(i8* %.t78, i8* %.p5053)
  %.t79 = icmp eq i32 %.r5054, 0
  store i1 %.t79, i1* %__sc.74
  br label %sc_end_30
sc_short_29:
  store i1 false, i1* %__sc.74
  br label %sc_end_30
sc_end_30:
  %.r5055 = load i1, i1* %__sc.74
  br i1 %.r5055, label %if_then_2_26, label %if_next_2_27
if_then_2_26:
  %__fld.80 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t81 = bitcast %Ast* %__fld.80 to %Ast*
  %.r5056 = load i64, i64* %e
  %.t82 = call i8* @Ast__text_of(%Ast* %.t81, i64 %.r5056)
  store i8* %.t82, i8** %name
  %__fld.83 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t84 = bitcast %Ast* %__fld.83 to %Ast*
  %.r5057 = load i64, i64* %e
  call void @Ast__span_of(%Span* %start, %Ast* %.t84, i64 %.r5057)
  %.t85 = bitcast %Parser* %self to %Parser*
  %.t86 = call i64 @Parser__advance(%Parser* %.t85)
  %.p5059 = getelementptr i64, i64* null, i32 1
  %.r5060 = ptrtoint i64* %.p5059 to i64
  %.r5061 = mul i64 %.r5060, 1
  %.p5058 = call i8* @malloc(i64 %.r5061)
  %.p5062 = bitcast i8* %.p5058 to i64*
  %.p5063 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %args, i32 0, i32 0
  store i64 0, i64* %.p5063
  %.p5064 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %args, i32 0, i32 1
  store i64 0, i64* %.p5064
  %.p5065 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %args, i32 0, i32 2
  store i64* %.p5062, i64** %.p5065
  %.t87 = bitcast %Parser* %self to %Parser*
  %.t88 = bitcast { i64, i64, i64* }* %args to { i64, i64, i64* }*
  %.t89 = call i64 @Parser__parse_call_args(%Parser* %.t87, { i64, i64, i64* }* %.t88)
  store i64 %.t89, i64* %et
  %.r5066 = load i64, i64* %et
  %.t90 = icmp slt i64 %.r5066, 0
  br i1 %.t90, label %if_then_0_32, label %if_next_0_33
if_then_0_32:
  %.t91 = sub i64 0, 1
  ret i64 %.t91
if_next_0_33:
  br label %if_end_31
if_end_31:
  %__fld.92 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t93 = bitcast %Ast* %__fld.92 to %Ast*
  %.t95 = bitcast %Span* %start to %Span*
  %.t97 = bitcast %Parser* %self to %Parser*
  %.r5067 = load i64, i64* %et
  call void @Parser__tspan(%Span* %__agg.96, %Parser* %.t97, i64 %.r5067)
  %.t98 = bitcast %Span* %__agg.96 to %Span*
  call void @span_to(%Span* %__agg.94, %Span* %.t95, %Span* %.t98)
  %.t99 = bitcast %Span* %__agg.94 to %Span*
  %.t100 = bitcast { i64, i64, i64* }* %args to { i64, i64, i64* }*
  %.p5068 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.329, i64 0, i64 0
  %.r5069 = load i8*, i8** %name
  %.t101 = call i64 @Ast__addl(%Ast* %.t93, i8* %.p5068, i8* %.r5069, %Span* %.t99, { i64, i64, i64* }* %.t100)
  store i64 %.t101, i64* %e
  br label %if_end_6
if_next_2_27:
  br label %while_end_5
if_end_6:
  br label %while_cond_3
while_end_5:
  %.t102 = load i64, i64* %e
  ret i64 %.t102
}

define i64 @Parser__parse_primary(%Parser* %self) {
entry:
  %span = alloca %Span
  %k = alloca i8*
  %t = alloca i64
  %name = alloca i8*
  %__sc.64 = alloca i1
  %ty = alloca i64
  %et = alloca i64
  %__agg.85 = alloca %Span
  %__agg.83 = alloca %Span
  %__sc.90 = alloca i1
  %count = alloca i64
  %__agg.119 = alloca %Span
  %__agg.117 = alloca %Span
  %inner = alloca i64
  %__agg.141 = alloca %Span
  %__agg.139 = alloca %Span
  %.t0 = bitcast %Parser* %self to %Parser*
  call void @Parser__peek_span(%Span* %span, %Parser* %.t0)
  %.t1 = bitcast %Parser* %self to %Parser*
  %.t2 = call i8* @Parser__peek(%Parser* %.t1)
  store i8* %.t2, i8** %k
  %.r5070 = load i8*, i8** %k
  %.p5071 = getelementptr inbounds [11 x i8], [11 x i8]* @.str.91, i64 0, i64 0
  %.r5072 = call i32 @strcmp(i8* %.r5070, i8* %.p5071)
  %.t3 = icmp eq i32 %.r5072, 0
  br i1 %.t3, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t4 = bitcast %Parser* %self to %Parser*
  %.t5 = call i64 @Parser__advance(%Parser* %.t4)
  store i64 %.t5, i64* %t
  %__fld.6 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t7 = bitcast %Ast* %__fld.6 to %Ast*
  %.t8 = bitcast %Parser* %self to %Parser*
  %.r5073 = load i64, i64* %t
  %.t9 = call i8* @Parser__ttext(%Parser* %.t8, i64 %.r5073)
  %.t10 = bitcast %Span* %span to %Span*
  %.p5074 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.251, i64 0, i64 0
  %.t11 = call i64 @Ast__add0(%Ast* %.t7, i8* %.p5074, i8* %.t9, %Span* %.t10)
  ret i64 %.t11
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.r5075 = load i8*, i8** %k
  %.p5076 = getelementptr inbounds [13 x i8], [13 x i8]* @.str.94, i64 0, i64 0
  %.r5077 = call i32 @strcmp(i8* %.r5075, i8* %.p5076)
  %.t12 = icmp eq i32 %.r5077, 0
  br i1 %.t12, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.t13 = bitcast %Parser* %self to %Parser*
  %.t14 = call i64 @Parser__advance(%Parser* %.t13)
  store i64 %.t14, i64* %t
  %__fld.15 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t16 = bitcast %Ast* %__fld.15 to %Ast*
  %.t17 = bitcast %Parser* %self to %Parser*
  %.r5078 = load i64, i64* %t
  %.t18 = call i8* @Parser__ttext(%Parser* %.t17, i64 %.r5078)
  %.t19 = bitcast %Span* %span to %Span*
  %.p5079 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.252, i64 0, i64 0
  %.t20 = call i64 @Ast__add0(%Ast* %.t16, i8* %.p5079, i8* %.t18, %Span* %.t19)
  ret i64 %.t20
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.r5080 = load i8*, i8** %k
  %.p5081 = getelementptr inbounds [14 x i8], [14 x i8]* @.str.96, i64 0, i64 0
  %.r5082 = call i32 @strcmp(i8* %.r5080, i8* %.p5081)
  %.t21 = icmp eq i32 %.r5082, 0
  br i1 %.t21, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.t22 = bitcast %Parser* %self to %Parser*
  %.t23 = call i64 @Parser__advance(%Parser* %.t22)
  store i64 %.t23, i64* %t
  %__fld.24 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t25 = bitcast %Ast* %__fld.24 to %Ast*
  %.t26 = bitcast %Parser* %self to %Parser*
  %.r5083 = load i64, i64* %t
  %.t27 = call i8* @Parser__ttext(%Parser* %.t26, i64 %.r5083)
  %.t28 = bitcast %Span* %span to %Span*
  %.p5084 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.325, i64 0, i64 0
  %.t29 = call i64 @Ast__add0(%Ast* %.t25, i8* %.p5084, i8* %.t27, %Span* %.t28)
  ret i64 %.t29
if_next_0_8:
  br label %if_end_6
if_end_6:
  %.r5085 = load i8*, i8** %k
  %.p5086 = getelementptr inbounds [15 x i8], [15 x i8]* @.str.99, i64 0, i64 0
  %.r5087 = call i32 @strcmp(i8* %.r5085, i8* %.p5086)
  %.t30 = icmp eq i32 %.r5087, 0
  br i1 %.t30, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.t31 = bitcast %Parser* %self to %Parser*
  %.t32 = call i64 @Parser__advance(%Parser* %.t31)
  store i64 %.t32, i64* %t
  %.t33 = bitcast %Parser* %self to %Parser*
  %.t34 = bitcast %Parser* %self to %Parser*
  %.r5088 = load i64, i64* %t
  %.t35 = call i8* @Parser__ttext(%Parser* %.t34, i64 %.r5088)
  %.t36 = bitcast %Span* %span to %Span*
  %.t37 = call i64 @Parser__desugar_fstring(%Parser* %.t33, i8* %.t35, %Span* %.t36)
  ret i64 %.t37
if_next_0_11:
  br label %if_end_9
if_end_9:
  %.r5089 = load i8*, i8** %k
  %.p5090 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.76, i64 0, i64 0
  %.r5091 = call i32 @strcmp(i8* %.r5089, i8* %.p5090)
  %.t38 = icmp eq i32 %.r5091, 0
  br i1 %.t38, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  %.t39 = bitcast %Parser* %self to %Parser*
  %.t40 = call i64 @Parser__advance(%Parser* %.t39)
  %__fld.41 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t42 = bitcast %Ast* %__fld.41 to %Ast*
  %.t43 = bitcast %Span* %span to %Span*
  %.p5092 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.338, i64 0, i64 0
  %.p5093 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.75, i64 0, i64 0
  %.t44 = call i64 @Ast__add0(%Ast* %.t42, i8* %.p5092, i8* %.p5093, %Span* %.t43)
  ret i64 %.t44
if_next_0_14:
  br label %if_end_12
if_end_12:
  %.r5094 = load i8*, i8** %k
  %.p5095 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.78, i64 0, i64 0
  %.r5096 = call i32 @strcmp(i8* %.r5094, i8* %.p5095)
  %.t45 = icmp eq i32 %.r5096, 0
  br i1 %.t45, label %if_then_0_16, label %if_next_0_17
if_then_0_16:
  %.t46 = bitcast %Parser* %self to %Parser*
  %.t47 = call i64 @Parser__advance(%Parser* %.t46)
  %__fld.48 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t49 = bitcast %Ast* %__fld.48 to %Ast*
  %.t50 = bitcast %Span* %span to %Span*
  %.p5097 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.338, i64 0, i64 0
  %.p5098 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.77, i64 0, i64 0
  %.t51 = call i64 @Ast__add0(%Ast* %.t49, i8* %.p5097, i8* %.p5098, %Span* %.t50)
  ret i64 %.t51
if_next_0_17:
  br label %if_end_15
if_end_15:
  %.r5099 = load i8*, i8** %k
  %.p5100 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.90, i64 0, i64 0
  %.r5101 = call i32 @strcmp(i8* %.r5099, i8* %.p5100)
  %.t52 = icmp eq i32 %.r5101, 0
  br i1 %.t52, label %if_then_0_19, label %if_next_0_20
if_then_0_19:
  %.t53 = bitcast %Parser* %self to %Parser*
  %.t54 = call i64 @Parser__advance(%Parser* %.t53)
  %__fld.55 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t56 = bitcast %Ast* %__fld.55 to %Ast*
  %.t57 = bitcast %Span* %span to %Span*
  %.p5102 = getelementptr inbounds [5 x i8], [5 x i8]* @.str.339, i64 0, i64 0
  %.p5103 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.t58 = call i64 @Ast__add0(%Ast* %.t56, i8* %.p5102, i8* %.p5103, %Span* %.t57)
  ret i64 %.t58
if_next_0_20:
  br label %if_end_18
if_end_18:
  %.r5104 = load i8*, i8** %k
  %.p5105 = getelementptr inbounds [11 x i8], [11 x i8]* @.str.101, i64 0, i64 0
  %.r5106 = call i32 @strcmp(i8* %.r5104, i8* %.p5105)
  %.t59 = icmp eq i32 %.r5106, 0
  br i1 %.t59, label %if_then_0_22, label %if_next_0_23
if_then_0_22:
  %.t60 = bitcast %Parser* %self to %Parser*
  %.t61 = bitcast %Parser* %self to %Parser*
  %.t62 = call i64 @Parser__cur(%Parser* %.t61)
  %.t63 = call i8* @Parser__ttext(%Parser* %.t60, i64 %.t62)
  store i8* %.t63, i8** %name
  %.r5107 = load i8*, i8** %name
  %.p5108 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.340, i64 0, i64 0
  %.r5109 = call i32 @strcmp(i8* %.r5107, i8* %.p5108)
  %.t65 = icmp eq i32 %.r5109, 0
  br i1 %.t65, label %sc_rhs_27, label %sc_short_28
sc_rhs_27:
  %.t66 = bitcast %Parser* %self to %Parser*
  %.t67 = call i8* @Parser__peek_at(%Parser* %.t66, i64 1)
  %.p5110 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.142, i64 0, i64 0
  %.r5111 = call i32 @strcmp(i8* %.t67, i8* %.p5110)
  %.t68 = icmp eq i32 %.r5111, 0
  store i1 %.t68, i1* %__sc.64
  br label %sc_end_29
sc_short_28:
  store i1 false, i1* %__sc.64
  br label %sc_end_29
sc_end_29:
  %.r5112 = load i1, i1* %__sc.64
  br i1 %.r5112, label %if_then_0_25, label %if_next_0_26
if_then_0_25:
  %.t69 = bitcast %Parser* %self to %Parser*
  %.t70 = call i64 @Parser__advance(%Parser* %.t69)
  %.t71 = bitcast %Parser* %self to %Parser*
  %.t72 = call i64 @Parser__advance(%Parser* %.t71)
  %.t73 = bitcast %Parser* %self to %Parser*
  %.t74 = call i64 @Parser__parse_type(%Parser* %.t73)
  store i64 %.t74, i64* %ty
  %.r5113 = load i64, i64* %ty
  %.t75 = icmp slt i64 %.r5113, 0
  br i1 %.t75, label %if_then_0_31, label %if_next_0_32
if_then_0_31:
  %.t76 = sub i64 0, 1
  ret i64 %.t76
if_next_0_32:
  br label %if_end_30
if_end_30:
  %.t77 = bitcast %Parser* %self to %Parser*
  %.p5114 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.144, i64 0, i64 0
  %.t78 = call i64 @Parser__expect(%Parser* %.t77, i8* %.p5114)
  store i64 %.t78, i64* %et
  %.r5115 = load i64, i64* %et
  %.t79 = icmp slt i64 %.r5115, 0
  br i1 %.t79, label %if_then_0_34, label %if_next_0_35
if_then_0_34:
  %.t80 = sub i64 0, 1
  ret i64 %.t80
if_next_0_35:
  br label %if_end_33
if_end_33:
  %__fld.81 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t82 = bitcast %Ast* %__fld.81 to %Ast*
  %.t84 = bitcast %Span* %span to %Span*
  %.t86 = bitcast %Parser* %self to %Parser*
  %.r5116 = load i64, i64* %et
  call void @Parser__tspan(%Span* %__agg.85, %Parser* %.t86, i64 %.r5116)
  %.t87 = bitcast %Span* %__agg.85 to %Span*
  call void @span_to(%Span* %__agg.83, %Span* %.t84, %Span* %.t87)
  %.t88 = bitcast %Span* %__agg.83 to %Span*
  %.p5117 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.341, i64 0, i64 0
  %.p5118 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.r5119 = load i64, i64* %ty
  %.t89 = call i64 @Ast__add1(%Ast* %.t82, i8* %.p5117, i8* %.p5118, %Span* %.t88, i64 %.r5119)
  ret i64 %.t89
if_next_0_26:
  br label %if_end_24
if_end_24:
  %.r5120 = load i8*, i8** %name
  %.p5121 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.342, i64 0, i64 0
  %.r5122 = call i32 @strcmp(i8* %.r5120, i8* %.p5121)
  %.t91 = icmp eq i32 %.r5122, 0
  br i1 %.t91, label %sc_rhs_39, label %sc_short_40
sc_rhs_39:
  %.t92 = bitcast %Parser* %self to %Parser*
  %.t93 = call i8* @Parser__peek_at(%Parser* %.t92, i64 1)
  %.p5123 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.142, i64 0, i64 0
  %.r5124 = call i32 @strcmp(i8* %.t93, i8* %.p5123)
  %.t94 = icmp eq i32 %.r5124, 0
  store i1 %.t94, i1* %__sc.90
  br label %sc_end_41
sc_short_40:
  store i1 false, i1* %__sc.90
  br label %sc_end_41
sc_end_41:
  %.r5125 = load i1, i1* %__sc.90
  br i1 %.r5125, label %if_then_0_37, label %if_next_0_38
if_then_0_37:
  %.t95 = bitcast %Parser* %self to %Parser*
  %.t96 = call i64 @Parser__advance(%Parser* %.t95)
  %.t97 = bitcast %Parser* %self to %Parser*
  %.t98 = call i64 @Parser__advance(%Parser* %.t97)
  %.t99 = bitcast %Parser* %self to %Parser*
  %.t100 = call i64 @Parser__parse_type(%Parser* %.t99)
  store i64 %.t100, i64* %ty
  %.r5126 = load i64, i64* %ty
  %.t101 = icmp slt i64 %.r5126, 0
  br i1 %.t101, label %if_then_0_43, label %if_next_0_44
if_then_0_43:
  %.t102 = sub i64 0, 1
  ret i64 %.t102
if_next_0_44:
  br label %if_end_42
if_end_42:
  %.t103 = bitcast %Parser* %self to %Parser*
  %.p5127 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.154, i64 0, i64 0
  %.t104 = call i64 @Parser__expect(%Parser* %.t103, i8* %.p5127)
  %.t105 = icmp slt i64 %.t104, 0
  br i1 %.t105, label %if_then_0_46, label %if_next_0_47
if_then_0_46:
  %.t106 = sub i64 0, 1
  ret i64 %.t106
if_next_0_47:
  br label %if_end_45
if_end_45:
  %.t107 = bitcast %Parser* %self to %Parser*
  %.t108 = call i64 @Parser__parse_expr(%Parser* %.t107)
  store i64 %.t108, i64* %count
  %.r5128 = load i64, i64* %count
  %.t109 = icmp slt i64 %.r5128, 0
  br i1 %.t109, label %if_then_0_49, label %if_next_0_50
if_then_0_49:
  %.t110 = sub i64 0, 1
  ret i64 %.t110
if_next_0_50:
  br label %if_end_48
if_end_48:
  %.t111 = bitcast %Parser* %self to %Parser*
  %.p5129 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.144, i64 0, i64 0
  %.t112 = call i64 @Parser__expect(%Parser* %.t111, i8* %.p5129)
  store i64 %.t112, i64* %et
  %.r5130 = load i64, i64* %et
  %.t113 = icmp slt i64 %.r5130, 0
  br i1 %.t113, label %if_then_0_52, label %if_next_0_53
if_then_0_52:
  %.t114 = sub i64 0, 1
  ret i64 %.t114
if_next_0_53:
  br label %if_end_51
if_end_51:
  %__fld.115 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t116 = bitcast %Ast* %__fld.115 to %Ast*
  %.t118 = bitcast %Span* %span to %Span*
  %.t120 = bitcast %Parser* %self to %Parser*
  %.r5131 = load i64, i64* %et
  call void @Parser__tspan(%Span* %__agg.119, %Parser* %.t120, i64 %.r5131)
  %.t121 = bitcast %Span* %__agg.119 to %Span*
  call void @span_to(%Span* %__agg.117, %Span* %.t118, %Span* %.t121)
  %.t122 = bitcast %Span* %__agg.117 to %Span*
  %.p5132 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.343, i64 0, i64 0
  %.p5133 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.r5134 = load i64, i64* %ty
  %.r5135 = load i64, i64* %count
  %.t123 = call i64 @Ast__add2(%Ast* %.t116, i8* %.p5132, i8* %.p5133, %Span* %.t122, i64 %.r5134, i64 %.r5135)
  ret i64 %.t123
if_next_0_38:
  br label %if_end_36
if_end_36:
  %.t124 = bitcast %Parser* %self to %Parser*
  %.t125 = call i64 @Parser__advance(%Parser* %.t124)
  %__fld.126 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t127 = bitcast %Ast* %__fld.126 to %Ast*
  %.t128 = bitcast %Span* %span to %Span*
  %.p5136 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.296, i64 0, i64 0
  %.r5137 = load i8*, i8** %name
  %.t129 = call i64 @Ast__add0(%Ast* %.t127, i8* %.p5136, i8* %.r5137, %Span* %.t128)
  ret i64 %.t129
if_next_0_23:
  br label %if_end_21
if_end_21:
  %.r5138 = load i8*, i8** %k
  %.p5139 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.68, i64 0, i64 0
  %.r5140 = call i32 @strcmp(i8* %.r5138, i8* %.p5139)
  %.t130 = icmp eq i32 %.r5140, 0
  br i1 %.t130, label %if_then_0_55, label %if_next_0_56
if_then_0_55:
  %.t131 = bitcast %Parser* %self to %Parser*
  %.t132 = call i64 @Parser__advance(%Parser* %.t131)
  %.t133 = bitcast %Parser* %self to %Parser*
  %.t134 = call i64 @Parser__parse_unary(%Parser* %.t133)
  store i64 %.t134, i64* %inner
  %.r5141 = load i64, i64* %inner
  %.t135 = icmp slt i64 %.r5141, 0
  br i1 %.t135, label %if_then_0_58, label %if_next_0_59
if_then_0_58:
  %.t136 = sub i64 0, 1
  ret i64 %.t136
if_next_0_59:
  br label %if_end_57
if_end_57:
  %__fld.137 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t138 = bitcast %Ast* %__fld.137 to %Ast*
  %.t140 = bitcast %Span* %span to %Span*
  %__fld.142 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t143 = bitcast %Ast* %__fld.142 to %Ast*
  %.r5142 = load i64, i64* %inner
  call void @Ast__span_of(%Span* %__agg.141, %Ast* %.t143, i64 %.r5142)
  %.t144 = bitcast %Span* %__agg.141 to %Span*
  call void @span_to(%Span* %__agg.139, %Span* %.t140, %Span* %.t144)
  %.t145 = bitcast %Span* %__agg.139 to %Span*
  %.p5143 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.68, i64 0, i64 0
  %.p5144 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.r5145 = load i64, i64* %inner
  %.t146 = call i64 @Ast__add1(%Ast* %.t138, i8* %.p5143, i8* %.p5144, %Span* %.t145, i64 %.r5145)
  ret i64 %.t146
if_next_0_56:
  br label %if_end_54
if_end_54:
  %.r5146 = load i8*, i8** %k
  %.p5147 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.146, i64 0, i64 0
  %.r5148 = call i32 @strcmp(i8* %.r5146, i8* %.p5147)
  %.t147 = icmp eq i32 %.r5148, 0
  br i1 %.t147, label %if_then_0_61, label %if_next_0_62
if_then_0_61:
  %.t148 = bitcast %Parser* %self to %Parser*
  %.t149 = bitcast %Span* %span to %Span*
  %.t150 = call i64 @Parser__parse_list_literal(%Parser* %.t148, %Span* %.t149)
  ret i64 %.t150
if_next_0_62:
  br label %if_end_60
if_end_60:
  %.r5149 = load i8*, i8** %k
  %.p5150 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.150, i64 0, i64 0
  %.r5151 = call i32 @strcmp(i8* %.r5149, i8* %.p5150)
  %.t151 = icmp eq i32 %.r5151, 0
  br i1 %.t151, label %if_then_0_64, label %if_next_0_65
if_then_0_64:
  %.t152 = bitcast %Parser* %self to %Parser*
  %.t153 = bitcast %Span* %span to %Span*
  %.t154 = call i64 @Parser__parse_dict_literal(%Parser* %.t152, %Span* %.t153)
  ret i64 %.t154
if_next_0_65:
  br label %if_end_63
if_end_63:
  %.r5152 = load i8*, i8** %k
  %.p5153 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.142, i64 0, i64 0
  %.r5154 = call i32 @strcmp(i8* %.r5152, i8* %.p5153)
  %.t155 = icmp eq i32 %.r5154, 0
  br i1 %.t155, label %if_then_0_67, label %if_next_0_68
if_then_0_67:
  %.t156 = bitcast %Parser* %self to %Parser*
  %.t157 = bitcast %Span* %span to %Span*
  %.t158 = call i64 @Parser__parse_paren_or_tuple(%Parser* %.t156, %Span* %.t157)
  ret i64 %.t158
if_next_0_68:
  br label %if_end_66
if_end_66:
  %__fld.159 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 3
  %.t160 = bitcast %Diags* %__fld.159 to %Diags*
  %.t161 = bitcast %Parser* %self to %Parser*
  %.t162 = call i8* @Parser__found(%Parser* %.t161)
  %.p5155 = getelementptr inbounds [31 x i8], [31 x i8]* @.str.344, i64 0, i64 0
  %.r5156 = call i64 @strlen(i8* %.p5155)
  %.r5157 = call i64 @strlen(i8* %.t162)
  %.r5158 = add i64 %.r5156, %.r5157
  %.r5159 = add i64 %.r5158, 1
  %.t163 = call i8* @malloc(i64 %.r5159)
  call i8* @memcpy(i8* %.t163, i8* %.p5155, i64 %.r5156)
  %.p5160 = getelementptr inbounds i8, i8* %.t163, i64 %.r5156
  call i8* @memcpy(i8* %.p5160, i8* %.t162, i64 %.r5157)
  %.p5161 = getelementptr inbounds i8, i8* %.t163, i64 %.r5158
  store i8 0, i8* %.p5161
  %.t164 = bitcast %Span* %span to %Span*
  %.p5162 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.345, i64 0, i64 0
  %.p5163 = getelementptr inbounds [28 x i8], [28 x i8]* @.str.346, i64 0, i64 0
  %.p5164 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  call void @Diags__add(%Diags* %.t160, i8* %.p5162, i8* %.t163, %Span* %.t164, i8* %.p5163, i8* %.p5164)
  %.t165 = sub i64 0, 1
  ret i64 %.t165
}

define i64 @Parser__parse_list_literal(%Parser* %self, %Span* %start) {
entry:
  %items = alloca { i64, i64, i64* }
  %it = alloca i64
  %et = alloca i64
  %__agg.21 = alloca %Span
  %__agg.19 = alloca %Span
  %.t0 = bitcast %Parser* %self to %Parser*
  %.t1 = call i64 @Parser__advance(%Parser* %.t0)
  %.p5166 = getelementptr i64, i64* null, i32 1
  %.r5167 = ptrtoint i64* %.p5166 to i64
  %.r5168 = mul i64 %.r5167, 1
  %.p5165 = call i8* @malloc(i64 %.r5168)
  %.p5169 = bitcast i8* %.p5165 to i64*
  %.p5170 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %items, i32 0, i32 0
  store i64 0, i64* %.p5170
  %.p5171 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %items, i32 0, i32 1
  store i64 0, i64* %.p5171
  %.p5172 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %items, i32 0, i32 2
  store i64* %.p5169, i64** %.p5172
  %.t2 = bitcast %Parser* %self to %Parser*
  %.p5173 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.148, i64 0, i64 0
  %.t3 = call i1 @Parser__at(%Parser* %.t2, i8* %.p5173)
  %.t4 = xor i1 %.t3, true
  br i1 %.t4, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  br label %while_cond_3
while_cond_3:
  br i1 true, label %while_body_4, label %while_end_5
while_body_4:
  %.t5 = bitcast %Parser* %self to %Parser*
  %.t6 = call i64 @Parser__parse_expr(%Parser* %.t5)
  store i64 %.t6, i64* %it
  %.r5174 = load i64, i64* %it
  %.t7 = icmp slt i64 %.r5174, 0
  br i1 %.t7, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.t8 = sub i64 0, 1
  ret i64 %.t8
if_next_0_8:
  br label %if_end_6
if_end_6:
  %.p5175 = getelementptr i64, i64* null, i32 1
  %.r5176 = ptrtoint i64* %.p5175 to i64
  %.p5177 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %items, i32 0, i32 0
  %.p5178 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %items, i32 0, i32 1
  %.p5179 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %items, i32 0, i32 2
  %.r5180 = load i64, i64* %.p5177
  %.r5181 = load i64, i64* %.p5178
  %.r5182 = icmp sge i64 %.r5180, %.r5181
  br i1 %.r5182, label %append.grow.5183, label %append.after.5184
append.grow.5183:
  %.r5185 = load i64*, i64** %.p5179
  %.r5186 = icmp eq i64 %.r5181, 0
  %.r5187 = mul i64 %.r5181, 2
  %.r5188 = select i1 %.r5186, i64 1, i64 %.r5187
  %.r5189 = mul i64 %.r5188, %.r5176
  %.p5190 = call i8* @malloc(i64 %.r5189)
  %.p5191 = bitcast i8* %.p5190 to i64*
  %.r5192 = mul i64 %.r5180, %.r5176
  %.p5193 = bitcast i64* %.r5185 to i8*
  call i8* @memcpy(i8* %.p5190, i8* %.p5193, i64 %.r5192)
  call void @free(i8* %.p5193)
  store i64* %.p5191, i64** %.p5179
  store i64 %.r5188, i64* %.p5178
  br label %append.after.5184
append.after.5184:
  %.r5194 = load i64*, i64** %.p5179
  %.r5195 = load i64, i64* %it
  %.p5196 = getelementptr inbounds i64, i64* %.r5194, i64 %.r5180
  store i64 %.r5195, i64* %.p5196
  %.r5197 = add i64 %.r5180, 1
  store i64 %.r5197, i64* %.p5177
  %.t9 = bitcast %Parser* %self to %Parser*
  %.p5198 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.154, i64 0, i64 0
  %.t10 = call i1 @Parser__at(%Parser* %.t9, i8* %.p5198)
  br i1 %.t10, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.t11 = bitcast %Parser* %self to %Parser*
  %.t12 = call i64 @Parser__advance(%Parser* %.t11)
  br label %if_end_9
if_next_0_11:
  br label %while_end_5
if_end_9:
  br label %while_cond_3
while_end_5:
  br label %if_end_0
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.t13 = bitcast %Parser* %self to %Parser*
  %.p5199 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.148, i64 0, i64 0
  %.t14 = call i64 @Parser__expect(%Parser* %.t13, i8* %.p5199)
  store i64 %.t14, i64* %et
  %.r5200 = load i64, i64* %et
  %.t15 = icmp slt i64 %.r5200, 0
  br i1 %.t15, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  %.t16 = sub i64 0, 1
  ret i64 %.t16
if_next_0_14:
  br label %if_end_12
if_end_12:
  %__fld.17 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t18 = bitcast %Ast* %__fld.17 to %Ast*
  %.t20 = bitcast %Span* %start to %Span*
  %.t22 = bitcast %Parser* %self to %Parser*
  %.r5201 = load i64, i64* %et
  call void @Parser__tspan(%Span* %__agg.21, %Parser* %.t22, i64 %.r5201)
  %.t23 = bitcast %Span* %__agg.21 to %Span*
  call void @span_to(%Span* %__agg.19, %Span* %.t20, %Span* %.t23)
  %.t24 = bitcast %Span* %__agg.19 to %Span*
  %.t25 = bitcast { i64, i64, i64* }* %items to { i64, i64, i64* }*
  %.p5202 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.347, i64 0, i64 0
  %.p5203 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.t26 = call i64 @Ast__addl(%Ast* %.t18, i8* %.p5202, i8* %.p5203, %Span* %.t24, { i64, i64, i64* }* %.t25)
  ret i64 %.t26
}

define i64 @Parser__parse_dict_literal(%Parser* %self, %Span* %start) {
entry:
  %entries = alloca { i64, i64, i64* }
  %kt = alloca i64
  %value = alloca i64
  %__agg.23 = alloca %Span
  %et = alloca i64
  %__agg.44 = alloca %Span
  %__agg.42 = alloca %Span
  %.t0 = bitcast %Parser* %self to %Parser*
  %.t1 = call i64 @Parser__advance(%Parser* %.t0)
  %.t2 = bitcast %Parser* %self to %Parser*
  call void @Parser__skip_blank_newlines(%Parser* %.t2)
  %.p5205 = getelementptr i64, i64* null, i32 1
  %.r5206 = ptrtoint i64* %.p5205 to i64
  %.r5207 = mul i64 %.r5206, 1
  %.p5204 = call i8* @malloc(i64 %.r5207)
  %.p5208 = bitcast i8* %.p5204 to i64*
  %.p5209 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %entries, i32 0, i32 0
  store i64 0, i64* %.p5209
  %.p5210 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %entries, i32 0, i32 1
  store i64 0, i64* %.p5210
  %.p5211 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %entries, i32 0, i32 2
  store i64* %.p5208, i64** %.p5211
  %.t3 = bitcast %Parser* %self to %Parser*
  %.p5212 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.152, i64 0, i64 0
  %.t4 = call i1 @Parser__at(%Parser* %.t3, i8* %.p5212)
  %.t5 = xor i1 %.t4, true
  br i1 %.t5, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  br label %while_cond_3
while_cond_3:
  br i1 true, label %while_body_4, label %while_end_5
while_body_4:
  %.t6 = bitcast %Parser* %self to %Parser*
  call void @Parser__skip_blank_newlines(%Parser* %.t6)
  %.t7 = bitcast %Parser* %self to %Parser*
  %.p5213 = getelementptr inbounds [14 x i8], [14 x i8]* @.str.96, i64 0, i64 0
  %.t8 = call i64 @Parser__expect(%Parser* %.t7, i8* %.p5213)
  store i64 %.t8, i64* %kt
  %.r5214 = load i64, i64* %kt
  %.t9 = icmp slt i64 %.r5214, 0
  br i1 %.t9, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.t10 = sub i64 0, 1
  ret i64 %.t10
if_next_0_8:
  br label %if_end_6
if_end_6:
  %.t11 = bitcast %Parser* %self to %Parser*
  %.p5215 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.156, i64 0, i64 0
  %.t12 = call i64 @Parser__expect(%Parser* %.t11, i8* %.p5215)
  %.t13 = icmp slt i64 %.t12, 0
  br i1 %.t13, label %if_then_0_10, label %if_next_0_11
if_then_0_10:
  %.t14 = sub i64 0, 1
  ret i64 %.t14
if_next_0_11:
  br label %if_end_9
if_end_9:
  %.t15 = bitcast %Parser* %self to %Parser*
  %.t16 = call i64 @Parser__parse_expr(%Parser* %.t15)
  store i64 %.t16, i64* %value
  %.r5216 = load i64, i64* %value
  %.t17 = icmp slt i64 %.r5216, 0
  br i1 %.t17, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  %.t18 = sub i64 0, 1
  ret i64 %.t18
if_next_0_14:
  br label %if_end_12
if_end_12:
  %__fld.19 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t20 = bitcast %Ast* %__fld.19 to %Ast*
  %.t21 = bitcast %Parser* %self to %Parser*
  %.r5217 = load i64, i64* %kt
  %.t22 = call i8* @Parser__ttext(%Parser* %.t21, i64 %.r5217)
  %.t24 = bitcast %Parser* %self to %Parser*
  %.r5218 = load i64, i64* %kt
  call void @Parser__tspan(%Span* %__agg.23, %Parser* %.t24, i64 %.r5218)
  %.t25 = bitcast %Span* %__agg.23 to %Span*
  %.p5219 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.259, i64 0, i64 0
  %.r5220 = load i64, i64* %value
  %.t26 = call i64 @Ast__add1(%Ast* %.t20, i8* %.p5219, i8* %.t22, %Span* %.t25, i64 %.r5220)
  %.p5221 = getelementptr i64, i64* null, i32 1
  %.r5222 = ptrtoint i64* %.p5221 to i64
  %.p5223 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %entries, i32 0, i32 0
  %.p5224 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %entries, i32 0, i32 1
  %.p5225 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %entries, i32 0, i32 2
  %.r5226 = load i64, i64* %.p5223
  %.r5227 = load i64, i64* %.p5224
  %.r5228 = icmp sge i64 %.r5226, %.r5227
  br i1 %.r5228, label %append.grow.5229, label %append.after.5230
append.grow.5229:
  %.r5231 = load i64*, i64** %.p5225
  %.r5232 = icmp eq i64 %.r5227, 0
  %.r5233 = mul i64 %.r5227, 2
  %.r5234 = select i1 %.r5232, i64 1, i64 %.r5233
  %.r5235 = mul i64 %.r5234, %.r5222
  %.p5236 = call i8* @malloc(i64 %.r5235)
  %.p5237 = bitcast i8* %.p5236 to i64*
  %.r5238 = mul i64 %.r5226, %.r5222
  %.p5239 = bitcast i64* %.r5231 to i8*
  call i8* @memcpy(i8* %.p5236, i8* %.p5239, i64 %.r5238)
  call void @free(i8* %.p5239)
  store i64* %.p5237, i64** %.p5225
  store i64 %.r5234, i64* %.p5224
  br label %append.after.5230
append.after.5230:
  %.r5240 = load i64*, i64** %.p5225
  %.p5241 = getelementptr inbounds i64, i64* %.r5240, i64 %.r5226
  store i64 %.t26, i64* %.p5241
  %.r5242 = add i64 %.r5226, 1
  store i64 %.r5242, i64* %.p5223
  %.t27 = bitcast %Parser* %self to %Parser*
  call void @Parser__skip_blank_newlines(%Parser* %.t27)
  %.t28 = bitcast %Parser* %self to %Parser*
  %.p5243 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.154, i64 0, i64 0
  %.t29 = call i1 @Parser__at(%Parser* %.t28, i8* %.p5243)
  br i1 %.t29, label %if_then_0_16, label %if_next_0_17
if_then_0_16:
  %.t30 = bitcast %Parser* %self to %Parser*
  %.t31 = call i64 @Parser__advance(%Parser* %.t30)
  %.t32 = bitcast %Parser* %self to %Parser*
  call void @Parser__skip_blank_newlines(%Parser* %.t32)
  %.t33 = bitcast %Parser* %self to %Parser*
  %.p5244 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.152, i64 0, i64 0
  %.t34 = call i1 @Parser__at(%Parser* %.t33, i8* %.p5244)
  br i1 %.t34, label %if_then_0_19, label %if_next_0_20
if_then_0_19:
  br label %while_end_5
if_next_0_20:
  br label %if_end_18
if_end_18:
  br label %if_end_15
if_next_0_17:
  br label %while_end_5
if_end_15:
  br label %while_cond_3
while_end_5:
  br label %if_end_0
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.t35 = bitcast %Parser* %self to %Parser*
  call void @Parser__skip_blank_newlines(%Parser* %.t35)
  %.t36 = bitcast %Parser* %self to %Parser*
  %.p5245 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.152, i64 0, i64 0
  %.t37 = call i64 @Parser__expect(%Parser* %.t36, i8* %.p5245)
  store i64 %.t37, i64* %et
  %.r5246 = load i64, i64* %et
  %.t38 = icmp slt i64 %.r5246, 0
  br i1 %.t38, label %if_then_0_22, label %if_next_0_23
if_then_0_22:
  %.t39 = sub i64 0, 1
  ret i64 %.t39
if_next_0_23:
  br label %if_end_21
if_end_21:
  %__fld.40 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t41 = bitcast %Ast* %__fld.40 to %Ast*
  %.t43 = bitcast %Span* %start to %Span*
  %.t45 = bitcast %Parser* %self to %Parser*
  %.r5247 = load i64, i64* %et
  call void @Parser__tspan(%Span* %__agg.44, %Parser* %.t45, i64 %.r5247)
  %.t46 = bitcast %Span* %__agg.44 to %Span*
  call void @span_to(%Span* %__agg.42, %Span* %.t43, %Span* %.t46)
  %.t47 = bitcast %Span* %__agg.42 to %Span*
  %.t48 = bitcast { i64, i64, i64* }* %entries to { i64, i64, i64* }*
  %.p5248 = getelementptr inbounds [8 x i8], [8 x i8]* @.str.348, i64 0, i64 0
  %.p5249 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.t49 = call i64 @Ast__addl(%Ast* %.t41, i8* %.p5248, i8* %.p5249, %Span* %.t47, { i64, i64, i64* }* %.t48)
  ret i64 %.t49
}

define i64 @Parser__parse_paren_or_tuple(%Parser* %self, %Span* %start) {
entry:
  %et = alloca i64
  %__agg.10 = alloca %Span
  %__agg.8 = alloca %Span
  %first = alloca i64
  %items = alloca { i64, i64, i64* }
  %it = alloca i64
  %__agg.39 = alloca %Span
  %__agg.37 = alloca %Span
  %.t0 = bitcast %Parser* %self to %Parser*
  %.t1 = call i64 @Parser__advance(%Parser* %.t0)
  %.t2 = bitcast %Parser* %self to %Parser*
  %.p5250 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.144, i64 0, i64 0
  %.t3 = call i1 @Parser__at(%Parser* %.t2, i8* %.p5250)
  br i1 %.t3, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t4 = bitcast %Parser* %self to %Parser*
  %.t5 = call i64 @Parser__advance(%Parser* %.t4)
  store i64 %.t5, i64* %et
  %__fld.6 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t7 = bitcast %Ast* %__fld.6 to %Ast*
  %.t9 = bitcast %Span* %start to %Span*
  %.t11 = bitcast %Parser* %self to %Parser*
  %.r5251 = load i64, i64* %et
  call void @Parser__tspan(%Span* %__agg.10, %Parser* %.t11, i64 %.r5251)
  %.t12 = bitcast %Span* %__agg.10 to %Span*
  call void @span_to(%Span* %__agg.8, %Span* %.t9, %Span* %.t12)
  %.t13 = bitcast %Span* %__agg.8 to %Span*
  %.p5252 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.349, i64 0, i64 0
  %.p5253 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.t14 = call i64 @Ast__add0(%Ast* %.t7, i8* %.p5252, i8* %.p5253, %Span* %.t13)
  ret i64 %.t14
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.t15 = bitcast %Parser* %self to %Parser*
  %.t16 = call i64 @Parser__parse_expr(%Parser* %.t15)
  store i64 %.t16, i64* %first
  %.r5254 = load i64, i64* %first
  %.t17 = icmp slt i64 %.r5254, 0
  br i1 %.t17, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.t18 = sub i64 0, 1
  ret i64 %.t18
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.t19 = bitcast %Parser* %self to %Parser*
  %.p5255 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.154, i64 0, i64 0
  %.t20 = call i1 @Parser__at(%Parser* %.t19, i8* %.p5255)
  br i1 %.t20, label %if_then_0_7, label %if_next_0_8
if_then_0_7:
  %.p5257 = getelementptr i64, i64* null, i32 1
  %.r5258 = ptrtoint i64* %.p5257 to i64
  %.r5259 = mul i64 %.r5258, 1
  %.p5256 = call i8* @malloc(i64 %.r5259)
  %.p5260 = bitcast i8* %.p5256 to i64*
  %.r5261 = load i64, i64* %first
  %.p5262 = getelementptr inbounds i64, i64* %.p5260, i64 0
  store i64 %.r5261, i64* %.p5262
  %.p5263 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %items, i32 0, i32 0
  store i64 1, i64* %.p5263
  %.p5264 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %items, i32 0, i32 1
  store i64 1, i64* %.p5264
  %.p5265 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %items, i32 0, i32 2
  store i64* %.p5260, i64** %.p5265
  br label %while_cond_9
while_cond_9:
  %.t21 = bitcast %Parser* %self to %Parser*
  %.p5266 = getelementptr inbounds [6 x i8], [6 x i8]* @.str.154, i64 0, i64 0
  %.t22 = call i1 @Parser__at(%Parser* %.t21, i8* %.p5266)
  br i1 %.t22, label %while_body_10, label %while_end_11
while_body_10:
  %.t23 = bitcast %Parser* %self to %Parser*
  %.t24 = call i64 @Parser__advance(%Parser* %.t23)
  %.t25 = bitcast %Parser* %self to %Parser*
  %.p5267 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.144, i64 0, i64 0
  %.t26 = call i1 @Parser__at(%Parser* %.t25, i8* %.p5267)
  br i1 %.t26, label %if_then_0_13, label %if_next_0_14
if_then_0_13:
  br label %while_end_11
if_next_0_14:
  br label %if_end_12
if_end_12:
  %.t27 = bitcast %Parser* %self to %Parser*
  %.t28 = call i64 @Parser__parse_expr(%Parser* %.t27)
  store i64 %.t28, i64* %it
  %.r5268 = load i64, i64* %it
  %.t29 = icmp slt i64 %.r5268, 0
  br i1 %.t29, label %if_then_0_16, label %if_next_0_17
if_then_0_16:
  %.t30 = sub i64 0, 1
  ret i64 %.t30
if_next_0_17:
  br label %if_end_15
if_end_15:
  %.p5269 = getelementptr i64, i64* null, i32 1
  %.r5270 = ptrtoint i64* %.p5269 to i64
  %.p5271 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %items, i32 0, i32 0
  %.p5272 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %items, i32 0, i32 1
  %.p5273 = getelementptr inbounds { i64, i64, i64* }, { i64, i64, i64* }* %items, i32 0, i32 2
  %.r5274 = load i64, i64* %.p5271
  %.r5275 = load i64, i64* %.p5272
  %.r5276 = icmp sge i64 %.r5274, %.r5275
  br i1 %.r5276, label %append.grow.5277, label %append.after.5278
append.grow.5277:
  %.r5279 = load i64*, i64** %.p5273
  %.r5280 = icmp eq i64 %.r5275, 0
  %.r5281 = mul i64 %.r5275, 2
  %.r5282 = select i1 %.r5280, i64 1, i64 %.r5281
  %.r5283 = mul i64 %.r5282, %.r5270
  %.p5284 = call i8* @malloc(i64 %.r5283)
  %.p5285 = bitcast i8* %.p5284 to i64*
  %.r5286 = mul i64 %.r5274, %.r5270
  %.p5287 = bitcast i64* %.r5279 to i8*
  call i8* @memcpy(i8* %.p5284, i8* %.p5287, i64 %.r5286)
  call void @free(i8* %.p5287)
  store i64* %.p5285, i64** %.p5273
  store i64 %.r5282, i64* %.p5272
  br label %append.after.5278
append.after.5278:
  %.r5288 = load i64*, i64** %.p5273
  %.r5289 = load i64, i64* %it
  %.p5290 = getelementptr inbounds i64, i64* %.r5288, i64 %.r5274
  store i64 %.r5289, i64* %.p5290
  %.r5291 = add i64 %.r5274, 1
  store i64 %.r5291, i64* %.p5271
  br label %while_cond_9
while_end_11:
  %.t31 = bitcast %Parser* %self to %Parser*
  %.p5292 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.144, i64 0, i64 0
  %.t32 = call i64 @Parser__expect(%Parser* %.t31, i8* %.p5292)
  store i64 %.t32, i64* %et
  %.r5293 = load i64, i64* %et
  %.t33 = icmp slt i64 %.r5293, 0
  br i1 %.t33, label %if_then_0_19, label %if_next_0_20
if_then_0_19:
  %.t34 = sub i64 0, 1
  ret i64 %.t34
if_next_0_20:
  br label %if_end_18
if_end_18:
  %__fld.35 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  %.t36 = bitcast %Ast* %__fld.35 to %Ast*
  %.t38 = bitcast %Span* %start to %Span*
  %.t40 = bitcast %Parser* %self to %Parser*
  %.r5294 = load i64, i64* %et
  call void @Parser__tspan(%Span* %__agg.39, %Parser* %.t40, i64 %.r5294)
  %.t41 = bitcast %Span* %__agg.39 to %Span*
  call void @span_to(%Span* %__agg.37, %Span* %.t38, %Span* %.t41)
  %.t42 = bitcast %Span* %__agg.37 to %Span*
  %.t43 = bitcast { i64, i64, i64* }* %items to { i64, i64, i64* }*
  %.p5295 = getelementptr inbounds [9 x i8], [9 x i8]* @.str.349, i64 0, i64 0
  %.p5296 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.t44 = call i64 @Ast__addl(%Ast* %.t36, i8* %.p5295, i8* %.p5296, %Span* %.t42, { i64, i64, i64* }* %.t43)
  ret i64 %.t44
if_next_0_8:
  br label %if_end_6
if_end_6:
  %.t45 = bitcast %Parser* %self to %Parser*
  %.p5297 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.144, i64 0, i64 0
  %.t46 = call i64 @Parser__expect(%Parser* %.t45, i8* %.p5297)
  %.t47 = icmp slt i64 %.t46, 0
  br i1 %.t47, label %if_then_0_22, label %if_next_0_23
if_then_0_22:
  %.t48 = sub i64 0, 1
  ret i64 %.t48
if_next_0_23:
  br label %if_end_21
if_end_21:
  %.t49 = load i64, i64* %first
  ret i64 %.t49
}

define i64 @parse_tokens({ i64, i64, %Token* }* %toks, %Ast* %ast, %Diags* %diags) {
entry:
  %p = alloca %Parser
  %root = alloca i64
  %.t0 = bitcast { i64, i64, %Token* }* %toks to { i64, i64, %Token* }*
  call void @Parser__new(%Parser* %p, { i64, i64, %Token* }* %.t0)
  %.t1 = bitcast %Parser* %p to %Parser*
  %.t2 = call i64 @Parser__parse_program(%Parser* %.t1)
  store i64 %.t2, i64* %root
  %.t3 = bitcast %Diags* %diags to %Diags*
  %__fld.4 = getelementptr inbounds %Parser, %Parser* %p, i32 0, i32 3
  %.t5 = bitcast %Diags* %__fld.4 to %Diags*
  call void @Diags__extend(%Diags* %.t3, %Diags* %.t5)
  %__fld.6 = getelementptr inbounds %Parser, %Parser* %p, i32 0, i32 4
  %.p5298 = getelementptr inbounds %Ast, %Ast* %__fld.6, i32 0, i32 0
  %.t7 = load { i64, i64, %Node* }, { i64, i64, %Node* }* %.p5298
  %.p5299 = getelementptr inbounds %Ast, %Ast* %ast, i32 0, i32 0
  store { i64, i64, %Node* } %.t7, { i64, i64, %Node* }* %.p5299
  %.t8 = load i64, i64* %root
  ret i64 %.t8
}

define i8* @read_source(i8* %path.arg) {
entry:
  %path = alloca i8*
  store i8* %path.arg, i8** %path
  %.r5300 = load i8*, i8** %path
  %.p5301 = alloca i8*
  %.p5302 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.mode.rb, i64 0, i64 0
  %.p5303 = call i8* @fopen(i8* %.r5300, i8* %.p5302)
  %.r5304 = icmp eq i8* %.p5303, null
  br i1 %.r5304, label %readfile.fail.5305, label %readfile.ok.5306
readfile.fail.5305:
  %.p5308 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.empty, i64 0, i64 0
  store i8* %.p5308, i8** %.p5301
  br label %readfile.after.5307
readfile.ok.5306:
  call i32 @fseek(i8* %.p5303, i64 0, i32 2)
  %.r5309 = call i64 @ftell(i8* %.p5303)
  call i32 @fseek(i8* %.p5303, i64 0, i32 0)
  %.r5310 = add i64 %.r5309, 1
  %.p5311 = call i8* @malloc(i64 %.r5310)
  call i64 @fread(i8* %.p5311, i64 1, i64 %.r5309, i8* %.p5303)
  %.p5312 = getelementptr inbounds i8, i8* %.p5311, i64 %.r5309
  store i8 0, i8* %.p5312
  call i32 @fclose(i8* %.p5303)
  store i8* %.p5311, i8** %.p5301
  br label %readfile.after.5307
readfile.after.5307:
  %.t0 = load i8*, i8** %.p5301
  ret i8* %.t0
}

define void @cmd_tokens(i8* %path.arg) {
entry:
  %path = alloca i8*
  %src = alloca i8*
  %diags = alloca %Diags
  %toks = alloca { i64, i64, %Token* }
  %__for.idx.3 = alloca i64
  %__for.len.4 = alloca i64
  %t = alloca %Token
  %text = alloca i8*
  store i8* %path.arg, i8** %path
  %.r5313 = load i8*, i8** %path
  %.t0 = call i8* @read_source(i8* %.r5313)
  store i8* %.t0, i8** %src
  %.p5314 = getelementptr inbounds %Diags, %Diags* %diags, i32 0, i32 0
  store { i64, i64, %Diag* } zeroinitializer, { i64, i64, %Diag* }* %.p5314
  %.t1 = bitcast %Diags* %diags to %Diags*
  %.r5315 = load i8*, i8** %src
  call void @lex({ i64, i64, %Token* }* %toks, i8* %.r5315, %Diags* %.t1)
  %.t2 = bitcast %Diags* %diags to %Diags*
  %.r5316 = load i8*, i8** %path
  %.r5317 = load i8*, i8** %src
  call void @emit_diags(%Diags* %.t2, i8* %.r5316, i8* %.r5317)
  store i64 0, i64* %__for.idx.3
  %.p5318 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %toks, i32 0, i32 0
  %.t5 = load i64, i64* %.p5318
  store i64 %.t5, i64* %__for.len.4
  br label %foreach_cond_0
foreach_cond_0:
  %.r5319 = load i64, i64* %__for.idx.3
  %.r5320 = load i64, i64* %__for.len.4
  %.t6 = icmp slt i64 %.r5319, %.r5320
  br i1 %.t6, label %foreach_body_1, label %foreach_end_3
foreach_body_1:
  %.r5321 = load i64, i64* %__for.idx.3
  %.p5322 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %toks, i32 0, i32 0
  %.r5323 = load i64, i64* %.p5322
  %.r5324 = icmp slt i64 %.r5321, 0
  %.r5325 = icmp sge i64 %.r5321, %.r5323
  %.r5326 = or i1 %.r5324, %.r5325
  br i1 %.r5326, label %idx.fail.5328, label %idx.ok.5327
idx.fail.5328:
  %.p5329 = getelementptr inbounds [79 x i8], [79 x i8]* @.err.bounds, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p5329, i64 %.r5321, i64 %.r5323)
  call void @exit(i32 1)
  unreachable
idx.ok.5327:
  %.p5331 = getelementptr inbounds { i64, i64, %Token* }, { i64, i64, %Token* }* %toks, i32 0, i32 2
  %.p5330 = load %Token*, %Token** %.p5331
  %.p5332 = getelementptr inbounds %Token, %Token* %.p5330, i64 %.r5321
  %.t7 = load %Token, %Token* %.p5332
  store %Token %.t7, %Token* %t
  %.p5333 = getelementptr inbounds %Token, %Token* %t, i32 0, i32 1
  %.t8 = load i8*, i8** %.p5333
  store i8* %.t8, i8** %text
  %.p5334 = getelementptr inbounds %Token, %Token* %t, i32 0, i32 0
  %.t9 = load i8*, i8** %.p5334
  %.p5335 = getelementptr inbounds [11 x i8], [11 x i8]* @.str.91, i64 0, i64 0
  %.r5336 = call i32 @strcmp(i8* %.t9, i8* %.p5335)
  %.t10 = icmp eq i32 %.r5336, 0
  br i1 %.t10, label %if_then_0_5, label %if_next_0_6
if_then_0_5:
  %.r5337 = load i8*, i8** %text
  %.t11 = call i8* @norm_int(i8* %.r5337)
  store i8* %.t11, i8** %text
  br label %if_end_4
if_next_0_6:
  %.p5338 = getelementptr inbounds %Token, %Token* %t, i32 0, i32 0
  %.t12 = load i8*, i8** %.p5338
  %.p5339 = getelementptr inbounds [13 x i8], [13 x i8]* @.str.94, i64 0, i64 0
  %.r5340 = call i32 @strcmp(i8* %.t12, i8* %.p5339)
  %.t13 = icmp eq i32 %.r5340, 0
  br i1 %.t13, label %if_then_1_7, label %if_next_1_8
if_then_1_7:
  %.r5341 = load i8*, i8** %text
  %.t14 = call i8* @norm_float(i8* %.r5341)
  store i8* %.t14, i8** %text
  br label %if_end_4
if_next_1_8:
  br label %if_end_4
if_end_4:
  %.p5342 = getelementptr inbounds %Token, %Token* %t, i32 0, i32 0
  %.t15 = load i8*, i8** %.p5342
  %.p5343 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.6, i64 0, i64 0
  %.r5344 = call i64 @strlen(i8* %.t15)
  %.r5345 = call i64 @strlen(i8* %.p5343)
  %.r5346 = add i64 %.r5344, %.r5345
  %.r5347 = add i64 %.r5346, 1
  %.t16 = call i8* @malloc(i64 %.r5347)
  call i8* @memcpy(i8* %.t16, i8* %.t15, i64 %.r5344)
  %.p5348 = getelementptr inbounds i8, i8* %.t16, i64 %.r5344
  call i8* @memcpy(i8* %.p5348, i8* %.p5343, i64 %.r5345)
  %.p5349 = getelementptr inbounds i8, i8* %.t16, i64 %.r5346
  store i8 0, i8* %.p5349
  %.r5350 = load i8*, i8** %text
  %.t17 = call i8* @dump_quote(i8* %.r5350)
  %.r5351 = call i64 @strlen(i8* %.t16)
  %.r5352 = call i64 @strlen(i8* %.t17)
  %.r5353 = add i64 %.r5351, %.r5352
  %.r5354 = add i64 %.r5353, 1
  %.t18 = call i8* @malloc(i64 %.r5354)
  call i8* @memcpy(i8* %.t18, i8* %.t16, i64 %.r5351)
  %.p5355 = getelementptr inbounds i8, i8* %.t18, i64 %.r5351
  call i8* @memcpy(i8* %.p5355, i8* %.t17, i64 %.r5352)
  %.p5356 = getelementptr inbounds i8, i8* %.t18, i64 %.r5353
  store i8 0, i8* %.p5356
  %.p5357 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.6, i64 0, i64 0
  %.r5358 = call i64 @strlen(i8* %.t18)
  %.r5359 = call i64 @strlen(i8* %.p5357)
  %.r5360 = add i64 %.r5358, %.r5359
  %.r5361 = add i64 %.r5360, 1
  %.t19 = call i8* @malloc(i64 %.r5361)
  call i8* @memcpy(i8* %.t19, i8* %.t18, i64 %.r5358)
  %.p5362 = getelementptr inbounds i8, i8* %.t19, i64 %.r5358
  call i8* @memcpy(i8* %.p5362, i8* %.p5357, i64 %.r5359)
  %.p5363 = getelementptr inbounds i8, i8* %.t19, i64 %.r5360
  store i8 0, i8* %.p5363
  %.p5364 = getelementptr inbounds %Token, %Token* %t, i32 0, i32 2
  %.t20 = load i64, i64* %.p5364
  %.p5365 = call i8* @malloc(i64 32)
  %.p5366 = getelementptr inbounds [5 x i8], [5 x i8]* @.fmt.int.raw, i64 0, i64 0
  call i32 (i8*, i64, i8*, ...) @snprintf(i8* %.p5365, i64 32, i8* %.p5366, i64 %.t20)
  %.t21 = bitcast i8* %.p5365 to i8*
  %.r5367 = call i64 @strlen(i8* %.t19)
  %.r5368 = call i64 @strlen(i8* %.t21)
  %.r5369 = add i64 %.r5367, %.r5368
  %.r5370 = add i64 %.r5369, 1
  %.t22 = call i8* @malloc(i64 %.r5370)
  call i8* @memcpy(i8* %.t22, i8* %.t19, i64 %.r5367)
  %.p5371 = getelementptr inbounds i8, i8* %.t22, i64 %.r5367
  call i8* @memcpy(i8* %.p5371, i8* %.t21, i64 %.r5368)
  %.p5372 = getelementptr inbounds i8, i8* %.t22, i64 %.r5369
  store i8 0, i8* %.p5372
  %.p5373 = getelementptr inbounds [3 x i8], [3 x i8]* @.str.350, i64 0, i64 0
  %.r5374 = call i64 @strlen(i8* %.t22)
  %.r5375 = call i64 @strlen(i8* %.p5373)
  %.r5376 = add i64 %.r5374, %.r5375
  %.r5377 = add i64 %.r5376, 1
  %.t23 = call i8* @malloc(i64 %.r5377)
  call i8* @memcpy(i8* %.t23, i8* %.t22, i64 %.r5374)
  %.p5378 = getelementptr inbounds i8, i8* %.t23, i64 %.r5374
  call i8* @memcpy(i8* %.p5378, i8* %.p5373, i64 %.r5375)
  %.p5379 = getelementptr inbounds i8, i8* %.t23, i64 %.r5376
  store i8 0, i8* %.p5379
  %__fld.24 = getelementptr inbounds %Token, %Token* %t, i32 0, i32 3
  %.p5380 = getelementptr inbounds %Span, %Span* %__fld.24, i32 0, i32 2
  %.t25 = load i64, i64* %.p5380
  %.p5381 = call i8* @malloc(i64 32)
  %.p5382 = getelementptr inbounds [5 x i8], [5 x i8]* @.fmt.int.raw, i64 0, i64 0
  call i32 (i8*, i64, i8*, ...) @snprintf(i8* %.p5381, i64 32, i8* %.p5382, i64 %.t25)
  %.t26 = bitcast i8* %.p5381 to i8*
  %.r5383 = call i64 @strlen(i8* %.t23)
  %.r5384 = call i64 @strlen(i8* %.t26)
  %.r5385 = add i64 %.r5383, %.r5384
  %.r5386 = add i64 %.r5385, 1
  %.t27 = call i8* @malloc(i64 %.r5386)
  call i8* @memcpy(i8* %.t27, i8* %.t23, i64 %.r5383)
  %.p5387 = getelementptr inbounds i8, i8* %.t27, i64 %.r5383
  call i8* @memcpy(i8* %.p5387, i8* %.t26, i64 %.r5384)
  %.p5388 = getelementptr inbounds i8, i8* %.t27, i64 %.r5385
  store i8 0, i8* %.p5388
  %.p5389 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.8, i64 0, i64 0
  %.r5390 = call i64 @strlen(i8* %.t27)
  %.r5391 = call i64 @strlen(i8* %.p5389)
  %.r5392 = add i64 %.r5390, %.r5391
  %.r5393 = add i64 %.r5392, 1
  %.t28 = call i8* @malloc(i64 %.r5393)
  call i8* @memcpy(i8* %.t28, i8* %.t27, i64 %.r5390)
  %.p5394 = getelementptr inbounds i8, i8* %.t28, i64 %.r5390
  call i8* @memcpy(i8* %.p5394, i8* %.p5389, i64 %.r5391)
  %.p5395 = getelementptr inbounds i8, i8* %.t28, i64 %.r5392
  store i8 0, i8* %.p5395
  %__fld.29 = getelementptr inbounds %Token, %Token* %t, i32 0, i32 3
  %.p5396 = getelementptr inbounds %Span, %Span* %__fld.29, i32 0, i32 3
  %.t30 = load i64, i64* %.p5396
  %.p5397 = call i8* @malloc(i64 32)
  %.p5398 = getelementptr inbounds [5 x i8], [5 x i8]* @.fmt.int.raw, i64 0, i64 0
  call i32 (i8*, i64, i8*, ...) @snprintf(i8* %.p5397, i64 32, i8* %.p5398, i64 %.t30)
  %.t31 = bitcast i8* %.p5397 to i8*
  %.r5399 = call i64 @strlen(i8* %.t28)
  %.r5400 = call i64 @strlen(i8* %.t31)
  %.r5401 = add i64 %.r5399, %.r5400
  %.r5402 = add i64 %.r5401, 1
  %.t32 = call i8* @malloc(i64 %.r5402)
  call i8* @memcpy(i8* %.t32, i8* %.t28, i64 %.r5399)
  %.p5403 = getelementptr inbounds i8, i8* %.t32, i64 %.r5399
  call i8* @memcpy(i8* %.p5403, i8* %.t31, i64 %.r5400)
  %.p5404 = getelementptr inbounds i8, i8* %.t32, i64 %.r5401
  store i8 0, i8* %.p5404
  %.p5405 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.8, i64 0, i64 0
  %.r5406 = call i64 @strlen(i8* %.t32)
  %.r5407 = call i64 @strlen(i8* %.p5405)
  %.r5408 = add i64 %.r5406, %.r5407
  %.r5409 = add i64 %.r5408, 1
  %.t33 = call i8* @malloc(i64 %.r5409)
  call i8* @memcpy(i8* %.t33, i8* %.t32, i64 %.r5406)
  %.p5410 = getelementptr inbounds i8, i8* %.t33, i64 %.r5406
  call i8* @memcpy(i8* %.p5410, i8* %.p5405, i64 %.r5407)
  %.p5411 = getelementptr inbounds i8, i8* %.t33, i64 %.r5408
  store i8 0, i8* %.p5411
  %__fld.34 = getelementptr inbounds %Token, %Token* %t, i32 0, i32 3
  %.p5412 = getelementptr inbounds %Span, %Span* %__fld.34, i32 0, i32 0
  %.t35 = load i64, i64* %.p5412
  %.p5413 = call i8* @malloc(i64 32)
  %.p5414 = getelementptr inbounds [5 x i8], [5 x i8]* @.fmt.int.raw, i64 0, i64 0
  call i32 (i8*, i64, i8*, ...) @snprintf(i8* %.p5413, i64 32, i8* %.p5414, i64 %.t35)
  %.t36 = bitcast i8* %.p5413 to i8*
  %.r5415 = call i64 @strlen(i8* %.t33)
  %.r5416 = call i64 @strlen(i8* %.t36)
  %.r5417 = add i64 %.r5415, %.r5416
  %.r5418 = add i64 %.r5417, 1
  %.t37 = call i8* @malloc(i64 %.r5418)
  call i8* @memcpy(i8* %.t37, i8* %.t33, i64 %.r5415)
  %.p5419 = getelementptr inbounds i8, i8* %.t37, i64 %.r5415
  call i8* @memcpy(i8* %.p5419, i8* %.t36, i64 %.r5416)
  %.p5420 = getelementptr inbounds i8, i8* %.t37, i64 %.r5417
  store i8 0, i8* %.p5420
  %.p5421 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.254, i64 0, i64 0
  %.r5422 = call i64 @strlen(i8* %.t37)
  %.r5423 = call i64 @strlen(i8* %.p5421)
  %.r5424 = add i64 %.r5422, %.r5423
  %.r5425 = add i64 %.r5424, 1
  %.t38 = call i8* @malloc(i64 %.r5425)
  call i8* @memcpy(i8* %.t38, i8* %.t37, i64 %.r5422)
  %.p5426 = getelementptr inbounds i8, i8* %.t38, i64 %.r5422
  call i8* @memcpy(i8* %.p5426, i8* %.p5421, i64 %.r5423)
  %.p5427 = getelementptr inbounds i8, i8* %.t38, i64 %.r5424
  store i8 0, i8* %.p5427
  %__fld.39 = getelementptr inbounds %Token, %Token* %t, i32 0, i32 3
  %.p5428 = getelementptr inbounds %Span, %Span* %__fld.39, i32 0, i32 1
  %.t40 = load i64, i64* %.p5428
  %.p5429 = call i8* @malloc(i64 32)
  %.p5430 = getelementptr inbounds [5 x i8], [5 x i8]* @.fmt.int.raw, i64 0, i64 0
  call i32 (i8*, i64, i8*, ...) @snprintf(i8* %.p5429, i64 32, i8* %.p5430, i64 %.t40)
  %.t41 = bitcast i8* %.p5429 to i8*
  %.r5431 = call i64 @strlen(i8* %.t38)
  %.r5432 = call i64 @strlen(i8* %.t41)
  %.r5433 = add i64 %.r5431, %.r5432
  %.r5434 = add i64 %.r5433, 1
  %.t42 = call i8* @malloc(i64 %.r5434)
  call i8* @memcpy(i8* %.t42, i8* %.t38, i64 %.r5431)
  %.p5435 = getelementptr inbounds i8, i8* %.t42, i64 %.r5431
  call i8* @memcpy(i8* %.p5435, i8* %.t41, i64 %.r5432)
  %.p5436 = getelementptr inbounds i8, i8* %.t42, i64 %.r5433
  store i8 0, i8* %.p5436
  %.p5437 = getelementptr inbounds [4 x i8], [4 x i8]* @.fmt.str, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p5437, i8* %.t42)
  br label %foreach_step_2
foreach_step_2:
  %.r5438 = load i64, i64* %__for.idx.3
  %.t43 = add i64 %.r5438, 1
  store i64 %.t43, i64* %__for.idx.3
  br label %foreach_cond_0
foreach_end_3:
  ret void
}

define void @cmd_ast(i8* %path.arg) {
entry:
  %path = alloca i8*
  %src = alloca i8*
  %diags = alloca %Diags
  %toks = alloca { i64, i64, %Token* }
  %ast = alloca %Ast
  %root = alloca i64
  store i8* %path.arg, i8** %path
  %.r5439 = load i8*, i8** %path
  %.t0 = call i8* @read_source(i8* %.r5439)
  store i8* %.t0, i8** %src
  %.p5440 = getelementptr inbounds %Diags, %Diags* %diags, i32 0, i32 0
  store { i64, i64, %Diag* } zeroinitializer, { i64, i64, %Diag* }* %.p5440
  %.t1 = bitcast %Diags* %diags to %Diags*
  %.r5441 = load i8*, i8** %src
  call void @lex({ i64, i64, %Token* }* %toks, i8* %.r5441, %Diags* %.t1)
  %.p5442 = getelementptr inbounds %Ast, %Ast* %ast, i32 0, i32 0
  store { i64, i64, %Node* } zeroinitializer, { i64, i64, %Node* }* %.p5442
  %.t2 = sub i64 0, 1
  store i64 %.t2, i64* %root
  %.t3 = bitcast %Diags* %diags to %Diags*
  %.t4 = call i1 @Diags__had_errors(%Diags* %.t3)
  %.t5 = xor i1 %.t4, true
  br i1 %.t5, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t6 = bitcast { i64, i64, %Token* }* %toks to { i64, i64, %Token* }*
  %.t7 = bitcast %Ast* %ast to %Ast*
  %.t8 = bitcast %Diags* %diags to %Diags*
  %.t9 = call i64 @parse_tokens({ i64, i64, %Token* }* %.t6, %Ast* %.t7, %Diags* %.t8)
  store i64 %.t9, i64* %root
  br label %if_end_0
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.t10 = bitcast %Diags* %diags to %Diags*
  %.t11 = call i1 @Diags__had_errors(%Diags* %.t10)
  br i1 %.t11, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.t12 = bitcast %Diags* %diags to %Diags*
  %.r5443 = load i8*, i8** %path
  %.r5444 = load i8*, i8** %src
  call void @emit_diags(%Diags* %.t12, i8* %.r5443, i8* %.r5444)
  %.r5445 = trunc i64 1 to i32
  call void @exit(i32 %.r5445)
  br label %if_end_3
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.t13 = bitcast %Ast* %ast to %Ast*
  %.r5446 = load i64, i64* %root
  %.t14 = call i8* @dump_node(%Ast* %.t13, i64 %.r5446, i64 0)
  %.p5447 = getelementptr inbounds [4 x i8], [4 x i8]* @.fmt.str, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p5447, i8* %.t14)
  ret void
}

define i32 @main(i32 %argc, i8** %argv) {
entry:
  %cmd = alloca i8*
  %path = alloca i8*
  store i32 %argc, i32* @.kite.argc
  store i8** %argv, i8*** @.kite.argv
  %.r5448 = load i32, i32* @.kite.argc
  %.r5449 = sext i32 %.r5448 to i64
  %.t0 = sub i64 %.r5449, 1
  %.t1 = icmp slt i64 %.t0, 2
  br i1 %.t1, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.p5450 = getelementptr inbounds [29 x i8], [29 x i8]* @.str.351, i64 0, i64 0
  call void @eprint_line(i8* %.p5450)
  %.r5451 = trunc i64 2 to i32
  call void @exit(i32 %.r5451)
  br label %if_end_0
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.r5452 = load i32, i32* @.kite.argc
  %.r5453 = sext i32 %.r5452 to i64
  %.r5454 = sub i64 %.r5453, 1
  %.r5455 = icmp slt i64 0, 0
  %.r5456 = icmp sge i64 0, %.r5454
  %.r5457 = or i1 %.r5455, %.r5456
  br i1 %.r5457, label %arg.fail.5459, label %arg.ok.5458
arg.fail.5459:
  %.p5460 = getelementptr inbounds [86 x i8], [86 x i8]* @.err.arg, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p5460, i64 0, i64 %.r5454)
  call void @exit(i32 1)
  unreachable
arg.ok.5458:
  %.p5461 = load i8**, i8*** @.kite.argv
  %.r5462 = add i64 0, 1
  %.p5463 = getelementptr inbounds i8*, i8** %.p5461, i64 %.r5462
  %.t2 = load i8*, i8** %.p5463
  store i8* %.t2, i8** %cmd
  %.r5464 = load i32, i32* @.kite.argc
  %.r5465 = sext i32 %.r5464 to i64
  %.r5466 = sub i64 %.r5465, 1
  %.r5467 = icmp slt i64 1, 0
  %.r5468 = icmp sge i64 1, %.r5466
  %.r5469 = or i1 %.r5467, %.r5468
  br i1 %.r5469, label %arg.fail.5471, label %arg.ok.5470
arg.fail.5471:
  %.p5472 = getelementptr inbounds [86 x i8], [86 x i8]* @.err.arg, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %.p5472, i64 1, i64 %.r5466)
  call void @exit(i32 1)
  unreachable
arg.ok.5470:
  %.p5473 = load i8**, i8*** @.kite.argv
  %.r5474 = add i64 1, 1
  %.p5475 = getelementptr inbounds i8*, i8** %.p5473, i64 %.r5474
  %.t3 = load i8*, i8** %.p5475
  store i8* %.t3, i8** %path
  %.r5476 = load i8*, i8** %cmd
  %.p5477 = getelementptr inbounds [7 x i8], [7 x i8]* @.str.352, i64 0, i64 0
  %.r5478 = call i32 @strcmp(i8* %.r5476, i8* %.p5477)
  %.t4 = icmp eq i32 %.r5478, 0
  br i1 %.t4, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.r5479 = load i8*, i8** %path
  call void @cmd_tokens(i8* %.r5479)
  br label %if_end_3
if_next_0_5:
  %.r5480 = load i8*, i8** %cmd
  %.p5481 = getelementptr inbounds [4 x i8], [4 x i8]* @.str.353, i64 0, i64 0
  %.r5482 = call i32 @strcmp(i8* %.r5480, i8* %.p5481)
  %.t5 = icmp eq i32 %.r5482, 0
  br i1 %.t5, label %if_then_1_6, label %if_next_1_7
if_then_1_6:
  %.r5483 = load i8*, i8** %path
  call void @cmd_ast(i8* %.r5483)
  br label %if_end_3
if_next_1_7:
  %.p5484 = getelementptr inbounds [25 x i8], [25 x i8]* @.str.354, i64 0, i64 0
  %.r5485 = load i8*, i8** %cmd
  %.r5486 = call i64 @strlen(i8* %.p5484)
  %.r5487 = call i64 @strlen(i8* %.r5485)
  %.r5488 = add i64 %.r5486, %.r5487
  %.r5489 = add i64 %.r5488, 1
  %.t6 = call i8* @malloc(i64 %.r5489)
  call i8* @memcpy(i8* %.t6, i8* %.p5484, i64 %.r5486)
  %.p5490 = getelementptr inbounds i8, i8* %.t6, i64 %.r5486
  call i8* @memcpy(i8* %.p5490, i8* %.r5485, i64 %.r5487)
  %.p5491 = getelementptr inbounds i8, i8* %.t6, i64 %.r5488
  store i8 0, i8* %.p5491
  %.p5492 = getelementptr inbounds [2 x i8], [2 x i8]* @.str.93, i64 0, i64 0
  %.r5493 = call i64 @strlen(i8* %.t6)
  %.r5494 = call i64 @strlen(i8* %.p5492)
  %.r5495 = add i64 %.r5493, %.r5494
  %.r5496 = add i64 %.r5495, 1
  %.t7 = call i8* @malloc(i64 %.r5496)
  call i8* @memcpy(i8* %.t7, i8* %.t6, i64 %.r5493)
  %.p5497 = getelementptr inbounds i8, i8* %.t7, i64 %.r5493
  call i8* @memcpy(i8* %.p5497, i8* %.p5492, i64 %.r5494)
  %.p5498 = getelementptr inbounds i8, i8* %.t7, i64 %.r5495
  store i8 0, i8* %.p5498
  call void @eprint_line(i8* %.t7)
  %.r5499 = trunc i64 2 to i32
  call void @exit(i32 %.r5499)
  br label %if_end_3
if_end_3:
  ret i32 0
}

define i64 @find(i8* %s.arg, i8* %sub.arg) {
entry:
  %s = alloca i8*
  %sub = alloca i8*
  store i8* %s.arg, i8** %s
  store i8* %sub.arg, i8** %sub
  %.r5500 = load i8*, i8** %s
  %.r5501 = load i8*, i8** %sub
  %.t0 = call i64 @find_from(i8* %.r5500, i8* %.r5501, i64 0)
  ret i64 %.t0
}

define i8* @repeat(i8* %s.arg, i64 %n.arg) {
entry:
  %s = alloca i8*
  %n = alloca i64
  %r = alloca i8*
  %i = alloca i64
  store i8* %s.arg, i8** %s
  store i64 %n.arg, i64* %n
  %.p5502 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  store i8* %.p5502, i8** %r
  store i64 0, i64* %i
  br label %while_cond_0
while_cond_0:
  %.r5503 = load i64, i64* %i
  %.r5504 = load i64, i64* %n
  %.t0 = icmp slt i64 %.r5503, %.r5504
  br i1 %.t0, label %while_body_1, label %while_end_2
while_body_1:
  %.r5505 = load i8*, i8** %r
  %.r5506 = load i8*, i8** %s
  %.r5507 = call i64 @strlen(i8* %.r5505)
  %.r5508 = call i64 @strlen(i8* %.r5506)
  %.r5509 = add i64 %.r5507, %.r5508
  %.r5510 = add i64 %.r5509, 1
  %.t1 = call i8* @malloc(i64 %.r5510)
  call i8* @memcpy(i8* %.t1, i8* %.r5505, i64 %.r5507)
  %.p5511 = getelementptr inbounds i8, i8* %.t1, i64 %.r5507
  call i8* @memcpy(i8* %.p5511, i8* %.r5506, i64 %.r5508)
  %.p5512 = getelementptr inbounds i8, i8* %.t1, i64 %.r5509
  store i8 0, i8* %.p5512
  store i8* %.t1, i8** %r
  %.r5513 = load i64, i64* %i
  %.t2 = add i64 %.r5513, 1
  store i64 %.t2, i64* %i
  br label %while_cond_0
while_end_2:
  %.t3 = load i8*, i8** %r
  ret i8* %.t3
}

define i64 @min(i64 %a.arg, i64 %b.arg) {
entry:
  %a = alloca i64
  %b = alloca i64
  store i64 %a.arg, i64* %a
  store i64 %b.arg, i64* %b
  %.r5514 = load i64, i64* %a
  %.r5515 = load i64, i64* %b
  %.t0 = icmp slt i64 %.r5514, %.r5515
  br i1 %.t0, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t1 = load i64, i64* %a
  ret i64 %.t1
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.t2 = load i64, i64* %b
  ret i64 %.t2
}

define i64 @max(i64 %a.arg, i64 %b.arg) {
entry:
  %a = alloca i64
  %b = alloca i64
  store i64 %a.arg, i64* %a
  store i64 %b.arg, i64* %b
  %.r5516 = load i64, i64* %a
  %.r5517 = load i64, i64* %b
  %.t0 = icmp sgt i64 %.r5516, %.r5517
  br i1 %.t0, label %if_then_0_1, label %if_next_0_2
if_then_0_1:
  %.t1 = load i64, i64* %a
  ret i64 %.t1
if_next_0_2:
  br label %if_end_0
if_end_0:
  %.t2 = load i64, i64* %b
  ret i64 %.t2
}

define i64 @find_from(i8* %s.arg, i8* %sub.arg, i64 %start.arg) {
entry:
  %s = alloca i8*
  %sub = alloca i8*
  %start = alloca i64
  %n = alloca i64
  %m = alloca i64
  %i = alloca i64
  store i8* %s.arg, i8** %s
  store i8* %sub.arg, i8** %sub
  store i64 %start.arg, i64* %start
  %.r5518 = load i8*, i8** %s
  %.t0 = call i64 @strlen(i8* %.r5518)
  store i64 %.t0, i64* %n
  %.r5519 = load i8*, i8** %sub
  %.t1 = call i64 @strlen(i8* %.r5519)
  store i64 %.t1, i64* %m
  %.r5520 = load i64, i64* %start
  store i64 %.r5520, i64* %i
  br label %while_cond_0
while_cond_0:
  %.r5521 = load i64, i64* %i
  %.r5522 = load i64, i64* %m
  %.t2 = add i64 %.r5521, %.r5522
  %.r5523 = load i64, i64* %n
  %.t3 = icmp sle i64 %.t2, %.r5523
  br i1 %.t3, label %while_body_1, label %while_end_2
while_body_1:
  %.r5524 = load i64, i64* %i
  %.r5525 = load i64, i64* %m
  %.t4 = add i64 %.r5524, %.r5525
  %.r5526 = load i8*, i8** %s
  %.r5527 = load i64, i64* %i
  %.r5528 = sub i64 %.t4, %.r5527
  %.r5529 = add i64 %.r5528, 1
  %.p5530 = call i8* @malloc(i64 %.r5529)
  %.p5531 = getelementptr inbounds i8, i8* %.r5526, i64 %.r5527
  call i8* @memcpy(i8* %.p5530, i8* %.p5531, i64 %.r5528)
  %.p5532 = getelementptr inbounds i8, i8* %.p5530, i64 %.r5528
  store i8 0, i8* %.p5532
  %.t5 = bitcast i8* %.p5530 to i8*
  %.r5533 = load i8*, i8** %sub
  %.r5534 = call i32 @strcmp(i8* %.t5, i8* %.r5533)
  %.t6 = icmp eq i32 %.r5534, 0
  br i1 %.t6, label %if_then_0_4, label %if_next_0_5
if_then_0_4:
  %.t7 = load i64, i64* %i
  ret i64 %.t7
if_next_0_5:
  br label %if_end_3
if_end_3:
  %.r5535 = load i64, i64* %i
  %.t8 = add i64 %.r5535, 1
  store i64 %.t8, i64* %i
  br label %while_cond_0
while_end_2:
  %.t9 = sub i64 0, 1
  ret i64 %.t9
}

define void @Lexer__new(%Lexer* %__ret, i8* %source.arg) {
entry:
  %source = alloca i8*
  %self = alloca %Lexer
  store i8* %source.arg, i8** %source
  %.p5536 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p5537 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 0
  store i8* %.p5536, i8** %.p5537
  %.p5538 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 1
  store { i64, i64, i64* } zeroinitializer, { i64, i64, i64* }* %.p5538
  %.p5539 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 2
  store { i64, i64, i64* } zeroinitializer, { i64, i64, i64* }* %.p5539
  %.p5540 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 3
  store i64 0, i64* %.p5540
  %.p5541 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 4
  store i64 0, i64* %.p5541
  %.p5542 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 5
  store i64 0, i64* %.p5542
  %.p5543 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 6
  store %Diags zeroinitializer, %Diags* %.p5543
  %.p5544 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 7
  store { i64, i64, %RawLine* } zeroinitializer, { i64, i64, %RawLine* }* %.p5544
  %.p5545 = getelementptr inbounds %Lexer, %Lexer* %self, i32 0, i32 8
  store i64 0, i64* %.p5545
  %.t0 = bitcast %Lexer* %self to %Lexer*
  %.r5546 = load i8*, i8** %source
  call void @Lexer__init(%Lexer* %.t0, i8* %.r5546)
  %.r5547 = load %Lexer, %Lexer* %self
  store %Lexer %.r5547, %Lexer* %__ret
  ret void
}

define void @Parser__new(%Parser* %__ret, { i64, i64, %Token* }* %toks) {
entry:
  %self = alloca %Parser
  %.p5548 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 0
  store { i64, i64, %Token* } zeroinitializer, { i64, i64, %Token* }* %.p5548
  %.p5549 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 1
  store i64 0, i64* %.p5549
  %.p5550 = getelementptr inbounds [1 x i8], [1 x i8]* @.str.1, i64 0, i64 0
  %.p5551 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 2
  store i8* %.p5550, i8** %.p5551
  %.p5552 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 3
  store %Diags zeroinitializer, %Diags* %.p5552
  %.p5553 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 4
  store %Ast zeroinitializer, %Ast* %.p5553
  %.p5554 = getelementptr inbounds %Parser, %Parser* %self, i32 0, i32 5
  store { i64, i64, i64* } zeroinitializer, { i64, i64, i64* }* %.p5554
  %.t0 = bitcast %Parser* %self to %Parser*
  %.t1 = bitcast { i64, i64, %Token* }* %toks to { i64, i64, %Token* }*
  call void @Parser__init(%Parser* %.t0, { i64, i64, %Token* }* %.t1)
  %.r5555 = load %Parser, %Parser* %self
  store %Parser %.r5555, %Parser* %__ret
  ret void
}


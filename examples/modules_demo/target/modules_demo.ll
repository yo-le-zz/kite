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

define double @circle_area(double %radius.arg) {
entry:
  %radius = alloca double
  store double %radius.arg, double* %radius
  %r0 = load double, double* %radius
  %t0 = fmul double 3.14159, %r0
  %r1 = load double, double* %radius
  %t1 = fmul double %t0, %r1
  ret double %t1
}

define double @rectangle_area(double %width.arg, double %height.arg) {
entry:
  %width = alloca double
  %height = alloca double
  store double %width.arg, double* %width
  store double %height.arg, double* %height
  %r2 = load double, double* %width
  %r3 = load double, double* %height
  %t0 = fmul double %r2, %r3
  ret double %t0
}

define i32 @main(i32 %argc, i8** %argv) {
entry:
  store i32 %argc, i32* @.kite.argc
  store i8** %argv, i8*** @.kite.argv
  %t0 = call double @circle_area(double 2.0)
  %p4 = getelementptr inbounds [4 x i8], [4 x i8]* @.fmt.float, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %p4, double %t0)
  %t1 = call double @rectangle_area(double 3.0, double 4.0)
  %p5 = getelementptr inbounds [4 x i8], [4 x i8]* @.fmt.float, i64 0, i64 0
  call i32 (i8*, ...) @printf(i8* %p5, double %t1)
  ret i32 0
}


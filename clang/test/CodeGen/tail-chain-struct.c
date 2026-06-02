// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -emit-llvm -o - %s | FileCheck %s

struct MyStruct {
  long a;
  long b;
  long c;
  long d;
};

// CHECK: define dso_local tail_chaincc { i64, i64, i64, i64 } @test_struct(i64 %s.coerce0, i64 %s.coerce1, i64 %s.coerce2, i64 %s.coerce3)
__attribute__((tail_chain)) struct MyStruct test_struct(struct MyStruct s) {
  return s;
}
union LargeUnion {
  char arr[32];
  long l;
};

struct StructWithUnion {
  int a;
  union LargeUnion u;
};

// We expect StructWithUnion to be flattened to { i32, [4 x i64] } (or similar, depending on alignment/padding, but definitely in registers, no sret/byval)
// CHECK: define dso_local tail_chaincc { i32, [4 x i64] } @test_union(i32 %s.coerce0, [4 x i64] %s.coerce1)
__attribute__((tail_chain)) struct StructWithUnion test_union(struct StructWithUnion s) {
  return s;
}

struct Nested {
  long x;
  long y;
};

struct ComplexStruct {
  struct Nested n;
  union {
    long u1[4];
    double u2[4];
  } u;
  long z;
};

// We expect ComplexStruct to be flattened. We will verify the exact signature.
// CHECK: define dso_local tail_chaincc { i64, i64, [4 x i64], i64 } @test_complex(i64 %s.coerce0, i64 %s.coerce1, [4 x i64] %s.coerce2, i64 %s.coerce3)
__attribute__((tail_chain)) struct ComplexStruct test_complex(struct ComplexStruct s) {
  return s;
}

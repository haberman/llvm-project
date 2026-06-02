// RUN: %clang_cc1 -triple x86_64-unknown-linux-gnu -fsyntax-only -verify %s
// expected-no-diagnostics

__attribute__((tail_chain)) void callee_6args(int, int, int, int, int, int);

__attribute__((tail_chain)) void caller_2args(int a, int b) {
  [[clang::musttail]] return callee_6args(a, b, 3, 4, 5, 6);
}

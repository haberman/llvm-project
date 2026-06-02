; RUN: llc -mtriple=x86_64-unknown-linux-gnu -mattr=+avx512f < %s | FileCheck %s

declare tail_chaincc void @callee_6args(i64, i64, i64, i64, i64, i64)

define tail_chaincc void @test_args(i64 %a, i64 %b, i64 %c, i64 %d, i64 %e, i64 %f) {
; CHECK-LABEL: test_args:
; CHECK: # %bb.0:
; CHECK-NOT: movq
; CHECK: jmp callee_6args{{(@PLT)?}} # TAILCALL
  tail call tail_chaincc void @callee_6args(i64 %a, i64 %b, i64 %c, i64 %d, i64 %e, i64 %f)
  ret void
}

declare void @standard_call(i64, i64)
declare tail_chaincc void @callee_tail()

define tail_chaincc void @test_intermediate(i64 %a, i64 %b, i64 %c, i64 %d) {
; CHECK-LABEL: test_intermediate:
; CHECK: # %bb.0:
; CHECK-NOT: pushq %r14
; CHECK-NOT: pushq %r15
; CHECK-DAG: movq %r12, %rdi
; CHECK-DAG: movq %r13, %rsi
; CHECK: callq standard_call{{(@PLT)?}}
; CHECK-NOT: popq %r15
; CHECK-NOT: popq %r14
; CHECK: jmp callee_tail{{(@PLT)?}} # TAILCALL
  call void @standard_call(i64 %a, i64 %b)
  tail call tail_chaincc void @callee_tail()
  ret void
}

declare tail_chaincc void @callee_0stack()

define tail_chaincc void @test_mismatch(
    i64 %a, i64 %b, i64 %c, i64 %d, i64 %e, i64 %f, i64 %g, i64 %h,
    i64 %i, i64 %j, i64 %k, i64 %l, i64 %m, i64 %n) {
; CHECK-LABEL: test_mismatch:
; CHECK: # %bb.0:
; CHECK:      movq 8(%rsp), %rax
; CHECK-NEXT: movq %rax, 24(%rsp)
; CHECK-NEXT: popq %rax
; CHECK:      addq $16, %rsp
; CHECK-NEXT: jmp callee_0stack{{(@PLT)?}} # TAILCALL
  tail call tail_chaincc void @callee_0stack()
  ret void
}

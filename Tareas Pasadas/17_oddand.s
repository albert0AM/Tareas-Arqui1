.global _start

_start:

mov x1, #33
and x0, x1, #1

mov x8, #93
svc #0

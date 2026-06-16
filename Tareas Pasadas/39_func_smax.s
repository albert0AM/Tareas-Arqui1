.global _start

_start:
       mov x0, #10
       mov x1, #15
       bl smax

       mov x8, #93           
        svc #0               
smax:
        cmp x0, x1
        csel x0, x0, x1, gt  // if x0 > x1, x0 = x0; else x0 = x1
        ret
        
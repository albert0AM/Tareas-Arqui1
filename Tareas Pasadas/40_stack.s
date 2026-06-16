.global _start
 
.text
_start:
     bl func               // func call

     mov x8, #93           // exit
     svc #0               
 
func:
     stp lr, fp, [sp, #-16]! // push lr and fp to stack (16B aligned), pre-index
     mov x0, #10            // load return value into x0
     ldp lr, fp, [sp], #16  // pop lr and fp from stack
     ret
                         
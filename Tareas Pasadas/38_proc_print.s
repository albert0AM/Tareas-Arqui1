.global _start
 
.data
 msg1: .asciz "First message! \n"  // 17 bytes: 16 chars + null terminator
 msg2: .asciz "Second message!\n"
 msg3: .asciz "Third message! \n"
 
.text
_start:
     ldr x1, =msg1         // x1 = &msg1
     bl print              // procedure call (Branch and Link)
 
     ldr x1, =msg2         // x1 = &msg2
     bl print              // procedure call
 
     ldr x1, =msg3         // x1 = &msg3
     bl print              // procedure call
 
     // Salir del programa (Exit syscall)
     mov x8, #93           // system call number for 'exit' on ARM
     svc #0                // execute system call (exit)
 
  print:
     // El registro x1 ya contiene la dirección del mensaje
     mov x0, #1            // file descriptor 1 (stdout)
     mov x2, #17           // length of message to write
     mov x8, #64           // system call number for 'write' on ARM
     svc #0
        ret                   // return from procedure



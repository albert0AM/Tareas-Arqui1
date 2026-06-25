.global _start

.bss
arg1: .space 32                     

.text
_start:
    //Validacion de argumentos
    ldr x0, [sp]                    // Cargar argc (número de argumentos)
    cmp x0, #2                      // ¿Hay al menos 2 argumentos? (programa + 1er param)
    blt exit_error                  // Si hay menos de 2, salir para evitar el segfault

    //Obteniendo el argumento
    ldr x0, [sp, #16]               // x0 = dirección de argv[1]
    ldr x1, =arg1                   
    mov x2, #0                      

loop:
    ldrb w3, [x0, x2]               
    cmp w3, #0                      
    beq end                         
    strb w3, [x1, x2]               
    add x2, x2, #1                  
    b loop                          

end:
    mov w0, #10                     
    strb w0, [x1, x2]               
    add x2, x2, #1                  
    mov w0, #0                      
    strb w0, [x1, x2]               

    //Imprimir el argumento en la consola
    mov x0, #1                      
    mov x2, #32                     
    mov x8, #64                     
    svc #0                          

exit_error:
    //Salir del Programa
    mov x8, #93                     
    svc #0
    
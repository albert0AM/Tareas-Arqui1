// --- Sección de Datos y Configuración ---
.global _start
.extern itoa

.data
head:   .dword 0                // Puntero inicial a la lista (NULL)

.bss
buffer: .space 11               // Buffer para conversión de números a texto

.text
_start:
    // Insertar valor 30
    mov x0, #30                 // val
    ldr x1, =head               // cargar dirección de head
    ldr x1, [x1]                // cargar valor de head (puntero actual)
    bl push                     // push(30, head)

    // Insertar valor 20
    mov x0, #20                 // val
    ldr x1, =head
    ldr x1, [x1]
    bl push                     // push(20, head)

    // Insertar valor 10
    mov x0, #10                 // val
    ldr x1, =head
    ldr x1, [x1]
    bl push                     // push(10, head)

    // Imprimir la lista
    ldr x0, =head               // cargar dirección de head
    ldr x0, [x0]                // cargar puntero al primer nodo
    bl print                    // llamar a función de impresión

    // Salida del programa
    mov x8, #93                 // syscall exit
    svc #0

// --- Procedimiento PUSH (Insertar al inicio) ---
push:
    mov x10, x0                 // Guardar val en x10
    mov x11, x1                 // Guardar head actual en x11

    // Solicitar memoria al sistema (brk)
    mov x8, #214                // syscall brk (obtener dirección actual)
    svc #0
    mov x12, x0                 // x12 = nueva dirección base (nuevo nodo)

    add x0, x0, #16             // Incrementar 16 bytes (8 val + 8 next)
    mov x8, #214                // syscall brk (reservar memoria)
    svc #0

    str x10, [x12]              // nuevo_nodo.val = val
    str x11, [x12, #8]          // nuevo_nodo.next = head antiguo
    
    ldr x13, =head              // Actualizar puntero global
    str x12, [x13]              // head = nuevo_nodo
    ret

// --- Procedimiento PRINT (Recorrer e imprimir) ---
print:
    stp lr, fp, [sp, #-16]!     // Guardar registros en la pila
    mov fp, sp
    mov x21, x0                 // x21 = puntero tmp (inicio de lista)

loop:
    cbz x21, end                // Si tmp == NULL, terminar
    
    ldr x0, [x21]               // Cargar valor del nodo
    ldr x1, =buffer             // Dirección del buffer
    bl itoa                     // Convertir valor a texto (externo)

    // Syscall write para imprimir el buffer
    mov x0, #1                  // stdout
    ldr x1, =buffer
    mov x2, #11                 // longitud
    mov x8, #64                 // syscall write
    svc #0

    ldr x21, [x21, #8]          // tmp = tmp.next
    b loop

end:
    ldp lr, fp, [sp], #16       // Restaurar registros
    ret
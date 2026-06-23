// determinant = a - b
//
// a = matrix[0, 0] * matrix[1, 1]
// b = matrix[1, 0] * matrix[0, 1]

.global _start
.extern itoa

.data
matrix:
    .word 25, 11
    .word 10, 20

.bss
buffer: .space 11

.text
_start:
    ldr x10, =matrix        // load matrix address

    // --- Cálculo para el elemento [0, 0] ---
    mov x0, #0              // row = 0
    mov x1, #0              // col = 0
    mov x2, #2              // num_cols = 2
    bl offset
    mov x11, x0             // x11 = offset matrix[0, 0]

    // --- Cálculo para el elemento [1, 1] ---
    mov x0, #1              // row = 1
    mov x1, #1              // col = 1
    mov x2, #2              // num_cols = 2
    bl offset
    mov x12, x0             // x12 = offset matrix[1, 1]

    // --- Carga de valores en memoria ---
    add x11, x10, x11       // address = base + offset
    ldr w11, [x11]          // load 32 bits (valor en 0,0)
    add x12, x10, x12       // address = base + offset
    ldr w12, [x12]          // load 32 bits (valor en 1,1)
    mul x13, x11, x12       // x13 = x11 * x12 (a)
    
    mov x0, #1              // row = 1
    mov x1, #0              // col = 1
    mov x2, #2              // num_cols = 2  
    bl offset
    mov x11, x0             // x14 = offset matrix[1, 0]

    mov x0, #0              // row = 1
    mov x1, #1              // col = 1
    mov x2, #2              // num_cols = 2  
    bl offset
    mov x12, x0             // x15 = offset matrix[0, 1]

    add x11, x10, x11
    ldr w11, [x11]          // load 32 bits (valor en 1,0)
    add x12, x10, x12
    ldr w12, [x12]
    mul x14, x11, x12       // x14 = x11 * x12 (b)
 
    // --- Cálculo del determinante final (Visible en imagen 3) ---
    sub x11, x13, x14       // x11 = x13 - x14 (det = a - b)

    mov x0, x11             // call itoa
    ldr x1, =buffer
    bl itoa

    mov x0, #1              // print buffer
    ldr x1, =buffer
    mov x2, #11
    mov x8, #64
    svc #0

    mov x8, #93             // exit
    svc #0
// --- Subrutina para calcular el offset en memoria ---
offset:                     // row-major offset
    mul x3, x0, x2          // x3 = row * num_cols
    add x3, x3, x1          // x3 = (row * num_cols) + col
    mov x4, #4              // tamaño del elemento (4 bytes)
    mul x0, x3, x4          // offset en bytes = índice * 4
    ret
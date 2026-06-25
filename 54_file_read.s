.global _start

.data
filename: .asciz "test.txt"         // Nombre del archivo a leer

.bss
buffer:   .space 1024               // Espacio reservado para almacenar lo leído

// --- Sección de Texto (Código) ---
.text
_start:
    // --- Abrir Archivo (OPENAT) ---
    mov x0, #-100                   // AT_FDCWD (directorio actual)
    ldr x1, =filename               // Dirección de "test.txt"
    mov x2, #0                      // Flag: O_RDONLY (solo lectura)
    mov x3, #0777                   // Modo (permisos)
    mov x8, #56                     // Syscall OPENAT
    svc #0                          // Llamada al sistema
    
    mov x20, x0                     // Preservar File Descriptor en x20

    // --- Leer del Archivo (READ) ---
    mov x0, x20                     // Cargar File Descriptor
    ldr x1, =buffer                 // Dirección donde guardar los datos
    mov x2, #1024                   // Tamaño máximo a leer
    mov x8, #63                     // Syscall READ
    svc #0                          // Llamada al sistema

    // --- Cerrar el Archivo (CLOSE) ---
    mov x0, x20                     // Cargar File Descriptor
    mov x8, #57                     // Syscall CLOSE
    svc #0                          // Llamada al sistema

    // --- Imprimir Contenido en Consola (WRITE a STDOUT) ---
    mov x0, #1                      // File Descriptor 1 (stdout)
    ldr x1, =buffer                 // Dirección de los datos leídos
    mov x2, #1024                   // Tamaño del buffer
    mov x8, #64                     // Syscall WRITE
    svc #0                          // Llamada al sistema

    // --- Salir del Programa (EXIT) ---
    mov x8, #93                     // Syscall EXIT
    svc #0                          // Llamada al sistema
    
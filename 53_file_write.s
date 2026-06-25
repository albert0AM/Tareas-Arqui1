.global _start


.data
filename: .asciz "test.txt"         // Nombre del archivo a crear/abrir
buffer:   .asciz "Hello,\nWorld!\n" // Contenido a escribir en el archivo

// --- Sección de Texto (Código) ---
.text
_start:
    // --- Abrir o Crear Archivo (OPENAT) ---
    mov x0, #-100                   // Cargar AT_FDCWD (directorio actual)
    ldr x1, =filename               // Dirección del nombre del archivo
    mov x2, #101                    // Flags: O_CREAT | O_WRONLY
    mov x3, #0777                   // Permisos: octal 777 (rwxrwxrwx)
    mov x8, #56                     // Syscall OPENAT
    svc #0                          // Llamada al sistema
    
    mov x20, x0                     // Preservar el File Descriptor devuelto en x20

    // --- Escribir en el Archivo (WRITE) ---
    mov x0, x20                     // Cargar el File Descriptor guardado
    ldr x1, =buffer                 // Dirección del contenido a escribir
    mov x2, #15                     // Tamaño del buffer (bytes)
    mov x8, #64                     // Syscall WRITE
    svc #0                          // Llamada al sistema

    // --- Cerrar el Archivo (CLOSE) ---
    mov x0, x20                     // Cargar el File Descriptor
    mov x8, #57                     // Syscall CLOSE
    svc #0                          // Llamada al sistema

    // --- Salir del Programa (EXIT) ---
    mov x8, #93                     // Syscall EXIT
    svc #0                          // Llamada al sistema

    
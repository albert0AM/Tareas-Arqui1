// utils.s
// Biblioteca común para los módulos ARM64 del Invernadero Inteligente IoT

// Proporciona las siguientes funciones reutilizables:
//   - atoi_csv            : Convierte ASCII a entero desde buffer 
//   - read_column_to_stack: Lee una columna del CSV y apila los valores 
//   - utils_open_file     : Abre lecturas.csv                         
//   - utils_read_file     : Lee el contenido al buffer                
//   - utils_close_file    : Cierra el archivo                         
//   - utils_skip_to_next_line  : Salta hasta '\n' o '$'              
//   - utils_skip_to_next_column: Salta hasta ',', '\n' o '$'         
//   - utils_save_number   : Guarda un número en el stack            
//   - print_uint          : Imprime un entero sin signo en stdout     
//   - write_file_open     : Abre/crea un archivo de salida para escritura 
//   - write_file_write    : Escribe bytes en un archivo ya abierto    
//   - write_file_close    : Cierra un archivo de salida             

// Convenciones de registros compartidos:
//   x5  = base 10 (para atoi_csv)
//   x10 = resultado numérico de atoi_csv
//   x7  = bandera: 1 si atoi_csv leyó al menos un dígito
//   w23 = último delimitador leído por atoi_csv
//   x19 = descriptor de archivo (fd) del CSV de entrada
//   x20 = bytes leídos del archivo
//   x21 = puntero actual dentro del buffer
//   x22 = contador de números guardados en stack
//   x11 = número de columna seleccionada (lo pasa el caller)
//   x28 = límite superior del área de datos en stack
//   x27 = posición para restaurar el stack al terminar
// Uso desde los módulos:
//   .include "utils.s"
//   (No requiere .extern; al incluir el archivo, todos los símbolos quedan disponibles)

// SECCIÓN DE DATOS
// Strings de nombre de archivo, mensajes de error, buffer de lectura.

.data

// Nombre del archivo de entrada 
utils_filename:
    .asciz "lecturas.csv"

// Mensaje de error si no se puede abrir el archivo
utils_err_open:
    .ascii "Error al abrir el archivo\n"
    utils_err_open_len = . - utils_err_open

// Mensaje de error si no se puede leer el archivo
utils_err_read:
    .ascii "Error al leer el archivo\n"
    utils_err_read_len = . - utils_err_read

// Buffer interno para conversión de entero a ASCII (print_uint)
// Se define aquí para que print_uint lo use sin depender del .bss del caller
utils_num_buffer:
    .skip 32



// SECCIÓN BSS

.bss

// Buffer donde se carga el contenido completo de lecturas.csv
utils_buffer:
    .skip 4096



// SECCIÓN DE CÓDIGO

.text

// atoi_csv
// Convierte una cadena ASCII decimal a entero, leyendo byte a byte desde x21.
// Se detiene al encontrar un carácter que no sea dígito (',' '\n' '$' o cualquier otro).

// Entrada:
//   x21 = puntero actual dentro del buffer (se avanza automáticamente)
//   x5  = base (debe ser 10)
//
// Salida:
//   x10 = número convertido
//   x7  = 1 si se leyó al menos un dígito, 0 si no
//   w23 = último carácter leído (el delimitador que detuvo la lectura)
//   x21 = apunta al carácter siguiente al delimitador
atoi_csv:
    mov x10, #0             // Inicializar resultado en 0
    mov x7,  #0             // Inicializar bandera "número activo" en 0 (ningún dígito leído aún)

atoi_loop:
    // Leer byte actual y avanzar puntero (post-incremento)
    ldrb w23, [x21], #1

    // Si es dígito válido ('0'..'9'), procesarlo
    cmp w23, '0'
    blt atoi_done           // Menor que '0' no es dígito → terminar

    cmp w23, '9'
    bgt atoi_done           // Mayor que '9' no es dígito → terminar

    // Convertir carácter ASCII a valor numérico: valor = char - '0'
    sub w23, w23, '0'

    // resultado = resultado * 10
    mov x4, x10
    mul x10, x4, x5         // x10 = x10 * 10

    // resultado = resultado + dígito actual
    add x10, x10, x23       // x10 = x10 + dígito

    // Marcar que se leyó al menos un dígito
    mov x7, #1

    b atoi_loop             // Continuar con el siguiente carácter

atoi_done:
    // w23 contiene el delimitador que terminó la lectura
    ret



// read_column_to_stack
// Lee el archivo lecturas.csv, extrae todos los valores de la columna x11
// y los apila en el stack. Salta la primera línea (encabezado).

// Entrada:
//   x11 = número de columna a extraer (1-based: 1=ID, 2=TEMP, 3=HUM_AIRE, ...)

// Salida:
//   x0 = puntero al primer elemento en el stack (tope actual del stack)
//   x1 = límite superior (valor de sp antes de apilar datos)
//   x2 = cantidad de números guardados
//   x3 = posición para restaurar el stack al terminar (caller debe hacer mov sp, x3)

// Registros internos usados:
//   x19 = fd del archivo
//   x20 = bytes leídos
//   x21 = puntero al buffer
//   x22 = contador de números
//   x28 = límite superior (sp antes de apilar)
//   x27 = posición para restaurar stack (sp antes de los datos, después del frame)
//   x12 = contador de columna actual al recorrer la línea

read_column_to_stack:
    // Guardar link register y frame pointer
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // Recordar dónde está el tope del stack antes de apilar datos
    // x28 = límite superior (datos se apilan por debajo de aquí)
    mov x28, sp

    // x27 = posición a la que el caller debe restaurar sp al terminar
    // Es sp + 16 (por encima del frame guardado)
    add x27, x28, #16

    mov x5,  #10            // Base decimal para atoi_csv
    mov x22, #0             // Contador de números apilados

    // Abrir el archivo
    // Ref: 11_utils.s (bl utils_open_file)
    bl utils_open_file

    // Leer el archivo completo al buffer
    bl utils_read_file

    // -Cerrar el archivo (ya tenemos el contenido en buffer)
    bl utils_close_file

    // Apuntar x21 al inicio del buffer
    ldr x21, =utils_buffer

    // altar encabezado
    bl utils_skip_to_next_line

    // Si inmediatamente encontramos '$', el archivo termina
    cmp w23, '$'
    beq utils_done

// Procesar cada línea de datos
utils_process_line:
    mov x12, #1             // Comenzar en la columna 1 de esta línea

// Avanzar hasta la columna deseada
utils_find_column:
    // Verificar si es la columana correcta
    cmp x12, x11
    beq utils_read_column

    // saltar caracteres hasta encontrar ',' 
    bl utils_skip_to_next_column

    cmp w23, '$'
    beq utils_done          // Fin de archivo

    cmp w23, #10            // '\n' = nueva línea (esta fila no tiene la columna)
    beq utils_process_line

    // Si fue coma, avanzamos el contador de columna y seguimos buscando
    add x12, x12, #1
    b utils_find_column

// Leer el valor de la columna usando atoi_csv
utils_read_column:
    bl atoi_csv

    // Si no se leyó ningún dígito válido, no guardar
    cbz x7, utils_after_column

    // Guardar número en el stack
    bl utils_save_number

// Después de leer la columna, manejar el resto de la línea
utils_after_column:
    cmp w23, '$'
    beq utils_done          // Fin de archivo

    cmp w23, #10            // Si ya estamos en '\n', pasar a la siguiente línea
    beq utils_process_line

    // Si no, saltar el resto de la línea hasta '\n' o '$'
    bl utils_skip_to_next_line

    cmp w23, '$'
    beq utils_done

    b utils_process_line    // Continuar con la siguiente línea

// Todos los datos han sido apilados
utils_done:
    // Devolver resultados al caller
    // x0 = tope del stack (primer dato)
    // x1 = límite superior (antes de apilar)
    // x2 = cantidad de datos
    // x3 = posición para restaurar stack
    mov x0, sp
    mov x1, x28
    mov x2, x22
    mov x3, x27

    // Restaurar solo el link register (no el sp, eso lo hace el caller con x3)
    ldr x30, [x29, #8]
    ret



// utils_open_file
// Abre el archivo lecturas.csv usando la syscall openat (AT_FDCWD, O_RDONLY).
// En caso de error, imprime mensaje y termina el programa.

// Entrada: ninguna (usa utils_filename interno)
// Salida:  x19 = descriptor de archivo válido

utils_open_file:
    mov x0, #-100           // AT_FDCWD: directorio de trabajo actual
    ldr x1, =utils_filename // Puntero al nombre del archivo
    mov x2, #0              // O_RDONLY: solo lectura
    mov x3, #0              
    mov x8, #56             
    svc #0

    // Verificar si el fd es negativo (error)
    cmp x0, #0
    blt utils_open_error

    mov x19, x0             // Guardar fd en x19
    ret


// =============================================================================
// utils_read_file
// Lee hasta 4096 bytes del archivo (fd en x19) al buffer interno utils_buffer.
// En caso de error, imprime mensaje y termina el programa.

// Entrada: x19 = descriptor de archivo
// Salida:  x20 = cantidad de bytes leídos
// utils_buffer lleno con el contenido del archivo
utils_read_file:
    mov x0, x19             // fd del archivo
    ldr x1, =utils_buffer   // Destino de la lectura
    mov x2, #4096           // Máximo a leer (tamaño del buffer)
    mov x8, #63             // Número de syscall: read
    svc #0

    // Verificar error
    cmp x0, #0
    blt utils_read_error

    mov x20, x0             // Guardar bytes leídos en x20
    ret

// utils_close_file
// Cierra el archivo cuyo descriptor está en x19.
// Entrada: x19 = descriptor de archivo
// Salida:  ninguna
utils_close_file:
    mov x0, x19             // fd a cerrar
    mov x8, #57             // Número de syscall: close
    svc #0
    ret

// utils_skip_to_next_line
// Avanza x21 byte a byte hasta encontrar '\n' (0x0A) o '$'.
// Se usa para saltar el encabezado y para saltar el resto de una línea.
// Entrada: x21 = puntero actual en el buffer
// Salida:  x21 apunta al byte siguiente a '\n' o '$'
//          w23 = carácter que detuvo el avance ('\n' o '$')

utils_skip_to_next_line:
    ldrb w23, [x21], #1     // Leer byte y avanzar puntero

    cmp w23, '$'
    beq utils_skip_done     // Fin de datos

    cmp w23, #10            // '\n'
    beq utils_skip_done     // Fin de línea

    b utils_skip_to_next_line

// utils_skip_to_next_column
// Avanza x21 byte a byte hasta encontrar ',' '\n' o '$'.
// Se usa para saltar columnas que no nos interesan.
// Entrada: x21 = puntero actual en el buffer
// Salida:  x21 apunta al byte siguiente al delimitador encontrado
//          w23 = delimitador (',' '\n' o '$')
utils_skip_to_next_column:
    ldrb w23, [x21], #1     // Leer byte y avanzar puntero

    cmp w23, '$'
    beq utils_skip_done     // Fin de datos

    cmp w23, #10            // '\n'
    beq utils_skip_done     // Fin de línea

    cmp w23, ','
    beq utils_skip_done     // Separador de columna

    b utils_skip_to_next_column

utils_skip_done:
    ret                     // El carácter detenedor está en w23


// utils_save_number
// Apila el valor de x10 en el stack (reserva 16 bytes para alineación AArch64)
// e incrementa el contador x22.

// Se reservan 16 bytes (el dato ocupa 8) para mantener
//       el stack alineado a 16 bytes según el ABI ARM64.

// Entrada: x10 = número a guardar
//          x22 = contador actual
// Salida:  sp  = apunta a la nueva entrada (sp decrementado en 16)
//          x22 = contador incrementado en 1
utils_save_number:
    sub sp, sp, #16         // Reservar espacio en stack (alineado a 16 bytes)
    str x10, [sp]           // Guardar el número en el tope del stack
    add x22, x22, #1        // Incrementar contador de números guardados
    ret

// print_uint
// Imprime en stdout un entero sin signo (x0) como cadena decimal.
// Convierte el número a ASCII de derecha a izquierda en utils_num_buffer,
// luego hace write(1, inicio_string, longitud)
// Entrada: x0 = número a imprimir (sin signo)
// Salida:  imprime en stdout; no modifica registros del caller (salva x29/x30)
print_uint:
    // Guardar frame pointer y link register
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    // Apuntar al final del buffer y colocar terminador nulo
    // Ref: archivo de prueba suma (ldr x1, =num_buffer / add x1, x1, #31 / mov w2, #0 / strb w2, [x1])
    ldr x1, =utils_num_buffer
    add x1, x1, #31         // Apuntar al último byte del buffer (índice 31)
    mov w2,  #0
    strb w2, [x1]           // Colocar '\0' al final (no estrictamente necesario, pero seguro)

    mov x3, #10             // Divisor decimal
    mov x4, #0              // Contador de dígitos escritos

    // Caso especial: si el número es 0, escribir '0' directamente
    cmp x0, #0
    bne convert_loop_u

    sub x1, x1, #1
    mov w2, '0'
    strb w2, [x1]
    mov x4, #1
    b write_number_u

// Ciclo de conversión: extrae el dígito menos significativo en cada iteración
// Ref: archivo de prueba suma (udiv x5, x0, x3 / msub x6, x5, x3, x0 / add x6, x6, '0')
convert_loop_u:
    udiv x5, x0, x3         // x5 = x0 / 10 (cociente)
    msub x6, x5, x3, x0     // x6 = x0 - (x5 * 10)  → dígito actual (resto)

    add x6, x6, '0'         // Convertir dígito a ASCII

    sub x1, x1, #1          // Avanzar puntero hacia la izquierda
    strb w6, [x1]           // Escribir dígito ASCII

    add x4, x4, #1          // Incrementar contador de dígitos

    mov x0, x5              // Siguiente número = cociente
    cbnz x0, convert_loop_u // Si cociente != 0, seguir

write_number_u:
    // Escribir la cadena construida en stdout
    mov x0, #1              // fd = stdout
    // x1 ya apunta al inicio del número en el buffer
    mov x2, x4              // cantidad de bytes a escribir
    mov x8, #64             // syscall: write
    svc #0

    // Restaurar frame pointer y link register
    ldp x29, x30, [sp], #16
    ret

// write_file_open
// Abre o crea un archivo de salida para escritura.

// Entrada: x1 = puntero a la cadena con el nombre del archivo (asciz)
// Salida:  x19 = descriptor de archivo del archivo de salida
//          Si hay error, imprime en stderr y termina

write_file_open:
    mov x0, #-100           // AT_FDCWD
    // x1 ya viene del caller con el nombre del archivo
    mov x2, #577            // O_WRONLY | O_CREAT | O_TRUNC  (1 | 64 | 512)
    mov x3, #420            // Permisos 0644
    mov x8, #56             // syscall: openat
    svc #0

    // Verificar error
    cmp x0, #0
    blt write_file_open_error

    mov x19, x0             // Guardar fd del archivo de salida
    ret
utils_open_error:
write_file_open_error:
    // Imprimir error y salir
    // Ref: 06_write_file.s (error: ldr x1, =mgs_err / mov x8, #64)
    mov x0, #2              // stderr
    ldr x1, =utils_err_open
    mov x2, utils_err_open_len
    mov x8, #64
    svc #0

    mov x0, #1
    mov x8, #93
    svc #0

// write_file_write
// Escribe un bloque de bytes en el archivo cuyo fd está en x19.
// Entrada: x19 = fd del archivo de salida
//          x1  = puntero al buffer con los datos a escribir
//          x2  = cantidad de bytes a escribir
// Salida:  ninguna (en caso de error, termina el programa)
write_file_write:
    mov x0, x19             // fd del archivo de salida
    // x1 y x2 vienen del caller
    mov x8, #64             // syscall: write
    svc #0

    cmp x0, #0
    blt write_file_write_error
    ret
    
utils_read_error:
write_file_write_error:
    mov x0, #2              // stderr
    ldr x1, =utils_err_open
    mov x2, utils_err_open_len
    mov x8, #64
    svc #0

    mov x0, #1
    mov x8, #93
    svc #0

// write_file_close
// Cierra el archivo de salida cuyo fd está en x19.
// Entrada: x19 = fd del archivo de salida
// Salida:  ninguna

write_file_close:
    mov x0, x19             // fd a cerrar
    mov x8, #57             // syscall: close
    svc #0
    ret
// =============================================================================
// modulo_3_anomalias.s
// Módulo 3 – Detección estadística de anomalías (Z-Score)
//
// Descripción:
//   Lee la columna dinámica pasada por argumento (argv[1]) desde lecturas.csv,
//   calcula media, desviación estándar y z-score para cada dato.
//   Clasifica cada lectura como ANOMALIA si |Z| >= 2.
//   Escribe los resultados en arm64_results/resultado_anomalias.txt
// =============================================================================

.include "utils.s"

// ─── Constantes ──────────────────────────────────────────────────────────────
.equ TOTAL_VALUES,  30          // Cantidad de lecturas en el CSV

// ─── Sección de datos (cadenas de salida) ─────────────────────────────────────
.data

out_filename:
    .asciz "resultado_anomalias.txt"

// Encabezado del informe
hdr_module:
    .ascii  "MODULE=ANOMALY_DETECTION\n"
    hdr_module_len = . - hdr_module

hdr_total:
    .ascii  "TOTAL_VALUES=30\n"
    hdr_total_len = . - hdr_total

hdr_mean_label:
    .ascii  "MEAN="
    hdr_mean_label_len = . - hdr_mean_label

hdr_std_label:
    .ascii  "\nSTD_DEV="
    hdr_std_label_len = . - hdr_std_label

hdr_anom_label:
    .ascii  "\nANOMALIES="
    hdr_anom_label_len = . - hdr_anom_label

hdr_risk_label:
    .ascii  "\nSYSTEM_RISK="
    hdr_risk_label_len = . - hdr_risk_label

str_newline:
    .ascii  "\n"
    str_newline_len = . - str_newline

// Clasificaciones de riesgo
risk_normal:
    .ascii  "NORMAL\n"
    risk_normal_len = . - risk_normal

risk_medium:
    .ascii  "MEDIUM\n"
    risk_medium_len = . - risk_medium

risk_high:
    .ascii  "HIGH\n"
    risk_high_len = . - risk_high

// Buffer reutilizable para escribir un entero al archivo
.bss
num_buf:     .skip 32           // Buffer ASCII para entero a texto (write_uint_to_file)
frac_buf:    .skip 8            // Buffer para parte fraccional del z-score

// ─── Sección de código ────────────────────────────────────────────────────────
.text
.global _start

_start:
    // ── PASO 1: Leer argumento de columna dinámica (argv[1]) desde el stack ──
    ldr x0, [sp]            // x0 = argc
    cmp x0, #2              // Verificar que se haya pasado un argumento (columna)
    blt usar_columna_default

    ldr x1, [sp, #16]       // x1 = ptr a argv[1] (ej: "1", "2", "3"...)
    ldrb w11, [x1]          // Cargar el carácter ASCII de la columna
    sub w11, w11, #'0'      // Convertir ASCII a número entero directo
    b   procesar_columna

usar_columna_default:
    mov x11, #1             // Fallback por defecto: Columna 1 (TEMP)

procesar_columna:
    // read_column_to_stack lee la columna indicada en x11 desde lecturas.csv
    bl  read_column_to_stack

    // Guardar referencias del stack de datos devueltas por la subrutina externa
    mov x24, x0             // x24 = ptr inicio datos
    mov x25, x1             // x25 = límite superior (sp antes de apilar)
    mov x26, x2             // x26 = cantidad de datos leídos (30)
    mov x27, x3             // x27 = sp original para restaurar al final

    // ── PASO 2: Calcular SUMA de todos los valores ────────────────────────
    mov x0, x24
    mov x1, x26
    bl  calc_sum            // x0 = suma total de los datos
    mov x14, x0             // x14 = suma (guardada para calcular media)

    // ── PASO 3: Calcular MEDIA entera ─────────────────
    mov x1, #TOTAL_VALUES
    udiv x15, x14, x1        // x15 = media

    // ── PASO 4: Calcular VARIANZA y DESVIACIÓN ESTÁNDAR (escalada) ────────
    mov x0, x24             // puntero a datos
    mov x1, x26             // cantidad de datos
    mov x2, x15             // media
    bl  calc_variance       // x0 = varianza

    // std_dev = isqrt(varianza)
    bl  integer_sqrt        // x0 = std_scaled
    mov x16, x0             // x16 = desviación estándar

    // ── PASO 5: Contar ANOMALÍAS con z-score ──────────────────────────────
    mov x0, x24
    mov x1, x26
    mov x2, x15             // media
    mov x3, x16             // std_dev
    bl  count_anomalies     // x0 = cantidad de anomalías detectadas
    mov x17, x0             // x17 = contador de anomalías

    // ── PASO 6: Abrir archivo de salida ───────────────────────────────────
    ldr x1, =out_filename
    bl  write_file_open     // x19 = fd del archivo de salida unificado

    // ── PASO 7: Escribir reporte formateado en el TXT ─────────────────────
    // 1. MODULE=ANOMALY_DETECTION
    ldr x1, =hdr_module
    mov x2, #hdr_module_len
    bl  write_file_write

    // 2. TOTAL_VALUES=30
    ldr x1, =hdr_total
    mov x2, #hdr_total_len
    bl  write_file_write

    // 3. MEAN=
    ldr x1, =hdr_mean_label
    mov x2, #hdr_mean_label_len
    bl  write_file_write

    mov x0, x15
    bl  write_uint_to_file

    // 4. STD_DEV=
    ldr x1, =hdr_std_label
    mov x2, #hdr_std_label_len
    bl  write_file_write

    mov x0, x16
    bl  write_uint_to_file

    // 5. ANOMALIES=
    ldr x1, =hdr_anom_label
    mov x2, #hdr_anom_label_len
    bl  write_file_write

    mov x0, x17             // Cantidad de anomalías calculadas
    bl  write_uint_to_file

    // 6. SYSTEM_RISK=
    ldr x1, =hdr_risk_label
    mov x2, #hdr_risk_label_len
    bl  write_file_write

    bl  write_risk_label    // Escribe NORMAL / MEDIUM / HIGH al archivo según x17

    // ── PASO 9: Cerrar archivo de salida y salir de forma limpia ──────────
    bl  write_file_close

    mov sp, x27             // Restaurar puntero de stack original
    mov x0, #0
    mov x8, #93             // syscall: exit
    svc #0

calc_sum:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    mov x2, x0              // puntero
    mov x3, x1              // contador
    mov x0, #0              // acumulador

calc_sum_loop:
    cbz x3, calc_sum_done
    ldr x4, [x2], #16      // Leer dato y avanzar (cada uno ocupa 16 bytes)
    add x0, x0, x4
    sub x3, x3, #1
    b   calc_sum_loop

calc_sum_done:
    ldp x29, x30, [sp], #16
    ret

calc_variance:
    stp x29, x30, [sp, #-32]!
    mov x29, sp
    str x19, [sp, #16]

    mov x3, x0              // puntero
    mov x4, x1              // contador
    mov x5, x2              // media
    mov x0, #0              // acumulador de suma de cuadrados

calc_var_loop:
    cbz x4, calc_var_done
    ldr x6, [x3], #16      // xi

    // diff = xi - media
    subs x8, x6, x5

    // Si diff es negativo, tomar valor absoluto
    bge calc_var_pos
    neg x8, x8

calc_var_pos:
    mul x9, x8, x8          // diff^2
    add x0, x0, x9          // acumular

    sub x4, x4, #1
    b   calc_var_loop

calc_var_done:
    mov x1, #TOTAL_VALUES
    udiv x0, x0, x1         // varianza

    ldr x19, [sp, #16]
    ldp x29, x30, [sp], #32
    ret

integer_sqrt:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    mov x1, x0              // guardar n
    cbz x0, isqrt_done      // sqrt(0) = 0

    mov x2, #1              // low
    mov x3, x0              // high = n
    mov x0, #0              // result

isqrt_loop:
    cmp x2, x3
    bgt isqrt_done

    // mid = (low + high) / 2
    add x4, x2, x3
    lsr x4, x4, #1

    mul x5, x4, x4          // mid * mid

    cmp x5, x1
    beq isqrt_exact
    bgt isqrt_high

    // mid*mid < n  → result = mid, low = mid+1
    mov x0, x4
    add x2, x4, #1
    b   isqrt_loop

isqrt_exact:
    mov x0, x4
    b   isqrt_done

isqrt_high:
    sub x3, x4, #1
    b   isqrt_loop

isqrt_done:
    ldp x29, x30, [sp], #16
    ret

count_anomalies:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    mov x4, x0              // puntero
    mov x5, x1              // contador
    mov x6, x2              // media
    mov x7, x3              // std_dev
    mov x0, #0              // acumulador anomalías

    // umbral = 2 * std_dev
    lsl x8, x7, #1          // x8 = 2 * std_dev

count_anom_loop:
    cbz x5, count_anom_done
    ldr x9, [x4], #16      // xi

    // diff = |xi - media|
    
    subs x11, x9, x6
    bge count_anom_abs_ok
    neg x11, x11

count_anom_abs_ok:
    // Si diff >= 2 * std_scaled → anomalía
    cmp x11, x8
    blt count_anom_next
    add x0, x0, #1

count_anom_next:
    sub x5, x5, #1
    b   count_anom_loop

count_anom_done:
    ldp x29, x30, [sp], #16
    ret

write_risk_label:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    cmp x17, #0
    beq write_risk_normal
    cmp x17, #4
    bge write_risk_high

    // 1-3 → MEDIUM
    ldr x1, =risk_medium
    mov x2, #risk_medium_len
    bl  write_file_write
    b   risk_done_label

write_risk_normal:
    ldr x1, =risk_normal
    mov x2, #risk_normal_len
    bl  write_file_write
    b   risk_done_label

write_risk_high:
    ldr x1, =risk_high
    mov x2, #risk_high_len
    bl  write_file_write

risk_done_label:
    ldp x29, x30, [sp], #16
    ret

write_uint_to_file:
    stp x29, x30, [sp, #-16]!
    mov x29, sp

    ldr x1, =num_buf
    add x1, x1, #31
    mov w2, #0
    strb w2, [x1]           // Terminador nulo al final

    mov x3, #10
    mov x4, #0              // contador de dígitos

    // Caso especial cero
    cmp x0, #0
    bne wuf_convert

    sub x1, x1, #1
    mov w2, #'0'
    strb w2, [x1]
    mov x4, #1
    b   wuf_write

wuf_convert:
    udiv x5, x0, x3         // cociente
    msub x6, x5, x3, x0    // resto = dígito
    add  x6, x6, #'0'
    sub  x1, x1, #1
    strb w6, [x1]
    add  x4, x4, #1
    mov  x0, x5
    cbnz x0, wuf_convert

wuf_write:
    mov x0, x19
    mov x2, x4
    mov x8, #64             // write syscall
    svc #0

    ldp x29, x30, [sp], #16
    ret
    
    
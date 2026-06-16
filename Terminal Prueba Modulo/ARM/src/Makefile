# Makefile: ARM64 multi-programa en host x86/x64 con QEMU
# Cada archivo .s (excepto utils.s) genera su propio ejecutable.

# ----------------------------------------------------------
# Toolchain
# ----------------------------------------------------------
AS      = aarch64-linux-gnu-as
LD      = aarch64-linux-gnu-ld
QEMU    = qemu-aarch64

# ----------------------------------------------------------
# Rutas
# ----------------------------------------------------------
BUILD   = build

# ----------------------------------------------------------
# Fuentes
# Archivos que se usan con .include y NO se ensamblan directo
# ----------------------------------------------------------
INCLUDES = utils.s

# Detectar todos los .s excepto los de INCLUDES
PROGS    = $(filter-out $(INCLUDES), $(wildcard *.s))

# Ejecutables finales: build/suma, build/resta, etc.
TARGETS  = $(patsubst %.s,$(BUILD)/%,$(PROGS))

# ----------------------------------------------------------
# Flags
# ----------------------------------------------------------
ASFLAGS = -g
LDFLAGS =

# ----------------------------------------------------------
# Targets principales
# ----------------------------------------------------------

all: $(TARGETS)

# Crear directorio build si no existe
$(BUILD):
	mkdir -p $(BUILD)

# Ensamblar cada .s a su .o
$(BUILD)/%.o: %.s | $(BUILD)
	$(AS) $(ASFLAGS) -o $@ $<

# Enlazar cada .o a su propio ejecutable
$(BUILD)/%: $(BUILD)/%.o
	$(LD) $(LDFLAGS) -o $@ $<

# ----------------------------------------------------------
# Ejecución: correr todos los programas con QEMU
# ----------------------------------------------------------
run: all
	@for target in $(TARGETS); do \
		echo ">>> Ejecutando $$target ..."; \
		$(QEMU) $$target; \
		echo ""; \
	done

# ----------------------------------------------------------
# Ejecutar uno solo: make run-suma, make run-resta, etc.
# ----------------------------------------------------------
run-suma: ARGS ?= 2
run-%: $(BUILD)/%
	$(QEMU) $< $(ARGS)

# ----------------------------------------------------------
# Depuración GDB para un programa: make gdb-suma
# ----------------------------------------------------------
gdb-%: $(BUILD)/%
	@echo "Esperando GDB en puerto 1234 para $< ..."
	$(QEMU) -g 1234 $<

# ----------------------------------------------------------
# Limpieza
# ----------------------------------------------------------
clean:
	rm -rf $(BUILD)

# ----------------------------------------------------------
# Info
# ----------------------------------------------------------
info:
	@echo "Programas detectados: $(PROGS)"
	@echo "Ejecutables a generar: $(TARGETS)"
	@echo "Archivos incluidos (.include): $(INCLUDES)"
	@echo ""
	@echo "Comandos disponibles:"
	@echo "  make           -> ensambla y enlaza todos los programas"
	@echo "  make run       -> ejecuta todos con QEMU"
	@echo "  make run-suma  -> ejecuta suma (por defecto usa la columna 2; override con ARGS=)"
	@echo "  make gdb-suma  -> depura suma con GDB"
	@echo "  make clean     -> elimina build/"
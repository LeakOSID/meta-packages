# --- Konfigurasi ---
PREFIX = /usr
BINDIR = $(PREFIX)/bin
SHAREDIR = $(PREFIX)/share/leakos
LOGDIR = /var/log/leakos
SKRIP_NAME = leak
SOURCE_FILE = leak

# --- Warna ---
BLUE = \033[1;34m
GREEN = \033[1;32m
RED = \033[1;31m
YELLOW = \033[1;33m
NC = \033[0m # No Color

all:
	@echo "${BLUE}=========================================${NC}"
	@echo "${BLUE}  LeakOS Package Manager (LPM) Builder   ${NC}"
	@echo "${BLUE}=========================================${NC}"
	@echo "Commands:"
	@echo "  ${BLUE}sudo make install${NC}   - Pasang LPM ke sistem"
	@echo "  ${BLUE}sudo make uninstall${NC} - Hapus binary saja"
	@echo "  ${BLUE}sudo make purge${NC}     - Hapus semua (binary + folder + symlink)"

install:
	@echo "${BLUE}[*]${NC} Creating system directories..."
	@mkdir -p $(BINDIR)
	@mkdir -p $(SHAREDIR)/build
	@mkdir -p $(LOGDIR)/packages
	@chmod 777 $(SHAREDIR)/build
	@echo "${BLUE}[*]${NC} Installing $(SKRIP_NAME) to $(BINDIR)..."
	@cp -f $(SOURCE_FILE) $(BINDIR)/$(SKRIP_NAME)
	@chmod +x $(BINDIR)/$(SKRIP_NAME)
	@echo "${GREEN}[+]${NC} Installation complete. Type '${BLUE}$(SKRIP_NAME)${NC}' to start."

uninstall:
	@echo "${BLUE}[*]${NC} Removing $(SKRIP_NAME) binary..."
	@if [ -f "$(BINDIR)/$(SKRIP_NAME)" ]; then \
		rm -f $(BINDIR)/$(SKRIP_NAME); \
		echo "${GREEN}[+]${NC} Binary removed."; \
	else \
		echo "${YELLOW}[!]${NC} Binary not found."; \
	fi
	@echo "${YELLOW}[!]${NC} Folders are kept:"
	@echo "  - $(SHAREDIR)"
	@echo "  - $(LOGDIR)"
	@echo "${BLUE}[*]${NC} Run '${BLUE}sudo make purge${NC}' to remove everything."

purge:
	@echo "${BLUE}[*]${NC} Removing everything..."
	
	
	@echo "${BLUE}[*]${NC} Removing $(SKRIP_NAME) binary..."
	@if [ -f "$(BINDIR)/$(SKRIP_NAME)" ]; then \
		rm -f $(BINDIR)/$(SKRIP_NAME); \
		echo "${GREEN}[✓]${NC} Binary removed"; \
	else \
		echo "${YELLOW}[!]${NC} Binary not found"; \
	fi
	
	
	@echo "${BLUE}[*]${NC} Searching for symlinks in $(BINDIR)..."
	@if [ -d "$(BINDIR)" ]; then \
		find $(BINDIR) -maxdepth 1 -type l 2>/dev/null | while read symlink; do \
			target=$$(readlink -f "$$symlink" 2>/dev/null || readlink "$$symlink" 2>/dev/null); \
			if [ -n "$$target" ]; then \
				if [ "$$target" = "$(BINDIR)/$(SKRIP_NAME)" ] || echo "$$symlink" | grep -q "$(SKRIP_NAME)"; then \
					echo "${BLUE}[*]${NC} Removing symlink: $$symlink -> $$target"; \
					rm -f "$$symlink"; \
				fi; \
			fi; \
		done; \
	fi
	
	
	@echo "${BLUE}[*]${NC} Removing shared directory..."
	@if [ -d "$(SHAREDIR)" ]; then \
		echo "${BLUE}[*]${NC} Removing: $(SHAREDIR)"; \
		rm -rf $(SHAREDIR); \
		echo "${GREEN}[✓]${NC} Shared directory removed"; \
	else \
		echo "${YELLOW}[!]${NC} Shared directory not found"; \
	fi
	
	
	@echo "${BLUE}[*]${NC} Removing log directory..."
	@if [ -d "$(LOGDIR)" ]; then \
		echo "${BLUE}[*]${NC} Removing: $(LOGDIR)"; \
		rm -rf $(LOGDIR); \
		echo "${GREEN}[✓]${NC} Log directory removed"; \
	else \
		echo "${YELLOW}[!]${NC} Log directory not found"; \
	fi
	
	
	@echo "${BLUE}[*]${NC} Searching for other symlinks..."
	@for dir in /usr/local/bin /usr/sbin /opt/local/bin /bin /sbin; do \
		if [ -d "$$dir" ]; then \
			find $$dir -maxdepth 1 -type l 2>/dev/null | while read symlink; do \
				target=$$(readlink -f "$$symlink" 2>/dev/null || readlink "$$symlink" 2>/dev/null); \
				if [ -n "$$target" ]; then \
					if basename "$$symlink" | grep -q "$(SKRIP_NAME)" || \
					   echo "$$target" | grep -q "$(SKRIP_NAME)" || \
					   echo "$$target" | grep -q "leakos"; then \
						echo "${BLUE}[*]${NC} Removing symlink: $$symlink -> $$target"; \
						rm -f "$$symlink"; \
					fi; \
				fi; \
			done; \
		fi; \
	done
	
	@echo "${GREEN}[+]${NC} Complete removal finished."

.PHONY: all install uninstall purge

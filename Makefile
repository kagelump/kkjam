# KKJam Makefile
# Convenience commands for development and testing

# Godot executable path (override with: make test GODOT=/path/to/godot)
GODOT ?= /Applications/Godot.app/Contents/MacOS/Godot

# Default target
.PHONY: help
help:
	@echo "KKJam Development Commands"
	@echo ""
	@echo "  make test          - Run all tests"
	@echo "  make test-unit     - Run unit tests only"
	@echo "  make test-int      - Run integration tests only"
	@echo "  make run           - Run the game"
	@echo "  make export-web    - Export game for web (release)"
	@echo "  make web-dev       - Export debug web build and serve locally"
	@echo "  make serve         - Serve exported web build locally (port 8000)"
	@echo "  make clean         - Clean temporary files"
	@echo "  make help          - Show this help message"
	@echo ""
	@echo "Override Godot path: make test GODOT=/path/to/godot"

# Run all tests
.PHONY: test
test:
	@echo "Running all tests..."
	@$(GODOT) --headless -s addons/gut/gut_cmdln.gd -gtest=res://test

# Run unit tests only
.PHONY: test-unit
test-unit:
	@echo "Running unit tests..."
	@$(GODOT) --headless -s addons/gut/gut_cmdln.gd -gtest=res://test/unit

# Run integration tests only
.PHONY: test-int
test-int:
	@echo "Running integration tests..."
	@$(GODOT) --headless -s addons/gut/gut_cmdln.gd -gtest=res://test/integration

# Run the game
.PHONY: run
run:
	@echo "Starting KKJam..."
	@$(GODOT) res://scenes/main.tscn

# Export for web
.PHONY: export-web
export-web:
	@echo "Exporting for web..."
	@mkdir -p build/web
	@$(GODOT) --headless --export-release "Web" build/web/index.html
	@echo "Export complete: build/web/index.html"

# Export web debug build and serve
.PHONY: web-dev
web-dev:
	@echo "Exporting debug web build..."
	@mkdir -p build/web
	@$(GODOT) --headless --export-debug "Web" build/web/index.html
	@echo "Export complete: build/web/index.html"
	@echo ""
	@echo "Starting web server at http://localhost:8000"
	@echo "Press Ctrl+C to stop"
	@cd build/web && python3 -m http.server 8000

# Serve web build locally
.PHONY: serve
serve:
	@echo "Serving web build at http://localhost:8000"
	@echo "Press Ctrl+C to stop"
	@cd build/web && python3 -m http.server 8000

# Clean temporary files
.PHONY: clean
clean:
	@echo "Cleaning temporary files..."
	@find . -name ".DS_Store" -delete
	@rm -rf .godot/mono_crash.*.json
	@rm -rf build/
	@echo "Clean complete."
	@echo "Clean complete."

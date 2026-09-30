#!/usr/bin/env bash

# ==============================================================================
# iOS Builder - Setup & Management Script for Flutter (HapoPay)
# Repository: https://github.com/Pak-Man926/ios-builder
# ==============================================================================

set -eo pipefail

# Text formatting
BOLD="\033[1m"
GREEN="\033[0;32m"
BLUE="\033[0;34m"
YELLOW="\033[0;33m"
RED="\033[0;31m"
CYAN="\033[0;36m"
NC="\033[0m" # No Color

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$PROJECT_ROOT"

print_header() {
    echo -e "\n${BLUE}${BOLD}====================================================${NC}"
    echo -e "${CYAN}${BOLD}       iOS Builder for Linux & Windows (MobAI)      ${NC}"
    echo -e "${BLUE}${BOLD}====================================================${NC}\n"
}

# 1. Ensure PATH has common binary locations
export PATH="$HOME/.local/bin:$HOME/bin:/usr/local/bin:$PATH"

# 2. Check and install builder CLI if missing
ensure_builder_installed() {
    echo -e "${BOLD}Checking Builder CLI installation...${NC}"
    if command -v builder >/dev/null 2>&1; then
        echo -e "${GREEN}✔ Builder CLI is already installed at: $(which builder)${NC}"
    else
        echo -e "${YELLOW}Builder CLI not found in PATH. Installing...${NC}"
        curl -sSL https://raw.githubusercontent.com/MobAI-App/ios-builder/main/install.sh | bash
        
        # Re-check PATH
        if ! command -v builder >/dev/null 2>&1; then
            if [ -f "$HOME/.local/bin/builder" ]; then
                export PATH="$HOME/.local/bin:$PATH"
            elif [ -f "/usr/local/bin/builder" ]; then
                export PATH="/usr/local/bin:$PATH"
            fi
        fi

        if command -v builder >/dev/null 2>&1; then
            echo -e "${GREEN}✔ Successfully installed Builder CLI!${NC}"
        else
            echo -e "${RED}✘ Installation finished but 'builder' was not found in PATH.${NC}"
            echo -e "Please ensure ~/.local/bin or /usr/local/bin is in your PATH and re-run."
            exit 1
        fi
    fi
}

# 3. Check project prerequisites (Flutter + iOS folder)
check_project() {
    echo -e "\n${BOLD}Checking project structure...${NC}"
    if [ ! -f "pubspec.yaml" ]; then
        echo -e "${RED}✘ pubspec.yaml not found in $PROJECT_ROOT.${NC}"
        echo -e "Please run this script from the root of your Flutter project."
        exit 1
    fi

    if [ ! -d "ios" ]; then
        echo -e "${RED}✘ ios/ directory not found in $PROJECT_ROOT.${NC}"
        echo -e "Please generate the iOS workspace using 'flutter create --platforms=ios .' first."
        exit 1
    fi
    echo -e "${GREEN}✔ Flutter project with iOS platform detected.${NC}"
}

# 4. Check Authentication Status
check_auth() {
    echo -e "\n${BOLD}Checking authentication status...${NC}"
    builder auth status
}

# 5. Authenticate GitHub
auth_github() {
    echo -e "\n${BOLD}Authenticating with GitHub...${NC}"
    builder auth github
}

# 6. Authenticate Apple
auth_apple() {
    echo -e "\n${BOLD}Authenticating with Apple App Store Connect...${NC}"
    echo -e "${CYAN}You will need an App Store Connect API Key (.p8 file), Issuer ID, and Key ID.${NC}"
    builder auth apple
}

# 7. Initialize Builder in project
init_builder() {
    echo -e "\n${BOLD}Initializing Builder for this repository...${NC}"
    if [ -f "builder.json" ] && [ -f ".github/workflows/ios-build.yml" ]; then
        echo -e "${GREEN}✔ builder.json and .github/workflows/ios-build.yml already exist.${NC}"
        read -rp "Do you want to re-run builder init? (y/N): " choice
        if [[ "$choice" =~ ^[Yy]$ ]]; then
            builder init --ios-path ios --project hapopay --remote origin
        fi
    else
        builder init --ios-path ios --project hapopay --remote origin
        echo -e "${GREEN}✔ Initialization completed.${NC}"
    fi

    # Ensure builder.json has Flutter watch configs if not already set
    if [ -f "builder.json" ]; then
        echo -e "${GREEN}✔ builder.json configured.${NC}"
    fi
}

# 8. Build iOS App
build_ios() {
    echo -e "\n${BOLD}Select build type:${NC}"
    echo "1) Unsigned IPA (Quick, development / sideloading)"
    echo "2) Standard build (Default configuration from builder.json)"
    echo "3) Store / TestFlight build (--profile store)"
    echo "4) Custom build profile"
    read -rp "Enter choice [1-4] (default 1): " build_choice
    build_choice="${build_choice:-1}"

    case "$build_choice" in
        1)
            echo -e "${CYAN}Running: builder ios build --unsigned${NC}"
            builder ios build --unsigned
            ;;
        2)
            echo -e "${CYAN}Running: builder ios build${NC}"
            builder ios build
            ;;
        3)
            echo -e "${CYAN}Running: builder ios build --profile store${NC}"
            builder ios build --profile store
            ;;
        4)
            read -rp "Enter profile name: " prof_name
            echo -e "${CYAN}Running: builder ios build --profile $prof_name${NC}"
            builder ios build --profile "$prof_name"
            ;;
        *)
            echo -e "${RED}Invalid choice.${NC}"
            ;;
    esac
}

# 9. Start Flutter Hot Reload / Dev
dev_flutter() {
    echo -e "\n${BOLD}Starting Flutter live development with hot reload via MobAI...${NC}"
    echo -e "${YELLOW}Ensure MobAI is running and your iOS device is connected.${NC}"
    echo "Options:"
    echo "1) Full dev (install & launch with hot reload)"
    echo "2) Skip install (app is already installed on device)"
    read -rp "Enter choice [1-2] (default 1): " dev_choice
    dev_choice="${dev_choice:-1}"

    if [ "$dev_choice" == "2" ]; then
        read -rp "Enter your installed App Bundle ID (e.g. com.example.hapopay.TEAMID): " bundle_id
        builder dev flutter --skip-install --bundle-id "$bundle_id"
    else
        builder dev flutter
    fi
}

# 10. Share / Simulator
share_simulator() {
    echo -e "\n${BOLD}Building working tree for iOS Simulator and sharing via MobAI...${NC}"
    echo -e "${YELLOW}Note: Requires MOBAI_API_KEY set in your repository secrets.${NC}"
    builder ios share
}

# 11. Code Signing Setup
setup_signing() {
    echo -e "\n${BOLD}Code Signing Setup...${NC}"
    echo "1) Automatic setup for connected MobAI devices (Development)"
    echo "2) Automatic setup for App Store / TestFlight (Distribution)"
    echo "3) Upload existing .p12 and .mobileprovision files"
    read -rp "Enter choice [1-3]: " sign_choice

    case "$sign_choice" in
        1)
            builder signing setup --devices-from-mobai
            ;;
        2)
            builder signing setup --distribution store
            ;;
        3)
            read -rp "Path to .p12 certificate: " cert_path
            read -rp "Path to .mobileprovision profile: " prof_path
            builder signing setup --certificate "$cert_path" --profile "$prof_path"
            ;;
        *)
            echo -e "${RED}Invalid choice.${NC}"
            ;;
    esac
}

# Interactive Menu
show_menu() {
    print_header
    echo -e "Project: ${BOLD}HapoPay (Flutter)${NC}"
    echo -e "Directory: ${BOLD}$PROJECT_ROOT${NC}\n"
    echo "Select an action:"
    echo "  1) Full Initial Setup (Install CLI, Check Auth, Run Init)"
    echo "  2) Check Authentication Status"
    echo "  3) Authenticate with GitHub (builder auth github)"
    echo "  4) Authenticate with Apple App Store Connect (builder auth apple)"
    echo "  5) Initialize / Reconfigure Project Workflow (builder init)"
    echo "  6) Build iOS IPA (builder ios build)"
    echo "  7) Run Flutter Dev + Hot Reload on Device (builder dev flutter)"
    echo "  8) Test on iOS Simulator (builder ios share)"
    echo "  9) Setup Code Signing & Secrets (builder signing setup)"
    echo "  10) Test MobAI Connectivity (builder mobai ping)"
    echo "  11) Update Builder CLI (builder update)"
    echo "  0) Exit"
    echo ""
    read -rp "Enter choice [0-11]: " choice

    case "$choice" in
        1)
            ensure_builder_installed
            check_project
            check_auth
            init_builder
            ;;
        2)
            ensure_builder_installed
            check_auth
            ;;
        3)
            ensure_builder_installed
            auth_github
            ;;
        4)
            ensure_builder_installed
            auth_apple
            ;;
        5)
            ensure_builder_installed
            check_project
            init_builder
            ;;
        6)
            ensure_builder_installed
            build_ios
            ;;
        7)
            ensure_builder_installed
            dev_flutter
            ;;
        8)
            ensure_builder_installed
            share_simulator
            ;;
        9)
            ensure_builder_installed
            setup_signing
            ;;
        10)
            ensure_builder_installed
            echo -e "${BOLD}Checking MobAI connection...${NC}"
            builder mobai ping
            ;;
        11)
            ensure_builder_installed
            echo -e "${BOLD}Updating Builder CLI...${NC}"
            builder update
            ;;
        0)
            echo -e "Exiting. Happy coding!"
            exit 0
            ;;
        *)
            echo -e "${RED}Invalid option.${NC}"
            ;;
    esac
}

# Non-interactive CLI flags support
handle_flags() {
    case "$1" in
        --install)
            ensure_builder_installed
            ;;
        --init)
            ensure_builder_installed
            check_project
            init_builder
            ;;
        --auth)
            ensure_builder_installed
            auth_github
            ;;
        --build)
            ensure_builder_installed
            builder ios build "${@:2}"
            ;;
        --dev)
            ensure_builder_installed
            builder dev flutter "${@:2}"
            ;;
        --share)
            ensure_builder_installed
            builder ios share "${@:2}"
            ;;
        --status)
            ensure_builder_installed
            check_auth
            ;;
        --help|-h)
            print_header
            echo "Usage: ./setup_builder.sh [OPTION]"
            echo ""
            echo "Options:"
            echo "  (no arguments)   Launch interactive setup menu"
            echo "  --install        Install/verify Builder CLI"
            echo "  --init           Initialize workflows and builder.json for this Flutter project"
            echo "  --auth           Authenticate with GitHub"
            echo "  --status         Show authentication status"
            echo "  --build [flags]  Run 'builder ios build [flags]'"
            echo "  --dev [flags]    Run 'builder dev flutter [flags]'"
            echo "  --share [flags]  Run 'builder ios share [flags]'"
            echo "  --help, -h       Display this help message"
            ;;
        *)
            show_menu
            ;;
    esac
}

if [ $# -eq 0 ]; then
    show_menu
else
    handle_flags "$@"
fi
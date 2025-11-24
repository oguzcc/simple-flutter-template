#!/bin/bash

# Renk tanımlamaları
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

# Başlık yazdırma fonksiyonu
print_header() {
    echo -e "\n${PURPLE}================================${NC}"
    echo -e "${PURPLE}       BUILD RUNNER SCRIPT       ${NC}"
    echo -e "${PURPLE}================================${NC}\n"
}

# Başarı mesajı yazdırma fonksiyonu
print_success() {
    echo -e "${GREEN}✅ $1${NC}"
}

# Hata mesajı yazdırma fonksiyonu
print_error() {
    echo -e "${RED}❌ $1${NC}"
}

# Bilgi mesajı yazdırma fonksiyonu
print_info() {
    echo -e "${BLUE}ℹ️  $1${NC}"
}

# Uyarı mesajı yazdırma fonksiyonu
print_warning() {
    echo -e "${YELLOW}⚠️  $1${NC}"
}

# İşlem başlangıcı mesajı
print_process() {
    echo -e "${BLUE}🔄 $1${NC}"
}

# Temizleme işlemi
clean_build() {
    print_process "Build dosyaları temizleniyor..."
    
    # Flutter clean
    if flutter clean; then
        print_success "Flutter clean tamamlandı"
    else
        print_error "Flutter clean başarısız"
        return 1
    fi
    
    # Build runner clean
    if dart run build_runner clean; then
        print_success "Build runner clean tamamlandı"
    else
        print_error "Build runner clean başarısız"
        return 1
    fi
    
    # .dart_tool build cache'ini sil
    if [ -d ".dart_tool/build" ]; then
        rm -rf .dart_tool/build
        print_success ".dart_tool/build cache'i temizlendi"
    fi
    
    return 0
}

# Paket yükleme işlemi
install_packages() {
    print_process "Paketler yükleniyor..."
    
    if flutter pub get; then
        print_success "Paketler başarıyla yüklendi"
        return 0
    else
        print_error "Paket yükleme başarısız"
        return 1
    fi
}

# Build runner işlemi
run_build_runner() {
    local delete_conflicting=$1
    
    print_process "Build runner çalıştırılıyor..."
    
    local command="dart run build_runner build"
    
    if [ "$delete_conflicting" == "true" ]; then
        command="$command --delete-conflicting-outputs"
        print_info "Çakışan çıktılar otomatik olarak silinecek"
    fi
    
    if eval "$command"; then
        print_success "Build runner başarıyla tamamlandı"
        return 0
    else
        print_error "Build runner başarısız"
        return 1
    fi
}

# Watch modu
run_build_runner_watch() {
    print_process "Build runner watch modu başlatılıyor..."
    print_warning "Watch modu başlatıldı. Ctrl+C ile durdurun."
    
    if dart run build_runner watch --delete-conflicting-outputs; then
        print_success "Build runner watch modu tamamlandı"
        return 0
    else
        print_error "Build runner watch modu başarısız"
        return 1
    fi
}

# Freezed dosyalarını kontrol et
check_freezed_files() {
    print_process "Freezed dosyaları kontrol ediliyor..."
    
    local freezed_files=$(find lib/ -name "*.freezed.dart" 2>/dev/null | wc -l)
    
    if [ "$freezed_files" -gt 0 ]; then
        print_success "$freezed_files adet Freezed dosyası bulundu"
        return 0
    else
        print_warning "Hiç Freezed dosyası bulunamadı"
        return 1
    fi
}

# JSON serializable dosyalarını kontrol et
check_json_files() {
    print_process "JSON serializable dosyaları kontrol ediliyor..."
    
    local json_files=$(find lib/ -name "*.g.dart" 2>/dev/null | wc -l)
    
    if [ "$json_files" -gt 0 ]; then
        print_success "$json_files adet JSON dosyası bulundu"
        return 0
    else
        print_warning "Hiç JSON serializable dosyası bulunamadı"
        return 1
    fi
}

# Ana işlem fonksiyonu
main() {
    print_header
    
    # Argümanları kontrol et
    case "$1" in
        "clean")
            print_info "Sadece temizleme işlemi yapılacak"
            if clean_build; then
                print_success "Temizleme işlemi tamamlandı"
            else
                print_error "Temizleme işlemi başarısız"
                exit 1
            fi
            ;;
        "build")
            print_info "Build runner işlemi yapılacak"
            if run_build_runner "false"; then
                check_freezed_files
                check_json_files
                print_success "Build işlemi tamamlandı"
            else
                print_error "Build işlemi başarısız"
                exit 1
            fi
            ;;
        "build-force")
            print_info "Çakışan dosyalar silinerek build runner işlemi yapılacak"
            if run_build_runner "true"; then
                check_freezed_files
                check_json_files
                print_success "Build işlemi tamamlandı"
            else
                print_error "Build işlemi başarısız"
                exit 1
            fi
            ;;
        "watch")
            print_info "Build runner watch modu başlatılacak"
            run_build_runner_watch
            ;;
        "full")
            print_info "Tam temizlik ve build işlemi yapılacak"
            
            # Adım 1: Temizlik
            if ! clean_build; then
                print_error "Temizlik işlemi başarısız"
                exit 1
            fi
            
            # Adım 2: Paket yükleme
            if ! install_packages; then
                print_error "Paket yükleme başarısız"
                exit 1
            fi
            
            # Adım 3: Build runner
            if ! run_build_runner "true"; then
                print_error "Build runner işlemi başarısız"
                exit 1
            fi
            
            # Adım 4: Kontroller
            check_freezed_files
            check_json_files
            
            print_success "Tüm işlemler başarıyla tamamlandı!"
            ;;
        "check")
            print_info "Generate edilmiş dosyalar kontrol ediliyor"
            check_freezed_files
            check_json_files
            ;;
        *)
            echo -e "${BLUE}Build Runner Yardımcı Script'i${NC}"
            echo -e "${BLUE}================================${NC}"
            echo ""
            echo -e "${YELLOW}Kullanım:${NC}"
            echo -e "  ./script/build_runner.sh ${GREEN}<komut>${NC}"
            echo ""
            echo -e "${YELLOW}Komutlar:${NC}"
            echo -e "  ${GREEN}clean${NC}       - Sadece build dosyalarını temizle"
            echo -e "  ${GREEN}build${NC}       - Build runner çalıştır"
            echo -e "  ${GREEN}build-force${NC} - Çakışan dosyaları sil ve build runner çalıştır"
            echo -e "  ${GREEN}watch${NC}       - Build runner watch modu (sürekli dinleme)"
            echo -e "  ${GREEN}full${NC}        - Tam temizlik + paket yükleme + build runner"
            echo -e "  ${GREEN}check${NC}       - Generate edilmiş dosyaları kontrol et"
            echo ""
            echo -e "${YELLOW}Örnekler:${NC}"
            echo -e "  ./script/build_runner.sh full       ${BLUE}# Tam işlem${NC}"
            echo -e "  ./script/build_runner.sh build-force ${BLUE}# Zorla build${NC}"
            echo -e "  ./script/build_runner.sh watch      ${BLUE}# İzleme modu${NC}"
            echo ""
            ;;
    esac
}

# Script'i çalıştır
main "$@"
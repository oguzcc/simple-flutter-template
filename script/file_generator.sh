#!/bin/bash

# Renk tanımlamaları
GREEN='\033[0;32m'
RED='\033[0;31m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Çıktı dosyalarının prefix'ini ve zip dosyasının adını belirle
output_prefix="output_part"
zip_file="output_files.zip"
single_output_file="combined_output.txt"

# Tüm desteklenen uzantılar
extensions=(".dart" ".java" ".kt" ".swift")

# Geçici dosya oluştur
temp_file=$(mktemp)

# dialog'un yüklü olup olmadığını kontrol et
if ! command -v dialog &> /dev/null
then
    echo "dialog yüklü değil. Lütfen yükleyin ve tekrar deneyin."
    exit 1
fi

# Dosya işleme fonksiyonu
process_files() {
    local file_selection_choice=$1
    local file_name_pattern=$2
    local selected_extensions=("${@:3}")

    # Tüm dosyaları bul
    all_files=()
    for ext in "${selected_extensions[@]}"; do
        if [ "$file_selection_choice" == "2" ]; then
            files=$(find . -type f -name "*${file_name_pattern}*$ext")
        else
            files=$(find . -type f -name "*$ext")
        fi
        while IFS= read -r file; do
            if [ -n "$file" ]; then
                all_files+=("$file")
            fi
        done <<< "$files"
    done

    # Kullanıcıya tüm dosyaları seçme veya manuel seçim yapma seçeneği sun
    selection_method=$(dialog --title "Dosya Seçim Yöntemi" --menu "Nasıl dosya seçmek istersiniz?" 15 50 2 \
        1 "Tüm dosyaları seç" \
        2 "Manuel seçim yap" 2>&1 >/dev/tty)

    case $selection_method in
        1)
            # Tüm dosyaları işle
            for file in "${all_files[@]}"; do
                echo -e "${BLUE}    •${NC} İşleniyor: $(basename "$file")"
                
                # Dosya adını ekle
                echo "$(basename "$file")" >> "$temp_file"
                
                # Dosya içeriğini ekle
                cat "$file" >> "$temp_file"
                
                # Ayırıcı ekle
                filename=$(basename "$file")
                separator_length=80
                filename_length=${#filename}
                left_padding=$(( (separator_length - filename_length) / 2 ))
                right_padding=$(( separator_length - filename_length - left_padding ))
                
                printf "\n%${left_padding}s%s%${right_padding}s\n" | tr ' ' '-' >> "$temp_file"
                printf "%${left_padding}s%s%${right_padding}s\n" | tr ' ' '-' | sed "s/^.\{$left_padding\}/$filename/" >> "$temp_file"
                printf "%${left_padding}s%s%${right_padding}s\n\n" | tr ' ' '-' >> "$temp_file"
            done
            ;;
        2)
            # Manuel seçim için dosya listesi oluştur
            file_options=()
            for i in "${!all_files[@]}"; do
                file_options+=("$i" "$(basename "${all_files[$i]}")")
            done

            # Dosyaları göster ve seçim yaptır
            selected_indices=$(dialog --title "Dosya Seçimi" --checklist "İşlemek istediğiniz dosyaları seçin:" 20 80 15 "${file_options[@]}" 2>&1 >/dev/tty)

            # Seçilen dosyaları işle
            for index in $selected_indices; do
                file="${all_files[$index]}"
                echo -e "${BLUE}    •${NC} İşleniyor: $(basename "$file")"
                
                # Dosya adını ekle
                echo "$(basename "$file")" >> "$temp_file"
                
                # Dosya içeriğini ekle
                cat "$file" >> "$temp_file"
                
                # Ayırıcı ekle
                filename=$(basename "$file")
                separator_length=80
                filename_length=${#filename}
                left_padding=$(( (separator_length - filename_length) / 2 ))
                right_padding=$(( separator_length - filename_length - left_padding ))
                
                printf "\n%${left_padding}s%s%${right_padding}s\n" | tr ' ' '-' >> "$temp_file"
                printf "%${left_padding}s%s%${right_padding}s\n" | tr ' ' '-' | sed "s/^.\{$left_padding\}/$filename/" >> "$temp_file"
                printf "%${left_padding}s%s%${right_padding}s\n\n" | tr ' ' '-' >> "$temp_file"
            done
            ;;
    esac
}

# Klasör yapısını çıkartma fonksiyonu
generate_tree() {
    local dir="$1"
    local prefix="$2"
    local files=()
    local dirs=()

    # Dosya ve dizinleri ayırıp sırala
    for item in "$dir"/*; do
        if [ -d "$item" ]; then
            dirs+=("$item")
        else
            files+=("$item")
        fi
    done

    # Dosyaları işle
    for file in "${files[@]}"; do
        local name=$(basename "$file")
        echo "${prefix}├── $name"
    done

    # Dizinleri işle
    local last_index=$((${#dirs[@]} - 1))
    for index in "${!dirs[@]}"; do
        local dir_name=$(basename "${dirs[$index]}")
        if [ $index -eq $last_index ]; then
            echo "${prefix}└── $dir_name/"
            generate_tree "${dirs[$index]}" "$prefix    "
        else
            echo "${prefix}├── $dir_name/"
            generate_tree "${dirs[$index]}" "$prefix│   "
        fi
    done
}

# Klasör yapısını çıkartma fonksiyonu
extract_folder_structure() {
    # Mevcut dizindeki klasörleri listele
    local dirs=$(ls -d */ 2>/dev/null)
    
    # Kullanıcıya klasör seçtir
    local selected_dir=$(dialog --title "Klasör Seçimi" --menu "Hangi klasör için ağaç yapısı oluşturmak istersiniz?" 15 50 10 $(echo "$dirs" | awk '{print NR, $0}') 2>&1 >/dev/tty)
    
    if [ -z "$selected_dir" ]; then
        dialog --msgbox "Klasör seçilmedi. İşlem iptal edildi." 8 40
        return
    fi

    selected_dir=$(echo "$dirs" | sed -n "${selected_dir}p")

    # Seçilen klasörün varlığını kontrol et
    if [ ! -d "$selected_dir" ]; then
        dialog --msgbox "Hata: '$selected_dir' klasörü bulunamadı." 8 40
        return
    fi

    # Sonucu bir dosyaya yaz
    local output_file="${selected_dir%/}_structure.txt"

    # Seçilen klasörü ekle
    echo "$selected_dir" > "$output_file"

    # Ağaç yapısını oluştur ve dosyaya ekle
    generate_tree "$selected_dir" "│" >> "$output_file"

    dialog --msgbox "Klasör yapısı '$output_file' dosyasına kaydedildi." 8 50
}

# Ana menü
while true; do
    choice=$(dialog --title "Ana Menü" --menu "Hangi işlemi yapmak istiyorsunuz?" 15 50 2 \
        1 "Klasör yapısını çıkart" \
        2 "File Generator" 2>&1 >/dev/tty)

    case $choice in
        1)
            extract_folder_structure
            ;;
        2)
            # File Generator işlevi
            while true; do
                # Kullanıcıya dosya seçim yöntemini sor
                file_selection_choice=$(dialog --title "Dosya Seçim Yöntemi" --menu "Hangi dosyaları işlemek istiyorsunuz?" 15 50 2 \
                    1 "Tüm dosyalar" \
                    2 "Belirli bir isme sahip dosyalar" 2>&1 >/dev/tty)

                if [ "$file_selection_choice" == "2" ]; then
                    file_name_pattern=$(dialog --title "Dosya İsmi Girişi" --inputbox "Aramak istediğiniz dosya ismini girin:" 8 40 2>&1 >/dev/tty)
                fi

                # Kullanıcıya dosya türü seçeneklerini göster
                choice=$(dialog --title "Dosya Türü Seçimi" --menu "Hangi tür dosyaları işlemek istiyorsunuz?" 15 50 6 \
                    1 "Dart (.dart)" \
                    2 "Java (.java)" \
                    3 "Kotlin (.kt)" \
                    4 "Swift (.swift)" \
                    5 "Tümü" \
                    6 "Özel uzantı" 2>&1 >/dev/tty)

                # Seçime göre uzantıyı belirle
                case $choice in
                    1) selected_extensions=(".dart") ;;
                    2) selected_extensions=(".java") ;;
                    3) selected_extensions=(".kt") ;;
                    4) selected_extensions=(".swift") ;;
                    5) selected_extensions=("${extensions[@]}") ;;
                    6) 
                        custom_extension=$(dialog --title "Özel Uzantı" --inputbox "Özel uzantıyı girin (örn: .py):" 8 40 2>&1 >/dev/tty)
                        selected_extensions=("$custom_extension") ;;
                    *) dialog --msgbox "Geçersiz seçim. Tekrar deneyin." 8 40; continue ;;
                esac

                # Dosya işleme işlemini çağır
                process_files "$file_selection_choice" "$file_name_pattern" "${selected_extensions[@]}"

                # Kullanıcıya başka dosya eklemek isteyip istemediğini sor
                if dialog --title "Devam Et" --yesno "Başka dosya eklemek istiyor musunuz?" 8 40; then
                    continue
                else
                    break
                fi
            done

            # Toplam satır sayısını al
            total_lines=$(wc -l < "$temp_file")

            # Kullanıcıya dosyaların parçalanıp parçalanmayacağını sor
            if dialog --title "Dosya Parçalama" --yesno "Dosyaları parçalamak istiyor musunuz?" 8 40; then
                # Kullanıcıya kaç parçaya bölmek istediğini sor
                num_parts=$(dialog --title "Parça Sayısı" --inputbox "Kaç parçaya bölmek istiyorsunuz? (Boş bırakırsanız varsayılan olarak 20 parça kullanılacak):" 8 60 2>&1 >/dev/tty)

                # Eğer kullanıcı bir değer girmezse veya geçersiz bir değer girerse varsayılan değeri kullan
                if ! [[ "$num_parts" =~ ^[0-9]+$ ]] ; then
                    num_parts=20
                fi

                # Her parçadaki satır sayısını hesapla
                lines_per_part=$((total_lines / num_parts))
                if [ $lines_per_part -eq 0 ]; then
                    lines_per_part=1
                fi

                # Dosyayı parçalara böl
                split -l $lines_per_part "$temp_file" "${output_prefix}_"

                # Çıktı dosyalarını zip'le
                zip -q "$zip_file" ${output_prefix}_*

                # Geçici dosyaları temizle
                rm ${output_prefix}_*

                dialog --msgbox "İşlem tamamlandı. Çıktı dosyaları '$zip_file' içinde bulunabilir." 8 60
            else
                # Dosyayı parçalamadan tek bir .txt dosyası olarak kaydet
                mv "$temp_file" "$single_output_file"
                dialog --msgbox "Dosya tek parça olarak '$single_output_file' adıyla kaydedildi." 8 60
            fi

            # Geçici dosyayı temizle (eğer hala varsa)
            [ -f "$temp_file" ] && rm "$temp_file"

            dialog --msgbox "İşlem tamamlandı." 8 40
            ;;
        *)
            break
            ;;
    esac
done
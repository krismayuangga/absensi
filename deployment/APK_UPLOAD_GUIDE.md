# 🚀 Setup APK Download di cPanel Domainesia

## 📁 **File Yang Perlu Diupload:**

### 1. **APK File**
```
Source: mobile/build/app/outputs/flutter-apk/app-release.apk
Target: public_html/downloads/oz3-kpi.apk
```

### 2. **Download Handler**
```
Source: deployment/download.php  
Target: public_html/download.php
```

### 3. **Updated Landing Page**
```
Source: deployment/welcome_custom.blade.php
Target: public_html/laravel/resources/views/welcome.blade.php
```

## 📋 **Langkah Setup di cPanel:**

### **Step 1: Create Downloads Folder**
1. Login cPanel Domainesia
2. Buka **File Manager**
3. Masuk ke `public_html`
4. **Create New Folder** → nama: `downloads`
5. Set permissions folder `downloads` ke **755**

### **Step 2: Upload APK File**
1. Masuk ke folder `public_html/downloads/`
2. **Upload File** → pilih `app-release.apk` dari komputer
3. **Rename** file menjadi `oz3-kpi.apk`
4. Set permissions file ke **644**

### **Step 3: Upload Download Handler**
1. Masuk ke `public_html/` (root)
2. **Upload File** → pilih `download.php`
3. Set permissions ke **644**

### **Step 4: Update Landing Page**
1. Masuk ke `public_html/laravel/resources/views/`
2. **Backup** file `welcome.blade.php` yang ada
3. **Upload** file `welcome_custom.blade.php` yang baru
4. **Rename** menjadi `welcome.blade.php`

## ✅ **Hasil Akhir:**

### **Struktur File:**
```
public_html/
├── download.php                     ← APK download handler
├── downloads/
│   ├── oz3-kpi.apk                 ← APK file (29MB)
│   └── download_log.txt            ← Auto-created download log
└── laravel/
    └── resources/views/
        └── welcome.blade.php       ← Updated landing page
```

### **Fungsi Website:**
- ✅ **Landing page** dengan tombol download
- ✅ **Direct APK download** saat klik tombol Android
- ✅ **Download tracking** dengan log file
- ✅ **User-friendly** dengan konfirmasi dan instruksi
- ✅ **Professional** dengan progress dan feedback

## 🔒 **Security Notes:**

1. **File APK** aman untuk public download
2. **Download log** untuk monitoring penggunaan
3. **File permissions** sudah sesuai standar
4. **No direct file listing** di folder downloads

## 📱 **User Experience:**

1. User klik **"Download for Android"**
2. Popup konfirmasi dengan info file size
3. **Direct download** dimulai otomatis
4. **Success message** dengan instruksi install
5. **Log entry** tercatat untuk admin

---

**Setelah setup ini, karyawan dapat langsung download APK OZ3 KPI dari website perusahaan!** 🎉
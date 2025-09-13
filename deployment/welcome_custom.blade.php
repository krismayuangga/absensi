<!DOCTYPE html>
<html lang="en">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>OZ3 KPI - Attendance Management System</title>
    <link rel="icon" type="image/png" href="/assets/favicon.png">
    <link rel="apple-touch-icon" href="/assets/ozonelogo.png">
    <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
    <link href="https://cdnjs.cloudflare.com/ajax/libs/font-awesome/6.0.0/css/all.min.css" rel="stylesheet">
    <style>
        .dark-gradient {
            background: linear-gradient(135deg, #0f0f23 0%, #1a1a2e 25%, #16213e 50%, #0f3460  75%, #533483 100%);
        }
        .card-glass {
            background: rgba(255, 255, 255, 0.05);
            backdrop-filter: blur(20px);
            border: 1px solid rgba(255, 255, 255, 0.1);
            transition: all 0.3s ease;
        }
        .card-glass:hover {
            background: rgba(255, 255, 255, 0.08);
            transform: translateY(-2px);
        }
        .btn-download {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            transition: all 0.3s ease;
            box-shadow: 0 10px 25px rgba(102, 126, 234, 0.3);
        }
        .btn-download:hover {
            background: linear-gradient(135deg, #5a67d8 0%, #6b46c1 100%);
            transform: translateY(-3px);
            box-shadow: 0 15px 35px rgba(102, 126, 234, 0.4);
        }
        .status-indicator {
            animation: pulse 2s infinite;
        }
        
        /* Modal Styles */
        .modal-overlay {
            position: fixed;
            top: 0;
            left: 0;
            right: 0;
            bottom: 0;
            background: rgba(0, 0, 0, 0.7);
            backdrop-filter: blur(10px);
            z-index: 9999;
            opacity: 0;
            visibility: hidden;
            transition: all 0.3s ease;
        }
        
        .modal-overlay.active {
            opacity: 1;
            visibility: visible;
        }
        
        .modal-content {
            position: absolute;
            top: 50%;
            left: 50%;
            transform: translate(-50%, -50%) scale(0.8);
            background: linear-gradient(135deg, #1a1a2e 0%, #16213e 100%);
            border-radius: 20px;
            border: 1px solid rgba(255, 255, 255, 0.1);
            max-width: 90vw;
            width: 400px;
            padding: 0;
            box-shadow: 0 25px 50px rgba(0, 0, 0, 0.5);
            transition: all 0.3s ease;
        }
        
        .modal-overlay.active .modal-content {
            transform: translate(-50%, -50%) scale(1);
        }
        
        .logo-container {
            background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
            border-radius: 20px;
        }
        
        @media (max-width: 480px) {
            .modal-content {
                width: 95vw;
                margin: 10px;
            }
        }
    </style>
</head>
<body class="dark-gradient min-h-screen text-white overflow-x-hidden">
    <!-- Navigation -->
    <nav class="card-glass sticky top-0 z-50">
        <div class="max-w-4xl mx-auto px-6 py-4">
            <div class="flex justify-between items-center">
                <div class="flex items-center space-x-3">
                    <div class="logo-container p-2 rounded-lg">
                        <img src="/assets/ozonelogo.png" alt="OZ3 KPI Logo" class="w-8 h-8" onerror="this.style.display='none'; this.nextElementSibling.style.display='block';">
                        <i class="fas fa-mobile-alt text-xl text-white" style="display: none;"></i>
                    </div>
                    <span class="text-white font-bold text-lg">OZ3 KPI</span>
                </div>
                <div id="system-status" class="flex items-center space-x-2">
                    <div class="status-indicator w-2 h-2 bg-green-400 rounded-full"></div>
                    <span class="text-gray-300 text-sm font-medium">Online</span>
                </div>
            </div>
        </div>
    </nav>

    <!-- Hero Section -->
    <section class="flex items-center justify-center min-h-[80vh] px-6">
        <div class="max-w-4xl mx-auto text-center">
            <!-- App Icon -->
            <div class="mb-8">
                <div class="inline-flex items-center justify-center w-24 h-24 logo-container rounded-3xl mb-6 shadow-2xl p-4">
                    <img src="/assets/ozonelogo.png" alt="OZ3 KPI Logo" class="w-full h-full object-contain" onerror="this.style.display='none'; this.nextElementSibling.style.display='block';">
                    <i class="fas fa-mobile-alt text-4xl text-white" style="display: none;"></i>
                </div>
            </div>

            <!-- Title -->
            <h1 class="text-4xl md:text-6xl font-bold text-white mb-4">
                OZ3 KPI
            </h1>
            <p class="text-lg text-gray-300 mb-2 font-medium">
                Attendance Management System
            </p>
            
            <!-- Company Names -->
            <div class="mb-8 space-y-1">
                <p class="text-sm text-blue-300 font-medium">PT KINERJA PAY INDONESIA</p>
                <p class="text-sm text-purple-300 font-medium">PT OZONE MINERAL INDONESIA</p>
            </div>

            <p class="text-gray-400 mb-12 max-w-2xl mx-auto leading-relaxed">
                Internal application for employee attendance management with GPS tracking and face recognition technology
            </p>

            <!-- Download Button -->
            <div class="flex justify-center mb-8">
                <button onclick="downloadAndroid()" class="btn-download px-10 py-4 rounded-2xl text-white font-semibold flex items-center space-x-4">
                    <i class="fab fa-android text-3xl"></i>
                    <div class="text-left">
                        <div class="text-xs opacity-80">Download App</div>
                        <div class="text-xl font-bold">Android APK</div>
                    </div>
                </button>
            </div>
        </div>
    </section>



    <!-- System Status Section -->
    <section class="py-16 px-6">
        <div class="max-w-4xl mx-auto">
            <div class="text-center mb-12">
                <h2 class="text-2xl font-bold text-white mb-2">System Status</h2>
                <p class="text-gray-400 text-sm">Real-time monitoring</p>
            </div>

            <div class="grid md:grid-cols-3 gap-6">
                <div class="card-glass rounded-2xl p-6 text-center">
                    <i class="fas fa-server text-3xl text-emerald-400 mb-4"></i>
                    <h3 class="text-white font-medium mb-2 text-sm">Backend API</h3>
                    <div id="api-status" class="text-emerald-400 font-semibold text-sm">
                        <i class="fas fa-spinner fa-spin"></i> Checking...
                    </div>
                </div>

                <div class="card-glass rounded-2xl p-6 text-center">
                    <i class="fas fa-database text-3xl text-blue-400 mb-4"></i>
                    <h3 class="text-white font-medium mb-2 text-sm">Database</h3>
                    <div id="db-status" class="text-blue-400 font-semibold text-sm">
                        <i class="fas fa-spinner fa-spin"></i> Checking...
                    </div>
                </div>

                <div class="card-glass rounded-2xl p-6 text-center">
                    <i class="fas fa-mobile-alt text-3xl text-purple-400 mb-4"></i>
                    <h3 class="text-white font-medium mb-2 text-sm">Mobile App</h3>
                    <div class="text-emerald-400 font-semibold text-sm">
                        <i class="fas fa-check-circle"></i> Ready
                    </div>
                </div>
            </div>
        </div>
    </section>



    <!-- Download Modal -->
    <div id="downloadModal" class="modal-overlay">
        <div class="modal-content">
            <!-- Modal Header -->
            <div class="logo-container p-6 text-center relative">
                <button onclick="closeModal()" class="absolute top-4 right-4 text-white/80 hover:text-white text-2xl">
                    <i class="fas fa-times"></i>
                </button>
                <div class="w-20 h-20 mx-auto mb-4 bg-white/10 rounded-2xl flex items-center justify-center">
                    <img src="/assets/logo-128.png" alt="OZ3 KPI Logo" class="w-16 h-16 object-contain" onerror="this.style.display='none'; this.nextElementSibling.style.display='block';">
                    <i class="fab fa-android text-4xl text-white" style="display: none;"></i>
                </div>
                <h3 class="text-2xl font-bold text-white mb-2">Download OZ3 KPI</h3>
                <p class="text-white/80 text-sm">Aplikasi Attendance Management</p>
            </div>
            
            <!-- Modal Body -->
            <div class="p-6 pt-0">
                <div class="bg-white/5 rounded-xl p-4 mb-6">
                    <div class="grid grid-cols-2 gap-4 text-sm">
                        <div class="text-center">
                            <div class="text-gray-400">File Size</div>
                            <div class="text-white font-semibold">~29MB</div>
                        </div>
                        <div class="text-center">
                            <div class="text-gray-400">Version</div>
                            <div class="text-white font-semibold">1.0.0</div>
                        </div>
                    </div>
                </div>
                
                <div class="space-y-3 mb-6 text-sm text-gray-300">
                    <div class="flex items-center space-x-3">
                        <i class="fas fa-check-circle text-green-400"></i>
                        <span>GPS Attendance Tracking</span>
                    </div>
                    <div class="flex items-center space-x-3">
                        <i class="fas fa-check-circle text-green-400"></i>
                        <span>Face Recognition Technology</span>
                    </div>
                    <div class="flex items-center space-x-3">
                        <i class="fas fa-check-circle text-green-400"></i>
                        <span>Real-time Dashboard</span>
                    </div>
                </div>
                
                <div class="space-y-3">
                    <button onclick="startDownload()" class="w-full bg-gradient-to-r from-green-500 to-emerald-600 hover:from-green-600 hover:to-emerald-700 text-white font-semibold py-4 px-6 rounded-xl flex items-center justify-center space-x-3 transition-all transform hover:scale-105">
                        <i class="fab fa-android text-xl"></i>
                        <span>Download APK</span>
                    </button>
                    
                    <button onclick="closeModal()" class="w-full bg-gray-600 hover:bg-gray-700 text-white font-medium py-3 px-6 rounded-xl transition-all">
                        Cancel
                    </button>
                </div>
            </div>
        </div>
    </div>

    <!-- Footer -->
    <footer class="py-8 px-6 border-t border-white/10">
        <div class="max-w-4xl mx-auto text-center">
            <p class="text-gray-400 text-sm mb-2">Ozone - Kinerja Labs © 2025 | All Rights Reserved</p>
            <p class="text-gray-500 text-xs">Version 1.0.0</p>
        </div>
    </footer>

    <script>
        // Check API Health
        function checkSystemStatus() {
            // API Health Check
            fetch('/api/health')
                .then(response => response.json())
                .then(data => {
                    document.getElementById('api-status').innerHTML = 
                        '<i class="fas fa-check-circle"></i> Online';
                    document.getElementById('api-status').className = 'text-green-400 font-bold';
                })
                .catch(error => {
                    document.getElementById('api-status').innerHTML = 
                        '<i class="fas fa-exclamation-triangle"></i> Error';
                    document.getElementById('api-status').className = 'text-red-400 font-bold';
                });

            // Database Check
            fetch('/api/admin-roles')
                .then(response => response.json())
                .then(data => {
                    if (data.success) {
                        document.getElementById('db-status').innerHTML = 
                            '<i class="fas fa-check-circle"></i> Connected';
                        document.getElementById('db-status').className = 'text-green-400 font-bold';
                    } else {
                        throw new Error('Database not connected');
                    }
                })
                .catch(error => {
                    document.getElementById('db-status').innerHTML = 
                        '<i class="fas fa-exclamation-triangle"></i> Disconnected';
                    document.getElementById('db-status').className = 'text-red-400 font-bold';
                });
        }

        // Modal Functions
        function downloadAndroid() {
            document.getElementById('downloadModal').classList.add('active');
            document.body.style.overflow = 'hidden'; // Prevent background scroll
        }
        
        function closeModal() {
            document.getElementById('downloadModal').classList.remove('active');
            document.body.style.overflow = 'auto'; // Restore scroll
        }
        
        function startDownload() {
            // Create temporary link and trigger download
            const link = document.createElement('a');
            link.href = '/download.php';
            link.download = 'OZ3-KPI-v1.0.0.apk';
            document.body.appendChild(link);
            link.click();
            document.body.removeChild(link);
            
            // Close modal and show success message
            closeModal();
            
            // Show professional success notification
            setTimeout(() => {
                showNotification('✅ Download Started!', 'Setelah download selesai, buka file APK dan install aplikasi. Login dengan akun perusahaan Anda.', 'success');
            }, 500);
            
            // Optional: Track download
            if (typeof gtag !== 'undefined') {
                gtag('event', 'apk_download', {
                    'platform': 'android',
                    'version': '1.0.0',
                    'source': 'landing_page'
                });
            }
        }
        
        // Notification Function
        function showNotification(title, message, type = 'info') {
            // Create notification element
            const notification = document.createElement('div');
            notification.className = `fixed top-4 right-4 z-50 max-w-sm p-4 rounded-xl shadow-2xl transform translate-x-full transition-all duration-300 ${
                type === 'success' ? 'bg-green-600' : 'bg-blue-600'
            }`;
            
            notification.innerHTML = `
                <div class="flex items-start space-x-3">
                    <div class="flex-shrink-0 mt-1">
                        <i class="fas ${type === 'success' ? 'fa-check-circle' : 'fa-info-circle'} text-white"></i>
                    </div>
                    <div class="flex-1">
                        <h4 class="text-white font-semibold text-sm">${title}</h4>
                        <p class="text-white/90 text-xs mt-1 leading-relaxed">${message}</p>
                    </div>
                    <button onclick="this.parentElement.parentElement.remove()" class="text-white/70 hover:text-white">
                        <i class="fas fa-times text-sm"></i>
                    </button>
                </div>
            `;
            
            document.body.appendChild(notification);
            
            // Show notification
            setTimeout(() => {
                notification.classList.remove('translate-x-full');
            }, 100);
            
            // Auto hide after 5 seconds
            setTimeout(() => {
                if (notification.parentElement) {
                    notification.classList.add('translate-x-full');
                    setTimeout(() => {
                        if (notification.parentElement) {
                            notification.remove();
                        }
                    }, 300);
                }
            }, 5000);
        }
        
        // Close modal when clicking outside
        document.addEventListener('click', function(e) {
            const modal = document.getElementById('downloadModal');
            if (e.target === modal) {
                closeModal();
            }
        });
        
        // Close modal with Escape key
        document.addEventListener('keydown', function(e) {
            if (e.key === 'Escape') {
                closeModal();
            }
        });



        // Initialize
        document.addEventListener('DOMContentLoaded', function() {
            checkSystemStatus();
            
            // Recheck status every 30 seconds
            setInterval(checkSystemStatus, 30000);
        });
    </script>
</body>
</html>
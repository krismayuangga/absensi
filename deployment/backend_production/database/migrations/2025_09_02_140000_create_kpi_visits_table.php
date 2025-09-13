<?php

use Illuminate\Database\Migrations\Migration;
use Illuminate\Database\Schema\Blueprint;
use Illuminate\Support\Facades\Schema;

return new class extends Migration
{
    /**
     * Run the migrations.
     */
    public function up(): void
    {
        Schema::create('kpi_visits', function (Blueprint $table) {
            $table->id();
            $table->foreignId('user_id')->constrained()->onDelete('cascade');
            $table->string('client_name'); // Nama klien/prospek
            $table->enum('visit_purpose', ['prospecting', 'follow_up', 'closing']); // Tujuan kunjungan
            $table->decimal('latitude', 10, 8); // GPS lokasi
            $table->decimal('longitude', 11, 8);
            $table->string('address')->nullable(); // Alamat lengkap
            $table->datetime('start_time'); // Waktu mulai
            $table->datetime('end_time')->nullable(); // Waktu selesai
            $table->text('notes')->nullable(); // Catatan singkat
            $table->string('photo_path')->nullable(); // Foto lokasi
            
            // Result tracking
            $table->enum('status', ['pending', 'success', 'failed'])->default('pending');
            $table->decimal('potential_value', 15, 2)->nullable(); // Nilai potensi investasi
            $table->date('next_follow_up')->nullable(); // Tanggal follow-up berikutnya
            $table->text('next_action')->nullable(); // Aksi selanjutnya
            $table->integer('probability_score')->nullable(); // Skor probabilitas 1-100
            $table->datetime('result_updated_at')->nullable(); // Waktu update hasil
            
            $table->timestamps();
            
            $table->index(['user_id', 'created_at']);
            $table->index(['status', 'created_at']);
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::dropIfExists('kpi_visits');
    }
};

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
        Schema::table('attendances', function (Blueprint $table) {
            $table->enum('work_type', ['office', 'field_work', 'meeting', 'survey', 'client_visit'])->default('office')->after('status');
            $table->text('activity_description')->nullable()->after('work_type');
            $table->string('client_name')->nullable()->after('activity_description');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('attendances', function (Blueprint $table) {
            $table->dropColumn(['work_type', 'activity_description', 'client_name']);
        });
    }
};

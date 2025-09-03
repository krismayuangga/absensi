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
        Schema::table('users', function (Blueprint $table) {
            $table->string('employee_id')->nullable()->after('id');
            $table->string('phone')->nullable()->after('email');
            $table->date('birth_date')->nullable()->after('phone');
            $table->string('position')->nullable()->after('birth_date');
            $table->string('department')->nullable()->after('position');
            $table->date('join_date')->nullable()->after('department');
            $table->string('profile_picture')->nullable()->after('join_date');
            $table->string('role')->default('employee')->after('profile_picture');
            $table->text('address')->nullable()->after('role');
            $table->enum('gender', ['male', 'female'])->nullable()->after('address');
            $table->boolean('is_active')->default(true)->after('gender');
            $table->timestamp('last_login')->nullable()->after('is_active');
        });
    }

    /**
     * Reverse the migrations.
     */
    public function down(): void
    {
        Schema::table('users', function (Blueprint $table) {
            $table->dropColumn([
                'employee_id',
                'phone',
                'birth_date',
                'position',
                'department',
                'join_date',
                'profile_picture',
                'role',
                'address',
                'gender',
                'is_active',
                'last_login'
            ]);
        });
    }
};

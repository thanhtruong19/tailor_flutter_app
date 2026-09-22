<?php

namespace App\Models;

// use Illuminate\Contracts\Auth\MustVerifyEmail;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Foundation\Auth\User as Authenticatable;
use Illuminate\Notifications\Notifiable;
use Laravel\Sanctum\HasApiTokens;

#[Fillable(['name', 'email', 'password'])]
#[Hidden(['password', 'remember_token'])]
class User extends Authenticatable
{
    /** @use HasFactory<UserFactory> */
    use HasApiTokens, //Cho phép tạo token đăng nhập
        HasFactory, //Cho phép tạo dữ liệu giả để phát triển và kiểm thử:
        Notifiable; //Cho phép user nhận thông báo từ Laravel

    const UPDATED_AT = null; //báo Laravel đừng cố cập nhật cột updated_at vì user đang không có

    protected $fillable = [
        'username',
        'email',
        'password_hash',
        'role',
        'last_login_at',
    ];
    //Danh sách những cột Laravel được phép thêm hoặc cập nhật hàng loạt.

    protected $hidden = [
        'password_hash',
    ];
    //Không cho password_hash xuất hiện trong JSON trả về Flutter.

    //chuyển dữ liệu thời gian trong MySQL thành đối tượng ngày giờ của PHP
    protected function casts(): array
    {
        return [
            'created_at' => 'datetime',
            'last_login_at' => 'datetime', 
        ];
    }
}

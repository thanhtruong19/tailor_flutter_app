<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use App\Models\User;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class AuthController extends Controller
{
    public function login(Request $request)
    {
        $validatedData = $request->validate([
            'email' => ['required', 'email'], //bắt buộc gửi định dạng email , gửi text bình thường cũng là fail rồi
            'password' => ['required'], //bắt buộc gửi password
        ]);

        $user = User::where(
            'email',
            $validatedData['email']
        )->first();

        if (
            !$user ||
            !Hash::check(
                $validatedData['password'],
                $user->password_hash
            )
        ) {
            return response()->json([
                'success' => false,
                'message' => 'Email hoặc mật khẩu không đúng',
            ], 401);
        }

        $user->last_login_at = now();
        $user->save();

        $token = $user->createToken('flutter-app')->plainTextToken; // mặc định create vào bảng access Token

        return response()->json([
            'success' => true,
            'message' => 'Đăng nhập thành công',
            'user' => $user,
            'token' => $token,
        ]);
    }
}

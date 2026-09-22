<?php

use App\Http\Controllers\Api\AuthController;
use Illuminate\Support\Facades\Route;
use App\Http\Controllers\Api\ProductController;

Route::post('/login', [AuthController::class, 'login']);
Route::post('/products', [ProductController::class, 'store']) -> middleware('auth:sanctum'); //auth:sanctum kiểm tra token.
Route::get('/products', [ProductController::class, 'getItemCloth']) -> middleware('auth:sanctum'); //auth:sanctum kiểm tra token.
Route::put('/products/{id}', [ProductController::class, 'updateItemCloth']) -> middleware('auth:sanctum');
Route::delete('/products/{id}', [ProductController::class, 'deleteItemCloth']) -> middleware('auth:sanctum'); //auth:sanctum kiểm tra token, sau khi request đi qua sanctum, đối tượng user được xác định và lưu vào request.

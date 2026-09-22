<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use App\Models\Product;
use Cloudinary\Cloudinary;

class ProductController extends Controller
{
    public function getItemCloth(Request $request)
    {
        if ($request->user()->role !== 'admin') {
            return response()->json([
                'message' => 'Bạn không có quyền xem sản phẩm',
            ], 403);
        }
        
        $product = Product::all();

        return response()->json([
            'products' => $product,
        ]);
    }

    public function deleteItemCloth(Request $request, int $id)
    {
        if ($request->user()->role !== 'admin') {
            return response()->json([
                'message' => 'Bạn không có quyền xóa sản phẩm',
            ], 403);
        }
        
        $product = Product::findOrFail($id);
        $product -> delete(); //phải có 1 đối tượng cụ thể được gọi ra mới dùng được delete

        return response()->json([
            'message' => 'Đã xóa sản phẩm',
        ]);
    }

    public function updateItemCloth(Request $request, int $id)
    {
        if ($request->user()->role !== 'admin') {
            return response()->json([
                'message' => 'Bạn không có quyền update sản phẩm',
            ], 403);
        }

        $product = Product::findOrFail($id);

        $data = $request->validate([
            'name' => ['sometimes', 'required', 'string', 'max:255'], //sometimes: chỉ kiểm tra nếu trường đó được gửi lên.
            'price' => ['sometimes', 'required', 'numeric', 'min:0'],
            'description' => ['sometimes', 'nullable', 'string'],
        ]);

        $cloudinary = new Cloudinary(
            config('cloudinary.url')
        );

        $uploadedImage = $cloudinary->uploadApi()->upload( 
            $request->file('cover_image')->getRealPath(), //lấy đường dẫn file tạm trên máy chạy laravel
            ['folder' => 'tailor_shop/products']
        );

        $data['cover_image_url'] = $uploadedImage['secure_url'];
        $data['cover_image_public_id'] = $uploadedImage['public_id'];
        
        $product->update($data); //Gán các giá trị trong $data vào sản phẩm vừa tìm được và lưu thay đổi xuống DB

        return response()->json([
            'message' => 'Cập nhật sản phẩm thành công',
            'product' => $product,
        ]);
    }

    public function store(Request $request)
    {
        if ($request->user()->role !== 'admin') {
            return response()->json([
                'message' => 'Bạn không có quyền thêm sản phẩm',
            ], 403);
        }


        $data = $request->validate([
            'name' => ['required', 'string', 'max:255'],
            'price' => ['required', 'numeric', 'min:0'],
            'description' => ['nullable', 'string'],
            'cover_image' => ['required', 'image', 'max:5120'],
        ]);

        $cloudinary = new Cloudinary(
            config('cloudinary.url')
        );

        $uploadedImage = $cloudinary->uploadApi()->upload( 
            $request->file('cover_image')->getRealPath(), //lấy đường dẫn file tạm trên máy chạy laravel
            ['folder' => 'tailor_shop/products']
        );

        $product = Product::create([
            'name' => $data['name'],
            'price' => $data['price'],
            'description' => $data['description'] ?? null,
            'cover_image_url' => $uploadedImage['secure_url'],
            'cover_image_public_id' => $uploadedImage['public_id'],
        ]);

        return response()->json([
            'message' => 'Thêm sản phẩm thành công',
            'product' => $product,
        ], 201);
    }
}

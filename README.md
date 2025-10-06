# MinIO Server - Object Storage 🚀

MinIO là một object storage server tương thích với Amazon S3. Dự án này giúp bạn dễ dàng setup MinIO để upload/download files cho ứng dụng web.

## Cài đặt và chạy nhanh ⚡

### Step 1: Setup Docker ()
```bash
# Ubuntu/Debian
sudo apt update && sudo apt install -y docker.io docker-compose
sudo systemctl start docker && sudo systemctl enable docker
sudo usermod -aG docker $USER
newgrp docker
```

### Step 2: Run MinIO
```bash
git clone <your-repo-url>
cd melog-minio
chmod +x setup.sh
./setup.sh
```

### Step 3: Access
- **Web Console**: http://localhost:9001
- **API Endpoint**: http://localhost:9000
- **Username**: `admin`
- **Password**: `password123`

## Test Upload with CURL 📤

###  1: Upload with presigned URL (for Frontend)

```bash
# 1. 
mc share upload local/uploads/my-file.jpg --expire=1h

# 2. 
curl http://localhost:9000/uploads/ \
  -F x-amz-algorithm=AWS4-HMAC-SHA256 \
  -F x-amz-credential=admin/20250921/us-east-1/s3/aws4_request \
  -F x-amz-date=20250921T112542Z \
  -F x-amz-signature=YOUR_SIGNATURE \
  -F bucket=uploads \
  -F policy=YOUR_POLICY \
  -F key=my-file.jpg \
  -F file=@/path/to/your/file.jpg
```

###  2: Upload directer with MinIO Client (đơn giản)

```bash
# Upload file
mc cp /path/to/your/image.jpg local/uploads/

# Kiểm tra file đã upload
mc ls local/uploads/

# Download file về
mc cp local/uploads/image.jpg ./downloaded-image.jpg

# Tạo public URL để truy cập
echo "File URL: http://localhost:9000/uploads/image.jpg"
```


`

### 1. Cài MinIO Client (để chạy lệnh):
```bash
# Download MinIO client
curl -O https://dl.min.io/client/mc/release/linux-amd64/mc
chmod +x mc
sudo mv mc /usr/local/bin/

# Kết nối với server
mc alias set local http://localhost:9000 admin password123
```

### 2. Tạo bucket và cấu hình:
```bash
# Tạo bucket
mc mb local/uploads

# Set bucket public (để download file)
mc policy set public local/uploads

# Kiểm tra bucket
mc ls local
```

### 3. Tạo Access Key (qua Web hoặc CLI):

**Cách 1: Qua Web Console:**
1. Mở http://localhost:9001
2. Đăng nhập: `admin` / `password123`
3. Chọn **Access Keys** > **Create access key**
4. Copy **Access Key** và **Secret Key**

**Cách 2: Qua CLI:**
```bash
# Tạo service account (khuyến nghị cho production)
mc admin user svcacct add local admin
```
// mc admin user svcacct add local admin --access-key myaccesskey --secret-key mysecretkey123
##  Frontend/Backend 💻

### JavaScript/Node.js (AWS SDK):
```bash
npm install aws-sdk
# hoặc
npm install @aws-sdk/client-s3
```

```form upload
const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();

    const file = fileInputRef.current?.files?.[0];
    if (!file) {
      setUploadStatus('Vui lòng chọn file');
      return;
    }

    setUploading(true);
    setUploadStatus('Đang upload...');

    try {
      console.log('Uploading file:', file.name, 'Size:', file.size);

      // Upload trực tiếp lên MinIO bằng PUT (đơn giản nhất)
      const fileName = `${Date.now()}-${file.name}`;

      const response = await fetch(`http://localhost:9000/uploads/${fileName}`, {
        method: 'PUT',
        body: file,
        headers: {
          'Content-Type': file.type || 'application/octet-stream',
        },
      });

      if (response.ok) {
        const fileUrl = `http://localhost:9000/uploads/${fileName}`;
        setUploadStatus(`✅ Upload thành công: ${file.name}`);
        console.log('Upload successful. URL:', fileUrl);
        console.log('View file at:', fileUrl);
      } else {
        const errorText = await response.text();
        setUploadStatus(`❌ Upload thất bại: ${response.status}`);
        console.error('Upload failed:', errorText);
      }
    } catch (error) {
      setUploadStatus(`❌ Lỗi: ${error instanceof Error ? error.message : 'Unknown error'}`);
      console.error('Upload error:', error);
    } finally {
      setUploading(false);
    }
  };


```


```javascript
// Node.js với aws-sdk v2
const AWS = require('aws-sdk');

const s3 = new AWS.S3({
  endpoint: 'http://localhost:9000',
  accessKeyId: 'your-access-key',
  secretAccessKey: 'your-secret-key',
  s3ForcePathStyle: true,
  signatureVersion: 'v4'
});

// Upload file
const uploadFile = async (file, fileName) => {
  const params = {
    Bucket: 'uploads',
    Key: fileName,
    Body: file,
    ContentType: file.type || 'application/octet-stream'
  };
  
  try {
    const result = await s3.upload(params).promise();
    console.log('File uploaded:', result.Location);
    return result;
  } catch (error) {
    console.error('Upload error:', error);
  }
};

// Download/Get file URL
const getFileUrl = (fileName) => {
  const params = {
    Bucket: 'uploads',
    Key: fileName,
    Expires: 3600 // 1 hour
  };
  
  return s3.getSignedUrl('getObject', params);
};
```

```

## Các lệnh quản lý ⚙️

```bash
# Stop MinIO
docker-compose down

# View logs
docker-compose logs -f minio

# Restart
docker-compose restart

# Upload file test
mc cp myfile.jpg local/uploads/

# List files trong bucket
mc ls local/uploads

# Download file
mc cp local/uploads/myfile.jpg ./downloaded-file.jpg

# Reset hoàn toàn
docker-compose down -v && ./setup.sh
```

## CORS Configuration 🌐

Để frontend có thể upload trực tiếp, chạy lệnh sau:

```bash
# Set CORS cho bucket (cho phép frontend upload)
mc anonymous set public local/uploads

# Hoặc set policy cụ thể
cat > /tmp/policy.json << EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Effect": "Allow",
      "Principal": {"AWS": "*},
      "Action": ["s3:GetObject", "s3:PutObject"],
      "Resource": "arn:aws:s3:::uploads/*"
    }
  ]
}
EOF

mc policy set-json /tmp/policy.json local/uploads
```

## Troubleshooting 🔧

### Lỗi CORS:
- Cấu hình CORS policy (xem trên)
- Kiểm tra bucket policy

### Lỗi Access Denied:
- Kiểm tra Access Key/Secret Key
- Kiểm tra bucket permissions

### File không tải được:
- Kiểm tra bucket public policy
- Sử dụng presigned URL thay vì direct URL

---

**Tip**: Trong production, nhớ đổi password và sử dụng HTTPS!

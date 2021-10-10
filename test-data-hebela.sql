
-- câu 1
CREATE TABLE DanhMuc
(
    MaDanhMuc INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
	TenDanhMuc NVARCHAR(MAX)
)
GO 
--DROP TABLE dbo.DanhMuc

CREATE TABLE SanPham
(
	MaSanPham INT IDENTITY(1, 1) NOT NULL PRIMARY KEY,
	TenSanPham NVARCHAR(MAX), 

	MaDanhMuc INT
)
GO 
--DROP TABLE dbo.SanPham

CREATE TABLE GiaTheoNgay
(
    MaGiaTheoNgay INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	Ngay DATE DEFAULT GETDATE(),
	Gia FLOAT DEFAULT 0,
	GhiChu NVARCHAR(MAX),

	MaSanPham INT 
)
GO 
--DROP TABLE dbo.GiaTheoNgay

CREATE TABLE HoaDon
(
    MaHoaDon INT IDENTITY(1,1) NOT NULL PRIMARY KEY,
	NgayDatDon DATE DEFAULT GETDATE(),
	SoLuongMua INT DEFAULT 1,
	PhiShip FLOAT DEFAULT 0,
	GiamGia_TheoPhanTram INT DEFAULT 0,
	GhiChu NVARCHAR(MAX),

	MaSanPham INT 
)
GO 
--DROP TABLE dbo.HoaDon

ALTER TABLE dbo.SanPham
ADD CONSTRAINT FK_DANHMUC_SANPHAM FOREIGN KEY (MaDanhMuc) REFERENCES dbo.DanhMuc (MaDanhMuc);
GO 

ALTER TABLE dbo.GiaTheoNgay
ADD CONSTRAINT FK_SANPHAM_GIATHEONGAY FOREIGN KEY (MaSanPham) REFERENCES dbo.SanPham (MaSanPham);
GO 

ALTER TABLE dbo.HoaDon
ADD CONSTRAINT FK_SANPHAM_HoaDon FOREIGN KEY (MaSanPham) REFERENCES dbo.SanPham (MaSanPham);
GO 


-- câu 2
CREATE FUNCTION GiaSP
-- tính giá sản phẩm
( @NgayDatDon DATE, @MaSanPham int, @Ngay Date )
RETURNS Float 
AS
BEGIN
	DECLARE @Gia FLOAT = NULL

	IF (DAY(CONVERT(DATE, @NgayDatDon)) <= 15) OR (DAY(CONVERT(DATE, @NgayDatDon)) = 31) AND (DAY(CONVERT(DATE, @Ngay)) = 15)
    BEGIN
        SET @Gia = (SELECT gia FROM giatheongay WHERE MONTH(CONVERT(DATE, ngay)) = MONTH(CONVERT(DATE, @NgayDatDon)) AND MaSanPham = @MaSanPham GROUP BY gia, ngay  HAVING DAY(CONVERT(DATE, ngay)) = 15)
    END

	ELSE IF (DAY(CONVERT(DATE, @NgayDatDon)) BETWEEN 16 AND 30)  AND (DAY(CONVERT(DATE, @Ngay)) = 30)
    BEGIN
        SET @Gia = (SELECT gia FROM giatheongay WHERE MONTH(CONVERT(DATE, ngay)) = MONTH(CONVERT(DATE, @NgayDatDon)) AND MaSanPham = @MaSanPham GROUP BY gia, ngay  HAVING DAY(CONVERT(DATE, ngay)) = 30)
    END

	RETURN @Gia;
END;
GO 

-- lấy ra số lượng mua của từng sản phẩm 
SELECT TenSanPham, COUNT(TenSanPham) SoLuongMua FROM dbo.HoaDon hd INNER JOIN dbo.SanPham ON SanPham.MaSanPham = hd.MaSanPham
GROUP BY  TenSanPham
GO 

CREATE FUNCTION DoanhThuSanPham
-- Tính doanh thu của các sản phẩm trong tháng đó
    (@Thang INT)
RETURNS TABLE
AS
    RETURN (
		SELECT tbl.TenSanPham, SUM(DISTINCT tbl.DoanhThu) DoanhThuThang 
		FROM (
			SELECT DISTINCT sp.MaSanPham, sp.TenSanPham, hd.SoLuongMua, hd.NgayDatDon, hd.MaHoaDon, ((dbo.GiaSP (CONVERT(DATE, hd.NgayDatDon), sp.MaSanPham, gtn.Ngay) * hd.SoLuongMua) - (dbo.GiaSP (CONVERT(DATE, hd.NgayDatDon), sp.MaSanPham, gtn.Ngay) / 100 * hd.GiamGia_TheoPhanTram)) DoanhThu
			FROM dbo.SanPham sp 
				INNER JOIN  dbo.HoaDon hd ON hd.MaSanPham = sp.MaSanPham
				INNER JOIN dbo.GiaTheoNgay gtn ON gtn.MaSanPham = sp.MaSanPham
			WHERE MONTH(CONVERT(DATE, hd.NgayDatDon)) = @Thang 
				AND MONTH(CONVERT(DATE, gtn.Ngay)) = @Thang 
				AND (
					(dbo.GiaSP (CONVERT(DATE, hd.NgayDatDon), sp.MaSanPham, gtn.Ngay) * hd.SoLuongMua) - (dbo.GiaSP (CONVERT(DATE, hd.NgayDatDon), sp.MaSanPham, gtn.Ngay) / 100 * hd.GiamGia_TheoPhanTram)
				) IS NOT NULL
			GROUP BY sp.MaSanPham, sp.TenSanPham, hd.NgayDatDon, hd.SoLuongMua, gtn.Ngay, hd.MaHoaDon, hd.GiamGia_TheoPhanTram 
		) tbl
		GROUP BY tbl.TenSanPham
	)
GO





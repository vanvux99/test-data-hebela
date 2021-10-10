
/****** Object:  Database [ok]    Script Date: 10/11/2021 1:11:44 AM ******/
CREATE DATABASE [ok]
GO
ALTER DATABASE [ok] SET ANSI_NULL_DEFAULT OFF 
GO
ALTER DATABASE [ok] SET ANSI_NULLS OFF 
GO
ALTER DATABASE [ok] SET ANSI_PADDING OFF 
GO
ALTER DATABASE [ok] SET ANSI_WARNINGS OFF 
GO
ALTER DATABASE [ok] SET ARITHABORT OFF 
GO
ALTER DATABASE [ok] SET AUTO_CLOSE OFF 
GO
ALTER DATABASE [ok] SET AUTO_SHRINK OFF 
GO
ALTER DATABASE [ok] SET AUTO_UPDATE_STATISTICS ON 
GO
ALTER DATABASE [ok] SET CURSOR_CLOSE_ON_COMMIT OFF 
GO
ALTER DATABASE [ok] SET CURSOR_DEFAULT  GLOBAL 
GO
ALTER DATABASE [ok] SET CONCAT_NULL_YIELDS_NULL OFF 
GO
ALTER DATABASE [ok] SET NUMERIC_ROUNDABORT OFF 
GO
ALTER DATABASE [ok] SET QUOTED_IDENTIFIER OFF 
GO
ALTER DATABASE [ok] SET RECURSIVE_TRIGGERS OFF 
GO
ALTER DATABASE [ok] SET  DISABLE_BROKER 
GO
ALTER DATABASE [ok] SET AUTO_UPDATE_STATISTICS_ASYNC OFF 
GO
ALTER DATABASE [ok] SET DATE_CORRELATION_OPTIMIZATION OFF 
GO
ALTER DATABASE [ok] SET TRUSTWORTHY OFF 
GO
ALTER DATABASE [ok] SET ALLOW_SNAPSHOT_ISOLATION OFF 
GO
ALTER DATABASE [ok] SET PARAMETERIZATION SIMPLE 
GO
ALTER DATABASE [ok] SET READ_COMMITTED_SNAPSHOT OFF 
GO
ALTER DATABASE [ok] SET HONOR_BROKER_PRIORITY OFF 
GO
ALTER DATABASE [ok] SET RECOVERY FULL 
GO
ALTER DATABASE [ok] SET  MULTI_USER 
GO
ALTER DATABASE [ok] SET PAGE_VERIFY CHECKSUM  
GO
ALTER DATABASE [ok] SET DB_CHAINING OFF 
GO
ALTER DATABASE [ok] SET FILESTREAM( NON_TRANSACTED_ACCESS = OFF ) 
GO
ALTER DATABASE [ok] SET TARGET_RECOVERY_TIME = 60 SECONDS 
GO
ALTER DATABASE [ok] SET DELAYED_DURABILITY = DISABLED 
GO
ALTER DATABASE [ok] SET ACCELERATED_DATABASE_RECOVERY = OFF  
GO
EXEC sys.sp_db_vardecimal_storage_format N'ok', N'ON'
GO
ALTER DATABASE [ok] SET QUERY_STORE = OFF
GO
USE [ok]
GO
/****** Object:  UserDefinedFunction [dbo].[GiaSP]    Script Date: 10/11/2021 1:11:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[GiaSP]
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
/****** Object:  Table [dbo].[SanPham]    Script Date: 10/11/2021 1:11:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[SanPham](
	[MaSanPham] [int] IDENTITY(1,1) NOT NULL,
	[TenSanPham] [nvarchar](max) NULL,
	[MaDanhMuc] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[MaSanPham] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[GiaTheoNgay]    Script Date: 10/11/2021 1:11:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[GiaTheoNgay](
	[MaGiaTheoNgay] [int] IDENTITY(1,1) NOT NULL,
	[Ngay] [date] NULL,
	[Gia] [float] NULL,
	[GhiChu] [nvarchar](max) NULL,
	[MaSanPham] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[MaGiaTheoNgay] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  Table [dbo].[HoaDon]    Script Date: 10/11/2021 1:11:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[HoaDon](
	[MaHoaDon] [int] IDENTITY(1,1) NOT NULL,
	[NgayDatDon] [date] NULL,
	[SoLuongMua] [int] NULL,
	[PhiShip] [float] NULL,
	[GiamGia_TheoPhanTram] [int] NULL,
	[GhiChu] [nvarchar](max) NULL,
	[MaSanPham] [int] NULL,
PRIMARY KEY CLUSTERED 
(
	[MaHoaDon] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
/****** Object:  UserDefinedFunction [dbo].[DoanhThuSanPham]    Script Date: 10/11/2021 1:11:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE FUNCTION [dbo].[DoanhThuSanPham]
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
/****** Object:  Table [dbo].[DanhMuc]    Script Date: 10/11/2021 1:11:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE TABLE [dbo].[DanhMuc](
	[MaDanhMuc] [int] IDENTITY(1,1) NOT NULL,
	[TenDanhMuc] [nvarchar](max) NULL,
PRIMARY KEY CLUSTERED 
(
	[MaDanhMuc] ASC
)WITH (PAD_INDEX = OFF, STATISTICS_NORECOMPUTE = OFF, IGNORE_DUP_KEY = OFF, ALLOW_ROW_LOCKS = ON, ALLOW_PAGE_LOCKS = ON, OPTIMIZE_FOR_SEQUENTIAL_KEY = OFF) ON [PRIMARY]
) ON [PRIMARY] TEXTIMAGE_ON [PRIMARY]
GO
SET IDENTITY_INSERT [dbo].[DanhMuc] ON 
GO
INSERT [dbo].[DanhMuc] ([MaDanhMuc], [TenDanhMuc]) VALUES (1, N'
Chăm sóc tóc')
GO
INSERT [dbo].[DanhMuc] ([MaDanhMuc], [TenDanhMuc]) VALUES (2, N'

Dưỡng mi')
GO
INSERT [dbo].[DanhMuc] ([MaDanhMuc], [TenDanhMuc]) VALUES (3, N'Chăm sóc da mặt')
GO
SET IDENTITY_INSERT [dbo].[DanhMuc] OFF
GO
SET IDENTITY_INSERT [dbo].[GiaTheoNgay] ON 
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (1, CAST(N'2021-07-15' AS Date), 490000, NULL, 1)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (2, CAST(N'2021-07-30' AS Date), 490000, NULL, 1)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (3, CAST(N'2021-08-15' AS Date), 490000, NULL, 1)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (4, CAST(N'2021-08-30' AS Date), 490000, NULL, 1)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (5, CAST(N'2021-09-15' AS Date), 470000, NULL, 1)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (6, CAST(N'2021-09-30' AS Date), 490000, NULL, 1)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (7, CAST(N'2021-07-15' AS Date), 490000, NULL, 2)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (8, CAST(N'2021-07-30' AS Date), 490000, NULL, 2)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (9, CAST(N'2021-08-15' AS Date), 490000, NULL, 2)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (10, CAST(N'2021-08-30' AS Date), 490000, NULL, 2)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (11, CAST(N'2021-09-15' AS Date), 460000, NULL, 2)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (12, CAST(N'2021-09-30' AS Date), 490000, NULL, 2)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (13, CAST(N'2021-07-15' AS Date), 490000, NULL, 3)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (14, CAST(N'2021-07-30' AS Date), 490000, NULL, 3)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (15, CAST(N'2021-08-15' AS Date), 490000, NULL, 3)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (16, CAST(N'2021-08-30' AS Date), 490000, NULL, 3)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (17, CAST(N'2021-09-15' AS Date), 450000, NULL, 3)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (18, CAST(N'2021-09-30' AS Date), 690000, NULL, 3)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (19, CAST(N'2021-07-15' AS Date), 249000, NULL, 4)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (20, CAST(N'2021-07-30' AS Date), 249000, NULL, 4)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (21, CAST(N'2021-08-15' AS Date), 279000, NULL, 4)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (22, CAST(N'2021-08-30' AS Date), 279000, NULL, 4)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (23, CAST(N'2021-09-15' AS Date), 249000, NULL, 4)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (24, CAST(N'2021-09-30' AS Date), 249000, NULL, 4)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (25, CAST(N'2021-07-15' AS Date), 470250, NULL, 5)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (26, CAST(N'2021-07-30' AS Date), 470250, NULL, 5)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (27, CAST(N'2021-08-15' AS Date), 470250, NULL, 5)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (28, CAST(N'2021-08-30' AS Date), 371250, NULL, 5)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (29, CAST(N'2021-09-30' AS Date), 470250, NULL, 5)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (30, CAST(N'2021-09-15' AS Date), 371250, NULL, 5)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (31, CAST(N'2021-07-15' AS Date), 490000, NULL, 6)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (32, CAST(N'2021-07-30' AS Date), 490000, NULL, 6)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (33, CAST(N'2021-08-15' AS Date), 490000, NULL, 6)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (34, CAST(N'2021-08-30' AS Date), 490000, NULL, 6)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (35, CAST(N'2021-09-15' AS Date), 490000, NULL, 6)
GO
INSERT [dbo].[GiaTheoNgay] ([MaGiaTheoNgay], [Ngay], [Gia], [GhiChu], [MaSanPham]) VALUES (36, CAST(N'2021-09-30' AS Date), 490000, NULL, 6)
GO
SET IDENTITY_INSERT [dbo].[GiaTheoNgay] OFF
GO
SET IDENTITY_INSERT [dbo].[HoaDon] ON 
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (1, CAST(N'2021-07-03' AS Date), 2, 30000, 10, NULL, 6)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (2, CAST(N'2021-07-05' AS Date), 3, 30000, 0, NULL, 3)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (3, CAST(N'2021-07-12' AS Date), 2, 0, 0, NULL, 3)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (4, CAST(N'2021-07-15' AS Date), 2, 30000, 10, NULL, 2)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (5, CAST(N'2021-07-15' AS Date), 2, 30000, 10, NULL, 4)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (6, CAST(N'2021-07-20' AS Date), 2, 0, 0, NULL, 3)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (7, CAST(N'2021-07-25' AS Date), 2, 30000, 10, NULL, 3)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (8, CAST(N'2021-07-26' AS Date), 1, 30000, 0, NULL, 4)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (9, CAST(N'2021-07-31' AS Date), 2, 30000, 10, NULL, 4)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (10, CAST(N'2021-08-06' AS Date), 1, 0, 0, NULL, 4)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (11, CAST(N'2021-08-06' AS Date), 1, 30000, 0, NULL, 2)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (12, CAST(N'2021-08-07' AS Date), 3, 30000, 0, NULL, 5)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (13, CAST(N'2021-08-07' AS Date), 1, 0, 0, NULL, 1)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (14, CAST(N'2021-08-09' AS Date), 2, 0, 10, NULL, 6)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (15, CAST(N'2021-08-16' AS Date), 3, 30000, 10, NULL, 3)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (16, CAST(N'2021-08-17' AS Date), 1, 0, 10, NULL, 4)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (17, CAST(N'2021-08-19' AS Date), 3, 30000, 0, NULL, 6)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (18, CAST(N'2021-08-25' AS Date), 3, 0, 0, NULL, 3)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (19, CAST(N'2021-08-26' AS Date), 1, 30000, 10, NULL, 4)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (20, CAST(N'2021-08-27' AS Date), 1, 30000, 0, NULL, 5)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (21, CAST(N'2021-08-28' AS Date), 1, 0, 10, NULL, 2)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (22, CAST(N'2021-08-30' AS Date), 3, 0, 0, NULL, 4)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (23, CAST(N'2021-08-31' AS Date), 2, 30000, 10, NULL, 3)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (24, CAST(N'2021-09-04' AS Date), 3, 30000, 10, NULL, 2)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (25, CAST(N'2021-09-04' AS Date), 2, 30000, 10, NULL, 3)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (26, CAST(N'2021-09-12' AS Date), 2, 0, 0, NULL, 3)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (27, CAST(N'2021-09-13' AS Date), 3, 0, 10, NULL, 5)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (28, CAST(N'2021-09-13' AS Date), 1, 30000, 0, NULL, 3)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (29, CAST(N'2021-09-24' AS Date), 1, 0, 10, NULL, 5)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (30, CAST(N'2021-09-24' AS Date), 2, 30000, 10, NULL, 3)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (31, CAST(N'2021-09-25' AS Date), 2, 0, 10, NULL, 3)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (32, CAST(N'2021-09-26' AS Date), 2, 0, 10, NULL, 1)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (33, CAST(N'2021-09-28' AS Date), 2, 30000, 10, NULL, 6)
GO
INSERT [dbo].[HoaDon] ([MaHoaDon], [NgayDatDon], [SoLuongMua], [PhiShip], [GiamGia_TheoPhanTram], [GhiChu], [MaSanPham]) VALUES (34, CAST(N'2021-09-30' AS Date), 1, 30000, 10, NULL, 3)
GO
SET IDENTITY_INSERT [dbo].[HoaDon] OFF
GO
SET IDENTITY_INSERT [dbo].[SanPham] ON 
GO
INSERT [dbo].[SanPham] ([MaSanPham], [TenSanPham], [MaDanhMuc]) VALUES (1, N'
Dầu Gội Alika For Women Extra Volume Shampoo 300 ml', 1)
GO
INSERT [dbo].[SanPham] ([MaSanPham], [TenSanPham], [MaDanhMuc]) VALUES (2, N'

Dầu Gội Alika For Men Extra Volume Shampoo 300 ml', 1)
GO
INSERT [dbo].[SanPham] ([MaSanPham], [TenSanPham], [MaDanhMuc]) VALUES (3, N'Dưỡng Mi Cao Cấp Alika Eyelash Growth Serum 5 ml', 2)
GO
INSERT [dbo].[SanPham] ([MaSanPham], [TenSanPham], [MaDanhMuc]) VALUES (4, N'Dưỡng Mi Cao Cấp Alika Eyelash Growth Serum 2 ml', 2)
GO
INSERT [dbo].[SanPham] ([MaSanPham], [TenSanPham], [MaDanhMuc]) VALUES (5, N'
Nước Tẩy Trang Và Làm Sạch Dành Cho Da Nhạy Cảm Bioderma Sensibio H2O 500 ml', 3)
GO
INSERT [dbo].[SanPham] ([MaSanPham], [TenSanPham], [MaDanhMuc]) VALUES (6, N'

Dầu Xả Alika For Women Extra Volume Conditioner 300 ml', 1)
GO
SET IDENTITY_INSERT [dbo].[SanPham] OFF
GO
ALTER TABLE [dbo].[GiaTheoNgay] ADD  DEFAULT (getdate()) FOR [Ngay]
GO
ALTER TABLE [dbo].[GiaTheoNgay] ADD  DEFAULT ((0)) FOR [Gia]
GO
ALTER TABLE [dbo].[HoaDon] ADD  DEFAULT (getdate()) FOR [NgayDatDon]
GO
ALTER TABLE [dbo].[HoaDon] ADD  DEFAULT ((1)) FOR [SoLuongMua]
GO
ALTER TABLE [dbo].[HoaDon] ADD  DEFAULT ((0)) FOR [PhiShip]
GO
ALTER TABLE [dbo].[HoaDon] ADD  DEFAULT ((0)) FOR [GiamGia_TheoPhanTram]
GO
ALTER TABLE [dbo].[GiaTheoNgay]  WITH CHECK ADD  CONSTRAINT [FK_SANPHAM_GIATHEONGAY] FOREIGN KEY([MaSanPham])
REFERENCES [dbo].[SanPham] ([MaSanPham])
GO
ALTER TABLE [dbo].[GiaTheoNgay] CHECK CONSTRAINT [FK_SANPHAM_GIATHEONGAY]
GO
ALTER TABLE [dbo].[HoaDon]  WITH CHECK ADD  CONSTRAINT [FK_SANPHAM_HoaDon] FOREIGN KEY([MaSanPham])
REFERENCES [dbo].[SanPham] ([MaSanPham])
GO
ALTER TABLE [dbo].[HoaDon] CHECK CONSTRAINT [FK_SANPHAM_HoaDon]
GO
ALTER TABLE [dbo].[SanPham]  WITH CHECK ADD  CONSTRAINT [FK_DANHMUC_SANPHAM] FOREIGN KEY([MaDanhMuc])
REFERENCES [dbo].[DanhMuc] ([MaDanhMuc])
GO
ALTER TABLE [dbo].[SanPham] CHECK CONSTRAINT [FK_DANHMUC_SANPHAM]
GO
/****** Object:  StoredProcedure [dbo].[DoanhThuSanPhamTheoThang]    Script Date: 10/11/2021 1:11:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[DoanhThuSanPhamTheoThang]  
    @Thang INT
AS
BEGIN
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
END
GO
/****** Object:  StoredProcedure [dbo].[GiaSanPham]    Script Date: 10/11/2021 1:11:44 AM ******/
SET ANSI_NULLS ON
GO
SET QUOTED_IDENTIFIER ON
GO
CREATE PROCEDURE [dbo].[GiaSanPham] --'2021-07-03'
   ( @NgayDatDon DATE, @MaSanPham int )
AS
BEGIN
	DECLARE @Gia FLOAT
    IF (DAY(CONVERT(DATE, @NgayDatDon)) <= 15) OR (DAY(CONVERT(DATE, @NgayDatDon)) = 31)
    BEGIN
        SET @Gia = (SELECT gia FROM giatheongay WHERE MONTH(CONVERT(DATE, ngay)) = MONTH(CONVERT(DATE, @NgayDatDon)) AND MaSanPham = @MaSanPham GROUP BY gia, ngay  HAVING DAY(CONVERT(DATE, ngay)) = 15)
    END

	IF DAY(CONVERT(DATE, @NgayDatDon)) BETWEEN 16 AND 30
    BEGIN
        SET @Gia = (SELECT gia FROM giatheongay WHERE MONTH(CONVERT(DATE, ngay)) = MONTH(CONVERT(DATE, @NgayDatDon)) AND MaSanPham = @MaSanPham GROUP BY gia, ngay  HAVING DAY(CONVERT(DATE, ngay)) = 30)
    END

	RETURN @Gia
END
GO
USE [master]
GO
ALTER DATABASE [ok] SET  READ_WRITE 
GO

CREATE TABLE HangSX (
    MaHangSX VARCHAR2(10) CONSTRAINT pk_hangsx PRIMARY KEY,
    TenHang  VARCHAR2(30) NOT NULL,
    DiaChi   VARCHAR2(50),
    SoDT     VARCHAR2(15),
    Email    VARCHAR2(50)
);

CREATE TABLE SanPham (
    MaSP      VARCHAR2(10) CONSTRAINT pk_sanpham PRIMARY KEY,
    MaHangSX  VARCHAR2(10) REFERENCES HangSX(MaHangSX),
    TenSP     VARCHAR2(50) NOT NULL,
    SoLuong   NUMBER(10),
    MauSac    VARCHAR2(20),
    GiaBan    NUMBER(15,2),
    DonViTinh VARCHAR2(15),
    MoTa      CLOB
);

CREATE TABLE NhanVien (
    MaNV     VARCHAR2(10) CONSTRAINT pk_nhanvien PRIMARY KEY,
    TenNV    VARCHAR2(50) NOT NULL,
    GioiTinh VARCHAR2(10),
    DiaChi   VARCHAR2(100),
    SoDT     VARCHAR2(15),
    Email    VARCHAR2(50),
    TenPhong VARCHAR2(30)
);

CREATE TABLE PNhap (
    SoHDN    VARCHAR2(10) CONSTRAINT pk_pnhap PRIMARY KEY,
    NgayNhap DATE,
    MaNV     VARCHAR2(10) REFERENCES NhanVien(MaNV)
);

CREATE TABLE Nhap (
    SoHDN    VARCHAR2(10) REFERENCES PNhap(SoHDN),
    MaSP     VARCHAR2(10) REFERENCES SanPham(MaSP),
    SoLuongN NUMBER(10),
    DonGiaN  NUMBER(15,2),
    CONSTRAINT pk_nhap PRIMARY KEY (SoHDN, MaSP)
);

CREATE TABLE PXuat (
    SoHDX    VARCHAR2(10) CONSTRAINT pk_pxuat PRIMARY KEY,
    NgayXuat DATE,
    MaNV     VARCHAR2(10) REFERENCES NhanVien(MaNV)
);

CREATE TABLE Xuat (
    SoHDX    VARCHAR2(10) REFERENCES PXuat(SoHDX),
    MaSP     VARCHAR2(10) REFERENCES SanPham(MaSP),
    SoLuongX NUMBER(10),
    CONSTRAINT pk_xuat PRIMARY KEY (SoHDX, MaSP)
);

-- a
CREATE OR REPLACE PROCEDURE sp_NhapHangSX (
    p_MaHangSX IN VARCHAR2,
    p_TenHang  IN VARCHAR2,
    p_DiaChi   IN VARCHAR2,
    p_SoDT     IN VARCHAR2,
    p_Email    IN VARCHAR2
) AS
    v_dem NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem FROM HangSX WHERE TenHang = p_TenHang;

    IF v_dem > 0 THEN
        DBMS_OUTPUT.PUT_LINE('TenHang da ton tai!');
    ELSE
        INSERT INTO HangSX VALUES (p_MaHangSX, p_TenHang, p_DiaChi, p_SoDT, p_Email);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Them HangSX thanh cong!');
    END IF;
END sp_NhapHangSX;
/

SET SERVEROUTPUT ON;
BEGIN
    sp_NhapHangSX('HSX01', 'Samsung', 'Han Quoc', '0123456789', 'samsung@gmail.com');
END;
/
BEGIN
    sp_NhapHangSX('HSX02', 'Samsung', 'Han Quoc', '0987654321', 'samsung2@gmail.com');
END;
/

-- b

CREATE OR REPLACE PROCEDURE sp_NhapSP (
    p_MaSP      IN VARCHAR2,
    p_MaHangSX  IN VARCHAR2,
    p_TenSP     IN VARCHAR2,
    p_SoLuong   IN NUMBER,
    p_MauSac    IN VARCHAR2,
    p_GiaBan    IN NUMBER,
    p_DonViTinh IN VARCHAR2,
    p_MoTa      IN VARCHAR2
) AS
    v_dem_hang NUMBER := 0;
    v_dem_sp   NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem_hang FROM HangSX WHERE MaHangSX = p_MaHangSX;

    IF v_dem_hang = 0 THEN
        DBMS_OUTPUT.PUT_LINE('TenHang khong co trong bang HangSX!');
    ELSE
        SELECT COUNT(*) INTO v_dem_sp FROM SanPham WHERE MaSP = p_MaSP;

        IF v_dem_sp > 0 THEN
            UPDATE SanPham SET
                MaHangSX  = p_MaHangSX,
                TenSP     = p_TenSP,
                SoLuong   = p_SoLuong,
                MauSac    = p_MauSac,
                GiaBan    = p_GiaBan,
                DonViTinh = p_DonViTinh,
                MoTa      = p_MoTa
            WHERE MaSP = p_MaSP;
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('Cap nhat san pham thanh cong!');
        ELSE
            INSERT INTO SanPham VALUES (p_MaSP, p_MaHangSX, p_TenSP, p_SoLuong, p_MauSac, p_GiaBan, p_DonViTinh, p_MoTa);
            COMMIT;
            DBMS_OUTPUT.PUT_LINE('Them san pham thanh cong!');
        END IF;
    END IF;
END sp_NhapSP;
/
--
SET SERVEROUTPUT ON;
BEGIN
    sp_NhapSP('SP01', 'HSX01', 'Samsung A54', 100, 'Den', 8000000, 'Cai', 'Dien thoai Samsung');
END;
/
BEGIN
    sp_NhapSP('SP01', 'HSX01', 'Samsung A54 Pro', 150, 'Trang', 9000000, 'Cai', 'Dien thoai Samsung moi');
END;
/
BEGIN
    sp_NhapSP('SP02', 'HSX99', 'iPhone 14', 50, 'Trang', 25000000, 'Cai', 'Dien thoai Apple');
END;
/
--c
CREATE OR REPLACE PROCEDURE sp_XoaHangSX (
    p_TenHang IN VARCHAR2
) AS
    v_dem NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem FROM HangSX WHERE TenHang = p_TenHang;

    IF v_dem = 0 THEN
        DBMS_OUTPUT.PUT_LINE('TenHang chua co trong bang HangSX!');
    ELSE
        DELETE FROM SanPham WHERE MaHangSX = (
            SELECT MaHangSX FROM HangSX WHERE TenHang = p_TenHang
        );

        DELETE FROM HangSX WHERE TenHang = p_TenHang;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Xoa HangSX thanh cong!');
    END IF;
END sp_XoaHangSX;
/
--
SET SERVEROUTPUT ON;

BEGIN
    sp_XoaHangSX('Samsung');
END;
/
BEGIN
    sp_XoaHangSX('Nokia');
END;
/

--d 
CREATE OR REPLACE PROCEDURE sp_NhapNhanVien (
    p_MaNV     IN VARCHAR2,
    p_TenNV    IN VARCHAR2,
    p_GioiTinh IN VARCHAR2,
    p_DiaChi   IN VARCHAR2,
    p_SoDT     IN VARCHAR2,
    p_Email    IN VARCHAR2,
    p_TenPhong IN VARCHAR2,
    p_Flag     IN NUMBER
) AS
BEGIN
    IF p_Flag = 0 THEN
        UPDATE NhanVien SET
            TenNV    = p_TenNV,
            GioiTinh = p_GioiTinh,
            DiaChi   = p_DiaChi,
            SoDT     = p_SoDT,
            Email    = p_Email,
            TenPhong = p_TenPhong
        WHERE MaNV = p_MaNV;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Cap nhat nhan vien thanh cong!');
    ELSE
        INSERT INTO NhanVien VALUES (p_MaNV, p_TenNV, p_GioiTinh, p_DiaChi, p_SoDT, p_Email, p_TenPhong);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Them moi nhan vien thanh cong!');
    END IF;
END sp_NhapNhanVien;
/
--
SET SERVEROUTPUT ON;
BEGIN
    sp_NhapNhanVien('NV01', 'Nguyen Van A', 'Nam', 'HCM', '0911111111', 'nva@gmail.com', 'Kinh doanh', 1);
END;
/
BEGIN
    sp_NhapNhanVien('NV01', 'Nguyen Van A (sua)', 'Nam', 'HN', '0911111111', 'nva@gmail.com', 'Ke toan', 0);
END;
/

--e
CREATE OR REPLACE PROCEDURE sp_NhapHangNhap (
    p_SoHDN    IN VARCHAR2,
    p_MaSP     IN VARCHAR2,
    p_MaNV     IN VARCHAR2,
    p_NgayNhap IN DATE,
    p_SoLuongN IN NUMBER,
    p_DonGiaN  IN NUMBER
) AS
    v_dem_sp   NUMBER := 0;
    v_dem_nv   NUMBER := 0;
    v_dem_hdn  NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem_sp FROM SanPham WHERE MaSP = p_MaSP;

    IF v_dem_sp = 0 THEN
        DBMS_OUTPUT.PUT_LINE('MaSP khong co trong bang SanPham!');
        RETURN;
    END IF;

    SELECT COUNT(*) INTO v_dem_nv FROM NhanVien WHERE MaNV = p_MaNV;

    IF v_dem_nv = 0 THEN
        DBMS_OUTPUT.PUT_LINE('MaNV khong co trong bang NhanVien!');
        RETURN;
    END IF;

    SELECT COUNT(*) INTO v_dem_hdn FROM PNhap WHERE SoHDN = p_SoHDN;

    IF v_dem_hdn > 0 THEN
        UPDATE Nhap SET
            SoLuongN = p_SoLuongN,
            DonGiaN  = p_DonGiaN
        WHERE SoHDN = p_SoHDN AND MaSP = p_MaSP;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Cap nhat Nhap thanh cong!');
    ELSE
        INSERT INTO PNhap VALUES (p_SoHDN, p_NgayNhap, p_MaNV);
        INSERT INTO Nhap VALUES (p_SoHDN, p_MaSP, p_SoLuongN, p_DonGiaN);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Them moi Nhap thanh cong!');
    END IF;
END sp_NhapHangNhap;
/

--
SET SERVEROUTPUT ON;
BEGIN
    sp_NhapHangNhap('HDN01', 'SP01', 'NV01', TO_DATE('01/03/2025', 'DD/MM/YYYY'), 50, 7000000);
END;
/
BEGIN
    sp_NhapHangNhap('HDN01', 'SP01', 'NV01', TO_DATE('01/03/2025', 'DD/MM/YYYY'), 100, 7500000);
END;
/
BEGIN
    sp_NhapHangNhap('HDN02', 'SP99', 'NV01', TO_DATE('01/03/2025', 'DD/MM/YYYY'), 50, 7000000);
END;
/
BEGIN
    sp_NhapHangNhap('HDN02', 'SP01', 'NV99', TO_DATE('01/03/2025', 'DD/MM/YYYY'), 50, 7000000);
END;
/

--f
CREATE OR REPLACE PROCEDURE sp_NhapHangXuat (
    p_SoHDX    IN VARCHAR2,
    p_MaSP     IN VARCHAR2,
    p_MaNV     IN VARCHAR2,
    p_NgayXuat IN DATE,
    p_SoLuongX IN NUMBER
) AS
    v_dem_sp   NUMBER := 0;
    v_dem_nv   NUMBER := 0;
    v_dem_hdx  NUMBER := 0;
    v_soluong  NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem_sp FROM SanPham WHERE MaSP = p_MaSP;

    IF v_dem_sp = 0 THEN
        DBMS_OUTPUT.PUT_LINE('MaSP khong co trong bang SanPham!');
        RETURN;
    END IF;

    SELECT COUNT(*) INTO v_dem_nv FROM NhanVien WHERE MaNV = p_MaNV;

    IF v_dem_nv = 0 THEN
        DBMS_OUTPUT.PUT_LINE('MaNV khong co trong bang NhanVien!');
        RETURN;
    END IF;

    SELECT SoLuong INTO v_soluong FROM SanPham WHERE MaSP = p_MaSP;

    IF p_SoLuongX > v_soluong THEN
        DBMS_OUTPUT.PUT_LINE('SoLuongX vuot qua so luong ton kho!');
        RETURN;
    END IF;

    SELECT COUNT(*) INTO v_dem_hdx FROM PXuat WHERE SoHDX = p_SoHDX;

    IF v_dem_hdx > 0 THEN
        UPDATE Xuat SET
            SoLuongX = p_SoLuongX
        WHERE SoHDX = p_SoHDX AND MaSP = p_MaSP;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Cap nhat Xuat thanh cong!');
    ELSE
        INSERT INTO PXuat VALUES (p_SoHDX, p_NgayXuat, p_MaNV);
        INSERT INTO Xuat VALUES (p_SoHDX, p_MaSP, p_SoLuongX);
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Them moi Xuat thanh cong!');
    END IF;
END sp_NhapHangXuat;
/

--
SET SERVEROUTPUT ON;

BEGIN
    sp_NhapHangXuat('HDX01', 'SP01', 'NV01', TO_DATE('05/03/2025', 'DD/MM/YYYY'), 10);
END;
/
BEGIN
    sp_NhapHangXuat('HDX01', 'SP01', 'NV01', TO_DATE('05/03/2025', 'DD/MM/YYYY'), 20);
END;
/
BEGIN
    sp_NhapHangXuat('HDX02', 'SP99', 'NV01', TO_DATE('05/03/2025', 'DD/MM/YYYY'), 10);
END;
/
BEGIN
    sp_NhapHangXuat('HDX02', 'SP01', 'NV99', TO_DATE('05/03/2025', 'DD/MM/YYYY'), 10);
END;
/
BEGIN
    sp_NhapHangXuat('HDX02', 'SP01', 'NV01', TO_DATE('05/03/2025', 'DD/MM/YYYY'), 99999);
END;
/

--g

CREATE OR REPLACE PROCEDURE sp_XoaNhanVien (
    p_MaNV IN VARCHAR2
) AS
    v_dem NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem FROM NhanVien WHERE MaNV = p_MaNV;

    IF v_dem = 0 THEN
        DBMS_OUTPUT.PUT_LINE('MaNV chua co trong bang NhanVien!');
    ELSE
        DELETE FROM Nhap WHERE SoHDN IN (
            SELECT SoHDN FROM PNhap WHERE MaNV = p_MaNV
        );
        DELETE FROM PNhap WHERE MaNV = p_MaNV;

        DELETE FROM Xuat WHERE SoHDX IN (
            SELECT SoHDX FROM PXuat WHERE MaNV = p_MaNV
        );
        DELETE FROM PXuat WHERE MaNV = p_MaNV;

        DELETE FROM NhanVien WHERE MaNV = p_MaNV;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Xoa NhanVien thanh cong!');
    END IF;
END sp_XoaNhanVien;
/
--

SET SERVEROUTPUT ON;

BEGIN
    sp_XoaNhanVien('NV01');
END;
/
BEGIN
    sp_XoaNhanVien('NV99');
END;
/

--h
CREATE OR REPLACE PROCEDURE sp_XoaSanPham (
    p_MaSP IN VARCHAR2
) AS
    v_dem NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem FROM SanPham WHERE MaSP = p_MaSP;

    IF v_dem = 0 THEN
        DBMS_OUTPUT.PUT_LINE('MaSP chua co trong bang SanPham!');
    ELSE
        DELETE FROM Nhap WHERE MaSP = p_MaSP;
        DELETE FROM Xuat WHERE MaSP = p_MaSP;

        DELETE FROM SanPham WHERE MaSP = p_MaSP;
        COMMIT;
        DBMS_OUTPUT.PUT_LINE('Xoa SanPham thanh cong!');
    END IF;
END sp_XoaSanPham;
/
--
SET SERVEROUTPUT ON;
BEGIN
    sp_XoaSanPham('SP01');
END;
/
BEGIN
    sp_XoaSanPham('SP99');
END;
/

--PHIEUBAITAP 2
CREATE OR REPLACE PROCEDURE sp_ThemNhanVien (
    p_MaNV     IN VARCHAR2,
    p_TenNV    IN VARCHAR2,
    p_GioiTinh IN VARCHAR2,
    p_DiaChi   IN VARCHAR2,
    p_SoDT     IN VARCHAR2,
    p_Email    IN VARCHAR2,
    p_TenPhong IN VARCHAR2,
    p_Flag     IN NUMBER,
    p_KQ       OUT NUMBER
) AS
    v_dem NUMBER := 0;
BEGIN
    IF p_GioiTinh <> 'Nam' AND p_GioiTinh <> 'Nu' THEN
        p_KQ := 1;
        RETURN;
    END IF;

    IF p_Flag = 0 THEN
        INSERT INTO NhanVien VALUES (p_MaNV, p_TenNV, p_GioiTinh, p_DiaChi, p_SoDT, p_Email, p_TenPhong);
        COMMIT;
        p_KQ := 0;
    ELSE
        UPDATE NhanVien SET
            TenNV    = p_TenNV,
            GioiTinh = p_GioiTinh,
            DiaChi   = p_DiaChi,
            SoDT     = p_SoDT,
            Email    = p_Email,
            TenPhong = p_TenPhong
        WHERE MaNV = p_MaNV;
        COMMIT;
        p_KQ := 0;
    END IF;
END sp_ThemNhanVien;
/

--TEST
SET SERVEROUTPUT ON;

DECLARE
    v_kq NUMBER;
BEGIN
    sp_ThemNhanVien('NV01', 'Nguyen Van A', 'Nam', 'HCM', '0911111111', 'nva@gmail.com', 'Kinh doanh', 0, v_kq);
    DBMS_OUTPUT.PUT_LINE('Ket qua: ' || v_kq);
END;
/
DECLARE
    v_kq NUMBER;
BEGIN
    sp_ThemNhanVien('NV01', 'Nguyen Van A (sua)', 'Nam', 'HN', '0911111111', 'nva@gmail.com', 'Ke toan', 1, v_kq);
    DBMS_OUTPUT.PUT_LINE('Ket qua: ' || v_kq);
END;
/
DECLARE
    v_kq NUMBER;
BEGIN
    sp_ThemNhanVien('NV02', 'Tran Thi B', 'Khac', 'HN', '0922222222', 'ttb@gmail.com', 'Kho', 0, v_kq);
    DBMS_OUTPUT.PUT_LINE('Ket qua: ' || v_kq);
END;
/
--b
CREATE OR REPLACE PROCEDURE sp_ThemMoiSP (
    p_MaSP      IN VARCHAR2,
    p_MaHangSX  IN VARCHAR2,
    p_TenSP     IN VARCHAR2,
    p_SoLuong   IN NUMBER,
    p_MauSac    IN VARCHAR2,
    p_GiaBan    IN NUMBER,
    p_DonViTinh IN VARCHAR2,
    p_MoTa      IN VARCHAR2,
    p_Flag      IN NUMBER,
    p_KQ        OUT NUMBER
) AS
    v_dem_hang NUMBER := 0;
    v_dem_sp   NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem_hang FROM HangSX WHERE MaHangSX = p_MaHangSX;

    IF v_dem_hang = 0 THEN
        p_KQ := 1;  
        RETURN;
    END IF;

    IF p_SoLuong < 0 THEN
        p_KQ := 2;  
        RETURN;
    END IF;

    IF p_Flag = 0 THEN
        INSERT INTO SanPham VALUES (p_MaSP, p_MaHangSX, p_TenSP, p_SoLuong, p_MauSac, p_GiaBan, p_DonViTinh, p_MoTa);
        COMMIT;
        p_KQ := 0;
    ELSE
        UPDATE SanPham SET
            MaHangSX  = p_MaHangSX,
            TenSP     = p_TenSP,
            SoLuong   = p_SoLuong,
            MauSac    = p_MauSac,
            GiaBan    = p_GiaBan,
            DonViTinh = p_DonViTinh,
            MoTa      = p_MoTa
        WHERE MaSP = p_MaSP;
        COMMIT;
        p_KQ := 0;
    END IF;
END sp_ThemMoiSP;
/

--

SET SERVEROUTPUT ON;

DECLARE
    v_kq NUMBER;
BEGIN
    sp_ThemMoiSP('SP01', 'HSX01', 'Samsung A54', 100, 'Den', 8000000, 'Cai', 'Dien thoai Samsung', 0, v_kq);
    DBMS_OUTPUT.PUT_LINE('Ket qua: ' || v_kq);
END;
/
DECLARE
    v_kq NUMBER;
BEGIN
    sp_ThemMoiSP('SP01', 'HSX01', 'Samsung A54 Pro', 150, 'Trang', 9000000, 'Cai', 'Dien thoai moi', 1, v_kq);
    DBMS_OUTPUT.PUT_LINE('Ket qua: ' || v_kq);
END;
/
DECLARE
    v_kq NUMBER;
BEGIN
    sp_ThemMoiSP('SP02', 'HSX99', 'iPhone 14', 50, 'Trang', 25000000, 'Cai', 'Dien thoai Apple', 0, v_kq);
    DBMS_OUTPUT.PUT_LINE('Ket qua: ' || v_kq);
END;
/
DECLARE
    v_kq NUMBER;
BEGIN
    sp_ThemMoiSP('SP03', 'HSX01', 'Sony WH1000', -5, 'Bac', 5000000, 'Cai', 'Tai nghe Sony', 0, v_kq);
    DBMS_OUTPUT.PUT_LINE('Ket qua: ' || v_kq);
END;
/

-- c
CREATE OR REPLACE PROCEDURE sp_XoaNhanVien_OUT (
    p_MaNV IN VARCHAR2,
    p_KQ   OUT NUMBER
) AS
    v_dem NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem FROM NhanVien WHERE MaNV = p_MaNV;

    IF v_dem = 0 THEN
        p_KQ := 1;  
    ELSE
        DELETE FROM Nhap WHERE SoHDN IN (
            SELECT SoHDN FROM PNhap WHERE MaNV = p_MaNV
        );
        DELETE FROM PNhap WHERE MaNV = p_MaNV;

        DELETE FROM Xuat WHERE SoHDX IN (
            SELECT SoHDX FROM PXuat WHERE MaNV = p_MaNV
        );
        DELETE FROM PXuat WHERE MaNV = p_MaNV;

        DELETE FROM NhanVien WHERE MaNV = p_MaNV;
        COMMIT;
        p_KQ := 0;  
    END IF;
END sp_XoaNhanVien_OUT;
/

--
SET SERVEROUTPUT ON;

DECLARE
    v_kq NUMBER;
BEGIN
    sp_XoaNhanVien_OUT('NV01', v_kq);
    DBMS_OUTPUT.PUT_LINE('Ket qua: ' || v_kq);
END;
/
DECLARE
    v_kq NUMBER;
BEGIN
    sp_XoaNhanVien_OUT('NV99', v_kq);
    DBMS_OUTPUT.PUT_LINE('Ket qua: ' || v_kq);
END;
/

--d
CREATE OR REPLACE PROCEDURE sp_XoaSanPham_OUT (
    p_MaSP IN VARCHAR2,
    p_KQ   OUT NUMBER
) AS
    v_dem NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem FROM SanPham WHERE MaSP = p_MaSP;

    IF v_dem = 0 THEN
        p_KQ := 1;  
    ELSE
        DELETE FROM Nhap WHERE MaSP = p_MaSP;
        DELETE FROM Xuat WHERE MaSP = p_MaSP;
        DELETE FROM SanPham WHERE MaSP = p_MaSP;
        COMMIT;
        p_KQ := 0;  
    END IF;
END sp_XoaSanPham_OUT;
/
--
SET SERVEROUTPUT ON;

DECLARE
    v_kq NUMBER;
BEGIN
    sp_XoaSanPham_OUT('SP01', v_kq);
    DBMS_OUTPUT.PUT_LINE('Ket qua: ' || v_kq);
END;
/
DECLARE
    v_kq NUMBER;
BEGIN
    sp_XoaSanPham_OUT('SP99', v_kq);
    DBMS_OUTPUT.PUT_LINE('Ket qua: ' || v_kq);
END;
/
--e
CREATE OR REPLACE PROCEDURE sp_NhapHangSX_OUT (
    p_MaHangSX IN VARCHAR2,
    p_TenHang  IN VARCHAR2,
    p_DiaChi   IN VARCHAR2,
    p_SoDT     IN VARCHAR2,
    p_Email    IN VARCHAR2,
    p_KQ       OUT NUMBER
) AS
    v_dem NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem FROM HangSX WHERE TenHang = p_TenHang;

    IF v_dem > 0 THEN
        p_KQ := 1;  
    ELSE
        INSERT INTO HangSX VALUES (p_MaHangSX, p_TenHang, p_DiaChi, p_SoDT, p_Email);
        COMMIT;
        p_KQ := 0; 
    END IF;
END sp_NhapHangSX_OUT;
/
--
SET SERVEROUTPUT ON;

DECLARE
    v_kq NUMBER;
BEGIN
    sp_NhapHangSX_OUT('HSX01', 'Samsung', 'Han Quoc', '0123456789', 'samsung@gmail.com', v_kq);
    DBMS_OUTPUT.PUT_LINE('Ket qua: ' || v_kq);
END;
/
DECLARE
    v_kq NUMBER;
BEGIN
    sp_NhapHangSX_OUT('HSX02', 'Samsung', 'Han Quoc', '0987654321', 'samsung2@gmail.com', v_kq);
    DBMS_OUTPUT.PUT_LINE('Ket qua: ' || v_kq);
END;
/

--f
CREATE OR REPLACE PROCEDURE sp_NhapHangNhap_OUT (
    p_SoHDN    IN VARCHAR2,
    p_MaSP     IN VARCHAR2,
    p_MaNV     IN VARCHAR2,
    p_NgayNhap IN DATE,
    p_SoLuongN IN NUMBER,
    p_DonGiaN  IN NUMBER,
    p_KQ       OUT NUMBER
) AS
    v_dem_sp  NUMBER := 0;
    v_dem_nv  NUMBER := 0;
    v_dem_hdn NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem_sp FROM SanPham WHERE MaSP = p_MaSP;

    IF v_dem_sp = 0 THEN
        p_KQ := 1;  
        RETURN;
    END IF;

    SELECT COUNT(*) INTO v_dem_nv FROM NhanVien WHERE MaNV = p_MaNV;

    IF v_dem_nv = 0 THEN
        p_KQ := 2; 
        RETURN;
    END IF;

    SELECT COUNT(*) INTO v_dem_hdn FROM PNhap WHERE SoHDN = p_SoHDN;

    IF v_dem_hdn > 0 THEN
        UPDATE Nhap SET
            SoLuongN = p_SoLuongN,
            DonGiaN  = p_DonGiaN
        WHERE SoHDN = p_SoHDN AND MaSP = p_MaSP;
        COMMIT;
        p_KQ := 0; 
    ELSE
        INSERT INTO PNhap VALUES (p_SoHDN, p_NgayNhap, p_MaNV);
        INSERT INTO Nhap VALUES (p_SoHDN, p_MaSP, p_SoLuongN, p_DonGiaN);
        COMMIT;
        p_KQ := 0;  
    END IF;
END sp_NhapHangNhap_OUT;
/

--Test
SET SERVEROUTPUT ON;
DECLARE
    v_kq NUMBER;
BEGIN
    sp_NhapHangNhap_OUT('HDN01', 'SP01', 'NV01', TO_DATE('01/03/2025', 'DD/MM/YYYY'), 50, 7000000, v_kq);
    DBMS_OUTPUT.PUT_LINE('Ket qua: ' || v_kq);
END;
/
DECLARE
    v_kq NUMBER;
BEGIN
    sp_NhapHangNhap_OUT('HDN01', 'SP01', 'NV01', TO_DATE('01/03/2025', 'DD/MM/YYYY'), 100, 7500000, v_kq);
    DBMS_OUTPUT.PUT_LINE('Ket qua: ' || v_kq);
END;
/
DECLARE
    v_kq NUMBER;
BEGIN
    sp_NhapHangNhap_OUT('HDN02', 'SP99', 'NV01', TO_DATE('01/03/2025', 'DD/MM/YYYY'), 50, 7000000, v_kq);
    DBMS_OUTPUT.PUT_LINE('Ket qua: ' || v_kq);
END;
/
DECLARE
    v_kq NUMBER;
BEGIN
    sp_NhapHangNhap_OUT('HDN02', 'SP01', 'NV99', TO_DATE('01/03/2025', 'DD/MM/YYYY'), 50, 7000000, v_kq);
    DBMS_OUTPUT.PUT_LINE('Ket qua: ' || v_kq);
END;
/

--g
CREATE OR REPLACE PROCEDURE sp_NhapHangXuat_OUT (
    p_SoHDX    IN VARCHAR2,
    p_MaSP     IN VARCHAR2,
    p_MaNV     IN VARCHAR2,
    p_NgayXuat IN DATE,
    p_SoLuongX IN NUMBER,
    p_KQ       OUT NUMBER
) AS
    v_dem_sp  NUMBER := 0;
    v_dem_nv  NUMBER := 0;
    v_dem_hdx NUMBER := 0;
    v_soluong NUMBER := 0;
BEGIN
    SELECT COUNT(*) INTO v_dem_sp FROM SanPham WHERE MaSP = p_MaSP;

    IF v_dem_sp = 0 THEN
        p_KQ := 1;  
        RETURN;
    END IF;
    SELECT COUNT(*) INTO v_dem_nv FROM NhanVien WHERE MaNV = p_MaNV;

    IF v_dem_nv = 0 THEN
        p_KQ := 2;  
        RETURN;
    END IF;
    SELECT SoLuong INTO v_soluong FROM SanPham WHERE MaSP = p_MaSP;

    IF p_SoLuongX > v_soluong THEN
        p_KQ := 3;  
        RETURN;
    END IF;
    SELECT COUNT(*) INTO v_dem_hdx FROM PXuat WHERE SoHDX = p_SoHDX;

    IF v_dem_hdx > 0 THEN
        UPDATE Xuat SET
            SoLuongX = p_SoLuongX
        WHERE SoHDX = p_SoHDX AND MaSP = p_MaSP;
        COMMIT;
        p_KQ := 0;  
    ELSE
        INSERT INTO PXuat VALUES (p_SoHDX, p_NgayXuat, p_MaNV);
        INSERT INTO Xuat VALUES (p_SoHDX, p_MaSP, p_SoLuongX);
        COMMIT;
        p_KQ := 0;  
    END IF;
END sp_NhapHangXuat_OUT;
/

--Test

SET SERVEROUTPUT ON;
DECLARE
    v_kq NUMBER;
BEGIN
    sp_NhapHangXuat_OUT('HDX01', 'SP01', 'NV01', TO_DATE('05/03/2025', 'DD/MM/YYYY'), 10, v_kq);
    DBMS_OUTPUT.PUT_LINE('Ket qua: ' || v_kq);
END;
/
DECLARE
    v_kq NUMBER;
BEGIN
    sp_NhapHangXuat_OUT('HDX01', 'SP01', 'NV01', TO_DATE('05/03/2025', 'DD/MM/YYYY'), 20, v_kq);
    DBMS_OUTPUT.PUT_LINE('Ket qua: ' || v_kq);
END;
/
DECLARE
    v_kq NUMBER;
BEGIN
    sp_NhapHangXuat_OUT('HDX02', 'SP99', 'NV01', TO_DATE('05/03/2025', 'DD/MM/YYYY'), 10, v_kq);
    DBMS_OUTPUT.PUT_LINE('Ket qua: ' || v_kq);
END;
/
DECLARE
    v_kq NUMBER;
BEGIN
    sp_NhapHangXuat_OUT('HDX02', 'SP01', 'NV99', TO_DATE('05/03/2025', 'DD/MM/YYYY'), 10, v_kq);
    DBMS_OUTPUT.PUT_LINE('Ket qua: ' || v_kq);
END;
/
DECLARE
    v_kq NUMBER;
BEGIN
    sp_NhapHangXuat_OUT('HDX02', 'SP01', 'NV01', TO_DATE('05/03/2025', 'DD/MM/YYYY'), 99999, v_kq);
    DBMS_OUTPUT.PUT_LINE('Ket qua: ' || v_kq);
END;
/
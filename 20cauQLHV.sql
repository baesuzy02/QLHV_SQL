--1 In ra danh sách (mã học viên, họ tên, ngày sinh, mã lớp) lớp trưởng của các lớp.
SELECT MAHV, HO,TEN, NGSINH, MALOP
FROM HocVien
WHERE MAHV IN (SELECT TRGLOP FROM Lop)
--2 . In ra bảng điểm khi thi (mã học viên, họ tên , lần thi, điểm số) môn CTRR của lớp “K12”, sắp xếp theo tên, họ học viên.
SELECT HV.MAHV, HV.HO,HV.TEN, BD.LANTHI,BD.DIEM
FROM HOCVIEN HV
INNER JOIN KETQUATHI BD ON HV.MAHV = BD.MAHV
WHERE BD.MAMH = 'CTRR' AND HV.MaLop = 'K12'
ORDER BY HV.HO, HV.TEN
--3. In ra danh sách những học viên (mã học viên, họ tên) và những môn học mà học viên đó thi lần thứ nhất đã đạt.
SELECT HV.MAHV, HV.HO,HV.TEN ,DH.MAMH
FROM HOCVIEN HV
INNER JOIN KETQUATHI DH ON HV.MAHV = DH.MAHV
WHERE DH.LANTHI = 1 AND DH.DIEM >= 5
--4. In ra danh sách học viên (mã học viên, họ tên) của lớp “K11” thi môn CTRR không đạt (ở lần thi 1).
SELECT HV.MAHV, HV.HO, HV.TEN
FROM HOCVIEN HV
INNER JOIN KETQUATHI BD ON HV.MAHV = BD.MAHV
WHERE HV.MaLop = 'K11' AND BD.MAMH = 'CTRR' AND BD.LanThi = 1 AND BD.DIEM < 5

--5. * Danh sách học viên (mã học viên, họ tên) của lớp “K” thi môn CTRR không đạt (ở tất cả các lần thi).
SELECT HV.MAHV, HV.HO, HV.TEN
FROM HOCVIEN HV
WHERE HV.MALOP LIKE 'K%' AND HV.MAHV NOT IN (
  SELECT BD.MAHV
  FROM KETQUATHI BD
  WHERE BD.MAMH = 'CTRR' AND BD.DIEM >= 5
)
--6. Tìm tên những môn học mà giáo viên có tên “Tran Tam Thanh” dạy trong học kỳ 1 năm 2006.
SELECT DISTINCT MH.MAMH, MH.TENMH
FROM MonHoc MH
INNER JOIN GiangDay GD ON MH.MAMH = GD.MAMH
INNER JOIN GiaoVien GV ON GD.MAGV = GV.MAGV
WHERE GV.HOTEN = 'Tran Tam Thanh' AND GD.HocKy = 1 AND GD.NAM = 2006

--7. Tìm những môn học (mã môn học, tên môn học) mà giáo viên chủ nhiệm lớp “K11” dạy trong học kỳ 1 năm 2006.
SELECT DISTINCT MH.MAMH, MH.TENMH
FROM MonHoc MH
INNER JOIN GiangDay GD ON MH.MAMH = GD.MAMH
INNER JOIN Lop L ON GD.MaLop = L.MaLop
INNER JOIN GiaoVien GV ON GD.MAGV = GV.MAGV
WHERE L.TenLop = 'K11' AND GD.HOCKY = 1 AND GD.Nam = 2006 AND L.MAGVCN = GV.MAGV
--8. Tìm họ tên lớp trưởng của các lớp mà giáo viên có tên “Nguyen To Lan” dạy môn “Co So Du Lieu”.
SELECT LopTruong.HO, LopTruong.TEN
FROM Lop
INNER JOIN HocVien AS LopTruong ON Lop.MaLop = LopTruong.MaLop AND Lop.TRGLOP = LopTruong.MAHV
WHERE Lop.MAGVCN = (
    SELECT DISTINCT GiaoVien.MAGV
    FROM GiaoVien
    INNER JOIN MonHoc ON GiaoVien.MAGV = MonHoc.MAGV
    WHERE GiaoVien.HoTen = 'Nguyen To Lan' AND MonHoc.TENMH = 'Co So Du Lieu'
)
--9. In ra danh sách những môn học (mã môn học, tên môn học) phải học liền trước môn “Co So Du Lieu”.
SELECT DISTINCT MonHoc.MAMH, MonHoc.TENMH
FROM MonHoc
INNER JOIN MonHoc AS NextSubject ON MonHoc.MAMH = NextSubject.MAMH
WHERE NextSubject.TENMH = 'Co So Du Lieu'
--10. Môn “Cau Truc Roi Rac” là môn bắt buộc phải học liền trước những môn học (mã môn học, tên môn học) nào.
SELECT DISTINCT MonHoc.MAMH, MonHoc.TENMH
FROM MonHoc
INNER JOIN MonHoc AS PrerequisiteSubject ON MonHoc.MAMH = PrerequisiteSubject.MaMH
WHERE PrerequisiteSubject.TENMH = 'Cau Truc Roi Rac'

--11. Tìm họ tên giáo viên dạy môn CTRR cho cả hai lớp “K11” và “K12” trong cùng học kỳ 1 năm 2006.
SELECT DISTINCT GIAOVIEN.HOTEN AS HoTen
FROM GIAOVIEN
JOIN GIANGDAY ON GIAOVIEN.MAGV = GIANGDAY.MAGV
JOIN MONHOC ON GIANGDAY.MAMH = MONHOC.MAMH
JOIN LOP ON GIANGDAY.MALOP = LOP.MALOP
WHERE MONHOC.TENMH = 'CTRR'
  AND LOP.MALOP IN ('K11', 'K12')
  AND GIANGDAY.HOCKY = 1
  AND YEAR(GIANGDAY.TUNGAY) = 2006
GROUP BY GIAOVIEN.HOTEN
HAVING COUNT(DISTINCT LOP.MALOP) = 2
--12. Tìm những học viên (mã học viên, họ tên) thi không đạt môn CSDL ở lần thi thứ 1 nhưng chưa thi lại môn này.
SELECT HOCVIEN.MAHV, HOCVIEN.HO + ' ' + HOCVIEN.TEN AS HoTen
FROM HOCVIEN
LEFT JOIN KETQUATHI ON HOCVIEN.MAHV = KETQUATHI.MAHV AND KETQUATHI.MAMH = 'CSDL' AND KETQUATHI.LANTHI = 1
WHERE KETQUATHI.MAHV IS NULL
--13. Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào.
SELECT GIAOVIEN.MAGV, GIAOVIEN.HOTEN AS HoTen
FROM GIAOVIEN
LEFT JOIN GIANGDAY ON GIAOVIEN.MAGV = GIANGDAY.MAGV
WHERE GIANGDAY.MAGV IS NULL
--14. Tìm giáo viên (mã giáo viên, họ tên) không được phân công giảng dạy bất kỳ môn học nào thuộc khoa giáo viên đó phụ trách.
SELECT GIAOVIEN.MAGV, GIAOVIEN.HOTEN
FROM GIAOVIEN
LEFT JOIN GIANGDAY ON GIAOVIEN.MAGV = GIANGDAY.MAGV
LEFT JOIN MONHOC ON GIANGDAY.MAMH = MONHOC.MAMH
WHERE MONHOC.MAKHOA = GIAOVIEN.MAKHOA
   OR MONHOC.MAKHOA IS NULL
--15. Tìm họ tên các học viên thuộc lớp “K11” thi một môn bất kỳ quá 3 lần vẫn “Khong dat” hoặc thi lần thứ 2 môn CTRR được 5 điểm.
SELECT HOCVIEN.HO, HOCVIEN.TEN
FROM HOCVIEN
INNER JOIN KETQUATHI ON HOCVIEN.MAHV = KETQUATHI.MAHV
INNER JOIN MONHOC ON KETQUATHI.MAMH = MONHOC.MAMH
WHERE HOCVIEN.MALOP = 'K11'
  AND ((MONHOC.TENMH = 'CTRR' AND KETQUATHI.LANTHI = 2 AND KETQUATHI.DIEM = 5)
       OR (KETQUATHI.KQUA = 'Khong Dat' AND KETQUATHI.LANTHI > 3))
--16. Tìm họ tên giáo viên dạy môn CTRR cho ít nhất hai lớp trong cùng một học kỳ của một năm học.
SELECT DISTINCT GIAOVIEN.HOTEN
FROM GIAOVIEN
INNER JOIN GIANGDAY ON GIAOVIEN.MAGV = GIANGDAY.MAGV
INNER JOIN LOP ON GIANGDAY.MALOP = LOP.MALOP
INNER JOIN MONHOC ON GIANGDAY.MAMH = MONHOC.MAMH
WHERE MONHOC.TENMH = 'CTRR'
GROUP BY GIAOVIEN.HOTEN, GIANGDAY.HOCKY, GIANGDAY.NAM
HAVING COUNT(DISTINCT LOP.MALOP) >= 2
---17 Danh sách học viên và điểm thi môn CSDL (chỉ lấy điểm của lần thi sau cùng).
SELECT HV.MAHV, HV.HO,HV.TEN, BD.DIEM
FROM HocVien HV
INNER JOIN KETQUATHI BD ON HV.MAHV = BD.MAHV
WHERE BD.MAMH = 'CSDL' AND BD.LanThi = (
    SELECT MAX(LanThi)
    FROM KETQUATHI
    WHERE MAHV = HV.MAHV AND MAMH = 'CSDL'
)
--18. Danh sách học viên và điểm thi môn “Co So Du Lieu” (chỉ lấy điểm cao nhất của các lần thi).
SELECT HOCVIEN.MAHV, HOCVIEN.HO, HOCVIEN.TEN, MAX(KETQUATHI.DIEM) AS DIEM
FROM HOCVIEN
INNER JOIN KETQUATHI ON HOCVIEN.MAHV = KETQUATHI.MAHV
INNER JOIN MONHOC ON KETQUATHI.MAMH = MONHOC.MAMH
WHERE MONHOC.TENMH = 'Co So Du Lieu'
GROUP BY HOCVIEN.MAHV, HOCVIEN.HO, HOCVIEN.TEN
--19. Khoa nào (mã khoa, tên khoa) được thành lập sớm nhất. 
SELECT TOP 1 MAKHOA, TENKHOA
FROM KHOA
ORDER BY NGTLAP ASC
--20. Có bao nhiêu giáo viên có học hàm là “GS” hoặc “PGS”.
SELECT COUNT(*)
FROM GIAOVIEN
WHERE HOCHAM = 'GS' OR HOCHAM = 'PGS'

--21 in ra cac giao vien co hoc ham la "GS" hoac "PGS"
SELECT MAGV, HOTEN
FROM GIAOVIEN
WHERE HOCHAM = 'GS' OR HOCHAM = 'PGS'
---

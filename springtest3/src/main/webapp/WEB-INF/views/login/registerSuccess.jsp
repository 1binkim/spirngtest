<%@ page contentType="text/html;charset=UTF-8" language="java" %>
<%@ taglib uri="http://java.sun.com/jsp/jstl/core" prefix="c" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>회원가입 성공</title>

    <!-- Bootstrap CDN -->
    <link rel="stylesheet" href="https://cdn.jsdelivr.net/npm/bootstrap@5.3.2/dist/css/bootstrap.min.css">

    <!-- Google Fonts & Animation -->
    <link href="https://fonts.googleapis.com/css2?family=Nanum+Gothic&display=swap" rel="stylesheet">
    <style>
        body {
            font-family: 'Nanum Gothic', sans-serif;
            background: linear-gradient(to right, #667eea, #764ba2);
            color: white;
            text-align: center;
            padding-top: 80px;
        }
        .card {
            background-color: #ffffff10;
            border: none;
            border-radius: 20px;
            padding: 40px;
            max-width: 500px;
            margin: auto;
            box-shadow: 0 10px 30px rgba(0,0,0,0.2);
            animation: fadeInUp 1s ease-out;
        }
        .btn-purple {
            background-color: #6f42c1;
            border: none;
        }
        .btn-purple:hover {
            background-color: #5a32a3;
        }
        @keyframes fadeInUp {
            from { opacity: 0; transform: translateY(30px); }
            to { opacity: 1; transform: translateY(0); }
        }
    </style>
</head>
<body>

<div class="card">
    <h2 class="mb-4">🎉 회원가입 완료!</h2>
    <p>
        <strong>${sessionScope.loginName}</strong> 님,  
        북마켓에 오신 걸 환영합니다!
    </p>

    <img src="https://cdn-icons-png.flaticon.com/512/942/942748.png" width="100" class="my-3"/>

    <p class="mt-3">지금 바로 로그인하고 도서 서비스를 이용해보세요.</p>
    
    <a href="${pageContext.request.contextPath}/loginForm" class="btn btn-purple btn-lg mt-3">로그인 하기</a>
</div>

</body>
</html>

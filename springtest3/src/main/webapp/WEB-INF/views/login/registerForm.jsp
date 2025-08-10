<%@ page contentType="text/html;charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>회원가입</title>
  <style>
    :root {
      --primary: #2e3e95;
      --bg-page: #f1f3f8;
      --bg-input: #ffffff;
      --border-input: #ced4da;
    }
    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: 'Segoe UI', Tahoma, Geneva, Verdana, sans-serif;
      background-color: var(--bg-page);
      min-height: 100vh;
      display: flex;
      align-items: center;
      justify-content: center;
      padding: 2rem;
    }
    .auth-card {
      background: #fff;
      border-radius: 1rem;
      box-shadow: 0 0.5rem 1.5rem rgba(0, 0, 0, 0.1);
      max-width: 400px;
      width: 100%;
      overflow: hidden;
    }
    .auth-header {
      background-color: var(--primary);
      color: #fff;
      text-align: center;
      padding: 1rem;
      font-size: 1.5rem;
      font-weight: bold;
    }
    .auth-body {
      padding: 2rem;
    }
    .form-group {
      margin-bottom: 1.5rem;
    }
    .form-label {
      display: block;
      margin-bottom: 0.5rem;
      font-weight: 600;
      color: #333;
    }
    .form-control {
      width: 100%;
      height: 3rem;
      padding: 0.5rem 1rem;
      font-size: 1rem;
      color: #495057;
      background-color: var(--bg-input);
      border: 1px solid var(--border-input);
      border-radius: 0.5rem;
    }
    .btn-block {
      display: block;
      width: 100%;
      height: 3rem;
      font-size: 1rem;
      font-weight: 600;
      border-radius: 0.5rem;
      line-height: 3rem;
      text-align: center;
      cursor: pointer;
      text-decoration: none;
    }
    .btn-primary {
      background-color: var(--primary);
      border: none;
      color: #fff;
      margin-bottom: 0.75rem;
    }
    .btn-secondary {
      background-color: transparent;
      border: 2px solid var(--primary);
      color: var(--primary);
    }
    .flash-message {
      margin-top: 1rem;
      margin-bottom: 1.5rem;
      text-align: center;
      font-size: 0.95rem;
    }
    .flash-message.alert-danger { color: #b02a37; }
    .flash-message.alert-success { color: #1e7e34; }
  </style>
</head>
<body>
  <div class="auth-card">
    <div class="auth-header">
      회원가입
    </div>
    <div class="auth-body">
    
      <!-- ✅ 플래시 메시지 먼저 출력 -->
      <c:if test="${not empty error}">
        <div class="flash-message alert-danger">
          ${error}
        </div>
      </c:if>
      <c:if test="${not empty message}">
        <div class="flash-message alert-success">
          ${message}
        </div>
      </c:if>

      <form action="${pageContext.request.contextPath}/register"
            method="post"
            onsubmit="return validateForm();">

        <sec:csrfInput/>

        <div class="form-group">
          <label for="name" class="form-label">이름</label>
          <input type="text" id="name" name="name"
                 class="form-control" required>
        </div>

        <div class="form-group">
          <label for="username" class="form-label">아이디</label>
          <input type="text" id="username" name="username"
                 class="form-control" required>
        </div>

        <div class="form-group">
          <label for="password" class="form-label">비밀번호</label>
          <input type="password" id="password" name="password"
                 class="form-control" required>
        </div>

        <div class="form-group">
          <label for="confirmPassword" class="form-label">비밀번호 확인</label>
          <input type="password" id="confirmPassword" name="confirmPassword"
                 class="form-control" required>
        </div>

        <div class="form-group">
          <label for="email" class="form-label">이메일</label>
          <input type="email" id="email" name="email"
                 class="form-control" required>
        </div>

        <!-- 버튼 그룹 -->
        <button type="submit" class="btn-primary btn-block">
          회원가입
        </button>
        <button type="button" class="btn-secondary btn-block"
                onclick="window.location.href='${pageContext.request.contextPath}/bookstore/books';">
          취소
        </button>
      </form>
    </div>
  </div>

  <script>
    function validateForm() {
      const email = document.getElementById('email').value.trim();
      const pw    = document.getElementById('password').value;
      const cpw   = document.getElementById('confirmPassword').value;
      const emailPattern = /^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$/;
      const pwPattern    = /^(?=.*[A-Z])(?=.*[a-z])(?=.*\d)(?=.*[\W_]).{8,}$/;

      if (!emailPattern.test(email)) {
        alert('올바른 이메일 형식을 입력하세요.');
        return false;
      }
      if (!pwPattern.test(pw)) {
        alert('비밀번호는 8자 이상이며, 대문자·소문자·숫자·특수문자를 포함해야 합니다.');
        return false;
      }
      if (pw !== cpw) {
        alert('비밀번호가 일치하지 않습니다.');
        return false;
      }
      return true;
    }
  </script>
</body>
</html>

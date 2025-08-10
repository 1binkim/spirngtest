<%@ page language="java" contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8"/>
  <title>BookMarket — 로그인</title>
  <!-- 구글 폰트 -->
  <link
    href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR&display=swap"
    rel="stylesheet"/>
  <style>
    /* ─── Reset & 공통 ─── */
    * { box-sizing: border-box; margin: 0; padding: 0; }
    body {
      font-family: 'Noto Sans KR', sans-serif;
      background: #f5f6fa;
      color: #333;
      padding-top: 80px;
    }

    /* ─── 브랜드 컬러 변수 ─── */
    :root {
      --primary:   #1a237e;
      --accent:    #4caf50;
      --errorBg:   #e53935;
      --successBg: #43a047;
      --shadow:    rgba(0,0,0,0.08);
    }

    /* ─── 헤더 ─── */
    header {
      position: fixed; top: 0; left: 0; right: 0; height: 80px;
      background: #fff; box-shadow: 0 2px 8px var(--shadow);
      display: flex; align-items: center; padding: 0 24px; z-index:1000;
    }
    .logo {
      font-size: 1.8em; font-weight: bold; color: var(--primary);
      text-decoration: none;
    }

    /* ─── 레이아웃 ─── */
    .container {
      max-width: 400px;
      margin: 0 auto;
      padding: 20px;
      display: flex;
      flex-direction: column;
      align-items: center;
    }
    .login-box {
      width: 100%;
      background: #fff;
      border-radius: 8px;
      box-shadow: 0 4px 16px var(--shadow);
      padding: 32px;
      margin-top: 60px;
    }
    .login-box h2 {
      text-align: center;
      font-size: 1.6em;
      color: var(--primary);
      margin-bottom: 24px;
    }

    /* ─── 경고/알림 ─── */
    .alert {
      padding: 12px 16px;
      border-radius: 4px;
      margin-bottom: 16px;
      font-size: 0.95em;
    }
    .alert.error { background: var(--errorBg); color: #fff; }
    .alert.success { background: var(--successBg); color: #fff; }

    /* ─── 폼 요소 ─── */
    .form-group {
      margin-bottom: 20px;
    }
    .form-group label {
      display: block;
      font-weight: 600;
      margin-bottom: 6px;
    }
    .form-group input {
      width: 100%;
      padding: 10px 12px;
      border: 1px solid #ccc;
      border-radius: 4px;
      font-size: 1em;
      outline: none;
    }
    .form-group input:focus {
      border-color: var(--primary);
      box-shadow: 0 0 0 2px rgba(26,35,126,0.2);
    }

    /* ─── 버튼 ─── */
    .text-btn {
      width: 100%;
      padding: 12px 0;
      background: var(--primary);
      color: #fff;
      border: none;
      border-radius: 4px;
      font-size: 1em;
      font-weight: 600;
      cursor: pointer;
      transition: filter .2s;
    }
    .text-btn:hover {
      filter: brightness(1.1);
    }
  </style>
</head>
<body>

  <header>
    <a href="${pageContext.request.contextPath}/bookstore/books" class="logo">BookMarket</a>
  </header>

  <div class="container">
    <div class="login-box">
      <h2>로그인</h2>

      <c:if test="${not empty errorMsg}">
        <div class="alert error">${errorMsg}</div>
      </c:if>
      <c:if test="${not empty msg}">
        <div class="alert success">${msg}</div>
      </c:if>

      <form action="<c:url value='/login'/>" method="post">
        <sec:csrfInput/>

        <div class="form-group">
          <label for="username">아이디</label>
          <input type="text" id="username" name="username"
                 value="${param.username}" required />
        </div>

        <div class="form-group">
          <label for="password">비밀번호</label>
          <input type="password" id="password"
                 name="password" required />
        </div>

        <button type="submit" class="text-btn">로그인</button>
      </form>
    </div>
  </div>

</body>
</html>

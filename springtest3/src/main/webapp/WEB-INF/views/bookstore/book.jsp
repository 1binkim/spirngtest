<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c"  uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<%@ taglib prefix="sec" uri="http://www.springframework.org/security/tags" %>
<!DOCTYPE html>
<html lang="ko">
<head>
  <meta charset="UTF-8">
  <title>BookMarket</title>
  <!-- 구글 폰트 -->
  <link href="https://fonts.googleapis.com/css2?family=Noto+Sans+KR&display=swap" rel="stylesheet">
  <style>
    /* ─── Reset & 공통 ─── */
    * { box-sizing: border-box; }
    body {
      margin: 0;
      font-family: 'Noto Sans KR', sans-serif;
      background: #f9f9f9;
      color: #333;
      padding-top: 80px;
    }

    /* ─── 브랜드 컬러 변수 ─── */
    :root {
      --primary: #1a237e;
      --accent:  #4caf50;
      --text-gray: #555;
      --bg-card: #fff;
      --shadow: rgba(0,0,0,0.08);
    }

    /* ─── 헤더 ─── */
    header {
      position: fixed;
      top: 0; left: 0; right: 0;
      height: 80px;
      background: #fff;
      box-shadow: 0 2px 8px var(--shadow);
      display: flex; align-items: center;
      padding: 0 20px;
      z-index: 1000;
    }
    .logo {
      font-size: 1.6em;
      font-weight: bold;
      color: var(--primary);
    }
    .logo a {
      text-decoration: none;
      color: inherit;
    }

    /* ─── 텍스트 버튼 공통 ─── */
    .text-btn {
      display: inline-flex;
      align-items: center;
      justify-content: center;
      padding: 0 14px;
      height: 40px;
      background: var(--primary);
      color: #fff;
      border: none;
      border-radius: 4px;
      font-size: 0.95em;
      text-decoration: none;
      cursor: pointer;
      margin-left: 8px;
      white-space: nowrap;
      transition: filter .2s;
    }
    .text-btn:hover { filter: brightness(1.1); }

    /* ─── 검색 바 ─── */
    .search-bar {
      flex: 1;
      margin: 0 20px;
      display: flex;
    }
    .search-bar input {
      flex: 1;
      height: 40px;
      padding: 0 12px;
      border: 1px solid #ccc;
      border-right: none;
      border-radius: 20px 0 0 20px;
      font-size: 0.95em;
      outline: none;
    }
    .search-bar .text-btn {
      border-radius: 0 20px 20px 0;
      margin-left: 0;
    }

    /* ─── 우측 버튼 그룹 ─── */
    .icons { display: flex; align-items: center; }
    form.logout-form { margin: 0; }

    /* ─── 본문 컨테이너 ─── */
    .container { max-width: 1200px; margin: 0 auto; padding: 20px; }
    .section-title { font-size: 1.5em; font-weight: bold; margin-bottom: 16px; }

    /* ─── 그리드 & 카드 ─── */
    .book-grid {
      display: grid;
      grid-template-columns: repeat(auto-fit, minmax(160px, 1fr));
      gap: 24px;
    }
    .book-card {
      position: relative;
      background: var(--bg-card);
      border: 1px solid #eee;
      border-radius: 6px;
      overflow: hidden;
      text-decoration: none;
      color: inherit;
      transition: box-shadow .2s, transform .2s;
      cursor: pointer;
    }
    .book-card:hover { box-shadow: 0 4px 16px var(--shadow); transform: translateY(-4px); }
    .cover { width: 100%; height: 240px; background-size: cover; background-position: center; }
    .book-info { padding: 12px; }
    .book-title {
      font-size: 0.95em; font-weight: 600; margin: 0 0 4px;
      white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
    }
    .book-author {
      font-size: 0.85em; color: var(--text-gray); margin: 0;
      white-space: nowrap; overflow: hidden; text-overflow: ellipsis;
    }

    /* ─── Hover Overlay ─── */
    .overlay {
      position: absolute; inset: 0; background: rgba(0,0,0,0.4);
      display: flex; align-items: center; justify-content: center;
      opacity: 0; transition: opacity .3s;
    }
    .book-card:hover .overlay { opacity: 1; }
    .overlay-text {
      padding: 8px 16px; background: #fff; border-radius: 4px;
      font-size: 0.9em; font-weight: 600; color: var(--primary);
    }

    /* ─── 반응형 ─── */
    @media (max-width: 600px) {
      .search-bar { flex-direction: column; gap: 6px; }
      .search-bar input, .search-bar .text-btn { width: 100%; border-radius: 8px; }
      .book-grid { grid-template-columns: repeat(2, 1fr); }
    }
  </style>
</head>
<body>

  <!-- 모든 링크/액션은 c:url로 생성 (EL에서 JS 함수 호출 없음) -->
  <c:url var="booksUrl"   value="/bookstore/books"/>
  <c:url var="searchUrl"  value="/search"/><!-- 필요 시 "/bookstore/search"로 조정 -->
  <c:url var="cartUrl"    value="/bookstore/cart"/>
  <c:url var="loginUrl"   value="/loginForm"/>
  <c:url var="registerUrl" value="/register"/>
  <c:url var="mypageUrl"  value="/mypage"/>
  <c:url var="logoutUrl"  value="/logout"/>

  <header>
    <div class="logo">
      <a href="${booksUrl}">BookMarket</a>
    </div>

    <!-- GET 폼은 브라우저가 자동으로 URL-encode 하므로 추가 인코딩 불필요 -->
    <form class="search-bar" action="${searchUrl}" method="get">
      <input type="text" name="q" placeholder="검색어 입력" value="${fn:escapeXml(param.q)}"/>
      <button type="submit" class="text-btn" title="검색">검색</button>
    </form>

    <div class="icons">
      <c:choose>
        <c:when test="${empty sessionScope.loginId}">
          <a href="${loginUrl}" class="text-btn" title="로그인">로그인</a>
          <a href="${registerUrl}" class="text-btn" title="회원가입">회원가입</a>
          <a href="${cartUrl}" class="text-btn" title="장바구니">장바구니</a>
        </c:when>
        <c:otherwise>
          <a href="${mypageUrl}" class="text-btn" title="내 정보">내 정보</a>
          <form class="logout-form" action="${logoutUrl}" method="post" style="display:inline;">
            <sec:csrfInput/>
            <button type="submit" class="text-btn" title="로그아웃">로그아웃</button>
            <a href="${cartUrl}" class="text-btn" title="장바구니">장바구니</a>
          </form>
        </c:otherwise>
      </c:choose>
    </div>
  </header>

  <div class="container">
    <div class="section-title">
      전체 도서 목록 (<c:out value="${fn:length(books)}"/>권)
    </div>
    <div class="book-grid">
      <c:forEach var="book" items="${books}">
        <!-- 상세 페이지 URL도 c:url로 생성 -->
        <c:url var="detailUrl" value="/bookstore/book/${book.bookId}"/>
        <a class="book-card" href="${detailUrl}">
          <div class="cover" style="background-image:url('${book.coverImage}');"></div>
          <div class="book-info">
            <div class="book-title"><c:out value="${book.title}"/></div>
            <div class="book-author"><c:out value="${book.author}"/></div>
          </div>
          <div class="overlay">
            <span class="overlay-text">자세히 보기</span>
          </div>
        </a>
      </c:forEach>
    </div>
  </div>
</body>
</html>

<%@ page contentType="text/html;charset=UTF-8"%>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core"%>
<!DOCTYPE html>
<html lang="ko">
<head>
<meta charset="UTF-8">
<title>${book.title} - 상세보기</title>
<style>
  body { font-family: 'Noto Sans KR', sans-serif; margin:0; padding:0; background:#f9f9f9; }
  .container { max-width: 900px; margin: 50px auto; background: white; padding: 30px; border-radius: 10px; box-shadow: 0 0 10px rgba(0,0,0,0.1); }
  .book-header { display: flex; gap: 30px; }
  .cover { width: 260px; height: 360px; background-size: cover; background-position: center; background-repeat: no-repeat; border-radius: 5px; border: 1px solid #ddd; flex-shrink: 0; }
  .book-info h1 { margin-top: 0; }
  .price { font-size: 1.2rem; font-weight: bold; color: #d9534f; }
  .stock { color: #5cb85c; }
  .btn-area { margin-top: 20px; }
  .btn { display: inline-block; padding: 10px 15px; border: none; border-radius: 5px; text-decoration: none; font-size: 14px; cursor: pointer; }
  .btn-primary { background: #007bff; color: white; }
  .btn-secondary { background: #6c757d; color: white; }
  .book-description { margin-top: 30px; }
</style>
</head>
<body>
  <div class="container">
    <div class="book-header">
      <div class="cover" style="background-image:url('${book.coverImage}');"></div>
      <div class="book-info">
        <h1>${book.title}</h1>
        <p>저자: ${book.author}</p>
        <p class="price"><c:out value="${book.price}"/>원</p>
        <p class="stock">재고: <c:out value="${book.stock}"/>권</p>
        <div class="btn-area">
          <button class="btn btn-primary" onclick="addToCart(${book.bookId}, 1)">장바구니 담기</button>
          <a href="${pageContext.request.contextPath}/bookstore/books" class="btn btn-secondary">목록으로</a>
          <a href="${pageContext.request.contextPath}/bookstore/cart" class="btn btn-secondary">장바구니 보기</a>
        </div>
      </div>
    </div>
    <hr>
    <div class="book-description">
      <h2>책 소개</h2>
      <p><c:out value="${book.description}"/></p>
    </div>
  </div>

<script>
// ===== cart cookie: Base64(btoa(encodeURIComponent(JSON))) + Path=/bookstore =====
function readCart(){
  const m = document.cookie.match(/(?:^|;\s*)cart=([^;]+)/);
  if(!m) return { i: [] };
  try {
    // v2(Base64) 우선
    return JSON.parse(decodeURIComponent(atob(m[1])));
  } catch(e){
    // v1(평문 JSON) 호환
    try { return JSON.parse(decodeURIComponent(m[1])); } catch(e2){ return { i: [] }; }
  }
}

function writeCart(cart){
  const v = btoa(encodeURIComponent(JSON.stringify(cart)));
  var maxAge = 60*60*24*14;
  // 구버전 Path=/ 제거
  document.cookie = 'cart=; Path=/; Max-Age=0; SameSite=Lax';
  document.cookie = 'cart=' + v + '; Path=/bookstore; Max-Age=' + maxAge + '; SameSite=Lax';
}

function addToCart(id, qty=1){
  const c = readCart();
  const hit = c.i.find(x => x.id === id);
  if(hit) hit.q = Math.min(99, hit.q + qty);
  else c.i.push({ id, q: Math.min(99, qty) });
  writeCart(c);
  alert('장바구니에 담았습니다!');
}
</script>
</body>
</html>

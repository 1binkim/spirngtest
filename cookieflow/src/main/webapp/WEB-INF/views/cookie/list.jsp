<%@ page contentType="text/html; charset=UTF-8" pageEncoding="UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html><html><head><meta charset="UTF-8"><title>목록</title></head>
<body>
<h1>상품 목록(데모)</h1>
<table border="1" style="border-collapse: collapse;">
  <tr><th>ID</th><th>제목</th><th>가격</th><th>재고</th><th></th></tr>
  <c:forEach var="it" items="${items}">
    <tr>
      <td>${it.id}</td>
      <td>${it.title}</td>
      <td><c:out value="${it.price}"/>원</td>
      <td><c:out value="${it.stock}"/></td>
      <td>
        <form method="post" action="${pageContext.request.contextPath}/cookie/add">
          <input type="hidden" name="id" value="${it.id}">
          <input type="hidden" name="redirect" value="${pageContext.request.contextPath}/cookie/list">
          <input type="number" name="qty" value="1" min="1" max="${it.stock}" style="width:60px">
          <button type="submit">담기</button>
        </form>
      </td>
    </tr>
  </c:forEach>
</table>

<p><a href="${pageContext.request.contextPath}/cookie/cart">장바구니 보기</a></p>
</body></html>

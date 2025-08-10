<%@ page contentType="text/html; charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html><html><head><meta charset="UTF-8"><title>장바구니</title></head>
<body>
<h1>장바구니</h1>

<c:choose>
  <c:when test="${empty rows}">
    <p>장바구니가 비었습니다.</p>
  </c:when>
  <c:otherwise>
    <table border="1" style="border-collapse: collapse;">
      <tr><th>제목</th><th>가격</th><th>수량</th><th>소계</th><th></th></tr>
      <c:forEach var="r" items="${rows}">
        <tr>
          <td>${r.item.title}</td>
          <td><c:out value="${r.item.price}"/>원</td>
          <td>
            <form method="post" action="${pageContext.request.contextPath}/cookie/update" style="display:inline">
              <input type="hidden" name="id" value="${r.item.id}">
              <input type="number" name="qty" value="${r.qty}" min="1" max="${r.item.stock}" style="width:60px">
              <button type="submit">변경</button>
            </form>
          </td>
          <td><c:out value="${r.subTotal}"/>원</td>
          <td>
            <form method="post" action="${pageContext.request.contextPath}/cookie/remove" style="display:inline">
              <input type="hidden" name="id" value="${r.item.id}">
              <button type="submit">삭제</button>
            </form>
          </td>
        </tr>
      </c:forEach>
    </table>

    <p><b>합계:</b> <c:out value="${total}"/>원</p>

    <form method="post" action="${pageContext.request.contextPath}/cookie/clear">
      <button type="submit">장바구니 비우기</button>
    </form>
  </c:otherwise>
</c:choose>

<p><a href="${pageContext.request.contextPath}/cookie/list">← 계속 쇼핑하기</a></p>
</body></html>
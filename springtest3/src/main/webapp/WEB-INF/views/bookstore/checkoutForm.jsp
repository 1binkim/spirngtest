<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <title>결제 정보 입력</title>
</head>
<body>
    <h1>배송 정보 입력</h1>
    <c:if test="${not empty error}">
        <p style="color:red;">${error}</p>
    </c:if>

<form action="${pageContext.request.contextPath}/bookstore/checkout" method="post">
    <input type="hidden" name="_csrf" value="${_csrf.token}">
    <label>주소</label>
    <input type="text" name="address" placeholder="배송지" required><br>

    <label>우편번호</label>
    <input type="text" name="postcode" placeholder="우편번호" required><br>

    <button type="submit">결제하기</button>
</form>
</body>
</html>

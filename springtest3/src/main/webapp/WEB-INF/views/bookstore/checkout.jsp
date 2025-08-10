<%@ page contentType="text/html;charset=UTF-8" %>
<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@ taglib prefix="fn" uri="http://java.sun.com/jsp/jstl/functions" %>
<!DOCTYPE html>
<html lang="ko">
<head>
    <meta charset="UTF-8">
    <title>결제 정보 입력</title>
</head>
<body>
    <h1>배송 정보 입력</h1>
    
    <!-- 오류 메시지 표시 -->
    <c:if test="${not empty error}">
        <p style="color:red;">${error}</p>
    </c:if>

    <!-- 결제 정보 입력 폼 -->
    <form action="${pageContext.request.contextPath}/bookstore/checkout" method="post">
        <!-- 주소 입력 필드 -->
        <label for="address">주소:</label>
        <input type="text" id="address" name="address" placeholder="배송지" value="${param.address}" required><br>

        <!-- 우편번호 입력 필드 -->
        <label for="postcode">우편번호:</label>
        <input type="text" id="postcode" name="postcode" placeholder="우편번호" value="${param.postcode}" required><br>

        <!-- 결제하기 버튼 -->
        <button type="submit">결제하기</button>
    </form>

</body>
</html>

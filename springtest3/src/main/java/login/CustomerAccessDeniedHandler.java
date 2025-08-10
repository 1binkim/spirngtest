package login;  // 실제 패키지에 맞춰 변경

import org.springframework.security.access.AccessDeniedException;
import org.springframework.security.web.access.AccessDeniedHandler;
import javax.servlet.RequestDispatcher;
import javax.servlet.ServletException;
import javax.servlet.http.*;
import java.io.IOException;

public class CustomerAccessDeniedHandler implements AccessDeniedHandler {

    // 권한 없는 요청이 들어왔을 때 호출됩니다.
    @Override
    public void handle(HttpServletRequest request,
                       HttpServletResponse response,
                       AccessDeniedException accessDeniedException)
            throws IOException, ServletException {
        // (1) 로그 남기기—선택
        System.out.println("Access denied for user: " +
            request.getUserPrincipal() + ", redirecting to accessDenied page.");

        // (2) 포워드 방식
        RequestDispatcher dispatcher =
            request.getRequestDispatcher("/WEB-INF/views/login/accessError.jsp");
        dispatcher.forward(request, response);

        // 또는 리다이렉트 방식
        // response.sendRedirect(request.getContextPath() + "/accessDenied");
    }
}

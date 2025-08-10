package login;

import java.io.IOException;

import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.security.core.Authentication;
import org.springframework.security.web.authentication.AuthenticationSuccessHandler;

import mapper.UserMapper;
import model.User;

public class CustomerLoginSuccessHandler implements AuthenticationSuccessHandler {

    @Autowired
    private UserMapper usermapper;

    @Override
    public void onAuthenticationSuccess(HttpServletRequest req, HttpServletResponse res, Authentication auth)
            throws IOException {
        // 로그인한 사용자 이름으로 DB에서 회원 정보 조회
        String loginId = auth.getName();
        User user = usermapper.findByUsername(loginId);

        // 세션에 사용자 정보 저장
        req.getSession().setAttribute("loginId", loginId);
        req.getSession().setAttribute("loginName", user.getName());

        // 로그인 성공 후 메인 페이지로 이동
        res.sendRedirect(req.getContextPath() + "/welcome");

        // 디버깅용 출력
        System.out.println("[로그인 성공] 사용자 ID: " + loginId + ", 이름: " + user.getName());
    }
}

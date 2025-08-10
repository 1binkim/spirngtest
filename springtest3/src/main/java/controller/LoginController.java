package controller;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestParam;

@Controller
public class LoginController {

    // GET /loginForm → 로그인 페이지
    @GetMapping("/loginForm")
    public String loginForm(
            @RequestParam(value="error",  required=false) String error,
            @RequestParam(value="logout", required=false) String logout,
            Model model) {
        if (error  != null) model.addAttribute("errorMsg", "아이디 또는 비밀번호가 올바르지 않습니다.");
        if (logout != null) model.addAttribute("msg",      "정상적으로 로그아웃 되었습니다.");
        return "login/loginForm";    // → /WEB-INF/views/loginForm.jsp
    }

}

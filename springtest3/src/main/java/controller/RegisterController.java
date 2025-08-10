package controller;

import javax.servlet.http.HttpSession;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestParam;
import org.springframework.web.servlet.mvc.support.RedirectAttributes;

import service.RegisterService;

@Controller
public class RegisterController {

    @Autowired
    private RegisterService registerService;

    // ① GET /register: 회원가입 폼 표시
    @GetMapping("/register")
    public String showForm() {
        return "login/registerForm";
    }

    // ② POST /register: 회원가입 처리
    @PostMapping("/register")
    public String doRegister(@RequestParam String name,
                             @RequestParam String username,
                             @RequestParam String password,
                             @RequestParam String confirmPassword,
                             @RequestParam String email,
                             RedirectAttributes ra,
                             HttpSession session) {

        // 1. 비밀번호 일치 확인
        if (!password.equals(confirmPassword)) {
            ra.addFlashAttribute("error", "비밀번호가 일치하지 않습니다.");
            return "redirect:/register";
        }

        // 2. 비밀번호 형식 검사
        String pwRegex = "^(?=.*[A-Z])(?=.*[a-z])(?=.*\\d)(?=.*[\\W_]).{8,}$";
        if (!password.matches(pwRegex)) {
            ra.addFlashAttribute("error", "비밀번호는 8자 이상이며, 대문자+소문자+숫자+특수문자를 포함해야 합니다.");
            return "redirect:/register";
        }

        try {
            // 3. 회원가입 시도
            boolean ok = registerService.register(name, username, password, email);
            if (!ok) {
                ra.addFlashAttribute("error", "이미 존재하는 아이디입니다.");
                return "redirect:/register";
            }

            // 4. 세션에 사용자 이름 저장
            session.setAttribute("loginName", name);
            return "redirect:/register/success";

        } catch (IllegalArgumentException e) {
            // 이메일 중복 등 사용자 입력 문제 처리
            ra.addFlashAttribute("error", e.getMessage());
            return "redirect:/register";

        } catch (Exception e) {
            // 알 수 없는 서버 오류 처리
            e.printStackTrace(); // 콘솔에 출력
            ra.addFlashAttribute("error", "서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.");
            return "redirect:/register";
        }
    }

    // ③ GET /register/success: 회원가입 성공 페이지
    @GetMapping("/register/success")
    public String showSuccess() {
        return "login/registerSuccess";
    }
}

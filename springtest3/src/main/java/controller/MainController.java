package controller;

import javax.servlet.http.HttpServletRequest;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;

@Controller
public class MainController {

    @GetMapping("/welcome")
    public String welcomePage(HttpServletRequest req, Model model) {
        String name = (String) req.getSession().getAttribute("loginName");
        model.addAttribute("name", name);
        return "welcome"; // /WEB-INF/views/welcome.jsp
    }
}

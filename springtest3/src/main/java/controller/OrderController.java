package controller;

import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.List;
import java.util.Map;

import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;

import mapper.CheckoutMapper;

@Controller
@RequestMapping("/bookstore") // ← URL 앞에 /bookstore 붙습니다
public class OrderController {

    private final CheckoutMapper checkoutMapper;

    // 생성자 주입
    public OrderController(CheckoutMapper checkoutMapper) {
        this.checkoutMapper = checkoutMapper;
    }

    @GetMapping("/order/complete")
    public String orderComplete(@RequestParam("orderId") Long orderId, Model model) throws Exception {
        Map<String, Object> order  = checkoutMapper.findOrderById(orderId);
        if (order == null) {
            String msg = URLEncoder.encode("주문을 찾을 수 없습니다", StandardCharsets.UTF_8);
            return "redirect:/bookstore/cart?error=" + msg;
        }
        List<Map<String, Object>> items = checkoutMapper.findOrderItemsByOrderId(orderId);

        model.addAttribute("order", order);
        model.addAttribute("items", items);
        return "bookstore/orderComplete"; // /WEB-INF/views/bookstore/orderComplete.jsp
    }
}

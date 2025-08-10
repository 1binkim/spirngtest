package controller;

import java.io.UnsupportedEncodingException;
import java.math.BigDecimal;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.stream.Collectors;
import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import org.springframework.stereotype.Controller;
import org.springframework.transaction.annotation.Transactional;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RequestParam;
import com.fasterxml.jackson.databind.JsonNode;
import com.fasterxml.jackson.databind.ObjectMapper;
import lombok.var;
import model.Book;
import mapper.BookMapper;
import mapper.CheckoutMapper;
import mapper.UserMapper;

@Controller
@RequestMapping("/bookstore")
public class CheckoutController {

	private final CheckoutMapper checkoutMapper;
	private final BookMapper bookMapper;
	private final ObjectMapper om = new ObjectMapper();

	private final UserMapper userMapper;
	public CheckoutController(CheckoutMapper checkoutMapper, BookMapper bookMapper, UserMapper userMapper) {
		this.checkoutMapper = checkoutMapper;
		this.bookMapper = bookMapper;
		this.userMapper = userMapper;
	}

	@PostMapping("/checkout")
	@Transactional
	public String checkout(java.security.Principal principal,
			@RequestParam(value="address",required=false) String address,
			@RequestParam(value="postcode",required=false) String postcode,
			HttpServletRequest req, HttpServletResponse res) throws UnsupportedEncodingException {

		if (principal == null || principal.getName() == null) {
			return "redirect:/loginForm";
		}
		String loginId = principal.getName();
		Long userId = userMapper.findUserIdByLoginId(loginId);   // ★ 절대 null 아니어야 함
		if (userId == null) {
			return "redirect:/loginForm?error=" + java.net.URLEncoder.encode("다시 로그인해주세요","UTF-8");
		}
		// 주소/우편번호 검증
		if (address == null || address.isBlank()) {
			String msg = URLEncoder.encode("주소를 입력하세요", StandardCharsets.UTF_8);
			return "redirect:/bookstore/checkoutForm?error=" + msg;
		}
		if (postcode == null || postcode.isBlank()) {
			String msg = URLEncoder.encode("우편번호를 입력하세요", StandardCharsets.UTF_8);
			return "redirect:/bookstore/checkoutForm?error=" + msg;
		}

		// 1) 쿠키 → Map<Long, Integer>
		Map<Long, Integer> wanted = readCartCookieToWantedMap(req);
		if (wanted.isEmpty()) {
			return "redirect:/bookstore/cart?error=장바구니가+비어있습니다";
		}

		// 2) 도서 정보 조회
		List<Book> rows = bookMapper.findByIdList(new ArrayList<>(wanted.keySet()));
		Map<Long, Book> bookMap = rows.stream()
				.collect(Collectors.toMap(Book::getBookId, b -> b));

		// 3) 검증 + 총액 계산
		BigDecimal total = BigDecimal.ZERO;
		for (var e : wanted.entrySet()) {
			Long bookId = e.getKey();
			int qty = e.getValue();
			Book b = bookMap.get(bookId);
			if (b == null) return "redirect:/bookstore/cart?error=존재하지+않는+도서";
			if (qty < 1) return "redirect:/bookstore/cart?error=잘못된+수량";
			if (b.getStock() == null || b.getStock() < qty) {
				return "redirect:/bookstore/cart?error=재고+부족";
			}
			total = total.add(BigDecimal.valueOf(b.getPrice())
					.multiply(BigDecimal.valueOf(qty)));
		}

		// 4) 주문 저장
		Map<String, Object> order = new HashMap<>();
		order.put("userId", userId);
		order.put("status", "PAID");
		order.put("totalAmount", total);
		order.put("address", address);
		order.put("postcode", postcode);
		checkoutMapper.insertOrder(order);

		Long orderId = checkoutMapper.selectCurrOrderId();
		if (orderId == null) {
			return "redirect:/bookstore/cart?error=주문ID+생성실패";
		}

		// 5) 주문 항목 저장 + 재고 차감
		for (var e : wanted.entrySet()) {
			Long bookId = e.getKey();
			int qty = e.getValue();
			BigDecimal unitPrice = BigDecimal.valueOf(bookMap.get(bookId).getPrice());

			Map<String, Object> item = new HashMap<>();
			item.put("orderId", orderId);
			item.put("bookId", bookId);
			item.put("quantity", qty);
			item.put("unitPrice", unitPrice);
			checkoutMapper.insertOrderItem(item);

			int updated = bookMapper.decreaseStock(bookId, qty);
			if (updated == 0) {
				return "redirect:/bookstore/cart?error=결제중+품절";
			}
		}

		// 6) 장바구니 쿠키 삭제
		clearCartCookie(res);

		return "redirect:/bookstore/order/complete?orderId=" + orderId;
	}


	/** cart 쿠키 → Map 변환 */
	private Map<Long, Integer> readCartCookieToWantedMap(HttpServletRequest req) {
		String raw = null;
		if (req.getCookies() != null) {
			for (Cookie c : req.getCookies()) {
				if ("cart".equals(c.getName())) {
					raw = c.getValue();
					break;
				}
			}
		}
		if (raw == null || raw.isEmpty()) return Collections.emptyMap();

		try {
			byte[] decoded = Base64.getDecoder().decode(raw);
			String json = URLDecoder.decode(new String(decoded, StandardCharsets.UTF_8), "UTF-8");
			JsonNode root = om.readTree(json);

			Map<Long, Integer> wanted = new LinkedHashMap<>();
			if (root.has("i") && root.get("i").isArray()) {
				for (JsonNode n : root.get("i")) {
					if (!n.has("id")) continue;
					long id = n.get("id").asLong();
					int q = n.has("q") ? n.get("q").asInt() : 1;
					if (id <= 0) continue;
					q = Math.max(1, q);
					wanted.merge(id, q, Integer::sum);
				}
			}
			return wanted;
		} catch (Exception ignore) {
			return Collections.emptyMap();
		}
	}

	private void clearCartCookie(HttpServletResponse res) {
		Cookie cart = new Cookie("cart", "");
		cart.setPath("/bookstore");
		cart.setMaxAge(0);
		cart.setHttpOnly(false);
		res.addCookie(cart);
	}
	@GetMapping("/checkoutForm")
	public String checkoutForm(@RequestParam(value="error", required=false) String error, Model model) { 
		model.addAttribute("error", error);
		return "bookstore/checkoutForm"; // WEB-INF/views/bookstore/checkoutForm.jsp

	}
}


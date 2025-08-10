package cookieflow;

import com.fasterxml.jackson.core.type.TypeReference;
import com.fasterxml.jackson.databind.ObjectMapper;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.*;

import javax.servlet.http.Cookie;
import javax.servlet.http.HttpServletRequest;
import javax.servlet.http.HttpServletResponse;
import java.net.URLDecoder;
import java.net.URLEncoder;
import java.nio.charset.StandardCharsets;
import java.util.*;
import java.util.Base64;

@Controller
@RequestMapping("/cookie")
public class CookieFlowController {

	private static final String CART_COOKIE = "cart";
	private static final int CART_MAX_AGE = 60 * 60 * 24 * 14; // 14일
	private final ObjectMapper om = new ObjectMapper();

	// 데모용 카탈로그(실제로는 DB)
	private static final Map<Integer, Item> CATALOG = new LinkedHashMap<>();
	static {
		CATALOG.put(1, new Item(1, "토비의 스프링", 45000, 10, "https://.../toby.jpg"));
		CATALOG.put(2, new Item(2, "이펙티브 자바", 40000, 7,  "https://.../effective.jpg"));
		CATALOG.put(3, new Item(3, "클린 코드",     38000, 5,  "https://.../clean.jpg"));
	}

	// 상품 목록
	@GetMapping("/list")
	public String list(Model model) {
		model.addAttribute("items", CATALOG.values());
		return "cookie/list";
	}

	// 장바구니 보기
	@GetMapping("/cart")
	public String cart(HttpServletRequest req, Model model) {
		Map<Integer, Integer> cart = readCart(req);
		List<CartRow> rows = new ArrayList<>();
		long total = 0;

		for (Map.Entry<Integer,Integer> e : cart.entrySet()) {
			Item it = CATALOG.get(e.getKey());
			if (it == null) continue;
			int qty = Math.max(1, Math.min(e.getValue(), it.stock)); // 1~재고
			long sub = (long) it.price * qty;
			total += sub;
			rows.add(new CartRow(it, qty, sub));
		}
		model.addAttribute("rows", rows);
		model.addAttribute("total", total);
		return "cookie/cart";
	}

	// 담기 (POST 권장)
	@PostMapping("/add")
	public String add(HttpServletRequest req, HttpServletResponse res,
			@RequestParam int id,
			@RequestParam(defaultValue = "1") int qty,
			@RequestParam(defaultValue = "/cookie/list") String redirect) {
		Map<Integer, Integer> cart = readCart(req);
		int cur = cart.getOrDefault(id, 0);
		int stock = CATALOG.getOrDefault(id, new Item(id, "", 0, 1, "")).stock;
		int next = Math.max(1, Math.min(cur + qty, Math.max(1, stock)));
		cart.put(id, next);
		writeCart(res, cart);
		return "redirect:" + redirect;
	}

	// 수량 변경
	@PostMapping("/update")
	public String update(HttpServletRequest req, HttpServletResponse res,
			@RequestParam int id, @RequestParam int qty) {
		Map<Integer, Integer> cart = readCart(req);
		if (cart.containsKey(id)) {
			int stock = CATALOG.getOrDefault(id, new Item(id, "", 0, 1, "")).stock;
			int next = Math.max(1, Math.min(qty, Math.max(1, stock)));
			cart.put(id, next);
			writeCart(res, cart);
		}
		return "redirect:/cookie/cart";
	}

	// 삭제
	@PostMapping("/remove")
	public String remove(HttpServletRequest req, HttpServletResponse res, @RequestParam int id) {
		Map<Integer, Integer> cart = readCart(req);
		cart.remove(id);
		writeCart(res, cart);
		return "redirect:/cookie/cart";
	}

	// 비우기
	@PostMapping("/clear")
	public String clear(HttpServletResponse res) {
		deleteCookie(res, CART_COOKIE);
		return "redirect:/cookie/cart";
	}

	// ====== helpers ======
	private Map<Integer, Integer> readCart(HttpServletRequest req) {
		String raw = cookieValue(req, CART_COOKIE);
		if (raw == null || raw.isEmpty()) return new LinkedHashMap<>();
		try {
			// Base64 → URL 디코드 → JSON
			String urlDecoded = URLDecoder.decode(new String(Base64.getDecoder().decode(raw), StandardCharsets.UTF_8), StandardCharsets.UTF_8);
			return om.readValue(urlDecoded, new TypeReference<LinkedHashMap<Integer, Integer>>() {});
		} catch (Exception e) {
			// 구버전(평문 URL-encoded JSON) 호환 시도
			try {
				String json = URLDecoder.decode(raw, StandardCharsets.UTF_8);
				return om.readValue(json, new TypeReference<LinkedHashMap<Integer, Integer>>() {});
			} catch (Exception ignore) {
				return new LinkedHashMap<>();
			}
		}
	}

	private void writeCart(HttpServletResponse res, Map<Integer, Integer> cart) {
		try {
			String json = om.writeValueAsString(cart);                  // JSON
			String enc = URLEncoder.encode(json, StandardCharsets.UTF_8); // URL 인코드
			String b64 = Base64.getEncoder().encodeToString(enc.getBytes(StandardCharsets.UTF_8)); // Base64
			Cookie c = new Cookie(CART_COOKIE, b64);
			c.setPath("/cookie");  // 이 데모 컨텍스트 하위에서만 사용
			c.setMaxAge(CART_MAX_AGE);
			c.setHttpOnly(false);  // 데모 편의상 false (실서비스는 true 권장, JS로 수정 안 할 거면)
			res.addCookie(c);
		} catch (Exception ignored) {}
	}

	private void deleteCookie(HttpServletResponse res, String name) {
		Cookie c = new Cookie(name, "");
		c.setPath("/cookie");
		c.setMaxAge(0);
		res.addCookie(c);
		// 충돌 방지: 과거 Path=/ 로 남은 쿠키 제거
		Cookie old = new Cookie(name, "");
		old.setPath("/");
		old.setMaxAge(0);
		res.addCookie(old);
	}

	private String cookieValue(HttpServletRequest req, String name) {
		Cookie[] arr = req.getCookies();
		if (arr == null) return null;
		for (Cookie c : arr) if (name.equals(c.getName())) return c.getValue();
		return null;
	}

	// ====== 내부 DTO ======
	public static class Item {
		private int id;
		private String title;
		private int price;
		private int stock;
		private String coverImage;
		public Item() {}
		public Item(int id, String title, int price, int stock, String coverImage) {
			this.id = id; this.title = title; this.price = price; this.stock = stock; this.coverImage = coverImage;
		}
		public int getId() { return id; }
		public String getTitle() { return title; }
		public int getPrice() { return price; }
		public int getStock() { return stock; }
		public String getCoverImage() { return coverImage; }
	}

	public static class CartRow {
		private Item item;
		private int qty;
		private long subTotal;
		public CartRow() {}
		public CartRow(Item item, int qty, long subTotal) {
			this.item = item; this.qty = qty; this.subTotal = subTotal;
		}
		public Item getItem() { return item; }
		public int getQty() { return qty; }
		public long getSubTotal() { return subTotal; }
	}

}

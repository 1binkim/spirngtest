package controller;

import lombok.Data;
import mapper.BookMapper;
import model.Book;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.*;

import java.util.*;
import java.util.stream.Collectors;

@RestController
@RequestMapping("/bookstore/cart")
public class CartController {

    @Autowired
    private BookMapper bookMapper;

    /** 클라이언트: { "i": [ { "id": 3, "q": 2 }, ... ] } */
    @PostMapping("/resolve")
    public List<CartItemView> resolve(@RequestBody CartResolveRequest req) {
        if (req == null || req.getI() == null || req.getI().isEmpty()) {
            return Collections.emptyList();
        }
        // 1) id 목록
        List<Long> ids = req.getI().stream()
                .map(Item::getId)
                .filter(Objects::nonNull)
                .distinct()
                .collect(Collectors.toList());
        if (ids.isEmpty()) return Collections.emptyList();

        // 2) DB 조회
        List<Book> books = bookMapper.findByIdList(ids); // 아래 MyBatis 예시 참고

        // 3) id -> qty 매핑
        Map<Long, Integer> qtyMap = req.getI().stream()
                .collect(Collectors.toMap(Item::getId, it -> Math.max(1, Optional.ofNullable(it.getQ()).orElse(1))));

        // 4) 뷰 모델로 변환
        List<CartItemView> out = new ArrayList<>();
        for (Book b : books) {
            CartItemView v = new CartItemView();
            v.setId(b.getBookId());
            v.setTitle(b.getTitle());
            v.setPrice(b.getPrice());
            v.setStock(b.getStock());
            v.setCoverImage(b.getCoverImage()); // DB에 전체 URL 저장 가정
            v.setQty(qtyMap.getOrDefault(b.getBookId(), 1));
            out.add(v);
        }
        // id 순서 유지 (요청 순서 기준)
        Map<Long, CartItemView> map = out.stream().collect(Collectors.toMap(CartItemView::getId, x -> x));
        List<CartItemView> ordered = new ArrayList<>();
        for (Long id : ids) {
            CartItemView v = map.get(id);
            if (v != null) ordered.add(v);
        }
        return ordered;
    }

    // ===== DTOs =====
    @Data
    public static class CartResolveRequest {
        private List<Item> i;
    }
    @Data
    public static class Item {
        private Long id;
        private Integer q; // quantity
    }
    @Data
    public static class CartItemView {
        private Long id;
        private String title;
        private Integer price;
        private Integer stock;
        private String coverImage;
        private Integer qty;
    }
}

package model;

import java.math.BigDecimal;
import lombok.Data;

@Data
public class OrderItem {
    private Long orderItemId;
    private Long orderId;
    private Long bookId;
    private Integer quantity;
    private BigDecimal unitPrice;

    // 조회용(조인으로 받는 필드)
    private String bookTitle;
}

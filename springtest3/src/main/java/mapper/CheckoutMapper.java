package mapper;

import java.util.List;
import java.util.Map;

public interface CheckoutMapper {

    /** 주문 헤더 저장 */
    void insertOrder(Map<String, Object> order);

    /** 직전 생성된 주문 ID 조회 */
    Long selectCurrOrderId();

    /** 주문 항목 저장 */
    void insertOrderItem(Map<String, Object> item);

    /** 완료 화면: 주문 헤더 조회 */
    Map<String, Object> findOrderById(Long orderId);

    /** 완료 화면: 주문 항목 + 책 제목 조회 */
    List<Map<String, Object>> findOrderItemsByOrderId(Long orderId);
}

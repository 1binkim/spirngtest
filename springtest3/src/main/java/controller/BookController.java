package controller;

import java.util.List;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Controller;
import org.springframework.ui.Model;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;

import model.Book;
import service.BookService;

@Controller
public class BookController {

    @Autowired
    private BookService bookservice;

    @GetMapping("/bookstore/books")
    public String bookPage(Model model) {
        List<Book> books = bookservice.getAll(); // Service 사용
        model.addAttribute("books", books);
        return "bookstore/book";
    }
    
    @GetMapping("/bookstore")
    public String redirectToBooks() {
        return "redirect:/bookstore/books";
    }
    /** 상세보기 페이지 */
    @GetMapping("/bookstore/book/{bookId}")
    public String bookDetail(@PathVariable("bookId") Long bookId, Model model) {
        // 1) bookId로 DB에서 책 한 권 조회
        Book book = bookservice.getOne(bookId);

        // 2) 없으면 404 페이지로 이동하거나 에러 처리
        if (book == null) {
            return "error/404"; // 뷰 이름 예시
        }

        // 3) 모델에 책 정보 담기
        model.addAttribute("book", book);

        // 4) 상세보기 JSP로 이동
        return "bookstore/bookDetail"; 
    }
    
    @GetMapping("/bookstore/cart")
    public String cartPage(){
        return "bookstore/cart"; // /WEB-INF/views/bookstore/cart.jsp
    }
}

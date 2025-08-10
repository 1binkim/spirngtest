package model;

import lombok.Data;
import lombok.NoArgsConstructor;
import lombok.AllArgsConstructor;

@Data
@NoArgsConstructor
@AllArgsConstructor
public class Book {
    private Long bookId;
    private String title;
    private String author;
    private String description;
    private Integer price;
    private Integer stock;
    private String coverImage;
}

package dto;

public class CartViewItem {
    private long id;
    private String title;
    private int price;
    private int qty;
    private String coverImage;
    private int stock;

    public CartViewItem() {}
    public CartViewItem(long id, String title, int price, int qty, String coverImage, int stock) {
        this.id = id; this.title = title; this.price = price; this.qty = qty; this.coverImage = coverImage; this.stock = stock;
    }

    public long getId() { return id; }
    public void setId(long id) { this.id = id; }
    public String getTitle() { return title; }
    public void setTitle(String title) { this.title = title; }
    public int getPrice() { return price; }
    public void setPrice(int price) { this.price = price; }
    public int getQty() { return qty; }
    public void setQty(int qty) { this.qty = qty; }
    public String getCoverImage() { return coverImage; }
    public void setCoverImage(String coverImage) { this.coverImage = coverImage; }
    public int getStock() { return stock; }
    public void setStock(int stock) { this.stock = stock; }
}

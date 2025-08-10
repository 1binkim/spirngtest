package model;

import lombok.Data;

@Data
public class User {
    private Long userId;
    private String loginId;
    private String password;
    private String name;
    private String email;
    private String hp;
    private String role;
}